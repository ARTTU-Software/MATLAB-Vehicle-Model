function studyFolder = prepare_study(projectRoot, inputFile, codeFolder)
%prepare_study - Combine study code with shared execution templates
%   studyFolder = prepare_study(projectRoot, inputFile) prepares a new
%   dated study from the JSON at inputFile and the code/ folder beside
%   it. projectRoot is the vehicle project root. studyFolder is the new
%   study root path. The source JSON and existing results are preserved.
%
%   studyFolder = prepare_study(projectRoot, inputFile, codeFolder)
%   selects an explicit source study code folder. This is useful when
%   reusing a legacy JSON with a newer compatible study implementation.
%   The source must supply study_config, simulate_run, plot_results and
%   write_study_plan, plus its study-specific checks/extraction helpers.
%
%   Call this maintained template from SimulationStudies/runner. It
%   checks shared inventory, saves the current project baseline, copies
%   study code and current shared templates, and records a review plan.
%   It does not create previews, open a model or run simulations.
%
%   Example: with the shared runner on the path, from a study folder
%       inputFile = fullfile(pwd, 'study_inputs.json');
%       newFolder = prepare_study(projectRoot, inputFile);
%
%   See also rerun_study, run_study, study_scope

% Study code stays in the source study; this folder holds shared templates.
if nargin < 3
    codeFolder = fullfile(fileparts(inputFile), 'code');
end
runnerFolder = fileparts(mfilename('fullpath'));
previousPath = path;
pathCleanup = onCleanup(@() path(previousPath));
addpath(codeFolder, '-begin');
addpath(runnerFolder, '-begin');
for name = {'study_config','write_study_plan','simulate_run','plot_results'}
    assert(strcmp(fileparts(which(name{1})), codeFolder), 'Study:Source', ...
        'Study-specific function %s must resolve inside %s.', name{1}, codeFolder);
end
cfg = study_config(inputFile);
assert(ismac || ispc, 'Study:OS', 'This example supports macOS and Windows.');
assert(strcmp(cfg.execution, 'sequential'), 'Study:Mode', ...
    'This example implements sequential execution only.');
assert(~isempty(regexp(cfg.name, '^[a-z0-9-]+$', 'once')), 'Study:Name', ...
    'Use lowercase letters, digits and hyphens for the study name.');
%% Check the saved inventory without initializing MATLAB project data
inventoryFolder = fullfile(projectRoot, 'SimulationStudies', 'inventory', 'saved');
inventoryFiles = readtable(fullfile(inventoryFolder, 'fingerprints.csv'), 'TextType','string');
% CSV imports 0/1 as numbers; table row selection needs logical flags.
inventoryFiles.External = logical(inventoryFiles.External);
for k = 1:height(inventoryFiles)
    sourceFile = inventoryFiles.Path(k);
    if ~inventoryFiles.External(k)
        sourceFile = fullfile(projectRoot, sourceFile);
    end
    assert(strcmp(file_sha256(sourceFile), inventoryFiles.SHA256(k)), 'Study:StaleInventory', ...
        'Inventory changed: %s. Refresh the saved-file inventory before preparation.', sourceFile);
end

%% Create a dated folder; never overwrite an earlier study
stamp = char(datetime('now', 'TimeZone',cfg.timezone, 'Format','yyyy-MM-dd_HHmmss_SSS'));
studyFolder = fullfile(projectRoot, 'SimulationStudies', 'studies', [stamp '_' cfg.name]);
assert(~isfolder(studyFolder), 'Study:Exists', 'Study folder already exists.');
mkdir(studyFolder);
mkdir(fullfile(studyFolder, 'code'));
% Copy the study implementation, then the current shared template snapshots.
sharedNames = {'prepare_study.m','run_study.m','study_scope.m','file_sha256.m'};
codeFiles = dir(fullfile(codeFolder, '*.m'));
for k = 1:numel(codeFiles)
    name = codeFiles(k).name;
    if ~ismember(name, [sharedNames, {'rerun_study.m'}])
        copyfile(fullfile(codeFolder, name), fullfile(studyFolder, 'code'));
    end
end
for k = 1:numel(sharedNames)
    copyfile(fullfile(runnerFolder, sharedNames{k}), fullfile(studyFolder, 'code'));
end
copyfile(fullfile(runnerFolder, 'rerun_study.m'), fullfile(studyFolder, 'rerun_study.m'));
copyfile(inputFile, fullfile(studyFolder,'study_inputs.json'));

%% Save a baseline archive, excluding generated output and private folders
relativeFiles = savedFiles(projectRoot, '');
hashes = strings(numel(relativeFiles),1);
for k = 1:numel(relativeFiles)
    hashes(k) = file_sha256(fullfile(projectRoot, relativeFiles{k}));
end
baselineFiles = table(string(relativeFiles(:)), hashes, 'VariableNames',{'Path','SHA256'});
writetable(baselineFiles, fullfile(studyFolder, 'baseline_files.csv'));
zip(fullfile(studyFolder, 'baseline.zip'), relativeFiles, projectRoot);

%% Write this study's scenario-specific plan
write_study_plan(studyFolder, cfg, stamp);

state.host = computer;
% Keep only preparation-time external hashes, not a model inventory copy.
state.externalDependencies = inventoryFiles(inventoryFiles.External,:);
state.inventorySource = 'SimulationStudies/inventory/saved';
state.scope = study_scope(studyFolder);
state.status = 'prepared_pending_preview_review';
state.validationPassed = false;
save(fullfile(studyFolder, 'state.mat'), 'state', 'cfg');
fprintf('Prepared (no simulation): %s\nPreview review and stage approvals are still required.\n', studyFolder);
end

function files = savedFiles(root, relative)
%savedFiles - List saved project files for the isolated baseline
%   FILES = savedFiles(ROOT, RELATIVE) recursively returns a cell array
%   of project-relative file paths. ROOT is the project root path;
%   RELATIVE is the starting subfolder, or an empty character vector
%   for the root. Generated/private folders and backup files are skipped.
%   No files are modified. This helper is local to prepare_study.
%
%   Example: internal call when collecting the baseline
%       files = savedFiles(projectRoot, '');
%
%   See also prepare_study, dir

skip = {'.git','.codex','.agents','.aws','SimulationStudies','work','slprj', ...
    'spinfo','codegen','__pycache__','sdireports'};
entries = dir(fullfile(root, relative));
files = {};
for k = 1:numel(entries)
    name = entries(k).name;
    if ismember(name, [{'.','..','.DS_Store'}, skip]) || startsWith(name,'~$')
        continue;
    end
    path = fullfile(relative, name);
    if entries(k).isdir
        files = [files; savedFiles(root, path)]; %#ok<AGROW>
    else
        [~,~,ext] = fileparts(name);
        if ismember(lower(ext), {'.original','.asv','.slxc','.mp4','.avi','.log'}) || ...
                ~isempty(regexp(ext, '^\.r\d{4}[ab]$', 'once'))
            continue;
        end
        files{end+1,1} = path; %#ok<AGROW>
    end
end
end
