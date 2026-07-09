---
title: obase
description: Organization Base — estructura y reglas de agentes
tags: [obase, coordination, reference, stable, both]
---

# obase

Organization Base — estructura y reglas de agentes.

## Qué es

obase es la herramienta CLI para:

1. Inicializar organizaciones con estructura completa
2. Configurar repos existentes para trabajar con agentes
3. Mantener reglas de agentes actualizadas across repos

## Features

- Inicialización de org en un comando
- Configuración de repos via submodules
- Actualización de headers AGENTS.md
- Soporte multi-organización
- Skills versionados con OS tagging

## Uso

```bash
# Crear org
achords obase --org my-company

# Configurar repo
achords obase --repo my-app

# Actualizar todos los repos
achords obase --org my-company --update-headers
```

## Ver también

- [[obase]] — Referencia CLI
- [[org-structure]] — Estructura de org
