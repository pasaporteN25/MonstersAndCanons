# T372 · Familia completa de íconos de «Novedades»

Continuación del paso 2 de T372 (2026-10-20). **Lucas aprobó el estilo de las muestras anteriores —cabeceras, mapa y torre— y autorizó producir los seis íconos faltantes**, según el encargo de esta sesión. Ya están los ocho medallones; los seis nuevos y la hoja completa quedan para revisión de Lucas. La aprobación del estilo no cierra los textos de P-67-1 ni autoriza integrar en este encargo. T372 sigue abierta: la integración la hace otro agente. No se modificaron el tablero ni el changelog porque esta entrega está limitada a `art/t372-muestras/` y nada cambió para quien juega.

Abrí [comparison.html](comparison.html) con zoom del navegador al 100 %. Hay imágenes con tamaño fijo y desplazamiento horizontal para que el navegador no las reduzca automáticamente.

## Qué se produjo

| Pieza | Formato | Peso real |
|---|---|---:|
| `news_header_1_0.png` | PNG opaco indexado, 1280 × 320 | 282.603 bytes |
| `news_header_plain.png` | PNG RGB opaco, 1280 × 160 | 4.550 bytes |
| `news_icon_map.png` | PNG RGBA, 96 × 96 | 10.150 bytes |
| `news_icon_tower.png` | PNG RGBA, 96 × 96 | 10.136 bytes |
| `news_icon_monster.png` | PNG RGBA, 96 × 96 | 10.649 bytes |
| `news_icon_siege.png` | PNG RGBA, 96 × 96 | 10.052 bytes |
| `news_icon_editor.png` | PNG RGBA, 96 × 96 | 9.999 bytes |
| `news_icon_mobile.png` | PNG RGBA, 96 × 96 | 9.071 bytes |
| `news_icon_book.png` | PNG RGBA, 96 × 96 | 10.002 bytes |
| `news_icon_upgrade.png` | PNG RGBA, 96 × 96 | 9.930 bytes |

La cabecera muestra el oasis con campamento, cuatro torres y dos monstruos lejanos. Se mantiene la técnica de pluma sepia y acuarela de la intro, con una mañana más luminosa. Sin texto ni emblemas. La banda sobria tiene hierro, bronce, remaches y grabados abstractos; sus extremos coinciden píxel a píxel y el módulo se repite cada 160 px.

Los ocho medallones usan hierro, bronce y crema, contorno `#2b2233` de 2 px, degradés de tres paradas y alfa real. El mapa lleva camino y cruz; el cañón lleva tres muescas de nivel. Se conserva exactamente el medallón y la paleta aprobados. Los nuevos motivos son: bestia cornuda mirando a la derecha, flecha que golpea una muralla, cuadrícula con casilla de bronce y pala, celular delante de monitor, cuaderno abierto y flecha ascendente sobre chispa. Sin letras, números, filtros ni imágenes incrustadas.

La hoja `contact_sheet.png` (760 × 1120) muestra la familia completa a 96, 64 y 48 px sobre el hierro del menú. Se inspeccionaron las tres escalas: los ocho motivos se distinguen y el contorno común se mantiene. La cuadrícula y la pala se leen por su masa; los trazos de página y el colmillo son detalles secundarios a 48 px. Esto es una revisión visual del agente, no aprobación de Lucas.

`mockup_pc.png` y `mockup_mobile.png` miden 1280 × 720, con panel de 720 y 880 px respectivamente. `mockup_mobile_real.png` mide 2400 × 1080. Hay vistas del final de la lista (`*_end.png`) y una lámina `all_rows.png` con los ocho textos completos del borrador de M67. Las ocho filas tienen su medallón, incluidas las vistas del final de la lista. El octavo ítem sigue siendo condicional como en la spec.

La ficha pide a la vez 2400 × 1080 y escala 1,875× respecto de 1280 × 720, pero esas proporciones difieren. La maqueta real conserva 1,875× usando un área lógica de 1280 × 576, sin estirar el contenido. Por eso muestra menos filas simultáneas. La lista debe desplazarse; no se achicó el texto para que entren las ocho filas.

## Fuentes y reproducción

- `sources/header_original.png` y `sources/header_revised.png`: salidas originales de `image_gen`, conservadas sin modificar. La primera se conserva como antecedente; la segunda alimenta la muestra.
- `sources/*.svg`: fuentes vectoriales nativas de los medallones y de la banda. `create_sources.py` las reproduce.
- `prompts.md`: prompts de ambas generaciones y descripción del dibujo vectorial.
- `pack.py`: recorte 4:1 sin deformación, reducción, cuantización a 256 colores, maquetas, comparación y manifest. Requiere Python 3 y Pillow; las maquetas usan DejaVu Sans del sistema como sustituto tipográfico, no una fuente aprobada del juego.
- `render_sources.gd`: rasteriza únicamente las nueve fuentes SVG (ocho medallones y banda). Debe ejecutarse desde un proyecto Godot temporal, no desde TDv1.
- `validate.py`: valida formato, tamaño, peso, alfa, manifest y SHA-256, preservación de las muestras aprobadas, medallón/materiales compartidos, repetición de la banda, montajes y enlaces locales del HTML. Escribe `validation.json`. No evalúa semántica artística ni prueba el juego.
- `intro_reference.png`: copia reducida para comparar con `assets/intro/07_el_oasis.png`; el original del juego no se modificó.
- `.gdignore`: evita que las muestras entren al escaneo del juego.

