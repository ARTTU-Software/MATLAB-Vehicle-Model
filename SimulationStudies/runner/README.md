# Shared MATLAB study templates

This folder holds one maintained set of shared templates, including plotting and input-JSON starters based on the working Constant Steer study. Do not keep separate per-study implementation folders here. Adapted study code and editable study inputs belong in `studies/<date-name>/`.

| Shared file | Purpose |
| --- | --- |
| `prepare_study.m` | Check the shared inventory and combine source study code with current shared templates in a new dated study |
| `rerun_study.m` | Template for each study's root wrapper; prepare from JSON or dispatch one approved batch stage |
| `run_study.m` | Execute reviewed cases in isolated project copies, record state/failure logs and perform cleanup |
| `study_scope.m` | Hash the wrapper, JSON, plan, baseline and copied code included in review |
| `file_sha256.m` | Calculate file content hashes |
| `plot_template.m` | Constant Steer plotting starter: light-mode yaw rate, lateral acceleration, sideslip and peak CSV |
| `study_inputs.json` | Simplified Constant Steer input starter to copy and adapt for a new study |

All functions include MATLAB help with arguments, outputs, side effects and contextual call examples. Use `help prepare_study` with this folder on the path. The wrapper template belongs at a study root when executed, beside its JSON.

## Study-specific examples

The documented JSON-driven Constant Steer implementation is [the newer study's code](../studies/2026-10-25_123418_016_constant-steer-default-vs-flc-dyc-v3/code). It supplies:

- `study_config.m`: read the simplified JSON and expand angle/controller pairs. Fixed project settings and `cfg.projectFunctions` remain here.
- `simulate_run.m`: exact maneuver setup, temporary overrides, simulation and selected metadata.
- `check_inputs.m`: effective-input and controller/estimator readbacks.
- `extract_signals.m`: requested logged paths, units and native times.
- `plot_results.m`: light-mode PNGs and the requested CSV metrics.
- `write_study_plan.m`: scenario-specific commands, outputs, run list and approval scope.

The [completed comparison](../studies/2026-10-24_214028_994_constant-steer-default-vs-flc-dyc-v3/) retains its historical code, results and known limitations. Its root wrapper explicitly borrows the newer compatible implementation for JSON preparation; it does not replace that historical execution code. If a referenced study is removed, first update wrappers that use it to another retained compatible implementation.

Earlier unique Ramp Steer commands and generator caveats are retained in [RAMP_STEER_REFERENCE.md](RAMP_STEER_REFERENCE.md). Per-scenario runner folders and obsolete duplicate scripts have been removed.

## Prepare and adapt a study

Read `../WORKFLOW.md`, `../MODEL_WORKSPACE.md` and relevant earlier study files before adapting code. Learn from their input readbacks, stop handling, comments and failures, but check mappings against the current saved model; historical settings are not current runtime proof. Preserve user edits and do not carry earlier approvals forward.

A source study normally contains all six study-specific functions above. Its wrapper adds the shared runner, then calls:

```matlab
newStudy = prepare_study(projectRoot, inputFile, sourceCodeFolder);
```

With the default source layout, `sourceCodeFolder` is the `code/` folder beside `inputFile`, so the third argument can be omitted. The new study receives its own adapted implementation and a snapshot of the shared templates, allowing stage execution to remain fixed after review even when shared templates later change. Those reviewed snapshots belong in studies; they are not per-study copies kept in this shared folder.

Preparation checks source hashes, saves a fresh baseline and pending-review state, and writes the study's plan. It does not initialize the project, generate previews or simulate. A source or code edit invalidates earlier review; prepare/review the revised study. Do not edit completed result data.

## Rerun from the JSON

From a JSON-capable study folder:

```matlab
newStudyFolder = rerun_study();
```

Review the new plan and historical Skidpad previews. After actual approval, start a fresh MATLAB process in the NEW folder:

```sh
matlab -sd "<new-study>" -batch "rerun_study('validation','<actual approval>')"
```

Review the short validation and obtain separate approval before another fresh process:

```sh
matlab -sd "<new-study>" -batch "rerun_study('full','<actual approval>')"
```

Only sequential execution is implemented. Stage calls use that study's reviewed local snapshots and study code. No automatic retry or approval carryover is introduced. Keep failure transcripts only in `logs/`, remove temporary project copies, and remove validation data after successful full export. Shared inventory and historical Skidpad preview data stay outside studies. Read prior study notes for limits; new stop-flag logging still needs approved runtime validation.

## Plot, rerun and input starters

Each study must adapt its input JSON, matching MATLAB reader, selected signals, plot layout and metrics to the actual request. The shared Constant Steer files are references for agreed conventions, not a fixed schema, required signal list or universal plot arrangement. Do not carry steering sweeps, controller choices, maneuver markers or outputs into an unrelated study merely because they appear in the example. Keep only the user-facing inputs needed for that study.

Reuse the discussed conventions where applicable: readable MATLAB sections/help, native signal timestamps and explicit units, light-mode PNG exports, CSV metrics, selected-signal storage, and evidence-based roll/lateral-deviation stop labels. Follow the current model's maneuver commands and the user's requested comparisons.

`plot_template.m`, `rerun_study.m` and `study_inputs.json` are the shared starters. The plot and JSON are based on the working Constant Steer implementation. Keep one copy of each shared starter here, then adapt them within a study; do not add a runner subfolder for each study.

Copy `plot_template.m` into the study's `code/plot_results.m` and rename its top-level function to `plot_results`. Adapt requested signals, units, panel grouping, labels, maneuver event markers and metrics there. The starter retains light-mode figures and white PNG backgrounds. Its distinct template name prevents it from shadowing an existing study's `plot_results.m` when the runner is on the MATLAB path.

Copy the input starter to the new study root and edit only the needed input values. The simplified fields match the current Constant Steer study reader; another maneuver still needs its own verified setup and checks. Existing study JSON and plot code take precedence and are never automatically overwritten by these starters.

The root wrapper template is already installed by preparation. To prepare from the shared JSON starter using a compatible prior study implementation, supply both paths explicitly:

```matlab
inputFile = fullfile(projectRoot,'SimulationStudies','runner','study_inputs.json');
newStudy = prepare_study(projectRoot,inputFile,sourceCodeFolder);
```

`sourceCodeFolder` is the compatible prior study's `code/` folder, adapted by the agent for the new request. Preparation copies that implementation and the selected JSON; it does not silently replace the study's plotter with the starter. See the retained studies and model workflow for examples and known limitations.
