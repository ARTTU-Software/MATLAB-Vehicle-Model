function save_workspace_preview(outputFolder)
%SAVE_WORKSPACE_PREVIEW Preserve the existing log for future layout previews.
% Reads the base workspace; never initializes, modifies or simulates the model.
archiveFile = fullfile(outputFolder,'skidpad_workspace_2026-10-23.mat');
assert(~isfile(archiveFile), 'Preview:Exists', ...
    'Preview data already exists. Choose new filenames before replacing it.');
logsout_sm_car = evalin('base','logsout_sm_car');
tout = evalin('base','tout');
vehicle = logsout_sm_car.get('VehBus').Values;
metadata.purpose = 'Reusable historical data for layout previews only; not results of a new study.';
metadata.requiredLabel = 'PREVIEW ONLY - historical Skidpad data, not this study''s results';
metadata.savedAt = char(datetime('now','TimeZone','Europe/Bucharest', ...
    'Format','yyyy-MM-dd HH:mm:ss Z'));
metadata.currentWorkspaceManeuver = evalin('base','Maneuver.Type');
metadata.currentController = get_param('sm_car/Controller','popup_control');
metadata.currentModelFile = get_param('sm_car','FileName');
metadata.currentModelDirty = get_param('sm_car','Dirty');
metadata.provenanceLimit = ['Current workspace/model settings are contextual; ' ...
    'the logged run configuration and original stop reason were not recorded.'];
metadata.matlabRelease = version('-release');
metadata.datasetElements = logsout_sm_car.numElements;
metadata.solverTimeRange_s = [tout(1),tout(end)];
metadata.signalPaths = struct('worldVx','VehBus.World.vx', ...
    'yawRate','VehBus.Chassis.Body.CG.nYaw', ...
    'lateralAcceleration','VehBus.Chassis.Body.CG.gy', ...
    'sideslip','VehBus.Chassis.Body.CG.aSideSlip');

% Save the full signal-logging dataset once for other future signal requests.
% Simscape tree and unrelated workspace variables are intentionally excluded.
save(archiveFile,'logsout_sm_car','tout','metadata','-v7.3');

% Verify the archived Dataset without writing a second signal file.
archive = load(archiveFile,'logsout_sm_car');
assert(archive.logsout_sm_car.numElements==logsout_sm_car.numElements, ...
    'Preview:Dataset','Dataset element count changed on save.');
assert(isequaln(archive.logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nYaw.Data, ...
    vehicle.Chassis.Body.CG.nYaw.Data),'Preview:Archive','Archived yaw data differs.');
disp(metadata);
fprintf('Saved and reloaded: %s\n',archiveFile);
end
