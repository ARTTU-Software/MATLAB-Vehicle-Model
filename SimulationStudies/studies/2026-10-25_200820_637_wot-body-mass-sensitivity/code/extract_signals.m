function signals = extract_signals(logs)
%extract_signals - Select the two requested CG signals
%   SIGNALS = extract_signals(LOGS) reads the logged VehBus from the
%   Simulink.SimulationData.Dataset LOGS. SIGNALS contains cgVelocity
%   (km/h) and longitudinalAcceleration (m/s^2). Each field
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
signals.cgVelocity = readSignal(cg.vx, 'm/s', 'km/h', 3.6);
signals.longitudinalAcceleration = readSignal(cg.gx, 'm/s^2', 'm/s^2', 1);
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
%   Example: internal CG-velocity conversion
%       signal = readSignal(cg.vx, 'm/s', 'km/h', 3.6);
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
