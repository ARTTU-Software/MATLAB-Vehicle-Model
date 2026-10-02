classdef sm_car_ggv_speed_profileTest < matlab.unittest.TestCase
    % Analytic grip tests and the real Balkans End exported interface.
    properties (TestParameter)
        road = {'CRG_Balkans_end','CRG_Balkans_end_f'};
    end
    methods (TestClassSetup)
        function paths(testCase)
            folder=fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(folder));
            root=fileparts(fileparts(fileparts(fileparts(folder))));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(...
                fullfile(root,'Scripts_Data','GGV_Sweep')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(...
                fullfile(root,'Libraries','Event','Scene','CRG_Balkans_End')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(...
                fullfile(root,'Libraries','Event','Scene','CRG_Balkans_End','data')));
        end
    end
    methods (Test)
        function constantRadiusMatchesPhysics(testCase)
            [xyz,data,options]=testCase.circle();
            [v,report]=sm_car_ggv_speed_profile(xyz,data,options);
            expected=sqrt(options.ggv_utilization*9.81*20);
            testCase.verifyEqual(v,repmat(expected,1,128),'AbsTol',1e-6);
            testCase.verifyEqual(report.max_utilization_bound,0.95,'AbsTol',1e-7);
        end
        function gripFactorHasSquareRootSpeedEffect(testCase)
            [xyz,data,options]=testCase.circle();
            vFast=sm_car_ggv_speed_profile(xyz,data,options);
            options.ggv_utilization=0.6;
            vSlow=sm_car_ggv_speed_profile(xyz,data,options);
            testCase.verifyEqual(vSlow./vFast,repmat(sqrt(0.6/0.95),1,128),'AbsTol',1e-7);
        end
        function brakesBeforeCornersAndAcceleratesAfter(testCase)
            [xyz,data,options]=testCase.oval();
            [v,report]=sm_car_ggv_speed_profile(xyz,data,options);
            testCase.verifyGreaterThan(max(diff(v)),0.05);
            testCase.verifyLessThan(min(diff(v)),-0.05);
            testCase.verifyTrue(any(v'<report.corner_speed_mps-0.5));
            % Independent physical check: the polygon is inside the unit circle.
            demand=hypot(report.demand_ax_mps2,report.demand_ay_mps2)/9.81;
            testCase.verifyLessThanOrEqual(max(demand),options.ggv_utilization+1e-7);
        end
        function closureDoesNotDependOnStartIndex(testCase)
            [xyz,data,options]=testCase.oval();
            [v,report]=sm_car_ggv_speed_profile(xyz,data,options);
            [shifted,shiftReport]=sm_car_ggv_speed_profile(circshift(xyz,37,1),data,options);
            testCase.verifyEqual(shifted,circshift(v,37,2),'AbsTol',1e-5);
            testCase.verifyEqual(shiftReport.lap_time_s,report.lap_time_s,'AbsTol',1e-5);
        end
        function signedLateralEnvelopeIsPreserved(testCase)
            [xyz,data,options]=testCase.circle();
            data.lat_acc_pts_g(data.lat_acc_pts_g<0)=0.5*data.lat_acc_pts_g(data.lat_acc_pts_g<0);
            left=sm_car_ggv_speed_profile(xyz,data,options);
            right=sm_car_ggv_speed_profile(flipud(xyz),data,options);
            testCase.verifyEqual(right./left,repmat(sqrt(0.5),1,128),'AbsTol',1e-6);
        end
        function speedDependentEnvelopeIsInterpolated(testCase)
            [xyz,data,options]=testCase.circle();
            data.lng_acc_pts_g(65:end)=2*data.lng_acc_pts_g(65:end);
            data.lat_acc_pts_g(65:end)=2*data.lat_acc_pts_g(65:end);
            v=sm_car_ggv_speed_profile(xyz,data,options);
            % Normalized facets interpolate linearly between 0 and 30 m/s.
            utilization=(1-v/60).*v.^2/(20*9.81);
            testCase.verifyEqual(utilization,repmat(0.95,1,128),'AbsTol',1e-6);
        end
        function noHighSpeedExtrapolation(testCase)
            [xyz,data,options]=testCase.circle();
            xyz=xyz*100;
            options.vmax=40;
            testCase.verifyWarning(@() sm_car_ggv_speed_profile(xyz,data,options),'sm_car_ggv:SpeedCapped');
        end
        function fullGripWarns(testCase)
            [xyz,data,options]=testCase.circle();
            options.ggv_utilization=1;
            testCase.verifyWarning(@() sm_car_ggv_speed_profile(xyz,data,options),'sm_car_ggv:AtGripLimit');
        end
        function incompleteEnvelopeRejected(testCase)
            [xyz,data,options]=testCase.circle();
            data=rmfield(data,'lng_acc_pts_g');
            testCase.verifyError(@() sm_car_ggv_speed_profile(xyz,data,options),'sm_car_ggv:InvalidData');
        end
        function duplicateClosingPointRejected(testCase)
            [xyz,data,options]=testCase.circle();
            testCase.verifyError(@() sm_car_ggv_speed_profile([xyz;xyz(1,:)],data,options),'sm_car_ggv:InvalidPath');
        end
        function gradeDemandStaysInsideGrip(testCase)
            [xyz,data,options]=testCase.oval();
            xyz(:,3)=0.05*xyz(:,1);
            [~,report]=sm_car_ggv_speed_profile(xyz,data,options);
            demand=hypot(report.demand_ax_mps2,report.demand_ay_mps2)/9.81;
            testCase.verifyLessThanOrEqual(max(demand),0.950001);
            testCase.verifyLessThanOrEqual(report.max_utilization_bound,0.950001);
        end
        function missingFileDoesNotFallBack(testCase)
            options=CRG_Create_Balkans_End;
            options.ggv_file='nonexistent_ggv_test_file.mat';
            testCase.verifyError(@() sm_car_trajectory_calc('CRG_Balkans_end_f',options),'sm_car_ggv:MissingFile');
        end
        function exportedBalkansInterface(testCase,road)
            options=CRG_Create_Balkans_End;
            options.show_plots=false;
            options.vmax=20;
            before=pwd;
            [trajectory,report]=sm_car_trajectory_calc(road,options);
            testCase.verifyEqual(pwd,before);
            testCase.verifyEqual(sort(fieldnames(trajectory)),sort({'x';'y';'z';'vx';'aYaw';'xTrajectory'}));
            testCase.verifyGreaterThan(min(diff(trajectory.xTrajectory.Value)),0);
            testCase.verifyEqual(trajectory.xTrajectory.Value(end),report.lap_length_m,'AbsTol',1e-9);
            testCase.verifyEqual(trajectory.x.Value(end),trajectory.x.Value(1),'AbsTol',1e-10);
            testCase.verifyEqual(trajectory.y.Value(end),trajectory.y.Value(1),'AbsTol',1e-10);
            testCase.verifyEqual(trajectory.vx.Value(end),trajectory.vx.Value(1),'AbsTol',1e-10);
            testCase.verifyLessThanOrEqual(max(trajectory.vx.Value),20);
            testCase.verifyLessThanOrEqual(report.max_utilization_bound,0.950001);
            testCase.verifyGreaterThan(min(trajectory.vx.Value),0);
            testCase.verifyTrue(isfield(trajectory.vx,'GGV'));
            testCase.verifySize(trajectory.vx.Value,[numel(trajectory.xTrajectory.Value),1]);
        end
    end
    methods (Static,Access=private)
        function [xyz,data,options]=circle()
            theta=(0:127)'*2*pi/128;
            xyz=[20*cos(theta) 20*sin(theta) zeros(size(theta))];
            a=(0:63)'*2*pi/64;
            data=struct('lng_acc_pts_g',repmat(cos(a),2,1),...
                'lat_acc_pts_g',repmat(sin(a),2,1),...
                'veh_spd_pts_mps',repelem([0;30],64));
            options=struct('ggv_utilization',0.95,'vmax',30);
        end
        function [xyz,data,options]=oval()
            [~,data,options]=sm_car_ggv_speed_profileTest.circle();
            theta=(0:255)'*2*pi/256;
            xyz=[60*cos(theta) 12*sin(theta) zeros(size(theta))];
        end
    end
end
