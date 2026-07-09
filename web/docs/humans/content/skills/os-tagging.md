---
title: OS Tagging
description: Skills específicos por plataforma con herencia
tags: [skills, reference, stable, agent]
---

# OS Tagging

Skills específicos por plataforma con herencia.

## Jerarquía

```
linux
├── debian
│   ├── ubuntu
│   │   ├── ubuntu-22.04
│   │   └── ubuntu-24.04
│   └── debian-12
└── fedora

windows
├── windows-11
└── windows-server-2022
```

## Formato de tag

```json
{
  "os": "ubuntu",
  "versions": ["22.04", "24.04"],
  "family": "debian"
}
```

## Herencia

Un skill con tag `ubuntu` funciona en:
- Ubuntu 22.04
- Ubuntu 24.04
- Cualquier sistema basado en Debian

## Incompatibilidad

Los skills pueden declarar incompatibilidades:

```json
{
  "os": "windows",
  "incompatible_with": ["linux"]
}
```

## Resolución

Al cargar un skill:

1. Verificar match exacto de OS
2. Verificar herencia de familia
3. Verificar incompatibilidades
4. Cargar mejor match

## Ver también

- [[skill-versioning]] — Versionado
- [[skill-spec]] — Especificación
