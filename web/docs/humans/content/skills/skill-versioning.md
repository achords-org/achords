---
title: Versionado
description: Skills se versionan por directorio
tags: [skills, reference, stable, agent]
---

# Versionado

Skills se versionan por directorio.

## Estructura

```
.skills/
└── skills/
    └── testing/
        ├── manifest.json
        └── versions/
            ├── v1.0.0/
            │   └── SKILL.md
            └── v1.1.0/
                └── SKILL.md
```

## manifest.json

```json
{
  "name": "testing",
  "description": "Testing patterns",
  "versions": {
    "v1.0.0": {
      "created": "2025-01-15",
      "platforms": ["linux", "windows"]
    },
    "v1.1.0": {
      "created": "2025-02-20",
      "platforms": ["linux"]
    }
  }
}
```

## Forks

Versiones específicas por plataforma son forks:

```
versions/
├── v1.0.0/          # Versión base
├── v1.1.0/          # Base actualizada
└── v1.1.0-windows/  # Fork de Windows
```

Manifest de fork:

```json
{
  "forked_from": "v1.1.0",
  "platform": "windows"
}
```

## Índice global

`version.json` en raíz del skill:

```json
{
  "version": "1.2.0",
  "skills": {
    "testing": {
      "latest": "v1.1.0",
      "platforms": ["linux"]
    }
  }
}
```

## Ver también

- [[os-tagging]] — Tags de plataforma
- [[skill-spec]] — Especificación
