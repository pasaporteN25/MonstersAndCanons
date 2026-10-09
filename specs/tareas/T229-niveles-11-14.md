# T229 a T232 · Niveles 11, 12, 13 y 14 (una tarea por nivel, con la misma ficha)

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Tareas:** **T229** = nivel 11 · **T230** = 12 · **T231** = 13 · **T232** = 14. **En orden**: cada una depende de la anterior, porque la dificultad sube en escalera.
- **Depende de:** T217 (Disruptora), T227 (fichas **con el OK de Lucas**) y T228 (textos) · **Compuerta:** las marcas **«A REVISAR TRAS G4»** de las fichas tienen que estar confirmadas o corregidas por Lucas (T226) antes de empezar; la G5 llega en T238 · **Tamaño:** mediano cada una

## Leer
- **La ficha de tu nivel en la spec**: §7.13 (nivel 11), §7.14 (12), §7.15 (13) y §7.16 (14), con sus RF de campaña (RF-476 a RF-479). Manda sobre este documento. Antes, **M52, RF-474 y RF-475** (rotación y reglas comunes) y D-091.
- **`specs/11-textos-lore.md`**: los textos de tu nivel, copiados tal cual.
- El plan 08 §5, bloque 3, como resumen.
- El RF de la regla de oro de M50, las respuestas Q-29 y Q-35, y los Resultados de T223 a T225 (método).
- Los enemigos que debutan: §6.3 de la spec, Chamán (RF-280 y siguientes) y Espejo. Sus datos están en `data/enemies/shaman.tres` y `mirror.tres`. **Nunca aparecieron en la campaña**: revisar en el Resultado de M18 cómo se probaron.

## Resumen de cada nivel (el detalle está en la ficha de la spec)
| Tarea | Nivel | Tema | Debut o novedad | Torres |
|---|---|---|---|---|
| T229 | 11 · Puesto seco | `desierto`, 24 × 11, 22 oleadas | **Chamán** (aturde torres) y la Disruptora disponible | `"torres"` de RF-474 (**sin la Básica**; con Mortero, Disruptora y Mecánico según sus colecciones) |
| T230 | 12 · El cañadón | `desierto`, 26 × 11, 24 oleadas | **Espejo** (rebote) | Ídem |
| T231 | 13 · Paso alto | `nieve`, 26 × 12, 24 oleadas | Grupos coordinados (escolta Guardián + Curandero + Chamán) y dos entradas | Ídem (sin Lanzamisiles, Q-28) |
| T232 | 14 · Los poblados vacíos | `ruinas`, 26 × 12, 26 oleadas | Todo junto; las señales culminan | Ídem |

*(Oro, vidas y aumento de vida iniciales: están en cada ficha de la spec. Son iniciales: los ajusta el bot.)*

## Pasos (para cada nivel)
1. Armar el mapa según la ficha: removibles, punto de extracción y señales. `check_level` sin errores.
2. Las oleadas:
   - el debut **solo**, con preparación, antes de combinarlo (07 §4: "enseñar antes de exigir combinaciones");
   - subir la dificultad respecto del nivel anterior: comparar su tabla de bot.
3. Bot, 5 semillas, las 5 estrategias:
   - **`sin_recursos` gana en al menos 4 de 5;**
   - con la Disruptora rinde mejor contra las auras;
   - sin la Básica, la apertura sigue siendo viable (oleadas 1 a 3 sin perder vidas en al menos 4 de 5).
4. **Solo en T229:** el Resultado trae la **tabla del bot con y sin Disruptora** (RF-475, punto 8). El balance de la Disruptora lo decide Lucas: no se toca su costo, supresión ni cadencia por cuenta de la tarea.
5. Cargar los textos aprobados (`11-textos-lore.md`) para ese nivel, en el campo `"textos"`. Sumarlo a `campaign.json` y hacer una captura.

## Hecho cuando (para cada nivel)
- Nivel en la campaña, tabla del bot en el Resultado, captura y todos los tests en verde.
- Resultado, `CHANGELOG.md`, commit `T2xx: nivel N …` y PR.

## Frenar si
- El Chamán o el Espejo se comportan en la campaña distinto de lo que dice su RF (un error en un sistema viejo va a una tarea aparte).
- La regla de oro no se cumple sin cambiar la ficha aprobada.
- Una marca **«A REVISAR TRAS G4»** de tu ficha sigue sin confirmar.
- El nivel pide un sistema nuevo (por ejemplo, un tipo de enemigo o de mapa que no existe): eso va a §13 como sugerencia, no se implementa.
