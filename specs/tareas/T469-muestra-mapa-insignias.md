# T469 · Muestra del mapa nuevo e insignias de conquista

- **Ejecutor:** Codex · arte, después de fijar estilo.
- **Depende de / compuerta:** T459 aprobada; 🎨 Lucas aprueba muestra antes de integrar.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-691, RF-695, RF-652. **Rama:** `feature/t469-muestra-mapa-insignias`, desde `origin/main` actualizado; un worktree, un commit `T469: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Preparar una revisión visual del mapa planetario actualmente integrado por T428, cuya muestra base se presentó en T427. Aplicar las decisiones ya aprobadas: geografía en serrucho oeste→este, aterrizaje en tierra, regiones orgánicas y zonas no conquistadas más grises; sumar el círculo rebelde, partido y jugador. Conservar los elementos aprobados del mapa y los biomas/canon. Mostrar PC y celular a escala, con y sin desborde; determinar el ancho por legibilidad, sin forzar scroll. La aprobación de T459 habilita preparar la muestra, pero no integrarla: Lucas aprueba esa revisión antes de cualquier cambio en runtime.

## Archivos previstos

art/t469-mapa-propuesta/; ninguna ruta runtime. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Hay fuente editable, procedencia, tamaños/peso y maqueta legible; Lucas puede aprobar cada pieza. No se declara aprobada por esta ficha.

## Verificación

Revisión documental y visual de muestra. No Godot ni tests si no cambia runtime. No teléfono ni rendimiento. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
