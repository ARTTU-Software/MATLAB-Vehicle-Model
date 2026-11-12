clear;
clc;
%% Default maneuver
load("dlc3dof.mat");
MODE = 3; % 2 - bicycle 2 dof; 3 - bicycle 3 dof

%% Assign Vehicle Parameters from file
Params.Car = data_Car;

%% Physics

Physics.g  = 9.81;    % Accelerația gravitațională [m/s^2]
Physics.mu = 2.5;    % Coeficientul de frecare maxim estimat (Kamm)

% Assign physics value to data structure
Params.Physics = Physics;
clear Physics;

%% Add friction circle values

% Apăsarea statică pe axa față și spate [N]
Params.Car.Fzf_static = Params.Car.m * Params.Physics.g * (Params.Car.b / Params.Car.L);
Params.Car.Fzr_static = Params.Car.m * Params.Physics.g * (Params.Car.a / Params.Car.L);

% Bugetul maxim de forță pe care îl poate genera anvelopa înainte de a derapa [N]
Params.Car.Fmax_FA = Params.Physics.mu * Params.Car.Fzf_static;
Params.Car.Fmax_RA = Params.Physics.mu * Params.Car.Fzr_static;


%% Initial Conditions
Params.Sim.vx_init = 1;     % Viteza longitudinală de start [m/s]
Params.Sim.vyInitial = 0;      % Initial lateral speed [m/s]
Params.Sim.yawRateInitial = 0; % Initial yaw rate [rad/s]

%% 3-DOF limits and tire force input
Params.Sim.vxMin = 0.1;       % Minimum longitudinal speed and slip denominator [m/s]
Params.Sim.vxMax = 40;        % Maximum longitudinal speed [m/s]
Params.Sim.vyMaxAbs = 15;     % Maximum lateral speed magnitude [m/s]
Params.Sim.frontLongitudinalForce = 0; % Ideal front longitudinal tire force [N]

