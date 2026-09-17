function traj_coeff = CRG_Create_Balkans_End
% CRG_Create_Custom    Create CRG file from centerline data
%
% If no outputs are requested, creates CRG and geometry files
%   Creates CRG file for track with and without elevation.
%   Creates STL files based on data in CRG file.
%
% If output is requested, provides default trajectory coefficients
%
% Copyright 2020-2024 The MathWorks, Inc.
% Coefficient-only calls must not rewrite the imported centerline.
if nargout == 0
file_data = readtable("CRG_Balkans_End_centerline.xlsx");
if width(file_data)<5
    dist_m(1,1) = 0;
    for i=2:height(file_data)
        dist_m(i,1) = dist_m(i-1,1) + norm([file_data{i,1},file_data{i,2},0] - [file_data{i-1,1},file_data{i-1,2},0]);
    end
    %file_data{:,1} = -file_data{:,1};
    dist=table(dist_m,dist_m/1000,'VariableNames',{'Distance_m','Distance_km'});
    writetable([file_data,dist],'CRG_Balkans_end_centerline.xlsx','WriteMode','overwrite','WriteVariableNames',true);
    clear dist dist_m
end
clear file_data;
end
if(nargout == 0)
    road_opts.create_stl_files = true;
    road_opts.create_no_elevation = true;
    road_opts.create_stl_files_f = true;
    road_opts.decim_data = 1;  % Was 2
    road_opts.decim_alti = 32;
    road_opts.road_width = 1.89;      % Half width of the road
    road_opts.blending_distance = 10;
    road_opts.xa = 0;
    road_opts.xb = 0;
    road_opts.ya = 0.0;
    road_opts.yb = 0;
    road_opts.za = 0.0;
    road_opts.zb = 0;
    road_opts.reverse = 1;
    road_opts.datasrc = 'xyz';  % xyz or gps
    sm_car_centerline_to_crg('CRG_Balkans_end',road_opts)
end

%% Create driver trajectory
traj_coeff.speed_method = 'ggv'; % 'legacy' restores the coefficient-based method
traj_coeff.ggv_file = 'GGV_Achilles_20260906_0012.mat'; % MAT file containing GGV_data
traj_coeff.ggv_utilization = 0.95; % Fraction of the combined acceleration envelope, (0,1]
% A value of 1 leaves no grip reserve and may make the driver unreliable.
% GGV mode uses no powertrain limit and caps speed at the GGV coverage limit.
% diff_*, curv_smooth, lim_smooth, target_shape_smooth and vmin are legacy-only.
traj_coeff.blend_distance = 10;     % m
traj_coeff.diff_exp       = 1.25;   % Curvature exponent
traj_coeff.diff_smooth    = 8;     % Diff smoothing number of points
traj_coeff.curv_smooth    = 10;    % Curvature smoothing number of points
traj_coeff.lim_smooth     = 40;    % Limit smoothing number of points
traj_coeff.target_shape_smooth = 4;  % Number of points for smoothing
traj_coeff.vmax           = 21;   % Max speed, m/s
traj_coeff.vmin           = 3;    % Min speed, m/s
traj_coeff.decimation     = 1;      % Decimation for interpolation

if(nargout == 0)
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Balkans_end',traj_coeff)
    
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Balkans_end_f',traj_coeff)
end
