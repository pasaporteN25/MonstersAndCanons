# T437 · Banderines y decoración del bosque

Los cuatro archivos de fuentes/ son las fuentes PNG RGBA generadas para esta propuesta. Se usaron como referencias visuales los recursos aprobados de T277: árbol del bosque, roca y escombro. Los PNG de runtime se preparan a 128×128 con prepare_assets.gd; no se convierten a SVG ni se les aplica espejo.

Para volver a preparar los recursos, desde la raíz del proyecto:

    godot --headless --path . --script res://art/t437-banderines/prepare_assets.gd

Para reconstruir el contacto a 220 y 34 px:

    godot --headless --path . --script res://art/t437-banderines/contact_sheet.gd

La vista web con nombres y tamaños está en muestras/index.html. La hoja PNG está en muestras/contacto_220_34.png.

capture.gd y capture.tscn reproducen dos capturas reales de 1280×720 del nivel 6: antes de ganar y después de registrar una victoria. La escena usa user://t437_banner_capture.json, lo elimina antes de empezar y lo borra al terminar. Ejecutala con ventana de Godot, no en modo headless:

    godot --path . res://art/t437-banderines/capture.tscn

Los emblemas enemigos y del jugador son propuestas visuales. El símbolo enemigo y el emblema de la colonia todavía no son canon aprobado.
