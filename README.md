# Achords — Repository Coordination

**Agent Chords** — Manage coordination between agents working on the same repository.

## What It Does

When multiple AI agents work on the same codebase, you need coordination. Achords provides claim-based intent declaration and CI validation.

## Quick Start

```bash
# Initialize Achords in your repo
bash templates/skills/repo/achords-init/scripts/init.sh templates

# Register as an agent
python .achords/skills/agent-union/scripts/register-agent.py

# Declare work intent
python .achords/skills/claim-declaration/scripts/declare-claim.py
```

## What It Creates

```
your-repo/
├── .achords/
│   ├── version.json        # Protocol version
│   ├── registry.json       # Agent registry
│   ├── claims.json         # Active claims
│   ├── topology.json       # Collaboration topology
│   ├── policies.json       # Protocol policies
│   ├── events.ndjson       # Audit log
│   ├── supervisor/state.json
│   ├── schemas/            # JSON schemas
│   └── skills/             # Core skills
└── .github/workflows/
    └── achords-*.yml       # CI workflows
```

## Features

- Claim-based intent declaration
- Collision detection
- CI validation
- Agent registration
- Audit logging

## Products

| Product | Branch | Status |
|---------|--------|--------|
| **Organization Base** | `main` | ✅ Stable |
| **Repository Coordination** | `feat/repository-coordination` | 🚧 In Development |
| **IA on CI** | TBD | 📋 Planned |
| **KB Web** | Poincare-Space/kb-web | 🚧 In Development |

## Documentation

| Document | Purpose |
|----------|---------|
| [Protocol](./docs/protocol.md) | How Achords works |
| [Claims](./docs/claims.md) | Claim declaration |
| [Collaboration](./docs/collaboration.md) | Async/sync modes |

## License

MIT
