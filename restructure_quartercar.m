function restructure_quartercar(mode)
%% restructure_quartercar.m  -  puts the quarter car files into folders (run ONCE)
% MATLAB R2026b. Put it in the project root (next to new_model.prj), together with the new
% add_test_links.m and qc_root.m. Open the project (new_model.prj) first.
%
%   restructure_quartercar            % DRY RUN: only prints what it would do
%   restructure_quartercar('apply')   % does it
%
% New structure:
%   new_model.prj, .gitignore, .gitattributes, resources/   (project root - must stay)
%   models/      suspension_model.slx, suspension_lib.slx (+ lib_sasiu_nou.slx if it exists)
%   parameters/  Vehicle_Parameters_QuarterCar.xlsx, init_car.m, cached_params.m
%   scripts/     plot_with_tie_rod.m, run_steering_test.m, qc_test_settings.m, compare_plots.m
%   tools/       add_test_links.m, organize_quartercar_folder.m, qc_root.m
%   results/     quartercar_*.mat / *.png            (already there)
%   backups/     local backups, not in git           (already there)
%   cache/       Simulink cache (*.slxc, slprj/)     (new, not in git)
%
% What else it does so that everything keeps working:
%   - moves the files INSIDE the MATLAB project (keeps the "Design" labels) and puts
%     models/, parameters/, scripts/, tools/ on the project path
%   - sets the project's Simulink cache folder to cache/
%   - init_car.m finds the Excel file and cached_params.m in its own folder (parameters/)
%   - the scripts save/load results in <root>/results/ (via qc_root), from any current folder
%   - redraws the hyperlink table in the model so the links work with the new folders
% No change to the model's blocks or parameters. Make a git commit first.

if nargin < 1, mode = 'dryrun'; end
apply = strcmpi(mode, 'apply');
root  = fileparts(mfilename('fullpath'));
cd(root);

layout = { ...
    'models',     {'suspension_model.slx', 'suspension_lib.slx', 'lib_sasiu_nou.slx'}; ...
    'parameters', {'Vehicle_Parameters_QuarterCar.xlsx', 'init_car.m', 'cached_params.m'}; ...
    'scripts',    {'plot_with_tie_rod.m', 'run_steering_test.m', 'qc_test_settings.m', 'compare_plots.m'}; ...
    'tools',      {'add_test_links.m', 'organize_quartercar_folder.m', 'qc_root.m'}};
stayInRoot = {'new_model.prj', '.gitignore', '.gitattributes', 'restructure_quartercar.m'};
cacheFiles = dir(fullfile(root, '*.slxc'));

%% Plan
fprintf('\n===== Restructure %s =====\n', root);
for r = 1:size(layout, 1)
    fprintf('\n%s/\n', layout{r,1});
    for k = 1:numel(layout{r,2})
        n = layout{r,2}{k};
        if isfile(fullfile(root, n)),                  s = 'move';
        elseif isfile(fullfile(root, layout{r,1}, n)), s = 'already there';
        else,                                          s = 'NOT FOUND (skipped)';
        end
        fprintf('   %-40s %s\n', n, s);
    end
end
fprintf('\ncache/  <- Simulink cache (deleted now, MATLAB recreates it there): %s\n', ...
    strjoin({cacheFiles.name}, ', '));
known = [[layout{:,2}], stayInRoot];
other = dir(root);
other = other(~[other.isdir] & ~ismember({other.name}, known) & ~endsWith({other.name}, '.slxc'));
if ~isempty(other)
    fprintf('\nOther files in the root (left where they are): %s\n', strjoin({other.name}, ', '));
end
if ~isfile(fullfile(root, 'qc_root.m')) && ~isfile(fullfile(root, 'tools', 'qc_root.m'))
    error('qc_root.m is missing - put it next to this script first.');
end
if ~apply
    fprintf('\nDRY RUN - nothing changed. If the plan is OK:  restructure_quartercar(''apply'')\n\n');
    return
end

%% Project
try
    proj = currentProject;
catch
    proj = openProject(fullfile(root, 'new_model.prj'));
end
if ~strcmp(proj.RootFolder, root)
    error('The open project is %s, not this folder. Open new_model.prj first.', proj.RootFolder);
end

%% Close the models
for m = {'suspension_model', 'suspension_lib', 'lib_sasiu_nou'}
    if bdIsLoaded(m{1})
        if strcmp(get_param(m{1}, 'Dirty'), 'on')
            error('%s has unsaved changes. Save it first.', m{1});
        end
        close_system(m{1}, 0);
    end
end

%% Move the files (inside the project)
for r = 1:size(layout, 1)
    folder = fullfile(root, layout{r,1});
    if ~isfolder(folder), mkdir(folder); end
    try, addFile(proj, folder); catch, end
    for k = 1:numel(layout{r,2})
        n = layout{r,2}{k};
        src = fullfile(root, n);  dst = fullfile(folder, n);
        if ~isfile(src)
            if strcmp(n, 'lib_sasiu_nou.slx')       % listed in the project but missing on disk
                try, removeFile(proj, src); fprintf('   removed missing %s from the project\n', n); catch, end
            end
            continue
        end
        movedInProject(proj, src, dst);
        fprintf('   %-40s -> %s/\n', n, layout{r,1});
    end
    try, addPath(proj, folder); catch e, fprintf('   (path: %s)\n', e.message); end
