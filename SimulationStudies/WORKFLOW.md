# Simulation study workflow

## Entry point and scope

Use the project [vehicle-model-studies skill](../.agents/skills/vehicle-model-studies/SKILL.md) to select the requested mode and relevant references. This document is the maintained detailed procedure; `MODEL_WORKSPACE.md` holds model mappings, provenance and historical observations. Keep one maintained copy of each.

A documentation-only rehearsal reads Markdown and explains future checks without accessing MATLAB or model/data files, refreshing inventory, generating previews, creating study folders or editing project files. Workflow maintenance permits the requested documentation/code edits and static checks, without preparing or executing a study. For analysis of existing results, use the selected study's recorded configuration and actual signals; do not prepare a new study, alter completed signals/state, or treat a current-model inventory refresh as necessary merely to replot historical data.

Actual preparation may use MATLAB only for saved-file processing and historical previews. It does not authorize project startup, maneuver execution, model update/compile or simulation. Examples and stage commands in these documents are instructions for the appropriate authorized stage, not permission to execute them when reading the workflow. No background automation is created by the skill or these documents.

## Purpose and implementation status

Translate a user's requested inputs, scenarios, and outputs into a reproducible simulation study. The user evaluates plots and metric tables. Optimization and ranking are outside the default scope.

The saved-file inventory generator is implemented in `tools/inspect_saved_project.py`; usage and limits are documented in `tools/README.md`. It reads saved files without accessing MATLAB. Shared preparation/execution templates under `runner/` and study-specific MATLAB implementations under `studies/<name>/code/` form the simulation workflow. Do not keep per-study implementation folders in `runner/`. See `runner/README.md` for editing guidance and approval gates. Both Ramp Steer and native Constant Steer controller comparisons passed preparation and 1 s validation for Default and the user-repaired FLC_DYC_V3 at 20, 30 and 40 degrees on 2026-10-24. The user stopped Ramp Steer and chose native throttle/braking for Constant Steer; its full-study results are tracked in the dated study folder. The parent example's full workflow and broader scenarios/Windows parallel execution still require validation or implementation.

Keep simulation scripts MATLAB-only, concise and directly editable by the user, including the simulation logic itself. Prefer ordinary MATLAB sections, explicit commands and a small run table. Avoid adding generic adapters, extra configuration layers or retry machinery unless requested. Inventory tools are separate from simulation scripts and may remain Python.

All paths in this document are relative to the project root. Use portable paths so the same project can be used on macOS and Windows.

## Confirmed preferences

| Item | Rule |
| --- | --- |
| Start | Show the plan and dummy previews; obtain approval for short validation, then a second approval for the full study |
| Source changes | Temporary overrides; modify original files only when explicitly requested |
| macOS | Sequential execution only, even if parallel facilities are installed |
| Windows | Study input must explicitly specify sequential or parallel execution |
| Run count | Derive from the requested values, scenarios, and combination rule; a separate maximum is optional |
| Discovery | Refresh a reusable model/workspace inventory before running the study |
| Inputs | Block/mask parameters, workspace variables, and simulation sequences, including values originating in spreadsheets or scripts |
| Sequence changes | Project-specific maneuver sequences: use generation/update commands in the top-level model hyperlinks |
| Preview | Use the shared historical Skidpad dataset to show the requested plot/table layout before approval |
| Results | New folder containing study name and date; selected signal logs, PNG plots, and metric tables |
| Tables | CSV metric tables; PNG previews of their layout |
| Preview cleanup | After successful completion, delete dummy PNG previews and replace/remove dummy CSV previews; keep final plots and tables |
| Reports | Narrative reports only on request |

These defaults are confirmed. Resolve experiment-specific inputs, signals, time windows, and ambiguous combinations when a study is requested; no sample experiment is implied by this document.

## Study preparation

