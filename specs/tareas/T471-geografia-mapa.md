# T471 · Integrar geografía aprobada del planeta

- **Ejecutor:** Sonnet · integración.
- **Depende de / compuerta:** T470 integrada y T469 aprobada por Lucas 🎨.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-691, RF-698. **Rama:** `feature/t471-geografia-mapa`, desde `origin/main` actualizado; un worktree, un commit `T471: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Tomar fuente y coordenadas de la muestra aprobada, actualizar modelo/fondo juntos y conservar estados derivados del progreso. Scroll solo al desbordar; no toca grillas de niveles ni canon. Preservar T427 como antecedente.

## Archivos previstos

scripts/logic/campaign_map.gd, scenes/ui/campaign_map_view.gd, assets/ui/campaign_map_background.svg (o formato aprobado), tests/test_campaign_map.gd. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Aterrizaje y regiones en tierra; ruta oeste→este sin mar ni cruces; se ve selección/foco en ambos extremos. Integrado solo arte aprobado.

## Verificación

Pruebas geométricas, input y GUT completo. Capturas PC/celular simulado inicio/medio/final cuando haya scroll; no teléfono real. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
