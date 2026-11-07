# Vehicle Model project instructions

The main agent coordinates the three core study subagents and optional target finder below and remains the user's point of contact. Use the existing focused skills as shared procedures; select only those needed for the assigned work. Read a skill's `SKILL.md` directly if it is not listed among available skills. Ordinary model or MATLAB edits alone do not require the study workflow.

| Request | Project skill |
| --- | --- |
| Resolve exact saved input/output targets and freshness | [vehicle-model-lookup](.agents/skills/vehicle-model-lookup/SKILL.md) |
| Define experiment, cases, outputs and validation coverage | [vehicle-study-planning](.agents/skills/vehicle-study-planning/SKILL.md) |
| Estimate resource capacity and theoretical parallel eligibility | [vehicle-study-parallel-capacity](.agents/skills/vehicle-study-parallel-capacity/SKILL.md) |
| Author readable, reusable simulation and input-check functions | [vehicle-study-simulation-code](.agents/skills/vehicle-study-simulation-code/SKILL.md) |
| Save sweep inputs, baseline, package and fresh rerun entry point | [vehicle-study-packaging](.agents/skills/vehicle-study-packaging/SKILL.md) |
| Author plots/metrics, historical previews or saved-result exports | [vehicle-study-plotting](.agents/skills/vehicle-study-plotting/SKILL.md) |
| Author parallel worker setup only when implementation is requested | [vehicle-study-parallel-setup](.agents/skills/vehicle-study-parallel-setup/SKILL.md) |
| Independently review a frozen code/documentation checkpoint | [vehicle-study-code-review](.agents/skills/vehicle-study-code-review/SKILL.md) |
| Observe runs and verify effective inputs, status and exports | [vehicle-study-run-verification](.agents/skills/vehicle-study-run-verification/SKILL.md) |
| Resolve monitoring preferences and deliver timed user updates | [vehicle-study-user-updates](.agents/skills/vehicle-study-user-updates/SKILL.md) |
| Launch separately approved short-validation/full stages | [vehicle-study-execution](.agents/skills/vehicle-study-execution/SKILL.md) |
| Define a numerical target, completion evidence and search authority | [vehicle-target-definition](.agents/skills/vehicle-target-definition/SKILL.md) |
| Propose initial or adaptive target-search candidates | [vehicle-target-candidates](.agents/skills/vehicle-target-candidates/SKILL.md) |
| Interpret verified target outcomes and report candidate history | [vehicle-target-assessment](.agents/skills/vehicle-target-assessment/SKILL.md) |
| Maintain instructions, shared templates and tool guides | [vehicle-study-maintenance](.agents/skills/vehicle-study-maintenance/SKILL.md) |

## Study team

For a new study requiring design and implementation, delegate to the core project roles below; include the optional target finder when the request is to find parameters satisfying a target. This is standing authorization to use these subagents within the requested study scope; it is not authorization to prepare or simulate a study merely because the team is configured.

| Role | Ownership | Skills to load as needed |
| --- | --- | --- |
| Main agent / coordinator | User questions, scope/approval records, assignments, stage launches, monitor lifecycle and consolidated delivery | Planning, execution, user updates; maintenance for instruction/tool changes |
| [vehicle_study_designer](.codex/agents/vehicle_study_designer.toml) | Exact saved mappings, experiment specification, validation proposal and theoretical resource feasibility | Model lookup, planning, parallel capacity |
| [vehicle_study_implementer](.codex/agents/vehicle_study_implementer.toml) | Sole writer for assigned study code/package, previews and export functions; parallel code only when requested | Simulation code, packaging, plotting, conditional parallel setup |
| [vehicle_study_supervisor](.codex/agents/vehicle_study_supervisor.toml) | Read-only checkpoint review, run/result verification and evidence-based update summaries | Code review, run verification, user updates; parallel capacity for assigned measurements |
| [vehicle_study_target_finder](.codex/agents/vehicle_study_target_finder.toml) (optional) | Target definition, evidence-supported parameter proposals and interpretation of verified search outcomes | Target definition, candidates, assessment |

