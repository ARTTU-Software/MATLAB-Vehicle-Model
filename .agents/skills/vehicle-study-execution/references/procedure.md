# Approved execution procedure

Paths in code spans below are relative to the project root. Read the selected study's plan and reviewed local code/configuration. Use the exact stage launch syntax in [runner usage](../../../../SimulationStudies/runner/README.md).

## Preflight and stages

Run each stage in a fresh separate MATLAB batch process, not in the user's interactive session. Verify host, reviewed scope/JSON/code, baseline and dependency identities before execution. Use the approved local implementation and baseline rather than today's shared templates. Current runner support is sequential; report a requested unsupported mode before launching it.

1. Verify the reviewed plan, baseline/dependency identities and local code. Fixed-case stages use the accepted expanded run list. A future supported target-search stage instead needs the reviewed policy, mandatory budget and implemented candidate records under the [candidate interface boundary](../../vehicle-target-candidates/references/procedure.md#execution-interface-boundary). Record the actual approval in supported state/chat without editing a frozen plan.
2. Run only the approved short validation to establish that the changed model runs and the requested inputs/outputs are applied correctly. For a parameter-only sweep, validate one representative changed configuration, not every parameter value. Add validation cases only for changes requiring a different compiled model configuration, such as a different structural variant or estimator bypass state. Rebuilding the same structure in separate isolated processes does not by itself justify validating every numeric value. Record the selected run IDs and compilation-related reason for any additional cases. Continue effective-input readbacks for every full run. Check effective parameter values, generated maneuver data, and available requested signal paths/extraction. Choose the shortest useful duration and explicitly state what it cannot validate, such as later maneuver phases. Do not run a full-length validation for output preview purposes; use historical Skidpad data for the full output layout.
3. For a future implemented parallel mode on macOS or Windows, verify worker setup/isolation within the approved short-validation scope and follow the capacity skill. Current runner support is sequential only. Report unsupported parallel requests rather than silently changing the reviewed mode.
4. Show the validation findings, effective inputs, any failures, and remaining limitations. Obtain the user's second approval for the full study. Do not automatically start full runs when the short validation finishes. Keep validation outputs separate from study metrics; short runs do not count as completed study runs.
5. After the second approval, execute full runs from the same baseline, without carrying state or parameter changes from the preceding run. Save each completed run independently; avoid accumulating full outputs in memory.
6. Record actual completion reason, simulated duration, elapsed time, warnings and failures. Use [run verification](../../vehicle-study-run-verification/references/procedure.md#completion-and-stop-evidence) for completion/stop classification: configured stop time or ModelStop completes a case; errors, manual interruptions, timeouts and pauses do not. Retain the evidence and never force a model-stopped run to the time limit.
7. The simple MATLAB example stops at the first failure and retains the failure transcript under `logs/`, small status metadata and completed selected results for review; remove temporary project copies. Do not silently change physics or solver settings to force completion. Continuing independent runs requires an explicitly implemented and reviewed failure policy.
8. There is no automatic retry after a failure. Review failures and prepare a new study. The active Constant Steer runner rejects existing result files and runs fresh cases. Its earlier D20-specific continuation helper is retained only in the historical study's code; it is not a general recovery method for new JSON studies. Apply [packaging retention](../../vehicle-study-packaging/references/procedure.md#storage-and-retention) after verification; evaluated target candidates are not superseded studies.

A requested wall-clock budget should be recorded and enforced by the runner where supported. If none is given, report estimated duration when evidence permits; do not invent a completion guarantee. Local execution requires an awake host and available MATLAB. Reading this documentation does not keep the computer awake or create a monitor. An enabled monitor is arranged by the user-updates skill and cannot make an unavailable host run.

Do not infer approval from elapsed time, reuse an earlier study's approval or repeatedly ask within an approved stage. Material input/scenario/solver/physics/mode/output changes need updated review unless already authorized.

## Effective values and run isolation

For every run restore the recorded baseline and apply the verified maneuver/override order from the prepared implementation. Recompute dependent data and verify effective input values, generated maneuver content, active configuration and requested extraction. Do not carry workspace or parameter state between cases.

Save each completed run independently, retaining only selected signals and necessary metadata rather than accumulating full SimulationOutput objects. The [results procedure](../../vehicle-study-plotting/references/procedure.md) owns extraction/output conventions; [run verification](../../vehicle-study-run-verification/SKILL.md) owns independent evidence and export checks.

## Stage transcripts and temporary execution copies

Use `logs/` for failed-stage console transcripts only (`validation.log` or `full.log`). Delete successful-stage transcripts. Do not keep `full/`, duplicate launch logs, failed model/project copies, workspace dumps or extra diagnostic files. Execution copies under `.work/` are temporary and are removed after success or a caught failure; after a process is forcibly killed, remove its leftovers before keeping the final study. Preserve selected completed results and the small failure/status record.

Keep validation signals/readbacks while needed for review or an incomplete study. [Packaging retention](../../vehicle-study-packaging/references/procedure.md#storage-and-retention) owns their removal after verified successful full export.

## Optional observation

When enabled, [monitoring](../../vehicle-study-user-updates/SKILL.md) reports this stage only and stops at completion, failure or an approval boundary. It cannot advance stages.

When capacity assessment is requested and RAM exceeds 16 GiB, observe the first real approved full case sequentially. It counts toward the study; do not insert a full-length validation, extra case, automatic retry or parallel dispatch. The [capacity procedure](../../vehicle-study-parallel-capacity/references/procedure.md) owns the estimate; current executable capacity stays one.
