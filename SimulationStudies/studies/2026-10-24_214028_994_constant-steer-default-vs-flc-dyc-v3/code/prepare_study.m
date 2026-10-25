function studyFolder = prepare_study(projectRoot)
%PREPARE_STUDY Freeze saved files; user waived dummy previews for this study.
% Edit the MATLAB files in this folder BEFORE preparation. Re-prepare after
% edits so the plan, previews and approvals always refer to the same code.
codeFolder = fileparts(mfilename('fullpath'));
cfg = study_config();
assert(ismac || ispc, 'Study:OS', 'This example supports macOS and Windows.');
assert(strcmp(cfg.execution, 'sequential'), 'Study:Mode', ...
    'This example implements sequential execution only.');
assert(~isempty(regexp(cfg.name, '^[a-z0-9-]+$', 'once')), 'Study:Name', ...
    'Use lowercase letters, digits and hyphens for the study name.');
assert(height(cfg.runs) > 0 && numel(unique(cfg.runs.ID)) == height(cfg.runs), ...
    'Study:Runs', 'Provide at least one run, with unique IDs.');
assert(all(matches(cfg.runs.ID, regexpPattern('^[A-Za-z0-9_\-]+$'))), ...
    'Study:ID', 'Run IDs must be safe file names.');
assert(cfg.validationSeconds > 0 && cfg.validationSeconds <= 1 && ...
    all(cfg.runs.Stop_s > cfg.validationSeconds), 'Study:Duration', ...
    'Use a short validation up to 1 s, shorter than every full run.');

%% Check the saved inventory without initializing MATLAB project data
inventoryFolder = fullfile(projectRoot, 'SimulationStudies', 'inventory', 'saved');
inventoryFiles = readtable(fullfile(inventoryFolder, 'fingerprints.csv'), 'TextType','string');
for k = 1:height(inventoryFiles)
    path = inventoryFiles.Path(k);
    if ~inventoryFiles.External(k), path = fullfile(projectRoot, path); end
    assert(strcmp(file_sha256(path), inventoryFiles.SHA256(k)), 'Study:StaleInventory', ...
        'Inventory changed: %s. Refresh the saved-file inventory before preparation.', path);
end

%% Create a dated folder; never overwrite an earlier study
stamp = char(datetime('now', 'TimeZone',cfg.timezone, 'Format','yyyy-MM-dd_HHmmss_SSS'));
studyFolder = fullfile(projectRoot, 'SimulationStudies', 'studies', [stamp '_' cfg.name]);
assert(~isfolder(studyFolder), 'Study:Exists', 'Study folder already exists.');
mkdir(studyFolder);
mkdir(fullfile(studyFolder, 'code'));
copyfile(fullfile(codeFolder, '*.m'), fullfile(studyFolder, 'code'));
copyfile(inventoryFolder, fullfile(studyFolder, 'inventory'));
copyfile(fullfile(projectRoot, 'SimulationStudies', 'MODEL_WORKSPACE.md'), studyFolder);

%% Save a baseline archive, excluding generated output and private folders
relativeFiles = savedFiles(projectRoot, '');
hashes = strings(numel(relativeFiles),1);
for k = 1:numel(relativeFiles)
    hashes(k) = file_sha256(fullfile(projectRoot, relativeFiles{k}));
end
baselineFiles = table(string(relativeFiles(:)), hashes, 'VariableNames',{'Path','SHA256'});
writetable(baselineFiles, fullfile(studyFolder, 'baseline_files.csv'));
zip(fullfile(studyFolder, 'baseline.zip'), relativeFiles, projectRoot);

