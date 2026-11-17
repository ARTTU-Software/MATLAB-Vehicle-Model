function sm_car_plot11SteeringTorque(sim_results)
%SM_CAR_PLOT11STEERINGTORQUE Estimate steering torque from front tire loads.
% Copyright 2018-2024 The MathWorks, Inc.


if nargin == 0
    sim_results = [];
end
plotBus = sm_car_plot_data(sim_results);
vehBus = plotBus.VehBus;
Vehicle = evalin('base','Vehicle');
% Reuse figure if it exists, else create new figure
fig_handle_name =   'h11_sm_car';
Init_type = evalin('base','Init.Type');

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

chassis_log_fieldnames = fieldnames(vehBus.Chassis);
whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
whlnames = sort(chassis_log_fieldnames(whl_inds));

L = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sOutboard.Value;
U = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sOutboard.Value;
WC = Vehicle.Chassis.SuspA1.Linkage.Upright.sWheelCentre.Value;
steer_link = Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value;
direction = U - L;
lamda_g = -L(3) / (direction(3));
axis_g = L + lamda_g * direction;

mechanical_trail = axis_g(1) - WC(1);

pitman_arm = norm(steer_link - WC);

steering_trail = Vehicle.Chassis.SuspA1.Steer.Pinion.xRad.Value;

% Plot results
for whl_i = [1 3]

    logsout_Mz(:,whl_i) = vehBus.Chassis.(whlnames{whl_i}).Mz.Data;
    logsout_Fy(:,whl_i) = vehBus.Chassis.(whlnames{whl_i}).Fy.Data;

end
time = vehBus.Chassis.(whlnames{1}).Fy.Time;

Torque_steer = sum(logsout_Fy * mechanical_trail + logsout_Mz,2) / pitman_arm * steering_trail;
   
ah(1) = subplot(1,1,1);
plot(time, Torque_steer,'LineWidth', 1)
title('Steering Torque (Nm)');
    

set(ah,'Box','on')
for i = 1:length(ah)
    grid(ah(i),'on')
    hold off
end
linkaxes(ah,'x');
legend('Location','Best',FontSize=6);


maneuver_str = evalin('base','Maneuver.Type');

text(0,1.3,sprintf('%s, %s',...
    strrep(maneuver_str,'_','\_'),...
    get_param(bdroot,'Solver')),...
    'Color',[1 1 1]*0.5,'Units','Normalized')
