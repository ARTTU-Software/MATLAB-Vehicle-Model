classdef sm_car_stanley_reference < matlab.System
    % Local path reference for the MathWorks Stanley controller.
    % Input: vehicle body-reference pose [x y yaw], metres/radians, and
    % direction (+1 forward, -1 reverse). Outputs use metres/radians.
    % Forward tracking projects the front axle onto the supplied polyline;
    % reverse tracking projects the rear axle. CurrPose always uses the rear
    % axle, as required by Lateral Controller Stanley. No preview is applied.
    % Path samples must describe the active trajectory in world coordinates.
    % Closed tracks should include their closing segment in those samples.

    properties (Nontunable)
        PathX = [0; 1]
        PathY = [0; 0]
        PathYaw = [0; 0]
        % [frontX frontY rearX rearY], relative to the body reference frame.
        AxleOffsets = [0 0 -1 0]
    end

    methods (Access = protected)
        function setupImpl(obj, ~, ~)
            % Validate the complete set at setup, allowing the block dialog
            % to update the three trajectory parameters independently.
            assert(numel(obj.PathX) >= 2);
            assert(numel(obj.PathX) == numel(obj.PathY));
            assert(numel(obj.PathX) == numel(obj.PathYaw));
            assert(all(isfinite(obj.PathX(:))) && all(isfinite(obj.PathY(:))));
            assert(all(isfinite(obj.PathYaw(:))));
            assert(numel(obj.AxleOffsets) == 4 && all(isfinite(obj.AxleOffsets(:))));
            assert(any(diff(obj.PathX(:)).^2 + diff(obj.PathY(:)).^2 > eps));
        end

        function [refPose, rearPose] = stepImpl(obj, currentPose, direction)
            c = cos(currentPose(3));
            s = sin(currentPose(3));
            rearPose = [currentPose(1) + c*obj.AxleOffsets(3) - s*obj.AxleOffsets(4), ...
                        currentPose(2) + s*obj.AxleOffsets(3) + c*obj.AxleOffsets(4), ...
                        currentPose(3)];
            qx = rearPose(1);
            qy = rearPose(2);
            if direction >= 0
                qx = currentPose(1) + c*obj.AxleOffsets(1) - s*obj.AxleOffsets(2);
                qy = currentPose(2) + s*obj.AxleOffsets(1) + c*obj.AxleOffsets(2);
            end

            bestDistance = inf;
            bestIndex = 1;
            bestFraction = 0;
            refPose = [obj.PathX(1), obj.PathY(1), obj.PathYaw(1)];
            for k = 1:numel(obj.PathX)-1
                dx = obj.PathX(k+1)-obj.PathX(k);
                dy = obj.PathY(k+1)-obj.PathY(k);
                lengthSquared = dx*dx + dy*dy;
                if lengthSquared > eps
                    fraction = min(1,max(0,((qx-obj.PathX(k))*dx + ...
                        (qy-obj.PathY(k))*dy)/lengthSquared));
                    px = obj.PathX(k)+fraction*dx;
                    py = obj.PathY(k)+fraction*dy;
                    distanceSquared = (qx-px)^2+(qy-py)^2;
                    if distanceSquared < bestDistance
                        bestDistance = distanceSquared;
                        bestIndex = k;
                        bestFraction = fraction;
                        refPose(1) = px;
                        refPose(2) = py;
                    end
                end
            end
            % Interpolate the sampled path tangent along its shortest angular
            % arc. This avoids a false turn at a +/-pi or 2*pi wrap boundary.
            delta = obj.PathYaw(bestIndex+1)-obj.PathYaw(bestIndex);
            heading = obj.PathYaw(bestIndex) + bestFraction*atan2(sin(delta),cos(delta));
            refPose(3) = atan2(sin(heading),cos(heading));
        end

        function [s1,s2] = getOutputSizeImpl(~)
            s1 = [1 3];
            s2 = [1 3];
        end

        function [t1,t2] = getOutputDataTypeImpl(~)
            t1 = 'double';
            t2 = 'double';
        end

        function [c1,c2] = isOutputComplexImpl(~)
            c1 = false;
            c2 = false;
        end

        function [f1,f2] = isOutputFixedSizeImpl(~)
            f1 = true;
            f2 = true;
        end

        function [n1,n2] = getOutputNamesImpl(~)
            n1 = 'LocalRefPose';
            n2 = 'RearAxlePose';
        end
    end
end
