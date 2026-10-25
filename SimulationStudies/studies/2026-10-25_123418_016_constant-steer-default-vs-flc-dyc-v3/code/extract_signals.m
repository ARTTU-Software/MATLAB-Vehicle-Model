function signals = extract_signals(logs)
%extract_signals - Select the three requested vehicle signals
%   SIGNALS = extract_signals(LOGS) reads the logged VehBus from the
%   Simulink.SimulationData.Dataset LOGS. SIGNALS contains yawRate
%   (deg/s), lateralAcceleration (m/s^2) and sideslip (deg). Each field
%   has its own time_s, value, unit and sourceUnit.
%
%   Units, scalar sample counts, finite values and native timestamp
%   order are checked. No model is accessed and no files are written.
%
%   Example: use a Dataset already loaded from the shared archive
%       signals = extract_signals(preview.logsout_sm_car);
%
%   See also simulate_run, plot_results

cg = logs.get('VehBus').Values.Chassis.Body.CG;
signals.yawRate = readSignal(cg.nYaw, 'rad/s', 'deg/s', 180/pi);
signals.lateralAcceleration = readSignal(cg.gy, 'm/s^2', 'm/s^2', 1);
signals.sideslip = readSignal(cg.aSideSlip, 'rad', 'deg', 180/pi);
end

function signal = readSignal(value, expectedUnit, outputUnit, scale)
%readSignal - Validate and convert one logged scalar timeseries
%   SIGNAL = readSignal(VALUE, expectedUnit, outputUnit, SCALE) checks
%   the timeseries VALUE and converts its samples by numeric SCALE.
%   expectedUnit and outputUnit are unit-name text values. SIGNAL holds
%   native time_s, converted value, unit and sourceUnit. At least two
%   finite scalar samples in nondecreasing time order are required.
%   This helper is local to extract_signals and writes no files.
%
%   Example: internal yaw-rate conversion
%       signal = readSignal(cg.nYaw, 'rad/s', 'deg/s', 180/pi);
%
%   See also extract_signals, timeseries

assert(isa(value,'timeseries'), 'Study:Type', 'Expected a scalar timeseries.');
unit = value.DataInfo.Units;
if isa(unit,'Simulink.SimulationData.Unit'), unit = unit.Name; end
assert(strcmp(strtrim(char(unit)),expectedUnit), 'Study:Units', ...
    'Expected %s; found %s.', expectedUnit, string(unit));
assert(any(strcmpi(char(value.TimeInfo.Units), {'seconds','second','sec','s'})), ...
    'Study:TimeUnits', 'Expected seconds.');
signal.time_s = double(value.Time(:));
signal.value = double(value.Data(:))*scale;
signal.unit = outputUnit;
signal.sourceUnit = expectedUnit;
assert(numel(signal.time_s)>=2 && numel(signal.time_s)==numel(signal.value), ...
    'Study:Shape', 'Expected at least two scalar samples.');
assert(all(isfinite(signal.time_s)) && all(isfinite(signal.value)) && ...
    all(diff(signal.time_s)>=0), 'Study:Samples', 'Nonfinite or unordered samples.');
end
