# Revisión con escenas y recursos de producción, sin reemplazar datos ni escalar nodos.
extends Node

const ROOT: String = "res://art/redesign-m30/"
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
	label_("Mejoras programáticas · nivel1 / nivel2 / nivel3", Vector2(55, 125))
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
	get_tree().quit()
