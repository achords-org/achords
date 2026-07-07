#!/usr/bin/env bash
# Achords — Organization Bootstrap Script
# Creates the initial repository structure for a new organization.
#
# Usage:
#   bash bootstrap.sh <org-name>
#
# Example:
#   bash bootstrap.sh Poincare-Space

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bash bootstrap.sh <org-name>"
  echo "Example: bash bootstrap.sh Poincare-Space"
  exit 1
fi

ORG="$1"
REPOS=(".github" ".internal" ".skills")
POINCARE_DIR="${HOME}/Poincare"

echo "Achords — Organization Bootstrap"
echo "================================"
echo "Organization: ${ORG}"
echo ""

# Check dependencies
for cmd in git gh; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    echo "Missing: $cmd"
    echo "Install it before running this script."
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
echo "# Organization Name" > "${PROFILE_DIR}/README.md"
echo "" >> "${PROFILE_DIR}/README.md"
echo "> Description of your organization." >> "${PROFILE_DIR}/README.md"

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

# .skills README
echo "# Agent Skills" > "${POINCARE_DIR}/.skills/README.md"
echo "" >> "${POINCARE_DIR}/.skills/README.md"
echo "Skills library for this organization." >> "${POINCARE_DIR}/.skills/README.md"

echo ""
echo "Base files generated"
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
echo "  3. Share the join-team skill with your team"
