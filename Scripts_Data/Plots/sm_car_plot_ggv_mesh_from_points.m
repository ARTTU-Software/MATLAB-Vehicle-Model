function [fig_h, GGV_data] = sm_car_plot_ggv_mesh_from_points(lat_acc, lng_acc, veh_spd_mps, varargin)
%sm_car_plot_ggv_mesh_from_points Plot a GGV mesh from saved acceleration points
%   fig_h = sm_car_plot_ggv_mesh_from_points(lat_acc, lng_acc, veh_spd_mps)
%   builds and plots a GGV mesh using lateral acceleration, longitudinal
%   acceleration, and vehicle speed vectors. No model sweep or simulation is
%   run.
%
%   [fig_h, GGV_data] = sm_car_plot_ggv_mesh_from_points(..., Name, Value)
%   specifies optional plotting settings:
%
%       AccelerationUnits   'm/s^2' (default) or 'g'
%       SpeedUnits          'm/s' (default) or 'km/h'
%       VehicleConfig       Vehicle configuration string for the title
%       HoldFigure          true to retain existing data on the figure
%       ShowPoints          true to overlay source points
%       MeshAnglePoints     Number of angle samples around the GG plane
%       MeshSpeedPoints     Number of speed samples for interpolation
%       MeshSpeedVector     Explicit speed samples, or [] to create them
%       MeshMethod          'interpolant' (default) or 'envelope'
%       EnvelopePercentile  Percentile used for the outer envelope
%       SurfaceAlpha        Mesh surface transparency
%       PointColor          RGB triplet for source points
%       PointSize           Scatter marker size
%       FigureName          Name of the reusable figure
%
%   Example:
%       fig_h = sm_car_plot_ggv_mesh_from_points(ay, ax, vx, ...
%           'VehicleConfig', Vehicle.config);
%
%   If your acceleration data is in one matrix, pass the columns explicitly:
%       fig_h = sm_car_plot_ggv_mesh_from_points(accel(:,2), accel(:,1), speed);

% Copyright 2026 The MathWorks, Inc.

options = parseOptions(varargin{:});

lat_acc = lat_acc(:);
lng_acc = lng_acc(:);
veh_spd_mps = veh_spd_mps(:);

if ~isequal(numel(lat_acc), numel(lng_acc), numel(veh_spd_mps))
    error('lat_acc, lng_acc, and veh_spd_mps must have the same number of elements.');
end

valid_pts = isfinite(lat_acc) & isfinite(lng_acc) & isfinite(veh_spd_mps);
lat_acc = lat_acc(valid_pts);
lng_acc = lng_acc(valid_pts);
veh_spd_mps = veh_spd_mps(valid_pts);

if isempty(lat_acc)
    error('No finite GGV points were provided.');
end

switch lower(options.AccelerationUnits)
    case {'m/s^2', 'mps2'}
        lat_acc_g = lat_acc/9.81;
        lng_acc_g = lng_acc/9.81;
    case 'g'
        lat_acc_g = lat_acc;
        lng_acc_g = lng_acc;
    otherwise
        error('AccelerationUnits must be ''m/s^2'' or ''g''.');
end

switch lower(options.SpeedUnits)
    case {'m/s', 'mps'}
        veh_spd_plot_mps = veh_spd_mps;
    case {'km/h', 'kph'}
        veh_spd_plot_mps = veh_spd_mps/3.6;
    otherwise
        error('SpeedUnits must be ''m/s'' or ''km/h''.');
end

[lat_acc_mesh_g, lng_acc_mesh_g, veh_spd_mesh_mps] = buildGgvMesh( ...
    lat_acc_g, lng_acc_g, veh_spd_plot_mps, options);

GGV_data.lat_acc_pts_g = lat_acc_g;
GGV_data.lng_acc_pts_g = lng_acc_g;
GGV_data.veh_spd_pts_mps = veh_spd_plot_mps;
GGV_data.lat_acc_mesh_g = lat_acc_mesh_g;
GGV_data.lng_acc_mesh_g = lng_acc_mesh_g;
GGV_data.veh_spd_mesh_mps = veh_spd_mesh_mps;
GGV_data.vehicle_config = options.VehicleConfig;

fig_h = getFigure(options.FigureName);
figure(fig_h);
if ~options.HoldFigure
    clf(fig_h);
end

