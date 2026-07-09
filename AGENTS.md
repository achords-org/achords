<!-- achords:header:v1.1.1 -->
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
<!-- achords:end -->

# AGENTS.md — Achords Project

> This is the achords repo itself. We use our own protocol — "en casa de herrero, cuchillo de palo".

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
| `package.json` | npm package config, version, scripts |
| `web/index.html` | Landing page |
| `web/docs/humans/` | Quartz documentation |
| `llms.txt` | AI-friendly project summary |
| `AGENTS.md` | This file — agent entry point |

## Products

### obase (Organization Base)

The only implemented product. Sets up GitHub orgs for multi-agent collaboration.

```bash
# Create org
achords obase --org my-company

# Configure repo
achords obase --repo my-app

# Update all repos
achords obase --org my-company --update-headers
```

What it creates:
- `.github/` — Org profile
- `.achords/` — Agent rules + shared memory
- `.internal/` — Team docs + onboarding
- `.skills/` — Shared skills library

### rcord, iaci, kbweb

Planning phase. See `web/docs/humans/content/products/` for details.

## Skills

Skills follow the Agent Skills specification. See `web/docs/humans/content/skills/` for:
- `skill-spec.md` — Specification
- `skill-versioning.md` — Version management
- `os-tagging.md` — Platform-specific skills
- `creating-skills.md` — How to create new skills

## Testing

No automated tests yet. Manual testing:

```bash
# CLI tests
./bin/achords --help
./bin/achords obase --help
./bin/achords version

# npx test
npx achords@1.1.1 obase --help
```

## Cloudflare Pages

- **Build command**: `npm run build:all`
- **Output directory**: `web/dist`
- **URL**: https://achords.pages.dev

## npm Publishing

Triggered by git tags:
```bash
git tag v1.1.1
git push origin v1.1.1
```

Workflow: `.github/workflows/publish.yml`

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
