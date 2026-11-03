function metrics = plot_results(studyFolder,cfg)
%plot_results Export and verify completed WOT mass-study outputs.
%   METRICS = plot_results(STUDYFOLDER,CFG) reads selected signals from
%   each results/Rnnn.mat. It writes two PNG comparisons, a signed-G CSV
%   and table PNG. After checking exports, it removes only this study's
%   four historical preview files. No simulation or model access occurs.
%   Example: metrics = plot_results(studyFolder,saved.cfg);
data = cell(height(cfg.runs),1);
for k = 1:numel(data)
    data{k} = load(fullfile(studyFolder,'results',cfg.runs.ID(k)+".mat"));
end
metrics = render_outputs(studyFolder,cfg,data,false);
check = readtable(fullfile(studyFolder,'tables','longitudinal_g_metrics.csv'));
assert(height(check)==height(metrics) && ...
    all(abs(check.PositivePeak_g-metrics.PositivePeak_g)<1e-10 | ...
        (isnan(check.PositivePeak_g)&isnan(metrics.PositivePeak_g))) && ...
    all(abs(check.NegativePeak_g-metrics.NegativePeak_g)<1e-10 | ...
        (isnan(check.NegativePeak_g)&isnan(metrics.NegativePeak_g))), ...
    'Study:Export','Exported CSV does not match recorded peaks.');
exports = {'plots/cg_velocity.png','plots/longitudinal_acceleration.png', ...
    'tables/longitudinal_g_metrics.png'};
for k = 1:numel(exports)
    details = imfinfo(fullfile(studyFolder,exports{k}));
    assert(details.Width>0 && details.Height>0,'Study:Export','Invalid PNG export.');
end
previewFolder = fullfile(studyFolder,'previews');
previews = {'cg_velocity.png','longitudinal_acceleration.png', ...
    'longitudinal_g_metrics.csv','longitudinal_g_metrics.png'};
for k = 1:numel(previews)
    target = fullfile(previewFolder,previews{k});
    if isfile(target), delete(target); end
end
if isfolder(previewFolder) && numel(dir(previewFolder))==2, rmdir(previewFolder); end
end
