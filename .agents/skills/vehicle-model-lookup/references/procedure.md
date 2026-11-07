# Saved inventory procedure

Paths in code spans below are relative to the project root. See [tool mechanics](../../../../SimulationStudies/tools/README.md) for commands and indexing limits.

## Scope and lookup

This procedure applies only within authorized saved-file discovery/preparation. A Markdown rehearsal explains it without performing it. Offline gaps never authorize accessing MATLAB. Runtime-only fields stay pending until an appropriately authorized stage; callbacks and output discovery must not be triggered to fill static gaps.

Use `MODEL_WORKSPACE.md` as the readable entry point and `inventory/saved/manifest.json` with the linked JSON/JSONL records as the authoritative generated saved-file inventory. `inventory/saved/README.md` is its generated coverage summary. Historical live-session observations are separate and must not be treated as saved-file values. Use `tools/query_saved_inventory.py` for targeted searches.

The user requested all accessible saved block/library contents and variables, with small values retained (up to 100 elements). Missing definitions remain explicitly marked as missing; no substitute libraries or model edits are authorized by inventory generation. See `tools/README.md` for excluded generated/backup files, opaque formats, and static-indexing limits.

Treat this saved inventory as the first lookup location for model structure, workspace structure, configuration, inputs and outputs. Build a complete structural inventory once, filling explicitly recorded gaps as needed. Before each later study, read it first and compare its baseline/configuration identity and dependency fingerprints with the selected state. Where a reliable unchanged fingerprint covers a recorded hyperlink or model section, reuse that record; when it changes, re-read the affected section and dependent mappings. A saved-file fingerprint does not establish the identity of unsaved model or workspace state. Broader inspection is needed only when changes or missing coverage prevent a reliable targeted refresh.

Recheck selected saved mappings during authorized preparation; effective runtime values are checked during approved validation/execution. Neither requires rediscovering the whole hierarchy. Save any corrected or newly discovered mappings back into `MODEL_WORKSPACE.md` before relying on them. A documentation-only rehearsal describes these future checks and does not perform live discovery.

Maintain a searchable input index using meaningful names and aliases from user requests. Each resolved entry must identify:

- Exact block path and parameter name, or full workspace structure/field path and scope (base, model, mask or dictionary).
- Source mapping: workbook/sheet/cell or importer field, parameter script/function, or maneuver generator and argument position.
- Class/shape, units, applicable configuration/variant, and observed value or expression with its verification date/status.
- Initialization/override order, calculations that depend on the input, callbacks that can reset it, effective-value readback, and temporary application/restoration method.

Index outputs by signal/container/leaf, component, units and transformations as well. Mark unknown fields explicitly instead of inventing a mapping. This is a saved lookup/configuration inventory, not an executable runner or a substitute for stage approvals.

Record from saved evidence or explicitly dated prior verification; mark unavailable runtime details pending:

- Inspection time, host OS, MATLAB release, project/model identity, loaded versus on-disk state, and whether observations were static or runtime verified.
- Model/subsystem hierarchy, referenced models and library links, active variants, block types, mask parameter names, parameter expressions, and applicable workspace scope.
- Relevant callbacks and startup order, including functions that reset data or generate derived parameters.
- Workspace variable/structure paths, classes, sizes, units where available, source files/import mappings, and dependencies. Identify saved base/model/mask workspace and dictionary definitions where readable; do not inspect live workspaces to fill gaps. Summarize large arrays rather than embedding them.
- Scenario hyperlink labels and exact command sequences, preparation inputs, and expected stopping behavior.
- Project maneuver sequence identity, generator/update commands from the hyperlink, arguments/units, target database/workspace fields, and how to read back the updated content.
- Logging containers and nested signal paths, components, units, availability by scenario/variant, and known transformations in plotting scripts.
- Content hashes or equivalent fingerprints for relevant models, scripts, and workbooks; current configuration identity and unsaved changes. A Git commit alone does not identify a dirty working tree.
- Unknowns, missing dependencies, and unverified assumptions explicitly.

Read saved callback/startup text to identify side effects without loading a model. Return runtime-only input/output gaps for [approved execution](../../vehicle-study-execution/SKILL.md) and [verification](../../vehicle-study-run-verification/SKILL.md); lookup does not launch MATLAB or trigger callbacks. Update the shared inventory in place, without a study copy. Keep preparation-time external dependency hashes in `state.mat` and baseline file hashes alongside the saved baseline, so later inventory refreshes do not alter the approved inputs.

## Targeted search sequence

1. Start with the user's physical meaning, units, maneuver and configuration. Read the relevant MODEL_WORKSPACE mapping before searching; list plausible variable aliases, block names and logged-signal names.
2. Query the smallest useful scope using the [lookup tool syntax](../../../../SimulationStudies/tools/README.md#look-up-a-target). The tool guide owns supported kinds, literal-search behavior, examples and coverage; an empty result is not proof the requested value is absent.
3. Inspect promising records and their provenance; search narrower aliases or follow the source importer/generator mapping. Distinguish a source value, an expression, a derived value, and the effective simulation target. Do not choose the first matching name without checking configuration and units.
4. Compare relevant saved-file fingerprints against the intended baseline. Reuse unchanged mappings. If stale or absent, return the precise affected source/scope and ask the coordinator for any needed discovery scope; an authorized assigned refresh may proceed without a new routine permission question.
5. Return input mappings with source, effective target/scope, values or expressions, units/shape, initialization/reset dependencies, override order, readback and restoration method. Return output mappings with container/leaf/component, units, transformation, native time axis and availability.
6. Mark each mapping saved-verified, stale, missing, ambiguous or runtime-pending, with evidence and limitations. Do not run MATLAB or a simulation to upgrade that status during lookup.

## Handoff

Use [simulation code](../../vehicle-study-simulation-code/SKILL.md) for applying resolved inputs and [packaging](../../vehicle-study-packaging/SKILL.md) for deriving a study baseline. Read only relevant mapping/history sections. A historical replot needs its recorded study data, not a refresh of today's model.
