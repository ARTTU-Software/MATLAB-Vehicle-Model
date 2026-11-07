# Parallel implementation procedure

## Establish the requested change

This is an authoring procedure for separately requested future support. The current runner is sequential only. A capacity estimate or maintenance of these instructions does not authorize implementing or running a parallel path.

Read the current runner interfaces and the intended installed MATLAB release's official guidance before choosing APIs. [MathWorks parallel simulation guidance](https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html) describes worker execution and dependencies; [parsim documentation](https://www.mathworks.com/help/simulink/slref/parsim.html) documents supported options. Do not assume an API, worker type, license or Simscape dependency is supported from its name alone.

Record the intended process/worker method, products/licenses, profile/worker bounds and model compatibility. For example, parsim can create a pool automatically and can execute serially when parallel products are absent; invoking it is not a harmless preparation check or proof of concurrency. Keep any pool creation behind approved execution and report unsupported requested modes explicitly.

## Prepare independent cases and workers

Use the input/setup contracts from [simulation code](../../vehicle-study-simulation-code/SKILL.md). Each case needs a stable ID, complete supported input values, baseline/configuration identity and effective readbacks.

Specify how each worker initializes the correct project paths, model/library/dependency versions, callbacks and required data. Avoid relying on the user's interactive base workspace. Reset case state so repeated work on one worker does not inherit previous overrides. Preserve the full scenario generation/selection order.

Provide independent study-owned temporary project/work directories, generated/cache/build artifacts and output paths wherever writes can conflict. Trace workbook/generator side effects, library changes, file writes and external resources; read-only shared dependencies may be shared only when verified. A different worker process alone does not establish filesystem isolation.

Keep requested/effective parameters and selected outputs tied to case IDs even when cases finish out of order. Use collision-free per-case output and one owner for aggregate status/approval state. Do not let workers overwrite the coordinator's state or each other's results. Keep existing JSON/result interfaces unless their change is part of the request.

## Bound dispatch and preserve approval controls

Use [parallel capacity](../../vehicle-study-parallel-capacity/SKILL.md) as the single owner of RAM thresholds, sampling, reserve/margin and CPU/license bounds. Unknown capacity/isolation remains unverified. Never use total installed RAM or all logical CPUs as an automatic worker count.

For a future supported full stage, retain the first real full case executed sequentially as its actual result; do not dispatch it twice. Any transition to parallel remaining cases must be implemented, reviewed and included in the approved execution policy in advance. Recheck clean available resources before dispatch. Missing/unreliable memory evidence or a bound below two cannot trigger parallel dispatch; use only a sequential continuation policy that was explicitly reviewed, otherwise return the limitation to the coordinator.

Do not create a new dispatch/pause policy while an existing sequential study is running. The current runner continues only within its present approved behavior.

Design failure handling before execution: stop submitting new work on the first failure under the default policy, retain completed results and record every in-flight case outcome. Explicitly resolve how existing in-flight work finishes or is cancelled in the reviewed policy; no hidden retries, force-killing or loss of evidence. Continuing independent failed-stage work requires the separately reviewed execution policy. Preserve model-stop semantics and per-case cleanup.

## Review and validation handoff

Return implementation file identities, worker initialization/isolation design, dependency and resource gaps, failure policy, and proposed checks to [code review](../../vehicle-study-code-review/SKILL.md).

Runtime isolation checks belong to separately approved short validation launched by the coordinator. Validate one representative changed numeric configuration, with extra cases only for distinct compiled configurations. If concurrency isolation requires a concurrent duplicate of that short case, it is an exception to the existing rule, not covered by ordinary short-validation approval. Identify the purpose/count and leave that check pending unless the user explicitly authorizes changing the validation case-count rule for this check. The coordinator must record that specific exception as well as the approved short duration; do not infer it from a general parallel-implementation request. Never silently expand validation or introduce a full-length profile. Static evidence alone cannot prove runtime isolation.

Verify independent effective inputs, artifacts, status ownership and completed outputs. Report which checks remain pending. Full execution still requires presentation of validation findings and its own approval. Update the reported executable limit only after the requested implementation exists, its worker/isolation checks are verified and its current resource bounds are known; until then it remains one.
