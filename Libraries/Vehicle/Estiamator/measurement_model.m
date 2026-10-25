function [y, wrapping] = measurement_model(x, u)
% y = [ V CoG Phi_dotg a_xa a_ya]
% u = [ delta,omega_fl, omega_fr, omega_rl, omega_rr ]
%#codegen

% Get States
v_x     = x(1);
v_y     = x(2);
Phi_dot = x(3);
a_x     = x(4);
a_y     = x(5);

%V = sqrt(v_x^2 + v_y^2);
beta = atan(v_y/v_x);
V = v_x * cos(beta);
% Output Vector
y = [V; Phi_dot; a_x; a_y];

% Upper and Lower measurement bounds for Simulink UKF Block
infVal = cast(inf, 'like', y);

wrapping = [ ...
    -infVal,  infVal;  % V not wrapped
    -infVal,  infVal;  % yaw rate not wrapped
    -infVal,  infVal;  % ax not wrapped
    -infVal,  infVal]; % ay not wrapped
end
