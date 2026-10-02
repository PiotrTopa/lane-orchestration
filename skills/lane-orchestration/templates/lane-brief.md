# Lane brief templates

Fill the `<>` fields. Keep briefs self-contained: the lane has none of the main thread's context.

## Theory / code / analysis lane (strong model)

```
Lane <ID> (<model>): <one-line goal>.

Repo: <abs path>. Read first: <profile>, NOTEBOOK.md §<n>, <charter/order>, <prior lane reports>.
Context: <3–8 lines: what is certified, what is open, why this lane exists>.

Deliverables:
1. <derivation / code / analysis>, certified as claims <Cxxx–Cyyy> (reserved for you):
   claims/Cnnn_slug/check.py prints `PASS Cnnn`; positives need a sabotage control; nulls are results.
2. If production compute is needed: write an order (orders/<ID>.md, format in docs/ORCHESTRATION.md). Do NOT launch it,
   and do NOT wait for it. Your lane ends when the claims pass and the order is committed.
3. Report: docs/lanes/<ID>-<slug>.md — results as FAV/UNFAV/INSTR, claims, deviations, open questions,
   recommended next lane.

Rules: write as you go; commit your files only (no NOTEBOOK.md / CLAUDE.md edits, no push);
pre-registered criteria are binding — any post-hoc change is disclosed; analyse only <data scope>;
absolute paths in parallel shell calls; times in <TZ> in the report.
Compute: local only, ≤ <N> threads / <X> GB on <host>; no rentals.
```

## Execution / orchestrator lane (cheaper model)

```
Lane <ID> (<model>): execute order(s) <IDs>.

Repo: <abs path>. Orders: <paths>. Policy: docs/COMPUTE_POLICY.md (quote: <key lines>).
Hosts: <table with limits and never-touch list>. Rentals: ≤ <K> instances, lane cap $<C>, funds floor $<F> → destroy all.
Secrets: `vault exec <key> -- sh -c 'TOKEN="$(cat)" exec <tool> ...'` — never print or write the value.

Do:
- Place the jobs by priority (gating first); run the kill checks early; one chain per card; checkpoint/resume only.
- Wait with ONE detached waiter for ALL pending jobs (templates/wait_all.sh pattern); no polling, no per-job waiters,
  no interim wake-ups. Act only on its exit events; acknowledge each one in the ack file.
- Before extending a stored chain, pre-copy it and record the md5.
- On completion: verify 0 instances alive and report the credit; pull and md5-verify every output; commit data and scripts
  (not NOTEBOOK.md / CLAUDE.md; no push).
- Report: docs/lanes/<ID>-exec.md — job table (host, rate, start/end in <TZ>), spend vs cap, final credit,
  every deviation (losses, restarts, moves, cap changes, benches) with reason.

You do not change analysis criteria, claims or physics. Cap raises and new rentals beyond the plan come
from the user via main — ask, do not assume. If an action is refused by a permission check, stop and report it.
```
