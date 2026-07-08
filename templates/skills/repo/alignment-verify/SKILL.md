---
name: alignment-verify
description: Verify that a pull request meets Achords protocol alignment requirements. Validates required files exist, JSON syntax is valid, and no active exclusive claims overlap across agents. Used in CI as the authoritative gate before merge. Logs alignment checks to supervisor/state.json.
license: MIT
compatibility: Designed for CI/GitHub Actions workflows. Requires .achords/ directory.
metadata:
  author: Achords
  version: "1.0.0"
  category: governance
  skill_type: core
---

# alignment-verify Skill

## Purpose

Gate pull request merges on Achords protocol compliance. Ensures repository state remains valid and collision-free.

## When to use

- Automatically in CI/GitHub Actions on every PR
- Manual verification before critical merges
- Debugging alignment failures

## What it does

1. **Validates required files exist**:
   - `.achords/ACHORDS.md`
   - `.achords/version.json`
   - `.achords/registry.json`
   - `.achords/claims.json`
   - `.achords/topology.json`
   - `.achords/policies.json`
   - `.achords/events.ndjson`
   - `.achords/supervisor/state.json`
   - All 4 schema files

2. **Validates JSON syntax** for all `.achords/*.json` files

3. **Checks claim overlaps**:
   - Runs claim-collision-check internally
   - Fails on blocking (exclusive) overlaps
   - Warns on advisory overlaps

4. **Updates supervisor state**:
   - Sets `last_alignment_check` timestamp
   - Records `alignment_status` (passed/failed)
   - Logs check details

5. **Determines merge eligibility**:
   - ✓ PASS: All checks passed, merge allowed
   - ⚠ WARNING: Advisories only, merge allowed but noted
   - ✗ FAIL: Blocking issues, merge blocked until resolved

## Steps

### CI Integration

Add to `.github/workflows/achords-alignment-check.yml`:

```yaml
- name: Achords Alignment Verify
  run: python .achords/skills/alignment-verify/scripts/verify-alignment.py
  continue-on-error: false  # Blocking
```

### Manual verification

1. Run: `python .achords/skills/alignment-verify/scripts/verify-alignment.py`
2. Review output
3. Fix any failures before PR merge

## Validation checklist

```
[ ] .achords/ directory exists
[ ] version.json present and valid JSON
[ ] registry.json present and valid JSON
[ ] claims.json present and valid JSON
[ ] topology.json present and valid JSON
[ ] policies.json present and valid JSON
[ ] events.ndjson present and valid NDJSON
[ ] supervisor/state.json present and valid JSON
[ ] All 4 schema files present
[ ] No active exclusive claim overlaps
[ ] Events logged correctly
```

## Output

### Success

```
✓ Alignment check PASSED

Validations:
✓ Required files: 13/13 present
✓ JSON syntax: all valid
✓ Schema compliance: all valid
✓ Claim collisions: 0 blocking detected
✓ Event stream: 42 events logged

Status: MERGE ALLOWED
Updated: supervisor/state.json (last_alignment_check)
```

### Warning

```
⚠ Alignment check PASSED with WARNINGS

Validations:
✓ Required files: 13/13 present
✓ JSON syntax: all valid
✓ Schema compliance: all valid
⚠ Claim collisions: 1 advisory overlap (non-blocking)
✓ Event stream: 42 events logged

Advisory:
- claim-20260704-001 (agent-a-001) overlaps with
  claim-20260704-002 (agent-b-001) in advisory mode

Status: MERGE ALLOWED (warnings noted)
Updated: supervisor/state.json
```

### Failure

```
✗ Alignment check FAILED

Validations:
✓ Required files: 13/13 present
✓ JSON syntax: 12/13 valid
✗ claims.json: JSON syntax error on line 45
✗ Claim collisions: 1 blocking overlap detected

Blocking issues:
1. claims.json malformed (line 45: unexpected token)
2. Exclusive claim overlap:
   claim-20260704-001 (agent-a-001): src/auth/**
   claim-20260704-003 (agent-c-001): src/auth/jwt.py

Fix:
1. Correct JSON syntax error
2. Coordinate with agents on claim conflict (resolve via issue)
3. Re-run alignment check

Status: MERGE BLOCKED
```

## Supervisor state update

After each check, `supervisor/state.json` is updated:

```json
{
  "mode": "advisory",
  "enabled": true,
  "last_alignment_check": "2026-07-04T14:30:00Z",
  "alignment_status": "passed",
  "last_pr": "#42",
  "pending_reviews": [],
  "blocked_merges": []
}
```

## Error codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | All checks passed | Proceed to merge |
| 1 | File missing | Create missing file |
| 2 | JSON syntax error | Fix JSON syntax |
| 3 | Schema validation fails | Adjust data to match schema |
| 4 | Blocking collision detected | Coordinate with other agents |
| 5 | Event stream corrupted | Restore from backup |

## Workflow in GitHub Actions

Typical `.github/workflows/achords-alignment-check.yml`:

```yaml
name: Achords Alignment Check

on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main]

jobs:
  alignment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Achords Alignment Verify
        run: python .achords/skills/alignment-verify/scripts/verify-alignment.py
```

## Supervisor authority

This skill is the final arbiter of merge eligibility.
- CI controls merge eligibility (supervisor authority)
- Unresolved alignment failures block merge
- Only maintainers can override (with documented reason)

## Files read/modified

```
.achords/
├── *.json files              (read)
├── supervisor/state.json     (modified: update last check)
└── events.ndjson            (read)
```

## See also

- [claim-collision-check](../claim-collision-check/SKILL.md) - Collision detection
- [ACHORDS.md](../../ACHORDS.md) - Protocol specification
- [AGENTS.md](../../../AGENTS.md) - Supervisor authority rules
