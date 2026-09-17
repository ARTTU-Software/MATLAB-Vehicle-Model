%% MFeval friction-envelope plot
function fricitonElipse(Fz, pressureBar, camberDeg,mode)
%FRICITONELIPSE Plot one tire friction envelope or a one-variable sweep.
%   fricitonElipse(Fz, pressureBar, camberDeg)
%   Input Variables:
%   - Fz            - tire load in N;
%   - pressureBar   - tire inflation pressure in bar;
%   - camberDeg     - tire inclination angle in deg;
%   - mode          - ellipse mode:  - friction  - friction circle
%                                    - force     - combined forces ellipse
%
%   Examples:
%     fricitonElipse(500, 0.8, 0, 'friction')              % Single point cloud
%     fricitonElipse([500 1000 1500], 0.8, 0, 'friction')  % Load sweep
%     fricitonElipse(500, [0.6 0.8 0.9], 0, 'friction')    % Pressure sweep
%     fricitonElipse(500, 0.8, [-2 0 2], 'friction')        % Camber sweep

tirFile = 'Hoosier_R20B_20p5x7_R13_7in_v2.tir';

% Defaults. Make at most ONE input an array to overlay its envelopes.
if nargin < 1 || isempty(Fz)
    Fz = 500;                         % Vertical load(s) [N]
end
if nargin < 2 || isempty(pressureBar)
    pressureBar = [0.45 0.55 0.8 0.9 1]; % Inflation pressure(s) [bar]
end
if nargin < 3 || isempty(camberDeg)
    camberDeg = 0;                    % Camber angle(s) [deg]
end

Vx   = 15; % Forward speed [m/s]
phit = 0;  % Turn slip [1/m]

validateattributes(Fz, {'numeric'}, ...
    {'real','finite','positive','vector','nonempty'}, mfilename, 'Fz');
validateattributes(pressureBar, {'numeric'}, ...
    {'real','finite','positive','vector','nonempty'}, mfilename, 'pressureBar');
validateattributes(camberDeg, {'numeric'}, ...
    {'real','finite','vector','nonempty'}, mfilename, 'camberDeg');

sweepFlags = [~isscalar(Fz), ~isscalar(pressureBar), ~isscalar(camberDeg)];
if nnz(sweepFlags) > 1
    error('fricitonElipse:MultipleSweeps', ...
        ['Only one operating condition may be an array. Set two of Fz, ' ...
        'pressureBar, and camberDeg to scalar values.']);
end

hasSweep = any(sweepFlags);
caseCount = max([numel(Fz), numel(pressureBar), numel(camberDeg)]);

FzCases = Fz(:).';
if isscalar(FzCases)
    FzCases = repmat(FzCases, 1, caseCount);
end

pressureBarCases = pressureBar(:).';
if isscalar(pressureBarCases)
    pressureBarCases = repmat(pressureBarCases, 1, caseCount);
end
pressurePaCases = pressureBarCases * 1e5;

camberDegCases = camberDeg(:).';
if isscalar(camberDegCases)
    camberDegCases = repmat(camberDegCases, 1, caseCount);
end
camberRadCases = deg2rad(camberDegCases);

% Adjust these ranges to the validity limits of the .tir model
kappaRange = linspace(-0.2, 0.2, 161);       % Slip ratio [-]
alphaRange = deg2rad(linspace(-12, 12, 161));  % Slip angle [rad]

% Generate every kappa/alpha combination
[kappaGrid, alphaGrid] = meshgrid(kappaRange, alphaRange);

kappa = kappaGrid(:);
alpha = alphaGrid(:);
n     = numel(kappa);

% Reading the file once is faster than parsing it on every evaluation
tirParameters = mfeval.readTIR(tirFile);

if isfield(tirParameters, 'PRESMIN') && isfield(tirParameters, 'PRESMAX')
    outsidePressureRange = pressurePaCases < tirParameters.PRESMIN | ...
        pressurePaCases > tirParameters.PRESMAX;
    if any(outsidePressureRange)
        warning('fricitonElipse:PressureOutsideTIRRange', ...
            ['Pressure(s) %s bar are outside the TIR validity range ' ...
            '[%.3g, %.3g] bar and will be saturated by MFeval.'], ...
            mat2str(pressureBarCases(outsidePressureRange)), ...
            tirParameters.PRESMIN/1e5, tirParameters.PRESMAX/1e5);
    end
end

figure('Color','w');
hold on;
colors = lines(caseCount);

