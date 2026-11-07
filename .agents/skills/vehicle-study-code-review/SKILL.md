---
name: vehicle-study-code-review
description: "Independently review an identified Vehicle_Model study code, packaging, plotting or workflow checkpoint against its accepted scope. Use for static findings and re-review; read-only and not simulation approval."
---

# Vehicle Study Code Review

Follow [AGENTS.md](../../../AGENTS.md) and the [review procedure](references/procedure.md). The supervisor reviews files frozen by the implementer.

**Input:** accepted request/specification, file identities, author checks, previews/waiver and known gaps.
**Work:** trace requirements to implementation, examine scope/baseline/stage protections and relevant authoring conventions, and distinguish defects from missing runtime evidence.
**Handoff:** checkpoint-specific readiness, prioritized findings with locations/evidence, required fixes and limits.

Do not edit code or run simulations. Send corrections through the coordinator to the implementer, then review the revised checkpoint. Passing this skill does not authorize validation or full execution; actual results are checked by [run verification](../vehicle-study-run-verification/SKILL.md).

For a requested target-finding checkpoint, use [target definition](../vehicle-target-definition/SKILL.md), [candidate interface requirements](../vehicle-target-candidates/references/procedure.md#execution-interface-boundary) and [assessment](../vehicle-target-assessment/SKILL.md) as the standards for that changed capability. Check immutable reviewed inputs/code, scoped parameter authority, cumulative-change checks, budget/duplicate-dispatch controls, completion evidence and full candidate history. A documentation-only role/skill update does not require implementing or runtime-testing an adaptive runner.
