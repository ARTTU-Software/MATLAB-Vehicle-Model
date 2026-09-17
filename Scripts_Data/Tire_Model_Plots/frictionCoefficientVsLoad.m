%% Peak tire friction coefficient versus vertical load
function results = frictionCoefficientVsLoad(loadsN, pressureBar, camberDeg)
%FRICTIONCOEFFICIENTVSLOAD Plot peak lateral and longitudinal load sensitivity.
%   results = frictionCoefficientVsLoad(loadsN, pressureBar, camberDeg)
%   creates separate lateral and longitudinal figures. Pressure OR camber
%   may be an array to compare sensitivity curves, but not both at once.
%
%   loadsN      Vertical tire loads [N]
%   pressureBar Inflation pressure(s) [bar]
%   camberDeg   Camber/inclination angle(s) [deg]
%
%   Examples:
%     frictionCoefficientVsLoad(100:100:1800, 0.8, 0)
%     frictionCoefficientVsLoad(100:100:1800, 0.8, [-3 -1 0 1 3])
%     frictionCoefficientVsLoad(100:100:1800, [0.6 0.8 0.95], 0)

if nargin < 1 || isempty(loadsN)
    loadsN = linspace(100, 1800, 18);
end
if nargin < 2 || isempty(pressureBar)
    pressureBar = 0.8;
end
if nargin < 3 || isempty(camberDeg)
    camberDeg = 0;
end

validateattributes(loadsN, {'numeric'}, ...
    {'real','finite','positive','vector','nonempty'}, mfilename, 'loadsN');
validateattributes(pressureBar, {'numeric'}, ...
    {'real','finite','positive','vector','nonempty'}, mfilename, 'pressureBar');
validateattributes(camberDeg, {'numeric'}, ...
    {'real','finite','vector','nonempty'}, mfilename, 'camberDeg');

if ~isscalar(pressureBar) && ~isscalar(camberDeg)
    error('frictionCoefficientVsLoad:MultipleSensitivitySweeps', ...
        'Pressure and camber cannot both be arrays. Sweep only one at a time.');
end

loadsN = loadsN(:);
caseCount = max(numel(pressureBar), numel(camberDeg));

pressureBarCases = pressureBar(:).';
if isscalar(pressureBarCases)
    pressureBarCases = repmat(pressureBarCases, 1, caseCount);
end

camberDegCases = camberDeg(:).';
if isscalar(camberDegCases)
    camberDegCases = repmat(camberDegCases, 1, caseCount);
end

tirFile = 'Hoosier_R20B_20p5x7_R13_7in.tir';
Vx = 15;  % Forward speed [m/s]
phit = 0; % Turn slip [1/m]
useMode = 111;

tirParameters = mfeval.readTIR(tirFile);
pressurePaCases = pressureBarCases * 1e5;
camberRadCases = deg2rad(camberDegCases);

if any(loadsN < tirParameters.FZMIN | loadsN > tirParameters.FZMAX)
    error('frictionCoefficientVsLoad:LoadOutsideTIRRange', ...
        'Loads must remain inside the TIR validity range [%.0f, %.0f] N.', ...
        tirParameters.FZMIN, tirParameters.FZMAX);
end
if any(pressurePaCases < tirParameters.PRESMIN | ...
        pressurePaCases > tirParameters.PRESMAX)
    error('frictionCoefficientVsLoad:PressureOutsideTIRRange', ...
        'Pressure must remain inside the TIR validity range [%.3g, %.3g] bar.', ...
        tirParameters.PRESMIN/1e5, tirParameters.PRESMAX/1e5);
end
if any(camberRadCases < tirParameters.CAMMIN | ...
        camberRadCases > tirParameters.CAMMAX)
    error('frictionCoefficientVsLoad:CamberOutsideTIRRange', ...
        'Camber must remain inside the TIR validity range [%.2f, %.2f] deg.', ...
        rad2deg(tirParameters.CAMMIN), rad2deg(tirParameters.CAMMAX));
end

% Sweep the full pure-slip ranges declared valid by the tire model.
nSlipPoints = 401;
kappaRange = linspace(tirParameters.KPUMIN, tirParameters.KPUMAX, nSlipPoints);
alphaRange = linspace(0, tirParameters.ALPMAX, nSlipPoints);
nLoads = numel(loadsN);

muLateral = zeros(nLoads, caseCount);
alphaAtPeakLateralDeg = zeros(nLoads, caseCount);
muLongitudinal = zeros(nLoads, caseCount);
kappaAtPeakLongitudinal = zeros(nLoads, caseCount);

