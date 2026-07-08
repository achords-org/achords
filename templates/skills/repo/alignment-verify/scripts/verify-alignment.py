#!/usr/bin/env python3
"""Validate Achords protocol state for CI and local smoke tests."""

import argparse
import fnmatch
import json
from datetime import datetime, timezone
from pathlib import Path


def load_json(path: Path):
    with path.open() as f:
        return json.load(f)


def path_overlaps(pattern_a: str, pattern_b: str, files: list[str]) -> bool:
    if pattern_a == pattern_b:
        return True
    for candidate in files:
        if fnmatch.fnmatch(candidate, pattern_a) and fnmatch.fnmatch(candidate, pattern_b):
            return True
    return False


def verify_alignment() -> int:
    parser = argparse.ArgumentParser(description="Verify Achords alignment")
    parser.add_argument("--repo", default=".", help="Repository root")
    args = parser.parse_args()

    repo = Path(args.repo)
    achords = repo / '.achords'
    required_files = [
        achords / 'ACHORDS.md',
        achords / 'version.json',
        achords / 'registry.json',
        achords / 'claims.json',
        achords / 'topology.json',
        achords / 'policies.json',
        achords / 'events.ndjson',
        achords / 'supervisor/state.json',
        achords / 'schemas/agent-profile.schema.json',
        achords / 'schemas/agent-state.schema.json',
        achords / 'schemas/claim.schema.json',
        achords / 'schemas/message.schema.json',
    ]

    missing = [str(path) for path in required_files if not path.exists()]
    if missing:
        print("✗ Missing required files:")
        for path in missing:
            print(f"  - {path}")
        return 1

    json_files = [
        achords / 'version.json',
        achords / 'registry.json',
        achords / 'claims.json',
        achords / 'topology.json',
        achords / 'policies.json',
        achords / 'supervisor/state.json',
        achords / 'schemas/agent-profile.schema.json',
        achords / 'schemas/agent-state.schema.json',
        achords / 'schemas/claim.schema.json',
        achords / 'schemas/message.schema.json',
    ]
    for path in json_files:
        try:
            load_json(path)
        except Exception as exc:
            print(f"✗ Invalid JSON: {path} -> {exc}")
            return 1

    events_file = achords / 'events.ndjson'
    for line in events_file.read_text().splitlines():
        if not line.strip():
            continue
        try:
            json.loads(line)
        except Exception as exc:
            print(f"✗ Invalid NDJSON line: {line} -> {exc}")
            return 1

    supervisor_state = load_json(achords / 'supervisor/state.json')
    reviewer_id = supervisor_state.get('reviewer_id')
    reviewer_role = supervisor_state.get('reviewer_role')
    if not reviewer_id or not reviewer_role:
        print("✗ Supervisor reviewer identity is not explicit")
        return 1

    claims_data = load_json(achords / 'claims.json')
    claims = claims_data.get('claims', [])
    active_exclusive = [claim for claim in claims if claim.get('status') == 'active' and claim.get('mode') == 'exclusive']
    repo_files = [str(path.relative_to(repo)).replace('\\', '/') for path in repo.rglob('*') if path.is_file()]
    collisions = []
    for index, claim_a in enumerate(active_exclusive):
        for claim_b in active_exclusive[index + 1:]:
            if claim_a.get('agent_id') == claim_b.get('agent_id'):
                continue
            for path_a in claim_a.get('paths', []):
                for path_b in claim_b.get('paths', []):
                    if path_overlaps(path_a, path_b, repo_files):
                        collisions.append((claim_a.get('id'), claim_b.get('id'), path_a, path_b))
                        break

    if collisions:
        print("✗ Blocking claim collision detected")
        for claim_a, claim_b, path_a, path_b in collisions:
            print(f"  - {claim_a} vs {claim_b}: {path_a} / {path_b}")
        return 4

    supervisor_state['last_alignment_check'] = datetime.now(timezone.utc).isoformat()
    supervisor_state['alignment_status'] = 'passed'
    (achords / 'supervisor/state.json').write_text(json.dumps(supervisor_state, indent=2) + '\n')

    print("✓ Alignment check passed")
    print(f"✓ Reviewer: {reviewer_role}:{reviewer_id}")
    print(f"✓ Active exclusive claims checked: {len(active_exclusive)}")
    return 0


if __name__ == '__main__':
    raise SystemExit(verify_alignment())