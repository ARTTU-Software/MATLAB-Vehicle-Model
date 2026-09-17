function maneuver_data = sm_car_maneuverdata_crg_balkans_end_f

maneuver_type = 'CRG_Balkans_End_F';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Trajectory_LoadFile.Value    = 'CRG_Balkans_End_f_trajectory_default.mat';
    mdata.(Instance).Trajectory_LoadFile.Units    = '';
    mdata.(Instance).Trajectory_LoadFile.Comments = '';

    mdata.(Instance).xMaxLat.Value         = 5; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 4; % m
    mdata.(Instance).vMinTarget.Units      = 'm/s'; % m
    mdata.(Instance).vMinTarget.Comments   = ''; % m

    mdata.(Instance).vGain.Value           = 0.95; % m
    mdata.(Instance).vGain.Units           = ''; % m
    mdata.(Instance).vGain.Comments        = 'Scales target speed Trajectory vx'; % m

    mdata.(Instance).xPreview.x.Value      = [3 5 10]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 5 20]; % m
    mdata.(Instance).xPreview.v.Units      = 'm/s'; % m
    mdata.(Instance).xPreview.v.Comments   = ''; % m

    mdata.(Instance).nPreviewPoints.Value      = 5; % m
    mdata.(Instance).nPreviewPoints.Units      = ''; % m
    mdata.(Instance).nPreviewPoints.Comments   = 'For Pure Pursuit Driver'; % m    

end

% Unique trajectory settings (larger vehicles)
% none

% Unique trajectory settings (counterclockwise)
% none

% Fill in trajectory data
for i = 1:length(fieldnames(mdata))
    Instance = Instance_List{i};
    mdata.(Instance).Trajectory = load(mdata.(Instance).Trajectory_LoadFile.Value);
    if isfield(mdata.(Instance).Trajectory.vx,'GGV')
        % The saved GGV profile already contains the requested grip reserve.
        mdata.(Instance).vGain.Value = 1;
        % This is an off-path recovery speed, not a normal speed floor.
        mdata.(Instance).vMinTarget.Value = min(4,min(mdata.(Instance).Trajectory.vx.Value));
    end
end

maneuver_data.(maneuver_type) = mdata;
