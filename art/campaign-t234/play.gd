# T234: partida de verificación del nivel 15 con la escena REAL del juego en una ventana, sin el modo de pruebas.
# Mismo método que art/campaign-t229/play.gd: las torres se compran con clics y movimientos de mouse reales (los
# eventos entran por Input.parse_input_event y el puntero se mueve con warp_mouse), las oleadas empiezan con el botón
# «Empezar oleada» y se saca una captura de lo que ve el jugador: el cartel de entrada, el mapa con la central, la
# tarjeta del Coloso, el Coloso partiéndose en Pedazos, la victoria con «Epílogo», el epílogo y los créditos.
#
#   godot --path . --resolution 1280x720 art/campaign-t234/play.tscn -- speed=6 out=art/campaign-t234
#
#   speed=X   velocidad del reloj del motor (x6)     out=ruta  carpeta de las capturas y del informe
#   until=N   termina al completar esa oleada (por omisión, la última: 30)
#   skip=N    NO se juegan las oleadas 1 a N: se dan 9000 de oro de ayuda, se compra la defensa con clics reales y se
#             dan por completadas con la propia sesión (begin_wave + complete_wave), igual que hacen los tests. Sirve
#             para llegar al final (26 a 30) sin depender de que esta partida simple sobreviva a la oleada 19. Lo que
#             sale en el informe como «ayuda de verificación» no es una partida jugada.
extends Node

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## El orden de compra del bot de balance para mapas sin Ametralladora (tools/balance_sim.gd, NO_BASIC_ORDER).
const ORDER: Array[String] = ["cannon", "frost", "cannon", "sniper", "cannon", "multi", "sniper", "tesla", "cannon",
	"burst", "sniper", "fire", "cannon", "frost", "tesla", "sniper", "burst", "multi"]

var level_number: int = 15
var until_wave: int = 0
var speed: float = 6.0
var skip_waves: int = 0
var out_dir: String = "res://art/campaign-t234"
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
var _colossus_seen_wave: int = 0
var _shards_seen_max: int = 0
var _shards_noted: bool = false


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"level": level_number = int(parts[1])
			"until": until_wave = int(parts[1])
			"skip": skip_waves = int(parts[1])
			"speed": speed = float(parts[1])
			"out": out_dir = "res://" + parts[1]
			"full": full = parts[1] == "1"
	DevMode.enabled = false
	SaveManager.save_path = "user://play_t234_level_%d.json" % level_number
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.load_save()
	if full:
		for source: String in ["level_08", "level_09", "level_10"]:
			SaveManager.collect_source(&"disruptor", StringName(source))
		for source: String in (CollectibleRun.definitions()["technology"]["sources"] as Array):
			SaveManager.collect_source(&"technology", StringName(source))
	# La campaña llega al 15: los niveles 1 a 14 figuran ganados (así «terminada» se deduce al ganar el 15, RF-471).
	for i: int in level_number - 1:
		SaveManager.record_victory(GameFlow.level(i).id, 12, 1000)
	GameFlow.current_index = level_number - 1
	GameFlow.current_community = null
	GameFlow.intro_pending = true  # como si se hubiera elegido el nivel en la selección: sale el cartel de entrada
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
	print("T234 ", text)
	(report["checks"] as Array).append(text)


