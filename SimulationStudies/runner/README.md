# Shared MATLAB study templates

This guide describes the existing shared template interfaces. [Packaging](../../.agents/skills/vehicle-study-packaging/SKILL.md) owns preparation/baselines/reruns; [simulation code](../../.agents/skills/vehicle-study-simulation-code/SKILL.md) owns authoring conventions; [execution](../../.agents/skills/vehicle-study-execution/SKILL.md) owns launch approvals and cleanup. Adapted code and input records belong in study folders, not additional runner subfolders.

| Shared file | Purpose |
| --- | --- |
| `prepare_study.m` | Check shared inventory and combine compatible study code with current templates in a new dated study |
| `rerun_study.m` | Study-root wrapper: prepare from JSON or dispatch one approved batch stage |
| `run_study.m` | Execute reviewed fixed cases in isolated project copies and record status/failure logs |
| `study_scope.m` | Hash reviewed wrapper, JSON, plan, baseline and copied code |
| `file_sha256.m` | Calculate file hashes |
| `plot_template.m` | Constant Steer plotting starter |
| `study_inputs.json` | Simplified Constant Steer input starter |

Functions include MATLAB help; use `help prepare_study` with this folder on the path. The wrapper executes at a study root beside its JSON.

## Study-specific examples

The [JSON-capable Constant Steer implementation](../studies/2026-10-25_123418_016_constant-steer-default-vs-flc-dyc-v3/code) supplies these functions:

| Function | Implementation responsibility |
| --- | --- |
| `study_config.m` | Read simplified JSON, expand angle/controller pairs, supply fixed settings and `cfg.projectFunctions` |
| `simulate_run.m` | Maneuver setup, temporary overrides, simulation and selected metadata |
| `check_inputs.m` | Effective-input and controller/estimator readbacks |
| `extract_signals.m` | Selected signal paths, units and native times |
| `plot_results.m` | Requested PNG/CSV outputs |
| `write_study_plan.m` | Scenario commands, outputs, cases and approval scope |

The [completed comparison](../studies/2026-10-24_214028_994_constant-steer-default-vs-flc-dyc-v3/) preserves its historical code/results. Its root wrapper references the newer compatible implementation for new JSON preparation; that dependency must remain valid when reorganizing retained studies. Historical plans/settings/waivers are evidence for those studies, not instructions or approvals for new ones.

[RAMP_STEER_REFERENCE.md](RAMP_STEER_REFERENCE.md) preserves earlier command examples and generator caveats. They are not maintained runtime-validated runners.

## Prepare and adapt a study

A compatible source contains the six functions above. Its wrapper adds the shared runner and calls:

```matlab
newStudy = prepare_study(projectRoot, inputFile, sourceCodeFolder);
```

When `sourceCodeFolder` is the `code/` folder beside `inputFile`, omit the third argument. Preparation copies the selected JSON, compatible implementation and current shared templates, checks saved source hashes, saves a fresh baseline/pending-review state and writes the plan. It does not initialize the project, generate previews or simulate. Later stage calls use the reviewed local snapshots.

## Constant Steer input contract

The retained JSON-capable reader uses only `name`, `execution`, `model`, `maneuver`, `steeringAngles_deg`, `controllers` and `stopTime_s`. MATLAB supplies `SSVT_FSAE.prj`, timezone `Europe/Bucharest`, native throttle/braking and a 1 s validation duration; it expands every angle/controller combination. The [retained implementation](../studies/2026-10-25_123418_016_constant-steer-default-vs-flc-dyc-v3/) is the matching example, not a universal study schema.

This retained Constant Steer reader supports native throttle/braking and sequential execution. Other maneuvers need a compatible study-specific reader and verified setup/readbacks; unsupported settings must stop instead of silently reusing this example. Input strings and numerical values are data, never executable MATLAB commands.

## Rerun from the JSON

Preparation-only call from a JSON-capable study folder:

```matlab
newStudyFolder = rerun_study();
```

After review and actual short-validation approval, start a fresh batch process in the NEW folder:

```sh
matlab -sd "<new-study>" -batch "rerun_study('validation','<actual approval>')"
```

After presenting validation findings and obtaining separate full approval:

```sh
matlab -sd "<new-study>" -batch "rerun_study('full','<actual approval>')"
```

These are syntax examples, not approval records. Current runner support is **fixed-case sequential execution**; parallel and adaptive candidate dispatch are not implemented. Saved progress exposes stage/case boundaries, not continuous simulated-time telemetry.

The configuration reader selects validation IDs through `cfg.validationRunIDs`; the runner defaults to the first run when absent. Use the [planning coverage rule](../../.agents/skills/vehicle-study-planning/SKILL.md) to select IDs for new studies rather than copying historical per-case validation plans.

## Plot, rerun and input starters

The shared plot/JSON examples are Constant Steer-specific, not universal schemas or required outputs. [Plotting](../../.agents/skills/vehicle-study-plotting/references/procedure.md#plot-starter) owns plotter adaptation; [packaging](../../.agents/skills/vehicle-study-packaging/references/procedure.md#input-and-plot-starters) owns input adaptation and preservation of customized files. The distinct `plot_template` name prevents MATLAB path shadowing of a study's plotter.

The root wrapper template is installed by preparation. To use the shared JSON starter with compatible source code, supply both paths:

```matlab
inputFile = fullfile(projectRoot,'SimulationStudies','runner','study_inputs.json');
newStudy = prepare_study(projectRoot,inputFile,sourceCodeFolder);
```

Preparation copies the supplied implementation; it does not silently replace a customized plotter with the shared starter. Another maneuver needs matching setup/readbacks from the [saved mappings](../MODEL_WORKSPACE.md).
