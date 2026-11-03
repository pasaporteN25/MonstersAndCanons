# El fondo de la presentación del jefe (RF-666, RF-738): color teñido, ilustración de fondo (si el jefe la tiene)
# y la franja oscura detrás del texto. Llena el rectángulo de su padre, así que sirve igual dentro del marco
# lógico de 1280 × 720 y en la superficie física completa del anfitrión: en el celular se dibuja en los dos
# sitios con la misma geometría y no se nota dónde termina el marco (T571).
class_name BossBackdrop
extends Control


## `art`: null = solo el color liso. `tint`: el color del jefe (`EnemyData.color`).
func setup(tint: Color, art: Texture2D) -> BossBackdrop:
	name = "BackdropLayer"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base := ColorRect.new()
	base.name = "Backdrop"
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.color = Color(0.05, 0.04, 0.06).lerp(tint, 0.18)
	add_child(base)
	if art != null:
		var picture := TextureRect.new()
		picture.name = "BackdropArt"
		picture.set_anchors_preset(Control.PRESET_FULL_RECT)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		picture.texture = art
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(picture)
		_add_text_shade()
	return self


## T548: una franja que se oscurece hacia abajo detrás del texto (color, alto y opacidad: `data/ui/boss_presentation.json`).
func _add_text_shade() -> void:
	var shade: Dictionary = BossPresentationArt.shade()
	var opacity: float = shade["opacidad"]
	var height: float = shade["alto"]
	if opacity <= 0.0 or height <= 0.0:
		return
	var color: Color = shade["color"]
	var gradient := Gradient.new()
	gradient.set_color(0, Color(color, 0.0))
	gradient.set_color(1, Color(color, opacity))
	gradient.add_point(0.55, Color(color, opacity * 0.6))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	texture.width = 4
	texture.height = 256
	var rect := TextureRect.new()
	rect.name = "TextShade"
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.anchor_left = 0.0
	rect.anchor_right = 1.0
	rect.anchor_top = 1.0 - height
	rect.anchor_bottom = 1.0
	rect.offset_left = 0.0
	rect.offset_right = 0.0
	rect.offset_top = 0.0
	rect.offset_bottom = 0.0
	add_child(rect)