func _problem(text: String) -> void:
	print("T234 PROBLEMA ", text)
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
				print("T234 DEBUG ventana=%s final_transform=%s pantalla=%s mouse_global=%s cell_at_mouse=%s hover=%s oro=%d libre=%s" % [
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
	var colossi: Array[Enemy] = []
	var shards: Array[Enemy] = []
	for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
		var enemy := node as Enemy
		if enemy.data == null or not enemy.is_active():
			continue
		if enemy.data.id == &"colossus":
			colossi.append(enemy)
		elif enemy.data.id == &"colossus_shard":
			shards.append(enemy)
	if not colossi.is_empty():
		_colossus_seen_wave = maxi(_colossus_seen_wave, game.session.wave)
		var hurt: Enemy = colossi[0]
		if hurt.health < hurt.max_health and hurt.distance > 200.0:
			await _shot("coloso_herido_%d" % game.session.wave)
	if shards.size() >= 2:
		_shards_seen_max = maxi(_shards_seen_max, shards.size())
		if not _shards_noted:
			_shards_noted = true
			_note("oleada %d: el Coloso se partió: %d Pedazos de %d de vida cada uno" % [game.session.wave, shards.size(), shards[0].max_health])
		await _shot("pedazos_%d" % game.session.wave)
	if game.hud._intro.visible and game.hud._intro.modulate.a > 0.9:
		var title: String = game.hud._intro_name.text
		if not _seen_intro.has(title):
			_seen_intro[title] = game.session.wave
			_note("oleada %d: se ve la tarjeta «%s»: %s" % [game.session.wave, title, game.hud._intro_text.text if "_intro_text" in game.hud else ""])
			await _shot("tarjeta_%s" % title.get_slice(":", 1).strip_edges().to_lower().replace(" ", "_"))


## Un clic real en el centro de un control.
func _click_control(control: Control) -> void:
	await _click(control.get_global_rect().get_center())


func _check_intro() -> void:
	if not game.level_intro.is_open():
		_problem("el cartel de entrada no se abrió al entrar al nivel")
		return
	_note("cartel de entrada abierto, partida en pausa: %s; texto: %s" % [game.is_paused(), game.level_intro.lines_text().replace("\n", " / ")])
	await _shot("cartel")
	await _click(Vector2(640, 360))  # un clic real en cualquier parte lo cierra (al soltar)
	await _frames(3)
	if game.level_intro.is_open():
		_problem("el clic no cerró el cartel")
	else:
		_note("el clic cerró el cartel y la partida sigue (en pausa: %s)" % game.is_paused())


func _play() -> void:
	var total: int = game.level_data.waves.size()
	if until_wave <= 0 or until_wave > total:
		until_wave = total
	_note("nivel %d «%s»: %d oleadas, %d torres en la barra: %s" % [level_number, game.level_data.display_name, total,
		game.available_towers.size(), game.available_towers.map(func(t: TowerData) -> String: return String(t.id))])
	await _check_intro()
	await _shot("inicio")
	if skip_waves > 0:
		game.session.earn(9000)
		_note("AYUDA DE VERIFICACIÓN: 9000 de oro y las oleadas 1 a %d dadas por completadas con la sesión (no se juegan)" % skip_waves)
		(report["checks"] as Array).append("ayuda de verificación: skip=%d" % skip_waves)
	await _buy()
	await _shot("apertura")
	for i: int in skip_waves:
		game.session.begin_wave()
		game.session.complete_wave()
		if i % 6 == 5:
			await _buy()
	if skip_waves > 0:
		_note("después de la ayuda: oleada %d, %d vidas, %d torres, %d de oro" % [game.session.wave, game.session.lives,
			game.tower_container.get_child_count(), game.session.gold])
	while not game.session.is_over() and game.session.wave < until_wave:
		await _buy()
		var wave_before: int = game.session.wave
		await _click(game.hud._start_wave_button.get_global_rect().get_center())
		if game.session.wave == wave_before:
			_problem("el botón «Empezar oleada» no empezó la oleada %d" % (wave_before + 1))
			game.start_next_wave()
		Engine.time_scale = speed
		var frames: int = 0
		var mid_wave_buy: int = 0
		while game.session.state == LevelSession.State.WAVE_RUNNING and frames < 60 * 900:
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
		print("T234 ", JSON.stringify(info))
		if game.session.wave == 1 or game.session.wave == 25 or game.session.wave == until_wave:
			await _shot("oleada_%d_fin" % game.session.wave)
	await _frames(10)
	await _end_flow()


## La victoria con «Epílogo», el epílogo, los créditos y volver, todo con clics y teclas reales.
func _end_flow() -> void:
	var end_screen: EndScreen = game.end_screen
	if game.session.state != LevelSession.State.WON:
		_problem("la partida no terminó en victoria (estado %s, vidas %d)" % [game.session.state, game.session.lives])
		await _shot("final")
		return
	await _frames(10)
	if end_screen.is_asking_name():
		await _shot("victoria_iniciales")
		end_screen.name_entry().confirm()
		await _frames(5)
	# RF-194: con los 15 niveles ganados, el Salón de la fama se abre primero, encima de la pantalla de victoria.
	if game.hall_of_fame != null:
		_note("el Salón de la fama se abre antes que la victoria (RF-194): pide las 5 letras")
		if game.hall_of_fame.is_asking_name():
			game.hall_of_fame.name_entry().confirm()
			await _frames(5)
		await _shot("salon_de_la_fama")
		for button: Node in game.hall_of_fame.find_children("*", "Button", true, false):
			if (button as Button).visible and (button as Button).text.begins_with("Continuar"):
				await _click_control(button)
				break
		await _frames(5)
		_note("el Salón de la fama se cerró: %s" % (game.hall_of_fame == null))
	var next_button: Button = end_screen.get_node("%NextButton")
	_note("victoria: botón «%s» visible=%s; «Reintentar» visible=%s; «Niveles» visible=%s; texto de victoria: %s" % [next_button.text,
		next_button.visible, end_screen.get_node("%RetryButton").visible, end_screen.get_node("%LevelsButton").visible,
		end_screen.win_text().replace("\n", " / ")])
	if next_button.text != "Epílogo" or not next_button.visible:
		_problem("la victoria del 15 no ofrece «Epílogo»")
	_note("campaña terminada (se deduce de los 15 niveles): %s" % GameFlow.is_campaign_complete())
	var save_before: String = FileAccess.get_file_as_string(SaveManager.save_path)
	await _shot("victoria")
	await _click_control(next_button)
	await _frames(5)
	if game.epilogue == null or not game.epilogue.is_open():
		_problem("el botón «Epílogo» no abrió el epílogo")
		return
	_note("epílogo abierto; texto: %s" % game.epilogue.text().replace("\n", " / "))
	await _shot("epilogo")
	var credits_button: Button = null
	var levels_button: Button = null
	for button: Node in game.epilogue.find_children("*", "Button", true, false):
		if (button as Button).text == "Créditos":
			credits_button = button
		elif (button as Button).text == "Niveles":
			levels_button = button
	_note("epílogo: botones «Créditos» (%s) y «Niveles» (%s)" % [credits_button != null, levels_button != null])
	await _click_control(credits_button)
	await _frames(5)
	if not game.epilogue.credits.is_open():
		_problem("el botón «Créditos» no abrió los créditos")
	else:
		_note("créditos abiertos: %s" % " / ".join(game.epilogue.credits.lines()))
	await _shot("creditos")
	var back: Button = game.epilogue.credits.find_children("*", "Button", true, false)[0]
	await _click_control(back)
	await _frames(5)
	_note("«Volver» cierra los créditos: %s; el epílogo sigue abierto: %s" % [not game.epilogue.credits.is_open(), game.epilogue.is_open()])
	await _shot("epilogo_de_vuelta")
	# Esc real: del epílogo vuelve a la pantalla de victoria.
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.physical_keycode = KEY_ESCAPE
	esc.pressed = true
	Input.parse_input_event(esc)
	await _frames(3)
	esc.pressed = false
	Input.parse_input_event(esc)
	await _frames(5)
	_note("Esc cierra el epílogo: %s; la victoria sigue a la vista: %s" % [not game.epilogue.is_open(), end_screen.visible])
	await _shot("victoria_de_vuelta")
	var save_after: String = FileAccess.get_file_as_string(SaveManager.save_path)
	_note("el guardado es idéntico antes y después de ver el epílogo y los créditos: %s" % (save_before == save_after))
	if save_before != save_after:
		_problem("el guardado cambió al ver el epílogo")


func _finish() -> void:
	Engine.time_scale = 1.0
	report["level"] = level_number
	report["speed"] = speed
	report["towers"] = game.available_towers.map(func(t: TowerData) -> String: return String(t.id))
	report["colossus_seen_wave"] = _colossus_seen_wave
	report["max_shards_seen_at_once"] = _shards_seen_max
	report["intro_cards"] = _seen_intro
	report["lives_end"] = game.session.lives
	var file: FileAccess = FileAccess.open("%s/play_level_%d.json" % [out_dir, level_number], FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	print("T234_FIN ", JSON.stringify({"problems": report["problems"], "lives": game.session.lives}))
	get_tree().quit()
