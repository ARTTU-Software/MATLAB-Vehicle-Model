---
name: vehicle-study-parallel-setup
description: "Design and author a Vehicle_Model parallel simulation implementation only when requested, with worker initialization, isolated files/workspaces and bounded dispatch. This skill does not make the current sequential runner parallel or authorize workers or simulations."
---

# Vehicle Study Parallel Setup

Follow [AGENTS.md](../../../AGENTS.md) and the [setup procedure](references/procedure.md). The implementer owns assigned code; the designer supplies eligibility and the supervisor reviews evidence.

**Input:** an explicit parallel-implementation request, accepted execution policy, compatible case specification and [capacity findings](../vehicle-study-parallel-capacity/SKILL.md).
**Work:** verify the intended worker method and dependencies, author isolated worker/case setup and bounded dispatch, preserve case provenance and stage/failure controls.
**Handoff:** a static implementation checkpoint, unsupported items and proposed short-validation checks for [code review](../vehicle-study-code-review/SKILL.md).

The current project runner supports sequential execution only. Loading or adding this skill does not change that fact. Do not implement a new runner merely because the user asks for a capacity estimate. Worker/runtime checks need an implemented reviewed path and explicit approved short-validation scope; the coordinator launches them.
