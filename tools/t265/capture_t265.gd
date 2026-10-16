extends Node

const LEVEL_SELECT_PATH: String = "res://scenes/ui/level_select.tscn"
const OUTPUT_DIR: String = "res://art/t265-torres-en-tarjetas/"
const CARD_SIZE := Vector2(200, 214)
const ICON_COLUMNS: int = 8
const CONTENT_LEFT: float = 6.0
const CONTENT_WIDTH: float = CARD_SIZE.x - CONTENT_LEFT * 2.0
const STYLE_NAMES: Array[String] = ["arsenal", "insignias", "inventario"]

var _select: Control
var _cards: HFlowContainer
var _scroll: ScrollContainer
var _capture_size: Vector2i = Vector2i(1280, 720)
var _save_manager: Node
var _original_save_path: String


func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("window="):
			var dimensions: PackedStringArray = argument.trim_prefix("window=").split("x")
			if dimensions.size() == 2:
				_capture_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	DisplayServer.window_set_size(_capture_size)
	call_deferred("_capture_all")


func _capture_all() -> void:
	# La escena real se carga dinámicamente para que esta herramienta compile con --check-only.
	var packed: PackedScene = load(LEVEL_SELECT_PATH)
	_select = packed.instantiate() as Control
	get_tree().root.add_child(_select)
	get_tree().current_scene = _select
	_cards = _select.get_node("%Cards") as HFlowContainer
	_scroll = _select.get_node("%Scroll") as ScrollContainer
	_prepare_isolated_save()
	for frame: int in 10:
		await get_tree().process_frame
	await _save_pair("before", 0, 0, "actual")
	await _save_pair("before", 11, 1, "actual")
	for style: int in STYLE_NAMES.size():
		_reset_cards(style)
		for frame: int in 4:
			await get_tree().process_frame
		await _save_pair("after/" + STYLE_NAMES[style], 0, 0, STYLE_NAMES[style])
		await _save_pair("after/" + STYLE_NAMES[style], 11, 1, STYLE_NAMES[style])
	_restore_save()
	_select.queue_free()
	await get_tree().process_frame
	get_tree().quit()


func _prepare_isolated_save() -> void:
	_save_manager = get_node("/root/SaveManager")
	_original_save_path = String(_save_manager.get("save_path"))
	_save_manager.set("save_path", "user://test_t265_capture.json")
	_save_manager.call("load_save")
	var level: Object = get_node("/root/GameFlow").call("level", 11)
	_save_manager.call("unlock", level.get("id"))
	_save_manager.call("record_victory", level.get("id"), 15)
	_select.call("show_page", StringName("campaign"))


func _restore_save() -> void:
	_save_manager.set("save_path", _original_save_path)
	_save_manager.call("load_save")
	var test_save: String = ProjectSettings.globalize_path("user://test_t265_capture.json")
	if FileAccess.file_exists(test_save):
		DirAccess.remove_absolute(test_save)


func _save_pair(folder: String, index: int, scroll_row: int, label: String) -> void:
	_scroll.scroll_vertical = 0 if scroll_row == 0 else int(_scroll.get_v_scroll_bar().max_value)
	for frame: int in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = _select.get_viewport().get_texture().get_image()
	var suffix: String = "nivel_%02d_1280x720_%s.png" % [index + 1, label]
	var path: String = OUTPUT_DIR + folder + "/" + suffix
	if _capture_size.x == 1600:
		suffix = "nivel_%02d_20x9_%s.png" % [index + 1, label]
		path = OUTPUT_DIR + folder + "/" + suffix
	var frame_size := image.get_size()
	var aspect: float = float(_capture_size.x) / float(_capture_size.y)
	if aspect > float(image.get_width()) / float(image.get_height()) + 0.01:
		frame_size.x = roundi(float(image.get_height()) * aspect)
	elif aspect < float(image.get_width()) / float(image.get_height()) - 0.01:
		frame_size.y = roundi(float(image.get_width()) / aspect)
	var framed := Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	framed.fill(Color.BLACK)
	framed.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (frame_size - image.get_size()) / 2)
	var absolute: String = ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var result: Error = framed.save_png(absolute)
	print("T265 captura: ", path, " ", framed.get_size(), " error=", result)


