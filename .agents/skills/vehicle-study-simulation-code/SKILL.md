---
name: vehicle-study-simulation-code
description: "Author reusable, readable Vehicle_Model study configuration, simulation, input-check and selected-signal extraction code from an accepted specification. Use for script creation or corrections; this skill does not launch simulation."
---

# Vehicle Study Simulation Code

Follow [AGENTS.md](../../../AGENTS.md) and the [authoring procedure](references/procedure.md). The implementer is the sole writer of assigned study code.

**Input:** resolved experiment, exact saved mappings, accepted JSON/case contract and assigned paths.
**Work:** adapt compatible MATLAB functions; implement complete maneuver/dependency order, temporary overrides, effective-input checks, selected extraction and clear errors. Keep sweep values in editable data and make code reusable for supported parameter sets.
**Handoff:** identified code checkpoint, static checks, pending runtime checks and limitations.

Use [packaging](../vehicle-study-packaging/SKILL.md) for inputs/baseline/wrapper, [plotting](../vehicle-study-plotting/SKILL.md) for output code and [code review](../vehicle-study-code-review/SKILL.md) for independent review. Parallel runner authoring belongs to [parallel setup](../vehicle-study-parallel-setup/SKILL.md) only when specifically requested. Authoring never grants stage approval.

When adaptive target-search code is specifically requested, consume [target definition](../vehicle-target-definition/SKILL.md) and the [candidate interface requirements](../vehicle-target-candidates/references/procedure.md#execution-interface-boundary). Keep measurement and maneuver-completion checks distinct, preserve immutable reviewed code/configuration and every candidate's provenance. Merely adding target-finder instructions does not authorize runner changes or simulation.
