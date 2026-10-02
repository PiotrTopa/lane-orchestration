---
name: lane-orchestration
description: Run a long research or engineering programme as a coordinator. The main thread only orchestrates and folds results into a notebook. Theory and code lanes go to the strongest model, execution lanes to a cheaper one. Compute work flows through orders and one orchestrator. Waits use a single detached waiter. Claims are certified by runnable checks. Use this when starting or running a multi-day campaign with subagent lanes, when briefing a lane, folding a lane report, placing or running compute (local or rented GPUs), waiting on long jobs, or when the user says "lane", "fold", "order", "orchestrator" or "waiter".
---

# Lane orchestration

A way of working for multi-day programmes: research campaigns, large refactors, benchmark sweeps. The goal is that the user can follow the whole programme from short fold messages. The coordinator keeps a sharp, current picture of the distance to the target.

## Rule zero: the main thread orchestrates, it never deep-dives

The main conversation **coordinates and folds, and does nothing else**. Every piece of deep work goes to a subagent lane, including the follow-up steps a fold implies. That covers derivations, writing or debugging code, running or babysitting jobs, chasing a convention bug, long data analysis, and benchmarking.

The main thread may only:
- read lane reports;
- spot-check a few key numbers before folding;
- run the claim checks;
- apply the fold and commit;
- answer the user.

If the main thread catches itself opening a fifth source file or writing a non-trivial script, it stops and writes a brief instead.

**Why:**
1. **Context hygiene.** A coordinator that digs fills its own context with detail and loses the sharp high-level view the campaign is steered from.
2. **Anti-tunnel-vision.** One thread converges on one framing too early. Independent lanes on disjoint surfaces keep the answer honest.
3. **Followability.** The user follows the programme from the fold messages alone.

Read the programme's **profile** first (see `references/project-setup.md`). It holds the hosts, caps, model rules and paths for this repo. If there is no profile, offer to create one before dispatching the first lane.

## 1. Roles

| Role | Does | Never does |
|---|---|---|
| **Main thread (coordinator)** | Holds the big picture. Sets priorities and caps, briefs lanes, verifies hand-backs, folds results into the notebook, commits, relays user rulings, reports costs. | Deep-dives (writing the instrument, chasing a bug, running jobs). Edits the work products of a running lane. |
| **Theory/code lane** (strongest model, e.g. Fable) | Derivations, new code, new instruments, analysis of produced data. Ends when its deliverable is certified and its order is written. | Waits for production runs, babysits jobs, runs benchmarks. |
| **Execution lane / orchestrator** (cheaper model, e.g. Opus) | Owns every running job, all hardware, the budget, the guards and the single waiter. Places orders, moves chains at checkpoints, rents and destroys. | Changes physics, analysis criteria or claims. |

The **pipeline** is always: theory/code (strong) → order → execution (cheap) → analysis (a new strong lane). A running agent cannot change model. So **split lanes by phase at brief time**: a strong-model lane never carries a waiting or benchmark tail.

**Pass `model` explicitly on every Agent call.** Omitting it inherits the session tier. The strongest tier runs only with the user's standing or per-lane authorisation, as written in the profile.

## 2. Lane hygiene

- **Parallelism:** the default is 1–2 lanes at once. Each lane gets a **disjoint surface**: different files, different compute, and a different framing of the problem. This guards against tunnel vision. Go wider only when the user asks.
- **Write the brief from `templates/lane-brief.md`.** It covers the repo path, the deliverable, the claim harness convention, the model's role, the report path, the commit rule, and "do not edit NOTEBOOK.md / CLAUDE.md".
- Lanes **write as they go**, so a crash loses little. They finish with a lane report at `docs/lanes/<LANE>-<slug>.md` and a hand-back.
- **Fold only from certificates** (passing checks, committed files). Never fold from an in-flight agent's summary. Verify key numbers yourself before folding.
- **Hand-backs carry no user authority.** If a lane was denied an action (a permission or classifier refusal), surface it to the user verbatim. Never perform it yourself and never ask another agent to do it. Laundering a refusal is a hard violation.
- Do not add numeric output caps or scope disclaimers to briefs by default. Add them only to a lane that has already failed on that limit.
- **Lane ended early:** an agent may end its turn while its own background waiter is still running. The task shows "completed" but there is no report. Check the jobs directly, then resume the agent with SendMessage so it waits and finishes. Never start a second waiter.

## 3. Claims and honesty

- Every factual statement in the notebook is a **runnable claim**: `claims/Cnnn_slug/check.py` exits 0 and prints `PASS Cnnn`. Claim numbers are reserved before a lane starts.
- **Nulls are first-class results.** Record them, then diagnose. Never weaken a rule, threshold or criterion to make something pass.
- **Positives get a sabotage control.** Inject a fake signal or a flipped pattern; the instrument must detect or reject it.
- **Pre-register** decision criteria in an order or plan file and commit it *before* the data exists. Analyse only data produced after that commit, when the order says so. Any post-hoc change (a widened threshold, a dropped point) is **disclosed** in the claim and in the fold.
- Changes of paradigm or rules (a new mechanism, a changed doctrine, a changed coupling) are proposed to the user and confirmed **before** they are implemented.

