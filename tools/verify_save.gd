# T268a (B-39): muestra qué carga la versión actual del juego de un archivo save.json, sin modificarlo.
# Uso (siempre sobre una COPIA del guardado, nunca sobre el original):
#   godot --headless --path . -s tools/verify_save.gd -- /ruta/a/copia_save.json
# Imprime niveles ganados y abiertos, estrellas, colecciones e intro. No escribe nada (comprueba el hash al final).
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		print("Falta la ruta del guardado. Uso: godot --headless --path . -s tools/verify_save.gd -- /ruta/save.json")
		quit(2)
		return
	var path: String = args[0]
	if not FileAccess.file_exists(path):
		print("No existe el archivo: %s" % path)
		quit(2)
		return
	# Los autoloads no se pueden nombrar acá (este script se compila antes que ellos): se buscan por nombre.
	var save_manager: Node = root.get_node("SaveManager")
	var game_flow: Node = root.get_node("GameFlow")
	var md5_before: String = FileAccess.get_md5(path)
	save_manager.save_path = path
	save_manager.load_save()
	var won: Array = []
	var open: Array = []
	for i: int in game_flow.level_count():
		if save_manager.is_completed(StringName("level_%02d" % (i + 1))):
			won.append(i + 1)
		if game_flow.is_level_unlocked(i):
			open.append(i + 1)
	print("Archivo: %s" % path)
	print("Niveles ganados: %s" % [won])
	print("Niveles abiertos para jugar: %s" % [open])
	print("Estrellas: %d" % game_flow.total_stars())
	print("Salón de la fama (total anotado): %d" % save_manager.hall_total())
	print("Colección technology: %s" % [Array(save_manager.collected_sources(&"technology"))])
	print("Colección disruptor: %s" % [Array(save_manager.collected_sources(&"disruptor"))])
	print("Intro ya vista: %s" % save_manager.intro_seen())
	print("Preferencias de interfaz: %s" % save_manager.get_ui_prefs().to_dict())
	print("Archivo sin modificar: %s" % (FileAccess.get_md5(path) == md5_before))
	quit()
