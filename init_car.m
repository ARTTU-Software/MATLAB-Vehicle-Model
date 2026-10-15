%% Quarter Car Model 
clear; clc;

%% 1. Geometry: Hardpoints (Coordinates [x, y, z] in meters)
% --- Upper Wishbone (Upper Arm) ---
Chassis.SuspA1.hp_u_chassis_front = [0.152882, 0.207316, 0.271782]; 
Chassis.SuspA1.hp_u_chassis_rear  = [-0.180729, 0.225000, 0.250894]; 
Chassis.SuspA1.hp_upright_u       = [-0.012087, 0.521103, 0.381500]; 

% --- Lower Wishbone (Lower Arm) ---
Chassis.SuspA1.hp_l_chassis_front = [0.200000, 0.203347, 0.076350];
Chassis.SuspA1.hp_l_chassis_rear  = [-0.196000, 0.225000, 0.076350];
Chassis.SuspA1.hp_upright_l       = [0.011982, 0.588501, 0.152500];

Chassis.SuspA1.hp_u_front = Chassis.SuspA1.hp_u_chassis_front;
Chassis.SuspA1.hp_u_rear  = Chassis.SuspA1.hp_u_chassis_rear;
Chassis.SuspA1.hp_u_out   = Chassis.SuspA1.hp_upright_u;
Chassis.SuspA1.hp_l_front = Chassis.SuspA1.hp_l_chassis_front;
Chassis.SuspA1.hp_l_rear  = Chassis.SuspA1.hp_l_chassis_rear;
Chassis.SuspA1.hp_l_out   = Chassis.SuspA1.hp_upright_l;

% --- Upright & Wheel Hub ---
Chassis.SuspA1.wheel_center       = [0.000000, 0.640000, 0.266500];
Chassis.SuspA1.upright_cg         = [0.016810, 0.582170, 0.281090]; 

% --- Pushrod & Bellcrank System ---
Chassis.SuspA1.hp_pushrod_out     = [0.011607, 0.543330, 0.173935]; 
Chassis.SuspA1.hp_bcr_pivot       = [0.009900, 0.244890, 0.277836];
Chassis.SuspA1.hp_bcr_pushrod     = [0.009540, 0.351996, 0.310579];
Chassis.SuspA1.hp_bcr_shock       = [0.009519, 0.318301, 0.312066];
Chassis.SuspA1.hp_shock_chassis   = [0.007846, 0.233225, 0.468064];

Chassis.SuspA1.hp_pushrod_in      = Chassis.SuspA1.hp_bcr_pushrod;

%% 2. Automatic Calculations for Simscape
Chassis.SuspA1.pushrod_length = norm(Chassis.SuspA1.hp_pushrod_out - Chassis.SuspA1.hp_pushrod_in);
Chassis.SuspA1.pushrod_half_length = Chassis.SuspA1.pushrod_length / 2;

%% 3. Mass and Inertia Properties (from Excel)
Chassis.Body.Mass_Total      = 255.07; 
Chassis.SuspA1.upright_mass  = 1.0;        
Chassis.SuspA1.wishbone_u_m  = 0.12;   
Chassis.SuspA1.wishbone_l_m  = 0.165; 
Chassis.SuspA1.wheel_mass    = 10.0;  
Chassis.SuspA1.bcr_mass      = 0.4;    
Chassis.Body.Inertia_Tensor  = [27, 0, 0; 0, 74, 0; 0, 0, 70]; 

%% 4. Springs and Dampers (from Excel)
Chassis.SuspA1.spring_rate   = 10; 
Chassis.SuspA1.spring_preload= 0.008;   
Chassis.SuspA1.damping_coeff = 1000;     
Chassis.SuspA1.free_length   = 0.25;    

disp('>>> init_car script loaded successfully!');