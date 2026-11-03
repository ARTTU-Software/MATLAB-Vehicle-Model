# Shared preview data: archived Skidpad workspace log

The only preview dataset is `skidpad_workspace_2026-10-23.mat`, saved from the user's MATLAB workspace on 2026-10-23. It contains the full `logsout_sm_car` Dataset (22 elements), solver time vector `tout`, and provenance metadata. `save_workspace_preview.m` is the original export/verification helper; it refuses to overwrite the archive and does not create a compact second dataset.

Load the archive and select the required signals directly in memory. Do not copy it into studies or save extracted preview signals as separate MAT/CSV datasets. Synthetic datasets and the former compact signal archive have been removed. Generated PNG/CSV layout previews are temporary study artifacts and are removed/replaced after successful completion. Real selected simulation results remain in their study's `results/` folder.

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

Use each signal's own timestamps; do not substitute solver `tout`. The four common traces have 261 samples spanning 0–26.8654 s; `tout` spans 0–26.8895 s. Validate units and dimensions when choosing signals. If a requested signal is absent, disclose the limitation and clarify the preview requirement rather than inventing data.

Label every preview:

> PREVIEW ONLY — historical Skidpad data, not this study's results.

Repeated curves demonstrate layout only; they cannot demonstrate controller or steering-angle differences. Preserve original samples unless a transformation is explicitly described. At export, the workspace maneuver was Skidpad and the controller was Default; the model had unsaved changes. These are contextual observations, not proof of the logged run's exact configuration or stop reason. The archive was reloaded and verified when saved. It excludes the Simscape logging tree and unrelated workspace data. Preserve this shared MAT file during cleanup.
