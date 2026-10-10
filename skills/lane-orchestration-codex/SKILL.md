---
name: lane-orchestration-codex
description: Coordinate a sustained research or engineering programme in Codex through bounded subagent lanes and concise evidence-aware folds. Use when the user requests this division of work or invokes this skill; ordinary single-task work does not need lanes.
---

# Lane orchestration for Codex

Keep the main thread focused on the objective, delegation, synthesis and user decisions. Delegate technical research, implementation, calculations, source verification and result checking. A fold explains what a result changes about the objective; it is not a count of completed tasks.

## Establish the working contract

Read applicable repository instructions and `docs/WAYS_OF_WORKING.md`, if present. The project profile overrides this skill's defaults; explicit user instructions and higher-priority instructions take precedence. Preserve standing authorization and preferences from the conversation. Do not ask again for an already authorized routine next step.

If there is no profile, proceed from the user's request and existing records. Create a short profile only when it would preserve useful decisions. Useful fields are the objective, record paths, role responsibilities, concurrency limit, authorized model mapping, resource limits, stopping conditions and user decisions. Do not scaffold a claim harness, notebook, roadmap or infrastructure merely to use this skill.

Inspect the tools and limits exposed by the current runtime before dispatch. Use inherited models by default. Apply explicit role-to-model mappings only when authorized by the user and supported by that runtime. Do not promise a particular model's price, availability or superiority, or claim to switch the main conversation's model.

Read [runtime.md](references/runtime.md) when choosing delegation tools, model settings or how to wait for work. If delegation is unavailable, explain that limitation and agree on a feasible mode; do not pretend a single-thread analysis was independent review.

## Select bounded lanes

Choose roles by the question, not a mandatory pipeline:

| Role | Bounded question | Typical handoff |
|---|---|---|
| Scout | Which materially different framing is worth examining? | Short sketches, central connection, biggest catch and a suggested challenge. |
| Formalization | What precisely follows from the proposed common rule? | Mapping/equations or design, supplied inputs, assumptions and a discriminating consequence. |
| Test / implementation | Does a stated consequence hold, or does the change work? | Code or calculation, relevant checks, outputs and scoped conclusion. |
| Reviewer | Is a consequential claim supported under its stated assumptions? | Independent challenge, source check or reproduction, with unresolved weaknesses. |
| Execution owner | How can an approved long job run within its limits? | Job state, outputs, deviations and resource accounting. |

An exploration may flow from scout to formalization to test to reviewer, with a main-thread fold between stages. Skip stages that add no value. Sketches need no automatic critic; consequential claims may warrant an independent reviewer. A revision after a diagnosed failure can be useful: label it exploratory and test a new consequence instead of silently relaxing the previous criterion.

Default to one bounded lane; parallelize independent questions when useful and within the runtime's capacity. Count the coordinator and other live agents against limits where required. Give concurrent writers disjoint file ownership. The main owns shared synthesis and decision records; lanes own only their assigned artifacts. No recursive delegation unless assigned. Committing, publishing and renting resources follow existing user authorization and repository policy, not an automatic skill rule.

Use [lane-brief.md](templates/lane-brief.md) for a compact brief. Supply the objective, reason this question matters, minimal context, selected files, outputs, evidence target and stopping condition. Prefer a fresh context for independent ideas; reuse an agent for related follow-ups. Avoid copying the whole chronology into every lane.

## Match claims to evidence

Keep these evidence descriptions distinct; they are not a compulsory progress ladder:

- **Speculative / exploratory:** a proposal, analogy or pattern noticed with access to data. Name what it could explain and where it might fail.
- **Derived / implemented:** a consequence of stated assumptions, or an implementation. Identify what is supplied versus generated; an implementation alone does not establish correctness.
- **Tested:** a result with an identified method, inputs, criterion, output and limitations. A passing software check certifies only what it checks.
- **Independently checked:** a specified claim examined by a separate reviewer or reproduction. State the scope of that check.

For confirmatory tests, fix the concrete hypothesis, data scope and decision rule before the confirmatory run, using an existing record with a timestamp or revision identifier. Disclose prior data access, post-hoc choices and deviations. Useful controls should challenge the claim; do not require a synthetic `PASS` certificate for every idea or literature statement. Verify technical literature through primary sources and link each consequential sourced claim to its support.

Negative results exclude only the tested assumptions and scope. Preserve uncertainty and distinguish observations, extracted quantities, model assumptions and proposed representations. An incomplete idea is not automatically refuted; a renamed known mechanism is not automatically explanatory progress.

## Fold and continue

Read the lane's handoff and link its artifacts. Delegate missing verification rather than repeating deep work in the main thread. Label unverified findings explicitly. Use [fold.md](templates/fold.md) when a result changes evidence or direction; keep small scout batches in an existing compact record rather than creating a formal report per sketch.

Record the central connection, evidence status, explanatory or practical gain (including none), remaining supplied inputs, scoped decision and why the next question is preferable to alternatives. Do not let an unfinished calculation automatically set the next agenda or force a roadmap toward the latest candidate. Preserve useful correspondences and scoped failures for renewed search.

Continue within the user's authorized scope and stopping conditions. Ordinary nonconvergence is not an approval gate. Bring the user a substantive choice, promising direction requiring their judgment, or blocker needing new information or resources. Keep progress messages concise and the durable record sufficient to resume. Never promise unattended continuation beyond the runtime's actual lifecycle.

## Long compute only when needed

Short checks stay with the technical lane. For costly, shared or long-running work, read [compute.md](references/compute.md). Use a clear order with one execution owner, resource budget and stop conditions. Use native completion events and bounded waits supported by the runtime; do not copy a detached shell waiter by default.
