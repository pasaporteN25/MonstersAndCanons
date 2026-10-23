# T440 · Muestra de catálogo de banderines

**Estado:** concepto visual para revisión de Lucas; no es arte final ni se integra al juego.

## Archivos

- `contacto_concepto.png` — lámina 4×4 a 1254×1254. Cada poste ocupa cerca de 220 px para comparar material, silueta y emblema.
- `contacto_34px.png` — la misma matriz reducida a casillas de 34×34 px para revisar lectura en el mapa.
- `index.html` — página de revisión editable con la lámina, la lectura real a 34 px y las etiquetas de paletas/emblemas.

## Matriz propuesta

Columnas: `meridiana` (verde azulado y crema), `brasa` (rojo ladrillo y crema), `musgo` (verde musgo y crema), `marea` (azul océano y crema).

Filas: `chevron`, `rombo`, `estrella`, `franja`; emblemas geométricos dorados, sin letras ni símbolos de facción.

Los ids coinciden con el borrador de lógica T442. La selección, el nombre y el emblema predeterminados todavía esperan revisión; cambiar estos ids antes de integrar es viable mientras ningún progreso de usuario dependa de ellos.

## Procedencia

- Referencia de forma y estilo: `assets/sprites/map/rendered/banner_post_player.png` (arte T437).
- Concepto generado con ImageGen el 2026-10-22 a partir de esa referencia. Se conserva la imagen de contacto completa y la miniatura a tamaño de casilla; no se alteró el asset aprobado ni se creó un recurso consumido por el runtime.
- Prompt editable: se reproduce en `index.html` y en el registro de este PR.

## Prompt

Use case: stylized-concept. Asset type: cosmetic game-art review sheet, not production-ready assets. Use the approved player banner post as the shape, material and rendering-style reference. Create one square 4-by-4 contact sheet with exactly sixteen instances of the same short carved wooden post carrying the same pair of small cloth pennants. Keep post, pennant silhouettes, angle, folds, stitching, scale and lighting consistent in every cell. Change only pennant palette by column and a simple embroidered abstract emblem by row. Columns: deep teal with warm cream; muted brick red with warm cream; forest moss green with warm cream; dark ocean blue with warm cream. Rows: gold chevron, gold diamond, gold five-point star, gold horizontal stripe. Emblems are simple decorative geometry, not faction marks; no letters or numbers. Warm handmade fantasy game prop, dimensional painted game art with restrained texture, soft highlights and shadows, and outlines matching the reference; readable at 34-pixel in-game scale. Even margins and gutters; each complete post centered in an equal cell, three-quarter front view, no overlaps, plain charcoal background. No captions, labels, UI, scenery, additional props, text or watermark. Preserve the recognizable silhouette of the reference; exploratory sample for approval, not final canon.
