# Tests del Chamán (T135, RF-281, RF-282, RF-285 a RF-287, D-043).
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0

var world: Node2D
var level: Level
var basic: TowerData = load("res://data/towers/basic.tres")
var casts: Array = []


func before_each() -> void:
	casts = []
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _data() -> EnemyData:
	return load("res://data/enemies/shaman.tres") as EnemyData


## Un Chamán quieto (velocidad 0) en un tramo recto del camino.
func _shaman() -> Enemy:
	var data: EnemyData = _data().duplicate()
	data.speed_tiles = 0.0
	data.max_health = 100000  # las torres de la prueba le disparan: que no muera
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), data.max_health)
	enemy.distance = 250.0
	enemy.cast_stun.connect(func(shaman: Enemy, tower: Tower) -> void: casts.append([shaman, tower]))
	world.add_child(enemy)
	return enemy


## Una torre a `pixels` del Chamán (en línea recta hacia la derecha).
func _tower_at(shaman: Enemy, pixels: float, vertical: float = 0.0) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(basic)
	tower.position = shaman.global_position + Vector2(pixels, vertical)
	tower.fired.connect(func(projectile: Projectile) -> void: projectile.free())
	world.add_child(tower)
	return tower


func _step(seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
			if (node as Enemy).is_active():
				(node as Enemy)._physics_process(DT)
		for node: Node in get_tree().get_nodes_in_group(Tower.GROUP):
			(node as Tower)._physics_process(DT)


# --- Los datos (RF-285) ---

func test_the_shaman_has_the_numbers_of_the_spec() -> void:
	var s: EnemyData = _data()
	assert_eq(s.id, &"shaman")
	assert_eq(s.display_name, "Chamán")
	assert_eq(s.max_health, 90)
	assert_almost_eq(s.speed_tiles, 0.9, 0.001)
	assert_eq(s.armor, 0)
	assert_eq(s.reward, 20)
	assert_eq(s.lives_damage, 2)
	assert_almost_eq(s.size_tiles, 0.32, 0.001)
	assert_almost_eq(s.stun_interval, 8.0, 0.001)
	assert_almost_eq(s.stun_seconds, 3.0, 0.001)
	assert_almost_eq(s.stun_range_tiles, 4.0, 0.001)
	assert_eq(s.description, "Cada tanto apaga la torre más cercana. Un Francotirador lo alcanza antes de que lance su hechizo.")


func test_the_spell_data_is_off_by_default() -> void:
	var data := EnemyData.new()
	assert_eq(data.stun_interval, 0.0)
	assert_eq(data.stun_seconds, 0.0)
	assert_eq(data.stun_range_tiles, 0.0)
	assert_false(_shaman().data.stun_interval == 0.0)
	var normal: Enemy = ENEMY_SCENE.instantiate()
	normal.setup(load("res://data/enemies/normal.tres"), level.get_ground_path(0), 30)
	world.add_child(normal)
	assert_false(normal.has_stun_spell())


func test_a_long_range_tower_outranges_the_spell() -> void:
	# RF-282: el hechizo llega menos que el Francotirador, así que se lo puede matar antes.
	var sniper: TowerData = load("res://data/towers/sniper.tres")
	assert_gt(sniper.levels[0].range_tiles, _data().stun_range_tiles)


# --- El hechizo (RF-282) ---

func test_the_first_spell_comes_one_interval_after_it_appears() -> void:
	var shaman: Enemy = _shaman()
	var tower: Tower = _tower_at(shaman, 128.0)
	_step(7.9)
	assert_false(tower.is_stunned(), "todavía no")
	_step(0.3)
	assert_true(tower.is_stunned(), "a los 8 segundos")
	assert_almost_eq(tower.stun_left(), 3.0 - 0.2, 0.15, "y dura 3 segundos")
	assert_eq(casts.size(), 1)
	assert_eq(casts[0][0], shaman)
	assert_eq(casts[0][1], tower)


func test_it_casts_again_every_interval() -> void:
	var shaman: Enemy = _shaman()
	_tower_at(shaman, 128.0)
	_step(8.2)
	assert_eq(casts.size(), 1)
	_step(7.6)
	assert_eq(casts.size(), 1, "todavía falta")
	_step(0.6)
	assert_eq(casts.size(), 2, "ocho segundos después del primero")


func test_it_stuns_the_nearest_tower() -> void:
	var shaman: Enemy = _shaman()
	var far: Tower = _tower_at(shaman, 200.0)
	var near: Tower = _tower_at(shaman, 100.0)
	var middle: Tower = _tower_at(shaman, 150.0, 50.0)
	_step(8.2)
	assert_true(near.is_stunned(), "la más cercana")
	assert_false(far.is_stunned())
	assert_false(middle.is_stunned())


func test_it_skips_a_tower_that_is_already_stunned() -> void:
	var shaman: Enemy = _shaman()
	var near: Tower = _tower_at(shaman, 100.0)
	var far: Tower = _tower_at(shaman, 200.0)
	near.stun(100.0)
	_step(8.2)
	assert_true(far.is_stunned(), "apaga la que no lo estaba")
	assert_lt(near.stun_left(), 100.0)


func test_the_range_is_four_tiles() -> void:
	var shaman: Enemy = _shaman()
	var inside: Tower = _tower_at(shaman, 255.0)
	var outside: Tower = _tower_at(shaman, 0.0, 258.0)
	_step(8.2)
	assert_true(inside.is_stunned(), "a 255 px (menos de 4 casillas)")
	assert_false(outside.is_stunned(), "a 258 px (más de 4 casillas)")


func test_with_no_tower_in_range_it_waits_and_does_not_store_spells() -> void:
	var shaman: Enemy = _shaman()
	_step(20.0)
	assert_eq(casts.size(), 0)
	var tower: Tower = _tower_at(shaman, 128.0)
	_step(0.1)
	assert_true(tower.is_stunned(), "apenas aparece una torre, lanza")
	assert_eq(casts.size(), 1, "uno solo: no se acumularon hechizos")
	_step(0.5)
	assert_eq(casts.size(), 1)


func test_a_dead_shaman_stops_casting() -> void:
	var shaman: Enemy = _shaman()
	var tower: Tower = _tower_at(shaman, 128.0)
	_step(4.0)
	shaman.vanish()
	_step(10.0)
	assert_false(tower.is_stunned())
	assert_eq(casts.size(), 0)


func test_a_sold_tower_does_not_break_the_spell() -> void:
	var shaman: Enemy = _shaman()
	var tower: Tower = _tower_at(shaman, 128.0)
	_step(4.0)
	tower.free()
	_step(5.0)
	assert_eq(casts.size(), 0, "no había otra torre")


# --- En el resto del juego ---

func test_it_is_found_by_name_and_starts_closed_in_the_bestiary() -> void:
	assert_true(LevelFile.enemy_ids().has("shaman"))
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, func(_id: StringName) -> bool: return false):
		if category.id == &"enemigos":
			assert_true(category.find(&"shaman").locked)


