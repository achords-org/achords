---
name: org-join
description: Join an existing GitHub organization for multi-agent collaboration. Clones core repositories and sets up local environment. Run this when a new team member joins an organization that uses Achords protocol.
license: MIT
compatibility: Requires GitHub CLI (gh) authenticated with read access to the target organization.
metadata:
  author: Achords
  version: "1.0.0"
  category: platform
  skill_type: core
---

# org-join Skill

## Purpose

Set up a new team member's local environment by cloning the organization's core repositories and generating local configuration.

## When to use

- New human member joins the organization
- New agent needs access to organization repositories
- Setting up a new machine for an existing team member

## What it does

1. Validates GitHub CLI authentication
2. Detects or accepts organization name
3. Clones core repositories to `~/Poincare/`:
   - `.github` — Organization profile
   - `.internal` — Team docs, onboarding, agent config
   - `.skills` — Agent skills library
4. Verifies repository structure
5. Reports setup status

## Prerequisites

- GitHub CLI (`gh`) installed
- Authenticated with read access to the target organization
- Network access to github.com

## Steps

### 1. Read the skill

```bash
cat .achords/skills/platform/org-join/SKILL.md
```

### 2. Run the setup script

```bash
bash .achords/skills/platform/org-join/scripts/setup.sh <org-name>
```

Example:
```bash
bash .achords/skills/platform/org-join/scripts/setup.sh Poincare-Space
```

### 3. Verify output

```
Dependencies OK
Organization: Poincare-Space
Cloning repositories...
  clone .github...
  clone .internal...
  clone .skills...
All repos cloned to ~/Poincare/
Setup complete
```

### 4. Read team documentation

After setup:
```bash
cat ~/Poincare/.internal/onboarding/README.md
cat ~/Poincare/.internal/onboarding/AGENTS.md
```

## Files created

```
~/Poincare/
├── .github/          # Organization profile
├── .internal/        # Team docs and onboarding
│   └── onboarding/
│       ├── README.md
│       ├── AGENTS.md
│       ├── scripts/
│       │   └── setup.sh
│       └── skills/
│           └── join-team/
│               └── SKILL.md
└── .skills/          # Agent skills library
```

## Agent integration

For AI agents, point the agent to:

```
~/Poincare/.internal/onboarding/skills/join-team/SKILL.md
```

The agent will:
1. Read the join-team skill
2. Clone repositories
3. Configure itself for the organization
4. Be ready for contributions

## Next steps

1. Read `AGENTS.md` for agent-specific protocols
2. Run `agent-union` skill in individual repos to register as an agent
3. Start contributing with claim-based workflow

## Troubleshooting

**"Repository not found"** — Ensure you have access to the organization. Ask an owner to invite you.

**"gh: not found"** — Install GitHub CLI: https://cli.github.com/

**"Not authenticated"** — Run `gh auth login` first.

**"Already cloned"** — Script skips existing repos. Safe to re-run.

## See also

- [org-bootstrap](../org-bootstrap/SKILL.md) — Initialize a new organization
- [agent-union](../../agent-union/SKILL.md) — Register an agent in a repository
- [achords-init](../../achords-init/SKILL.md) — Initialize Achords in a repository
