---
title: Crear Skills
description: Guía paso a paso para crear nuevos skills
tags: [skills, guide, stable, human]
---

# Crear Skills

Guía paso a paso para crear nuevos skills.

## 1. Crear directorio

```bash
mkdir -p .skills/skills/my-skill/versions/v1.0.0
```

## 2. Crear SKILL.md

```yaml
---
name: my-skill
description: Qué hace este skill
triggers:
  - cuándo usar este skill
scope:
  - "**/*.ts"
  - "**/*.js"
---

# My Skill

## Instructions

1. Paso uno
2. Paso dos
3. Paso tres

## Resources

- [Link](url) — Descripción
```

## 3. Crear manifest.json

```json
{
  "name": "my-skill",
  "description": "Qué hace este skill",
  "versions": {
    "v1.0.0": {
      "created": "2025-03-01",
      "platforms": ["linux"]
    }
  }
}
```

## 4. Agregar scripts (opcional)

```bash
mkdir -p .skills/skills/my-skill/versions/v1.0.0/scripts
```

## 5. Agregar references (opcional)

```bash
mkdir -p .skills/skills/my-skill/versions/v1.0.0/scripts/references
```

## 6. Actualizar índice global

Agregar a `version.json`:

```json
{
  "skills": {
    "my-skill": {
      "latest": "v1.0.0",
      "platforms": ["linux"]
    }
  }
}
```

## Mejores prácticas

- Mantener SKILL.md conciso
- Usar triggers claros
- Incluir ejemplos
- Probar con agentes

## Ver también

- [[skill-spec]] — Especificación
- [[skill-versioning]] — Versionado
