# constant-steer-default-vs-flc-dyc-v3

Prepared 2026-10-24_214028_994 (Europe/Bucharest), MACA64.

6 Constant Steer run(s), sequential execution. Saved-file baseline.

User explicitly waived previews and the separate validation approval.
User approved automatic full comparison after short validation passes.
User stopped Ramp Steer and requested the same comparison using Constant Steer, then explicitly selected native throttle/braking.
Validation: at most 1 simulated seconds per configuration. Full runs: 19 s limit, or any model-triggered stop condition.

Exact hyperlink: sm_car_config_maneuver('sm_car','turn'); replace only the nonzero steering values in MDatabase.Turn.FSAE_Achilles beforehand.
Native steering starts at 5 s and reaches the selected angle at 5.2 s; throttle starts at 1 s and is released at 10 s; braking starts at 11 s. No 10 km/h speed target.
User clarified that any ModelStop is a normal completion, regardless of condition, source or time. Retain its reason and actual stop time. Manual stops, errors, timeouts and pauses remain incomplete. Compare actual recorded windows in the CSV.

The short check verifies generated inputs and early logging. It does not test the later steering response.

## Explicit run list

```text
     <strong>ID</strong>       <strong>Controller</strong>     <strong>Steer_deg</strong>            <strong>Label</strong>                     <strong>InputProfile</strong>             <strong>Stop_s</strong>
    <strong>_____</strong>    <strong>____________</strong>    <strong>_________</strong>    <strong>_____________________</strong>    <strong>______________________________</strong>    <strong>______</strong>

    "D20"    "Default"          20        "Default | 20 deg"       "Native Turn throttle/braking"      19  
    "F20"    "FLC_DYC_V3"       20        "FLC_DYC_V3 | 20 deg"    "Native Turn throttle/braking"      19  
    "D30"    "Default"          30        "Default | 30 deg"       "Native Turn throttle/braking"      19  
    "F30"    "FLC_DYC_V3"       30        "FLC_DYC_V3 | 30 deg"    "Native Turn throttle/braking"      19  
    "D40"    "Default"          40        "Default | 40 deg"       "Native Turn throttle/braking"      19  
    "F40"    "FLC_DYC_V3"       40        "FLC_DYC_V3 | 40 deg"    "Native Turn throttle/braking"      19  


```

Review `code/simulate_run.m` for exact scenario commands, overrides and signal extraction.

Outputs from VehBus.Chassis.Body.CG: nYaw (rad/s to deg/s), gy (m/s^2), aSideSlip (rad to deg). Native time samples.
Peak table: signed min/max and maximum absolute lateral acceleration, signed value/time at that peak, full recorded interval. g uses 9.80665 m/s^2.
Controller mask: sm_car/Controller popup_control = Default or FLC_DYC_V3; verify active label after initialization.
Baseline includes the user-repaired five-state V3 UKF and input noises. Verify that its State Estimation subsystem is enabled; make no estimator overrides.
Archived Skidpad data and Ramp Steer validations are excluded from this six-case comparison.
Keep selected MAT logs, PNG overlays, CSV metrics. No ranking or narrative report.

Shared model/workspace guide: [MODEL_WORKSPACE.md](../../MODEL_WORKSPACE.md). Shared saved-file inventory: `../../inventory/saved/`. These are maintained in place, without study copies. See final state and selected run metadata for the completed runtime checks.

## Reviewed continuation

Source: /Users/andrei/Desktop/FSAE/Vehicle Model/Vehicle_Model/SimulationStudies/studies/2026-10-24_203954_775_constant-steer-default-vs-flc-dyc-v3

Saved baseline, run configuration, simulation setup and signal extraction match. Reuse all six passed short checks and D20 at 15.1071 s. Only stop classification was corrected; no simulated samples changed. The remaining five cases will run. Previous state and imported file hashes are retained.

## Completed-study storage (2026-10-25)

All six full cases completed. Only this final study folder is retained. The duplicate inventory and model/workspace guide have been removed; use the shared locations above. Console transcripts are retained only for failures under `logs/`, so this successful study has no such folder. No simulation was rerun for this cleanup.

`code/` preserves the original execution snapshot; its historical inventory-copy references describe the old layout. For a new study use the updated templates in `../../runner/` together with the newer study’s scenario-specific code. The reviewed scope in `state.mat` records the original preparation, before storage cleanup; do not reuse that scope as a new execution approval. Final selected data, plots, tables and execution code were verified unchanged. `baseline.zip` and `baseline_files.csv` preserve the saved source baseline; `previous_state.mat` and `reused_files.csv` record the reused validation and D20 provenance.

Validation signal and input-readback files were removed after completion at the user’s request. The outcome remains recorded in `state.mat`; validation paths/hashes in continuation records are historical provenance, not retained artifacts.

`study_inputs.json` was added after completion as an editable record of this study’s input choices. The historical execution used the preserved MATLAB configuration (D20/F20/D30/F30/D40/F40); new JSON preparations generate their own IDs. To change inputs, ask the agent to prepare a new study from this JSON. Existing results, state and execution code remain unchanged.

A root-level `rerun_study.m` wrapper was added after completion. Calling it without arguments prepares a new study from this JSON using the current maintained runner and current saved project; it does not reuse this archived baseline or alter completed results. New stage approvals remain required.

On 2026-10-25, the study’s plotting code was updated only to force a light figure theme and white PNG background. All three PNGs were regenerated from saved selected results, with no simulation. The MAT results, original metric CSV and state files were verified byte-for-byte unchanged. The archived execution scope remains historical; this styling change does not authorize another run.

Storage refactor (2026-10-25): `runner/` now contains shared templates only. Study-specific functions live in retained study code. The legacy wrapper explicitly borrows the newer compatible implementation when preparing from its JSON; stage execution still uses the prepared study’s own reviewed snapshots. No simulation was started by this change.
