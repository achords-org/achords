#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# version — Show achords version and check for updates
# ══════════════════════════════════════════════════════════════════════
# Description: Show current version and check if achords is up to date
#
# Usage:
#   achords version
#
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── config ───────────────────────────────────────────────────────────
ACHORDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_URL="https://github.com/cxto21/achords.git"

# Read version from package.json (single source of truth)
get_version() {
  local pkg_json="${ACHORDS_DIR}/package.json"
  if [ -f "$pkg_json" ]; then
    # Use grep + sed to extract version without jq dependency
    grep '"version"' "$pkg_json" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  else
    echo "unknown"
  fi
}

# ── branding ─────────────────────────────────────────────────────────
BANNER=$(cat << 'EOF'
  ╔═══════════════════════════════════════════╗
  ║     🎵 A C H O R D S                     ║
  ║     Version Check                        ║
  ╚═══════════════════════════════════════════╝
EOF
)

# ── colors ───────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "${CYAN}▸${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
err()   { printf "${RED}✗${NC} %s\n" "$*" >&2; }

# ── check for updates ────────────────────────────────────────────────
check_updates() {
  info "Checking for updates..."
  
  # Check if we're in a git repo
  if [ ! -d "$ACHORDS_DIR/.git" ]; then
    warn "Not a git repository. Cannot check for updates."
    return 1
  fi
  
  cd "$ACHORDS_DIR"
  
  # Fetch latest from remote
  if ! git fetch origin --quiet 2>/dev/null; then
    warn "Could not fetch from remote. Check your internet connection."
    return 1
  fi
  
  # Get current commit
  local current_commit
  current_commit=$(git rev-parse HEAD 2>/dev/null)
  
  # Get latest commit on main
  local latest_commit
  latest_commit=$(git rev-parse origin/main 2>/dev/null)
  
  # Compare
  if [ "$current_commit" = "$latest_commit" ]; then
    ok "achords is up to date!"
    return 0
  else
    warn "New version available!"
    echo ""
    echo "  Current:  ${current_commit:0:8}"
    echo "  Latest:   ${latest_commit:0:8}"
    echo ""
    return 1
  fi
}

# ── show version info ────────────────────────────────────────────────
show_version() {
  local version
  version=$(get_version)
  
  echo "$BANNER"
  echo ""
  printf "  ${BOLD}Version:${NC} %s\n" "$version"
  echo ""
  
  # Get git info if available
  if [ -d "$ACHORDS_DIR/.git" ]; then
    cd "$ACHORDS_DIR"
    local commit
    commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    printf "  ${BOLD}Git:${NC} %s (%s)\n" "$commit" "$branch"
  fi
  echo ""
}

# ── show commands ────────────────────────────────────────────────────
show_commands() {
  printf "  ${BOLD}Available commands:${NC}\n"
  echo ""
  echo "    achords version              Show this version info"
  echo "    achords update               Update achords to latest version"
  echo "    achords obase                Organization Base setup"
  echo ""
  printf "  ${BOLD}For help:${NC}\n"
  echo "    achords --help               Show all products"
  echo "    achords obase --help         Show obase options"
  echo ""
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  show_version
  
  # Check for updates
  if ! check_updates; then
    echo ""
    warn "Run 'achords update' to get the latest version."
  fi
  
  echo ""
  show_commands
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi