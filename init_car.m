%% Script de Initializare Vehicul - Quarter Car Model
% Proiect: Suspensie Double Wishbone cu Pushrod
clear; clc;

%% 1. Geometrie: Hardpoints (Coordonate [x, y, z])
% Am setat coordonatele astfel incat bratele sa iasa direct pe axa Y.
% Sasiul (cubul gri) are latimea de 0.2m, deci fata laterala este la Y = 0.1.

% --- Brat Superior (Upper Arm) ---
% P1: Prindere pe sasiu (Y=0.1 inseamna lipit de sasiu)
Chassis.SuspA1.hp_u_chassis_front = [0.2, 0.1, 0.15];  
% P2: Prindere pe fuzeta (Y=0.4 inseamna un brat de 30cm)
Chassis.SuspA1.hp_upright_u       = [0.2, 0.4, 0.15];  

% --- Brat Inferior (Lower Arm) ---
% P1: Prindere pe sasiu (mai jos, la Z = -0.05)
Chassis.SuspA1.hp_l_chassis_front = [0.2, 0.1, 0.05]; 
% P2: Prindere pe fuzeta
Chassis.SuspA1.hp_upright_l       = [0.2, 0.4, 0.05]; 

% --- Fuzeta (Upright) ---
% Dimensiunile pentru piesa verde in Simulink ar trebui sa fie [0.05, 0.05, 0.2]
Chassis.SuspA1.upright_mass       = 1.5;     % Masa [kg]

% --- Sistem Pushrod & Bellcrank ---
% Punctul de unde pleaca tija de pe brat (la mijlocul bratului inferior)
Chassis.SuspA1.hp_pushrod_out     = [0.17, 0.34, 0.05]; 
% Pivotul balansierului (Bellcrank) pe sasiu
% Z_rel=0.10 => Z_abs=0.35m (in interiorul sasiului, deasupra centrului)
% Sasiul are centrul R la Z_world=0.25m (din Transform Chassis [0,0,0.25] din SLX)
Chassis.SuspA1.hp_bcr_pivot       = [0.18, 0.05, 0.22];
% Punct prindere Pushrod pe balansier: brat ~0.11m, orientat spre exterior-sus
% (pushrod-ul vine din exterior-jos de la hp_pushrod_out=[0.17,0.34,-0.05])
Chassis.SuspA1.hp_bcr_pushrod     = [0.24, 0.08, 0.25];
% Punct prindere amortizor pe balansier: brat ~0.08m, unghi ~110 grade fata de brat pushrod
Chassis.SuspA1.hp_bcr_shock       = [0.12, 0.05, 0.27];
% Capatul de sus al pushrod-ului = punctul de pe balansier
Chassis.SuspA1.hp_pushrod_in      = Chassis.SuspA1.hp_bcr_pushrod;

%% 2. Calcule Automate pentru Simscape (Norma si Jumatea)
% Aceste variabile le folosesti in Rigid Transforms la "Offset"

% Braț Superior (V-shape)
Chassis.SuspA1.hp_u_front = [0.1, 0.1, 0.35]; % x, y, z
Chassis.SuspA1.hp_u_rear  = [0.3, 0.1, 0.35]; 
Chassis.SuspA1.hp_u_out   = [0.2, 0.4, 0.35]; 

% Braț Inferior (V-shape)
Chassis.SuspA1.hp_l_front = [0.05, 0.1, 0.05];
Chassis.SuspA1.hp_l_rear  = [0.35, 0.1, 0.05];
Chassis.SuspA1.hp_l_out   = [0.2, 0.4, 0.05];

% Pushrod
P_in = Chassis.SuspA1.hp_pushrod_in;
P_out = Chassis.SuspA1.hp_pushrod_out;
Chassis.SuspA1.pushrod_length = norm(P_out - P_in);
Chassis.SuspA1.pushrod_half_length = Chassis.SuspA1.pushrod_length / 2;

%% 3. Proprietati de Masa si Inertie
Chassis.Body.Mass_Total      = 60;   % Masa sasiu [kg]
Chassis.SuspA1.wheel_mass    = 12.0; % Masa roata [kg]
Chassis.SuspA1.bcr_mass      = 0.4;  % Masa Bellcrank [kg]

% Matrice de inertie sasiu (exemplu cub)
Chassis.Body.Inertia_Tensor = [1.2, 0, 0; 0, 1.5, 0; 0, 0, 1.8];

%% 4. Arcuri si Amortizoare
Chassis.SuspA1.spring_rate   = 80000; % [N/m]
Chassis.SuspA1.damping_coeff = 3500;  % [Ns/m]
Chassis.SuspA1.free_length   = 0.25;  % [m]
% hp_shock_chassis: X,Y identice cu hp_bcr_shock=[0.10, 0.05, 0.12]
% Distanta initiala = 0.22m (arc pre-comprimat 30mm fata de free_length=0.25m)
% => forta initiala arc = 80000*0.03 = 2400N => roata apasata pe sol
% dZ = 0.22m => z = 0.12 - 0.22 = -0.10 (Z_abs = -0.10+0.25 = 0.15m, in sasiu)
Chassis.SuspA1.hp_shock_chassis = [0.12, 0.05, 0.02];
hp_b = [0, 0, 0];
hp_f = [0.1, 0.4, 0];

disp('>>> Scriptul init_car a fost incarcat! Geometrie Double Wishbone pregatita.');
