function actual = check_inputs(row, inputFile)
%check_inputs - Verify the effective maneuver and controller inputs
%   ACTUAL = check_inputs(ROW, inputFile) reads the initialized model
%   and base workspace and compares them with one prepared run-table
%   ROW. inputFile is the MAT file path for the small input readback.
%   ACTUAL is a structure with the observed maneuver, controller and
%   applicable estimator settings. It is saved before assertions so
%   failed checks also retain evidence.
%
%   Called by simulate_run's InitFcn after model initialization in the
%   isolated batch copy. Native steering/pedal timing is checked, and
%   the saved V3 estimator must be enabled when V3 is requested.
%
%   Example: inside the initialized batch model's callback
%       actual = check_inputs(studyExpectedRun, studyInputFile);
%
%   See also simulate_run, study_config

%% 1. Read the generated maneuver and selected controller
maneuver = evalin('base', 'Maneuver');
actual.type = maneuver.Type;
actual.instance = maneuver.Instance;
actual.steerTime_s = double(maneuver.Steer.t.Value(:)');
actual.steerAngle_deg = double(maneuver.Steer.aWheel.Value(:)') * 180/pi;
actual.accelTime_s = double(maneuver.Accel.t.Value(:)');
actual.accelPedal = double(maneuver.Accel.rPedal.Value(:)');
actual.brakeTime_s = double(maneuver.Brake.t.Value(:)');
actual.brakePedal = double(maneuver.Brake.rPedal.Value(:)');
actual.driverType = get_param('sm_car/Driver','popup_driver_type');
actual.vehicle = evalin('base', 'Vehicle.config');
actual.tire = evalin('base', 'Vehicle.Chassis.Tire.class.Value');
actual.controller = get_param('sm_car/Controller','popup_control');
actual.activeController = get_param('sm_car/Controller','LabelModeActiveChoice');

%% 2. Verify the saved V3 estimator when that controller is requested
if strcmp(row.Controller,'FLC_DYC_V3')
    % SIDs identify the repaired saved V3 subsystem, without name ambiguity.
    estimator = Simulink.ID.getFullName('sm_car:4253:1493');
    ukf = Simulink.ID.getFullName('sm_car:4253:1603');
    actual.estimator.commented = get_param(estimator,'Commented');
    actual.estimator.initialState = get_param(ukf,'InitialState');
    actual.estimator.initialCovariance = get_param(ukf,'InitialStateCovariance');
    actual.estimator.processNoise = get_param(ukf,'ProcessNoise');
    actual.estimator.measurementNoise = get_param(ukf,'MeasurementNoise1');
    actual.estimator.variableProcessNoise = get_param(ukf,'HasTimeVaryingProcessNoise');
    actual.estimator.variableMeasurementNoise = get_param(ukf,'HasTimeVaryingMeasurementNoise1');
end
% Retain the readback even if an assertion fails; this is small metadata only.
save(inputFile, 'actual', 'row');
if strcmp(row.Controller,'FLC_DYC_V3')
    assert(strcmp(actual.estimator.commented,'off'), 'Study:EstimatorBypassed', ...
        'The requested V3 estimator must be enabled.');
end
assert(strcmp(actual.controller,row.Controller) && strcmp(actual.activeController,row.Controller), ...
    'Study:Controller','Requested controller was not applied: %s',row.Controller);

%% 3. Compare the generated steering and pedal profiles with the request
% Native FSAE Turn data: preserve all timing and pedal values.
expectedTime = [0,5,5.2,180,181,200];
expectedAngle = [0,0,row.Steer_deg,row.Steer_deg,0,0];
assert(strcmp(actual.type, 'Turn') && strcmp(actual.instance, 'FSAE_Achilles'), ...
    'Study:Maneuver', 'Expected the FSAE Constant Steer (Turn) maneuver.');
assert(isequal(size(actual.steerTime_s), size(expectedTime)) && ...
    all(abs(actual.steerTime_s - expectedTime) < 1e-8), ...
    'Study:SteerTime', 'Generated steering times differ from the requested sequence.');
assert(isequal(size(actual.steerAngle_deg), size(expectedAngle)) && ...
    all(abs(actual.steerAngle_deg - expectedAngle) < 1e-8), ...
    'Study:SteerAngle', 'Generated steering angles differ from the requested sequence.');
assert(strcmp(actual.driverType,'Open Loop'),'Study:Driver','Expected native open-loop driver.');
assert(isequal(actual.accelTime_s,[0,1,1.1,10,10.1,200]) && ...
    isequal(actual.accelPedal,[0,0,0.5,0.5,0,0]) && ...
    isequal(actual.brakeTime_s,[0,11,11.2,190,191,200]) && ...
    isequal(actual.brakePedal,[0,0,0.4,0.4,0,0]), ...
    'Study:Pedals','The native throttle/braking profile changed.');
end
