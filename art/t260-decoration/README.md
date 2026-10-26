# T260 · Mejora del arte de la decoración del mapa

> **Nota histórica (T516, 2026-10-26):** `render_contact.gd`, `refine_vectors.py` y `manifest.json` de esta carpeta leían `assets/sprites/map/{pino,abeto,roca_nieve,huesos}.svg`. Esos cuatro SVG se **retiraron del proyecto el 2026-10-26** (con OK de Lucas) porque los reemplazan `pine_snow.png`, `fir_snow.png`, `snow_rock.png` y `bones_skull.png` (T497 y T498). Las herramientas no se reescribieron: si se vuelven a correr, fallarán o saltearán esos cuatro. El arte viejo sigue en `sources/before/` (y el pulido de T260, en el historial de git).

**PROVISIONAL: pendiente de aprobación artística de Lucas.** Pedido y estilo decididos por Lucas el 2026-10-11: pulido en el mismo lenguaje vectorial de la guía, con más detalle, sombras suaves y variedad, conservando el tono y los colores base de cada bioma. Esta entrega no declara arte definitivo.

Abrir [comparison.html](comparison.html) para comparar las hojas ANTES/DESPUÉS a **220 y 34 px**, las muestras individuales a tamaño real y las galerías. [manifest.json](manifest.json) enumera los 27 archivos, sus posiciones en las hojas y sus hashes. `sources/before/` conserva los SVG anteriores, sin redibujarlos.

## Alcance y criterio

Referencia: `specs/05-guia-de-arte.md` §§2, 4 y 5, reglas de arte y RF-260/RF-261 de los temas del mapa. No se agrega comportamiento jugable: se revisan los recursos existentes. Se conservan las rutas, nombres y lienzos **64×64**, la transparencia, el contorno `#2b2233`, las marcas A y el sentido de cada señal. No se conectan variantes ni se cambian código del juego, escenas o datos de balance.

**Dado** el conjunto actual de decoración → **Cuando** se importa y compara la propuesta → **Entonces** los 27 SVG conservan su contrato, muestran el material mediante degradés de tres paradas y detalles subordinados a la silueta, y se pueden revisar antes/después sobre sus biomas a 220 y 34 px. La producción termina con las verificaciones; la aprobación visual queda a cargo de Lucas.

**Decisión de producción:** SVG nativos, iluminación suave desde arriba/izquierda y sombras de apoyo sin filtros. Se descarta cambiar el estilo a imágenes renderizadas porque Lucas pidió mantener el lenguaje vectorial; se descarta conectar otros recursos porque excedería este despacho. Las flores mantienen un parche abierto de tallos y hojas, sin una base maciza que las haga parecer una casilla bloqueada.

**Plan aplicado:** conservar originales → pulir geometría/materiales → rasterizar con Godot → revisar hojas y contexto gráfico → importar → ejecutar GUT completo → revisar cambios ajenos del import → commit único de T260.

**Hecho cuando:** los 27 archivos estén pulidos, los originales y hojas comparativas estén conservados, haya revisión visual en Godot y la suite completa pase sin `SCRIPT ERROR` ni `Parse Error`, con los límites documentados. El detalle de la aprobación posterior no se confunde con este criterio de producción.

## Qué cambió

| Grupo | Mejora | Qué conservó |
|---|---|---|
| Flores | Cinco corolas de cinco pétalos, hojas anchas, tallos curvos y alturas distintas; rosa, amarillo, violeta y blanco con volumen suave. | Parche bajo, espacio transparente entre tallos, mismos colores base y uso construible. |
| Arbusto y árbol | Copa irregular, grupos de follaje con volumen, frutos más claros; tronco ramificado en el árbol. | Verde de pradera/bosque, silueta baja del arbusto y alta del árbol. |
| Abeto y pino | Ramas escalonadas, nieve con borde irregular, materiales de follaje, madera y nieve; apoyo tenue. | Abeto ancho de dos pisos y pino estrecho de tres, lienzo y familia verde/blanca. |
| Rocas | Gradientes de material, aristas claras y detalles de fractura/estratos; sombra menos oscura. | Gris, arenisca roja, basalto volcánico y piedra azul nevada. |
| Cactus | Volumen del tronco y brazos, detalle de espinas y pétalos en la flor. | Dos brazos asimétricos, verde desértico y flor rosa. |
| Columna, estatua y bloques | Degradés de piedra, biseles y fracturas; musgo y piezas originales. | Siluetas, espada de la estatua, columna rota y estructura de sillares. |
| Helecho, tronco, juncos, hongos y huesos | Volumen de materiales y nervaduras, corteza, fracturas o aristas según el objeto. | Siluetas y paletas de bosque, pantano y desierto. |
| Señales y ruinas | Aristas en roca/ruina/hito, facetas, desgaste y pliegues; veta de madera y atadura del poste. | A tallada legible, tres pasos del sendero, cintas sin letras, herramienta de hueso y campamento apagado. |

