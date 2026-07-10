---
title: Engram
description: Memoria persistente across sesiones via Engram
tags: [memory, reference, stable, both]
---

# Engram

Memoria persistente via [Engram](https://github.com/Gentleman-Programming/engram).

## Qué es Engram

Engram es un sistema de memoria en Go con:

- SQLite + FTS5 para búsqueda rápida
- Servidor MCP para integración con agentes
- API HTTP para acceso programático
- CLI y TUI para gestión

## Setup

Engram se configura automáticamente cuando ejecutas `achords obase`.

### Por org

```
.achords/.engram/    # Memoria compartida de org
```

### Por repo

```
.engram/             # Memoria específica del repo
```

## Configuración

### Org memory (`.achords/.engram/config.json`)

Creado por `obase init` dentro del `.achords` repo. Viaja a cada repo miembro via submodule.

```json
{
  "project_name": ".achords",
  "scope": "org",
  "org_name": "my-company",
  "created_at": "2026-07-09T20:00:00Z",
  "achords_version": "1.5.0",
  "description": "Shared org memory for my-company — conventions, decisions, patterns"
}
```

### Repo memory (`.engram/config.json`)

Creado por `achords obase --repo my-app` en cada repo miembro.

```json
{
  "project_name": "my-app",
  "scope": "repo",
  "org_level": "my-company",
  "created_at": "2026-07-09T20:00:00Z"
}
```

## APIs principales

| API | Propósito |
|-----|-----------|
| `mem_save` | Guardar una memoria |
| `mem_search` | Buscar memorias |
| `mem_context` | Obtener contexto reciente |
| `mem_session_summary` | Resumen de fin de sesión |

## Ver también

- [[memory-protocol]] — Protocolo de uso
- [[topic-keys]] — Claves de topic
