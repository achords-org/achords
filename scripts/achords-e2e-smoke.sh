#!/usr/bin/env bash
set -euo pipefail

source_repo="${1:-$PWD}"
temp_root="$(mktemp -d)"
temp_repo="$temp_root/achords-smoke"

cleanup() {
  rm -rf "$temp_root"
}
trap cleanup EXIT

rsync -a --exclude '.git' --exclude '__pycache__' "$source_repo/" "$temp_repo/"

echo "[1/4] Registering smoke agent"
python3 "$temp_repo/.achords/skills/agent-union/scripts/register-agent.py" \
  --repo "$temp_repo" \
  --agent-id smoke-agent-001 \
  --name "Smoke Agent" \
  --agent-type ai

echo "[2/4] Declaring smoke claim"
python3 "$temp_repo/.achords/skills/claim-declaration/scripts/declare-claim.py" \
  --repo "$temp_repo" \
  --agent-id smoke-agent-001 \
  --paths "src/**" "tests/**" \
  --purpose "smoke-test" \
  --mode exclusive \
  --ttl-minutes 30

echo "[3/4] Verifying alignment"
python3 "$temp_repo/.achords/skills/alignment-verify/scripts/verify-alignment.py" --repo "$temp_repo"

echo "[4/4] Verifying reviewer identity"
python3 - <<'PY' "$temp_repo"
import json, pathlib, sys
repo = pathlib.Path(sys.argv[1])
state = json.loads((repo / '.achords/supervisor/state.json').read_text())
assert state.get('reviewer_role') == 'supervisor'
assert state.get('reviewer_id') == 'achords-supervisor'
print('✓ Reviewer identity present')
PY

echo "✓ Achords smoke test passed"