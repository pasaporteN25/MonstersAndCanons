# Revisa el archivo del tutorial del nivel 1 (M63, RF-578) sin abrir el juego y dice qué hay que arreglar, en castellano.
#   godot --headless --path . -s tools/check_tutorial.gd                      (revisa data/tutorial/tutorial.json)
#   godot --headless --path . -s tools/check_tutorial.gd -- ruta/al/archivo.json
# Termina con código 0 si está bien y 1 si tiene errores. No usa los autoloads (los `tools/` se compilan antes).
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else TutorialData.DEFAULT_PATH
	var data: TutorialData = TutorialData.load_file(path)
	if not data.is_valid():
		print("TUTORIAL CON ERRORES (%s):" % path)
		for error: String in data.errors:
			print("  - %s" % error)
		quit(1)
		return
	print("Tutorial OK (%s): nivel %s, %d pasos en PC y %d en el celular. Estado de los textos: %s." % [
		path, data.level_id, data.pc_steps.size(), data.mobile_steps.size(),
		"BORRADOR (falta el OK de Lucas)" if data.draft else "aprobados"])
	quit(0)
