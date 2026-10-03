## Estados reales en una instancia aislada; posiciones de muestra, no una estrategia jugada.
extends Node

func _ready() -> void:
	SaveManager.save_path = "user://test_m41_capture.json"
	SaveManager.load_save()
	DevMode.enabled = true
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(6)
	add_child(game)
	game.dev_enable_support(true)
	game.session.set_gold(210)
	var cannon: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
	cannon.setup(preload("res://data/towers/basic.tres"))
	cannon.position = Vector2(600,340)
	game.tower_container.add_child(cannon)
	cannon.apply_wear(40.0)
	cannon.set_physics_process(false)
	var support: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
	support.setup(preload("res://data/towers/mechanical_standard.tres"))
	support.position = Vector2(685,380)
	game.tower_container.add_child(support)
	support.set_physics_process(false)
	cannon._update_repair(1.0)
	(game.hud.get_node("TowerPanel") as TowerPanel).show_tower(cannon,35,210)
	var title := Label.new()
	title.text = "M41 · Desgaste reparable · Mecánico activo · Arte inicial revisable"
	title.position = Vector2(24,70)
	title.add_theme_font_size_override("font_size",22)
	add_child(title)
	game.spawner.spawn_now(preload("res://data/enemies/thief.tres"))
	game.spawner.spawn_now(preload("res://data/enemies/rammer.tres"))
	var thief: Enemy = game.get_node("Enemies").get_child(0)
	var rammer: Enemy = game.get_node("Enemies").get_child(1)
	thief.set_physics_process(false)
	rammer.set_physics_process(false)
	thief.position = Vector2(580,230)
	rammer.position = Vector2(820,230)
	rammer._charge_progress = Rules.tiles_to_px(4)
	game.hud.get_node("EnemyIntro").hide()
	await get_tree().create_timer(0.4).timeout
	thief._update_gold_drain(2.0)
	await get_tree().create_timer(0.1).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/mechanics-m41/desgaste_reparacion.png")
	(game.hud.get_node("TowerPanel") as TowerPanel).show_tower(support,84,game.session.gold)
	await get_tree().process_frame
	(game.hud.get_node("TowerPanel") as TowerPanel)._details.scroll_vertical = 500
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/mechanics-m41/panel_mecanico.png")
	game.hide()
	game.hud.hide()
	title.hide()
	GameFlow.editor_draft = LevelDraft.from_text(FileAccess.get_file_as_string("res://data/levels/level_07.json"))
	var editor: MapEditor = preload("res://scenes/editor/map_editor.tscn").instantiate()
	add_child(editor)
	editor.show_panel(editor.waves_panel(),true)
	editor.waves_panel().show_wave(6)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/mechanics-m41/editor_probabilidad.png")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
