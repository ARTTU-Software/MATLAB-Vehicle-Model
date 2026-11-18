function sm_car_plot8_Suspension_Forces(out,Maneuver,~)
% Plot forces against their logged timestamps. The third input is optional
% and is retained for callers that pass the simulation time vector.
plotBus = sm_car_plot_data(out);
VehBus = plotBus.VehBus.Chassis;
rearAxleX = [];

Aarm = {'UpperWishbone', 'LowerWishbone'};
Axle = {'SuspA1', 'SuspA2'};
Link = {'LinkageL', 'LinkageR'};
Element={'Front', 'Rear','Upr'};
ArmF={'UA_F','LA_F'};
Upr={'UprUA_F','UprLA_F'};

AarmForces=[];
UprForces = [];
PushrodForces=[];
TrackrodForces=[];

for i=1:2
    for j=1:2
        if j==1
            mirrorY=-1;
        else
            mirrorY=1;
        end
        corner = VehBus.(Axle{i}).(Link{j});

        for k=1:2
            for l=1:2
                armForce = corner.(ArmF{k}).(Element{l});
                AarmForces =[AarmForces; struct( ...
                    'Axle',(Axle{i}), ...
                    'Link',(Link(j)), ...
                    'Aarm',(Aarm{k}), ...
                    'Element',(Element{l}), ...
                    'AxialTime', armForce.Time, ...
                    'Faxial', armForce.Data(2,:,:))];
            end

            uprightForce = corner.(Upr{k});
            UprForces =[UprForces; struct( ...
                    'Axle',(Axle{i}), ...
                    'Link',(Link(j)), ...
                    'Aarm',(Aarm{k}), ...
                    'Element',(Element{3}), ...
                    'ComponentTime', uprightForce.Time, ...
                    'Fx', uprightForce.Data(1,:,:), ...
                    'Fy', uprightForce.Data(2,:,:)*mirrorY, ...
                    'Fz', uprightForce.Data(3,:,:))];
        end
        PushrodForces =[PushrodForces; struct( ...
                'Axle',(Axle{i}), ...
                'Link',(Link(j)), ...
                'Element','Pushrod', ...
                'AxialTime', corner.Push_F.Time, ...
                'Faxial', corner.Push_F.Data(3,:,:))];
        TrackrodForces =[TrackrodForces; struct( ...
                'Axle',(Axle{i}), ...
                'Link',(Link(j)), ...
                'Element','Trackrod', ...
                'AxialTime', corner.TrackRod_F.Time, ...
                'Faxial', corner.TrackRod_F.Data(3,:,:), ...
                'ComponentTime', corner.UprTrack_F.Time, ...
                'Fx', corner.UprTrack_F.Data(1,:,:), ...
                'Fy', corner.UprTrack_F.Data(2,:,:)*mirrorY, ...
                'Fz', corner.UprTrack_F.Data(3,:,:))];
    end
end

Forces_MinMax_export(AarmForces, UprForces, PushrodForces, TrackrodForces, Maneuver.Type);
viewForcesGUI(AarmForces, UprForces, PushrodForces, TrackrodForces, Maneuver.Type);

%% Export Function
function Forces_MinMax_export(Aarm,Upr,Pushrod, Trackrod,Maneuver)
TAarm = extremaTable(Aarm,"Faxial",'Pozitiv e compression');
TUpr = extremaTable(Upr,["Fx","Fy","Fz"], ...
    'Fy pozitiv e orientat spre monopost, restul in sistemul de coordonate al monopostului');
TPush = extremaTable(Pushrod,"Faxial",'Pozitiv e compression');
TTrack = extremaTable(Trackrod,["Faxial","Fx","Fy","Fz"], ...
    'Faxial pozitiv e compression, Fy pozitiv e orientat spre monopost');

% === Create directory if it doesn't exist ===
sdlreportsDir = fullfile(pwd, 'sdlreports');
if ~exist(sdlreportsDir, 'dir')
    mkdir(sdlreportsDir);
end

% === Define full path for the Excel file ===
filename = fullfile(sdlreportsDir, strcat(Maneuver, '_Forces.xlsx'));
writetable(TAarm, filename, 'Sheet', 'AarmForces');
writetable(TUpr, filename, 'Sheet', 'UprForces');
writetable(TPush, filename, 'Sheet', 'PushrodForces');
writetable(TTrack, filename, 'Sheet', 'TrackrodForces');

end

