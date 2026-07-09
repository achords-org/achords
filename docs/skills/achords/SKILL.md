---
name: achords-protocol
description: "Trigger: achords, obase, achords workflow, achords release. Guide for working on the achords CLI, its command implementations, docs, and release process."
license: Apache-2.0
metadata:
  author: "achords-org"
  version: "1.0.0"
---

# Skill: achords-protocol

## Activation Contract

Load this skill when:
- Implementing, fixing, or refactoring `bin/commands/*.sh`
- Releasing a new achords version (tag + npm publish)
- Updating docs under `web/docs/humans/`
- Modifying `AGENTS.md` or `.engram/config.json`
- Creating or updating obase features

## Hard Rules

1. **AGENTS.md is the single source of truth** for project conventions — read it first, update it when architecture changes.
2. **Version in lockstep** — `package.json`, `AGENTS.md` header, `.engram/config.json`, and `web/index.html` must all reflect the same version.
3. **Never hardcode secrets** — no `.env`, tokens, or passwords in code commits.
4. **Conventional commits only** — `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, never `Co-Authored-By`.
5. **No secrets in .engram** — save decisions and patterns, not credentials.
6. **obase templates and the `--upgrade` command must stay in sync** — when a template changes, `upgrade_guides()` must also reflect the change because it regenerates from the same heredocs.

## Decision Gates

| Need | Action |
|------|--------|
| New CLI command | Create `bin/commands/<name>.sh`, add to `bin/achords`, wire in `show_help` |
| obase feature | Modify `bin/commands/obase.sh`, update CLI docs in `web/docs/humans/content/cli/obase.md` |
| Guide template change | Update heredocs in `bin/commands/obase.sh` (both `init_achords_repo` and `upgrade_guides`) |
| Docs update | Edit `.md` files under `web/docs/humans/content/`, verify in `llms.txt` |
| Release | Bump `package.json`, update web version, tag `v*`, push (GitHub Actions publishes) |

## Execution Steps

### Working on obase

1. Read `bin/commands/obase.sh` to understand the full flow.
2. Identify which function to modify:
   - `setup_env` — interactive prompts
   - `init_achords_repo` — .achords repo structure + templates
   - `update_all_agents_headers` — per-repo AGENTS.md update
   - `upgrade_guides` — full guide regeneration
   - `setup_repo_memory` — single repo config
3. If changing templates (AGENTS.md body, policies, version.json), update ALL instances: `init_achords_repo`, `upgrade_guides`, and `update_all_agents_headers` (create-new branch).
4. Verify with: `bash -n bin/commands/obase.sh`
5. Commit with conventional message.

### Doing a release

1. Bump `version` in `package.json`
2. Update `"softwareVersion"` and the npm badge in `web/index.html`
3. Update `achords_version` in `.engram/config.json`
4. Update the `<!-- achords:header:vX.Y.Z -->` in `AGENTS.md`
5. Update `npx achords@X.Y.Z` references in `AGENTS.md`
6. Commit: `chore: bump version to X.Y.Z`
7. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`
8. GitHub Actions publishes to npm automatically

### Updating docs

1. Human docs: `web/docs/humans/content/<section>/<topic>.md`
2. CLI docs: `web/docs/humans/content/cli/<command>.md`
3. Product docs: `web/docs/humans/content/products/<product>.md`
4. AI docs: update `llms.txt` at repo root
5. Verify all cross-references (`[[wikilinks]]`) resolve

## Output Contract

Return:
- Files created or modified with brief description
- Whether `AGENTS.md` was updated
- Which skill or template changed
- Version bumps applied

## References

- `AGENTS.md` — project conventions, architecture, products
- `.engram/config.json` — project metadata and version
- `bin/commands/obase.sh` — obase implementation (templates + commands)
- `web/docs/humans/content/cli/obase.md` — CLI reference docs
- `.github/workflows/publish.yml` — npm publish workflow
- `llms.txt` — AI-friendly project summary
