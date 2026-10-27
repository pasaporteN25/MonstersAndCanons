# T525 · Revisar muestras de cactus y campamento vacío de M79

- **Estado:** completada como revisión de muestras; aprobación de las cuatro variantes nuevas pendiente de Lucas.
- **Ejecutor:** Codex `gpt-6.1-sol`, esfuerzo medio; raster generado con herramienta nativa `image_gen.imagegen` (modelo interno no expuesto), revisión y registro de procedencia por Codex.
- **Depende de:** T523; comentarios de Lucas del 2026-10-26 sobre cactus y campamento.
- **Refs:** RF-712 a RF-714, D-210. **Rama/PR:** `feature/t523-muestras-adornos-m79`, PR #124, contra `main`; un commit `T525: revisar muestras de cactus y campamento M79`.

## Objetivo

Mejorar las dos variantes de cactus y las dos de campamento vacío objetadas por Lucas, manteniendo el resto de las muestras sin cambios. Registrar también que Lucas dio su visto bueno al motivo de roca roja, columna, bloque y estatua, sin elegir variante entre las presentadas.

## Alcance

- Sustituir las cuatro variantes activas de cactus y campamento por propuestas dimensionales más orgánicas y legibles a 34 px.
- Preservar en `sources/iterations/initial/` las cuatro variantes anteriores y sus fuentes; dejar byte a byte las otras ocho variantes.
- Actualizar hojas, composiciones externas, fuentes, prompts, manifiestos e informe.
- No integrar assets ni tocar escenas, código, temas, leyendas, mapas, datos o CHANGELOG. Las nuevas variantes requieren aprobación visual de Lucas antes de T524.

## Hecho cuando

Las nuevas variantes mantienen la huella de 128×128 RGBA para una casilla, se pueden revisar a 220/64/34 px y en sus composiciones pertinentes, las versiones anteriores están conservadas y los cuatro motivos con visto bueno mantienen sus hashes.

## Verificación

`git diff --check`; verificador de adornos y regeneración exacta desde `/tmp`; hashes protegidos; verificadores existentes de nieve M79 y marcas M80 en copias temporales. No ejecutar Godot/GUT, importación ni medir celular o rendimiento para una tarea de muestras.

## Resultado (2026-10-26)

Se rehacen las dos opciones de cactus y las dos de campamento; se archivan las cuatro versiones objetadas y se preservan los PNG de roca roja, columna, bloque y estatua. El informe documenta que las espinas y varios detalles se pierden a 34 px, la variante 02 del campamento pierde contraste sobre ruinas y la sombra del cactus 01 es tenue. Se registran las cuatro piezas sin cambios con el visto bueno de Lucas; no se inventa aprobación para las nuevas.

El verificador informó PASS para 12 variantes RGBA 128×128, 51 hashes PNG y 19 insumos, los ocho PNG protegidos, cuatro originales archivados, seis composiciones sin cambios fuera de las casillas, y reproducción byte a byte desde `/tmp`. Pasaron también los verificadores de nieve M79 y marcas M80 en copias temporales y `git diff --check`. No se ejecutó Godot/GUT ni se probó en teléfono real o rendimiento. Las propuestas siguen sin integrar y pendientes de aprobación de Lucas.
