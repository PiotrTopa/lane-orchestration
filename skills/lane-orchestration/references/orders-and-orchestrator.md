# Orders and the orchestrator

Lanes **place orders**. One orchestrator **fulfils** them. This replaces per-lane silos, where each lane started its own jobs, watchers and budget guards. Those silos led to wrong queue order, frozen chains and budget guards that collided.

## Order file: `orders/<ID>.md`
`<ID>` = `<lane>-<short-name>`. The lane writes the file. After that, only the orchestrator edits `state:`.

```yaml
order: K-S1b
lane: K
priority: 1                # 1 = gating; larger = later; ties broken by needed-by
consumes: C200-C202        # claims that will consume the result
needed-by: 2026-10-02T20:00Z
budget-class: laneK        # which $ cap pays for rented time
rental: allowed            # allowed | local-only | <class>-only
preregistered: <commit>    # commit fixing the analysis criteria (for pre-registered orders)
constraints:
  min-acceptance: 0.5      # per 50-step window after burn-in; below -> finer integrator on resume
  memory: 26 GB per measurement
  one-chain-per-card: yes
jobs:                      # exact job lines, tag first
  - TAG_A --L 8 ... --ntraj 1000 --out results/...
kill-checks:               # cheap early tests; failure -> stop and report
  - acceptance >= 0.5 by traj 100
  - |A(h)| response sign/size as predicted for h >= 2
state:                     # orchestrator only
  status: open | accepted | placed | running | done | closed | refused
  placement: TAG_A -> host (job file, logdir) since <time>
  notes: moves, restarts, integrator changes, unthermalised stretches
```

**Lifecycle:** open → accepted (or refused, with the reason) → placed/running → done (every tag has `END <tag> exit 0` and has been pulled) → closed (the lane has consumed the result; rentals are destroyed).

## Orchestrator rules
- **Priority first.** A lower class is paused at a checkpoint when a higher class needs a card. Within a class, balance the queues so they all finish at about the same time.
- **Moves only at checkpoints.** A moved chain keeps its tag. The old pool gets a `MOVED` marker, and waiters look for END lines in the new logdir.
- **Crashes:** a chain gets one restart from its checkpoint. After a second crash it is stopped and reported.
- **Lost host:** pull what is reachable, destroy the instance, restart once from the last pulled checkpoint on a new card, and log it in `moved.txt`.
- **Budget:** projected spend = spent + burn × longest remaining ETA. If that breaks a cap or the floor, move lower-priority rented chains to local cards and report. Any cap raise comes from the user, through the main thread.
- **Logging:** every decision gets one timestamped line in `ORCHESTRATOR.md`, with a reason. Report to the main thread only the events that need a decision.
- **Pre-copy before extending:** before resuming or extending a stored chain, copy its file aside and record its md5. The analysis then knows exactly which trajectories are new.

## Infrastructure scripts worth having (per programme)
| Script | Role |
|---|---|
| `pool.sh <jobfile> <logdir>` | runs job lines in order, writes `START/END <tag> exit N` to `queue.log`, and claims tags so two pools never run the same tag |
| `pull.sh` (cron, every 15 min) | pulls the logs and checkpoints of rented hosts; logs UNREACHABLE |
| `guard.sh` | budget guard: trips at the cap and stops rented work |
| `autodestroy.sh <id> <jobfile> <logdir>` | destroys the instance after its queue ends and the final pull is verified |
| `place.sh` | rent, bring up, seed checkpoints (verified by md5), start the pool |
| `wait_all.sh` | the single waiter (see `templates/wait_all.sh`) |
