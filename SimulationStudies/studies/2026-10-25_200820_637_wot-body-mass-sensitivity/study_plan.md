# WOT body-mass sensitivity

Prepared 2026-10-25_200820_637 (Europe/Bucharest), MACA64.

## Confirmed scope
Sequential macOS execution from isolated saved-file baselines.
Default controller; temporarily comment through `sm_car/Controller/Default/State Estimation`.
Change only body mass; preserve body CG and inertia. Nominal saved body mass: 255.07 kg.
User confirmed: 100% throttle phase, then native braking from 7 s.
No full-run time limit: StopTime=Inf; actual model stop determines completion.

## Expanded full cases
| ID | Body mass (kg) | Offset (kg) | Controller |
| --- | --- | --- | --- |
| R001 | 245.07 | -10 | Default |
| R002 | 255.07 | +0 | Default |
| R003 | 265.07 | +10 | Default |

## Maneuver and temporary changes
Run the complete saved hyperlink in order: set tire class to MFEval, then
`sm_car_config_maneuver('sm_car','WOT Braking')`.
Change selected Maneuver.Accel.rPedal.Value to [0,0,1,1,0,0].
Throttle times [0,1,1.2,6,6.2,200] s; zero steering.
Keep brake times [0,7,7.2,190,191,200] s and pedal [0,0,0.7,0.7,0,0].
Set Vehicle.Chassis.Body.m.Value after baseline and maneuver setup.
Also override the physical body mask chassis_mass explicitly for the run.
This avoids relying on parent mask workspace refresh during InitFcn.
Mass source: sm_car_ARTTU_Chassis.xlsx / Body / C14; never edit workbook.
Verify effective mass through physical body mask chassis_mass, controller/active label,
Commented=through, unchanged sCG/J and exact pedal data after initialization.
Native low-speed stop: below 0.1 m/s after 5 s, expected after braking.
Other model stops remain active. Any ModelStop is completed at its actual time.
Label roll/lateral-deviation causes only from actual logged gated requests.
Errors, interruptions, timeouts and pauses are incomplete; fail fast with no automatic retry.

## Outputs and preview layout
VehBus.Values.Chassis.Body.CG.vx: m/s to km/h; gx: m/s^2.
Two light-mode PNG overlays, native timestamps, one trace per mass.
Signed-G metric CSV and PNG table: mass, offset, positive maximum, most negative minimum,
peak times, actual stop time and recorded interval; g = gx/9.80665.
Use all valid recorded samples, without filtering or resampling; NaN for an absent sign.
Expose unequal run windows; no ranking or narrative report. Save only these two signal leaves
and compact execution/input metadata in MAT files.
Previews load the shared Skidpad archive directly in memory, repeat actual traces for layout,
and explicitly say PREVIEW ONLY - historical Skidpad data, not WOT results.
Remove only the four study-owned previews after successful verified real exports.

## Validation and approval gates
Short validation: one additional 1.3 s run, R003 (265.07 kg, +10 kg).
All masses share one compiled model configuration; scalar mass changes need no separate validation.
This extends 0.1 s beyond the full-throttle ramp and checks the representative effective mass,
the bypass, stopping parameters, profiles and requested signal extraction.
It does not validate the later throttle release, braking dynamics or natural stop.
Review these previews/plan and obtain explicit validation approval first.
Present validation findings, then obtain separate full execution approval.
Approval records are retained in state.mat at stage execution; none carried from older studies.
Full execution has no time limit or runtime guarantee.
Known historical MFEval low-speed/load/coefficient warnings may recur.
Successful execution does not by itself establish tire-model validity.

## Baseline and retention
Current saved files, including saved local changes, are the baseline.
Preserve the live MATLAB session and unsaved work; stages use separate batch processes.
Shared inventory: ../../inventory/saved; mappings: ../../MODEL_WORKSPACE.md.
Prior 2026-10-25_195833_409 attempt stopped in InitFcn: workspace mass 265.07 kg,
body-mask resolution 255.07 kg. No simulation interval completed. Its failed log and
input readback remain in that study. This fresh attempt uses an explicit physical mass override.
Keep baseline.zip, hashes, local code/JSON/wrapper, compact state and selected results.
Remove temporary project copies; retain failed-stage transcripts only.
Clean validation data after successful full exports.
