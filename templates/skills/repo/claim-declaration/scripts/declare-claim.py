#!/usr/bin/env python3
"""Declare an Achords claim in .achords/claims.json."""

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def parse_paths(raw_paths: list[str]) -> list[str]:
    paths: list[str] = []
    for value in raw_paths:
        for item in value.split(','):
            item = item.strip()
            if item:
                paths.append(item)
    return paths


def declare_claim() -> int:
    parser = argparse.ArgumentParser(description="Declare an Achords claim")
    parser.add_argument("--repo", default=".", help="Repository root containing .achords")
    parser.add_argument("--agent-id", required=False)
    parser.add_argument("--paths", nargs="*", default=[])
    parser.add_argument("--purpose")
    parser.add_argument("--mode", choices=["exclusive", "advisory"], default="exclusive")
    parser.add_argument("--ttl-minutes", type=int, default=240)
    args = parser.parse_args()

    achords_dir = Path(args.repo) / '.achords'
    claims_file = achords_dir / 'claims.json'
    events_file = achords_dir / 'events.ndjson'

    if not claims_file.exists():
        print("✗ .achords/claims.json not found")
        return 1

    with open(claims_file) as f:
        claims_data = json.load(f)

    agent_id = args.agent_id or input("Agent ID: ").strip()
    if not agent_id:
        print("✗ agent_id is required")
        return 1

    paths = parse_paths(args.paths)
    if not paths:
        raw_paths = input("Paths to claim (comma-separated globs): ").strip()
        paths = parse_paths([raw_paths])
    if not paths:
        print("✗ at least one path is required")
        return 1

    purpose = args.purpose or input("Purpose: ").strip()
    if not purpose:
        print("✗ purpose is required")
        return 1

    claim_id = f"claim-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"
    claim = {
        'id': claim_id,
        'agent_id': agent_id,
        'paths': paths,
        'purpose': purpose,
        'mode': args.mode,
        'ttl_minutes': args.ttl_minutes,
        'status': 'active',
        'created_at': datetime.now(timezone.utc).isoformat(),
        'released_at': None,
    }

    claims_data.setdefault('claims', []).append(claim)
    claims_data['last_updated'] = datetime.now(timezone.utc).isoformat()

    with open(claims_file, 'w') as f:
        json.dump(claims_data, f, indent=2)

    event = {
        'type': 'claim-created',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'claim_id': claim_id,
        'agent_id': agent_id,
    }
    with open(events_file, 'a') as f:
        json.dump(event, f)
        f.write('\n')

    print(f"✓ Claim created: {claim_id}")
    print(f"✓ Agent: {agent_id}")
    print(f"✓ Paths: {', '.join(paths)}")
    print(f"✓ Mode: {args.mode}")
    print(f"✓ TTL: {args.ttl_minutes} minutes")
    return 0


if __name__ == '__main__':
    raise SystemExit(declare_claim())