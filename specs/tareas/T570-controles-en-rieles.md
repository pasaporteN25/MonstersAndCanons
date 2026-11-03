# T570 · Pasar los controles a los rieles y sumar «+» y «−»

- Ejecutor · Sonnet · esfuerzo alto
- Depende de · T566, T567, T568, T569 · Compuerta · ninguna · Tamaño · Grande

## Leer

`specs/01-spec.md`: RF-734, RF-733, RF-736, RF-507, RF-513, RF-675. `specs/04-decisiones.md`: D-224. H-16 de `specs/tareas/informes/T454-reauditoria-mobile.md`. `scenes/game/mobile_hud.gd` (botones flotantes y su acomodo, 594-634 y 1224-1290).

## Objetivo

Despejar el mapa: con rieles, los controles flotantes y «Vender» salen del marco.

## Alcance

**Sí:** `scenes/game/mobile_hud.gd`, `scenes/game/game.gd`, `scenes/game/camera_controller.gd` (zoom por botón), `data/ui/mobile_ui.json` (`zoom_boton_factor`), textos en dos idiomas, tests, `CHANGELOG.md` y `ONBOARDING.md` si describe los controles. Íconos provisionales de «+» y «−».

**No:** la capa de rieles (salvo arreglos chicos), el tutorial (T574), ni nada visible en 16:9.

## Pasos

1. Con rieles, **izquierdo:** Menú, «+», «−», lupa y, abajo de todo, «Vender». **Derecho:** carrito y «Demoler». Son los del RF-734.
2. Conservar la lógica: las señales son las mismas. Un botón del riel y su equivalente flotante no existen a la vez. `is_interactive_at` no debe contar lo que está afuera.
3. «Vender» en el riel conserva sus dos toques, su armado y `vender_rearmar_s`. Sale de la barra, y la separación de RF-512 deja de ocupar lugar: el texto gana ese ancho.
4. `+`/`−`: `CameraController.zoom_step(factor)` alrededor del centro del área visible. Se apagan en cada tope. Aparece el aviso de RF-676 igual que al acercar.
5. Los botones del riel no se arrastran. Las posiciones guardadas de los flotantes se conservan, sin aplicarse.
6. Modales: `set_modal_open`, el menú, el cartel y la presentación ocultan los rieles. Fin de partida también. Cuidar la vuelta.
7. Cambiar de tamaño con la partida abierta (rotar entre 16:9 y 20:9 en PC) no deja botones duplicados ni estados perdidos.
8. Revisar el estado «con fantasma»: el carrito activo y el corrimiento (`set_cart_active`).
9. Tests: 16:9 igual a hoy; con rieles, ningún botón dentro del marco; «+» y «−» y sus topes; dos toques de «Vender»; rieles ocultos con cada modal; cambio de tamaño; carrito abre catálogo; «Demoler» aparece solo si está disponible.
10. Capturas en 16:9, 19,5:9, 20:9 y 21:9: mapa libre, torre elegida, fantasma y catálogo abierto.

## Hecho cuando

Con rieles, los botones salen del marco y funcionan; sin rieles, todo queda como antes. «+» y «−» respetan los topes. «Vender» sigue protegido. Los modales ocultan los rieles. Hay capturas en las cuatro proporciones. El tutorial no se traba, aunque todavía no señale bien el riel (si un paso queda mal, anotarlo para T574).

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** los pulgares, los 6 mm reales ni la barra de gestos.

## Frenar si

Un botón no entra en el riel sin bajar de los 6 mm, o el tutorial queda sin salida.
