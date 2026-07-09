---
title: update
description: Actualiza achords a última versión
tags: [cli, guide, stable, human]
---

# achords update

Actualiza achords a la última versión.

## Uso

```bash
achords update
```

## Comportamiento

1. Verifica registry de npm para última versión
2. Compara con versión instalada
3. Pide confirmación
4. Actualiza via npm o git pull

## Ejemplos

### Actualizar via npm

```bash
achords update
# Verifica npm, pide confirmación, actualiza
```

### Actualizar desde fuente

Si se instaló desde git:

```bash
achords update
# Ejecuta git pull en vez de npm
```

## Ver también

- [[version]] — Verificar versión actual
