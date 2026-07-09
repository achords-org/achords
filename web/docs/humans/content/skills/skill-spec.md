---
title: Especificación de Skills
description: Skills siguen el Agent Skills spec
tags: [skills, reference, stable, agent]
---

# Especificación de Skills

Skills siguen el [Agent Skills spec](https://agentskills.io/specification).

## Estructura de SKILL.md

```yaml
---
name: my-skill
description: Qué hace este skill
triggers:
  - cuándo usar este skill
---

# Skill Name

## Instructions

Guía paso a paso para el agente.

## Resources

- [Link](url) — Descripción
```

## Campos requeridos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `name` | string | Identificador único |
| `description` | string | Qué hace el skill |

## Campos opcionales

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `triggers` | list | Cuándo usar este skill |
| `scope` | string | Patrones de archivo |
| `os` | object | Requisitos de plataforma |

## Estructura de directorio

```
skills/
└── {skill-name}/
    ├── manifest.json     # Metadatos de versión
    └── versions/
        └── v{version}/
            ├── SKILL.md   # Instrucciones
            ├── scripts/   # Helpers
            └── references/ # Datos
```

## Ver también

- [[skill-versioning]] — Versionado
- [[os-tagging]] — Tags de plataforma
- [[creating-skills]] — Cómo crear skills
