function results = tireStiffness(Fz, pressureBar, camberDeg, tirFile)
%TIRESTIFFNESS Plot pure-slip forces and their stiffness tangents at zero slip.
%   results = tireStiffness(Fz, pressureBar, camberDeg, tirFile)
%   overlays one Fy(alpha) and Fx(kappa) curve per vertical load, with
%   dashed tangents at zero slip, and prints a stiffness table.
%
%   Fz          Positive vertical load(s) [N]; default [500 1000 1500].
%   pressureBar Scalar inflation pressure [bar]; default 0.8.
%   camberDeg   Scalar camber/inclination angle [deg]; default 0.
%   tirFile     Optional TIR filename/path; default is the project's
%               Hoosier_R20B_20p5x7_R13_7in_v2.tir.
%
%   Stiffness magnitudes are abs(dFy/dalpha) [N/rad] and abs(dFx/dkappa)
%   [N/unit slip ratio], evaluated at alpha = kappa = 0. Signed slopes are
%   also returned and printed to retain the model's force convention.
%   Force offsets at zero slip are retained in the plotted tangents.
%   These numerical slopes need not equal MFeval's nominal Kya/Kxk when
%   the fitted curves contain horizontal shifts.
%
%   Examples:
%     tireStiffness([500 1000 1500])
%     results = tireStiffness([400; 800; 1200], 0.8, -2);
%     tireStiffness(1000, 0.8, 0, 'another_tire.tir');

if nargin < 1 || isempty(Fz)
    Fz = [500 1000 1500];
end
if nargin < 2 || isempty(pressureBar)
    pressureBar = 0.8;
end
if nargin < 3 || isempty(camberDeg)
    camberDeg = 0;
end
if nargin < 4 || isempty(tirFile)
    projectFolder = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    tirFile = fullfile(projectFolder, 'Libraries', 'Vehicle', 'Tire', ...
        'Data_TIR', 'Hoosier_R20B_20p5x7_R13_7in.tir');
end

validateattributes(Fz, {'numeric'}, ...
    {'real','finite','positive','vector','nonempty'}, mfilename, 'Fz');
validateattributes(pressureBar, {'numeric'}, ...
    {'real','finite','positive','scalar'}, mfilename, 'pressureBar');
validateattributes(camberDeg, {'numeric'}, ...
    {'real','finite','scalar'}, mfilename, 'camberDeg');

Fz = double(Fz(:));
pressurePa = double(pressureBar) * 1e5;
camberRad = deg2rad(double(camberDeg));
tirParameters = mfeval.readTIR(char(tirFile));

% Reject invalid conditions rather than silently reporting clipped inputs.
localCheckRange(Fz, tirParameters.FZMIN, tirParameters.FZMAX, 'Fz [N]');
localCheckRange(pressurePa, tirParameters.PRESMIN, ...
    tirParameters.PRESMAX, 'Pressure [Pa]');
localCheckRange(camberRad, tirParameters.CAMMIN, ...
    tirParameters.CAMMAX, 'Camber [rad]');

alphaStep = 1e-5; % Central-difference spacing [rad]
kappaStep = 1e-5; % Central-difference spacing [unit slip ratio]
localCheckRange([-alphaStep alphaStep], tirParameters.ALPMIN, ...
    tirParameters.ALPMAX, 'Slip-angle derivative samples [rad]');
localCheckRange([-kappaStep kappaStep], tirParameters.KPUMIN, ...
    tirParameters.KPUMAX, 'Slip-ratio derivative samples [-]');

Vx = 15;       % Forward speed [m/s]
useMode = 111; % Conventional slip angle, limit checks enabled, no turn slip
alpha = unique([linspace(tirParameters.ALPMIN, ...
    tirParameters.ALPMAX, 401), -alphaStep, 0, alphaStep]).';
kappa = unique([linspace(tirParameters.KPUMIN, ...
    tirParameters.KPUMAX, 401), -kappaStep, 0, kappaStep]).';
nLoads = numel(Fz);
Fy = zeros(numel(alpha), nLoads);
Fx = zeros(numel(kappa), nLoads);
signedCorneringSlope = zeros(nLoads, 1);
signedLongitudinalSlope = zeros(nLoads, 1);

for loadIndex = 1:nLoads
    % MFeval inputs: [Fz, kappa, alpha, gamma, turnSlip, Vx, pressure].
    lateralInputs = repmat( ...
        [Fz(loadIndex), 0, 0, camberRad, 0, Vx, pressurePa], numel(alpha), 1);
    lateralInputs(:,3) = alpha;
    lateralOutput = mfeval(tirParameters, lateralInputs, useMode);
    Fy(:,loadIndex) = lateralOutput(:,2);

    longitudinalInputs = repmat( ...
        [Fz(loadIndex), 0, 0, camberRad, 0, Vx, pressurePa], numel(kappa), 1);
    longitudinalInputs(:,2) = kappa;
    longitudinalOutput = mfeval(tirParameters, longitudinalInputs, useMode);
    Fx(:,loadIndex) = longitudinalOutput(:,1);

    signedCorneringSlope(loadIndex) = ...
        (Fy(alpha == alphaStep,loadIndex) - ...
        Fy(alpha == -alphaStep,loadIndex)) / (2*alphaStep);
    signedLongitudinalSlope(loadIndex) = ...
        (Fx(kappa == kappaStep,loadIndex) - ...
        Fx(kappa == -kappaStep,loadIndex)) / (2*kappaStep);
