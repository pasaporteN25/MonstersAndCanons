# T474 · Insignias de conquista y números sin cero inicial

- **Ejecutor:** Sonnet · integración UI.
- **Depende de / compuerta:** T459 aprobada; T469 insignias aprobadas; T473 integrada.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-695, RF-697. **Rama:** `feature/t474-estandartes-numeros`, desde `origin/main` actualizado; un worktree, un commit `T474: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Auditar todas las pantallas con número de nivel. Mostrar número 1–15 sin renombrar ids/rutas ni reemplazar texto canónico indiscriminadamente. Fondo rebelde 0, partido 1–2, jugador 3; receta solo cosmética. Quitar rótulos redundantes del mapa manteniendo candado y razón de acceso.

## Archivos previstos

campaign_region.gd, campaign_map_view.gd, level_select.gd, HUD/entrada/victoria/Wiki/Récords que muestren números; modelo/formateador de UI y tests. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Los tres estados coinciden tarjeta/mapa, receta no cambia reglas, números sin cero en todas las superficies auditadas y rutas intactas.

## Verificación

Tests de estados/formato/receta y GUT completo; capturas de 0/1/2/3 estrellas en ambas vistas/interfaces. No se declara aprobado arte no revisado. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
