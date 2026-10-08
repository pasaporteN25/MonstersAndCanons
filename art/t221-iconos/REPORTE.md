# T221 · Entrega provisional de iconos

Se entregan tres iconos SVG de 64 × 64: material genérico, pieza de colección de la Disruptora y demoledora compacta. Las fuentes están en `sources/`, los prompts normalizados y el manifest acompañan la entrega, y las hojas de contacto muestran los tres a 220 y 34 px.

**Integración:** los puntos de consumo del contador, la colección y el panel de infraestructura todavía no están implementados (T209/T211). No se cambiaron escenas ni lógica. La aprobación de Lucas queda pendiente; el arte no bloquea el código.

**Verificación:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, 0 `SCRIPT ERROR`/`Parse Error`. No se probó exportación de Windows ni se pudo capturar un HUD con recursos/colección reales porque T209/T211 aún no existen; queda pendiente la revisión artística de Lucas. Ver Resultado T221 en `specs/03-tareas.md`.
