function generate_previews(projectRoot,studyFolder)
%generate_previews Render the requested layout from the shared archive.
%   generate_previews(PROJECTROOT,STUDYFOLDER) reads only the archived
%   historical Skidpad Dataset and prepared JSON. It repeats its actual
%   vx/gx traces for the three labels and writes explicitly historical
%   PNG/CSV layouts under previews/. No model or project is opened, no
%   new signals are synthesized and no extracted dataset is persisted.
%   Example: generate_previews(projectRoot,newStudyFolder);
cfg = study_config(fullfile(studyFolder,'study_inputs.json'));
archive = load(fullfile(projectRoot,'SimulationStudies','preview_data', ...
    'skidpad_workspace_2026-10-23.mat'),'logsout_sm_car');
historical.signals = extract_signals(archive.logsout_sm_car);
data = repmat({historical},height(cfg.runs),1);
render_outputs(fullfile(studyFolder,'previews'),cfg,data,true);
end
