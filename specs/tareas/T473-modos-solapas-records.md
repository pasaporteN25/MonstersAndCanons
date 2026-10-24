# T473 · Solapas alcanzables y récords de modos; absorbe T235

- **Ejecutor:** Sonnet · UI y lectura de récords.
- **Depende de / compuerta:** T459 aprobada; T470/T471 integradas si modifican selector.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-694. **Rama:** `feature/t473-modos-solapas-records`, desde `origin/main` actualizado; un worktree, un commit `T473: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Conservar orden RF-389, hacer alcanzables las solapas con más de dos modos propios. Agregar selector de modo a Récords usando ids guardados y top 5 existente. Retorno a misma solapa/selección. No adoptar Desafíos, porcentajes/encabezados nuevos ni fusionar modos.

## Archivos previstos

scenes/ui/level_select.gd/.tscn, records_screen.gd/.tscn, scripts/autoload/game_flow.gd solo si necesita preservar selección; tests de modos/récords. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Cinco modos propios accesibles por mouse/teclado/touch simulado; Récords muestra Asedio y modos sin mezclarlos; T235 absorbida con resultado honesto.

## Verificación

Tests de catálogo/errores/selección/top 5 y suite GUT. Capturas PC y celular simulado; no gameplay humano ni teléfono real. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
