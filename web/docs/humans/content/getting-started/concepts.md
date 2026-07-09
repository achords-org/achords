---
title: Conceptos
description: Modelo mental core de Achords
tags: [getting-started, concept, stable, both]
---

# Conceptos

Modelo mental core de Achords.

## Organizaciones

Una organización es el contenedor principal. Contiene:

- Reglas de agentes (`.achords/`)
- Skills (`.skills/`)
- Onboarding de devs (`.internal/`)
- Perfil de GitHub (`.github/`)

Cada org tiene su propio subdirectorio: `~/achords/{org-name}/`

## Repos

Repos son proyectos individuales. Importan reglas de la org via git submodules:

```
my-repo/
├── .achords → ../.achords/ (submodule)
├── .skills  → ../.skills/  (submodule)
├── .engram/  (memoria del repo)
└── AGENTS.md (instrucciones de agente)
```

## Skills

Skills son capacidades reutilizables para agentes. Siguen el [Agent Skills spec](https://agentskills.io/specification).

Cada skill tiene:
- `SKILL.md` — Instrucciones y recursos
- `scripts/` — Helpers ejecutables
- `references/` — Datos estáticos

Skills se versionan por directorio:

```
.skills/
└── skills/
    └── testing/
        ├── v1.0.0/
        │   └── SKILL.md
        └── v1.1.0/
            └── SKILL.md
```

## Memoria

La memoria es manejada por [Engram](https://github.com/Gentleman-Programming/engram). Provee:

- **Memoria de org** — Compartida across todos los repos (`.achords/.engram/`)
- **Memoria de repo** — Específica de cada repo (`.engram/`)

La memoria persiste across sesiones. Los agentes pueden buscar, guardar y actualizar contexto.

## Flujo del Agente

Toda sesión de agente sigue este flujo:

```
Sesión start
    ↓
Leer .achords/AGENTS.md (obligatorio)
    ↓
Leer .skills/AGENTS.md (obligatorio)
    ↓
Sincronizar memoria (mem_context)
    ↓
Trabajar (leer on-demand)
    ↓
Sesión end (mem_session_summary)
```

## Ver también

- [[org-structure]] — Qué vive dónde
- [[memory-isolation]] — Cómo se aisla la memoria
- [[skill-spec]] — Especificación de skills