%% Record the concrete scope and the user's study-specific approval exception
fid = fopen(fullfile(studyFolder, 'study_plan.md'), 'w');
assert(fid >= 0, 'Study:Plan', 'Cannot create study plan.');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '# %s\n\nPrepared %s (%s), %s.\n\n', cfg.name, stamp, cfg.timezone, computer);
fprintf(fid, '%d Constant Steer run(s), sequential execution. Saved-file baseline.\n\n', height(cfg.runs));
fprintf(fid, 'User explicitly waived previews and the separate validation approval.\n');
fprintf(fid, 'User approved automatic full comparison after short validation passes.\n');
fprintf(fid, 'User stopped Ramp Steer and requested the same comparison using Constant Steer, then explicitly selected native throttle/braking.\n');
fprintf(fid, 'Validation: at most %.3g simulated seconds per configuration. Full runs: 19 s limit, or any model-triggered stop condition.\n\n', cfg.validationSeconds);
fprintf(fid, 'Exact hyperlink: sm_car_config_maneuver(''sm_car'',''turn''); replace only the nonzero steering values in MDatabase.Turn.FSAE_Achilles beforehand.\n');
fprintf(fid, 'Native steering starts at 5 s and reaches the selected angle at 5.2 s; throttle starts at 1 s and is released at 10 s; braking starts at 11 s. No 10 km/h speed target.\n');
fprintf(fid, 'User clarified that any ModelStop is a normal completion, regardless of condition, source or time. Retain its reason and actual stop time. Manual stops, errors, timeouts and pauses remain incomplete. Compare actual recorded windows in the CSV.\n\n');
fprintf(fid, 'The short check verifies generated inputs and early logging. It does not test the later steering response.\n\n');
fprintf(fid, '## Explicit run list\n\n```text\n%s\n```\n\n', evalc('disp(cfg.runs)'));
fprintf(fid, 'Review `code/simulate_run.m` for exact scenario commands, overrides and signal extraction.\n\n');
fprintf(fid, 'Outputs from VehBus.Chassis.Body.CG: nYaw (rad/s to deg/s), gy (m/s^2), aSideSlip (rad to deg). Native time samples.\n');
fprintf(fid, 'Peak table: signed min/max and maximum absolute lateral acceleration, signed value/time at that peak, full recorded interval. g uses 9.80665 m/s^2.\n');
fprintf(fid, 'Controller mask: sm_car/Controller popup_control = Default or FLC_DYC_V3; verify active label after initialization.\n');
fprintf(fid, 'Baseline includes the user-repaired five-state V3 UKF and input noises. Verify that its State Estimation subsystem is enabled; make no estimator overrides.\n');
fprintf(fid, 'Archived Skidpad data and Ramp Steer validations are excluded from this six-case comparison.\n');
fprintf(fid, 'Keep selected MAT logs, PNG overlays, CSV metrics. No ranking or narrative report.\n\n');
fprintf(fid, 'Missing dependencies remain in `inventory/dependencies.json`; runtime availability and units await validation.\n');
clear cleanup
state.host = computer;
state.scope = study_scope(studyFolder);
state.status = 'prepared_validation_authorized';
state.validationPassed = false;
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
fprintf('Prepared (no simulation, previews waived): %s\n', studyFolder);
end

function files = savedFiles(root, relative)
% Small recursive file list: no generated studies, caches or backup models.
skip = {'.git','.codex','.agents','.aws','SimulationStudies','work','slprj', ...
    'spinfo','codegen','__pycache__','sdireports'};
entries = dir(fullfile(root, relative));
files = {};
for k = 1:numel(entries)
    name = entries(k).name;
    if ismember(name, [{'.','..','.DS_Store'}, skip]) || startsWith(name,'~$'), continue; end
    path = fullfile(relative, name);
    if entries(k).isdir
        files = [files; savedFiles(root, path)]; %#ok<AGROW>
    else
        [~,~,ext] = fileparts(name);
        if ismember(lower(ext), {'.original','.asv','.slxc','.mp4','.avi','.log'}) || ...
                ~isempty(regexp(ext, '^\.r\d{4}[ab]$', 'once')), continue; end
        files{end+1,1} = path; %#ok<AGROW>
    end
end
end
