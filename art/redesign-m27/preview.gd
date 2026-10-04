# Visor artístico: no cambia los recursos de producción.
extends Node2D

const ROOT: String = "res://art/redesign-m27/"
const NAMES: Array[String] = ["cannon", "basic", "multi", "sniper", "burst", "fire", "mortar", "frost", "tesla"]
const TITLES: Array[String] = ["Cañón", "Básica", "Múltiple", "Francotirador", "Ráfaga", "Fuego", "Mortero", "Hielo", "Tesla"]
var _sprites: Array[Sprite2D] = []
var _elapsed: float = 0.0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#202330"))
	for index: int in NAMES.size():
		var origin := Vector2(10 + (index % 3) * 425, 15 + (index / 3) * 225)
		var title := Label.new()
		title.text = TITLES[index] + " · niveles 1 / 2 / 3"
		title.position = origin
		add_child(title)
		for level: int in 3:
			var path: String = "res://assets/sprites/towers/rendered/" + NAMES[index] + "_atlas.png" if level == 0 else ROOT + "atlases/" + NAMES[index] + "_level_" + str(level + 1) + ".png"
			var image: Image = Image.load_from_file(path)
			if image == null:
				continue
			var sprite := Sprite2D.new()
			sprite.texture = ImageTexture.create_from_image(image)
			sprite.hframes = 4
			sprite.vframes = 2
			sprite.position = origin + Vector2(68 + level * 132, 118)
			add_child(sprite)
			_sprites.append(sprite)
	if OS.get_cmdline_user_args().has("--capture"):
		await get_tree().create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ROOT + "previews/evolutions_godot.png")
		get_tree().quit()

func _process(delta: float) -> void:
	_elapsed += delta
	var direction: int = int(_elapsed / 0.7) % 8
	for sprite: Sprite2D in _sprites:
		sprite.frame = direction
