# T367 · Muestras de arte para aprobar

Abrí [comparison.html](comparison.html) con zoom del navegador al 100 %. Todas las imágenes tienen medidas explícitas: las grandes se desplazan horizontalmente, no se achican para entrar. Esta entrega responde al pedido de producir **solo muestras** en `art/t367-muestras/`, que reemplaza la ruta `art/jefes-m66/` de la ficha para este despacho.

## Lo producido

| Pieza | Formato | Peso exacto | Uso propuesto |
|---|---|---:|---|
| `boss_burst.png` | PNG RGBA 1024×512, 4×2 de 256×256 | 54.987 bytes | Aro, luz ascendente, polvo y esquirlas; neutro para teñir |
| `boss_crack.png` | PNG RGBA 192×96 | 10.924 bytes | Grieta oscura sin tinte, con polvo apagado |
| `boss_card_frame.png` | PNG RGBA 192×128 | 3.748 bytes | Hierro/bronce; 9-slice de 32 px, centro transparente |

El atlas conserva el anclaje (128,176), márgenes de al menos 8 px y ocho cuadros en orden de lectura. Dura 0,7 s a 11,428571 cps; el cuadro 1 es casi vacío y el 8 es completamente transparente. No hay mipmaps, sombras pintadas, texto ni símbolos en estas tres piezas. El alfa es real, sin mate negro. El marco conserva los remaches al estirar a 720×120.

`review/` contiene las hojas a 256 y 34 px, cinco tintes (neutro, carmesí, azul acero, verde y rojo de los datos), ocho montajes de la entrada del nivel 1 a 1280×720 en fila en el HTML, GIF en bucle, cartel armado de 720×120 y vistas PC/celular. El retrato de referencia mide 34 px en las hojas y 96 px en el cartel. El GIF anima 700 ms y espera 1.400 ms para que puedas revisar la repetición; no representa una repetición dentro del juego. Los ocho tiempos del GIF se redondean a centésimas sin alterar la duración total.

## Fuentes y reproducción

`pack.py` es la fuente de dibujo y el empaquetador nativo: formas, colores, curvas y semillas quedan reproducibles. `sources/burst_01.png` a `burst_08.png` conservan los cuadros separados; `crack_original.png` y `frame_original.png` son las fuentes raster sin empaquetar. `prompts.md` conserva las instrucciones normalizadas de diseño. No se usó IA generativa.

Las referencias en `sources/` son copias exactas de `assets/sprites/enemies/rendered/boss.png`, `boss_walk.png` y `art/t277-integracion/level_01_initial.png`; sus rutas y hashes están en `manifest.json`. La captura de T277 documenta una escena real del nivel 1 con su barra superior; **es histórica y no fue recapturada en este despacho**. No se redibujó el retrato ni se crearon poses nuevas del jefe.

Desde la raíz del repositorio, con Python 3, Pillow y la fuente Lato de Linux:

```bash
python3 art/t367-muestras/pack.py
python3 art/t367-muestras/validate.py
```

`pack.py` escribe exclusivamente en esta carpeta. No importa ni ejecuta Godot. La hoja HTML y los documentos se conservan como fuentes de revisión.

## Qué se verificó

Se inspeccionaron visualmente las hojas, los montajes del efecto y del cartel, y la grieta. `validation.json` registra dimensiones, RGBA, pesos, transparencia final, márgenes, neutralidad del destello, transparencia del centro del marco, conservación de esquinas y duración del GIF. Compara además la barra superior de los ocho montajes con la captura original: no se modifica ningún píxel de esa franja. Comprueba los vínculos locales de la hoja y los hashes de las referencias. Los tres archivos pesan menos de 250/30/40 KB, respectivamente.

El efecto se compone debajo del jefe, que permanece visible en el montaje. Las hojas permiten revisar polvo y luz con tintes multiplicativos sin hornear el rojo. La grieta está debajo y se desvanece en los montajes durante los mismos 0,7 s. En la entrada real se recorta parte del aro por el borde izquierdo; no se desplazó el punto de nacimiento para ocultarlo.

