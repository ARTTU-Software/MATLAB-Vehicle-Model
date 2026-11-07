---
name: vehicle-study-planning
description: "Plan Vehicle_Model simulation experiments and documentation-only workflow rehearsals: resolve cases, outputs, short-validation coverage and monitoring preferences. Planning alone does not authorize preparation or simulation."
---

# Vehicle Study Planning

Turn the request into a reviewable experiment under the shared rules in [AGENTS.md](../../../AGENTS.md). This skill is specific to the project containing `SSVT_FSAE.prj`.

## Resolve the experiment

1. Use the request, prior decisions and relevant Markdown mappings/history in [MODEL_WORKSPACE.md](../../../SimulationStudies/MODEL_WORKSPACE.md). Ask only about material ambiguity that those sources cannot resolve. A documentation-only rehearsal stays entirely within Markdown.
2. Resolve the objective, maneuver, input targets and values, units, initialization dependencies, requested outputs/conversions, metric windows and duration. Mark unresolved saved/runtime mappings for later authorized [inventory work](../vehicle-model-lookup/SKILL.md). Do not inherit Constant Steer example values, controllers, outputs or event markers.
3. For fixed sweeps, resolve Cartesian, paired or one-at-a-time combinations; expand the full run list and derive its count. A separate run cap is optional. For requested target finding, use [target definition](../vehicle-target-definition/SKILL.md): the simulation-count budget is required and later candidates are adaptive, so no complete predetermined case list is required. Disclose full baseline evaluations and short validation separately.
4. Propose the shortest useful validation: one representative changed case for numeric sweeps, with additional cases only for different compiled configurations. State the selected IDs, reasons and later phases it cannot test. Never propose full-length validation.
5. Record the execution host/mode and implementation limits. Windows mode must be explicit; ask if missing. Use [parallel capacity](../vehicle-study-parallel-capacity/SKILL.md) when assessing parallel feasibility on macOS or Windows. Current executable capacity remains one.
6. If monitoring is unspecified, ask whether it is wanted. If enabled, resolve any missing interval/clock times, timezone and output preferences with [monitoring](../vehicle-study-user-updates/SKILL.md). Do not create a monitor during a rehearsal.

## Review and handoff

Present inputs, expanded cases/count for fixed sweeps or the target policy/budget for target finding, execution mode, requested plots/table layouts and formats, defaults, duration/budget if requested, limitations, validation coverage and monitoring agreement. Defaults are full valid recorded intervals, signed minima/maxima and time on plot x-axes; clarify ambiguous “peak” meaning.

Actual [packaging](../vehicle-study-packaging/SKILL.md) produces the code/baseline and [historical previews](../vehicle-study-plotting/SKILL.md) needed for a concrete execution review. Explain these future steps in a rehearsal without carrying them out. Ask for short-validation approval only once that reviewable package exists. Static inspection within the requested scope can continue while approval is pending; simulation cannot.

Optimization, ranking and narrative reports require a request. Preparation or one stage's approval does not authorize the next stage.

In the [study team](../../../AGENTS.md#study-team), the designer drafts this specification and returns unresolved questions to the coordinator. The coordinator owns the user conversation and final review; it does not delegate approval decisions.

For target finding, the designer hands mappings and study requirements to the optional target finder through the coordinator. The specialist supplies the target specification and proposals. Current adaptive runner support is absent; do not substitute mutable reviewed inputs or unapproved repeated runs.
