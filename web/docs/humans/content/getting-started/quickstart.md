---
title: Quick Start
description: Bootstrap una organización y onboardea tu primer repo en 5 minutos
tags: [getting-started, tutorial, stable, human]
---

# Quick Start

Bootstrap una organización y onboardea tu primer repo en 5 minutos.

## 1. Crear tu org

```bash
achords obase --org my-company
```

Esto crea:

```
~/achords/my-company/
├── .achords/      # Reglas de agentes
├── .skills/       # Skills compartidos
├── .internal/     # Onboarding de devs
└── .github/       # Perfil de org
```

## 2. Onboardear un repo

```bash
cd ~/achords/my-company
achords obase --repo my-app
```

## 3. Verificar

```bash
ls -la my-app/
# Debería mostrar .engram/
cat my-app/AGENTS.md
# Debería mostrar instrucciones de agente
```

## Qué pasó

1. `.engram` se agregó para memoria de agentes
2. `AGENTS.md` se creó con instrucciones
3. `.achords` y `.skills` se agregaron como submodules
4. Las reglas de la org ahora aplican a este repo

## Siguiente paso

- [[concepts]] — Entiende el modelo mental
- [[org-structure]] — Qué vive dónde