1. Read the user's request and existing decisions. Ask only about material ambiguities that cannot be resolved from the project or prior instructions.
2. Identify the actual execution host and operating system. macOS uses sequential execution. On Windows, ask for the execution mode if missing. Verify toolbox/license availability and worker initialization before proposing parallel execution. For any other OS, resolve the execution policy with the user.
3. Read the previously saved model/workspace structure and configuration inventory in `MODEL_WORKSPACE.md` before searching the model. Check its baseline identity, coverage and freshness; update changed or missing sections and their dependencies, then reuse the unchanged records. Create the initial complete inventory if it is absent or incomplete; do not repeat a full model inspection for each study. Preserve unsaved user work; do not blindly rerun startup or close loaded models. For a Markdown-only rehearsal, state this check in the plan without accessing MATLAB or the model.
4. Look up each requested input in the inventory's searchable input index and resolve its exact target, units, value list, initialization order, and dependent calculations. For a missing or ambiguous mapping, inspect only the relevant scope and save the resolved mapping for future studies; ask the user when intent remains ambiguous. Resolve each output through the saved signal index in the same way.
5. Define whether values are combined as a Cartesian product, paired configurations, or one-at-a-time variations. Ask if the request is ambiguous. Expand an explicit run list and derive its count; do not impose an arbitrary mandatory run cap. Disclose short validation runs separately from the full study run count, including any proposed additional baseline runs.
6. Prepare the study configuration and executable code needed for the requested scope. Reuse suitable existing scripts, inspecting side effects before reuse.
7. Generate previews using the archived Skidpad fixture in `preview_data/` by default, as requested on 2026-10-23. Match the requested axes, units, legends, grouping, and table columns. Label every preview as historical Skidpad data, not results of the requested study. Repeated traces demonstrate layout only; do not fabricate controller differences or predict new-case extrema. If a requested signal is unavailable, disclose the gap and clarify the preview requirement; do not create synthetic fallback data.
8. Present the concrete plan, previews, unresolved limitations, run count, execution mode, output formats, proposed short validation duration/coverage, and any requested budget. Ask for approval for short validation and wait. Inspection and static checks may proceed while approval is pending; simulation may not proceed unless already authorized.

Do not infer approval from elapsed time. The first approval authorizes only short validation. Present its outcome and obtain the second approval before the full study. Once a stage is approved, proceed within that scope without another routine confirmation. Material changes to input values, scenarios, solver/physics settings, execution mode, or requested outputs require an updated plan and approval unless the user already authorized them.

## Model and workspace inventory

Use `MODEL_WORKSPACE.md` as the readable entry point and `inventory/saved/manifest.json` with the linked JSON/JSONL records as the authoritative generated saved-file inventory. `inventory/saved/README.md` is its generated coverage summary. Historical live-session observations are separate and must not be treated as saved-file values. Use `tools/query_saved_inventory.py` for targeted searches.

The user requested all accessible saved block/library contents and variables, with small values retained (up to 100 elements). Missing definitions remain explicitly marked as missing; no substitute libraries or model edits are authorized by inventory generation. See `tools/README.md` for excluded generated/backup files, opaque formats, and static-indexing limits.

Treat this saved inventory as the first lookup location for model structure, workspace structure, configuration, inputs and outputs. Build a complete structural inventory once, filling explicitly recorded gaps as needed. Before each later study, read it first and compare its baseline/configuration identity and dependency fingerprints with the selected state. Where a reliable unchanged fingerprint covers a recorded hyperlink or model section, reuse that record; when it changes, re-read the affected section and dependent mappings. A saved-file fingerprint does not establish the identity of unsaved model or workspace state. Broader inspection is needed only when changes or missing coverage prevent a reliable targeted refresh.

Always revalidate the selected study targets and their effective values at the relevant preparation/validation stage; this does not require rediscovering the whole hierarchy. Save any corrected or newly discovered mappings back into `MODEL_WORKSPACE.md` before relying on them. A documentation-only rehearsal describes these future checks and does not perform live discovery.

Maintain a searchable input index using meaningful names and aliases from user requests. Each resolved entry must identify:

