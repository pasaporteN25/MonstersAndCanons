# Revisa el archivo de consejos de la derrota (M70, RF-638) sin abrir el juego y dice qué hay que arreglar, en castellano.
#   godot --headless --path . -s tools/check_consejos.gd                      (revisa data/consejos/consejos.json)
#   godot --headless --path . -s tools/check_consejos.gd -- ruta/al/archivo.json
# Además del formato, revisa contra los datos reales: que cada regla aplique a algún enemigo del juego y que alguna
# torre del juego pueda cumplirla. Termina con código 0 si está bien y 1 si tiene errores. No usa los autoloads.
extends SceneTree


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else AdviceData.DEFAULT_PATH
	var data: AdviceData = AdviceData.load_file(path)
	var problems: PackedStringArray = data.errors.duplicate()
	if data.is_valid():
		problems.append_array(_check_against_game(data))
	if not problems.is_empty():
		print("CONSEJOS CON ERRORES (%s):" % path)
		for problem: String in problems:
			print("  - %s" % problem)
		quit(1)
		return
	print("Consejos OK (%s): %d reglas, %d criterios. Estado de los textos: %s." % [
		path, data.rules.size(), data.criteria.size(), "BORRADOR (falta el OK de Lucas)" if data.draft else "aprobados"])
	quit(0)


func _check_against_game(data: AdviceData) -> PackedStringArray:
	var problems: PackedStringArray = []
	var enemies: Array[EnemyData] = []
	enemies.assign(_load_all("res://data/enemies", EnemyData))
	var towers: Array[TowerData] = []
	towers.assign(_load_all("res://data/towers", TowerData))
	var longest: int = 0
	for tower: TowerData in towers:
		if not tower.support_only:
			longest = maxi(longest, tower.display_name.length())
	for rule: Dictionary in data.rules:
		var applies: PackedStringArray = []
		for enemy: EnemyData in enemies:
			if AdviceData.enemy_matches(rule["enemy"], enemy):
				applies.append(String(enemy.id))
		if applies.is_empty():
			problems.append("la regla \"%s\" no aplica a ningún enemigo del juego." % rule["id"])
		var fits: bool = false
		for criterion: String in rule["towers"]:
			for tower: TowerData in towers:
				fits = fits or data.tower_fits(criterion, tower)
		if not fits:
			problems.append("la regla \"%s\" no la puede cumplir ninguna torre del juego." % rule["id"])
		if data.worst_case_length(rule["text"], longest) > data.max_chars:
			problems.append("la regla \"%s\" con los nombres reales más largos (%d letras) pasa de %d caracteres." % [
					rule["id"], longest, data.max_chars])
	return problems


func _load_all(dir_path: String, type: Variant) -> Array:
	var result: Array = []
	for file_name: String in DirAccess.get_files_at(dir_path):
		var res_name: String = file_name.trim_suffix(".remap")
		if res_name.ends_with(".tres"):
			var resource: Resource = load("%s/%s" % [dir_path, res_name])
			if is_instance_of(resource, type):
				result.append(resource)
	return result
