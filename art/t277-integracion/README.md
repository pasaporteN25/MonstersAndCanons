# T277 · Integración del arte aprobado

Lucas aprobó todas las muestras de T267b y autorizó integrarlas en el despacho de T277 del 2026-10-16. Se trajo `origin/feature/t267b-assets-nuevos` con merge, sin conflictos ni pérdida de bloques de specs. Las fuentes, los prompts y las hojas aprobadas permanecen en `art/t267b/`.

## Qué se integró

- 18 PNG idénticos a los derivados aprobados, en `assets/sprites/map/rendered/`, con mipmaps: mina y bosque en tres estados, escombros en dos, Central en cuatro cuartos y seis estatuas (tres torres × dos materiales).
- `MapDrawings.TEXTURES` usa el estado inicial y los cuatro cuartos de Central. `LevelDecor` recibe el `ObstacleField` real desde `Game`, consulta su estado y se redibuja cuando se habilita/agota una extracción, empieza/cancela/termina una demolición. Se conservan marcas, reserva, velos y barras de progreso de `ObstacleLayer`.
- Las cinco estatuas de leyenda de los niveles 1, 3 y 5 eligen Cañón, Francotirador o Ametralladora con `posmod(x + 7*y, 3)`. Musgo en pradera; escarcha disponible cuando una leyenda con `estatua` usa tema `nieve`. El nivel 13 no tiene estatuas y no se agregaron. No se cambiaron los datos, las casillas bloqueadas ni su decoración automática (incluidas las estatuas anteriores de ruinas), suelos, flores, torres, economía o recorridos.
- Central continua de 2×2 en las mismas cuatro casillas del nivel 15. Sin escena de torre, selección ni círculo de alcance para las estatuas.
- Auditoría `KNOWN_UNUSED` actualizada para los cuatro SVG de Central reemplazados; se conservan las fuentes históricas. Se actualizó el test que esperaba dibujos provisorios y se agregaron pruebas de estados reales, cancelación y materiales/variantes de las estatuas.

## Capturas y reproducción

```bash
godot --headless --import
godot --path . --resolution 1280x720 art/t277-integracion/capture.tscn
python3 art/t277-integracion/build_review.py
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Las **32 capturas de 1280×720** usan `game.tscn` real dentro de un SubViewport de tamaño fijo, con sus niveles y cámara reales, sin reemplazar la decoración. Hay una toma inicial, activa, agotada y despejada por cada nivel 1, 3, 5, 11, 12, 13, 14 y 15. En los niveles sin infraestructura las cuatro tomas repiten el estado visual. Las transiciones se preparan llamando al campo real: habilitar sitios, ordenar trabajo, completar producción y adelantar el reloj de demolición; **no son una partida humana ni una secuencia de oleadas jugada**. Se conserva la superposición de reserva/velo y los efectos de la demolición. El guardado de captura se aísla en `user://test_t277_capture.json`.

El sondeo llama al recorrido de toque del controlador en cada una de las cinco estatuas y comprueba que no hay torre, selección de torre ni selección de infraestructura y que la casilla sigue sin permitir construir. No inyecta eventos físicos de mouse ni de pantalla táctil. Las capturas iniciales posteriores al sondeo no muestran panel de objeto ni círculo de alcance.

Se miraron las ocho capturas completas iniciales, la [vista reducida al 50 %](overview.png) y los [recortes a tamaño nativo de los estados](states_native.png): estatuas con pedestal y una casilla, estados distinguibles y Central sin junta interna. El velo agotado sigue oscureciendo bastante los sprites, tal como antes; no se quitó para mejorar artificialmente la muestra. El control `validation/art_check.json` compara bytes de los 18 PNG, reconstruye el máster de Central píxel a píxel, verifica mipmaps, resolución y diferencias entre estados.

## Validación y límites

Los registros finales son `validation/import_verified.txt`, `validation/capture_verified.txt` y `validation/gut_verified.txt`; los archivos con `first_attempt`, `first_run` y `audio_diagnostic` son intentos previos, no evidencia de la versión final. La primera importación compiló scripts antes de importar los PNG nuevos y produjo errores de preload; las siguientes importaciones resolvieron ese orden. La captura inicial dejó un playback de música al cerrar; la herramienta de captura final detiene el audio y espera cinco cuadros antes de salir. No se modificó el audio del juego.

Importación final y captura final con salida 0 y sin `SCRIPT ERROR`, `Parse Error`, `Failed to load script` ni errores del motor. La importación conserva el aviso de que ADB no atiende en `tcp:5037`. Se revisó el estado y se ejecutó `git checkout -- assets`; se retiraron únicamente cuatro traducciones generadas accidentalmente al importar el CSV de T276.

La suite completa final pasó **1660/1660 tests**, 20.135 aserciones y 118 scripts en 64,367 s, salida 0; sin `SCRIPT ERROR`, `Parse Error` ni `Failed to load script`. Conserva el error esperado del fixture `no_existe`, los avisos provocados por pruebas de datos corruptos y huérfanos informados por GUT. No se probaron partidas humanas completas, balance, todas las oleadas, eventos físicos de toque/clic, Windows, Android, exportaciones, FPS ni medidas físicas en un celular. La escarcha está integrada y cubierta por tests, pero no aparece en estos mapas porque no contienen una estatua sobre nieve. No hay permisos pendientes. El despacho pide informar a coordinación y hacer push de la rama, sin publicaciones por otros canales; no se abre PR en esta ejecución.
