classdef sm_car_path_progress < matlab.System
    % Signed path progress from initial CG position and absolute station, m.
    % Project onto the nominal maneuver polyline. A local station window
    % preserves route continuity at crossings and repeated path branches.
    % Distance starts at zero after setup/reset and continues across laps.
    % The separate station output wraps for existing lap-transition counters.

    properties (Nontunable)
        PathX = [0; 1]
        PathY = [0; 0]
        PathStation = [0; 1]
        PathClosed = false
        SearchDistance = 20
        SampleTime = 0.002
    end

    properties (DiscreteState)
        PreviousStation
        DistanceFromStart
        Initialized
    end

    methods
        function obj = sm_car_path_progress(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj, ~, ~)
            assert(numel(obj.PathX) >= 2);
            assert(numel(obj.PathX) == numel(obj.PathY));
            assert(numel(obj.PathX) == numel(obj.PathStation));
            assert(all(isfinite(obj.PathX(:))));
            assert(all(isfinite(obj.PathY(:))));
            assert(all(isfinite(obj.PathStation(:))));
            assert(all(diff(obj.PathStation(:)) >= 0));
            assert(obj.PathStation(end) > obj.PathStation(1));
            assert(any(diff(obj.PathX(:)).^2 + diff(obj.PathY(:)).^2 > eps));
            assert(isscalar(obj.PathClosed));
            assert(isscalar(obj.SearchDistance) && ...
                isfinite(obj.SearchDistance) && obj.SearchDistance > 0);
            assert(isscalar(obj.SampleTime) && ...
                isfinite(obj.SampleTime) && obj.SampleTime > 0);
            obj.PreviousStation = 0;
            obj.DistanceFromStart = 0;
            obj.Initialized = false;
        end

        function [dist,station] = stepImpl(obj, xCG, yCG)
            closingLength = 0;
            if obj.PathClosed
                closingLength = hypot(obj.PathX(1)-obj.PathX(end), ...
                    obj.PathY(1)-obj.PathY(end));
            end
            pathLength = obj.PathStation(end)-obj.PathStation(1)+closingLength;
            bestDistance = inf;
            bestDelta = inf;
            bestStation = obj.PreviousStation;
            globalDistance = inf;
            globalStation = 0;
            segmentCount = numel(obj.PathX)-1;
            if obj.PathClosed && closingLength > eps
                segmentCount = segmentCount+1;
            end

            for k = 1:segmentCount
                if k < numel(obj.PathX)
                    x0 = obj.PathX(k);
                    y0 = obj.PathY(k);
                    dx = obj.PathX(k+1)-x0;
                    dy = obj.PathY(k+1)-y0;
                    s0 = obj.PathStation(k)-obj.PathStation(1);
                    ds = obj.PathStation(k+1)-obj.PathStation(k);
                else
                    x0 = obj.PathX(end);
                    y0 = obj.PathY(end);
                    dx = obj.PathX(1)-x0;
                    dy = obj.PathY(1)-y0;
                    s0 = obj.PathStation(end)-obj.PathStation(1);
                    ds = closingLength;
                end
                lengthSquared = dx*dx+dy*dy;
                if lengthSquared <= eps
                    continue
                end
                fraction = min(1,max(0,((xCG-x0)*dx+(yCG-y0)*dy)/lengthSquared));
                candidate = s0+fraction*ds;
                distance = (xCG-x0-fraction*dx)^2+(yCG-y0-fraction*dy)^2;
                if distance < globalDistance
                    globalDistance = distance;
                    globalStation = candidate;
                end

                delta = candidate-obj.PreviousStation;
                if obj.PathClosed
                    delta = mod(delta+pathLength/2,pathLength)-pathLength/2;
                end
                if ~obj.Initialized || abs(delta) <= obj.SearchDistance
                    % Prefer nearby route progress when geometry is tied.
                    tieTolerance = 1e-12*max(1,distance);
                    if distance < bestDistance-tieTolerance || ...
                            (abs(distance-bestDistance) <= tieTolerance && ...
                             abs(delta) < bestDelta)
                        bestDistance = distance;
                        bestDelta = abs(delta);
                        bestStation = candidate;
                    end
                end
            end

            % Reacquire after a large position jump/off-path excursion.
            if ~isfinite(bestDistance) || bestDistance > obj.SearchDistance^2
                bestStation = globalStation;
            end
            station = bestStation;
            if obj.PathClosed
                station = mod(station,pathLength);
            end
            if obj.Initialized
                advance = station-obj.PreviousStation;
                if obj.PathClosed
                    advance = mod(advance+pathLength/2,pathLength)-pathLength/2;
                end
                obj.DistanceFromStart = obj.DistanceFromStart+advance;
            else
                obj.DistanceFromStart = 0;
            end
            dist = obj.DistanceFromStart;
            obj.PreviousStation = station;
            obj.Initialized = true;
        end

        function resetImpl(obj)
            obj.PreviousStation = 0;
            obj.DistanceFromStart = 0;
            obj.Initialized = false;
        end

        function [stateSize,stateType,stateComplex] = ...
                getDiscreteStateSpecificationImpl(~,stateName)
            stateSize = [1 1];
            stateComplex = false;
            if strcmp(stateName,'Initialized')
                stateType = 'logical';
            else
                stateType = 'double';
            end
        end

        function sampleTime = getSampleTimeImpl(obj)
            sampleTime = createSampleTime(obj,'Type','Discrete', ...
                'SampleTime',obj.SampleTime);
        end

        function [distSize,stationSize] = getOutputSizeImpl(~)
            distSize = [1 1];
            stationSize = [1 1];
        end

        function [distType,stationType] = getOutputDataTypeImpl(~)
            distType = 'double';
            stationType = 'double';
        end

        function [distComplex,stationComplex] = isOutputComplexImpl(~)
            distComplex = false;
            stationComplex = false;
        end

        function [distFixed,stationFixed] = isOutputFixedSizeImpl(~)
            distFixed = true;
            stationFixed = true;
        end

        function [distName,stationName] = getOutputNamesImpl(~)
            distName = 'dist';
            stationName = 'pathStation';
        end
    end
end