function results = extremaTable(forces, components, comment)
    signalFields = intersect(fieldnames(forces), [cellstr(components), {'AxialTime','ComponentTime'}]);
    results = struct2table(rmfield(forces,signalFields));
    sampleDetails = table;
    n = numel(forces);

    for component = components
        timeField = 'ComponentTime';
        if component == "Faxial"
            timeField = 'AxialTime';
        end
        extrema = nan(n,2);
        sampleTimes = nan(n,2);
        upperXYZ = nan(n,3,2);
        lowerXYZ = nan(n,3,2);
        for row = 1:n
            force = forces(row);
            values = force.(component);
            if all(isnan(values(:)))
                continue
            end
            time_noinit = force.(timeField)(:) > 1;
            [maximum,maxIndex] = max(values(time_noinit));
            [minimum,minIndex] = min(values(time_noinit));
            indices = [maxIndex,minIndex];
            extrema(row,:) = [maximum,minimum];
            time = force.(timeField)(time_noinit);
            sampleTimes(row,:) = time(indices).';

            corner = VehBus.(force.Axle).(force.Link);
            upperPosition = positionAtForceSamples(corner,'UpperUprightXYZ',time,indices);
            lowerPosition = positionAtForceSamples(corner,'LowerUprightXYZ',time,indices);
            if strcmp(force.Axle,'SuspA2') && any(isfinite([upperPosition(:,1); lowerPosition(:,1)]))
                % Rear upright sensors report X relative to the rear axle.
                if isempty(rearAxleX)
                    rearAxleX = evalin('base','Vehicle.Chassis.Body.sAxle2.Value(1)');
                end
                upperPosition(:,1) = upperPosition(:,1) + rearAxleX;
                lowerPosition(:,1) = lowerPosition(:,1) + rearAxleX;
            end
            upperXYZ(row,:,:) = upperPosition.';
            lowerXYZ(row,:,:) = lowerPosition.';
        end
        prefixes = ["max","min"] + component;
        axesNames = ["X","Y","Z"];
        for k = 1:2
            prefix = prefixes(k);
            results.(prefix) = extrema(:,k);
            sampleDetails.(prefix + "_Time_s") = sampleTimes(:,k);
            for axis = 1:3
                sampleDetails.(prefix + "_Upper" + axesNames(axis) + "_m") = upperXYZ(:,axis,k);
            end
            for axis = 1:3
                sampleDetails.(prefix + "_Lower" + axesNames(axis) + "_m") = lowerXYZ(:,axis,k);
            end
        end
    end
    results.Comments = repmat({''},n,1);
    results.Comments{1} = comment;
    results = [results, sampleDetails];
end

function xyz = positionAtForceSamples(corner, field, forceTime, indices)
    xyz = nan(numel(indices),3);
    if ~isfield(corner,field) || isempty(corner.(field).Time)
        return
    end
    signal = corner.(field);
    time = signal.Time(:);
    % Logged vectors can have time along either their first or last dimension.
    if signal.IsTimeFirst
        data = reshape(signal.Data,numel(time),3);
    else
        data = reshape(signal.Data,3,numel(time)).';
    end

    if isequal(time,forceTime)
        xyz = data(indices,:);
        return
    end
    % Sample at the force timestamps when the sensors have a different time grid.
    [time,rows] = unique(time,'last');
    queryTime = forceTime(indices);
    if numel(time) == 1
        xyz(queryTime == time,:) = data(repmat(rows,nnz(queryTime == time),1),:);
    else
        xyz = interp1(time,data(rows,:),queryTime,'linear',NaN);
    end
