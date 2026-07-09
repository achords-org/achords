---
title: Protocolo de Memoria
description: Cuándo guardar, buscar y resumir
tags: [memory, reference, stable, agent]
---

# Protocolo de Memoria

Cuándo guardar, buscar y resumir.

## Ciclo de vida de sesión

```
Inicio de sesión
    ↓
mem_context (recuperar contexto previo)
    ↓
Trabajar...
    ↓
mem_save (después de decisiones/fixes)
    ↓
mem_session_summary (antes de cerrar)
```

## Cuándo guardar

Llamar `mem_save` inmediatamente después de:

- Decisión de arquitectura
- Fix de bug
- Descubrimiento no obvio
- Cambio de configuración
- Patrón establecido

## Formato

```json
{
  "title": "Título corto y buscable",
  "type": "decision|bugfix|discovery|pattern|config",
  "content": {
    "What": "Qué se hizo",
    "Why": "Qué lo motivó",
    "Where": "Archivos afectados",
    "Learned": "Gotchas y edge cases"
  }
}
```

## Cuándo buscar

- Antes de empezar trabajo (verificar si ya se hizo)
- Cuando el usuario referencia trabajo previo
- Cuando encontrás un patrón familiar

## Flujo de búsqueda

1. `mem_context` — Historial de sesiones recientes
2. `mem_search` — Búsqueda full-text
3. `mem_get_observation` — Contenido completo

## Ver también

- [[engram]] — Integración con Engram
- [[topic-keys]] — Claves de topic
