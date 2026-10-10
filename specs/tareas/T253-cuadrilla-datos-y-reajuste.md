# T253 · Datos y reajuste de La Cuadrilla (niveles 7, 10, 13 y 14)

> **Estado: PENDIENTE, a la espera del OK de Lucas a P1 de M55** (qué niveles). La spec es **M55** (`01-spec.md`, RF-485 a RF-491), la decisión es **D-094** y la medición que la respalda, `specs/tareas/informes/T252-medicion-cuadrilla.md`. Esta ficha **manda sobre lo que el informe deja abierto**; si algo de acá contradice la spec, manda la spec.

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** · **Tamaño:** mediano (dos archivos de datos, cuatro niveles, un artículo, tests y el bot)
- **Depende de:** T252 (**hecha**) · **Compuerta:** 🚦 Lucas contestó **P1** (niveles), **P2** (Asedio 7), **P4** (nombres) y **P5** (frases) de M55; **P3** (el texto del artículo) solo hace falta para cargarlo · **El arte (T254) no bloquea:** se usa arte provisional.
- **Cuándo:** **antes de T238 (G5)**, que es cuando Lucas juega del 1 al 15. Toca niveles que se ajustaron al milímetro (el 13 y el 14 están a 1 punto del borde), así que **no se deja para después de que él los juegue**.

## Por qué existe
Lucas eligió **La Cuadrilla** (Rateros y Cargador) para la V1 (D-094). T252 la especificó y midió **dónde entra sin romper la regla de oro**. Falta lo que hace que exista en el juego: los dos `.tres`, las cuatro apariciones por nivel, el reajuste con el bot, el artículo de la Wiki, los tests y los documentos. **No hay sistema ni campo nuevo**: el robo ya existe (RF-363).

