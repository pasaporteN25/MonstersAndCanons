# T233 · Central, abastecimiento y final

**PROVISIONAL: pendiente de revisión y OK artístico de Lucas.** El despacho del 2026-10-09 autorizó la producción provisional para no frenar el código. P5/P6 de M52 aprueban cuatro cuartos y la inclusión del hito; no se registra aprobación de los dibujos. T233 sigue abierta por esa compuerta.

## Entrega para integrar

| Id | Ruta | Tamaño lógico | Uso |
|---|---|---|---|
| `central_1` a `central_4` | `assets/sprites/map/central_1.svg` a `central_4.svg` | 64×64 cada uno | Central permanente junto a la salida del 15, en cuatro `X`. |
| `supply_depot` | `assets/sprites/map/supply_depot.svg` | 64×64 | Depósito permanente. |
| `supply_line_pole` | `assets/sprites/map/supply_line_pole.svg` | 64×64 | Poste de línea permanente. |
| `supply_cart` | `assets/sprites/map/supply_cart.svg` | 64×64 | Vagoneta permanente. |
| `supply_conveyor` | `assets/sprites/map/supply_conveyor.svg` | 64×64 | Cinta permanente. |
| `hito` | `assets/sprites/map/hito.svg` | 64×64 | Pila de piedras, niveles 11–13. |
| `epilogue` | `assets/sprites/story/epilogue.png` | 1920×1080 | Colonia encendida y fuegos alejándose, franja inferior tranquila. |

**Orden obligatorio de la central:** `central_1 central_2` arriba (NO/NE), `central_3 central_4` abajo (SO/SE). Dibujar cada cuarto sobre su casilla completa, sin centrarlo como un objeto aislado ni agregarle margen; el margen está en la fuente conjunta. La fuente de verdad completa es `sources/central_master.svg` (128×128). Los SVG importan al doble por D-023: se posicionan según su tamaño lógico, no su resolución de textura. No rotar ni reflejar.

**Integración pendiente:** T234 debe conectar las rutas mediante `preload` y asociarlas a las cuatro casillas contiguas junto a `S` (sin reemplazar la salida), y colocar de dos a cuatro piezas de abastecimiento en `X` del borde. Los ids de abastecimiento son nuevos; debe registrarlos la tarea de código en su leyenda/dibujo. T229–T231 deben consumir `hito`. T228/T234 deben usar el PNG en la pantalla del epílogo con ajuste 16:9 y el texto de `specs/11-textos-lore.md` §2. No se modificaron lógica, niveles, balance ni rutas del juego durante esta entrega.

## Capturas para revisar

- [Hoja ampliada a 220 px](captures/contact_220.png), [Wiki a 112 px](captures/contact_112.png), [juego a 64 px](captures/contact_64.png) y [34 px](captures/contact_34.png). Orden: central completa, depósito, poste, vagoneta, cinta, hito; filas pradera/desierto/nieve. En estas hojas la central completa se reduce al tamaño indicado; en el mapa real ocupa dos casillas de ancho y dos de alto.
- [Central ensamblada 128×128](captures/central_assembled.png): cuatro cuartos sin separación ni contorno interior.
- [Muestras sobre partida real](captures/game_samples.png): ventana Godot 4.7.2, OpenGL/GTX 1660 SUPER, 1777×1000, nivel 1 y guardado separado `user://test_t233_capture.json`. Central a 128 px y piezas a 64 px lógicos, superpuestas como banco de muestras rotulado; **no demuestra integración en el nivel 15 ni ubicación legal**.
- [Muestra del epílogo con sus cuatro líneas](captures/epilogue_preview.png): escena de revisión separada, no la pantalla final integrada ni una victoria real. Permite comprobar composición, contraste y espacio del texto.

Los SVG conservan las facetas y el contorno de T249, sin marcas ámbar de demolición. La ilustración pintada conserva piedra/madera/hierro/cobre y luz cálida frente al horizonte frío; es más detallada que los SVG de casilla y requiere revisión de Lucas. Los Moradores se sugieren mediante campamentos y fuegos en profundidad, sin personajes identificables ni juicio moral.

## Reproducir

```bash
python3 art/t233-final/build_vectors.py
godot --headless --import
godot --headless -s art/t233-final/pack.gd
godot --headless --import
godot --path . --resolution 1777x1000 --position 20,30 art/t233-final/capture.tscn
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

`build_vectors.py` conserva las fuentes SVG, `pack.gd` normaliza el PNG y rasteriza las hojas. La fuente PNG generada queda intacta, con el prompt exacto en [prompts.md](prompts.md); dimensiones, orden y hashes en [manifest.json](manifest.json).

## Verificación y límites

**GUT: 1334/1334 tests, 12149 asserts, 98 scripts; 0 `SCRIPT ERROR` y 0 `Parse Error`.** Importaciones completas sin errores de scripts. SVG válidos, lienzos 64×64 y PNG 1920×1080; alfa del montaje idéntico a la fuente completa. El redondeo del degradé al trasladar las ventanas cambia 23 píxeles RGB como máximo 1/255; no cambia contorno ni transparencia. Las fuentes/herramientas no forman parte de la lógica exportada.

Se conserva el historial de fallos de preparación: `pack_before_import.txt` refleja que se ejecutó el empaquetador antes de preparar el worktree con importación (clases y audio ausentes); se corrigió importando. `pack_exact_comparison.txt` y `pack_diagnostic.txt` muestran el ajuste de la comparación de raster a la tolerancia medida de 1/255. **No se consideran resultados verdes.** La corrida final es `pack.txt`. El empaquetador avisa de `Image.load_from_file` en herramientas y del aviso de recursos vivos al salir, ya observado en T249; GUT imprime únicamente el error esperado del fixture `no_existe`. Salidas completas en `validation/`.

No se probaron una victoria en el 15, integración de leyenda/epílogo, combate con estos objetos, exportación Windows, dispositivo móvil físico ni rendimiento. Las hojas reducidas permiten revisar lectura chica; la aprobación artística, la integración y su validación visual pertenecen a Lucas/T234. No se creó PR: el despacho pide reportar solo a coordinación y no publicar por otros canales.
