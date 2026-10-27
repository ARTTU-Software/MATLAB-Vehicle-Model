function cfg = study_config(inputFile)
%study_config Read WOT mass-study JSON and expand the sequential run table.
%   CFG = study_config(INPUTFILE) reads the JSON path; when omitted it
%   uses study_inputs.json at the parent study root. Null stopTime_s
%   means Inf: model stop conditions determine completion. Mass offsets
%   are kg relative to the reviewed saved body mass, 255.07 kg.
%   This function neither loads a model nor writes files.
%   Example: cfg = study_config('/path/to/study_inputs.json');
if nargin < 1
    inputFile = fullfile(fileparts(mfilename('fullpath')),'..','study_inputs.json');
end
cfg = jsondecode(fileread(inputFile));
required = {'name','execution','model','maneuver','bodyMassOffsets_kg', ...
    'controller','stateEstimator','stopTime_s'};
assert(isscalar(cfg) && all(isfield(cfg,required)) && ...
    isempty(setdiff(fieldnames(cfg),required)),'Study:JSON','Unsupported input JSON.');
assert(strcmp(cfg.model,'sm_car') && strcmp(cfg.maneuver,'WOT Braking') && ...
    strcmp(cfg.execution,'sequential') && strcmp(cfg.controller,'Default') && ...
    strcmp(cfg.stateEstimator,'through'),'Study:Scope','Unsupported WOT configuration.');
cfg.timezone = 'Europe/Bucharest';
cfg.project = 'SSVT_FSAE.prj';
cfg.projectFunctions = {'sm_car_read_database','sm_car_config_maneuver', ...
    'sm_car_maneuverdata_wot_braking','sm_car_vehcfg_checkConfig'};
cfg.nominalBodyMass_kg = 255.07;
cfg.validationSeconds = 1.3;
cfg.inputProfile = '100% throttle 1.2-6 s; native braking from 7 s';
if isempty(cfg.stopTime_s)
    cfg.stopTime_s = Inf;
else
    validateattributes(cfg.stopTime_s,{'numeric'}, ...
        {'scalar','real','finite','>',cfg.validationSeconds});
end
offsets = cfg.bodyMassOffsets_kg(:);
validateattributes(offsets,{'numeric'},{'vector','nonempty','real','finite'});
assert(numel(unique(offsets))==numel(offsets),'Study:Duplicate','Duplicate mass offsets.');
count = numel(offsets);
ID = string(compose('R%03d',(1:count)'));
Controller = repmat(string(cfg.controller),count,1);
BodyMassOffset_kg = offsets;
BodyMass_kg = cfg.nominalBodyMass_kg + offsets;
assert(all(BodyMass_kg>0),'Study:Mass','Body mass must be positive.');
cfg.runs = table(ID,Controller,BodyMassOffset_kg,BodyMass_kg);
cfg.runs.Label = string(compose('%.2f kg (%+g kg)',BodyMass_kg,offsets));
cfg.validationRunIDs = cfg.runs.ID(end); % One changed mass represents the shared structure.
cfg.runs.InputProfile = repmat(string(cfg.inputProfile),count,1);
cfg.runs.Stop_s = repmat(cfg.stopTime_s,count,1);
end
