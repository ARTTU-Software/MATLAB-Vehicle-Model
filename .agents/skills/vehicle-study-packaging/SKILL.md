---
name: vehicle-study-packaging
description: "Package a Vehicle_Model study with editable sweep inputs, explicit cases, fresh baseline, local code snapshots and rerun entry point. Use for authorized preparation, fresh reruns or verified final retention; code authoring is a separate skill."
---

# Vehicle Study Packaging

Follow [AGENTS.md](../../../AGENTS.md) and the [packaging procedure](references/procedure.md). The implementer owns assigned study files.

**Input:** accepted specification, current saved mappings and compatible authored code.
**Work:** retain editable JSON, exact expanded cases, a fresh saved baseline and dependency hashes, reviewed local code, the plan and a clear preparation-only rerun entry point. Arrange historical previews through [plotting](../vehicle-study-plotting/SKILL.md).
**Handoff:** a concrete, reproducible package and identified checkpoint for [code review](../vehicle-study-code-review/SKILL.md).

Read [simulation code](../vehicle-study-simulation-code/SKILL.md) only when authoring those functions. Packaging does not execute startup/maneuvers/compile/simulation or grant validation/full approval. A later rerun uses a new preparation and current saved sources. Final retention follows verification; completed evidence remains historical.

For target finding, package the accepted [target definition](../vehicle-target-definition/SKILL.md) and budget instead of claiming all future adaptive values are known. The [candidate interface requirements](../vehicle-target-candidates/references/procedure.md#execution-interface-boundary) apply only to separately requested implementation; the current runner is fixed-case. Preserve every evaluated candidate and the [required history](../vehicle-target-assessment/references/procedure.md#preserve-all-evaluated-attempts); they are not superseded study attempts to delete. Keep reviewed specification/code immutable and use only an implemented reviewed runtime record for candidate inputs/results.
