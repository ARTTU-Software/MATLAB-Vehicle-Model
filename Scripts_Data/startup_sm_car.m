% Startup file for sm_car.slx Example
% Copyright 2019-2024 The MathWorks, Inc.
clc
clear
curr_proj = simulinkproject;

% Add folders with Simscape Multibody tire subsystem to path
addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody']);

%% Load visualization and other parameters in workspace
Visual = sm_car_param_visual('default');
assignin('base','Visual',Visual);

%% Create .mat files with Vehicle structure presets
evalin('base','Vehicle = sm_car_read_database;')

%% Load Initial Vehicle state database
sm_car_gen_init_database;
evalin('base','Init = IDatabase.Skidpad.FSAE_Achilles;')

%% Load Maneuver database
sm_car_import_maneuver_data;

%% Load Driver database
sm_car_gen_driver_database;

%% Load Camera Frame Database
CDatabase.Camera = sm_car_gen_camera_database;
assignin('base','CDatabase',CDatabase)

%% Load driving surface parameters
Scene = sm_car_import_scene_data;
assignin('base','Scene',Scene);

%% Load control parameters
Control = sm_car_import_control_param;
Control.TrqVec = Control.Ideal_L1_R1_L2_R2_achilles;
assignin('base','Control',Control);

%% Create custom components for drag calculation
custom_code = dir('**/custom_abs.ssc');
cd(custom_code.folder)
ssc_build
cd(fileparts(which('sm_car.slx')))

%% Modify solver settings - patch from development
limitDerivativePerturbations()
daesscSetMultibody()

% If running in a parallel pool
% do not open model or demo script
open_start_content = 1;
if(~isempty(ver('parallel')))
    if(~isempty(getCurrentTask()))
        open_start_content = 0;
    end
end

if(open_start_content)

    %% Open app
    %evalin('base','sm_car_vehcfg_run');

    %% Open model
    sm_car
    sm_car_config_maneuver('sm_car','Skidpad')  
 
end
