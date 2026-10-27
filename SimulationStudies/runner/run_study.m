function run_study(studyFolder, stage, approvalNote)
%run_study - Execute one approved stage from the reviewed study code
%   run_study(studyFolder, STAGE, approvalNote) executes the selected
%   stage in a fresh MATLAB -batch process. studyFolder is the absolute
%   path to the prepared study. STAGE must be:
%       "validation" - Run the short checks, then stop for review.
%       "full"       - Run the approved full study and export outputs.
%
%   approvalNote is the actual user approval text for this stage.
%   Full execution requires passed validation and its separate approval.
%   Call the reviewed function in studyFolder/code, not this template
%   directly. It verifies the JSON/code/baseline, uses isolated project
%   copies and records progress in state.mat. Failures retain a console
%   log. Validation uses cfg.validationRunIDs (default: first run);
%   full execution uses all cfg.runs. Successful full export removes
%   temporary validation data.
%   This function has no return value and rejects completed studies.
%
%   Example: inside a new, separately approved MATLAB batch process
%       run_study(studyFolder, 'validation', approvalNote);
%
%   See also rerun_study, simulate_run, plot_results

%% 1. Check the approved study and saved file identities
assert(batchStartupOptionUsed, 'Study:Batch', 'Use a separate MATLAB -batch process.');
assert(nargin == 3 && strlength(string(approvalNote)) > 0, 'Study:Approval', ...
    'Explicit user approval is required for this stage.');
assert(any(strcmp(stage, {'validation','full'})), 'Study:Stage', 'Unknown stage.');
assert(isempty(find_system('Type','block_diagram')), 'Study:LoadedModel', ...
    'Start a fresh batch process without loaded models.');
studyFolder = char(java.io.File(studyFolder).getCanonicalPath());
codeFolder = fullfile(studyFolder, 'code');
assert(strcmp(fileparts(mfilename('fullpath')), codeFolder), 'Study:CodeCopy', ...
    'Call the reviewed run_study.m inside the study folder.');
saved = load(fullfile(studyFolder, 'state.mat'));
state = saved.state;
cfg = saved.cfg;
assert(~strcmp(state.status,'completed'), 'Study:Completed', ...
    'This study is completed. Prepare a new study to rerun.');
assert(isequaln(cfg,study_config(fullfile(studyFolder,'study_inputs.json'))), ...
    'Study:ConfigChanged','JSON inputs differ from the prepared configuration. Prepare again.');
assert(strcmp(state.host, computer), 'Study:Host', 'Prepare again on the execution host.');
assert(isequal(state.scope, study_scope(studyFolder)), 'Study:Changed', ...
    'Study code, plan or baseline changed. Prepare and review a new study.');
dependencies = state.externalDependencies;
for k = 1:height(dependencies)
    assert(strcmp(file_sha256(dependencies.Path(k)), dependencies.SHA256(k)), ...
        'Study:LibraryChanged', 'External dependency changed: %s', dependencies.Path(k));
end
if strcmp(stage, 'full')
    assert(state.validationPassed, 'Study:Validation', 'Short validation must pass first.');
end

%% 2. Choose the stage duration, results folder and temporary working folder
stageRuns = cfg.runs;
if strcmp(stage, 'validation')
    validationRunIDs = cfg.runs.ID(1);
    if isfield(cfg,'validationRunIDs')
        validationRunIDs = string(cfg.validationRunIDs(:));
    end
    assert(~isempty(validationRunIDs) && ...
        numel(unique(validationRunIDs))==numel(validationRunIDs) && ...
        all(ismember(validationRunIDs,cfg.runs.ID)), ...
        'Study:ValidationCases','Invalid representative validation run IDs.');
    [~,indices] = ismember(validationRunIDs,cfg.runs.ID);
    stageRuns = cfg.runs(indices,:);
end
stopSeconds = cfg.validationSeconds;
resultFolder = fullfile(studyFolder, 'validation');
if strcmp(stage, 'full')
    stopSeconds = cfg.stopTime_s;
    resultFolder = fullfile(studyFolder, 'results');
end
if ~isfolder(resultFolder)
    mkdir(resultFolder);
end
baseline = readtable(fullfile(studyFolder, 'baseline_files.csv'), 'TextType','string');
stageFolder = fullfile(studyFolder, '.work', stage);
workFolder = fullfile(studyFolder, '.work');
if ~isfolder(workFolder)
    mkdir(workFolder);
end
% Atomic directory creation prevents two processes from starting the same stage.
stageDirectory = java.io.File(stageFolder);
assert(stageDirectory.mkdir(), 'Study:ExistingStage', ...
    'This stage already has an attempt. Review it and prepare a new study to retry.');

