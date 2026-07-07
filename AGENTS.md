# AGENTS.md

This repository is **Achords-native** and optimized for coordinated multi-agent collaboration.

## Mission

Build and maintain **Achords** as a lightweight, repository-native protocol for multi-agent orchestration across three levels:
- **Platform** — Organization setup and team onboarding
- **Repository** — Claim-based intent and CI alignment
- **Agent** — Identity, registration, and contribution workflow

## Non-negotiable collaboration rules

### Platform rules

1. **Bootstrap before join**
   - Organization owners must run `org-bootstrap` before any team members join.
   - Bootstrap creates the required repository structure.

2. **Join before contribute**
   - New team members must run `org-join` to clone repositories.
   - Local environment must be set up before any contributions.

### Repository rules

3. **Init before union**
   - Each repository must run `achords-init` before agents can register.
   - Initializes `.achords/` directory and protocol files.

4. **Union first**
   - New agents must be onboarded before normal contributions.
   - Onboarding creates `.achords/agents/<agent_id>/` and updates `.achords/registry.json`.

5. **Claim before code edits**
   - Before modifying source files, an agent must register/update a claim in `.achords/claims.json`.
   - Claims must include: `id`, `agent_id`, `paths`, `purpose`, `mode`, `ttl_minutes`, `status`, `created_at`.

### Agent rules

6. **Inbox-first iteration**
   - On each iteration, check `.achords/agents/<agent_id>/state.json`.
   - If `has_messages = 1`, process inbox before continuing.

7. **Collision discipline**
   - Never proceed with overlapping active exclusive claims.
   - Resolve via coordination, path split, or claim mode change.

8. **Supervisor authority**
   - CI alignment checks are authoritative for merge safety.
   - Merge must be blocked for unresolved claim overlaps or invalid Achords state.

## Repository outcomes required in this implementation

- Platform skills for organization management
- Baseline Achords protocol files in `.achords/`
- JSON schemas for key protocol entities
- CI workflows for union + alignment checks
- Practical docs in `/docs`
- Clean README and clear value proposition

## Implementation constraints

- Keep it lightweight: JSON files + GitHub workflows.
- Avoid overengineering or backend dependencies.
- Preserve repo-native auditable state.
- Favor clear extension points over speculative complexity.

## Definition of done (DoD)

A PR is done when:

1. The following exist and are coherent:

   - `README.md`
   - `VALUE_PROPOSITION.md`
   - `.achords/ACHORDS.md`
   - `.achords/version.json`
   - `.achords/registry.json`
   - `.achords/claims.json`
   - `.achords/topology.json`
   - `.achords/policies.json`
   - `.achords/events.ndjson`
   - `.achords/supervisor/state.json`
   - `.achords/schemas/*.schema.json`
   - `.achords/skills/platform/org-bootstrap/SKILL.md`
   - `.achords/skills/platform/org-join/SKILL.md`
   - `.achords/skills/achords-init/SKILL.md`
   - `.achords/skills/agent-union/SKILL.md`
   - `.achords/skills/claim-declaration/SKILL.md`
   - `.achords/skills/claim-collision-check/SKILL.md`
   - `.achords/skills/alignment-verify/SKILL.md`
   - `.github/workflows/achords-union.yml`
   - `.github/workflows/achords-alignment-check.yml`
   - `docs/achords.md`
   - `docs/agent-union.md`
   - `docs/claims-and-alignment.md`

2. Workflows run successfully on PR.
3. Basic claim-overlap guard works for active exclusive claims.
4. Documentation explains the operational flow end-to-end.

## Suggested branch and PR conventions

- Branch: `feat/achords-bootstrap`
- PR title: `feat: bootstrap Achords protocol, workflows, and docs`
- PR body sections:
  - What was added
  - Why this structure
  - Validation and checks
  - Next extension steps
