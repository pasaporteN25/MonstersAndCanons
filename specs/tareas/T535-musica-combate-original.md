# T535 · Muestra original nueva para la música de combate

- **Ejecutor:** Codex · **Tamaño:** mediano · **Tipo:** 🎵 propuesta de audio.
- **Depende de:** ninguna. RF-354/D-020 ya establecen música original sintetizada por código.
- **Compuerta:** Lucas escucha la muestra y aprueba explícitamente antes de reemplazar `assets/audio/music_combat.wav`.

## Leer

- `CLAUDE.md`, `specs/00-constitucion.md` y `specs/tareas/README.md`
- RF-116, RF-354, D-020 y B-27 en `specs/01-spec.md` / `specs/04-decisiones.md`
- `art/redesign-m36/README.md` y manifiesto de audio
- `assets/audio/music_combat.wav`, `assets/audio/music_menu.wav`, `tools/make_sounds.gd`

## Objetivo

Presentar una nueva pieza original de combate con más desarrollo que el bucle actual. Lucas eligió electrónica de ciencia ficción y el destino «Combate» el 2026-10-27.

## Alcance

- Componer una melodía propia y arreglo electrónico/cinemático desde cero; usar únicamente síntesis y código propios, sin muestras, loops, melodías ni paquetes de audio ajenos.
- Crear una muestra de bucle de combate, su generador determinista, manifiesto de procedencia y una página sencilla para escuchar la propuesta frente a `music_combat.wav`.
- Conservar por separado todas las fuentes y la exportación de la propuesta bajo `art/t535-combat-music/`.
- Pedir revisión por GitHub con enlace directo al WAV reproducible/descargable.

## Fuera de alcance

- No tocar `assets/audio/`, `Audio`, escenas, buses, controles de volumen ni el uso de las pistas actuales.
- No afirmar que la melodía es matemáticamente única respecto de todo YouTube. Se compone sin referencias melódicas externas; si Lucas comparte el video, se puede comparar esa referencia de forma específica.
- No implementar cambios de combate, SFX, mezcla global ni música de menú.

## Hecho cuando

- La página permite escuchar la pista actual y la propuesta, con duración y dirección musical anotadas.
- La pieza propuesta tiene comienzo/fin de loop suaves, sin clipping digital, y su generación repetida produce el mismo archivo.
- El manifiesto declara herramientas, proceso y ausencia de fuentes de terceros.
- `assets/audio/` y el código del juego no cambian; `git diff --check` pasa.
- La tarea queda en revisión de Lucas: aprobar para una futura tarea de integración, pedir cambios o conservar la música actual.

## Verificación

Inspección de duración, canales, frecuencia de muestreo, pico/RMS, continuidad del loop, escucha comparativa y hash reproducible. No correr GUT ni `--import` porque la muestra vive fuera del runtime y no modifica código o assets activos.

## Frenar si

La pieza requiere una referencia con derechos, algún archivo de tercero o cambios de integración. No reemplazar la pista activa ni usar material protegido.
