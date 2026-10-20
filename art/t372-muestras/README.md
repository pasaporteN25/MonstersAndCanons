# T372 · Muestras de «Novedades» para aprobar

Primera tanda del paso 1 de la ficha T372. **No es la entrega completa de T372 ni arte aprobado.** El pedido de esta sesión autoriza producir muestras; no se toma como respuesta definitiva a P-67-1/P-67-6 ni como aprobación de M67. Todo queda en esta carpeta, sin integración. No se modificaron el tablero ni el changelog porque T372 sigue pendiente y nada cambió para quien juega.

Abrí [comparison.html](comparison.html) con zoom del navegador al 100 %. Hay imágenes con tamaño fijo y desplazamiento horizontal para que el navegador no las reduzca automáticamente.

## Qué se produjo

| Pieza | Formato | Peso real |
|---|---|---:|
| `news_header_1_0.png` | PNG opaco indexado, 1280 × 320 | 282.603 bytes |
| `news_header_plain.png` | PNG RGB opaco, 1280 × 160 | 4.550 bytes |
| `news_icon_map.png` | PNG RGBA, 96 × 96 | 10.150 bytes |
| `news_icon_tower.png` | PNG RGBA, 96 × 96 | 10.136 bytes |

La cabecera muestra el oasis con campamento, cuatro torres y dos monstruos lejanos. Se mantiene la técnica de pluma sepia y acuarela de la intro, con una mañana más luminosa. Sin texto ni emblemas. La banda sobria tiene hierro, bronce, remaches y grabados abstractos; sus extremos coinciden píxel a píxel y el módulo se repite cada 160 px.

Los dos medallones usan hierro, bronce y crema, contorno `#2b2233` de 2 px, degradés de tres paradas y alfa real. El mapa lleva camino y cruz; el cañón lleva tres muescas de nivel. La hoja `contact_sheet.png` los muestra a 96, 64 y 48 px sobre el hierro del menú. Se verificó visualmente la diferencia entre mapa y cañón a 48 px.

`mockup_pc.png` y `mockup_mobile.png` miden 1280 × 720, con panel de 720 y 880 px respectivamente. `mockup_mobile_real.png` mide 2400 × 1080. Hay vistas del final de la lista (`*_end.png`) y una lámina `all_rows.png` con los ocho textos completos del borrador de M67. En las seis filas sin ícono se dejó una reserva vacía; esos cuadrados no son arte propuesto. El octavo ítem sigue siendo condicional como en la spec.

La ficha pide a la vez 2400 × 1080 y escala 1,875× respecto de 1280 × 720, pero esas proporciones difieren. La maqueta real conserva 1,875× usando un área lógica de 1280 × 576, sin estirar el contenido. Por eso muestra menos filas simultáneas. La lista debe desplazarse; no se achicó el texto para que entren las ocho filas.

## Fuentes y reproducción

- `sources/header_original.png` y `sources/header_revised.png`: salidas originales de `image_gen`, conservadas sin modificar. La primera se conserva como antecedente; la segunda alimenta la muestra.
- `sources/*.svg`: fuentes vectoriales nativas de los medallones y de la banda. `create_sources.py` las reproduce.
- `prompts.md`: prompts de ambas generaciones y descripción del dibujo vectorial.
- `pack.py`: recorte 4:1 sin deformación, reducción, cuantización a 256 colores, maquetas, comparación y manifest. Requiere Python 3 y Pillow; las maquetas usan DejaVu Sans del sistema como sustituto tipográfico, no una fuente aprobada del juego.
- `render_sources.gd`: rasteriza únicamente las tres fuentes SVG. Debe ejecutarse desde un proyecto Godot temporal, no desde TDv1.
- `intro_reference.png`: copia reducida para comparar con `assets/intro/07_el_oasis.png`; el original del juego no se modificó.
- `.gdignore`: evita que las muestras entren al escaneo del juego.

Comandos de preparación desde la raíz (las rutas absolutas se pueden adaptar al checkout):

```bash
python3 art/t372-muestras/create_sources.py
# Crear antes un proyecto Godot mínimo en /tmp/t372-render.
XDG_DATA_HOME=/tmp/t372-render/userdata godot --headless --path /tmp/t372-render --script "$PWD/art/t372-muestras/render_sources.gd" -- "$PWD/art/t372-muestras"
python3 art/t372-muestras/pack.py
```

