%% compare_quartercars.m  -  overlays YOUR quarter car and the BIG MODEL quarter car
% Needs both files in the current folder:
%    quartercar_kinematics.mat   <- plot_quartercar.m            (your model)
%    quartercar_bigmodel.mat     <- plot_bigmodel_quartercar.m   (big model)
% x-axis for both = wheel travel [mm]. Signs are aligned automatically
% (the script tells you if it had to flip one of your curves).

mine = load(fullfile(qc_root,'results','quartercar_kinematics.mat')); mine = mine.results;
big  = load(fullfile(qc_root,'results','quartercar_bigmodel.mat'));   big  = big.results;

fields = {'camber_deg','toe_deg','dSpring_mm','Fpost_N','FSpring_N'};
names  = {'Camber change [deg]','Toe change [deg]','\Delta Spring length [mm]', ...
    'Wheel force F_z [N]','Spring force [N]'};
units  = {'deg/mm','deg/mm','mm/mm','N/mm','N/mm'};
label  = {'Camber gain','Bump steer','Motion ratio','Wheel rate','Spring rate @ wheel'};

% common travel grid
[xM,iM] = unique(mine.travel_mm);  [xB,iB] = unique(big.travel_mm);
xc = linspace(max(min(xM),min(xB)), min(max(xM),max(xB)), 201)';
slope = @(x,y) subsref(polyfit(x(abs(x)<=10), y(abs(x)<=10), 1), struct('type','()','subs',{{1}}));

fig = figure('Name','Quarter-Car Comparison','Color','w','Position',[60 60 1300 760]);
try, theme(fig,'light'); catch, end
fprintf('\n%-22s %12s %12s %10s\n','', 'Your model','Big model','Diff');
ax = gobjects(6,1); diffs = nan(numel(xc),2);

for f = 1:numel(fields)
    fn = fields{f};
    if ~ismember(fn, mine.Properties.VariableNames) || ~ismember(fn, big.Properties.VariableNames) ...
            || all(isnan(mine.(fn))) || all(isnan(big.(fn)))
        fprintf('%-22s  (not available in both files - run both plot scripts again)\n', label{f});
        continue
    end
    if f <= 3      % kinematic quantities (no hysteresis): put both on one grid
        xpM = xc; xpB = xc;
        yM = interp1(xM, mine.(fn)(iM), xc);  yB = interp1(xB, big.(fn)(iB), xc);
        yM = yM - interp1(xc,yM,0); yB = yB - interp1(xc,yB,0);
        c = corrcoef(yM, yB);
        if c(1,2) < 0      % align sign conventions
            yM = -yM;
            fprintf('  (note: your %s had the opposite sign convention - flipped)\n', label{f});
        end
        if f <= 2, diffs(:,f) = yM - yB; end
    else           % forces: loops because of the damper -> plot raw data
        xpM = mine.travel_mm; yM = mine.(fn);
        xpB = big.travel_mm;  yB = big.(fn);
    end
    sM = slope(xpM,yM); sB = slope(xpB,yB);
    fprintf('%-22s %+10.4f   %+10.4f   %+7.1f %%   [%s]\n', label{f}, sM, sB, 100*(sM-sB)/abs(sB), units{f});

    ax(f) = subplot(2,3,f);
    plot(xpM, yM, 'b-', xpB, yB, 'r--', 'LineWidth', 2);
    xlabel('Wheel travel [mm] (Bump +, Rebound -)'); ylabel(names{f});
    title(sprintf('%s: %.4g vs %.4g %s', label{f}, sM, sB, units{f}));
    if f == 1, lg = legend('Your model','Big model','Location','best'); end
end

ax(6) = subplot(2,3,6);
plot(xc, diffs(:,1), 'b-', xc, diffs(:,2), 'r-', 'LineWidth', 2);
xlabel('Wheel travel [mm]'); ylabel('Your - Big [deg]');
legend('Camber','Toe','Location','best');
title('Kinematic Differences');
fprintf('Max camber difference over the stroke: %.3f deg\n', max(abs(diffs(:,1))));
fprintf('Max toe difference over the stroke:    %.3f deg\n\n', max(abs(diffs(:,2))));

for i = 1:6
    if isgraphics(ax(i))
        set(ax(i),'Color','w','XColor','k','YColor','k','GridColor',[0.15 0.15 0.15],'GridAlpha',0.25,'FontSize',9);
        grid(ax(i),'on'); ax(i).Title.Color = 'k';
    end
end
try, set(lg,'TextColor','k','Color','w','EdgeColor',[0.6 0.6 0.6]); catch, end
if ~isfolder(fullfile(qc_root,'results')), mkdir(fullfile(qc_root,'results')); end
exportgraphics(fig,fullfile(qc_root,'results','quartercar_comparison.png'),'Resolution',200,'BackgroundColor','white');
disp('>>> Saved quartercar_comparison.png');