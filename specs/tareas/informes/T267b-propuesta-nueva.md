# T267b · Nueva propuesta renderizada, etapa 1

**Propuesta aislada para revisión de Lucas, sin aprobación artística ni integración.** Referencia de partida: `928318a`, rama `feature/t267b-assets-nuevos`. El despacho de T267b selecciona expresamente las cinco familias que se rehacen acá; no habilita producir ni conectar otras piezas de T267. El estado anterior del tablero sobre selección pendiente corresponde a T267a.

Se revisaron `AGENTS.md`, `CLAUDE.md`, las reglas de arte/documentación, la constitución, la guía de arte, B-38/T267, el inventario y la propuesta T267a, sus capturas y herramientas, y los antecedentes T233/T218/T219/T220. Esos antecedentes usan SVG provisionales; para alcanzar el volumen solicitado se siguió el método renderizado de M23: fuentes de imagen conservadas → recorte por alfa → derivados normalizados → hojas → escena real de revisión. No se ejecutó el empaquetador histórico que escribe en `assets/`.

## Propuesta

- Mina: portón cerrado, boca abierta con vagoneta, boca clausurada con tablones cruzados. Tres estados sobre el mismo macizo de roca y puntales.
- Bosque explotable: grupo de tres árboles, corta parcial con troncos y árboles en pie, conjunto de tocones y madera restante. Se conservan las diferencias grandes de silueta.
- Escombros: mampostería rectangular quebrada y viga de hierro, con variante de trabajo. No llevan la A canónica ni repiten la forma de una roca natural.
- Central: edificio civil industrial compacto de piedra, hierro, bronce y madera, con cubierta y ventilación volumétricas. Una fuente completa y cuatro cuartos NO/NE/SO/SE recortados de esa misma imagen, sin juntas internas ni cuatro edificios independientes.
- Estatuas de máquinas: Cañón (`cannon`), Francotirador (`sniper`) y Ametralladora (`basic`), nombres comprobados en `data/towers/`. Piedra gris erosionada con pedestal cuadrado, musgo o escarcha. Sin humanos, espada, casco, engranaje, aura ni círculo de alcance. El Estandarte mecánico usa casco, engranaje y metal/bronce; se conserva y se incluye como comparador.

Los PNG son propuestas generadas, no renders de un modelo 3D compartido. Las pequeñas variaciones de detalle entre estados se deben revisar antes de una eventual integración; no se afirma continuidad exacta de geometría ni aprobación de Lucas.

## Material para revisar

[Comparador de mapas](../../../art/t267b/comparison.html), [hoja a 220 px](../../../art/t267b/review/contact_220.png) y [hoja a 34 px](../../../art/t267b/review/contact_34.png). La Central conserva dos casillas por lado en las hojas; cada otro objeto ocupa una. Se incluyen árbol, roca, las tres torres y Estandarte actuales como vecinos de comparación. Las fuentes originales y los prompts están en `art/t267b/`; no quedan únicamente en el directorio de la herramienta.

Las capturas de 1280×720 usan la escena real `game.tscn`, el mismo `SubViewport` fijo de T267a, los datos reales y la cámara del juego. La subclase local de decoración sustituye exclusivamente el dibujo de las casillas seleccionadas. Las capas de reserva y el velo permanecen: alternar dibujos no simula haber completado extracción o demolición. No son mapas reconstruidos con Python ni capturas de una partida humana.

| Niveles | Piezas revisadas |
|---|---|
| 1, 3, 5 | Estatuas, con las tres alternativas en las mismas casillas actuales. |
| 11 | Mina y escombros, junto a roca removible y roca marcada actuales. |
| 12 | Bosque explotable y escombros. |
| 13 | Mina, bosque y escombros sobre nieve. |
| 14 | Mina, bosque y escombros en ruinas. |
| 15 | Central, mina, bosque y escombros junto al árbol y roca renderizados. |

Las estatuas con escarcha se presentan en la hoja sobre nieve y en un muestrario separado del 13: [antes](../../../art/t267b/captures/level_13_statue_samples_before.png) / [después](../../../art/t267b/captures/level_13_statue_samples_after.png). **Los datos actuales del 13 no tienen estatuas**: estas tres muestras sustituyen dibujos de casillas bloqueadas únicamente en la escena de revisión, no son apariciones de campaña. No se agregan casillas ni se cambia la leyenda o los datos del nivel.

## Verificación

- Godot **4.7.2**, importación y escena de captura con salida **0**; **0 `SCRIPT ERROR`, `Parse Error` y `Failed to load script`** en importación, capturas y GUT.
- **1635/1635 tests GUT**, 19.704 asserts, 117 scripts, 61,47 s; salida 0. La salida conserva el error esperado del fixture `no_existe` y los avisos provocados por tests de archivos inválidos/guardados corruptos; no se presentan como fallos nuevos. La importación avisa que ADB no atiende en `tcp:5037`, sin impedir que termine.
- **15 fuentes seleccionadas** RGBA con alfa real, más el primer bosque activo conservado como borrador. Derivados de 128×128; Central de 256×256 y cuatro cuartos de 128×128 que reconstruyen el máster **píxel por píxel**. [Control de arte](../../../art/t267b/validation/art_check.json).
- **34 capturas originales de 1280×720**: ocho mapas con antes y tres variantes, más el par de muestrario de escarcha. **24 comparaciones** sin diferencias fuera de las casillas seleccionadas. El muestrario extra del 13 se distingue expresamente y no se cuenta entre esas 24. [Control de píxeles](../../../art/t267b/validation/comparison_check.json).
- Se revisaron las hojas a 220 y 34 px, los recortes nativos con vecinos, mapas completos y el resumen de los ocho mapas (este último está explícitamente [reducido al 25 %](../../../art/t267b/review/overview_25_percent.png)). El primer bosque activo se rehízo porque su silueta era demasiado parecida a la inicial; la segunda versión deja dos copas separadas y un tocón claro. Los materiales renderizados acompañan mejor al árbol/roca/torres actuales, pero **esta evaluación no sustituye la aprobación de Lucas**. Bajo el velo real los detalles de mina todavía pierden contraste; no se retiró ese velo para mejorar artificialmente la muestra.
- `git status` después de importar no mostró modificaciones de assets; igualmente se ejecutó `git checkout -- assets`, como pidió el despacho. No hay cambios del juego ni de los datos. [Salidas completas](../../../art/t267b/validation/).

No hubo bloqueos técnicos ni permisos pendientes. La aprobación artística y la integración siguen siendo etapas futuras. No se abrió PR ni se publicó por otros canales: este despacho pide informar únicamente a coordinación y publicar la rama solicitada.

## Qué no se hizo

Cero integración en `assets/`, `data/`, `scripts/`, `scenes/` o `tools/`. Se conservan suelos restaurados, flores, torres, señales y juego actual. No se alteró economía, reserva, tiempos, niveles, balance o lore. No se probaron partida humana completa, ciclo jugable completo de extracción/demolición, Windows, Android, exportaciones ni FPS. No se cierra T267, no se declara arte final y no se habilita reenviar al tester. La próxima compuerta es la elección y aprobación de Lucas antes de integrar.
