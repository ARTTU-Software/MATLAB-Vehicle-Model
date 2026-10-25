function run_study(studyFolder, stage, approvalNote)
%RUN_STUDY Execute ONE approved stage in a fresh MATLAB -batch process.
% stage is 'validation' or 'full'. Never call from the interactive session.
% approvalNote records the user's actual approval for this particular stage.
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
assert(strcmp(state.host, computer), 'Study:Host', 'Prepare again on the execution host.');
assert(isequal(state.scope, study_scope(studyFolder)), 'Study:Changed', ...
    'Study code, plan or baseline changed. Prepare and review a new study.');
inventoryFiles = readtable(fullfile(studyFolder, 'inventory', 'fingerprints.csv'), 'TextType','string');
for k = find(inventoryFiles.External)'
    assert(strcmp(file_sha256(inventoryFiles.Path(k)), inventoryFiles.SHA256(k)), ...
        'Study:LibraryChanged', 'External dependency changed: %s', inventoryFiles.Path(k));
end
if strcmp(stage, 'full')
    assert(state.validationPassed, 'Study:Validation', 'Short validation must pass first.');
end
stageFolder = fullfile(studyFolder, stage);
% Atomic directory creation prevents two processes from starting the same stage.
stageDirectory = java.io.File(stageFolder);
assert(stageDirectory.mkdir(), 'Study:ExistingStage', ...
    'This stage already has an attempt. Review it and prepare a new study to retry.');
diary(fullfile(stageFolder, 'matlab.log'));
diaryCleanup = onCleanup(@() diary('off'));
state.status = [stage '_running'];
state.(stage).approval = char(approvalNote);
state.(stage).approvedAt = char(datetime('now','TimeZone',cfg.timezone));
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');

%% Each run starts from its own fresh extraction of the saved baseline
% Fail fast: preserve the failed copy and logs for review. No automatic retry.
try
    for k = 1:height(cfg.runs)
        row = cfg.runs(k,:);
        state.(stage).currentRun = char(row.ID);
        save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
        fprintf('%s %s starting (%d/%d).\n', stage, row.ID, k, height(cfg.runs));
        % A reviewed continuation can import a completed, fingerprinted result.
        resultFile = fullfile(studyFolder,'results',row.ID + ".mat");
        if strcmp(stage,'full') && isfile(resultFile)
            imported = readtable(fullfile(studyFolder,'reused_files.csv'),'TextType','string');
            registered = imported.Path == string(fullfile('results',row.ID + ".mat"));
            assert(nnz(registered)==1 && ...
                strcmp(file_sha256(resultFile),imported.SHA256(registered)), ...
                'Study:Reuse','Result %s was not registered for reuse.',row.ID);
            reused = load(resultFile,'metadata');
            assert(reused.metadata.completed && isequal(reused.metadata.run,row), ...
                'Study:Reuse','Imported result does not match case %s.',row.ID);
            state.(stage).completedRuns = cfg.runs.ID(1:k);
            save(fullfile(studyFolder,'state.mat'),'state','cfg');
            fprintf('%s %s reused from the reviewed earlier run.\n',stage,row.ID);
            continue
        end
        root = fullfile(stageFolder, char(row.ID), 'project');
        mkdir(root);
        unzip(fullfile(studyFolder, 'baseline.zip'), root);
        baseline = readtable(fullfile(studyFolder, 'baseline_files.csv'), 'TextType','string');
        for j = 1:height(baseline)
            assert(strcmp(file_sha256(fullfile(root, baseline.Path(j))), baseline.SHA256(j)), ...
                'Study:Baseline', 'Extracted baseline mismatch: %s', baseline.Path(j));
        end
        cd(root);
        project = openProject(fullfile(root, cfg.project));
        addpath(codeFolder, '-begin');
        assertLocal(which(cfg.model), root);
        for name = {'sm_car_read_database','sm_car_config_maneuver', ...
                'sm_car_maneuverdata_turn','sm_car_vehcfg_checkConfig'}
            assertLocal(which(name{1}), root);
        end
        Simulink.fileGenControl('set', 'CacheFolder',fullfile(root,'work','cache'), ...
            'CodeGenFolder',fullfile(root,'work','codegen'), 'createDir',true);
        stopSeconds = cfg.validationSeconds;
        resultFolder = stageFolder;
        if strcmp(stage, 'full')
            stopSeconds = row.Stop_s;
            resultFolder = fullfile(studyFolder, 'results');
        end
        if ~isfolder(resultFolder), mkdir(resultFolder); end
        simulate_run(cfg, row, stopSeconds, fullfile(resultFolder, row.ID + ".mat"));
        % Only this batch's copied project/models are closed; originals are not saved.
        bdclose('all');
        close(project);
        cd(codeFolder);
        rmdir(root, 's');
        state.(stage).completedRuns = cfg.runs.ID(1:k);
        save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
        fprintf('%s %s completed.\n', stage, row.ID);
    end
    if strcmp(stage, 'validation')
        state.validationPassed = true;
        state.status = 'validation_passed';
        fprintf('Short validation passed. Review metadata before the separately authorized full stage.\n');
    else
        plot_results(studyFolder, cfg);
        state.status = 'completed';
    end
catch exception
    state.status = [stage '_failed'];
    state.(stage).error = getReport(exception, 'extended', 'hyperlinks','off');
    save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
    rethrow(exception);
end
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
end

function assertLocal(path, root)
assert(~isempty(path), 'Study:MissingFile', 'Required project dependency not found.');
path = char(java.io.File(path).getCanonicalPath());
assert(startsWith(path, [root filesep]), 'Study:OutsideCopy', ...
    'Project dependency resolves outside the copied baseline: %s', path);
end
