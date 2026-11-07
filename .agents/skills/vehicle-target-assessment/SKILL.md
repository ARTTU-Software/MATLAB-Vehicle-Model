---
name: vehicle-target-assessment
description: "Interpret verified Vehicle_Model results for one numerical target and maneuver completion, classify misses and physical limits versus technical failures, and report final parameters and every attempt. Not independent verification or general optimization."
---

# Vehicle Target Assessment

Follow [AGENTS.md](../../../AGENTS.md) and the [assessment procedure](references/procedure.md). Interpret evidence already checked through [run verification](../vehicle-study-run-verification/SKILL.md).

**Input:** accepted target, candidate identity, verified effective values/results/completion evidence and budget status.
**Work:** classify outcomes, determine whether another proposal is permitted and explain all evaluated candidates.
**Handoff:** match, numerical miss, physical-limit invalidity, technical/evidence hold or budget exhaustion, with evidence and next action.

Require passed input/configuration verification before accepting a match or adapting from a result; requested/effective mismatches are a hold. Return successful parameters plus complete candidate history, or closest completed attempts and unmet requirements if no match exists. Do not infer maneuver completion from a stop timestamp, hide unsuccessful attempts, launch retries or alter the search.
