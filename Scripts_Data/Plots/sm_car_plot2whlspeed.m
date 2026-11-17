% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%
% Copyright 2018-2024 The MathWorks, Inc.

plotBus = sm_car_plot_data();

% Reuse figure if it exists, else create new figure
if ~exist('h2_sm_car', 'var') || ...
        ~isgraphics(h2_sm_car, 'figure')
    h2_sm_car = figure('Name', 'sm_car');
end
figure(h2_sm_car)
clf(h2_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
vehBus = plotBus.VehBus;

logsout_vxVeh = vehBus.World.vx;
logsout_vyVeh = vehBus.World.vy;
logsout_sVeh = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2);
logsout_xCar = vehBus.World.x;
logsout_yCar = vehBus.World.y;

logsout_px0 = logsout_xCar.Data(1);
logsout_py0 = logsout_yCar.Data(1);


% Find wheels
tire_radius = sm_car_vehcfg_getTireRadius(Vehicle);

chassis_log_fieldnames = fieldnames(vehBus.Chassis);
whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
whlnames = sort(chassis_log_fieldnames(whl_inds));

% Plot results
plot(logsout_vxVeh.Time, logsout_sVeh*3.6, 'k--', 'LineWidth', 1,'DisplayName','Vehicle')
hold on

for whl_i = 1:length(whl_inds)
    logsout_nWhl = vehBus.Chassis.(whlnames{whl_i}).n;
    radius_ind = 1;
    if ~isscalar(tire_radius)
        radius_ind = str2double(whlnames{whl_i}(end));
    end
    plot(logsout_nWhl.Time, logsout_nWhl.Data*3.6*tire_radius(radius_ind),'LineWidth', 1,'DisplayName',whlnames{whl_i})
end
hold off
grid on
title('Wheel Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')
legend('Location','Best');

if(isMATLABReleaseOlderThan("R2023b"))
    f=Simulink.FindOptions('FollowLinks',1,'LookUnderMasks','all','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
else
    f=Simulink.FindOptions('FollowLinks',1,'LookUnderMasks','all','MatchFilter',@Simulink.match.legacy.filterOutInactiveVariantSubsystemChoices);
end
temp_tire_h=Simulink.findBlocks(bdroot,'Name','Tire R1',f);
if(length(temp_tire_h)==1)
    temp_tire_sys = {getfullname(temp_tire_h)};
else
    temp_tire_sys = getfullname(temp_tire_h);
end
temp_tire_sys_vehi = find(contains(temp_tire_sys,'/Vehicle/Chassis/'));
tire_variant_name = char(get_param(temp_tire_sys(temp_tire_sys_vehi),'ActiveVariant'));
text(0.1,0.8,sprintf('Tire %s\nSteps: %d',tire_variant_name,length(logsout_vxVeh.Time)),'Units','Normalized','Color',[1 1 1]*0.5);
text(0.1,0.65,sprintf('xFinal: %0.2f m\nyFinal: %0.2f m',...
    logsout_xCar.Data(end)-logsout_px0,logsout_yCar.Data(end)-logsout_py0),'Units','Normalized','Color',[1 1 1]*0.5);

if(isfield(Vehicle,'config'))
    config_string = Vehicle.config;
else
    config_string = 'custom';
end

text(0.05,0.1,sprintf('%s\n%s',strrep(config_string,'_','\_'),get_param(bdroot,'Solver')),...
    'Color',[1 1 1]*0.5,'Units','Normalized')

clear tire_variant_name temp_tire_sys

clear plotBus vehBus logsout_vxVeh logsout_vyVeh logsout_sVeh logsout_nWhl
clear logsout_xCar logsout_yCar logsout_px0 logsout_py0

clear temp_colororder