%% 3. Record approval and capture a transcript (retained only on failure)
logFolder = fullfile(studyFolder, 'logs');
if ~isfolder(logFolder)
    mkdir(logFolder);
end
logFile = fullfile(logFolder, [stage '.log']);
diary(logFile);
diaryCleanup = onCleanup(@() diary('off'));
state.status = [stage '_running'];
state.(stage).approval = char(approvalNote);
state.(stage).selectedRuns = stageRuns.ID;
state.(stage).approvedAt = char(datetime('now','TimeZone',cfg.timezone));
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');

%% 4. Run each case from a fresh copy of the saved project
% Fail fast; retain the failure transcript, not temporary project copies.
try
    for k = 1:height(stageRuns)
        row = stageRuns(k,:);
        state.(stage).currentRun = char(row.ID);
        save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
        fprintf('%s %s starting (%d/%d).\n', stage, row.ID, k, height(stageRuns));
        % Never overwrite or silently reuse results from another attempt.
        resultFile = fullfile(resultFolder, row.ID + ".mat");
        assert(~isfile(resultFile), 'Study:ExistingResult', ...
            'Result already exists: %s. Prepare a new study.', resultFile);
        root = fullfile(stageFolder, char(row.ID), 'project');
        mkdir(root);
        unzip(fullfile(studyFolder, 'baseline.zip'), root);
        for j = 1:height(baseline)
            assert(strcmp(file_sha256(fullfile(root, baseline.Path(j))), baseline.SHA256(j)), ...
                'Study:Baseline', 'Extracted baseline mismatch: %s', baseline.Path(j));
        end
        cd(root);
        project = openProject(fullfile(root, cfg.project));
        addpath(codeFolder, '-begin');
        assertLocal(which(cfg.model), root);
        for name = cfg.projectFunctions
            assertLocal(which(name{1}), root);
        end
        Simulink.fileGenControl('set', 'CacheFolder',fullfile(root,'work','cache'), ...
            'CodeGenFolder',fullfile(root,'work','codegen'), 'createDir',true);
        simulate_run(cfg, row, stopSeconds, resultFile);
        % Only this batch's copied project/models are closed; originals are not saved.
        bdclose('all');
        close(project);
        cd(codeFolder);
        rmdir(root, 's');
        state.(stage).completedRuns = stageRuns.ID(1:k);
        save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
        fprintf('%s %s completed.\n', stage, row.ID);
    end
    %% 5. Finish validation, or export the full-study plots and table
    if strcmp(stage, 'validation')
        state.validationPassed = true;
        state.status = 'validation_passed';
        fprintf('Short validation passed. Review metadata before the separately authorized full stage.\n');
    else
        plot_results(studyFolder, cfg);
        % Keep the validation status, not its temporary signal/input files.
        validationFolder = fullfile(studyFolder,'validation');
        if isfolder(validationFolder)
            rmdir(validationFolder,'s');
        end
        state.status = 'completed';
    end
catch exception
    % Failed stages keep their transcript and small status record only.
    state.status = [stage '_failed'];
    state.(stage).error = getReport(exception, 'extended', 'hyperlinks','off');
    save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
    fprintf(2, '%s\n', state.(stage).error);
    % Close only the isolated batch project before removing temporary files.
    try
        bdclose('all');
        if exist('project','var') && isvalid(project), close(project); end
        cd(codeFolder);
        rmdir(stageFolder,'s');
    catch cleanupError
        fprintf(2,'Temporary cleanup requires attention: %s\n',cleanupError.message);
    end
    rethrow(exception);
end
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
%% 6. Remove temporary files after a successful stage
% Successful stages need no console transcript; metadata stays in state/results.
clear diaryCleanup
if isfile(logFile)
    delete(logFile);
end
rmdir(stageFolder,'s');
entries = dir(workFolder);
if numel(entries)==2
    rmdir(workFolder);
end
entries = dir(logFolder);
if numel(entries)==2
    rmdir(logFolder);
end
end

function assertLocal(path, root)
%assertLocal - Require a dependency to resolve inside the project copy
%   assertLocal(PATH, ROOT) checks the resolved file PATH against the
%   isolated project folder ROOT. Both arguments are text paths. It
%   raises an error for a missing or outside dependency and otherwise
%   returns nothing. This helper is local to run_study.
%
%   Example: internal check after opening the isolated project
%       assertLocal(which(cfg.model), root);
%
%   See also run_study, which

assert(~isempty(path), 'Study:MissingFile', 'Required project dependency not found.');
path = char(java.io.File(path).getCanonicalPath());
assert(startsWith(path, [root filesep]), 'Study:OutsideCopy', ...
    'Project dependency resolves outside the copied baseline: %s', path);
end
