---
title: Aislamiento de Memoria
description: Cómo se organiza la memoria across orgs y repos
tags: [architecture, memory, concept, stable, both]
---

# Aislamiento de Memoria

Cómo se organiza la memoria across orgs y repos.

## Dos niveles de memoria

```
Memoria de org (compartida)
└── .achords/.engram/
    └── Todos los repos la ven

Memoria de repo (aislada)
└── .engram/
    └── Solo este repo la ve
```

## Memoria de org

Vive en `.achords/.engram/`. Compartida across todos los repos de la org.

Contiene:
- Convenciones de org
- Decisiones de arquitectura
- Descubrimientos compartidos
- Patrones cross-repo

## Memoria de repo

Vive en `.engram/`. Específica de cada repo.

Contiene:
- Bugs específicos del repo
- Patrones locales
- Decisiones de features
- Descubrimientos de testing

## Protocolo de memoria

Los agentes siguen este protocolo:

1. **Inicio de sesión** — Llamar `mem_context` para recuperar
2. **Durante el trabajo** — Llamar `mem_save` después de decisiones/fixes
3. **Fin de sesión** — Llamar `mem_session_summary`

## Ver también

- [[engram]] — Integración con Engram
- [[memory-protocol]] — Protocolo detallado
