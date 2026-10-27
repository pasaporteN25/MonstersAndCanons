# T539 · Muestras de vegetación alienígena

- **Ejecutor:** Codex `gpt-6.1-sol`, esfuerzo medio.
- **Depende de:** pedido de Lucas del 2026-10-27; niveles 1, 3, 4 y 5.
- **Compuerta:** aprobación visual de Lucas antes de producir o integrar el reemplazo.
- **Alcance:** conceptos y galería comparativa; no editar assets activos ni datos de niveles.

## Objetivo

Preparar direcciones visuales para reemplazar en el futuro la decoración histórica `flores.svg` por una familia de vegetación de otro mundo propia de Cántaro, sin alterar la distribución actual.

## Hecho cuando

- Tres siluetas diferenciadas se comparan en una galería, a 220 px, 34 px y sobre pradera aproximada.
- La página explica que son propuestas, no capturas reales ni arte aprobado.
- Se identifica que `dibujo:flores` aparece en los niveles 1, 3, 4 y 5.
- Ningún asset activo, nivel, escena o lógica de juego cambia.

## Resultado (2026-10-27)

Galería en [`art/t539-flora-alien-review/preview.html`](../../art/t539-flora-alien-review/preview.html) y hoja estática `contact_sheet.png`. A: flor de láminas espiraladas; B: hongo-flor bajo de cápsulas asimétricas; C: roseta estrellada con flor plegada. Las tres comparten paleta provisoria de salvia, malva y arcilla. El SVG histórico queda copiado intacto para comparar. Se verificaron los SVG, el JSON del manifiesto, los SHA-256 y 55 referencias locales del HTML; `git diff --check` pasa. No se corrió Godot/GUT, no hay capturas reales ni aprobación de Lucas, y no se integró arte.
