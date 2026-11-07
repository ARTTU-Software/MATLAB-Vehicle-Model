---
name: vehicle-study-maintenance
description: "Maintain this Vehicle_Model project's study skills, workflow documentation and shared templates/tools. Use for requested workflow changes and static verification; maintenance does not authorize MATLAB startup or a study run."
---

# Vehicle Study Maintenance

Make the requested workflow change under [AGENTS.md](../../../AGENTS.md). Preserve user changes and historical study evidence.

1. Identify the affected capability and read its skill/reference plus the implementation-specific guide when needed. [WORKFLOW.md](../../../SimulationStudies/WORKFLOW.md) is navigation, not a second procedure manual.
2. Keep shared rules/routing in root AGENTS, detailed procedure with its owning skill, model mappings/history in [MODEL_WORKSPACE.md](../../../SimulationStudies/MODEL_WORKSPACE.md), and tool mechanics in their existing guides. Replace duplication with links. Do not reintroduce a nested AGENTS or umbrella study skill.
3. For skill changes, use the available skill-creator guidance. Keep names/descriptions discriminating, automatic discovery enabled, display metadata consistent, and references task-specific.
4. For requested template/code changes, read callers and retained study lessons before editing. Preserve stage/baseline controls and existing interfaces unless the request changes them. Keep one shared runner/template set, inventory and preview archive.
5. Perform static checks appropriate to the change: skill validation, metadata, relative links/anchors, current routing and affected approval/scope scenarios. When migrating instructions, check that each prior requirement has one owner or a deliberate replacement.

This mode permits the requested file edits and static checks. It does not authorize MATLAB startup, model/data discovery, inventory refresh, preparation, simulation, live monitoring or session closure. Requested skill or documentation work alone must not become a runtime test.

## Persist reusable clarifications

Apply the root [clarification and persistence rule](../../../AGENTS.md#clarifications-and-reusable-instruction-updates) when a user answer resolves a general workflow, role or skill ambiguity. The coordinator supplies the resolved answer, its intended scope and the owning file; ask it about any remaining uncertainty before changing the rule.

Edit the existing owning section into a clear instruction with the necessary condition, action and handoff. Preserve the user's intended scope; task-specific settings and exceptions do not become global defaults. Remove or reconcile conflicting wording and update affected routing references without duplicating the procedure. Keep the change within assigned files and preserve any frozen checkpoint until its review is completed or explicitly superseded.

Check the affected Markdown links, skill metadata or role TOML syntax, and walk through the clarified behavior and any affected approval boundary. Return the saved rule, file path and verification to the coordinator so it can inform the user and affected subagents. This standing persistence instruction requires no second conversational approval simply to save an already resolved reusable rule; tool-enforced permissions and explicit read-only limits still apply.

Report what changed, verification and implementation limits. In particular, capacity assessment is distinct from implementing/validating a parallel runner, and monitoring instructions are distinct from creating a live monitor.

Maintain the [study team](../../../AGENTS.md#study-team) through its project-local TOML role files and root coordination rules. Keep procedures in the focused project skills, preserve the single writer and independent reviewer roles, and support the optional target finder within the three-concurrent-subagent limit. Target-finding instruction maintenance does not implement an adaptive runner or general minimization. Narrow maintenance can stay with the coordinator; an independent supervisor review can be delegated within the same static-only scope.
