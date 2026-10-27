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

## Aprobaciones registradas · Lucas

- 2026-10-26: aprobación de los otros cuatro motivos expresada como «Lo demás lo veo bien» (T525/T526).
- 2026-10-27: cactus opción 02 y campamento vacío opción 02. Se aplican en el tema desierto y en las leyendas existentes de niveles 14 y 15, respectivamente.
- Uso: rocas rojas en las `X` desérticas existentes; columna, bloque y estatua en las `X` de ruinas; columna en la entrada de tema volcánico que ya existía. No se modifica `data/levels/`.


## Resultado · 2026-10-27

Se integraron las opciones aprobadas en `MapThemes`/`MapDrawings`, conservando el arte fuente y variantes en `art/m79-muestras/adornos/`. GUT completo: 2536/2536 tests y 46.691 asserts, sin `SCRIPT ERROR`. Import final limpio (exit 0); la primera importación registró errores transitorios de precarga durante el escaneo inicial, no 139. Se generaron seis capturas reales del motor en PC y celular simulado a 1280×720. La de nivel 14 en PC guardó su PNG con exit 0 y mostró un aviso de recursos aún referenciados al cerrar. `git diff -- data/levels/` vacío. Sin teléfono real ni mediciones de rendimiento.