**27 SVG finales modificados.** Sin variantes nuevas. El resto de `assets/sprites/map/` corresponde a central, puerta, infraestructura, marcas, reservas, extracción y estados de removibles; no se modifica.

## Imágenes y contexto real

- `before/contact_220.png`, `after/contact_220.png` y sus pares `contact_34.png`: rasterizados por Godot sobre las texturas reales de los siete biomas. Orden del manifiesto, siete columnas, margen de 12 px. Los dibujos miden exactamente 220 o 34 px; el fondo ocupa el resto de cada casillero.
- `before/<nombre>_220/34.png` y `after/<nombre>_220/34.png`: muestras individuales RGBA; el HTML presenta la pequeña a 34 píxeles CSS, sin ampliarla.
- `before/gallery_level_01/06/08/10.png` y pares en `after/`: **banco de muestras rotulado** sobre partidas reales, a 64 px lógicos, sin crear objetos en el mapa ni cambiar sus reglas. ANTES/DESPUÉS corresponde a las muestras superpuestas; el mapa debajo usa en ambos casos los recursos actuales. No es una comparación de la campaña anterior.
- `after/level_01/06/08/10.png`: partidas reales sin la galería, con mapa, HUD y barra originales. Muestran el contexto actual y los recursos que ya consume la campaña.

Capturas hechas en **Godot 4.7.2 con ventana gráfica**, OpenGL sobre **GTX 1660 SUPER**, a **1777×1000**. Guardado de pruebas separado: `user://test_t260_capture.json`. Se revisaron visualmente las hojas de 34/220 px, la galería de ruinas y los mapas reales 1, 6 y 10. En la revisión se corrigió una intersección del manto de nieve en la punta del pino y se volvieron a generar las imágenes finales.

## Integración y límites

`MapThemes` usa los **PNG de `assets/sprites/map/rendered/`** para `tree`, `bush`, `rock_a` y `rock_b`: los cuatro SVG pulidos se muestran en la galería pero **no reemplazan esos PNG en campaña**. Se avisó a coordinación; su eventual integración requiere otro alcance. No se repintaron ni sobrescribieron esos PNG.

Las flores sí aparecen en el mapa real del nivel 1; la estatua también. El nivel 6 permite ver el poste y el helecho. El 10 muestra cactus, huesos, rocas rojas, columnas y señales de ruina. Las muestras individuales son la referencia para el conjunto completo: no todas las señales aparecen en los cuatro niveles fotografiados. La decoración densa del desierto sigue siendo la existente; no se cambió su cantidad ni ubicación.

No se jugaron oleadas ni se probaron tiempos de trabajo, balance humano, movimiento, exportación de Windows, Wiki o rendimiento/FPS. No se revisó la escena de nieve en una partida real: pino, abeto y roca nevada se revisaron en hojas sobre su terreno y en galerías. La aprobación artística queda pendiente.

## Reproducir

Desde la raíz del proyecto, ejecutar cada paso cuando termine el anterior:

```bash
python3 art/t260-decoration/refine_vectors.py
godot --headless --import
godot --headless -s art/t260-decoration/render_contact.gd
godot --path . --rendering-method gl_compatibility --resolution 1777x1000 --position 20,30 art/t260-decoration/capture_gallery.tscn
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

El generador vuelve a partir de `sources/before/`; no acumula cambios sobre el resultado. Las herramientas dentro de `art/` se ejecutan desde el proyecto, no forman parte del juego exportado. Los avisos sobre cargar terrenos como `Image` solo afectan a esas herramientas; no se cambió el método de carga del juego.

## Verificación y resultado

`validation/assets.txt`: **27/27** archivos XML válidos, 64×64, referencias de degradé resueltas, tres paradas por degradé, sin texto/filtros/imágenes incrustadas, sin mezclar el contorno de enemigos y hashes antes/después coincidentes.

Primera suite: **1569/1569 tests**, **18645 asserts**, **113 scripts**, **0 `SCRIPT ERROR`/`Parse Error`**. Suite final después de corregir el pino y reimportar: **1569/1569 tests**, **18645 asserts**, **113 scripts**, **0 `SCRIPT ERROR`/`Parse Error`** (`validation/gut_final.log`).

Salidas completas en `validation/`: importación inicial/final, rasterización, captura gráfica y GUT inicial/final. La primera rasterización se inició antes de terminar la importación y produjo errores de recursos de audio todavía no importados (`contact_initial.log`); se conservó ese intento y se volvió a ejecutar después de importar. Las ejecuciones finales de imágenes solo muestran los avisos del uso de `Image` y `resources still in use` al cerrar, conocido del método T249. La importación imprime el aviso de conexión a ADB `tcp:5037` no disponible. El test de `no_existe` emite su `ERROR` esperado; no es un `SCRIPT ERROR`.

Tras las verificaciones se revisó `git status`: solo los 27 SVG intencionales y el material de esta entrega; no hubo assets ajenos reescritos que restaurar. La documentación central se deja a coordinación para evitar solapamientos con otros despachos.
