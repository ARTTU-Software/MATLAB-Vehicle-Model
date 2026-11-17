%% plot_quartercar.m  -  runs YOUR quarter car and makes the same 6 plots as the big model
% Run from your QUARTER folder, after upgrade_quartercar.m has been run once.
% Camber is in the vehicle convention: negative = top of the wheel tilted inboard.

init_car;                                   % parameters (note: init_car calls clear)

%% Inputs
qc_test_settings;                           % test settings -> edit qc_test_settings.m
amp  = TEST.bump.amp;                       % [m]  +/- amplitude at the contact patch
freq = TEST.bump.freq;                      % [Hz]
Tend = TEST.bump.Tend;                      % [s]
t = (0:TEST.sim.dt:Tend)';
z_road_in = timeseries(amp*sin(2*pi*freq*t), t);   % contact patch height [m]
rack_in   = timeseries(zeros(size(t)), t);         % rack displacement [m] (0 = straight)

%% Simulation
simOut = sim('suspension_model', 'StopTime', num2str(Tend), 'MaxStep', num2str(TEST.sim.MaxStep), 'RelTol', num2str(TEST.sim.RelTol));

sig = @(name) squeeze(simOut.(name).Data);
tt      = simOut.wheel_travel.Time;
zIn     = 1000*interp1(t, z_road_in.Data, tt);       % contact patch input [mm]
travel  = zIn;                                       % wheel travel [mm] (= wheel centre within ~0.05 mm)
upright = sig('wheel_travel');  upright = upright - upright(1);
camber  = -sig('camber_deg');                        % vehicle convention
toe     =  sig('toe_deg');
camber  = camber - camber(1);
toe     = toe - toe(1);

% shock length -> motion ratio and spring force
xyz  = squeeze(simOut.shock_xyz.Data);
if size(xyz,1) == 3 && size(xyz,2) ~= 3, xyz = xyz.'; end
Lsh  = sqrt(sum(xyz.^2, 2));                          % shock length [m]
Lsh  = interp1(simOut.shock_xyz.Time, Lsh, tt);
dSpring = 1000*(Lsh - Lsh(1));                        % [mm]
FSpring = Spring.spring_rate.value*(Spring.free_length.value - Lsh);   % + = compression [N]

% vertical force at the contact patch (sign: + = pushing the wheel up)
Fz = interp1(simOut.Fz_contact.Time, sig('Fz_contact'), tt);

%% Metrics around static (+/-10 mm)
idx = abs(travel) <= 10;
pc = polyfit(travel(idx), camber(idx), 1);
pt = polyfit(travel(idx), toe(idx), 1);
pm = polyfit(travel(idx), dSpring(idx), 1);
pw = polyfit(travel(idx)/1000, Fz(idx), 1);
if pw(1) < 0, Fz = -Fz; pw = -pw; end                 % normalise sign: + = pushing wheel up

fprintf('\n=== Your quarter car ===\n');
fprintf('Camber gain : %+.4f deg/mm  (%+.3f deg per 25 mm)\n', pc(1), 25*pc(1));
fprintf('Bump steer  : %+.4f deg/mm  (%+.3f deg per 25 mm)\n', pt(1), 25*pt(1));
fprintf('Motion ratio (spring/wheel): %.3f\n', abs(pm(1)));
fprintf('Wheel rate  : %.0f N/m  (spring rate x MR^2 = %.0f N/m)\n', pw(1), Spring.spring_rate.value*pm(1)^2);
fprintf('Spring force at static: %.0f N\n\n', FSpring(1));

%% Plots (same layout as the big model)
fig = figure('Name','Your Quarter-Car Validation','Color','w','Position',[80 80 1200 750]);
try, theme(fig,'light'); catch, end
ax = gobjects(6,1);

% colours different from the big model's plots (blue/red/magenta/black/green)
cTeal   = [0.00 0.55 0.55];
cOrange = [0.95 0.50 0.00];
cPurple = [0.45 0.20 0.70];
cBrown  = [0.60 0.30 0.10];
cOlive  = [0.45 0.60 0.00];

ax(1) = subplot(2,3,1);
plot(tt, zIn, 'k--', 'LineWidth', 1.5); hold on
plot(tt, upright, '-', 'Color', cTeal, 'LineWidth', 1.5); hold off
xlabel('Time [s]'); ylabel('Displacement [mm]');
lg = legend('Input (contact patch)','Upright travel','Location','best');
title('Input vs. Response');

ax(2) = subplot(2,3,2);
plot(travel, camber, '-', 'Color', cTeal, 'LineWidth', 2);
xlabel('Wheel travel [mm] (Bump +, Rebound -)'); ylabel('\Delta Camber [deg]');
title(sprintf('Camber Gain (%.4f deg/mm)', pc(1)));

ax(3) = subplot(2,3,3);
plot(travel, toe, '-', 'Color', cOrange, 'LineWidth', 2);
xlabel('Wheel travel [mm] (Bump +, Rebound -)'); ylabel('\Delta Toe [deg]');
title(sprintf('Bump Steer (%.4f deg/mm)', pt(1)));

ax(4) = subplot(2,3,4);
plot(travel, dSpring, '-', 'Color', cPurple, 'LineWidth', 2);
xlabel('Wheel travel [mm]'); ylabel('\Delta Spring length [mm]');
title(sprintf('Motion Ratio (%.3f)', abs(pm(1))));

ax(5) = subplot(2,3,5);
plot(travel, Fz, '-', 'Color', cBrown, 'LineWidth', 2);
xlabel('Wheel travel [mm]'); ylabel('Contact force F_z [N]');
title(sprintf('Wheel Rate (%.0f N/m)', pw(1)));

ax(6) = subplot(2,3,6);
plot(travel, FSpring, '-', 'Color', cOlive, 'LineWidth', 2);
xlabel('Wheel travel [mm]'); ylabel('Spring force [N] (+ = compression)');
title('Spring Force (computed)');

sgtitle('QUARTER CAR (suspension\_model)', 'FontWeight','bold', 'Color', cTeal);

for i = 1:numel(ax)
    set(ax(i),'Color','w','XColor','k','YColor','k','GridColor',[0.15 0.15 0.15],'GridAlpha',0.25,'FontSize',10);
    grid(ax(i),'on'); ax(i).Title.Color = 'k';
end
set(lg,'TextColor','k','Color','w','EdgeColor',[0.6 0.6 0.6]);

%% Save (same columns as the big model)
results = table(tt, zIn, travel, camber, toe, dSpring, Fz, FSpring, ...
    'VariableNames', {'t_s','z_input_mm','travel_mm','camber_deg','toe_deg', ...
                      'dSpring_mm','Fpost_N','FSpring_N'});
if ~isfolder(fullfile(qc_root,'results')), mkdir(fullfile(qc_root,'results')); end
save(fullfile(qc_root,'results','quartercar_kinematics.mat'),'results');
exportgraphics(fig,fullfile(qc_root,'results','quartercar_kinematics.png'),'Resolution',200,'BackgroundColor','white');
disp('>>> Saved quartercar_kinematics.mat and quartercar_kinematics.png');