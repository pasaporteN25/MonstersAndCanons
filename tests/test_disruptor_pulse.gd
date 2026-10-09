# Tests de la Disruptora (T217, RF-438 a RF-448, D-086, D-087): el pulso, la supresión y los datos.
# Los enemigos no se mueven (velocidad 0); la torre se mueve con `_physics_process` a mano.
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const DT: float = 1.0 / 60.0
const BASE_DISTANCE: float = 200.0
const TILE: float = 64.0

var world: Node2D
var level: Level
var disruptor: TowerData = load("res://data/towers/disruptor.tres")
var pulses: Array[float] = []


func before_each() -> void:
	pulses = []
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _data(armor: int = 0, flying: bool = false) -> EnemyData:
	var data := EnemyData.new()
	data.id = &"prueba"
	data.display_name = "Prueba"
	data.max_health = 100
	data.speed_tiles = 0.0
	data.armor = armor
	data.is_flying = flying
	data.size_tiles = 0.3
	return data


func _emitter_data(armor_bonus: int = 2, heal: float = 0.0) -> EnemyData:
	var data: EnemyData = _data()
	data.max_health = 200
	data.aura_radius_tiles = 2.0
	data.aura_armor_bonus = armor_bonus
	data.aura_heal_percent_per_second = heal
	return data


func _spawn(data: EnemyData, tiles_from_base: float = 0.0) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), data.max_health)
	enemy.distance = BASE_DISTANCE + tiles_from_base * TILE
	world.add_child(enemy)
	return enemy


## Una Disruptora a `offset` píxeles de `anchor` (un enemigo), del nivel `level_number` (1 a 3).
func _tower(anchor: Enemy, level_number: int = 1, offset: Vector2 = Vector2(40, 0)) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(disruptor)
	tower.position = anchor.global_position + offset
	tower.pulsed.connect(func(radius: float) -> void: pulses.append(radius))
	world.add_child(tower)
	for i: int in level_number - 1:
		tower.apply_upgrade()
	return tower


