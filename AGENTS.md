<!-- achords:header:v1.2.1 -->
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
<!-- achords:resources -->
| Resource | Path | Purpose |
|----------|------|---------|
| Project Config | `.engram/config.json` | Project name and settings |
| Memory | `.engram/` | Persistent memory across sessions |
| CLI Entry | `bin/achords` | Unified CLI entry point |
| Products | `bin/commands/` | Product implementations |
| Docs | `web/docs/humans/` | Quartz documentation site |
| Landing | `web/index.html` | Marketing page |
| LLM Docs | `llms.txt` | AI-friendly project summary |
| CLI Reference | `web/docs/humans/content/cli/` | CLI docs per command |
<!-- achords:end -->

# AGENTS.md — Achords Project

> This is the achords repo itself. We use our own protocol — "en casa de herrero, cuchillo de diamante".

## Project Status

**⚠️ EVERYTHING IS IN DEVELOPMENT.** No product is production-ready. This is an experimental protocol.

## What is Achords

A multi-agent orchestration protocol for software development. Four products:

| Product | Status | Tags | Description |
|---------|--------|------|-------------|
| obase | 🟡 Alpha | `obase coordination reference stable agent` | Organization Base — setup org for agents |
| rcord | 🔴 Planning | `rcord coordination reference coming-soon both` | Repository Coordination |
| iaci | 🔴 Planning | `iaci coordination reference coming-soon both` | IA on CI |
| kbweb | 🔴 Planning | `kbweb memory reference coming-soon both` | KB Web — deployable docs per org |

## Architecture

```
achords/
├── bin/
│   ├── achords              # Unified CLI (resolves symlinks)
│   └── commands/
│       ├── obase.sh         # Organization Base setup
│       ├── update.sh        # Self-update
│       └── version.sh       # Version check
├── web/
│   ├── index.html           # Landing page (Vite + Tailwind)
│   ├── src/                 # Frontend source
│   ├── dist/                # Built output (Cloudflare Pages)
│   └── docs/humans/         # Quartz v5 documentation
├── .engram/                 # Persistent memory (git-tracked)
│   ├── config.json          # Project config
│   └── chunks/              # Memory chunks
├── docs/                    # Product documentation
├── templates/               # File templates
└── scripts/                 # Helper scripts
```

## Reading Order (MANDATORY)

1. **This file** — AGENTS.md (org-wide rules)
2. `.engram/config.json` — Project name: `achords`
3. `llms.txt` — AI-friendly summary
4. On-demand files as needed

## Memory Protocol

### At Session Start (MANDATORY)

```bash
# 1. Check project context
mem_search(project: "achords", query: "recent changes", limit: 3)

# 2. Load conventions
mem_search(project: "achords", query: "conventions", limit: 3)

# 3. Check for ongoing work
mem_search(project: "achords", query: "last session", limit: 3)
```

### During Work

Save after significant decisions:

```bash
mem_save(
  project: "achords",
  title: "Decision: use pattern X",
  type: "decision",
  content: "We decided to use X because...",
  topic_key: "decisions/architecture"
)
```

Save after bug fixes:

```bash
mem_save(
  project: "achords",
  title: "Fixed N+1 in user list",
  type: "bugfix",
  content: "Root cause was...",
  topic_key: "bugs/..."
)
```

### At Session End (MANDATORY)

```bash
mem_session_summary(content: "## Goal\n...## Accomplished\n...")
```

## Conventions

### Code

- **Language**: Code comments and UI in English, user-facing docs in Spanish/English
- **CLI**: Bash scripts in `bin/commands/` with `set -euo pipefail`
- **Landing**: Vite + Tailwind in `web/`
- **Docs**: Quartz v5 in `web/docs/humans/`

### Commits

Conventional commits:
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation
- `chore:` — maintenance
- `refactor:` — code restructuring

### Tags (5-dimension taxonomy)

Every generated file should carry tags:
- **product**: obase, rcord, iaci, kbweb
- **domain**: memory, skills, coordination, cli, architecture, getting-started
- **type**: concept, reference, guide, tutorial
- **status**: stable, coming-soon
- **audience**: human, agent, both

Format in AGENTS.md:
```html
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
```

### Branches

- `main` = stable release
- `feat/*` = feature branches
- `fix/*` = bug fix branches

