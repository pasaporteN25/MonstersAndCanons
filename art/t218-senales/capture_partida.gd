extends Node

func _ready() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var result: Dictionary = LevelFile.load_level("res://tools/ejemplos/tema_ruinas.json")
	if result["level"] == null:
		push_error("No se pudo leer el ejemplo de ruinas: %s" % "; ".join(result["errors"]))
		get_tree().quit(1)
		return
	var level_data: LevelData = result["level"]
	# Seis casillas de pasto del mapa de ejemplo quedan como muestra de la leyenda T218.
	level_data.map_rows[0] = "rshpuc" + level_data.map_rows[0].substr(6)
	for entry: Dictionary in [
		{"letra": "r", "dibujo": "roca_marcada"}, {"letra": "s", "dibujo": "sendero"},
		{"letra": "h", "dibujo": "herramienta"}, {"letra": "p", "dibujo": "poste_cintas"},
		{"letra": "u", "dibujo": "simbolo_ruina"}, {"letra": "c", "dibujo": "campamento_vacio"},
	]:
		level_data.legend[entry["letra"]] = {"dibujo": entry["dibujo"], "construible": false}
	GameFlow.current_index = -1
	GameFlow.test_level = level_data
	var game: Node = load("res://scenes/game/game.tscn").instantiate()
	get_tree().root.add_child(game)
	for frame: int in 5:
		await get_tree().process_frame
	var screenshot: Image = get_viewport().get_texture().get_image()
	var output: String = ProjectSettings.globalize_path("res://art/t218-senales/capturas/partida.png")
	var error: Error = screenshot.save_png(output)
	if error != OK:
		push_error("No se pudo guardar la captura: %s" % error_string(error))
		get_tree().quit(1)
	else:
		print("Captura en partida guardada: %s (%s)" % [output, screenshot.get_size()])
	get_tree().quit()
