---
name: vehicle-target-candidates
description: "Propose initial and adaptive Vehicle_Model parameter candidates within a defined target-search policy and budget. Use after target definition or verified feedback; no simulation launches or code/state edits."
---

# Vehicle Target Candidates

Follow [AGENTS.md](../../../AGENTS.md) and the [candidate procedure](references/procedure.md). The target finder proposes; the coordinator controls execution.

**Input:** resolved [definition](../vehicle-target-definition/SKILL.md), model evidence, verified assessments and coordinator-supplied budget status.
**Work:** propose an initial or next candidate, justify changes and check incremental/cumulative authority.
**Handoff:** candidate identity, complete values/units, deltas, rationale/evidence and any approval question.

Use [assessment](../vehicle-target-assessment/SKILL.md) before adapting to a result. Do not launch runs, change hashed inputs, add parameters or improvise adaptive support in the fixed-case runner. Return a stopping condition when required.
