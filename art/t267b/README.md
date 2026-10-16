# T267b · Propuesta renderizada, etapa 1

En preparación. Esta carpeta contiene únicamente arte y herramientas de revisión aisladas; nada se conecta al juego. La aprobación artística de Lucas y la integración quedan pendientes.

Referencias: `assets/sprites/map/rendered/tree.png`, `rock_a.png`, `assets/sprites/towers/rendered/turret_cannon.png`, `turret_basic.png` y `turret_sniper.png`. Luz arriba a la izquierda, perspectiva ortográfica elevada, materiales con volumen y lectura a 34 px. Los ids comprobados son `cannon` (Cañón), `sniper` (Francotirador) y `basic` (Ametralladora); las estatuas representan sus máquinas talladas en piedra, sin figuras humanas, casco, engranaje ni aura del Estandarte mecánico.

Las fuentes se producen con la herramienta integrada de generación de imágenes (skill `imagegen`), no con los SVG provisionales de T267a/T218/T219/T220. Los antecedentes se conservaron intactos. Los prompts y resultados quedan registrados en esta carpeta.

## Reproducción de derivados y revisión

Desde la raíz del repositorio, con Godot 4.7.2, Python 3 y Pillow:

```bash
python3 art/t267b/prepare.py
godot --headless --import
# Revisar git status y restaurar únicamente cambios involuntarios de assets.
XDG_DATA_HOME=/tmp/t267b-user godot --path . --resolution 1280x720 --position 20,30 art/t267b/capture.tscn
python3 art/t267b/build_review.py
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

`prepare.py` conserva las fuentes RGBA, recorta por alfa y normaliza los objetos a PNG de 128×128 con apoyo común. Central usa 256×256 y se corta exactamente en cuatro ventanas de 128×128, sin modificar el máster. Las hojas se componen sobre las texturas restauradas existentes y muestran una casilla a 220/34 px; Central ocupa dos por lado. El empaquetador no escribe fuera de esta carpeta.

`capture.gd` y `sample_decor.gd` son herramientas de revisión aisladas, derivadas del banco de T267a. Instancian el juego real con guardado `user://test_t267b_capture.json` y datos de usuario separados; capturan 1280×720 exactos sin reescalar. No arrancan oleadas ni afirman una extracción jugada. Se alternan los tres estados de dibujo sobre el mismo mundo pausado: `proposal` = reposo/Cañón, `proposal_state_1` = activa/Francotirador y `proposal_state_2` = agotada/Ametralladora. Escombros conserva trabajo en los dos últimos; Central es estática.

`level_13_statue_samples_before/after` es un muestrario adicional de las tres estatuas con escarcha en casillas bloqueadas separadas, junto a la decoración actual de nieve. **No son apariciones de campaña:** el nivel 13 no contiene estatuas en sus datos. El antes conserva los objetos reales y el después los sustituye solo en esta escena. Las capturas normales del 13 mantienen su contenido real y se evalúan por separado.

`build_review.py` arma recortes sin ampliar los píxeles de mapa, un comparador HTML y el control de diferencias fuera de las casillas seleccionadas. Las capturas normales son partidas reales en preparación, no mapas reconstruidos; los estados posteriores se fuerzan exclusivamente en la presentación de arte. Las capas reales de reserva y velo no cambian al alternar.

Las fuentes generadas no son deterministas ni provienen de un único modelo 3D. Sus prompts conservan la formulación original enviada a la herramienta para permitir nuevas iteraciones; los derivados sí se reproducen exactamente desde los PNG guardados. La aprobación de Lucas sigue pendiente; no ejecutar herramientas históricas que escriben en `assets/` para integrar esta entrega.

## Resultado verificado

Importación y captura: salida 0. GUT completo: **1635/1635**, 19.704 asserts, 117 scripts; **0 SCRIPT ERROR/Parse Error/Failed to load script** en los tres logs. El fixture `no_existe` y los avisos de guardados inválidos son esperados; ADB no disponible fue un aviso de la importación. Se verificaron 24 comparaciones sin cambios fuera de las casillas seleccionadas y reconstrucción exacta del máster de Central desde sus cuatro cuartos. Las 34 capturas originales miden 1280×720. El resumen `review/overview_25_percent.png` se reduce al 25 % y no sustituye esos originales.

Informe completo: [T267b-propuesta-nueva.md](../../specs/tareas/informes/T267b-propuesta-nueva.md). Prompts: `mine_initial_prompt.txt`, `prompts.json` y `forest_revision.json`. El primer bosque activo está en `sources/drafts/forest_active_v1.png`: se conservó para documentar la corrección de silueta a 34 px. Todo permanece como propuesta pendiente de aprobación; sin cambios integrados ni validación humana, móvil o de rendimiento.
