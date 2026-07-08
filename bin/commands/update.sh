#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# update — Update achords to latest version
# ══════════════════════════════════════════════════════════════════════
# Description: Update achords CLI to the latest version
#
# Usage:
#   achords update
#
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── config ───────────────────────────────────────────────────────────
ACHORDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

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
  ║     Update                               ║
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

# ── check if update is needed ────────────────────────────────────────
check_update_needed() {
  info "Checking if update is needed..."
  
  # Check if we're in a git repo
  if [ ! -d "$ACHORDS_DIR/.git" ]; then
    err "Not a git repository. Cannot update."
    echo ""
    echo "  If you installed achords via npm, update with:"
    echo "    npm update -g achords"
    echo ""
    exit 1
  fi
  
  cd "$ACHORDS_DIR"
  
  # Fetch latest from remote
  if ! git fetch origin --quiet 2>/dev/null; then
    err "Could not fetch from remote. Check your internet connection."
    exit 1
  fi
  
  # Get current commit
  local current_commit
  current_commit=$(git rev-parse HEAD 2>/dev/null)
  
  # Get latest commit on main
  local latest_commit
  latest_commit=$(git rev-parse origin/main 2>/dev/null)
  
  # Compare
  if [ "$current_commit" = "$latest_commit" ]; then
    ok "achords is already up to date!"
    echo ""
    return 0
  fi
  
  return 1
}

# ── perform update ───────────────────────────────────────────────────
perform_update() {
  info "Updating achords..."
  
  cd "$ACHORDS_DIR"
  
  # Stash any local changes
  local stash_needed=false
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    warn "Stashing local changes..."
    git stash push -m "achords-update-$(date +%s)" --quiet
    stash_needed=true
  fi
  
  # Pull latest changes
  if git pull origin main --quiet 2>/dev/null; then
    ok "Update successful!"
  else
    err "Update failed. Check for conflicts."
    
    # Restore stash if needed
    if [ "$stash_needed" = true ]; then
      warn "Restoring stashed changes..."
      git stash pop --quiet 2>/dev/null || true
    fi
    exit 1
  fi
  
  # Restore stash if needed
  if [ "$stash_needed" = true ]; then
    info "Restoring stashed changes..."
    if ! git stash pop --quiet 2>/dev/null; then
      warn "Could not restore stashed changes. Check manually."
    fi
  fi
}

# ── show post-update info ────────────────────────────────────────────
show_post_update() {
  echo ""
  printf "  ${BOLD}Updated to:${NC} %s\n" "$(git rev-parse --short HEAD 2>/dev/null)"
  echo ""
  printf "  ${BOLD}Available commands:${NC}\n"
  echo ""
  echo "    achords version              Show version info"
  echo "    achords update               Update achords"
  echo "    achords obase                Organization Base setup"
  echo ""
  printf "  ${BOLD}For help:${NC}\n"
  echo "    achords --help               Show all products"
  echo ""
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  echo "$BANNER"
  echo ""
  
  # Check if update is needed
  if check_update_needed; then
    show_post_update
    exit 0
  fi
  
  # Ask user if they want to update
  echo ""
  read -rp "  Do you want to update? [Y/n] " -n 1 confirm
  echo ""
  
  if [[ "$confirm" =~ ^[Nn]$ ]]; then
    info "Update cancelled."
    echo ""
    exit 0
  fi
  
  # Perform update
  perform_update
  show_post_update
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi