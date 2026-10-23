# T443 · Editor y variantes de banderines

La muestra T440 y `banner_post_player.png` de T437 son las referencias visuales. Lucas aprobó la muestra de T440 antes de integrar las variantes.

Se produjo una atlas PNG con fondo transparente y 16 combinaciones (4 paletas × 4 emblemas). El poste, el tamaño, la perspectiva, la luz y el banderín enemigo se mantienen iguales; solo cambia la bandera del jugador. El juego carga una sola atlas de runtime de 512×512 en `assets/sprites/map/rendered/banner_variants_atlas.png`; cada una de sus 16 regiones es de 128×128. Los PNG individuales quedan en `variantes/` como fuente editable, y la atlas 1254×1254 conserva la salida completa de ImageGen. El archivo `.gdignore` evita importar al proyecto las láminas, capturas y fuentes de revisión. Los contactos permiten revisar la lectura a 220 y 34 px.

La atlas se generó con la herramienta integrada ImageGen de Codex usando el arte T437 y la muestra T440 como referencias. Prompt utilizado:

> Generá una atlas de sprites 4×4 sobre fondo transparente con dieciséis postes de banderines completos. Conservá exactamente el poste, la perspectiva y el estilo pintado dimensional de la imagen de referencia 1. Usá la imagen 2 para las paletas y emblemas aprobados. Cambiá solo la bandera izquierda/del jugador por columna: verde azulado, rojo ladrillo, verde musgo y azul océano. Cambiá solo el emblema dorado por fila: chevron, rombo, estrella de cinco puntas y franja horizontal. La bandera derecha/enemiga debe ser idéntica en las dieciséis celdas: tela crema con el mismo chevron dorado. Sin texto, líneas de grilla, fondo, objetos ni marca de agua.

## Capturas

Las imágenes se capturaron con Godot 4.7.2 en Linux desktop. El poste del nivel está compuesto con el contexto explícito de campaña completada y mide 34×34 px en el mapa.

- Hub: [1280×720](capturas/1280_hub.png), [1920×1080](capturas/1920_hub.png)
- Editor: [1280×720](capturas/1280_editor.png), [1920×1080](capturas/1920_editor.png)
- Poste en nivel 6: [mapa y poste a 34 px](capturas/1280_level06.png)
- Muestras de arte: [220 px](contacto_220.png), [34 px](contacto_34px.png)
