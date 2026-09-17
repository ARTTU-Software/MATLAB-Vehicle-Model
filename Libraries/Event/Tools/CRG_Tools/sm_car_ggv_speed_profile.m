function [vx, report] = sm_car_ggv_speed_profile(xyz, GGV_data, options)
%SM_CAR_GGV_SPEED_PROFILE Grip-limited speed along a closed, sampled path.
% [vx,report] = sm_car_ggv_speed_profile(xyz,GGV_data,options)
% xyz is N-by-3 in metres, WITHOUT a duplicate closing point. options has
% ggv_utilization in (0,1] and vmax in m/s. GGV acceleration fields are in g.
% The model is quasi-steady, unbanked, with gravity along each road segment.
% It does not include propulsion, tyre transients or driver tracking error.
% Signed curvature uses the circumcircle through three adjacent samples.
% The speed lookup is assumed linear in distance. Segment bounds cover its
% entire interval (including the closing segment), not just sample points.

validateattributes(xyz,{'double'},{'2d','ncols',3,'finite','real'});
if size(xyz,1)<4
    error('sm_car_ggv:InvalidPath','At least four distinct path points are required.');
end
validateattributes(options.ggv_utilization,{'numeric'},...
    {'scalar','real','finite','positive','<=',1});
validateattributes(options.vmax,{'numeric'},{'scalar','real','finite','positive'});
eta = options.ggv_utilization;
if eta == 1
    warning('sm_car_ggv:AtGripLimit',...
        ['GGV utilization is 1: no grip reserve remains. The driver may be ' ...
        'unreliable at the grip limit; use a factor below 1.']);
end
env = prepareEnvelope(GGV_data);
speedMax = min(options.vmax,env.speed(end));
if options.vmax > env.speed(end)
    warning('sm_car_ggv:SpeedCapped',...
        'Requested vmax %.3g m/s is capped at GGV coverage %.3g m/s.',...
        options.vmax,env.speed(end));
end
n = size(xyz,1);
next = [2:n 1];
prev = [n 1:n-1];
edge = xyz(next,:)-xyz;
ds = vecnorm(edge,2,2);
planarDs = vecnorm(edge(:,1:2),2,2);
if any(ds<1e-6) || any(planarDs<1e-6)
    error('sm_car_ggv:InvalidPath',...
        'Path contains duplicate points or a vertical segment, including at closure.');
end
incoming = xyz(:,1:2)-xyz(prev,1:2);
outgoing = edge(:,1:2);
chord = vecnorm(incoming+outgoing,2,2);
if any(chord<1e-6)
    error('sm_car_ggv:InvalidPath','Path contains a reversing cusp.');
end
kappaXY = 2*(incoming(:,1).*outgoing(:,2)-incoming(:,2).*outgoing(:,1)) ...
    ./ (planarDs(prev).*planarDs.*chord);
% Horizontal turning acceleration for speed measured along the 3-D path.
horizontalFraction = (planarDs(prev)+planarDs)./(ds(prev)+ds);
kappa = kappaXY.*horizontalFraction.^2;
gradeAccel = 9.81*edge(:,3)./ds;
kMin = min([zeros(n,1) kappa kappa(next)],[],2);
kMax = max([zeros(n,1) kappa kappa(next)],[],2);

