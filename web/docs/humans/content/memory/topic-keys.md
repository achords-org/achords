---
title: Topic Keys
description: Organizar memorias por topic
tags: [memory, reference, stable, agent]
---

# Topic Keys

Organizar memorias por topic.

## Qué son topic keys

Topic keys agrupan memorias relacionadas. Permiten:

- Upserting (actualizar mismo topic)
- Búsqueda acotada
- Recuperación organizada

## Formato

```
{category}/{topic}
```

Ejemplos:

- `architecture/auth-model`
- `bugfix/n-plus-one-query`
- `config/engram-setup`

## Uso

### Guardar con topic

```json
{
  "title": "JWT auth middleware",
  "topic_key": "architecture/auth-model",
  "type": "architecture",
  "content": { ... }
}
```

### Actualizar mismo topic

Mismo `topic_key` + mismo proyecto = upsert (actualiza existente).

### Buscar por topic

```
mem_search(query: "architecture/auth-model")
```

## Mejores prácticas

- Usar lowercase kebab-case
- Empezar con categoría
- Mantener consistencia dentro del proyecto
- No sobrescribir diferentes topics

## Ver también

- [[memory-protocol]] — Protocolo
- [[engram]] — Integración con Engram
