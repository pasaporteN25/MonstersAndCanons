# Revisión con escenas y recursos de producción, sin reemplazar datos ni escalar nodos.
extends Node

const ROOT: String = "res://art/redesign-m29/previews/"
const TOWERS: Array[String] = ["cannon", "basic", "multi", "sniper", "burst", "fire", "mortar", "frost", "tesla"]
const MONSTERS: Array[String] = ["normal", "fast", "tank", "flyer", "armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss"]
const NAMES: Array[String] = ["Diablillo", "Bestia", "Tanque", "Volador", "Blindado", "Troll", "Araña", "Cría", "Guardián", "Curandero", "Chamán", "Espejo", "Jefe"]

func _ready() -> void:
	call_deferred("capture")

func label_(text_: String, position_: Vector2) -> void:
	var label := Label.new()
	label.text = text_
	label.position = position_
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
	label.add_theme_constant_override("outline_size", 5)
	add_child(label)

func save_(name_: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ROOT + name_ + ".png")

func clear_() -> void:
	for node: Node in get_children():
		node.queue_free()
	await get_tree().process_frame

func game_() -> Node2D:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	return game

func capture() -> void:
	var game: Node2D = game_()
	await get_tree().process_frame
	label_("Montaje C · base fija y mecanismo móvil · tres niveles", Vector2(55, 125))
	for index: int in TOWERS.size():
		var data: TowerData = load("res://data/towers/" + TOWERS[index] + ".tres")
		label_(data.display_name, Vector2(35 + index * 137, 550))
		for level: int in 3:
			var tower: Tower = (load("res://scenes/towers/tower.tscn") as PackedScene).instantiate()
			tower.setup(data)
			tower.level_index = level
			tower.position = Vector2(75 + index * 137, 220 + level * 130)
			tower.aim_angle = [0.0, PI / 4.0, -PI / 2.0][level]
			game.add_child(tower)
			tower.set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	await save_("torres_full_hd")
	await clear_()
	game = game_()
	await get_tree().process_frame
	label_("Trece monstruos migrados · +20 % visual · radios lógicos originales", Vector2(55, 125))
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(1000, 0))
	game.add_child(path)
	for index: int in MONSTERS.size():
		var data: EnemyData = load("res://data/enemies/" + MONSTERS[index] + ".tres")
		var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
		enemy.setup(data, path, data.max_health)
		game.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.distance = 12
		enemy.position = Vector2(120 + (index % 7) * 172, 290 + (index / 7) * 200)
		label_(NAMES[index], enemy.position + Vector2(-40, 38))
	await get_tree().create_timer(0.2).timeout
	await save_("monstruos_full_hd")
	await clear_()
	game = game_()
	await get_tree().process_frame
	label_("Movimiento en producción · pasos por distancia, sin aplastamiento", Vector2(55, 120))
	for index: int in 6:
		var id: String = ["normal", "fast", "tank", "normal", "flyer", "armored"][index]
		var data: EnemyData = load("res://data/enemies/" + id + ".tres")
		path = Path2D.new()
		path.position = Vector2(240, 205 + index * 62)
		path.curve = Curve2D.new()
		path.curve.add_point(Vector2.ZERO)
		path.curve.add_point(Vector2(800, 0))
		game.add_child(path)
		var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
		enemy.setup(data, path, data.max_health)
		game.add_child(enemy)
		if index == 3:
			enemy.take_hit(1, 0.5, 10.0)
		label_(["Diablillo", "Bestia", "Tanque", "Ralentizado 50 %", "Volador", "Blindado (pose fija)"][index], Vector2(45, path.position.y - 12))
	for index: int in 24:
		await get_tree().create_timer(0.06).timeout
		await save_("motion_" + str(index).pad_zeros(2))
	await clear_()
	game = game_()
	await get_tree().process_frame
	game.session.earn(10000)
	for index: int in 6:
		game.build_controller.try_build(game.tower_types[index], Vector2i(3 + (index % 3) * 4, 2 + (index / 3) * 4))
	# Captura de combate real usando el mismo botón/flujo que la partida.
	game.start_next_wave()
	await get_tree().create_timer(6.0).timeout
	await save_("combate_full_hd")
	get_tree().quit()
