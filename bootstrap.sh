#!/usr/bin/env bash
# Achords — Organization Bootstrap
# Creates the initial repository structure for a new organization.
#
# Usage:
#   bash bootstrap.sh <org-name> [skills-repo-url]
#
# Examples:
#   bash bootstrap.sh Poincare-Space
#   bash bootstrap.sh Poincare-Space https://github.com/myorg/team-skills.git

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m%s\033[0m %s\n" ">>>" "$*"; }
ok()    { printf "\033[1;32m%s\033[0m %s\n" "OK" "$*"; }
warn()  { printf "\033[1;33m%s\033[0m %s\n" "WARN" "$*"; }
err()   { printf "\033[1;31m%s\033[0m %s\n" "ERR" "$*" >&2; }

# ── load .env ────────────────────────────────────────────────────────
if [ -f "${SCRIPT_DIR}/.env" ]; then
  set -a
  source "${SCRIPT_DIR}/.env"
  set +a
fi

# ── config ───────────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
  echo "Usage: bash bootstrap.sh <org-name> [skills-repo-url]"
  echo ""
  echo "Examples:"
  echo "  bash bootstrap.sh Poincare-Space"
  echo "  bash bootstrap.sh Poincare-Space https://github.com/myorg/team-skills.git"
  exit 1
fi

ORG="$1"
SKILLS_URL="${2:-}"
WORK_DIR="${HOME}/Poincare"

echo "Achords — Organization Bootstrap"
echo "================================"
echo "Organization: ${ORG}"
if [ -n "$SKILLS_URL" ]; then
  echo "Skills repo:  ${SKILLS_URL}"
fi
echo ""

# ── check dependencies ───────────────────────────────────────────────
for cmd in git gh; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    err "Missing: $cmd"
    exit 1
  fi
done

# ── check GitHub auth ────────────────────────────────────────────────
if ! gh auth status > /dev/null 2>&1; then
  err "Not logged in to GitHub CLI."
  echo "  Run: gh auth login"
  exit 1
fi

ok "Dependencies OK"
echo ""

# ── check if organization exists ─────────────────────────────────────
info "Checking organization..."

if ! gh org view "$ORG" > /dev/null 2>&1; then
  err "Organization '${ORG}' does not exist."
  echo ""
  echo "  Create it here:"
  echo "    https://github.com/organizations/new"
  echo ""
  echo "  After creating, re-run this script."
  exit 1
fi

ok "Organization exists"
echo ""

# ── pre-check: verify local state ────────────────────────────────────
info "Checking local state..."

CONFLICTS=0

for repo in .internal .skills; do
  DIR="${WORK_DIR}/${repo}"
  if [ -d "$DIR" ]; then
    CONTENT_COUNT=$(find "$DIR" -mindepth 1 -not -path '*/\.git/*' -not -path '*/\.git' 2>/dev/null | wc -l)
    if [ "$CONTENT_COUNT" -gt 0 ]; then
      err "${repo} exists with content — will NOT overwrite"
      echo "  Location: ${DIR}"
      echo "  To reset:  rm -rf ${DIR}"
      CONFLICTS=$((CONFLICTS + 1))
    fi
  fi
done

if [ "$CONFLICTS" -gt 0 ]; then
  echo ""
  err "Found ${CONFLICTS} conflict(s). Fix the issues above and retry."
  exit 1
fi

ok "Local state OK"
echo ""

# ── create repos ─────────────────────────────────────────────────────
info "Creating repositories..."

for repo in .github .internal .skills; do
  if gh repo view "${ORG}/${repo}" > /dev/null 2>&1; then
    ok "${repo} exists on GitHub"
  else
    VISIBILITY="private"
    DESC="Internal team documentation"
    if [ "$repo" = ".github" ]; then
      VISIBILITY="public"
      DESC="GitHub organization profile"
    fi
    info "Creating ${repo} (${VISIBILITY})..."
    gh repo create "${ORG}/${repo}" --"${VISIBILITY}" --description "$DESC" --quiet
    ok "${repo} created"
  fi
done
echo ""

# ── clone repos ──────────────────────────────────────────────────────
info "Cloning repositories..."

mkdir -p "$WORK_DIR"

for repo in .github .internal .skills; do
  TARGET="${WORK_DIR}/${repo}"
  if [ -d "$TARGET" ]; then
    ok "${repo} exists locally"
  else
    info "Cloning ${repo}..."
    git clone "https://github.com/${ORG}/${repo}.git" "$TARGET" --quiet
    ok "${repo} cloned"
  fi
done
echo ""

# ── generate base files ──────────────────────────────────────────────
info "Generating base files..."

# .github profile README
PROFILE_DIR="${WORK_DIR}/.github/profile"
mkdir -p "$PROFILE_DIR"
echo "# ${ORG}" > "${PROFILE_DIR}/README.md"
echo "" >> "${PROFILE_DIR}/README.md"
echo "> Multi-agent development organization." >> "${PROFILE_DIR}/README.md"
ok "Profile README"

# .internal onboarding
ONBOARDING_DIR="${WORK_DIR}/.internal/onboarding"
mkdir -p "${ONBOARDING_DIR}/scripts"
mkdir -p "${ONBOARDING_DIR}/skills/join-team"

cat > "${ONBOARDING_DIR}/README.md" << 'EOF'
# Onboarding

## Quick Start

Run the setup script:
```bash
bash onboarding/scripts/setup.sh
```

Or let your agent do it — point it to:
```
onboarding/skills/join-team/SKILL.md
```

## Files

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `AGENTS.md` | Agent configuration |
| `scripts/setup.sh` | Team member setup |
| `skills/join-team/SKILL.md` | Agent join skill |
EOF

cat > "${ONBOARDING_DIR}/AGENTS.md" << 'EOF'
# Agents.md

> Agent configuration and protocols for this organization.

*To be completed by the team.*
EOF

ok "Onboarding files"
echo ""

# ── import skills if provided ────────────────────────────────────────
if [ -n "$SKILLS_URL" ]; then
  info "Importing skills from ${SKILLS_URL}..."
  TEMP_DIR=$(mktemp -d)
  if git clone "$SKILLS_URL" "$TEMP_DIR" --quiet 2>/dev/null; then
    rm -rf "${WORK_DIR}/.skills"
    mv "$TEMP_DIR" "${WORK_DIR}/.skills"
    ok "Skills imported"
  else
    warn "Could not clone skills repo"
    echo "  You can add it later:"
    echo "    cd ${WORK_DIR}/.skills && git remote add origin ${SKILLS_URL} && git pull origin main"
  fi
  rm -rf "$TEMP_DIR"
fi
echo ""

# ── summary ──────────────────────────────────────────────────────────
ok "Bootstrap complete!"
echo ""
echo "Structure:"
echo "  ~/Poincare/"
echo "  ├── .github/"
echo "  ├── .internal/"
echo "  └── .skills/"
echo ""
echo "Next steps:"
echo "  1. Edit ~/Poincare/.github/profile/README.md"
echo "  2. Edit ~/Poincare/.internal/onboarding/AGENTS.md"
if [ -n "$SKILLS_URL" ]; then
  echo "  3. Skills loaded from ${SKILLS_URL}"
else
  echo "  3. Add skills to ~/Poincare/.skills/"
fi
