function sm_car_refresh_outbus_types(output)
model = bdroot(output);
if ~strcmp(get_param(model,'SimulationStatus'),'stopped') || ...
        strcmp(get_param(model,'FastRestart'),'on')
    error('sm_car:OutBusRefreshRunning', ...
        'Stop the simulation and turn off Fast Restart before refreshing OutBus types.');
end

outport = [model '/OutBus'];
port = get_param(outport,'PortHandles');
line = get_param(port.Inport,'Line');
if line == -1
    error('sm_car:OutBusNotConnected','Connect the root OutBus port before refreshing its types.');
end
source = get_param(line,'SrcPortHandle');
if source == -1
    error('sm_car:OutBusNotConnected','Connect the root OutBus port before refreshing its types.');
end
points = get_param(line,'Points');
lineName = get_param(line,'Name');
outputType = get_param(outport,'OutDataTypeStr');
rootType = strtrim(extractAfter(outputType,'Bus:'));

dictionary = Simulink.data.dictionary.open(get_param(model,'DataDictionary'));
if dictionary.HasUnsavedChanges
    close(dictionary);
    error('sm_car:OutBusDictionaryHasEdits', ...
        'Save or discard the pending OutBus dictionary edits before refreshing.');
end
closeDictionary = onCleanup(@() closeRefreshDictionary(dictionary));
section = getSection(dictionary,'Design Data');
oldTypes = collectTypes(section,rootType);

dirty = get_param(model,'Dirty');
restoreExport = @() reconnect(model,port.Inport,source,points,lineName);
resetExport = onCleanup(restoreExport);
try
    delete_line(line);
    schema = captureOutBus(model,outport,source);
    restoreExport();
    clear resetExport
    for name = setdiff(oldTypes,{rootType},'stable')
        deleteEntry(section,name{1});
    end
    generated = Simulink.Bus.createObject(schema,'','cell',dictionary);
    root = getEntry(section,generated.busName);
    setValue(getEntry(section,rootType),getValue(root));
    deleteEntry(section,generated.busName);
    set_param(model,'SimulationCommand','update');
    save_system(model);
    saveChanges(dictionary);
catch cause
    restoreExport();
    set_param(model,'Dirty',dirty);
    rethrow(cause);
end
fprintf('Refreshed and saved OutBus types in %s.\n',get_param(model,'DataDictionary'));
end

function schema = captureOutBus(model,outport,source)
tap = add_block('simulink/Sinks/Record',[model '/OutBus Type Source'], ...
    'MakeNameUnique','on','RecordToWorkspace','on','VariableName','outBusTypeSample');
removeTap = onCleanup(@() removeTypeSource(tap));
ports = get_param(tap,'PortHandles');
add_line(model,source,ports.Inport,'autorouting','on');
runsBefore = Simulink.sdi.getAllRunIDs();
removeProbeRun = onCleanup(@() removeRefreshRun(model,runsBefore));
input = Simulink.SimulationInput(model);
input = input.setBlockParameter(outport,'OutDataTypeStr','Inherit: auto');
input = input.setBlockParameter(outport,'BusOutputAsStruct','off');
input = input.setModelParameter('SaveOutput','off','StartFcn','','StopFcn','', ...
    'StopTime',get_param(model,'StartTime'));
result = sim(input);
probe = result.get('outBusTypeSample');
sample = probe{1};
schema = sample.Values;
end

function removeRefreshRun(model,runsBefore)
run = Simulink.sdi.getCurrentSimulationRun(model);
if ~isempty(run) && ~ismember(run.ID,runsBefore)
    Simulink.sdi.deleteRun(run.ID);
end
end

function closeRefreshDictionary(dictionary)
if dictionary.HasUnsavedChanges
    discardChanges(dictionary);
end
close(dictionary);
end

function removeTypeSource(tap)
ports = get_param(tap,'PortHandles');
wire = get_param(ports.Inport,'Line');
if wire ~= -1
    delete_line(wire);
end
delete_block(tap);
end

function names = collectTypes(section,rootType)
entries = find(section);
available = {entries.Name};
names = {};
pending = {rootType};
while ~isempty(pending)
    name = pending{end};
    pending(end) = [];
    if any(strcmp(names,name))
        continue
    end
    bus = getValue(getEntry(section,name));
    if isa(bus,'Simulink.Bus')
        names{end+1} = name;
        children = regexprep({bus.Elements.DataType},'^Bus:\s*','');
        pending = [pending, intersect(children,available,'stable')];
    end
end
end

function reconnect(model,destination,source,points,lineName)
if get_param(destination,'Line') == -1
    wire = add_line(model,points);
    if get_param(wire,'SrcPortHandle') ~= source || get_param(destination,'Line') == -1
        delete_line(wire);
        wire = add_line(model,source,destination,'autorouting','on');
    end
    set_param(wire,'Name',lineName);
end
end
