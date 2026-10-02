# Hoja de contacto de los cinco especiales, cuerpo grande y lectura a 34 px.
extends Node2D
const ROOT: String = "res://art/redesign-m27/"
const NAMES: Array[String] = ["guardian", "healer", "shaman", "mirror", "boss"]
const TITLES: Array[String] = ["Guardián · protección", "Curandero · bulbo vital", "Chamán · interrupción", "Espejo · caparazón reflectante", "Jefe · soberano cornudo"]
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#182431"))
	for index: int in NAMES.size():
		var origin := Vector2(10 + (index % 3) * 425, 10 + (index / 3) * 350)
		var panel := Polygon2D.new()
		panel.polygon = PackedVector2Array([origin, origin + Vector2(405, 0), origin + Vector2(405, 335), origin + Vector2(0, 335)])
		panel.color = Color("#293e50")
		add_child(panel)
		var label := Label.new()
		label.text = TITLES[index]
		label.position = origin + Vector2(14, 10)
		add_child(label)
		var texture: Texture2D = ImageTexture.create_from_image(Image.load_from_file(ROOT + "monsters/" + NAMES[index] + ".png"))
		var large := Sprite2D.new()
		large.texture = texture
		large.position = origin + Vector2(202, 155)
		large.scale = Vector2.ONE * 1.2
		add_child(large)
		var strip := Polygon2D.new()
		strip.polygon = PackedVector2Array([origin + Vector2(10, 275), origin + Vector2(395, 275), origin + Vector2(395, 325), origin + Vector2(10, 325)])
		strip.color = Color("#75a64e")
		add_child(strip)
		for copy_: int in 5:
			var small := Sprite2D.new()
			small.texture = texture
			small.position = origin + Vector2(60 + copy_ * 70, 297)
			small.scale = Vector2.ONE * 34.0 / 162.0
			add_child(small)
	await get_tree().create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ROOT + "previews/special_monsters.png")
	get_tree().quit()
