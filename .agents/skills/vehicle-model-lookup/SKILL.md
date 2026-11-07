---
name: vehicle-model-lookup
description: "Resolve requested Vehicle_Model inputs and outputs through the shared saved inventory, with source paths, units, freshness and runtime gaps. Use for targeted mapping searches or an explicitly assigned inventory refresh; not live model discovery."
---

# Vehicle Model Lookup

Use the [root scope rules](../../../AGENTS.md) and [lookup procedure](references/procedure.md). The designer normally owns this work.

**Input:** the requested parameter/signal, maneuver/configuration and permitted discovery scope. A Markdown rehearsal explains lookup without querying saved records.

1. Translate the request into candidate names/aliases and search the existing shared records.
2. Trace candidates to exact source and effective target; check units, shape, configuration, initialization dependencies and saved fingerprints.
3. Resolve ambiguity using evidence or return a specific question. Missing definitions and runtime-only values remain explicit gaps.
4. Refresh changed scopes only when authorized and assigned sole mapping ownership.

**Handoff:** a concise mapping for each requested input/output, evidence paths/freshness, application/readback requirements and unresolved gaps. Use the existing shared inventory and MODEL_WORKSPACE record; create no duplicate inventory. [Simulation code](../vehicle-study-simulation-code/SKILL.md) consumes the mappings; saved evidence is not runtime verification.
