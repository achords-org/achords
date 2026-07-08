# Achords Protocol Specification

Version: 1.0.0  
Status: Draft

## Overview

Achords is a lightweight, repository-native protocol for multi-agent software collaboration. It provides coordination primitives through JSON files and GitHub Actions workflows.

## Protocol Entities

### Agent

An entity (AI, human, or service) that makes contributions to a repository.

**Registry entry**:
```json
{
  "agent_id": "agent-a-001",
  "name": "Claude Code Assistant",
  "agent_type": "ai",
  "status": "active",
  "registered_at": "2026-07-07T10:00:00Z"
}
```

**State**:
```json
{
  "agent_id": "agent-a-001",
  "has_messages": 0,
  "last_activity": "2026-07-07T10:30:00Z",
  "active_claims": ["claim-20260707-001"]
}
```

### Claim

A pre-edit declaration of intent over repository paths.

**Structure**:
```json
{
  "id": "claim-20260707-001",
  "agent_id": "agent-a-001",
  "paths": ["src/auth/**"],
  "purpose": "Refactor JWT validation",
  "mode": "exclusive",
  "ttl_minutes": 240,
  "status": "active",
  "created_at": "2026-07-07T10:00:00Z",
  "released_at": null
}
```

**Modes**:
- `exclusive`: Blocks other agents from overlapping paths
- `advisory`: Signals intent without blocking

**Statuses**:
- `active`: Claim is in effect
- `released`: Agent finished work
- `expired`: TTL elapsed

### Event

A state change logged to the audit trail.

**Structure**:
```json
{
  "type": "claim-created",
  "timestamp": "2026-07-07T10:00:00Z",
  "agent_id": "agent-a-001",
  "claim_id": "claim-20260707-001"
}
```

**Event types**:
- `bootstrap`: Protocol initialized
- `agent-union`: Agent registered
- `claim-created`: Claim declared
- `claim-released`: Claim released
- `alignment-check`: CI validation run

## Protocol Files

| File | Purpose |
|------|---------|
| `version.json` | Protocol version and status |
| `registry.json` | Agent registry |
| `claims.json` | Active claims |
| `topology.json` | Collaboration configuration |
| `policies.json` | Policy rules |
| `events.ndjson` | Audit log |
| `supervisor/state.json` | CI state |

## Collaboration Rules

1. **Union first**: Agents must register before contributing
2. **Claim before edit**: Agents must declare intent before modifying files
3. **Collision discipline**: Never proceed with overlapping exclusive claims
4. **Supervisor authority**: CI checks are authoritative for merge safety

## CI Validation

The `alignment-verify` workflow checks:

1. Required protocol files exist
2. JSON syntax is valid
3. No blocking claim overlaps
4. Events are logged consistently

**On pass**: Merge allowed  
**On fail**: Merge blocked, issues must be fixed

---

*This specification is normative. Implementations must follow it.*
