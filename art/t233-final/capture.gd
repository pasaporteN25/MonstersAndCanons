# Muestras provisionales sobre una partida real; no modifica mapas de campaña.
extends Node

const SAMPLES: Array[Texture2D] = [preload("res://assets/sprites/map/supply_depot.svg"), preload("res://assets/sprites/map/supply_line_pole.svg"), preload("res://assets/sprites/map/supply_cart.svg"), preload("res://assets/sprites/map/supply_conveyor.svg"), preload("res://assets/sprites/map/hito.svg")]
const QUARTERS: Array[Texture2D] = [preload("res://assets/sprites/map/central_1.svg"), preload("res://assets/sprites/map/central_2.svg"), preload("res://assets/sprites/map/central_3.svg"), preload("res://assets/sprites/map/central_4.svg")]

func _ready() -> void:
	DevMode.set_enabled(true, "user://test_t233_capture.json")
	GameFlow.current_index = -1
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	game.level_data = GameFlow.level(0)
	add_child(game)
	await get_tree().process_frame
	var tray: Control = Control.new()
	tray.position = Vector2(18, 115)
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tray)
	var title: Label = Label.new()
	title.text = "T233 · PROVISIONAL · muestras sobre pradera, pendientes de integración en T234"
	title.add_theme_color_override("font_shadow_color", Color.BLACK)
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	tray.add_child(title)
	for i: int in 4:
		_icon(tray, QUARTERS[i], Vector2(i % 2 * 64, 40 + i / 2 * 64), Vector2(64, 64))
	for i: int in SAMPLES.size():
		_icon(tray, SAMPLES[i], Vector2(160 + i * 100, 76), Vector2(64, 64))
	await _save("game_samples")
	game.queue_free()
	tray.queue_free()
	await get_tree().process_frame
	var backdrop: TextureRect = TextureRect.new()
	backdrop.texture = preload("res://assets/sprites/story/epilogue.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var text: Label = Label.new()
	text.text = "La central se encendió al anochecer. La colonia tiene, por primera vez, luz propia.\nHay agua, energía y un camino de abastecimiento que une la mina con el valle.\nDel otro lado del paso, los fuegos de los Moradores se ven cada vez más lejos.\nEl resto de Cántaro sigue ahí."
	text.add_theme_font_size_override("font_size", 20)
	text.position = Vector2(40, 530)
	text.size = Vector2(1200, 170)
	add_child(text)
	var status: Label = Label.new()
	status.text = "T233 · MUESTRA DEL EPÍLOGO · PROVISIONAL (no es la pantalla integrada)"
	status.position = Vector2(30, 20)
	add_child(status)
	await _save("epilogue_preview")
	get_tree().quit()

func _icon(parent: Control, texture: Texture2D, position_value: Vector2, size_value: Vector2) -> void:
	var icon: TextureRect = TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = position_value
	icon.size = size_value
	parent.add_child(icon)

func _save(id: String) -> void:
	for frame: int in 5:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert(get_viewport().get_texture().get_image().save_png("res://art/t233-final/captures/%s.png" % id) == OK)
	print("T233 captura: ", id)
