# M36 · B-20 a B-27

Tanda completa, autorizada por Lucas el2026-10-03. B-28 quedó terminado en M35.

| Entrada | Resultado | Evidencia |
|---|---|---|
| B-20 | Implementado: placa/remaches en base, nueve torres × tres niveles, también aturdidas | [Torres](torres_niveles.png), [aturdidas](torres_aturdidas.png) |
| B-21 | Investigación entregada: tres vistas del mismo mapa y comparación de costos/riesgos; producción por decidir | [Informe](B21-profundidad.md), [relieve](profundidad_relieve2d.png), [oblicua](profundidad_oblicua2d.png), [2.5D](profundidad_suelo3d.png) |
| B-22 | Análisis entregado: tres torres/tres monstruos, funciones y desbloqueos, selección recomendada | [Informe](B22-contenido.md) |
| B-23 | Análisis entregado: tres recetas, requisitos2/3, estados y36 casos ejecutados sobre Enemy/Rules | [Informe](B23-vecindad.md), [resultados](combo_results.json) |
| B-24 | Implementado: residuo de pose actual de las trece especies, desintegración y fragmentos | [Vivos](bestiario_vivo.png), [muertes](bestiario_muertes.png), [fase media](bestiario_muertes_media.png) |
| B-25 | Implementado: trayectoria de rebote, aro roto/descargas y recuperación de torre | [Rebote](cura_rebote.png), [recuperación](torres_recuperacion.png) |
| B-26 | Implementado: límite de aura separado de pulso de cura; receptores heridos/fuego/vida completa diferenciados | [Muestra](cura_rebote.png) |
| B-27 | Implementado: música menú/combate, timbres suaves, cuatro avisos nuevos y mezcla limitada | [Informe](B27-audio.md), [manifest](audio_manifest.json) |

## Verificación

898/898 GUT,8150 asserts,70 scripts, sin SCRIPT ERROR ni Parse Error.200 enemigos/60 torres con residuos de muerte:100FPS de promedio, peor cuadro28,8ms,7 de601 cuadros por encima de16,6ms en esta máquina (RX6900XT); es una medición local, no garantía universal ni prueba móvil. Shader y fragmentos se ajustaron después de medir una primera versión que quedaba justo por debajo de60FPS. Residuos limitados a12 y pulsos de cura a16; ocho fragmentos por muerte.

Windows normal/pruebas y Linux exportados; ambos ejecutables Windows arrancan headless y salen con código0. No se ejecutó Linux ni Android en dispositivo. El aviso previo de certificados persiste; algunas corridas de herramientas muestran avisos previos de recursos al cerrar. Las capturas se revisaron visualmente; no se hizo evaluación auditiva humana de gusto/fatiga.

## Reproducir

Usar APPDATA aislado dentro de build/t180-user, para conservar el guardado del jugador. Desde la raíz:

- `godot --path . res://art/redesign-m36/capture.tscn`
- `godot --path . res://art/redesign-m36/depth_preview.tscn`
- `godot --headless --path . res://art/redesign-m36/combo_lab.tscn`
- `godot --headless --path . -s tools/make_sounds.gd` y luego importar.
- `godot --path . -s tools/perf_test.gd`

Los prototipos, JSON de resultados e informes de art quedan fuera del juego exportado. No se activaron nueva proyección, nuevos enemigos/torres ni recetas vecinales; esas entradas pedían una investigación previa. Se entregan completas y quedan listas para seleccionar una opción de producción.
