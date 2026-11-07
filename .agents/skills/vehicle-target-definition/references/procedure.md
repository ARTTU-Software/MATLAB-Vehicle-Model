# Target definition procedure

## Resolve acceptance

Use the request and the designer's [model lookup](../../vehicle-model-lookup/SKILL.md) findings. Markdown rehearsals stay within Markdown; this skill does not imply saved/live discovery.

Define one numerical metric: source signals/components, units, calculation, measurement window and acceptance rule. Support a requested interval, threshold or value with an agreed tolerance. Resolve endpoint inclusion and meaningful precision; do not invent exact-equality requirements or a tolerance that makes the target easier. Questions go through the coordinator. Multiple numerical targets and full minimization/maximization remain deferred.

Define successful maneuver completion independently: identify a completion event/flag or other reliable recorded evidence, and distinguish known physical-limit outcomes. Configured end time or generic ModelStop alone does not prove maneuver completion. Missing evidence calls for measurement/code work before execution, not an invented success rule.

For the motivating time-window example, measure **simulated maneuver completion time**, not computer calculation time or an unrelated stop timestamp. Rolling or leaving bounds inside that time window is not a match. Other requests may target a different numerical metric.

## Parameter authority

The user names adjustable parameters. Resolve exact targets, starting values, units/types, initialization dependencies, effective readbacks and known hard limits. The specialist may challenge their relevance or recommend others, but adding/replacing adjustable parameters requires user agreement.

After search approval, small steps for named parameters may be chosen from model evidence without per-candidate approval. There is no universal percentage: consider scale, units, physical meaning, dependencies and observed response, particularly for values near zero.

Ask about large changes or uncertain limits. Respect user bounds and known hard model limits. An unknown acceptable range is not unrestricted merely because an increment looks small. Track cumulative departure from the starting configuration as well as each increment; repeated small steps cannot bypass approval for a large total change.

Record starting values, known bounds, supporting evidence and the small-step rationale in the search specification. Do not require user approval for every small step or insist on user-supplied numeric bounds when evidence already supports the permitted adjustment. Keep unlisted parameters, maneuver, structure, solver and physics fixed unless separately authorized.

## Budget and stage authority

Require a simulation-count limit; a wall-clock limit is optional. Count each launched full candidate evaluation, including physical-limit outcomes and technical failures. A full baseline or explicitly requested confirmation run also counts. Present the separately approved short-validation count alongside the search budget so total possible work is visible. Preparation and saved-result calculations do not consume simulation slots.

If a time limit is requested, define its start/elapsed accounting and treatment of an in-flight case at expiry. Do not promise hard cancellation without implemented, reviewed support and authorization. No new candidate launches after an exhausted count/time budget.

Use [planning](../../vehicle-study-planning/SKILL.md) for short-validation coverage and monitoring preferences. A concrete package/checkpoint precedes short-validation approval; its findings precede separate full-search approval. Search approval covers the adaptive policy, known bounds, count budget and optional time policy. It does not authorize large/uncertain changes, technical retries or mid-search code edits.

Stop at the first verified match, without an extra confirmation run by default, or at budget exhaustion. Return an unsuccessful-search summary and next-step proposals rather than automatically extending budget. If evidence cannot support further permitted progress earlier, report the limitation instead of spending the remaining budget blindly.

## Handoff and implementation limit

Return acceptance calculation/rule; maneuver-completion evidence; named parameters/start values/types/units; known bounds and small-step rationale; fixed settings; budget accounting; validation coverage; monitoring preferences; and implementation gaps. Use the existing study specification/plan when preparation is authorized, not a competing plan.

The current fixed-case sequential runner has no adaptive candidate interface. These instructions support planning and proposals; execution needs separately requested, reviewed implementation. Do not repeatedly edit hashed JSON/code or bypass completed-study controls to improvise support. [Candidate selection](../../vehicle-target-candidates/references/procedure.md#execution-interface-boundary) owns the future execution handoff requirements.
