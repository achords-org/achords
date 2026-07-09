#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# obase — Organization Base
# ══════════════════════════════════════════════════════════════════════
# Description: Set up your GitHub organization for multi-agent collaboration
#
# Usage:
#   achords obase [options]
#   achords obase --org MyOrg
#   achords obase --help
#
# Options:
#   --org <name>      Organization name
#   --skills <url>    Skills repository URL
#   --dir <path>      Work directory (default: ~/achords-workspace)
#   --help, -h        Show this help
#
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── branding ────────────────────────────────────────────────────────
ACHORDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRODUCT="obase"
PRODUCT_NAME="Organization Base"

# Read version from package.json (single source of truth)
get_version() {
  local pkg_json="${ACHORDS_DIR}/package.json"
  if [ -f "$pkg_json" ]; then
    grep '"version"' "$pkg_json" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
  else
    echo "unknown"
  fi
}
BANNER=$(cat << 'EOF'
  ╔═══════════════════════════════════════════╗
  ║     🎵 A C H O R D S                     ║
  ║     Organization Base                     ║
  ╚═══════════════════════════════════════════╝
EOF
)

# ── helpers ──────────────────────────────────────────────────────────
info()  { printf "\033[1;36m▸\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$*"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$*" >&2; }
header(){ printf "\n\033[1;35m── %s ──\033[0m\n" "$*"; }

# ── validate org/repo names ─────────────────────────────────────────
validate_name() {
  local name="$1"
  local field="$2"  # "organization" or "repository"

  # Prevents path traversal and command injection
  # Must start with alphanumeric, can contain letters/numbers/dots/hyphens/underscores
  # But no consecutive dots (path traversal) and no special chars
  if [[ "$name" =~ ^[0-9A-Za-z][0-9A-Za-z._-]*$ ]] && [[ ! "$name" =~ \.\. ]]; then
    return 0
  else
    err "${field^} name invalid: '${name}'"
    echo "  Must match: ^[0-9A-Za-z][0-9A-Za-z._-]*\$"
    echo "  Cannot contain consecutive dots (..) or special characters"
    return 1
  fi
}

# ── help ─────────────────────────────────────────────────────────────
show_help() {
  local version
  version=$(get_version)
  
  echo "$BANNER"
  echo ""
  printf "  \033[1m%s\033[0m — %s\n" "$PRODUCT" "$PRODUCT_NAME"
  echo ""
  echo "  Set up your GitHub organization for multi-agent collaboration."
  echo ""
  echo "  Usage:"
  echo "    achords obase [options]"
  echo ""
  echo "  Options:"
  echo "    --org <name>          Organization name"
  echo "    --skills <url>        Skills repository URL"
  echo "    --dir <path>          Work directory (default: ~/achords/{org})"
  echo "    --repo <name>         Setup existing repo for agent memory"
  echo "    --update-profile      Update repos table in profile README only"
  echo "    --update-headers      Update AGENTS.md headers in all repos"
  echo "    --push                Commit and push changes (works with all modes)"
  echo "    --help, -h            Show this help"
  echo ""
  echo "  Examples:"
  echo "    achords obase"
  echo "    achords obase --org MyOrg"
  echo "    achords obase --org MyOrg --skills https://github.com/org/skills.git"
  echo "    achords obase --org MyOrg --push"
  echo "    achords obase --repo my-project"
  echo "    achords obase --update-profile"
  echo "    achords obase --update-profile --push"
  echo ""
}

# ── parse args ───────────────────────────────────────────────────────
parse_args() {
  ORG_NAME=""
  SKILLS_URL=""
  WORK_DIR=""
  UPDATE_PROFILE=false
  UPDATE_HEADERS=false
  AUTO_PUSH=false
  REPO_NAME=""
  DIR_OVERRIDE=false
  # CLI flag tracking (for .env precedence)
  _ORG_SET=""
  _SKILLS_SET=""
  _WORK_DIR_SET=""
  
  while [ $# -gt 0 ]; do
    case "$1" in
      --org)
        ORG_NAME="$2"
        _ORG_SET="true"
        shift 2
        ;;
      --skills)
        SKILLS_URL="$2"
        _SKILLS_SET="true"
        shift 2
        ;;
      --dir)
        WORK_DIR="$2"
        DIR_OVERRIDE=true
        _WORK_DIR_SET="true"
        shift 2
        ;;
      --repo)
        REPO_NAME="$2"
        shift 2
        ;;
      --update-profile)
        UPDATE_PROFILE=true
        shift
        ;;
      --update-headers)
        UPDATE_HEADERS=true
        shift
        ;;
      --push)
        AUTO_PUSH=true
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        # Unknown flag - show help
        if [[ "$1" == --* ]]; then
          err "Unknown option: $1"
          echo ""
          show_help
          exit 1
        fi
        # Treat as org name for backwards compatibility
        if [ -z "$ORG_NAME" ]; then
          ORG_NAME="$1"
          _ORG_SET="true"
        fi
        shift
        ;;
    esac
  done
}

# ── load .env safely (no shell execution) ────────────────────────────
safe_load_env() {
  local env_file="$1"
  if [ ! -f "$env_file" ]; then
    return 1
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue

    # Validate KEY=VALUE format (no shell commands allowed)
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*$ ]]; then
      local key="${line%%=*}"
      local value="${line#*=}"
      # Remove surrounding quotes if present
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"
      export "$key"="$value"
    else
      warn "Skipping invalid .env line: $line"
    fi
  done < "$env_file"
}

