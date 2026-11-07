# Target-finding agent guide

The optional [target finder](../.codex/agents/vehicle_study_target_finder.toml) and its skills are configured for one numerical target plus successful maneuver completion. This former plan is now navigation; current procedures have one owner below.

| Work | Owning instruction |
| --- | --- |
| Role coordination, concurrency and approvals | [Root target-finding handoff](../AGENTS.md#target-finding-handoff) |
| Acceptance, parameter authority and budget | [Target definition](../.agents/skills/vehicle-target-definition/SKILL.md) |
| Initial/adaptive proposals and execution-interface requirements | [Candidate selection](../.agents/skills/vehicle-target-candidates/SKILL.md) |
| Verified outcome interpretation, final parameters and complete history | [Target assessment](../.agents/skills/vehicle-target-assessment/SKILL.md) |

The specialist consumes designer mappings; the implementer authors requested code, the supervisor verifies evidence, and the coordinator owns execution. General minimization and multiple numerical targets remain deferred.

The current runner supports fixed sequential cases only. Adaptive dispatch still requires separately requested, reviewed implementation under the [candidate interface boundary](../.agents/skills/vehicle-target-candidates/references/procedure.md#execution-interface-boundary). Adding or maintaining these instructions does not implement that support or authorize simulations.
