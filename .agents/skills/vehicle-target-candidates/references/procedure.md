# Candidate proposal procedure

## Initial candidate

Require the acceptance rule, parameter authority and stage identity from [definition](../../vehicle-target-definition/SKILL.md). Resolve required uncertainty about parameter identity or limits before dependent proposals.

Use saved mappings, comparable historical evidence and the starting configuration to explain which named parameters affect the target. Do not infer influence from a name alone. Recommend a different adjustable set through the coordinator, retaining the existing set until the user agrees.

Choose an evidence-supported small initial change, or the starting configuration itself if a real baseline evaluation is needed; a full baseline counts against budget. Historical results may inform proposals but are not new success evidence unless identity, effective values, maneuver and acceptance evidence are verified and reuse is explicitly within the accepted scope.

Return the complete named-parameter vector, with unchanged values explicit. Start with sequential candidates so each proposal can use the preceding verified response. A hardware capacity estimate does not enable parallel search.

## Adapt from verified outcomes

Use [assessment](../../vehicle-target-assessment/SKILL.md) and its source evidence; do not adapt from partially written or unverified outputs.

Select the simplest evidence-supported method for the parameter types and response. A numerical miss informs direction/step size; known physical limits identify infeasible candidates. Consider coupled effects and explain combined changes when needed. Do not assume monotonicity, convergence or equivalent responses across model configurations.

Compare proposed values with the previous candidate and original start. Apply the definition skill's small-step policy, cumulative check and known bounds. Ask before large changes, uncertain limits or parameter-set changes. Never repair a target miss by changing the target, maneuver, solver or physics.

Avoid duplicate effective candidates within the same configuration; account for rounding/discrete values. If initialization would reset a change, return the mapping issue instead of spending a run. Intentional repeats need an explicit reason and applicable authorization, and count against budget.

Stop proposing launches after a match, exhausted budget, technical hold or unresolved required evidence. If no further permitted candidate can be justified, report the obstacle and options rather than claiming convergence.

## Candidate handoff

Return candidate ID and prior-result IDs; complete requested values/units; deltas from start and previous candidate; rationale/evidence; expected qualitative effect with uncertainty; bounds/cumulative checks; and remaining budget as supplied by the coordinator. A proposal is not an executed result; do not modify a runtime ledger yourself.

The coordinator checks policy and budget, then dispatches through a supported reviewed interface under the approved stage. Permitted small changes need no per-candidate user approval. The supervisor verifies effective inputs/outcomes; assessment interprets them before another proposal.

## Execution interface boundary

The existing runner supports prepared sequential cases only. Do not edit hashed JSON, plan/code or completed state between candidates, invent a status schema or create an ad hoc dispatch loop merely to make this role appear executable.

When adaptive implementation is separately requested, the implementer must define a reviewed candidate-request/result interface preserving immutable search specification/code/baseline. It must check parameter authority and budget before dispatch, tie requested/effective values and outcomes to stable IDs, prevent duplicate/replayed dispatch, preserve every evaluation and provide one coordinator-owned source of budget/status truth.

A supported reviewed search stage may evaluate several candidates under one full-search approval, restoring baseline without state leakage. Stage lifecycle, runtime history format and pause/resume behavior must be implemented and reviewed explicitly; they are not supplied by this instruction file. Preserve existing interfaces and historical evidence unless change is requested.

Known physical limits can lead to another candidate under the approved policy. Technical errors/crashes or uncertain outcomes stop further dispatch; never automatically retry. Code corrections, increased budgets or enlarged parameter authority follow the applicable review/approval rules. Do not use a restart/new study to conceal consumed budget.

The implementer writes code/packages, the supervisor reviews/verifies and the coordinator launches. The target finder returns proposals and reasoning without editing project, study or runtime files.