func _step_enemies(seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
			var enemy := node as Enemy
			if enemy.is_active():
				enemy._physics_process(DT)


func _step_tower(tower: Tower, seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		tower._physics_process(DT)


# --- Enemigo: la supresión (RF-442, RF-443, RF-444) ---

func test_a_suppressed_emitter_stops_giving_its_aura() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var normal: Enemy = _spawn(_data(), 1.0)
	_step_enemies(0.3)
	assert_eq(normal.aura_armor(), 2, "sin suprimir recibe el aura")
	guardian.suppress(2.5)
	_step_enemies(0.5)
	assert_eq(normal.aura_armor(), 0, "RF-443: caduca sola en menos de 0,35 s")
	normal.take_hit(5)
	assert_eq(normal.health, 95, "ya sin el +2")


func test_the_emitter_gives_its_aura_again_when_the_suppression_ends() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var normal: Enemy = _spawn(_data(), 1.0)
	guardian.suppress(1.0)
	_step_enemies(0.9)
	assert_true(guardian.is_suppressed())
	assert_eq(normal.aura_armor(), 0)
	_step_enemies(0.4)
	assert_false(guardian.is_suppressed())
	assert_eq(normal.aura_armor(), 2, "vuelve a emitir en menos de 0,25 s")


func test_suppressing_again_keeps_the_longest_time_not_the_sum() -> void:
	var healer: Enemy = _spawn(_emitter_data(0, 5.0))
	healer.suppress(2.5)
	_step_enemies(1.5)
	assert_almost_eq(healer.suppress_left(), 1.0, 0.05)
	healer.suppress(2.5)
	assert_almost_eq(healer.suppress_left(), 2.5, 0.05, "queda 2,5, no 3,5")
	healer.suppress(1.0)
	assert_almost_eq(healer.suppress_left(), 2.5, 0.05, "uno más corto no lo acorta")


func test_an_enemy_without_aura_is_never_suppressed() -> void:
	var normal: Enemy = _spawn(_data())
	normal.suppress(2.5)
	assert_false(normal.is_suppressed())
	assert_eq(normal.suppress_left(), 0.0)
	normal.suppress(0.0)
	assert_false(normal.is_suppressed(), "0 segundos no suprime")


func test_suppression_does_not_advance_while_the_enemy_is_not_processed() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	guardian.suppress(2.5)
	# La pausa congela el mundo: nadie llama a _physics_process.
	assert_almost_eq(guardian.suppress_left(), 2.5, 0.001)


func test_only_the_mirror_is_pulse_immune() -> void:
	assert_true((load("res://data/enemies/mirror.tres") as EnemyData).reflect_range_tiles > 0.0)
	assert_true(_spawn(load("res://data/enemies/mirror.tres")).is_pulse_immune())
	assert_false(_spawn(load("res://data/enemies/guardian.tres")).is_pulse_immune())
	assert_false(_spawn(load("res://data/enemies/shaman.tres")).is_pulse_immune())


# --- Torre: el pulso (RF-438, RF-440, RF-441, RF-444, RF-445) ---

func test_it_pulses_only_with_an_emitter_in_range_and_keeps_its_wait() -> void:
	var normal: Enemy = _spawn(_data())
	var tower: Tower = _tower(normal)
	_step_tower(tower, 1.0)
	assert_eq(pulses.size(), 0, "solo Normales: no pulsa")
	assert_lte(tower._cooldown, 0.0, "y no gasta su espera")
	var healer: Enemy = _spawn(_emitter_data(0, 5.0), 0.3)
	_step_tower(tower, DT)
	assert_eq(pulses.size(), 1, "apenas entra un emisor, pulsa")
	assert_almost_eq(pulses[0], 160.0, 0.01, "radio 2,5 casillas")
	assert_true(healer.is_suppressed())
	assert_almost_eq(healer.suppress_left(), 2.5, 0.05)


func test_the_pulse_hits_everyone_in_range_armor_included() -> void:
	var guardian: Enemy = _spawn(_emitter_data(2))
	var normal: Enemy = _spawn(_data(), 0.5)
	var flyer: Enemy = _spawn(_data(0, true), 0.5)
	var far: Enemy = _spawn(_data(), 6.0)
	_step_enemies(0.3)
	var tower: Tower = _tower(guardian)
	_step_tower(tower, DT)
	assert_eq(guardian.health, 200 - 5, "5 de daño, sin armadura propia")
	assert_eq(normal.health, 100 - 3, "5 − 2 del aura que todavía no caducó")
	assert_eq(flyer.health, 100 - 3, "el volador también (la aura todavía lo cubre)")
	assert_eq(far.health, 100, "fuera del radio no recibe nada")
	assert_false(normal.is_suppressed(), "sin aura no queda suprimido")
	_step_enemies(0.5)
	assert_eq(normal.aura_armor(), 0, "y el aura que recibía desaparece enseguida")


func test_the_damage_has_a_minimum_of_one() -> void:
	var guardian: Enemy = _spawn(_emitter_data(0, 5.0))
	var armored: Enemy = _spawn(_data(9), 0.5)
	var tower: Tower = _tower(guardian)
	_step_tower(tower, DT)
	assert_eq(armored.health, 99, "5 − 9 → mínimo 1 (RF-80)")


func test_the_mirror_is_left_out_and_the_tower_is_not_stunned() -> void:
	var mirror: Enemy = _spawn(load("res://data/enemies/mirror.tres"), 0.2)
	var guardian: Enemy = _spawn(_emitter_data())
	var tower: Tower = _tower(guardian)
	var mirror_health: int = mirror.health
	_step_tower(tower, DT)
	assert_eq(pulses.size(), 1)
	assert_eq(mirror.health, mirror_health, "el Espejo no recibe el golpe")
	assert_false(tower.is_stunned(), "ni rebote ni aturdimiento")
	assert_true(guardian.is_suppressed())


func test_a_mirror_alone_does_not_make_it_pulse() -> void:
	var mirror: Enemy = _spawn(load("res://data/enemies/mirror.tres"))
	var tower: Tower = _tower(mirror)
	_step_tower(tower, 1.0)
	assert_eq(pulses.size(), 0)


func test_other_abilities_are_not_suppressed() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var shaman_data: EnemyData = load("res://data/enemies/shaman.tres")
	var shaman: Enemy = _spawn(shaman_data, 0.5)
	var tower: Tower = _tower(guardian)
	var cast_before: float = shaman._stun_cast_left
	_step_tower(tower, DT)
	assert_eq(shaman.health, shaman_data.max_health - 5, "recibe el golpe")
	assert_false(shaman.is_suppressed(), "el Chamán no queda suprimido de nada")
	assert_eq(shaman._stun_cast_left, cast_before, "su hechizo sigue a su hora")


func test_a_stunned_tower_does_not_pulse_and_does_when_it_recovers() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var tower: Tower = _tower(guardian)
	tower.stun(1.0)
	_step_tower(tower, 0.9)
	assert_eq(pulses.size(), 0, "aturdida no pulsa")
	_step_tower(tower, 0.2)
	assert_eq(pulses.size(), 1, "al recuperarse pulsa en el acto")


func test_the_pulse_waits_the_cadence_and_wear_spaces_it() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var tower: Tower = _tower(guardian)
	_step_tower(tower, DT)
	assert_eq(pulses.size(), 1)
	_step_tower(tower, 3.9)
	assert_eq(pulses.size(), 1, "un pulso cada 4 s")
	_step_tower(tower, 0.2)
	assert_eq(pulses.size(), 2)
	tower.wear_percent = 40.0
	assert_almost_eq(tower.effective_fire_rate(), 0.15, 0.001, "RF-445: 40 de desgaste → 0,15/s")


func test_upgrading_widens_the_radius_and_the_suppression() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var tower: Tower = _tower(guardian, 3)
	assert_almost_eq(tower.range_px(), 3.5 * TILE, 0.01)
	_step_tower(tower, DT)
	assert_almost_eq(guardian.suppress_left(), 3.5, 0.05)


func test_a_level_3_tower_with_a_level_3_mechanic_never_lets_the_emitter_talk() -> void:
	var guardian: Enemy = _spawn(_emitter_data())
	var normal: Enemy = _spawn(_data(), 1.0)
	var tower: Tower = _tower(guardian, 3)
	var mechanic: Tower = TOWER_SCENE.instantiate()
	mechanic.setup(load("res://data/towers/mechanical_standard.tres"))
	mechanic.position = tower.position + Vector2(30, 0)
	world.add_child(mechanic)
	mechanic.apply_upgrade()
	mechanic.apply_upgrade()
	assert_almost_eq(tower.effective_fire_rate(), 0.3, 0.001, "+20 % de 0,25")
	var armored_ticks: int = 0
	for i: int in roundi(12.0 / DT):
		tower._physics_process(DT)
		_step_enemies(DT)
		if i > 60 and normal.aura_armor() > 0:
			armored_ticks += 1
	assert_eq(armored_ticks, 0, "RF-445: sin huecos mientras haya un emisor")
	assert_gte(pulses.size(), 3)


func test_a_pulse_that_kills_does_not_break_the_loop() -> void:
	var weak: EnemyData = _data()
	weak.max_health = 3
	var guardian: Enemy = _spawn(_emitter_data())
	var first: Enemy = _spawn(weak, 0.2)
	var second: Enemy = _spawn(weak, 0.4)
	var tower: Tower = _tower(guardian)
	_step_tower(tower, DT)
	assert_true(first.health <= 0 or not first.is_active())
	assert_true(guardian.is_suppressed())
	assert_eq(pulses.size(), 1)
	assert_true(second != null)


# --- Datos (RF-439, RF-446, RF-447, RF-448) ---

func test_the_data_match_the_spec() -> void:
	assert_eq(disruptor.id, &"disruptor")
	assert_true(disruptor.reserved)
	assert_eq(disruptor.required_collection, &"disruptor")
	assert_eq(disruptor.resource_cost, 2)
	assert_true(disruptor.can_hit_air)
	assert_eq(disruptor.build_gold(), 130)
	assert_eq(disruptor.build_resources(), 2)
	assert_eq(disruptor.levels.size(), 3)
	var costs: Array[int] = [130, 100, 150]
	var radii: Array[float] = [2.5, 3.0, 3.5]
	var seconds: Array[float] = [2.5, 3.0, 3.5]
	for i: int in 3:
		var stats: TowerLevelData = disruptor.levels[i]
		assert_eq(stats.cost, costs[i])
		assert_eq(stats.damage, 5)
		assert_eq(stats.fire_rate, 0.25)
		assert_eq(stats.range_tiles, radii[i])
		assert_eq(stats.suppress_seconds, seconds[i])


func test_a_pulse_tower_has_no_other_behaviour() -> void:
	for stats: TowerLevelData in disruptor.levels:
		assert_eq(stats.burst_count, 0)
		assert_eq(stats.extra_targets, 0)
		assert_eq(stats.chain_extra_targets, 0)
		assert_eq(stats.splash_radius_tiles, 0.0)
		assert_eq(stats.slow_amount, 0.0)
		assert_eq(stats.burn_damage_per_second, 0)


func test_it_is_the_tenth_tower_and_no_key_moves() -> void:
	var game: Game = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	var ids: Array[String] = []
	for tower: TowerData in game.tower_types:
		ids.append(String(tower.id))
	game.free()
	assert_eq(ids.slice(0, 10), ["basic", "cannon", "frost", "sniper", "fire", "multi", "burst", "tesla", "mortar", "disruptor"])


func test_no_campaign_level_before_the_eleventh_offers_it_even_with_the_collection() -> void:
	# T229: el nivel 11 (puesto seco) es el primero que la ofrece (RF-474); los niveles 1 a 10 no.
	var all: Array[TowerData] = TowerOffer.canonical_towers()
	for i: int in mini(GameFlow.level_count(), 10):
		var offered: Array[TowerData] = GameFlow.level(i).available_towers(all, func(_c: StringName) -> bool: return true)
		for tower: TowerData in offered:
			assert_ne(tower.id, &"disruptor", "el nivel %d no la ofrece" % (i + 1))
	for i: int in range(10, GameFlow.level_count()):
		var with_collection: Array[TowerData] = GameFlow.level(i).available_towers(all, func(_c: StringName) -> bool: return true)
		var without: Array[TowerData] = GameFlow.level(i).available_towers(all, func(_c: StringName) -> bool: return false)
		assert_true(with_collection.has(disruptor), "el nivel %d la ofrece con la colección" % (i + 1))
		assert_false(without.has(disruptor), "el nivel %d no la ofrece sin la colección (RF-395)" % (i + 1))


func test_naming_it_enables_it_only_with_the_collection() -> void:
	var all: Array[TowerData] = TowerOffer.canonical_towers()
	var custom := LevelData.new()
	custom.towers = PackedStringArray(["cannon", "disruptor"])
	var with_collection: Array[TowerData] = custom.available_towers(all, func(_c: StringName) -> bool: return true)
	var without: Array[TowerData] = custom.available_towers(all, func(_c: StringName) -> bool: return false)
	assert_true(with_collection.has(disruptor))
	assert_false(without.has(disruptor), "RF-395: nombrarla no saltea la colección")
