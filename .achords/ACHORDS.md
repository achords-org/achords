# Achords Protocol Specification

## Overview

Achords is a lightweight, repository-native protocol for multi-agent software collaboration. It provides:

- **Platform management** for organization setup and team onboarding
- **Union onboarding** for agent identity and lifecycle
- **Claims** for explicit pre-edit intent over repository paths
- **Supervisor alignment checks** in CI for collision and policy enforcement
- **Versioned state files** for transparency and auditability
- **Agent Skills** for discoverable, self-contained protocol operations

## Three-level architecture

Achords operates across three levels:

### Platform level

Organization-level operations for setting up and joining teams.

| Skill | Purpose |
|-------|---------|
| `org-bootstrap` | Initialize GitHub organization structure |
| `org-join` | Team member onboarding |

### Repository level

Repository-level operations for managing agent collaboration.

| Skill | Purpose |
|-------|---------|
| `achords-init` | Bootstrap protocol in repository |
| `agent-union` | Register agent identity |
| `claim-declaration` | Declare work intent |
| `claim-collision-check` | Detect overlapping claims |
| `alignment-verify` | CI validation |

### Agent level

Individual agent operations within the protocol.

| Operation | Purpose |
|-----------|---------|
| Claim lifecycle | Create, use, release claims |
| Inbox processing | Check and respond to messages |
| State management | Track activity and status |

## Protocol Files

### `version.json`
Stores protocol version, initialization date, and status.

### `registry.json`
Canonical list of onboarded agents. New agents are registered via the `agent-union` skill.

### `claims.json`
Active, released, and expired claims over repository paths. Agents declare intent before editing via the `claim-declaration` skill.

### `topology.json`
Team collaboration topology, supervision model, and coordination strategy.

### `policies.json`
Policy flags and enforcement rules:
- Claim requirement (enabled/disabled)
- Exclusive claim overlap handling (blocking/advisory)
- Enforcement level (advisory/strict/regulated)

### `events.ndjson`
Append-only event stream for audit trail. Newline-delimited JSON recording all state transitions and actions.

### `supervisor/state.json`
Supervisor mode (`advisory` or `strict`), alignment check status, and blocked merges.

## Agent Skills

Skills are discoverable, self-contained protocol operations. Located in `.achords/skills/`, each skill has:

- **SKILL.md**: YAML frontmatter + Markdown instructions (agentskills.io format)
- **scripts/**: Executable code (Python, Bash, etc.)
- **assets/**: Templates, reference files
- **references/**: Documentation

### Core Skills

**Platform:**
1. **org-bootstrap** - Initialize organization structure
2. **org-join** - Join existing organization

**Repository:**
3. **achords-init** - Bootstrap Achords in a repository
4. **agent-union** - Register a new agent
5. **claim-declaration** - Declare work intent
6. **claim-collision-check** - Detect overlapping claims
7. **alignment-verify** - CI validation

## Collaboration Workflow

### Platform initialization (one-time)

```
1. Organization owner
   ↓ (Run org-bootstrap skill)
2. GitHub org structure created
   ↓ (Repos cloned locally)
3. Base files generated
   ↓ (Team members can now join)
```

### Team member onboarding

```
1. New team member
   ↓ (Run org-join skill)
2. Repos cloned to ~/Poincare/
   ↓ (Read onboarding docs)
3. Ready for contributions
```

### Repository setup

```
1. New repository
   ↓ (Run achords-init skill)
2. Initialize .achords/ structure
   ↓ (Protocol files created)
3. Ready for agent registration
```

### Agent workflow

```
1. New agent arrives at repository
   ↓
2. Reads AGENTS.md (mandatory)
   ↓
3. Reads .achords/skills/agent-union/SKILL.md
   ↓
4. Runs agent-union skill
   ↓
5. Agent registered in .achords/registry.json
   ↓
6. Reads .achords/skills/claim-declaration/SKILL.md
   ↓
7. Plans work, declares claim in .achords/claims.json
   ↓
8. Makes code changes
   ↓
9. Commits and opens PR
   ↓
10. CI runs alignment-verify skill automatically
    ✓ Alignment PASSED → merge allowed
    ✗ Alignment FAILED → fix and retry
   ↓
11. PR merged, claim auto-releases
    ↓
12. Event logged to events.ndjson
```

## Claim Lifecycle

A claim has fields:

```json
{
  "id": "claim-001",
  "agent_id": "agent-a-001",
  "paths": ["src/**", "tests/**"],
  "purpose": "Refactor authentication module",
  "mode": "exclusive",
  "ttl_minutes": 240,
  "status": "active",
  "created_at": "2026-07-04T10:00:00Z",
  "released_at": null
}
```

**Status values**: `active`, `released`, `expired`

**Mode values**: 
- `exclusive`: Only this agent can edit paths
- `advisory`: Advisory; overlaps allowed but noted

## Collision Discipline

- **Active exclusive claims** from different agents on overlapping paths → CI blocks merge
- Resolution: coordinate via issue comments, split paths, or change mode
- Supervisor authority: CI checks are final arbiter

## JSON Schema Validation

All protocol files conform to JSON schemas in `.achords/schemas/`:

- `agent-profile.schema.json` - Agent registry entries
- `agent-state.schema.json` - Per-agent state (inbox, metadata)
- `claim.schema.json` - Claim structure and constraints
- `message.schema.json` - Inter-agent message format

## Extensions & Future

Achords is designed for incremental evolution:

- **Phase 1 (Current)**: Platform setup, union, claims, basic alignment checks
- **Phase 2**: Objective tracking, dependency graphs, policy profiles
- **Phase 3**: Cross-repo federation, rich metrics, policy enforcement tiers
- **Phase 4**: Agent-to-agent delegation, learned collision patterns

---

See `.achords/skills/` for protocol operations. See `/docs/` for operational guides.
