# T257 · La Cuadrilla, arte provisional

Entrega **pendiente de aprobación de Lucas**. No cambia datos ni código del juego. Ficha y resultado: [T257](../../specs/tareas/T257-arte-cuadrilla.md).

Para revisar: [hoja de contacto](captures/contact_sheet.png), [todas las fases](captures/walk_cycles.png) y [caminata animada](captures/walk_preview.gif). La hoja compara al Ratero y al Cargador con el Ladrón aprobado M43 sobre colores de pradera; incluye encuadres de 220, 112 y 34 px, siluetas de 34 px de alto visible y una referencia proporcional según RF-485. No es una captura en partida.

Las fuentes son SVG nativos, dibujados en coordenadas, con contorno `#202330`, tres paradas de degradé y luz arriba/izquierda. La entrega PNG conserva el formato de los enemigos actuales: estáticas 256×256 y atlas 1024×1024 con filas derecha, abajo, izquierda, arriba. La vista izquierda tiene geometría propia en sus coordenadas y conserva la iluminación: el juego no debe reflejar el PNG. Los frentes y espaldas se dibujaron por separado. El atlas no se obtiene moviendo una pose rígida: cambian patas y brazos según la fase, con apoyos constantes.

Ratero: cobre rosado claro, cuerpo horizontal sin ropa ni bolsa. Cargador: terracota oscura, cuerpo ancho y bolsa de lona dominante. No hay símbolo A, capucha, capa, corona, uniforme ni marcas de las comunidades. El acabado vectorial es más simple que el del Ladrón renderizado: esta entrega propone las siluetas, no certifica una equivalencia de acabado definitivo.

## Reproducir

Desde la raíz, con Godot 4.7.2 y Python 3 con Pillow:

```bash
python3 art/t257-cuadrilla/draw.py
godot --headless --import
godot --headless -s art/t257-cuadrilla/pack.gd
python3 art/t257-cuadrilla/review.py
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

`draw.py` reproduce las 32 fuentes; `pack.gd` rasteriza directamente con Godot; `review.py` valida alfa, anclaje, márgenes, unicidad y estática/fase cero y genera hojas, GIF y manifiesto con hashes. La bolsa no lleva sombra de suelo. El GIF muestra todas las fases a la misma cadencia para comparar, no representa velocidades de campaña.

Los `.tres` de la banda todavía no existen aquí. Las rutas y los parámetros visuales sugeridos para T253 están en la ficha y el manifiesto. Pendientes aprobación, integración y captura real; no se cambiaron campos jugables, no se probó balance ni plataformas de exportación.

La auditoría `tests/test_resource_audit.gd` enumera los cuatro PNG como recursos intencionalmente sin uso (`KNOWN_UNUSED`), porque los `.tres` no existen aquí. T253 debe retirar esas cuatro entradas al integrar sus rutas. No se cambia la lógica del test ni se declaran integrados los dibujos.

La validación conserva salidas completas en archivos `.txt` dentro de `art/t257-cuadrilla/validation/`; los `.log` de ejecución quedan locales. La importación mostró el aviso de ADB (`cannot connect to daemon at tcp:5037`), sin errores de script. No se modificó la configuración del sistema.

## Resultado de validación

Final: **1524/1524 tests**, 17367 assertions, 112 scripts, salida 0; sin `SCRIPT ERROR` ni `Parse Error`. Primera suite: 1523/1524 por los cuatro assets intencionalmente sin uso; se corrigió la lista de auditoría. Empaquetado e importación final sin errores de script; 32 fases únicas con alfa, márgenes y apoyo constante verificados. Las salidas completas incluyen el error esperado de `no_existe` y avisos de nodos huérfanos de GUT. No se hizo captura real, integración, balance, pruebas de rendimiento o exportación.
