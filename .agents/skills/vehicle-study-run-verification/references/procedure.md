# Run and result verification procedure

**Input:** accepted specification and reviewed identity, current permitted stage and existing evidence. **Output:** an observation or verification verdict with sources, timestamps, gaps and actionable findings. The supervisor is read-only; the coordinator can apply this procedure directly when it is unavailable.

## Observe without controlling

Use existing saved progress records (`state.mat`), failed/in-progress logs, process information and completed outputs through available read-only tooling. Do not attach to or start an interactive MATLAB session merely to report progress, refresh inventory, create diagnostic datasets or modify stage state. If a file is being written, use the last coherent observation and retry on a later check; do not call a torn/stale read a simulation failure.

Report, when observed:

- Stage/status and current case ID/configuration.
- Completed/full count, validation count separately, failures, and the time of the observation.
- Stage wall time from recorded stage timestamps, or case time only when a reliable case start is recorded.
- Requested resource usage with units/method and a clear unavailable marker when missing.
- Requested completed-run outputs using the recorded study configuration and existing selected signals. Use [results](../../vehicle-study-plotting/SKILL.md) if new authorized exports are needed; do not read partially written results as finished.

Current runner state reports case boundaries, not continuous simulated-time progress. Never convert completed-case counts into within-case simulation percentage or invent an ETA. Provide an estimate only with credible comparable timing evidence and label uncertainty.

A missing process or stale state alone does not prove success, failure or a physical stop cause. Correlate state, process exit and recorded evidence. Monitoring may notify that intervention is needed; it never launches, retries, pauses, stops, kills, reconfigures or advances a study.


## Verify effective inputs and stage evidence

Check the launched stage and reviewed configuration/baseline identity against the approval record. For fixed sweeps, verify case IDs/counts against the accepted expanded list. For a future supported target search, reconcile dispatched-candidate records with the reviewed parameter policy, remaining budget and [assessment requirements](../../vehicle-target-assessment/SKILL.md); do not demand a predetermined complete case list. Keep validation distinct from full results in both modes. Check actual readbacks for requested input values/units, active configuration, initialization/dependency effects and generated maneuver content. A saved configuration is not proof an override took effect.

For validation, check only what its short duration can establish: correct effective setup, simulation viability and required signal/extraction availability. Report later phases and untested compiled configurations explicitly. Do not infer full-study physical validity or success from a short run. Report findings to the coordinator before it seeks distinct full approval.

During execution, report observed failures and mismatches promptly to the coordinator. Do not edit the state, retry, stop, change solver/physics or alter cases. Follow the execution skill's existing failure policy; a verification finding itself grants no control authority.

## Completion and stop evidence

Reaching the configured stop time or a recorded Simulink ModelStop counts as completion. Record actual simulated duration, wall time, source/description and warnings. ModelStop may end a case early; do not force it to the requested limit. Diagnostic errors, manual interruption, timeouts and pauses are incomplete. An expected case with no reliable terminal record remains unknown/pending rather than guessed successful or failed.

A normal ModelStop before the requested end time needs no human-facing reason classification. Only label an excessive roll-angle or lateral-deviation stop when the actual gated stop requests support it. The dated [stop-request mapping](../../../../SimulationStudies/MODEL_WORKSPACE.md#stop-requests-for-future-constant-steer-runs-saved-file-mapping-2026-10-25) owns their exact paths and gates. Inspect only the final flag evidence/labels already retained by the reviewed implementation. [Simulation code](../../vehicle-study-simulation-code/references/procedure.md#stop-request-evidence) owns any prior instrumentation. Missing flags mean the physical cause is unverified; do not add instrumentation or change the model during verification. Do not infer the cause from generic stop descriptions, a root-model stop source, shortened time, or decimated vehicle signals. If both flags are active, retain both labels. Errors/manual stops/timeouts/pauses remain incomplete. Historical files without these flags must not be assigned an invented reason.


## Verify completed results

Verify exported plots/table values against the selected real signal files and actual run status before cleanup. Identify configurations/scenarios in legends and table rows. Expose unequal native recording windows separately from configured/actual stop times. Preserve approved layout/column specifications after preview images are removed.

Check requested signal leaves/components, units/conversions, native timestamps, missing/nonfinite samples and metric-window coverage. Recalculate key reported metrics from selected data using the agreed definition and compare them with exported table values and plot labels. Check all requested artifacts/cases are accounted for; distinguish a missing output from a failed simulation and an early completed run from full-window coverage. Do not silently interpolate. Comparison/ranking is limited to the accepted request, including the defined numerical-distance comparison for target finding.

Inspect exported artifact identity/readability and source provenance within authorized results scope. Static maintenance review does not open data, execute MATLAB or generate exports. If the allowed scope cannot establish a check, list it as pending.

Use [plotting conventions](../../vehicle-study-plotting/references/procedure.md) for expected output behavior and [packaging retention](../../vehicle-study-packaging/references/procedure.md#storage-and-retention) to assess whether cleanup is ready. The reviewer reports readiness; the coordinator assigns any authorized deletion.

## Verdict and handoff

Return stage/checkpoint identity, observation time and evidence sources; completed/failed/incomplete/unknown counts; effective-input findings; output checks; warnings and limitations; prioritized corrections; and readiness for the next review step. Distinguish a code defect, execution failure, data limitation and unverified assumption.

A pass means the stated checks succeeded, not scientific validation of the entire model or approval for another simulation. Return artifact links and a concise status summary to the coordinator. [User updates](../../vehicle-study-user-updates/SKILL.md) owns presentation/cadence and monitor shutdown; this skill never schedules an automation.
