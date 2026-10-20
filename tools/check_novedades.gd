# Revisa el archivo de «Novedades de esta versión» (M67, RF-605, RF-609) sin abrir el juego y dice qué hay que arreglar,
# en castellano. También avisa si la versión de `project.godot` es un número y no tiene una entrada aprobada.
#   godot --headless --path . -s tools/check_novedades.gd                      (revisa data/novedades/novedades.json)
#   godot --headless --path . -s tools/check_novedades.gd -- ruta/al/archivo.json
# Termina con código 0 si está bien (los avisos no cuentan) y 1 si tiene errores. No usa los autoloads.
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else NewsData.DEFAULT_PATH
	var data: NewsData = NewsData.load_file(path)
	if not data.is_valid():
		print("NOVEDADES CON ERRORES (%s):" % path)
		for error: String in data.errors:
			print("  - %s" % error)
		quit(1)
		return
	var version: String = GameVersion.raw()
	var drafts: int = 0
	for entry: Dictionary in data.entries:
		if bool(entry["borrador"]):
			drafts += 1
	print("Novedades OK (%s): %d versiones (%d en borrador). Versión de project.godot: «%s»." % [path, data.entries.size(), drafts, version])
	for warning: String in data.warnings_for(version):
		print("  AVISO: %s" % warning)
	quit(0)
