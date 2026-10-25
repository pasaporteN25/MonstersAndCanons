# T483 · Recorrido sobre el atlas original

Propuesta visual solicitada por Lucas tras rechazar T482/PR #78. Mantiene la identidad de T428, ubica el aterrizaje en tierra y traza un recorrido abierto de oeste a este. **Pendiente de aprobación; sin integración al juego.**

## Procedencia

Base del trabajo: `origin/main` `cb748459` (incluye #76). El SVG geográfico se copia de `assets/ui/campaign_map_background.svg`; sus siete bloques de contenido se conservan intactos. La captura original viene de `art/t428-mapa-propuesta/captura_producto_1280x720.png`. La referencia anterior es la captura A de T482, commit `2fd7a52`, rama `feature/t482-revision-mapa-propuestas` (PR #78). El fondo de interfaz se conserva de T428 para comparar con el mismo marco; la captura tiene textos históricos.

Ejecutor: GPT‑6.1‑sol con esfuerzo alto, Impeccable 4.5.2 para refinamiento/crítica y revisión independiente coordinada por el orquestador. No se usaron imágenes generativas ni se reemplazó el atlas aprobado.

## Archivos

- `route.svg`: copia editable del atlas con ruta, aterrizaje y círculos de muestra agregados. No es un recurso runtime.
- `route_points.json`: coordenadas de los quince puntos y aterrizaje, separadas del dibujo.
- `render_preview.py`: rasteriza el SVG con Godot en un directorio temporal y compone las capturas con Pillow. Los números y rótulos se componen con DejaVu Sans del sistema porque la rasterización SVG de Godot no representa texto.
- `index.html`: comparación en el mismo marco de la propuesta, el original y la anterior; utiliza las imágenes relativas de `../../Capturas/`.
- `Capturas/T483-propuesta-recorrido.png`: composición estática, 1280×720.
- `Capturas/T483-lectura-geografica.png`: lámina explicativa, 1280×760; las marcas no forman parte del mapa.
- `Capturas/T483-referencia-T428.png` y `T483-referencia-T482-A.png`: referencias de comparación, 1280×720.

## Reproducción

Desde la raíz del worktree, con Godot 4.7.2 y Pillow disponibles:

```bash
python3 art/t483-mapa-organico/render_preview.py
```

No requiere abrir el juego ni correr `--import`. Para ver el HTML, abrir `index.html` manteniendo la estructura del checkout; sus imágenes están en `Capturas/`.

## Qué se decide

Si la nueva ruta conserva el atractivo del original y comunica un avance continental verosímil; si no, señalar el tramo entre niveles que necesita corregirse. No se fijan biomas, canon, diseño final de insignias ni coordenadas runtime. Las distancias del dibujo no validan por sí solas los objetivos táctiles de 56 px ni la composición celular.

La [ficha T483](../../specs/tareas/T483-recorrido-organico.md) registra el análisis previo, las decisiones geométricas, la revisión, las verificaciones y sus límites. No se verificó el visor en navegador porque CUA no tiene navegadores disponibles en esta sesión; sí se inspeccionaron las imágenes renderizadas. No se corrieron pruebas de juego, GUT, bots, celular ni mediciones de rendimiento.

## Tamaños y huellas de las capturas

| Archivo | Peso | SHA-256 |
|---|---:|---|
| `T483-lectura-geografica.png` | 231,294 bytes | `27a3d6f079ef0d2fd5de2bc29b5d6f885412d48cdd04c9f408a6679aa95cdd20` |
| `T483-propuesta-recorrido.png` | 233,795 bytes | `2c19cf66f8e9e3034cacf27991ab429a03aae3ea067dca0b9ccc3a2800e6588b` |
| `T483-referencia-T428.png` | 219,283 bytes | `bb371607be1de426c33bc2fdb67c2fd64248d3ea2e1f916a1f0d8596fbb15a71` |
| `T483-referencia-T482-A.png` | 223,163 bytes | `ab9813fc5e864f0fe4111ac4a64535a18bbd1ce85ce544c501f2e5e57691fc89` |
