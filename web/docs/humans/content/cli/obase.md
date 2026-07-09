---
title: obase
description: Inicializa una organización o configura un repo
tags: [cli, obase, reference, stable, human]
---

# achords obase

Inicializa una organización o configura un repo.

## Uso

```bash
achords obase [options]
```

## Opciones

| Flag | Descripción | Default |
|------|-------------|---------|
| `--org` | Nombre de la org | Requerido |
| `--repo` | Repo a configurar | Ninguno |
| `--dir` | Directorio custom | `~/achords/{org}` |
| `--skills` | URL del repo de skills | Ninguno |
| `--update-headers` | Actualizar AGENTS.md headers en todos los repos | false |
| `--upgrade` | Regenerar guías completas desde la versión actual de achords (preserva reglas custom) | false |
| `--push` | Push cambios a GitHub | false |

## Ejemplos

### Inicializar org

```bash
achords obase --org my-company
```

Crea `~/achords/my-company/` con estructura completa.

### Configurar repo existente

```bash
cd ~/achords/my-company
achords obase --repo my-app
```

### Actualizar todos los repos

```bash
achords obase --org my-company --update-headers --push
```

### Upgrade guías a nueva versión de achords

```bash
# Regenera AGENTS.md completo en todos los repos
# (preserva reglas custom debajo de ## Repository-Specific Rules)
achords obase --org my-company --upgrade --push
```

### Directorio custom

```bash
achords obase --org my-company --dir /custom/path
```

## Qué crea

### Org init

```
~/achords/my-company/
├── .achords/
├── .skills/
├── .internal/
└── .github/
```

### Repo config

```
my-app/
├── .achords → (submodule)
├── .skills  → (submodule)
├── .engram/
└── AGENTS.md
```

## Ver también

- [[org-structure]] — Estructura de org
- [[repo-integration]] — Integración de repos
