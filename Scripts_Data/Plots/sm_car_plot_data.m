function bus = sm_car_plot_data(results)
%SM_CAR_PLOT_DATA Read the vehicle output bus for the plotting tools.
% Accept a SimulationOutput, a dataset, or the OutBus values directly.
if nargin == 0 || isempty(results)
    results = [];
    names = ["out","yout","logsout_sm_car"];
    for name = names
        if evalin('caller',"exist('" + name + "','var')")
            results = evalin('caller',name);
            break
        end
    end
    if isempty(results)
        for name = names
            if evalin('base',"exist('" + name + "','var')")
                results = evalin('base',name);
                break
            end
        end
    end
end

if isa(results,'Simulink.SimulationOutput')
    outputNames = who(results);
    if any(strcmp(outputNames,'yout'))
        results = results.get('yout');
    elseif any(strcmp(outputNames,'logsout_sm_car'))
        results = results.get('logsout_sm_car');
    end
end

if isa(results,'Simulink.SimulationData.Dataset') || ...
        isa(results,'Simulink.SimulationData.DatasetRef')
    names = string(results.getElementNames);
    if any(names == "OutBus")
        results = results.get('OutBus').Values;
    else
        % A legacy dataset records the component buses as separate elements.
        groups = ["VehBus","DrvBus","RdBus","CtrlBus","PostBus","TrlBus"];
        values = struct;
        for name = groups(ismember(groups,names))
            values.(name) = results.get(char(name)).Values;
        end
        results = values;
    end
elseif isa(results,'Simulink.SimulationData.Signal')
    results = results.Values;
end

if ~isstruct(results) || ~isscalar(results) || ~isfield(results,'VehBus')
    error('sm_car:MissingPlotOutput', ...
        'No vehicle output found. Run the model with OutBus output logging or pass a simulation result.');
end
bus = results;
end
