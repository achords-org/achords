---
name: achords-init
description: Bootstrap Achords protocol in a new repository. Initializes .achords/ directory, creates baseline protocol files (version.json, registry.json, claims.json, topology.json, policies.json, events.ndjson), and generates JSON schemas. Use when setting up multi-agent collaboration in a repository for the first time.
license: MIT
compatibility: Works with any Git repository. Requires write access to root directory.
metadata:
  author: Achords
  version: "1.0.0"
  category: setup
  skill_type: core
---

# achords-init Skill

## Purpose

Initialize the Achords protocol in a repository that has no existing `.achords/` directory.

## When to use

- First-time setup of multi-agent collaboration in a repository
- Creating a new repository that will use Achords protocol
- Resetting Achords infrastructure (backup first!)

## What it does

1. Creates `.achords/` directory structure
2. Generates baseline protocol files:
   - `version.json` - Protocol version and repo metadata
   - `registry.json` - Empty agent registry (to be populated by agent-union)
   - `claims.json` - Empty claims registry
   - `topology.json` - Team collaboration topology
   - `policies.json` - Protocol policy flags
   - `events.ndjson` - Append-only event log
   - `supervisor/state.json` - Supervisor mode and status
3. Creates `.achords/schemas/` with 4 JSON schemas:
   - `agent-profile.schema.json`
   - `agent-state.schema.json`
   - `claim.schema.json`
   - `message.schema.json`
4. Bootstraps `.achords/skills/` with all 5 core skills
5. Logs bootstrap event to events.ndjson

## Steps

### Manual execution (if no script available)

1. Clone/create repository
2. Run: `bash .achords/skills/achords-init/scripts/init.sh`
3. Verify `.achords/` directory structure
4. Commit changes: `git add .achords/ && git commit -m "feat: bootstrap Achords protocol"`

### Script-based (automated)

The `scripts/init.sh` script:
- Checks for existing `.achords/` (prevents overwrites)
- Creates directory structure
- Generates baseline JSON files
- Populates schemas
- Seeds skills
- Logs initialization event

## Output

On success:
```
✓ Achords initialized
✓ .achords/ directory created
✓ 8 protocol files created
✓ 4 JSON schemas created
✓ 5 core skills bootstrapped
✓ events.ndjson updated
```

On error (e.g., `.achords/` exists):
```
✗ .achords/ already exists. Use agent-union skill to register agents.
```

## Files created

```
.achords/
├── ACHORDS.md
├── version.json
├── registry.json
├── claims.json
├── topology.json
├── policies.json
├── events.ndjson
├── agents/
├── supervisor/
│   └── state.json
├── schemas/
│   ├── agent-profile.schema.json
│   ├── agent-state.schema.json
│   ├── claim.schema.json
│   └── message.schema.json
└── skills/
    ├── achords-init/
    ├── agent-union/
    ├── claim-declaration/
    ├── claim-collision-check/
    └── alignment-verify/
```

## Next steps

1. Use `agent-union` skill to register the first agent
2. Use `claim-declaration` skill to declare work intent
3. Configure `.github/workflows/` for CI alignment checks

## See also

- [ACHORDS.md](../../ACHORDS.md) - Protocol specification
- [agent-union](../agent-union/SKILL.md) - Agent onboarding
- [claim-declaration](../claim-declaration/SKILL.md) - Claim registration
