---
name: org-bootstrap
description: Initialize a GitHub organization for multi-agent collaboration. Creates core repositories, folder structure, and base files. Run this first when setting up a new organization that will use Achords protocol.
license: MIT
compatibility: Requires GitHub CLI (gh) authenticated with owner access to the target organization.
metadata:
  author: achords-org
  version: "1.0.0"
  category: platform
  skill_type: core
---

# org-bootstrap Skill

## Purpose

Bootstrap a GitHub organization with the repository structure required for Achords-based multi-agent collaboration.

## When to use

- Creating a new GitHub organization for agent-assisted development
- Setting up Achords protocol at the organization level
- First-time initialization before any repos or agents exist

## What it does

1. Validates GitHub CLI authentication and org access
2. Creates core repositories:
   - `.github` (public) — Organization profile
   - `.internal` (private) — Team docs, onboarding, agent config
   - `.skills` (private) — Agent skills library
3. Clones all repos locally to `~/achords-workspace/`
4. Generates base files:
   - `.github/profile/README.md` — Organization description
   - `.internal/onboarding/README.md` — Team onboarding entry point
   - `.internal/onboarding/AGENTS.md` — Agent configuration placeholder
   - `.internal/onboarding/scripts/setup.sh` — Member setup script
   - `.internal/onboarding/skills/join-team/SKILL.md` — Agent join skill
   - `.skills/README.md` — Skills library documentation
5. Logs bootstrap event

## Prerequisites

- GitHub CLI (`gh`) installed
- Authenticated with owner access to target org
- Network access to github.com

## Steps

### 1. Read the skill

```bash
cat .achords/skills/platform/org-bootstrap/SKILL.md
```

### 2. Run the bootstrap script

```bash
bash .achords/skills/platform/org-bootstrap/scripts/bootstrap.sh <org-name> [skills-repo-url]
```

Examples:
```bash
# Basic bootstrap
bash .achords/skills/platform/org-bootstrap/scripts/bootstrap.sh my-org

# With team skills from external repo
bash .achords/skills/platform/org-bootstrap/scripts/bootstrap.sh my-org https://github.com/myorg/team-skills.git
```

### 3. Follow prompts

The script will:
- Verify dependencies
- Create repositories on GitHub
- Clone them locally
- Generate base files
- Clone skills repo (if provided)

### 4. Verify output

```
✓ GitHub CLI authenticated
✓ Organization: my-org
✓ Repository .github created (public)
✓ Repository .internal created (private)
✓ Repository .skills created (private)
✓ All repos cloned to ~/achords-workspace/
✓ Base files generated
✓ Bootstrap complete
```

### 5. Customize

After bootstrap:
- Edit `~/achords-workspace/.github/profile/README.md` with org description
- Edit `~/achords-workspace/.internal/onboarding/AGENTS.md` with team protocols
- Add skills to `~/achords-workspace/.skills/`

## Files created

```
~/achords-workspace/
├── .github/
│   └── profile/
│       └── README.md
├── .internal/
│   └── onboarding/
│       ├── README.md
│       ├── AGENTS.md
│       ├── scripts/
│       │   └── setup.sh
│       └── skills/
│           └── join-team/
│               └── SKILL.md
└── .skills/
    └── README.md
```

## Repository purposes

| Repo | Visibility | Purpose |
|------|------------|---------|
| `.github` | Public | Organization profile shown on GitHub org page |
| `.internal` | Private | Team documentation, onboarding, agent configuration |
| `.skills` | Private | Reusable agent skills following agentskills.io spec |

## Next steps

1. Customize the generated files for your team
2. Share the `join-team` skill with team members
3. Run `achords-init` in individual repos to enable claim-based collaboration
4. Register agents with `agent-union` skill

## Troubleshooting

**"Repository already exists"** — Script skips existing repos. Safe to re-run.

**"Permission denied"** — Ensure you have owner access to the GitHub organization.

**"gh: not found"** — Install GitHub CLI: https://cli.github.com/

**"Not authenticated"** — Run `gh auth login` first.

## See also

- [org-join](../org-join/SKILL.md) — Join an existing organization
- [achords-init](../../achords-init/SKILL.md) — Initialize Achords in a repository
- [agent-union](../../agent-union/SKILL.md) — Register an agent
