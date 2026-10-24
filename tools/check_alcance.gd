extends SceneTree

func _initialize() -> void:
	var config := RangeDisplayConfig.load_from()
	if not config.is_valid():
		for error: String in config.errors:
			push_error(error)
		quit(1)
		return
	print("Configuración del círculo de alcance válida.")
	quit(0)
