extends SceneTree

const IDS: PackedStringArray = ["stat_resources", "coleccion_disruptor", "demoledora"]

func _initialize() -> void:
	_render_sheet(220, "res://art/t221-iconos/hoja_220.png")
	_render_sheet(34, "res://art/t221-iconos/hoja_34.png")
	quit()

func _render_sheet(sprite_size: int, output: String) -> void:
	var margin: int = 12
	var tile_w: int = sprite_size + margin * 2
	var tile_h: int = sprite_size + margin * 2
	var image := Image.create(tile_w * IDS.size(), tile_h, false, Image.FORMAT_RGBA8)
	image.fill(Color("#20232b"))
	for col: int in IDS.size():
		var texture: Texture2D = load("res://assets/sprites/ui/%s.svg" % IDS[col])
		if texture == null:
			push_error("Falta textura para %s" % IDS[col])
			continue
		var source: Image = texture.get_image()
		source.resize(sprite_size, sprite_size, Image.INTERPOLATE_LANCZOS)
		image.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i(col * tile_w + margin, margin))
	var absolute: String = ProjectSettings.globalize_path(output)
	var error: Error = image.save_png(absolute)
	if error != OK:
		push_error("No se pudo guardar %s: %s" % [absolute, error_string(error)])
	else:
		print("Hoja %d px guardada: %s" % [sprite_size, absolute])
