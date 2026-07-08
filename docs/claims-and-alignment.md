# Claims and Alignment: Coordination and Validation

## Overview

**Claims** establish explicit intent before editing. **Alignment checks** validate protocol compliance in CI, preventing collisions and ensuring auditable state.

## Claims: Declaring work intent

### What is a claim?

A claim is a pre-edit declaration:
- "I, agent-a-001, plan to modify src/auth/** for the next 2 hours"
- "This is an exclusive claim; no other agent should edit these paths"
- "If I don't release it by then, it expires automatically"

Claims live in `.achords/claims.json`.

### When to declare a claim

**Before** you edit any source files.

Workflow:

```
1. Plan work
2. Declare claim (specify paths, duration, mode)
3. Make edits
4. Commit and PR
5. CI validates alignment
6. Merge and claim auto-releases (or release manually)
```

### Declaring a claim

Use the `claim-declaration` skill:

```bash
python .achords/skills/claim-declaration/scripts/declare-claim.py
```

Prompts:

```
Paths to claim (comma-separated globs): src/auth/**, tests/auth/**
Purpose (brief description): Refactor JWT validation module
Mode [exclusive/advisory] [exclusive]: exclusive
TTL in minutes [240]: 120
```

### Claim structure

```json
{
  "id": "claim-20260704-001",
  "agent_id": "agent-a-001",
  "paths": ["src/auth/**", "tests/auth/**"],
  "purpose": "Refactor JWT validation module for better error handling",
  "mode": "exclusive",
  "ttl_minutes": 120,
  "status": "active",
  "created_at": "2026-07-04T10:45:00Z",
  "released_at": null
}
```

### Claim modes

#### Exclusive (recommended default)

```json
"mode": "exclusive"
```

**Behavior**:
- Only your agent can edit claimed paths
- Other agents' overlapping exclusive claims → CI blocks merge
- Use for: refactoring, critical features, coordinated changes

**Advantage**: Prevents accidental collisions.

**Disadvantage**: Requires coordination if paths overlap.

#### Advisory

```json
"mode": "advisory"
```

**Behavior**:
- Informational; doesn't block other agents
- Other agents can edit same paths
- Useful for broadcasting intent

**Advantage**: Non-blocking, good for large-scale changes you want visibility on.

**Disadvantage**: Doesn't prevent collisions; relies on agent coordination.

### Claim TTL (time-to-live)

Specifies how long the claim is valid:

```json
"ttl_minutes": 120
```

Auto-expires after TTL elapses. Examples:

| Work | TTL | Reason |
|------|-----|--------|
| Bug fix | 30 min | Quick change |
| Feature work | 120-240 min | Typical feature branch (2-4 hours) |
| Large refactor | 480-1440 min | Multi-day work (8-24 hours) |
| Spike/exploration | 60-120 min | Experimental |

Choose TTL based on expected work duration. It's not a hard deadline, but:
- **Too short**: Claim expires, auto-releases, other agents think you're done
- **Too long**: Claim blocks others unnecessarily
- **Right size**: Matches actual work window

### Releasing a claim

When you finish (or before TTL expires), release the claim:

```bash
python .achords/skills/claim-declaration/scripts/release-claim.py claim-20260704-001
```

Status changes:

```json
"status": "released",
"released_at": "2026-07-04T12:45:00Z"
```

Or, let it auto-expire (claim status becomes `expired` automatically).

### Collision detection

Before opening a PR, check for overlaps:

```bash
python .achords/skills/claim-collision-check/scripts/check-overlaps.py
```

If overlap detected and it's blocking:

```
✗ Collision detected (BLOCKING)

Claim: claim-20260704-001
  Agent: agent-a-001
  Paths: src/auth/**

Overlaps with:

Claim: claim-20260704-002
  Agent: agent-b-001
  Paths: src/auth/jwt.py
  Mode: exclusive

Recommendation: Coordinate via GitHub issue or change to 'advisory' mode
```

### Resolving collisions

**Option 1: Coordinate**

Open a GitHub issue:

```
Title: Coordinate on claims: src/auth/**
Body: 
My claim: src/auth/** (claim-20260704-001) for JWT refactor
Your claim: src/auth/jwt.py (claim-20260704-002) for token validation

Proposed solution: Let's split:
- I'll handle: src/auth/validation.py, tests/auth/test_validation.py
- You handle: src/auth/jwt.py, tests/auth/test_jwt.py

Release my claim on validation.py path?
```

**Option 2: Change to advisory**

Release exclusive claim and redeclare as advisory:

```bash
python .achords/skills/claim-declaration/scripts/release-claim.py claim-20260704-001
python .achords/skills/claim-declaration/scripts/declare-claim.py
# Answer: mode = advisory
```

**Option 3: Wait for other claim to release**

If the other agent's TTL is short, wait for auto-expiration or coordinate outside Achords.

## Alignment: CI validation

### What alignment checks do

On every PR, `alignment-verify` skill:

