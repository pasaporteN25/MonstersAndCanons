# T482 · Revisar la geografía del mapa con dos propuestas
- Ejecutor · Codex, GPT‑6.1‑sol medio; revisión visual independiente GPT‑6.1‑sol medio
- Depende de · T469; captura original y estilo de T428 · Compuerta: Lucas elige o pide ajustes antes de integrar geografía · Tamaño: chico

## Leer
- `specs/01-spec.md` RF-691, RF-695 y RF-698.
- `specs/04-decisiones.md` D-198–203.
- `specs/05-guia-de-arte.md` y `.claude/rules/arte.md`.
- `art/t428-mapa-propuesta/captura_producto_1280x720.png` y `assets/ui/campaign_map_background.svg`.
- `art/t469-mapa-propuesta/` cuando esté disponible en la revisión de T469.

## Objetivo
Presentar a Lucas dos costas de aspecto más natural, derivadas del lenguaje gráfico original de T428, para que elija una o pida cambios en la muestra T469.

## Alcance
- Sí: dos fuentes SVG editables; comparación con la captura original en idéntica escala; relieves y ríos finos; ruta y aterrizaje sobre tierra; fuente y receta de reproducción.
- No: integrar assets, asignar biomas o mapas, fijar coordenadas jugables, cambiar reglas, arte aprobado, canon, escenas o interacción; simular una prueba de teléfono.

## Pasos
1. Revisar el original de T428 y la crítica de Lucas a las muestras anteriores.
2. Dibujar A como masa continental asimétrica basada en el perfil original, con plataforma occidental más ancha; dibujar B con una ensenada meridional amplia.
3. Mantener idénticos encuadre, paleta, relieve, símbolos, ruta y escala de marcadores para aislar la comparación de costas.
4. Renderizar las dos opciones y el original en capturas a 1280 × 720 y armar la página de revisión.
5. Dejar explícito que la muestra no fija biomas ni posiciones y que integrar requiere aprobación.

## Hecho cuando
- Hay dos SVG editables con capturas visibles junto al original a la misma escala.
- Los quince marcadores, la ruta y el aterrizaje quedan sobre tierra con margen legible.
- Los números coinciden con el centro de los marcadores y no se agregan manchas o símbolos que parezcan asignaciones de bioma.
- La fuente puede regenerar las capturas y el PR pide una decisión concreta a Lucas.

## Verificación
- `python3 art/t482-mapa-propuestas/render_captures.py`; rasterización SVG en Godot 4.7.2 aislado y capturas con Pillow.
- Inspección visual del original y las dos capturas a 1280 × 720. Sin GUT ni `--import`, porque no se modifica el juego ni se incorporan recursos runtime.

## Frenar si
- La muestra requiere cambiar una decisión de T459, la guía visual, el terreno canónico o la distribución de niveles.
- Aterrizaje o cualquier marcador queda fuera del territorio o los números no coinciden con los centros.
