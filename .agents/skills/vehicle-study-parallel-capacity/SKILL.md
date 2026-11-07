---
name: vehicle-study-parallel-capacity
description: "Assess local parallel-simulation eligibility and measured RAM capacity for Vehicle_Model on macOS or Windows. Use for concurrency recommendations and confirmed unused-session handling; it does not implement a parallel runner or authorize profiling simulations."
---

# Vehicle Study Parallel Capacity

Assess resources under [AGENTS.md](../../../AGENTS.md). Read [the capacity procedure](references/procedure.md) for memory measurements, limits, eligibility evidence and session handling.

At 16 GiB installed RAM or less, recommend sequential execution. Above 16 GiB, measure the first approved full study case sequentially; it remains a real study result. Never add a full-length validation or start a run just to estimate capacity.

Report the memory-based ceiling separately from verified executable capacity. Check CPU, workers/licenses and independent model/filesystem setup. Current runner executable capacity is **one** on macOS and Windows; a higher hardware estimate does not enable parallel execution.

Before closing an interactive MATLAB session, identify it, establish it is not the study coordinator, and ask once whether it is unused and may close. Preserve unsaved work, close only that confirmed session gracefully, and remeasure available RAM. Low CPU usage is insufficient evidence; never force-close it.

Missing measurements or unverified worker isolation mean “unknown/not verified,” not permission to guess or launch parallel jobs.

In the [study team](../../../AGENTS.md#study-team), the designer assesses theoretical eligibility within its saved-file/environment scope; the supervisor may observe the first approved full case for measured capacity. The coordinator handles user decisions and any authorized session closure. Neither subagent launches profiling runs or parallel workers.

**Handoff:** installed/available RAM, measurement coverage/reliability, memory ceiling, other bounds, eligibility gaps and current executable limit. [Parallel setup](../vehicle-study-parallel-setup/SKILL.md) consumes these findings only for a separately requested implementation; it is not part of this assessment.
