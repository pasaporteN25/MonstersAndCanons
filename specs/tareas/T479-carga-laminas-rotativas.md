# T479 · Láminas de intro rotativas en la carga

- **Ejecutor:** Sonnet · implementación acotada, revisión independiente si Gemini disponible.
- **Depende de / compuerta:** T460 aprobada; 🚦 anexo al informe T454 con medición real del costo de láminas en celular y aprobación escrita de Lucas con esos datos; T476 integrada.
- **Refs:** RF-703–707. **Tamaño:** una sesión; dividir si el alcance real la supera.
- **Rama:** `feature/t479-carga-laminas-rotativas` desde origin/main actualizado, worktree propio; un commit `T479: …`, PR a main, Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, constitución, M77 (RF-699–707), D-204–206, plan técnico M77, informe T450 entero y ficha T454 (desde main cuando se integre #57; lectura remota hasta entonces, sin editar ese PR). La ficha T454 vigente no pide medir las láminas: agregarlo como anexo al informe de resultados, sin cambiar el PR #57.

## Objetivo y alcance

Solo tras compuerta: una imagen por transición aceptada, bolsa sin repetición consecutiva, estado en memoria de GameFlow. Cargar textura en hilo, color/barra primero, descartar tardías sin alargar carga. Núcleo no conoce intro/rutas. Recorte/velo revisado; 0/1/N válidas, fallo y busy; no cargar siete ni precarga permanente ni cambios de import.

## Archivos previstos

scripts/autoload/game_flow.gd, scripts/logic/scene_transition.gd, modelo puro de rotación/proveedor genérico, tests/test_scene_transition.gd/test_loading_flow.gd y tests propios. Leer reglas por carpeta antes de editar y asignar propietario único de cada archivo compartido.

## Hecho cuando

Rotación y asincronía cumplen criterios, entrada bloqueada y restaurada, mínimo 0,4s intacto, escena lista no espera textura/fundido; anexo de medición y aprobación previas enlazadas, verificación móvil final documentada.

## Verificación

Tests puros/escena/flujo con costuras de carga lenta/fallida, GUT sin errores, capturas PC y celular simulado; nuevo resultado real T454 después de integrar. No sustituir compuerta con PC. Versionar cada `.uid` de test propio. Tras import, revertir únicamente assets no tocados a propósito; salida 139 se relanza y registra. Un test con SCRIPT ERROR es fallo. Capturas fuera del repo salvo las del PR; resolución/hardware/uptime/build obligatorios para afirmar rendimiento.

## Frenar si

Falta aprobación funcional/de arte/medición que la ficha exige; la solución pide expandir mapa/HUD, cambiar mecánicas/canon/balance o descartar guardados; otro agente edita los mismos archivos. Informar el límite y seguir solo con trabajo independiente autorizado.
