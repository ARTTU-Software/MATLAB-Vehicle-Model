# Model and workspace inventory

This is the shared model/workspace guide. Refresh this file and `inventory/saved/` in place as sources change; do not copy them into study folders. See [WORKFLOW.md](WORKFLOW.md#storage-and-retention) for final-study and failure-log retention.

Preview data uses only the shared `preview_data/skidpad_workspace_2026-10-23.mat` archive. Select the needed logged signals directly in memory; do not save separate preview signal datasets or study-local copies. See `preview_data/README.md`.

## Constant Steer replacement requested 2026-10-24

The user stopped the Ramp Steer full stage during its first case; no full
case completed. All six 1 s validations remain historical evidence. The batch
process exit was confirmed. Superseded attempt folders have since been removed.

The current Constant Steer hyperlink is exactly
`sm_car_config_maneuver('sm_car','turn');`. It selects
`MDatabase.Turn.FSAE_Achilles`, `IDatabase.Flat.FSAE_Achilles`, an Open Loop
driver and Plane Grid road. The selector's default StopTime is 40 s; the
replacement study retains the previously requested 19 s run limit.

Source `Libraries/Event/Scene/Plane_Grid/sm_car_maneuverdata_turn.m` defines:

- Steering times `[0,5,5.2,180,181,200]` s and angles `[0,0,30,30,0,0]` deg.
  Override only the two nonzero angles in the in-memory Turn database before
  calling the hyperlink; read back `Maneuver.Steer` afterward.
- Throttle times `[0,1,1.1,10,10.1,200]` s, pedal `[0,0,0.5,0.5,0,0]`.
- Brake times `[0,11,11.2,190,191,200]` s, pedal `[0,0,0.4,0.4,0,0]`.

The user explicitly chose native throttle/braking instead of retaining the
10 km/h speed target. Keep Default versus FLC_DYC_V3 at 20/30/40 degrees and
the same three CG signal comparisons and peak lateral-acceleration table.
The user clarified that any `ModelStop` is a normal completion, regardless
of condition, source or time. Record its source, description and actual
duration; do not restrict acceptance to zero speed or a specific block path.
The first D20 run ended at 15.107060115 s on `ModelStop`, with source `sm_car`
(the model root, rather than the physical Stop block). The user confirmed this
case stopped after the vehicle returned to zero speed. The old classifier
incorrectly rejected it. The continuation
`studies/2026-10-24_214028_994_constant-steer-default-vs-flc-dyc-v3/`
preserves its samples and reuses the passed short checks while correcting
completion metadata. Imported data hashes and the previous state are recorded;
the remaining five full cases finished sequentially. All six are completed
with `ModelStop`: D20 15.1071 s, F20 15.2589 s, D30 14.9514 s,
F30 15.0647 s, D40 9.87454 s, F40 14.2661 s. D40 ended before braking;
its specific stop condition is not identified by the generic stop description.
Three PNG comparisons and `tables/peak_lateral_acceleration.csv` were generated;
CSV peaks were checked against all six saved signal files. Manual stops,
diagnostic errors, timeouts and pauses remain incomplete. Unequal actual recording
windows must remain visible in the CSV. All six 1 s Constant Steer checks
passed; their status remains in the final study’s `state.mat`. Temporary validation signal/input files were removed after completion at the user’s request:
native timing/pedals, Open Loop driver, angles, controller/estimator selection
and all requested signal extractions were verified. Warning counts were
85,949 per Default case and 78,068 per V3 case. Full execution is completed;
MFEval warnings remain recorded and execution completion is not a physics-validity check.
Study implementation: `studies/2026-10-25_123418_016_constant-steer-default-vs-flc-dyc-v3/code/`. Shared templates: `runner/`.

## Saved V3 repair inspected 2026-10-24

The saved-file refresh changed only `sm_car.slx` among 521 indexed source
fingerprints; 150 unchanged model records were reused. Integrity verification
passed, with 3,998 blocks stored in `sm_car`. The top-level Ramp Steer hyperlink
still generates `(10,8,NaN,30,0.1,10,8)` before selecting `ramp steer`.

The old FLC V3 six-state estimator was replaced by
`sm_car/Controller/TrqVec_FLC_V3/Power Control/State Estimation`
(SID `4253:1493`), with the Default controller's five-state UKF and noise
subsystem. The UKF (SID `4253:1603`) has initial state `[0.4;0;0;0;0]`, state
covariance `diag([0.04,0.04,1e-3,0.1,0.1])`, variable process noise and four
measurement-noise values `[9e-4,7.29e-7,1.22e-4,1.22e-4]`. Downstream FLC
selection uses `v_x,a_x,a_y,phi_dot,v_y`, matching the five state names.

The user subsequently enabled the enclosing estimator manually and saved the
model. Saved-file inspection confirms the `Commented=through` override was
removed (the normal enabled state); initialization readback must verify
`Commented=off`. No study override of the estimator is needed. Runtime
validation is recorded in the fresh
`studies/2026-10-24_195807_004_ramp-steer-default-vs-flc-dyc-v3/` baseline.
All six cases (Default and FLC_DYC_V3 at 20, 30 and 40 degrees) reached 1 s
with requested signal extraction verified. V3 initialization confirmed `Commented=off` and
the repaired five-state/four-measurement settings. Warning counts were 60,135
and 191,464 respectively, including MFEval coefficient/load/low-speed warnings.
The full Ramp Steer comparison was stopped at the user's request; these short checks
do not test the steering ramp beginning at 10 s. Preserve the failed
2026-10-23 attempts as historical records.

## Controller comparison mappings verified 2026-10-23

Read-only inspection of the current MATLAB session found `logsout_sm_car`, with
261 samples in each requested signal spanning 0–26.8654 s (`tout` has 2602
solver samples spanning 0–26.8895 s). Current workspace maneuver is Skidpad,
current controller is Default, and `sm_car` is dirty and stopped. These current
settings are context, not proof of the logged run's provenance. Preserve this
session; use its data only to verify extraction for the new Ramp Steer study.

| Requested quantity | Verified logged leaf under `logsout_sm_car.get('VehBus').Values` | Logged unit | Display |
| --- | --- | --- | --- |
| Yaw rate | `Chassis.Body.CG.nYaw` | rad/s | deg/s |
| Lateral acceleration | `Chassis.Body.CG.gy` | m/s^2 | m/s^2 |
| Vehicle sideslip | `Chassis.Body.CG.aSideSlip` | rad | deg |

Units are `Simulink.SimulationData.Unit` objects: read their `Name` property.
Vehicle sideslip is already logged; do not substitute tire slip or derive it
from world-frame velocities. Tire slip is not requested for this comparison.

Controller target is mask parameter `sm_car/Controller:popup_control` with
values `Default` and `FLC_DYC_V3`. Its mask initialization selects the matching
`LabelModeActiveChoice`. Apply temporary SimulationInput overrides and read
back both selector and active label during initialization. Existing brake
selection is `Pedal`. Controller parameter import already loads FLC V3 data;
do not replace the unrelated `Control.TrqVec` field to select this variant.

Saved inventory refresh detected changes to `sm_car.slx`, `Custom_lib.slx` and
the Double Lane Change trajectory MAT file. The saved Ramp Steer hyperlink
still runs its generator before `sm_car_config_maneuver` with default arguments
`(10,8,NaN,30,0.1,10,8)`.

Runtime validation on 2026-10-23: Default/20 degrees completed to 1 s, with
generated steering times `[0,10,10.1,19]`, angles `[0,0,20,20]`, 10 km/h target,
and Default selector/active label verified. Three requested signal extractions
passed. The run recorded 51,249 warnings, including MFEval low-speed/load and
coefficient-limit warnings; execution success does not establish tire validity.

FLC_DYC_V3/20 degrees failed at compile in its UKF prediction block. The FLC
UKF instance has six initial states, 6x6 state/process covariance and six
measurement channels; shared `prediction_model.m` computes five state updates
and `measurement_model.m` returns four measurements. The first error is a
6x1 + 5x1 operation at `prediction_model.m:92`. This is a pre-existing saved
controller/function mismatch, not a Ramp Steer command-order error. Do not
trim/extend vectors or replace the estimator without resolving the intended
state and measurement definitions. The six-case full study has not started.

## Current saved-file inventory

An offline inventory was generated on 2026-10-22 from saved project files and referenced libraries under `/Applications/MATLAB_R2026b.app/toolbox`. MATLAB was not accessed; no startup, callbacks, model update or simulation was executed. Unsaved live state is outside this baseline.

- [Generated coverage and lookup guide](inventory/saved/README.md)
- [Manifest and limitations](inventory/saved/manifest.json)
- [Model/library catalog](inventory/saved/models.json)
- [Block and mask parameter index](inventory/saved/parameters.jsonl.gz)
- [Variable and small-value index](inventory/saved/variables.jsonl.gz)
- [Source-code mappings](inventory/saved/sources.json)
- [Workbook structure and import candidates](inventory/saved/workbooks.json)
- [Port and logging metadata](inventory/saved/signals.jsonl.gz)
- [Reference resolution](inventory/saved/dependencies.json)
- [Gaps and opaque records](inventory/saved/gaps.json)
- [Saved-file fingerprints](inventory/saved/fingerprints.json)
- [Inspector usage and scope](tools/README.md)

The initial completed export records 151 saved model/library files, 44,199 block definitions and 34,889 connection records. `sm_car.slx` itself contains 4,036 directly stored block records across 412 system XML members. Counts include all project alternatives and inspected library definitions, not the compiled/instantiated size of `sm_car`.

The variable index contains 14,805 records, including structural records and assignments; this is not a count of unique base-workspace variables. Small readable values up to 100 elements are retained. Stored expressions and source statements are not evaluated. Runtime initialization, variable scoping/resolution, active variants and signal availability remain unverified.

The scan indexes 317 source records and eight workbooks. Fifteen missing reference occurrences identify eight unavailable definitions in supporting models/libraries. The user chose to keep them marked missing. Opaque MATLAB objects, embedded serialization, dictionary contents and protected code remain explicit gaps. Read the manifest for current counts after a refresh; do not describe this offline coverage as full runtime verification.

## Historical live-session observations — separate baseline

The records below predate the saved-file inventory and are retained as historical context only. Do not combine their live values with saved-file results or treat them as authorization to access MATLAB.

Partial live refresh, 2026-10-22 10:53 Europe/Bucharest, during a preparation-only workflow rehearsal. No simulation, model update/compile, startup, or scenario setup was executed. This remains an incomplete inventory and must be completed for the selected saved-file baseline before execution according to [WORKFLOW.md](WORKFLOW.md).

### Live observations from the rehearsal

- MATLAB R2026b (26.2.0.3386108), MACA64, project `SSVT_FSAE`; `sm_car` loaded, stopped, with unsaved changes. Preserve that session.
- Live setup: `Maneuver.Type=Skidpad`, `Maneuver.Instance=FSAE_Achilles`, `Vehicle.config=Achilles_DWishbone`, tire class `MFEval`; `ode23t`, accelerator, StopTime 100 s. These observations do not verify the saved-file baseline requested for the Ramp Steer rehearsal.
- Base workspace contains scalar structures `Vehicle`, `Visual`, `Control`, `MDatabase`, `Maneuver`, `IDatabase`, `Init`, `DDatabase`, `Driver`, `CDatabase`, `Camera`, `Scene`; older output containers also exist and were not used as trial results. Variable classes/sizes/bytes are recorded in the study's `runtime_inspection.txt`.
- Model workspace query listed no variables and DataDictionary was empty. Structural search with `Simulink.match.allVariants`, masks inspected and library links not traversed, found 4,936 blocks. This is not a compiled active-variant inventory. References, linked-library internals, mask details and full dependencies still require completion.
- Live InitFcn: `sm_car_config_camera; Vehicle = sm_car_vehcfg_checkConfig(Vehicle); sm_car_check_tire_model(bdroot);`. PostLoadFcn configures vehicle and logging. Do not reopen or initialize the dirty model merely for discovery.
- Live and saved Ramp Steer hyperlinks agree with the exact two-command sequence below. Generator source statically constructs steering times `[0 10 10.1 19]` s and angles `[0 0 30 30]` deg for those arguments. The final argument's documented return-to-zero description differs from the implemented hold; no correction was made.
- Logging candidate for the selected output: `logsout_sm_car.get('VehBus').Values.World.vx`, scaled by 3.6 for signed km/h, pending unit/type/availability validation. Live SignalLoggingName is `logsout_sm_car`, ReturnWorkspaceOutputs is `off`; a future runner must explicitly capture outputs instead of relying on old base results.
- User selected saved files on disk, including saved local edits, for a future baseline. The live dirty model/workspace is not that baseline. Isolation and initialization code are not yet implemented or validated. Disk hashes cannot fingerprint unsaved live state.

Rehearsal plan and provenance: [2026-10-22 Ramp Steer workflow trial](studies/2026-10-22_ramp-steer-workflow-trial/study_plan.md). No execution approval was requested or granted.

Project-relative paths are used for portability. Live workspace values, active variants, mask parameters, dependency fingerprints, and runtime signal availability remain unverified. Project-specific maneuver sequence commands are sourced from the top-level hyperlinks; their runtime effects still need short validation for each study.

## Inventory lookup and maintenance

### WOT body-mass study discovery — 2026-10-25 (saved files only)

The shared inventory was refreshed and integrity verification passed: 151 model
records reused, 521 source fingerprints checked, 3,998 saved `sm_car` blocks.
No MATLAB startup, model initialization or simulation was performed.

- The saved Accel/Decel hyperlink sets
  `Vehicle.Chassis.Tire.class.Value = 'MFEval'`, then calls
  `sm_car_config_maneuver('sm_car','WOT Braking')`. The selector uses
  `MDatabase.WOT_Braking.FSAE_Achilles`, flat initial conditions, Open Loop
  driver, Plane Grid and a 40 s time limit.
- Startup calls `sm_car_import_maneuver_data`, which runs the
  `sm_car_maneuverdata_*.m` functions. Its WOT generator is
  `Libraries/Event/Scene/Plane_Grid/sm_car_maneuverdata_wot_braking.m`:
  throttle times `[0,1,1.2,6,6.2,200]` s and pedal
  `[0,0,0.7,0.7,0,0]`; brake times `[0,7,7.2,190,191,200]` s
  and pedal `[0,0,0.7,0.7,0,0]`; steering is zero. The separate
  `Libraries/Event/Maneuver_data_wot_braking.m` script has a different 100%
  profile, but is not selected by that importer. Resolve native versus true
  full-throttle scope with the user; runtime readback remains pending.
- Body mass is base-workspace `Vehicle.Chassis.Body.m.Value`, scalar kg,
  imported from `Scripts_Data/Data_Vehicle/sm_car_ARTTU_Chassis.xlsx`,
  sheet `Body`, cell `C14`: saved value 255.07 kg. `import_excel` maps the
  sheet/row into `Body.m.Value`; `sm_car_read_database` installs it under
  `Vehicle.Chassis`. Its assembly helpers do not derive body inertia from
  mass. The saved physical body mask
  `sm_car/Vehicle/Vehicle/Chassis/Body:chassis_mass` references
  `Chassis.Body.m.Value`. Proposed offsets yield 245.07 and 265.07 kg;
  nominal-case inclusion and inertia treatment await scope clarification.
  Apply after baseline initialization and scenario setup; verify workspace
  mass and physical mask resolution after model initialization. Changes are
  temporary and must not write the workbook.
- Default controller selector remains `sm_car/Controller:popup_control` and
  `LabelModeActiveChoice = Default`. The requested estimator bypass target is
  `sm_car/Controller/Default/State Estimation:Commented = through`, applied
  temporarily in the isolated simulation copy and checked after initialization.
- Requested output candidates under `VehBus.Values` are
  `Chassis.Body.CG.vx` (longitudinal CG velocity) and
  `Chassis.Body.CG.gx` (longitudinal acceleration). Actual availability, units,
  preview coverage and extraction still require verification in their proper
  stages. Do not substitute world-frame velocity silently.

The user subsequently confirmed three offsets `[-10,0,+10]` kg, body mass
only, fixed CG and inertia, and the 100% throttle phase **followed by native
braking from 7 s**. Keep the native throttle times and replace its pedal values
with `[0,0,1,1,0,0]`; native brake timing and 70% pedal remain unchanged.
Full runs have `StopTime=Inf` and finish at the model stop. The native low-speed
criterion is below 0.1 m/s after 5 s; later braking is expected to bring the
vehicle to rest. Do not impose another duration. Requested metrics are both
the maximum positive and most negative longitudinal G over the recorded run.
The shared historical Skidpad archive was inspected in a separate MATLAB
process without opening the project or model: CG `vx` is m/s and `gx` is
m/s^2, each with 261 samples from 0 to 26.8653795 s. These establish preview
coverage, not WOT runtime verification or execution approval.

The user revised validation coverage on 2026-10-25: one representative changed
case for numeric parameter sweeps; additional validation only for changes
requiring a different compiled model configuration. WOT validation selected
R003 (+10 kg), 1.3 s. The attempt in
`studies/2026-10-25_195833_409_wot-body-mass-sensitivity/` stopped in the
initialization guard before any simulation interval completed. Saved readback:
`Vehicle.Chassis.Body.m.Value=265.07`, but resolving the physical body's
`chassis_mass` expression `Chassis.Body.m.Value` returned 255.07. The parent
masks bind `Vehicle` and `Chassis=Vehicle.Chassis`; resolving this cached mask
workspace during InitFcn is not sufficient to establish the new workspace
mass has reached the body. Default, active Default label, `Commented=through`,
fixed sCG/J and requested pedals were read back correctly. Temporary project
copy cleanup completed; the failed transcript and small input readback remain.
The corrected preparation explicitly overrides the physical body's promoted
`chassis_mass` parameter through SimulationInput, as well as the workspace
mass, so its initialization readback does not rely on parent-mask refresh.
This correction still awaits a newly authorized validation attempt; do not
treat the failed initialization as a passed model-run check.

The user authorized the corrected attempt. In
`studies/2026-10-25_200820_637_wot-body-mass-sensitivity/`, only R003 (+10 kg)
was validated; it reached 1.3 s (`ReachedStopTime`) and the separate MATLAB
batch exited successfully. Workspace and promoted physical body mass both
read 265.07 kg, Default selector/active label and estimator `Commented=through`
were confirmed, and sCG/J stayed unchanged. Both requested CG leaves extracted
44 finite samples at native timestamps from 0 to 1.280948286 s (velocity km/h,
acceleration m/s^2). The simulation recorded 135,805 warnings, including MFEval
low-speed, vertical-load saturation and Ex coefficient-limit warnings; it used
the saved ode23t solver and accelerator mode. Elapsed simulation wall time was
141.92 s. This passes the representative model-run/input/extraction check,
not later throttle-release/braking dynamics, natural stopping or tire validity.
The compact state records `validation_passed`; validation readback/signals
remain for review. Temporary execution copies and the successful stage
transcript were removed. Full three-case execution still needs its separate
approval. Use the explicit physical-body `chassis_mass` override for this
study rather than relying on cached parent-mask resolution in InitFcn.

Full execution was authorized by the user's “run the study” instruction and
completed sequentially in that same corrected study. All three cases ended
with `ModelStop`: R001 245.07 kg at 9.853410901 s, R002 255.07 kg at
9.908899396 s, and R003 265.07 kg at 9.961521563 s. Each physical mass,
Default controller, estimator bypass and fixed CG/inertia was checked.
Neither the logged roll nor lateral-deviation stop request was active in any
case; no more specific stop cause was inferred. Recorded warning counts were
171,487 / 204,303 / 186,486; MFEval warnings remain a validity limitation.
Two light-mode overlays and the signed-G CSV/PNG table were exported and
checked against all three selected signal files. The CSV retains native
recording windows and actual stop times separately. Final exports are
`plots/cg_velocity.png`, `plots/longitudinal_acceleration.png` and
`tables/longitudinal_g_metrics.{csv,png}` under the corrected study.

After export verification, temporary project copies, historical previews,
validation signals and redundant full-run input files were removed. Their
effective inputs remain in selected-result metadata. The superseded
`2026-10-25_195833_409` attempt was removed after its small state/readback
history was retained in final `state.initialFailedValidation` and its failed
transcript was verified in final
`logs/initial_validation_failed_2026-10-25_195833_409.log`. Original model,
library and chassis workbook files were not changed by the study.

Before preparing each study, read this file first. Use the input index and recorded hierarchy/workspace/source mappings to find requested targets. Check the selected baseline/configuration and relevant fingerprints, refresh only changed or missing sections and their dependencies, and write the resolved mappings back here. Reuse unchanged sections; do not rediscover the entire model for each request. An absent or incomplete inventory needs initial completion, and a broadly invalidated inventory needs rebuilding.

For a Markdown-only workflow rehearsal, describe these checks without accessing MATLAB or the model. The partial observations above do not constitute a completed saved-file inventory.

### Searchable input index — initial entries, coverage incomplete

| Search names / aliases | Exact target or known mapping | Source / units | Order, readback and verification |
| --- | --- | --- | --- |
| Vehicle configuration, vehicle preset | Base workspace `Vehicle.config` | `Scripts_Data/Data_Vehicle/sm_car_read_database.m`; configuration selector | Import/assembly dependencies must be resolved for the selected baseline; observed live identity is not saved-baseline verification |
| Tire model, tire class | Base workspace `Vehicle.Chassis.Tire.class.Value` | Vehicle data/import mapping; tire class selector | Some scenario hyperlinks reset this field before maneuver setup; verify the selected scenario and effective class; full importer mapping/restoration pending |
| Body mass, chassis mass | Base workspace `Vehicle.Chassis.Body.m.Value` and physical body `sm_car/Vehicle/Vehicle/Chassis/Body:chassis_mass` | `sm_car_ARTTU_Chassis.xlsx` / Body / C14; scalar kg; saved nominal 255.07 | Change workspace after scenario setup and explicitly override physical mask through SimulationInput; do not rely on cached parent-mask resolution in InitFcn. Full WOT readbacks verified 245.07/255.07/265.07 kg on 2026-10-25; sCG/J fixed |
| Default state estimator bypass, comment through | `sm_car/Controller/Default/State Estimation:Commented` | `through` bypasses; `off` enables | Apply temporary SimulationInput block override after selecting Default; initialized readback and full WOT execution verified `through` on 2026-10-25 |
| Ramp Steer sequence, ramp maneuver | `MDatabase.Ramp_Steer.FSAE_Achilles`, then selected `Maneuver` | `sm_car_maneuverdata_ramp_steer`, followed by `sm_car_config_maneuver`; exact commands below | Generate before selecting the maneuver; generated field-level readback and restoration pending for the saved baseline |
| Ramp Steer target speed | Argument 1 of `sm_car_maneuverdata_ramp_steer`, generating `MDatabase.Ramp_Steer.FSAE_Achilles` | km/h; recorded hyperlink value 10 | Override before generation; complete generated-field mapping and verify effective value before execution |
| Ramp Steer time to target speed | Argument 2 of the same generator | seconds; recorded hyperlink value 8 | Override before generation; argument 3 selects distance instead when applicable; verify the generated sequence |
| Ramp Steer steering angle | Argument 4 of the same generator | degrees; recorded hyperlink value 30 | Override before generation; verify generated steering values and units |
| Ramp Steer steering rise time / start time / final duration | Arguments 5 / 6 / 7 of the same generator | seconds; recorded values 0.1 / 10 / 8 | Override before generation; final-duration documentation/implementation mismatch recorded above |
| Torque vectoring parameters, active controller parameters | Base workspace `Control.TrqVec`; individual parameter fields not yet indexed | `sm_car_import_control_param` and named parameter functions | Resolve the requested parameter's exact field, units, active variant, dependencies and effective-value readback before use |

Add each newly resolved input here with its full target and source mapping, applicable configuration, units, class/shape, verification status, override stage, dependencies, readback and restoration method. Expand the structural sections as required; this initial index does not claim to cover every possible input. Use the logging section below as the output lookup index.

## Project entry point records

| Source | Role observed in source files |
| --- | --- |
| `SSVT_FSAE.prj` | MATLAB project file |
| `sm_car.slx` | Main model; top-level annotations contain scenario hyperlinks |
| `Scripts_Data/startup_sm_car.m` | Clears workspace; loads vehicle, initialization, maneuver, driver, camera, scene, and control data; builds custom components; configures solver support; can open/configure the model |
| `Scripts_Data/Data_Vehicle/sm_car_read_database.m` | Finds `sm_car_ARTTU_*.xlsx`, imports data, sets vehicle configuration, and assembles derived fields |
| `Scripts_Data/Data_Vehicle/import_excel.m` | Excel importer; inspect exact mapping for each study input |
| `Scripts_Data/Data_Vehicle/sm_car_import_control_param.m` | Discovers `sm_car_controlparam_*.m` under Libraries and builds named control configurations |
| `Scripts_Data/Configure_Event/sm_car_config_maneuver.m` | Configures maneuver, driver, road, initial conditions, stopping checks, and other model settings |
| `Libraries/Event/` | Event initialization, maneuver and scene data/functions |
| `Libraries/Vehicle/Control/` | Controller implementations and parameter functions |
| `Scripts_Data/Plots/` | Existing signal extraction and plotting references |
| `Scripts_Data/GGV_Sweep/sm_car_sweep_ggv_pts.m` | Existing specialized GGV sweep; inspect model modifications and logging reduction before any reuse |

## Workspace structure inferred from startup

| Name | Purpose/source | Verification |
| --- | --- | --- |
| `Vehicle` | Imported/assembled vehicle data; includes `Chassis`, `Powertrain`, `Brakes`, and `config` | Source only; inspect runtime fields |
| `Visual` | Visualization settings from `sm_car_param_visual` | Source only |
| `IDatabase`, `Init` | Initial-state database and selected initial state | Source only |
| `MDatabase`, `Maneuver` | Maneuver database and selected maneuver | Source only |
| Driver database | Generated by `sm_car_gen_driver_database`; enumerate actual variable names | Not yet inspected |
| `CDatabase.Camera` | Camera frame database | Source only |
| `Scene` | Imported scene data | Source only |
| `Control`, `Control.TrqVec` | Imported control configurations and active torque-vectoring parameters | Source only; startup selects `Ideal_L1_R1_L2_R2_achilles` |
| `out.logsout_sm_car` | Logging container referenced by existing plotting code | Source only; no current output verified |

Startup uses `clear` and performs compilation/setup side effects. Do not rerun it blindly in a user's active workspace. The Excel importer also assembles derived parameters; a source value override may require dependent recalculation.

## Scenario hyperlinks observed in the saved model

Re-read the current top-level hyperlinks before use. These entries describe the saved model inspected on the date above; unsaved model changes could differ. Each preparation action precedes its maneuver call.

| UI label | Preparation | Maneuver argument to `sm_car_config_maneuver('sm_car', ...)` |
| --- | --- | --- |
| Accel/Decel | Set `Vehicle.Chassis.Tire.class.Value` to `MFEval` | `WOT Braking` |
| Constant Steer | No extra preparation in hyperlink | `turn` |
| Ramp Steer | Generate `MDatabase.Ramp_Steer.FSAE_Achilles` as shown below | `ramp steer` |
| Slalom | Set tire class to `MFEval` | `slalom` |
| DLC | Set tire class to `MFEval` | `double lane change` |
| Skidpad | Set tire class to `MFEval` | `Skidpad` |
| Balkans | Set tire class to `MFMbody` | `CRG Balkans` |
| Balkans Endurance | Set tire class to `MFEval` | `CRG Balkans End` |
| FSG | Set tire class to `MFMbody` | `CRG Germania` |

Ramp Steer preparation currently observed:

```matlab
MDatabase.Ramp_Steer.FSAE_Achilles = ...
    sm_car_maneuverdata_ramp_steer(10,8,NaN,30,0.1,10,8);
sm_car_config_maneuver('sm_car','ramp steer');
```

The user confirmed that “simulation sequence” means these project-specific maneuver sequences. Use generation/update commands from the current hyperlinks and inspect their arguments and output fields before changing sequence inputs. The Ramp Steer hyperlink is a concrete example; do not substitute a Test Sequence or Signal Editor API.

## Logging paths observed in plotting code

`Scripts_Data/Plots/sm_car_plot1speed.m` accesses `out.logsout_sm_car.get('VehBus').Values` and the following leaves:

- `World.vx`, `World.vy`: longitudinal/lateral velocity; the script multiplies by 3.6 for km/h display.
- `World.x`, `World.y`: position.
- `Chassis.SuspA1.Steer.xRack`, `Chassis.SuspA2.Steer.xRack`: steering rack position.

The plotting script accesses leaf `.Time` and `.Data`. Validate actual types, units, and availability during an approved trial. Other requested signals require inventory expansion. Do not save the entire `VehBus` when only a leaf is used.

## Runtime refresh checklist

- Record host OS, MATLAB release, inspection timestamp and loaded model state.
- Inventory hierarchy, references, variants, masks and relevant callbacks.
- Enumerate base/model workspace and dictionaries, parameter sources and dependencies.
- Resolve the maneuver sequence's hyperlink commands, generator arguments, target database/selected-maneuver fields and restoration method.
- Verify selected output paths and metadata, marking runtime-dependent entries pending until validation.
- Refresh the shared inventory in place and retain only small preparation-time source hashes in each study; do not copy the inventory.

## Stop requests for future Constant Steer runs (saved-file mapping, 2026-10-25)

The saved sm_car fingerprint was checked against the shared inventory before tracing Check connections. `Check/Product7` (SID 3837) gates the roll comparison with `Start Checking2`: `abs(Chassis.Body.CG.aRoll) > 0.4` and the configured start-check step. It contributes to `Check/Sum` input 1. `Check/Product1` (SID 2472) gates `Reference.latdev > lat_dev_threshold` with `Start Checking Lat Dev` and contributes to the same sum. Do not reinterpret this signed lateral comparison as an absolute-value check. Read the runtime gates rather than reimplementing their thresholds in post-processing.

The active runner temporarily logs those two final stop requests as `study_stop_roll` and `study_stop_lateral` in its isolated model copy, with no decimation. It labels only these two causes; other normal early endings need no classification. This wiring has saved-file verification only and awaits the next approved short runtime validation. Original study results do not contain these requests, so their specific causes must not be retrospectively inferred. The original model is not modified or saved by the refactor.

Study-specific implementation is retained in study folders, not duplicate runner folders. Read retained study code, plans and known issues together with this guide before adapting future studies; check current mappings rather than assuming historical runtime settings are still effective.
