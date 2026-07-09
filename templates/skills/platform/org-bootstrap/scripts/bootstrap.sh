#!/usr/bin/env bash
# Achords — Organization Bootstrap Script
# Creates the initial repository structure for a new organization.
#
# Usage:
#   bash bootstrap.sh <org-name> [skills-repo-url]
#
# Examples:
#   bash bootstrap.sh my-org
#   bash bootstrap.sh my-org https://github.com/myorg/team-skills.git

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m%s\033[0m %s\n" ">>>" "$*"; }
ok()    { printf "\033[1;32m%s\033[0m %s\n" "OK" "$*"; }
warn()  { printf "\033[1;33m%s\033[0m %s\n" "WARN" "$*"; }
err()   { printf "\033[1;31m%s\033[0m %s\n" "ERR" "$*" >&2; }

# ── load .env ────────────────────────────────────────────────────────
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

# ── config ───────────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
  echo "Usage: bash bootstrap.sh <org-name> [skills-repo-url]"
  echo ""
  echo "Examples:"
  echo "  bash bootstrap.sh my-org"
  echo "  bash bootstrap.sh my-org https://github.com/myorg/team-skills.git"
  exit 1
fi

ORG="$1"
SKILLS_URL="${2:-}"
WORK_DIR="${HOME}/achords-workspace"

echo "Achords — Organization Bootstrap"
echo "================================"
echo "Organization: ${ORG}"
if [ -n "$SKILLS_URL" ]; then
  echo "Skills repo:  ${SKILLS_URL}"
fi
echo ""

# Check dependencies
for cmd in git gh; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    err "Missing: $cmd"
    exit 1
  fi
done

# Check GitHub auth
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
  echo "  Or if you're using a personal account:"
  echo "    https://github.com/account/repositories/new"
  echo ""
  echo "  After creating, re-run this script."
  exit 1
fi

ok "Organization exists"
echo ""

# ── pre-check: verify local state before doing anything ──────────────
info "Checking local state..."

CONFLICTS=0

# Check .internal
INTERNAL_DIR="${WORK_DIR}/.internal"
if [ -d "$INTERNAL_DIR" ]; then
  CONTENT_COUNT=$(find "$INTERNAL_DIR" -mindepth 1 -not -path '*/\.git/*' -not -path '*/\.git' 2>/dev/null | wc -l)
  if [ "$CONTENT_COUNT" -gt 0 ]; then
    err ".internal exists with content — will NOT overwrite"
    echo "  Location: ${INTERNAL_DIR}"
    echo "  To reset:  rm -rf ${INTERNAL_DIR}"
    CONFLICTS=$((CONFLICTS + 1))
  fi
fi

# Check .skills
SKILLS_DIR="${WORK_DIR}/.skills"
if [ -d "$SKILLS_DIR" ]; then
  CONTENT_COUNT=$(find "$SKILLS_DIR" -mindepth 1 -not -path '*/\.git/*' -not -path '*/\.git' 2>/dev/null | wc -l)
  if [ "$CONTENT_COUNT" -gt 0 ]; then
    err ".skills exists with content — will NOT overwrite"
    echo "  Location: ${SKILLS_DIR}"
    echo "  To reset:  rm -rf ${SKILLS_DIR}"
    CONFLICTS=$((CONFLICTS + 1))
  fi
fi

if [ "$CONFLICTS" -gt 0 ]; then
  echo ""
  err "Found ${CONFLICTS} conflict(s). Fix the issues above and retry."
  exit 1
fi

ok "Local state OK"
echo ""

# ── create repos ─────────────────────────────────────────────────────
info "Creating repositories..."

# .github
if gh repo view "${ORG}/.github" > /dev/null 2>&1; then
  ok ".github exists on GitHub"
else
  info "Creating .github on GitHub..."
  gh repo create "${ORG}/.github" --public --description "GitHub organization profile" --quiet
  ok ".github created"
fi

# .internal
if gh repo view "${ORG}/.internal" > /dev/null 2>&1; then
  ok ".internal exists on GitHub"
else
  info "Creating .internal on GitHub..."
  gh repo create "${ORG}/.internal" --private --description "Internal team documentation" --quiet
  ok ".internal created"
fi

# .skills
if gh repo view "${ORG}/.skills" > /dev/null 2>&1; then
  ok ".skills exists on GitHub"
else
  info "Creating .skills on GitHub..."
  gh repo create "${ORG}/.skills" --private --description "Agent skills library" --quiet
  ok ".skills created"
fi
echo ""

# ── clone repos ──────────────────────────────────────────────────────
info "Cloning repositories..."

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

echo "# Onboarding" > "${ONBOARDING_DIR}/README.md"
echo "" >> "${ONBOARDING_DIR}/README.md"
echo "Run: bash onboarding/scripts/setup.sh" >> "${ONBOARDING_DIR}/README.md"

echo "# Agents.md" > "${ONBOARDING_DIR}/AGENTS.md"
echo "" >> "${ONBOARDING_DIR}/AGENTS.md"
echo "Agent configuration placeholder." >> "${ONBOARDING_DIR}/AGENTS.md"
ok "Onboarding files"
echo ""

# ── import skills if provided ────────────────────────────────────────
if [ -n "$SKILLS_URL" ]; then
  info "Importing skills from ${SKILLS_URL}..."
  TEMP_DIR=$(mktemp -d)
  if git clone "$SKILLS_URL" "$TEMP_DIR" --quiet 2>/dev/null; then
    # Move contents to .skills (including .git)
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
echo "  ~/achords-workspace/"
echo "  ├── .github/"
echo "  ├── .internal/"
echo "  └── .skills/"
echo ""
echo "Next steps:"
echo "  1. Edit ~/achords-workspace/.github/profile/README.md"
echo "  2. Edit ~/achords-workspace/.internal/onboarding/AGENTS.md"
if [ -n "$SKILLS_URL" ]; then
  echo "  3. Skills loaded from ${SKILLS_URL}"
else
  echo "  3. Add skills to ~/achords-workspace/.skills/"
fi
