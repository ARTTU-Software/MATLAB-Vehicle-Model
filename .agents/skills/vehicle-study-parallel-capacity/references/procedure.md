# Parallel eligibility and RAM capacity

This procedure assesses local macOS/Windows capacity. It does not implement a parallel runner, launch a profiling simulation, create workers without stage authorization, or switch execution modes. Paths in code spans are project-relative. GiB means `1024^3` bytes.

## Establish scope and current support

Record host/OS, installed physical RAM, intended execution method and remaining case/configuration groups. Other operating systems need an agreed policy. Consult the relevant current runner rather than historical evidence: the existing implementation accepts sequential execution only, so **current executable concurrency is one**, independently of the hardware estimate.

At installed RAM `T <= 16 GiB`, recommend sequential execution without a profiling run. Above 16 GiB, gather a measurement only during the first separately approved full stage. Before that stage report the memory-based limit as pending. A user who explicitly requests sequential execution keeps that mode.

## Interactive MATLAB sessions

During an actual authorized study context, identify candidate interactive session/process IDs and their relationship to the study before proposing closure. Exclude batch runners, workers, monitors and the process coordinating the study.

Ask once about the particular session: whether the user is using it and whether it may close. Low CPU usage or an idle window is not evidence of permission. If the user needs it, retain it and account for its RAM. A previous confirmation for that session need not be repeated unless its work/ownership changes.

Check for unsaved models, editor buffers and workspace work using available supported access only within scope. Resolve any needed save/discard decision explicitly; do not overwrite sources, choose an arbitrary workspace save, or dismiss an unsaved-work prompt. If preservation cannot be established, keep the session open and report that limitation.

Close only the confirmed session gracefully, verify its exit and remeasure available RAM. Never force-quit or close a study coordinator. A failure to close does not justify killing it or assuming its memory was reclaimed.

## Observe the first real full case

1. Once the full stage is approved, observe its first case running sequentially through the existing reviewed execution skill. Count and retain it as an ordinary full result. Do not add a case, rerun a failed case automatically, run full-length validation or alter the reviewed launch to create a benchmark.
2. Before launching the full-stage process, record available physical RAM `A` after any confirmed session closure. Other applications and an existing coordinator remain charged against availability; do not add their memory back as free. Record measurement time, OS metric, process ownership and limitations.
3. Sample the full simulation process tree from process startup through initialization/compilation, the first simulation and its extraction. Use the maximum simultaneous summed resident physical footprint as `P`, including the MATLAB process baseline and child processes. Record sample interval (target 1 second), observed phase coverage, PIDs, units and the sampled peak; it is not an exact guaranteed lifetime peak.
4. Use native OS physical-memory/process counters (for example macOS physical memory statistics and process RSS; Windows available physical memory and process working sets). Do not use virtual address space as RAM or MATLAB `whos` as process memory. MATLAB's [memory function](https://www.mathworks.com/help/matlab/ref/memory.html) is Windows-only; do not call it on macOS. Exclude swap as usable RAM and disclose compressed/shared-memory accounting limits. Summed process RSS may double-count shared pages; report that conservative limitation.
5. If sampling starts late, a phase/boundary is unobservable, counters are inaccessible, memory pressure makes the resident peak misleading, or the first case fails, report the measurement as incomplete/unreliable. Do not turn missing evidence into a capacity recommendation.
6. Match the sample to its model/configuration and observed duration. Do not claim it covers a different compiled configuration or heavier logging setup. Such groups remain unmeasured until their own real approved execution supplies evidence; no hidden profiling cases.

## Calculate and qualify the ceiling

For a reliable comparable sample, use these defaults, in the same units:

```text
T       = installed physical RAM
A       = available physical RAM measured without a study simulation running
reserve = max(4 GiB, 0.20 * T)
perRun  = 1.25 * P
N_RAM   = floor(max(0, A - reserve) / perRun)
```

The reserve is additional responsiveness/overhead headroom; it is not a measured MATLAB requirement. The 25% per-run margin addresses unobserved variation but does not guarantee safety. Do not divide total installed RAM by P while ignoring other applications.

Bound the recommendation by CPU capacity (accounting for each simulation's thread use), verified worker/profile and licensing limits for the intended execution method, and remaining cases. Report unknown limits as unknown, not unlimited. The intended method must support Simulink/Simscape and the model's dependencies; do not assume a thread pool or several independent MATLAB licenses are interchangeable.

Check worker initialization, callbacks/workspace isolation, per-worker temporary/project directories, writable generated/build/cache artifacts, output filenames, dependencies and any external resources. [MathWorks parallel simulation guidance](https://www.mathworks.com/help/simulink/ug/running-parallel-simulations.html) describes worker/dependency requirements. Inspect statically first; runtime worker tests belong only to an approved short-validation scope and an implemented runner, not ordinary preparation/capacity inspection.

Report separately:

- Installed/available RAM, sampled P, phase coverage, headroom and N_RAM.
- CPU, worker, license, case-count and configuration-coverage bounds or gaps.
- The resulting estimated ceiling and eligibility evidence.
- **Current executable limit: one; parallel runner support not implemented/verified**, while the present runner is in use.

If any verified bound is below two, recommend sequential execution. If N_RAM is zero, state that even one extra process lacks the chosen headroom; do not claim sequential execution has sufficient RAM merely because it is the fallback. Missing measurements give no memory ceiling, while unsupported implementation still limits current execution to one.

Recheck availability before any future supported parallel launch; reduce the estimate if other applications consume more RAM. Do not count the sampled process twice: recalculate with no study simulation running, or retain the prelaunch budget and label it stale until a clean recheck is possible. Reassess if higher actual peaks or different configurations appear. Never kill active runs or change an approved mode automatically.

## Record and hand off

Put the capacity assumptions/pending measurement plan into the study plan before review; present measured findings in the stage outcome/chat and use only metadata paths already supported by the runner. Do not edit hashed plan/JSON/code during execution or completed signals/state to insert telemetry.

Current sequential execution may continue within its existing approval; capacity assessment cannot insert a pause/dispatch mechanism or change the approved run policy. Enabling parallel execution requires separately requested implementation, isolation verification and updated review. A hardware estimate is not a parallel speedup guarantee.
