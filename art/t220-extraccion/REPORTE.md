# T220 · Entrega provisional de mina y bosque explotable

Se entregan seis estados de recursos de extracción y dos segmentos de reserva de 8 × 8. Los SVG finales están en `assets/sprites/map/`; las fuentes, prompts y manifest, en esta carpeta. Las hojas de contacto cubren la lectura a 220 y 34 px sobre pradera, bosque y ruinas.

**Integración:** T210 todavía no tiene estados de extracción visibles en el juego, por eso no se tocaron escenas ni lógica. Los dibujos mantienen la mina y el bosque como obstáculos permanentes. No se pudo capturar una mina o bosque en partida hasta que exista esa integración. Aprobación de Lucas pendiente; no bloquea el código.

**Verificación:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, 0 `SCRIPT ERROR`/`Parse Error`. Godot informó al cerrar que quedaba un recurso en uso; el log también contiene el `push_error` esperado de una prueba. No se probó exportación Windows ni se pudo capturar una partida con estos estados, porque T210 aún no existe. Ver Resultado T220 en `specs/03-tareas.md`.
