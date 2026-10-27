# T536 · Nueva muestra original de música de combate

- **Ejecutor:** Codex · **Estado:** muestra pendiente de aprobación de Lucas; tarea abierta.
- **Refs:** M36, D-020, RF-354; pedido expreso de Lucas tras rechazar T535 por demasiado básica.
- **Dependencias:** síntesis ya habilitada por D-020/RF-354; producción de esta propuesta autorizada por Lucas. Cualquier integración requiere primero su escucha y aprobación.

## Objetivo y alcance

Proponer una composición electrónica de ciencia ficción para el combate de Monsters & Canons, con motivo identificable, evolución y capas funcionales. No leer, reutilizar ni tomar como plantilla la melodía de T535. Solo síntesis reproducible por código, sin música ajena, samples/loops externos ni dependencias nuevas.

Entregar en `art/t536-combat-music/` WAV estéreo de 90–120 s, generador Python estándar, `revision.html` en español con reproductor relativo y notas, README de estado y evidencia técnica. Conservar intactos audio activo, escenas, runtime, opciones, balance, RF/D existentes y changelog. Al publicar la propuesta, no ejecutar GUT porque no se modifica juego.

## Plan de la propuesta

«Vigilia de frontera»: 48 compases a 112 BPM, centro en re menor. Seis bloques: introducción, exposición, respuesta/contraste, tensión, clímax y salida con resolución. Bajo sincopado, percusión sintetizada con variación de acento, armonía sostenida, frase principal de dos compases y balizas/contracanto FM. Render PCM estéreo, semilla fija, mezcla con margen de pico y cierre suave. La propuesta no define todavía un loop de producción.

## Hecho cuando

- El WAV se puede escuchar desde el HTML servido o descargado junto a sus archivos, con estructura, motivo y funciones de capas documentadas.
- El generador local regenera el mismo archivo en el entorno verificado y no usa dependencias nuevas ni fuentes externas.
- Las verificaciones comprueban audio no vacío, formato, ausencia de saturación digital y rutas relativas existentes, y declaran límites.
- Lucas escucha y aprueba expresamente la muestra. Hasta entonces mantener T536 sin marcar como completada. Aprobar la muestra no integra automáticamente el audio.

## Resultado provisional · 2026-10-27

Artefacto producido: «Vigilia de frontera», 106,057 s, WAV PCM estéreo de 44.100 Hz / 16 bits, generador y visor en `art/t536-combat-music/`. La melodía de T535 no se consultó ni se reutilizó.

Verificaciones técnicas y regeneración registradas en `../../art/t536-combat-music/verification.json`: dos renders idénticos byte a byte, WAV no vacío, pico cercano a −2 dBFS, cero muestras a escala completa, energía por ventanas, offset continuo y canales distintos; revisión estática de enlaces/HTML y alcance del diff. Sin Godot/GUT porque no se modifica juego.

**Pendiente:** escucha y aprobación de Lucas. Sin evaluación auditiva humana, prueba de fatiga durante una partida larga, mezcla con efectos ni reproducción en navegador. No se verificó unicidad contra YouTube. No hay integración; la escucha y aprobación de Lucas siguen pendientes.
