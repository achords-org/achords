---
title: Flujo del Agente
description: Todo sigue este patrón de sesión
tags: [architecture, coordination, concept, stable, agent]
---

# Flujo del Agente

Toda sesión de agente sigue este flujo.

## Ciclo de vida

```
┌─────────────────────────────────────────┐
│ 1. Inicio de Sesión                     │
│    - Detectar proyecto de cwd           │
│    - Llamar mem_context                 │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 2. Lecturas Obligatorias                │
│    - Leer .achords/AGENTS.md            │
│    - Leer .skills/AGENTS.md             │
│    - Leer .engram/config.json           │
│    - Leer .achords/.engram/config.json  │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 3. Sincronización de Memoria            │
│    - Buscar contexto previo             │
│    - Cargar memorias relevantes         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 4. Trabajo                              │
│    - Leer skills on-demand              │
│    - Tomar decisiones                   │
│    - Guardar en memoria                 │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 5. Fin de Sesión                        │
│    - Llamar mem_session_summary         │
│    - Persistir contexto importante      │
└─────────────────────────────────────────┘
```

## Lecturas obligatorias

Estos archivos DEBEN leerse al inicio:

| Archivo | Propósito |
|---------|-----------|
| `.achords/AGENTS.md` | Reglas de org |
| `.skills/AGENTS.md` | Documentación de skills |
| `.engram/config.json` | Configuración de memoria de repo |
| `.achords/.engram/config.json` | Configuración de memoria de org |

## Lecturas on-demand

Se leen según necesidad:

| Archivo | Cuándo |
|---------|--------|
| `conventions.json` | Antes de escribir código |
| `policies.json` | Antes de decisiones de política |
| Manifests de skills | Antes de usar un skill |
| Versiones de skills | Antes de ejecutar un skill |

## Operaciones de memoria

| Operación | Cuándo |
|-----------|--------|
| `mem_context` | Inicio de sesión |
| `mem_search` | Buscando trabajo previo |
| `mem_save` | Después de decisiones/fixes |
| `mem_session_summary` | Fin de sesión |

## Ver también

- [[memory-protocol]] — Protocolo detallado
- [[repo-integration]] — Cómo se conectan los repos
