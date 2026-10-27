# T529 · Actualizar la galería de revisión visual de T267

- Ejecutor · Codex, esfuerzo medio
- Depende de · T267a existente y `origin/main` actualizado
- Compuerta · decisiones visuales de Lucas quedan en T267
- Tamaño · Chico

## Leer

- `specs/tareas/informes/T267a-propuesta-assets.md`
- `art/t267a/README.md`
- `specs/05-guia-de-arte.md`

## Objetivo

Que Lucas pueda comparar las propuestas principales de T267 con la campaña integrada actual, después de M79 y M80, y elegir cada pieza por separado.

## Alcance

- Capturar niveles 1, 3, 5, 11, 13 y 15 en Godot 4.7.2 a 1280×720 sobre `main` actualizado.
- Preparar comparación de mina, bosque explotable, Central y estatua, sin conectar muestras al juego.
- Mantener H G2 en las muestras; excluir escombro de la elección porque la prueba T267a disponible conserva la A anterior a M80.
- Mostrar los mapas completos y los detalles comparativos en una guía y en imágenes visibles desde GitHub.

## No incluye

- Aprobar o producir arte final, integrar assets, cambiar niveles o modificar reglas.
- Cerrar T267 ni decidir qué deudas visuales son requisito para V1.

## Hecho cuando

- Las capturas actuales corresponden al `main` posterior a T508/T524 y se comparan con pruebas aisladas sin cambiar las demás decoraciones.
- La galería indica con claridad qué está integrado, qué es una muestra y qué quedó obsoleto.
- Las imágenes se abren desde GitHub sin depender de que el navegador renderice el HTML local.
- `git diff --check` pasa.

## Resultado (2026-10-27)

Galería en `art/t529-review-t267/`: pares de capturas actuales/prueba para los niveles 1, 3, 5, 11, 13 y 15, detalles de cuatro piezas, selector HTML local y hoja comparativa que se ve directamente en GitHub. Capturas tomadas sobre `main` `b775feb`, después de T508/T524, con Godot 4.7.2 a 1280×720. Escombro no se ofrece para decidir hasta rehacer su muestra con H G2; la prueba anterior conservaba la A. **No se aprobaron ni integraron assets.** `godot --headless --import` terminó con salida 0; la primera captura antes del import produjo errores por el caché vacío y se repitió después, con salida 0 y sin `SCRIPT ERROR`. Se quitaron únicamente los `.import` sueltos que Godot generó en `Capturas/`. `git diff --check` limpio. No se corrió GUT porque no se modificó el juego.
