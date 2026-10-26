# T493 · Muestras de pinos, abetos y rocas nevadas

**Propuesta sin integrar, para que Lucas elija.** Fecha: 2026-10-25. No hay aprobación artística implícita en estas recomendaciones.

Se prepararon **tres variantes de cada dibujo**, nueve PNG RGBA de **128×128**, con fondo transparente. El destino previsto es una casilla de **64×64**; los montajes usan los **48×48 píxeles de pantalla** que tiene cada casilla en la captura original a 1280×720. No se agrandó la huella ni se modificó ningún dato del nivel.

El pedido directo de esta sesión habilita las muestras con Codex y la roca nevada, aunque la ficha y M79 todavía conserven restricciones anteriores sobre el ejecutor y preguntas pendientes. Se encontró T491 terminada y se usó su inventario. La integración y la elección siguen pendientes de Lucas en T495.

## Para revisar

- [Detalle de las nueve decoraciones a 220 px](decoration_detail.png): primera comparación de las formas y la cobertura de nieve.
- [Hoja completa a 34 px](contact_034.png): nueve variantes y los 17 enemigos de la guía sobre nieve y camino.
- [Hoja completa a 220 px sobre nieve](contact_220.png) y [complemento sobre camino](contact_220_path.png): los enemigos usan sus texturas estáticas vigentes, resueltas desde los `.tres`, no recreaciones de la tabla de colores.
- [Comparación específica con Araña y Cría](spider_comparison.png), con lienzos de 64 y 34 px. Es una comparación de texturas al mismo tamaño; no representa el tamaño relativo real de los enemigos.
- Montajes del nivel 13: [serie 01, recomendada](level_13_proposal_01.png), [serie 02](level_13_proposal_02.png), [serie 03](level_13_proposal_03.png). Son composiciones sobre la captura de T491, **no capturas nuevas del motor**.
- [Tablero de referencias dimensionales](reference_board.png), sin modificar sus dibujos.

## Qué cambia entre las variantes

| Pieza | 01 | 02 | 03 |
|---|---|---|---|
| Pino | Copa abierta, más follaje visible y tronco expuesto. | Nieve más abundante; ramas más cubiertas. | Copa despareja y cobertura intermedia. |
| Abeto | Copa más baja y ancha que el pino; base densa. | Más nieve y mayor continuidad de los mantos. | Ramas desparejas, con una silueta menos regular. |
| Roca nevada | Grupo de piedra alto, con casquetes contenidos. | Mismo grupo, un poco mayor y con más nieve. | Grupo bajo y alargado, derivado de la otra roca dimensional. |

La diferencia pino/abeto conserva el criterio del dibujo vigente: pino más alto y estrecho; abeto más bajo y ancho. No propone una especie nueva ni agrega explicación de universo.

## Recomendación para Lucas

| Dibujo actual | Variante recomendada | Motivo y reserva |
|---|---|---|
| `pino` | [pine_01.png](pine_01.png) | La nieve no tapa todo el follaje. El verde oliva oscuro y el tronco cálido se separan del turquesa de Araña y Cría. A 34 px se mantiene la lectura de conífera. Queda a revisar si la copa resulta demasiado estrecha. |
| `abeto` | [fir_01.png](fir_01.png) | La base más ancha ayuda a distinguirlo del pino y a ocupar visualmente la casilla bloqueada. No tiene pedestal, piezas mecánicas ni emblema. A 34 px la diferencia entre ambas especies es sutil: la lectura de árbol nevado es más fuerte que la identificación botánica. |
| `roca_nieve` | [snow_rock_01.png](snow_rock_01.png) | Deja suficiente piedra oscura visible para separar la nieve del suelo y sostener la lectura de obstáculo. Conserva las caras y la iluminación de T277. La 03 queda como alternativa si Lucas prefiere menos altura; su silueta baja comunica peor el bloqueo a escala chica. |

La serie 02 ofrece una opción más cargada de nieve, pero se acerca más al blanco del suelo. La 03 rompe la regularidad; no se propone alternar variantes automáticamente ni cambiar la selección de casillas. Eso requeriría una decisión posterior. El montaje recomendado usa exclusivamente las tres variantes 01.

## Técnica, fuentes y procedencia

Fuente editable: [generate_samples.py](generate_samples.py). Comprobación reproducible: [verify_samples.py](verify_samples.py), ejecutable después del generador con `python3 art/m79-muestras/nieve/verify_samples.py`. Se ejecuta desde cualquier carpeta con:

