---
name: vehicle-study-user-updates
description: "Resolve Vehicle_Model study monitoring preferences, compose evidence-based updates and arrange opt-in timed Codex follow-ups. Use for schedules, update content and stage-bound monitor lifecycle; run observation is a separate read-only skill."
---

# Vehicle Study User Updates

Follow [AGENTS.md](../../../AGENTS.md) and the [updates procedure](references/procedure.md).

**Input:** study/stage identity, user preferences and observations from [run verification](../vehicle-study-run-verification/SKILL.md).
**Work:** ask whether monitoring is wanted when unspecified, resolve missing schedule/timezone/content, record the agreement, and compose the requested updates. Explicit periodic updates continue even when unchanged.
**Handoff:** agreed preferences and concise evidenced messages; the coordinator alone creates and stops one temporary Codex monitor in the main user chat.

A supervisor returns findings but is not a persistent scheduler. Stop the monitor at completion, failure, cancellation or an approval boundary. Reuse preferences for a later authorized stage. No monitor is created for maintenance/rehearsal or when monitoring is declined; no update authorizes execution.
