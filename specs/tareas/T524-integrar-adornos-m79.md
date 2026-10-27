# T524 · Integrar adornos de M79 aprobados por Lucas

- **Ejecutor:** Sonnet · integración.
- **Depende de:** T523 mergeada; aprobación visual escrita de Lucas para cada asset y su aplicación; T508 integrada antes por compartir `MapThemes`/`MapDrawings`.
- **Refs:** M79, RF-712 a RF-714, D-210. **Rama:** `feature/t524-integrar-adornos-m79`, desde `origin/main`; un commit `T524: …`, PR a `main`; Lucas mergea.

## Leer

CLAUDE.md, `~/.agents/AGENTS.md`, `specs/00-constitucion.md`, `.claude/rules/arte.md`, `specs/05-guia-de-arte.md` §4, M79/RF-712 a RF-714, D-210, informe y aprobaciones de T523, `MapThemes`, `MapDrawings` y tests de mapa.

## Objetivo

Integrar exclusivamente las piezas de T523 que Lucas aprobó, en el uso y bioma que aprobó. Cada pieza puede quedar fuera si fue rechazada o si no se aprobó su ubicación.

## Alcance

Copiar fuentes y PNG aprobados, actualizar solo rutas/temas/tests/guía de arte que los referencien y capturar los niveles afectados en el motor real. Preservar mapas, leyendas, grillas, casillas y mecánicas byte a byte. No inferir ubicaciones de campamentos ni alterar mapas para hacerles lugar.

## Hecho cuando

Cada pieza aprobada se ve en su aplicación aprobada, los mapas y reglas jugables no cambiaron, tests de assets y GUT completo pasan sin `SCRIPT ERROR`, y hay capturas a 1280×720 y celular simulado identificado como tal. `godot --headless --import` se ejecuta primero; si cae con 139, se relanza y se registran ambos intentos. El diff de `data/levels/` debe seguir vacío. No se afirma rendimiento ni prueba en teléfono real.

## Frenar si

Falta una aprobación escrita; hay que cambiar un JSON de nivel, una leyenda, una grilla o mecánica; los diseños invaden camino/casillas vecinas; aparece un `SCRIPT ERROR` o un fallo sin causa clara.
