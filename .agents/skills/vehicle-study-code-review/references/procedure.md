# Independent code review procedure

**Input:** accepted specification or scoped maintenance/results request, assigned file list, checkpoint identity, author checks, previews/waiver and known gaps. **Output:** prioritized findings and readiness for the next review step. The supervisor reviews; the implementer remains the sole writer.

## Establish the checkpoint

Read the root coordination contract and only the skills owning the changed capabilities. Use [simulation code](../../vehicle-study-simulation-code/SKILL.md), [packaging](../../vehicle-study-packaging/SKILL.md), [plotting](../../vehicle-study-plotting/SKILL.md) and, if applicable, [parallel setup](../../vehicle-study-parallel-setup/SKILL.md) as maintained standards rather than copying their procedures here.

Confirm the file hashes/revision and that the author has frozen the submitted files. A dirty working tree is identified by the actual files, not just the Git commit. Review within the assigned scope; a documentation-only rehearsal reads Markdown only and maintenance performs static checks only.

## Check the implementation against its request

- Trace every requested input and case to JSON/configuration and effective readback code. Check combination rule, units, stable IDs, defaults and expected count; avoid a numerically correct implementation of the wrong experiment.
- Trace maneuver commands and initialization/override order to saved mappings. Check temporary isolation/restoration, derived values and callbacks. Missing runtime evidence is a validation task, not a fabricated pass.
- Inspect baseline/dependency identity, reviewed-file guards, explicit stage controls, fresh-rerun behavior and protection of completed signals/state.
- Check requested signal paths, native timestamps, conversions, metric windows, missing-data handling and output labels against the requested layouts/previews. Keep historical previews visibly separate from results.
- Check code readability/reuse and user editing guidance through the owning authoring skills. Ensure sweep data are saved and not hidden in execution/plot code.
- Inspect failure handling, cleanup ownership, file collisions and any worker setup. A parallel code path needs both resource evidence and verified isolation; RAM alone is insufficient.
- Examine the author's claimed checks and known gaps. Do not run MATLAB, compile, simulate, create workers or generate data to complete a static review.

For a maintenance-only checkpoint, apply these questions to the changed instructions and interfaces; do not demand a study package or runtime test. For a standalone replot, review only the authorized post-processing changes against recorded study data, without demanding new inventory/baseline/preparation.

## Report, correct and re-review

Return checkpoint identity and a concise verdict: ready for the specified next review step, changes required, or evidence insufficient. For each finding give priority, exact file/location, evidence, consequence and requested correction. Separate blocking defects from suggestions and pending runtime checks.

Return findings to the coordinator. Do not edit files, approve your own changes or grant simulation approval. If files change during review, mark the affected review stale. The implementer applies assigned corrections and submits a new identified checkpoint; review the changed behavior and affected dependencies before replacing the verdict.

Code review precedes execution approval. [Run verification](../../vehicle-study-run-verification/SKILL.md) checks actual validation/full evidence later; static review cannot stand in for it.
