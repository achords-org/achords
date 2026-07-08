#!/usr/bin/env bash
# Achords — Developer Environment Setup
# Sets up opencode + gentle-ai + .engram for a project.
#
# Usage:
#   bash dev-setup.sh [project-name]
#
# Example:
#   bash dev-setup.sh my-project

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;34m%s\033[0m %s\n" ">>>" "$*"; }
ok()    { printf "\033[1;32m%s\033[0m %s\n" "OK" "$*"; }
err()   { printf "\033[1;31m%s\033[0m %s\n" "ERR" "$*" >&2; }
warn()  { printf "\033[1;33m%s\033[0m %s\n" "WARN" "$*"; }

# ── config ───────────────────────────────────────────────────────────
ENGRAM_REPO="${ENGRAM_REPO:-https://github.com/Poincare-Space/.engram.git}"
OPENCODE_CONFIG="${HOME}/.config/opencode"
PROJECT_NAME="${1:-$(basename "$(pwd)")}"

# ── file locations guide ─────────────────────────────────────────────
show_file_locations() {
  cat <<'LOCATIONS'

=== File Locations Guide ===

Where each file lives and what it does:

  GLOBAL (your machine, shared across projects):
  ┌─────────────────────────────────────────────────────────────┐
  │ ~/.config/opencode/                                        │
  │ ├── opencode.json          Main opencode configuration     │
  │ ├── AGENTS.md              Global agent rules              │
  │ └── skills/                Installed skills                │
  │     └── gentle-ai/         Gentle AI skills                │
  └─────────────────────────────────────────────────────────────┘

  PROJECT (per-repo, version controlled):
  ┌─────────────────────────────────────────────────────────────┐
  │ ./                                                        │
  │ ├── .engram/                Shared memory (submodule)       │
  │ │   ├── decisions/          Architecture decisions         │
  │ │   ├── discoveries/        Technical findings             │
  │ │   ├── patterns/           Established conventions        │
  │ │   ├── bugs/               Bug fixes                      │
  │ │   └── sessions/           Session summaries              │
  │ ├── .achords/               Achords protocol               │
  │ │   ├── skills/             Protocol skills                │
  │ │   ├── registry.json       Agent registry                 │
  │ │   ├── claims.json         Active claims                  │
  │ │   └── events.ndjson       Audit log                      │
  │ ├── AGENTS.md               Project-specific agent rules   │
  │ └── README.md               Project documentation          │
  └─────────────────────────────────────────────────────────────┘

  READ THIS FIRST:
  • ~/.config/opencode/AGENTS.md     — Global rules for all agents
  • ./AGENTS.md                       — Project-specific rules
  • ./ .engram/README.md              — How shared memory works
  • ./.achords/skills/README.md       — Available Achords skills

LOCATIONS
}

# ── check prerequisites ──────────────────────────────────────────────
check_prerequisites() {
  info "Checking prerequisites..."

  # git
  if ! command -v git &>/dev/null; then
    err "git not found. Install git first."
    exit 1
  fi
  ok "git found"

  # gh (optional but recommended)
  if command -v gh &>/dev/null; then
    ok "GitHub CLI found"
  else
    warn "GitHub CLI not found (optional but recommended)"
  fi

  echo ""
}

# ── install opencode ─────────────────────────────────────────────────
install_opencode() {
  if command -v opencode &>/dev/null; then
    ok "opencode already installed"
    return
  fi

  info "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
  ok "opencode installed"
}

# ── install gentle-ai ────────────────────────────────────────────────
install_gentleai() {
  if command -v gentle-ai &>/dev/null; then
    ok "gentle-ai already installed"
    return
  fi

  info "Installing gentle-ai..."
  curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
  ok "gentle-ai installed"
}

# ── add .engram submodule ────────────────────────────────────────────
add_engram_submodule() {
  if [ -d ".engram" ]; then
    ok ".engram submodule already exists"
    return
  fi

  info "Adding .engram as git submodule..."
  git submodule add "$ENGRAM_REPO" .engram
  ok ".engram submodule added"

  info "Initializing submodule..."
  git submodule update --init
  ok ".engram initialized"
}

# ── configure SDD phases ─────────────────────────────────────────────
configure_sdd_phases() {
  info "Configuring SDD phases with .engram context..."

  OPENCODE_JSON="${OPENCODE_CONFIG}/opencode.json"

  if [ ! -f "$OPENCODE_JSON" ]; then
    warn "opencode.json not found at $OPENCODE_JSON"
    warn "Run 'gentle-ai install' first to generate it"
    return
  fi

  # Add .engram context to SDD agents
  AGENTS_TO_UPDATE=(
    "sdd-explore"
    "sdd-propose"
    "sdd-spec"
    "sdd-design"
    "sdd-tasks"
    "sdd-apply"
    "sdd-verify"
    "sdd-archive"
  )

  for agent in "${AGENTS_TO_UPDATE[@]}"; do
    if jq -e ".agent.\"$agent\"" "$OPENCODE_JSON" > /dev/null 2>&1; then
      # Add .engram read instruction to agent config
      tmp=$(mktemp)
      jq ".agent.\"$agent\".instructions += [\"Read .engram/README.md for shared memory context.\"]" "$OPENCODE_JSON" > "$tmp" \
        && mv "$tmp" "$OPENCODE_JSON"
      ok "$agent: .engram context added"
    fi
  done

  ok "SDD phases configured"
}

# ── create project .gitmodules ───────────────────────────────────────
create_gitmodules() {
  if [ ! -f ".gitmodules" ]; then
    info "Creating .gitmodules..."
    cat > .gitmodules << 'EOF'
[submodule ".engram"]
	path = .engram
	url = https://github.com/Poincare-Space/.engram.git
EOF
    ok ".gitmodules created"
  else
    ok ".gitmodules already exists"
  fi
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  cat <<'BANNER'

=== Achords Developer Setup ===

This script sets up:
  1. opencode (AI coding assistant)
  2. gentle-ai (SDD workflow)
  3. .engram (shared memory submodule)
  4. SDD phase configuration

BANNER
  echo ""

  # Show file locations
  show_file_locations

  # Check prerequisites
  check_prerequisites

  # Install tools
  install_opencode
  echo ""

  install_gentleai
  echo ""

  # Add .engram submodule
  add_engram_submodule
  echo ""

  # Configure SDD phases
  configure_sdd_phases
  echo ""

  # Create .gitmodules if needed
  create_gitmodules
  echo ""

  # Summary
  ok "Setup complete!"
  echo ""
  info "File locations summary:"
  echo "  Global config:  ${OPENCODE_CONFIG}/"
  echo "  Project memory: ./.engram/"
  echo "  Achords:        ./.achords/"
  echo ""
  info "Next steps:"
  echo "  1. Read ./AGENTS.md for project rules"
  echo "  2. Read ./.engram/README.md for memory usage"
  echo "  3. Start developing with achords workflow"
  echo ""
}

main "$@"
