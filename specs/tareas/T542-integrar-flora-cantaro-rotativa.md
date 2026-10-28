# T542 · Integrar y rotar la flora alienígena aprobada

- **Ejecutor:** Sonnet 5.5 · GDScript; revisión Codex.
- **Depende de:** T541 mergeada y T540 (#139) mergeada, para usar sus fuentes aprobadas y guía de estilo. PR propio a `main`; el cuerpo debe indicar ambas dependencias.
- **Refs:** RF-263/RF-728, D-218; niveles 1, 3, 4 y 5.
- **Compuerta de arte:** satisfecha por la aprobación explícita de Lucas del 2026-10-27 para A/B/C; no se requiere rediseño.

## Leer

Constitución, GDScript, RF-263/RF-728, D-218, T541, `MapDrawings`, `LevelDecor`, tests de dibujos/mapas y guía de arte §4.

## Objetivo

Reemplazar el único sprite activo del dibujo de leyenda `flores` por las tres PNG de 128×128 aprobadas en T540, con una variante elegida de forma determinista por casilla.

## Alcance (sí / no)

- **Sí:** copiar A/B/C a `assets/sprites/map/rendered/cantaro/` con nombres de código descriptivos; resolver la textura de `flores` por coordenada con `preload`; asegurar que las seis ubicaciones oficiales cubren las tres variantes; actualizar pruebas, `CHANGELOG.md`, tabla y documentación de assets si corresponde; importar y capturar niveles 1, 3, 4 y 5.
- **No:** cambiar `data/levels/`, la clave `flores`, ubicaciones/densidad/huella, biomas, construcción, camino, mecánicas, guardado, paleta de tierra, canon/lore, redibujar/recolorear las variantes, borrar el SVG histórico ni integrar ninguna pieza ajena a T540.

## Pasos

1. Usar byte a byte los PNG aprobados de `art/t540-flora-current-style/variants/` y verificar RGBA 128×128.
2. Añadir selección por coordenada estable; nunca usar RNG por partida.
3. Confirmar que el recorrido de las flores oficiales de niveles 1, 3, 4 y 5 muestra A, B y C, y que las mismas coordenadas repiten textura. Los mapas de comunidad con `flores` usan la misma selección.
4. Probar que no cambia geometría/datos y revisar las cuatro escenas a escala 34 px.
5. Dejar `flores.svg` sin referencias activas, conservar el archivo sin borrarlo y actualizar documentación de fuente de estilo.

## Hecho cuando

Los tres sprites aprobados reemplazan el recurso único de `flores`, rotan de manera determinista, todas las ubicaciones oficiales muestran las tres variantes, las ubicaciones/mapas siguen intactos, pruebas cubren distribución y estabilidad, importación/GUT pasan sin errores y hay capturas del motor de los cuatro niveles.

## Verificación

`godot --headless --import`; si cae con 139, volver a correr y registrar ambos intentos. GUT completo (`godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`) sin `SCRIPT ERROR`, `.uid` de tests versionados. Revisar diff/status y los datos JSON idénticos. Capturas del motor a 1280×720; no afirmar prueba móvil real ni rendimiento.

## Frenar si

Alguna PNG no corresponde byte a byte a la propuesta aprobada, la selección por coordenada no permite usar las tres, hay que cambiar datos/leyendas o aparecen diferencias de tamaño/filtrado visual que requieran editar el arte.
