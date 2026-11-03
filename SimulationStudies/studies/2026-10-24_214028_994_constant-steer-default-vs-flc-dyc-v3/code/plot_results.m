function metrics = plot_results(studyFolder,cfg)
%PLOT_RESULTS Compare controllers at each angle; save plots and peak table.
plotFolder = fullfile(studyFolder,'plots');
tableFolder = fullfile(studyFolder,'tables');
if ~isfolder(plotFolder), mkdir(plotFolder); end
if ~isfolder(tableFolder), mkdir(tableFolder); end
names = {'yawRate','lateralAcceleration','sideslip'};
labels = {'Yaw rate (deg/s)','Lateral acceleration (m/s^2)','Vehicle sideslip (deg)'};
files = {'yaw_rate.png','lateral_acceleration.png','vehicle_sideslip.png'};
angles = unique(cfg.runs.Steer_deg,'stable');
count = height(cfg.runs);
data = cell(count,1);
metrics = cfg.runs(:,{'ID','Controller','Steer_deg','InputProfile'});
metrics.StopEvent = strings(count,1);
metrics.StopSource = strings(count,1);
metrics.StopDescription = strings(count,1);
metrics.ActualStop_s = nan(count,1);
metrics.Start_s = nan(count,1);
metrics.End_s = nan(count,1);
metrics.Minimum_mps2 = nan(count,1);
metrics.Maximum_mps2 = nan(count,1);
metrics.PeakAbs_mps2 = nan(count,1);
metrics.PeakSigned_mps2 = nan(count,1);
metrics.PeakTime_s = nan(count,1);
for k = 1:count
    data{k} = load(fullfile(studyFolder,'results',cfg.runs.ID(k)+".mat"));
    assert(data{k}.metadata.completed,'Study:Incomplete','Incomplete case: %s',cfg.runs.ID(k));
    metrics.StopEvent(k) = string(data{k}.metadata.stopEvent);
    metrics.StopSource(k) = string(data{k}.metadata.stopSource);
    metrics.StopDescription(k) = string(data{k}.metadata.stopDescription);
    metrics.ActualStop_s(k) = data{k}.metadata.actualStop_s;
    ay = data{k}.signals.lateralAcceleration;
    metrics.Start_s(k) = ay.time_s(1);
    metrics.End_s(k) = ay.time_s(end);
    metrics.Minimum_mps2(k) = min(ay.value);
    metrics.Maximum_mps2(k) = max(ay.value);
    [metrics.PeakAbs_mps2(k),peakIndex] = max(abs(ay.value));
    metrics.PeakSigned_mps2(k) = ay.value(peakIndex);
    metrics.PeakTime_s(k) = ay.time_s(peakIndex);
end
metrics.PeakAbs_g = metrics.PeakAbs_mps2/9.80665;
writetable(metrics,fullfile(tableFolder,'peak_lateral_acceleration.csv'));

for s = 1:numel(names)
    fig = figure('Visible','off','Color','w','Position',[100 100 1250 470]);
    theme(fig, 'light'); % Keep axes, labels and legends light on every host.
    cleanup = onCleanup(@() close(fig));
    layout = tiledlayout(fig,1,numel(angles),'TileSpacing','compact','Padding','compact');
    for a = 1:numel(angles)
        ax = nexttile(layout);
        hold(ax,'on');
        for k = find(cfg.runs.Steer_deg==angles(a))'
            signal = data{k}.signals.(names{s});
            if cfg.runs.Controller(k)=="Default", style='-'; else, style='--'; end
            plot(ax,signal.time_s,signal.value,style,'LineWidth',1.6, ...
                'DisplayName',cfg.runs.Controller(k));
        end
        xline(ax,5,':','Steer starts','HandleVisibility','off');
        xline(ax,11,':','Brake starts','HandleVisibility','off');
        title(ax,sprintf('%g deg steering wheel',angles(a)));
        xlabel(ax,'Time (s)'); ylabel(ax,labels{s}); grid(ax,'on');
        legend(ax,'Location','best','Interpreter','none');
    end
    title(layout,'Constant Steer | native throttle/braking');
    exportgraphics(fig,fullfile(plotFolder,files{s}),'Resolution',170, 'BackgroundColor', 'white');
    clear cleanup
end
end