## Lo que no se pudo verificar

No se integró nada ni se ejecutó Godot, GUT, una partida, Android o pruebas de rendimiento. No se verificaron importación, filtrado en GPU, jerarquía final de capas, coordenadas finales del nodo, escala exacta del jefe, corona, barra de vida, pausa, doble velocidad, salteo, límites de frecuencia ni igualdad de balance: corresponden al código y la integración posteriores. El desplazamiento del jefe en el montaje usa la velocidad actual de los datos como aproximación, no la transformación completa del dibujo del juego. El GIF anima el montaje, no demuestra una partida funcionando.

La vista de 2400×1080 amplía el lienzo PC al 150 % con bandas laterales de 240 px; **no es una captura del HUD móvil ni valida su adaptación**. La barra de la captura dice 0/10 porque se preservó el original histórico; no se la presenta como evidencia de la oleada 10. El cartel y el destello se muestran por separado: M66 pide que el cartel espere al aviso de oleada, no que salgan al mismo tiempo.

## Decisiones abiertas para Lucas

- **Lectura del verde:** en la hoja de pradera, el tinte verde tiene contraste bajo, especialmente a 34 px. No lo doy por resuelto: revisar si alcanza en movimiento o hace falta ajustar la cobertura neutra antes de integrar. No se horneó un color propio para ocultar este límite.
- Aprobar o pedir ajustes de intensidad del destello, cantidad de polvo, grieta y familia visual del marco. El dibujo es una propuesta nativa simple, pendiente de revisión en movimiento dentro del juego.
- La ficha pide carmesí **#ba403e**; `boss.tres` usa **#c0392b** (color convertido a RGB de 8 bits). Se muestran ambos sin cambiar los datos. La integración debería modular por el color del recurso según RF-601.
- El título y el nombre son dos rótulos; la descripción completa del recurso necesita **dos renglones a 20 px** dentro del ancho restante. Se mantienen tres rótulos pero cuatro renglones visibles. Confirmar esa disposición o aprobar una frase más corta para `entrance.line`; no se inventó ni recortó texto.
- El aro queda parcialmente cortado a la izquierda por la ubicación real de la entrada. Confirmar si este recorte natural resulta aceptable; cualquier ajuste de posición corresponde a la integración y debe respetar el anclaje del jefe.
- Sigue pendiente el OK de M66 y las preguntas P-66-1/P-66-5 de la ficha. T365 figura hecha, pero eso solo acredita la especificación. Esta entrega no aprueba el piloto ni un retrato animado.

No se tocó `scenes/`, `scripts/`, `data/`, `assets/` ni `project.godot`. No se modificaron tablero ni changelog porque el pedido limita todos los cambios a esta carpeta y T367 todavía requiere aprobación e integración. La animación es presentación: no cambia ninguna regla ni parámetro jugable. El commit local de muestras no implica aprobación artística, cierre de T367, push ni PR.

## Estado del commit local

Se intentó preparar el commit pedido, `T367: muestras de arte para aprobar`, pero `git add -- art/t367-muestras` falló: Git no puede crear `/home/newman/Documentos/Proyectos/TDv1/.git/worktrees/codex-t367/index.lock` porque el directorio Git compartido está en un sistema de archivos de solo lectura para esta sesión. No se creó ningún commit ni se hizo push o PR. No se alteraron permisos ni configuración para sortear la restricción.

Quien lanzó la tarea puede completar el único commit local desde este worktree, en una sesión con escritura en su directorio Git:

```bash
git add -- art/t367-muestras
git commit -m 'T367: muestras de arte para aprobar'
```

La estructura y los vínculos del HTML se verificaron con el validador; no se probó su reproducción interactiva en un navegador durante esta sesión.
