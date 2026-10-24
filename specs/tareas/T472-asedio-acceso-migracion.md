# T472 · Asedio por victoria de campaña y acceso heredado

- **Ejecutor:** Sonnet · lógica de guardado.
- **Depende de / compuerta:** T459 aprobada; SaveManager/GameFlow libres de otro agente.
- **Tamaño:** una sesión de implementación; si el alcance real la supera, subdividir en nuevas tareas antes de mezclar cambios.
- **Refs:** RF-692, RF-693. **Rama:** `feature/t472-asedio-acceso-migracion`, desde `origin/main` actualizado; un worktree, un commit `T472: …`, PR a main; Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, specs/00-constitucion.md, M76 (RF-687 a RF-698) en specs/01-spec.md, D-198 a D-203, plan técnico M76 y las dos secciones finales de informes/T449-selector-campana-asedio.md.

## Objetivo y alcance

Regla específica Asedio: campaña N ganada o derecho heredado; no abrir N+1 al ganar Asedio N. Migrar una vez cada archivo con evidencia de juego, sin cerrar accesos ni perder récords. Modo de pruebas abre todo en su archivo propio; no toca normal. Conservar otras reglas y porcentajes.

## Archivos previstos

scripts/autoload/game_flow.gd, save_manager.gd, scripts/logic/mode_packs.gd (comprobar ruta actual), pruebas de modos y guardados. Antes de editar, leer las reglas por carpeta correspondientes. Coordinar propietario único de archivos compartidos; nunca dos agentes sobre el mismo archivo.

## Hecho cuando

Guardados nuevos/viejos/jugados/no jugados y normal→pruebas→normal cumplen RF-692/693; no cambia economía, dificultad ni campaña.

## Verificación

Tests puros/guardados/flujo y GUT completo sin errores de script. No bots como aprobación de dificultad y no celular real. Versionar cada `.uid` propio de los tests; tras import revertir solo cambios de assets no intencionales. Si import termina 139, reintentar e informar. Las capturas se guardan fuera del repo salvo las adjuntas al PR. No afirmar rendimiento sin resolución, hardware, uptime/carga y build.

## Frenar si

Falta el OK de esta spec, arte o posición que exige la ficha; hay que cambiar mapa jugable/canon/balance; otra tarea edita los mismos archivos; una prueba imprime SCRIPT ERROR aunque su resumen diga aprobada. Documentar el límite y avanzar solo con la parte independiente autorizada.
