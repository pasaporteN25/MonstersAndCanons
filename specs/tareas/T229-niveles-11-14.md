# T229 a T232 · Niveles 11, 12, 13 y 14 (una tarea por nivel, con la misma ficha)

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Tareas:** **T229** = nivel 11 · **T230** = 12 · **T231** = 13 · **T232** = 14. **En orden**: cada una depende de la anterior, porque la dificultad sube en escalera.
- **Depende de:** T217 (Disruptora), T227 (fichas aprobadas del 11 al 15) y T228 (textos) · **Compuerta:** ninguna (la G5 llega en T238) · **Tamaño:** mediano cada una

## Leer
- **La ficha de tu nivel en la spec §7** (escrita en T227): manda sobre este documento.
- El plan 08 §5, bloque 3, como resumen.
- El RF de la regla de oro de M50, las respuestas Q-29 y Q-35, y los Resultados de T223 a T225 (método).
- Los enemigos que debutan: §6.3 de la spec, Chamán (RF-280 y siguientes) y Espejo. Sus datos están en `data/enemies/shaman.tres` y `mirror.tres`. **Nunca aparecieron en la campaña**: revisar en el Resultado de M18 cómo se probaron.

## Resumen de cada nivel (el detalle está en la ficha de la spec)
| Tarea | Nivel | Tema | Debut o novedad | Torres |
|---|---|---|---|---|
| T229 | 11 · Puesto seco | `desierto` | **Chamán** (aturde torres) y la Disruptora disponible | `"torres"` **sin la Básica** (Q-29), más la Disruptora y el Mortero |
| T230 | 12 · El cañadón | `desierto` | **Espejo** (rebote) | Ídem |
| T231 | 13 · Paso alto | `nieve` | Grupos coordinados (escolta Guardián + Curandero + Chamán) y dos entradas | Ídem |
| T232 | 14 · Los poblados vacíos | `ruinas` | Todo junto; las señales culminan | Ídem |

## Pasos (para cada nivel)
1. Armar el mapa según la ficha: removibles, punto de extracción y señales. `check_level` sin errores.
2. Las oleadas:
   - el debut **solo**, con preparación, antes de combinarlo (07 §4: "enseñar antes de exigir combinaciones");
   - subir la dificultad respecto del nivel anterior: comparar su tabla de bot.
3. Bot, 5 semillas, las 5 estrategias:
   - **`sin_recursos` gana en al menos 4 de 5;**
   - con la Disruptora rinde mejor contra las auras;
   - sin la Básica, la apertura sigue siendo viable (oleadas 1 a 3 sin perder vidas en al menos 4 de 5).
4. Cargar los textos aprobados en T227 para ese nivel. Sumarlo a `campaign.json` y hacer una captura.

## Hecho cuando (para cada nivel)
- Nivel en la campaña, tabla del bot en el Resultado, captura y todos los tests en verde.
- Resultado, `CHANGELOG.md`, commit `T2xx: nivel N …` y PR.

## Frenar si
- El Chamán o el Espejo se comportan en la campaña distinto de lo que dice su RF (un error en un sistema viejo va a una tarea aparte).
- La regla de oro no se cumple sin cambiar la ficha aprobada.
