# Revisa el archivo del efecto de mejora de torres (M65, RF-594) sin abrir el juego y dice qué hay que arreglar.
#   godot --headless --path . -s tools/check_mejoras.gd                      (revisa data/ui/mejoras.json)
#   godot --headless --path . -s tools/check_mejoras.gd -- ruta/al/archivo.json
# Termina con código 0 si está bien y 1 si tiene errores. No usa los autoloads (los `tools/` se compilan antes).
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else UpgradeFxConfig.PATH
	var config: UpgradeFxConfig = UpgradeFxConfig.load_from(path)
	if not config.is_valid():
		print("MEJORAS CON ERRORES (%s):" % path)
		for error: String in config.errors:
			print("  - %s" % error)
		print("El juego usa los valores por omisión en lo que está mal.")
		quit(1)
		return
	print("Mejoras OK (%s): %d estadísticas, variantes %s." % [path, config.stats.size(), ", ".join(config.variants.keys())])
	quit(0)
