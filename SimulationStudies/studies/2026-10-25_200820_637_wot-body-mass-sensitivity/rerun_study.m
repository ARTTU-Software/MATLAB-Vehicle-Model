function newStudyFolder = rerun_study(stage, approvalNote)
%rerun_study - Prepare a rerun or execute one approved stage
%   newStudyFolder = rerun_study() reads the JSON beside this wrapper
%   and prepares a fresh dated study. It uses the shared runner templates and
%   current saved project. Existing results are not changed.
%
%   newStudyFolder = rerun_study(STAGE) selects an action. STAGE must be:
%       "prepare"    - (default) Prepare only; do not simulate.
%       "validation" - Run the short checks in a fresh batch process.
%       "full"       - Run the full study after validation and review.
%
%   newStudyFolder = rerun_study(STAGE, approvalNote) records the actual
%   user approval for validation or full execution. approvalNote is a
%   nonempty text description, not a flag that bypasses approval.
%   These stages must run in separate MATLAB -batch processes, using
%   the NEW study folder. The returned path is that stage's study folder.
%   A logical value such as true is not a supported STAGE.
%
%   Example: prepare after editing this study's JSON
%       newStudyFolder = rerun_study();
%
%   Example: inside the separately approved validation batch process
%       rerun_study('validation', 'replace with actual user approval');
%
%   See also prepare_study, run_study, study_config

if nargin < 1
    stage = 'prepare';
end
if nargin < 2
    approvalNote = '';
end
assert(any(strcmp(stage, {'prepare','validation','full'})), ...
    'Study:Stage', 'Use prepare, validation or full.');
studyFolder = fileparts(mfilename('fullpath'));
projectRoot = fileparts(fileparts(fileparts(studyFolder)));
assert(isfile(fullfile(studyFolder, 'study_inputs.json')), ...
    'Study:Inputs', 'Keep this wrapper beside the study_inputs.json file.');

% Restore the caller's MATLAB path after either action.
previousPath = path;
pathCleanup = onCleanup(@() path(previousPath));
if strcmp(stage, 'prepare')
    %% Combine the shared templates with this study's own implementation
    runnerFolder = fullfile(projectRoot, 'SimulationStudies', 'runner');
    codeFolder = fullfile(studyFolder, 'code');
    addpath(runnerFolder, '-begin');
    for name = {'prepare_study','study_scope','file_sha256'}
        assert(strcmp(fileparts(which(name{1})), runnerFolder), ...
            'Study:Path', 'Use the maintained runner, not a shadowing %s.', name{1});
    end
    newStudyFolder = prepare_study(projectRoot, ...
        fullfile(studyFolder, 'study_inputs.json'), codeFolder);
    fprintf('New study: %s\nReview its plan/previews before approving validation.\n', newStudyFolder);
else
    %% Execute only this study's reviewed code, in a fresh batch process
    assert(batchStartupOptionUsed, 'Study:Batch', ...
        'Use MATLAB -batch for validation/full; prepare can run interactively.');
    assert(strlength(strtrim(string(approvalNote))) > 0, 'Study:Approval', ...
        'Supply the actual user approval for this stage.');
    saved = load(fullfile(studyFolder, 'state.mat'), 'state');
    assert(~strcmp(saved.state.status, 'completed'), 'Study:Completed', ...
        'This study is completed. Call rerun_study() to prepare a new one.');
    codeFolder = fullfile(studyFolder, 'code');
    addpath(codeFolder, '-begin');
    assert(strcmp(fileparts(which('run_study')), codeFolder), ...
        'Study:Path', 'Use the reviewed run_study.m inside this study.');
    run_study(studyFolder, stage, approvalNote);
    newStudyFolder = studyFolder;
end
end
