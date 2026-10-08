# M51 · Ficha de arte de la Disruptora (para Codex, T216)

**Estado:** ficha escrita en T215. **Todavía no hay arte** y **no se produce nada sin el OK de Lucas sobre el concepto** (compuerta 🎨 de T216). Reglas del juego: RF-438 a RF-452 de `specs/01-spec.md` (M51) y D-086 / D-087. Protocolo de Codex: `specs/tareas/README.md` §6.

## Qué es (en una frase)
Una **bobina Tesla** (pedido de Lucas, 07 §9) que **no dispara**: emite **pulsos en anillo** que **apagan el aura** del Guardián y del Curandero. Tiene que parecer una torre de **utilidad** y **verse distinta de la Eléctrica** a 64 y a 34 px.

## Cómo se distingue de la Eléctrica (obligatorio)
Referencia **para no parecerse**: `assets/sprites/towers/rendered/turret_tesla.png` y `tesla_atlas.png` (bobina de bronce en espiral con **esfera violeta** y un **brazo con garra** de costado).

| | Eléctrica (existente) | Disruptora (nueva) |
|---|---|---|
| Silueta | Asimétrica: columna en espiral con un brazo a un costado | **Columna simétrica y alta**, de **anillos horizontales apilados** que se **ensanchan hacia arriba** (como un cono de discos) |
| Remate | Esfera violeta | **Disco emisor plano**, ancho, sin esfera |
| Energía | Violeta y amarilla | **Blanco azulado** (`#DCEBFF`) con borde azul (`#7FA8FF`); **nunca violeta ni amarilla** |
| Materiales | Bronce y cristal | **Cobre y bronce sobre hierro oscuro**; los anillos son de cobre, el disco, de cristal claro |
| Movimiento | Gira hacia el objetivo | **Casi no gira** (no apunta): las 8 direcciones **cambian poco** entre sí, solo la luz y los detalles |
| Familia (guía §7) | C | **C** (metal claro, bronce y cristal), con silueta propia |

## Qué hay que entregar
Todo en `art/m51-disruptora/` y los finales en `assets/sprites/towers/rendered/` (como pide `specs/tareas/T216-arte-disruptora.md`):

| Pieza | Formato | Notas |
|---|---|---|
| **Concepto** (para la compuerta) | 2 o 3 variantes en **una vista SE**, 512 × 512, en una hoja | Lucas elige antes del atlas. Registrar el OK en `README.md` de esta carpeta, con la fecha y su texto. |
| `disruptor_atlas.png` | 512 × 256: **4 × 2 cuadros de 128 × 128**, orden E, SE, S, SO, O, NO, N, NE | **Solo el mecanismo**, sin base. Como casi no gira (ver arriba), los 8 cuadros son **la misma torre** con la luz en el mismo lugar. |
| `turret_disruptor.png` | 128 × 128 | La vista independiente (Wiki, barra, panel). |
| `disruptor_level_2.png`, `disruptor_level_3.png` | Atlas de 512 × 256, como los de las otras torres | El nivel 2 suma **un anillo** más y el disco más grande; el 3, **dos** anillos y un disco con un **segundo disco chico** encima. La lectura del nivel la da la **placa con remaches ámbar** de la base (RF-350), como en las demás: no depender del brillo. |
| Textura del **anillo de pulso** | 128 × 128 con alfa | **Blanco azulado**, un anillo fino con un halo suave **hacia afuera**, centrado. La **anima el código** (crece y se desvanece, `RingEffect`), así que tiene que escalar bien. **Distinta** del aturdimiento violeta, del aura cian del Mecánico y del celeste del Hielo. |
| **Ícono de supresión** | 32 × 32 con alfa | **Tres arcos de un anillo roto**, blanco azulado con contorno oscuro `#202330`; legible a 12 px. Va al lado de la barra de vida del enemigo (RF-449). Lo vacía el código (arco por arco), así que **conviene entregar un solo arco** además del ícono completo, o los tres por separado. |

La **base** de la torre es la de siempre (`base_1` a `base_3`): no se rehace.

## Colores (todos con luz arriba a la izquierda, sin sombra incrustada)
- **Cobre y bronce:** los anillos (de claro arriba a oscuro abajo).
- **Hierro oscuro:** el eje central y los soportes.
- **Cristal claro:** el disco emisor.
- **Blanco azulado:** la energía, el pulso y la marca (`#DCEBFF` y `#7FA8FF`).
- **No usar:** violeta (aturdimiento y Eléctrica), verde amarillento (cura), marfil (aura de armadura), cian fino (apoyo del Mecánico), amarillo (Eléctrica), celeste saturado (Hielo).

## Lectura y estados
- **Lista y con un emisor en el radio:** el disco **encendido** (blanco azulado). **Esperando:** el disco **apagado** (cristal gris). **Aturdida:** lo dibuja el juego (aro roto violeta y descargas sobre el mecanismo, RF-280): **no se pinta en el arte**.
- **A 34 px** la silueta de **columna de anillos con un disco arriba** tiene que ser **distinta de todas las otras torres** (en una hoja de contacto con las nueve torres, a 34 px, se encuentra sola).
- **El pulso en el mapa** se compone en código con la textura del anillo; **no hace falta** un cuadro de animación.

## Cómo se entrega (como M43)
Fuentes originales sin modificar (`sources/`), `prompts.md` con los prompts normalizados, `manifest.json`, un `pack.gd` que **recorta y normaliza sin repintar**, una **hoja de contacto** a 112 y a 34 px junto a las otras nueve torres, una **captura en partida** (con un Guardián suprimido) y una de la **Wiki**. Mipmaps y filtrado lineal. Tests completos en verde (incluidos los de sprites).

## Lo que **no** hace falta (y no se hace)
- Tocar código (si integrar el arte pide más código, queda anotado para T217).
- Animación de disparo o de retroceso (no dispara) ni proyectil.
- Arte de enemigos nuevos: la marca de supresión es un ícono, no un dibujo del enemigo.
- Cambiar el atlas ni la base de la Eléctrica ni de otra torre aprobada.

## Mientras tanto
T217 dibuja la torre con **figuras simples** (`_draw`: pila de anillos y disco) con estos colores, sin esperar el arte (Q-40). Cuando llegue T216, solo se cambian las rutas de textura de `data/towers/disruptor.tres`.
