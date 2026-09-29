# Fondo de los menús: el mapa del primer nivel, oscurecido detrás de los botones.
# Solo visual.
extends Node2D


func _ready() -> void:
	if GameFlow.level_count() == 0:
		return
	var map: Node2D = GameFlow.level(0).build_map()
	map.position = Vector2(0, 72)  # centrado en la pantalla de 720 px de alto
	add_child(map)
