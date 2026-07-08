# Claims System

Claims are how agents declare intent before modifying code.

## What is a Claim?

A claim is a pre-edit contract that says:

- **What** paths will be modified
- **Why** the modification is needed
- **How long** the claim is valid (TTL)
- **Whether** it blocks other agents (exclusive vs advisory)

## Claim Lifecycle

```
Created → Active → Released
                 → Expired (TTL elapsed)
```

### States

| State | Meaning |
|-------|---------|
| `active` | Claim is in effect, paths are reserved |
| `released` | Agent finished, claim explicitly released |
| `expired` | TTL elapsed, claim no longer valid |

## Claim Modes

### Exclusive

```json
{
  "mode": "exclusive"
}
```

- **Blocks** other agents from claiming overlapping paths
- Use when: Agent needs sole access to prevent conflicts
- Example: Refactoring a critical module

### Advisory

```json
{
  "mode": "advisory"
}
```

- **Does not block** other agents
- Use when: Agent wants to signal intent, not reserve paths
- Example: Bug fix, documentation update

## Claim Structure

```json
{
  "id": "claim-20260707-001",
  "agent_id": "agent-a-001",
  "paths": ["src/auth/**", "tests/auth/**"],
  "purpose": "Refactor JWT validation for better error handling",
  "mode": "exclusive",
  "ttl_minutes": 240,
  "status": "active",
  "created_at": "2026-07-07T10:00:00Z",
  "released_at": null
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique claim identifier |
| `agent_id` | Yes | Who made the claim |
| `paths` | Yes | File patterns covered |
| `purpose` | Yes | Why the work is needed |
| `mode` | Yes | `exclusive` or `advisory` |
| `ttl_minutes` | Yes | How long claim is valid |
| `status` | Yes | Current state |
| `created_at` | Yes | When claim was made |
| `released_at` | No | When claim was released |

## Collision Detection

When two agents claim overlapping paths with `exclusive` mode:

```
Agent A: Claims src/auth/** (exclusive)
Agent B: Claims src/auth/jwt.py (exclusive)

Result: BLOCKING COLLISION
CI will block both PRs until resolved
```

### Resolution Options

1. **Coordinate** — Agents agree on path split
2. **Change mode** — One agent switches to advisory
3. **Wait** — One agent waits for the other to release
4. **Escalate** — Supervisor decides

## Example Workflow

```bash
# 1. Agent declares claim
python templates/skills/repo/claim-declaration/scripts/declare-claim.py

# Output:
# Claim ID: claim-20260707-001
# Paths: src/auth/**
# Mode: exclusive
# Status: active

# 2. Agent works on code
# ...

# 3. Agent opens PR
# CI checks claims.json for conflicts

# 4. PR merges, claim auto-releases
# Event logged to events.ndjson
```

---

*See [Collaboration](./collaboration.md) for async vs sync modes.*
