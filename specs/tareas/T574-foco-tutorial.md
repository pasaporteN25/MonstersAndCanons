# T574 · Efecto de foco en el tutorial

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T570 (botones en los rieles) · Compuerta · ninguna · Tamaño · Mediano

## Leer

`specs/01-spec.md`: RF-739, RF-574, RF-577. `scenes/ui/tutorial_overlay.gd`, `scenes/game/tutorial_controller.gd` (`_targets`, 209), `scripts/logic/tutorial_layout.gd`, `data/tutorial/tutorial.json`. La API de `SideRails` de T569.

## Objetivo

Que en cada paso de acción quede clarísimo qué hay que tocar: lo demás se oscurece y lo señalado llama la atención. Es el efecto «pulsame» que pidió Lucas. **Los pasos nuevos de mecánicas son T576.**

## Alcance

**Sí:** `scenes/ui/tutorial_overlay.gd`, `scenes/game/tutorial_controller.gd`, `data/tutorial/tutorial.json` y `scripts/logic/tutorial_data.gd` (oscuridad, velocidad y rótulos), la capa de rieles para el estado de foco, textos en dos idiomas, tests, `CHANGELOG.md`.

**No:** el mapa, oro ni oleadas del nivel 1 (RF-577), cuáles son los pasos, ni que el tutorial pause la partida.

## Pasos

1. Oscurecido: cuatro rectángulos alrededor de lo señalado, con `MOUSE_FILTER_IGNORE`. Un paso de lectura no oscurece.
2. Anillo que se expande desde el centro de lo señalado y rótulo «Tocá acá» o «Hacé clic acá». El parpadeo y la flecha actuales se mantienen o se reemplazan, lo que se lea mejor en las capturas.
3. Calcular el tiempo con `Time`, como ahora: la partida puede estar en pausa o a ×2.
4. Rieles: si lo señalado está en un riel, ese botón pulsa, los otros se apagan y el oscurecido cubre el marco. Revisar `target_control` y qué pasa con la flecha, que no puede salir del marco.
5. Con varias zonas (el camino, el mapa): usar un solo agujero que las cubra o dejar el oscurecido apagado en ese paso. No usar una máscara por casilla.
6. Tests: el foco no consume toques (un toque sobre lo señalado llega al control); lectura sin oscurecido; riel y marco; el resaltado sigue al control con zoom; la tarjeta no queda tapada; PC y celular.
7. Capturas de cada paso de acción en PC, celular 16:9 y celular 20:9.

## Hecho cuando

Los pasos de acción oscurecen lo demás y señalan con el anillo. Los toques pasan. Funciona sobre botones del riel. El tutorial se completa de punta a punta en PC y celular. Hay capturas.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** cómo se percibe en un teléfono real ni con alguien que juegue por primera vez.

## Frenar si

Hay que bloquear toques para que el foco funcione: eso contradice RF-574.