## Qué se verificó

Se comprobaron las cuatro dimensiones de archivo, opacidad de cabeceras, alfa 0–255 en los íconos y límites de peso. Todos los PNG están por debajo de sus topes. Se rasterizaron los SVG con Godot 4.7.2 en un proyecto aislado y se inspeccionaron las imágenes de cabecera, íconos, banda y maquetas.

Se importó **una copia** de la cabecera en un proyecto temporal fuera del juego, con `compress/mode=0` y `mipmaps/generate=false`, y se midió el `.ctex` real, como hace `art/intro-v1/peso.py`: **291.062 bytes (0,278 MiB)**, menor que 1 MiB. No se ejecutó `peso.py` porque modifica las importaciones de la intro. El editor aislado produjo advertencias de sockets restringidos y un intento fallido de guardar configuración fuera del sandbox; la textura se generó y pudo medirse. La rasterización posterior con los datos de usuario en `/tmp` terminó sin errores.

El título crema `#f4ecd8` sobre el soporte opaco `#1b1c20` da **14,46:1**; el subtítulo `#d7c8a5`, **10,29:1**. Son relaciones de luminancia sRGB de colores planos, no mediciones del antialias de los glifos. Sobre la ilustración sola, el peor píxel de la zona de texto da **1,02:1**: no alcanza. Por eso las maquetas proponen un soporte oscuro explícito detrás del texto, que no está incrustado en la cabecera. Lucas debe aprobarlo o pedir una ilustración más oscura/sencilla abajo.

## Qué no se verificó y qué queda abierto

- Falta el OK de Lucas al estilo, a las dos cabeceras y a los medallones. La ficha pide este OK antes de producir los seis íconos restantes: monstruo, asedio, editor, celular, libro y mejora.
- P-67-1 y P-67-6 siguen abiertas en los documentos. La lista y los textos se usaron solo para la maqueta; no se validaron las afirmaciones contra el changelog ni se cargaron datos.
- Revisar las dos torres altas: la generación no logró por completo la base compacta pedida y el recorte panorámico deja fuera las puntas de las antenas. No se presenta como una reproducción exacta de los atlas aprobados. Revisar también si el tamaño y la presencia de los dos monstruos funcionan como fondo optimista.
- El 40 % inferior evita objetos narrativos importantes, pero conserva textura visible. El soporte de texto resuelve el contraste en la maqueta; sigue abierta su aprobación.
- No se capturó ni ejecutó el juego, no se probaron GUT, controles táctiles, desplazamiento real, Android, filtros de Godot dentro de una partida, consumo de VRAM ni tamaño final de APK. Las maquetas son imágenes de revisión, no capturas de una pantalla implementada. El peso importado se midió solo en aislamiento.
- El HTML referencia imágenes locales y ofrece alternar entre inicio y final de la lista. Se intentó una captura con Brave headless, pero el sandbox bloqueó el socket de Crashpad (`Operation not permitted`), así que su renderizado en navegador no se verificó. Se revisaron las imágenes subyacentes y se validó que todas las rutas locales existen.
- No hay animación en este encargo (RF-604 prevé pantalla estática). Nada de esta muestra cambia lógica, tiempos, estados ni comportamiento del juego.

No se copiaron archivos a `assets/`, ni se tocaron `scenes/`, `scripts/`, `data/` o `project.godot`. No se declara cumplida la aceptación completa de T372: esta entrega termina en la revisión de las muestras.

## Entrega local y bloqueo del commit

Se intentó el commit solicitado `T372: muestras de arte para aprobar`, pero el entorno rechazó crear `/home/newman/Documentos/Proyectos/TDv1/.git/worktrees/codex-t372/index.lock`: `Read-only file system`. `git add` también falló antes de modificar el índice. Los archivos quedan sin seguimiento en esta carpeta, listos para que quien lanzó la tarea los revise y confirme desde un entorno con escritura sobre los metadatos del worktree:

```bash
git add -- art/t372-muestras
git diff --cached --check
git diff --cached --stat
git commit -m 'T372: muestras de arte para aprobar'
```

No se hizo push ni se abrió PR.
