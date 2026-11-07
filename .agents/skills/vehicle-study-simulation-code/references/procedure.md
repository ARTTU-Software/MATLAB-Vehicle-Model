# Simulation code authoring procedure

**Input:** the accepted experiment, resolved model mappings, execution conventions and assigned files. **Output:** readable study functions and static-check evidence for packaging and independent review. This skill authors code; the coordinator executes stages.

## Implement the experiment

Use [lookup mappings](../../vehicle-model-lookup/SKILL.md) and the selected study's compatible implementation. Read [runner usage](../../../../SimulationStudies/runner/README.md) before adapting its API. Preserve existing function contracts and the reviewed scope/baseline guards.

Keep study_config, simulate_run, check_inputs and extract_signals responsibilities explicit. Packaging owns the editable-input record, fixed-case expansion or reviewed target policy, baseline and wrapper; [plotting](../../vehicle-study-plotting/SKILL.md) owns metrics/export code. Coordinate these interfaces through the one implementer rather than duplicate them.

For every case, use a stable ID and explicit input values/units from the expanded configuration. Validate supported names, shapes, ranges when known, combination lengths and required dependencies before simulation. Reject unsupported maneuvers/modes and malformed inputs with an actionable message; do not silently substitute example settings.

Save compact requested and effective input metadata with the case result/status through the existing supported interfaces. Readbacks must distinguish what the user requested from what initialization actually applied. Keep failure/status and extraction behavior compatible with [execution](../../vehicle-study-execution/SKILL.md) and [run verification](../../vehicle-study-run-verification/SKILL.md).

## Scenario and input handling

The top-level `sm_car` scenario hyperlinks are the source of truth. Execute their full command sequence in order, including tire selection and maneuver generation. Do not replace it with only `sm_car_config_maneuver`, or infer behavior solely from the Event directory.

For each run, restore the recorded baseline, execute required initialization and scenario setup, apply overrides at the correct dependency stage, recompute dependent data, and verify effective inputs before simulation. Overrides of scenario-generator inputs must be supplied before generation; overrides of values reset by scenario setup must be applied afterward. Check callbacks that may reset values during initialization. Keep explicit study changes distinguishable from hyperlink defaults.

| Input source | Required mapping and behavior |
| --- | --- |
| Excel-derived data | Trace workbook/sheet/field through the importer to the MATLAB structure; override temporarily and repeat relevant assembly/derived calculations |
| Parameter script | Identify the returned or assigned variable, active controller configuration, workspace scope, and derived values; override the effective value |
| Block or mask | Record full block path and actual parameter name, expression/value, units, and any mask initialization effects; apply temporarily |
| Simulation sequence | Use the project-specific maneuver generation/update sequence from the top-level hyperlink, with requested arguments; read back generated database fields and the selected maneuver; record changes and restoration method |

The user's term “simulation sequence” refers to project-specific maneuver sequences, not Simulink Test Sequence or Signal Editor blocks. For example, the Ramp Steer hyperlink generates `MDatabase.Ramp_Steer.FSAE_Achilles` before selecting the maneuver. Preserve that dependency. When a requested sequence edit has no corresponding update command in the current hyperlink, inspect the called project functions and clarify unsupported behavior before promising an implementation.

Use per-run input objects or temporary isolated configurations where supported. If a sequence or callback cannot be isolated with ordinary input overrides, prepare a study-local copy with correct dependencies. Do not overwrite original files or discard unsaved changes. Restore only study-owned changes after execution.


## Stop-request evidence

If the requested output includes a physical stop-cause label, prepare temporary logging of the actual gated stop requests in the isolated model copy before checkpoint review. Resolve the exact targets from the [shared stop-request mapping](../../../../SimulationStudies/MODEL_WORKSPACE.md#stop-requests-for-future-constant-steer-runs-saved-file-mapping-2026-10-25) and verify freshness for the selected saved model. Retain only final flag evidence/labels as small case metadata, including both when both are active. Do not persist unrelated diagnostic signals.

A normal ModelStop needs no human-facing physical-cause label by default. Use [run verification](../../vehicle-study-run-verification/references/procedure.md#completion-and-stop-evidence) for interpreting retained evidence. Missing historical flags stay missing; never retrofit evidence into completed results. Authoring instrumentation does not authorize loading, compiling or running the model during preparation.

## MATLAB readability

Keep simulation scripts MATLAB-only, concise and directly editable, including simulation logic. Prefer ordinary sections, explicit commands and a small run table; add generic adapters, configuration layers or retry machinery only when requested. Separate offline inventory tools may remain Python.

Use ordinary loops, descriptive variables and numbered MATLAB sections for preparation, scenario setup, temporary settings, simulation, extraction, metrics and cleanup. Keep the actual maneuver commands and requested signal paths visible in the simulation code. Small file-identity checks remain; do not replace the approved-stage or baseline controls merely to shorten scripts.

Document each function with MATLAB help comments describing its purpose, argument meanings/defaults/units, return value, side effects and a contextual call example. Keep execution stage names explicit (`prepare`, `validation`, `full`); do not use a boolean to imply simulation approval.


## Reuse and user-facing editing

Separate changing sweep data from simulation logic: the user edits study_inputs.json; for fixed sweeps the MATLAB reader expands it deterministically into cases. A future supported target search instead uses the reviewed policy and candidate interface; do not edit its frozen JSON between candidates. Avoid scattering sweep constants through scripts. Keep fixed project conventions in one appropriate function and document which fields the user is expected to change.

Reuse small existing functions for repeated operations, preserving explicit maneuver commands and signal paths. Reusable means usable for another supported parameter set without copying/editing the execution algorithm; it does not require a new framework. Keep paths portable and resolve them from the project/study location rather than the working directory or one user's home.

Provide concise help, a preparation-only example and separately labelled approved-stage examples. Explain supported inputs, units, outputs and errors in user terms. Never use an example approval string as actual authorization.

## Check and hand off

Perform only checks allowed by the current scope. For maintenance, use static inspection only. Preparation does not run startup, maneuver setup, model update/compile, simulations or pools. Static checks cannot establish effective runtime values; list those checks for approved short validation.

Return assigned file identities, implemented case/input contracts, checks performed, expected validation checks and unresolved limitations. Submit the complete checkpoint to [code review](../../vehicle-study-code-review/SKILL.md), then stop editing it until findings are returned. A correction to reviewed execution code follows the fresh-preparation and approval rules.
