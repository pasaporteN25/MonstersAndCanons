# Disruptora · entrega provisional

El arte de T216 está preparado como **provisional** para revisión de Lucas. La dirección respeta la ficha M51: columna simétrica de anillos de cobre y bronce, eje de hierro oscuro, disco emisor plano y energía blanco azulada. La Tesla existente conserva su silueta lateral con esfera violeta.

## Concepto y piezas

- [Hoja de concepto provisional](concept_provisional.png): tres variantes, vista SE, 512 × 512 px.
- `assets/sprites/towers/rendered/disruptor_atlas.png`: atlas 512 × 256, ocho celdas de 128 × 128; repite la vista SE en las ocho direcciones.
- `turret_disruptor.png`: vista independiente de 128 × 128.
- `disruptor_level_2.png` y `disruptor_level_3.png`: atlas de mejora 512 × 256 cada uno.
- `disruptor_pulse_ring.png`: aro blanco azulado de 128 × 128 con halo tenue.
- `disruptor_suppression_icon.png` y `disruptor_suppression_arc_1.png` a `_3.png`: marca de tres arcos y sus segmentos, 32 × 32.
- [Comparación a 112 px](contact_112px.png) y [comparación a 34 px](contact_34px.png) con las nueve torres actuales. El orden, de izquierda a derecha y de arriba abajo: Básica, Francotirador, Incendiaria, Múltiple, Ráfaga, Hielo, Eléctrica, Cañón, Mortero y Disruptora.
- [Fuentes originales](sources/) y [prompts normalizados](prompts.md).

## Aprobación y límites

**Aprobación de Lucas: pendiente.** No registrar aprobación hasta recibirla. La imagen es una propuesta de trabajo y puede cambiar luego de la revisión.

No hay captura de partida ni de Wiki: T217 todavía no creó ni integró la torre. No se tocaron `.tres` ni lógica. La biblia `specs/10-universo.md` no está en este checkout; se usaron como dirección visual la ficha FICHA.md, RF-451 y 07 §9.

## Reproducir

```bash
godot --headless --path . -s art/m51-disruptora/pack.gd
```

`pack.gd` recorta y normaliza las tres variantes; genera atlas, vista independiente, texturas, hoja de concepto reducida y contactos. La fuente de generación se conserva intacta en `sources/concept_sheet.png`.
