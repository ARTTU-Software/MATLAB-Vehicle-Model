function Fx = MF_x(Fz_in, alpha, kappa, long)
%#codegen
coder.inline('always')

% 1. PROTECT FZ: Prevent wheel lift-off and negative loads
Fz = max(Fz_in, single(10.0));

% Friction scaling coefficient
Amu = 1;
LMUX_prime = Amu * long.LMUX / (1 + (Amu - 1) * long.LMUX);  

% Nominal load and normalized nominal load
Fz0 = long.Fz0;  
dfz = (Fz - long.LFZ0 * Fz0) / (long.LFZ0 * Fz0); 

% Longitudinal stiffness (Kx)
Kx = Fz * (long.PKX1 + long.PKX2 * dfz) * exp(long.PKX3 * dfz) * long.LKX;  

% Shift terms
SHx = (long.PHX1 + long.PHX2 * dfz) * long.LHX;
SVx = Fz * (long.PVX1 + long.PVX2 * dfz) * long.LVX * LMUX_prime;

% Slip ratio shift
kappax = kappa + SHx;

% Peak longitudinal Friction (mux), Force (Dx)
mux = (long.PDX1 + long.PDX2 * dfz) * long.LMUX;
Dx 	= mux * Fz;

% Shape (Cx), Curvature (Ex)
Cx 	= long.PCX1 * long.LCX;
if kappax >= 0
    Ex = (long.PEX1 + long.PEX2 * dfz + long.PEX3 * dfz^2) * (1 - long.PEX4) * long.LEX;
else
    Ex = (long.PEX1 + long.PEX2 * dfz + long.PEX3 * dfz^2) * (1 + long.PEX4) * long.LEX;
end
Ex = min(Ex, 1);
% 2. PROTECT Bx: Prevent denominator cancellation
Bx = Kx / max(Cx * Dx, single(1e-4));

% Pure longitudinal force
Fx0 = Dx * sin(Cx * atan(Bx * kappax - Ex * (Bx * kappax - atan(Bx * kappax)))) + SVx;

% Weighting function for combined slip
SHxa = long.RHX1;
Cxa = long.RCX1; 
Exa = long.REX1 + long.REX2 * dfz;
Bxa = long.RBX1 * cos(atan(long.RBX2 * kappa)) * long.LXAL;
            
% Weighting function term with alpha shift
alphas = alpha + SHxa;  
Gxa0 = cos(Cxa * atan(Bxa * SHxa - Exa * (Bxa * SHxa - atan(Bxa * SHxa))));  

% 3. PROTECT Gxa0: Prevent division by zero
Gxa0_safe = sign(Gxa0) * max(abs(Gxa0), single(1e-4));
if Gxa0_safe == 0 % Fallback just in case sign is 0
    Gxa0_safe = single(1e-4);
end

Gxa = cos(Cxa * atan(Bxa * alphas - Exa * (Bxa * alphas - atan(Bxa * alphas)))) / Gxa0_safe; 
            
% Longitudinal force
Fx = Gxa * Fx0;
end