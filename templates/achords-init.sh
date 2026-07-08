#!/usr/bin/env bash
# Achords — Repository Initialization
# Bootstraps the Achords protocol in a repository.
#
# Usage:
#   bash templates/achords-init.sh
#
# What it does:
#   1. Creates .achords/ directory structure
#   2. Copies protocol files from templates/
#   3. Sets up CI workflows

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

echo "Initializing Achords protocol..."

# Create .achords directory
mkdir -p .achords/agents .achords/supervisor .achords/skills

# Copy schemas
cp "${TEMPLATES_DIR}/schemas/"* .achords/schemas/ 2>/dev/null || true

# Copy skills
cp -r "${TEMPLATES_DIR}/skills/repo/"* .achords/skills/ 2>/dev/null || true

# Copy workflows
mkdir -p .github/workflows
cp "${TEMPLATES_DIR}/workflows/"* .github/workflows/ 2>/dev/null || true

# Create baseline files
cat > .achords/version.json << 'EOF'
{
  "protocol_version": "1.0.0",
  "initialized_at": "TIMESTAMP",
  "status": "active"
}
EOF

cat > .achords/registry.json << 'EOF'
{
  "agents": []
}
EOF

cat > .achords/claims.json << 'EOF'
{
  "claims": []
}
EOF

cat > .achords/topology.json << 'EOF'
{
  "collaboration_model": "async",
  "supervisor_enabled": true
}
EOF

cat > .achords/policies.json << 'EOF'
{
  "claim_requirement": {
    "enabled": true,
    "mode": "mandatory"
  },
  "exclusive_claim_overlap": {
    "enabled": true,
    "mode": "blocking"
  },
  "policy_enforcement_level": "advisory"
}
EOF

cat > .achords/events.ndjson << 'EOF'
{"type":"bootstrap","timestamp":"TIMESTAMP","message":"Achords initialized"}
EOF

cat > .achords/supervisor/state.json << 'EOF'
{
  "mode": "advisory",
  "enabled": true,
  "last_check": null
}
EOF

echo "Achords initialized."
echo ""
echo "Next steps:"
echo "  1. Review .achords/policies.json"
echo "  2. Run agent-union to register agents"
echo "  3. Open a PR to trigger CI validation"