ax_h = get(fig_h, 'CurrentAxes');
if isempty(ax_h) || ~options.HoldFigure
    ax_h = axes('Parent', fig_h);
end
if options.HoldFigure
    hold(ax_h, 'on');
end

surf_h = surf(ax_h, lat_acc_mesh_g, lng_acc_mesh_g, veh_spd_mesh_mps, ...
    veh_spd_mesh_mps);
set(surf_h, ...
    'FaceAlpha', options.SurfaceAlpha, ...
    'EdgeColor', [0.45 0.45 0.45], ...
    'FaceColor', 'interp');
colorbar(ax_h);

if options.ShowPoints
    hold(ax_h, 'on');
    scatter3(ax_h, lat_acc_g, lng_acc_g, veh_spd_plot_mps, ...
        options.PointSize, options.PointColor, 'filled', ...
        'MarkerEdgeColor', [0.15 0.15 0.15]);
end

grid(ax_h, 'on');
box(ax_h, 'on');
xlabel(ax_h, 'Lateral Accel (g)');
ylabel(ax_h, 'Long. Accel (g)');
zlabel(ax_h, 'Speed m/s');

vehicle_name = getVehicleName(options.VehicleConfig);
title(ax_h, ['GGV Mesh (Vehicle: ' vehicle_name ')']);
view(ax_h, 100, 7);

maxxy = max([max(lat_acc_g)-min(lat_acc_g) max(lng_acc_g)-min(lng_acc_g)]);
if maxxy > 0
    maxz = max(veh_spd_plot_mps)-min(veh_spd_plot_mps);
    if maxz == 0
        maxz = 1;
    end
    set(ax_h, 'DataAspectRatio', [1 1 maxz/maxxy]);
end

if ~options.HoldFigure
    hold(ax_h, 'off');
end

end

function options = parseOptions(varargin)
options.AccelerationUnits = 'm/s^2';
options.SpeedUnits = 'm/s';
options.VehicleConfig = 'custom';
options.HoldFigure = false;
options.ShowPoints = true;
options.MeshAnglePoints = 72;
options.MeshSpeedPoints = 20;
options.MeshSpeedVector = [];
options.MeshMethod = 'interpolant';
options.EnvelopePercentile = 95;
options.EnvelopeAngleWindow = [];
options.EnvelopeSpeedWindow = [];
options.MinEnvelopePoints = 4;
options.SmoothAnglePoints = 7;
options.SmoothSpeedPoints = 3;
options.SurfaceAlpha = 0.55;
options.InterpolationMethod = 'natural';
options.ExtrapolationMethod = 'nearest';
options.PointColor = [0.15 0.15 0.15];
options.PointSize = 18;
options.FigureName = 'h1_sm_car_ggv_mesh_from_points';

if mod(numel(varargin), 2) ~= 0
    error('Optional inputs must be specified as Name, Value pairs.');
end

valid_names = fieldnames(options);
for opt_i = 1:2:numel(varargin)
    name = varargin{opt_i};
    value = varargin{opt_i+1};
    if isstring(name)
        name = char(name);
    end
    match = strcmpi(name, valid_names);
    if ~any(match)
        error('Unknown option ''%s''.', name);
    end
    options.(valid_names{match}) = value;
end
end

function [lat_acc_mesh_g, lng_acc_mesh_g, veh_spd_mesh_mps] = buildGgvMesh( ...
    lat_acc_g, lng_acc_g, veh_spd_mps, options)
theta = atan2(lng_acc_g, lat_acc_g);
radius = hypot(lat_acc_g, lng_acc_g);

if nnz(radius > 0) < 3
    error('At least three nonzero acceleration points are required to build a GGV mesh.');
end

theta_vec_open = linspace(-pi, pi, options.MeshAnglePoints + 1);
theta_vec = theta_vec_open(1:end-1);
speed_vec = getMeshSpeedVector(veh_spd_mps, options);

switch lower(options.MeshMethod)
    case 'envelope'
        radius_mesh = buildEnvelopeRadiusMesh( ...
            theta, radius, veh_spd_mps, theta_vec, speed_vec, options);
    case {'interpolant', 'scattered'}
        radius_mesh = buildInterpolatedRadiusMesh( ...
            theta, radius, veh_spd_mps, theta_vec, speed_vec, options);
    otherwise
        error('MeshMethod must be ''envelope'' or ''interpolant''.');
end

