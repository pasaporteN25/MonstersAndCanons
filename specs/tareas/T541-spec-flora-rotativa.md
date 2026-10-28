# T541 · Especificar la flora alienígena rotativa

- **Ejecutor:** Codex; revisión documental.
- **Depende de:** aprobación explícita de Lucas a las tres muestras T540 (2026-10-27); PR #139 integra las fuentes de esas muestras.
- **Refs:** RF-263, RF-728, D-218, T540.
- **Tipo:** 📜 spec. Una única tarea documental de este bloque.

## Leer

`specs/00-constitucion.md`, §7.11 de `specs/01-spec.md`, D-218, `specs/05-guia-de-arte.md` §4, `specs/tareas/T540-rehacer-muestras-flora-familia-vigente.md` y la galería T540.

## Objetivo

Registrar como modelos activos las tres variantes aprobadas por Lucas, fijar su rotación determinista y la dirección visual de flora de Cántaro, y dejar una tarea de implementación con criterios verificables.

## Alcance (sí / no)

- **Sí:** enmendar RF-263 con RF-728, registrar D-218, actualizar la guía y el plan, y crear T542.
- **No:** integrar código o sprites, redibujar/recolorear las propuestas aprobadas, tocar mapas/leyendas/guardados ni inventar canon biológico.

## Hecho cuando

La spec dice que A/B/C se conservan y rotan de forma estable; las tres aparecen entre las seis casillas oficiales actuales; el SVG histórico queda marcado como no activo y sin valor de referencia; T542 depende del merge de T540 y T541 y tiene pruebas/alcance claros.

## Verificación

Revisar referencias y numeración, `git diff --check` y coherencia entre spec, decisión, guía, plan, tablero y fichas. No ejecutar Godot/GUT en esta tarea documental.

## Frenar si

La implementación requiere cambiar posiciones o leyendas, inventar canon/biología, rediseñar cualquiera de las tres muestras o cambiar progreso/guardado.
