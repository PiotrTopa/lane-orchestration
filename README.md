# lane-orchestration

A [Claude Code](https://claude.com/claude-code) skill for running a long research or engineering programme over several days. It covers how the agents split the work, how results get recorded, and how compute and money are handled.

- **The main thread coordinates.** It briefs lanes, verifies what they hand back, folds results into a notebook and reports to the user. It never does the deep work itself.
- **Lanes by phase.** Theory, code and analysis lanes run on the strongest model. Execution, orchestration and benchmarks run on a cheaper model. A strong-model lane never sits waiting on jobs.
- **Every claim is a runnable check** (`claims/Cnnn/check.py` prints `PASS Cnnn`). Nulls count as results. Positives get sabotage controls. Decision criteria are pre-registered, and post-hoc changes are disclosed.
- **Folds** are short updates tagged `[FAV]` / `[UNFAV]` / `[INSTR]`, each with the roadmap and status to the target. They are written to the notebook and repeated to the user.
- **Orders and one orchestrator.** Lanes write order files; a single orchestrator owns every job, every host, the budget and the rentals.
- **One detached waiter** watches all pending jobs and exits only on an event that needs action. It does no polling and has no per-job waiters.
- **Money discipline.** Work runs locally first. Rentals are used only when they turn weeks into days. Each lane has a cap, a funds floor triggers destroy-all, instances auto-destroy at queue end, and work is benchmarked before it moves.
- **Security.** Secrets are only piped from a vault. Refusals reported by agents are surfaced, never worked around.

## Install

```sh
git clone https://github.com/<you>/lane-orchestration
ln -s "$PWD/lane-orchestration/skills/lane-orchestration" ~/.claude/skills/lane-orchestration
```

Then, inside a repository, ask Claude to "set up lane orchestration for this programme". It writes `docs/WAYS_OF_WORKING.md` (the programme profile) with you.

## Layout

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