- Exact block path and parameter name, or full workspace structure/field path and scope (base, model, mask or dictionary).
- Source mapping: workbook/sheet/cell or importer field, parameter script/function, or maneuver generator and argument position.
- Class/shape, units, applicable configuration/variant, and observed value or expression with its verification date/status.
- Initialization/override order, calculations that depend on the input, callbacks that can reset it, effective-value readback, and temporary application/restoration method.

Index outputs by signal/container/leaf, component, units and transformations as well. Mark unknown fields explicitly instead of inventing a mapping. This is a saved lookup/configuration inventory, not an executable runner or a substitute for stage approvals.

Record:

- Inspection time, host OS, MATLAB release, project/model identity, loaded versus on-disk state, and whether observations were static or runtime verified.
- Model/subsystem hierarchy, referenced models and library links, active variants, block types, mask parameter names, parameter expressions, and applicable workspace scope.
- Relevant callbacks and startup order, including functions that reset data or generate derived parameters.
- Workspace variable/structure paths, classes, sizes, units where available, source files/import mappings, and dependencies. Inspect base and model workspaces and linked dictionaries where used. Summarize large arrays rather than embedding them.
- Scenario hyperlink labels and exact command sequences, preparation inputs, and expected stopping behavior.
- Project maneuver sequence identity, generator/update commands from the hyperlink, arguments/units, target database/workspace fields, and how to read back the updated content.
- Logging containers and nested signal paths, components, units, availability by scenario/variant, and known transformations in plotting scripts.
- Content hashes or equivalent fingerprints for relevant models, scripts, and workbooks; current configuration identity and unsaved changes. A Git commit alone does not identify a dirty working tree.
- Unknowns, missing dependencies, and unverified assumptions explicitly.

Model inspection may trigger callbacks when loading a model. Inspect those side effects first. A simulation needed to discover output details belongs in the approved validation stage. Update the shared inventory in place, without a study copy. Keep preparation-time external dependency hashes in `state.mat` and baseline file hashes alongside the saved baseline, so later inventory refreshes do not alter the approved inputs.

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

## Validation and execution approvals

1. Save the plan, exact expanded run list, baseline provenance, shared-inventory reference and dependency hashes, study code, and first approval record.
2. Run only the approved short validation to check that requested changes are applied correctly. Check effective parameter values, generated maneuver data, and available requested signal paths/extraction. Choose the shortest useful duration and explicitly state what it cannot validate, such as later maneuver phases. Do not run a full-length validation for output preview purposes; use historical Skidpad data for the full output layout.
3. On Windows parallel studies, validate worker setup/isolation within the approved short validation scope. If parallel execution is unavailable, report the issue rather than silently switching the approved mode.
4. Show the validation findings, effective inputs, any failures, and remaining limitations. Obtain the user's second approval for the full study. Do not automatically start full runs when the short validation finishes. Keep validation outputs separate from study metrics; short runs do not count as completed study runs.
5. After the second approval, execute full runs from the same baseline, without carrying state or parameter changes from the preceding run. Save each completed run independently; avoid accumulating full outputs in memory.
6. Record completion reason, simulated duration, elapsed time, warnings, and failures. Any Simulink `ModelStop` is a completed run, regardless of which model stop condition fired or when. Reaching the configured stop time is also a completion. Retain the actual stop time, source and description; do not force a model-stopped run to continue to the time limit. Diagnostic errors, manual interruptions, timeouts and pauses remain incomplete.
7. The simple MATLAB example stops at the first failure and retains the failure transcript under `logs/`, small status metadata and completed selected results for review; remove temporary project copies. Do not silently change physics or solver settings to force completion. Continuing independent runs requires an explicitly implemented and reviewed failure policy.
8. There is no automatic retry after a failure. Review failures and prepare a new study. The active Constant Steer runner rejects existing result files and runs fresh cases. Its earlier D20-specific continuation helper is retained only in the historical study's code; it is not a general recovery method for new JSON studies. Remove superseded attempts only after final artifacts have been verified.

