function ukf = UKF_Init
% y = [ V_GPS COG_GPS Phi_GPS Phi_dotg a_xa a_ya omega_fl omega_fr ]

MeasurementNoise = single(diag([9e-4, 9e-4, 7.29e-7, 1.22e-4, 1.22e-4]));

% x     = [ v_x v_y Phi_dot a_x a_y miu ]
ProcessNoise = single(diag([1e-5, 1e-6, 1e-3, 5e-5, 1e-4]));

alpha = single(0.1);
beta  = single(2);
kappa = single(0);
initial_state = single([1e-1; 0; 0; 0; 0]);
ukf = unscentedKalmanFilter(@prediction_model, @measurement_model, initial_state);
ukf.Alpha =alpha;
ukf.Beta = beta;
ukf.Kappa = kappa;
ukf.ProcessNoise = ProcessNoise;
ukf.MeasurementNoise = MeasurementNoise;

ukf.StateCovariance = single(diag([1e-2, 1e-3, 1e-3, 0.1, 0.1]));
end