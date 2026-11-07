---
name: vehicle-study-execution
description: "Execute explicitly approved short validation or full Vehicle_Model study stages using reviewed local code and baseline. Use for stage execution and outcome review, not preparation or implicit retries."
---

# Vehicle Study Execution

Run only the authorized stage under [AGENTS.md](../../../AGENTS.md). Read [the execution procedure](references/procedure.md) and the selected study's reviewed plan/configuration before dispatch.

Require actual short-validation approval, report its outcome, then require separate full approval. Keep stage names `validation` and `full` explicit. Run each approved stage in a fresh batch process; preserve the user's interactive MATLAB work. Current runner execution is sequential.

Verify reviewed scope, baseline and dependencies; read back effective inputs for every run. Keep validation separate from final study metrics. Stop at the first failure under the existing reviewed policy; do not retry or alter physics/solver settings automatically.

Use [monitoring](../vehicle-study-user-updates/SKILL.md) only when enabled, and [parallel capacity](../vehicle-study-parallel-capacity/SKILL.md) only for requested/needed assessment. Capacity measurement uses a real approved full case, never an extra full-length validation. Neither skill grants execution authority.

Present completion/failure, effective inputs, actual durations, warnings and limitations. Stop at the validation approval boundary. Use [run verification](../vehicle-study-run-verification/SKILL.md) for export checks and [packaging](../vehicle-study-packaging/SKILL.md) for final retention.

The [team contract](../../../AGENTS.md#study-team) assigns stage launches to the coordinator, [code authoring](../vehicle-study-simulation-code/SKILL.md) to the implementer, and [checkpoint review](../vehicle-study-code-review/SKILL.md)/[run verification](../vehicle-study-run-verification/SKILL.md) to the supervisor. A role assignment or passing review does not authorize execution.

For requested target finding, the [target-search handoff](../../../AGENTS.md#target-finding-handoff) distinguishes known physical-limit candidates from technical failures and permits adaptive proposals within approved authority/budget. This does not change current fixed-case stage dispatch. A supported reviewed candidate interface must exist before adaptive execution; do not mutate hashed inputs or loop existing stage calls to bypass that requirement.
