# Saved-file inspection tools

These Python tools read saved files without starting, connecting to, or executing MATLAB. They do not run project startup, mask code, callbacks, maneuver generation, model update, or simulation. Existing user files and the live MATLAB session are not modified. Generated inventory files are written under `SimulationStudies/inventory/saved/`.

The inspector also writes `fingerprints.csv` (Path, External, SHA256), a flat view of the saved-file identities for the MATLAB study scripts. External paths are absolute on the inspection host; project paths are relative. Refresh the inventory on a different execution host. The MATLAB simulation workflow does not invoke Python.

## Run

Use Python 3.10 or newer with `numpy`, `scipy`, `openpyxl`, and `h5py`. The initial inspection used the existing `/opt/anaconda3/bin/python` environment; no packages were installed. On another computer, select an existing Python environment with these dependencies.

From the project root:

```sh
python SimulationStudies/tools/inspect_saved_project.py --library-root /path/to/MATLAB/toolbox
```

On this Mac, the library root is `/Applications/MATLAB_R2026b.app/toolbox`. On Windows, pass the actual MATLAB toolbox directory in quotes. Add repeated `--library-root` arguments for other saved library folders. The default project root is derived from the script location, so it works across computers. The manifest records which library roots were actually inspected.

The inspection includes all saved project `.slx`, `.mdl`, and protected `.slxp` files, plus recursively referenced library/model definitions found under the project and supplied library roots. It includes inactive variant structures stored in those files. Library definitions are stored once and linked through dependency records; runtime library instances are not flattened or compiled.

Project scripts (`.m`, `.ssc`, `.mlx`), workbooks (`.xlsx`, `.xlsm`), MAT files and data dictionary/protected-code identities are indexed. `.git`, `work`, `slprj`, `spinfo`, hidden directories, Office lock files, and `SimulationStudies` outputs are excluded. Versioned backup extensions such as `.original`, `.r2025b`, and `.asv` are not treated as active model sources. See the manifest for actual coverage.

## Small values and provenance

Scalars and arrays with at most 100 elements are retained when readable. Larger MAT arrays retain their shape/class/source; large worksheet grids retain dimensions and source coordinates. Stored MATLAB expressions and source statements are retained as text for traceability, even if they describe a larger value. Code is never evaluated to derive a value.

- `literal`: simple numeric, boolean, string or matrix literal recognized syntactically.
- `source_assignment`: a lexical source statement, with scope and line number; not an effective workspace value. Conditional execution and dynamically created fields are not resolved.
- `excel_import_candidate`: workbook/sheet/cell and a candidate pre-assembly field. The actual importer, nested sheet/table handling, and assembly functions must be traced for a study input.
- `mat_value`: saved data, not proof that it is loaded into the model's workspace.
- `mat_opaque_object`: name/class identified, but MATLAB object properties require a separate decoder or later authorized MATLAB inspection.

Opaque SLX `.mxarray` members, proprietary dictionaries, protected code and missing references remain in the gap/dependency records. They are not silently counted as fully decoded variables. Active variants, evaluated mask values, callbacks, and runtime output availability cannot be certified by this offline inventory.

## Look up a target

```sh
python SimulationStudies/tools/query_saved_inventory.py Proportional_P --kind variables --limit 5
python SimulationStudies/tools/query_saved_inventory.py Vehicle.Chassis --kind parameters --limit 5
python SimulationStudies/tools/query_saved_inventory.py sm_car.slx --kind models
```

Start with `inventory/saved/README.md` and `models.json`. Detailed model JSON and JSONL indexes are gzip-compressed to reduce storage; the lookup command reads them directly. Use Python `gzip.open(path, 'rt')` and `json.load` to read a complete per-model record when needed. Source/output accesses are also indexed in `sources.json`. Compression preserves every exported record.

## Refresh and integrity

Every inspected file gets a SHA-256 fingerprint. Rerunning the inspector reuses unchanged model records when both their fingerprint and the inspector's own fingerprint/settings match. Source/data indexes are rebuilt from saved files, and references are resolved again against the supplied library directories. Changes to the inspector invalidate its model cache. The current `models.json` catalog identifies active records; it is authoritative over any unreferenced old files in the generated models directory.

Saved hashes cannot describe unsaved MATLAB state. The agent must compare the selected baseline against these fingerprints before relying on the inventory. Missing definitions remain explicitly missing, as requested by the user on 2026-10-22; do not substitute unrelated libraries or silently change the model.

## Verify

```sh
python SimulationStudies/tools/test_inspect_saved_project.py
python SimulationStudies/tools/verify_saved_inventory.py
```

Fixture checks cover SLX hierarchy/masks/branches, legacy MDL structure, safe literal recognition, nested MAT data and value limits, and Excel array-formula serialization. The verification command checks exported counts/readability, raw `sm_car` block declarations and current source hashes, writing `inventory/saved/verification.json`. These checks do not establish equivalence to a compiled Simulink model.
