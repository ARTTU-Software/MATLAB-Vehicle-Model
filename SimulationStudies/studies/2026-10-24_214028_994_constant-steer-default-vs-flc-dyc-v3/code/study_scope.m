function scope = study_scope(studyFolder)
%STUDY_SCOPE Identify the reviewed study; edits require new preparation.
files = dir(fullfile(studyFolder, 'code', '*'));
files = files(~[files.isdir]);
paths = ["baseline.zip"; "study_plan.md"; "baseline_files.csv"; ...
    "inventory/fingerprints.csv"; "code/" + string({files.name})'];
if isfile(fullfile(studyFolder,'reused_files.csv'))
    reused = readtable(fullfile(studyFolder,'reused_files.csv'),'TextType','string');
    paths = [paths; "reused_files.csv"; "previous_state.mat"; reused.Path];
end
hashes = strings(size(paths));
for k = 1:numel(paths)
    hashes(k) = file_sha256(fullfile(studyFolder, paths(k)));
end
scope = table(paths, hashes);
end