func _reset_cards(style: int) -> void:
	for index: int in _cards.get_child_count():
		var card: Button = _cards.get_child(index) as Button
		var row: Control = card.get_node_or_null("TowerIcons") as Control
		if row == null:
			continue
		for child: Node in card.get_children():
			if child.name.begins_with("T265"):
				card.remove_child(child)
				child.free()
		row.visible = true
		var rows: int = maxi(ceili(float(row.get_child_count()) / ICON_COLUMNS), 1)
		var icon_size: float = minf(22.0, 44.0 / float(rows))
		row.position = Vector2(CONTENT_LEFT, 89.0 + (44.0 - float(rows) * icon_size) / 2.0)
		row.size = Vector2(CONTENT_WIDTH, float(rows) * icon_size)
		for icon: Control in row.get_children():
			icon.custom_minimum_size = Vector2(icon_size, icon_size)
			icon.size = Vector2(icon_size, icon_size)
			icon.position = Vector2.ZERO
			for child: Node in icon.get_children():
				if child.name == "NewMark" or child.name == "T265NewMark":
					icon.set_meta("t265_is_new", true)
				child.queue_free()
			if style >= 0:
				_apply_icon_style(icon, style)
		if style >= 0:
			_apply_card_style(card, row, style)


func _apply_card_style(card: Button, row: Control, style: int) -> void:
	var count: int = row.get_child_count()
	var columns: int = 6 if style == 2 else ICON_COLUMNS
	var rows: int = maxi(ceili(float(count) / columns), 1)
	var panel := Panel.new()
	panel.name = "T265Plate"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(8, 87)
	panel.size = Vector2(CARD_SIZE.x - 16, 58 if style == 2 else 49)
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color("#292b37") if style != 1 else Color("#322c2b")
	style_box.border_color = Color("#6f614d") if style != 1 else Color("#92714a")
	style_box.set_border_width_all(1)
	style_box.set_corner_radius_all(5 if style != 2 else 12)
	style_box.content_margin_left = 2
	style_box.content_margin_right = 2
	style_box.content_margin_top = 2
	style_box.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", style_box)
	card.add_child(panel)
	card.move_child(panel, 0)
	var heading := Label.new()
	heading.name = "T265Heading"
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.add_theme_font_size_override("font_size", 11)
	heading.add_theme_color_override("font_color", Color("#e8bc72"))
	heading.text = "ARSENAL  ·  %02d" % count if style == 0 else ("INSIGNIAS  ·  %02d" % count if style == 1 else "INVENTARIO  ·  %02d" % count)
	heading.position = Vector2(12, 88)
	heading.size = Vector2(CARD_SIZE.x - 24, 12)
	card.add_child(heading)
	row.add_theme_constant_override("h_separation", 8 if style == 2 else 0)
	row.add_theme_constant_override("v_separation", 2 if style == 2 else 0)
	row.position = Vector2(10, 99 if style == 2 else 101)
	row.size = Vector2(CARD_SIZE.x - 20, 44 if style == 2 else (34 if rows == 2 else 25))
	var icon_size: float = 20.0 if style == 2 else minf(22.0, row.size.y / float(rows))
	for i: int in row.get_child_count():
		var icon: Control = row.get_child(i) as Control
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size = Vector2(icon_size, icon_size)


func _apply_icon_style(icon: Control, style: int) -> void:
	var panel := Panel.new()
	panel.name = "T265IconFrame"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0, 0, 0, 0)
	frame.border_color = Color("#887654") if style == 0 else (Color("#c28d4d") if style == 1 else Color("#6e8a9b"))
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(3 if style != 1 else 12)
	panel.add_theme_stylebox_override("panel", frame)
	icon.add_child(panel)
	icon.move_child(panel, 0)
	if icon.has_meta("t265_is_new") and icon.get_meta("t265_is_new"):
		var new_mark := Panel.new()
		new_mark.name = "T265NewMark"
		new_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		new_mark.position = Vector2(0, 0)
		new_mark.size = Vector2(5, 5)
		var mark_style := StyleBoxFlat.new()
		mark_style.bg_color = Color("#f0a44c")
		mark_style.set_corner_radius_all(2)
		new_mark.add_theme_stylebox_override("panel", mark_style)
		icon.add_child(new_mark)
	icon.position = Vector2.ZERO
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Un margen deja respirar el render de cada torre dentro del marco.
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
