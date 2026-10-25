# Saved-file inventory

Generated: 2026-10-24T16:57:45.422357+00:00

Offline inspection only. MATLAB was not accessed; no project code was executed.

## Coverage

- models and libraries: **151**
- saved blocks: **44,161**
- connections: **34,858**
- variable records: **14,805**
- parameter records: **184,326**
- source files: **317**
- workbooks: **8**
- references: **6,277**
- missing references: **15**
- ambiguous references: **0**
- gaps: **166**

## Searchable records

- `models.json`: model/library catalog; `models/*.json.gz`: compressed JSON hierarchy, block parameters, masks, connections, callbacks, algorithms and metadata.
- `parameters.jsonl.gz`: block/mask parameter lookup and candidate workspace references.
- `variables.jsonl.gz`: source assignments, saved MAT structures/values, spreadsheet field candidates.
- `sources.json`: function signatures, dynamic operations and logging-access statements with line numbers.
- `workbooks.json`: sheets, small sheet values and vehicle importer rows.
- `signals.jsonl.gz`: stored port/logging metadata; runtime signal contents are unverified.
- `dependencies.json`: referenced definitions, candidate files and unresolved references.
- `gaps.json`: opaque records, errors and coverage limitations.
- `fingerprints.json`: SHA-256 identities of inspected saved files; `fingerprints.csv` is the flat MATLAB-readable view.

## Interpretation

- No base workspace initialized or inspected; source assignments are not runtime values.
- No compiled variant resolution, mask evaluation, solver execution, or signal availability validation.
- Offline SLX/MDL parsing does not expose undocumented defaults or opaque MATLAB serialized objects.
- References point to definition records; library instances are not flattened or evaluated.
- Lexical source indexing does not prove execution order, control flow, dynamic fields, or complete variable coverage.
- MAT files may contain old results; saved contents are not assumed to be current model inputs.
- Path precedence and library forwarding are not resolved using MATLAB; candidates remain explicit.

Use `tools/query_saved_inventory.py` to search the compressed indexes without unpacking them. JSON compression preserves all records. The count covers all project model files plus recursively discovered library definitions, not the number of instantiated blocks in sm_car.
