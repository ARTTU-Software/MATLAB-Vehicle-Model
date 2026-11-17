%% qc_test_settings.m  -  ONE place for all test settings of the New Quarter Car
% Edit the numbers, SAVE this file (Ctrl+S / Cmd+S), then click a RUN button in the model.
% Read by plot_with_tie_rod.m and run_steering_test.m right AFTER init_car
% (init_car clears the workspace, so the settings are loaded after it).
%
% NOTE: the comparison with the Old QC (compare_plots.m) is only meaningful for the
%       same test as the Old QC run: amp = 0.025 m, freq = 0.5 Hz, Tend = 5 s.

%% Solver settings (same as the validated Old QC / New QC runs)
TEST.sim.MaxStep = 1e-3;     % [s]  maximum solver step
TEST.sim.RelTol  = 1e-5;     % [-]  relative tolerance
TEST.sim.dt      = 1e-3;     % [s]  sample time of the input signals

%% Bump test  (shaker post: vertical sine at the contact patch, rack held at 0)
TEST.bump.amp  = 0.025;      % [m]  +/- amplitude   (0.025 = +/- 25 mm)
TEST.bump.freq = 0.5;        % [Hz] frequency
TEST.bump.Tend = 5;          % [s]  duration

%% Steering test  (rack_in sine, road height fixed at 0)
TEST.steer.amp  = 0.010;     % [m]  +/- rack travel (0.010 = +/- 10 mm)
TEST.steer.freq = 0.5;       % [Hz]
TEST.steer.Tend = 5;         % [s]