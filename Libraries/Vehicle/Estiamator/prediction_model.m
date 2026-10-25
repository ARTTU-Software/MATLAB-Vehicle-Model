function x_next = prediction_model(x, u)
%#codegen
% u     = [ delta  omega_fl omega_fr omega_rl omega_rr ]
% x     = [ v_x v_y Phi Phi_dot a_x a_y ]
% x_dot = [ v_x_dot v_y_dot Phi_dot a_x_dot a_y_dot]

% Get States
v_x           = x(1);
v_y           = x(2);
Phi_dot       = x(3);
a_x           = x(4);
a_y           = x(5);

% Get Parameters
miu_rd        = 0.85;
Params        = get_vehicle_params();

% Get Inputs
delta         = u(1) / Params.Car.SteerR;
omega_fl      = u(2);
omega_fr      = u(3); 
omega_rl      = u(4); 
omega_rr      = u(5); 

eps           = single(1e-3);

% Aero forces
Fz_down       = 1 / 2 * Params.Physics.ro * Params.Car.Af * Params.Car.cl * v_x ^ 2;
Fx_drag       = 1 / 2 * Params.Physics.ro * Params.Car.Af * Params.Car.cd * v_x ^ 2;

% Ackermann steering angles
delta_L       = atan2(Params.Car.L * tan(delta), (Params.Car.L - Params.Car.tf / 2 * tan(delta)));
delta_R       = atan2(Params.Car.L * tan(delta), (Params.Car.L + Params.Car.tf / 2 * tan(delta)));

% Velocity vectors
v_x_fl        = v_x - Phi_dot * Params.Car.tf / 2;
v_x_fr        = v_x + Phi_dot * Params.Car.tf / 2;
v_x_rl        = v_x - Phi_dot * Params.Car.tr / 2;
v_x_rr        = v_x + Phi_dot * Params.Car.tr / 2;

v_y_f         = v_y + Phi_dot * Params.Car.a;
v_y_r         = v_y - Phi_dot * Params.Car.b;

% Safe velocities for slip angle calculation (prevents low-speed atan2 singularity)
% If perfectly 0, the logic defaults to +0.1 to prevent sign(0)*0.1 = 0
v_x_fl_safe   = max(abs(v_x_fl), single(0.1)) * sign(v_x_fl + single(v_x_fl == 0));
v_x_fr_safe   = max(abs(v_x_fr), single(0.1)) * sign(v_x_fr + single(v_x_fr == 0));
v_x_rl_safe   = max(abs(v_x_rl), single(0.1)) * sign(v_x_rl + single(v_x_rl == 0));
v_x_rr_safe   = max(abs(v_x_rr), single(0.1)) * sign(v_x_rr + single(v_x_rr == 0));

% Slip angles (Using the safe bounded longitudinal velocities)
alpha_fl      = atan2(v_y_f, v_x_fl_safe) - delta_L;
alpha_fr      = atan2(v_y_f, v_x_fr_safe) - delta_R;
alpha_rl      = atan2(v_y_r, v_x_rl_safe);
alpha_rr      = atan2(v_y_r, v_x_rr_safe);

% Slip ratios
kappa_fl      = (omega_fl * Params.Car.r_load - ((v_x_fl * cos(delta_L) + v_y_f * sin(delta_L)))) / max(abs(omega_fl) * Params.Car.r_load, abs(v_x_fl * cos(delta_L) + v_y_f * sin(delta_L)) + eps);
kappa_fr      = (omega_fr * Params.Car.r_load - ((v_x_fr * cos(delta_R) + v_y_f * sin(delta_R)))) / max(abs(omega_fr) * Params.Car.r_load, abs(v_x_fr * cos(delta_R) + v_y_f * sin(delta_R)) + eps );
kappa_rl      = (omega_rl * Params.Car.r_load - v_x_rl) / max(abs(omega_rl) * Params.Car.r_load, abs(v_x_rl) + eps);
kappa_rr      = (omega_rr * Params.Car.r_load - v_x_rr) / max(abs(omega_rr) * Params.Car.r_load, abs(v_x_rr) + eps);

