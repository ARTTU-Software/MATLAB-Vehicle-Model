function metrics = render_outputs(outputFolder,cfg,data,isPreview)
%render_outputs Export two overlays and a signed longitudinal-G table.
%   METRICS = render_outputs(OUTPUTFOLDER,CFG,DATA,ISPREVIEW) uses a cell
%   array of selected signals/metadata, one entry per CFG.runs row.
%   ISPREVIEW labels repeated historical Skidpad traces explicitly and
%   puts all four exports in OUTPUTFOLDER. Actual results use plots/ and
%   tables/ below OUTPUTFOLDER. Native timestamps are never resampled.
%   No model access or simulation occurs. Files of the same names are
%   replaced. Peaks use all valid samples, g = acceleration/9.80665;
%   a missing positive/negative sign is NaN rather than an invented zero.
%   Example: metrics = render_outputs(studyFolder,cfg,data,false);
plotFolder = fullfile(outputFolder,'plots');
tableFolder = fullfile(outputFolder,'tables');
if isPreview, plotFolder = outputFolder; tableFolder = outputFolder; end
if ~isfolder(plotFolder), mkdir(plotFolder); end
if ~isfolder(tableFolder), mkdir(tableFolder); end
count = height(cfg.runs);
metrics = cfg.runs(:,{'ID','BodyMassOffset_kg','BodyMass_kg','Controller'});
metrics.Start_s = nan(count,1);
metrics.End_s = nan(count,1);
metrics.ActualStop_s = nan(count,1);
metrics.PositivePeak_g = nan(count,1);
metrics.PositivePeakTime_s = nan(count,1);
metrics.NegativePeak_g = nan(count,1);
metrics.NegativePeakTime_s = nan(count,1);
metrics.StopCondition = strings(count,1);
for k = 1:count
    acceleration = data{k}.signals.longitudinalAcceleration;
    g = acceleration.value/9.80665;
    metrics.Start_s(k) = acceleration.time_s(1);
    metrics.End_s(k) = acceleration.time_s(end);
    positive = find(g>0);
    negative = find(g<0);
    if ~isempty(positive)
        [metrics.PositivePeak_g(k),index] = max(g(positive));
        metrics.PositivePeakTime_s(k) = acceleration.time_s(positive(index));
    end
    if ~isempty(negative)
        [metrics.NegativePeak_g(k),index] = min(g(negative));
        metrics.NegativePeakTime_s(k) = acceleration.time_s(negative(index));
    end
    if ~isPreview
        assert(data{k}.metadata.completed,'Study:Incomplete','Incomplete run %s.',cfg.runs.ID(k));
        metrics.ActualStop_s(k) = data{k}.metadata.actualStop_s;
        metrics.StopCondition(k) = string(data{k}.metadata.stopCondition);
    end
end
if isPreview
    metrics.Provenance = repmat("Historical Skidpad; repeated for layout only",count,1);
end
writetable(metrics,fullfile(tableFolder,'longitudinal_g_metrics.csv'));

names = {'cgVelocity','longitudinalAcceleration'};
labels = {'CG longitudinal velocity (km/h)','Longitudinal acceleration (m/s^2)'};
files = {'cg_velocity.png','longitudinal_acceleration.png'};
colors = [0.00 0.38 0.67;0.85 0.32 0.08;0.30 0.58 0.22];
styles = {'-','--',':'};
for signalNumber = 1:2
    fig = figure('Visible','off','Color','w','Position',[100 100 1180 600]);
    theme(fig,'light');
    cleanup = onCleanup(@() close(fig));
    ax = axes(fig); hold(ax,'on');
    for k = 1:count
        signal = data{k}.signals.(names{signalNumber});
        plot(ax,signal.time_s,signal.value,styles{mod(k-1,3)+1}, ...
            'Color',colors(mod(k-1,3)+1,:),'LineWidth',1.8, ...
            'DisplayName',cfg.runs.Label(k));
    end
    if isPreview
        title(ax,{'PREVIEW ONLY - historical Skidpad data, not this study''s results'; ...
            'Repeated traces show layout only; no mass-response prediction'},'FontSize',13);
    else
        xline(ax,1,':','Throttle starts','HandleVisibility','off');
        xline(ax,6,':','Throttle release','HandleVisibility','off');
        xline(ax,7,':','Brake starts','HandleVisibility','off');
        title(ax,{'WOT body-mass comparison | Default controller | estimator bypassed'; ...
            '100% throttle phase, then native braking; actual recorded durations'});
    end
    xlabel(ax,'Time (s)'); ylabel(ax,labels{signalNumber}); grid(ax,'on');
    legend(ax,'Location','best','Interpreter','none');
    exportgraphics(fig,fullfile(plotFolder,files{signalNumber}), ...
        'Resolution',170,'BackgroundColor','white');
    clear cleanup
end

fig = figure('Visible','off','Color','w','Position',[100 100 1320 460]);
theme(fig,'light');
cleanup = onCleanup(@() close(fig));
ax = axes(fig,'Position',[0.035 0.12 0.93 0.75]);
axis(ax,[0 1 0 1]); axis(ax,'off');
caption = 'WOT body-mass comparison | signed longitudinal-G peaks';
if isPreview
    caption = 'PREVIEW ONLY - historical Skidpad values repeated for layout; not WOT results';
end
title(ax,caption,'FontSize',13);
headers = {'Body mass (kg)','Offset (kg)','Max positive (g)','Min negative (g)','Recorded interval (s)'};
x = [0.01 0.21 0.39 0.61 0.80];
for column = 1:numel(headers)
    text(ax,x(column),0.84,headers{column},'FontWeight','bold','FontSize',11);
end
for k = 1:count
    values = {sprintf('%.2f',metrics.BodyMass_kg(k)), ...
        sprintf('%+g',metrics.BodyMassOffset_kg(k)), ...
        sprintf('%.5f',metrics.PositivePeak_g(k)), ...
        sprintf('%.5f',metrics.NegativePeak_g(k)), ...
        sprintf('%.3f - %.3f',metrics.Start_s(k),metrics.End_s(k))};
    for column = 1:numel(values)
        text(ax,x(column),0.65-(k-1)*0.18,values{column},'FontSize',12);
    end
end
text(ax,0.01,0.04,'g = 9.80665 m/s^2 | full recorded interval | NaN if that sign is absent', ...
    'FontSize',10);
exportgraphics(fig,fullfile(tableFolder,'longitudinal_g_metrics.png'), ...
    'Resolution',170,'BackgroundColor','white');
end
