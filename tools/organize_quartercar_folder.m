function organize_quartercar_folder(mode)
%ORGANIZE_QUARTERCAR_FOLDER Clean up the quarter car project folder.
%
%   organize_quartercar_folder           List the planned changes (no files are changed).
%   organize_quartercar_folder('apply')  Apply the changes.
%
%   Files used by suspension_model and by the test scripts stay in the root folder.
%   Test results (quartercar_*.mat, quartercar_*.png) are moved to results/.
%   Files that are not used are deleted to the Recycle Bin.
%   Simulink cache files (*.slxc, slprj/) and .DS_Store are deleted permanently.
%
%   Required files are found with dependencies.fileDependencyAnalysis and libinfo.
%   The test scripts are updated to save and load their results in results/.
%   A copy of each script is saved in backups/ before it is changed.
%

if nargin < 1, mode = 'dryrun'; end
apply = strcmpi(mode, 'apply');
mdl   = 'suspension_model';
here  = fileparts(mfilename('fullpath'));
cd(here);

%% Files and folders kept in the root folder
keep = {[mdl '.slx'], 'suspension_lib.slx', 'Vehicle_Parameters_QuarterCar.xlsx', ...
        'init_car.m', 'cached_params.m', 'new_model.prj', ...
        'plot_with_tie_rod.m', 'run_steering_test.m', 'qc_test_settings.m', ...
        'compare_plots.m', 'add_test_links.m', 'organize_quartercar_folder.m', ...
        '.gitignore', '.gitattributes'};
keepDirs = {'resources', '.git', 'results', 'backups'};

deps = findDependencies(here, mdl, keep);
keep = unique([keep, deps]);

%% Classify the contents of the root folder
L = dir(here);
L = L(~ismember({L.name}, {'.', '..'}));
plan = struct('name', {}, 'action', {}, 'why', {});
for i = 1:numel(L)
    n = L(i).name;
    if L(i).isdir
        if ismember(n, keepDirs),          a = 'keep';    w = 'project / organiser folder';
        elseif strcmp(n, 'slprj'),         a = 'delete';  w = 'Simulink cache, recreated automatically';
        elseif startsWith(n, 'backup_'),   a = 'trash';   w = 'old backup folder';
        else,                              a = 'keep';    w = 'unknown folder - left alone';
        end
    else
        if ismember(n, keep),                               a = 'keep';    w = 'needed';
        elseif endsWith(n, '.slxc') || strcmp(n, '.DS_Store'), a = 'delete';  w = 'cache / Mac file, recreated automatically';
        elseif ~isempty(regexp(n, '^quartercar_\w+\.(mat|png)$', 'once')), a = 'results'; w = 'test result';
        else,                                               a = 'trash';   w = 'not used by the model or the scripts';
        end
    end
    plan(end+1) = struct('name', n, 'action', a, 'why', w); %#ok<AGROW>
end

%% Print the plan
fprintf('\n===== Quarter car folder: %s =====\n', here);
order = {'keep', 'results', 'trash', 'delete'};
heads = {'STAYS in the root', 'MOVES to results/', 'DELETED to the Recycle Bin (not used any more)', ...
         'DELETED permanently (caches, recreated automatically)'};
for k = 1:numel(order)
    p = plan(strcmp({plan.action}, order{k}));
    if isempty(p), continue; end
    fprintf('\n%s\n', heads{k});
    for j = 1:numel(p), fprintf('   %-40s %s\n', p(j).name, p(j).why); end
end
if ~isempty(deps)
    fprintf('\nFound as dependencies (kept): %s\n', strjoin(deps, ', '));
end
fprintf('\nScripts that will save/load results in results/: plot_with_tie_rod.m, run_steering_test.m, compare_plots.m\n');

if ~apply
    fprintf(['\nDRY RUN - nothing was changed.\n' ...
             'Check the lists above. If a file in the Recycle Bin list is needed, add its name to "keep"\n' ...
             'at the top of this script. Then run:  organize_quartercar_folder(''apply'')\n\n']);
    return
end

%% Close the model and the library
if bdIsLoaded(mdl)
    if strcmp(get_param(mdl, 'Dirty'), 'on')
        error('%s has unsaved changes. Save it first, then run again.', mdl);
    end
    close_system(mdl, 0);
end
if bdIsLoaded('suspension_lib'), close_system('suspension_lib', 0); end

stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
for d = {'results', 'backups'}
    if ~isfolder(d{1}), mkdir(d{1}); end
end
bkScripts = fullfile('backups', ['before_organize_' stamp]);
mkdir(bkScripts);

proj = [];
try, proj = currentProject; catch, end