## Leer
- **M55 entero** (`01-spec.md`, desde «### M55»): RF-485 a RF-491 y su criterio de aceptación. D-094.
- **El informe de T252**, sobre todo §2 (tablas por semilla), §3 (el criterio), §4 (oro robado) y el apéndice (el generador de niveles).
- RF-432 y RF-475 (regla de oro y reglas comunes), RF-453 (el 10 «no estrena enemigos»), RF-203 (grupos, `desde`, `entrada`), RF-363 y RF-364 (robo y probabilidad), RF-134 (tarjeta), RF-233 y RF-238 (Wiki), RF-469 y RF-470 (Lore).
- `data/enemies/thief.tres` (el robo), `fast.tres` y `tank.tres` (formato), `tests/test_colossus.gd` (modelo de test de dos enemigos nuevos), `tests/test_lore_wiki.gd`.
- `10-universo.md` §4.2 y `11-textos-lore.md` §4.11.

## Qué hay que hacer

1. **Comprobar la compuerta** (README §1, punto 2). Si Lucas cambió los niveles de P1, **manda su respuesta**, pero mirar antes la tabla de §3 del informe: el **6 rompe la regla de oro** y el **15 no se toca**. Si pidió el 8, el 9, el 11 o el 12, hay que **avisarle** de lo medido (no es negarse: el 8 y el 9 terminan con 1 a 4 vidas con la vida igualada y el 11 y el 12 empatan con el 15).
2. **Los dos `.tres`** (`data/enemies/ratero.tres` y `cargador.tres`, `id` igual al archivo) con los números de **RF-485**. El robo se copia de `thief.tres` (`gold_drain_amount`, `gold_drain_interval`, `gold_drain_floor`); **`optional_wave_limit` queda en 0**. `description` con las frases de RF-489 (las que Lucas confirmó en P5).
   - **Arte provisional:** sin `texture` ni `walk_atlas`, el juego usa la forma geométrica (RF-156). Cada uno con **forma y `color` distintos** entre sí y del Ladrón (gris violeta `Color(0.58, 0.48, 0.72)`), para que se lea en la partida. **Comprobar** que la Wiki, la tarjeta y la barra de «próxima oleada» no se rompen sin dibujo.
3. **Las oleadas** del 7, el 10, el 13 y el 14: **cuatro apariciones** como dice la tabla de RF-487 (grupos `ratero` con `"cada": 0.4` y `cargador` con `"cada": 3.0`, sin `desde`, encima de lo que la oleada ya traía, sin `probabilidad`). Se puede usar el generador del apéndice del informe, pero **el resultado se escribe en los archivos**: la tarea no deja scripts sueltos. `check_level` sin errores en los cuatro (`godot --headless --path . -s tools/check_level.gd -- data/levels/level_07.json`).
4. **Medir con el bot**, en cada uno de los cuatro niveles, **5 semillas, `sin_recursos`** (y las otras cuatro estrategias, anotadas):
   ```bash
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos level=7 seeds=5
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1 levels=7-14   # la regla de oro (se salta los mapas sin recursos: por eso también la línea de arriba)
   ```
   Lo que tiene que dar es **RF-488**: gana al menos 4 de 5; termina con **3 vidas o más en todas**; el **14 termina con 3 o más y el 15, con 2**; el oro robado, entre 100 y 1000 (informar si no). **Una sola partida por proceso** y se pueden correr varias a la vez (cada una tarda 1 a 2 minutos).
   - **Referencia medida** (T252, `sin_recursos`, versión «suma», semillas 1 a 5):

     | Nivel | Sin la Cuadrilla | Con la Cuadrilla | Oro robado (semilla 1) |
     |---|---|---|---|
     | 7 | V16 ×5 | V5 V12 V12 V12 V12 | 326 |
     | 10 | V9 V9 V13 V7 V9 | V7 V11 V7 V9 V11 | 603 |
     | 13 | V6 ×5 | V5 ×5 | 807 |
     | 14 | V3 ×5 | V3 ×5 | 528 |

     Si lo que midas es **bastante peor** que esto con los mismos números, **algo cambió en el nivel** desde T252: parar y mirarlo antes de ajustar.
   - **El oro robado** no sale en la tabla del bot. Opciones: sumar la columna a `tools/balance_sim.gd` (es una **herramienta**: conectar `session.gold_stolen` e imprimir el total; está en el apéndice del informe) o medirlo en una copia. Si se suma al bot, **no cambia ningún resultado** del juego y va en el mismo commit.
5. **Reajuste** (si un nivel no cumple RF-488), **en este orden** y de a uno:
   1. la **cantidad** o la **oleada** de la Cuadrilla en ese nivel;
   2. **sacar relleno** (Normales, Rápidos, Voladores) de esas oleadas hasta igualar la vida (la versión «reemplazo» del informe; **ojo:** en el 8 y el 9 esa versión terminó al borde, así que es un remedio de último recurso);
   3. recién ahí, el **`aumento_vida`** del nivel, **de a un punto** y anotado.
   **No tocar** los números del Ratero ni del Cargador, ni los de ningún enemigo que ya existía, **sin avisar a Lucas con la tabla**. Si ni así pasa en un nivel, **ese nivel queda sin Cuadrilla** y se anota (es una salida válida, no un fracaso).
6. **Asedio 7:** medir `modo=asedio level=7` con `sin_recursos` y `mix`, 3 semillas, **con los datos finales** (el informe midió 11/20 con la Cuadrilla y 19 o 20 de 20 sin ella). Aplicar lo que Lucas contestó en **P2**: dejar que herede (no se toca nada) o una **copia propia del mapa 7 en `data/modos/asedio/`** sin la Cuadrilla (RF-388; solo datos). Anotar la tabla en el Resultado.
7. **La Wiki.** *(Solo si Lucas aprobó el texto, P3. Si no, se deja anotado y no se carga.)* `data/wiki/lore/la_cuadrilla.json` con `"desbloqueo": "level_07"` y el texto de `11-textos-lore.md` §4.11, **tal cual**; su `orden` queda entre el del artículo 5 y el del 6, y **los artículos 6 a 10 pasan a `orden` 7 a 11** (solo cambia ese campo). **No se toca el artículo 5.** Comprobar a mano que la entrada de cada enemigo trae la línea «Robo» y que «Dónde aparece» lista los niveles 7, 10, 13 y 14.
8. **Tests** (`.claude/rules/tests.md`: nada que cambie de escena, guardados en `user://test_*.json`):
   - **Nuevo `tests/test_cuadrilla.gd`** (modelo: `tests/test_colossus.gd`), de unas diez pruebas: (1) los dos `.tres` cargan y tienen los números de RF-485; (2) `optional_wave_limit` es 0 y **salen los 8 Rateros** de un grupo de 8 aunque haya probabilidad 1 (no el tope del Ladrón); (3) el robo respeta el **piso de 10** (con 11 de oro baja en 1) y corre **en el reloj de cada uno**; (4) un Ratero que llega a la salida quita 1 vida y no roba más; (5) un Cargador, 2; (6) **solo** los niveles 7, 10, 13 y 14 nombran `ratero` o `cargador`, con cuatro apariciones; (7) ninguna oleada con Cuadrilla trae Guardián, Curandero, Chamán, Espejo ni `boss`; (8) la Wiki Enemigos los lista y están **cerrados** con un guardado nuevo; (9) *(si se cargó)* ganar el 7 abre «La Cuadrilla» y el artículo 5 sigue igual; (10) ningún campo nuevo de `EnemyData`.
   - **Actualizar** `tests/test_lore_wiki.gd` (`:68`, «los 10 artículos» pasa a 11, y `:180`, la lista de artículos abiertos), `tests/test_enemy_visual.gd` (como el Coloso: los ciclos de caminata solo si hay atlas) y todo test que cuente los archivos de `data/enemies/`: `git grep "colossus_shard\|spiderling" tests/` antes de dar por cerrada la tarea.
   - Correr **toda** la suite y mirar la salida completa: un test que pasa pero imprime `SCRIPT ERROR` **es un fallo**. Tiene que haber **más** tests en verde que al empezar, no menos.
9. **Documentos** (CLAUDE.md: «se actualiza en todos los lugares»): `CONTENIDO.md` (los dos enemigos y el artículo), `CHANGELOG.md` (lo que ve quien juega: una banda nueva en los niveles 7, 10, 13 y 14), `README.md` y `ONBOARDING.md` **si** listan enemigos, las **fichas de los niveles 7, 10, 13 y 14** y los RF de campaña (una línea cada uno, entre ellos RF-453, RF-478 y RF-479), y el plan «M55» (`02-plan-tecnico.md`: pasar «Estado» a hecho y anotar lo que cambió al programarla).

## Hecho cuando
- `ratero.tres` y `cargador.tres` con los números de RF-485; los niveles que Lucas aprobó con sus cuatro apariciones; **`check_level` sin errores**.
- **El bot, 5 semillas, `sin_recursos`**: gana al menos 4 de 5 en cada nivel con Cuadrilla, con 3 vidas o más, **el 14 en 3 o más y el 15 sin cambios (2)**; la tabla de las cinco estrategias y el **oro robado** quedan en el Resultado.
- Asedio 7 medido y resuelto según P2.
- Los tests de arriba, **toda la suite en verde y sin `SCRIPT ERROR`**.
- Documentos actualizados; el Resultado dice honestamente **qué se midió y qué no** (una persona no jugó nada; el arte es provisional).
- Commit **`T253: …`** en una rama `feature/t253-cuadrilla-datos` y `git push` de esa rama (nunca a `main`).

## Frenar si
- **Lucas no contestó P1.** No se empieza.
- **Hace falta un campo o un sistema nuevo** (una aura, una velocidad compartida, un jefe): eso va a §13 como sugerencia y no se implementa.
- **El 14 termina con menos de 3 vidas** o el 15 pasa a ser más fácil que el 14: se informa a Lucas con la tabla antes de tocar el `aumento_vida` de nada.
- Una **aparición con aura o con jefe** parece necesaria para que el nivel pase: no se midió y no se hace sola (RF-487).
- Cargar la Cuadrilla en un nivel obliga a **cambiar números del 15** o de un enemigo que ya existía.
- La **Wiki o la tarjeta** necesitan código para mostrar dos enemigos sin dibujo: se anota y se pregunta.
