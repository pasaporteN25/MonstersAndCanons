# Muestras aisladas; no cambian escenas ni datos de producción.
extends Node2D
const FRAMER: Script = preload("res://tools/prepare_monster_sprites.gd")
const ROOT: String = "res://art/redesign-m28/"
const IDS: Array[String] = ["normal", "fast", "tank", "armored", "troll", "flyer", "spider", "spiderling", "guardian", "healer", "shaman", "mirror", "boss"]
const TITLES: Array[String] = ["Normal", "Rápido", "Tanque", "Blindado", "Troll", "Volador", "Araña", "Cría", "Guardián", "Curandero", "Chamán", "Espejo", "Jefe"]
var _data: Array[EnemyData] = []
var _new: Array[Texture2D] = []
var _walks: Dictionary = {}
var _towers: Array[TowerData] = []
var _flyer: Texture2D
var _concept: Texture2D
var _time: float = 0.0
var _mode: String = "sizes"

func _ready() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--sample="):
			_mode = argument.trim_prefix("--sample=")
	RenderingServer.set_default_clear_color(Color("#182431"))
	for id: String in IDS:
		var data: EnemyData = load("res://data/enemies/" + id + ".tres")
		_data.append(data)
		var path: String = "res://art/redesign-m26/monsters/" + id + ".png"
		_new.append(ImageTexture.create_from_image(Image.load_from_file(path)) if FileAccess.file_exists(path) else data.texture)
	for id: String in ["normal", "fast", "tank"]:
		_walks[id] = ImageTexture.create_from_image(Image.load_from_file("res://art/redesign-m25/atlases/" + id + "_walk.png"))
	for id: String in ["cannon", "basic", "frost"]:
		_towers.append(load("res://data/towers/" + id + ".tres"))
	if FileAccess.file_exists(ROOT + "sources/flyer_flap_normalized.png"):
		_flyer = ImageTexture.create_from_image(Image.load_from_file(ROOT + "sources/flyer_flap_normalized.png"))
	if FileAccess.file_exists(ROOT + "sources/cannon_mount_concepts.png"):
		var image: Image = Image.load_from_file(ROOT + "sources/cannon_mount_concepts.png")
		_concept = ImageTexture.create_from_image(image.get_region(FRAMER.body_rect(image)))
	call_deferred("capture")

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _text(point: Vector2, value: String, size_: int = 19, color: Color = Color.WHITE) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_, color)

func _draw() -> void:
	if _data.is_empty():
		return
	if _mode == "sizes":
		_draw_sizes()
	elif _mode == "concepts":
		_text(Vector2(24, 34), "M28 · Soportes integrados: dos conceptos", 26)
		_text(Vector2(45, 105), "B · aro giratorio bajo y asiento de madera", 21)
		_text(Vector2(660, 105), "C · abrazaderas y soporte integrado", 21)
		if _concept != null:
			var size_: Vector2 = _concept.get_size()
			var factor: float = minf(1220.0 / size_.x, 530.0 / size_.y)
			var display_size: Vector2 = size_ * factor
			draw_texture_rect(_concept, Rect2(Vector2(640 - display_size.x / 2.0, 145), display_size), false)
	elif _mode == "mounts":
		_draw_mounts()
	else:
		_draw_motion()

func _lane(y: float) -> void:
	var texture: Texture2D = MapThemes.PATH_TEXTURE
	for x: int in 20:
		draw_texture_rect(texture, Rect2(x * 64, y, 64, 90), false)

func _draw_sizes() -> void:
	_text(Vector2(24, 34), "M28 · Migración y tamaño visual", 26)
	_text(Vector2(24, 64), "Muestras para aprobar · colisiones y balance sin cambios · todos los diseños físicos disponibles", 18, Color("#adc1ce"))
	for row: int in 3:
		var y: float = 175 + row * 180
		_text(Vector2(24, y - 60), ["ACTUAL · mezcla de SVG y PNG", "A · arte nuevo, +20 % de cuerpo", "B · arte nuevo, +35 % de cuerpo"][row], 21)
		_lane(y - 40)
		for index: int in IDS.size():
			var point := Vector2(45 + index * 97, y + 12)
			var radius: float = Rules.tiles_to_px(_data[index].size_tiles)
			var factor: float = [1.0, 1.2, 1.35][row]
			draw_set_transform(point + Vector2(0, radius * 0.55), 0.0, Vector2(1, 0.45))
			draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.25))
			draw_set_transform(point)
			EnemyShape.draw_sprite(self, _data[index].texture if row == 0 else _new[index], radius * factor)
			draw_set_transform(Vector2.ZERO)
			_text(Vector2(point.x - 36, y + 72), TITLES[index], 15)

