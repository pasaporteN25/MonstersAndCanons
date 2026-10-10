# T258 · Asedio con los 15 mapas y porcentaje de vida por mapa (formato, datos, bot y tests)

> **Estado: PENDIENTE. Sin compuerta:** Lucas aprobó la estructura el 2026-10-10 (conservar los 15 mapas y la campaña, 115 % global y una tabla opcional por id de mapa). La spec es **M56** (`01-spec.md`, RF-492 a RF-496), la decisión es **D-095** (que revisa D-078) y la medición que la respalda, `specs/tareas/informes/T255-curva-dificultad-asedio.md` (§5.3 y §7). Esta ficha **manda sobre lo que el informe deja abierto**; si algo de acá contradice la spec, manda la spec.

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio** · **Tamaño:** mediano (una clave nueva en `ModePacks`, un archivo de datos, una opción del bot, tests y documentos)
- **Depende de:** T256 (**hecha**) y T255 (**hecha**). **Resuelve la decisión que dejó T235** (los mapas 10 a 15 de Asedio); las solapas con más de dos modos propios y los récords de los modos **siguen siendo de T235** y no son de esta tarea.
- **Orden con T253 (La Cuadrilla):** conviene **después de T253**, porque la Cuadrilla entra en los niveles 7, 10, 13 y 14 y sus cuatro porcentajes salen «a remedir» (RF-494). **Si T253 todavía no está hecha**, T258 hace igual el formato, la validación, el bot, los datos y los tests con la tabla inicial, y **deja esas cuatro filas marcadas «a remedir»** en el Resultado y en el plan; la remedición la hace entonces una tarea de seguimiento que se abre cuando T253 termine (no se la inventa acá).
- **Cuándo:** **antes de T238 (G5)**, que es cuando Lucas juega del 1 al 15.

## Por qué existe
Asedio tiene hoy los mapas 1 a 9 con 115 % de vida para todos. El bot **no gana 6 de los 15** al 115 % ni aun mejorando torres, y T235 frenó el pase a 15 mapas por eso. T255 midió que cada mapa pide **su** porcentaje (de 101 % a 118 %) y que con una tabla por mapa el bot gana **75 de 75** partidas, sin tocar la campaña. T256 lo especificó. Falta lo que lo hace existir: la clave en el `modo.json`, su validación, los 15 mapas, la opción del bot para medirlo y los tests.

