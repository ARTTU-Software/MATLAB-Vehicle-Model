function add_test_links(mode)
%ADD_TEST_LINKS Add the hyperlink table to suspension_model.
%
%   add_test_links            Add the title and hyperlink table (replaces an existing one).
%   add_test_links('remove')  Remove the title and hyperlink table.
%
%   The table is placed under the blocks and uses the same style as sm_car.slx.
%   It has links to run the bump and steering tests, reload the parameters, open the
%   Excel file and the test settings, and open the test scripts.
%
%   Only annotations are changed. All block parameters and the number of blocks and
%   lines are compared before saving; if they differ, the model is closed without saving.
%   A backup of the model and plot_with_tie_rod.m is saved in backups/ first.
%
%   Open the project (new_model.prj) before running this function.
%
% 

% If true, plot_with_tie_rod.m is updated to read the test settings from
% qc_test_settings.m (only if it does not already do so).
patchPlotScript = true;

if nargin < 1, mode = 'add'; end
mdl = 'suspension_model';
if exist('qc_root', 'file') == 2
    here = qc_root;
else
    here = fileparts(mfilename('fullpath'));
end
cd(here);

%% Check the required files
need = {[mdl '.slx'], 'plot_with_tie_rod.m', 'init_car.m'};
if strcmpi(mode, 'add'), need = [need, {'qc_test_settings.m', 'run_steering_test.m'}]; end
missing = need(cellfun(@(f) isempty(which(f)), need));
if ~isempty(missing)
    error('Not found on the path:\n  %s\nOpen the project (new_model.prj) first.', strjoin(missing, sprintf('\n  ')));
end
if bdIsLoaded(mdl) && strcmp(get_param(mdl, 'Dirty'), 'on')
    error('%s is open with UNSAVED changes. Save or discard them first.', mdl);
end