Comandos de preparación desde la raíz (las rutas absolutas se pueden adaptar al checkout):

```bash
python3 art/t372-muestras/create_sources.py
mkdir -p /tmp/t372-render/userdata /tmp/t372-render/config
printf 'config_version=5\n' > /tmp/t372-render/project.godot
XDG_DATA_HOME=/tmp/t372-render/userdata XDG_CONFIG_HOME=/tmp/t372-render/config godot --headless --path /tmp/t372-render --script "$PWD/art/t372-muestras/render_sources.gd" -- "$PWD/art/t372-muestras"
python3 art/t372-muestras/pack.py
python3 art/t372-muestras/validate.py
```

## Qué se verificó

Se rasterizaron los nueve SVG con Godot **4.7.2** en `/tmp/t372-render`, con datos/configuración de usuario en `/tmp`; terminó sin errores. `validate.py` pasó **123 verificaciones**: los diez recursos finales tienen el formato, tamaño y peso exigidos, los ocho íconos tienen alfa real 0–255 y el mismo medallón/materiales, los montajes contienen los ocho PNG y los enlaces locales existen. La validación inicial detectó que el celular llega a parte del límite interior de la máscara de comparación; se ajustó esa comprobación al aro exterior (radio ≥ 40 px), y la igualdad del medallón SVG completo se verifica por separado.

Las dos cabeceras, mapa, torre y sus tres fuentes SVG aprobadas conservan su SHA-256 anterior, **idénticos byte por byte**; la referencia está en `approved_baseline_sha256` del manifest. Se volvió a ejecutar el pipeline para comprobar reproducción. Se inspeccionaron la hoja completa, la lámina con ocho filas y las maquetas PC/celular (inicio y final).

En la tanda anterior se importó **una copia** de la cabecera en un proyecto temporal fuera del juego, con `compress/mode=0` y `mipmaps/generate=false`, y se midió el `.ctex` real, como hace `art/intro-v1/peso.py`: **291.062 bytes (0,278 MiB)**, menor que 1 MiB. No se ejecutó `peso.py` porque modifica las importaciones de la intro. El editor aislado produjo advertencias de sockets restringidos y un intento fallido de guardar configuración fuera del sandbox; la textura se generó y pudo medirse. La rasterización posterior con los datos de usuario en `/tmp` terminó sin errores.

El título crema `#f4ecd8` sobre el soporte opaco `#1b1c20` da **14,46:1**; el subtítulo `#d7c8a5`, **10,29:1**. Son relaciones de luminancia sRGB de colores planos, no mediciones del antialias de los glifos. Sobre la ilustración sola, el peor píxel de la zona de texto da **1,02:1**: no alcanza. Por eso las maquetas proponen un soporte oscuro explícito detrás del texto, que no está incrustado en la cabecera. Lucas debe aprobarlo o pedir una ilustración más oscura/sencilla abajo.

## Qué no se verificó y qué queda abierto

- El estilo anterior está aprobado y los seis íconos pendientes ya están producidos. Falta la revisión de Lucas de los seis nuevos y de la hoja completa antes de la integración por otro agente.
- P-67-1 y P-67-6 siguen abiertas en los documentos. La lista y los textos se usaron solo para la maqueta; no se validaron las afirmaciones contra el changelog ni se cargaron datos.
- Observación heredada de la cabecera aprobada, que no se retocó: la generación no logró por completo la base compacta pedida y el recorte panorámico deja fuera las puntas de las antenas. No se presenta como una reproducción exacta de los atlas aprobados. El tamaño y la presencia de los dos monstruos también quedan como observación de la primera tanda.
- El 40 % inferior evita objetos narrativos importantes, pero conserva textura visible. El soporte de texto resuelve el contraste en la maqueta; no se volvió a evaluar su aprobación por separado del estilo.
- No se capturó ni ejecutó el juego, no se probaron GUT, controles táctiles, desplazamiento real, Android, filtros de Godot dentro de una partida, consumo de VRAM ni tamaño final de APK. Las maquetas son imágenes de revisión, no capturas de una pantalla implementada. El peso importado se midió solo en aislamiento.
- El HTML referencia imágenes locales y ofrece alternar entre inicio y final de la lista. No se verificó el HTML en navegador en esta tanda. El intento previo con Brave headless había fallado porque el sandbox bloqueó el socket de Crashpad (`Operation not permitted`). Se revisaron las imágenes subyacentes y se validó que todas las rutas locales existen.
- No hay animación en este encargo (RF-604 prevé pantalla estática). Nada de esta muestra cambia lógica, tiempos, estados ni comportamiento del juego.

No se copiaron archivos a `assets/`, ni se tocaron `scenes/`, `scripts/`, `data/` o `project.godot`. No se declara cumplida la aceptación completa de T372: esta entrega termina en la revisión de las muestras.

## Entrega local

No se intentó `git add`, commit, push ni PR: Lucas pidió dejar los archivos listos para quien lanzó la tarea, porque los metadatos git del sandbox son de solo lectura. Los cambios se limitan a esta carpeta. La revisión artística y la integración posterior no forman parte de esta entrega.
