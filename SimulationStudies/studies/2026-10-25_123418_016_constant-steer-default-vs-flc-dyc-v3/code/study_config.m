function cfg = study_config(inputFile)
%study_config - Read the input JSON and build the run table
%   CFG = study_config() reads study_inputs.json beside this function,
%   or at the parent study root when called from a study's code folder.
%   CFG contains fixed project settings and the expanded CFG.runs table.
%
%   CFG = study_config(inputFile) reads the specified JSON file path.
%   Every steeringAngles_deg value is paired with every controller,
%   in angle order and then controller order. Run IDs are R001, R002,
%   and so on. Unsupported settings and duplicate values are rejected.
%   This function does not load a model, simulate or write files.
%
%   Example: inspect the run list
%       cfg = study_config();
%       disp(cfg.runs)
%
%   See also prepare_study, rerun_study

%% 1. Read the input JSON
if nargin < 1
    folder = fileparts(mfilename('fullpath'));
    inputFile = fullfile(folder,'study_inputs.json');
    if ~isfile(inputFile)
        inputFile = fullfile(folder,'..','study_inputs.json');
    end
end
cfg = jsondecode(fileread(inputFile));
required = {'name','execution','model','maneuver', ...
    'steeringAngles_deg','controllers','stopTime_s'};
assert(isscalar(cfg) && all(isfield(cfg,required)), ...
    'Study:JSON','The input JSON is missing required configuration fields.');
assert(isempty(setdiff(fieldnames(cfg),required)), 'Study:JSON', ...
    'Unsupported JSON fields: resolve their input mappings before execution.');
%% 2. Fixed settings and supported execution mode
cfg.timezone = 'Europe/Bucharest';
cfg.project = 'SSVT_FSAE.prj';
cfg.projectFunctions = {'sm_car_read_database','sm_car_config_maneuver', ...
    'sm_car_maneuverdata_turn','sm_car_vehcfg_checkConfig'};
cfg.inputProfile = 'native throttle/braking';
cfg.validationSeconds = 1;
assert(strcmp(cfg.maneuver,'constant steer'), 'Study:Maneuver', ...
    ['This runner implements Constant Steer with native pedals only. ' ...
    'The agent must prepare matching scenario commands/checks for another maneuver.']);
assert(strcmp(cfg.model,'sm_car'), ...
    'Study:Project','This runner implements the sm_car FSAE project only.');
assert(strcmp(cfg.execution,'sequential'), 'Study:Mode', ...
    'This runner implements sequential execution only.');
validateattributes(cfg.stopTime_s,{'numeric'}, ...
    {'scalar','finite','>',cfg.validationSeconds});
%% 3. Check the requested angles and controller names
angles = cfg.steeringAngles_deg(:);
validateattributes(angles,{'numeric'},{'vector','nonempty','real','finite'});
assert(iscellstr(cfg.controllers) || isstring(cfg.controllers), ...
    'Study:Controllers','controllers must be an array of nonempty strings.');
controllers = string(cfg.controllers(:));
assert(~isempty(controllers) && all(strlength(strtrim(controllers))>0), ...
    'Study:Controllers','Provide at least one nonempty controller name.');
assert(numel(unique(angles))==numel(angles) && ...
    numel(unique(controllers))==numel(controllers), ...
    'Study:Duplicate','Angles and controllers must not contain duplicates.');
%% 4. Build one row for each angle/controller pair
% Ordinary nested loops keep the run order easy to see and edit.
count = numel(angles)*numel(controllers);
ID = strings(count, 1);
Controller = strings(count, 1);
Steer_deg = zeros(count, 1);
runNumber = 0;
for angleNumber = 1:numel(angles)
    for controllerNumber = 1:numel(controllers)
        runNumber = runNumber + 1;
        ID(runNumber) = sprintf('R%03d', runNumber);
        Controller(runNumber) = controllers(controllerNumber);
        Steer_deg(runNumber) = angles(angleNumber);
    end
end
cfg.runs = table(ID, Controller, Steer_deg);
cfg.runs.Label = Controller + " | " + Steer_deg + " deg";
cfg.runs.InputProfile = repmat("Native Turn throttle/braking", count, 1);
cfg.runs.Stop_s = repmat(cfg.stopTime_s, count, 1);
end
