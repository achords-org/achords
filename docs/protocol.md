# What is Achords?

**Achords (Agent Chords)** is a lightweight, repository-native protocol for multi-agent software collaboration.

## The Problem

When multiple AI agents work on the same codebase:

- **Collisions**: Two agents edit the same file simultaneously
- **Chaos**: No clear ownership or intent tracking
- **Context loss**: Decisions made outside the repo are forgotten
- **Trust**: No way to verify agents follow team rules

## The Solution

Achords provides coordination primitives that live in Git:

```
Before editing → Agent declares intent (claim)
                 ↓
During work    → CI checks for collisions
                 ↓
Before merge   → Protocol compliance verified
                 ↓
After merge    → Event logged for audit
```

## Core Principles

| Principle | How |
|-----------|-----|
| **Repo-native** | All state lives in Git files |
| **Lightweight** | JSON + GitHub Actions, no backend |
| **Auditable** | Every action logged to events stream |
| **Extensible** | Schema and policy evolution |

## What Achords Is NOT

- **Not an orchestrator** — Agents decide what to work on
- **Not a task manager** — Use your project management tool
- **Not a runtime** — It's a coordination protocol

## Quick Example

```bash
# 1. Initialize protocol in your repo
bash templates/achords-init.sh

# 2. Agent registers
python templates/skills/repo/agent-union/scripts/register-agent.py

# 3. Agent declares intent
python templates/skills/repo/claim-declaration/scripts/declare-claim.py

# 4. Agent works and opens PR

# 5. CI validates compliance automatically
```

---

*Next: [Architecture](./architecture.md) — How the three levels work together.*
