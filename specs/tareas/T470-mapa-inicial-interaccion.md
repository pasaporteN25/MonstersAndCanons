# T470 · Mapa inicial, migración e interacción PC/celular

- **Ejecutor:** Sonnet · implementación acotada.
- **Depende de / compuerta:** T459 aprobada; coordinar SaveManager con T461/T458.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-687 a RF-690. **Rama:** `feature/t470-mapa-inicial-interaccion`, desde `origin/main` actualizado; un worktree, un commit `T470: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Migrar estilo una vez por archivo y respetar elección posterior. Separar selección de inicio; Enter/Jugar confirman una vez, doble clic no. Separar lienzo del pie fijo. Reutilizar umbral de MenuTouch para un dedo y scroll solo si excede ancho; foco visible y selección llevada a vista. Tarjetas siguen iniciando con un clic. Puede usar la geografía actual mientras T469/T471 preparan la nueva; no altera ni aprueba su arte.

## Archivos previstos

scripts/logic/campaign_map.gd, scripts/autoload/save_manager.gd, scenes/ui/campaign_map_view.gd, campaign_region.gd, level_select.gd; tests correspondientes. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Casos de migración y input de RF-687–690 cubiertos, bloqueo intacto, Jugar siempre visible y marcadores táctiles sin solaparse. No toca cámara de partida.

## Verificación

Tests de guardados e input/escena con puntero real simulado y suite GUT sin SCRIPT ERROR. Capturas PC en ambas resoluciones y celular simulado; real queda T454. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