% First connected feasible interval from rest. Checking each speed slice
% also avoids assuming downforce-dependent speed feasibility is monotone.
speedGrid = unique([linspace(0,speedMax,201) env.speed(env.speed<speedMax)']);
segmentCap = zeros(n,1);
for i = 1:n
    values = arrayfun(@(v) segmentUtil(v,v,i),speedGrid);
    firstBad = find(values>eta,1);
    if isempty(firstBad)
        segmentCap(i) = speedMax;
    elseif firstBad == 1
        error('sm_car_ggv:InfeasibleGrade',...
            'GGV reserve cannot support the grade on segment %d.',i);
    else
        lo = speedGrid(firstBad-1); hi = speedGrid(firstBad);
        for j = 1:32
            mid = (lo+hi)/2;
            if segmentUtil(mid,mid,i)<=eta, lo=mid; else, hi=mid; end
        end
        segmentCap(i) = lo;
    end
end
cornerCap = min(segmentCap,segmentCap(prev));
v = cornerCap;
converged = false;
for iteration = 1:200
    old = v;
    % Forward: acceleration out of each corner.
    for i = 1:n
        j = next(i);
        if v(j)>v(i) && segmentUtil(v(i),v(j),i)>eta
            lo=v(i); hi=v(j);
            for b = 1:32
                mid=(lo+hi)/2;
                if segmentUtil(v(i),mid,i)<=eta, lo=mid; else, hi=mid; end
            end
            v(j)=lo;
        end
    end
    % Backward: brake early enough to arrive at the next corner's speed.
    for i = n:-1:1
        j = next(i);
        if v(i)>v(j) && segmentUtil(v(i),v(j),i)>eta
            lo=v(j); hi=v(i);
            for b = 1:32
                mid=(lo+hi)/2;
                if segmentUtil(mid,v(j),i)<=eta, lo=mid; else, hi=mid; end
            end
            v(i)=lo;
        end
    end
    if max(abs(v-old))<1e-7
        converged = true;
        break
    end
end
if ~converged
    error('sm_car_ggv:NoConvergence','Closed-lap forward/backward passes did not converge.');
end
util = arrayfun(@(i) segmentUtil(v(i),v(next(i)),i),(1:n)');
if any(util>eta+1e-6) || any(v<1e-4)
    error('sm_car_ggv:InfeasibleProfile',...
        'Final profile is stalled or violates the selected combined GGV envelope.');
end
% Exact travel time of a piecewise-linear speed-versus-distance lookup.
dv = v(next)-v;
dt = ds./v;
changing = abs(dv)>1e-8;
dt(changing) = ds(changing).*log(v(next(changing))./v(changing))./dv(changing);
report.method = 'ggv';
report.utilization = eta;
report.speed_cap_mps = speedMax;
report.ggv_speed_range_mps = [env.speed(1) env.speed(end)];
report.low_speed_policy = 'Hold the lowest measured envelope below its speed; no high-speed extrapolation.';
report.used_low_speed_extension = any(v<env.speed(1));
report.distance_m = [0;cumsum(ds(1:end-1))];
report.lap_length_m = sum(ds);
report.lap_time_s = sum(dt);
report.curvature_1pm = kappa;
report.corner_speed_mps = cornerCap;
report.segment_utilization_bound = util;
report.max_utilization_bound = max(util);
report.iterations = iteration;
report.assumptions = ['Grip only; no powertrain limit. Unbanked quasi-steady road; ' ...
    'no vertical load correction from crests, dips or grade. Piecewise-linear ' ...
    'speed and curvature. Conservative segment bounds and polygon edge halfspaces.'];
% Dense actual demand for plotting and independent sampled validation.
f = linspace(0,1,11);
speed = v + dv.*f;
ax = speed.*(dv./ds)+gradeAccel;
ay = (kappa+(kappa(next)-kappa).*f).*speed.^2;
report.demand_speed_mps = speed(:);
report.demand_ax_mps2 = ax(:);
report.demand_ay_mps2 = ay(:);
vx = v';

    function utilization = segmentUtil(v0,v1,index)
        % Bound all combinations of longitudinal/lateral demand in a segment.
        % Normalized polygon facets are linear between GGV speed slices, so
        % their extrema for this bounding box occur at endpoints or knots.
        low=min(v0,v1); high=max(v0,v1);
        knots=env.speed(env.speed>low & env.speed<high);
        speeds=[low;high;knots];
        [A,B]=facetAtSpeed(env,speeds);
        accel=[v0 v1]*(v1-v0)/ds(index)+gradeAccel(index);
        axLow=min(accel); axHigh=max(accel);
        ayLow=kMin(index)*high^2; ayHigh=kMax(index)*high^2;
        bound=max(A*axLow,A*axHigh)+max(B*ayLow,B*ayHigh);
        utilization=max(bound,[],'all');
    end
end

function env = prepareEnvelope(data)
required = {'lat_acc_pts_g','lng_acc_pts_g','veh_spd_pts_mps'};
for i=1:numel(required)
    if ~isfield(data,required{i})
        error('sm_car_ggv:InvalidData','GGV_data is missing %s.',required{i});
    end
    validateattributes(data.(required{i}),{'numeric'},{'vector','real','finite','nonempty'});
end
ax=double(data.lng_acc_pts_g(:))*9.81;
ay=double(data.lat_acc_pts_g(:))*9.81;
speed=double(data.veh_spd_pts_mps(:));
if numel(ax)~=numel(ay) || numel(ax)~=numel(speed) || any(speed<0)
    error('sm_car_ggv:InvalidData','GGV point arrays must match and speeds must be nonnegative.');
end
env.speed=unique(speed);
if numel(env.speed)<2 || env.speed(end)<=0
    error('sm_car_ggv:InvalidData','Provide at least two distinct GGV speed slices.');
end
angles=[];
for i=1:numel(env.speed)
    points=[ax(speed==env.speed(i)) ay(speed==env.speed(i))];
    [theta,order]=sort(mod(atan2(points(:,2),points(:,1)),2*pi));
    points=points(order,:);
    % Accept an optional duplicate closing vertex from external exports.
    keep=[true;diff(theta)>1e-8];
    if any(~keep)
        if any(vecnorm(points(~keep,:)-points(find(~keep)-1,:),2,2)>1e-6)
            error('sm_car_ggv:InvalidData','Repeated angles have conflicting GGV limits.');
        end
        points=points(keep,:); theta=theta(keep);
    end
    if size(points,1)<4 || max(diff([theta;theta(1)+2*pi]))>=pi
        error('sm_car_ggv:InvalidData','Each speed slice must surround the origin in all four quadrants.');
    end
    if i==1
        angles=theta;
        env.A=zeros(numel(env.speed),numel(theta)); env.B=env.A;
    elseif numel(theta)~=numel(angles) || any(abs(theta-angles)>1e-6)
        error('sm_car_ggv:InvalidData','GGV speed slices must use matching acceleration directions.');
    end
    nextPoints=points([2:end 1],:);
    edge=nextPoints-points;
    normal=[edge(:,2) -edge(:,1)];
    rhs=sum(normal.*points,2);
    if any(rhs<=1e-10)
        error('sm_car_ggv:InvalidData','GGV boundary must have nonzero grip and surround the origin.');
    end
    % Intersection, not convex hull: never expand a concave sampled polygon.
    env.A(i,:)=normal(:,1)./rhs;
    env.B(i,:)=normal(:,2)./rhs;
end
end

function [A,B] = facetAtSpeed(env,speed)
speed=max(env.speed(1),min(env.speed(end),speed));
% Small fixed tables: explicit interpolation avoids interp1 setup per query.
index=sum(speed>=env.speed',2);
index=min(index,numel(env.speed)-1);
t=(speed-env.speed(index))./(env.speed(index+1)-env.speed(index));
A=env.A(index,:)+(env.A(index+1,:)-env.A(index,:)).*t;
B=env.B(index,:)+(env.B(index+1,:)-env.B(index,:)).*t;
end
