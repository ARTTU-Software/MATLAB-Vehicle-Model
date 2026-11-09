function sm_car_plot_ggv_speed_profile(trajectory,report,GGV_data)
%SM_CAR_PLOT_GGV_SPEED_PROFILE Inspect speed, curvature and combined demand.
figure('Name','CRG GGV speed profile');
tiledlayout(3,1);
nexttile;
plot(report.distance_m,report.curvature_1pm);
ylabel('Curvature (1/m)'); grid on;
title(sprintf('Grip-limited lap: %.2f s; GGV utilization: %.2f',...
    report.lap_time_s,report.utilization));
nexttile;
plot(report.distance_m,report.corner_speed_mps,'--',...
    trajectory.xTrajectory.Value,trajectory.vx.Value,'LineWidth',1.2);
ylabel('Speed (m/s)'); grid on;
legend('Corner/coverage ceiling','Acceleration/braking limited','Location','best');
nexttile;
plot(report.distance_m,report.segment_utilization_bound,'LineWidth',1.2);
yline(report.utilization,'--');
xlabel('Distance (m)'); ylabel('GGV utilization bound'); grid on;

figure('Name','CRG demand on selected GGV');
hold on;
speeds=unique(GGV_data.veh_spd_pts_mps);
for i=1:numel(speeds)
    mask=GGV_data.veh_spd_pts_mps==speeds(i);
    ax=GGV_data.lng_acc_pts_g(mask); ay=GGV_data.lat_acc_pts_g(mask);
    [~,order]=sort(atan2(ay,ax)); order=[order(:);order(1)];
    plot3(ay(order),ax(order),speeds(i)*ones(size(order)),...
        'Color',[0.6 0.6 0.6],'HandleVisibility','off');
    plot3(report.utilization*ay(order),report.utilization*ax(order),...
        speeds(i)*ones(size(order)),'--','Color',[0.2 0.4 0.7],...
        'HandleVisibility','off');
end
scatter3(report.demand_ay_mps2/9.81,report.demand_ax_mps2/9.81,...
    report.demand_speed_mps,8,report.demand_speed_mps,'filled');
xlabel('Lateral acceleration (g)'); ylabel('Longitudinal demand (g)');
zlabel('Speed (m/s)'); grid on; view(40,25); colorbar;
title('Reference demand; gray: measured GGV; dashed: utilization-scaled slices');
hold off;
end
