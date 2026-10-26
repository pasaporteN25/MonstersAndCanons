class_name CampaignBadgeIcon
extends Control
## La insignia de un nivel de la campaña en la vista de **tarjetas** del selector (T501, RF-695). Dibuja exactamente lo mismo
## que el mapa planetario (la insignia V3 con su número, el candado y el halo punteado de «disponible») llamando al mismo
## código de `CampaignRegion`, a una escala menor, para que el estado se lea igual en las dos vistas. No agrega arte ni
## guarda nada: el estado sale del progreso (`CampaignMap.state_of`). No atiende al puntero: el clic es de la tarjeta.

## Lado del cuadro que ocupa en la tarjeta, en px lógicos.
const SIDE: float = 40.0
## Escala del dibujo del mapa: el borde de 26 px pasa a 18 px (36 px de diámetro) y el halo queda adentro del cuadro.
const UNIT: float = 0.69

var state: CampaignMap.State = CampaignMap.State.LOCKED
var level_index: int = 0


func setup(badge_state: CampaignMap.State, index: int) -> void:
	state = badge_state
	level_index = index
	custom_minimum_size = Vector2(SIDE, SIDE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size / 2.0
	if CampaignMap.has_halo(state):
		CampaignRegion.draw_halo(self, center, UNIT)
	CampaignRegion.draw_badge(self, state, level_index, center, get_theme_default_font(), UNIT)
