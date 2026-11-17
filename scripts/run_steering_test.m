%% run_steering_test.m  -  steering test of the New Quarter Car (first version)
% rack_in = sine (settings in qc_test_settings.m, TEST.steer), road height fixed at 0,
% chassis fixed. Plots toe and camber against rack travel and saves the results.
% Rack sign: + = positive direction of the rack Prismatic joint (along Y).

init_car;                                   % parameters (note: init_car calls clear)
qc_test_settings;                           % TEST.* (must come after init_car)

%% Inputs
S = TEST.steer;
t = (0:TEST.sim.dt:S.Tend)';
rack_in   = timeseries(S.amp*sin(2*pi*S.freq*t), t);   % rack displacement [m]
z_road_in = timeseries(zeros(size(t)), t);             % road held at the static height [m]

%% Simulation
simOut = sim('suspension_model', 'StopTime', num2str(S.Tend), ...
    'MaxStep', num2str(TEST.sim.MaxStep), 'RelTol', num2str(TEST.sim.RelTol));

sig  = @(name) squeeze(simOut.(name).Data);
tt   = simOut.toe_deg.Time;
rack = 1000*interp1(t, rack_in.Data, tt);               % [mm]
toe    =  sig('toe_deg');     toe    = toe - toe(1);    % [deg]
camber = -sig('camber_deg');  camber = camber - camber(1);   % vehicle convention
Fz = interp1(simOut.Fz_contact.Time, sig('Fz_contact'), tt); % [N]

%% Metrics (central half of the rack stroke)
idx = abs(rack) <= 0.5*max(abs(rack));
pt = polyfit(rack(idx), toe(idx), 1);
pc = polyfit(rack(idx), camber(idx), 1);

fprintf('\n=== Steering test (New QC) ===\n');
fprintf('Rack amplitude      : +/- %.1f mm, %.2f Hz\n', 1000*S.amp, S.freq);
fprintf('Toe per rack travel : %+.4f deg/mm  (%.2f mm of rack per degree of toe)\n', pt(1), 1/abs(pt(1)));
fprintf('Camber per rack     : %+.4f deg/mm\n', pc(1));
fprintf('Toe range           : %+.3f ... %+.3f deg\n\n', min(toe), max(toe));

%% Plots
fig = figure('Name','New QC - Steering Test','Color','w','Position',[100 100 1100 700]);
try, theme(fig,'light'); catch, end
ax = gobjects(4,1);

ax(1) = subplot(2,2,1);
yyaxis left;  plot(tt, rack, 'k--', 'LineWidth', 1.5); ylabel('Rack travel [mm]');
yyaxis right; plot(tt, toe, '-', 'LineWidth', 1.5);    ylabel('\Delta Toe [deg]');
xlabel('Time [s]'); title('Input vs. Response');

ax(2) = subplot(2,2,2);
plot(rack, toe, '-', 'Color', [0.95 0.50 0.00], 'LineWidth', 2);
xlabel('Rack travel [mm]'); ylabel('\Delta Toe [deg]');
title(sprintf('Toe vs Rack (%.4f deg/mm)', pt(1)));

ax(3) = subplot(2,2,3);
plot(rack, camber, '-', 'Color', [0.00 0.55 0.55], 'LineWidth', 2);
xlabel('Rack travel [mm]'); ylabel('\Delta Camber [deg]');
title(sprintf('Camber vs Rack (%.4f deg/mm)', pc(1)));

ax(4) = subplot(2,2,4);
plot(rack, Fz, '-', 'Color', [0.60 0.30 0.10], 'LineWidth', 2);
xlabel('Rack travel [mm]'); ylabel('Contact force F_z [N]');
title('Contact Force vs Rack');

sgtitle('QUARTER CAR (suspension\_model) - STEERING TEST', 'FontWeight','bold');
for i = 1:numel(ax)
    set(ax(i),'Color','w','XColor','k','GridColor',[0.15 0.15 0.15],'GridAlpha',0.25,'FontSize',10);
    grid(ax(i),'on'); ax(i).Title.Color = 'k';
end

%% Save
steering = table(tt, rack, toe, camber, Fz, ...
    'VariableNames', {'t_s','rack_mm','toe_deg','camber_deg','Fz_N'});
if ~isfolder(fullfile(qc_root,'results')), mkdir(fullfile(qc_root,'results')); end
save(fullfile(qc_root,'results','quartercar_steering.mat'),'steering');
exportgraphics(fig,fullfile(qc_root,'results','quartercar_steering.png'),'Resolution',200,'BackgroundColor','white');
disp('>>> Saved quartercar_steering.mat and quartercar_steering.png');
