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
│  .skills/                     ← Versioned skills           │
│  ├── version.json             ← Global version index       │
│  └── skills/                  ← Skill directories          │
│      ├── testing/                                        │
│      │   ├── manifest.json    ← Version list              │
│      │   ├── SKILL.md         ← Reference to latest       │
│      │   └── versions/        ← Version files             │
│      │       ├── v1.0.0.md                                 │
│      │       └── v1.1.0.md                                 │
│      └── code-review/                                     │
│          ├── manifest.json                                 │
│          ├── SKILL.md                                      │
│          └── versions/                                     │
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

## Skill Versioning

### Structure

```
.skills/
├── version.json                    # Global version index
├── AGENTS.md                       # Agent entry point
└── skills/
    ├── testing/
    │   ├── manifest.json           # Version list
    │   ├── SKILL.md                # Reference to latest
    │   └── versions/
    │       ├── v1.0.0/             # Version directory
    │       │   ├── SKILL.md        # Skill instructions
    │       │   └── scripts/        # Helper scripts (optional)
    │       └── v1.1.0/
    │           ├── SKILL.md
    │           └── scripts/
    └── code-review/
        ├── manifest.json
        ├── SKILL.md
        └── versions/
            ├── v1.0.0/
            └── v1.1.0/
```

**Each version is a directory** because skills can contain:
- `SKILL.md` — Main instructions
- `scripts/` — Helper scripts (optional)
- `references/` — Additional docs (optional)

### Manifest Format

```json
{
  "name": "testing",
  "latest": "v1.1.0",
  "versions": [
    {
      "version": "v1.0.0",
      "path": "versions/v1.0.0",
      "description": "Initial version",
      "platforms": ["linux", "macos", "windows"],
      "created": "2026-07-08"
    },
    {
      "version": "v1.1.0",
      "path": "versions/v1.1.0",
      "description": "Added gotchas and validation",
      "platforms": ["linux", "macos", "windows"],
      "created": "2026-07-09"
    }
  ]
}
```

### Forks/Variants

Skills can have platform-specific forks:

```
versions/
├── v1.1.0/           # Standard version
│   ├── SKILL.md
│   └── scripts/
├── v1.1.0-windows/   # Windows fork
│   ├── SKILL.md
│   └── scripts/
└── v1.1.0-arm/       # ARM fork
    ├── SKILL.md
    └── scripts/
```

Forks reference parent via `forked_from` in manifest:

```json
{
  "version": "v1.1.0-windows",
  "path": "versions/v1.1.0-windows",
  "description": "Windows-specific fork",
  "platforms": ["windows"],
  "forked_from": "v1.1.0",
  "created": "2026-07-09"
}
```

### Why Versioned Skills?

1. **History preserved** — explicit version files
2. **Forks supported** — variants tracked
3. **Manifest provides** — quick overview
4. **Agent-friendly** — clear loading flow
5. **Future-proof** — ai-on-ci integration planned

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

### Existing Skills

```bash
# Convert to versioned structure
achords skills versionize testing
```
