# T546 · Imagen del final con dos variantes según estrellas

- **Ejecutor:** Sonnet 5.5 · GDScript; arte con Codex o quien Lucas indique; revisión Codex.
- **Depende de:** T545 mergeada (frase del epílogo aprobada); respuestas de Lucas a Q1 a Q5 de RF-729; **OK escrito de Lucas** sobre las muestras de las dos imágenes. Coordinar con T547 (retira el arte viejo de T233). PR propio a `main`; el cuerpo debe indicar las dependencias.
- **Refs:** RF-729, D-219 (enmienda RF-471); RF-93; T233, T544, T545, T547.
- **Compuerta de arte:** 🎨 sin aprobación escrita de Lucas no se integra nada en `assets/`. Aplicar la «Compuerta de estilo antes de producir muestras» de `specs/05-guia-de-arte.md`.

## Leer

Constitución, `.claude/rules/gdscript.md`, `.claude/rules/tests.md`, `.claude/rules/arte.md`, RF-471/RF-472/RF-729, D-219, `specs/05-guia-de-arte.md` (compuerta de estilo), `specs/11-textos-lore.md` §2, `GameFlow` (`is_campaign_complete`, `level_stars`, `total_stars`, `max_stars`), `EpilogueScreen`, `Game.open_epilogue`, `tests/test_epilogue.gd`.

## Objetivo

Que el epílogo muestre la imagen **luminosa** solo si los 15 niveles tienen 3 estrellas, y la variante con **referencia oscura** en cualquier otro caso, sin tocar el guardado.

## Alcance (sí / no)

- **Sí:** `GameFlow.is_campaign_perfect()`; elegir la textura en `EpilogueScreen` (o quien la abre) con respaldo si falta un archivo; dos imágenes 16:9 nuevas en la familia visual vigente; tests; captura del motor de ambas; documentación (`CHANGELOG.md`, `CONTENIDO.md`/`README.md` si nombran el epílogo).
- **No:** campos nuevos en el guardado ni `SAVE_VERSION`; cambiar el texto del epílogo, los créditos, los récords o los desbloqueos; un acceso nuevo al epílogo; una variante intermedia (sin respuesta de Lucas a Q2); reutilizar la imagen de T233 como estilo; borrar el arte viejo (eso es T547).

## Pasos

1. Confirmar T545 y las respuestas de Lucas a Q1 a Q5. Si faltan, frenar.
2. **Muestras fuera de `assets/`** (en `art/t546-final/`): aplicar la compuerta de estilo (≥ 3 recursos activos de la familia y una captura reciente; registrar técnica, perspectiva, iluminación, paleta, alfa y escala), producir las dos imágenes con la franja de texto simulada encima y presentarlas a Lucas. Esperar su OK escrito.
3. Con el OK: copiar byte a byte a `assets/sprites/story/` con nombres descriptivos (por ejemplo `epilogue_bright.png` y `epilogue_dark.png`).
4. Agregar `GameFlow.is_campaign_perfect()` junto a `is_campaign_complete()`, derivada de `level_stars` (campaña vacía = `false`).
5. Hacer que `EpilogueScreen.open` reciba la variante y elija la textura; si el archivo falta, usar el fondo provisional de código y avisar por consola.
6. Tests y capturas (ver abajo). Actualizar documentos donde aparezca la imagen del final.

## Hecho cuando

- El epílogo muestra la luminosa solo con los 15 niveles en 3 estrellas y la oscura en cualquier otro caso.
- No hay claves nuevas en el guardado, `SAVE_VERSION` no cambió y ver el epílogo no escribe nada.
- Las dos imágenes tienen OK escrito de Lucas, salieron primero fuera de `assets/` y respetan la familia visual vigente.
- Los tests cubren los casos de abajo; GUT completo sin `SCRIPT ERROR`.

## Pruebas esperadas

- **Ambas variantes:** guardado nuevo con el 15 recién ganado, oscura; los 15 con 3 estrellas, luminosa.
- **Borde de 14/15:** 14 niveles con 3 estrellas y el 15 ganado ahora con 3, luminosa; con 2 estrellas, oscura; 14 con 3 estrellas y el 15 sin ganar, no hay epílogo (RF-471).
- **2 estrellas en uno:** los 15 completados pero un nivel intermedio con 2 estrellas, oscura.
- **Mejor marca:** con todo en 3 estrellas, volver a ganar el 15 con menos vidas sigue dando la luminosa.
- **Campaña vacía** (`level_count() == 0`): `false`, sin error.
- **Modo de pruebas y comunidad:** sin botón «Epílogo»; el guardado de pruebas es independiente. Lo mismo en modos y editor.
- **Guardado:** idéntico antes y después de ver cualquiera de las dos; `SAVE_VERSION` sin cambios.
- **Respaldo:** archivo faltante, fondo provisional sin `SCRIPT ERROR`.
- **Captura del motor** de ambas con la franja de texto, en 16:9 y recortada (por ejemplo 21:9).

## Verificación

`godot --headless --import` (después devolver con `git checkout -- assets` lo que no se tocó a propósito); GUT completo (`godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`) sin `SCRIPT ERROR`; `git diff --check`. No afirmar prueba en celular real ni rendimiento.

## Frenar si

Falta T545, alguna respuesta de Lucas o el OK escrito de las muestras; la imagen no se lee con la franja de texto; hay que agregar un campo al guardado; o aparece la necesidad de una variante intermedia (consultar a Lucas, no agregarla).