% Wheel loads 
Fz_fl         = 1 / 2 * Params.Car.m * Params.Physics.g * Params.Car.b / Params.Car.L - 1 / 2 * Fz_down * Params.Car.b_cop / Params.Car.L - 1 / 2 * Params.Car.m * a_x * Params.Car.h_cog / Params.Car.L - Params.Car.b / Params.Car.L * Params.Car.m * a_y * Params.Car.h_cog / Params.Car.tf;
Fz_fr         = 1 / 2 * Params.Car.m * Params.Physics.g * Params.Car.b / Params.Car.L - 1 / 2 * Fz_down * Params.Car.b_cop / Params.Car.L - 1 / 2 * Params.Car.m * a_x * Params.Car.h_cog / Params.Car.L + Params.Car.b / Params.Car.L * Params.Car.m * a_y * Params.Car.h_cog / Params.Car.tf;
Fz_rl         = 1 / 2 * Params.Car.m * Params.Physics.g * Params.Car.a / Params.Car.L - 1 / 2 * Fz_down * Params.Car.a_cop / Params.Car.L + 1 / 2 * Params.Car.m * a_x * Params.Car.h_cog / Params.Car.L - Params.Car.a / Params.Car.L * Params.Car.m * a_y * Params.Car.h_cog / Params.Car.tr;
Fz_rr         = 1 / 2 * Params.Car.m * Params.Physics.g * Params.Car.a / Params.Car.L - 1 / 2 * Fz_down * Params.Car.a_cop / Params.Car.L + 1 / 2 * Params.Car.m * a_x * Params.Car.h_cog / Params.Car.L + Params.Car.a / Params.Car.L * Params.Car.m * a_y * Params.Car.h_cog / Params.Car.tr;

% Magic formula lateral 
Fy_fl         = miu_rd * MF_y(Fz_fl, alpha_fl, kappa_fl, Params.TireLeft.lat);
Fy_fr         = miu_rd * MF_y(Fz_fr, alpha_fr, kappa_fr, Params.TireRight.lat);
Fy_rl         = miu_rd * MF_y(Fz_rl, alpha_rl, kappa_rl, Params.TireLeft.lat);
Fy_rr         = miu_rd * MF_y(Fz_rr, alpha_rr, kappa_rr, Params.TireRight.lat);

% Magic formula longitudinal 
Fx_fl         = miu_rd * MF_x(Fz_fl, alpha_fl, kappa_fl, Params.TireLeft.long);
Fx_fr         = miu_rd * MF_x(Fz_fr, alpha_fr, kappa_fr, Params.TireRight.long);
Fx_rl         = miu_rd * MF_x(Fz_rl, alpha_rl, kappa_rl, Params.TireLeft.long);
Fx_rr         = miu_rd * MF_x(Fz_rr, alpha_rr, kappa_rr, Params.TireRight.long);

% State derivatives [1, 2, 4]
v_x_dot       = 1 / Params.Car.m * (Fx_rr + Fx_rl + Fx_fl * cos(delta_L) + Fx_fr * cos(delta_R) - Fy_fl * sin(delta_L) - Fy_fr * sin(delta_R) + Fx_drag) + v_y * Phi_dot;
v_y_dot       = 1 / Params.Car.m * (Fy_rr + Fy_rl + Fx_fl * sin(delta_L) + Fx_fr * sin(delta_R) + Fy_fl * cos(delta_L) + Fy_fr * cos(delta_R)) - v_x * Phi_dot;
Phi_dot_dot   = 1 / Params.Car.Izz * ((Fy_fl * cos(delta_L) + Fx_fl * sin(delta_L) + Fx_fr * sin(delta_R) + Fy_fr * cos(delta_R)) * Params.Car.a - Fy_rl * Params.Car.b - Fy_rr * Params.Car.b + (Fx_rr - Fx_rl) * Params.Car.tr / 2 + (Fx_fr*cos(delta_R) - Fy_fr * sin(delta_R) + Fy_fl * sin(delta_L) - Fx_fl*cos(delta_L))*Params.Car.tf/2);

% Random walk model (assume 0 jerk with exception of some noise) [4, 5, 6]
a_x_dot       = 0;
a_y_dot       = 0;
x_dot         = [v_x_dot, v_y_dot, Phi_dot_dot, a_x_dot, a_y_dot]';

% Update state using Euler integration
x_next        = x + x_dot * Params.TimeStep; 

end