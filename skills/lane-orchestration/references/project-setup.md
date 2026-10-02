# Programme profile

Each programme keeps a short profile at `docs/WAYS_OF_WORKING.md`, linked from `CLAUDE.md`. The skill reads it before it dispatches anything. Create it with the user when a programme starts, and update it when the user rules on something.

```markdown
# Ways of working — <programme>

## Target
One paragraph: what "done" is (paper, release, verdict), and the kill criteria.

## Record
- Notebook: NOTEBOOK.md (folds numbered; § roadmap, § facts, § lanes)
- Charter / plan: docs/CHARTER.md
- Claims: claims/Cnnn_slug/check.py → prints `PASS Cnnn`; run all: `python scripts/check_all.py`
- Lane reports: docs/lanes/<LANE>-<slug>.md
- Orders: results/orders/<ID>.md; orchestrator log: results/ORCHESTRATOR.md

## Models
- Theory / code / analysis lanes: <strong model> (standing authorisation: yes/no — if no, ask per lane)
- Execution / orchestration / benchmarks / reproductions: <cheaper model>
- Max parallel lanes: <1|2>

## Compute
| Host | Use | Limits | Never touch |
|---|---|---|---|
| <primary workstation> | primary | ≤ N threads, ≤ X GB | — |
| <shared node> | overflow | ≤ 2 cores, nice 10, ≤ 10 GB | <other programme's jobs> |
| rented (<provider>) | gating work only | ≤ K instances, lane cap $C, floor $F | — |

Secrets: vault key names only (e.g. `<provider>_api_key`), used through `vault exec`.

## User rulings (dated)
- 2026-…: <ruling> — why.

## Tie-breakers / preferences
- <e.g. preferred interpretation, gets an extra ranking point and is never decisive>
- Timezone for reports: <TZ>
```

## Bootstrapping a new programme
1. Write the profile, `NOTEBOOK.md` (fold 0: target, initial claims, roadmap) and `claims/` with one trivial claim plus `scripts/check_all.py`.
2. The first lane is a strong-model **charter lane**. It writes the plan, the decision criteria and the reserved claim numbers.
3. From there, run the normal pipeline: theory/code → order → orchestrator → analysis → fold.