%% Move and delete files
for i = 1:numel(plan)
    n = plan(i).name;  src = fullfile(here, n);
    switch plan(i).action
        case 'results'
            dst = fullfile(here, plan(i).action, n);
            if exist(dst, 'file') || isfolder(dst)
                [~, b, e] = fileparts(n); dst = fullfile(here, plan(i).action, [b '_' stamp e]);
            end
            movefile(src, dst);
            removeFromProject(proj, src);
            fprintf('   moved   %-38s -> %s/\n', n, plan(i).action);
        case 'delete'
            if isfolder(src), rmdir(src, 's'); else, delete(src); end
            removeFromProject(proj, src);
            fprintf('   deleted %s\n', n);
        case 'trash'
            toRecycleBin(src);
            removeFromProject(proj, src);
            fprintf('   deleted %-38s (Recycle Bin)\n', n);
    end
end

%% Update the result paths in the test scripts
for s = {'plot_with_tie_rod.m', 'run_steering_test.m', 'compare_plots.m'}
    f = fullfile(here, s{1});
    if ~isfile(f), continue; end
    copyfile(f, bkScripts);
    src = fileread(f);
    if contains(src, 'fullfile(''results''')
        fprintf('   %s already uses results/ - not changed\n', s{1});
        continue
    end
    new = regexprep(src, '''(quartercar_\w+\.(mat|png))''', 'fullfile(''results'',''$1'')');
    % Create results/ before the first save or exportgraphics call.
    new = regexprep(new, '^([ \t]*)(save\(|exportgraphics\()', ...
        '$1if ~isfolder(''results''), mkdir(''results''); end\n$1$2', 'lineanchors', 'once');
    fid = fopen(f, 'w', 'n', 'UTF-8'); fprintf(fid, '%s', new); fclose(fid);
    fprintf('   updated %s (results in results/)\n', s{1});
end

%% Exclude backups/ from git
gi = fullfile(here, '.gitignore');
if isfile(gi) && ~contains(fileread(gi), 'backups/')
    fid = fopen(gi, 'a'); fprintf(fid, '\n# Local backups made by the scripts\nbackups/\n'); fclose(fid);
    fprintf('   .gitignore: added backups/\n');
end

%% Check that the model loads
fprintf('\nChecking that the model still loads ...\n');
try
    load_system(mdl);
    fprintf('   %s loads OK.\n', mdl);
    close_system(mdl, 0);
catch e
    fprintf(2, '   PROBLEM loading %s: %s\n   Restore the missing file from the Recycle Bin.\n', mdl, e.message);
end
fprintf(['\nDone. Now run a test (link "Run" in the model) to check everything.\n' ...
         'Undo: restore deleted files from the Recycle Bin (or git), move files back from results/,\n' ...
         'and copy the 3 scripts from\n   %s\n\n'], ...
         fullfile(here, bkScripts));
end


%% Local functions

function deps = findDependencies(here, mdl, keep)
%FINDDEPENDENCIES Files in the root folder used by the model or by the kept scripts.
%   Includes libraries, referenced models, data files and called scripts/functions.
deps = {};
items = [{mdl}, keep(endsWith(keep, '.m') & cellfun(@(f) isfile(fullfile(here, f)), keep))];
for i = 1:numel(items)
    try
        files = dependencies.fileDependencyAnalysis(items{i});
        if ischar(files), files = {files}; end
        for k = 1:numel(files)
            [p, b, e] = fileparts(files{k});
            if strcmp(p, here), deps{end+1} = [b e]; end %#ok<AGROW>
        end
    catch
    end
end
%Libraries linked from the model
try
    load_system(mdl);
    li = libinfo(mdl);
    for k = 1:numel(li)
        f = which(li(k).Library);
        if ~isempty(f)
            [p, b, e] = fileparts(f);
            if strcmp(p, here), deps{end+1} = [b e]; end %#ok<AGROW>
        end
    end
catch
end
deps = unique(deps(~ismember(deps, keep)));
% Result files are handled separately and always go to results/.
deps = deps(cellfun(@isempty, regexp(deps, '^quartercar_\w+\.(mat|png)$', 'once')));
end

function toRecycleBin(src)
%TORECYCLEBIN Delete a file or folder to the Recycle Bin (Windows) or Trash (macOS).
old = recycle('on');
c = onCleanup(@() recycle(old));
if isfolder(src)
    f = dir(fullfile(src, '**', '*'));
    f = f(~[f.isdir]);
    for k = 1:numel(f), delete(fullfile(f(k).folder, f(k).name)); end
    rmdir(src, 's');
else
    delete(src);
end
end

function removeFromProject(proj, f)
%REMOVEFROMPROJECT Remove a moved or deleted file from the MATLAB project.
if isempty(proj), return; end
try, removeFile(proj, f); catch, end
end