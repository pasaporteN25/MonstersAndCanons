# B-27 · Audio original y mezcla

Todos los archivos son síntesis original de `tools/make_sounds.gd`, sin descargas, grabaciones, bancos de muestras ni material de terceros. La procedencia queda también en `audio_manifest.json`. Se conserva la política/licencia del proyecto para los archivos generados; no se atribuye una licencia externa inexistente.

## Cambios integrados

-44,1kHz, PCM16 como fuente; música estéreo con ensanchamiento discreto.
- Ondas cuadradas discontinuas sustituidas por suma suave de armónicos; ruido filtrado y envolvente con ataque/final a cero. Los timbres mantienen identidad por torre: percusión grave para Cañón/Mortero, cristal para Hielo, metal corto para armas, soplido para fuego y descarga para Tesla.
- Menú: acordes menores, bajo cálido y arpegio a84BPM,45,71s. Combate: mismo mundo sonoro,112BPM, percusión y34,29s. Son composición procedural original, no grabación instrumental. Cambio de pista con salida0,2s/entrada0,3s; abrir otra pantalla del menú no reinicia la misma pista. Buses y controles de Opciones intactos.
- Señales propias de impacto, rebote, hechizo y cura; se conservan muerte, construcción, mejora, venta, oleada, combo, victoria, derrota y clic.
- Nueve voces reservadas para disparos/impactos; tres para avisos. Los disparos no cortan un aviso. Volumen relativo: disparos-9dB, cura-5dB, avisos-2dB, música-5dB antes de los buses del usuario. Variaciones de afinación de disparo97/100/103%, sin usar el RNG del juego.
- Repetición mínima de disparos80ms; impacto120ms, rebote150ms, hechizo200ms y cura800ms, para controlar saturación. Los combos mantienen su intervalo existente.
- Limitador HardLimiter en Master con techo-1dB y recuperación100ms evita el recorte de la suma de voces, conservando buses y controles del usuario.
- Fuente limitada a pico0,75 en efectos y0,45 en música, sin recorte por suma de capas. Manifest incluye duración, tasa, pico y RMS. No equivale a medición LUFS ni a revisión subjetiva con auriculares.

## Muestras y reproducción

Música: `assets/audio/music_menu.wav` y `music_combat.wav`. Efectos individuales en la misma carpeta; `reflect.wav`, `stun.wav`, `heal.wav`, `impact.wav` son nuevos. Regenerar con `godot --headless --path . -s tools/make_sounds.gd`; luego importar. Los bucles se conservan con edit/loop_mode=2 en sus .import.

Verificación: bucles, tasa y estéreo por GUT; separación de voces y misma pista sin reinicio; picos/RMS por manifest. Escuchar muestras y una partida completa con Opciones al50% permite la revisión humana de gusto/fatiga, que no se puede sustituir por esos checks. No se ejecutó una prueba auditiva humana en esta sesión.
