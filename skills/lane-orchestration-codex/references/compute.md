# Bounded compute orders

Use an order only when work needs durable resource ownership or a handoff. Adapt an existing project format; a short record is sufficient:

```text
Purpose and claim/question served:
Execution owner and output owner:
Approved environment and resource limits:
Exact command, working directory, inputs and output/log paths:
Expected duration and maximum runtime or cost:
Early failure checks and stop conditions:
Checkpoint/resume and bounded retry policy:
Completion criterion and evidence to return:
Cleanup scope and authorization:
State, session/job identifiers, deviations and final output links:
```

Assign one owner to each job and one coordinator for shared resource allocation. Only the execution owner updates its live job state. Keep analysis criteria with the technical owner; operational adjustments that affect results must be disclosed.

Run locally within existing limits when suitable. Rentals, new external services or higher spending require authorization unless already covered by standing permission. Benchmark before making a consequential resource move. A budget increase does not follow from available credit. Limit cleanup to resources this programme owns and is authorized to stop; never turn a cap into a blanket destroy-all instruction.

Prefer native job completion events. Use documented process/session waits when necessary, with bounded retry and timeout behavior. Do not start multiple watchers for the same job or assume a shell waiter guarantees future agent turns. On a lost process or host, preserve reachable evidence and follow the specified retry policy; otherwise report the blocker.

Before treating work as complete, the execution lane checks exit status, output integrity, deviations and cleanup status. A scientific or product conclusion still needs its appropriate analysis or review. Report measured cost and resource state when relevant, and mark unavailable accounting as unknown rather than estimating it as fact.

Keep credentials out of briefs, commands, logs and reports. Use the environment's approved secret mechanism. A permission denial is not permission to reroute the action through another agent; report the denied action and reason, and use a permitted alternative if one exists.
