# Achords

**Agent Chords** — A lightweight protocol for multi-agent software collaboration.

## What It Does

When multiple AI agents work on the same codebase, you need coordination. Achords provides:

- **Claims** — Agents declare intent before editing
- **Collision detection** — CI blocks conflicting changes
- **Audit trail** — Every action is logged
- **Repo-native** — All state lives in Git

## Quick Start

```bash
# Clone
git clone https://github.com/your-org/achords.git
cd achords

# Configure
cp .env.example .env
# Edit .env with your org name

# Bootstrap organization
bash bootstrap.sh YourOrg
```

## How It Works

### Three Levels

| Level | Scope | What Happens |
|-------|-------|--------------|
| **Platform** | Organization | Bootstrap org, onboard team |
| **Repository** | Single repo | Init protocol, manage claims |
| **Agent** | Individual | Register, declare, contribute |

### Workflow

```
1. Bootstrap org (one-time)
   bash bootstrap.sh YourOrg

2. Team members join
   bash templates/skills/platform/org-join/scripts/setup.sh YourOrg

3. Init protocol in repo
   bash templates/achords-init.sh

4. Agent registers
   python templates/skills/repo/agent-union/scripts/register-agent.py

5. Agent declares claim
   python templates/skills/repo/claim-declaration/scripts/declare-claim.py

6. Agent works, opens PR
   CI validates → merge or block
```

## Structure

```
achords/
├── bootstrap.sh              # Bootstrap organization
├── docs/                     # Documentation
│   ├── protocol.md           # What Achords is
│   ├── architecture.md       # Three-level design
│   ├── collaboration.md      # Async/sync modes
│   └── roadmap.md            # Status and plans
├── templates/                # Files copied to projects
│   ├── skills/               # Protocol skills
│   ├── schemas/              # JSON schemas
│   └── workflows/            # CI workflows
├── protocol/                 # Specification
├── scripts/                  # Setup scripts
└── .env.example              # Configuration
```

## Documentation

| Document | Purpose |
|----------|---------|
| [Protocol](./docs/protocol.md) | What Achords is and why |
| [Architecture](./docs/architecture.md) | Three-level design |
| [Collaboration](./docs/collaboration.md) | Async, sync, repo modes |
| [Getting Started](./docs/getting-started.md) | Set up your project |
| [Roadmap](./docs/roadmap.md) | What's ready, what's coming |

## Status

See [Roadmap](./docs/roadmap.md) for current status.

| Area | Status |
|------|--------|
| Platform setup | ✅ Ready |
| Documentation | ✅ Ready |
| Org bootstrap | 🚧 Refining |
| Repo-level skills | 📋 Planned |
| Claims system | 📋 Planned |

## License

MIT