end

    function viewForcesGUI(AarmForces, UprForces, PushrodForces, TrackrodForces, Maneuver)
    % === Suspension Forces Viewer (no struct merging) ===
    f = figure('Name','Suspension Forces Viewer','Position',[200 100 950 600]);

    % === Collect available options dynamically ===
    axles = unique([ {AarmForces.Axle}, {UprForces.Axle}, {PushrodForces.Axle}, {TrackrodForces.Axle} ]);
    links = unique([ {AarmForces.Link}, {UprForces.Link}, {PushrodForces.Link}, {TrackrodForces.Link} ]);
    elements = unique([ {AarmForces.Element}, {UprForces.Element}, {PushrodForces.Element}, {TrackrodForces.Element} ]);
    aarms = unique([{AarmForces.Aarm}, {UprForces.Aarm}]);
    aarms = [{'N/A'}, aarms]; % for elements that don't use 'Aarm'

    % === UI Controls ===
    uicontrol('Style','text','String','Axle:',...
        'Position',[50 540 60 20],'HorizontalAlignment','left');
    ddAxle = uicontrol('Style','popupmenu','String',axles,...
        'Position',[120 540 120 25]);

    uicontrol('Style','text','String','Link:',...
        'Position',[50 500 60 20],'HorizontalAlignment','left');
    ddLink = uicontrol('Style','popupmenu','String',links,...
        'Position',[120 500 120 25]);

    uicontrol('Style','text','String','Element:',...
        'Position',[50 460 60 20],'HorizontalAlignment','left');
    ddElement = uicontrol('Style','popupmenu','String',elements,...
        'Position',[120 460 120 25]);

    uicontrol('Style','text','String','Arm (if any):',...
        'Position',[50 420 100 20],'HorizontalAlignment','left');
    ddArm = uicontrol('Style','popupmenu','String',aarms,...
        'Position',[150 420 120 25],'Value',2);

    % === Buttons ===
    uicontrol('Style','pushbutton','String','Plot Forces',...
        'Position',[100 370 100 30],'Callback',@plotForces);

    uicontrol('Style','pushbutton','String','Export Min/Max to Excel',...
        'Position',[50 330 200 30],'BackgroundColor',[0.6 0.8 0.6],...
        'Callback',@exportData);

    % === Axes ===
    ax1 = axes('Parent',f,'Position',[0.38 0.18 0.6 0.75]);
    title(ax1,'Force Time Series');
    grid(ax1,'on');
    xlabel(ax1,'Time (s)');
    ylabel(ax1,'Force (N)');

    % === Info text ===
    txtInfo = uicontrol('Style','text','String','',...
        'Position',[50 270 300 50],'HorizontalAlignment','left','FontWeight','bold');

    % === Callback: Plot Forces ===
    function plotForces(~,~)
        axle = ddAxle.String{ddAxle.Value};
        link = ddLink.String{ddLink.Value};
        elem = ddElement.String{ddElement.Value};
        arm  = ddArm.String{ddArm.Value};

        % --- Identify correct struct ---
        if any(strcmp({UprForces.Element}, elem))
            dataList = UprForces(strcmp({UprForces.Axle},axle) & strcmp({UprForces.Link},link) & strcmp({UprForces.Aarm},arm));
        elseif any(strcmp({PushrodForces.Element}, elem))
            arm = 'N/A';
            dataList = PushrodForces(strcmp({PushrodForces.Axle},axle) & strcmp({PushrodForces.Link},link));
        elseif any(strcmp({TrackrodForces.Element}, elem))
            arm = 'N/A';
            dataList = TrackrodForces(strcmp({TrackrodForces.Axle},axle) & strcmp({TrackrodForces.Link},link));
        else
            dataList = AarmForces(strcmp({AarmForces.Axle},axle) & strcmp({AarmForces.Link},link) & strcmp({AarmForces.Element},elem) & strcmp({AarmForces.Aarm},arm));
        end

        if isempty(dataList)
            cla(ax1);
            title(ax1,'No matching data found');
            set(txtInfo,'String','No data found for selected combination');
            return;
        end

        % --- Clear and plot ---
        cla(ax1); hold(ax1,'on');
        s = dataList(1);
        legendEntries = {};

        % --- Plot logic ---
        if isfield(s,'Faxial')
            plot(ax1,s.AxialTime,s.Faxial(:),'LineWidth',1.5);
            legendEntries = {'Faxial'};
        end
        if isfield(s,'ComponentTime')
            plot(ax1,s.ComponentTime,s.Fx(:),'LineWidth',1.3);
            plot(ax1,s.ComponentTime,s.Fy(:),'LineWidth',1.3);
            plot(ax1,s.ComponentTime,s.Fz(:),'LineWidth',1.3);
            legendEntries = [legendEntries, {'Fx','Fy','Fz'}];
        end
        hold(ax1,'off');

        legend(ax1,legendEntries,'Location','best');
        title(ax1,sprintf('%s - %s - %s - %s',link,axle,arm,elem));
        xlabel(ax1,'Time (s)'); ylabel(ax1,'Force (N)');
        grid(ax1,'on');

        set(txtInfo,'String',sprintf('Axle: %s | Link: %s | Element: %s | Arm: %s',axle,link,elem,arm));
        drawnow;
    end

    % === Callback: Export Data ===
    function exportData(~,~)
        try
            Forces_MinMax_export(AarmForces,UprForces,PushrodForces,TrackrodForces,Maneuver);
            msgbox(sprintf('Data exported successfully for "%s" maneuver.',Maneuver),'Export Complete','help');
        catch ME
            errordlg(['Export failed: ' ME.message],'Export Error');
        end
    end
end
end
