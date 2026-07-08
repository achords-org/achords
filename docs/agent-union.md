# Agent Union: Onboarding Guide

## Overview

Agent union is the process of registering a new agent in the Achords protocol before it makes any contributions. It establishes agent identity, creates state tracking infrastructure, and enables the supervisor to track who is making changes.

## When to perform union

**Mandatory**: Before an agent makes its first contribution.

This applies to:
- New AI agents being introduced to the repository
- New team members (human)
- Bots or automation services
- Any entity that will create commits

## Union steps

### 1. Ensure `.achords/` exists

If this is a new repository or Achords hasn't been initialized:

```bash
# Run achords-init skill first
python .achords/skills/achords-init/scripts/init.sh
```

If `.achords/` already exists, proceed to step 2.

### 2. Read the agent-union skill

```bash
cat .achords/skills/agent-union/SKILL.md
```

This explains what union does and the required inputs.

### 3. Run the agent-union script

```bash
python .achords/skills/agent-union/scripts/register-agent.py
```

You'll be prompted for:

| Field | Example | Notes |
|-------|---------|-------|
| `agent_id` | `agent-a-001` | Lowercase, alphanumeric, hyphens. Pattern: `^[a-z0-9-]+$` |
| `name` | `Claude Code Assistant` | Human-readable name |
| `agent_type` | `ai` | One of: `ai`, `human`, `service` |

### 4. Verify the entry

The script will confirm:

```
✓ Agent registered
✓ agent_id: agent-a-001
✓ Name: Claude Code Assistant
✓ Type: ai
✓ Status: active
✓ Registry updated: .achords/registry.json
✓ State created: .achords/agents/agent-a-001/state.json
✓ Event logged: events.ndjson
```

### 5. Commit the changes

```bash
git add .achords/registry.json .achords/agents/ .achords/events.ndjson
git commit -m "feat: register agent-a-001 via agent-union"
```

Push to main or a feature branch (no PR required for union commits).

## Choosing an agent_id

Recommended format: `agent-{type-letter}-{sequence}`

Examples:
- `agent-a-001` - First AI agent (a)
- `agent-a-002` - Second AI agent
- `agent-h-001` - First human (h)
- `agent-s-001` - First service (s)

Or use domain-specific names:
- `agent-code-gen-01`
- `agent-code-review-01`

Requirements:
- Lowercase only
- Alphanumeric + hyphens
- 1-255 characters
- Must be unique in registry

## After union

Once registered, the agent is ready to:

1. Read `.achords/skills/claim-declaration/SKILL.md`
2. Declare claims before editing code
3. Make contributions under the Achords protocol

## Union file outputs

### registry.json (modified)

New entry added:

```json
{
  "agent_id": "agent-a-001",
  "name": "Claude Code Assistant",
  "agent_type": "ai",
  "status": "active",
  "registered_at": "2026-07-04T10:15:00Z",
  "metadata": {}
}
```

### agents/<agent_id>/state.json (created)

Per-agent state tracking:

```json
{
  "agent_id": "agent-a-001",
  "has_messages": 0,
  "last_activity": "2026-07-04T10:15:00Z",
  "active_claims": [],
  "metadata": {}
}
```

### agents/<agent_id>/inbox/ (created)

Directory for inter-agent messages (initially empty).

### events.ndjson (modified)

New event appended:

```jsonlines
{"type":"agent-union","timestamp":"2026-07-04T10:15:00Z","agent_id":"agent-a-001","status":"success"}
```

## Common issues

### Error: "agent_id already exists"

```
✗ agent_id 'agent-a-001' already registered
```

**Cause**: Agent already registered.

**Fix**: Use a different agent_id (increment sequence).

### Error: "Invalid agent_id format"

```
✗ agent_id must match pattern: ^[a-z0-9-]+$
```

**Cause**: agent_id contains uppercase, spaces, or invalid characters.

**Fix**: Use lowercase letters, numbers, and hyphens only.

### Error: ".achords/ does not exist"

```
✗ .achords/ directory not found
```

**Cause**: Achords not initialized.

**Fix**: Run `achords-init` skill first.

## Reusing agent_id across repositories

Each repository has its own registry. The same `agent_id` can be registered in multiple repositories independently. If you want global agent identity, consider:

1. Using a standard naming convention (e.g., `agent-claude-001`)
2. Documenting agent identity in team wiki
3. Using GitHub Actions secrets/context (future enhancement)

## Removing an agent

Currently: No removal mechanism (agents are immutable for audit trail).

**Workaround**: Set agent status to `inactive` manually in `registry.json`:

```json
{
  "agent_id": "agent-old-001",
  "status": "inactive",
  "retired_at": "2026-07-04T15:00:00Z"
}
```

Then log an event to `events.ndjson`:

```jsonlines
{"type":"agent-retired","timestamp":"2026-07-04T15:00:00Z","agent_id":"agent-old-001"}
```

## Inbox and messages (future)

Currently: `.achords/agents/<agent_id>/inbox/` is created but unused.

Future: Inter-agent messaging for collision coordination:

```json
{
  "id": "msg-001",
  "from_agent_id": "agent-b-001",
  "to_agent_id": "agent-a-001",
  "type": "collision-alert",
  "subject": "Overlapping claim detected",
  "body": "Your claim overlaps with my claim on src/auth/**. Let's coordinate.",
  "timestamp": "2026-07-04T10:20:00Z",
  "priority": "high"
}
```

## See also

- [achords.md](achords.md) - Full protocol spec
- [claims-and-alignment.md](claims-and-alignment.md) - Claiming and CI checks
- `.achords/skills/agent-union/SKILL.md` - Skill reference
