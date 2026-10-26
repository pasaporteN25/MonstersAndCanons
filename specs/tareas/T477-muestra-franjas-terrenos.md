# T477 · Muestra de fondos por terreno y recortes

- **Ejecutor:** Codex · arte después de fijar estilo.
- **Depende de / compuerta:** T460 aprobada; 🎨 Lucas aprueba cada terreno/composición antes de producir finales.
- **Refs:** RF-700/RF-701. **Tamaño:** una sesión; dividir si el alcance real la supera.
- **Rama:** `feature/t477-muestra-franjas-terrenos` desde origin/main actualizado, worktree propio; un commit `T477: …`, PR a main, Lucas mergea.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, specs/tareas/README.md, constitución, M77 (RF-699–707), D-204–206, plan técnico M77, informe T450 entero y ficha T454 (desde main cuando se integre #57; lectura remota hasta entonces, sin editar ese PR).

## Objetivo y alcance

Comprobar temas en datos vigentes; preparar ficha/muestra de más allá del mapa, fijo respecto al zoom. Mostrar combinación con mapa actual y recorte runtime 16:10,21:9,4:3 y 20:9, sin casillas jugables nuevas. Proponer fuente/tamaño/peso y encuadre con guía de arte, sin asumir aprobación de composición.

## Archivos previstos

art/t477-fondos-franjas/ (fuentes, manifest, prompts y muestras); ninguna ruta runtime. Leer reglas por carpeta antes de editar y asignar propietario único de cada archivo compartido.

## Hecho cuando

Lucas tiene muestras por terreno a escala y puede aprobar/rechazar cada una; no se modifica arte aprobado ni se produce final antes de compuerta.

## Verificación

Revisión visual/documental, procedencia y límites. No ejecutar Godot/GUT si no cambia runtime; no performance ni teléfono real. Versionar cada `.uid` de test propio. Tras import, revertir únicamente assets no tocados a propósito; salida 139 se relanza y registra. Un test con SCRIPT ERROR es fallo. Capturas fuera del repo salvo las del PR; resolución/hardware/uptime/build obligatorios para afirmar rendimiento.

## Frenar si

Falta aprobación funcional/de arte/medición que la ficha exige; la solución pide expandir mapa/HUD, cambiar mecánicas/canon/balance o descartar guardados; otro agente edita los mismos archivos. Informar el límite y seguir solo con trabajo independiente autorizado.
