# Achords — For Humans

> Developer setup and usage guide.

## Quick Start

```bash
# Install
npm install -g achords

# Setup organization
achords obase --org MyOrg

# Configure existing repo
achords obase --repo my-repo
```

## What You Get

After running `achords obase`:

```
your-repo/
├── .achords/          # Org rules (submodule)
├── .engram/           # Repo memory
│   └── config.json    # project_name: "your-repo"
├── AGENTS.md          # Agent entry point
└── src/
```

## Commands

```bash
achords version              # Check version
achords update               # Update to latest
achords obase --org <name>   # Setup org
achords obase --repo <name>  # Configure repo
achords obase --update-profile  # Update org profile
```

## How It Works

1. **obase** sets up your GitHub org for multi-agent collaboration
2. Each repo gets `.achords/` as a submodule (org rules)
3. Each repo gets `.engram/` for isolated memory
4. AI agents read `AGENTS.md` to understand the setup

## Updating Org Rules

```bash
# In .achords/ repo
# Edit files, commit, push

# In each repo
git submodule update --remote
```

## Troubleshooting

**Agent not reading .achords:**
```bash
git submodule update --init --recursive
```

**Memory not persisting:**
```bash
engram doctor
```

## More

- [Agent Documentation](/docs/agents/) — How agents integrate
- [GitHub](https://github.com/cxto21/achords) — Source code
