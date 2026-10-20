# Revisa la entrada de los jefes (M66, RF-601) sin abrir el juego y dice qué hay que arreglar, en castellano:
# los números de data/ui/entrada_jefes.json y la `entrance` de cada enemigo de data/enemies/.
#   godot --headless --path . -s tools/check_entrada_jefes.gd                 (revisa el archivo oficial)
#   godot --headless --path . -s tools/check_entrada_jefes.gd -- ruta/al/archivo.json
# Termina con código 0 si está bien y 1 si tiene errores. No usa los autoloads (los `tools/` se compilan antes).
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else BossEntranceConfig.PATH
	var config: BossEntranceConfig = BossEntranceConfig.load_from(path)
	var errors: PackedStringArray = config.errors.duplicate()
	errors.append_array(BossEntranceConfig.validate_enemies())
	if not errors.is_empty():
		print("ENTRADA DE JEFES CON ERRORES (%s):" % path)
		for error: String in errors:
			print("  - %s" % error)
		quit(1)
		return
	var with_entrance: PackedStringArray = []
	for enemy_id: String in LevelFile.enemy_ids():
		var enemy: EnemyData = LevelFile.find_enemy(enemy_id)
		if enemy != null and enemy.entrance != null:
			var scope: String = "todos los niveles" if enemy.entrance.levels.is_empty() else ", ".join(enemy.entrance.levels)
			with_entrance.append("%s (%s)" % [enemy_id, scope])
	print("Entrada de jefes OK (%s). Enemigos con entrada: %s." % [
		path, ", ".join(with_entrance) if not with_entrance.is_empty() else "ninguno"])
	quit(0)
