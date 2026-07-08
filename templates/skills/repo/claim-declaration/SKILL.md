---
name: claim-declaration
description: Declare work intent (claim) before editing source files. Adds a claim entry to .achords/claims.json with paths, purpose, mode, and TTL. Use when starting work on specific files to coordinate with other agents and prevent collisions.
license: MIT
compatibility: Requires .achords/ and agent registered via agent-union skill.
metadata:
  author: Achords
  version: "1.0.0"
  category: coordination
  skill_type: core
---

# claim-declaration Skill

## Purpose

Declare a work claim before editing code. Establishes explicit intent over specific file paths.

## When to use

- Before modifying source files
- Starting a new feature or refactoring
- Coordinating with other agents to prevent path collisions
- Allocating time-limited work windows

## What it does

1. Prompts for claim details:
   - `paths`: File paths/glob patterns (e.g., "src/auth/**")
   - `purpose`: Human description of intended work
   - `mode`: `exclusive` (blocking overlaps) or `advisory` (informational)
   - `ttl_minutes`: Time-to-live for the claim
2. Validates inputs against schema
3. Generates unique `claim_id`
4. Creates claim entry in `.achords/claims.json`:
   ```json
   {
     "id": "claim-20260704-001",
     "agent_id": "agent-a-001",
     "paths": ["src/auth/**", "tests/auth/**"],
     "purpose": "Refactor JWT validation module",
     "mode": "exclusive",
     "ttl_minutes": 120,
     "status": "active",
     "created_at": "2026-07-04T10:45:00Z",
     "released_at": null
   }
   ```
5. Logs claim event to `.achords/events.ndjson`

## Steps

### Declare a new claim

1. Ensure you're registered via `agent-union` skill
2. Run: `python .achords/skills/claim-declaration/scripts/declare-claim.py`
3. Answer prompts:
   ```
   Paths to claim (comma-separated globs): src/auth/**, tests/auth/**
   Purpose (brief description): Refactor JWT validation module
   Mode [exclusive/advisory] [exclusive]: exclusive
   TTL in minutes [240]: 120
   ```
4. Verify claim ID and details
5. Confirm to add to claims.json
6. Proceed with editing the claimed files

## Claim mode guide

### `exclusive` mode
- Only your agent can edit claimed paths
- Other agents' overlapping exclusive claims → CI blocks merge
- Used for critical refactoring or coordinated work
- **Choose this by default** for most changes

### `advisory` mode
- Informational; doesn't block other agents
- Used for large-scale changes you want to broadcast
- Allows collaboration/concurrent editing
- Choose if work is non-blocking

## TTL guidance

| Work Type | TTL Minutes | Notes |
|-----------|------------|-------|
| Quick fix | 15-30 | Small bug fixes |
| Feature work | 120-240 | Typical feature branch |
| Large refactor | 480-1440 | Multi-day work (8-24 hours) |
| Spike/exploration | 60-120 | Experimental work |

## Output

On success:
```
✓ Claim created
✓ Claim ID: claim-20260704-001
✓ Agent: agent-a-001
✓ Paths: src/auth/**, tests/auth/**
✓ Mode: exclusive
✓ TTL: 120 minutes
✓ Status: active (expires at 2026-07-04T12:45:00Z)
✓ Event logged to events.ndjson
```

On error (e.g., overlapping exclusive claim):
```
✗ Warning: Exclusive claim overlap detected
  Overlapping claim: claim-20260704-002 (agent-b-001)
  Paths: src/auth/jwt.py
  Consider: changing mode to advisory or coordinating via GitHub issue
```

## Files modified

```
.achords/
├── claims.json              (modified: added claim entry)
└── events.ndjson           (modified: added declare event)
```

## Releasing a claim

When you finish the work:

1. Run: `python .achords/skills/claim-declaration/scripts/release-claim.py claim-20260704-001`
2. Claim status changes from `active` to `released`
3. `released_at` timestamp is set
4. Event logged

Alternatively, claims auto-expire after TTL expires.

## Next steps

1. Edit files covered by the claim
2. Commit and push to feature branch
3. Open PR (CI will validate via `alignment-verify`)
4. After merge, claim auto-releases
5. Read `alignment-verify` skill for merge requirements

## See also

- [AGENTS.md](../../../AGENTS.md) - Collaboration rules
- [claim-collision-check](../claim-collision-check/SKILL.md) - Detect overlaps
- [agent-union](../agent-union/SKILL.md) - Agent registration