Skills are procedures, not additional agents. Each role loads only the capability needed for its current assignment. A skill's output is the next role's input; no role silently takes another role's write or execution authority.

Keep at most three subagents active alongside the coordinator, drawn from the four available roles. Schedule the optional specialist in phases; finish or hand off design work before activating it if all slots are occupied. Reuse their existing threads for corrections or later stages; subagents do not spawn their own teams. They inherit the selected model/reasoning settings and parent permissions. For a narrow lookup, replot, explanation or maintenance change, use only the relevant role, or handle it directly when delegation adds no useful work. Documentation-only rehearsals stay Markdown-only in every role.

Use the named custom role when the client exposes role selection. If the spawn tool has no custom-role selector, read the corresponding TOML and include its `developer_instructions` in the assignment. A task name alone does not load a role file. For a Markdown-only rehearsal, handle it in the coordinator by default; if delegation is explicitly requested, use role instructions already available in context or the Markdown role descriptions here, without opening TOML or other non-Markdown files. If delegation is unavailable, report that limitation and apply the same responsibilities in the main agent; do not claim a subagent review occurred.

### Handoffs and ownership

1. **Coordinator briefs the designer.** Supply the user's request and decisions, current permitted stage, relevant paths, known limitations and the required output. Subagents return unresolved questions to the coordinator, which asks the user only what remains material. No separate subagent interviews or approval requests; tool-enforced permission prompts still apply.
2. **Designer returns a specification.** Include objective, maneuver, parameter values/units/dependencies, expanded cases/count for fixed sweeps (or named parameters and target requirements for target finding), output paths/units/windows/layouts, duration, validation IDs/coverage, execution feasibility and open questions. Distinguish saved evidence from pending runtime checks. During authorized preparation only, the designer may be assigned sole ownership of shared inventory/mapping refresh; it does not create study code or inspect live MATLAB merely to fill gaps.
3. **Implementer builds the package.** After the coordinator resolves material design questions and preparation is authorized, assign the implementer the study folder and any expressly permitted shared-template files. It is the sole agent editing those files. The designer hands off shared mapping writes before implementation relies on them. The coordinator and supervisor do not make competing script edits.
4. **Supervisor reviews a completed checkpoint using code review.** The implementer supplies the affected paths, revision/file identity, static-check results, preview locations and known gaps. Freeze those files while the supervisor reviews them against the accepted specification. The supervisor reports readiness, evidence-backed findings with file locations, required corrections and limits; it does not edit the implementation. The coordinator routes fixes to the implementer and obtains review of the revised checkpoint. A review applies only to the files actually reviewed.
5. **Coordinator controls execution.** Present the concrete package/previews and resolve blocking findings before seeking short-validation approval. The coordinator launches each separately approved batch stage once; subagents do not launch simulations. A future supported target-search stage may dispatch sequential candidates under its reviewed adaptive policy as described below; do not emulate that behavior with the current fixed-case runner. After validation, the supervisor reviews its evidence and the coordinator presents the findings before requesting full approval. Passing code review is not execution approval. A code/scope change invalidates affected review and must follow the existing baseline/approval rules.
6. **Supervisor observes; coordinator acts.** The supervisor reports issues and agreed progress summaries to the coordinator, including terminal stage outcomes and requested RAM measurements when observable. It does not retry, kill, pause, reconfigure or advance a simulation, close MATLAB sessions, or modify execution state. The coordinator handles explicit stop requests and other authorized actions under the execution rules.
7. **Deliver outputs checked through run verification.** The implementer owns any requested export-code corrections; the supervisor checks completed signals/exports and reports discrepancies. The coordinator presents final artifacts and assigns allowed cleanup only after verification. Preserve completed state/data and do not retroactively edit a reviewed implementation to conceal a failure.

