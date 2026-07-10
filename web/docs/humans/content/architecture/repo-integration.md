---
title: Integración de Repos
description: Cómo los repos importan reglas de la org via git submodules
tags: [architecture, reference, stable, both]
---

# Integración de Repos

Cómo los repos importan reglas de la org via git submodules.

## Setup de submodule

Cuando ejecutas `achords obase --repo my-app`, hace:

1. Agrega `.achords` como submodule (trae reglas + org memory)
2. Agrega `.skills` como submodule
3. Crea `.engram/` para memoria del repo
4. Crea `AGENTS.md` con instrucciones

## Estructura resultante

```
my-app/
├── .achords → ../.achords/ (submodule)
│   ├── AGENTS.md               (reglas de org)
│   ├── config/                 (convenciones, policies)
│   ├── templates/AGENTS/       (templates versionados)
│   └── .engram/                (org memory — compartida)
├── .skills  → ../.skills/  (submodule)
├── .engram/                    (repo memory — aislada)
├── AGENTS.md                   (instrucciones del repo)
├── src/
└── ...
```

## Sincronización de org memory

`.achords/.engram/` vive DENTRO del submodule `.achords`. Cuando hacés `git submodule update --remote .achords`, recibís tanto las reglas como la memoria de org.

```
# En cada repo miembro:
git submodule update --remote .achords

# Esto trae:
#   - Nuevas reglas en .achords/AGENTS.md
#   - Nueva memoria de org en .achords/.engram/
#   - Nuevos templates en .achords/templates/AGENTS/
```

No hay paso extra — la org memory viaja con el submodule.

## Actualizar reglas de org

Cuando cambian las reglas, los repos actualizan:

```bash
cd ~/achords/my-company/my-app
git submodule update --remote .achords .skills
```

### Actualización rápida (headers)

Usa `--update-headers` para actualizar la version en AGENTS.md de todos los repos:

```bash
achords obase --org my-company --update-headers --push
```

### Upgrade completo (cuando achords se actualiza)

Cuando instalás una versión nueva de achords, las guías pueden haber mejorado (nuevas secciones en AGENTS.md, mejores defaults, etc.). Usa `--upgrade` para regenerar TODO el contenido:

```bash
achords obase --org my-company --upgrade --push
```

Esto regenera:
- `.achords/AGENTS.md` con el template actual
- `.achords/config/policies.json` con defaults actualizados
- `.achords/version.json` con la nueva `achords_version`
- AGENTS.md de CADA repo existente (body completo)
- **Preserva** las reglas custom debajo de `## Repository-Specific Rules`

### Diferencia entre `--update-headers` y `--upgrade`

| `--update-headers` | `--upgrade` |
|--------------------|-------------|
| Solo actualiza el header version | Regenera header + body completo |
| No toca el body template | Reemplaza secciones obsoletas |
| Rápido, seguro | Más lento, para upgrades de versión |

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
