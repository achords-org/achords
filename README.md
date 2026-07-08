# Achords

**Achords (Agent Chords)** is a lightweight, repository-native protocol for multi-agent software collaboration.

It standardizes how organizations, repositories, and agents coordinate across three levels:

- **Platform** — Organization setup and team onboarding
- **Repository** — Claim-based intent and CI alignment
- **Agent** — Identity, registration, and contribution workflow

---

## Mandatory for all agents

Before doing any work in this repository, **read**:

- [`AGENTS.md`](./AGENTS.md)

That file defines mandatory collaboration rules (union, claim-before-edit, collision handling, alignment authority).

If an agent skips `AGENTS.md`, its contributions are considered non-compliant.

---

## Why Achords

As multi-agent development scales, teams need explicit coordination primitives that are:

- **Repo-native** (state lives in Git)
- **Lightweight** (JSON + workflows)
- **Auditable** (events and decisions are inspectable)
- **Extensible** (schema/policy evolution)
- **Multi-level** (organization → repository → agent)

Achords provides those primitives without requiring heavy external orchestration.

---

## Three-level architecture

```
Platform (Organization)
├── org-bootstrap    Create GitHub org structure
├── org-join         Team member onboarding
└── ...
    │
    ▼
Repository
├── achords-init     Bootstrap protocol in repo
├── agent-union      Register agent
├── claim-declaration    Declare work intent
├── claim-collision-check    Detect overlaps
├── alignment-verify    CI validation
└── ...
    │
    ▼
Agent
└── Contributes via claims → PR → CI → merge
```

| Level | Scope | Skills |
|-------|-------|--------|
| **Platform** | GitHub organization | `org-bootstrap`, `org-join` |
| **Repository** | Individual repo | `achords-init`, `agent-union`, claims, alignment |
| **Agent** | Specific agent | `claim-declaration`, `alignment-verify` |

---

## Quick start

### Developer environment setup

```bash
# Set up opencode + gentle-ai + .engram for a project
bash .achords/skills/platform/org-bootstrap/scripts/dev-setup.sh <project-name>
```

This installs:
- **opencode** — AI coding assistant
- **gentle-ai** — SDD workflow with Engram
- **.engram** — Shared memory submodule

### For organization owners

```bash
# Bootstrap a new organization
bash .achords/skills/platform/org-bootstrap/scripts/bootstrap.sh <org-name>
```

### For team members

```bash
# Join an existing organization
bash .achords/skills/platform/org-join/scripts/setup.sh <org-name>
```

### For repository setup

```bash
# Initialize Achords in a repository
bash .achords/skills/achords-init/scripts/init.sh
```

### For agents

```bash
# Register as an agent
python .achords/skills/agent-union/scripts/register-agent.py

# Declare work intent
python .achords/skills/claim-declaration/scripts/declare-claim.py
```

---

## Repository structure

```text
.
├── AGENTS.md
├── README.md
├── VALUE_PROPOSITION.md
├── docs/
│   ├── achords.md
│   ├── agent-union.md
│   ├── claims-and-alignment.md
│   └── file-locations.md          # Where each file lives and what it does
├── .engram/                        # Shared memory (git submodule)
│   ├── README.md
│   ├── decisions/
│   ├── discoveries/
│   ├── patterns/
│   ├── bugs/
│   └── sessions/
├── .achords/
│   ├── ACHORDS.md
│   ├── version.json
│   ├── registry.json
│   ├── claims.json
│   ├── topology.json
│   ├── policies.json
│   ├── events.ndjson
│   ├── agents/
│   │   └── .gitkeep
│   ├── supervisor/
│   │   └── state.json
│   ├── schemas/
│   │   ├── agent-profile.schema.json
│   │   ├── agent-state.schema.json
│   │   ├── claim.schema.json
│   │   └── message.schema.json
│   └── skills/
│       ├── platform/
│       │   ├── org-bootstrap/
│       │   │   ├── SKILL.md
│       │   │   └── scripts/
│       │   │       ├── bootstrap.sh
│       │   │       └── dev-setup.sh
│       │   └── org-join/
│       │       ├── SKILL.md
│       │       └── scripts/setup.sh
│       ├── achords-init/
│       ├── agent-union/
│       ├── claim-declaration/
│       ├── claim-collision-check/
│       └── alignment-verify/
└── .github/
    └── workflows/
        ├── achords-union.yml
        └── achords-alignment-check.yml
```

---

## Collaboration model

### Platform level

1. **Org bootstrap** — Owner creates organization structure with `org-bootstrap`
2. **Team join** — Members clone repos with `org-join`
3. **Repository initialization** — Each repo runs `achords-init`

### Repository level

1. **Agent union** — Agent registers via `agent-union`
2. **Claim declaration** — Agent declares intent via `claim-declaration`
3. **Alignment check** — CI validates via `alignment-verify`

### Agent level

1. Agent reads `AGENTS.md`
2. Agent registers via `agent-union`
3. Agent declares claims before editing
4. Agent opens PR
5. CI validates compliance
6. Merge allowed or blocked

---

## Workflows

### `achords-union.yml`
Checks onboarding PRs (e.g. PR title/label includes `agent-union`) and validates required Achords baseline context.

### `achords-alignment-check.yml`
Runs on PR updates and validates:
- required Achords files exist,
- JSON syntax is valid,
- active exclusive claims do not overlap across different agents.

---

## Related documents

- [`AGENTS.md`](./AGENTS.md) — mandatory agent rules
- [`VALUE_PROPOSITION.md`](./VALUE_PROPOSITION.md) — strategic/product framing
- [`docs/file-locations.md`](./docs/file-locations.md) — where each file lives and what it does
- [`docs/`](./docs) — operational documentation
- [`.achords/ACHORDS.md`](./.achords/ACHORDS.md) — protocol spec
- [`.achords/skills/`](./.achords/skills/README.md) — skill documentation
- [`.engram/README.md`](./.engram/README.md) — shared memory usage

---

## Current status

This repository implements the **Achords protocol** with:
- Platform-level skills for organization management
- Repository-level skills for agent coordination
- CI workflows for alignment checks
- JSON schemas for protocol entities
- Operational documentation

Future iterations can add richer semantics (objectives, dependencies, stricter policy tiers, cross-repo federation).
