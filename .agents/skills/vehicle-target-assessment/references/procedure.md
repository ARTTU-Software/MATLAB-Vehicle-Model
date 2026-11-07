# Target assessment procedure

## Use verified evidence

Consume the supervisor's [run-verification](../../vehicle-study-run-verification/SKILL.md) findings: candidate/run identity, actual effective values, numerical metric and maneuver outcome. When delegation is unavailable, the coordinator may perform verification directly, disclosing that no independent subagent review occurred. Target interpretation does not replace these checks.

Apply the accepted calculation, units, window and tolerance exactly. Missing/nonfinite/unreliable values cannot pass. Missing completion or stop-cause evidence stays unresolved; do not infer success or a known physical limit. A torn live file calls for coherent verification, not a failure declaration or replacement run.

Require passed input/configuration verification before accepting a match or using an outcome to adapt candidates. A supervisor-reported requested/effective parameter mismatch, wrong maneuver, wrong baseline/configuration or failed readback is a verification hold even when the numerical target and maneuver completion appear to pass. Preserve and count the launched attempt, report the discrepancy through the coordinator and await resolution under the existing review rules. Do not silently accept the unintended effective vector as the solution, learn a search response from it, or retry it.

Runner completion and target feasibility differ: ModelStop can complete a simulation while making the target candidate invalid. A physical-limit stop inside a requested maneuver-time window is not a successful maneuver.

## Classify and hand off

| Verified outcome | Assessment and coordinator action |
| --- | --- |
| Passed input/configuration verification, successful maneuver and numerical acceptance | Match: stop and return parameters/history |
| Passed input/configuration verification, successful maneuver but numerical miss | Report measured gap and feedback for another permitted candidate |
| Passed input/configuration verification and known physical limit, including rolling, stopping on track or leaving bounds | Invalid candidate: record supported reason and adapt within authority/budget |
| Failed input/configuration verification, including a requested/effective parameter mismatch | Verification hold: report the discrepancy; do not accept or adapt from the unintended configuration |
| Error, crash or unexpected model problem | Technical hold: stop further launches, preserve evidence and report through the coordinator |
| Required outcome/input/completion evidence missing or unreliable | Evidence hold: obtain coherent verification or report the gap; do not guess, rerun or advance |
| No match and budget exhausted | No solution within budget: return history, closest completed attempts and proposals |

Technical problems on the first run pause further launches; later technical problems follow the same rule. Known physical-limit outcomes can guide another candidate, including on the first full evaluation, if reliably identified and the approved stage/budget permits continuation. They are not technical retries. Ordinary numerical misses need no renewed approval.

A hold concerns future launches, not permission to pause/kill an active MATLAB process. The coordinator owns any authorized control action. Do not automatically retry a failure or change code, solver, physics, target or budget.

For completed comparable attempts, report distance to the accepted numerical set. For inclusive interval [L,U], distance is max(L-y,0,y-U); a value with tolerance uses that tolerance interval. Respect other endpoint rules when specified and record pass/fail separately. This explains proximity to the requested target, not a new minimization objective.

## Preserve all evaluated attempts

Account for every launched candidate, including invalid and failed attempts, using implemented execution records as the source of truth. Reconcile run IDs and budget counts. Proposed-but-unlaunched candidates are not evaluated results; keep short validation separate.

Retain or reference each candidate's requested/effective values and units; deltas from start/previous; rationale; model/maneuver/configuration identity; measured metric and completion evidence; physical-limit reason or technical failure; acceptance status; and consumed budget. Include approved non-parameter changes, if any, and distinguish incompatible configurations. Changed configurations do not silently inherit old evidence or authority.

The implementer supplies history/output support when requested; the reviewed execution interface records runtime data. The target finder summarizes through the coordinator without rewriting state, inventing a second ledger or removing unsuccessful candidates as superseded study versions. Missing metrics remain unavailable, never fabricated numerical penalties.

## Final delivery

For a match, return final effective parameters/units, changes from start, numerical result and acceptance rule, successful-completion evidence, run identity, budget used and all evaluated attempts. Stop at the first verified match; no extra confirmation is required unless requested and budgeted. Applying the solution to original models/workbooks/scripts needs a separate request.

If budget is exhausted or progress becomes impossible earlier, say no verified solution was found. Show closest successfully completed comparable attempts and their numerical gaps. If none completed, say so. List physical-limit candidates separately with their unmet completion requirement even if incidental stop times appear close. Include technical failures/unresolved evidence without claiming the entire search space is infeasible.

Propose more budget, revised bounds or additional parameters with the required user decision; do not execute those proposals. Use [plotting](../../vehicle-study-plotting/SKILL.md) and [user updates](../../vehicle-study-user-updates/SKILL.md) for artifacts/delivery. The coordinator stops the stage monitor at success, exhaustion or a hold requiring intervention.
