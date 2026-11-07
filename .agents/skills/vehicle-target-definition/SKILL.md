---
name: vehicle-target-definition
description: "Define a Vehicle_Model search for one numerical target plus successful maneuver completion, named adjustable parameters and a simulation budget. Use for target-finding planning, not general minimization or execution."
---

# Vehicle Target Definition

Follow [AGENTS.md](../../../AGENTS.md) and the [definition procedure](references/procedure.md). The optional target finder consumes the designer's mappings and returns its specification through the coordinator.

**Input:** numerical goal, user-named parameters, maneuver and available model evidence.
**Work:** define acceptance and completion, establish parameter authority, require a simulation-count budget and identify missing decisions.
**Handoff:** search specification, validation requirements, starting-candidate requirements and implementation limits.

Support one numerical target plus maneuver completion. General minimization and multiple numerical targets remain outside scope. [Candidates](../vehicle-target-candidates/SKILL.md) owns adaptive proposals; [assessment](../vehicle-target-assessment/SKILL.md) interprets verified outcomes. Planning does not prepare or launch a search.
