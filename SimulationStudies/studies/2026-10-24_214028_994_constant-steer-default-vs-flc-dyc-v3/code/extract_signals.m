function signals = extract_signals(logs)
%EXTRACT_SIGNALS Keep only three requested CG signals, in their native time grids.
cg = logs.get('VehBus').Values.Chassis.Body.CG;
signals.yawRate = readSignal(cg.nYaw, 'rad/s', 'deg/s', 180/pi);
signals.lateralAcceleration = readSignal(cg.gy, 'm/s^2', 'm/s^2', 1);
signals.sideslip = readSignal(cg.aSideSlip, 'rad', 'deg', 180/pi);
end

function signal = readSignal(value, expectedUnit, outputUnit, scale)
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
