---
name: agent-union
description: Onboard a new agent to the Achords protocol. Registers agent_id in registry.json, creates .achords/agents/<agent_id>/ folder with state.json, and logs union event. Use before an agent makes its first contribution to ensure proper tracking and coordination.
license: MIT
compatibility: Requires existing .achords/ directory. Run achords-init first if needed.
metadata:
  author: Achords
  version: "1.0.0"
  category: agent-management
  skill_type: core
---

# agent-union Skill

## Purpose

Register and onboard a new agent into the Achords protocol before it makes any contributions.

## When to use

- New agent joining the repository (human or AI)
- First contribution from an agent
- Formally establishing agent identity for claim tracking
- Setting up agent state and messaging infrastructure

## What it does

1. Validates `.achords/registry.json` exists
2. Prompts for or accepts `agent_id`, `name`, and `agent_type`
3. Validates `agent_id` format (lowercase alphanumeric + hyphens)
4. Creates `.achords/agents/<agent_id>/` directory
5. Creates `.achords/agents/<agent_id>/state.json` with:
   - `agent_id`
   - `has_messages = 0` (no pending messages)
   - `active_claims = []`
   - `last_activity` timestamp
6. Adds agent entry to `.achords/registry.json`:
   - `agent_id`
   - `name`
   - `agent_type` (ai/human/service)
   - `status = active`
   - `registered_at` timestamp
7. Logs union event to `.achords/events.ndjson`

## Steps

### Using the skill

1. Ensure `.achords/` exists (run `achords-init` if needed)
2. Run: `python .achords/skills/agent-union/scripts/register-agent.py`
3. Follow prompts:
   ```
   Agent ID [e.g., agent-a-001]: agent-b-002
   Agent name: Claude Code Assistant
   Agent type (ai/human/service) [ai]: ai
   ```
4. Verify output

## Required agent_id format

- Lowercase letters, numbers, hyphens only
- Pattern: `^[a-z0-9-]+$`
- Recommended: `agent-{type}-{seq}` (e.g., `agent-a-001`)

## Output

On success:
```
✓ Agent registered
✓ agent_id: agent-b-002
✓ Status: active
✓ Registry updated
✓ State file created at .achords/agents/agent-b-002/state.json
✓ Event logged to events.ndjson
```

On error (e.g., agent already registered):
```
✗ agent_id 'agent-b-002' already exists in registry.json
```

## Files created/modified

```
.achords/
├── registry.json                    (modified: added agent entry)
├── agents/
│   └── <agent_id>/
│       ├── state.json              (created)
│       └── inbox/                  (created)
└── events.ndjson                   (modified: added union event)
```

## Agent state structure

```json
{
  "agent_id": "agent-b-002",
  "has_messages": 0,
  "last_activity": "2026-07-04T10:30:00Z",
  "active_claims": [],
  "metadata": {}
}
```

## Next steps

1. Agent reads `claim-declaration` skill documentation
2. Agent declares a claim before modifying source code
3. Agent makes changes and opens PR
4. CI runs `alignment-verify` to check protocol compliance

## See also

- [AGENTS.md](../../../AGENTS.md) - Mandatory collaboration rules
- [claim-declaration](../claim-declaration/SKILL.md) - Declare work intent
- [achords-init](../achords-init/SKILL.md) - Bootstrap protocol