%% Backup
bk = fullfile(here, 'backups', ['backup_links_' char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'))]);
mkdir(bk);
copyfile(which([mdl '.slx']), bk);
copyfile(which('plot_with_tie_rod.m'), bk);
fprintf('>>> Backup saved in %s\n', bk);

%% Load the model and record its blocks and parameters
load_system(mdl);
before = snapshot(mdl);

% Remove annotations added by earlier versions of this function.
removeTagged(mdl, {'QC_LINKS', 'QC_TITLE', 'QC_UI'});

if strcmpi(mode, 'add')
    %% Place the table under the top-level blocks
    hb = find_system(mdl, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'block');
    P  = get_param(hb, 'Position'); if iscell(P), P = cell2mat(P); end
    xL = min(P(:,1));
    yB = max(P(:,4)) + 45;

    %% Title
    h = newAnnotation(mdl);
    set_param(h, 'Tag', 'QC_TITLE', 'Interpreter', 'off', ...
        'Text', 'Quarter Car with Double Wishbone Pushrod Suspension');
    set_param(h, 'Position', [xL, yB, xL+420, yB+19]);
    set_param(h, 'FontSize', 14, 'FontWeight', 'bold');

    %% Hyperlink table
    h = newAnnotation(mdl);
    set_param(h, 'Tag', 'QC_LINKS');
    set_param(h, 'Interpreter', 'rich');
    set_param(h, 'Text', tableHTML(mdl));
    set_param(h, 'Position', [xL, yB+28, xL+420, yB+330]);
    try, set_param(h, 'InternalMargins', [0 0 0 0]); catch, end
    try, set_param(h, 'FixedWidth', 'on', 'FixedHeight', 'off'); catch, end
end

%% Check that only annotations changed, then save
after = snapshot(mdl);
[ok, msg] = samePhysics(before, after);
if ~ok
    close_system(mdl, 0);
    error('Something other than the annotations changed - closed WITHOUT saving.\n%s', msg);
end
open_system(mdl);
set_param(mdl, 'ZoomFactor', 'FitSystem');
save_system(mdl);
fprintf('>>> Check passed (all block parameters unchanged). %s.slx saved.\n', mdl);

if strcmpi(mode, 'add') && patchPlotScript
    patchPlot(which('plot_with_tie_rod.m'));
end
fprintf(['\nDone. To undo: close the model (close_system(''%s'',0)) and copy the 2 files from\n' ...
         '   %s\nback to their folders.\n\n'], mdl, bk);
end


%% Local functions

function html = tableHTML(mdl)
%TABLEHTML Rich-text HTML for the hyperlink table.
%   The HTML structure and style (Arial 12px, black border, blue underlined links)
%   are the same as in the test table of sm_car.slx.

% Each link first changes to the project root, so result files are saved there.
if exist('qc_root', 'file') == 2
    go = 'cd(qc_root);';
else
    go = ['cd(fileparts(get_param(''' mdl ''',''FileName'')));'];
end

% HTML building blocks
ps  = ' style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"';
lnk = @(cmd, txt) ['<a href="matlab:' cmd '"><span style=" text-decoration: underline; color:#0000ff;">' txt '</span></a>'];
pc  = @(inner) ['<p align="center"' ps '>' inner '</p>'];
pl  = @(inner) ['<p align="left"' ps '>' inner '</p>'];
bold = @(txt) ['<span style=" font-weight:600;">' txt '</span>'];
empty = ['<p align="left" style="-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; ' ...
         'margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;"><br /></p>'];

openExcel = [go 'xf = which(''Vehicle_Parameters_QuarterCar.xlsx''); ' ...
             'if ispc, winopen(xf); else, system([''open '', xf]); end'];

html = [ ...
 '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">' newline ...
 '<html><head><meta name="qrichtext" content="1" /><meta charset="utf-8" /><style type="text/css">' newline ...
 'p, li { white-space: pre-wrap; }' newline ...
 'hr { height: 1px; border-width: 0; }' newline ...
 '</style></head><body align="left" style=" font-family:''Arial''; font-size:12px; font-weight:400; font-style:normal;">' newline ...
 pl('1. Tests: Click on the hyperlink to run the test.') newline ...
 '<table border="1" style=" border-color:#000000; border-style:solid; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px;" align="left" cellspacing="1" cellpadding="4">' newline ...
 '<tr>' newline ...
 '<td width="140">' pc(bold('Bump Test'))        pc('(road input)')   '</td>' newline ...
 '<td width="140">' pc(bold('Steering Test'))    pc('(rack_in)')      '</td></tr>' newline ...
 '<tr>' newline ...
 '<td>' pc(lnk([go 'plot_with_tie_rod'], 'Run'))  '</td>' newline ...
 '<td>' pc(lnk([go 'run_steering_test'], 'Run'))  '</td></tr></table>' newline ...
 empty newline ...
 pl(['2. ' lnk([go 'init_car; msgbox(''Data loaded'')'], 'Update data') ...
     '  (' lnk([go 'edit init_car'], 'see code') ')']) newline ...
 pl(['3. ' lnk(openExcel, 'Open Excel parameters')]) newline ...
 pl(['4. ' lnk([go 'edit qc_test_settings'], 'Test settings') ': amplitude, frequency, duration']) newline ...
 pl(['5. Bump test plots  (' lnk([go 'edit plot_with_tie_rod'], 'see code') ')']) newline ...
 pl(['6. Steering test plots  (' lnk([go 'edit run_steering_test'], 'see code') ')']) newline ...
 '</body></html>'];
end

function h = newAnnotation(mdl)
%NEWANNOTATION Create an empty annotation in the model and return its handle.
try
    a = Simulink.Annotation([mdl '/QC_tmp']);
    h = a.Handle;
catch
    h = add_block('built-in/Note', [mdl '/QC_tmp'], 'MakeNameUnique', 'on');
end
end

function removeTagged(mdl, tags)
%REMOVETAGGED Delete the top-level annotations whose Tag is one of TAGS.
hs = find_system(mdl, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'annotation');
for i = 1:numel(hs)
    try
        if any(strcmp(get_param(hs(i), 'Tag'), tags))
            try, delete(get_param(hs(i), 'Object')); catch, delete_block(hs(i)); end
        end
    catch
    end
end
end

function S = snapshot(mdl)
%SNAPSHOT Record all blocks, lines and block dialog parameters of the model,
%   including blocks inside subsystems and library links.
opts = {'FollowLinks', 'on', 'LookUnderMasks', 'all', 'FindAll', 'on'};
try
    hb = find_system(mdl, opts{:}, 'MatchFilter', @Simulink.match.allVariants, 'Type', 'block');
    hl = find_system(mdl, opts{:}, 'MatchFilter', @Simulink.match.allVariants, 'Type', 'line');
catch
    hb = find_system(mdl, opts{:}, 'Type', 'block');
    hl = find_system(mdl, opts{:}, 'Type', 'line');
end
S.nBlocks = numel(hb); S.nLines = numel(hl);
S.h = sort(hb); S.vals = cell(numel(S.h), 1);
for i = 1:numel(S.h)
    try
        dp = get_param(S.h(i), 'DialogParameters'); f = {};
        if isstruct(dp), f = fieldnames(dp); end
    catch
        f = {};
    end
    v = cell(numel(f), 1);
    for k = 1:numel(f)
        try
            x = get_param(S.h(i), f{k});
            if ischar(x) || isstring(x), v{k} = char(x);
            elseif isnumeric(x) || islogical(x), v{k} = mat2str(x);
            else, v{k} = ['<' class(x) '>'];
            end
        catch
            v{k} = '<unreadable>';
        end
    end
    S.vals{i} = [f(:) v];
end
end

function [ok, msg] = samePhysics(A, B)
%SAMEPHYSICS Compare two snapshots. OK is false if any block, line or parameter differs.
ok = true; msg = '';
if A.nBlocks ~= B.nBlocks || A.nLines ~= B.nLines || ~isequal(A.h, B.h)
    ok = false;
    msg = sprintf('Blocks %d -> %d, lines %d -> %d.', A.nBlocks, B.nBlocks, A.nLines, B.nLines);
    return
end
bad = {};
for i = 1:numel(A.h)
    if ~isequal(A.vals{i}, B.vals{i}), bad{end+1} = getfullname(A.h(i)); end %#ok<AGROW>
end
if ~isempty(bad)
    ok = false;
    msg = sprintf('Parameters changed in:\n  %s', strjoin(bad(1:min(10, end)), sprintf('\n  ')));
end
end

function patchPlot(f)
%PATCHPLOT Make plot_with_tie_rod.m read amp, freq, Tend, MaxStep and RelTol
%   from qc_test_settings.m. Does nothing if the script already uses qc_test_settings.
src = fileread(f);
if contains(src, 'qc_test_settings')
    fprintf('>>> plot_with_tie_rod.m already reads qc_test_settings.m - not changed.\n');
    return
end
o = {'lineanchors', 'once'};
pAmp  = '^[ \t]*amp[ \t]*=[^\r\n]*';
pFreq = '^[ \t]*freq[ \t]*=[^\r\n]*';
pTend = '^[ \t]*Tend[ \t]*=[^\r\n]*';
if isempty(regexp(src, pAmp, o{:})) || isempty(regexp(src, pFreq, o{:})) || isempty(regexp(src, pTend, o{:}))
    warning('amp / freq / Tend lines not found in plot_with_tie_rod.m - not changed.');
    return
end
new = src;
new = regexprep(new, pAmp, ['qc_test_settings;                           % test settings -> edit qc_test_settings.m' newline ...
                            'amp  = TEST.bump.amp;                       % [m]  +/- amplitude at the contact patch'], o{:});
new = regexprep(new, pFreq, 'freq = TEST.bump.freq;                      % [Hz]', o{:});
new = regexprep(new, pTend, 'Tend = TEST.bump.Tend;                      % [s]', o{:});
new = regexprep(new, '\(0:0\.001:Tend\)', '(0:TEST.sim.dt:Tend)', o{:});
% The sim call is replaced only if it is on a single line.
pSim = '^[ \t]*simOut[ \t]*=[ \t]*sim\(''suspension_model''[^\r\n]*';
simLine = regexp(new, pSim, 'match', o{:});
if ~isempty(simLine) && ~endsWith(strtrim(simLine), '...')
    new = regexprep(new, pSim, ['simOut = sim(''suspension_model'', ''StopTime'', num2str(Tend), ' ...
        '''MaxStep'', num2str(TEST.sim.MaxStep), ''RelTol'', num2str(TEST.sim.RelTol));'], o{:});
end
if ~isempty(regexp(new, 'zIn\s*=s\s', 'once'))
    new = regexprep(new, 'zIn\s*=s\s', 'zIn     = ', 'once');
    fprintf('>>> Fixed the typo "zIn =s" in plot_with_tie_rod.m.\n');
end
fid = fopen(f, 'w', 'n', 'UTF-8'); fprintf(fid, '%s', new); fclose(fid);
fprintf('>>> plot_with_tie_rod.m now reads the test settings from qc_test_settings.m.\n');
end