# M24 · Formato de la próxima entrega artística

Qué hace falta para pasar de los conceptos estáticos de la primera tanda (un solo PNG por criatura o torre) a arte que se mueve y se ve bien en todas las direcciones. Es una lista de pedidos para quien produzca el arte; el juego todavía no usa nada de esto (D-050).

## Qué se integró y qué límites tiene

- Normal (diablillo rojo), Rápido (bestia turquesa) y Tanque (ogro verde) son **una sola imagen** cada uno, con la luz arriba a la izquierda y mirando hacia un solo lado.
- No se reflejan en espejo al caminar a la izquierda (el espejo cambiaría la luz de lado), así que **miran siempre hacia el mismo lado**. Se mueven solo con el bamboleo del juego (estirarse y aplastarse).
- No tienen cuadros de caminar, de daño ni de desaparición.

## Monstruos: lo que falta pedir

Para cada criatura (empezar por Normal, Rápido y Tanque):

1. **Cuatro vistas** con la **misma luz** (arriba a la izquierda, fija): derecha, izquierda, hacia abajo (de frente a la cámara) y hacia arriba (de espaldas). Con ellas el juego puede elegir la vista según el rumbo sin reflejar nada. Si después se ven pobres, se pasa a ocho (agregar las cuatro diagonales).
2. **Caminar:** un ciclo corto de **4 a 6 cuadros** por vista, en bucle, con los pies tocando el suelo siempre en la misma altura.
3. **Reacción al golpe** (1 o 2 cuadros por vista, o una sola pose que se pueda mostrar 0,08 s) y **desaparición** (4 a 6 cuadros que terminen en transparente).
4. **Formato de los archivos:** PNG RGBA con fondo realmente transparente (sin fondo de ajedrez dibujado), un archivo por vista y acción, o una hoja con cuadrícula regular. Cuadros de **256×256**, cuerpo a **~70 % del alto** y **pies al 74,5 % del alto**, centrado horizontalmente (la herramienta `tools/prepare_monster_sprites.gd` enmarca así hoy). Sin sombra dibujada (la pone el juego) y sin texto.
5. **Legibilidad:** probar a **34 px** de alto y sobre el verde del mapa. No usar naranja brillante en el cuerpo (se confunde con la quemadura) ni celeste (se confunde con la ralentización).
6. Los conceptos `fast_B` (púrpura) y `tank_B` (grietas de lava) quedan como ideas para enemigos futuros con otra función.

## Torres: evoluciones de nivel 2 y 3

Las hojas de `upgrades_comparison.png` son de **una sola dirección** y no sirven como atlas. Para integrarlas, por cada torre y por cada nivel (2 y 3):

1. **Atlas de ocho vistas** de 512×256 (4 columnas × 2 filas de 128×128), en el **mismo orden** que los atlas de M23: derecha, abajo-derecha, abajo, abajo-izquierda, izquierda, arriba-izquierda, arriba, arriba-derecha (guía de arte §7).
2. **Mismo mecanismo, misma silueta y misma luz** que el nivel 1 aprobado: solo cambian piezas (refuerzos, bandas de metal) y un acento de color con brillo localizado. Sin halos que tapen enemigos o proyectiles.
3. El **nivel 1 no se reemplaza**: se conserva el atlas actual de `assets/sprites/towers/rendered/`.
4. Se entregan además el **mecanismo con la vista hacia arriba** de cada nivel (para el HUD) y, si cambian, el proyectil y el punto de salida.

Cuando lleguen, se suma a `TowerData` un atlas por nivel (campo opcional: si falta, se usa el del nivel 1) y se agrega un test que revise que cada atlas tiene ocho cuadros con cuerpo y margen transparente.
