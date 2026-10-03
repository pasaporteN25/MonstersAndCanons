# Muestras iniciales del apoyo fijo; no escriben el progreso real.
extends Node
func _ready() -> void:
	SaveManager.save_path = "user://test_m37_capture.json"
	SaveManager.load_save()
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(6)
	add_child(game)
	game.hud.hide()
	var title := Label.new()
	title.text = "Estandarte mecánico · Apoyo inicial · Reparación en etapa posterior"
	title.position = Vector2(35,8)
	title.add_theme_font_size_override("font_size",24)
	add_child(title)
	for i: int in 3:
		var support: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
		support.setup(preload("res://data/towers/mechanical_standard.tres"))
		game.tower_container.add_child(support)
		support.position = Vector2(220+i*410,280)
		for level: int in i:
			support.apply_upgrade()
		var label := Label.new()
		label.text = "Nivel%d · +%d%% · radio%.1f" % [i+1,support.stats().support_rate_percent,support.stats().range_tiles]
		label.position = support.position + Vector2(-110,70)
		add_child(label)
		var cannon: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
		cannon.setup(preload("res://data/towers/basic.tres"))
		game.tower_container.add_child(cannon)
		cannon.position = support.position + Vector2(0,-90)
		cannon.set_physics_process(false)
	var icon := TextureRect.new()
	icon.texture = preload("res://assets/ui/technology_token.svg")
	icon.position = Vector2(100,490)
	icon.size = Vector2(100,100)
	add_child(icon)
	var text := Label.new()
	text.position = Vector2(230,520)
	text.text = "Avance tecnológico genérico · 1 por nivel1–5 · 5 fuentes distintas"
	text.add_theme_font_size_override("font_size",22)
	add_child(text)
	await get_tree().create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/progression-m37/estandarte.png")
	game.hud.show()
	DevMode.enabled = true
	game.dev_enable_support(true)
	game._add_dev_panel()
	game.dev_panel.visible = true
	await get_tree().create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/progression-m37/admin.png")
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	get_tree().quit()