# ── load .env ────────────────────────────────────────────────────────
load_env() {
  ENV_FILE="${WORK_DIR}/.env"
  if [ -f "$ENV_FILE" ]; then
    # Only use .env values if CLI flags weren't explicitly set
    if [ -z "${_ORG_SET:-}" ]; then
      safe_load_env "$ENV_FILE"
      _ORG_SET="true"
    fi
  fi
}

# ── create .env if missing ───────────────────────────────────────────
setup_env() {
  mkdir -p "$WORK_DIR"
  ENV_FILE="${WORK_DIR}/.env"
  
  if [ ! -f "$ENV_FILE" ]; then
    info "No .env found. Let's configure your organization."
    echo ""
    
    # Get org name from arg or prompt
    if [ -n "$ORG_NAME" ]; then
      READ_ORG="$ORG_NAME"
    else
      read -rp "  Organization name: " READ_ORG
    fi
    
    # Get optional skills repo
    if [ -n "$SKILLS_URL" ]; then
      READ_SKILLS="$SKILLS_URL"
    else
      read -rp "  Skills repo URL (optional, press Enter to skip): " READ_SKILLS
    fi
    
    # Get work directory
    read -rp "  Work directory [${WORK_DIR}]: " READ_WORKDIR
    READ_WORKDIR="${READ_WORKDIR:-${WORK_DIR}}"
    
    # Write .env
    cat > "$ENV_FILE" << EOF
# Organization Configuration
ORG_NAME=${READ_ORG}
WORK_DIR=${READ_WORKDIR}
EOF
    
    if [ -n "$READ_SKILLS" ]; then
      echo "SKILLS_REPO_URL=${READ_SKILLS}" >> "$ENV_FILE"
    fi
    
    ok ".env created"
    echo ""
    
    # Update variables
    ORG_NAME="$READ_ORG"
    WORK_DIR="$READ_WORKDIR"
    SKILLS_URL="$READ_SKILLS"
  else
    load_env
  fi
}

# ── check dependencies ───────────────────────────────────────────────
check_deps() {
  header "Checking dependencies"
  
  local missing=0
  for cmd in git gh; do
    if command -v "$cmd" > /dev/null 2>&1; then
      ok "$cmd $(command -v "$cmd")"
    else
      err "$cmd not found"
      missing=$((missing + 1))
    fi
  done
  
  if [ "$missing" -gt 0 ]; then
    echo ""
    err "Install missing dependencies and retry."
    exit 1
  fi
}

# ── check GitHub auth ────────────────────────────────────────────────
check_auth() {
  header "Checking GitHub authentication"
  
  if gh auth status > /dev/null 2>&1; then
    local user
    user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
    ok "Authenticated as ${user}"
  else
    err "Not logged in to GitHub CLI."
    echo ""
    echo "  Run: gh auth login"
    exit 1
  fi
}

# ── check organization ───────────────────────────────────────────────
check_org() {
  header "Checking organization"

  # Validate org name before API call
  if ! validate_name "$ORG_NAME" "organization"; then
    exit 1
  fi
  
  # Use API directly - more reliable than gh org view for newly created orgs
  if gh api "orgs/${ORG_NAME}" > /dev/null 2>&1; then
    ok "Organization '${ORG_NAME}' exists"
  else
    err "Organization '${ORG_NAME}' does not exist."
    echo ""
    echo "  ┌─────────────────────────────────────────────────┐"
    echo "  │  Create your organization here:                 │"
    echo "  │                                                 │"
    echo "  │  https://github.com/organizations/new          │"
    echo "  │                                                 │"
    echo "  │  Then re-run this command.                      │"
    echo "  └─────────────────────────────────────────────────┘"
    echo ""
    exit 1
  fi
}

# ── check local state ────────────────────────────────────────────────
check_local() {
  header "Checking local state"
  
  local conflicts=0
  
  for repo in .internal .skills; do
    local dir="${WORK_DIR}/${repo}"
    if [ -d "$dir" ]; then
      local count
      count=$(find "$dir" -mindepth 1 -not -path '*/\.git/*' -not -path '*/\.git' 2>/dev/null | wc -l)
      if [ "$count" -gt 0 ]; then
        err "${repo} exists with content"
        echo "    Location: ${dir}"
        echo "    To reset: rm -rf ${dir}"
        conflicts=$((conflicts + 1))
      fi
    fi
  done
  
  if [ "$conflicts" -gt 0 ]; then
    echo ""
    err "Found ${conflicts} conflict(s). Fix above and retry."
    exit 1
  fi
  
  ok "No conflicts"
}

# ── create repositories ──────────────────────────────────────────────
create_repos() {
  header "Creating repositories"

  # Validate org name
  if ! validate_name "$ORG_NAME" "organization"; then
    exit 1
  fi
  
  for repo in .github .internal .skills .achords; do
    if gh repo view "${ORG_NAME}/${repo}" > /dev/null 2>&1; then
      ok "${repo} already exists"
    else
      local visibility="private"
      local desc="Internal team documentation"
      
      case "$repo" in
        .github)
          visibility="public"
          desc="GitHub organization profile"
          ;;
        .achords)
          visibility="private"
          desc="Agent orchestration rules and versioned configuration"
          ;;
      esac
      
      info "Creating ${repo} (${visibility})..."
      gh repo create "${ORG_NAME}/${repo}" --"${visibility}" --description "$desc"
      ok "${repo} created"
    fi
  done
}