end

if any(~isfinite(Fy(:))) || any(~isfinite(Fx(:)))
    error('tireStiffness:NonfiniteForce', ...
        'The tire model returned nonfinite forces at the requested conditions.');
end

corneringStiffness = abs(signedCorneringSlope);
longitudinalStiffness = abs(signedLongitudinalSlope);
results = table(Fz, corneringStiffness, ...
    longitudinalStiffness, signedCorneringSlope, signedLongitudinalSlope, ...
    'VariableNames', {'Fz_N','CorneringStiffness_N_per_rad', ...
    'LongitudinalStiffness_N_per_unitSlip', ...
    'dFy_dAlpha_N_per_rad','dFx_dKappa_N_per_unitSlip'});

fprintf('\nTire stiffness from force-curve slopes at zero slip\n');
fprintf('TIR: %s\n', char(tirFile));
fprintf('Pressure: %.3g bar; camber: %.3g deg; speed: %.3g m/s\n', ...
    pressureBar, camberDeg, Vx);
fprintf(['Stiffness columns are magnitudes; dFy/dAlpha and dFx/dKappa ' ...
    'retain the model signs.\n']);
fprintf('Longitudinal stiffness is per unit slip ratio, not per percent slip.\n');
disp(results);

colors = lines(nLoads);
caseLabels = compose("F_z = %g N", Fz);
conditionLabel = sprintf('P = %.2f bar, camber = %.1f deg, V_x = %.1f m/s', ...
    pressureBar, camberDeg, Vx);

lateralFigure = figure('Color','w','Name','Cornering stiffness from Fy');
lateralAxes = axes('Parent', lateralFigure);
colororder(lateralAxes, colors);
plot(lateralAxes, rad2deg(alpha), Fy, 'LineWidth', 1.8);
hold(lateralAxes, 'on');
% Keep tangents near zero so they do not obscure the nonlinear curves.
alphaTangent = [max(alpha(1), -deg2rad(1)); ...
    min(alpha(end), deg2rad(1))];
fyTangent = Fy(alpha == 0,:) + alphaTangent * signedCorneringSlope.';
for loadIndex = 1:nLoads
    plot(lateralAxes, rad2deg(alphaTangent), fyTangent(:,loadIndex), '--', ...
        'Color', colors(loadIndex,:), 'LineWidth', 1.5, ...
        'HandleVisibility','off');
end
grid(lateralAxes, 'on');
box(lateralAxes, 'on');
xlabel(lateralAxes, 'Slip angle \alpha [deg]');
ylabel(lateralAxes, 'Lateral force F_y [N]');
title(lateralAxes, {'Cornering stiffness: dashed zero-slip tangents', conditionLabel});
legend(lateralAxes, caseLabels + compose(", C_{\\alpha} = %.1f N/rad", ...
    corneringStiffness), 'Location','best');

longitudinalFigure = figure('Color','w','Name','Longitudinal stiffness from Fx');
longitudinalAxes = axes('Parent', longitudinalFigure);
colororder(longitudinalAxes, colors);
plot(longitudinalAxes, kappa, Fx, 'LineWidth', 1.8);
hold(longitudinalAxes, 'on');
kappaTangent = [max(kappa(1), -0.02); min(kappa(end), 0.02)];
fxTangent = Fx(kappa == 0,:) + kappaTangent * signedLongitudinalSlope.';
for loadIndex = 1:nLoads
    plot(longitudinalAxes, kappaTangent, fxTangent(:,loadIndex), '--', ...
        'Color', colors(loadIndex,:), 'LineWidth', 1.5, ...
        'HandleVisibility','off');
end
grid(longitudinalAxes, 'on');
box(longitudinalAxes, 'on');
xlabel(longitudinalAxes, 'Slip ratio \kappa [-]');
ylabel(longitudinalAxes, 'Longitudinal force F_x [N]');
title(longitudinalAxes, {'Longitudinal stiffness: dashed zero-slip tangents', conditionLabel});
legend(longitudinalAxes, caseLabels + compose(", C_{\\kappa} = %.0f N/unit slip", ...
    longitudinalStiffness), 'Location','best');
end

function localCheckRange(values, lowerLimit, upperLimit, label)
if any(values < lowerLimit | values > upperLimit)
    error('tireStiffness:OutsideTIRRange', ...
        '%s must be inside the TIR validity range [%g, %g].', ...
        label, lowerLimit, upperLimit);
end
end
