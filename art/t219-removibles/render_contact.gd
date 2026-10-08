extends SceneTree

const IDS: PackedStringArray = [
	"arbol_removible", "arbol_removible_trabajo", "roca_removible", "roca_removible_trabajo",
	"escombro", "escombro_trabajo", "marca_pieza", "despejado_pradera", "despejado_bosque",
	"despejado_ruinas", "despejado_desierto",
]
const GROUNDS: Array[Color] = [Color("#8baf60"), Color("#59794b"), Color("#777365")]

func _initialize() -> void:
	_render_sheet(220, "res://art/t219-removibles/hoja_220.png")
	_render_sheet(34, "res://art/t219-removibles/hoja_34.png")
	quit()

func _render_sheet(sprite_size: int, output: String) -> void:
	var margin: int = 10
	var tile_w: int = sprite_size + margin * 2
	var tile_h: int = sprite_size + margin * 2
	var image := Image.create(tile_w * IDS.size(), tile_h * GROUNDS.size(), false, Image.FORMAT_RGBA8)
	image.fill(Color("#24242b"))
	for row: int in GROUNDS.size():
		for col: int in IDS.size():
			var texture: Texture2D = load("res://assets/sprites/map/%s.svg" % IDS[col])
			if texture == null:
				push_error("Falta textura para %s" % IDS[col])
				continue
			var source: Image = texture.get_image()
			source.resize(sprite_size, sprite_size, Image.INTERPOLATE_LANCZOS)
			var x: int = col * tile_w + margin
			var y: int = row * tile_h + margin
			image.fill_rect(Rect2i(col * tile_w, row * tile_h, tile_w, tile_h), GROUNDS[row])
			image.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i(x, y))
	var absolute: String = ProjectSettings.globalize_path(output)
	var error: Error = image.save_png(absolute)
	if error != OK:
		push_error("No se pudo guardar %s: %s" % [absolute, error_string(error)])
	else:
		print("Hoja %d px guardada: %s" % [sprite_size, absolute])
