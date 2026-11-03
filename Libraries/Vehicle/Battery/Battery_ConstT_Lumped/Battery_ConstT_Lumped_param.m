%% Battery parameters

%% BatteryPack.Module2
BatteryPack.Module2.BatteryCapacityCell = 27; % Battery capacity, A*hr
BatteryPack.Module2.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Module2.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Module2.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Module2.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Module2.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Module2.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Module2.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Module2.SimulationTemperatureCell = 298.15; % Simulation temperature, K

%% BatteryPack.Module3
BatteryPack.Module3.BatteryCapacityCell = 27; % Battery capacity, A*hr
BatteryPack.Module3.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Module3.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Module3.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Module3.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Module3.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Module3.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Module3.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Module3.SimulationTemperatureCell = 298.15; % Simulation temperature, K

%% BatteryPack.Module4
BatteryPack.Module4.BatteryCapacityCell = 27; % Battery capacity, A*hr
BatteryPack.Module4.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Module4.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Module4.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Module4.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Module4.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Module4.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Module4.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Module4.SimulationTemperatureCell = 298.15; % Simulation temperature, K

%% BatteryPack.Module5
BatteryPack.Module5.BatteryCapacityCell = 27; % Battery capacity, A*hr
BatteryPack.Module5.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Module5.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Module5.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Module5.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Module5.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Module5.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Module5.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Module5.SimulationTemperatureCell = 298.15; % Simulation temperature, K

%% BatteryPack.Segment
BatteryPack.Segment.BatteryCapacityCell = 27; % Battery capacity, A*hr
BatteryPack.Segment.SOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints, SOC
BatteryPack.Segment.TemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints, T, K
BatteryPack.Segment.OpenCircuitVoltageThermalCell = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, OCV(SOC,T), V
BatteryPack.Segment.VoltageRangeCell = [0, inf]; % Terminal voltage operating range, [Min Max], V
BatteryPack.Segment.ResistanceSOCBreakpointsCell = [0, .1, .25, .5, .75, .9, 1]; % State of charge breakpoints for resistance, SOC
BatteryPack.Segment.ResistanceTemperatureBreakpointsCell = [278, 293, 313]; % Temperature breakpoints for resistance, T, K
BatteryPack.Segment.R0ThermalCell = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Instantaneous resistance, R0(SOC,T), Ohm
BatteryPack.Segment.SimulationTemperatureCell = 298.15; % Simulation temperature, K
