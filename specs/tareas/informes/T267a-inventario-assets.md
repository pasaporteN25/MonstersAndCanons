# T267a · Inventario de assets de los niveles 1 a 5 y 11 a 15

> Generado el 2026-10-16 con un script de una corrida sobre `data/levels/` (la tarea mecánica O1; la hizo Claude porque el modelo local se trabó). Solo lectura; no propone nada. Cada `dibujo` es `assets/sprites/map/<id>.svg` y el suelo es `assets/tiles/rendered/ground_<tema>.png`.

| Nivel | Nombre | Tema (suelo) | Decoración (`dibujo`) | Removibles | Extracción | Enemigos distintos |
|---|---|---|---|---|---|---|
| 1 | Pradera | `ground_pradera.png` | `agua`, `estatua`, `flores` | — | — | armored, boss, fast, flyer, normal, tank |
| 2 | Desfiladero | `ground_pradera.png` | `agua`, `columna` | — | — | armored, boss, fast, flyer, normal, tank |
| 3 | Encrucijada | `ground_pradera.png` | `agua`, `estatua`, `flores` | — | — | armored, boss, fast, flyer, normal, tank |
| 4 | Espiral | `ground_pradera.png` | `agua`, `flores`, `tronco` | — | — | armored, boss, fast, flyer, normal, tank |
| 5 | Fortaleza | `ground_pradera.png` | `estatua`, `flores` | — | — | armored, boss, fast, flyer, normal, tank |
| 11 | Puesto seco | `ground_desierto.png` | `agua`, `roca_marcada` | escombro, roca | mina | armored, boss, fast, flyer, guardian, healer, normal, rammer, shaman, spider, tank, thief, troll |
| 12 | El cañadón | `ground_desierto.png` | `roca_marcada` | escombro, roca | bosque_explotable | armored, boss, fast, flyer, guardian, healer, mirror, normal, rammer, shaman, spider, tank, thief, troll |
| 13 | Paso alto | `ground_nieve.png` | `hielo`, `roca_marcada` | escombro, roca | bosque_explotable, mina | armored, boss, cargador, fast, flyer, guardian, healer, mirror, normal, rammer, ratero, shaman, spider, tank, thief, troll |
| 14 | Los poblados vacíos | `ground_ruinas.png` | `campamento_vacio`, `columna`, `simbolo_ruina` | escombro, roca | bosque_explotable, mina | armored, boss, cargador, fast, flyer, guardian, healer, mirror, normal, rammer, ratero, shaman, spider, tank, thief, troll |
| 15 | La Central | `ground_pradera.png` | `campamento_vacio`, `central_1`, `central_2`, `central_3`, `central_4`, `roca_marcada`, `supply_cart`, `supply_depot`, `supply_line_pole` | escombro | bosque_explotable, mina | armored, colossus, fast, flyer, guardian, healer, mirror, normal, rammer, shaman, spider, tank, thief, troll |

**Nota:** `agua` y `hielo` no tienen archivo SVG: son terrenos que se dibujan por código (`scripts/logic/map_drawings.gd`, `scenes/levels/level_decor.gd`, de tipo `KIND_GROUND`). Todas las demás rutas existen. **Dato útil para T267:** los niveles 1 a 5 y el 15 comparten el mismo suelo `ground_pradera`, y los niveles 11 y 12 comparten `ground_desierto`.
