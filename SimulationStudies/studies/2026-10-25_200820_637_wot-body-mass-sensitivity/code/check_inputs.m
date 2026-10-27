function actual = check_inputs(row,inputFile)
%check_inputs Check initialized WOT pedals, physical mass and estimator bypass.
%   ACTUAL = check_inputs(ROW,INPUTFILE) reads the isolated model/base
%   workspace during InitFcn and writes small readbacks to INPUTFILE
%   before asserting. ROW supplies the expected controller and body mass.
%   This callback does not simulate or save the model.
%   Example: actual = check_inputs(studyExpectedRun,studyInputFile);
maneuver = evalin('base','Maneuver');
vehicle = evalin('base','Vehicle');
actual.type = maneuver.Type;
actual.instance = maneuver.Instance;
actual.accelTime_s = double(maneuver.Accel.t.Value(:)');
actual.accelPedal = double(maneuver.Accel.rPedal.Value(:)');
actual.brakeTime_s = double(maneuver.Brake.t.Value(:)');
actual.brakePedal = double(maneuver.Brake.rPedal.Value(:)');
actual.steerAngle_rad = double(maneuver.Steer.aWheel.Value(:)');
actual.bodyMass_kg = vehicle.Chassis.Body.m.Value;
actual.cg_m = vehicle.Chassis.Body.sCG.Value;
actual.inertia_kgm2 = vehicle.Chassis.Body.J.Value;
actual.baselineCG_m = evalin('base','studyBaselineCG');
actual.baselineInertia_kgm2 = evalin('base','studyBaselineInertia');
actual.vehicle = vehicle.config;
actual.tire = vehicle.Chassis.Tire.class.Value;
actual.driverType = get_param('sm_car/Driver','popup_driver_type');
actual.controller = get_param('sm_car/Controller','popup_control');
actual.activeController = get_param('sm_car/Controller','LabelModeActiveChoice');
actual.estimatorCommented = get_param( ...
    'sm_car/Controller/Default/State Estimation','Commented');
actual.stopTime = get_param('sm_car','StopTime');
bodyBlock = 'sm_car/Vehicle/Vehicle/Chassis/Body';
actual.massExpression = get_param(bodyBlock,'chassis_mass');
actual.physicalBodyMass_kg = slResolve(actual.massExpression,bodyBlock);
actual.stopSpeed_mps = slResolve(get_param('sm_car/Check','stop_speed'),'sm_car/Check');
actual.startCheck_s = slResolve(get_param('sm_car/Check','start_check_time'),'sm_car/Check');
save(inputFile,'actual','row');
assert(strcmp(actual.type,'WOT_Braking') && strcmp(actual.instance,'FSAE_Achilles'), ...
    'Study:Maneuver','Expected the FSAE WOT Braking maneuver.');
assert(isequal(actual.accelTime_s,[0,1,1.2,6,6.2,200]) && ...
    isequal(actual.accelPedal,[0,0,1,1,0,0]) && ...
    isequal(actual.brakeTime_s,[0,7,7.2,190,191,200]) && ...
    isequal(actual.brakePedal,[0,0,0.7,0.7,0,0]) && ...
    all(actual.steerAngle_rad==0),'Study:Pedals','WOT or native braking profile changed.');
assert(strcmp(actual.driverType,'Open Loop') && strcmp(actual.tire,'MFEval'), ...
    'Study:Driver','Expected Open Loop driver and MFEval tires.');
assert(strcmp(actual.controller,row.Controller) && ...
    strcmp(actual.activeController,row.Controller) && strcmp(actual.estimatorCommented,'through'), ...
    'Study:Controller','Default controller/estimator bypass was not applied.');
assert(abs(actual.bodyMass_kg-row.BodyMass_kg)<1e-9 && ...
    abs(actual.physicalBodyMass_kg-row.BodyMass_kg)<1e-9, ...
    'Study:Mass','Requested body mass did not reach the physical body.');
assert(isequal(actual.cg_m,actual.baselineCG_m) && ...
    isequal(actual.inertia_kgm2,actual.baselineInertia_kgm2), ...
    'Study:Inertia','CG or inertia changed with body mass.');
assert(actual.stopSpeed_mps==0.1 && actual.startCheck_s==5, ...
    'Study:Stopping','Native low-speed stop settings changed.');
end