A requested wall-clock budget should be recorded and enforced by the runner where supported. If none is given, report estimated duration when evidence permits; do not invent a completion guarantee. Local execution requires an awake host and available MATLAB. This documentation does not create an automation or keep the computer awake.

## Signals, metrics, and previews

Export every study/preview PNG in light mode. Set the figure theme to light before creating plots (`theme(fig, 'light')`) and export with `BackgroundColor='white'`. A white figure background alone is insufficient: axes, titles, ticks, legends and annotations must also use the light theme. Do not change the user’s global MATLAB/desktop theme.

Resolve requested outputs against actual logging data. Existing plots are useful references, but do not assume all scenarios expose identical signals or that every script can be called unchanged.

Record signal paths, components, units/conversions, time windows, and any derived calculations. Unless the request specifies otherwise, use the full valid recorded interval, signed minima/maxima, and time on the x-axis; disclose these defaults in the plan. Clarify an ambiguous request for a “peak” when signed versus absolute magnitude affects interpretation.

Keep native time samples for simple overlays. Resampling or alignment by distance/event must be explicit. Flag missing signals, empty windows, nonfinite data, and incomplete runs instead of silently producing valid-looking metrics. Do not compare extrema from incompatible run durations without labeling that limitation.

Keep only signals used to generate the requested outputs, including necessary time axes, reference signals, and components used in derived metrics. Extract nested leaves rather than saving an entire bus because one leaf was requested. Save the selected data and compact metadata in MAT files; do not persist the entire workspace, full `SimulationOutput`, or unrelated Simscape logs by default. Reduce runtime logging only when it is verified not to remove required data or affect execution.

The sole reusable preview source is `SimulationStudies/preview_data/skidpad_workspace_2026-10-23.mat`, archived from the user's workspace. Load its `logsout_sm_car` Dataset and select the requested signals directly in memory, retaining each signal's own timestamps and applying documented unit conversions. Do not save separate signal subsets, compact preview MAT files, synthetic CSV sources or copies inside individual studies. Keep the one shared archive unchanged. Real study results still retain the selected signals needed for their requested outputs; this rule concerns preview data only. Read `preview_data/README.md` for paths, units and provenance limits. Label every preview as historical Skidpad data, not results of the requested study. If a requested signal is missing, disclose it and clarify the preview requirement. Do not generate previews for a study where the user has explicitly waived them.

After the full study completes and real artifacts have been verified, delete study-generated dummy PNG previews and replace dummy CSV tables with real results or remove the redundant dummy CSV copies. Keep the final simulation PNG plots and CSV tables. Keep the shared Skidpad archive for future studies. Restrict cleanup to recorded preview files created for that study, never a broad wildcard over final plots. Preserve the approved layout/column specification in the plan even after preview images are removed. For interrupted studies, keep previews only while they are still needed to resume/review; never mix them into real results.

## Storage and retention

Keep one final version of each logical study. Remove superseded attempts after verifying that the final selected data, plots and tables are intact. A different requested study is not an attempt to delete.

Refresh `SimulationStudies/inventory/saved/` and `SimulationStudies/MODEL_WORKSPACE.md` in place when sources change. Do not copy either into a study. Retain only small preparation-time dependency hashes and configuration metadata in the study; a later shared-inventory refresh must not change an approved baseline.

Use `logs/` for failed-stage console transcripts only (`validation.log` or `full.log`). Delete successful-stage transcripts. Do not keep `full/`, duplicate launch logs, failed model/project copies, workspace dumps or extra diagnostic files. Execution copies under `.work/` are temporary and are removed after success or a caught failure; after a process is forcibly killed, remove its leftovers before keeping the final study. Preserve selected completed results and the small failure/status record.

