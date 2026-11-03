function simulate_run(cfg, row, stopSeconds, resultFile)
%simulate_run - Set up and simulate one case in an isolated project
%   simulate_run(CFG, ROW, stopSeconds, resultFile) runs one approved
%   case. CFG is the prepared configuration from study_config. ROW is
%   one row of CFG.runs, including controller and steering-wheel angle.
%   stopSeconds is the simulated-time limit in seconds; the model may
%   stop earlier. resultFile is the destination MAT file path.
%
%   The caller must already have opened the isolated baseline project
%   in a fresh batch process. This function applies the maneuver and
%   temporary controller settings, checks inputs after initialization,
%   then saves selected signals and metadata. It also writes the small
%   resultFile.inputs.mat readback. It has no return value and does not
%   save the model. Only roll/lateral-deviation flags get stop labels.
%
%   Example: inside run_study after isolated project initialization
%       row = cfg.runs(1, :);
%       simulate_run(cfg, row, cfg.validationSeconds, resultFile);
%
%   See also run_study, check_inputs, extract_signals

assert(batchStartupOptionUsed, 'Study:Batch', 'Use the batch-stage entry point.');
inputFile = [char(resultFile) '.inputs.mat'];
model = cfg.model;
controllerBlock = [model '/Controller'];

%% 1. Change only the nonzero angle values, then run the saved hyperlink
MDatabase = evalin('base','MDatabase');
angles = MDatabase.Turn.FSAE_Achilles.Steer.aWheel.Value;
angles(angles~=0) = row.Steer_deg*pi/180;
MDatabase.Turn.FSAE_Achilles.Steer.aWheel.Value = angles;
assignin('base','MDatabase',MDatabase);
sm_car_config_maneuver(model, 'turn');

%% 2. Apply temporary controller, duration and logging settings
in = Simulink.SimulationInput(model);
in = in.setBlockParameter(controllerBlock, 'popup_control', char(row.Controller));
in = in.setBlockParameter(controllerBlock, 'LabelModeActiveChoice', char(row.Controller));
in = in.setModelParameter('StartTime', '0', 'StopTime', num2str(stopSeconds, 17));
in = in.setModelParameter('ReturnWorkspaceOutputs', 'on', 'SignalLogging', 'on', ...
    'SignalLoggingName', 'logsout_sm_car', 'LoggingToFile', 'off');
in = in.setModelParameter('SimscapeLogType', 'none', 'SimMechanicsOpenEditorOnUpdate', 'off');

% These are the model's actual gated stop requests, not inferred thresholds.
% Only this run's isolated model copy is changed. No model file is saved.
logStopFlag([model '/Check/Product7'], 'study_stop_roll');
logStopFlag([model '/Check/Product1'], 'study_stop_lateral');

% The project uses the base workspace. Pass the run to the initialization
% callback so check_inputs runs AFTER the model's own initialization.
assignin('base', 'studyExpectedRun', row);
assignin('base', 'studyInputFile', inputFile);
assignin('base', 'studyInputsChecked', false);
initCallback = string(get_param(model, 'InitFcn')) + newline + ...
    "studyEffectiveInputs = check_inputs(studyExpectedRun,studyInputFile);" + newline + ...
    "studyInputsChecked = true;";
in = in.setModelParameter('InitFcn', char(initCallback));

%% 3. Run the approved duration (short validation or the JSON full-run limit)
out = sim(in);
assert(isempty(out.ErrorMessage),'Study:Simulation','%s',out.ErrorMessage);
assert(evalin('base','studyInputsChecked'),'Study:Inputs','Input checks did not execute.');

%% 4. Extract logged CG yaw rate, lateral acceleration and vehicle sideslip
signals = extract_signals(out.logsout_sm_car);

%% 5. Save requested signals and small execution metadata
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
metadata.simulationMode = get_param(model,'SimulationMode');

% Check the two logged requests even during short validation.
rollFlag = out.logsout_sm_car.get('study_stop_roll').Values;
lateralFlag = out.logsout_sm_car.get('study_stop_lateral').Values;
assert(all(isfinite([rollFlag.Data(end), lateralFlag.Data(end)])), ...
    'Study:StopFlags', 'Stop-request flags contain invalid values.');
metadata.stopFlags.roll = rollFlag.Data(end) ~= 0;
metadata.stopFlags.lateralDeviation = lateralFlag.Data(end) ~= 0;

% Give a reason only for the two exceptional model stops requested by the user.
metadata.stopCondition = "";
if strcmp(info.StopEvent, 'ModelStop')
    if metadata.stopFlags.roll
        metadata.stopCondition = "excessive roll angle";
    end
    if metadata.stopFlags.lateralDeviation
        if strlength(metadata.stopCondition) > 0
            metadata.stopCondition = metadata.stopCondition + "; ";
        end
        metadata.stopCondition = metadata.stopCondition + "excessive lateral deviation";
    end
end
% Any model-triggered stop is normal. Keep its actual time and reason.
% Manual stops, timeouts and diagnostic failures are not completed runs.
metadata.completed = any(strcmp(info.StopEvent,{'ReachedStopTime','ModelStop'}));
save(resultFile,'signals','metadata');
assert(metadata.completed,'Study:EarlyStop','Stopped at %.6g s: %s', ...
    info.StopEventTime,metadata.stopDescription);
end

function logStopFlag(blockPath, signalName)
%logStopFlag - Enable logging for one actual model stop request
%   logStopFlag(blockPath, signalName) enables output-port logging on
%   the block at blockPath, using the custom Dataset name signalName.
%   Both arguments are text values. Decimation and point limits are
%   disabled. The isolated model is changed in memory, never saved.
%   This local helper has no return value and is used by simulate_run.
%
%   Example: internal call for the roll request
%       logStopFlag([model '/Check/Product7'], 'study_stop_roll');
%
%   See also simulate_run, get_param, set_param

ports = get_param(blockPath, 'PortHandles');
set_param(ports.Outport, 'DataLogging', 'on', ...
    'DataLoggingNameMode', 'Custom', 'DataLoggingName', signalName, ...
    'DataLoggingDecimateData', 'off', 'DataLoggingLimitDataPoints', 'off');
end
