# M43: hoja, movimiento de Enemy real, partida y Wiki con recursos integrados.
extends Node2D
const ROOT: String = "res://art/redesign-m43/"
const IDS: Array[String] = ["rammer","healer","thief"]
var actors: Array[Enemy] = []
var slots: Array[Vector2] = []
var overlay: Node2D

func label_(text_: String, at: Vector2, font_size: int = 18) -> void:
	var label: Label = Label.new()
	label.text = text_
	label.position = at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_constant_override("outline_size",3)
	overlay.add_child(label)

func icon_(textures: Array[Texture2D], at: Vector2, side: float) -> void:
	var icon: WikiIcon = WikiIcon.new().setup(textures,side)
	icon.position = at
	icon.size = Vector2.ONE * side
	overlay.add_child(icon)

func save_(file: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ROOT + file)

func _ready() -> void:
	DevMode.set_enabled(true,"user://test_m43_capture.json")
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(6)
	add_child(game)
	game.dev_enable_support(true)
	game.hud.get_node("EnemyIntro").hide()
	overlay = Node2D.new()
	add_child(overlay)
	overlay.z_index = 20
	label_("M43 · B31 · Siluetas, cuatro direcciones y movimiento",Vector2(24,80),24)
	label_("112px Wiki / 34px lectura pequeña · poses reales debajo",Vector2(24,112))
	for index: int in IDS.size():
		var data: EnemyData = load("res://data/enemies/" + IDS[index] + ".tres")
		var x: float = 70 + index * 290
		label_(data.display_name,Vector2(x,150),22)
		icon_([data.texture],Vector2(x,180),112)
		icon_([data.texture],Vector2(x + 140,220),34)
		for row: int in 4:
			var path: Path2D = Path2D.new()
			path.curve = Curve2D.new()
			path.curve.add_point(Vector2.ZERO)
			path.curve.add_point(Vector2.from_angle(row*PI/2)*10000)
			game.add_child(path)
			var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
			enemy.setup(data,path,data.max_health)
			game.add_child(enemy)
			enemy.set_physics_process(false)
			enemy.z_index = 30
			var slot: Vector2 = Vector2(x + 80,360 + row*85)
			enemy.position = slot
			actors.append(enemy)
			slots.append(slot)
	var support: TowerData = preload("res://data/towers/mechanical_standard.tres")
	label_("Mecánico / cañón",Vector2(940,150),22)
	icon_([support.levels[0].base_texture,support.turret_texture],Vector2(960,200),112)
	icon_([support.levels[0].base_texture,support.turret_texture],Vector2(1090,230),34)
	var cannon: TowerData = preload("res://data/towers/cannon.tres")
	icon_([cannon.levels[0].base_texture,cannon.turret_texture],Vector2(960,340),112)
	for index: int in 16:
		for actor_index: int in actors.size():
			actors[actor_index]._physics_process(0.1)
			actors[actor_index].position = slots[actor_index]
		await save_("motion_%02d.png" % index)
		if index == 5:
			await save_("direcciones.png")
	overlay.hide()
	for enemy: Enemy in actors:
		enemy.hide()
	for index: int in IDS.size():
		game.dev_spawn(load("res://data/enemies/" + IDS[index] + ".tres"))
		var enemy: Enemy = game.enemies.get_child(index)
		enemy.set_physics_process(false)
		enemy.position = Vector2(460 + index*120,235)
		if IDS[index] == "rammer":
			enemy._charge_progress = Rules.tiles_to_px(4)
	var tower: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
	tower.setup(support)
	tower.position = Vector2(620,440)
	game.tower_container.add_child(tower)
	tower.set_physics_process(false)
	var gun: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
	gun.setup(cannon)
	gun.position = Vector2(535,440)
	game.tower_container.add_child(gun)
	gun.set_physics_process(false)
	gun.apply_wear(30)
	gun._update_repair(0.5)
	await get_tree().process_frame
	game.hud.get_node("EnemyIntro").hide()
	await save_("partida.png")
	game.hide()
	game.hud.hide()
	var wiki: Control = preload("res://scenes/ui/wiki_screen.tscn").instantiate()
	add_child(wiki)
	wiki.set_anchors_preset(Control.PRESET_TOP_LEFT)
	wiki.size = get_viewport_rect().size
	wiki.show_category(&"enemigos")
	wiki.show_entry(&"healer")
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	await save_("wiki_curandero.png")
	wiki.show_category(&"torres")
	wiki.show_entry(&"mechanical_standard")
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	await save_("wiki_mecanico.png")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
