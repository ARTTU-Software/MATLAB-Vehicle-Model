% clear; clc;

%% 1. Geometrie și Mase (FSAE_Achilles)
Params.Car.m    = 319;       % Masa totală cu pilot [kg]
Params.Car.L    = 1.575;     % Ampatament (Wheelbase) [m]
Params.Car.a    = 0.8232;    % Distanța CoG - axa față (lf) [m]
Params.Car.b    = Params.Car.L - Params.Car.a; % Distanța CoG - axa spate (lr) [m]
Params.Car.i_st = 6.5618;    % Raport de direcție (Steering ratio) [-]

%% 2. Inerție și Constante Fizice
Params.Car.Izz    = 140;     % Moment de inerție pe axa Z [kg*m^2]
Params.Physics.g  = 9.81;    % Accelerația gravitațională [m/s^2]
Params.Physics.mu = 2.5;    % Coeficientul de frecare maxim estimat (Kamm)

%% 3. Parametri Anvelope (Cornering & Longitudinal)
Params.Car.C_af = 46504 * 2;     % Cornering stiffness punte față [N/rad]
Params.Car.C_ar = 48872 * 2;     % Cornering stiffness punte spate [N/rad]

% Așteptăm valorile exacte de la Andrei mâine; acum punem estimări (50.000)
Params.Car.C_kf = 39736 * 2;     % Longitudinal stiffness punte față [N/slip]
Params.Car.C_kr = 43677 * 2;     % Longitudinal stiffness punte spate [N/slip]

%% 4. Condiții Inițiale (Plecarea în test)
Params.Sim.vx_init = 1;     % Viteza longitudinală de start [m/s]

%% 5. Bugetul Static de Aderență (Friction Circle Limits)
% Apăsarea statică pe axa față și spate [N]
Params.Car.Fzf_static = Params.Car.m * Params.Physics.g * (Params.Car.b / Params.Car.L);
Params.Car.Fzr_static = Params.Car.m * Params.Physics.g * (Params.Car.a / Params.Car.L);

% Bugetul maxim de forță pe care îl poate genera anvelopa înainte de a derapa [N]
Params.Car.Fmax_f = Params.Physics.mu * Params.Car.Fzf_static;
Params.Car.Fmax_r = Params.Physics.mu * Params.Car.Fzr_static;