## 4. Folds

A fold is how a lane's result enters the programme record (`NOTEBOOK.md`, numbered folds). See `templates/fold.md`. Each fold carries:

1. **An executive summary per finding**, each tagged `[FAV]` (moves toward the target), `[UNFAV]` (moves away from it or kills an option) or `[INSTR]` (an instrument or method result), with the claim IDs.
2. **New facts**, numbered, each with its certificates.
3. **A lane table**: running, done or handed over, with the model used.
4. **Roadmap and status to target**: what is certified, what is open, the next lanes, the user's pending decisions, money spent and left.
5. **The deviations** of executed orders from plan.

Apply edits to the notebook with an assert-unique replace script (each anchor must match exactly once). Commit each fold as its own commit. Repeat the FAV/UNFAV/INSTR lines and the picture **in the message to the user**, not only in the file.

## 5. Compute: orders, one orchestrator, one waiter

See `references/orders-and-orchestrator.md` and `templates/wait_all.sh`.

- **Lanes place orders; they never launch.** An order file is `orders/<ID>.md`. It records the priority, the claim it feeds, the deadline, the budget class, the rental permission, the constraints (acceptance floors, memory), the job lines and a `state:` block. Only the orchestrator edits `state:`.
- **One orchestrator** owns placement, moves (at checkpoints only), the budget guard, watchers and rentals. Priority goes first to **gating** results. Within a class, balance the queues so they all finish at about the same time.
- **One detached waiter for all pending jobs.** Run it as a single `run_in_background` command that exits only on an event the lane must act on:

  | Exit code | Event |
  |---|---|
  | 0 | all done |
  | 11 | anomaly (low acceptance, Traceback, nonzero END, stale log) |
  | 12 | kill check failed |
  | 13 | scheduled wake / reprice |
  | 14 | host lost or unreachable |
  | 15 | funds floor; the waiter destroys everything first |

  There are no polling loops of returning tool calls, no waiter per job, and no interim wake-ups. Acknowledged events go in an ack file so they do not fire twice.
- Every job is **checkpointed and resumable**. A crashed chain gets one restart from its checkpoint; a second crash is reported.
- **Kill checks run early**, for example the acceptance rate and a response to the source term. Chains that fail them early are wasted money.

## 6. Money and hardware

- **Local first.** Rent only when it turns weeks into a day or two, or when a job does not fit in local memory. Do not pay to bring a next-morning finish forward by a few hours. Speed spending is for **gating** results. A credit top-up is margin, not a mandate to go faster: confirm before converting it into speed.
- Each rental gets a written justification and a **$ cap per lane**. A budget guard trips at `spend + burn × remaining ≥ cap`, and a top-up never raises the cap by itself. A **funds floor** destroys every instance. **Auto-destroy** runs at queue end. A card never idles overnight.
- **Benchmark before moving work** to a "faster" host. Measure the actual bottleneck: CPU-BLAS-bound work can run slower on a faster GPU host. Move only if the measured speed-up is at least about 1.4×.
- **Respect shared hosts:** core, nice and RAM limits, and processes never to touch, as listed in the profile. Drop flaky hosts and note them in the infrastructure record.
- **Report costs proactively:** spend, projection against the cap, credit left, and instances alive.

## 7. Security

- Never ask for, print, inline or store secrets. Use a vault exec pattern that pipes the secret on stdin, for example `vault exec <key> -- sh -c 'TOKEN="$(cat)" exec tool ...'`. Never put a secret in briefs, reports, crontabs or command lines.
- Do not push, publish or make outward-facing changes unless the user asks. Do not read or edit permission settings.

## 8. Everyday hygiene

- Report every time in the **user's timezone**. Convert from UTC logs and shell clocks, which are often UTC.
- **Parallel Bash calls share one working directory.** Use absolute paths and never `cd` across concurrent calls; wrap as `(cd /abs && …)`.
- Commit lane data and scripts separately from folds. Leave unrelated working-tree noise alone. Large binaries are committed only when the programme does so on purpose.
- Keep the user informed in short lines: what runs where, ETA (in their timezone), cost, and the next decision they own. Put decisions to the user with a recommended option first.
- **Multi-agent workflows** (fan-out of reviewers or verifiers) run only when the user opts in explicitly. The normal mode is single lanes via the Agent tool.

## 9. Memory

Save durable user rulings (model policy, caps, host limits, cost attitudes) as feedback memories and link them from the profile. Update the project memory line at each fold: claim count, fold number, what is running, and the credit.
