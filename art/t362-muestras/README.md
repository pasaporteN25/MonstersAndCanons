# T362 · Muestras de arte para aprobar

Muestras de **Refuerzo (nivel 2)** y **Maestría (nivel 3)** para Lucas. Abrí [comparison.html](comparison.html): reúne reproducción, selección de suelo y tinte, comparación contra el anillo actual, pausa por cuadro, mezcla normal/aditiva y escalas 70 %, 100 % y 150 %. Mantener el zoom del navegador al 100 % para revisar las medidas indicadas.

**Estado: propuesta artística; sin aprobación ni integración.** La solicitud de este despacho autoriza producir muestras; no se interpreta como aprobación de M65, D-135 ni P-65-6. T360 figura completa, pero esas decisiones siguen abiertas en los documentos leídos. Por pedido de Lucas todo queda en `art/t362-muestras/`, reemplazando para este despacho la carpeta `art/mejoras-m65/` de la ficha. No se modificó el tablero ni se marcó T362 como terminada.

## Qué se produjo

| Pieza | Formato | Tiempo | Peso del atlas |
|---|---|---|---|
| [Refuerzo](upgrade_l2.png) | PNG RGBA 768×384; 4×2 cuadros de 192×192 | 0,5 s; 16 cps | 27.924 bytes (27,27 KiB) |
| [Maestría](upgrade_l3.png) | PNG RGBA 768×384; 4×2 cuadros de 192×192 | 0,7 s; 11,428571 cps | 53.552 bytes (52,30 KiB) |

Centro contractual `(96, 96)`, orden izquierda a derecha y arriba abajo. Primer cuadro casi vacío, último totalmente transparente. Margen transparente de al menos 8 px por cuadro. Alfa recto; sin fondo, sombras, contornos oscuros, texto ni símbolos. Color marfil casi blanco, con bordes suaves por alfa y un núcleo claro. El tinte se multiplica por RGB y conserva el alfa.

- Refuerzo: un anillo elíptico que asciende desde la base hacia el mecanismo y se abre; seis chispas pequeñas. Envolvente visible máxima de unos 123 px de ancho.
- Maestría: el mismo gesto, doble anillo escalonado, ocho chispas en abanico y un destello en cruz desplazado hacia arriba para liberar el mecanismo. Envolvente visible máxima de unos 156 px de ancho.
- `sources/`: 16 originales SVG nativos y sus 16 cuadros rasterizados sin pérdida. No se usó generación de imágenes por IA ni se retocaron las torres existentes.
- `pack.py`: fuente procedural reproducible, rasterizador a 4×, empaquetador y generador de hojas y GIF. Solo escribe dentro de esta carpeta; lee referencias del repositorio.
- `prompts.md`: consignas normalizadas y criterios de producción.
- `manifest.json`: tamaños, anclaje, cuadros, duración, pesos, tintes, límites alfa y procedencia/hash de las referencias.
- `contact/`: cuatro hojas PNG de 1600×3424. Cada una incluye ambos efectos, los ocho cuadros a 192 y 34 px, neutro y cinco tintes, sobre la textura real de pradera, nieve, volcán o desierto. Los píxeles de las texturas se reducen a casillas de 64 px; no se cambiaron los suelos para favorecer el dibujo.
- `preview/`: GIF en bucle de ambos efectos junto al anillo actual, con Ametralladora 1×1 y Mortero 2×2, más los atlas teñidos usados por el HTML. Los atlas teñidos son material de revisión, **no nuevas piezas para integrar**.
- `reference/`: copias intactas de suelos, bases, atlas de torres y efectos `frost.png`/`explosion.png`, con procedencia en el manifest. Permiten llevarse la carpeta completa y abrir el HTML sin depender de `assets/`.

La animación del HTML usa exactamente 0,5 y 0,7 s, con 1 s de descanso. Los GIF mantienen esos tiempos totales, con intervalos cuantizados a centésimas por la limitación del formato. El Mortero duplica torre y efecto; el encastre del mecanismo está 24 px sobre el centro de su base, frente a 12 px para la Ametralladora. La reconstrucción del anillo actual usa `RingEffect`/`EffectsLayer.tower_built`: 0,3 s, radios 16→44,8 por footprint, grosor 3 y color propio de cada torre aclarado un 50 %. Los nuevos efectos usan los cinco valores exactos de `TowerVisual.upgrade_glow_color`.

