# Tests de los números de daño flotantes (T65, RF-132).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
var TEST_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)
const DT: float = 1.0 / 60.0

var game: Game


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()  # opciones por defecto: números de daño encendidos
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


func _damage_texts() -> Array[FloatingText]:
	var texts: Array[FloatingText] = []
	for child: Node in game.effects.get_children():
		if child is FloatingText:
			texts.append(child)
	return texts


func test_hit_shows_the_real_damage() -> void:
	var enemy: Enemy = _spawn("normal")
	enemy.take_hit(5)
	var texts: Array[FloatingText] = _damage_texts()
	assert_eq(texts.size(), 1)
	assert_eq(texts[0]._text, "5")
	assert_eq(texts[0]._color, EffectsLayer.DAMAGE_COLOR)


func test_armor_turns_the_number_grey() -> void:
	var armored: Enemy = _spawn("armored")
	armored.take_hit(5)  # armadura 3: hace 2 de 5, la armadura se comió más de la mitad
	var texts: Array[FloatingText] = _damage_texts()
	assert_eq(texts[0]._text, "2", "daño real, después de la armadura")
	assert_eq(texts[0]._color, EffectsLayer.DAMAGE_BLOCKED_COLOR)


func test_small_armor_keeps_the_number_white() -> void:
	var armored: Enemy = _spawn("armored")
	armored.take_hit(40)  # hace 37 de 40
	assert_eq(_damage_texts()[0]._color, EffectsLayer.DAMAGE_COLOR)


func test_numbers_can_be_turned_off() -> void:
	SaveManager.set_setting("damage_numbers", false)
	var enemy: Enemy = _spawn("normal")
	enemy.take_hit(5)
	assert_eq(_damage_texts().size(), 0, "RF-113")


func test_never_more_than_the_cap() -> void:
	var enemy: Enemy = _spawn("boss")
	enemy.max_health = 100000
	enemy.health = 100000
	for i: int in EffectsLayer.MAX_DAMAGE_NUMBERS + 25:
		enemy.take_hit(10)
	assert_eq(game.effects.damage_numbers_alive(), EffectsLayer.MAX_DAMAGE_NUMBERS)


func test_counter_goes_down_when_numbers_fade() -> void:
	var enemy: Enemy = _spawn("normal")
	enemy.take_hit(5)
	assert_eq(game.effects.damage_numbers_alive(), 1)
	simulate(game.effects, 60, DT)  # 1 s: más que los 0.6 s que dura
	await wait_process_frames(2)
	assert_eq(game.effects.damage_numbers_alive(), 0)
