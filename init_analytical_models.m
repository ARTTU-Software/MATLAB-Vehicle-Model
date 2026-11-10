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
Params.Car.Fmax_f = Params.Physics.mu * Params.Car.Fzf_static;
Params.Car.Fmax_r = Params.Physics.mu * Params.Car.Fzr_static;


%% Initial Conditions
Params.Sim.vx_init = 1;     % Viteza longitudinală de start [m/s]

