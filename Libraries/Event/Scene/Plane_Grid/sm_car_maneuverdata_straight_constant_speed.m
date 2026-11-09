function maneuver_data = sm_car_maneuverdata_straight_constant_speed(varargin)
%sm_car_traj_gen_straight_constant_speed Construct Maneuver for straightline test
%   traj = sm_car_traj_gen_straight_constant_speed
% Optional arguments
%
%      tgtSpd      Speed during lane change (km/h)
%      tgtDist     Distance when target speed is reached (m)
%                    NaN means use time for target speed
%      tgtTime     Time when target speed is reached (sec)
%                    NaN means use distance for target speed
%                  Only distance or time target is observed
%      latOffset   Offset for straightline trajectory (m)
%
% Copyright 2018-2024 The MathWorks, Inc.


% Default values if no arguments supplied
if(nargin == 0)
    tgtSpd      = 12;    % (m/s)
    tgtDist     = NaN;   % (m), NaN means use time for target speed
    tgtTime     =  5;    % (sec), NaN means use distance for target speed
    latOffset   =  0;    % (m)
elseif (nargin == 1)
    tgtSpd    = varargin{1};
    tgtTime   = NaN;
    tgtDist   = 5;
    latOffset = 0;
else     
    tgtSpd    = varargin{1};
    tgtTime   = varargin{2};
    tgtDist   = varargin{3};
    latOffset = varargin{4};
end

maneuver_type = 'Straight_Constant_Speed';


Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;

    % Obtain closed loop trajectory (ramp to target speed)
    traj = sm_car_traj_gen_straight_constant_speed(tgtSpd/3.6,tgtTime,tgtDist,latOffset,false);
    mdata.(Instance).Trajectory = traj;

    mdata.(Instance).xMaxLat.Value         = 5; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 5; % m
    mdata.(Instance).vMinTarget.Units      = 'm/s'; % m
    mdata.(Instance).vMinTarget.Comments   = ''; % m

    mdata.(Instance).vGain.Value           = 1; % m
    mdata.(Instance).vGain.Units           = ''; % m
    mdata.(Instance).vGain.Comments        = 'Scales target speed Trajectory vx'; % m

    mdata.(Instance).xPreview.x.Value      = [2.5 3 21]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 5 20]; % m
    mdata.(Instance).xPreview.v.Units      = 'm/s'; % m
    mdata.(Instance).xPreview.v.Comments   = ''; % m

    mdata.(Instance).nPreviewPoints.Value      = 5; % m
    mdata.(Instance).nPreviewPoints.Units      = ''; % m
    mdata.(Instance).nPreviewPoints.Comments   = 'For Pure Pursuit Driver'; % m    
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end
disp('Running...')