Keep editable MATLAB code, selected MAT signals, final PNG plots, CSV tables, the study plan and small final state. The baseline ZIP and its file hashes are retained for reproducibility. Small continuation provenance is retained when data were reused. Validation MAT files and their input readbacks are temporary evidence for stage review. After successful full execution and verified exports, delete `validation/`; retain only its outcome, approvals and small configuration metadata in `state.mat`. Keep validation data while it is needed for an incomplete study. Completed-state scope hashes describe the original reviewed preparation, including temporary files that may have been removed; prepare a new study for another execution. This retention policy does not authorize a simulation or change the approval gates.

## Study folder and deliverables

Use `SimulationStudies/studies/YYYY-MM-DD_<study-name>/`, with an additional time or suffix to avoid collisions. Use the user's local date/time with timezone recorded in metadata; do not hard-code an absolute Mac or Windows path.

```text
YYYY-MM-DD_<study-name>/
    rerun_study.m          # Prepare from JSON or dispatch one approved batch stage
    study_inputs.json      # Editable input record required for every future study
    study_plan.md          # Scope, run list, preview specification, two approval records
    code/                  # Editable MATLAB files, including study_config.m
    previews/              # Temporary historical-data previews; cleaned after completion
    results/               # Selected signals per run in MAT files
    plots/                 # Requested PNG plots
    tables/                # Requested real CSV metric tables
    state.mat              # Approval records, status, reviewed scope and run config
    logs/                  # Failed-stage console logs only; absent after success
    baseline.zip           # Exact saved baseline for reproducibility
    baseline_files.csv     # Baseline file hashes
    report.md              # Only if the user requested a narrative report
```

This tree is a target layout, not a claim that these files or their generators already exist. Small plan/manifest files support reproducibility and are not unsolicited narrative reports. Plot legends and table rows must identify the configuration and scenario. Retain failures in the status record; do not hide them or select a “best” result.

At completion, provide links to the requested artifacts and a concise run-status summary. State limitations or missing outputs. Do not generate a separate report unless requested.

## Editable input JSON

Every future study must retain `study_inputs.json` at its root so the user can reuse and edit the study inputs for later runs. Keep this file small: include the study name, execution mode, model, maneuver and requested input values/durations. Keep fixed project settings and implementation details in MATLAB. Preserve the user's chosen simplified format; do not add redundant fields solely to mirror the internal configuration structure. Adapt older templates to read and copy their study-specific JSON before using them for a future study.

For the current Constant Steer comparison the JSON contains only `name`, `execution`, `model`, `maneuver`, `steeringAngles_deg`, `controllers` and `stopTime_s`. The reader supplies the project file (`SSVT_FSAE.prj`), timezone (`Europe/Bucharest`), native throttle/braking profile and 1 s validation duration in MATLAB. It expands every angle/controller combination. The editable input example and its matching implementation are retained in `studies/2026-10-25_123418_016_constant-steer-default-vs-flc-dyc-v3/`. Numerical values and names are data, never executable MATLAB commands. The current runner supports Constant Steer with native throttle/braking and sequential execution only. For a different maneuver, the agent must verify its current top-level hyperlink and prepare the corresponding MATLAB setup/readbacks; unsupported settings must stop rather than silently using the previous maneuver.

`prepare_study(projectRoot,inputFile)` accepts an explicit JSON path, copies it to the new study root and includes it in the reviewed file hashes. Run stages use the prepared configuration and reject JSON changes. A JSON in a completed study is an editable starting point for later runs; changing it does not change existing results. Prepare and review a new study from the edited file. Keep completed signals and execution state unchanged. Preview and both stage approvals still apply unless explicitly waived for the new request. Reading or editing JSON does not itself authorize a simulation.

## Script readability and stop labels

Use ordinary loops, descriptive variables and numbered MATLAB sections for preparation, scenario setup, temporary settings, simulation, extraction, metrics and cleanup. Keep the actual maneuver commands and requested signal paths visible in the simulation code. Small file-identity checks remain; do not replace the approved-stage or baseline controls merely to shorten scripts.

Document each function with MATLAB help comments describing its purpose, argument meanings/defaults/units, return value, side effects and a contextual call example. Keep execution stage names explicit (`prepare`, `validation`, `full`); do not use a boolean to imply simulation approval.

