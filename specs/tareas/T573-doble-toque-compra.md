# T573 · Doble toque en una casilla vacía abre la compra

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T568 (mismo gesto) · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-740, RF-505, RF-510, RF-610. `specs/04-decisiones.md`: D-227. `scenes/game/build_controller.gd` (`_mobile_map_tap`, 395-403; `_handle_selection_input`, 491), `scripts/logic/ghost_placement.gd:50`, `scenes/ui/bar_tabs.gd`.

## Objetivo

Comprar más rápido: dos toques o clics en una casilla libre abren la compra.

## Alcance

**Sí:** `scenes/game/build_controller.gd`, una función pura en `scripts/logic/` para decidir el doble toque, `scenes/game/game.gd`, `scenes/game/hud.gd` (pestaña y pulso en la PC), `scenes/game/mobile_hud.gd` solo para llamar a `open_catalog`, tests, `CHANGELOG.md`.

**No:** portar el catálogo a la PC ni cambiar el doble toque con fantasma.

## Pasos

1. Función pura: misma casilla, dentro de `doble_toque_s`, primer toque sin fantasma. Sirve para los dos modos.
2. Señal hacia arriba, `empty_cell_double_tapped`. `Game` decide: en el celular, `open_catalog`; en la PC, la pestaña de torres y un pulso breve de la barra.
3. Condiciones de RF-740: solo pasto construible sin torre ni objeto. No en camino, bloqueada, en pausa, con herramienta, con modal ni con la partida terminada. Un toque simple sigue soltando la selección.
4. Tras un desplazamiento (T568) no cuenta: el gesto debe ser `TAP`. Un mouse real en Android va por el camino de `PointerFilter`.
5. En el tutorial, abrir así el catálogo cumple el paso `open_cart`: comprobarlo.
6. Tests: cada exclusión; con fantasma sigue confirmando; dos casillas distintas no cuenta; pasada la ventana no cuenta; PC y celular.

## Hecho cuando

En el celular abre el catálogo y en la PC la pestaña de torres. No se cobra nada. Con fantasma sigue confirmando. Las exclusiones tienen test.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** el doble toque con el dedo real ni la ventana de 0,35 s en un teléfono.

## Frenar si

La PC necesita más que cambiar de pestaña y un pulso.
