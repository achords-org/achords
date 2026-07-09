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

`.engram/config.json`:

```json
{
  "project": "my-app",
  "memory_backend": "sqlite",
  "auto_save": true
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
