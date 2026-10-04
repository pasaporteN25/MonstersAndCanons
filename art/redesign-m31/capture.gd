# Captura de poses con Enemy y recursos de producción; datos/balance no se reemplazan.
extends Node

const ROOT: String = "res://art/redesign-m31/previews/"
const IDS: Array[String] = ["armored", "troll", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss"]
var actors: Array[Enemy] = []
var slots: Array[Vector2] = []

func _ready() -> void:
	call_deferred("capture")

func label_(text_: String, position_: Vector2, size_: int = 17) -> void:
	var label := Label.new()
	label.text = text_
	label.position = position_
	label.add_theme_font_size_override("font_size", size_)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
	label.add_theme_constant_override("outline_size", 4)
	add_child(label)

func capture() -> void:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	label_("M31 · nueve ciclos nuevos · cuatro direcciones · ritmo por distancia", Vector2(40, 82), 22)
	for index: int in IDS.size():
		var data: EnemyData = load("res://data/enemies/" + IDS[index] + ".tres")
		label_(data.display_name, Vector2(34 + index * 137, 138))
		for row: int in 4:
			var path := Path2D.new()
			path.curve = Curve2D.new()
			path.curve.add_point(Vector2.ZERO)
			path.curve.add_point(Vector2.from_angle(row * PI / 2) * 10000)
			game.add_child(path)
			var enemy: Enemy = (load("res://scenes/enemies/enemy.tscn") as PackedScene).instantiate()
			enemy.setup(data, path, data.max_health)
			game.add_child(enemy)
			enemy.set_physics_process(false)
			var slot := Vector2(75 + index * 137, 215 + row * 120)
			enemy.position = slot
			actors.append(enemy)
			slots.append(slot)
	for index: int in 32:
		for actor_index: int in actors.size():
			var enemy: Enemy = actors[actor_index]
			# El ritmo sale de su física real. Solo se fija la posición de exposición después de avanzar.
			enemy._physics_process(0.08)
			enemy.position = slots[actor_index]
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ROOT + "motion_" + str(index).pad_zeros(2) + ".png")
		if index == 8:
			get_viewport().get_texture().get_image().save_png(ROOT + "directions_full_hd.png")
		await get_tree().process_frame
	get_tree().quit()
