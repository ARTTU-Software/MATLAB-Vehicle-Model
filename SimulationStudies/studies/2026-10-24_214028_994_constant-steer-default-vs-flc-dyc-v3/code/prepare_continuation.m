function studyFolder = prepare_continuation(projectRoot, previousFolder)
%PREPARE_CONTINUATION Recover this study after correcting stop classification.
% No model changes or extra simulations. The previous attempt stays intact.
previous = load(fullfile(previousFolder,'state.mat'));
assert(previous.state.validationPassed,'Study:Validation','Prior checks must have passed.');
cfg = study_config();
assert(isequal(previous.cfg,cfg),'Study:Config','Run configuration changed.');
for name = {'study_config.m','check_inputs.m','extract_signals.m'}
    assert(strcmp(file_sha256(fullfile(previousFolder,'code',name{1})), ...
        file_sha256(fullfile(fileparts(mfilename('fullpath')),name{1}))), ...
        'Study:Changed','Simulation inputs or extraction changed: %s',name{1});
end
% Only the metadata/stop classification section of simulate_run may differ.
oldCode = fileread(fullfile(previousFolder,'code','simulate_run.m'));
newCode = fileread(fullfile(fileparts(mfilename('fullpath')),'simulate_run.m'));
assert(strcmp(extractBefore(oldCode,'%% 5.'),extractBefore(newCode,'%% 5.')), ...
    'Study:Changed','Simulation setup or extraction changed.');

studyFolder = prepare_study(projectRoot);
oldBaseline = readtable(fullfile(previousFolder,'baseline_files.csv'),'TextType','string');
newBaseline = readtable(fullfile(studyFolder,'baseline_files.csv'),'TextType','string');
assert(isequal(sortrows(oldBaseline),sortrows(newBaseline)), ...
    'Study:BaselineChanged','Cannot reuse results from a different saved baseline.');
copyfile(fullfile(previousFolder,'state.mat'),fullfile(studyFolder,'previous_state.mat'));
mkdir(fullfile(studyFolder,'validation'));
mkdir(fullfile(studyFolder,'results'));
for k = 1:height(cfg.runs)
    id = cfg.runs.ID(k);
    checked = load(fullfile(previousFolder,'validation',id + ".mat"));
    assert(checked.metadata.completed && isequal(checked.metadata.run,cfg.runs(k,:)), ...
        'Study:Validation','Prior validation does not match %s.',id);
    copyfile(fullfile(previousFolder,'validation',id + ".mat"),fullfile(studyFolder,'validation'));
    copyfile(fullfile(previousFolder,'validation',id + ".mat.inputs.mat"),fullfile(studyFolder,'validation'));
end

% D20 already ran successfully; only its old stop classifier rejected it.
record = load(fullfile(previousFolder,'results','D20.mat'));
assert(strcmp(record.metadata.stopEvent,'ModelStop') && ...
    isequal(record.metadata.run,cfg.runs(1,:)),'Study:Result','Unexpected D20 result.');
record.metadata.originalCompleted = record.metadata.completed;
record.metadata.completed = true;
record.metadata.reusedFrom = fullfile(previousFolder,'results','D20.mat');
record.metadata.stopConditionNote = 'Zero speed confirmed by user; any ModelStop is accepted.';
save(fullfile(studyFolder,'results','D20.mat'),'-struct','record');
reloaded = load(fullfile(studyFolder,'results','D20.mat'));
assert(isequaln(record.signals,reloaded.signals),'Study:Data','Imported signals changed.');
copyfile(fullfile(previousFolder,'results','D20.mat.inputs.mat'),fullfile(studyFolder,'results'));

files = [dir(fullfile(studyFolder,'validation','*.mat')); ...
    dir(fullfile(studyFolder,'results','*.mat'))];
paths = strings(numel(files),1); hashes = paths;
for k = 1:numel(files)
    path = fullfile(files(k).folder,files(k).name);
    paths(k) = extractAfter(string(path),strlength(string(studyFolder))+1);
    hashes(k) = file_sha256(path);
end
writetable(table(paths,hashes,'VariableNames',{'Path','SHA256'}), ...
    fullfile(studyFolder,'reused_files.csv'));
fid = fopen(fullfile(studyFolder,'study_plan.md'),'a');
assert(fid>=0,'Study:Plan','Cannot append continuation provenance.');
fprintf(fid,'\n## Reviewed continuation\n\nSource: %s\n\n',previousFolder);
fprintf(fid,'Saved baseline, run configuration, simulation setup and signal extraction match. Reuse all six passed short checks and D20 at %.6g s. Only stop classification was corrected; no simulated samples changed. The remaining five cases will run. Previous state and imported file hashes are retained.\n',record.metadata.actualStop_s);
fclose(fid);
saved = load(fullfile(studyFolder,'state.mat'));
state = saved.state;
state.validationPassed = true;
state.validation = previous.state.validation;
state.validation.reusedFrom = previousFolder;
state.status = 'validation_passed_reused';
state.scope = study_scope(studyFolder);
save(fullfile(studyFolder,'state.mat'),'state','cfg');
fprintf('Continuation ready: %s\n',studyFolder);
end
