function sm_car_plot10_tire_force_torque(vehicleType,sim_results)
%sm_car_plot10_tire_force_torque  Plot tire forces and torques for all wheels
%  sm_car_plot10_tire_force_torque(vehicleType,sim_results)
%  You may specify 'vehicle' or 'trailer' to select which data is plotted
% 
% Copyright 2018-2024 The MathWorks, Inc.

if nargin < 2
    sim_results = [];
end
plotBus = sm_car_plot_data(sim_results);
if nargin < 1 || isempty(vehicleType) || strcmpi(vehicleType,'vehicle')
    busName = 'VehBus';
elseif strcmpi(vehicleType,'trailer')
    busName = 'TrlBus';
else
    error('sm_car:InvalidVehicleType','Specify vehicle or trailer.');
end
if ~isfield(plotBus,busName) || ~isstruct(plotBus.(busName)) || ...
        ~isfield(plotBus.(busName),'Chassis')
    warning('sm_car:MissingTireForces','This run does not contain tire forces for %s.',vehicleType);
    return
end

% Reuse figure if it exists, else create new figure
fig_handle_name =   'h10_sm_car';
Init_type = evalin('base','Init.Type');

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

% Get simulation results
vehBus = plotBus.(busName);

chassis_log_fieldnames = fieldnames(vehBus.Chassis);
whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
whlnames = sort(chassis_log_fieldnames(whl_inds));

% Plot results
for whl_i = 1:length(whl_inds)
    line_style = '-';
    if(whl_i>(length(whl_inds)/2))
        line_style = '--';
    end
    
    ah(1) = subplot(3,2,1);
    logsout_Fx = vehBus.Chassis.(whlnames{whl_i}).Fx;
    hold on
    plot(logsout_Fx.Time, squeeze(logsout_Fx.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i})
    title('Fx (N)');
    
    ah(2) = subplot(3,2,3);
    logsout_Fy = vehBus.Chassis.(whlnames{whl_i}).Fy;
    hold on
    plot(logsout_Fy.Time, squeeze(logsout_Fy.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i})
    title('Fy (N)');
    
    ah(3) = subplot(3,2,5);
    logsout_Fz = vehBus.Chassis.(whlnames{whl_i}).Fz;
    hold on
    % Squeeze needed for MFeval tire
    plot(logsout_Fz.Time, squeeze(logsout_Fz.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i});
    title('Fz (N)');
    xlabel('Time (s)')
    
    ah(4) = subplot(3,2,2);
    logsout_Mx = vehBus.Chassis.(whlnames{whl_i}).Mx;
    hold on
    plot(logsout_Mx.Time, squeeze(logsout_Mx.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i})
    title('Mx (N*m)');
    
    ah(5) = subplot(3,2,4);
    logsout_My = vehBus.Chassis.(whlnames{whl_i}).My;
    hold on
    plot(logsout_My.Time, squeeze(logsout_My.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i})
    title('My (N*m)');
    
    ah(6) = subplot(3,2,6);
    logsout_Mz = vehBus.Chassis.(whlnames{whl_i}).Mz;
    hold on
    plot(logsout_Mz.Time, squeeze(logsout_Mz.Data),'LineWidth', 1,'LineStyle',line_style,'DisplayName',whlnames{whl_i})
    title('Mz (N*m)');
    xlabel('Time (s)')
    
end


set(ah,'Box','on')
for i = 1:length(ah)
    grid(ah(i),'on')
    hold off
end
linkaxes(ah,'x');
legend('Location','Best',FontSize=6);

% Annotate figure (associated with subplot 1)
subplot(3,2,1)
config_str = evalin('base','Vehicle.config');
if(isempty(config_str))
    config_str = 'custom';
end

maneuver_str = evalin('base','Maneuver.Type');
if(isempty(maneuver_str))
    maneuver_str = '';
end

text(0,1.3,sprintf('%s, %s, %s',...
    strrep(config_str,'_','\_'),...
    strrep(maneuver_str,'_','\_'),...
    get_param(bdroot,'Solver')),...
    'Color',[1 1 1]*0.5,'Units','Normalized')
