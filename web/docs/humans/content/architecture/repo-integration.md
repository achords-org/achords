---
title: Integración de Repos
description: Cómo los repos importan reglas de la org via git submodules
tags: [architecture, reference, stable, both]
---

# Integración de Repos

Cómo los repos importan reglas de la org via git submodules.

## Setup de submodule

Cuando ejecutas `achords obase --repo my-app`, hace:

1. Agrega `.achords` como submodule
2. Agrega `.skills` como submodule
3. Crea `.engram/` para memoria del repo
4. Crea `AGENTS.md` con instrucciones

## Estructura resultante

```
my-app/
├── .achords → ../.achords/ (submodule)
├── .skills  → ../.skills/  (submodule)
├── .engram/                (memoria repo)
├── AGENTS.md               (instrucciones)
├── src/
└── ...
```

## Actualizar reglas de org

Cuando cambian las reglas, los repos actualizan:

```bash
cd ~/achords/my-company/my-app
git submodule update --remote .achords .skills
```

O usa `--update-headers` para actualizar todos los repos:

```bash
achords obase --org my-company --update-headers
```

## AGENTS.md

Cada repo recibe un `AGENTS.md` con:

- Header con marcador de versión
- Sección de lecturas obligatorias
- Flujo del agente
- Protocolo de memoria

Los agentes leen este archivo al inicio de la sesión.

## Ver también

- [[org-structure]] — Qué vive dónde
- [[agent-flow]] — Flujo del agente
