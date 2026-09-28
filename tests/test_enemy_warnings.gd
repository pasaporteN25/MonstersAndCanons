# Tests de los avisos de enemigos (T67-T68, spec §9.5).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_save.json"
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	GameFlow.current_index = -1
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	GameFlow.current_index = -1
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Lo que muestra "Próxima oleada": [[id, cantidad], ...] en orden.
func _next_wave_shown() -> Array:
	var shown: Array = []
	for icon: Node in (game.hud.get_node("%NextWaveIcons") as Node).get_children():
		if icon.is_queued_for_deletion():
			continue
		shown.append([String((icon as EnemyIcon).enemy.id), (icon as EnemyIcon).count])
	return shown


# --- RF-133: próxima oleada ---

func test_wave_enemy_counts_merge_groups_of_the_same_enemy() -> void:
	var wave := WaveData.new()
	for count: int in [3, 4]:
		var group := SpawnGroup.new()
		group.enemy = _enemy("normal")
		group.count = count
		wave.groups.append(group)
	var counts: Dictionary = wave.enemy_counts()
	assert_eq(counts.size(), 1)
	assert_eq(counts[_enemy("normal")], 7)


func test_shows_the_first_wave_before_starting() -> void:
	assert_eq(_next_wave_shown(), [["normal", 8]], "nivel 1, oleada 1: 8 Normales")


func test_shows_the_following_wave_once_one_starts() -> void:
	game.session.begin_wave()  # empieza la 1 → la próxima es la 2
	assert_eq(_next_wave_shown(), [["normal", 12]])
	game.session.complete_wave()
	game.session.begin_wave()  # empieza la 2 → la próxima es la 3
	game.session.complete_wave()
	game.session.begin_wave()  # empieza la 3 → la próxima es la 4
	assert_eq(_next_wave_shown(), [["normal", 10], ["armored", 4]])


func test_the_busiest_wave_fits_in_one_row() -> void:
	# La oleada 10 del nivel 1 trae 4 tipos, el máximo de todos los niveles.
	game.hud.show_next_wave(game.level_data.waves[9])
	await wait_process_frames(2)  # deja que el contenedor acomode los íconos
	var row: HFlowContainer = game.hud.get_node("%NextWaveIcons")
	var icons: Array[Control] = []
	for child: Node in row.get_children():
		if not child.is_queued_for_deletion():
			icons.append(child as Control)
	assert_eq(icons.size(), 4)
	for icon: Control in icons:
		assert_eq(icon.position.y, icons[0].position.y, "todos en la misma fila")
		assert_lte(icon.position.x + icon.size.x, row.size.x, "no se sale por el costado")
	var bottom: float = row.get_global_rect().end.y
	assert_lte(bottom, 720.0, "no se sale de la pantalla por abajo")


func test_nothing_after_the_last_wave() -> void:
	for i: int in game.session.total_waves:
		game.session.begin_wave()
		if i < game.session.total_waves - 1:
			game.session.complete_wave()
	assert_false((game.hud.get_node("%NextWave") as Control).visible)


# --- RF-135: cartel del Jefe ---

func test_boss_wave_banner() -> void:
	for i: int in 9:
		game.session.begin_wave()
		game.session.complete_wave()
	game.session.begin_wave()  # oleada 10: trae al Jefe
	assert_eq((game.hud.get_node("%BossLine") as Label).text, "¡Llega el Jefe!")


func test_no_boss_line_in_normal_waves() -> void:
	game.session.begin_wave()
	assert_eq((game.hud.get_node("%BossLine") as Label).text, "")


# --- RF-134: presentación de enemigos ---

func _spawn(enemy_id: String) -> void:
	var group := SpawnGroup.new()
	group.enemy = _enemy(enemy_id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)


func _intro_label(unique_name: String) -> String:
	return (game.hud.get_node("%" + unique_name) as Label).text


func test_first_appearance_shows_the_card() -> void:
	_spawn("flyer")
	assert_true((game.hud.get_node("%EnemyIntro") as Control).visible)
	assert_eq(_intro_label("IntroName"), "Nuevo enemigo: Volador")
	assert_eq(_intro_label("IntroText"), _enemy("flyer").description)
	assert_true(SaveManager.has_seen_enemy(&"flyer"))


func test_card_appears_only_once_per_type() -> void:
	_spawn("flyer")
	var queued_after_first: int = game.hud._intro_queue.size()
	_spawn("flyer")
	assert_eq(game.hud._intro_queue.size(), queued_after_first, "la segunda vez no se encola nada")


func test_two_new_enemies_are_shown_one_after_the_other() -> void:
	_spawn("flyer")
	_spawn("armored")
	assert_eq(_intro_label("IntroName"), "Nuevo enemigo: Volador", "primero el que llegó primero")
	assert_eq(game.hud._intro_queue.size(), 1, "el Blindado espera su turno")


func test_seen_enemies_survive_closing_the_game() -> void:
	SaveManager.mark_enemy_seen(&"boss")
	SaveManager.save()
	SaveManager.load_save()
	assert_true(SaveManager.has_seen_enemy(&"boss"))
	assert_false(SaveManager.has_seen_enemy(&"tank"))


func test_outside_the_campaign_nothing_is_written() -> void:
	_spawn("tank")
	assert_false(FileAccess.file_exists(TEST_PATH), "RF-117")


func test_in_the_campaign_it_is_saved() -> void:
	GameFlow.current_index = 0
	_spawn("tank")
	assert_true(FileAccess.file_exists(TEST_PATH))
