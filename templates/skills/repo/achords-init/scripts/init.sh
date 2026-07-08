#!/bin/bash
# achords-init.sh - Bootstrap Achords protocol in a repository
# Usage: bash init.sh [templates-dir]

set -e

echo "=== Achords Init ==="

# Check if .achords already exists
if [ -d .achords ]; then
    echo "✗ .achords/ already exists"
    echo "  Use agent-union skill to register agents"
    exit 1
fi

# Determine templates directory
if [ -n "$1" ]; then
    TEMPLATES_DIR="$1"
else
    # Try to find templates relative to script location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Check if we're in the repo's templates/skills/repo/achords-init/scripts/
    if [ -d "$SCRIPT_DIR/../../../../schemas" ]; then
        TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
    # Check if templates dir is passed as argument
    elif [ -d "$SCRIPT_DIR/templates" ]; then
        TEMPLATES_DIR="$SCRIPT_DIR/templates"
    else
        echo "⚠ Could not find templates directory"
        echo "  Usage: bash init.sh /path/to/achords/templates"
        TEMPLATES_DIR=""
    fi
fi

echo "✓ Creating .achords/ directory structure..."
mkdir -p .achords/{agents,supervisor,schemas,skills}

echo "✓ Initializing protocol files..."

# version.json
cat > .achords/version.json << EOF
{
  "achords_version": "1.0.0",
  "spec_date": "2026-07-04",
  "repo_initialized": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "protocol_status": "active",
  "notes": "MVP baseline with Agent Skills integration"
}
EOF

# registry.json
cat > .achords/registry.json << EOF
{
  "agents": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "notes": "Agents are registered here via agent-union skill before making contributions"
}
EOF

# claims.json
cat > .achords/claims.json << EOF
{
  "claims": [],
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "notes": "Active, released, and expired claims tracked here"
}
EOF

# topology.json
cat > .achords/topology.json << EOF
{
  "collaboration_mode": "claim-based",
  "supervisor_enabled": true,
  "allow_parallel_exclusive": false,
  "require_claim_before_edit": true,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# policies.json
cat > .achords/policies.json << EOF
{
  "claim_ttl_default_minutes": 60,
  "claim_ttl_max_minutes": 10080,
  "require_supervisor_approval": false,
  "allow_advisory_claims": true,
  "auto_expire_released_claims": true,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# supervisor/state.json
cat > .achords/supervisor/state.json << EOF
{
  "mode": "advisory",
  "enabled": true,
  "last_alignment_check": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "alignment_status": "initialized",
  "pending_reviews": [],
  "blocked_merges": []
}
EOF

# events.ndjson
echo "{\"type\":\"bootstrap\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"message\":\"Achords protocol initialized\",\"version\":\"1.0.0\"}" > .achords/events.ndjson

echo "✓ Copying JSON schemas..."
if [ -n "$TEMPLATES_DIR" ] && [ -d "$TEMPLATES_DIR/schemas" ]; then
    cp "$TEMPLATES_DIR/schemas/"*.json .achords/schemas/
    echo "  Copied $(ls "$TEMPLATES_DIR/schemas/"*.json | wc -l) schemas"
else
    echo "  ⚠ Templates dir not found, skipping schemas"
fi

echo "✓ Copying core skills..."
if [ -n "$TEMPLATES_DIR" ] && [ -d "$TEMPLATES_DIR/skills/repo" ]; then
    cp -r "$TEMPLATES_DIR/skills/repo/"* .achords/skills/
    echo "  Copied $(ls -d "$TEMPLATES_DIR/skills/repo/"* | wc -l) skills"
else
    echo "  ⚠ Templates dir not found, skipping skills"
fi

echo ""
echo "✓ Achords initialization complete"
echo ""
echo "Files created:"
echo "  .achords/"
echo "  ├── version.json"
echo "  ├── registry.json"
echo "  ├── claims.json"
echo "  ├── topology.json"
echo "  ├── policies.json"
echo "  ├── events.ndjson"
echo "  ├── supervisor/state.json"
echo "  ├── schemas/ (4 files)"
echo "  └── skills/ (5 skills)"
echo ""
echo "Next steps:"
echo "  1. Register agents: python .achords/skills/agent-union/scripts/register-agent.py"
echo "  2. Declare claims: python .achords/skills/claim-declaration/scripts/declare-claim.py"
echo "  3. Commit: git add .achords/ && git commit -m 'feat: bootstrap Achords protocol'"
