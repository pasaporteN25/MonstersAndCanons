# T435 · Actualizar la guía de sprites de enemigos

- **Ejecutor:** Codex · documentación
- **Refs:** T434, `specs/05-guia-de-arte.md` §§6 y 8, `data/enemies/*.tres`
- **Depende de:** confirmar recursos de runtime en los datos de enemigo
- **Compuerta de arte:** ninguna; no se producen ni integran imágenes

## Objetivo
Corregir las afirmaciones de formato de §6 y §8 que quedaron viejas frente a los PNG y atlas de caminata usados por los recursos actuales.

## Hecho cuando
La guía distingue fuentes SVG históricas de texturas de runtime, dirige a los `.tres` para conocer `texture` y `walk_atlas`, y ya no dice que Normal, Rápido y Tanque carecen de cuadros de caminata. No se modifican sprites, `.tres`, scripts ni balance. `git diff --check` pasa.

## Resultado (2026-10-21)
Actualizadas §6 y §8 con las rutas y configuración que usan los datos vigentes. No se cambiaron assets ni código. `git diff --check` pasó; no hacía falta ejecutar GUT para este cambio documental.