## Verificación realizada

Se revisaron visualmente imágenes de la hoja de pradera y una comparación del tinte Hielo sobre los cuatro suelos, además de un cuadro del montaje animado con ambas torres. El doble anillo permite diferenciar Maestría a 34 px; las chispas pequeñas pierden detalle a esa escala. La lectura sobre nieve es más tenue, en especial durante entrada y salida: queda para evaluación de Lucas en la hoja completa.

`python3 art/t362-muestras/validate.py` verifica dimensiones, RGBA, margen, peso, correspondencia exacta entre cuadros raster originales y atlas, inicio/final, SVG sin filtros ni imágenes incrustadas, hashes de referencias, enlaces locales y duración total de los GIF. También se verificó la sintaxis del JavaScript del HTML. El resultado final está en `verification.txt`.

## Qué NO se pudo verificar

- **No se pudo renderizar ni operar el HTML en un navegador.** Firefox está empaquetado con Snap y no pudo iniciar por restricciones de escritura del entorno; la herramienta de navegación no tenía navegadores disponibles. La revisión visual se hizo sobre PNG y cuadros de GIF, no sobre una captura del HTML. La sintaxis del JavaScript y los enlaces locales sí se comprobaron. Quedan pendientes sus controles, carga local y reproducción efectiva en navegador.
- No se importó ni ejecutó Godot: no hay captura en partida, prueba de pausa/velocidad del juego, HUD, combate, acumulación de efectos ni medición de FPS o celular real. No se corrió GUT ni el bot de balance porque este despacho solo incorpora archivos de muestras.
- La mezcla normal está representada en los PNG y GIF. La aditiva está disponible como simulación Canvas 2D en el HTML, **sin revisión visual ni validación contra el mezclado de Godot**.
- 70 % y 150 % son escalas de revisión del mismo material en el HTML, no una prueba de dispositivo ni del zoom real de Godot. No se verificaron visualmente en navegador.
- El montaje de torre utiliza el cuadro E y base del nivel correspondiente, sin shader de brillo permanente, sombra del motor, retroceso ni animación de combate. Es una comparación de tamaño y cobertura, no una captura del juego.
- Peso informado: PNG fuente. No se midió textura importada, VRAM ni peso en APK. No se configura mipmap/importación en este despacho.

## Decisiones abiertas

1. Lucas debe confirmar **P-65-6: único efecto teñido o uno por familia**. Esta muestra sigue la propuesta de dos atlas teñibles; no se produjeron seis atlas ni se cerró la decisión.
2. Aprobar o ajustar intensidad, velocidad del ascenso, tamaño de las chispas y diferencia entre niveles, especialmente a 34 px y sobre nieve.
3. Elegir la mezcla final en Godot después de comparar su lectura con el tinte y los efectos reales del combate. Este paquete no decide cambios de renderizado ni de código.
4. Obtener el OK escrito antes de cualquier integración de T364. M65 y sus restantes decisiones de presentación conservan su estado documental.

La animación **no cambia la lógica del juego**: no modifica costos, tiempos jugables, daño, niveles, alcance, controles ni disparadores. No se tocó `scenes/`, `scripts/`, `data/`, `assets/` ni `project.godot`. No se hizo push ni PR.

## Commit local pendiente por el entorno

Se intentó preparar el commit pedido, pero `git add` falló antes de agregar archivos: no puede crear `/home/newman/Documentos/Proyectos/TDv1/.git/worktrees/codex-t362/index.lock` porque ese directorio es de solo lectura en este entorno. **No se creó el commit ni se alteraron permisos.** Quien lanzó la tarea puede completarlo desde un entorno con acceso de escritura a los metadatos de Git:

```bash
git add -- art/t362-muestras
git diff --cached --check
git commit -m 'T362: muestras de arte para aprobar'
```

## Reproducir

Requiere Python 3, Pillow (verificado con 12.1.1) y la fuente DejaVu Sans del sistema. Desde la raíz del repositorio:

```bash
python3 art/t362-muestras/pack.py
python3 art/t362-muestras/validate.py
```

Abrí `art/t362-muestras/comparison.html` conservando toda la carpeta. Si el navegador restringe archivos locales, servila con `python3 -m http.server 8362 --bind 127.0.0.1 --directory art/t362-muestras` y abrí `http://127.0.0.1:8362/comparison.html`. No hace falta instalar nada en Godot.
