# Collaboration Modes

Achords supports three coordination modes. Use the right one for the right situation.

## Overview

| Mode | When | How | Speed |
|------|------|-----|-------|
| **Async** | Different times, same repo | Claims + CI | Slow but safe |
| **Sync** | Same time, real-time coordination | Pairing, live claims | Fast but requires coordination |
| **Repository** | Structural setup | One-time init | One-time |

## Async Collaboration

**When**: Agents work at different times, no overlap needed.

**How it works**:

```
Agent A: Claims src/auth/** at 10:00
         Works for 2 hours
         Opens PR
         Merges

Agent B: Sees A's claim at 11:00
         Claims src/api/** (no overlap)
         Works
         Opens PR
         Merges
```

**Rules**:
- Check `claims.json` before starting
- Don't overlap with active exclusive claims
- CI blocks merges with conflicting claims

**Best for**:
- Distributed teams
- Different time zones
- Independent features

## Sync Collaboration

**When**: Agents need to work together in real-time.

**How it works**:

```
Agent A and B agree to pair on src/auth/**
One agent claims with advisory mode
Both work simultaneously
Coordinate via PR comments or issues
```

**Rules**:
- Use `advisory` claim mode (not exclusive)
- Communicate intent explicitly
- Merge one PR, reference both agents

**Best for**:
- Complex features requiring multiple perspectives
- Code review with the author
- Debugging sessions

## Repository-Level Coordination

**When**: Setting up the project structure.

**How it works**:

```
1. Run achords-init → creates .achords/
2. Configure policies in policies.json
3. Set up CI workflows
4. Document team rules in AGENTS.md
```

**Rules**:
- Initialize before any agents register
- Configure policies to match team culture
- Keep protocols lightweight

**Best for**:
- New projects
- Adding Achords to existing projects
- Team onboarding

## Choosing a Mode

```
Is this a one-time setup?
  → Repository mode

Are agents working independently?
  → Async mode

Do agents need to coordinate live?
  → Sync mode

Unsure?
  → Start with Async (safest default)
```

## Claim Modes

| Mode | Blocks Others | Use When |
|------|---------------|----------|
| `exclusive` | Yes | Agent needs sole access to paths |
| `advisory` | No | Agent wants to signal intent, not block |

---

*Next: [Getting Started](./getting-started.md) — Set up your first project.*
