# Balkans End GGV speed profile

Edit `CRG_Create_Balkans_End.m` to select the GGV MAT file, grip utilization
and optional maximum speed. The default file is
`GGV_Achilles_20260906_0012.mat`, utilization is `0.95`, and the existing
21 m/s request is capped at this file's measured maximum of 20 m/s.

`ggv_utilization` scales the combined longitudinal/lateral acceleration
envelope, not the speed. For example, on a constant-radius corner with a
speed-independent lateral limit, speed scales with the square root of this
factor. A value of 1 leaves no grip reserve and can make driver tracking
unreliable. The script warns at 1; values outside (0,1] are rejected.

With the vehicle project open, regenerate just the speed trajectories from
the existing CRG data (no road or source-spreadsheet regeneration):

```matlab
coeff = CRG_Create_Balkans_End;
sm_car_trajectory_calc('CRG_Balkans_end', coeff);
sm_car_trajectory_calc('CRG_Balkans_end_f', coeff);
sm_car_import_maneuver_data;
% Select/reselect the Balkans End maneuver before running the vehicle model.
```

Calling `CRG_Create_Balkans_End` without requesting an output retains the
existing full road-generation workflow and now generates GGV trajectories.

To inspect without saving files:

```matlab
coeff = CRG_Create_Balkans_End;
coeff.show_plots = false; % Default is true for GGV mode
[trajectory, report] = sm_car_trajectory_calc('CRG_Balkans_end_f', coeff);
```

The speed planner uses signed geometric curvature and cyclic acceleration
and braking passes. It retains all CRG trajectory samples and recalculates
distance after the existing closure blending. The exported path repeats its
first position/speed at the full lap distance, as required by the driver's
interpolation period. `vx.Value` retains its original column-vector format.

The MAT file keeps the original six top-level trajectory fields. `vx.GGV`
records the source file, utilization and estimated lap time. The maneuver
loaders recognize this metadata and use `vGain=1`; off-track recovery speed
is `min(4,min(vx.Value))`. Legacy files retain their old settings. After
regenerating files, reload/reselect the maneuver to replace cached data.

Each saved GGV trajectory also writes a `_ggv_report.mat` file with lap time,
curvature, speed limits, segment utilization bounds and sampled acceleration
demand. Plots show the profile and its demand over the measured GGV slices.
The diagnostic lap time includes the closing segment and integrates the
piecewise-linear speed lookup. It is a grip-limited estimate, not a promise
of the lap time the vehicle and driver will achieve.

GGV files must contain `GGV_data` with matching numeric vectors
`lat_acc_pts_g`, `lng_acc_pts_g`, `veh_spd_pts_mps`. Each speed slice must
surround the origin with matching angular directions across slices. Invalid
or missing selected data raises an error; there is no silent legacy fallback.
The implementation intersects normalized polygon edge constraints (a
conservative interior for concave sampled boundaries) and interpolates these
constraints between measured speeds. It does not inflate a convex hull.
Below the lowest measured speed, the lowest slice is held constant and its
use is reported. Above the maximum measured speed, speed is capped.

Segment validation conservatively bounds combined acceleration across the
whole linear speed/curvature interval, including speed-slice crossings.
This can give some extra reserve near rapid curvature changes. The result
is not a globally optimized lap-time solution. No motor/powertrain limit is
included. Elevation, when present in `dat.rz`, contributes tangential gravity
and a horizontal-speed correction; banking and vertical load changes at
crests/dips are not modeled. Actual Pure Pursuit tracking, its spatial
interpolation, tyre transients and longitudinal lag are outside this check.

The old shape/smoothing coefficients and `vmin` are ignored in GGV mode.
Set `speed_method='legacy'` to regenerate the original heuristic profile.
Other tracks without a speed-method setting continue using that method.

Tests:

```matlab
runtests(fullfile(fileparts(which('sm_car_ggv_speed_profile')), ...
    'tests', 'sm_car_ggv_speed_profileTest.m'))
```
