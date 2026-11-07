# User updates and timed monitoring procedure

**Input:** study stage/identity, agreed preferences and verified observations. **Output:** clear user-facing updates and, only when enabled, one temporary stage-bound monitor owned by the coordinator.

## Resolve the agreement

During actual study planning, if monitoring is unspecified ask whether it is needed; do not treat silence as enablement. If declined, record that choice and create nothing. If enabled, ask only for missing preferences:

- Recurring interval (for example every 10 minutes) or specific dated clock times.
- Timezone, using the user's current local timezone (`Europe/Bucharest` in this project) unless specified otherwise. Resolve ambiguous dates or daylight-saving clock times.
- Requested content: concise status; status plus resources such as RAM/process count; or status plus already available completed-run plots/metrics. Accept custom requests and disclose unavailable telemetry.

Record the agreed enablement, schedule/timezone and output content in the study plan **before** its reviewed scope is finalized. Reuse those choices across this study's approved stages without repeating routine questions. Runtime scheduling must not edit the hashed plan/JSON/code or completed execution state; keep the monitor ID in the chat/scheduler metadata.

If monitoring is requested after scope review or during a running stage, record the agreement in the chat without modifying reviewed files. Include it in the next newly reviewed preparation if one is needed; monitoring alone does not require a new simulation study.

A documentation rehearsal or maintenance request describes this setup only. Preparation or reviewing the skill does not itself enable a live monitor. Creating one is appropriate for the agreed authorized stage, and is not approval to start that stage.


## Arrange the temporary follow-up

Under the [study team](../../../../AGENTS.md#study-team), the coordinator owns scheduler creation/update/shutdown in the main user chat. The supervisor returns observations, suggested update content and terminal-stage notices to the coordinator; it does not schedule a monitor in its own subagent chat. Keep one monitor per study/stage and reuse its identity across active observation and scheduled wakeups. If the supervisor becomes unavailable, the coordinator can read the same evidence directly without duplicating the schedule.

1. Discover the current Codex `automation_update` tool and follow its live schema. Prefer a temporary heartbeat attached to the main user chat; use its view/update capabilities to avoid a duplicate for the same study/stage. Do not create a new chat or standalone job unless requested.
2. Bind it to the exact study folder, stage and reviewed identity. Include the observed sources it may read, agreed output content, update cadence and stop boundaries. Keep delivery/mute settings in the tool's notification policy rather than prose overrides.
3. Express the requested schedule through supported tool fields, never raw automation directives, an OS cron workaround or an invented API. If the requested cadence or clock schedule is unsupported, explain and resolve an alternative before creation. Do not silently round it or claim exact delivery guarantees.
4. Explicit recurring progress updates must still report a concise “unchanged” status at the agreed times. When the user instead requests change-only monitoring, stay quiet while unchanged/non-actionable. Respect the user's delivery preferences.
5. Retain the returned monitor identity for shutdown. Confirm its actual saved schedule and study/stage target. A monitor depends on the host/app being available; it does not keep the machine awake.


## Compose an evidence-based update

Obtain current observations through [run verification](../../vehicle-study-run-verification/SKILL.md); reuse the supervisor's fresh evidence or let the coordinator read the same sources. Keep evidence collection and its reliability rules in that skill.

Use this compact order when fields are available: stage and current case; completed/failed counts with validation separate; elapsed wall time and observation timestamp; requested resources or completed-run artifacts; issues, limitations or required user action. Include units and source limitations for resources. Custom content replaces the default format when agreed.

Say when nothing has changed at an explicitly requested periodic update. Mark stale/unavailable evidence clearly. Do not turn case counts into within-case percentage, or claim an ETA without comparable timing evidence. Do not attach partially written results as completed artifacts.

Code-review updates identify the reviewed checkpoint, material finding and next correction/review step. Simulation updates identify the authorized stage and observed evidence. Consolidate subagent messages into the main user conversation; subagents do not conduct separate interviews or announce approval.

## End at the stage boundary

On observing stage completion, failure, user cancellation, or a wait for approval, send the appropriate final status and deactivate/remove this temporary monitor using its returned ID. In delegated observation the supervisor reports that boundary to the coordinator, which performs the scheduler shutdown; a scheduled wakeup in the main chat follows the same rule directly. At validation completion, report the validation result/limitations and required full approval; do not schedule execution.

If the user later authorizes the next stage, use the existing agreement to arrange a stage-bound monitor again without duplicates. For changed preferences update the existing targeted monitor and preserve unrelated automations. Do not leave a recurring heartbeat after the stage ends or archive the chat automatically.


## Handoff and boundaries

The supervisor returns observations and notices to the coordinator; the coordinator delivers updates and owns the saved monitor ID, creation and shutdown. If a persistent scheduling tool is unavailable, state that updates cannot continue automatically after the chat turn. Do not claim a live subagent provides that persistence.

Neither timed updates nor an urgent notice authorize launch, retry, stop, mode changes or another stage. Declining timed monitoring prevents scheduled updates; ordinary stage findings and actionable issue notices remain part of the study workflow.
