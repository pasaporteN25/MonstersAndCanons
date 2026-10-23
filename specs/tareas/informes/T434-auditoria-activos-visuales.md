# T434 · Auditoría de arte activo y piezas antiguas pendientes

**Revisión visual y lectura estática:** Claude Opus, 2026-10-21. **Formalización del informe:** Codex. Checkout revisado: `feature/rudd`; la base remota `origin/main` estaba 17 commits adelante al momento del análisis. No se editaron archivos ni se corrió Godot.

## Hallazgo principal: nivel 6

El nivel no necesita rehacer todos sus recursos. La mayoría de su presentación ya usa la migración vigente: suelo de bosque, caminos, árboles y rocas, puerta, enemigos, torres y Estandarte. Dos piezas antiguas/provisionales sí aparecen en la captura del nivel:

| Recurso | Uso comprobado | Estado | Evidencia/deuda |
|---|---|---|---|
| `assets/sprites/map/helecho.svg` | La letra `f` del nivel 6; también decoración aleatoria del tema bosque | Arte viejo de M15, plano, verde chillón y contorno pesado frente a los elementos renderizados | T223 añade la casilla; T260 propuso un rediseño que se revirtió. No hay tarea abierta que lo migre. |
| `assets/sprites/map/poste_cintas.svg` | Letra `p` del nivel 6 | Provisional de T218/T249; sin aprobación de Lucas | No aparece en T267a, por lo que quedó fuera de esa revisión. |
| `assets/sprites/map/tronco.svg` | Decoración aleatoria del tema bosque en niveles 4 y 7; no se vio en nivel 6 | Arte viejo de M15 | No es una pieza actual del nivel 6, pero comparte el tema afectado. |

El suelo de bosque lo carga `scripts/logic/map_themes.gd` desde `assets/tiles/rendered/ground_bosque.png`. La decoración del tema también se resuelve desde `map_themes.gd`; los dibujos colocados por letra pasan por `scripts/logic/map_drawings.gd`. La leyenda de `data/levels/level_06.json` confirma `p` (poste) y `f` (helecho). La comparación `art/t249-mejoras/after/level_06.png` muestra el contexto visual descrito. La observación de que la única casilla bloqueada aparece como árbol procede de esa captura; no se volvió a abrir el nivel para recalcularla.

## Otros hallazgos visibles

1. **Nivel 14, prioridad alta:** `scripts/logic/map_themes.gd` usa `assets/sprites/map/estatua.svg` para decorar casillas bloqueadas del tema ruinas. El nivel tiene 117 de esas casillas. La captura `art/t277-integracion/level_14_initial.png` muestra estatuas de guerrero con espada, en conflicto con D-098 y `specs/05-guia-de-arte.md` §9, que reserva las estatuas para representar torres. T277 cambió estatuas explícitas de las leyendas en niveles 1, 3 y 5; no cambió la decoración aleatoria de ruinas. Evaluar si alcanza con reutilizar una estatua aprobada con musgo; revisar primero sobre ese suelo.
2. **Niveles 10–14:** decoración de casillas bloqueadas aún usa SVG de M15 (cactus, rocas, huesos, pinos, columnas y bloques). T267a ya había observado esa deuda como parte de B-38; no es un hallazgo nuevo ni requiere rehacerla automáticamente.
3. **Guía desactualizada:** `specs/05-guia-de-arte.md` §§6 y 8 aún describe diez enemigos como SVG, pero las escenas usan sus PNG renderizados bajo `assets/sprites/enemies/rendered/`.
4. **Candidatos huérfanos:** un recuento literal encontró 26 de 236 PNG/SVG/WebP/JPG bajo `assets/` sin ruta exacta en escenas/scripts/datos/config. No se pueden borrar solo por esa búsqueda: recursos como enemigos y proyectiles se referencian por identificador y se resuelven dinámicamente. Además, `tests/test_resource_audit.gd` detecta uso por nombre sin extensión, lo que puede dar falsos positivos. Hace falta una auditoría de referencias dinámicas y una lista de cargas reales antes de limpiar.

## Qué se considera vigente

El análisis no recomienda tocar el suelo/path (la variante actual fue elegida por Lucas al revertir T261), flores, enemigos, torres, Estandarte, puerta, efectos ni HUD. En nivel 6, Opus consideró migrados los diez enemigos de sus oleadas y las familias de torre; cualquier cambio ahí debería responder a una muestra concreta.

## Orden sugerido, con aprobación de arte

1. Confirmar si Lucas quiere priorizar M72 o abrir un bloque de mantenimiento visual a partir de estos hallazgos.
2. Preparar muestras nuevas a escala real para helecho, poste con cintas y tronco siguiendo el método reproducible de T267b; presentar su fuente, comparación sobre pradera/bosque y lecturas a 220 y 34 px. No reemplazar producción antes del OK.
3. En una tarea independiente, comprobar la estatua de ruinas con una variante ya aprobada; no cambiar código hasta validar contraste y sentido.
4. Decidir después si se amplía la auditoría a la decoración ya registrada de niveles 10–14 y a candidatos sin referencia dinámica.

**Validación recomendada para futuras integraciones:** importación Godot, suite GUT completa sin `SCRIPT ERROR`/`Parse Error`, hojas de comparación a 220 y 34 px, capturas reales a 1280×720 junto a T249/T277 y restaurar únicamente cualquier SVG reescrito accidentalmente por importación. No se hizo ninguna de estas pruebas en esta auditoría.
