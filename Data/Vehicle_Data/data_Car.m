function Car = data_Car
%% 1. Geometrie și Mase (FSAE_Achilles)
Car.m    = 319;       % Masa totală cu pilot [kg]
Car.L    = 1.575;     % Ampatament (Wheelbase) [m]
Car.a    = 0.8232;    % Distanța CoG - axa față (lf) [m]
Car.b    = Car.L - Car.a; % Distanța CoG - axa spate (lr) [m]
Car.i_st = 6.5618;    % Raport de direcție (Steering ratio) [-]
Car.h    = 0.358;
%% 2. Inerție
Car.Izz    = 140;     % Moment de inerție pe axa Z [kg*m^2]

%% 3. Parametri Anvelope (Cornering & Longitudinal)
Car.C_a_FA = 39672*2;     % Cornering stiffness punte față [N/rad]
Car.C_a_RA = 43105*2;     % Cornering stiffness punte spate [N/rad]

% Așteptăm valorile exacte de la Andrei mâine; acum punem estimări (50.000)
Car.C_k_FA = 39726*2;     % Longitudinal stiffness punte față [N/slip]
Car.C_k_RA = 43677*2;     % Longitudinal stiffness punte spate [N/slip]

