#!/usr/bin/env python3
"""
agent-union: Register a new agent in the Achords protocol.
"""

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


def validate_agent_id(agent_id: str) -> bool:
    """Validate agent_id format."""
    pattern = r'^[a-z0-9-]+$'
    if not re.match(pattern, agent_id):
        print(f"✗ Invalid agent_id format: {agent_id}")
        print(f"  Must match pattern: {pattern}")
        return False
    if len(agent_id) < 1 or len(agent_id) > 255:
        print(f"✗ agent_id must be 1-255 characters")
        return False
    return True


def prompt_or_value(prompt_text: str, value: str | None, default: str | None = None) -> str:
    if value:
        return value
    prompt_suffix = f" [{default}]" if default else ""
    response = input(f"{prompt_text}{prompt_suffix}: ").strip()
    if response:
        return response
    if default is not None:
        return default
    return ""


def register_agent() -> int:
    parser = argparse.ArgumentParser(description="Register a new agent in Achords")
    parser.add_argument("--repo", default=".", help="Repository root containing .achords")
    parser.add_argument("--agent-id", dest="agent_id")
    parser.add_argument("--name")
    parser.add_argument("--agent-type", dest="agent_type", choices=["ai", "human", "service"])
    args = parser.parse_args()

    achords_dir = Path(args.repo) / '.achords'
    if not achords_dir.exists():
        print("✗ .achords/ directory not found")
        print("  Run achords-init skill first")
        return 1
    
    registry_file = achords_dir / 'registry.json'
    if not registry_file.exists():
        print("✗ .achords/registry.json not found")
        return 1
    
    with open(registry_file) as f:
        registry_data = json.load(f)
    
    agents = registry_data.get('agents', [])
    existing_ids = {agent['agent_id'] for agent in agents}
    
    print("\n=== Agent Union Registration ===\n")
    
    while True:
        agent_id = prompt_or_value("Agent ID [e.g., agent-a-001]", args.agent_id)
        if not agent_id:
            print("✗ agent_id is required")
            continue
        if not validate_agent_id(agent_id):
            continue
        if agent_id in existing_ids:
            print(f"✗ agent_id '{agent_id}' already registered")
            continue
        break
    
    while True:
        name = prompt_or_value("Agent name", args.name)
        if not name:
            print("✗ name is required")
            continue
        break
    
    valid_types = ['ai', 'human', 'service']
    while True:
        agent_type = prompt_or_value("Agent type (ai/human/service)", args.agent_type, "ai").lower()
        if agent_type in valid_types:
            break
        print(f"✗ Invalid type. Choose from: {', '.join(valid_types)}")
    
    # Create agent entry
    agent_entry = {
        'agent_id': agent_id,
        'name': name,
        'agent_type': agent_type,
        'status': 'active',
        'registered_at': datetime.now(timezone.utc).isoformat(),
        'metadata': {}
    }
    
    # Create agent state directory
    agent_dir = achords_dir / 'agents' / agent_id
    agent_dir.mkdir(parents=True, exist_ok=True)
    
    # Create agent state.json
    agent_state = {
        'agent_id': agent_id,
        'has_messages': 0,
        'last_activity': datetime.now(timezone.utc).isoformat(),
        'active_claims': [],
        'metadata': {}
    }
    
    with open(agent_dir / 'state.json', 'w') as f:
        json.dump(agent_state, f, indent=2)
    
    # Create inbox directory
    (agent_dir / 'inbox').mkdir(exist_ok=True)
    
    # Update registry
    agents.append(agent_entry)
    registry_data['agents'] = agents
    registry_data['last_updated'] = datetime.now(timezone.utc).isoformat()
    
    with open(registry_file, 'w') as f:
        json.dump(registry_data, f, indent=2)
    
    # Log event
    events_file = achords_dir / 'events.ndjson'
    event = {
        'type': 'agent-union',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'agent_id': agent_id,
        'status': 'success'
    }
    
    with open(events_file, 'a') as f:
        json.dump(event, f)
        f.write('\n')
    
    # Print results
    print(f"\n✓ Agent registered")
    print(f"✓ agent_id: {agent_id}")
    print(f"✓ name: {name}")
    print(f"✓ type: {agent_type}")
    print(f"✓ status: active")
    print(f"✓ Registry updated: .achords/registry.json")
    print(f"✓ State created: .achords/agents/{agent_id}/state.json")
    print(f"✓ Event logged: events.ndjson")
    print(f"\nNext steps:")
    print(f"1. git add .achords/")
    print(f"2. git commit -m 'feat: register {agent_id} via agent-union'")
    print(f"3. Read .achords/skills/claim-declaration/SKILL.md")
    return 0


if __name__ == '__main__':
    raise SystemExit(register_agent())
