# T225: exposición del Embestidor en el nivel 10 (como M45, pero con las dos entradas):
# por cada recta de 3 o más casillas, qué casillas construibles quedan a distancia de impacto y
# si hay otra casilla cerca para un apoyo. Es geometría, no una partida.
extends Node


func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t225_exposure.json")
	GameFlow.current_index = -1
	var results: Array[Dictionary] = []
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(9)
	add_child(game)
	for entrance: int in game.level.entrance_count():
		var path: Path2D = game.level.get_ground_path(entrance)
		var endpoints: int = 0
		var threatened: Dictionary = {}
		var supported: int = 0
		for segment: Dictionary in ChargeRules.segments(path.curve):
			if float(segment.end) - float(segment.start) < Rules.tiles_to_px(3):
				continue
			var end: Vector2 = path.to_global(segment.position)
			endpoints += 1
			for cell: Vector2i in game.level.ground.get_used_cells():
				if game.level.is_buildable(cell) and end.distance_to(game.level.cell_center(cell)) <= Rules.tiles_to_px(1.25):
					threatened[str(cell)] = true
					for other: Vector2i in game.level.ground.get_used_cells():
						if other != cell and game.level.is_buildable(other) and Vector2(other).distance_to(Vector2(cell)) <= 3.0:
							supported += 1
							break
		results.append({"level": 10, "entrance": entrance, "long_straights": endpoints,
			"threatened_cells": threatened.keys(), "threatened_with_support_nearby": supported})
	game.queue_free()
	var file: FileAccess = FileAccess.open("res://art/campaign-t225/exposure.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "\t") + "\n")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	print("T225_EXPOSURE ", JSON.stringify(results))
	get_tree().quit()