```bash
python3 art/m79-muestras/nieve/generate_samples.py
```

Usa Python 3 y **Pillow 12.1.1**, disponibles en esta máquina. Se comprobó que **numpy, scipy y cairosvg no están instalados**; no se instalaron paquetes ni se usaron. El generador escribe únicamente junto a su propio archivo. Necesita el repositorio para leer las referencias y DejaVu Sans en la ruta declarada para los rótulos.

- **Pinos y abetos:** dibujo procedural original en Python, a 384×384, reducido a 128×128 con Lanczos. Las ramas se componen con volúmenes elipsoidales irregulares, iluminación por normales desde arriba a la izquierda, textura de agujas, acumulaciones de nieve con borde sombreado, tronco y sombra de apoyo suave. Semillas fijas: la generación es determinista en este entorno. No se usó SVG plano ni un servicio generativo de imágenes.
- **Rocas 01 y 02:** derivadas de `assets/sprites/map/rendered/rock_a.png`; roca 03, de `rock_b.png`. Se conserva el material pintado existente, con reencuadre y acumulaciones de nieve de borde redondeado y relieve sombreado. El alfa original recorta las acumulaciones. El script contiene las coordenadas editables de cada casquete. Los originales no se modificaron.
- **Paleta de árboles:** oliva apagado y marrón cálido, con nieve marfil y sombras gris azuladas. Se evitó usar el verde azulado como color dominante del follaje. Las sombras de la nieve son frías, pero no buscan reproducir el turquesa saturado de Araña y Cría.
- **Referencias observadas:** `tree.png`, `rock_a.png`, `rock_b.png`, `forest_idle.png`, `statue_basic_frost.png`, poste dimensional, captura T475 del nivel 13, captura T491 del nivel 13 y atlas/UI de `Capturas/T471-pc-1280x720-final.png`. La dirección buscada es la familia dimensional actual, con volumen y sombra de apoyo; la aprobación de la coincidencia de estilo sigue siendo de Lucas.
- **Suelos:** `assets/tiles/rendered/ground_nieve.png` y `path.png`, los que declara `MapThemes`. Las superficies de las hojas se reescalan a cada panel para facilitar la comparación; no son reproducciones de una cámara del juego.
- **Enemigos:** los 17 renglones de la tabla de la guía, incluidos Coloso, Pedazo, Ratero y Cargador. La textura se busca en el recurso estático de cada uno. Las imágenes actuales no siempre coinciden literalmente con las descripciones históricas de la tabla; no se recoloreó ningún enemigo para disimular esa diferencia.

No hay marcas, símbolos, personajes ni canon nuevos en las piezas. Las señales con la A que aparecen en el montaje son las que ya estaban en la captura y quedan fuera de esta tarea.

## Cómo se armó el nivel 13

Base: `art/m79-inventario/antes-nivel-13-1280x720.png`, del inventario T491; contexto de este worktree: `feature/t493-muestras-pinos-nevados`, commit `37de9a8`. No se actualizó ni cambió la rama, ni se afirma una comparación contra un `origin/main` recién descargado.

Se leyó `data/levels/level_13.json` sin modificarlo. La captura tiene origen de grilla `(16, 48)` y casillas de 48 px. Sobre cada `X` visible se repuso el suelo vigente y luego la variante correspondiente. El dibujo anterior se identificó por la presencia y el ancho del follaje de su SVG en la captura; **no se reimplementó el hash de Godot**.

Cada montaje reemplaza **115 objetos visibles: 64 pinos, 19 abetos y 32 rocas nevadas**. El inventario cuenta 117 casillas: las otras dos son los postes de campaña en `(23, 2)` y `(24, 9)`, que se conservaron exactamente como estaban. La diferencia de un pino y un abeto respecto del inventario es compatible con esas dos casillas ocultas; no se verificó su selección mediante el motor.

Se conservaron camino, hielo, señales, removibles, extracciones y postes. El único cambio fuera de las casillas de decoración es un rótulo sobre la franja inferior que identifica el montaje como propuesta. Las coordenadas y la variante por casilla están en [map_manifest.json](map_manifest.json).

## Verificación y límites