end

%% Cache folder
mkdir(fullfile(root, 'cache'));
for k = 1:numel(cacheFiles)
    try, removeFile(proj, fullfile(root, cacheFiles(k).name)); catch, end
    delete(fullfile(root, cacheFiles(k).name));
end
if isfolder(fullfile(root, 'slprj')), rmdir(fullfile(root, 'slprj'), 's'); end
try
    proj.SimulinkCacheFolder   = fullfile(root, 'cache');
    proj.SimulinkCodeGenFolder = fullfile(root, 'cache');
    fprintf('   Simulink cache folder -> cache/\n');
catch e
    fprintf('   (could not set the cache folder: %s)\n', e.message);
end
gi = fullfile(root, '.gitignore');
if isfile(gi) && ~contains(fileread(gi), 'cache/')
    fid = fopen(gi, 'a'); fprintf(fid, '\n# Simulink cache folder of the project\ncache/\n'); fclose(fid);
end

%% init_car.m: Excel + cached_params.m from its own folder
f = fullfile(root, 'parameters', 'init_car.m');
src = fileread(f);
if ~contains(src, 'mfilename(''fullpath'')')
    new = regexprep(src, '^([ \t]*)excel_file[ \t]*=[ \t]*''Vehicle_Parameters_QuarterCar\.xlsx''[ \t]*;', ...
        '$1excel_file = fullfile(fileparts(mfilename(''fullpath'')), ''Vehicle_Parameters_QuarterCar.xlsx'');', 'lineanchors', 'once');
    new = regexprep(new, '^([ \t]*)cache_file[ \t]*=[ \t]*''cached_params\.m''[ \t]*;', ...
        '$1cache_file = fullfile(fileparts(mfilename(''fullpath'')), ''cached_params.m'');', 'lineanchors', 'once');
    if strcmp(new, src)
        warning('init_car.m: excel_file / cache_file lines not found - check it by hand.');
    else
        writeText(f, new);
        fprintf('   init_car.m now reads the Excel file from parameters/\n');
    end
end

%% Scripts: results always in <root>/results
for s = {'plot_with_tie_rod.m', 'run_steering_test.m', 'compare_plots.m'}
    f = fullfile(root, 'scripts', s{1});
    if ~isfile(f), continue; end
    src = fileread(f);
    if contains(src, 'qc_root'), continue; end
    new = src;
    if ~contains(new, 'fullfile(''results''')
        new = regexprep(new, '''(quartercar_\w+\.(mat|png))''', 'fullfile(''results'',''$1'')');
        new = regexprep(new, '^([ \t]*)(save\(|exportgraphics\()', ...
            '$1if ~isfolder(''results''), mkdir(''results''); end\n$1$2', 'lineanchors', 'once');
    end
    new = strrep(new, 'isfolder(''results''), mkdir(''results'')', ...
                      'isfolder(fullfile(qc_root,''results'')), mkdir(fullfile(qc_root,''results''))');
    new = strrep(new, 'fullfile(''results'',', 'fullfile(qc_root,''results'',');
    writeText(f, new);
    fprintf('   %s saves/loads results in <root>/results\n', s{1});
end

%% Redraw the hyperlinks in the model for the new folders
rehash path;
try
    add_test_links;
catch e
    fprintf(2, '   add_test_links failed: %s\n   Run it again by hand: add_test_links\n', e.message);
end

%% Check
fprintf('\nCheck:\n');
for n = {'suspension_model.slx', 'suspension_lib.slx', 'init_car.m', 'Vehicle_Parameters_QuarterCar.xlsx', ...
         'plot_with_tie_rod.m', 'run_steering_test.m', 'qc_test_settings.m', 'qc_root.m', 'add_test_links.m'}
    w = which(n{1});
    if isempty(w), fprintf(2, '   NOT FOUND on the path: %s\n', n{1});
    else, fprintf('   OK  %s\n', strrep(w, [root filesep], ''));
    end
end
fprintf(['\nDone. Click "Run" on the Bump Test in the model to check everything.\n' ...
         'You can delete restructure_quartercar.m now. Undo: !git checkout . (after a commit).\n\n']);
end


%% ============================== helpers =============================================

function movedInProject(proj, src, dst)
% Move a file and keep it in the project with the same labels.
labels = {};
try
    pf = findFile(proj, src);
    if ~isempty(pf)
        for L = pf.Labels(:)'
            labels(end+1, :) = {L.CategoryName, L.Name}; %#ok<AGROW>
        end
    end
catch
end
try, removeFile(proj, src); catch, end
movefile(src, dst);
try
    nf = addFile(proj, dst);
    for k = 1:size(labels, 1)
        try, addLabel(nf, labels{k,1}, labels{k,2}); catch, end
    end
catch
end
end

function writeText(f, txt)
fid = fopen(f, 'w', 'n', 'UTF-8');
fprintf(fid, '%s', txt);
fclose(fid);
end