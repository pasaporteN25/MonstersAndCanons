# T234 · Nivel 15 · La Central y epílogo

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (es el cierre del juego)
- **Depende de:** T232 (nivel 14), T228 (pantallas) y T243 (diseño del jefe supremo: **hecha, 2026-10-09**, el Coloso). T233 y T244 son opcionales: sin su arte, se usa el provisional · **Compuerta:** la G5 llega en T238 · **Tamaño:** mediano

## Leer
- La ficha del 15 (**§7.17** de la spec, RF-480), **M52** (RF-471 y RF-472: epílogo y créditos; RF-474 y RF-475), D-090 y D-091, `specs/11-textos-lore.md` (lugar, entrada, victoria, **epílogo** y **créditos**), Q-32 ✎, **RF-481 a RF-484, D-092 y el plan «M54 / T243»** (el Coloso), y el 07 §1 y §12.
- Los Resultados de T229 a T232 (método y curva de dificultad).
- `data/enemies/boss.tres` (Soberano, **que el 15 no trae**), `spider.tres` y `spiderling.tres` (el mismo mecanismo que el Coloso: `death_spawn`) y cómo funcionan los grupos con `desde` y `entrada` (RF-203).

## Objetivo
- El **último nivel**: mapa grande (hasta 26 × 12), la central de energía y la cadena de abastecimiento como elementos del mapa, y todas las torres disponibles.
- **Final:** el **Coloso** (T243, RF-481 a RF-484) con una **escolta coordinada** (Guardián + Curandero + Chamán que entran juntos y en formación por varias entradas), en las últimas oleadas. **Un Coloso en cada una de las oleadas 26, 28 y 30; la escolta completa solo en la 30** (valores iniciales: las cantidades, los `desde` y las entradas las cierra esta tarea con el bot). Lo que **no se mueve:** el Coloso sale **siempre en la 30**, la escolta completa **no viene antes**, el Soberano **no** está en el nivel y el Coloso **debuta sin otra amenaza nueva** en la 26 y con tiempo de preparación (RF-475, punto 1).
- **Los dos enemigos** (solo datos, sin código): `data/enemies/colossus.tres` y `colossus_shard.tres`, con los números de RF-481 (Coloso: 600 de vida, 0.5, armadura 5, 12 vidas, 200 de oro, resiste la mitad de la ralentización, suelta 3 Pedazos; Pedazo: 180, 1.0, sin armadura, 4 vidas, 30 de oro). Copiarlos de `spider.tres` y `spiderling.tres`. **El Pedazo no se nombra en ninguna oleada.** Textura y atlas: los de T244 si ya están; si no, **arte provisional hecho en código** (Q-40) y se anota.
- Victoria: el botón **«Epílogo»** de la pantalla de victoria (T228 deja `epilogue_pressed`), la pantalla de **epílogo** con la imagen de T233 y el texto de 4 líneas, y la pantalla de **créditos** (`data/creditos.json`).

## Pasos
1. Mapa, oleadas y textos según la ficha.
2. Bot, 5 semillas, las 5 estrategias. **Regla de oro.** Tiene que ser **el más difícil** de la campaña, sin estar por encima de lo que gana `mix` con apoyo y mejoras: comparar con el 14.
   - **El balance del Coloso va primero por los Pedazos:** con ≈ 1330 de vida cada uno y velocidad 1.0, el bot puede dejar pasar los tres a la vez (12 vidas de golpe). Es lo primero a medir; después la armadura y la vida del Coloso. Todo cambio de número va a los `.tres` y al Resultado.
   - **Si cambia la cantidad de Pedazos o las vidas** (la cuenta 3 × 4 = 12 es a propósito), se corrige también la frase de presentación del Coloso (RF-484) y el párrafo del artículo «La Central» en `specs/11-textos-lore.md`, que dicen «tres».
   - Confirmar que **`check_level`, el bot y los tests** aceptan un enemigo que está en `data/enemies/` pero no en ninguna oleada (el Pedazo; la Cría ya es así) y que el bot no se rompe con el Coloso.
   - **Las 12 vidas son decisión de Lucas:** si con el bot el 15 se pierde casi siempre por una sola fuga, no se baja el número por cuenta propia: se le informa con la tabla.
3. Ganar el 15:
   - muestra el epílogo;
   - la campaña queda **terminada sin ningún campo nuevo en el guardado** (se deduce de los 15 niveles completados, RF-471): un test compara el guardado antes y después de ver el epílogo;
   - "Siguiente nivel" no aparece y en su lugar está "Epílogo"; en modos, comunidad y editor tampoco aparece.
4. Captura del mapa, del combate final (**el Coloso y sus Pedazos**) y del epílogo.
5. **Pruebas del Coloso** (plan «M54 / T243»): los datos; partirse (3 Pedazos con la vida de la oleada, la oleada no termina hasta que mueren o llegan los 3); llegar sin partirse (12 vidas y nada que soltar); la armadura y la ralentización; que solo el 15 lo nombre; las entradas de la Wiki (y la corona solo en el Coloso); y el párrafo del Coloso en «La Central».

## Hecho cuando
Campaña de 15 niveles completa con el bot, epílogo visible y todos los tests en verde. `README.md` y `CHANGELOG.md` ("15 niveles" y el Coloso, que es lo que ve quien juega), Resultado, commit y PR.