Keep handoffs concise and in the agent conversation or existing study plan/state where appropriate. Do not create duplicate plans, inventories, runners, review archives or new status schemas. For a prepared study, do not insert review notes or monitoring preferences into hashed files after review; retain later coordination in the chat.

### Target-finding handoff

Use the optional target finder only for a requested search for **one numerical target plus successful maneuver completion**. Full minimization/maximization and multiple numerical targets remain deferred. The designer supplies verified saved mappings; the target finder proposes and interprets; the implementer writes any requested code/package; the supervisor verifies; the coordinator owns user decisions and execution.

1. Resolve acceptance, maneuver-completion evidence, user-named parameters, small-step authority, known bounds and required simulation-count budget through [target definition](.agents/skills/vehicle-target-definition/SKILL.md). Wall-clock budget is optional. Do not demand a predetermined complete case list for an adaptive search.
2. Obtain a concrete reviewed implementation before short-validation approval, present validation findings, then obtain separate full-search approval covering the adaptive policy and budget. Agent instructions do not supply adaptive runner support.
3. Under a supported reviewed search stage, [candidate selection](.agents/skills/vehicle-target-candidates/SKILL.md) returns complete parameter proposals and rationale. The coordinator checks authority/budget and dispatches; the supervisor verifies actual inputs/results; [assessment](.agents/skills/vehicle-target-assessment/SKILL.md) interprets the outcome before the next proposal.
4. Small evidence-supported changes to named parameters need no per-candidate approval. Large or cumulatively large changes, uncertain limits and additional parameters return to the user through the coordinator. Known physical-limit outcomes can guide further candidates; technical errors/crashes or unresolved required evidence stop further dispatch.
5. Stop at the first verified match or budget exhaustion. Return final parameters and all evaluated attempts, or closest completed attempts with unmet requirements and proposed next steps. Candidate evaluations are evidence within one search, not superseded studies to discard. The coordinator stops any stage-bound monitor at success, exhaustion or a hold requiring intervention.

The target finder is read-only with respect to project/study/runtime files and cannot launch simulations or grant approvals. No role changes hashed specification/code/JSON between candidates. The current runner is sequential and fixed-case, with no reviewed adaptive candidate interface; implementing that interface is separate requested work. Until it exists, the optional role may define searches, propose candidates and interpret supplied verified evidence, but it cannot execute an adaptive search.

### Clarifications and reusable instruction updates

Whenever a subagent finds its workflow, role or skill unclear, it must send the question to the main coordinator, identifying the relevant file/section, what is ambiguous and which work depends on the answer. Do not silently invent a rule or interview the user directly. Continue independent authorized work while the dependent decision remains unresolved.

The coordinator checks the existing instructions and prior user decisions first. If they already answer the question, return that answer with its source; otherwise ask the user through the main chat. Relay the resolved answer to every affected subagent. A required answer remains pending until it arrives; elapsed time is not a decision or permission.

Classify the answer by scope. Task-specific values, choices and exceptions stay in the current conversation or appropriate study record. A clarification about how the agent, workflow or skill should operate across tasks must be incorporated into its owning instruction file so the same ambiguity does not recur. If the intended scope is unclear, ask whether the answer applies only to this task or should become the standing rule. Do not turn an unanswered question, an agent assumption or a one-off exception into a permanent instruction.

This is standing authorization to persist resolved reusable clarifications without asking again merely to save them. The coordinator owns completion of the update: edit it directly or assign one implementer under the [maintenance skill](.agents/skills/vehicle-study-maintenance/SKILL.md). Shared coordination rules belong here; role-specific behavior belongs in the relevant `.codex/agents/*.toml`; capability procedures belong in the relevant skill's `SKILL.md` or supporting reference. Update the existing owning text, replace contradictions and adjust links where needed rather than adding duplicate rules or a separate question archive. Keep the supervisor read-only.

