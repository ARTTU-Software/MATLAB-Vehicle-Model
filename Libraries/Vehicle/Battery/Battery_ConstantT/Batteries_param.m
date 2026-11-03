%% Battery parameters

BatteryPack.Segment.BatteryCapacityCell = 18; % Battery capacity, A*hr
BatteryPack.Segment.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Segment.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Segment.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Segment.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Segment.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Segment.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Segment.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Segment.SimulationTemperatureCell = 298.15; % Simulation temperature, K

%% Battery initial targets

BatteryPack.Segment.socCell = repmat(1, 75, 1); % Cell state of charge
BatteryPack.Segment.batteryVoltage = repmat(0, 75, 1); % Terminal voltage, V
BatteryPack.Segment.batteryCurrent = repmat(0, 75, 1); % Current (positive in), A
BatteryPack.Segment.numCycles = repmat(0, 75, 1); % Discharge cycles
BatteryPack.Segment.vParallelAssembly = repmat(0, 15, 1); % Parallel Assembly Voltage, V
BatteryPack.Segment.socParallelAssembly = repmat(1, 15, 1); % Parallel Assembly state of charge

% Suppress MATLAB editor message regarding readability of repmat
%#ok<*REPMAT>
