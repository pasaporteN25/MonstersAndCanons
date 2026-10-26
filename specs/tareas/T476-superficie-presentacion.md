# T476 · Superficie física y contenido lógico fijo

- **Ejecutor:** Sonnet · implementación; Opus arquitectura/revisión pesada.
- **Depende de / compuerta:** T460 aprobada y OK explícito de Lucas a la propuesta técnica D-204/T476 (host/viewport, escenas e input), archivos compartidos libres.
- **Refs:** RF-699/RF-702/RF-707. **Tamaño:** una sesión; dividir si el alcance real la supera.
- **Rama:** `feature/t476-superficie-presentacion` desde origin/main actualizado, worktree propio; un commit `T476: …`, PR a main, Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, constitución, M77 (RF-699–707), D-204–206, plan técnico M77, informe T450 entero y ficha T454 (desde main cuando se integre #57; lectura remota hasta entonces, sin editar ese PR).

## Objetivo y alcance

Prototipar una presentación física que conserve el marco lógico 1280×720 sin agrandar el juego/HUD ni usar expand jugable. SubViewport/host es la propuesta recomendada, no una decisión: revisar también alternativas seguras y volver a Lucas con impactos antes de implementarla. Si se aprueba, elegir render target dinámico o mecanismo equivalente que mantenga nítidos HUD/texto a 1920×1080 y móvil; no escalar una imagen fija de 1280×720 sin verificar. Auditar `current_scene`/`reload_current_scene` en GameFlow, root, `get_viewport`, F6, ventanas emergentes/OptionButton/FileDialog, selección/foco/teclado, `physics_object_picking`, DesktopWindow, balance_sim, tests headless y la capa/texto/barra de SceneTransition. Preservar escena inicial/reintentar y fallback; bloquear/restaurar input sin duplicar eventos.

## Archivos previstos

project.godot (solo presentación), scripts/autoload/game_flow.gd, scripts/logic/scene_transition.gd, nuevo host/modelo de presentación, tests y adaptaciones mínimas de consultas de viewport. Leer reglas por carpeta antes de editar y asignar propietario único de cada archivo compartido.

## Hecho cuando

Marco lógico y tamaños/input conservados en todas las relaciones; flujo y bloqueo/restauración funcionan; no mecánicas nuevas. Si supera sesión, subdividir con revisión antes de mezclar.

## Verificación

Tests de geometría/input/host/flujo y GUT completo, sin tests que cambien escena según reglas de tests; usar swapper/costuras. Capturas ventana 16:9,16:10,21:9,4:3 y 20:9 simulado; no Android real. Versionar cada `.uid` de test propio. Tras import, revertir únicamente assets no tocados a propósito; salida 139 se relanza y registra. Un test con SCRIPT ERROR es fallo. Capturas fuera del repo salvo las del PR; resolución/hardware/uptime/build obligatorios para afirmar rendimiento.

## Frenar si

Falta aprobación funcional/de arte/medición que la ficha exige; la solución pide expandir mapa/HUD, cambiar mecánicas/canon/balance o descartar guardados; otro agente edita los mismos archivos. Informar el límite y seguir solo con trabajo independiente autorizado.
