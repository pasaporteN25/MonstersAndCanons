# Revisión visual actualizada de T267

La galería compara el estado integrado en `main` (`b775feb`, con M79 y M80) con cuatro pruebas aisladas de T267: mina, bosque explotable, Central y estatua.

- `revision.html`: selector interactivo de capturas completas; abrirlo desde una copia local del repositorio.
- `review/comparaciones-por-pieza.png`: comparación rápida para ver directamente en GitHub.
- `captures/`: PNG originales de Godot a 1280×720, antes y con las pruebas T267.
- `capture.gd` y `sample_decor_current_canon.gd`: reproducción de las imágenes sobre la escena real; el glifo actual H G2 se conserva.
- `build_review.py`: arma las imágenes comparativas desde las capturas y metadatos.

**Escombro queda fuera de la elección:** la prueba de T267a usa la A anterior a M80. La actualizaremos a H G2 antes de solicitar aprobación. Ninguna muestra de esta carpeta es final ni está integrada en el juego.

Para repetir las capturas, importar primero (`godot --headless --import`) y luego ejecutar `art/t529-review-t267/capture.tscn` con la ventana a 1280×720. Para regenerar las hojas, correr `python3 art/t529-review-t267/build_review.py`.
