# T569 · Capa de rieles laterales en el host

- Ejecutor · Codex (Terra 6.1) · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-733, RF-699, RF-702, RF-726. `specs/04-decisiones.md`: D-224, D-204. `specs/02-plan-tecnico.md`: M89. H-05 y H-19 de `specs/tareas/informes/T454-reauditoria-mobile.md`. `scripts/host/presentation_host.gd`, `scripts/logic/presentation_geometry.gd`, `scripts/autoload/game_flow.gd` (487-495).

## Objetivo

La infraestructura: una capa fuera del `SubViewport` que sabe si hay rieles, dónde van y entrega toques una sola vez. **Todavía no mueve ningún botón del juego** (eso es T570).

## Alcance

**Sí:** `scripts/logic/presentation_geometry.gd` (función pura), `scripts/host/presentation_host.gd` y su `.tscn`, una clase `SideRails`, `scripts/autoload/game_flow.gd` (acceso), `data/ui/mobile_ui.json` y su config (`riel_min_px`), tests.

**No:** `expand`, el tamaño del marco, las coordenadas del juego, el material de las franjas ni `mobile_hud.gd`.

## Pasos

1. Función pura `side_rail_rects(surface_size, safe_area, min_logical_px)`, que devuelve los dos rectángulos en píxeles físicos o ninguno, usando `frame_rect` y `frame_scale`. Si un solo lado no llega al mínimo, no hay rieles.
2. Tests de esa función en 16:9, 16:10, 4:3, 19,5:9, 20:9 y 21:9, con y sin área segura, incluida una muesca de un solo lado.
3. `SideRails`: dos columnas con API `set_buttons(left, right)`, `set_visible_for_modal(bool)` y una señal por botón. Mide los botones en físico según `frame_scale` y el mínimo de RF-507, y se recalcula en `NOTIFICATION_RESIZED`.
4. Leer el área segura con `DisplayServer.get_display_safe_area()` solo en Android, con una costura para los tests.
5. Respetar el bloqueo de transición (RF-702): con la raíz bloqueada, no actúa. Las partes vacías no consumen acciones de juego.
6. Tests: un botón de prueba emite **una sola vez** por toque, también si llega el clic emulado (H-05); la franja vacía no actúa; un toque dentro del marco sigue llegando a la misma casilla con los rieles presentes; sin rieles, nada cambia.
7. Sin botones cargados, los rieles no dibujan nada. El juego se ve igual que hoy al terminar esta tarea.

## Hecho cuando

La función da los rieles correctos en todas las proporciones probadas. `SideRails` entrega un botón de prueba una vez por toque. La franja vacía no actúa. El juego no cambia a la vista. Las coordenadas de juego están cubiertas por test.

## Verificación

Suite completa sin `SCRIPT ERROR`. Captura en una ventana 20:9 con un botón de prueba (que no quede en el código final). **No se puede probar acá:** la muesca real, la barra de gestos de Android ni el multitáctil real.

## Frenar si

Los rieles obligan a cambiar el `SubViewportContainer` o pasan toques dobles a la partida. D-204 no se reabre sin Lucas.
