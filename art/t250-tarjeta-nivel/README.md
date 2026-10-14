# T250 · Tarjeta de nivel

Capturas de la escena real `LevelSelect`, antes y después de separar los bloques de cada tarjeta. Se tomaron al iniciar el proyecto Godot en una ventana OpenGL, con el guardado cambiado a un archivo temporal para abrir o bloquear los niveles 6, 8 y 10 sin tocar el progreso del jugador. El render del escritorio salió a 1777 × 999 por el escalado del monitor; los PNG se guardaron a 1280 × 720, la resolución lógica configurada en el juego.

El nivel 1 aparece abierto en todas las capturas: RF-112 establece que siempre está desbloqueado. No se fabricó un estado bloqueado que el juego no puede tener.

## Antes

- [Nivel 1, abierto](captures/before/level_01_unlocked.png)
- [Nivel 6, bloqueado](captures/before/level_06_locked.png) · [abierto](captures/before/level_06_unlocked.png)
- [Nivel 8, bloqueado](captures/before/level_08_locked.png) · [abierto](captures/before/level_08_unlocked.png)
- [Nivel 10, bloqueado](captures/before/level_10_locked.png) · [abierto](captures/before/level_10_unlocked.png)

## Después

- [Nivel 1, abierto](captures/after/level_01_unlocked.png)
- [Nivel 6, bloqueado](captures/after/level_06_locked.png) · [abierto](captures/after/level_06_unlocked.png)
- [Nivel 8, bloqueado](captures/after/level_08_locked.png) · [abierto](captures/after/level_08_unlocked.png)
- [Nivel 10, bloqueado](captures/after/level_10_locked.png) · [abierto](captures/after/level_10_unlocked.png)

`capture.gd` es el capturador de la escena. Para usarlo, agregarlo temporalmente a `[autoload]` en `project.godot`, iniciar `scenes/ui/level_select.tscn` con `--resolution 1280x720` y un directorio de guardado temporal; luego quitar esa entrada. No forma parte de la carga normal del juego.
