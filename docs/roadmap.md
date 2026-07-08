# Roadmap

Achords ecosystem — Products and their status.

## Products

### 1. Organization Base

**What**: Initializes a GitHub organization configured with resources for agent-assisted development.

**Status**: ✅ Stable  
**Branch**: main

| Feature | Status | Notes |
|---------|--------|-------|
| `org-bootstrap` | ✅ Stable | Creates org structure |
| `org-join` | ✅ Stable | Team member onboarding |
| `.engram` integration | ✅ Stable | Shared memory submodule |
| Multi-org support | ✅ Stable | `.env` configuration |
| Error handling | ✅ Stable | Pre-checks, conflict detection |

**What it creates:**
```
your-org/
├── .github/          # Public profile
├── .internal/        # Team docs, onboarding
└── .skills/          # Shared skills library
```

---

### 2. Repository Coordination

**What**: Manages coordination between different agents working on the same repository.

**Status**: 🚧 In Development  
**Branch**: feat/repository-coordination

| Feature | Status | Notes |
|---------|--------|-------|
| `achords-init` | 🚧 In Development | Bootstrap protocol |
| `agent-union` | 📋 Planned | Agent registration |
| `claim-declaration` | 📋 Planned | Intent declaration |
| `claim-collision-check` | 📋 Planned | Overlap detection |
| `alignment-verify` | 📋 Planned | CI validation |

**What it creates:**
```
your-repo/
├── .achords/
│   ├── registry.json       # Agent registry
│   ├── claims.json         # Active claims
│   ├── events.ndjson       # Audit log
│   └── schemas/            # JSON schemas
└── .github/workflows/
    └── achords-*.yml       # CI workflows
```

---

### 3. IA on CI

**What**: Manages AI-powered review processes for repository integration.

**Status**: 📋 Planned  
**Branch**: TBD

| Feature | Status | Notes |
|---------|--------|-------|
| PR review automation | 📋 Planned | — |
| Code quality checks | 📋 Planned | — |
| Protocol compliance | 📋 Planned | — |
| Merge gating | 📋 Planned | — |

**What it will do:**
- Review PRs against protocol rules
- Check claim compliance
- Validate code quality
- Block or allow merges

---

### 4. KB Web

**What**: Obsidian-compatible web interface for organization documentation, repository history, and memories.

**Status**: 🚧 In Development  
**Branch**: v5 (based on Quartz)

| Feature | Status | Notes |
|---------|--------|-------|
| Quartz v5 setup | ✅ Complete | Cloned and configured |
| Achords docs | ✅ Complete | Copied to content/ |
| .engram sync | ✅ Complete | Script ready |
| GitHub Pages deploy | ✅ Complete | Workflow ready |
| Custom theme | 📋 Planned | Branding pending |
| Repo history viewer | 📋 Planned | — |
| Agent levels page | 📋 Planned | — |

**What it shows:**
- Organization documentation
- Repository commit history
- `.engram` memories (decisions, discoveries)
- Visual graph of relationships

---

## Status Legend

| Status | Meaning |
|--------|---------|
| ✅ Stable | Fully implemented, tested, documented |
| 🚧 In Development | Being built, not yet complete |
| 📋 Planned | Designed but not yet implemented |

## Branch Strategy

```
main
├── Organization Base (stable)
└── Documentation

feat/repository-coordination
└── Repository Rules (in development)

feat/ia-on-ci
└── AI review (planned)

feat/kb-web
└── Knowledge base web (in development - Quartz v5)
```

---

*Updated as products move from Planned → In Development → Stable.*
