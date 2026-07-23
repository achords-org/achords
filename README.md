# 🎵 Achords

**Multi-agent collaboration protocol for software development.**

## Quick start

### One-liner install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/achords-org/achords/main/scripts/install.sh | bash
```

This installs:
- **gentle-ai** — AI agent ecosystem (persona, memory, SDD)
- **opencode** — AI coding agent IDE
- **achords** — Multi-agent orchestration

### Manual install

```bash
# Clone achords
git clone https://github.com/achords-org/achords.git
cd achords

# Set up your organization
./bin/achords obase --org YourOrg
```

## Products

| Product | Command | Description | Status |
|---------|---------|-------------|--------|
| [**Organization Base**](./docs/obase.md) | `achords obase` | Set up your GitHub org | ✅ Stable |
| **Repository Coordination** | — | Claim-based agent coordination | 🚧 In Development |
| **IA on CI** | — | AI-powered review | 📋 Planned |
| **KB Web** | — | Documentation web | 🚧 In Development |

## CLI Usage

```bash
# List available products
./bin/achords

# Show product help
./bin/achords obase --help

# Run product
./bin/achords obase --org MyOrg

# Health check
./bin/achords doctor
```

## Integration with gentle-ai + OpenCode

Achords integrates with [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) for:

- **Persona** — Senior Architect personality with warm Rioplatense Spanish
- **Memory** — Persistent memory via Engram across sessions
- **SDD** — Spec-Driven Development for substantial changes
- **Skills** — Auto-loaded skills based on context

When you run `achords obase`, it generates:
- `AGENTS.md` with gentle-ai markers (persona + engram protocol)
- `opencode.json` with MCP servers (Engram, Context7)
- `.engram/` for persistent memory
- `.achords/` submodule for org-wide rules

## How it works

Achords provides three levels of coordination:

1. **Organization** — Set up your GitHub org for multi-agent work
2. **Repository** — Coordinate agents within a repo using claims
3. **Agent** — Register and declare work intent

## Commands

| Command | Description |
|---------|-------------|
| `achords obase --org <name>` | Initialize organization |
| `achords obase --repo <name>` | Setup single repo |
| `achords obase --upgrade` | Upgrade to latest version |
| `achords doctor` | Health check |
| `achords doctor --fix` | Auto-fix issues |

## Documentation

| Document | Purpose |
|----------|---------|
| [Organization Base](./docs/obase.md) | Set up your org |
| [Architecture](./docs/architecture.md) | Three-level design |
| [Getting Started](./docs/getting-started.md) | Quick start guide |
| [Roadmap](./docs/roadmap.md) | Product status |

## License

MIT