Se revisaron visualmente el detalle de las nueve piezas, la hoja de 34 px, la comparación con Araña y Cría y el montaje recomendado. En estas imágenes los árboles se reconocen como decoración y los enemigos turquesas se separan del follaje oliva; esto es juicio visual de la propuesta, no una medición de usabilidad ni aprobación artística. La nieve recibió una segunda pasada de sombreado porque la primera versión resultaba demasiado uniforme; las imágenes finales son las posteriores a esa corrección.

Se verificaron las nueve dimensiones 128×128, modo RGBA, transparencia de los bordes, márgenes dentro de la casilla, pesos, lectura de todos los PNG y preservación de las zonas del montaje que no deben cambiar. Los detalles y hashes están en [verification.json](verification.json), [file_manifest.json](file_manifest.json) y [provenance.json](provenance.json).

**No se corrió Godot, no se ejecutó `godot --import`, no se integró ningún recurso ni se corrieron GUT.** No se probaron mipmaps, animaciones, oclusiones durante una partida, input, celular simulado ni teléfono real. No se midieron FPS, memoria ni tiempos de carga. El tamaño PNG no permite concluir nada sobre rendimiento. Las hojas con enemigos usan lienzos iguales para comparar color y silueta; no aplican `size_tiles` ni `visual_scale`, y la Cría se ve relativamente más grande que en una partida real.

Solo se escribió en `art/m79-muestras/nieve/`. No se actualizaron tablero, changelog ni fichas por la restricción explícita de esta sesión. No se hizo commit ni push. Estas muestras no cierran la verificación de integración de RF-714.

## Preguntas para la elección de Lucas

1. ¿Qué número elegís para cada pieza? Podés mezclar, por ejemplo pino 01, abeto 03 y roca 01.
2. ¿Al pino 01 le darías más ancho, o alcanza su ocupación de la casilla? ¿La diferencia con el abeto se lee lo suficiente a 34 px?
3. ¿Preferís dejar más follaje y piedra a la vista, como en la serie 01, o una cobertura abundante como en la 02?
4. ¿La roca 03 resulta demasiado baja o querés conservarla como alternativa? La roca nevada fue incluida por pedido explícito de esta sesión; su selección sigue abierta.
5. ¿El volumen y el nivel de detalle acompañan suficientemente a T277, o querés una pasada artística adicional antes de autorizar T497?

La integración, si Lucas la autoriza, todavía necesita capturas del motor y las verificaciones de su propia tarea. No hay una variante aprobada en esta entrega.

## Peso de los archivos

Los pesos exactos por PNG y sus SHA-256 están en `file_manifest.json`. La tabla siguiente se genera al cerrar la entrega; KiB significa bytes / 1024.

<!-- FILE_WEIGHTS -->

| Archivo | Bytes | KiB |
|---|---:|---:|
| `contact_034.png` | 360,506 | 352.06 |
| `contact_220.png` | 1,973,718 | 1927.46 |
| `contact_220_path.png` | 2,084,082 | 2035.24 |
| `decoration_detail.png` | 713,780 | 697.05 |
| `file_manifest.json` | 3,703 | 3.62 |
| `fir_01.png` | 15,826 | 15.46 |
| `fir_02.png` | 15,136 | 14.78 |
| `fir_03.png` | 15,650 | 15.28 |
| `generate_samples.py` | 19,471 | 19.01 |
| `level_13_proposal_01.png` | 367,080 | 358.48 |
| `level_13_proposal_02.png` | 369,035 | 360.39 |
| `level_13_proposal_03.png` | 361,451 | 352.98 |
| `map_manifest.json` | 35,574 | 34.74 |
| `pine_01.png` | 14,133 | 13.80 |
| `pine_02.png` | 13,972 | 13.64 |
| `pine_03.png` | 14,087 | 13.76 |
| `provenance.json` | 7,142 | 6.97 |
| `reference_board.png` | 313,547 | 306.20 |
| `snow_rock_01.png` | 15,707 | 15.34 |
| `snow_rock_02.png` | 16,528 | 16.14 |
| `snow_rock_03.png` | 11,010 | 10.75 |
| `spider_comparison.png` | 316,290 | 308.88 |
| `verification.json` | 2,437 | 2.38 |
| `verify_samples.py` | 4,327 | 4.23 |

Las nueve piezas suman **132,049 bytes (128.95 KiB)**. Los PNG de revisión suman **6.67 MiB**. La tabla no incluye el propio informe; los montajes y hojas son material de revisión, no recursos para integrar.
