function sm_car_plot8_Suspension_Forces(out,Maneuver,tout)
VehBus = out.get('VehBus');
VehBus = VehBus.Values.Chassis;

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

        for k=1:2
            for l=1:2
                AarmForces =[AarmForces; struct( ...
                    'Axle',(Axle{i}), ...
                    'Link',(Link(j)), ...
                    'Aarm',(Aarm{k}), ...
                    'Element',(Element{l}), ...
                    'Faxial', VehBus.(Axle{i}).(Link{j}).(ArmF{k}).(Element{l}).Data(2,:,:))];
            end

            UprForces =[UprForces; struct( ...
                    'Axle',(Axle{i}), ...
                    'Link',(Link(j)), ...
                    'Aarm',(Aarm{k}), ...
                    'Element',(Element{3}), ...
                    'Fx', VehBus.(Axle{i}).(Link{j}).(Upr{k}).Data(1,:,:), ...
                    'Fy', VehBus.(Axle{i}).(Link{j}).(Upr{k}).Data(2,:,:)*mirrorY, ...
                    'Fz', VehBus.(Axle{i}).(Link{j}).(Upr{k}).Data(3,:,:))];
        end
        PushrodForces =[PushrodForces; struct( ...
                'Axle',(Axle{i}), ...
                'Link',(Link(j)), ...
                'Element','Pushrod', ...
                'Faxial', VehBus.(Axle{i}).(Link{j}).Push_F.Data(3,:,:))];
        TrackrodForces =[TrackrodForces; struct( ...
                'Axle',(Axle{i}), ...
                'Link',(Link(j)), ...
                'Element','Trackrod', ...
                'Faxial', VehBus.(Axle{i}).(Link{j}).TrackRod_F.Data(3,:,:), ...
                'Fx', VehBus.(Axle{i}).(Link{j}).UprTrack_F.Data(1,:,:), ...
                'Fy', VehBus.(Axle{i}).(Link{j}).UprTrack_F.Data(2,:,:)*mirrorY, ...
                'Fz', VehBus.(Axle{i}).(Link{j}).UprTrack_F.Data(3,:,:))];
    end
end

Forces_MinMax_export(AarmForces, UprForces, PushrodForces, TrackrodForces, Maneuver.Type);
viewForcesGUI(AarmForces, UprForces, PushrodForces, TrackrodForces, tout, Maneuver.Type);

%% Export Function
function Forces_MinMax_export(Aarm,Upr,Pushrod, Trackrod,Maneuver)
% --- A-arm Forces ---
Aarm_MinMax = arrayfun(@(s) struct( ...
    'Axle', s.Axle, ...
    'Link', s.Link, ...
    'Aarm', s.Aarm, ...
    'Element', s.Element, ...
    'maxFaxial', max(s.Faxial), ...
    'minFaxial', min(s.Faxial)), ...
    Aarm);

% --- Upright Forces ---
Upr_MinMax = arrayfun(@(s) struct( ...
    'Axle', s.Axle, ...
    'Link', s.Link, ...
    'Aarm', s.Aarm, ...
    'Element', s.Element, ...
    'maxFx', max(s.Fx), ...
    'minFx', min(s.Fx), ...
    'maxFy', max(s.Fy), ...
    'minFy', min(s.Fy), ...
    'maxFz', max(s.Fz), ...
    'minFz', min(s.Fz)), ...
    Upr);

% --- Pushrod Forces ---
Pushrod_MinMax = arrayfun(@(s) struct( ...
    'Axle', s.Axle, ...
    'Link', s.Link, ...
    'Element', s.Element, ...
    'maxFaxial', max(s.Faxial)), ...
    Pushrod);

% --- Trackrod Forces ---
Trackrod_MinMax = arrayfun(@(s) struct( ...
    'Axle', s.Axle, ...
    'Link', s.Link, ...
    'Element', s.Element, ...
    'maxFaxial', max(s.Faxial), ...
    'minFaxial', min(s.Faxial), ...
    'maxFx', max(s.Fx), ...
    'minFx', min(s.Fx), ...
    'maxFy', max(s.Fy), ...
    'minFy', min(s.Fy), ...
    'maxFz', max(s.Fz), ...
    'minFz', min(s.Fz)), ...
    Trackrod);
[Aarm_MinMax.Comments, Upr_MinMax.Comments, Pushrod_MinMax.Comments, Trackrod_MinMax.Comments ] = deal('');
Aarm_MinMax(1).Comments = 'Pozitiv e compression';
Upr_MinMax(1).Comments = 'Fy pozitiv e orientat spre monopost, restul in sistemul de coordonate al monopostului';
Pushrod_MinMax(1).Comments = 'Pozitiv e compression';
Trackrod_MinMax(1).Comments = 'Faxial pozitiv e compression, Fy pozitiv e orientat spre monopost';

% === Export results to Excel ===
TAarm = struct2table(Aarm_MinMax);
TUpr = struct2table(Upr_MinMax);
TPush = struct2table(Pushrod_MinMax);
TTrack = struct2table(Trackrod_MinMax);

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

    function viewForcesGUI(AarmForces, UprForces, PushrodForces, TrackrodForces, time, Maneuver)
    % === Suspension Forces Viewer (no struct merging) ===
    f = figure('Name','Suspension Forces Viewer','Position',[200 100 950 600]);

    % === Determine time vector from simulation ===
    try
        t = time;
    catch
        t = 1:size(AarmForces(1).Faxial,3); % fallback
        warning('Time vector not found in VehBus. Using index instead.');
    end

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
        'Position',[150 420 120 25]);

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
            dataList = PushrodForces(strcmp({PushrodForces.Axle},axle) & strcmp({PushrodForces.Link},link));
        elseif any(strcmp({TrackrodForces.Element}, elem))
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
        if isfield(s,'Fx') && isfield(s,'Fy') && isfield(s,'Fz') % Upright
            plot(ax1,t,squeeze(s.Fx),'LineWidth',1.3);
            plot(ax1,t,squeeze(s.Fy),'LineWidth',1.3);
            plot(ax1,t,squeeze(s.Fz),'LineWidth',1.3);
            legendEntries = {'Fx','Fy','Fz'};
        elseif isfield(s,'Faxial') && strcmp(s.Element,'Pushrod')
            plot(ax1,t,squeeze(s.Faxial),'LineWidth',1.5);
            legendEntries = {'Faxial'};
        elseif isfield(s,'Faxial') && strcmp(s.Element,'Trackrod')
            plot(ax1,t,squeeze(s.Faxial),'LineWidth',1.5);
            if isfield(s,'Fy')
                plot(ax1,t,squeeze(s.Fy),'--','LineWidth',1.3);
                legendEntries = {'Faxial','Fy'};
            else
                legendEntries = {'Faxial'};
            end
        elseif isfield(s,'Faxial') % A-arm
            plot(ax1,t,squeeze(s.Faxial),'LineWidth',1.5);
            if isfield(s,'Fy')
                plot(ax1,t,squeeze(s.Fy),'--','LineWidth',1.3);
                legendEntries = {'Faxial','Fy'};
            else
                legendEntries = {'Faxial'};
            end
        else
            title(ax1,'Unsupported data structure');
        end

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