# T535 · Muestra de música de combate

La propuesta es una pieza de combate electrónica de ciencia ficción, compuesta sin tomar referencias melódicas externas. Se genera desde `build_preview.gd` y no depende de sonidos ni archivos de audio de terceros.

## Escucha

Abrí [`listen.html`](listen.html) para comparar la pista actual con `combat_proposal.wav`. El WAV nuevo también se puede reproducir o descargar directamente.

## Dirección

- 108 BPM, 32 compases (aprox. 71 s), bucle estéreo.
- D menor con segunda menor y suspensiones para un color de ciencia ficción oscuro.
- Arreglo con pad armónico, motivo de sintetizador, arpegio sincopado, bajo pulsante y percusión electrónica.
- Cambios de densidad por bloques de ocho compases; final atenuado para llegar a silencio antes de volver al inicio.
- Normalización por RMS a un nivel similar al audio actual, con pico limitado para evitar recorte digital.

La página y el audio son una muestra de revisión. No se sustituye `assets/audio/music_combat.wav` sin el OK escrito de Lucas.

## Reproducir la muestra

Desde la raíz del proyecto:

```bash
godot --headless --path art/t535-combat-music -s res://build_preview.gd
```

El resultado es `art/t535-combat-music/combat_proposal.wav`. La generación no escribe en `assets/audio/` ni carga los autoloads del juego.
