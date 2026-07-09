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
NPM_PACKAGE="achords"

# Get installed version (from package.json in dev, or npm in production)
get_installed_version() {
  local pkg_json="${ACHORDS_DIR}/package.json"
  if [ -f "$pkg_json" ]; then
    grep '"version"' "$pkg_json" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  else
    # Fallback: try npm list
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
  local installed_version
  installed_version=$(get_installed_version)
  
  local latest_version
  latest_version=$(get_latest_version)
  
  info "Checking for updates..."
  
  if [ "$latest_version" = "unknown" ]; then
    # Package not yet published to npm
    if [ -d "$ACHORDS_DIR/.git" ]; then
      # Check git remote instead
      cd "$ACHORDS_DIR"
      if git fetch origin --quiet 2>/dev/null; then
        local current_commit
        current_commit=$(git rev-parse HEAD 2>/dev/null)
        local latest_commit
        latest_commit=$(git rev-parse origin/main 2>/dev/null)
        
        if [ "$current_commit" = "$latest_commit" ]; then
          ok "achords is up to date! (v${installed_version} - dev mode)"
          return 0
        else
          warn "New changes available on remote!"
          echo ""
          echo "  Current:  ${current_commit:0:8}"
          echo "  Latest:   ${latest_commit:0:8}"
          echo ""
          return 1
        fi
      else
        warn "Could not check npm registry or git remote."
        return 1
      fi
    else
      warn "Package not found on npm. Check your internet connection."
      return 1
    fi
  fi
  
  if [ "$installed_version" = "$latest_version" ]; then
    ok "achords is up to date! (v${installed_version})"
    return 0
  else
    warn "New version available!"
    echo ""
    echo "  Installed:  v${installed_version}"
    echo "  Latest:     v${latest_version}"
    echo ""
    return 1
  fi
}

# ── show version info ────────────────────────────────────────────────
show_version() {
  local version
  version=$(get_installed_version)
  
  echo "$BANNER"
  echo ""
  printf "  ${BOLD}Installed:${NC} v%s\n" "$version"
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