# Shared preview data: archived Skidpad workspace log

The only preview dataset is `skidpad_workspace_2026-10-23.mat`, saved from the user's MATLAB workspace on 2026-10-23. It contains the full `logsout_sm_car` Dataset (22 elements), solver time vector `tout`, and provenance metadata. `save_workspace_preview.m` is the original export/verification helper; it refuses to overwrite the archive and does not create a compact second dataset.

The [plotting procedure](../../.agents/skills/vehicle-study-plotting/references/procedure.md#signals-metrics-and-previews) owns authorized loading, historical labeling, timestamps, exports and cleanup. This guide retains archive-specific paths and provenance; reading it does not authorize loading the dataset. Synthetic datasets and the former compact signal archive were removed.

For example, from the project root:

```matlab
preview = load(fullfile('SimulationStudies','preview_data', ...
    'skidpad_workspace_2026-10-23.mat'),'logsout_sm_car');
cg = preview.logsout_sm_car.get('VehBus').Values.Chassis.Body.CG;
time_s = double(cg.nYaw.Time(:));
yawRate_deg_s = double(cg.nYaw.Data(:))*180/pi;
```

Common paths below `VehBus.Values`:

| Signal | Path | Logged → display units |
| --- | --- | --- |
| Longitudinal velocity | `World.vx` | m/s → km/h |
| Yaw rate | `Chassis.Body.CG.nYaw` | rad/s → deg/s |
| Lateral acceleration | `Chassis.Body.CG.gy` | m/s² |
| Vehicle sideslip | `Chassis.Body.CG.aSideSlip` | rad → deg |

The four common traces have 261 native samples spanning 0–26.8654 s; solver `tout` spans 0–26.8895 s and is not their time axis.

At export, the workspace maneuver was Skidpad and the controller was Default; the model had unsaved changes. These are contextual observations, not proof of the logged run's exact configuration or stop reason. The archive was reloaded and verified when saved. It excludes the Simscape logging tree and unrelated workspace data.
