#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# doctor — Health check for achords + gentle-ai + opencode
# ══════════════════════════════════════════════════════════════════════
# Description: Verify installation and configuration
#
# Usage:
#   achords doctor
#   achords doctor --fix
#
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── branding ────────────────────────────────────────────────────────
ACHORDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Read version from package.json (single source of truth)
get_version() {
  local pkg_json="${ACHORDS_DIR}/package.json"
  if [ -f "$pkg_json" ]; then
    grep '"version"' "$pkg_json" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  else
    echo "unknown"
  fi
}

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m➜\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$*"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$*" >&2; }
header(){ printf "\n\033[1;35m── %s ──\033[0m\n" "$*"; }

# ── parse args ───────────────────────────────────────────────────────
FIX_MODE=false
while [ $# -gt 0 ]; do
  case "$1" in
    --fix)
      FIX_MODE=true
      shift
      ;;
    --help|-h)
      echo "Usage: achords doctor [--fix]"
      echo ""
      echo "Options:"
      echo "  --fix    Attempt to fix issues automatically"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

# ── checks ───────────────────────────────────────────────────────────
ERRORS=0
WARNINGS=0
FIXED=0

check_binary() {
  local name="$1"
  local cmd="$2"
  
  if command -v "$cmd" &>/dev/null; then
    local version
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "unknown")
    ok "${name}: ${version}"
    return 0
  else
    err "${name}: NOT FOUND"
    ERRORS=$((ERRORS + 1))
    return 1
  fi
}

check_file() {
  local path="$1"
  local desc="$2"
  
  if [ -f "$path" ]; then
    ok "${desc}: exists"
    return 0
  else
    warn "${desc}: not found"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
}

check_gentleai_markers() {
  local agents_md="${HOME}/.config/opencode/AGENTS.md"
  
  if [ ! -f "$agents_md" ]; then
    warn "OpenCode AGENTS.md: not found"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
  
  local has_persona=false
  local has_engram=false
  
  grep -q "gentle-ai:persona" "$agents_md" 2>/dev/null && has_persona=true
  grep -q "gentle-ai:engram-protocol" "$agents_md" 2>/dev/null && has_engram=true
  
  if [ "$has_persona" = true ] && [ "$has_engram" = true ]; then
    ok "OpenCode AGENTS.md: has gentle-ai markers"
    return 0
  else
    warn "OpenCode AGENTS.md: missing gentle-ai markers"
    WARNINGS=$((WARNINGS + 1))
    
    if [ "$FIX_MODE" = true ]; then
      info "Running gentle-ai sync to fix markers..."
      gentle-ai sync 2>/dev/null || true
      FIXED=$((FIXED + 1))
    fi
    return 1
  fi
}

check_opencode_json() {
  local config="${HOME}/.config/opencode/opencode.json"
  
  if [ ! -f "$config" ]; then
    warn "opencode.json: not found"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
  
  # Check for engram MCP
  if grep -q '"engram"' "$config" 2>/dev/null; then
    ok "opencode.json: has engram MCP"
  else
    warn "opencode.json: missing engram MCP"
    WARNINGS=$((WARNINGS + 1))
    
    if [ "$FIX_MODE" = true ]; then
      info "Running gentle-ai sync to add MCP config..."
      gentle-ai sync 2>/dev/null || true
      FIXED=$((FIXED + 1))
    fi
  fi
  
  return 0
}

check_engram() {
  if command -v engram &>/dev/null; then
    ok "engram: installed"
    
    # Check if engram is running
    if engram doctor 2>/dev/null | grep -q "reachable\|running\|ok" 2>/dev/null; then
      ok "engram: reachable"
    else
      warn "engram: not reachable (may need to start)"
      WARNINGS=$((WARNINGS + 1))
    fi
    return 0
  else
    warn "engram: not installed (optional)"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
}

check_workspace() {
  local work_dir="${1:-.}"
  
  if [ ! -d "$work_dir" ]; then
    return 1
  fi
  
  header "Workspace checks (${work_dir})"
  
  # Check .engram
  if [ -d "${work_dir}/.engram" ]; then
    ok ".engram: exists"
    if [ -f "${work_dir}/.engram/config.json" ]; then
      ok ".engram/config.json: exists"
    else
      warn ".engram/config.json: missing"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    info ".engram: not initialized (run achords obase --repo <name>)"
  fi
  
  # Check AGENTS.md
  if [ -f "${work_dir}/AGENTS.md" ]; then
    ok "AGENTS.md: exists"
    if grep -q "achords:header" "${work_dir}/AGENTS.md" 2>/dev/null; then
      ok "AGENTS.md: has achords markers"
    else
      warn "AGENTS.md: missing achords markers"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    info "AGENTS.md: not created (run achords obase --repo <name>)"
  fi
  
  # Check opencode.json
  if [ -f "${work_dir}/opencode.json" ]; then
    ok "opencode.json: exists"
  else
    info "opencode.json: not created (run achords obase --repo <name>)"
  fi
  
  # Check .achords submodule
  if [ -f "${work_dir}/.gitmodules" ] && grep -q ".achords" "${work_dir}/.gitmodules" 2>/dev/null; then
    ok ".achords submodule: configured"
  else
    info ".achords submodule: not added"
  fi
  
  return 0
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "  ╔═══════════════════════════════════════════╗"
  echo "  ║  🎵 Achords Doctor                       ║"
  echo "  ╚═══════════════════════════════════════════╝"
  echo ""
  
  header "Required binaries"
  check_binary "achords" "achords" || true
  check_binary "opencode" "opencode" || true
  check_binary "gentle-ai" "gentle-ai" || true
  
  header "Optional binaries"
  check_binary "engram" "engram" || true
  check_binary "git" "git" || true
  check_binary "gh" "gh" || true
  
  header "gentle-ai integration"
  check_gentleai_markers || true
  check_opencode_json || true
  
  header "Engram"
  check_engram || true
  
  # Check workspace if in a git repo
  if git rev-parse --git-dir >/dev/null 2>&1; then
    check_workspace "$(git rev-parse --show-toplevel)"
  fi
  
  # Summary
  echo ""
  header "Summary"
  
  if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    ok "All checks passed!"
  else
    if [ "$ERRORS" -gt 0 ]; then
      err "Errors: ${ERRORS}"
    fi
    if [ "$WARNINGS" -gt 0 ]; then
      warn "Warnings: ${WARNINGS}"
    fi
    if [ "$FIXED" -gt 0 ]; then
      ok "Fixed: ${FIXED}"
    fi
    
    echo ""
    if [ "$ERRORS" -gt 0 ]; then
      echo "  Run 'achords doctor --fix' to attempt automatic fixes"
    fi
  fi
  
  echo ""
}

main