for caseIndex = 1:caseCount
    pressurePa = pressurePaCases(caseIndex);
    camberRad = camberRadCases(caseIndex);

    % Pure longitudinal sweep: alpha = 0.
    [kappaGrid, loadGridLong] = meshgrid(kappaRange, loadsN);
    nLong = numel(kappaGrid);
    longInputs = [ ...
        loadGridLong(:), ...
        kappaGrid(:), ...
        zeros(nLong,1), ...
        camberRad * ones(nLong,1), ...
        phit      * ones(nLong,1), ...
        Vx        * ones(nLong,1), ...
        pressurePa * ones(nLong,1)];
    longOutput = mfeval(tirParameters, longInputs, useMode);
    Fx = reshape(longOutput(:,1), size(kappaGrid));

    [peakLongitudinalForce, longitudinalIndex] = max(abs(Fx), [], 2);
    muLongitudinal(:,caseIndex) = peakLongitudinalForce ./ loadsN;
    kappaAtPeakLongitudinal(:,caseIndex) = ...
        kappaRange(longitudinalIndex).';

    % Pure lateral sweep: kappa = 0. The peak is found independently at
    % every load, rather than assuming one fixed slip angle.
    [alphaGrid, loadGridLat] = meshgrid(alphaRange, loadsN);
    nLat = numel(alphaGrid);
    latInputs = [ ...
        loadGridLat(:), ...
        zeros(nLat,1), ...
        alphaGrid(:), ...
        camberRad * ones(nLat,1), ...
        phit      * ones(nLat,1), ...
        Vx        * ones(nLat,1), ...
        pressurePa * ones(nLat,1)];
    latOutput = mfeval(tirParameters, latInputs, useMode);
    Fy = reshape(latOutput(:,2), size(alphaGrid));

    [peakLateralForce, lateralIndex] = max(abs(Fy), [], 2);
    muLateral(:,caseIndex) = peakLateralForce ./ loadsN;
    alphaAtPeakLateralDeg(:,caseIndex) = ...
        rad2deg(alphaRange(lateralIndex).');
end

% Return one row per load and sensitivity case.
loadColumn = repmat(loadsN, caseCount, 1);
pressureColumn = repelem(pressureBarCases(:), nLoads);
camberColumn = repelem(camberDegCases(:), nLoads);
results = table(loadColumn, pressureColumn, camberColumn, ...
    muLateral(:), alphaAtPeakLateralDeg(:), muLongitudinal(:), ...
    kappaAtPeakLongitudinal(:), ...
    'VariableNames', {'LoadN','PressureBar','CamberDeg', ...
    'MuLateralPeak','AlphaAtLateralPeakDeg','MuLongitudinalPeak', ...
    'KappaAtLongitudinalPeak'});

colors = lines(caseCount);

% Lateral load-sensitivity figure.
figure('Color','w','Name','Lateral friction load sensitivity');
hold on;
for caseIndex = 1:caseCount
    plot(loadsN, muLateral(:,caseIndex), 'o-', 'LineWidth', 2, ...
        'Color', colors(caseIndex,:), ...
        'DisplayName', localCaseLabel(pressureBarCases, camberDegCases, ...
        caseIndex));
end
grid on;
box on;
xlabel('Vertical load F_z [N]');
ylabel('Peak lateral coefficient \mu_y = max|F_y|/F_z');
title(sprintf('Peak Lateral Friction vs Load, V_x = %.1f m/s', Vx));
if caseCount > 1
    legend('Location','best');
end

% Longitudinal load-sensitivity figure.
figure('Color','w','Name','Longitudinal friction load sensitivity');
hold on;
for caseIndex = 1:caseCount
    plot(loadsN, muLongitudinal(:,caseIndex), 's-', 'LineWidth', 2, ...
        'Color', colors(caseIndex,:), ...
        'DisplayName', localCaseLabel(pressureBarCases, camberDegCases, ...
        caseIndex));
end
grid on;
box on;
xlabel('Vertical load F_z [N]');
ylabel('Peak longitudinal coefficient \mu_x = max|F_x|/F_z');
title(sprintf('Peak Longitudinal Friction vs Load, V_x = %.1f m/s', Vx));
if caseCount > 1
    legend('Location','best');
end
end

function label = localCaseLabel(pressureBarCases, camberDegCases, caseIndex)
if numel(unique(pressureBarCases)) > 1
    label = sprintf('P = %.2f bar', pressureBarCases(caseIndex));
elseif numel(unique(camberDegCases)) > 1
    label = sprintf('Camber = %.1f deg', camberDegCases(caseIndex));
else
    label = sprintf('P = %.2f bar, Camber = %.1f deg', ...
        pressureBarCases(caseIndex), camberDegCases(caseIndex));
end
end
