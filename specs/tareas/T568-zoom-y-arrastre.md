# T568 · Zoom hasta 2,0 y un dedo mueve el mapa

- Ejecutor · Sonnet · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-731, RF-732, RF-504, RF-505, RF-506, RF-701. `specs/04-decisiones.md`: D-223, D-205, D-037. H-07 y H-12 de `specs/tareas/informes/T454-reauditoria-mobile.md`.

## Causa ya medida

`CameraController.maximum_zoom_from_cell_pixels` limita a 1,0 y `_fit_map` da 560 ÷ 576 = 0,97 en 20 × 9: casi no hay recorrido. El desplazamiento solo se hace con dos dedos (`_handle_screen_drag`).

## Objetivo

Que se pueda acercar de verdad y recorrer el mapa con un dedo.

## Alcance

**Sí:** `scenes/game/camera_controller.gd`, `scenes/game/build_controller.gd` (`_handle_mobile_input`, `_start_mobile_ghost`), `data/ui/mobile_ui.json`, `scripts/data/mobile_ui_config.gd`, los tests de cámara y de gestos, `CHANGELOG.md`.

**No:** el encuadre mínimo, el fondo de las franjas, botones «+» y «−» (T570), ni guardar el zoom.

## Pasos

1. Subir `zoom_casilla_max_px` a 128 y el tope absoluto a 2,0. Renombrar `MAX_PRESENTATION_ZOOM` a algo que diga lo que es. Actualizar los tests que fijaban 1,0, citando D-223.
2. Comprobar que el `_fit_map` de PC sigue sin crear cámara cuando no hace falta: en PC con 20 × 9 el mínimo es 1,0 y `camera_controller` la crea al primer zoom.
3. Un dedo: en `_handle_mobile_input`, con `TouchGesture.Gesture.DRAG`, sin fantasma ni herramienta y con zoom por encima del mínimo, pedirle a la cámara que se desplace. **Un solo dueño del gesto**: que no actúe también la cámara por su lado, que un segundo dedo pase a la pinza sin salto y que al soltar no quede un toque.
4. H-07: el fantasma nace en la casilla válida más cercana al centro de **lo que se ve** (RF-505).
5. Comprobar el tope de movimiento: con 2,0 se llega a las cuatro esquinas con las barras puestas. `_clamp_camera_center` limita el centro al mapa, y el área visible está corrida por las barras.
6. Tests con la lógica pura y eventos sintéticos: rangos en 20 × 9, 24 × 11 y 26 × 12; un toque acierta la casilla con zoom 2,0 tras desplazar; un dedo con fantasma lo mueve sin desplazar; un dedo con zoom mínimo no desplaza; un arrastre no elige ni suelta; el pasaje de un dedo a dos.
7. Capturas del celular simulado y de PC a 2,0 en un nivel de cada terreno. Mirar el suelo y los adornos: **si se ven mal, anotarlo y avisar**.

## Hecho cuando

En 20 × 9 la pinza y la rueda llegan a 2,0. Un dedo mueve el mapa acercado sin elegir ni comprar. Un toque acierta la casilla a cualquier zoom. Se llega a las cuatro esquinas. El fantasma nace en lo que se ve. «Ver todo» sigue volviendo al encuadre. Hay capturas a 2,0.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** la pinza y el arrastre reales, ni el rendimiento a 2,0 en un teléfono.

## Frenar si

El suelo se ve inaceptable a 2,0, o separar el dueño del gesto exige rehacer `TouchGesture`.
