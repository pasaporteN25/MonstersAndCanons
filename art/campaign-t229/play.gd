# T229 a T232: partida de verificación con la escena REAL del juego en una ventana, sin el modo de pruebas:
# las torres se compran con clics y movimientos de mouse reales (los eventos entran por Input.parse_input_event,
# igual que un mouse), las oleadas empiezan con el botón «Empezar oleada» y se mira lo que ve el jugador (vidas, oro,
# la tarjeta de «Nuevo enemigo», el rayo del Chamán, el rebote del Espejo). No es el bot de balance: acá se juega
# un tramo del nivel y se sacan capturas.
#
#   godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=11 until=7 speed=6 out=art/campaign-t229
#
#   level=N   nivel de la campaña (11 a 14)         until=N   termina al completar esa oleada (por omisión, la última)
#   speed=X   velocidad del reloj del motor (x6)     out=ruta  carpeta de las capturas y del informe
#   full=1    con las colecciones completas (10 torres: suma la Disruptora y el Mecánico)
extends Node

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## El orden de compra del bot de balance para mapas sin Ametralladora (tools/balance_sim.gd, NO_BASIC_ORDER).
const ORDER: Array[String] = ["cannon", "frost", "cannon", "sniper", "cannon", "multi", "sniper", "tesla", "cannon",
	"burst", "sniper", "fire", "cannon", "frost", "tesla", "sniper", "burst", "multi"]

var level_number: int = 11
var until_wave: int = 0
var speed: float = 6.0
var out_dir: String = "res://art/campaign-t229"
var full: bool = false
var game: Game
var report: Dictionary = {"checks": [], "waves": [], "problems": []}
var _order_pos: int = 0
var _bad_cells: Dictionary = {}
var _shots: Dictionary = {}
var _seen_stun: bool = false
var _seen_intro: Dictionary = {}
var _seen_reflect: bool = false
var _stun_left_max: float = 0.0
var _debug_left: int = 3
var _watched_mirrors: Dictionary = {}
var _reflect_seen: bool = false
var _reflect_count: int = 0
var _pending_reflect_shot: bool = false


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"level": level_number = int(parts[1])
			"until": until_wave = int(parts[1])
			"speed": speed = float(parts[1])
			"out": out_dir = "res://" + parts[1]
			"full": full = parts[1] == "1"
	DevMode.enabled = false
	SaveManager.save_path = "user://play_t229_level_%d.json" % level_number
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.load_save()
	if full:
		for source: String in ["level_08", "level_09", "level_10"]:
			SaveManager.collect_source(&"disruptor", StringName(source))
		for source: String in (CollectibleRun.definitions()["technology"]["sources"] as Array):
			SaveManager.collect_source(&"technology", StringName(source))
	GameFlow.current_index = level_number - 1
	GameFlow.current_community = null
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child(game)
	await _frames(4)
	await _play()
	_finish()


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func _note(text: String) -> void:
	print("T229 ", text)
	(report["checks"] as Array).append(text)


func _problem(text: String) -> void:
	print("T229 PROBLEMA ", text)
	(report["problems"] as Array).append(text)


func _shot(name: String) -> void:
	if _shots.has(name):
		return
	_shots[name] = true
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/level_%d_%s.png" % [out_dir, level_number, name])


## Un movimiento y un clic reales del mouse en `pos` (coordenadas del juego, 1280 × 720).
func _click(pos: Vector2) -> void:
	var window_pos: Vector2 = get_viewport().get_final_transform() * pos
	# En una ventana real los movimientos sintéticos no cambian la posición del mouse que lee el juego
	# (get_global_mouse_position): manda el puntero del sistema. Por eso se lo mueve de verdad con warp_mouse,
	# igual que una mano; el clic (apretar y soltar) sí entra como evento.
	Input.warp_mouse(window_pos)
	await _frames(3)
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = window_pos
		click.global_position = window_pos
		Input.parse_input_event(click)
		await _frames(1)


func _screen_pos(cell: Vector2i) -> Vector2:
	return game.get_viewport().get_canvas_transform() * game.level.cell_center(cell)


func _path_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for entrance: int in game.level.entrance_count():
		var path: Path2D = game.level.get_ground_path(entrance)
		var length: float = path.curve.get_baked_length()
		var d: float = 0.0
		while d < length:
			points.append(path.to_global(path.curve.sample_baked(d)))
			d += 16.0
	return points


func _best_cell(tower: TowerData, points: Array[Vector2]) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_score: int = -1
	var range_px: float = Rules.tiles_to_px(tower.levels[0].range_tiles)
	var rows: int = game.level_data.map_rows.size()
	var cols: int = game.level_data.map_rows[0].length()
	for y: int in rows:
		for x: int in cols:
			var cell := Vector2i(x, y)
			if _bad_cells.has(cell) or not game.build_controller.cells_free(tower, cell):
				continue
			var center: Vector2 = game.level.cell_center(cell)
			var score: int = 0
			for point: Vector2 in points:
				if point.distance_to(center) <= range_px:
					score += 1
			if score > best_score:
				best_score = score
				best = cell
	return best


func _tower_index(id: String) -> int:
	for i: int in game.available_towers.size():
		if String(game.available_towers[i].id) == id:
			return i
	return -1


