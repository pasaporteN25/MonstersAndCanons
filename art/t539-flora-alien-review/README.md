# T539 · Flora alienígena para revisión

Abrí **[preview.html](preview.html)** en un navegador local o mirá **[contact_sheet.png](contact_sheet.png)**. Son composiciones de revisión, **no capturas del juego**. Ninguna variante está aprobada ni integrada.

## Qué se muestra

- **A:** flor de láminas anulares espiraladas, tallo corto.
- **B:** hongo-flor bajo con cápsulas asimétricas y hojas.
- **C:** roseta estrellada con flor central pequeña.

Las tres fuentes son SVG nativos originales de 64 × 64, contorno de mapa, degradés de tres paradas y un reflejo principal. El apoyo se representa con elipses de baja opacidad, sin filtros. No se midieron valores de alfa ni cobertura de píxeles; la transparencia está definida en el SVG. No se decidió un tamaño final de integración.

La comparación presenta cada dirección a 220 y 34 px y repeticiones a 34 px sobre pradera aproximada para **nivel 1 Pradera, 3 Encrucijada, 4 Espiral y 5 Fortaleza**. Los cuatro usan el mismo tema: se mantiene una paleta compartida y no se inventa una especie por nivel. Los fondos y posiciones son ilustrativos. El HTML usa px CSS; verlo al 100 % facilita la comparación, sin garantizar tamaño físico en toda pantalla.

La copia histórica en `sources/historical_flowers.svg` conserva exactamente la fuente actual para comparar. No es una cuarta propuesta ni fue modificada.

## Qué falta aprobar

Lucas debe elegir dirección y revisar color, material, silueta a escala pequeña, presencia/densidad y convivencia con el atlas de Cántaro y decoración dimensional. Las propuestas SVG simplifican el volumen pintado; no reemplazan por aprobación implícita la familia renderizada. Quedan pendientes una futura integración autorizada, importación en Godot 4.7.2, capturas reales y aprobación artística en contexto. No se corrieron Godot ni GUT.

## Archivos

- `sources/a_annular.svg`, `sources/b_capsules.svg`, `sources/c_rosette.svg`: fuentes originales.
- `sources/historical_flowers.svg`: copia histórica intacta.
- `preview.html`: comparador local en español, sin dependencias remotas.
- `contact_sheet.png`: hoja estática de 1120 × 1110 px.
- `prompts.md`: encargo normalizado, paleta, decisiones, referencias y preguntas.
- `manifest.json`: rutas relativas a esta carpeta, variantes, dimensiones y SHA-256 de los demás archivos; excluye su propio hash para evitar autorreferencia.

## Verificaciones y alcance

Fuentes nuevas comprobadas con parser XML y rasterizadas mediante librsvg/cairo para inspección visual de la hoja a 220/34 px. JSON analizado; enlaces HTML y referencias locales comprobados. Copia histórica cotejada byte a byte. `git diff --check` y revisión de estado ejecutados al cierre, sin cambios fuera de esta carpeta. El HTML no se verificó dentro del motor ni mediante una captura del navegador; la inspección visual se hizo sobre la composición PNG.

Trabajo limitado a `art/t539-flora-alien-review/`. Sin integración, borrado, cambios de datos/código/specs/tareas/configuración/changelog, commit ni push.
