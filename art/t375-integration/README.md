# T375 · Integración del arte de Novedades

Lucas autorizó integrar los `news_*.png` aprobados en el pedido del 2026-10-20. Las muestras y sus fuentes de T372 se conservan intactas. Esta carpeta registra las mediciones de la integración; no produce arte nuevo.

Los diez PNG se copiaron byte por byte a `assets/ui/novedades/`. La presentación conecta siete medallones y la cabecera 4:1; la banda 8:1 y el medallón `upgrade` quedan disponibles sin agregar textos. Cabecera al ancho interior, título y subtítulo debajo sobre el panel oscuro, íconos a 48 px en PC y 64 px en celular. Una novedad sin ícono conserva el rombo.

Las importaciones usan compresión sin pérdida (`compress/mode=0`) y no generan mipmaps. `import_report.json` registra tamaño, SHA-256, peso fuente y bytes del `.ctex` real. Ese peso mide las texturas importadas, no una APK exportada.

La versión del proyecto, los presets y `borrador: true` se mantienen. No se generan APK ni ejecutables. La integración se publica en un PR para revisión de Lucas, sin mergear.


## Medición y límites

Los diez PNG suman **367.142 bytes de origen** y **365.880 bytes importados** (0,349 MiB). La cabecera de presentación ocupa **291.062 bytes importados** (0,278 MiB), por debajo del límite de 1 MiB. Todos conservan el SHA-256 de su muestra aprobada. La medición corresponde a los `.ctex` generados por Godot 4.7.2, sin mipmaps, y no al tamaño final de una APK.

Se ejecutó `godot --headless --import` sobre la integración original y el árbol limpio de revisión, con código 0 y sin `SCRIPT ERROR` ni `Parse Error`. Los diez SHA-256 y tamaños de `.ctex` se volvieron a comparar con `import_report.json`: coinciden. El editor informó que el daemon ADB no estaba disponible; no se produjo ninguna exportación.

Los datos y la configuración de QA se aislaron en `~/orca/qa/t375/data` y `~/orca/qa/t375/config`, sin tocar el guardado de Lucas ni escribir artefactos grandes en `/tmp`.

## GUT

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

La suite final repetida sobre la rama limpia de revisión pasó **147 scripts, 2061/2061 tests y 22.880 aserciones**, código 0, sin `SCRIPT ERROR` ni `Parse Error`, en **120,311 s**. La corrida original también pasó en 146,96 s. `check_novedades.gd` se repitió sobre la rama final: una versión válida, en borrador, proyecto `beta`.

Las seis pruebas nuevas verifican datos y texturas, medidas PC/celular, proporciones con redondeo a píxel entero, título y botón dentro de la ventana, desplazamiento hasta la última fila, mezcla de ítems con/sin ícono y las diez importaciones sin mipmaps.

El validador `check_novedades.gd` dio resultado válido y código 0, pero informó al cerrar 2 instancias/1 recurso pendientes de liberación; no hubo `SCRIPT ERROR` ni `Parse Error`. No se probó un celular físico ni se midieron FPS/VRAM. El peso importado no equivale al tamaño final de una APK. La lista de publicación sin ejecutar está exclusivamente en la entrada T375 del tablero.

## Capturas reales

En `captures/1280x720/` y `captures/2400x1080/` están las ocho capturas revisadas: PC/celular, inicio/final de la lista oficial. La cabecera se conserva completa, los textos se leen sobre el panel oscuro, los medallones conservan proporción y «Entendido» permanece visible; se llega a la séptima novedad. Las imágenes tienen exactamente las resoluciones indicadas.

La herramienta usa un viewport con la resolución pedida aunque el monitor limite la ventana, y espera la liberación de nodos antes de cerrar. Ambas corridas terminaron con código 0 y sin errores ni advertencias de fugas. Es una revisión de la interfaz celular en Linux, no una prueba en un teléfono físico.