Apply and statically check the update in the same task, then tell the user what reusable rule was saved and where. If an explicit read-only scope or a tool restriction prevents persistence, report the pending update rather than claiming it was saved. Preserve frozen review checkpoints, hashed study files and completed evidence; if the clarification changes an active study's approved behavior, use the existing review/approval process before applying it to that study. Saving an instruction never grants simulation or other runtime authority.

### Monitoring and parallel capacity

Resolve monitoring preferences once through the coordinator. The supervisor reviews stage outcomes regardless of whether periodic monitoring is enabled; report actionable execution issues when observed. Timed progress updates require the agreed schedule/content and must respect a decision to decline them. When timed monitoring is enabled, the coordinator creates/updates one temporary monitor in the main user chat and owns shutdown. A supervisor subagent is not a persistent scheduler. Scheduled wakeups may read the same evidence through run verification and format it through user updates; do not create duplicate monitors in subagent chats.

The designer checks theoretical parallel eligibility from the available saved/environment evidence within its assigned scope. The supervisor can observe the first approved full case for the capacity skill's memory estimate. These checks neither create worker pools nor enable a parallel runner: executable concurrency currently remains one. The implementer's parallel-setup skill applies only to separately requested implementation; it does not change current runner support. The coordinator alone handles the skill's session-specific confirmation and any authorized graceful MATLAB closure.

The three core roles are joined by the optional target finder within the concurrency limit. Target-finding instructions are configured; general optimization and adaptive-runner implementation are not supplied by this configuration.

## Shared scope and approval rules

Preserve existing user changes and unsaved MATLAB work. Use temporary per-run overrides for studies; edit original models, workbooks or parameter scripts only when requested. Never infer that an interactive MATLAB session is unused from low CPU usage. The parallel-capacity skill owns session-specific confirmation and graceful closure; preserve unsaved work and never force-close a session or close the study coordinator.

A documentation-only rehearsal reads Markdown and explains future steps. It must not access MATLAB or model/data files, refresh inventory, generate previews, create a study or modify project files. Planning language alone does not authorize preparation. Workflow maintenance authorizes the requested instruction/code edits and static checks, without MATLAB startup, study preparation or simulation.

Authorized preparation may use MATLAB for saved-file processing and historical previews only: no project startup, maneuver execution, model update/compile or simulation. Existing-results analysis uses the selected study's recorded configuration and signals; it does not require current-model inventory refresh, new preparation, or rewriting completed signals/state.

Present the concrete plan and historical previews unless explicitly waived. Obtain approval for short validation, present its findings, then obtain separate approval for full execution. No full-length validation. Validate one representative changed configuration for numeric sweeps; additional cases require a different compiled configuration. Loading instructions, preparing files, editing JSON or assessing capacity does not authorize simulation. Do not infer approval from elapsed time or reuse earlier-study approvals. Proceed within an approved stage without repeated routine confirmation. Material scope changes require updated review unless already authorized; follow explicit user changes within their stated scope.

macOS and Windows may be assessed for parallel capacity. The current runner implements sequential execution only; a hardware recommendation does not enable parallel execution. Other operating systems need an agreed execution policy.

Create a temporary study monitor only when monitoring has been enabled and its schedule/output preferences are resolved. Monitoring reads progress; it does not control execution or authorize another stage.

## Shared records

[SimulationStudies/WORKFLOW.md](SimulationStudies/WORKFLOW.md) is lifecycle navigation; detailed procedures belong to their skills. [SimulationStudies/MODEL_WORKSPACE.md](SimulationStudies/MODEL_WORKSPACE.md) owns model mappings, provenance and history. Tool guides own interface syntax and data provenance, not a second set of workflow rules. Dated mappings, old study plans, snapshots and waivers are evidence for their recorded context; they do not override current skills or authorize new work. Preserve reviewed historical files during instruction cleanup. Read relevant sections as needed. Keep one shared inventory, runner-template set and historical preview archive; do not duplicate them. Preserve completed studies and use a fresh reviewed preparation for later execution.