radius_mesh = max(radius_mesh, 0);
radius_mesh = [radius_mesh radius_mesh(:, 1)];
theta_vec_closed = [theta_vec theta_vec(1) + 2*pi];
[theta_mesh, veh_spd_mesh_mps] = meshgrid(theta_vec_closed, speed_vec);
lat_acc_mesh_g = radius_mesh.*cos(theta_mesh);
lng_acc_mesh_g = radius_mesh.*sin(theta_mesh);
end

function radius_mesh = buildEnvelopeRadiusMesh( ...
    theta, radius, veh_spd_mps, theta_vec, speed_vec, options)
radius_mesh = NaN(numel(speed_vec), numel(theta_vec));
angle_half_width = getEnvelopeAngleHalfWidth(theta_vec, options);
speed_half_width = getEnvelopeSpeedHalfWidth(speed_vec, veh_spd_mps, options);
min_speed_band_pts = max(options.MeshAnglePoints, options.MinEnvelopePoints*6);

for speed_i = 1:numel(speed_vec)
    speed_mask = abs(veh_spd_mps - speed_vec(speed_i)) <= speed_half_width;
    if nnz(speed_mask) < min_speed_band_pts
        [~, speed_sort_ind] = sort(abs(veh_spd_mps - speed_vec(speed_i)));
        speed_mask = false(size(veh_spd_mps));
        speed_mask(speed_sort_ind(1:min(min_speed_band_pts, numel(speed_sort_ind)))) = true;
    end

    theta_band = theta(speed_mask);
    radius_band = radius(speed_mask);
    for theta_i = 1:numel(theta_vec)
        angle_mask = angularDistance(theta_band, theta_vec(theta_i)) <= ...
            angle_half_width;
        if nnz(angle_mask) >= options.MinEnvelopePoints
            radius_mesh(speed_i, theta_i) = percentileValue( ...
                radius_band(angle_mask), options.EnvelopePercentile);
        end
    end
    radius_mesh(speed_i, :) = fillCircularRow(radius_mesh(speed_i, :));
end

radius_mesh = fillSpeedGaps(radius_mesh, speed_vec);
radius_mesh = smoothCircularRows(radius_mesh, options.SmoothAnglePoints);
radius_mesh = smoothSpeedColumns(radius_mesh, options.SmoothSpeedPoints);
end

function radius_mesh = buildInterpolatedRadiusMesh( ...
    theta, radius, veh_spd_mps, theta_vec, speed_vec, options)
theta_ext = [theta - 2*pi; theta; theta + 2*pi];
speed_ext = repmat(veh_spd_mps, 3, 1);
radius_ext = repmat(radius, 3, 1);
[theta_mesh, veh_spd_mesh_mps] = meshgrid(theta_vec, speed_vec);

if numel(unique(veh_spd_mps)) < 2
    [theta_sort, sort_ind] = sort(theta_ext);
    radius_sort = radius_ext(sort_ind);
    [theta_unique, unique_ind] = unique(theta_sort);
    radius_unique = radius_sort(unique_ind);
    radius_mesh = interp1(theta_unique, radius_unique, theta_vec, ...
        'linear', 'extrap');
    radius_mesh = repmat(radius_mesh, numel(speed_vec), 1);
else
    radius_interp = scatteredInterpolant(speed_ext, theta_ext, radius_ext, ...
        options.InterpolationMethod, options.ExtrapolationMethod);
    radius_mesh = radius_interp(veh_spd_mesh_mps, theta_mesh);
end
end

function angle_half_width = getEnvelopeAngleHalfWidth(theta_vec, options)
if ~isempty(options.EnvelopeAngleWindow)
    angle_half_width = options.EnvelopeAngleWindow/2;
    return
end

angle_step = 2*pi/numel(theta_vec);
angle_half_width = angle_step*2;
end

function speed_half_width = getEnvelopeSpeedHalfWidth(speed_vec, veh_spd_mps, options)
if ~isempty(options.EnvelopeSpeedWindow)
    speed_half_width = options.EnvelopeSpeedWindow/2;
    return
end

if numel(speed_vec) > 1
    speed_half_width = median(diff(speed_vec))*1.5;
else
    speed_half_width = max(1, range(veh_spd_mps));
end
end

function angle_dist = angularDistance(angle_a, angle_b)
angle_dist = abs(atan2(sin(angle_a - angle_b), cos(angle_a - angle_b)));
end

