# constant-steer-default-vs-flc-dyc-v3

Prepared 2026-10-25_123418_016 (Europe/Bucharest), MACA64.
Inputs: `study_inputs.json`; every angle is combined with every controller.
Execution: sequential, using isolated copies of the saved baseline.

## Review and approvals
Show historical Skidpad previews and obtain approval for short validation.
Validation is 1 s per case: check applied inputs and early logging only.
It does not test the later steering response.
Present validation findings and obtain a separate approval for the full study.
An exception requires an explicit waiver for this new request.

## Run list
| ID | Controller | Steering wheel (deg) | Full time limit (s) |
| --- | --- | --- | --- |
| R001 | Default | 20 | 19 |
| R002 | FLC_DYC_V3 | 20 | 19 |
| R003 | Default | 30 | 19 |
| R004 | FLC_DYC_V3 | 30 | 19 |
| R005 | Default | 40 | 19 |
| R006 | FLC_DYC_V3 | 40 | 19 |

## Maneuver and temporary changes
Change only the nonzero angles in `MDatabase.Turn.FSAE_Achilles`.
Then run the full hyperlink: `sm_car_config_maneuver('sm_car','turn');`.
Keep native throttle/braking: steer 5-5.2 s, throttle release 10-10.1 s, brake 11-11.2 s.
Select the requested controller temporarily; verify its active choice after initialization.
For V3, verify the saved estimator is enabled; do not override its UKF settings.
Any ModelStop is completed. Only label excessive roll or lateral-deviation stop flags.
Other normal early endings need no reason label; retain their actual stop time.
Errors, manual stops, timeouts and pauses remain incomplete.

## Outputs
Use VehBus.Chassis.Body.CG: nYaw (rad/s to deg/s), gy (m/s^2), aSideSlip (rad to deg).
Save selected MAT signals with native timestamps, three PNG comparisons and a CSV peak table.
Extrema use the full recorded interval; peak magnitude in g uses 9.80665 m/s^2.
Compare actual recording windows. Do not rank configurations or create a narrative report.
Keep JSON, code, state and baseline provenance. Remove validation data after full export.
Shared inventory: `../../inventory/saved/`; shared guide: `../../MODEL_WORKSPACE.md`.
Missing saved definitions remain explicit; runtime availability awaits validation.

Storage refactor (2026-10-25): `runner/` now contains shared templates only. Study-specific functions live in retained study code. The legacy wrapper explicitly borrows the newer compatible implementation when preparing from its JSON; stage execution still uses the prepared study’s own reviewed snapshots. No simulation was started by this change.
