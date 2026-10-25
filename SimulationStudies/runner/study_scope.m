function scope = study_scope(studyFolder)
%study_scope - Fingerprint the files included in study review
%   SCOPE = study_scope(studyFolder) reads the root wrapper, JSON,
%   plan, baseline archive/hash list and files under code/. studyFolder
%   is the prepared study's root path. SCOPE is a table of relative
%   paths and SHA-256 hashes for checking edits between approved stages.
%   It does not modify files. All reviewed files must still exist.
%
%   Example: inspect the scope of a prepared study
%       scope = study_scope(studyFolder);
%
%   See also file_sha256, prepare_study, run_study

files = dir(fullfile(studyFolder, 'code', '*'));
files = files(~[files.isdir]);
paths = ["rerun_study.m"; "study_inputs.json"; "baseline.zip"; "study_plan.md"; "baseline_files.csv"; ...
    "code/" + string({files.name})'];
hashes = strings(size(paths));
for k = 1:numel(paths)
    hashes(k) = file_sha256(fullfile(studyFolder, paths(k)));
end
scope = table(paths, hashes);
end
