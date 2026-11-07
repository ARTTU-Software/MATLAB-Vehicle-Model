# Plotting and metrics procedure

Paths in code spans below are relative to the project root. Use selected historical results for analysis, or the shared archive for authorized layout previews. Do not prepare or simulate another study to replot existing results. Do not rewrite completed signals/state or retrofit missing stop evidence.


## Signals, metrics, and previews

Match previews to the requested axes, units, legends, grouping and table columns. Include PNG previews of the metric-table layout and keep any dummy CSV clearly historical. Repeated traces demonstrate layout only; do not predict new-case extrema or controller differences.

Export every study/preview PNG in light mode. Set the figure theme to light before creating plots (`theme(fig, 'light')`) and export with `BackgroundColor='white'`. A white figure background alone is insufficient: axes, titles, ticks, legends and annotations must also use the light theme. Do not change the user’s global MATLAB/desktop theme.

Resolve requested outputs against actual logging data. Existing plots are useful references, but do not assume all scenarios expose identical signals or that every script can be called unchanged.

Record signal paths, components, units/conversions, time windows, and any derived calculations. Unless the request specifies otherwise, use the full valid recorded interval, signed minima/maxima, and time on the x-axis; disclose these defaults in the plan. Clarify an ambiguous request for a “peak” when signed versus absolute magnitude affects interpretation.

Keep native time samples for simple overlays. Resampling or alignment by distance/event must be explicit. Flag missing signals, empty windows, nonfinite data, and incomplete runs instead of silently producing valid-looking metrics. Do not compare extrema from incompatible run durations without labeling that limitation.

Keep only signals used to generate the requested outputs, including necessary time axes, reference signals, and components used in derived metrics. Extract nested leaves rather than saving an entire bus because one leaf was requested. Save the selected data and compact metadata in MAT files; do not persist the entire workspace, full `SimulationOutput`, or unrelated Simscape logs by default. Reduce runtime logging only when it is verified not to remove required data or affect execution.

The sole reusable preview source is `SimulationStudies/preview_data/skidpad_workspace_2026-10-23.mat`, archived from the user's workspace. Load its `logsout_sm_car` Dataset and select the requested signals directly in memory, retaining each signal's own timestamps and applying documented unit conversions. Do not save separate signal subsets, compact preview MAT files, synthetic CSV sources or copies inside individual studies. Keep the one shared archive unchanged. Real study results still retain the selected signals needed for their requested outputs; this rule concerns preview data only. Read `preview_data/README.md` for paths, units and provenance limits. Label every preview as historical Skidpad data, not results of the requested study. If a requested signal is missing, disclose it and clarify the preview requirement. Do not generate previews for a study where the user has explicitly waived them.

After the full study completes and real artifacts have been verified, delete study-generated dummy PNG previews and replace dummy CSV tables with real results or remove the redundant dummy CSV copies. Keep the final simulation PNG plots and CSV tables. Keep the shared Skidpad archive for future studies. Restrict cleanup to recorded preview files created for that study, never a broad wildcard over final plots. Preserve the approved layout/column specification in the plan even after preview images are removed. For interrupted studies, keep previews only while they are still needed to resume/review; never mix them into real results.


## Plot starter

Use `runner/plot_template.m` as a reference for agreed plotting conventions. When preparing a new study, adapt it into that study's `code/plot_results.m` and rename the top-level function to `plot_results`. Change requested signals, units, grouping, labels, event markers and calculations to the actual experiment. The distinct starter name avoids shadowing a study's existing plotter.

Do not overwrite customized study plotting code or inherit example-only Constant Steer controllers, angles, signals or event markers. Input JSON and matching setup belong to [preparation](../../vehicle-study-packaging/SKILL.md); the shared starter does not establish another maneuver's support.


## Reusable output functions

Runtime extract_signals authoring belongs to [simulation code](../../vehicle-study-simulation-code/SKILL.md); this procedure defines which data are needed and how saved data are selected/processed. Use selected signal data and recorded configuration as function inputs, with requested signal paths, units, windows and grouping explicit. Separate metric calculations from figure/export operations so values can be checked independently. Avoid hidden dependence on the base workspace, today's model defaults or hard-coded paths. Apply the readability/help conventions in [simulation code](../../vehicle-study-simulation-code/references/procedure.md#matlab-readability).

Return clear artifact paths and warnings. Keep plots, legends and table rows tied to stable case IDs and effective recorded configurations. Reusing this function with a different supported sweep must not require editing numerical case values into the plotter.

For an existing-results request, reuse an unchanged plotter or create separately identified post-processing code without rewriting the reviewed execution code, selected signals or state. Missing evidence remains missing; do not simulate to fill it. No new study/baseline/inventory refresh is required.

## Check and hand off

Check calculations, dimensions, conversions, timestamps and exported files within the authorized scope. The supervisor uses [run verification](../../vehicle-study-run-verification/SKILL.md) for independent acceptance; author self-checks do not replace that review.

Return requested artifact paths, source case/data identities, applied metric definitions and limitations. Do not optimize, rank configurations or write a narrative report unless requested. [Packaging](../../vehicle-study-packaging/references/procedure.md#storage-and-retention) owns retained study evidence and final cleanup eligibility.
