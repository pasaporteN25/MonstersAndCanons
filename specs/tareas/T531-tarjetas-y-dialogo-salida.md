# T531 · Ocultar tarjetas bloqueadas y simplificar la salida

- **Ejecutor:** Sonnet 5.5 · **Tamaño:** mediano · **Tipo:** código y UI.
- **Depende de:** T530 mergeada.

## Leer

- `specs/00-constitucion.md`, RF-111, RF-459 a RF-461, RF-688 y RF-724/RF-725
- `scenes/ui/level_select.gd`, `scripts/logic/game_flow.gd`, vistas de mapa/tarjetas y tests actuales del selector
- `scenes/ui/exit_dialog.*`, `scripts/logic/exit_text.gd`, `scenes/game/game.gd` y tests del diálogo
- Reglas de `.claude/rules/` correspondientes a escenas, scripts y tests

## Objetivo

Hacer que Tarjetas coincida con lo que puede iniciarse y dejar la confirmación de salida breve, sin cambiar la interacción del mapa ni el flujo de pausa.

## Alcance

- Construir tarjetas solo para índices desbloqueados con la misma función que ya usa el juego.
- Conservar el total global de estrellas y las listas de modos/comunidad/pruebas.
- Reemplazar las frases largas de `ExitText` por ninguna frase o por el aviso de RF-725.
- Actualizar tests y textos de changelog.

## Hecho cuando

- Guardado nuevo: Tarjetas presenta solo nivel 1; una campaña que habilitó hasta N muestra 1…N y no otros.
- El mapa sigue mostrando e inspeccionando niveles bloqueados; las estrellas siguen calculadas sobre toda la campaña.
- El diálogo tiene título, botones y como máximo el aviso exacto de RF-725.
- Sigue pausando, restaura estado/velocidad al cancelar, conserva foco/Esc y no modifica el guardado al salir.
- Se cubren caminos excluidos y progreso/coleccionables/demolición sin romper la salida.
- `godot --headless --import` y GUT completo terminan sin errores ni `SCRIPT ERROR`; capturas PC y celular simulado.

## Verificación

Seguir el protocolo del proyecto; revisar `git status` tras importar y no borrar `.import` versionados de `assets/`. No afirmar prueba real en teléfono.

## Frenar si

El selector necesita alterar `CampaignMapView`, desbloqueos, `SAVE_VERSION` o datos de campaña para cumplir la regla.