A normal ModelStop before the requested end time needs no human-facing reason classification. Only label an excessive roll-angle or lateral-deviation stop when the actual gated stop requests support it. For the current saved sm_car Check subsystem these are Product7 (roll) and Product1 (lateral deviation). Temporarily log those two requests in the isolated model copy and retain only the final flag evidence/label as small metadata. Do not infer the cause from generic stop descriptions, a root-model stop source, shortened time, or decimated vehicle signals. If both flags are active, retain both labels. Errors/manual stops/timeouts/pauses remain incomplete. Historical files without these flags must not be assigned an invented reason.

## Rerunning from a study folder

Every future study includes `rerun_study.m` beside `study_inputs.json`. For the Constant Steer implementation, change the JSON, open that study folder in MATLAB and call `newStudyFolder = rerun_study();`. This prepares a new dated study using the shared runner templates, its compatible source study implementation and current saved project files; it does not reuse the old baseline archive, alter old results, generate previews or start a simulation. The shared inventory must be current first, and changed maneuvers still need verified matching MATLAB commands/checks. Other study templates must supply a matching wrapper before use.

Review the new plan and historical-data previews. After the first approval, launch a fresh MATLAB batch process in the NEW study folder and call `rerun_study('validation','<actual approval>')`. Review its validation outcome, obtain the second approval, then launch another fresh batch process there with `rerun_study('full','<actual approval>')`. The wrapper dispatches that study's reviewed `code/run_study.m`; existing JSON/scope/baseline checks and cleanup rules apply. No interactive simulations or automatic approval carryover are introduced. Completed studies reject stage execution and offer new preparation instead.

## Shared templates and learning from previous studies

Keep one set of shared templates in `runner/`: prepare_study, run_study, rerun_study, study_scope and file_sha256, plus the Constant Steer-based plot_template.m and study_inputs.json starters. Study-specific functions (study_config, simulate_run, check_inputs, extract_signals, plot_results and write_study_plan) belong in the relevant study. Do not retain per-study script folders or collections of per-study JSON copies inside runner; retain only the one shared input-JSON starter. New studies combine their adapted source implementation with reviewed snapshots of the shared templates, all within the new study folder.

Before adapting a study, read relevant earlier study code, plans, comments, effective-input records, failure notes and this model workflow. Use them as examples and lessons, then verify their input/output mappings and maneuver commands against the current model. Avoid reintroducing fixed errors such as guessing stop causes, overriding maneuver syntax or mixing previews with results. Do not infer current runtime state or new approval from historical evidence. Preserve existing user modifications.

Rerun wrappers ordinarily prepare from their own study code plus current shared templates. The original legacy comparison predates the JSON reader, so its wrapper explicitly references the newer compatible study code instead. Keep that reference valid if studies are removed or reorganized. The legacy execution code and completed results remain historical records. The newer prepared study's code/template refresh requires renewed preview/plan review; no stage approval is implied by this reorganization.

## Shared plotting and input starters

The user requested the working Constant Steer plotter and simplified input JSON as shared references. Each study must adapt its JSON fields, MATLAB input reader, selected outputs, plot layout and metric calculations to its own request; the Constant Steer schema and outputs are examples, not requirements for other studies. Keep `runner/plot_template.m`, `runner/rerun_study.m` and `runner/study_inputs.json` available for new studies. Adapt the plot starter into the new study's `code/plot_results.m`, updating the function name and scenario-specific signals, labels, event markers and metrics. Copy/adapt the JSON at the study root. Preserve light-mode PNG exports. Do not overwrite an existing study's customized code or inputs from the shared starters. Their role is to illustrate previously agreed conventions, including concise inputs/code, explicit units/native timestamps, light-mode PNGs, CSV metrics, selected-signal storage and evidence-based exceptional stop labels. Do not inherit example-only steering/controller values, signals or event markers without a study-specific reason. These references do not establish that another maneuver is implemented. Continue to read retained study files and current model workflow when adapting them.