for caseIndex = 1:caseCount
    caseFz = FzCases(caseIndex);
    casePressureBar = pressureBarCases(caseIndex);
    casePressurePa = pressurePaCases(caseIndex);
    caseCamberDeg = camberDegCases(caseIndex);
    caseCamberRad = camberRadCases(caseIndex);

    % MFeval inputs:
    % [Fz, kappa, alpha, gamma, turnSlip, Vx, pressure]
    inputs = [ ...
        caseFz         * ones(n,1), ...
        kappa, ...
        alpha, ...
        caseCamberRad  * ones(n,1), ...
        phit           * ones(n,1), ...
        Vx             * ones(n,1), ...
        casePressurePa * ones(n,1)];

    % 111 = combined slip, conventional alpha definition, limit checks enabled
    output = mfeval(tirParameters, inputs, 111);

    Fx = output(:,1);
    Fy = output(:,2);

    % Remove invalid results
    valid = isfinite(Fx) & isfinite(Fy);
    Fx = Fx(valid);
    Fy = Fy(valid);

    % Lateral friction is plotted horizontally and longitudinal vertically.

    switch mode

        case 'force'
            % Take calculated forces directly
            elipsePoints = unique([Fy, Fx],'rows'); 
        case 'friction'
            % Transform from forces to friction coefficient
            elipsePoints = unique([Fy/caseFz, Fx/caseFz], 'rows');
    end
    % Outer convex envelope of the sampled combined-slip force set
    hullIndex = convhull(elipsePoints(:,1), elipsePoints(:,2));

    if hasSweep
        if sweepFlags(1)
            caseLabel = sprintf('F_z = %.0f N', caseFz);
        elseif sweepFlags(2)
            caseLabel = sprintf('P = %.2f bar (%.1f psi)', ...
                casePressureBar, casePressurePa/6894.757);
        else
            caseLabel = sprintf('Camber = %.1f deg', caseCamberDeg);
        end
        scatter(elipsePoints(:,1), elipsePoints(:,2), 5, ...
            'Color', colors(caseIndex,:),...
            'HandleVisibility','off');
        plot(elipsePoints(hullIndex,1), elipsePoints(hullIndex,2), ...
            'Color', colors(caseIndex,:), 'LineWidth', 2, ...
            'DisplayName', caseLabel);
    else
        scatter(elipsePoints(:,1), elipsePoints(:,2), 5, ...
            hypot(elipsePoints(:,1),elipsePoints(:,2)), 'filled', ...
            'HandleVisibility','off');
        plot(elipsePoints(hullIndex,1), elipsePoints(hullIndex,2), ...
            'k-', 'LineWidth', 2, 'HandleVisibility','off');
    end
end

axis equal;
grid on;
box on;


if hasSweep
    if sweepFlags(1)
        title(sprintf(['Load Sweep: P = %.2f bar, Camber = %.1f deg, ' ...
            'V_x = %.1f m/s'], pressureBarCases(1), camberDegCases(1), Vx));
    elseif sweepFlags(2)
        title(sprintf(['Pressure Sweep: F_z = %.0f N, Camber = %.1f deg, ' ...
            'V_x = %.1f m/s'], FzCases(1), camberDegCases(1), Vx));
    else
        title(sprintf(['Camber Sweep: F_z = %.0f N, P = %.2f bar, ' ...
            'V_x = %.1f m/s'], FzCases(1), pressureBarCases(1), Vx));
    end
    legend('Location','best');
else
    switch mode
        case 'friction'
             title(sprintf(['Tire Friction Envelope: F_z = %.0f N, P = %.2f bar, ' ...
                      'Camber = %.1f deg, V_x = %.1f m/s'], ...
                     FzCases(1), pressureBarCases(1), camberDegCases(1), Vx));
              xlabel('\mu_y = F_y/F_z');
              ylabel('\mu_x = F_x/F_z');
        case 'force'
            title(sprintf(['Tire Force Envelope: F_z = %.0f N, P = %.2f bar, ' ...
                'Camber = %.1f deg, V_x = %.1f m/s'], ...
                FzCases(1), pressureBarCases(1), camberDegCases(1), Vx));
            xlabel('\F_y');
            ylabel('\F_x');
    end
end
switch mode
    case 'friction'
        xlabel('Lateral Friction Coef. \mu_y = F_y/F_z [~]');
        ylabel('Longitudinal Friction Coef. \mu_x = F_x/F_z [~]');
    case 'force'
        xlabel('Lateral Force F_y [N]');
        ylabel('Lonigtudinal Force F_x [N]');
end
end
