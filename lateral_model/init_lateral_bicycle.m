% clear; clc;
%% 1. Vehicle Geometry & Mass Parameters (FSAE_Achilles)
Params.Car.m    = 319;   % Total vehicle mass with driver [kg]
Params.Car.L    = 1.575;    % Wheelbase [m]
Params.Car.a    = 0.8232;   % Distance from CoG to front axle (lf) [m]
Params.Car.b    = Params.Car.L - Params.Car.a; % Distance from CoG to rear axle (lr) [m]
Params.Car.i_st = 6.5618;     % Steering ratio [-]

%% 2. Chassis Inertia
% Yaw moment of inertia around the vertical axis (Z)
Params.Car.Izz  = 140;      % Yaw moment of inertia [kg*m^2] (reference estimate)

%% 3. Tire Parameters (Linear Range / Small Angles)
% Cornering stiffness per axle (sum of both tires on the axle)
Params.Car.C_af =46504;    % Front axle cornering stiffness [N/rad] (reference estimate)
Params.Car.C_ar = 48872;    % Rear axle cornering stiffness [N/rad] (reference estimate)

%% 4. Operating Condition (Constant Forward Speed)
% Dynamic bicycle model assumes constant longitudinal velocity
Params.Sim.vx_const = 12; % Constant longitudinal speed [m/s] (~36 km/h)
