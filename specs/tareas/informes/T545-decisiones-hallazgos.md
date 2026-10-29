# T545 · Decisiones de Lucas sobre los 16 hallazgos (2026-10-28)

Respuestas de Lucas a las preguntas de T545. **Todavía no se cambió ningún texto del juego**: esto es lo que la tarea de aplicación tiene que hacer, junto con lo que Lucas elija en `T545-decisiones-redaccion.md`. La revisión de redacción texto por texto sigue en pie; estas decisiones resuelven antes los hallazgos de coherencia.

| Hallazgo | Decisión | Qué hay que hacer |
|---|---|---|
| H1 · agua del oasis y nivel 2 | **B** | No tocar el nivel 2. Suavizar la lámina 4 de la intro («…vio agua en un solo lugar de todo el planeta…») y el artículo «El oasis» para que no digan que es el único lugar con agua, y revisar el «Hay agua» del nivel 1 para que no contradiga el nivel 2. Hay que re-aprobar el texto de la lámina 4 con Lucas. |
| H2 · victoria del 15 | **C** | «Central encendida. La línea de abastecimiento está completa. La colonia ya no depende de la nave.» |
| H3 · epílogo | Ya resuelto | Tres líneas aprobadas por Lucas. |
| H4 · imagen del final | Ya resuelto | T546 (dos variantes). |
| H5 · hitos del 13 | **A** | Entrada, línea 3: «Hay rocas marcadas en el camino. Marcan un límite, y ya lo pasamos.» Victoria, línea 2: «Las rocas marcadas quedaron del lado de adentro.» (`hito.svg` ya se borró.) |
| H6 · nombres de nivel | **B** | Nombres 1–10 sin cambios; 11 a 15 pasan a «Puesto seco», «Cañadón», «Paso alto», «Poblados», «Central». Actualizar selector, tests que citan nombres y documentos. Los nombres de los niveles 11–15 también los ven T534 y T545 al traducir. |
| H7 · nivel 14 | **A** | Entrada, línea 2: «Los fogones están armados y no se ve a nadie.» El nombre pasa a «Poblados» por H6-B. |
| H8 · Jefe y Soberano | Texto de Lucas | En el juego es «el Jefe». El artículo «El Soberano» aclara que los colonos **oyeron hablar a los monstruos de un «Soberano»** y nadie sabía si existía hasta el final. Redactar la frase y mostrarla a Lucas antes de cargar. |
| H9 · dónde queda la Central | **A** | El artículo dice «el valle de más al este» o «el último valle», y se aclara cuál es «el valle» de la victoria del 13. |
| H10 · voz | Dejar la mezcla | Sin cambios. |
| H11 · nivel 11 | Sí | Victoria: «Informe del puesto seco: punto de agua asegurado.» (anotar que cambia la frase de ejemplo de la biblia). |
| H12 · repeticiones | Variar también el «asegurado» | Quitar el lugar repetido tal cual en 2, 10, 12 y 15 y reescribir la apertura de las 9 victorias que empiezan con «X asegurado/a» (1, 2, 3, 6, 8, 9, 10, 12, 13) para que no se repitan. Proponer opciones a Lucas antes de cargar. |
| H13 · relleno | Sí, las tres | Nivel 3: «Sin huerta no hay con qué alimentar a la colonia.» Nivel 4: «El camino hasta ahí da muchas vueltas: conviene que a las manadas les cueste llegar.» Nivel 12, línea 3: «Cruzarlo es llegar al resto de la región.» |
| H14 · Wiki | Sí, ambos | «Los poblados vacíos», párrafo 2: «No hay nadie. Se fueron hace poco y se llevaron lo que podían cargar.» (sin las brasas). «La Central»: quitar el párrafo 4. |
| H15 · créditos | Sumar nombre y mail | Lucas quiere su nombre y su mail. **Falta que escriba la línea exacta** (cómo quiere que figure el nombre y qué dirección es pública) antes de cargarla. Los créditos tienen que seguir pasando el test de `11-textos-lore.md`. |
| H16 · intro | Dejarla | Solo se ajusta la lámina 4 por H1. |

## Consecuencias para otras tareas
- **T534 (inglés):** el Lore (incluidos nombres y descripciones de nivel, créditos y artículos) se traduce después de aplicar esto; los nombres nuevos de 11–15 ya van en la lista.
- **Tests con hash de `data/levels/*.json`** (`test_campaign_posts.gd`, `test_campaign_marks.gd`): cambian al tocar los JSON; se actualizan a propósito.
- **Siguiente paso:** Lucas completa `T545-decisiones-redaccion.md` (el resto de los textos, que él quiere revisar a mano) y después una tarea aplica todo junto.
