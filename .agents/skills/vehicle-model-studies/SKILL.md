---
name: vehicle-model-studies
description: "Plan, prepare, validate, execute, rerun, and post-process simulation studies for this Vehicle_Model project, including documentation-only rehearsals. Use for study workflow or runner changes; ordinary model or MATLAB edits alone do not require this workflow."
---

# Vehicle Model studies

Turn the user's requested experiment into reviewed, reproducible comparisons. This skill is specific to the repository containing `SSVT_FSAE.prj` and `SimulationStudies/`; it does not provide a general Simulink study framework.

## Select the requested mode first

Loading this skill authorizes no additional stage. Infer the mode from the user's request; clarify only material ambiguity. Planning language alone does not authorize preparation or simulation.

| Mode | Work within scope | Boundary |
| --- | --- | --- |
| Documentation-only rehearsal | Read Markdown instructions, explain the steps and ask clarifying questions | Do not access MATLAB or model/data files, refresh inventory, generate previews, create a study or modify project files |
| Preparation (`prepare`) | Check saved sources/inventory, resolve the experiment, prepare editable code/JSON/baseline and historical previews | MATLAB is limited to saved-file processing and preview generation; no project startup, maneuver execution, model update/compile or simulation |
| Short validation (`validation`) | Run the explicitly approved duration and cases, verify effective inputs and extraction, present findings | Separate batch process; stop before full execution and obtain its separate approval |
| Full execution (`full`) | Execute the reviewed full cases and verify/export/clean the requested outputs | Separate batch process; use the approved study's local code and baseline |
| Existing-results analysis | Read the selected historical results and produce requested plots/metrics | Do not prepare or run another study, rewrite completed signals/state or infer missing stop causes |
| Workflow maintenance | Edit the requested skill, documentation, templates or study code and perform static checks | Maintenance does not authorize MATLAB startup, study preparation or simulation |

## Read the maintained sources

Read [WORKFLOW.md](../../../SimulationStudies/WORKFLOW.md) and [MODEL_WORKSPACE.md](../../../SimulationStudies/MODEL_WORKSPACE.md) before preparing, changing, executing or post-processing a study, or explaining a rehearsal. The workflow owns detailed procedure and retention rules; the model guide owns mappings, provenance and historical observations. Do not copy them into this skill or a study.

Then read only the references needed for the task:

- Saved-file discovery or inventory gaps: [tools/README.md](../../../SimulationStudies/tools/README.md). Use the shared saved inventory first; retain small readable values up to 100 elements and mark missing/opaque definitions explicitly. Do not access MATLAB just to fill offline gaps without authorization for that stage.
- Study code preparation, reruns or runner maintenance: [runner/README.md](../../../SimulationStudies/runner/README.md), then the relevant retained study's code, plan, comments, input readbacks and failure notes. Reuse lessons, not old approvals or assumed runtime settings.
- Historical output previews: [preview_data/README.md](../../../SimulationStudies/preview_data/README.md). Use only the shared Skidpad archive directly in memory, with explicit historical labels; resolve unavailable signals with the user.
- Ramp Steer adaptation: [RAMP_STEER_REFERENCE.md](../../../SimulationStudies/runner/RAMP_STEER_REFERENCE.md), after checking the current hyperlink when preparation is authorized.

Resolve these links relative to this skill directory, not the shell working directory. For rehearsal and maintenance, reading the Markdown guide does not authorize following its links into model/data files or executing its examples.

## Apply the study workflow

1. Resolve the objective, maneuver, input values, combination rule, outputs, units, metric windows and duration. Ask only material questions not answered by the request or project records. Expand the full run list; disclose validation cases separately. Do not inherit Constant Steer example values or outputs into another experiment.
2. During authorized preparation, check the selected saved baseline against the shared inventory. Refresh changed/missing scopes and dependencies in place, reusing unchanged records. Preserve unsaved user work; saved records are not proof of effective runtime state. The current top-level `sm_car` hyperlink controls the complete maneuver command order. Verify temporary overrides, dependent calculations and effective readbacks.
3. Keep user-facing inputs in a small root `study_inputs.json`, read by MATLAB to derive cases. Include a root `rerun_study.m`, concise study-specific MATLAB code and reviewed shared-template snapshots. New execution uses a fresh dated study from the JSON and current saved project; completed results and prior approvals stay unchanged.
4. Present the concrete plan, historical previews, expanded cases, execution mode, requested outputs, implementation limits and shortest useful validation coverage. Validate one representative changed configuration to establish that the model runs; do not validate every value in a parameter-only sweep. Add validation cases only for changes requiring a different compiled model configuration, and explain that coverage in the plan. No full-length validation. Obtain approval, run only that short stage, and present its findings before obtaining separate full approval. Proceed within an approved stage without repeated routine confirmation. Material scope changes require updated review unless already authorized.
5. Use sequential execution on macOS. Windows requests must specify execution mode, and parallel support/isolation must be verified before use. The retained JSON implementation currently supports sequential Constant Steer with native throttle/braking; other maneuvers require matching verified setup/readbacks. Consult current runner notes for code awaiting runtime validation.
6. Retain only requested signal leaves and necessary metadata. Export readable light-mode PNGs and CSV metrics using explicit units/native signal timestamps. Treat `ModelStop` as completed at its actual time; label only roll/lateral-deviation causes supported by actual gated stop requests. Keep errors/interruptions incomplete, expose unequal windows and do not rank configurations or write a narrative report unless requested.
7. Verify real exports before removing study-owned previews, validation data and temporary execution copies under the workflow's retention rules. Keep the shared archive, final selected results, baseline, compact state and failed-stage transcripts. Do not automatically retry a failed study or change physics/solver settings to force completion.

Keep simulation scripts MATLAB-only; the separate offline inventory tools may remain Python. Detailed code/help conventions, JSON/wrapper behavior, approvals, stop evidence and cleanup are maintained in the workflow. No background automation is created by this skill.
