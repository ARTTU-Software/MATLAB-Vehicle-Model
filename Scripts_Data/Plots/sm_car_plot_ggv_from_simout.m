function [fig_h, GGV_data] = sm_car_plot_ggv_from_simout(sim_results, varargin)
%sm_car_plot_ggv_from_simout Plot GGV mesh from sm_car simulation output
%   [fig_h, GGV_data] = sm_car_plot_ggv_from_simout(out) extracts body
%   accelerations and vehicle speed from the OutBus output, then calls
%   sm_car_plot_ggv_mesh_from_points.
%
%   The input can also be a logged dataset or the OutBus values.
%
%   [fig_h, GGV_data] = sm_car_plot_ggv_from_simout() uses the current
%   simulation output from the workspace.
%
%   Extra Name, Value pairs are passed to sm_car_plot_ggv_mesh_from_points.

% Copyright 2026 The MathWorks, Inc.

if nargin == 0
    sim_results = [];
elseif isNameValueStart(sim_results)
    varargin = [{sim_results} varargin];
    sim_results = [];
end

plotBus = sm_car_plot_data(sim_results);
vehBus = plotBus.VehBus;

[logsout_vxVeh, speed_x_signal] = getLoggedSignal( ...
    vehBus, {'Chassis.Body.CG.vx', 'World.vx'});
[logsout_vyVeh, speed_y_signal] = getLoggedSignal( ...
    vehBus, {'Chassis.Body.CG.vy', 'World.vy'});
[logsout_gxVeh, lng_acc_signal] = getLoggedSignal( ...
    vehBus, {'Chassis.Body.CG.gx'});
[logsout_gyVeh, lat_acc_signal] = getLoggedSignal( ...
    vehBus, {'Chassis.Body.CG.gy'});

sim_t = getSignalTime(logsout_vxVeh);
veh_vx = getSignalDataAtTime(logsout_vxVeh, sim_t);
veh_vy = getSignalDataAtTime(logsout_vyVeh, sim_t);
veh_spd_mps = hypot(veh_vx, veh_vy);

lng_acc = getSignalDataAtTime(logsout_gxVeh, sim_t);
lat_acc = getSignalDataAtTime(logsout_gyVeh, sim_t);

plot_args = addDefaultPlotOptions(varargin);
[fig_h, GGV_data] = sm_car_plot_ggv_mesh_from_points( ...
    lat_acc, lng_acc, veh_spd_mps, plot_args{:});

GGV_data.source.speed_x = speed_x_signal;
GGV_data.source.speed_y = speed_y_signal;
GGV_data.source.lat_acc = lat_acc_signal;
GGV_data.source.lng_acc = lng_acc_signal;
end

function tf = isNameValueStart(value)
tf = ischar(value) || (isstring(value) && isscalar(value));
end

function [signal, signal_path] = getLoggedSignal(values, candidate_paths)
for path_i = 1:numel(candidate_paths)
    this_path = candidate_paths{path_i};
    [found, this_signal] = tryGetNestedSignal(values, this_path);
    if found
        signal = this_signal;
        signal_path = this_path;
        return
    end
end

error('None of these logged signals were found: %s', ...
    strjoin(candidate_paths, ', '));
end

function [found, signal] = tryGetNestedSignal(values, signal_path)
signal = values;
path_parts = strsplit(signal_path, '.');
found = true;

for part_i = 1:numel(path_parts)
    try
        signal = signal.(path_parts{part_i});
    catch
        found = false;
        signal = [];
        return
    end
end
end

function signal_time = getSignalTime(signal)
try
    signal_time = signal.Time(:);
catch
    error('Logged signal does not include a Time vector.');
end
end

function signal_data = getSignalDataAtTime(signal, target_time)
signal_time = getSignalTime(signal);
signal_data = squeeze(signal.Data);
signal_data = signal_data(:);

if numel(signal_data) ~= numel(signal_time)
    error('Logged signal data length does not match its time vector.');
end

if isequal(signal_time, target_time)
    return
end

[signal_time_unique, unique_ind] = unique(signal_time);
signal_data_unique = signal_data(unique_ind);
if isscalar(signal_time_unique)
    signal_data = repmat(signal_data_unique, size(target_time));
else
    signal_data = interp1(signal_time_unique, signal_data_unique, ...
        target_time, 'linear', 'extrap');
end
end

function plot_args = addDefaultPlotOptions(plot_args)
if ~hasNameValue(plot_args, 'VehicleConfig')
    plot_args = [plot_args {'VehicleConfig', getVehicleConfig()}];
end

if ~hasNameValue(plot_args, 'FigureName')
    plot_args = [plot_args {'FigureName', 'h1_sm_car_ggv'}];
end
end

function tf = hasNameValue(args, name)
tf = false;
for arg_i = 1:2:numel(args)
    arg_name = args{arg_i};
    if isstring(arg_name)
        arg_name = char(arg_name);
    end
    if ischar(arg_name) && strcmpi(arg_name, name)
        tf = true;
        return
    end
end
end

function vehicle_config = getVehicleConfig()
if evalin('base', 'exist(''Vehicle'', ''var'') && isfield(Vehicle, ''config'')')
    vehicle_config = evalin('base', 'Vehicle.config');
else
    vehicle_config = 'custom';
end
end
