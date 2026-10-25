# T469 · Muestra de insignias de conquista y zona oculta del atlas

**Propuesta de arte, no integrada y no aprobada.** No toca `scenes/`, `scripts/`, `data/` ni `assets/`. Lucas aprueba cada pieza antes de que T474 (insignias) y T488 (máscara gris) integren nada. Estética: el atlas vigente (M76/T471, `assets/ui/campaign_map_background.svg`), los postes de T475 (carmesí y negro = rebelde; turquesa y crema = jugador) y la UI actual de `main`; no se reutiliza arte del mapa viejo T427/T428.

Maqueta: `index.html` (autocontenida con rutas relativas; las capturas se cargan desde `../../Capturas/T469-*.png`). Hojas sueltas: `hoja_*.html`; marcos de captura: `frames/`.

## Procedencia (cómo se generó cada pieza)

Todo sale de `build.py` (Python 3 estándar; `python3 -I art/t469-mapa-propuesta/build.py`), que **lee** `assets/ui/campaign_map_background.svg` y `scripts/logic/campaign_map.gd` (puntos y curvas de la ruta) y escribe solo en esta carpeta. Las capturas las saca `capturar_todo.sh` con Firefox headless (snap; el perfil tiene que estar bajo `~/snap/firefox/common`).

| Pieza | Archivos | Cómo |
|---|---|---|
| Insignias rebelde / partido / jugador, 3 variantes (V1 aro liso, V2 aro dentado y tachas, V3 relieve con costura diagonal) | `insignias/{rebelde,partido,jugador}_v{1,2,3}.svg` (64×64, sin número ni texto) | SVG dibujado por código. Contorno `#2b2233`, degradé de 3 paradas, un brillo por pieza (guía de arte §2). Carmesí `#d9604a/#a6302f/#5b2231` con aro `#231c28`; turquesa `#4fb3aa/#1f7f7c/#124a54` con aro crema `#ecd9ae`: colores tomados de `banner_post_enemy.png` y `banner_post_player.png` (muestreo de los PNG). Sin emblema: no se inventa ninguno canónico (D-203). El candado es el actual (`candado_actual.svg`, copiado de `CampaignRegion.draw_mark`). |
| Números 1–15 | dentro de las escenas y hojas, no en los SVG de insignia | Texto SVG DejaVu Sans Bold 15 px (14 px de dos cifras), crema con contorno oscuro. **El juego usa la fuente por defecto de Godot**: el alto real puede variar un poco. |
| Escenas del lienzo con insignias | `escenas/atlas_v{1,2,3}_completo.svg` | Lienzo real del selector (1413,6×380 px lógicos, atlas ×1,14 desde y=160), con el atlas actual incrustado, ruta, aterrizaje, estrellas, selección (aro dorado r+6) y foco (aro blanco r+11) como en `campaign_region.gd`. Se quitan la leyenda y los rótulos «tomada/rebeldes/bloqueada» (RF-695). Los estados son ejemplos, no guardados. |
| Zona oculta G1 / G2 | `escenas/zonas_{G1,G2}_{A,AB,ABC}.svg`, `fuentes/gris_G2_atlas.svg` | Máscara SVG con los contornos de zona de `art/t485-atlas-biomas/render_preview.py` (A 1–5, B 6–10) recortada a la costa del atlas. G1: relleno liso `#848b8c→#636a6c` con borde difuso (trazos de máscara con alfa decreciente, sin filtros). G2: copia del atlas con todos los colores pasados a gris (Y' = 78 + 0,38·Y) y borde nítido. Sin nodos, números, candados, estrellas, ruta ni rótulo en lo oculto. |
| Fuente del atlas | `fuentes/atlas_actual.svg` | Copia literal del fondo integrado. |
| Capturas | `Capturas/T469-*.png` | Firefox headless sobre `frames/` y `hoja_*.html`. |

## Tamaños y peso

- Insignias: 64×64, entre 475 B (candado) y 3,2 KB; la insignia se dibuja a radio 19,5 px (el juego usa 19) dentro del área táctil de 56 px.
- Escenas SVG: 41–72 KB cada una (el atlas incrustado pesa ~30 KB; G2 duplica el atlas). La carpeta entera pesa ~1,4 MB.
- Capturas PNG (peso): pc-1280×720 ~325 KB (×2), pc-1920×1080 592 KB, 2560×1080 simulado (1706×720 lógicos) 350 KB, celular simulado 1688×780 ~372 KB (×2), catálogo 215 KB, números 194 KB, variantes 966 KB, zonas grises 1,26 MB, gris vs. candado 597 KB.
- No se afirma rendimiento: son SVG estáticos de maqueta, sin medición en el motor.

## Lo que se midió

- **Áreas táctiles (RF-690):** en `T469-numeros-1-15.png` las 135 insignias quedan dentro del cuadro punteado de 56×56 px lógicos y no se pisan (la separación de nodos la fija T471 con ×1,14).
- **Contraste del número:** crema `#fff7e6` contra el contorno oscuro `#1c1620` = 16,6:1. Contra el relleno medio: rebelde 6,4:1, jugador 4,5:1; contra la luz del degradé: 3,4:1 y 2,4:1 (por eso lleva contorno de 3 px).
- **Gris vs. candado (CIE76 sobre las capturas; `T469-gris-vs-candado.png`):** relleno del candado `#414b4b` frente a G1 ΔE 16–18, contraste 1,8–1,9:1; frente a G2 ΔE 21–26, contraste 2,1–2,6:1. Son pares cercanos en luminosidad (el candado es el más oscuro), así que **el color por sí solo no basta**: los separan el tamaño (disco de ~36 px frente a un terreno de cientos), el aro oscuro y el candadito claro, y que nunca hay un candado sobre el gris. G2 se distingue más por color; G1 menos.
- **Desborde:** a 1,14 el lienzo mide 1413,6 px y la vista 1240: desborda 173,6 px en PC (1280 y 1920 comparten diseño lógico) y en el celular simulado. Sin desborde solo en pantallas más anchas que ~1414+40 px lógicos (ejemplo: 2560×1080 → 1706×720 lógicos).

## Qué no se pudo comprobar

- Ningún teléfono real: el celular es **simulado** (844×390 pt a 2×, 1280×720 lógicos escalados a 0,5417 con barras, como haría `canvas_items` con aspect keep; el proyecto no fija el aspect, supuesto no verificado). A esa escala el número de 15 px queda en ~8 pt: está al límite en un celular real y habría que verlo en uno.
- No se corrió Godot: la maqueta es HTML/SVG renderizado por Firefox, no el motor; la fuente, el antialiasing y el alto del número cambiarán. No se probó input, arrastre ni foco real.
- Daltonismo: no se simuló. La forma (partido, aro dentado en V2) agrega señal, pero no se midió.
- El halo dorado punteado de «disponible» es una propuesta mía; RF-695 solo dice «fondo rebelde sin victoria».
- El borde difuso de G1 muestra una franja cálida (terreno descubierto semitransparente) que a algunos les puede parecer un resplandor; no hay animación (RF-710).
- Receta del editor (RF-697): no se pintó; la parte «jugador» tendría que aceptarla.

## Pieza → variante recomendada y por qué

| Pieza | Recomendada | Por qué |
|---|---|---|
| Rebelde | **V1** (aro liso) | La más limpia a 1×; el aro negro-carmesí conversa con el pendón negro y rojo del poste. V2 es la alternativa si se quiere una señal de forma además del color. |
| Partido (1–2★) | **V1** | Mitades verticales: el número cruza la costura sin perder lectura; mantiene la familia con las otras dos. V3 (costura diagonal) es la más expresiva pero más fina a 34–40 px. |
| Jugador (3★) | **V1** | Turquesa y aro crema, igual que el pendón del jugador; ya se distingue del dorado de las estrellas. V2 (tachas) recarga el aro a 1×. |
| Números sin cero | crema con contorno oscuro, 15/14 px | Se lee sobre las dos mitades; 1–15 caben en el círculo. A confirmar en celular real. |
| Estrellas, candado, selección y foco | sin cambios (los actuales) | Solo se muestran sobre la insignia; el halo de «disponible» queda a decisión de Lucas. |
| Zona oculta (máscara gris) | **G1 niebla pizarra** | No adelanta contenido (no se ven biomas, ruinas ni relieve), que es el espíritu de RF-710. Contra: es la más parecida al relleno del candado (ΔE ~16); si preocupa, aclararla un poco (G2 llega a ΔE 26 pero deja ver ruinas y nieve). |
