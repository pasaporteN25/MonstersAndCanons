# T491 · Inventario de los assets de los niveles altos

- **Ejecutor:** Haiku · solo lectura y capturas.
- **Depende de / compuerta:** 🚦 T490 aprobada por Lucas.
- **Refs:** RF-712, D-210. **Rama:** `feature/t491-inventario-assets-altos`, desde `origin/main`; un commit `T491: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M79 en `specs/01-spec.md` (RF-712 a RF-714 y las preguntas abiertas), D-210 y `specs/10-universo.md` (§4 y §6).

## Objetivo y alcance

Producir la tabla real de qué dibujos usa cada nivel 8 a 15: tema, `MapThemes.BLOCKED`, leyendas de `MapDrawings`, cantidad de casillas, archivo, técnica (SVG plano M4/M5 o PNG dimensional T277) y una captura del motor real a 1280×720 por nivel como «antes». Confirmar o corregir la tabla «Qué hay hoy» de M79 y marcar la discrepancia de `10-universo.md` §6 (roca marcada en el 1 y el 5, hoy `estatua`). No opina sobre el arte.

## Archivos (propietario único)

Solo `art/m79-inventario/` (informe y capturas). Nadie más escribe ahí. No toca `assets/`, `scripts/`, `data/` ni `specs/`.

## Hecho cuando

`art/m79-inventario/inventario.md` con las 8 filas de niveles y los conteos; 8 capturas rotuladas «antes»; las diferencias con M79, si las hay, listadas; `git status` limpio fuera de la carpeta.

## Frenar si

Una captura falla o `--import` reescribe SVG que nadie tocó (devolver con `git checkout -- assets`); un conteo no coincide con M79 y no se explica.
