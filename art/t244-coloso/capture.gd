# Banco de muestras con Enemy de producción: no es el combate final del nivel 15.
extends Node2D
const ROOT: String = "res://art/t244-coloso/"
const BODY: Texture2D = preload("res://assets/sprites/enemies/rendered/colossus.png")
const SHARD: Texture2D = preload("res://assets/sprites/enemies/rendered/colossus_shard.png")
const BODY_WALK: Texture2D = preload("res://assets/sprites/enemies/rendered/colossus_walk.png")
const SHARD_WALK: Texture2D = preload("res://assets/sprites/enemies/rendered/colossus_shard_walk.png")
var actors: Array[Enemy] = []
var slots: Array[Vector2] = []

func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t244_capture.json")
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(0)
	add_child(game)
	await get_tree().process_frame
	game.hud.get_node("EnemyIntro").hide()
	var title: Label = Label.new()
	title.text = "T244 · PROVISIONAL · Enemy real sobre pradera · muestra, no integración en el nivel 15"
	title.position = Vector2(20, 80)
	title.add_theme_constant_override("outline_size", 3)
	add_child(title)
	var body: EnemyData = (preload("res://data/enemies/guardian.tres") as EnemyData).duplicate()
	body.texture = BODY
	body.walk_atlas = BODY_WALK
	body.walk_art_scale = 1.0
	body.walk_stride_tiles = 1.1
	body.visual_scale = 1.8
	body.size_tiles = 0.5
	body.lives_damage = 12
	body.aura_radius_tiles = 0.0
	body.speed_tiles = 0.5
	var shard: EnemyData = body.duplicate()
	shard.texture = SHARD
	shard.walk_atlas = SHARD_WALK
	shard.walk_stride_tiles = 0.55
	shard.visual_scale = 1.2
	shard.size_tiles = 0.3
	shard.lives_damage = 4
	shard.speed_tiles = 1.0
	var samples: Array[EnemyData] = [body, shard, preload("res://data/enemies/guardian.tres"), preload("res://data/enemies/boss.tres"), preload("res://data/enemies/tank.tres")]
	for index: int in samples.size():
		for row: int in 4:
			var path: Path2D = Path2D.new()
			path.curve = Curve2D.new()
			path.curve.add_point(Vector2.ZERO)
			path.curve.add_point(Vector2.from_angle(row * PI / 2) * 10000)
			game.add_child(path)
			var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
			enemy.setup(samples[index], path, samples[index].max_health)
			game.add_child(enemy)
			enemy.set_physics_process(false)
			enemy.z_index = 30
			var slot: Vector2 = Vector2(160 + index * 215, 230 + row * 105)
			enemy.position = slot
			actors.append(enemy)
			slots.append(slot)
		var name_label: Label = Label.new()
		name_label.text = ["Coloso", "Pedazo", "Guardián", "Soberano", "Tanque"][index]
		name_label.position = Vector2(115 + index * 215, 135)
		name_label.add_theme_constant_override("outline_size", 3)
		add_child(name_label)
	for step: int in 4:
		for index: int in actors.size():
			var actor: Enemy = actors[index]
			actor.distance = Rules.tiles_to_px(actor.data.walk_stride_tiles) * step / 4.0 + 0.001
			actor._physics_process(0.001)
			actor.position = slots[index]
		for frame: int in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		assert(get_viewport().get_texture().get_image().save_png(ROOT + "captures/game_step_%d.png" % step) == OK)
	get_tree().quit()
