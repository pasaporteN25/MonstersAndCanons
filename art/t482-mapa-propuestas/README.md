# T482 · Revisión de las propuestas de costa

Iteración visual solicitada por Lucas después de revisar las opciones del PR #74. Parte de la captura y el perfil geográfico de T428; corrige el aspecto de ondas repetidas y manchas de bioma con dos propuestas de costa para revisar. No integra arte ni cambia lógica.

## Archivos

- `mapa-a.svg`: perfil continental asimétrico basado en la silueta de T428, con plataforma occidental más amplia.
- `mapa-b.svg`: mismo lenguaje gráfico, con una ensenada amplia en el sur.
- `index.html`: comparación de A y B con la captura original, todas a 1280 × 720.
- `render_captures.py`: renderiza los SVG con Godot 4.7.2 en un directorio temporal y compone la captura de revisión con Pillow.
- `Capturas/T482-mapa-original-T428.png`, `Capturas/T482-mapa-propuesta-A.png`, `Capturas/T482-mapa-propuesta-B.png`: capturas comparables que se muestran en el PR.

## Alcance de esta revisión

Se conserva la paleta del mar azul petróleo y la tierra oliva, el contorno oscuro, el relieve fino, los ríos, los símbolos, la presentación de T428 y el tamaño de los círculos. Los marcadores avanzan de oeste a este y el aterrizaje y la ruta se ubican sobre la tierra. No se dibujan las manchas de bioma de la versión anterior; esta revisión se concentra en la silueta. No se asignan biomas, no se fijan coordenadas finales y no se interpreta canon.

La captura de referencia conserva textos antiguos del selector porque es el original de T428; esos rótulos no se proponen para la versión nueva. La muestra es desktop estática: no valida interacción ni composición celular.

## Verificación

`python3 art/t482-mapa-propuestas/render_captures.py` completó la rasterización de las dos fuentes en Godot 4.7.2 y generó capturas 1280 × 720 con Pillow. No se ejecutaron GUT ni `--import`: no se modificó el proyecto jugable ni se integraron assets.

T482 queda listo para revisión visual. T469 y la integración T471 siguen pendientes de la elección y aprobación de Lucas.
