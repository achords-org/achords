# File Locations Guide

> Where each file lives and what it does.

## Overview

Achords-based projects use three layers of configuration:

1. **Global** — Your machine, shared across all projects
2. **Project** — Per-repo, version controlled
3. **Shared memory** — Cross-project context via .engram submodule

## Global configuration

Location: `~/.config/opencode/`

These files apply to ALL projects on your machine.

### `opencode.json`

**Purpose**: Main opencode configuration.

**Contains**:
- Agent definitions and models
- SDD phase assignments
- Tool permissions
- MCP server connections

**When to edit**: When changing default models or adding new agents.

**Example**:
```json
{
  "agent": {
    "gentle-orchestrator": {
      "model": "opencode/mimo-v2.5-free"
    },
    "sdd-apply": {
      "model": "opencode/north-mini-code-free"
    }
  }
}
```

### `AGENTS.md`

**Purpose**: Global rules that apply to ALL agents in ALL projects.

**Contains**:
- Persona definition
- Language rules
- Engram protocol
- Trigger rules

**When to edit**: When changing how agents behave everywhere.

**Note**: Project-specific `AGENTS.md` files can add rules, but global rules always apply.

### `skills/`

**Purpose**: Installed agent skills.

**Contains**:
- `gentle-ai/` — SDD workflow skills
- `review-*/` — Code review lenses
- Custom skills

**When to edit**: When adding or modifying skills globally.

## Project configuration

Location: `./` (project root)

These files are version-controlled and specific to each repository.

### `AGENTS.md`

**Purpose**: Project-specific agent rules.

**Contains**:
- Project-specific collaboration rules
- Workflow requirements
- Definition of done

**When to edit**: When adding project-specific constraints.

**Example**:
```markdown
# AGENTS.md

This project uses Achords protocol.

## Rules

1. All contributions must go through claims
2. CI must pass before merge
3. Read .engram/ for context before decisions
```

### `.achords/`

**Purpose**: Achords protocol state.

**Contains**:
- `registry.json` — Agent registry
- `claims.json` — Active claims
- `events.ndjson` — Audit log
- `skills/` — Protocol skills
- `schemas/` — JSON schemas

**When to edit**: Never edit directly. Use skills to modify.

### `.github/workflows/`

**Purpose**: CI/CD pipelines.

**Contains**:
- `achords-union.yml` — Agent onboarding checks
- `achords-alignment-check.yml` — Protocol compliance

**When to edit**: When modifying CI behavior.

## Shared memory (.engram)

Location: `./.engram/` (git submodule)

This is a **shared repository** imported as a submodule. It's the same across all projects.

### `decisions/`

**Purpose**: Architecture and design decisions.

**Contains**: One markdown file per decision.

**When to add**: After making any architecture choice.

**Example file**: `chose-postgres-over-mongodb.md`
```markdown
# Chose PostgreSQL over MongoDB

**Date**: 2026-07-07
**Context**: Building user authentication system
**Decision**: Use PostgreSQL for user data
**Rationale**: ACID compliance, relational data model, team expertise
**Alternatives**: MongoDB (rejected due to lack of transactions)
**Impact**: All user-related queries use SQL
```

### `discoveries/`

**Purpose**: Technical findings and gotchas.

**Contains**: One markdown file per discovery.

**When to add**: When learning something non-obvious.

**Example file**: `fts5-special-chars.md`
```markdown
# FTS5 Special Character Handling

**Date**: 2026-07-07
**Context**: Implementing search functionality
**Finding**: FTS5 treats special characters as operators
**Gotcha**: Query like "fix auth bug" crashes because FTS5 interprets "fix" as an operator
**Prevention**: Always sanitize user input before FTS5 MATCH
```

### `patterns/`

**Purpose**: Established conventions.

**Contains**: One markdown file per pattern.

**When to add**: When establishing a new convention.

**Example file**: `error-handling.md`
```markdown
# Error Handling Pattern

**Date**: 2026-07-07
**Pattern**: Always return Result<T, E> from operations
**Context**: Any function that can fail
**Example**:
```rust
fn get_user(id: u64) -> Result<User, AppError> {
    // ...
}
```
**Anti-pattern**: Using unwrap() or panic!()
```

### `bugs/`

**Purpose**: Bug fixes with root cause analysis.

**Contains**: One markdown file per bug fix.

**When to add**: After fixing a non-trivial bug.

**Example file**: `n-plus-one-query.md`
```markdown
# N+1 Query in UserList

**Date**: 2026-07-07
**Symptom**: API response taking 5+ seconds
**Root cause**: Loading user roles in a loop
**Fix**: Use JOIN query to load users and roles in one query
**Prevention**: Always check for N+1 patterns in list endpoints
```

### `sessions/`

**Purpose**: Session summaries for continuity.

**Contains**: One markdown file per session.

**When to add**: At the end of significant work sessions.

**Example file**: `2026-07-07-auth-setup.md`
```markdown
# Auth Setup Session

**Date**: 2026-07-07
**Goal**: Set up JWT authentication
**Accomplished**: 
- Created auth middleware
- Added login/register endpoints
- Set up token refresh
**Discoveries**: 
- Must set httpOnly flag on cookies
**Next steps**: 
- Add rate limiting
- Implement password reset
```

## Reading order for new team members

1. **Global rules**: `~/.config/opencode/AGENTS.md`
2. **Project rules**: `./AGENTS.md`
3. **Protocol**: `.achords/ACHORDS.md`
4. **Skills**: `.achords/skills/README.md`
5. **Memory**: `.engram/README.md`

## Reading order for agents

1. **Project rules**: `./AGENTS.md`
2. **Protocol**: `.achords/ACHORDS.md`
3. **Memory**: `.engram/README.md`
4. **Relevant skill**: `.achords/skills/<skill>/SKILL.md`
5. **Related decisions**: `.engram/decisions/`
6. **Related discoveries**: `.engram/discoveries/`

## Common tasks

### Adding a new decision

```bash
# Create decision file
cat > .engram/decisions/chose-redis-for-cache.md << 'EOF'
# Chose Redis for Caching

**Date**: $(date +%Y-%m-%d)
**Context**: Need to cache API responses
**Decision**: Use Redis
**Rationale**: Fast, simple, good ecosystem
**Impact**: Add Redis dependency
EOF

# Commit
git add .engram/decisions/
git commit -m "docs: add Redis caching decision"
```

### Reading prior context

```bash
# Before making a decision
cat .engram/decisions/README.md

# Before fixing a bug
cat .engram/bugs/README.md

# Before establishing a pattern
cat .engram/patterns/README.md
```

### Updating shared memory

```bash
# Pull latest memories
cd .engram
git pull origin main
cd ..

# Commit the update
git add .engram
git commit -m "chore: update .engram submodule"
```

---

*This guide is the source of truth for file locations in Achords-based projects.*
