# T426 · Selector actual: 15 niveles visibles en desktop
- Ejecutor · Gemini, esfuerzo medio
- Depende de · T425 · Compuerta · aprobación visual de Lucas si la ficha de T425 la define
- Tamaño · Mediano

## Objetivo
Rediseñar el selector de tarjetas para mostrar la campaña completa de un vistazo en desktop.

## Alcance
Quitar la cantidad de oleadas; integrar torres disponibles de forma orgánica dentro del marco de nivel; probar fondos relacionados con cada nivel. Mantener nombre, estrellas, récord, estado, desbloqueos e interacción existentes.

## Hecho cuando
Los 15 niveles se ven y se pueden seleccionar a 1280×720 sin scroll y se leen a 1920×1080; se verifican foco/teclado, estados bloqueados y completados, resoluciones y rendimiento; pruebas de integración y GUT completo pasan. Si no se puede cumplir sin sacrificar legibilidad, entregar comparación y evidencia sin inventar una solución.

## No incluye
El estilo de mapa planetario, cambios mobile o nuevos datos de nivel.

## Resultado (2026-10-21)
En desktop, las 15 tarjetas entran en tres filas sin scroll a 1280×720; a 1920×1080 mantienen el mismo layout escalado, sin estirar el contenido lógico. Se quitaron las oleadas y los marcos individuales de las torres; se conservaron estados, estrellas, récord, desbloqueos y acciones. Mobile conserva las tarjetas anteriores.

Capturas y muestra editable: [`art/t426-selector-propuesta/`](../../art/t426-selector-propuesta/). La propuesta vectorial de pradera, bosque, ruinas, desierto y nieve se inspira en los temas actuales; no se integraron fondos en el juego porque falta aprobación de Lucas.

GUT: 154 scripts, 2156 pruebas y 23386 aserciones, todo pasó. `git diff --check` pasó. Gemini CLI devolvió 503 y luego cuota cero en Pro; realizó la implementación Codex.
