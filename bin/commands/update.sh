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
NPM_PACKAGE="achords"

# Get installed version (from package.json in dev, or npm in production)
get_installed_version() {
  local pkg_json="${ACHORDS_DIR}/package.json"
  if [ -f "$pkg_json" ]; then
    grep '"version"' "$pkg_json" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  else
    npm list -g achords --depth=0 2>/dev/null | grep achords | sed 's/.*@\([^ ]*\).*/\1/' || echo "unknown"
  fi
}

# Get latest version from npm registry
get_latest_version() {
  npm view "$NPM_PACKAGE" version 2>/dev/null || echo "unknown"
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
  local installed_version
  installed_version=$(get_installed_version)
  
  local latest_version
  latest_version=$(get_latest_version)
  
  info "Checking if update is needed..."
  
  if [ "$latest_version" = "unknown" ]; then
    # Package not yet published to npm - check git
    if [ -d "$ACHORDS_DIR/.git" ]; then
      cd "$ACHORDS_DIR"
      if git fetch origin --quiet 2>/dev/null; then
        local current_commit
        current_commit=$(git rev-parse HEAD 2>/dev/null)
        local latest_commit
        latest_commit=$(git rev-parse origin/main 2>/dev/null)
        
        if [ "$current_commit" = "$latest_commit" ]; then
          ok "achords is already up to date! (v${installed_version} - dev mode)"
          echo ""
          return 0
        fi
      fi
    fi
    
    err "Package not found on npm. Check your internet connection."
    exit 1
  fi
  
  if [ "$installed_version" = "$latest_version" ]; then
    ok "achords is already up to date! (v${installed_version})"
    echo ""
    return 0
  fi
  
  echo ""
  echo "  Installed:  v${installed_version}"
  echo "  Latest:     v${latest_version}"
  echo ""
  
  return 1
}

# ── perform update ───────────────────────────────────────────────────
perform_update() {
  local latest_version
  latest_version=$(get_latest_version)
  
  info "Updating achords to v${latest_version}..."
  
  # Check if installed globally or locally
  if [ -d "$ACHORDS_DIR/.git" ]; then
    # Development mode - git pull
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
  else
    # Production mode - npm update
    if npm update -g achords 2>/dev/null; then
      ok "Update successful!"
    else
      err "Update failed. Try running: npm install -g achords"
      exit 1
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