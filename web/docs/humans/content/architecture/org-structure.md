---
title: Estructura de Organización
description: Qué vive dónde en una organización Achords
tags: [architecture, concept, stable, both]
---

# Estructura de Organización

Qué vive dónde en una organización Achords.

## Layout del directorio

```
~/achords/{org-name}/
├── .achords/           # Reglas de agentes
│   ├── AGENTS.md       # Reglas para todos
│   ├── .engram/        # Memoria compartida
│   ├── conventions.json
│   └── policies.json
├── .skills/            # Skills compartidos
│   ├── AGENTS.md       # Docs de skills
│   ├── version.json    # Índice global
│   └── skills/
│       ├── testing/
│       ├── code-review/
│       └── ...
├── .internal/          # Onboarding
│   ├── README.md
│   ├── AGENTS.md
│   └── scripts/
├── .github/            # Perfil org
│   └── profile/
│       └── README.md
└── repos/              # Tus proyectos
    ├── app-1/
    ├── app-2/
    └── ...
```

## .achords

La fuente de verdad para comportamiento de agentes. Contiene:

- `AGENTS.md` — Instrucciones para todos los agentes
- `.engram/` — Base de datos de memoria compartida
- `conventions.json` — Convenciones de código
- `policies.json` — Políticas organizacionales

## .skills

Skills versionados que los agentes pueden usar. Cada skill es un directorio:

```
.skills/
└── skills/
    └── {skill-name}/
        ├── manifest.json
        └── versions/
            ├── v1.0.0/
            │   └── SKILL.md
            └── v1.1.0/
                └── SKILL.md
```

## .internal

Onboarding de desarrolladores y docs internas. Privado por defecto.

## .github

Perfil de org y config específica de GitHub. Público.

## Ver también

- [[repo-integration]] — Cómo se conectan los repos
- [[memory-isolation]] — Cómo se aisla la memoria
