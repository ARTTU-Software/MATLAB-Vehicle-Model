function cfg = study_config()
%STUDY_CONFIG Native Constant Steer; edit cases and duration directly here.
cfg.name = 'constant-steer-default-vs-flc-dyc-v3';
cfg.timezone = 'Europe/Bucharest';
cfg.execution = 'sequential';
cfg.model = 'sm_car';
cfg.project = 'SSVT_FSAE.prj';
cfg.validationSeconds = 1;
cfg.runs = table(["D20";"F20";"D30";"F30";"D40";"F40"], ...
    ["Default";"FLC_DYC_V3";"Default";"FLC_DYC_V3";"Default";"FLC_DYC_V3"], ...
    [20;20;30;30;40;40], 'VariableNames',{'ID','Controller','Steer_deg'});
cfg.runs.Label = cfg.runs.Controller + " | " + cfg.runs.Steer_deg + " deg";
cfg.runs.InputProfile = repmat("Native Turn throttle/braking",6,1);
cfg.runs.Stop_s = repmat(19,6,1);
% Prior preview waiver and automatic full-stage approval continue for this test.
end
