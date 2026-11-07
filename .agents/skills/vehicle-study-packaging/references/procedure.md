# Study packaging procedure

Paths in code spans are relative to the project root; use portable paths on macOS and Windows. [Runner usage](../../../../SimulationStudies/runner/README.md) owns exact API examples.

## Prepare the reviewable package

1. Resolve the experiment with [planning](../../vehicle-study-planning/SKILL.md). Check current saved targets and relevant fingerprints through [inventory](../../vehicle-model-lookup/SKILL.md), reusing unchanged records. Preserve unsaved work; saved fingerprints do not identify it.
2. Identify the execution host. Make Windows execution mode explicit, asking if absent. Use [capacity assessment](../../vehicle-study-parallel-capacity/SKILL.md) for parallel feasibility on macOS or Windows; current runner support remains sequential. Agree an execution policy for other operating systems.
3. Read relevant earlier study code, plans, comments, effective-input records and failure notes before adapting them. Inspect side effects before reuse. Historical approvals/settings are not new permission or current runtime evidence.
4. Use [simulation code](../../vehicle-study-simulation-code/SKILL.md) to author the configuration/simulation/check/extraction functions and [plotting](../../vehicle-study-plotting/SKILL.md) for output functions. Package fixed sweeps with an explicit run table. For a future supported target search, package its reviewed policy/budget and initial candidate rather than an invented full case list; the authoring skill owns maneuver order and overrides.
5. Retain the fresh saved baseline ZIP/file hashes, external dependency hashes, shared-inventory reference, reviewed local code/template snapshots and small pending-review state. Shared-inventory refresh must not change that baseline. Inspect callbacks before any later model loading; startup/compile/maneuver execution remain outside preparation.
6. With [results](../../vehicle-study-plotting/SKILL.md), generate historical-data layout previews unless waived. The preparation wrapper itself does not generate them. Disclose unavailable signals and implementation limits.
7. Present the concrete plan, execution mode, outputs, previews, baseline provenance, short-validation IDs/duration/coverage and monitoring agreement. Fixed sweeps include expanded full cases/count and any requested budget. Target searches use the [target definition](../../vehicle-target-definition/SKILL.md), mandatory simulation-count budget and [supported-interface boundary](../../vehicle-target-candidates/references/procedure.md#execution-interface-boundary), without a predetermined complete candidate list. Obtain short-validation approval before [execution](../../vehicle-study-execution/SKILL.md); the next full approval follows its findings.


## Study folder and deliverables

Use `SimulationStudies/studies/YYYY-MM-DD_<study-name>/`, with an additional time or suffix to avoid collisions. Use the user's local date/time with timezone recorded in metadata; do not hard-code an absolute Mac or Windows path.

```text
YYYY-MM-DD_<study-name>/
    rerun_study.m          # Prepare from JSON or dispatch one approved batch stage
    study_inputs.json      # Editable input record required for every future study
    study_plan.md          # Reviewed scope/cases or search policy, layouts and approval gates
    code/                  # Editable MATLAB files, including study_config.m
    previews/              # Temporary historical-data previews; cleaned after completion
    results/               # Selected signals per run in MAT files
    plots/                 # Requested PNG plots
    tables/                # Requested real CSV metric tables
    state.mat              # Supported approval/status records, reviewed scope and run config
    logs/                  # Failed-stage console logs only; absent after success
    baseline.zip           # Exact saved baseline for reproducibility
    baseline_files.csv     # Baseline file hashes
    report.md              # Only if the user requested a narrative report
```

Describe the approval gates in the plan before hashing it. Record later actual grants in the supported execution state and chat; do not modify the frozen plan to insert approvals.

This tree is a target layout, not a claim that these files or their generators already exist. Small plan/manifest files support reproducibility and are not unsolicited narrative reports. Plot legends and table rows must identify the configuration and scenario. Retain failures in the status record; do not hide them or select a “best” result.


## Editable input JSON

Every future study must retain `study_inputs.json` at its root so the user can reuse and edit the study inputs for later runs. Keep this file small: include the study name, execution mode, model, maneuver and requested input values/durations. Keep fixed project settings and implementation details in MATLAB. Preserve the user's chosen simplified format; do not add redundant fields solely to mirror the internal configuration structure. Adapt older templates to read and copy their study-specific JSON before using them for a future study.

The [runner input contract](../../../../SimulationStudies/runner/README.md#constant-steer-input-contract) documents the current Constant Steer fields, defaults and support limits. They are implementation-specific examples, not the schema for every new maneuver.

The preparation interface documented in the [runner guide](../../../../SimulationStudies/runner/README.md#prepare-and-adapt-a-study) copies the chosen JSON into the new study and its reviewed hashes. Run stages use the prepared configuration and reject JSON changes. A JSON in a completed study is an editable starting point for later runs; changing it does not change existing results. Prepare and review a new study from the edited file. Keep completed signals and execution state unchanged. Preview and both stage approvals still apply unless explicitly waived for the new request. Reading or editing JSON does not itself authorize a simulation.


## Save the sweep and reproducibility record

Keep user-editable input values in study_inputs.json. Fixed sweeps retain deterministic expanded case IDs/values/units and the combination rule in the existing plan/configuration. A separately implemented target search retains its reviewed policy/budget there and records later candidate inputs/results only through its [reviewed runtime interface](../../vehicle-target-candidates/references/procedure.md#execution-interface-boundary). Record fixed inputs, defaults, duration, expected outputs, validation IDs and baseline identity there, without introducing a second manifest/schema merely to duplicate them. Review changes to both the editable source and its interpreted cases.

Requested values describe the experiment; effective values observed during execution belong to each case's existing result/status metadata. Both are needed to explain a result. Do not claim prepared values were applied before runtime readbacks exist.

The user's normal entry point is rerun_study.m. Keep the preparation-only path clear and explain that changing saved inputs prepares a fresh study; it does not rerun or rewrite completed results. Preserve current JSON interfaces unless a change was explicitly requested.

## Rerunning from a study folder

Include a compatible rerun_study.m beside study_inputs.json. Preparation from edited inputs creates a fresh dated study from current saved sources and compatible code/templates; it does not reuse an old baseline, alter completed results, generate previews or launch simulations. Resolve saved-inventory freshness through lookup within the authorized scope. Other maneuvers need matching setup/readbacks and a compatible wrapper.

Use the [runner guide](../../../../SimulationStudies/runner/README.md#rerun-from-the-json) for current invocation syntax. Review the new package/previews and obtain separate validation/full approvals; completed-study execution and old approvals cannot be reused. These existing wrappers are for fixed-case studies, not an adaptive-search interface.

## Shared templates and learning from previous studies

Keep one maintained shared template/starter set in runner, with study-specific code/inputs in each study. The [runner guide](../../../../SimulationStudies/runner/README.md) owns the file list, compatible function contracts and source-study dependencies. New preparations retain reviewed local snapshots, not additional per-study folders in runner.

Before adapting a study, read relevant earlier study code, plans, comments, effective-input records, failure notes and this model workflow. Use them as examples and lessons, then verify their input/output mappings and maneuver commands against the current model. Avoid reintroducing fixed errors such as guessing stop causes, overriding maneuver syntax or mixing previews with results. Do not infer current runtime state or new approval from historical evidence. Preserve existing user modifications.

Preserve the runner guide's retained implementation dependencies during reorganization. A refreshed code/template snapshot needs new review; reorganizing files does not grant stage approval.

## Input and plot starters

The Constant Steer input fields, outputs and event markers are examples, not defaults for another study. Adapt the JSON, matching MATLAB reader, maneuver/readbacks, selected outputs and metric windows to the actual request. Keep one shared `runner/study_inputs.json` starter and preserve existing customized study inputs/code. [Results](../../vehicle-study-plotting/SKILL.md) owns adaptation of the plotting starter and export conventions.


## Storage and retention

Keep one final version of each logical study. Remove superseded preparation/study attempts only after verifying final artifacts and retaining necessary failure/continuation evidence. A distinct study is not an attempt to delete. Evaluated target-search candidates, including invalid and failed ones, are evidence within that search: preserve their [required history](../../vehicle-target-assessment/references/procedure.md#preserve-all-evaluated-attempts), rather than treating them as superseded study attempts.

Keep the shared inventory and MODEL_WORKSPACE guide outside studies. Any refresh belongs to [model lookup](../../vehicle-model-lookup/SKILL.md) within its authorized discovery scope and assigned write ownership; retention/cleanup does not initiate one. Retain only small preparation-time dependency hashes and configuration metadata in the study; a later shared-inventory refresh must not change an approved baseline.

Keep editable MATLAB code, selected MAT signals, final PNG plots, CSV tables, the study plan and small final state. The baseline ZIP and its file hashes are retained for reproducibility. Small continuation provenance is retained when data were reused. Validation MAT files and their input readbacks are temporary evidence for stage review. After successful full execution and verified exports, delete `validation/`; retain only its outcome, approvals and small configuration metadata in `state.mat`. Keep validation data while it is needed for an incomplete study. Completed-state scope hashes describe the original reviewed preparation, including temporary files that may have been removed; prepare a new study for another execution. This retention policy does not authorize a simulation or change the approval gates.

Failed/successful transcript handling and removal of execution copies are owned by [execution cleanup](../../vehicle-study-execution/references/procedure.md#stage-transcripts-and-temporary-execution-copies). Stop any enabled monitor at its stage boundary before removing transient evidence it may read; monitor prompt/cadence are not new study metrics.


## Package handoff

Return the new folder, input/case record, baseline and dependency identity, code/template snapshots, pending-review state, preview artifacts or waiver, validation proposal and limitations. The coordinator freezes an identified checkpoint for [code review](../../vehicle-study-code-review/SKILL.md). Do not insert later coordination notes into hashed files.

Final cleanup is assigned by the coordinator only after [run/result verification](../../vehicle-study-run-verification/SKILL.md). The supervisor reports readiness; it does not delete files. [Plotting](../../vehicle-study-plotting/SKILL.md) owns exact preview-artifact cleanup, and execution owns temporary run copies/transcripts.