# ── clone repositories ───────────────────────────────────────────────
clone_repos() {
  header "Cloning repositories"
  
  mkdir -p "$WORK_DIR"
  
  for repo in .github .internal .skills .achords; do
    local target="${WORK_DIR}/${repo}"
    if [ -d "$target" ]; then
      ok "${repo} exists locally"
    else
      info "Cloning ${repo}..."
      git clone "https://github.com/${ORG_NAME}/${repo}.git" "$target" --quiet 2>/dev/null || {
        warn "Could not clone ${repo}, will init later"
        continue
      }
      ok "${repo} cloned"
    fi
  done
}

# ── initialize .achords repo structure ──────────────────────────────
init_achords_repo() {
  header "Initializing .achords repo structure"
  
  local achords_dir="${WORK_DIR}/.achords"
  
  if [ ! -d "$achords_dir/.git" ]; then
    err "Not a git repository: ${achords_dir}"
    return 1
  fi
  
  # Use subshell to prevent cd from leaking global state
  (
    cd "$achords_dir"
    
    # Check if already initialized
    if [ -f "version.json" ]; then
      ok ".achords already initialized"
      exit 0
    fi
    
    # Create directory structure
    mkdir -p config/schemas
    mkdir -p skills
    mkdir -p agents
    mkdir -p templates
    mkdir -p .engram/chunks
    
    # Create version.json
    cat > version.json << 'EOF'
{
  "version": "1.0.0",
  "schema_version": "1.0.0",
  "created_at": "TIMESTAMP",
  "updated_at": "TIMESTAMP",
  "description": "Achords organization configuration",
  "owner": "ORG_NAME",
  "components": {
    "engram": "1.0.0",
    "agents": "1.0.0",
    "skills": "1.0.0",
    "config": "1.0.0"
  }
}
EOF
    sed -i "s/TIMESTAMP/$(date -u +%Y-%m-%dT%H:%M:%SZ)/g" version.json
    sed -i "s/\"ORG_NAME\"/\"${ORG_NAME}\"/g" version.json
    
    # Create AGENTS.md - the main entry point for agents
    local achords_version
    achords_version=$(get_version)
    
    cat > AGENTS.md << EOF
<!-- achords:header:v${achords_version} -->
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
<!-- achords:resources -->
| Resource | Path | Purpose |
|----------|------|---------|
| Org Rules | \`.achords/AGENTS.md\` | Organization-wide agent rules |
| Org Memory | \`.achords/.engram/\` | Shared knowledge (git-synced) |
| Conventions | \`.achords/config/conventions.json\` | Code conventions |
| Policies | \`.achords/config/policies.json\` | Org policies |
| Skills | \`.skills/skills/\` | Shared skills (Agent Skills spec) |
| Onboarding | \`.internal/onboarding/\` | Setup scripts and docs |
<!-- achords:end -->

# .achords — Agent Orchestration Rules

> This file defines how AI agents work within this organization.
> Each repo's AGENTS.md should reference this file.

## Reading Order

1. \`.achords/AGENTS.md\` — This file (org-wide rules)
2. \`.achords/config/conventions.json\` — Code conventions
3. \`.achords/config/policies.json\` — Org policies
4. \`repo/.engram/config.json\` — Repo context
5. \`repo/AGENTS.md\` — Repo-specific rules

## Memory Protocol

### At Session Start

\`\`\`bash
# Update .achords submodule
git submodule update --remote .achords

# Load org knowledge
mem_search(project: "${ORG_NAME}", query: "conventions", limit: 5)
\`\`\`

### During Work

Save after significant decisions:

\`\`\`bash
mem_save(
  project: "${ORG_NAME}",
  title: "Decision: use pattern X",
  type: "decision",
  content: "We decided to use X because...",
  topic_key: "decisions/architecture"
)
\`\`\`

### At Session End

\`\`\`bash
mem_session_summary(content: "## Goal\n...## Accomplished\n...")
\`\`\`

## Skills

Skills follow the [Agent Skills specification](https://agentskills.io/specification):

\`\`\`bash
cat .skills/skills/testing/SKILL.md
\`\`\`

## Modification Rules

- **Don't modify** \`.achords/\` directly
- **Do modify** current repo files
- **Do create** shared skills in \`.skills/skills/\`

## Versioning

When the organization updates agent rules:
1. Update files in this repo
2. Bump version in \`version.json\`
3. All repos pull the latest via submodule update
EOF
    
    # Create default policies
    cat > config/policies.json << 'EOF'
{
  "version": "1.0.0",
  "access": {
    "who_can_create_repos": ["admin", "member"],
    "who_can_invite": ["admin"],
    "default_repo_permission": "read"
  },
  "agents": {
    "allowed_models": ["gpt-4", "claude-3-opus"],
    "require_review": true,
    "max_changes_per_pr": 500
  },
  "memory": {
    "org_level": "ORG_NAME",
    "sync_enabled": true,
    "retention_days": 365
  }
}
EOF
    sed -i "s/\"ORG_NAME\"/\"${ORG_NAME}\"/g" config/policies.json
    
    # Create empty schemas directory marker
    cat > config/schemas/README.md << 'EOF'
# Schemas

Data schemas for agent communication and data exchange.
EOF
    
    # Create skills README
    cat > skills/README.md << 'EOF'
# Skills

Shared skills across all repositories in this organization.
EOF
    
    # Create agents README
    cat > agents/README.md << 'EOF'
# Agents

Agent-specific configurations and profiles.
EOF
    
    # Create templates README
    cat > templates/README.md << 'EOF'
# Templates

Templates for new repositories and agent configurations.
EOF
    
    # Create .gitignore for .engram
    cat > .gitignore << 'EOF'
# Engram local database (synced via manifest.json + chunks)
.engram/engram.db

# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Node modules (if any)
node_modules/

# Environment files
.env
.env.local
EOF
    
    # Commit
    git add -A
    git commit -m "init: achords configuration structure with .engram" --quiet
    
    # Push to remote so submodules work for other repos
    if git push --quiet origin main 2>/dev/null || git push --quiet origin master 2>/dev/null; then
      ok ".achords pushed to remote"
    else
      warn ".achords committed locally but push failed — push manually:"
      echo "    cd ${achords_dir} && git push -u origin main"
    fi
  )
}

# ── generate base files ──────────────────────────────────────────────
generate_files() {
  header "Generating base files"
  
  # .github profile README
  local profile_dir="${WORK_DIR}/.github/profile"
  mkdir -p "$profile_dir"
  
  # Fetch public repos from the organization
  local repos_json
  repos_json=$(gh api "orgs/${ORG_NAME}/repos?type=public&per_page=100" --paginate 2>/dev/null || echo "[]")
  
  # Build repos table
  local repos_table=""
  
  # Add achords-managed repos (always included)
  repos_table+="| \`.github\` | Organization profile |"
  repos_table+=$'\n'"| \`.achords\` | Agent orchestration rules |"
  repos_table+=$'\n'"| \`.internal\` | Internal team documentation |"
  repos_table+=$'\n'"| \`.skills\` | Shared skills library |"
  
  # Add existing public repos from the organization
  if [ "$repos_json" != "[]" ] && [ -n "$repos_json" ]; then
    local existing_repos
    existing_repos=$(echo "$repos_json" | jq -r '.[] | select(.name != ".github" and .name != ".internal" and .name != ".skills" and .name != ".achords") | "\(.name)|\(.description // "No description")"' 2>/dev/null)
    
    if [ -n "$existing_repos" ]; then
      while IFS='|' read -r repo_name repo_desc; do
        if [ -n "$repo_name" ]; then
          repos_table+=$'\n'"| \`${repo_name}\` | ${repo_desc} |"
        fi
      done <<< "$existing_repos"
    fi
  fi
  
  # Write profile README with markers for the repos table
  cat > "${profile_dir}/README.md" << EOF
# ${ORG_NAME}

> Multi-agent development organization powered by [Achords](https://github.com/achords-org/achords).

## Repositories

<!-- achords:repos:start -->
| Repo | Purpose |
|------|---------|
${repos_table}
<!-- achords:repos:end -->
EOF
  ok "Profile README"
  
  # .internal onboarding
  local onboarding_dir="${WORK_DIR}/.internal/onboarding"
  mkdir -p "${onboarding_dir}/scripts"
  mkdir -p "${onboarding_dir}/skills/join-team"
  
  cat > "${onboarding_dir}/README.md" << 'EOF'
# Onboarding

## Quick Start

Run the setup script:
```bash
bash onboarding/scripts/setup.sh
```

Or let your agent do it — point it to:
```
onboarding/skills/join-team/SKILL.md
```

## Files

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `AGENTS.md` | Agent configuration |
| `scripts/setup.sh` | Team member setup |
| `skills/join-team/SKILL.md` | Agent join skill |
EOF
  
  cat > "${onboarding_dir}/AGENTS.md" << 'EOF'
# Agents.md

> Agent configuration and protocols for this organization.

*To be completed by the team.*
EOF
  ok "Onboarding files"
}

# ── update profile README repos table ────────────────────────────────
update_profile() {
  header "Updating profile README"
  
  local profile_dir="${WORK_DIR}/.github/profile"
  local profile_file="${profile_dir}/README.md"
  
  # Create directory and file if they don't exist
  mkdir -p "$profile_dir"
  
  if [ ! -f "$profile_file" ]; then
    info "Creating profile README..."
    cat > "$profile_file" << EOF
# ${ORG_NAME}

> Multi-agent development organization powered by [Achords](https://github.com/achords-org/achords).

## Repositories

<!-- achords:repos:start -->
| Repo | Purpose |
|------|---------|
<!-- achords:repos:end -->
EOF
    ok "Profile README created"
  fi
  
  # Check for markers - if missing, add them
  if ! grep -q "<!-- achords:repos:start -->" "$profile_file"; then
    info "Adding repos markers to existing README..."
    # Find the ## Repositories line and add markers after the table header
    awk '
      /^## Repositories/ { print; found=1; next }
      found && /^\| Repo/ { print; print "|------|---------|"; print "<!-- achords:repos:start -->"; skip=1; next }
      found && skip && /^\|/ { next }
      found && skip && !/^\|/ { print "<!-- achords:repos:end -->"; skip=0 }
      { print }
    ' "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
    ok "Markers added"
  fi
  
  # Fetch public repos from the organization
  local repos_json
  repos_json=$(gh api "orgs/${ORG_NAME}/repos?type=public&per_page=100" --paginate 2>/dev/null || echo "[]")
  
  # Build repos table
  local repos_table=""
  
  # Add achords-managed repos (always included)
  repos_table+="| \`.github\` | Organization profile |"
  repos_table+=$'\n'"| \`.achords\` | Agent orchestration rules |"
  repos_table+=$'\n'"| \`.internal\` | Internal team documentation |"
  repos_table+=$'\n'"| \`.skills\` | Shared skills library |"
  
  # Add existing public repos from the organization
  if [ "$repos_json" != "[]" ] && [ -n "$repos_json" ]; then
    local existing_repos
    existing_repos=$(echo "$repos_json" | jq -r '.[] | select(.name != ".github" and .name != ".internal" and .name != ".skills" and .name != ".achords") | "\(.name)|\(.description // "No description")"' 2>/dev/null)
    
    if [ -n "$existing_repos" ]; then
      while IFS='|' read -r repo_name repo_desc; do
        if [ -n "$repo_name" ]; then
          repos_table+=$'\n'"| \`${repo_name}\` | ${repo_desc} |"
        fi
      done <<< "$existing_repos"
    fi
  fi
  
  # Replace content between markers using awk
  awk -v table="<!-- achords:repos:start -->
| Repo | Purpose |
|------|---------|
${repos_table}
<!-- achords:repos:end -->" '
    /<!-- achords:repos:start -->/ { print table; skip=1; next }
    /<!-- achords:repos:end -->/ { skip=0; next }
    !skip { print }
  ' "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
  
  ok "Repos table updated"
  echo ""
  echo "  Updated repos in: ${profile_file}"
  
  # Handle push if --push flag is set
  if [ "$AUTO_PUSH" = true ]; then
    local github_dir="${WORK_DIR}/.github"
    
    if [ ! -d "$github_dir/.git" ]; then
      err "Not a git repository: ${github_dir}"
      echo "  Run: achords obase --org ${ORG_NAME}"
      return 1
    fi
    
    cd "$github_dir"
    
    # Check for conflicts
    local status
    status=$(git status --porcelain 2>/dev/null)
    
    if [ -n "$status" ]; then
      warn "Uncommitted changes in ${github_dir}:"
      echo "$status" | head -10
      echo ""
    fi
    
    # Check if there are changes to commit
    if [ -z "$status" ]; then
      ok "No changes to commit"
      return 0
    fi
    
    # Commit and push silently
    info "Committing changes..."
    git add -A
    git commit -m "update: repos table" --quiet
    
    info "Pushing to remote..."
    if git push --quiet 2>/dev/null; then
      ok "Changes pushed to remote"
    else
      err "Push failed"
      echo "  Check your permissions and try again."
      return 1
    fi
  else
    # No --push flag: ask user
    local github_dir="${WORK_DIR}/.github"
    
    if [ -d "$github_dir/.git" ]; then
      cd "$github_dir"
      
      local status
      status=$(git status --porcelain 2>/dev/null)
      
      if [ -n "$status" ]; then
        echo ""
        read -rp "  Commit and push changes? [Y/n] " -n 1 confirm
        echo ""
        
        if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
          info "Committing changes..."
          git add -A
          git commit -m "update: repos table" --quiet
          
          info "Pushing to remote..."
          if git push --quiet 2>/dev/null; then
            ok "Changes pushed to remote"
          else
            err "Push failed"
            echo "  Check your permissions and try again."
          fi
        else
          info "Skipping push"
          echo "  Changes saved locally in: ${github_dir}"
        fi
      else
        ok "No changes to commit"
      fi
    fi
  fi
  
  echo ""
}

# ── import skills if provided ────────────────────────────────────────
import_skills() {
  if [ -n "${SKILLS_URL:-}" ]; then
    header "Importing skills"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if git clone "$SKILLS_URL" "$temp_dir" --quiet 2>/dev/null; then
      rm -rf "${WORK_DIR}/.skills"
      mv "$temp_dir" "${WORK_DIR}/.skills"
      ok "Skills imported from ${SKILLS_URL}"
    else
      warn "Could not clone skills repo"
      echo "  Add it later:"
      echo "    cd ${WORK_DIR}/.skills && git remote add origin ${SKILLS_URL}"
    fi
    
    rm -rf "$temp_dir"
  fi
}

# ── setup repo for agent memory ──────────────────────────────────────
setup_repo_memory() {
  local repo_dir="$1"
  local repo_name="$2"
  
  # Validate repo name
  if ! validate_name "$repo_name" "repository"; then
    return 1
  fi
  
  if [ ! -d "$repo_dir" ]; then
    return 1
  fi
  
  cd "$repo_dir"
  
  # Create .engram directory and config.json
  mkdir -p .engram
  
  cat > .engram/config.json << EOF
{
  "project_name": "${repo_name}",
  "scope": "repo",
  "org_level": "${ORG_NAME}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
  
  # Add .achords submodule if not already added
  if [ ! -f ".gitmodules" ] || ! grep -q ".achords" ".gitmodules" 2>/dev/null; then
    # Check if .achords directory exists in work dir
    if [ -d "${WORK_DIR}/.achords" ]; then
      info "Adding .achords submodule to ${repo_name}..."
      git submodule add "https://github.com/${ORG_NAME}/.achords.git" .achords 2>/dev/null || true
    fi
  fi
  
  # Create AGENTS.md if not exists
  if [ ! -f "AGENTS.md" ]; then
    local achords_version
    achords_version=$(get_version)
    
    cat > AGENTS.md << EOF
<!-- achords:header:v${achords_version} -->
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
<!-- achords:resources -->
| Resource | Path | Purpose |
|----------|------|---------|
| Org Rules | \`.achords/AGENTS.md\` | Organization-wide agent rules |
| Org Memory | \`.achords/.engram/\` | Shared knowledge (git-synced) |
| Conventions | \`.achords/config/conventions.json\` | Code conventions |
| Policies | \`.achords/config/policies.json\` | Org policies |
| Skills Rules | \`.skills/AGENTS.md\` | How to create/maintain skills |
| Skills | \`.skills/skills/\` | Shared skills (Agent Skills spec) |
| Onboarding | \`.internal/onboarding/\` | Setup scripts and docs |
| Repo Memory | \`.engram/\` | Isolated repo memory |
| Repo Config | \`.engram/config.json\` | project_name setting |
<!-- achords:end -->

# ${repo_name}

> Agent configuration for this repository.

## Agent Flow

### 1. Session Start (MANDATORY)

\`\`\`bash
# Sync submodules
git submodule update --remote .achords
git submodule update --remote .skills

# Load org context
mem_search(project: "${ORG_NAME}", query: "recent changes", limit: 3)

# Load repo context
mem_search(project: "${repo_name}", query: "last session", limit: 3)
\`\`\`

### 2. Mandatory Reads (before ANY work)

| File | Why |
|------|-----|
| \`.achords/AGENTS.md\` | Org rules + resource table |
| \`.skills/AGENTS.md\` | How to create/maintain skills |
| \`.engram/config.json\` | Project name: ${repo_name} |

### 3. On-Demand Reads (when needed)

| File | When to Read |
|------|--------------|
| \`.achords/config/conventions.json\` | Before writing code |
| \`.achords/config/policies.json\` | Before access decisions |
| \`.skills/skills/*/manifest.json\` | When loading a skill |
| \`.skills/skills/*/versions/*/SKILL.md\` | When using a skill |
| \`.internal/onboarding/\` | When setting up new repo |

### 4. During Work

\`\`\`bash
# After significant decision
mem_save(
  project: "${repo_name}",
  title: "Decision: use X",
  type: "decision",
  content: "We chose X because...",
  topic_key: "decisions/architecture"
)

# Before starting new task
mem_search(project: "${repo_name}", query: "similar task", limit: 5)
\`\`\`

### 5. Session End (ALWAYS)

\`\`\`bash
mem_session_summary(content: "## Goal\n...## Accomplished\n...")
\`\`\`

## Reading Order

1. \`.achords/AGENTS.md\` — Org rules (main entry point)
2. \`.engram/config.json\` — Repo project name
3. This file — Repo-specific rules
4. On-demand files as needed

## Skills (Versioned)

Skills are versioned in \`.skills/\` with manifest tracking:

\`\`\`bash
# Load skill manifest
cat .skills/skills/testing/manifest.json

# Load specific version
cat .skills/skills/testing/versions/v1.1.0/SKILL.md

# Load latest
cat .skills/skills/testing/SKILL.md
\`\`\`

### Each Version is a Directory

Versions are directories, not files:
\`\`\`
versions/
├── v1.1.0/
│   ├── SKILL.md        # Main instructions
│   └── scripts/        # Helper scripts (optional)
└── v1.1.0-windows/
    ├── SKILL.md
    └── scripts/
\`\`\`

### Fork/Variants

Skills can have platform-specific forks:
- \`v1.1.0/\` — Standard version
- \`v1.1.0-ubuntu/\` — Ubuntu fork (apt dependencies)
- \`v1.1.0-windows/\` — Windows fork (winget)

### OS Tagging

Skills use granular OS tags with hierarchy:

\`\`\`json
{
  "os": "ubuntu",
  "versions": ["22.04", "24.04"],
  "family": "debian"
}
\`\`\`

**Agent Loading Priority**:
1. Exact match (ubuntu-24.04)
2. Family match (ubuntu)
3. Parent match (debian)
4. Generic match (linux)

Check \`manifest.json\` for available versions and platforms.

## Repository-Specific Rules

Add your repo-specific rules here.

## SDD Integration

When running SDD phases:

1. Update \`.achords\` submodule before \`sdd-apply\` or \`sdd-verify\`
2. Check skill versions in \`.skills/skills/\`
3. If you modified a skill, commit new version

## Modification Rules

- **Don't modify** \`.achords/\` directly
- **Do modify** current repo files
- **Do create** shared skills in \`.skills/skills/\`
EOF
    git add AGENTS.md 2>/dev/null || true
  fi
  
  # Add .engram to .gitignore if not already there
  if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Engram local database
.engram/engram.db

# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Node modules (if any)
node_modules/

# Environment files
.env
.env.local
EOF
    git add .gitignore 2>/dev/null || true
  elif ! grep -q "\.engram/engram.db" ".gitignore" 2>/dev/null; then
    echo -e "\n# Engram local database\n.engram/engram.db" >> .gitignore
    git add .gitignore 2>/dev/null || true
  fi
  
  # Commit changes if any
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A 2>/dev/null || true
    git commit -m "feat: add agent memory configuration with .achords submodule" --quiet 2>/dev/null || true
  fi
  
  return 0
}

# ── summary ──────────────────────────────────────────────────────────
summary() {
  echo ""
  echo "  ╔═══════════════════════════════════════════╗"
  echo "  ║  ✓ Setup complete!                        ║"
  echo "  ╚═══════════════════════════════════════════╝"
  echo ""
  echo "  Your organization is ready:"
  echo ""
  echo "    ${WORK_DIR}/"
  echo "    ├── .github/     → Organization profile"
  echo "    ├── .achords/    → Agent orchestration rules & shared memory"
  echo "    │   └── .engram/ → Org-level memory (git-synced)"
  echo "    ├── .internal/   → Team docs & onboarding"
  echo "    └── .skills/     → Shared skills library"
  echo ""
  echo "  Existing repos have been injected with:"
  echo "    • AGENTS.md with achords resource table"
  echo "    • .engram/config.json with project context"
  echo "    • .achords submodule for org rules"
  echo "    • .skills submodule for shared skills"
  echo ""
  if [ "$AUTO_PUSH" = true ]; then
    echo "  ✓ All changes pushed to remote"
  else
    echo "  Changes are committed locally. To push all repos:"
    echo "    achords obase --org ${ORG_NAME} --update-headers --push"
  fi
  echo ""
  echo "  For NEW repositories created later:"
  echo "    achords obase --repo <repo-name>"
  echo ""
  echo "  Next steps:"
  echo "    1. Edit ${WORK_DIR}/.github/profile/README.md"
  echo "    2. Add team members to ${WORK_DIR}/.internal/"
  echo "    3. Start adding skills to ${WORK_DIR}/.skills/"
  echo ""
}

# ── update AGENTS.md headers in all repos ──────────────────────────
update_all_agents_headers() {
  header "Updating AGENTS.md headers in all repositories"
  
  local achords_version
  achords_version=$(get_version)
  
  # Get all repos in the org
  local repos
  repos=$(gh repo list "$ORG_NAME" --json name --jq '.[].name' 2>/dev/null)
  
  if [ -z "$repos" ]; then
    warn "No repositories found in ${ORG_NAME}"
    return 0
  fi
  
  local count=0
  local updated=0
  local created=0
  
  for repo in $repos; do
    # Skip special repos
    if [[ "$repo" == ".github" || "$repo" == ".achords" || "$repo" == ".skills" || "$repo" == ".internal" ]]; then
      continue
    fi
    
    count=$((count + 1))
    local repo_dir="${WORK_DIR}/${repo}"
    
    # Clone if not exists
    if [ ! -d "$repo_dir" ]; then
      info "Cloning ${repo}..."
      git clone "https://github.com/${ORG_NAME}/${repo}.git" "$repo_dir" --quiet 2>/dev/null || {
        warn "Could not clone ${repo}, skipping"
        continue
      }
    fi
    
    cd "$repo_dir"
    
    # Check if AGENTS.md exists
    if [ -f "AGENTS.md" ]; then
      # Check if header exists and version matches
      if grep -q "<!-- achords:header:v${achords_version} -->" AGENTS.md; then
        ok "${repo}: header up to date (v${achords_version})"
        continue
      fi
      
      # Update header - replace everything before first # heading
      info "${repo}: updating header to v${achords_version}..."
      
      # Extract repo-specific content (after first # heading)
      local repo_content
      repo_content=$(awk '/^# /{found=1} found' AGENTS.md)
      
      # Generate new header
      cat > AGENTS.md << EOF
<!-- achords:header:v${achords_version} -->
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
<!-- achords:resources -->
| Resource | Path | Purpose |
|----------|------|---------|
| Org Rules | \`.achords/AGENTS.md\` | Organization-wide agent rules |
| Org Memory | \`.achords/.engram/\` | Shared knowledge (git-synced) |
| Conventions | \`.achords/config/conventions.json\` | Code conventions |
| Policies | \`.achords/config/policies.json\` | Org policies |
| Skills Rules | \`.skills/AGENTS.md\` | How to create/maintain skills |
| Skills | \`.skills/skills/\` | Shared skills (Agent Skills spec) |
| Onboarding | \`.internal/onboarding/\` | Setup scripts and docs |
| Repo Memory | \`.engram/\` | Isolated repo memory |
| Repo Config | \`.engram/config.json\` | project_name setting |
<!-- achords:end -->

${repo_content}
EOF
      
      updated=$((updated + 1))
      ok "${repo}: header updated to v${achords_version}"
    else
      # Create new AGENTS.md with minimal header
      info "${repo}: creating AGENTS.md..."
      
      cat > AGENTS.md << EOF
<!-- achords:header:v${achords_version} -->
<!-- achords:tags: { "product": "obase", "domain": "coordination", "type": "reference", "status": "stable", "audience": "agent" } -->
<!-- achords:resources -->
| Resource | Path | Purpose |
|----------|------|---------|
| Org Rules | \`.achords/AGENTS.md\` | Organization-wide agent rules |
| Org Memory | \`.achords/.engram/\` | Shared knowledge (git-synced) |
| Conventions | \`.achords/config/conventions.json\` | Code conventions |
| Policies | \`.achords/config/policies.json\` | Org policies |
| Skills Rules | \`.skills/AGENTS.md\` | How to create/maintain skills |
| Skills | \`.skills/skills/\` | Shared skills (Agent Skills spec) |
| Onboarding | \`.internal/onboarding/\` | Setup scripts and docs |
| Repo Memory | \`.engram/\` | Isolated repo memory |
| Repo Config | \`.engram/config.json\` | project_name setting |
<!-- achords:end -->

# ${repo}

> Agent configuration for this repository.

## Reading Order

1. \`.achords/AGENTS.md\` — Org rules (main entry point)
2. \`.skills/AGENTS.md\` — Skills rules
3. \`.engram/config.json\` — Repo project name
4. This file — Repo-specific rules

## Organization Rules

Read \`.achords/AGENTS.md\` for organization-wide agent rules.

## Repository-Specific Rules

Add your repo-specific rules here.
EOF
      
      created=$((created + 1))
      ok "${repo}: AGENTS.md created"
    fi
    
    # Add .achords submodule if not present
    if [ ! -d ".achords" ]; then
      info "${repo}: adding .achords submodule..."
      git submodule add "https://github.com/${ORG_NAME}/.achords.git" .achords 2>/dev/null || true
    fi
    
    # Add .skills submodule if not present
    if [ ! -d ".skills" ]; then
      info "${repo}: adding .skills submodule..."
      git submodule add "https://github.com/${ORG_NAME}/.skills.git" .skills 2>/dev/null || true
    fi
    
    # Create .engram if not present
    if [ ! -d ".engram" ]; then
      mkdir -p .engram
      cat > .engram/config.json << EOF
{
  "project_name": "${repo}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "achords_version": "${achords_version}"
}
EOF
    fi
    
    # Commit changes if any
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      info "${repo}: committing injected configuration..."
      git add -A 2>/dev/null || true
      git commit -m "chore: inject achords agent configuration (AGENTS.md, .engram, submodules)" --quiet 2>/dev/null || true
    fi
    
    # Push if --push flag is set
    if [ "$AUTO_PUSH" = true ]; then
      if git push --quiet 2>/dev/null; then
        ok "${repo}: pushed to remote"
      else
        warn "${repo}: push failed"
      fi
    fi
    
    cd "$WORK_DIR"
  done
  
  echo ""
  # Summary (updated to show push hint if not auto-pushed)
  header "Summary"
  echo "  • Repos scanned: ${count}"
  echo "  • Headers updated: ${updated}"
  echo "  • Headers created: ${created}"
  echo ""
  if [ "$AUTO_PUSH" = false ] && [ "$count" -gt 0 ]; then
    echo "  To commit and push changes in each repo:"
    echo "    achords obase --org ${ORG_NAME} --update-headers --push"
    echo ""
  fi
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  parse_args "$@"
  
  # Skip banner if sourced by parent
  if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
  fi
  
  # Validate org name early if provided
  if [ -n "$ORG_NAME" ]; then
    if ! validate_name "$ORG_NAME" "organization"; then
      exit 1
    fi
  fi
  
  # Set WORK_DIR based on ORG_NAME if not overridden
  if [ "$DIR_OVERRIDE" = false ] && [ -n "$ORG_NAME" ]; then
    WORK_DIR="${HOME}/achords/${ORG_NAME}"
  elif [ -z "$WORK_DIR" ]; then
    WORK_DIR="${HOME}/achords"
  fi
  
  echo "$BANNER"
  echo ""
  
  # Handle --repo mode
  if [ -n "$REPO_NAME" ]; then
    # Validate repo name early
    if ! validate_name "$REPO_NAME" "repository"; then
      exit 1
    fi
    
    # Load .env to get ORG_NAME
    load_env
    
    # Validate we have an org name
    if [ -z "$ORG_NAME" ]; then
      err "No organization name found."
      echo "  Run: achords obase --org <name> --repo <repo-name>"
      exit 1
    fi
    
    # Check if repo directory exists
    local repo_dir="${WORK_DIR}/${REPO_NAME}"
    if [ ! -d "$repo_dir" ]; then
      err "Repository directory not found: ${repo_dir}"
      echo "  Clone the repository first, then run:"
      echo "    achords obase --repo ${REPO_NAME}"
      exit 1
    fi
    
    header "Setting up agent memory for ${REPO_NAME}"
    setup_repo_memory "$repo_dir" "$REPO_NAME"
    ok "Repository ${REPO_NAME} configured for agent memory"
    echo ""
    echo "  Next steps:"
    echo "    1. Commit the changes to ${REPO_NAME}"
    echo "    2. Start your agent in the repository"
    echo "    3. Agent will load org knowledge from .achords/.engram/"
    echo ""
    return
  fi
  
  # Handle --update-profile mode
  if [ "$UPDATE_PROFILE" = true ]; then
    # Load .env to get ORG_NAME
    load_env
    
    # Validate we have an org name
    if [ -z "$ORG_NAME" ]; then
      err "No organization name found."
      echo "  Run: achords obase --org <name> --update-profile"
      exit 1
    fi
    
    check_deps
    check_auth
    update_profile
    return
  fi
  
  # Handle --update-headers mode
  if [ "$UPDATE_HEADERS" = true ]; then
    load_env
    
    if [ -z "$ORG_NAME" ]; then
      err "No organization name found."
      echo "  Run: achords obase --org <name> --update-headers"
      exit 1
    fi
    
    check_deps
    check_auth
    update_all_agents_headers
    return
  fi
  
  # Full setup mode
  # Setup .env
  setup_env
  
  # Run checks and setup
  check_deps
  check_auth
  check_org
  check_local
  create_repos
  clone_repos
  init_achords_repo || warn ".achords init skipped — continuing with repo injection"
  generate_files
  import_skills
  update_all_agents_headers
  summary
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