## Leer
- **M56 entero** (`01-spec.md`, desde «### M56»): RF-492 a RF-496 y su criterio de aceptación. D-095 y la «Revisada por D-095» de D-078.
- **El informe de T255**, sobre todo §2 (las dos reglas de mejoras), §5.3 (el perfil) y §7 (cómo repetirlo y el parche de §7.1).
- RF-388 a RF-392 (M49), RF-391 con su nota de T256, RF-396 (modo y nivel juntos), RF-432 y RF-475 (la referencia que **no** cambia), RF-468 y RF-429 (sin textos ni piezas en los modos).
- `scripts/logic/mode_packs.gd` (`KEYS`, `RULE_KEYS`, `_read_settings`, `_read_rules`, `_whole`, `_read_map`, `_apply`, `add_map`), `scripts/data/level_data.gd` (`enemy_health_percent`, **ya existe**), `data/modos/asedio/modo.json`.
- `tools/balance_sim.gd` y `scripts/logic/balance_args.gd` (cómo se leen `modo=`, `levels=` y `seeds=`), y T254 en `03-tareas.md` (las herramientas de `tools/` tienen que compilar con `--check-only`, sin autoloads).
- `tests/test_mode_packs.gd`, `tests/test_mode_flow.gd`, `tests/test_mode_select.gd` y `tests/test_editor_modes.gd`.
- `.claude/rules/gdscript.md` (tabuladores, tipos estáticos, **números de balance en `data/`**), `.claude/rules/tests.md` y `.claude/rules/datos.md`.

## Qué hay que hacer

1. **Comprobar dependencias y el estado de T253** (README §1). Mirar `specs/03-tareas.md`: si T253 está en `[x]`, las filas 7, 10, 13 y 14 se miden con sus datos finales; si no, quedan «a remedir». En los dos casos, **antes de medir** correr `git log --oneline -3 -- data/levels/` y anotar sobre qué datos de nivel se midió.

2. **La clave nueva** (`scripts/logic/mode_packs.gd`), con la forma de **RF-492**:
   - Constante `RULE_HEALTH_BY_MAP: String = "vida_monstruos_por_mapa_%"` y se suma a `RULE_KEYS` (así el aviso de «clave desconocida» la lista).
   - `_read_rules` recibe la lista de mapas que `_read_settings` ya leyó (los mapas se leen **antes** que las reglas) y valida, **con un mensaje en castellano que nombra el mapa o el valor**:
     1. la tabla es un **objeto** (`"vida_monstruos_por_mapa_%" tiene que estar entre { }, como {"level_01": 105}`);
     2. cada clave **está en `"mapas"`** (un id desconocido es **error**, no se ignora; el mensaje lista los ids del modo);
     3. cada valor es **entero entre `MIN_PERCENT` y `MAX_PERCENT`**: reusar `_whole` (así el rango y el mensaje son los mismos de `vida_monstruos_%`).
   - `_apply(level, settings, map_id)` pasa a recibir el id del mapa (`_read_map` ya lo tiene): si la tabla trae `map_id`, **ese** porcentaje va a `level.enemy_health_percent`; si no, el global; si no, queda 100. **No se toca** el oro, las vidas ni las torres. Tabla vacía `{ }`: válida y sin efecto.
   - **No se cambia** `LevelFile`, `LevelData`, `WaveSpawner` ni `Rules`: el porcentaje llega por el mismo camino que el global (`enemy_health_percent` → generador de oleadas).
   - `add_map` y `create` **ya conservan** las claves de `reglas` al reescribir (`add_map` lee, suma el mapa y vuelve a escribir todo el diccionario): **comprobarlo con un test**, no darlo por hecho. Si perdiera la tabla, arreglarlo acá.
   - Actualizar el comentario del encabezado del archivo con la clave nueva.

3. **Los datos** (`data/modos/asedio/modo.json`): `"mapas"` con `level_01` a `level_15` en orden, `"oro_inicial_%": 100`, `"vida_monstruos_%": 115` (**sin cambios**) y la tabla con **las 13 excepciones** (los mapas 4 y 15 **no** se escriben: toman el global). **Valores iniciales de RF-494; no se cambian a ojo:**

   ```json
   "vida_monstruos_por_mapa_%": {
   	"level_01": 105, "level_02": 105, "level_03": 105,
   	"level_05": 108, "level_06": 101, "level_07": 103,
   	"level_08": 101, "level_09": 101, "level_10": 118,
   	"level_11": 101, "level_12": 110, "level_13": 101,
   	"level_14": 118
   }
   ```

   Actualizar la `"descripcion"` del modo si dice «nueve» (máximo 200 letras, RF-388). **No se crea ninguna copia de mapa** en `data/modos/asedio/`.

4. **El bot** (`tools/balance_sim.gd` y, si hace falta, `BalanceArgs`), **sin cambiar ningún resultado de hoy** (la opción nueva está apagada por omisión):
   - **`mejoras=llenar`**: cuando ya no queda ninguna casilla construible libre, una mejora por frame: la torre de **menor nivel** y, entre ellas, la de **menor costo de mejora**, pagada por `BuildController.try_upgrade` (sin oro ni daño gratis). Es la regla de T255 §2; el parche de **§7.1 del informe** es la base (hay que **reaplicarlo sobre el `balance_sim.gd` actual**: el informe lo aplicó sobre otra revisión). No vende, no repara, no cambia objetivos.
   - **`mejoras=temprana`**: lo mismo, pero **desde que hay tres torres construidas**, aunque queden casillas libres (T255 §2.1 y §7, última tabla).
   - **Una política por mapa** en un **archivo de datos de la herramienta** (por ejemplo `tools/asedio_politicas.json`; no en el código ni en el `modo.json`: RF-495, punto 7): `level_02` con `smart` + `llenar`, `level_04` con `sin_recursos` + `temprana` y los demás con `sin_recursos` + `llenar`. Una opción (`perfil=asedio`, a criterio de quien programa) juega los 15 mapas del modo oficial con **5 semillas** y esas políticas, imprime la tabla, el **promedio de vidas por bloque** (1–5, 6–10, 11–15) y termina con **código 1** si alguna fila no cumple RF-495 (gana las 5 y **3 vidas o más**) o si los promedios por bloque **suben**. Como `check_rule=1`, para que lo corra una tarea y la regresión final.
   - **Cada corrida imprime qué variante usó** (estrategia, mejoras, porcentaje efectivo, semillas): RF-495, punto 6.
   - **Tiene que compilar con `--check-only`** (T254): nada que nombre autoloads o tipos de `game.gd` en el código de la herramienta.
   - Actualizar el encabezado de `balance_sim.gd` (uso de las opciones nuevas).

5. **Medir** (una partida por proceso; se pueden correr varias a la vez, cada una tarda 1 a 2 minutos):
   ```bash
   godot --headless --import
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos modo=asedio levels=1-15 seeds=5 mejoras=llenar
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart modo=asedio level=2 seeds=5 mejoras=llenar
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos modo=asedio level=4 seeds=5 mejoras=temprana
   godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1   # la regla de oro de la campaña, sin cambios
   ```
   - **Referencia medida** (T255, mismas políticas y semillas): ver la tabla de RF-494 (75 de 75; mínimo V5 en el 15; promedios 16,00 · 11,72 · 6,84). Si algo sale **bastante peor** con los mismos números, **algo cambió** (en el nivel, en el bot o en la tabla): parar y mirarlo antes de ajustar.
   - **Las filas 7, 10, 13 y 14 con La Cuadrilla** (si T253 está hecha): medirlas y anotar la tabla. Si una **no** cumple RF-495, bajar **solo ese porcentaje**, de a poco y repitiendo las **cinco** semillas, **sin bajar de 101 %** (RF-495, punto 5). Si ni 101 % pasa, **no se toca nada más**: se informa a Lucas con la tabla.
   - **Se miden también** la campaña (`check_rule=1`) y el Asedio 7 con la política de su fila, para dejar en el Resultado que **la campaña no se movió**.

6. **Tests** (`.claude/rules/tests.md`: nada que cambie de escena, guardados en `user://test_*.json`, carpetas `user://test_*`):
   - **`tests/test_mode_packs.gd`** (modelo: sus pruebas de errores y de reglas): (1) con tabla y global, el mapa de la tabla toma **su** porcentaje y los demás el **global**; (2) con tabla y **sin** global, los demás **100**; (3) **cada motivo de error** (id que no está en `mapas`, `105.5`, `"105"`, `5`, `1001`, una lista en lugar de un objeto) dice su motivo y el modo queda con error sin tocar a los otros modos; (4) la tabla vacía es válida; (5) un `modo.json` **sin** tabla carga **igual que antes** (los tests de hoy tienen que seguir en verde sin tocarlos); (6) el oro y las vidas del modo no cambian por la tabla; (7) `add_map` sobre un modo con tabla **conserva** la tabla y los enteros siguen siendo enteros.
   - **`tests/test_mode_packs.gd:69`** y todo test que cuente los mapas de Asedio (`git grep -n "level_09\|mapas 1 a 9\|nueve" tests/`): pasan de 9 a 15.
   - **El Asedio oficial real** (en `test_mode_packs.gd` o `test_mode_flow.gd`): lista `level_01` a `level_15` en orden; cada mapa tiene **las mismas oleadas** que el de la campaña (mismo número de oleadas, mismos grupos); el `enemy_health_percent` efectivo de cada uno **es el de la tabla de RF-494** (los 15 números van escritos en el test: es el que cuida que el archivo y la spec digan lo mismo) y **todos son mayores que 100**; el 4 y el 15 valen 115; oro y vidas son los de la campaña; ningún mapa trae error.
   - **`tests/test_mode_flow.gd`**: la vida del modo **por mapa** llega al generador (el mismo caso que ya prueba el global) y ganar el 9 de Asedio abre el 10. Los tests de «sin piezas ni textos» (RF-429, RF-468) que T235 dejó **cubren los 15** y no solo del 1 al 9.
   - **`tests/test_mode_select.gd`**: la solapa Asedio muestra 15 tarjetas (el primero abierto, los demás bloqueados en un guardado nuevo).
   - **`tests/test_editor_modes.gd`**: guardar un mapa en un modo propio que trae la tabla no la pierde.
   - **Las opciones nuevas del bot**: si hay lógica pura (leer la política de un archivo, elegir la torre a mejorar), un test chico; el resto se prueba corriéndolo.
   - Correr **toda** la suite y mirar la salida completa: un test que pasa pero imprime `SCRIPT ERROR` **es un fallo**. Tiene que haber **más** tests en verde que al empezar (1524 en T255), no menos.

7. **Documentos** (CLAUDE.md: «se actualiza en todos los lugares»):
   - **`CONTENIDO.md`:** la tabla de `reglas` del `modo.json` (§ de modos, ~línea 531) con la clave nueva y un ejemplo; el párrafo «**Asedio:**» (~546: «mapas 1 a 9», «115 % y el mismo oro») con los 15 mapas y la tabla; la línea de `modo=asedio` (~543) con las opciones de mejoras; y que **una versión anterior rechaza un modo con la tabla**.
   - **`README.md`** (~162 y ~294: «nueve mapas», «vida 115 %») y **`ONBOARDING.md`** (~474: «Tiene nueve mapas»; cómo probar los mapas 10 a 15 y el porcentaje de cada uno).
   - **`CHANGELOG.md`:** lo que ve quien juega: Asedio con los 15 mapas y una dificultad propia por mapa; los modos con la tabla no se abren en versiones anteriores. **No** repetir que «sigue con los mapas 1 a 9» (línea 92 es de una versión anterior: no se reescribe).
   - **Spec y plan:** en `01-spec.md`, M56 pasa de «sin datos ni código» a **hecha en T258**, y se corrigen las notas de T256 que dicen «hasta que T258 lo programe» (encabezado de M49 y RF-391); `02-plan-tecnico.md` (M56: estado y lo que cambió al programarla), la entrada de T235 en `03-tareas.md` (una línea: **los 15 mapas los hizo T258**; quedan las solapas y los récords) y `08-plan-cierre-v1.md`.

## Hecho cuando
- `modo.json` de Asedio con **los 15 mapas**, `vida_monstruos_%` en 115 y la tabla de **13 entradas** de RF-494; sin ninguna copia de mapa.
- `ModePacks` lee y valida `"vida_monstruos_por_mapa_%"` con los tres motivos de RF-492; los modos que ya existen cargan igual; `add_map` conserva la tabla.
- **El bot, 5 semillas, política fija por mapa**: cada fila gana las cinco con **3 vidas o más** y los promedios por bloque **no suben**; la tabla completa y la **variante usada** quedan en el Resultado. **La campaña (`check_rule=1`) no se movió.**
- Las filas **7, 10, 13 y 14**: medidas con La Cuadrilla (T253 hecha) o dejadas «a remedir» **diciéndolo en el Resultado** y en el plan.
- Los tests de arriba, **toda la suite en verde y sin `SCRIPT ERROR`** y con más tests que al empezar.
- Documentos actualizados; el Resultado dice honestamente **qué se midió y qué no** (una persona no jugó nada; el bot no es una persona).
- Commit **`T258: …`** en una rama `feature/t258-asedio-por-mapa` y `git push` de esa rama (nunca a `main`).

## Frenar si
- **Una fila no pasa ni con 101 %.** Se informa a Lucas con la tabla; **no** se toca la campaña, el nivel ni el bot para que dé.
- **El porcentaje por mapa pide un cambio en `LevelFile`, `WaveSpawner`, `Rules` o `enemy_health_percent`** (algo más que leer una clave y pasarla): esa no es esta tarea; va a §13 y se pregunta.
- **Lucas pide editar la tabla desde el editor o el selector** (P2 de M56): es una tarea 📜 aparte.
- **Un cambio de `aumento_vida`, de oleadas o de entradas de un nivel de la campaña** parece necesario para que un mapa pase: no se hace; se informa.
- **`add_map` o el editor pierden claves de `reglas`** y arreglarlo exige tocar el guardado del editor más allá de `ModePacks`: se anota y se pregunta.
- **Los mapas 10 a 15 de Asedio muestran textos, cartel de entrada o piezas** (RF-468, RF-429): eso es un error del modo, no de esta tarea, pero **no se da por cerrada** hasta que se arregle o se pregunte.