## Compra con clics reales todo lo que alcance, en el orden del bot: botón de la torre, después la casilla.
func _buy() -> void:
	var points: Array[Vector2] = _path_points()
	while not game.session.is_over():
		var id: String = ORDER[_order_pos % ORDER.size()]
		var index: int = _tower_index(id)
		if index < 0:
			_order_pos += 1
			continue
		var tower: TowerData = game.available_towers[index]
		if game.session.gold < tower.levels[0].cost:
			return
		var cell: Vector2i = _best_cell(tower, points)
		if cell.x < 0:
			return
		var before: int = game.tower_container.get_child_count()
		await _click(game.hud._tower_buttons[index].get_global_rect().get_center())
		if game.build_controller.selected_tower() != tower:
			_problem("el clic en el botón de %s no eligió la torre" % id)
			return
		await _click(_screen_pos(cell))
		if game.tower_container.get_child_count() == before:
			_bad_cells[cell] = true
			_problem("el clic en %s no construyó %s" % [cell, id])
			if _debug_left > 0:
				_debug_left -= 1
				print("T229 DEBUG ventana=%s final_transform=%s pantalla=%s mouse_global=%s cell_at_mouse=%s hover=%s oro=%d libre=%s" % [
					get_window().size, get_viewport().get_final_transform(), _screen_pos(cell), game.get_global_mouse_position(),
					game.level.cell_at(game.get_global_mouse_position()), game.build_controller._hover_cell, game.session.gold,
					game.build_controller.cells_free(tower, cell)])
			game.build_controller.cancel()
			continue
		_order_pos += 1


func _on_reflected(_mirror: Enemy, tower: Tower, first: bool) -> void:
	_reflect_count += 1
	if not _reflect_seen:
		_reflect_seen = true
		_note("oleada %d: el Espejo devolvió un tiro y la torre de %s quedó aturdida (primera vez: %s)" % [game.session.wave, tower.origin_cell, first])
		_pending_reflect_shot = true


func _watch() -> void:
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if enemy.data != null and enemy.data.id == &"mirror" and not _watched_mirrors.has(enemy.get_instance_id()):
			_watched_mirrors[enemy.get_instance_id()] = true
			enemy.reflected.connect(_on_reflected)
	if _pending_reflect_shot:
		_pending_reflect_shot = false
		await _shot("rebote")
	for node: Node in get_tree().get_nodes_in_group(Tower.GROUP):
		var tower := node as Tower
		_stun_left_max = maxf(_stun_left_max, tower.stun_left())
		if tower.is_stunned() and not _seen_stun:
			_seen_stun = true
			_note("oleada %d: una torre quedó aturdida (%.1f s) en %s" % [game.session.wave, tower.stun_left(), tower.origin_cell])
			await _shot("aturdida")
	if game.hud._intro.visible and game.hud._intro.modulate.a > 0.9:
		var title: String = game.hud._intro_name.text
		if not _seen_intro.has(title):
			_seen_intro[title] = game.session.wave
			_note("oleada %d: se ve la tarjeta «%s»" % [game.session.wave, title])
			await _shot("tarjeta_%d" % _seen_intro.size())


func _play() -> void:
	var total: int = game.level_data.waves.size()
	if until_wave <= 0 or until_wave > total:
		until_wave = total
	_note("nivel %d «%s»: %d oleadas, %d torres en la barra: %s" % [level_number, game.level_data.display_name, total,
		game.available_towers.size(), game.available_towers.map(func(t: TowerData) -> String: return String(t.id))])
	await _shot("inicio")
	await _buy()
	await _shot("apertura")
	var started: bool = false
	while not game.session.is_over() and game.session.wave < until_wave:
		await _buy()
		var wave_before: int = game.session.wave
		if not started:
			started = true
		await _click(game.hud._start_wave_button.get_global_rect().get_center())
		if game.session.wave == wave_before:
			_problem("el botón «Empezar oleada» no empezó la oleada %d" % (wave_before + 1))
			game.start_next_wave()
		Engine.time_scale = speed
		var frames: int = 0
		var mid_wave_buy: int = 0
		while game.session.state == LevelSession.State.WAVE_RUNNING and frames < 60 * 600:
			await get_tree().process_frame
			frames += 1
			await _watch()
			mid_wave_buy += 1
			if mid_wave_buy >= 90:
				mid_wave_buy = 0
				Engine.time_scale = 1.0
				await _buy()
				Engine.time_scale = speed
		Engine.time_scale = 1.0
		var info: Dictionary = {"wave": game.session.wave, "lives": game.session.lives, "gold": game.session.gold,
			"towers": game.tower_container.get_child_count(), "state": str(game.session.state)}
		(report["waves"] as Array).append(info)
		print("T229 ", JSON.stringify(info))
		if game.session.wave == 1 or game.session.wave == until_wave:
			await _shot("oleada_%d_fin" % game.session.wave)
	await _shot("final")


func _finish() -> void:
	Engine.time_scale = 1.0
	report["level"] = level_number
	report["speed"] = speed
	report["towers"] = game.available_towers.map(func(t: TowerData) -> String: return String(t.id))
	report["shaman_stun_seen"] = _seen_stun
	report["mirror_reflects_seen"] = _reflect_count
	report["max_stun_left"] = _stun_left_max
	report["intro_cards"] = _seen_intro
	report["lives_end"] = game.session.lives
	var file: FileAccess = FileAccess.open("%s/play_level_%d.json" % [out_dir, level_number], FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	print("T229_FIN ", JSON.stringify({"problems": report["problems"], "lives": game.session.lives}))
	get_tree().quit()
