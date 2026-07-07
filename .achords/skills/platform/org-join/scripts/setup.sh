#!/usr/bin/env bash
# Achords — Organization Join Script
# Clones core repositories for a new team member.
#
# Usage:
#   bash setup.sh <org-name>
#
# Example:
#   bash setup.sh Poincare-Space

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bash setup.sh <org-name>"
  echo "Example: bash setup.sh Poincare-Space"
  exit 1
fi

ORG="$1"
REPOS=(".github" ".internal" ".skills")
POINCARE_DIR="${HOME}/Poincare"

echo "Achords — Organization Join"
echo "==========================="
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

# Verify org access
if ! gh org view "$ORG" > /dev/null 2>&1; then
  echo "Cannot access organization: ${ORG}"
  echo "Ensure you have been invited and accepted."
  exit 1
fi

echo "Dependencies OK"
echo ""

# Create base directory
mkdir -p "$POINCARE_DIR"

# Clone repos
echo "Cloning repositories..."
for repo in "${REPOS[@]}"; do
  FULL_NAME="${ORG}/${repo}"
  TARGET="${POINCARE_DIR}/${repo}"

  if [ -d "$TARGET" ]; then
    echo "  skip ${repo} (exists locally)"
  else
    echo "  clone ${repo}..."
    git clone "https://github.com/${FULL_NAME}.git" "$TARGET" --quiet 2>/dev/null || {
      echo "  warn: could not clone ${repo} (may not exist or no access)"
    }
  fi
done

echo ""
echo "All repos cloned to ${POINCARE_DIR}/"
echo ""

# Summary
echo "Structure:"
for repo in "${REPOS[@]}"; do
  if [ -d "${POINCARE_DIR}/${repo}" ]; then
    echo "  ${repo}/"
  else
    echo "  ${repo}/ (not available)"
  fi
done

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Read ${POINCARE_DIR}/.internal/onboarding/README.md"
echo "  2. Read ${POINCARE_DIR}/.internal/onboarding/AGENTS.md"
echo "  3. Start contributing"
