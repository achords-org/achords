#!/usr/bin/env bash
# Achords — Developer Setup
# Adds .engram shared memory to this project.
#
# Usage:
#   bash scripts/dev-setup.sh
#
# What it does:
#   1. Adds .engram as git submodule (if not present)
#   2. Pulls latest shared memory

set -euo pipefail

ENGRAM_REPO="https://github.com/Poincare-Space/.engram.git"

# Check if .engram exists
if [ -d ".engram" ]; then
  echo "Updating .engram..."
  cd .engram && git pull --quiet && cd ..
else
  echo "Adding .engram submodule..."
  git submodule add "$ENGRAM_REPO" .engram
fi

git add .engram
echo "Done. .engram is ready."
