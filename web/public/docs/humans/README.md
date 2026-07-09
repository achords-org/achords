# Achords — Architecture

> How obase works and why it's designed this way.

## Overview

Obase is the layer that tells AI agents how to interpret achords resources. It generates `AGENTS.md` files that are the entry point for agents.

## Core Concept

```
┌─────────────────────────────────────────────────────────────┐
│                     ACHORDS ECOSYSTEM                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  .achords/                    ← Org rules (shared)         │
│  ├── AGENTS.md                ← Main entry point           │
│  ├── .engram/                 ← Shared memory              │
│  ├── config/                  ← Policies & conventions     │
│  └── skills/                  ← Shared skills              │
│                                                             │
│  repo/                         ← Your project              │
│  ├── AGENTS.md                ← Repo-specific rules        │
│  ├── .achords/ → (submodule)  ← Points to org rules        │
│  └── .engram/                 ← Isolated repo memory       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Agent Flow

### Diagram

```
SESSION START
      │
      ▼
┌─────────────────────────────────────┐
│  1. MANDATORY READS                 │
│  ├── .achords/AGENTS.md             │
│  └── .engram/config.json            │
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│  2. MEMORY SYNC                     │
│  ├── git submodule update           │
│  ├── mem_search(org)                │
│  └── mem_search(repo)               │
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│  3. ON-DEMAND READS                 │
│  ├── conventions.json (when coding) │
│  ├── policies.json (when checking)  │
│  └── skills/*.md (when task matches)│
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│  4. DURING WORK                     │
│  ├── mem_save() after decisions     │
│  └── mem_search() before new tasks  │
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│  5. SESSION END                     │
│  └── mem_session_summary()          │
└─────────────────────────────────────┘
```

### Why This Flow?

1. **Mandatory reads first** — Agent needs org rules before ANY work
2. **Memory sync** — Load context from previous sessions
3. **On-demand reads** — Don't load everything upfront
4. **During work** — Save decisions as they happen
5. **Session end** — Always summarize for next session

## File Classification

### Mandatory Files

| File | Why Mandatory |
|------|---------------|
| `.achords/AGENTS.md` | Entry point for org rules |
| `.engram/config.json` | Project name for memory isolation |

### On-Demand Files

| File | When to Read |
|------|--------------|
| `.achords/config/conventions.json` | Before writing code |
| `.achords/config/policies.json` | Before access decisions |
| `.skills/skills/*.md` | When task matches skill description |
| `.internal/onboarding/` | When setting up new repo |

## Memory Isolation

### Org Memory (shared)

- **Location**: `.achords/.engram/`
- **Scope**: All repos in org
- **Sync**: Via git submodule
- **Use**: Conventions, patterns, shared knowledge

### Repo Memory (isolated)

- **Location**: `.engram/`
- **Scope**: Single repo
- **Sync**: Local only
- **Use**: Repo-specific decisions, bugs, features

### Why Isolation?

- Different repos have different contexts
- Prevents memory pollution
- Allows org-wide patterns without repo noise

## Version Control

### Header Versioning

```markdown
<!-- achords:header:v1.1.0 -->
```

- Changes when achords updates resources
- Agent sees new resources in table
- Repos pull via `git submodule update`

### Resource Table

| Resource | Path | Purpose |
|----------|------|---------|
| Org Rules | `.achords/AGENTS.md` | Organization-wide agent rules |
| Org Memory | `.achords/.engram/` | Shared knowledge (git-synced) |
| Conventions | `.achords/config/conventions.json` | Code conventions |
| Policies | `.achords/config/policies.json` | Org policies |
| Skills | `.skills/skills/` | Shared skills (Agent Skills spec) |
| Onboarding | `.internal/onboarding/` | Setup scripts and docs |
| Repo Memory | `.engram/` | Isolated repo memory |
| Repo Config | `.engram/config.json` | project_name setting |

## Design Decisions

### Why Two AGENTS.md Files?

1. **`.achords/AGENTS.md`** — Org rules, shared across all repos
2. **`repo/AGENTS.md`** — Repo-specific rules, can override org

**Benefit**: Org stays consistent, repos stay flexible.

### Why Header Versioning?

- Agent sees what resources are available
- New resources added without breaking existing repos
- Clear migration path when version changes

### Why Lazy Loading?

- Not all repos use all resources
- Skills loaded only when task matches
- Reduces initial context load

## Migration

### Existing Repos

```bash
# Add header to existing AGENTS.md
achords obase --repo my-repo --update-header
```

### New Repos

```bash
# Full setup
achords obase --repo my-repo
```
