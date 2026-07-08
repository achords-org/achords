# Achords

**Achords (Agent Chords)** is a lightweight, repository-native protocol for multi-agent software collaboration.

---

## Mandatory for all agents

Before doing any work in this repository, **read**:

- [`AGENTS.md`](./AGENTS.md)

---

## Quick start

### Developer setup

```bash
bash scripts/dev-setup.sh
```

Adds `.engram` shared memory to this project.

### Organization owners

```bash
bash .achords/skills/platform/org-bootstrap/scripts/bootstrap.sh <org-name>
```

### Team members

```bash
bash .achords/skills/platform/org-join/scripts/setup.sh <org-name>
```

---

## Structure

```
.
├── AGENTS.md
├── README.md
├── .engram/                  # Shared memory (submodule)
├── .achords/
│   ├── skills/
│   │   ├── platform/
│   │   │   ├── org-bootstrap/
│   │   │   └── org-join/
│   │   ├── achords-init/
│   │   ├── agent-union/
│   │   ├── claim-declaration/
│   │   ├── claim-collision-check/
│   │   └── alignment-verify/
│   ├── registry.json
│   ├── claims.json
│   └── events.ndjson
├── scripts/
│   └── dev-setup.sh          # Add .engram submodule
└── .github/
    └── workflows/
```

---

## Skills

| Skill | Purpose |
|-------|---------|
| `org-bootstrap` | Create GitHub org structure |
| `org-join` | Team member onboarding |
| `achords-init` | Bootstrap protocol in repo |
| `agent-union` | Register agent |
| `claim-declaration` | Declare work intent |
| `claim-collision-check` | Detect overlapping claims |
| `alignment-verify` | CI validation |

---

## Docs

- [`AGENTS.md`](./AGENTS.md) — Agent rules
- [`.achords/ACHORDS.md`](./.achords/ACHORDS.md) — Protocol spec
- [`.achords/skills/`](./.achords/skills/README.md) — Skills

---

*Lightweight. Repo-native. Extensible.*
