# lane-orchestration

Skills for coordinating a sustained research or engineering programme through bounded agent lanes and short result summaries (folds).

- [Claude Code original](skills/lane-orchestration/SKILL.md): the original workflow, preserved unchanged.
- [Codex adaptation](skills/lane-orchestration-codex/SKILL.md): a separate workflow using the delegation capabilities exposed by the current Codex runtime. The coordinator delegates technical work and checking, then folds results against the programme objective.

## Codex

The Codex adaptation supports scout, formalization, test, reviewer and execution roles as needed. It distinguishes exploratory ideas, derived consequences, tested results and independent checks. A speculative idea does not need a `PASS` certificate, and a failed bounded test does not reject every related idea.

Read an existing `docs/WAYS_OF_WORKING.md` profile first; it overrides skill defaults. Existing user instructions and authorization still apply. No profile, claim harness, roadmap or compute infrastructure is required to begin. Models inherit by default; explicit user-approved role mappings depend on runtime support. Long jobs get a bounded order and execution owner when needed, with native completion events instead of the Claude waiter script.

### Install for Codex

Clone the repository, then link the Codex skill into your user skill directory:

```sh
git clone https://github.com/PiotrTopa/lane-orchestration
mkdir -p ~/.agents/skills
ln -s "$PWD/lane-orchestration/skills/lane-orchestration-codex" ~/.agents/skills/lane-orchestration-codex
```

Use a fresh destination for the link; if that name already exists, inspect it before replacing anything. For a repository-scoped installation, use that repository's `.agents/skills` directory instead. See [official skill guidance](https://learn.chatgpt.com/docs/build-skills).

Invoke with `$lane-orchestration-codex` and describe the objective, scope and stopping condition. For example: “Use $lane-orchestration-codex to investigate two alternative designs, implement the better-supported option and delegate an independent check.” Delegation requires a runtime that exposes subagent tools; the skill documents how to handle unavailable capabilities.

```text
skills/lane-orchestration-codex/
  SKILL.md                  workflow and working contract
  agents/openai.yaml        Codex UI metadata
  references/runtime.md     runtime adaptation and official sources
  references/compute.md     optional bounded compute orders
  templates/lane-brief.md    compact delegation brief
  templates/fold.md          concise evidence-aware fold
```

## Claude Code original

The original [Claude Code](https://claude.com/claude-code) skill covers how agents split work, record results and handle compute and money. Its original rules include:

- **The main thread only orchestrates, it never deep-dives.** It briefs lanes, verifies what they hand back, folds results into a notebook and reports to the user. It never does the deep work itself.
- **Lanes by phase.** Theory, code and analysis lanes run on the strongest model. Execution, orchestration and benchmarks run on a cheaper model. A strong-model lane never sits waiting on jobs.
- **Every claim is a runnable check** (`claims/Cnnn/check.py` prints `PASS Cnnn`). Nulls count as results. Positives get sabotage controls. Decision criteria are pre-registered, and post-hoc changes are disclosed.
- **Folds** are short updates tagged `[FAV]` / `[UNFAV]` / `[INSTR]`, each with the roadmap and status to the target. They are written to the notebook and repeated to the user.
- **Orders and one orchestrator.** Lanes write order files; a single orchestrator owns every job, every host, the budget and the rentals.
- **One detached waiter** watches all pending jobs and exits only on an event that needs action. It does no polling and has no per-job waiters.
- **Money discipline.** Work runs locally first. Rentals are used only when they turn weeks into days. Each lane has a cap, a funds floor triggers destroy-all, instances auto-destroy at queue end, and work is benchmarked before it moves.
- **Security.** Secrets are only piped from a vault. Refusals reported by agents are surfaced, never worked around.

### Install for Claude Code

```sh
git clone https://github.com/PiotrTopa/lane-orchestration
ln -s "$PWD/lane-orchestration/skills/lane-orchestration" ~/.claude/skills/lane-orchestration
```

Then, inside a repository, ask Claude to "set up lane orchestration for this programme". It writes `docs/WAYS_OF_WORKING.md` (the programme profile) with you.

### Claude Code layout

```
skills/lane-orchestration/
  SKILL.md                              the rules
  references/project-setup.md           programme profile + bootstrap
  references/orders-and-orchestrator.md order format, lifecycle, orchestrator rules
  templates/lane-brief.md               theory/code and execution brief templates
  templates/fold.md                     fold format + assert-unique notebook edit
  templates/wait_all.sh                 single-waiter template (exit codes 0/11–15)
```

## Licence

MIT
