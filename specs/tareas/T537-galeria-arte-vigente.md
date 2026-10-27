# T537 · Galería del arte vigente para revisión

- **Ejecutor:** Codex.
- **Depende de:** estado integrado de `origin/main`; tareas T267, T233 y T527.
- **Compuerta:** las decisiones artísticas siguen siendo de Lucas.
- **Alcance:** galería de revisión y capturas; no se integra ni modifica arte del juego.

## Objetivo

Mostrar el arte actual de campaña que Lucas necesita revisar y distinguirlo de propuestas no integradas. Excluir las muestras antiguas sin integrar del PR #132.

## Hecho cuando

- Capturas recientes del juego vigente muestran los niveles 1, 14 y 15.
- La página identifica qué está integrado, qué sigue pendiente y cuál concepto ya recibió conformidad de dirección.
- Las preguntas de decisión corresponden a T267, T434 y T233, sin declarar aprobaciones no recibidas.
- `godot --headless --import` y el generador de capturas finalizan correctamente; `git diff --check` pasa.

## Resultado (2026-10-27)

Galería en [`art/t537-arte-campana/revision.html`](../../art/t537-arte-campana/revision.html), con instrucciones en su README y capturas actuales de los niveles 1, 14 y 15 a 1280×720. Se incorporó el concepto corregido de T527 solo como referencia ya aceptada por Lucas, todavía no integrado, y la muestra provisional del epílogo T233, que sí espera aprobación. Se dejaron preguntas concretas para la validación de T267 y la selección de deudas T434. Las muestras antiguas sin integrar del PR #132 no aparecen.

Verificación: `godot --headless --import` terminó con código 0 y el generador de capturas terminó con código 0. `git diff --check` pasa. No se corrieron GUT, pruebas manuales, partidas ni dispositivo real; la creación de la galería no cierra las aprobaciones artísticas de T267/T233.