## Key Files

| File | Purpose |
|------|---------|
| `bin/achords` | CLI entry point — resolves symlinks for npx |
| `bin/commands/obase.sh` | Organization Base setup (1300+ lines) |
| `bin/commands/doctor.sh` | Health check for achords + gentle-ai + opencode |
| `scripts/install.sh` | One-liner installer (curl pipe) |
| `package.json` | npm package config, version, scripts |
| `web/index.html` | Landing page |
| `web/docs/humans/` | Quartz documentation |
| `llms.txt` | AI-friendly project summary |
| `AGENTS.md` | This file — agent entry point |

## Products

### obase (Organization Base)

The only implemented product. Sets up GitHub orgs for multi-agent collaboration.

```bash
# Create org (with push) — auto-discovers skills in existing repos
achords obase --org my-company --push

# Configure a single repo
achords obase --repo my-app

# Update AGENTS.md headers in all repos
achords obase --org my-company --update-headers --push

# UPGRADE guides to latest achords version (regenerates full AGENTS.md body)
achords obase --org my-company --upgrade --push
```

What it creates:
- `.github/` — Org profile
- `.achords/` — Agent rules + shared memory
- `.internal/` — Team docs + onboarding
- `.skills/` — Shared skills library (auto-populated from repos with `skills/` or `.skills/skills/` dirs)

**Skills auto-discovery**: During init, obase scans ALL repos for `skills/` or `.skills/skills/` directories and imports them into the org `.skills` repo. Skills get proper manifests and version.json entries. Existing skills are never overwritten — only new versions are added.

**Upgrade flow**: Each achords release ships improved guide templates. Run `--upgrade` to sync existing orgs — custom repo rules under `## Repository-Specific Rules` are preserved.

### rcord, iaci, kbweb

Planning phase. See `web/docs/humans/content/products/` for details.

## Skills

Skills follow the Agent Skills specification. See `web/docs/humans/content/skills/` for:
- `skill-spec.md` — Specification
- `skill-versioning.md` — Version management
- `os-tagging.md` — Platform-specific skills
- `creating-skills.md` — How to create new skills

This project provides its own skill for agents working on achords:
```
docs/skills/achords/SKILL.md
```
Load it when implementing obase features, releasing, or updating docs.
`<!-- achords:skill:docs/skills/achords/SKILL.md -->`

## OpenCode + gentle-ai Integration

Achords integrates with [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) for OpenCode.

### What obase generates

When you run `achords obase --repo <name>`, it creates:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Agent config with gentle-ai markers (persona + engram protocol) |
| `opencode.json` | MCP servers (Engram, Context7) and permissions |
| `.engram/` | Persistent memory directory |
| `.achords/` | Submodule for org-wide rules |

### Health check

```bash
# Verify installation
achords doctor

# Auto-fix issues
achords doctor --fix
```

### One-liner install

```bash
curl -fsSL https://raw.githubusercontent.com/achords-org/achords/main/scripts/install.sh | bash
```

This installs gentle-ai, opencode, and achords together.

## Testing

No automated tests yet. Manual testing:

```bash
# CLI tests
./bin/achords --help
./bin/achords obase --help
./bin/achords version

# npx test
npx achords@1.2.1 obase --help
```

## Cloudflare Pages

- **Build command**: `npm run build:all`
- **Output directory**: `web/dist`
- **URL**: https://achords.pages.dev

## npm Publishing

Triggered by git tags via GitHub Actions (`.github/workflows/publish.yml`):
```bash
git tag v1.2.1
git push origin v1.2.1
```

The workflow:
1. Checkout + Node.js setup
2. `npm install --ignore-scripts`
3. `npm run build`
4. `npm publish` with `NODE_AUTH_TOKEN` from secrets

**Bump first** — always update `version` in `package.json` and the web landing page before tagging.

## Sensitive Data Rules

- **NEVER** commit `.env` files
- **NEVER** commit API keys or tokens
- **NEVER** save passwords to .engram
- **.gitignore** must include: `.env`, `*.db`, `node_modules/`

## Modification Rules

- **Don't commit** secrets, tokens, or passwords
- **Don't modify** `.engram/config.json` without team agreement
- **Do** follow conventional commits
- **Do** update this file when architecture changes
- **Do** save decisions to .engram
