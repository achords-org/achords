#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# achords — One-liner installer
# ══════════════════════════════════════════════════════════════════════
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/achords-org/achords/main/scripts/install.sh | bash
#
# This script:
#   1. Installs gentle-ai if not present
#   2. Installs opencode if not present
#   3. Installs achords via npm
#   4. Runs gentle-ai install with full-gentleman preset
#   5. Verifies everything works
#
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m➜\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$*"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$*" >&2; }

# ── banner ───────────────────────────────────────────────────────────
cat << 'EOF'
  ╔═══════════════════════════════════════════╗
  ║     🎵 A C H O R D S                     ║
  ║     Installer + gentle-ai integration     ║
  ╚═══════════════════════════════════════════╝
EOF
echo ""

# ── check/install gentle-ai ──────────────────────────────────────────
install_gentleai() {
  if command -v gentle-ai &>/dev/null; then
    ok "gentle-ai already installed: $(gentle-ai version 2>/dev/null || echo 'unknown')"
    return 0
  fi
  
  info "Installing gentle-ai..."
  curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
  ok "gentle-ai installed"
}

# ── check/install opencode ───────────────────────────────────────────
install_opencode() {
  if command -v opencode &>/dev/null; then
    ok "opencode already installed: $(opencode --version 2>/dev/null || echo 'unknown')"
    return 0
  fi
  
  info "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
  ok "opencode installed"
}

# ── install achords ──────────────────────────────────────────────────
install_achords() {
  if command -v achords &>/dev/null; then
    ok "achords already installed"
    return 0
  fi
  
  info "Installing achords via npm..."
  npm install -g achords
  ok "achords installed"
}

# ── configure gentle-ai for opencode ─────────────────────────────────
configure_gentleai() {
  info "Configuring gentle-ai for OpenCode..."
  
  # Run gentle-ai install with full-gentleman preset if not already configured
  local config_dir="${HOME}/.config/opencode"
  if [ ! -f "${config_dir}/AGENTS.md" ]; then
    gentle-ai install \
      --agents opencode \
      --scope global \
      --channel stable \
      --preset full-gentleman 2>&1 || true
    ok "gentle-ai configured for OpenCode"
  else
    ok "gentle-ai already configured"
  fi
  
  # Sync skills and registry
  gentle-ai sync 2>/dev/null || true
  gentle-ai skill-registry refresh 2>/dev/null || true
  ok "gentle-ai synced"
}

# ── verify installation ──────────────────────────────────────────────
verify() {
  info "Verifying installation..."
  
  local errors=0
  
  # Check gentle-ai
  if command -v gentle-ai &>/dev/null; then
    ok "gentle-ai: $(gentle-ai version 2>/dev/null || echo 'OK')"
  else
    err "gentle-ai not found"
    errors=$((errors + 1))
  fi
  
  # Check opencode
  if command -v opencode &>/dev/null; then
    ok "opencode: $(opencode --version 2>/dev/null || echo 'OK')"
  else
    err "opencode not found"
    errors=$((errors + 1))
  fi
  
  # Check achords
  if command -v achords &>/dev/null; then
    ok "achords: $(achords --version 2>/dev/null || echo 'OK')"
  else
    err "achords not found"
    errors=$((errors + 1))
  fi
  
  # Check OpenCode AGENTS.md
  local agents_md="${HOME}/.config/opencode/AGENTS.md"
  if [ -f "$agents_md" ]; then
    if grep -q "gentle-ai:persona" "$agents_md" 2>/dev/null; then
      ok "OpenCode AGENTS.md: has gentle-ai markers"
    else
      warn "OpenCode AGENTS.md: missing gentle-ai markers (run gentle-ai sync)"
    fi
  else
    warn "OpenCode AGENTS.md: not found"
  fi
  
  # Check engram
  if command -v engram &>/dev/null; then
    ok "engram: installed"
  else
    warn "engram: not found (optional, needed for persistent memory)"
  fi
  
  echo ""
  if [ "$errors" -eq 0 ]; then
    ok "Installation complete!"
  else
    err "Installation completed with ${errors} error(s)"
  fi
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  install_gentleai
  echo ""
  
  install_opencode
  echo ""
  
  install_achords
  echo ""
  
  configure_gentleai
  echo ""
  
  verify
  echo ""
  
  echo "  ╔═══════════════════════════════════════════╗"
  echo "  ║  ✓ Ready to go!                          ║"
  echo "  ╚═══════════════════════════════════════════╝"
  echo ""
  echo "  Next steps:"
  echo "    1. Open opencode in your project"
  echo "    2. Run: achords obase --org <your-org>"
  echo "    3. Start coding with AI agents!"
  echo ""
  echo "  Documentation: https://achords.pages.dev"
  echo ""
}

main "$@"
