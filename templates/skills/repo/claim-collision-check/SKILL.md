---
name: claim-collision-check
description: Detect overlapping exclusive claims across different agents. Parses .achords/claims.json, identifies path overlaps using glob matching, and reports collisions with severity and recommended actions. Use before merging PRs or as an advisory check during development.
license: MIT
compatibility: Requires .achords/claims.json with active claims.
metadata:
  author: Achords
  version: "1.0.0"
  category: validation
  skill_type: core
---

# claim-collision-check Skill

## Purpose

Detect and report overlapping exclusive claims that could cause merge conflicts or coordination problems.

## When to use

- Before opening a PR (local validation)
- As part of CI alignment checks
- During development to understand current claim landscape
- Resolving claim conflicts before merge

## What it does

1. Reads `.achords/claims.json`
2. Filters claims by:
   - `status = "active"`
   - `mode = "exclusive"`
3. Compares path globs across agent_ids
4. Identifies overlaps using glob-to-path matching
5. Reports collisions with:
   - Conflicting claim IDs
   - Agent IDs
   - Overlapping path patterns
   - Time remaining (TTL countdown)
   - Severity (warning/error)
6. Suggests resolutions

## Steps

### Check for collisions

1. Run: `python .achords/skills/claim-collision-check/scripts/check-overlaps.py`
2. Review output for collisions
3. If collisions exist:
   - **Option A**: Coordinate with other agent via GitHub issue
   - **Option B**: Change your claim mode to `advisory`
   - **Option C**: Adjust claimed paths to avoid overlap

### Check specific path

1. Run: `python .achords/skills/claim-collision-check/scripts/check-overlaps.py --path src/auth/jwt.py`
2. Shows which active exclusive claims cover this path

### CI integration

CI runs this automatically on PR:
```yaml
- name: Achords Collision Check
  run: python .achords/skills/claim-collision-check/scripts/check-overlaps.py
```

Fails if blocking collisions detected (unless resolved).

## Output examples

### No collisions

```
✓ Collision check passed
  Checked: 3 active exclusive claims
  Status: No overlaps detected
```

### Collision detected

```
⚠ Collision detected (WARNING)

Claim: claim-20260704-001
  Agent: agent-a-001
  Paths: src/auth/**
  TTL: 45 minutes remaining

Overlaps with:

Claim: claim-20260704-002
  Agent: agent-b-001
  Paths: src/auth/jwt.py, src/auth/utils.py
  TTL: 120 minutes remaining

Recommendation: Coordinate via GitHub issue #42
                or change mode to 'advisory'
```

### Blocking collision

```
✗ Collision detected (BLOCKING)

Cannot merge: exclusive claims from different agents overlap.

Resolve by:
1. Contacting agent-b-001 (Issue: #42)
2. Changing your claim to 'advisory' mode
3. Adjusting claimed paths
```

## Path matching

Supports glob patterns:
- `src/**` - All files under src/
- `src/auth/*.py` - Python files in src/auth/
- `src/auth/jwt.py` - Specific file
- `tests/**` - All test files

Uses standard glob semantics.

## Algorithm

1. For each active exclusive claim from Agent A
2. For each other active exclusive claim from Agent B (B ≠ A)
3. Expand glob paths to file sets
4. Find intersection
5. If non-empty → report collision

## Severity levels

- **INFO**: Overlapping advisory claims (not blocking)
- **WARNING**: One exclusive, one advisory claim
- **ERROR**: Two exclusive claims from different agents (blocking)

## Resolution workflow

```
1. Collision detected during development
   ↓
2. Open GitHub issue to coordinate
   ↓
3. Discussion:
   - Path adjustment?
   - Mode change to advisory?
   - Timing adjustment (TTL)?
   ↓
4. Update claims via claim-declaration
   ↓
5. Re-run collision check
   ↓
6. ✓ Proceed to PR
```

## Files read

```
.achords/
└── claims.json      (read only)
```

## See also

- [claim-declaration](../claim-declaration/SKILL.md) - Declare/release claims
- [alignment-verify](../alignment-verify/SKILL.md) - CI integration
- [AGENTS.md](../../../AGENTS.md) - Collision discipline rules
