---
name: vehicle-study-run-verification
description: "Observe approved Vehicle_Model runs and independently verify effective inputs, stage outcomes, stop evidence and completed exports. Use for validation findings, progress evidence or final result checks; read-only and no scheduling or execution control."
---

# Vehicle Study Run Verification

Follow [AGENTS.md](../../../AGENTS.md) and the [verification procedure](references/procedure.md). The supervisor normally performs these checks.

**Input:** accepted scope/identity, permitted stage and existing progress/result evidence.
**Work:** correlate coherent state/log/process evidence, verify effective inputs and completion, check requested signals and independently compare metrics/exports with real selected data.
**Handoff:** evidenced status, counts, input/output findings, limitations and readiness for the next review step.

Use [parallel capacity](../vehicle-study-parallel-capacity/SKILL.md) only for assigned resource measurements. Return observations to [user updates](../vehicle-study-user-updates/SKILL.md); creating a monitor and controlling execution belong to the coordinator. Never infer progress, ETA, stop cause or failure without supporting evidence.

For target searches, verify the numerical measurement and maneuver-completion evidence against [target definition](../vehicle-target-definition/SKILL.md), then send the findings to the coordinator for [target assessment](../vehicle-target-assessment/SKILL.md). Keep ModelStop completion separate from successful maneuver completion. Record known physical-limit evidence; do not call an unexplained stop a known limit. The target finder's interpretation does not replace these checks.