function p_value = percentileValue(values, percentile)
values = sort(values(:));
percentile = min(max(percentile, 0), 100);
if isempty(values)
    p_value = NaN;
    return
end
if isscalar(values)
    p_value = values;
    return
end

interp_ind = 1 + (numel(values)-1)*percentile/100;
low_ind = floor(interp_ind);
high_ind = ceil(interp_ind);
if low_ind == high_ind
    p_value = values(low_ind);
else
    p_value = values(low_ind) + (values(high_ind)-values(low_ind))* ...
        (interp_ind-low_ind);
end
end

function row_data = fillCircularRow(row_data)
finite_ind = find(isfinite(row_data));
if isempty(finite_ind)
    row_data(:) = 0;
    return
end
if isscalar(finite_ind)
    row_data(:) = row_data(finite_ind);
    return
end

n_pts = numel(row_data);
theta_ind = 1:n_pts;
theta_ext = [finite_ind-n_pts finite_ind finite_ind+n_pts];
radius_ext = row_data([finite_ind finite_ind finite_ind]);
row_data = interp1(theta_ext, radius_ext, theta_ind, 'pchip');
end

function radius_mesh = fillSpeedGaps(radius_mesh, speed_vec)
for theta_i = 1:size(radius_mesh, 2)
    col_data = radius_mesh(:, theta_i);
    finite_mask = isfinite(col_data);
    if all(finite_mask)
        continue
    elseif nnz(finite_mask) >= 2
        col_data(~finite_mask) = interp1(speed_vec(finite_mask), ...
            col_data(finite_mask), speed_vec(~finite_mask), ...
            'pchip', 'extrap');
    elseif nnz(finite_mask) == 1
        col_data(:) = col_data(finite_mask);
    else
        col_data(:) = 0;
    end
    radius_mesh(:, theta_i) = col_data;
end
end

function radius_mesh = smoothCircularRows(radius_mesh, window_pts)
window_pts = max(1, round(window_pts));
if window_pts <= 1
    return
end
if mod(window_pts, 2) == 0
    window_pts = window_pts + 1;
end

pad_pts = floor(window_pts/2);
kernel = ones(1, window_pts)/window_pts;
for speed_i = 1:size(radius_mesh, 1)
    row_ext = [radius_mesh(speed_i, end-pad_pts+1:end) ...
        radius_mesh(speed_i, :) radius_mesh(speed_i, 1:pad_pts)];
    row_smooth = conv(row_ext, kernel, 'same');
    radius_mesh(speed_i, :) = row_smooth(pad_pts+1:end-pad_pts);
end
end

function radius_mesh = smoothSpeedColumns(radius_mesh, window_pts)
window_pts = max(1, round(window_pts));
if window_pts <= 1 || size(radius_mesh, 1) < 2
    return
end

radius_mesh = movmean(radius_mesh, window_pts, 1, 'Endpoints', 'shrink');
end

function speed_vec = getMeshSpeedVector(veh_spd_mps, options)
if ~isempty(options.MeshSpeedVector)
    speed_vec = sort(options.MeshSpeedVector(:));
    return
end

unique_speed = unique(veh_spd_mps);
if numel(unique_speed) <= options.MeshSpeedPoints
    speed_vec = unique_speed;
else
    speed_vec = linspace(min(veh_spd_mps), max(veh_spd_mps), ...
        options.MeshSpeedPoints).';
end

if isscalar(speed_vec)
    speed_vec = [speed_vec; speed_vec + eps(max(1, abs(speed_vec)))];
end
end

function fig_h = getFigure(fig_name)
fig_name = char(fig_name);
figures = findobj(groot,'Type','figure','Name',fig_name);
if isempty(figures)
    fig_h = figure('Name', fig_name);
else
    fig_h = figures(1);
end
if isvarname(fig_name)
    assignin('base', fig_name, fig_h);
end
end

function vehicle_name = getVehicleName(vehicle_config)
if isstring(vehicle_config)
    vehicle_config = char(vehicle_config);
end
vehicle_strs = strsplit(vehicle_config, '_');
vehicle_name_cfg = vehicle_strs{1};

switch vehicle_name_cfg
    case 'Hamba'
        vehicle_name = 'Sedan';
    case 'Achilles'
        vehicle_name = 'FSAE';
    otherwise
        vehicle_name = vehicle_name_cfg;
end
end
