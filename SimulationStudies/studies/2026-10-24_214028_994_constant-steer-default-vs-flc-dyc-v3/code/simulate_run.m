function simulate_run(cfg, row, stopSeconds, resultFile)
%SIMULATE_RUN Explicit maneuver, controller, simulation and selected output.
assert(batchStartupOptionUsed, 'Study:Batch', 'Use the batch-stage entry point.');
inputFile = [char(resultFile) '.inputs.mat'];

%% 1. Change only the nonzero angle values, then run the saved hyperlink
MDatabase = evalin('base','MDatabase');
angles = MDatabase.Turn.FSAE_Achilles.Steer.aWheel.Value;
angles(angles~=0) = row.Steer_deg*pi/180;
MDatabase.Turn.FSAE_Achilles.Steer.aWheel.Value = angles;
assignin('base','MDatabase',MDatabase);
sm_car_config_maneuver(cfg.model,'turn');

%% 2. Select the controller through temporary SimulationInput settings
in = Simulink.SimulationInput(cfg.model);
in = in.setBlockParameter([cfg.model '/Controller'], ...
    'popup_control',char(row.Controller));
in = in.setBlockParameter([cfg.model '/Controller'], ...
    'LabelModeActiveChoice',char(row.Controller));
in = in.setModelParameter('StartTime','0','StopTime',num2str(stopSeconds,17), ...
    'ReturnWorkspaceOutputs','on','SignalLogging','on', ...
    'SignalLoggingName','logsout_sm_car','LoggingToFile','off', ...
    'SimscapeLogType','none','SimMechanicsOpenEditorOnUpdate','off');
% Keep project initialization, then read back the requested maneuver/controller.
assignin('base','studyExpectedRun',row);
assignin('base','studyInputFile',inputFile);
assignin('base','studyInputsChecked',false);
originalInit = get_param(cfg.model,'InitFcn');
in = in.setModelParameter('InitFcn',sprintf('%s\n%s\n%s',originalInit, ...
    'studyEffectiveInputs = check_inputs(studyExpectedRun,studyInputFile);', ...
    'studyInputsChecked = true;'));

%% 3. Simulate (the caller chooses 1 s validation or 19 s full run)
out = sim(in);
assert(isempty(out.ErrorMessage),'Study:Simulation','%s',out.ErrorMessage);
assert(evalin('base','studyInputsChecked'),'Study:Inputs','Input checks did not execute.');

%% 4. Extract logged CG yaw rate, lateral acceleration and vehicle sideslip
signals = extract_signals(out.logsout_sm_car);

%% 5. Save selected signals and small metadata, including incomplete-run evidence
info = out.SimulationMetadata.ExecutionInfo;
metadata.run = row;
metadata.effectiveInputs = evalin('base','studyEffectiveInputs');
metadata.requestedStop_s = stopSeconds;
metadata.actualStop_s = info.StopEventTime;
metadata.stopEvent = char(info.StopEvent);
metadata.stopDescription = char(info.StopEventDescription);
metadata.stopSource = '';
if isa(info.StopEventSource,'Simulink.SimulationData.BlockPath') && ...
        info.StopEventSource.getLength()>0
    metadata.stopSource = info.StopEventSource.getBlock(info.StopEventSource.getLength());
end
metadata.warningCount = numel(info.WarningDiagnostics);
metadata.elapsedSeconds = out.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
metadata.matlabRelease = version('-release');
metadata.solver = get_param(cfg.model,'Solver');
metadata.simulationMode = get_param(cfg.model,'SimulationMode');
% Any model-triggered stop is normal. Keep its actual time and reason.
% Manual stops, timeouts and diagnostic failures are not completed runs.
metadata.completed = any(strcmp(info.StopEvent,{'ReachedStopTime','ModelStop'}));
save(resultFile,'signals','metadata');
assert(metadata.completed,'Study:EarlyStop','Stopped at %.6g s: %s', ...
    info.StopEventTime,metadata.stopDescription);
end
