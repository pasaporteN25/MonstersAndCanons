# Visor aislado: no altera Enemy ni los datos del juego.
extends Node2D

const NAMES: Array[String] = ["normal", "fast", "tank"]
const TITLES: Array[String] = ["Diablillo rojo", "Bestia turquesa", "Ogro de piedra"]
const DIRECTIONS: Array[String] = ["Este", "Sur", "Oeste", "Norte"]
var textures: Array[Texture2D] = []
var clock_: float = 0.0

func _ready() -> void:
	for id: String in NAMES:
		textures.append(ImageTexture.create_from_image(Image.load_from_file("res://art/redesign-m25/atlases/" + id + "_walk.png")))
	call_deferred("capture")

func _process(delta: float) -> void:
	clock_ += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("172331"))
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(35, 38), "M25 · Caminar en cuatro direcciones", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
	draw_string(font, Vector2(35, 67), "Visor de atlas · ampliado y a tamaño de partida · no integrado todavía", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("aabccc"))
	for col: int in 3:
		draw_string(font, Vector2(200 + col * 340, 108), TITLES[col], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
		var seconds: float = 0.1 if col == 0 else (0.08 if col == 1 else 0.18)
		var frame: int = int(clock_ / seconds) % 4
		for row: int in 4:
			var y: float = 130 + row * 140
			draw_string(font, Vector2(35, y + 70), DIRECTIONS[row], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
			var rect: Rect2 = Rect2(170 + col * 340, y, 310, 130)
			draw_rect(rect, Color("293d50"))
			var region: Rect2 = Rect2(frame * 256, row * 256, 256, 256)
			draw_texture_rect_region(textures[col], Rect2(rect.position + Vector2(10, 0), Vector2(128, 128)), region)
			var size_: float = [45.0, 36.0, 63.0][col]
			draw_rect(Rect2(rect.position + Vector2(180, 25), Vector2(95, 85)), Color("73a650"))
			draw_texture_rect_region(textures[col], Rect2(rect.position + Vector2(227 - size_ / 2, 105 - size_ * 191 / 256), Vector2.ONE * size_), region)

func capture() -> void:
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m25/walks_godot.png")
	if "--capture" in OS.get_cmdline_user_args():
		get_tree().quit()
