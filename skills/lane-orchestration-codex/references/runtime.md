# Runtime adaptation

Tool availability, argument names, models and concurrency limits depend on the Codex surface. Inspect live tool definitions; the examples below are conditional mappings, not required APIs or static configuration.

When the runtime exposes `collaboration` tools:

- `spawn_agent`: start a lane. Prefer `fork_turns: "none"` with a self-contained brief when a fresh context is useful. Omit model overrides to inherit the parent's model and settings. If the user approved an explicit mapping, verify supported model identifiers and fork restrictions before using it.
- `followup_task`: assign another bounded task to an existing agent, including an idle agent.
- `send_message`: clarify or steer a running task; this may not restart an idle agent.
- `wait_agent`: wait for a completion or mailbox event. Use the returned notifications and reports; do not assume a wait response itself contains the result.
- `list_agents`: inspect live state when needed for capacity or ownership; avoid repeated status polling.
- `interrupt_agent`: stop ongoing work when its scope, budget or stopping condition requires it. Interruption may leave the agent available; it is not necessarily a way to release a capacity slot.

Other runtimes may expose different names or no delegation at all. Map the responsibilities to available tools rather than inventing calls. Do not use Claude-specific `Agent` or `run_in_background` parameters in Codex merely because the original skill used them.

Bound waits by the tool limits and communication requirements. Prefer event-driven waits; if a computation only offers a process/session handle, use its documented resume or status mechanism. A shell job that survives a tool call does not imply the conversation will autonomously resume after the turn ends. Record a resumable checkpoint when continuous operation is unavailable.

For consequential independent review, supply the reviewer the claim, assumptions, raw artifacts and requested scope, without dictating the expected verdict. The reviewer checks evidence; the coordinator compares implications and updates the shared synthesis.

## Official references

Reviewed 2026-10-10. Recheck official guidance when installing on a different surface or changing runtime configuration.

- [Build skills](https://learn.chatgpt.com/docs/build-skills): supports user skills under `~/.agents/skills`, repository skills under `.agents/skills`, symlink discovery and optional `agents/openai.yaml` metadata. Metadata describes the skill UI; it does not select the main model or create subagents.
- [Subagents configuration](https://learn.chatgpt.com/docs/agent-configuration/subagents): supports inherited settings and configurable agent roles/models where available. It does not establish which tools or models a particular live session exposes; use the runtime definitions for those details.
