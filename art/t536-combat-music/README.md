# T536 · Vigilia de frontera

**Muestra original de música de combate, pendiente de escucha y aprobación de Lucas. No es audio aprobado ni integrado.** La pista activa permanece intacta.

Abrí [revision.html](revision.html) junto con sus archivos: incluye reproductor HTML con WAV por ruta relativa, estructura, motivo, instrumentos y límites de verificación. Para escuchar desde un PR, hay que abrir su HTML servido o descargar esta carpeta; la vista de código de GitHub no reproduce HTML.

- Audio: [frontier-vigil.wav](frontier-vigil.wav), 106,057 s, PCM estéreo 44.100 Hz / 16 bits, 112 BPM.
- Generador: [generate.py](generate.py), solo Python estándar. Desde la raíz: `python3 art/t536-combat-music/generate.py`. Con `--output /tmp/t536-check.wav` escribe una copia independiente. Con `--inspect ruta.wav` analiza sin generar.
- Evidencia técnica: [verification.json](verification.json). Se compararon dos renders completos byte a byte en el entorno registrado. Otras versiones/plataformas de Python pueden variar en los últimos bits por funciones matemáticas; no se verificaron.
- `.gdignore` mantiene esta propuesta fuera de la importación de Godot.

Composición escrita para T536 sin leer ni reutilizar la melodía de T535. Sin samples/loops externos ni música ajena. No se verificó unicidad contra YouTube. Tiene cierre propio, todavía no un empalme circular de producción.

Las verificaciones técnicas no equivalen a aprobación musical. Falta escucha de Lucas, revisión de fatiga en partidas largas y eventual mezcla con los efectos. No se ejecutaron Godot/GUT ni se probó reproducción en navegador. No hay cambios de runtime, audio activo ni integración.
