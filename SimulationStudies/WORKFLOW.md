# Simulation study workflow

## Entry point and scope

[AGENTS.md](../AGENTS.md) owns role routing, handoffs, scope and approvals. This page is lifecycle navigation, with established anchors retained for existing links; it does not duplicate the skill procedures.

## Purpose and implementation status

Produce reproducible requested comparisons, plots and metrics. Dated mappings/provenance and previous study outcomes remain in [MODEL_WORKSPACE.md](MODEL_WORKSPACE.md); generated saved records remain shared in `inventory/saved/`.

The [runner guide](runner/README.md) describes shared templates and compatible retained study implementations. Current execution is sequential only; a capacity assessment does not add parallel support. Read the relevant implementation guide for supported interfaces; the presence of a skill is not proof of runtime support.

## Confirmed preferences

Use the [root capability routing](../AGENTS.md) and [team handoffs](../AGENTS.md#handoffs-and-ownership). A fixed study proceeds through specification, authorized preparation, code review, approved short validation, findings, separate full approval and verified delivery. [Target finding](TARGET_FINDING_PLAN.md) adds the optional specialist; replotting enters plotting directly. Detailed rules live in the linked skills.

## Study preparation

Follow [planning](../.agents/skills/vehicle-study-planning/SKILL.md), then the [packaging procedure](../.agents/skills/vehicle-study-packaging/references/procedure.md#prepare-the-reviewable-package) when preparation is requested.

## Model and workspace inventory

Use the [lookup procedure](../.agents/skills/vehicle-model-lookup/references/procedure.md) and [tool mechanics](tools/README.md). Model-specific records remain in [MODEL_WORKSPACE.md](MODEL_WORKSPACE.md).

## Scenario and input handling

[Simulation code owns maneuver order, dependencies and temporary input overrides](../.agents/skills/vehicle-study-simulation-code/references/procedure.md#scenario-and-input-handling).

## Validation and execution approvals

[Execution owns approved stages and findings review](../.agents/skills/vehicle-study-execution/references/procedure.md#preflight-and-stages). Validation never advances automatically to full execution.

## Signals, metrics, and previews

[Plotting owns signal selection, historical previews, units and metric windows](../.agents/skills/vehicle-study-plotting/references/procedure.md#signals-metrics-and-previews). [Preview provenance](preview_data/README.md) describes the one shared archive.

## Storage and retention

[Packaging owns final retention after verification](../.agents/skills/vehicle-study-packaging/references/procedure.md#storage-and-retention); [execution owns transcripts and temporary execution copies](../.agents/skills/vehicle-study-execution/references/procedure.md#stage-transcripts-and-temporary-execution-copies).

## Study folder and deliverables

[Packaging owns the study layout](../.agents/skills/vehicle-study-packaging/references/procedure.md#study-folder-and-deliverables); [run verification checks final delivery](../.agents/skills/vehicle-study-run-verification/references/procedure.md#verify-completed-results).

## Editable input JSON

[Packaging owns the small editable JSON and its reviewed identity](../.agents/skills/vehicle-study-packaging/references/procedure.md#editable-input-json). Inputs remain data, not MATLAB commands.

## Script readability and stop labels

[Simulation code owns MATLAB readability](../.agents/skills/vehicle-study-simulation-code/references/procedure.md#matlab-readability); [run verification owns evidence-based stop labels](../.agents/skills/vehicle-study-run-verification/references/procedure.md#completion-and-stop-evidence).

## Rerunning from a study folder

[Packaging owns fresh preparation from edited JSON](../.agents/skills/vehicle-study-packaging/references/procedure.md#rerunning-from-a-study-folder). Completed results/state and prior approvals stay historical.

## Shared templates and learning from previous studies

[Packaging owns shared-template snapshots and reuse of previous lessons](../.agents/skills/vehicle-study-packaging/references/procedure.md#shared-templates-and-learning-from-previous-studies). [Runner usage](runner/README.md) keeps the implementation-specific API and examples.

## Shared plotting and input starters

Use [plotting for the plot starter](../.agents/skills/vehicle-study-plotting/references/procedure.md#plot-starter) and [packaging for input starters](../.agents/skills/vehicle-study-packaging/references/procedure.md#input-and-plot-starters). Adapt examples to the actual request.

## Monitoring

[User updates](../.agents/skills/vehicle-study-user-updates/SKILL.md) asks about enablement and missing schedule/content, then arranges a temporary stage-bound follow-up. It observes progress without controlling execution.

## Parallel capacity

[Parallel capacity](../.agents/skills/vehicle-study-parallel-capacity/SKILL.md) owns the >16 GiB gate, first-real-full-case memory sample, headroom/eligibility checks and confirmed unused-session handling. Current runner executable capacity remains one.

## Independent review and verification

[Code review](../.agents/skills/vehicle-study-code-review/SKILL.md) checks a frozen implementation before execution approval. [Run verification](../.agents/skills/vehicle-study-run-verification/SKILL.md) checks actual stage/input/output evidence. The coordinator owns decisions and stage launches.

## Parallel implementation

[Parallel setup](../.agents/skills/vehicle-study-parallel-setup/SKILL.md) guides worker/isolation authoring only when requested. It consumes capacity findings; adding this skill does not implement a parallel runner.

## Target-finding design

The [target-finding guide](TARGET_FINDING_PLAN.md) routes to the optional role and its three implemented instruction skills. [Root handoffs](../AGENTS.md#target-finding-handoff) define authority and coordination. Adaptive runner support remains separate work; the current runner still executes fixed sequential cases.
