# T508 · Integrar las rocas genéricas en los niveles

- **Ejecutor:** Sonnet · integración.
- **Depende de / compuerta:** 🚦🎨 T506 completada (G2 y arte aprobados) y T507 integrada (comparten `map_drawings.gd` y `level_decor.gd`). **No empezar antes de T507.**
- **Refs:** RF-716, RF-719, D-212. **Rama:** `feature/t508-rocas-por-niveles`, desde `origin/main`; un commit `T508: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/00-constitucion.md, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` (§4), M80 en `specs/01-spec.md` (RF-716 a RF-719 y las preguntas abiertas), D-212 (con la lista de menciones del símbolo A) y `specs/10-universo.md` (§5 y §6).

## Objetivo y alcance

Hacer que `roca_marcada` y `simbolo_ruina` (ids sin cambio) se dibujen como la roca del color del tema, más la marca «grabada» de T507, en los 9 niveles de la tabla de M80 (7 a 15), con modelo estable por casilla (hash de la casilla, sin consumir el azar del juego). En la misma tarea, actualizar el escombro activo `assets/sprites/map/rendered/rubble_idle.png` con la H G2 elegida. Misma huella de una casilla; el poste de campaña oculta lo de atrás como siempre. Retirar `roca_marcada.svg`, `simbolo_ruina.svg` y el SVG legado `escombro.svg`, preservando el historial Git. Comparar los JSON con `origin/main` (idénticos).

## Archivos (propietario único)

`scripts/logic/map_drawings.gd`, los PNG aprobados en `assets/sprites/map/rendered/`, `tests/test_map_drawings.gd`, `tests/test_map_themes.gd` (si cita rutas), `tests/test_campaign_posts.gd` solo si cita rutas, y la guía §4. No `data/`. Una integración a la vez.

## Hecho cuando

Las rocas aprobadas se ven en los 9 niveles y el escombro activo muestra H G2; capturas a 1280×720 y celular simulado (identificado como tal), con y sin poste donde corresponda; JSON de `data/levels/`, `data/campaign.json` y `postes_campana.json` idénticos; GUT completo sin `SCRIPT ERROR` (`--import` primero; si cae con 139, relanzar y registrar ambos intentos); `git status` revisado. No se afirma rendimiento ni prueba en teléfono real.

## Frenar si

Falta T507; el arte exige cambiar un JSON o la grilla; el poste oculta una señal y hay que mover algo (eso es de T475, no de acá).
