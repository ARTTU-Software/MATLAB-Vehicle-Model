function Params = get_vehicle_params()
%#codegen
% Physical parameters
Params.Physics.g              = 9.81;               % Gravitational acceleration [m/s^2]
Params.Physics.ro             = 1.225;              % Air density [kg/m^3]

% Ecu parameters
Params.TimeStep               = 0.003;              % Time step for integration

% Vehicle parameters
Params.Car.SteerR      = 6.56;      % Steering Ratio 
Params.Car.a           = 0.8232;     % Distance from CoG to front axle[ m]
Params.Car.b           = 0.7518;     % Distance from CoG to rear axle [m]
Params.Car.tf          = 1.28;      % Front track [m]
Params.Car.tr          = 1.25;      % Rear track [m]
Params.Car.m           = 319;       % Mass [kg]
Params.Car.L           = 1.578;     % Wheelbase
Params.Car.b_cop       = 0.868;     % Distance from center of pressure to rear axle [m]
Params.Car.a_cop       = 0.707;       % Distance from center of pressure to front axle [m]
Params.Car.h_cog       = 0.3583;      % CoG height [m]
Params.Car.Izz         = 140;       % Yaw inertia [kg*m^2]
Params.Car.Af          = 1.2;       % Frontal area [m^2]
Params.Car.cl          = -2.15;     % Lift coefficient [~] -0.9
Params.Car.cd          = -1;        % Drag coefficient [~] -0.8
% General tire parameters
Params.Car.f          = 0.02;      % Rolling resistance coef [~]
Params.Car.r_load     = 0.263;     % Load tire radius [m]
% =========================================================
% TIRE BUILDER
% Build the BaseTire first to prevent MATLAB Coder errors
% =========================================================


% --- Essential Longitudinal Parameters ---
BaseTire.long.Fz0   = 838;      % Nominal load
BaseTire.long.LFZ0  = 1;         % Scale factor load
BaseTire.long.LMUX  = 1;         % Peak friction scale
BaseTire.long.LCX   = 1;         % Shape factor scale
BaseTire.long.LEX   = 1;         % Curvature factor scale
BaseTire.long.LKX   = 1;         % Stiffness scale
BaseTire.long.LHX   = 1;         % Horizontal shift scale
BaseTire.long.LVX   = 1;         % Vertical shift scale
BaseTire.long.LXAL  = 1;         % Combined stiffness scale

% Pure Longitudinal Coeffs
BaseTire.long.PCX1  = 2.24241;   % Shape factor Cfx
BaseTire.long.PDX1  = 2.36211;   % Friction Mux at Fznom
BaseTire.long.PDX2  = -0.08032;  % Friction variation with load
BaseTire.long.PEX1  = 1.17108;  % Curvature Efx at Fznom
BaseTire.long.PEX2  = 0.56377;  % Curvature variation with load
BaseTire.long.PEX3  = -0.53965;   % Curvature variation with load squared
BaseTire.long.PEX4  = 0.33255;  % Asymmetry factor (driving vs braking)
BaseTire.long.PKX1  = 52.83;    % Slip stiffness Kfx/Fz at Fznom
BaseTire.long.PKX2  = 14.967;    % Stiffness variation with load
BaseTire.long.PKX3  = -0.45489;  % Stiffness exponent with load
BaseTire.long.PHX1  = -0.00084;  % Horizontal shift Shx
BaseTire.long.PHX2  = -0.00152;   % Shift variation with load
BaseTire.long.PVX1  = 0.05557;   % Vertical shift Svx/Fz
BaseTire.long.PVX2  = -0.02002;  % Shift variation with load

% Combined Slip Coefs
BaseTire.long.RBX1  = 12.427;    % Slope factor
BaseTire.long.RBX2  = 12.906;    % Slope variation with kappa
BaseTire.long.RCX1  = 1.25;   % Shape factor
BaseTire.long.REX1  = 0.43111;   % Curvature factor
BaseTire.long.REX2  = 0.28174;     % Curvature variation with load
BaseTire.long.RHX1  = 0.01;   % Shift factor

% --- Essential Lateral Parameters ---
BaseTire.lat.Fz0   = 838;      % Nominal load
BaseTire.lat.LCY   = 1;         % Shape factor scale
BaseTire.lat.LEY   = 1;         % Curvature factor scale
BaseTire.lat.LKY   = 1;         % Cornering stiffness scale
BaseTire.lat.LHY   = 1;         % Horizontal shift scale
BaseTire.lat.LVY   = 1;         % Vertical shift scale
BaseTire.lat.LYKA  = 1;         % Kappa influence scale
BaseTire.lat.LVYKA = 1;         % Kappa induced Fy scale
BaseTire.lat.LMUY  = 1;         % Peak friction scale
BaseTire.lat.LFZ0  = 1;         % Scale factor load

% Pure Lateral Coefs
BaseTire.lat.PCY1  = 1.6873;   % Shape factor Cfy
BaseTire.lat.PDY1  = 2.4002;   % Lateral friction Muy
BaseTire.lat.PDY2  = -0.2292;  % Friction variation with load
BaseTire.lat.PEY1  = 0.55024;   % Curvature Efy
BaseTire.lat.PEY2  = -0.01809;  % Curvature variation with load
BaseTire.lat.PKY1  = -73.376;   % Max stiffness Kfy/Fznom
BaseTire.lat.PKY2  = 5.75433;   % Load for max stiffness
BaseTire.lat.PKY4  = 4.61143;   % Curvature of stiffness
BaseTire.lat.PHY1  = 0.00225;   % Horizontal shift Shy
BaseTire.lat.PHY2  = 0.00099;   % Shift variation with load
BaseTire.lat.PVY1  = 0.03587;   % Vertical shift Svy
BaseTire.lat.PVY2  = 0.01566;   % Shift variation with load

% Combined Slip Coefs
BaseTire.lat.RBY1  = 15.813;    % Slope factor
BaseTire.lat.RBY2  = 19.816;     % Slope variation with alpha
BaseTire.lat.RBY3  = 0.04847;   % Alpha shift
BaseTire.lat.RCY1  = 1.11166;   % Shape factor
BaseTire.lat.REY1  = 0.40022;  % Curvature factor
BaseTire.lat.REY2  = 0.28721;   % Curvature variation with load
BaseTire.lat.RHY1  = 0.00334;     % Shift factor
BaseTire.lat.RHY2  = 0.00402;   % Shift variation with load
BaseTire.lat.RVY1  = 0;  % Kappa induced side force
BaseTire.lat.RVY2  = 0;  % variation with load
BaseTire.lat.RVY4  = 0;   % variation with alpha
BaseTire.lat.RVY5  = 0;   % variation with kappa
BaseTire.lat.RVY6  = 25.014;    % variation with atan(kappa)

% =========================================================
% TIRE SPLITTER (Left/Right Assignment)
% =========================================================

% 1. Create Left and Right versions from the base
TireRight = BaseTire;
TireLeft  = BaseTire;

% 2. Invert lateral shifts for the Left tires (Conicity/Plysteer mirror)
TireLeft.lat.PHY1 = -BaseTire.lat.PHY1;
TireLeft.lat.PHY2 = -BaseTire.lat.PHY2;
TireLeft.lat.PVY1 = -BaseTire.lat.PVY1;
TireLeft.lat.PVY2 = -BaseTire.lat.PVY2;

% 3. Attach them cleanly to the main Params struct
Params.TireRight = TireRight;
Params.TireLeft  = TireLeft;

end