1. ✓ Validates required files exist (13 protocol files)
2. ✓ Validates JSON syntax (all `.achords/*.json` files)
3. ✓ Validates JSON schema compliance (agent-profile, claim, etc.)
4. ✓ Runs claim-collision-check (detects blocking overlaps)
5. ✓ Logs alignment result to supervisor state

### GitHub Actions workflow

File: `.github/workflows/achords-alignment-check.yml`

```yaml
name: Achords Alignment Check

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  alignment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Achords Alignment Verify
        run: python .achords/skills/alignment-verify/scripts/verify-alignment.py
```

### Alignment check results

#### ✓ PASS

```
✓ Alignment check PASSED

Validations:
✓ Required files: 13/13 present
✓ JSON syntax: all valid
✓ Schema compliance: all valid
✓ Claim collisions: 0 blocking detected

Status: MERGE ALLOWED
```

PR can be merged.

#### ⚠ WARNING

```
⚠ Alignment check PASSED with WARNINGS

Advisory collision detected:
claim-20260704-001 (agent-a-001) overlaps claim-20260704-002 (agent-b-001)
Mode: advisory (non-blocking)

Status: MERGE ALLOWED (warnings noted)
```

PR can be merged; warnings are logged.

#### ✗ FAIL

```
✗ Alignment check FAILED

Blocking issues:
1. claims.json: JSON syntax error on line 45
2. Blocking collision: exclusive claims from agent-a-001 and agent-b-001 overlap

Status: MERGE BLOCKED

Fix:
1. Correct JSON syntax in claims.json
2. Resolve claim collision
3. Push fix and re-run check
```

PR merge is blocked. Fix and push again.

### Supervisor authority

Alignment checks are **authoritative** for merge eligibility:
- ✓ Passed → merge allowed (subject to branch protection rules)
- ✗ Failed → merge blocked until resolved

Repository settings should enforce this:

**Settings → Branches → Branch protection rule**:
- ✓ Require branches to be up to date before merging
- ✓ Require status checks to pass before merging
  - Check: "Achords Alignment Verify"

### Policy enforcement levels

Configured in `.achords/policies.json`:

#### Advisory (default)

```json
"policy_enforcement_level": "advisory"
```

- Collisions detected but don't block merge
- Useful for onboarding teams to the protocol
- Switch to strict once comfortable

#### Strict

```json
"policy_enforcement_level": "strict"
```

- Any collision blocks merge
- No exceptions without supervisor review
- Recommended for mature multi-agent teams

#### Regulated (future)

```json
"policy_enforcement_level": "regulated"
```

- Strict + additional governance
- Approval from designated reviewers required
- Custom per-path policies

## Workflow: Declaring and aligning

```
1. Agent decides to work on src/auth/
2. Reads claim-declaration skill
3. Runs declare-claim.py:
   - Paths: src/auth/**
   - Mode: exclusive
   - TTL: 120 min
4. Claim added to claims.json (status=active)
5. Agent makes edits to src/auth/
6. Agent commits and pushes to feature branch
7. Agent opens PR
8. CI runs alignment-verify automatically
   ✓ No overlapping claims → PASS
   ✗ Overlapping claim from another agent → FAIL (or WARN in advisory mode)
9. If FAIL:
   - Agent coordinates with other agent via GitHub issue
   - Resolves collision (split paths / change mode / wait)
   - Pushes fix
   - Re-run check
10. If PASS:
    - PR merge allowed
    - Claim auto-releases (or agent can release manually)
    - Event logged to events.ndjson
```

## Event logging

Every significant action logged to `.achords/events.ndjson`:

```jsonlines
{"type":"claim-created","timestamp":"2026-07-04T10:45:00Z","claim_id":"claim-20260704-001","agent_id":"agent-a-001"}
{"type":"alignment-check","timestamp":"2026-07-04T11:00:00Z","pr":"#42","status":"passed"}
{"type":"claim-released","timestamp":"2026-07-04T13:00:00Z","claim_id":"claim-20260704-001","reason":"manual-release"}
```

Audit trail is immutable and queryable.

## Troubleshooting

### "Unexpected overlap detected"

You edited files that weren't in your claim.

**Fix**: Update claim paths or adjust edits to match claim.

### "Claim TTL too short"

Work took longer than expected; claim expired.

**Fix**: Redeclare with longer TTL.

### "JSON syntax error in claims.json"

Someone edited claims.json incorrectly.

**Fix**: Use claim-declaration scripts (not manual edits) to avoid malformed JSON.

### "alignment-verify is slow"

Checking large glob patterns can be slow.

**Fix**: Use specific paths instead of broad globs (e.g., `src/auth/jwt.py` instead of `src/**`).

## See also

- [achords.md](achords.md) - Full protocol spec
- [agent-union.md](agent-union.md) - Agent onboarding
- `.achords/skills/claim-declaration/SKILL.md` - Claiming skill
- `.achords/skills/claim-collision-check/SKILL.md` - Collision checking
- `.achords/skills/alignment-verify/SKILL.md` - CI validation
