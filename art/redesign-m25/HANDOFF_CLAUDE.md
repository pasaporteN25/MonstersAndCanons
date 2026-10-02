# Entrega a Claude · locomoción de los tres monstruos aprobados

Preparado por Codex. No se modificó código de producción para esta entrega.

## Archivos

Copiar desde `art/redesign-m25/atlases/` a una carpeta de producción bajo `assets/sprites/enemies/`:

- `normal_walk.png`: diablillo rojo, selección normal_B.
- `fast_walk.png`: bestia turquesa cuadrúpeda, selección fast_A.
- `tank_walk.png`: ogro de piedra y piel verde, selección tank_A.

Los tres PNG son RGBA de **1024×1024**, con **4 columnas × 4 filas**. Cada cuadro mide **256×256**. Las fuentes originales generadas están en `sources/`; no usarlas como atlas porque el espaciado no es exacto. El empaquetador separa las 16 figuras por alfa y mantiene una escala común para cada criatura.

## Convención

| Fila | Dirección | Cuadros |
|---|---|---|
| 0 | Este, +X | pasos 0, 1, 2, 3 |
| 1 | Sur, +Y | pasos 0, 1, 2, 3 |
| 2 | Oeste, −X | pasos 0, 1, 2, 3 |
| 3 | Norte, −Y | pasos 0, 1, 2, 3 |

No girar ni reflejar el PNG: las direcciones están dibujadas y la luz permanece arriba a la izquierda. Para diagonales, elegir el eje dominante de la velocidad; mantener la última dirección estando quieto. El cuadro se obtiene con `Rect2(columna * 256, fila * 256, 256, 256)`.

Duración sugerida por cuadro: Normal **0,10 s**, Rápido **0,08 s**, Tanque **0,18 s**. Son valores iniciales para ajustar visualmente, no cambios de velocidad o balance. El reloj debe respetar pausa, cámara lenta y ralentización. En reposo se puede sostener el cuadro 0; no se entregó una animación independiente de respiración.

Los pies están alineados en **(128,191)**. Si se conserva el dibujado actual de Enemy, adaptar ese pivote a la sombra existente, sin cambiar la posición lógica del enemigo. Para un lado visual `side` y suelo local `ground_y`, el rectángulo de destino comienza en `Vector2(-side / 2, ground_y - side * 191 / 256)` y mide `Vector2(side, side)`. La sombra sigue siendo un efecto separado del motor.

## Estados e interfaz

Mantener los efectos actuales de impacto, quemadura, frío y desaparición. Para el destello de daño se puede cachear la silueta blanca del atlas completo y dibujar la misma región que el cuadro normal. No mostrar las 16 figuras juntas en iconos: Wiki y próxima oleada deben usar una región seleccionada o el retrato estático ya integrado.

No añadir squash/bamboleo fuerte encima del paso dibujado: comprobar primero sin ese movimiento para evitar duplicar la animación. Ajustar la posición de corona y barra de vida usando los nuevos márgenes visuales. Conservar tamaños de colisión, IDs, habilidades, estadísticas y las pruebas existentes.

## Verificación y límites

`manifest.json` guarda el formato y los tiempos. `preview_walks.tscn` reproduce las tres criaturas en cuatro direcciones en Godot, ampliadas y pequeñas. `walks_godot.png` es una captura real del visor. `walks_preview.gif` reproduce cuatro cuadros a ritmo común de comparación, diferente a los tiempos recomendados por criatura.

Se verifican 48 cuadros no vacíos, cuatro cuadros distintos en cada fila, margen transparente y que no se arrastren fragmentos de otras figuras. Hay pequeñas variaciones de detalles y amplitud entre poses generadas; revisar en una ruta real antes de considerarlo cerrado. Esta entrega incluye caminar/correr; no contiene una animación específica de ataque, daño o muerte, que estos tres enemigos no necesitan para sustituir sus efectos existentes.

Las cinco propuestas de Blindado, Troll, Volador, Araña y Cría son conceptos para selección de Lucas. No integrarlas ni animarlas como diseños aprobados todavía. Bestia violeta y ogro volcánico de M24 quedan reservados para futuras especies; el diablillo verde sigue descartado.

El formato coincide con art/FORMATO_PROXIMA_ENTREGA_M24.md: cuadro de 256 px, cuerpo máximo 63,3 % de alto, pies al 74,6 %. Hay vistas este/sur/oeste/norte; los retratos estáticos de producción quedan como respaldo.
