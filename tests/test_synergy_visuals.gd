# Tests del aviso visual, el panel y la Wiki de las sinergias por estado (M20, T144, spec RF-313).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const TEST_PATH: String = "user://test_save.json"
const DT: float = 1.0 / 60.0

var game: Game
var cannon: TowerData = load("res://data/towers/cannon.tres")
var tesla: TowerData = load("res://data/towers/tesla.tres")
var basic: TowerData = load("res://data/towers/basic.tres")


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _spawn(enemy_id: String) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = load("res://data/enemies/%s.tres" % enemy_id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1)


func _combo_texts() -> Array[FloatingText]:
	var texts: Array[FloatingText] = []
	for child: Node in game.effects.get_children():
		if child is FloatingText and (child as FloatingText)._color == EffectsLayer.COMBO_COLOR:
			texts.append(child)
	return texts


func _hit_with(tower: TowerData, enemy: Enemy) -> void:
	var projectile: Projectile = preload("res://scenes/towers/projectile.tscn").instantiate()
	projectile.setup(enemy, enemy.global_position, tower.levels[0], true, 10.0, Color.WHITE)
	game.add_child(projectile)
	projectile._physics_process(DT)


func test_a_combo_hit_shows_the_golden_text() -> void:
	var enemy: Enemy = _spawn("normal")
	enemy.take_hit(1, 0.4, 5.0)  # ralentizado
	_hit_with(cannon, enemy)
	assert_eq(_combo_texts().size(), 1, "RF-313: un ¡Combo!")
	assert_eq(_combo_texts()[0]._text, "¡Combo!")


func test_a_normal_hit_shows_no_combo() -> void:
	var enemy: Enemy = _spawn("normal")
	_hit_with(cannon, enemy)
	assert_eq(_combo_texts().size(), 0)


func test_the_combo_follows_the_damage_numbers_option() -> void:
	SaveManager.set_setting("damage_numbers", false)
	var enemy: Enemy = _spawn("normal")
	enemy.take_hit(1, 0.4, 5.0)
	_hit_with(cannon, enemy)
	assert_eq(_combo_texts().size(), 0, "RF-113: apagados los números, tampoco hay combo")


func test_the_panel_and_the_wiki_say_the_bonus() -> void:
	assert_string_contains(TowerText.describe(cannon.levels[0], false), "+25 % de daño a ralentizados")
	assert_string_contains(TowerText.describe(tesla.levels[0], true), "+30 % de daño a quemados")
	assert_false(TowerText.describe(basic.levels[0], true).contains("de daño a"), "las demás no lo dicen")
	var cannon_wiki: String = JSON.stringify(Wiki.tower_entry(cannon).blocks)
	assert_string_contains(cannon_wiki, "+25 % de daño a ralentizados")
	assert_string_contains(JSON.stringify(Wiki.tower_entry(tesla).blocks), "+30 % de daño a quemados")
	assert_false(JSON.stringify(Wiki.tower_entry(basic).blocks).contains("de daño a ralentizados"))
