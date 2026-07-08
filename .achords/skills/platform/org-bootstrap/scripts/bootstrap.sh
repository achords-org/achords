#!/usr/bin/env bash
# Achords — Organization Bootstrap Script
# Creates the initial repository structure for a new organization.
#
# Usage:
#   bash bootstrap.sh <org-name> [skills-repo-url]
#
# Examples:
#   bash bootstrap.sh Poincare-Space
#   bash bootstrap.sh Poincare-Space https://github.com/myorg/team-skills.git

set -euo pipefail

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
REPOS=(".github" ".internal" ".skills")
POINCARE_DIR="${HOME}/Poincare"

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
    echo "Missing: $cmd"
    exit 1
  fi
done

# Check GitHub auth
if ! gh auth status > /dev/null 2>&1; then
  echo "Not logged in to GitHub CLI."
  echo "Run: gh auth login"
  exit 1
fi

echo "Dependencies OK"
echo ""

# Create base directory
mkdir -p "$POINCARE_DIR"

# Create repos
echo "Creating repositories..."
for repo in "${REPOS[@]}"; do
  FULL_NAME="${ORG}/${repo}"
  TARGET="${POINCARE_DIR}/${repo}"

  # Create on GitHub
  if gh repo view "$FULL_NAME" > /dev/null 2>&1; then
    echo "  skip ${repo} (exists on GitHub)"
  else
    VISIBILITY="private"
    DESC="Internal team documentation and agent configuration"

    if [ "$repo" = ".github" ]; then
      VISIBILITY="public"
      DESC="GitHub organization profile"
    fi

    echo "  create ${repo} (${VISIBILITY})..."
    gh repo create "$FULL_NAME" --"${VISIBILITY}" --description "$DESC" --quiet
  fi

  # Clone locally
  if [ -d "$TARGET" ]; then
    echo "  skip ${repo} (exists locally)"
  else
    echo "  clone ${repo}..."
    git clone "https://github.com/${FULL_NAME}.git" "$TARGET" --quiet
  fi
done

echo ""
echo "Repositories ready"
echo ""

# Generate base files
echo "Generating base files..."

# .github profile README
PROFILE_DIR="${POINCARE_DIR}/.github/profile"
mkdir -p "$PROFILE_DIR"
echo "# ${ORG}" > "${PROFILE_DIR}/README.md"
echo "" >> "${PROFILE_DIR}/README.md"
echo "> Multi-agent development organization." >> "${PROFILE_DIR}/README.md"

# .internal onboarding
ONBOARDING_DIR="${POINCARE_DIR}/.internal/onboarding"
mkdir -p "${ONBOARDING_DIR}/scripts"
mkdir -p "${ONBOARDING_DIR}/skills/join-team"

echo "# Onboarding" > "${ONBOARDING_DIR}/README.md"
echo "" >> "${ONBOARDING_DIR}/README.md"
echo "Run: bash onboarding/scripts/setup.sh" >> "${ONBOARDING_DIR}/README.md"

echo "# Agents.md" > "${ONBOARDING_DIR}/AGENTS.md"
echo "" >> "${ONBOARDING_DIR}/AGENTS.md"
echo "Agent configuration placeholder." >> "${ONBOARDING_DIR}/AGENTS.md"

echo ""
echo "Base files generated"
echo ""

# Clone skills repo if provided
if [ -n "$SKILLS_URL" ]; then
  echo "Cloning skills repository..."
  SKILLS_DIR="${POINCARE_DIR}/.skills"

  if [ -d "${SKILLS_DIR}/.git" ]; then
    echo "  skip .skills (already has git history)"
  else
    # Clone to temp directory, then move contents
    TEMP_DIR=$(mktemp -d)
    if git clone "$SKILLS_URL" "$TEMP_DIR" --quiet 2>/dev/null; then
      # Copy contents (including .git)
      rm -rf "${SKILLS_DIR:?}"
      mv "$TEMP_DIR" "$SKILLS_DIR"
      echo "  skills cloned from ${SKILLS_URL}"
    else
      echo "  warn: could not clone skills repo"
      echo "  you can add it later:"
      echo "    cd ${SKILLS_DIR} && git init && git remote add origin ${SKILLS_URL} && git pull origin main"
    fi
    rm -rf "$TEMP_DIR"
  fi
else
  # Create empty .skills with README
  SKILLS_DIR="${POINCARE_DIR}/.skills"
  echo "# Agent Skills" > "${SKILLS_DIR}/README.md"
  echo "" >> "${SKILLS_DIR}/README.md"
  echo "Skills library for this organization." >> "${SKILLS_DIR}/README.md"
fi

echo ""

# Summary
echo "Structure:"
for repo in "${REPOS[@]}"; do
  echo "  ${repo}/"
done

echo ""
echo "Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ${POINCARE_DIR}/.github/profile/README.md"
echo "  2. Edit ${POINCARE_DIR}/.internal/onboarding/AGENTS.md"
if [ -n "$SKILLS_URL" ]; then
  echo "  3. Skills loaded from ${SKILLS_URL}"
else
  echo "  3. Add skills to ${POINCARE_DIR}/.skills/"
fi
