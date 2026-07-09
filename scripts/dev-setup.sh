#!/usr/bin/env bash
# Achords — Developer Setup
# Adds .engram shared memory to this project.
#
# Usage:
#   bash scripts/dev-setup.sh
#
# What it does:
#   1. Loads .env configuration
#   2. Adds .engram as git submodule (if not present)
#   3. Pulls latest shared memory

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m%s\033[0m %s\n" ">>>" "$*"; }
ok()    { printf "\033[1;32m%s\033[0m %s\n" "OK" "$*"; }
warn()  { printf "\033[1;33m%s\033[0m %s\n" "WARN" "$*"; }
err()   { printf "\033[1;31m%s\033[0m %s\n" "ERR" "$*" >&2; }

# ── load .env ────────────────────────────────────────────────────────
if [ -f ".env" ]; then
  info "Loading .env..."
  set -a
  source .env
  set +a
fi

# Use env var or default
ENGRAM_REPO="${ENGRAAM_REPO_URL:-https://github.com/achords-org/.engram.git}"

info "Using .engram repo: ${ENGRAM_REPO}"
echo ""

# ── main ─────────────────────────────────────────────────────────────
if [ -d ".engram" ]; then
  info "Updating .engram..."
  cd .engram && git pull --quiet && cd ..
  ok ".engram updated"
else
  info "Adding .engram submodule..."
  git submodule add "$ENGRAM_REPO" .engram
  ok ".engram added"
fi

git add .engram
ok "Done"