func _draw_mounts() -> void:
	_text(Vector2(24, 34), "M28 · Contacto entre torreta y base", 26)
	_text(Vector2(24, 64), "Ajuste de montaje sobre el arte actual · E, SE y N · ampliado para revisar", 18, Color("#adc1ce"))
	var names: Array[String] = ["cannon", "basic", "frost"]
	for row: int in 2:
		var y: float = 230 + row * 285
		_text(Vector2(24, y - 100), "ACTUAL" if row == 0 else "A · mecanismo elevado 8 px + contacto sobre el aro", 21)
		for index: int in 3:
			var data: TowerData = _towers[index]
			for direction: int in 3:
				var point := Vector2(100 + index * 425 + direction * 125, y)
				var rect := Rect2(point - Vector2(60, 60), Vector2(120, 120))
				draw_texture_rect(data.levels[0].base_texture, rect, false)
				if row == 1:
					draw_set_transform(point + Vector2(0, -8), 0.0, Vector2(1.0, 0.45))
					draw_circle(Vector2.ZERO, 27.0, Color(0.05, 0.04, 0.03, 0.32))
					draw_set_transform(Vector2.ZERO)
				var angle: float = [0.0, PI / 4.0, -PI / 2.0][direction]
				var shift: Vector2 = Vector2(0, -15) if row == 1 else Vector2.ZERO
				draw_texture_rect_region(data.turret_atlas, Rect2(rect.position + shift, rect.size), TowerVisual.frame_rect(data.turret_atlas, angle))
			_text(Vector2(45 + index * 425, y + 110), ["Cañón", "Básica", "Hielo"][index], 20)

func _draw_motion() -> void:
	_text(Vector2(24, 34), "M28 · Movimiento: cuerpo elástico vs pasos", 26)
	_text(Vector2(24, 64), "Ciclo M25, escala visual +20 %, pies estables; reproducción lenta para revisar", 18, Color("#adc1ce"))
	for row: int in 2:
		var y: float = 205 + row * 215
		_text(Vector2(24, y - 75), "ACTUAL · deformación del cuerpo 8 %" if row == 0 else "A · ciclo de patas, sin deformar el cuerpo entero", 20)
		_lane(y - 40)
		for index: int in 3:
			var data: EnemyData = _data[index]
			var speed: float = Rules.tiles_to_px(data.speed_tiles)
			var phase: float = _time * speed
			var point := Vector2(80 + index * 420 + fmod(phase * 0.5, 300.0), y + 10)
			var radius: float = Rules.tiles_to_px(data.size_tiles)
			draw_set_transform(point + Vector2(0, radius * 0.55), 0.0, Vector2(1, 0.45))
			draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.25))
			var wave: float = sin(_time * TAU * data.speed_tiles * 1.2)
			if row == 0:
				draw_set_transform(point + Vector2(0, -absf(wave) * 2.0), 0.0, Vector2(1 + 0.08 * wave, 1 - 0.08 * wave))
				EnemyShape.draw_sprite(self, data.texture, radius)
			else:
				draw_set_transform(point)
				var step: int = int(phase / 12.0) % 4
				var side: float = radius * EnemyShape.SPRITE_SCALE * 1.2
				draw_texture_rect_region(_walks[IDS[index]], Rect2(-side / 2.0, -side / 2.0 - side / 32.0, side, side), Rect2(step * 256, 0, 256, 256))
			draw_set_transform(Vector2.ZERO)
			_text(Vector2(45 + index * 420, y + 85), TITLES[index], 18)
	var flyer_path: String = ROOT + "sources/flyer_flap_normalized.png"
	if _flyer != null:
		_text(Vector2(24, 585), "Vuelo · ciclo de alas exploratorio", 20)
		var flyer: Texture2D = _flyer
		var step: int = int(_time * 6.0) % 4
		var cell: Vector2 = flyer.get_size() / 2.0
		draw_texture_rect_region(flyer, Rect2(610, 590, 110, 110), Rect2(Vector2(step % 2, step / 2) * cell, cell))

func capture() -> void:
	set_process(false)
	var count: int = 24 if _mode == "motion" else 1
	for index: int in count:
		_time = index / 12.0
		queue_redraw()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ROOT + ("frames/motion_%02d.png" % index if _mode == "motion" else "previews/" + _mode + ".png"))
	get_tree().quit()
