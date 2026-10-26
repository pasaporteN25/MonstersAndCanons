# T496 · Integrar la piedra con la A aprobada

> **Reemplazada por M80 (Lucas, 2026-10-26).** La piedra con la A ya no se integra: se hace con T507 (sistema de marcas) y T508 (rocas por niveles), tras la aprobación de T506. El cambio de canon A → H requiere el OK escrito de Lucas (D-212). No hacer esta tarea.

- **Ejecutor:** Sonnet · integración.
- **Depende de / compuerta:** 🚦🎨 T495 con la variante elegida. **No empezar antes.**
- **Refs:** RF-713 (a), RF-714, D-210. **Rama:** `feature/t496-integrar-piedra-a`, desde `origin/main`; un commit `T496: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M79 en `specs/01-spec.md` (RF-712 a RF-714 y las preguntas abiertas), D-210 y `specs/10-universo.md` (§4 y §6).

## Objetivo y alcance

Reemplazar el dibujo por el aprobado en la estética actual, con la misma huella de una casilla, sin cambiar ids de leyenda, `data/levels/*.json`, grilla ni construibilidad. Comparar los JSON con `origin/main` (deben ser idénticos).

## Archivos (propietario único)

`scripts/logic/map_drawings.gd` (`SIGNAL_ROCK`, `SIGNAL_RUIN`), los PNG aprobados en `assets/sprites/map/rendered/`, los tests que nombren esos dibujos (`tests/test_map_drawings.gd`, `tests/test_campaign_posts.gd` solo si cita rutas) y la tabla de la guía §4. No `data/`. Comparte archivos con las otras integraciones de M79: una a la vez.

## Hecho cuando

El dibujo aprobado se ve en todos los niveles que lo usan; capturas a 1280×720 y celular simulado (identificado como tal), con y sin poste de campaña (T475) donde corresponda; los JSON de `data/levels/` idénticos; GUT completo sin `SCRIPT ERROR` (`--import` primero; si cae con 139, relanzar y registrar ambos intentos); `git status` revisado (`git checkout -- assets` para SVG reescritos sin querer). No se afirma rendimiento ni prueba en teléfono real.

## Frenar si

Falta el OK de Lucas; el arte exige cambiar un JSON o la grilla; un test de otro nivel falla sin causa evidente; el poste oculta la señal y hay que mover algo (eso es de T475, no de acá).
