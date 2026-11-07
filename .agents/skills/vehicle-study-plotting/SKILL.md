---
name: vehicle-study-plotting
description: "Create historical Vehicle_Model layout previews and reusable saved-data selection, metric, plot and export functions, or replot saved results. Use for requested PNG plots and CSV tables; independent acceptance belongs to run verification."
---

# Vehicle Study Plotting

Follow [AGENTS.md](../../../AGENTS.md) and the [plotting procedure](references/procedure.md). The implementer authors saved-data selection, metrics, output code and requested artifacts. [Simulation code](../vehicle-study-simulation-code/SKILL.md) owns extraction from live simulation outputs into retained selected-result files.

**Input:** requested outputs/layouts, exact signal definitions and authorized historical or completed data.
**Work:** define units, native timestamps, metric windows and calculations; produce reusable MATLAB output functions, light-theme PNGs and labelled CSV tables. Historical previews demonstrate layout only.
**Handoff:** artifacts, source identities, metric definitions, checks and limitations for [run verification](../vehicle-study-run-verification/SKILL.md).

Existing-results analysis enters here directly, without new preparation or current-model discovery. Keep completed execution records unchanged. The shared preview archive stays shared. Remove only identified study previews after verified full results; [packaging](../vehicle-study-packaging/SKILL.md) owns overall retention.
