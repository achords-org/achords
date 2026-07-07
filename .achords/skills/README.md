# Agent Skills for Achords

This directory contains the core skills that implement the Achords protocol operations. Each skill follows the [Agent Skills specification](https://agentskills.io/specification.md).

## Skill Categories

Achords skills are organized by scope:

### Platform Skills (`platform/`)

Organization-level operations. Use these to bootstrap or join a GitHub organization.

#### 1. [org-bootstrap](./platform/org-bootstrap/SKILL.md)
Initialize a GitHub organization for multi-agent collaboration.
- Creates core repositories (.github, .internal, .skills)
- Generates base files and onboarding structure
- Clones repos locally
- Use: First-time org setup

#### 2. [org-join](./platform/org-join/SKILL.md)
Join an existing organization as a team member.
- Clones core repositories to local machine
- Sets up environment for contributions
- Use: Every new team member

### Repo Skills (`./`)

Repository-level operations. Use these to manage agent collaboration within a repo.

#### 3. [achords-init](./achords-init/SKILL.md)
Bootstrap the Achords protocol in a new repository.
- Creates `.achords/` directory structure
- Generates baseline protocol files
- Seeds JSON schemas and skills
- Use: First-time repo setup

#### 4. [agent-union](./agent-union/SKILL.md)
Register a new agent before making contributions.
- Adds agent entry to registry.json
- Creates per-agent state directory
- Use: Every new agent joining the team

#### 5. [claim-declaration](./claim-declaration/SKILL.md)
Declare work intent (claim) before editing files.
- Creates claim entry with paths, TTL, mode
- Supports exclusive and advisory modes
- Use: Before any code changes

#### 6. [claim-collision-check](./claim-collision-check/SKILL.md)
Detect overlapping exclusive claims.
- Identifies path overlaps
- Reports severity and recommendations
- Use: Before opening PR or during development

#### 7. [alignment-verify](./alignment-verify/SKILL.md)
Verify protocol compliance in CI.
- Validates required files and JSON syntax
- Checks claim collisions
- Updates supervisor state
- Use: Automatically on every PR

## Workflow

```
Organization setup (one-time)
    org-bootstrap
         |
         v
Team member joins
    org-join
         |
         v
Repository setup (per-repo)
    achords-init
         |
         v
Agent onboarding (per-agent)
    agent-union
         |
         v
Agent contributes
    claim-declaration -> work -> PR
         |
         v
CI validates
    alignment-verify
```

## Using Skills

Each skill has a `SKILL.md` file with:
- **Frontmatter**: name, description, license, compatibility, metadata
- **Instructions**: purpose, when to use, steps, output
- **Scripts/Assets**: implementation code and templates

### Example

To use agent-union:

```bash
# 1. Read the skill documentation
cat .achords/skills/agent-union/SKILL.md

# 2. Run the script
python .achords/skills/agent-union/scripts/register-agent.py

# 3. Provide inputs when prompted
# Agent ID, name, type (ai/human/service)

# 4. Verify the entry in registry.json
cat .achords/registry.json
```

## Agent Skills Format

Standard structure for all skills:

```
skill-name/
├── SKILL.md                          # Required
├── scripts/                          # Optional: executable code
├── assets/                           # Optional: templates/resources
└── references/                       # Optional: docs
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name
description: What it does + when to use
license: MIT
compatibility: Compatibility notes
metadata:
  author: Achords
  version: "1.0.0"
  category: platform|repo|agent
  skill_type: core
---
```

## Extending Achords

To add a new skill:

1. Create directory in appropriate category:
   - `platform/` for org-level operations
   - Root skills dir for repo-level operations
2. Create `SKILL.md` with proper YAML frontmatter
3. Add implementation:
   - `scripts/` for executable code
   - `assets/` for templates
   - `references/` for documentation
4. Test the skill
5. Document in this README

## Discovery and Integration

Skills are:
- **Self-documenting**: SKILL.md explains purpose and usage
- **Discoverable**: Listed here and in ACHORDS.md
- **Composable**: Skills can invoke other skills
- **Standardized**: Follow agentskills.io format

Agents can discover and use skills through:
1. Reading `.achords/skills/*/SKILL.md`
2. Checking `.achords/ACHORDS.md` for protocol overview
3. Reading `/docs/achords.md` for detailed guidance

## See Also

- [ACHORDS.md](../ACHORDS.md) - Protocol specification
- [/docs/achords.md](../../docs/achords.md) - Full operational guide
- [Agent Skills Specification](https://agentskills.io/specification.md)
