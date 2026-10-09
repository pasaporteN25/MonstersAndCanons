# T234 · Nivel 15 · La Central y epílogo

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (es el cierre del juego)
- **Depende de:** T232 (nivel 14), T228 (pantallas) y T243 (diseño del jefe supremo). T233 y T244 son opcionales: sin su arte, se usa el provisional · **Compuerta:** la G5 llega en T238 · **Tamaño:** mediano

## Leer
- La ficha del 15 (**§7.17** de la spec, RF-480), **M52** (RF-471 y RF-472: epílogo y créditos; RF-474 y RF-475), D-090 y D-091, `specs/11-textos-lore.md` (lugar, entrada, victoria, **epílogo** y **créditos**), Q-32 ✎, la spec de T243 y el 07 §1 y §12.
- Los Resultados de T229 a T232 (método y curva de dificultad).
- `data/enemies/boss.tres` (Soberano) y cómo funcionan los grupos con `desde` y `entrada` (RF-203).

## Objetivo
- El **último nivel**: mapa grande (hasta 26 × 12), la central de energía y la cadena de abastecimiento como elementos del mapa, y todas las torres disponibles.
- **Final:** el **jefe supremo nuevo** (T243) con una **escolta coordinada** (Guardián + Curandero + Chamán que entran juntos y en formación por varias entradas), en las últimas oleadas.
- Victoria: el botón **«Epílogo»** de la pantalla de victoria (T228 deja `epilogue_pressed`), la pantalla de **epílogo** con la imagen de T233 y el texto de 4 líneas, y la pantalla de **créditos** (`data/creditos.json`).

## Pasos
1. Mapa, oleadas y textos según la ficha.
2. Bot, 5 semillas, las 5 estrategias. **Regla de oro.** Tiene que ser **el más difícil** de la campaña, sin estar por encima de lo que gana `mix` con apoyo y mejoras: comparar con el 14.
3. Ganar el 15:
   - muestra el epílogo;
   - la campaña queda **terminada sin ningún campo nuevo en el guardado** (se deduce de los 15 niveles completados, RF-471): un test compara el guardado antes y después de ver el epílogo;
   - "Siguiente nivel" no aparece y en su lugar está "Epílogo"; en modos, comunidad y editor tampoco aparece.
4. Captura del mapa, del combate final y del epílogo.

## Hecho cuando
Campaña de 15 niveles completa con el bot, epílogo visible y todos los tests en verde. `README.md` y `CHANGELOG.md` ("15 niveles"), Resultado, commit y PR.
