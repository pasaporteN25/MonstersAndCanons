# T216 · 🎨 Arte de la Disruptora

- **Ejecutor:** **Codex** (`image_gen` integrado)
- **Depende de:** T215 (su ficha de arte) · **Compuerta:** 🎨 Lucas aprueba **el concepto** (2 o 3 variantes de una sola vista) antes del atlas · **Tamaño:** mediano

## Leer
- `specs/tareas/README.md` §6 (protocolo de Codex).
- `specs/05-guia-de-arte.md` §7 (torres renderizadas: formato y familias), §M36 (lectura de estados) y §M43.
- `art/redesign-m43/README.md` y `prompts.md`: el último pipeline aprobado, para copiarlo.
- **La ficha de arte de T215: `art/m51-disruptora/FICHA.md`** (la tabla de cómo se distingue de la Eléctrica, los colores y los estados) y los RF-449 y RF-451 de la spec. Si algo de la ficha de esta tarea difiere de ese archivo, **manda `FICHA.md`**.
- Las referencias visuales: `assets/sprites/towers/rendered/tesla_atlas.png` (**no parecerse**), `turret_tesla.png` y `base_1.png` a `base_3.png`.

## Entregables
Todo en `art/m51-disruptora/`, con los finales en `assets/sprites/towers/rendered/`:

| Pieza | Formato |
|---|---|
| Concepto (para la compuerta) | 2 o 3 variantes, una vista SE, 512 × 512, en una hoja. |
| `disruptor_atlas.png` | Atlas de 512 × 256: 4 × 2 cuadros de 128 × 128, en el orden E, SE, S, SO, O, NO, N, NE. Solo el mecanismo que gira, sin base. |
| `turret_disruptor.png` | La vista independiente, de 128 × 128. |
| `disruptor_level_2.png` y `disruptor_level_3.png` | Las variantes de mejora, como las de las otras torres. |
| Pulso (efecto) | Una textura de anillo de 128 × 128 con alfa (blanco y azulado), **distinta** del aturdimiento violeta y del aura cian del Mecánico. La anima el código. |
| Ícono de la marca de supresión sobre el enemigo | 32 × 32, alfa. |

## Dirección (pedido de Lucas, 07 §9)
- Bobina Tesla de **cobre y bronce sobre hierro oscuro**, con **anillos concéntricos** como emisores.
- Lo que la distingue de la Tesla actual (bobinas con energía violeta y una esfera): **anillos horizontales apilados**, energía **blanca y azulada** y un **disco emisor arriba**, sin esfera.
- Luz arriba a la izquierda, sin sombra incrustada y legible a 64 y a 34 px.

## Pasos
1. Concepto, y esperar el **OK de Lucas** (registrarlo en `art/m51-disruptora/README.md` con la fecha y su texto).
2. Generar el atlas y las piezas. Un `pack.gd`, como el de M43, que recorte y normalice **sin repintar**.
3. Integración mínima: el `.tres` de la Disruptora (si T217 ya lo creó) apunta a los PNG. Si T217 no existe todavía, **no crear la torre**: dejar los archivos listos y anotarlo.
4. Capturas: la hoja de las 8 direcciones a 112 y a 34 px, la partida con el pulso y la Wiki.
5. Tests completos en verde.

## Hecho cuando
- El concepto aprobado está registrado.
- Los archivos tienen el formato exacto, con fuentes, prompts, manifest y capturas.
- Commit `T216: …` y PR.