func test_the_wiki_writes_down_the_spell() -> void:
	var entry: WikiEntry
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == &"enemigos":
			entry = category.find(&"shaman")
	var facts: Dictionary = {}
	for block: Dictionary in entry.blocks:
		if block["tipo"] == WikiEntry.KIND_FACTS:
			for row: Array in block["filas"]:
				facts[row[0]] = row[1]
	assert_eq(facts["Hechizo"], "apaga la torre más cercana (a menos de 4 casillas) durante 3 s, cada 8 s")


func test_its_color_is_its_own() -> void:
	var color: Color = _data().color
	for id: String in LevelFile.enemy_ids():
		if id == "shaman":
			continue
		var other: Color = (load("res://data/enemies/%s.tres" % id) as EnemyData).color
		var distance: float = Vector3(color.r - other.r, color.g - other.g, color.b - other.b).length()
		assert_gt(distance, 0.18, "se parece demasiado a %s" % id)


func test_in_a_real_game_the_shaman_switches_off_a_tower_and_the_bolt_is_drawn() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.earn(500)
	assert_true(game.build_controller.try_build(game.tower_types[0], Vector2i(3, 2)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(3, 2))
	game.dev_spawn(_data())
	var stunned_once: bool = false
	for i: int in 60 * 14:
		for node: Node in game.get_tree().get_nodes_in_group(Enemy.GROUP):
			(node as Enemy)._physics_process(DT)
		tower._physics_process(DT)
		if tower.is_stunned():
			stunned_once = true
			break
	assert_true(stunned_once, "el Chamán pasó cerca y apagó la torre")
	await wait_physics_frames(3)
	assert_gt(game.effects.get_child_count(), 0, "se dibujó el rayo")
