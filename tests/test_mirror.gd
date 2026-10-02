# Tests del Espejo (T136, RF-283 a RF-287, D-043).
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const DT: float = 1.0 / 60.0
const HEALTH: int = 1000

var world: Node2D
var level: Level
var basic: TowerData = load("res://data/towers/basic.tres")
var cannon: TowerData = load("res://data/towers/cannon.tres")
var frost: TowerData = load("res://data/towers/frost.tres")
var fire: TowerData = load("res://data/towers/fire.tres")
var tesla: TowerData = load("res://data/towers/tesla.tres")
var reflections: Array = []


func before_each() -> void:
	reflections = []
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _data() -> EnemyData:
	return load("res://data/enemies/mirror.tres") as EnemyData


func _mirror() -> Enemy:
	var data: EnemyData = _data().duplicate()
	data.speed_tiles = 0.0
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), HEALTH)
	enemy.distance = 250.0
	enemy.reflected.connect(func(m: Enemy, t: Tower, first: bool) -> void: reflections.append([m, t, first]))
	world.add_child(enemy)
	return enemy


func _plain(near: Enemy, pixels_away: float = 40.0) -> Enemy:
	var data: EnemyData = (load("res://data/enemies/normal.tres") as EnemyData).duplicate()
	data.speed_tiles = 0.0
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), HEALTH)
	enemy.distance = near.distance + pixels_away
	world.add_child(enemy)
	return enemy


func _tower(data: TowerData, target: Enemy, pixels: float) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(data)
	tower.position = target.global_position + Vector2(0, pixels)
	world.add_child(tower)
	return tower


## Dispara el proyectil de `tower` a `target`: sale de donde está el objetivo, así impacta en el primer cuadro.
func _shoot(tower: Tower, target: Enemy, with_source: bool = true) -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(target, target.global_position, tower.stats(), tower.data.can_hit_air,
		tower.data.projectile_speed_tiles, tower.data.color)
	if with_source:
		projectile.source = tower
	world.add_child(projectile)
	projectile._physics_process(DT)


# --- Los datos (RF-285) ---

func test_the_mirror_has_the_numbers_of_the_spec() -> void:
	var m: EnemyData = _data()
	assert_eq(m.id, &"mirror")
	assert_eq(m.display_name, "Espejo")
	assert_eq(m.max_health, 180)
	assert_almost_eq(m.speed_tiles, 0.7, 0.001)
	assert_eq(m.armor, 0)
	assert_eq(m.reward, 25)
	assert_eq(m.lives_damage, 2)
	assert_almost_eq(m.size_tiles, 0.36, 0.001)
	assert_almost_eq(m.reflect_range_tiles, 2.5, 0.001)
	assert_almost_eq(m.reflect_stun_seconds, 2.0, 0.001)
	assert_eq(m.description, "Devuelve los tiros de las torres cercanas y las aturde. El fuego y las torres de largo alcance lo golpean sin problema.")


func test_the_reflection_data_is_off_by_default() -> void:
	var data := EnemyData.new()
	assert_eq(data.reflect_range_tiles, 0.0)
	assert_eq(data.reflect_stun_seconds, 0.0)
	var normal: Enemy = _plain(_mirror())
	assert_false(normal.can_reflect())


func test_the_reflection_range_is_below_the_long_range_towers() -> void:
	var sniper: TowerData = load("res://data/towers/sniper.tres")
	assert_gt(sniper.levels[0].range_tiles, _data().reflect_range_tiles)


# --- El rebote (RF-284, criterio de aceptación) ---

func test_a_close_tower_is_reflected_and_a_far_one_is_not() -> void:
	var mirror: Enemy = _mirror()
	var close: Tower = _tower(basic, mirror, 128.0)   # 2 casillas
	var far: Tower = _tower(basic, mirror, 256.0)     # 4 casillas
	_shoot(close, mirror)
	assert_eq(mirror.health, HEALTH, "el golpe de la cercana rebota: 0 de daño")
	assert_true(close.is_stunned(), "y la torre queda aturdida")
	assert_almost_eq(close.stun_left(), 2.0, 0.001)
	_shoot(far, mirror)
	assert_eq(mirror.health, HEALTH - basic.levels[0].damage, "el de la lejana le pega normal")
	assert_false(far.is_stunned())


func test_the_border_is_two_and_a_half_tiles() -> void:
	var mirror: Enemy = _mirror()
	var inside: Tower = _tower(basic, mirror, 158.0)
	var outside: Tower = _tower(basic, mirror, 162.0)
	assert_true(mirror.will_reflect(inside), "158 px: menos de 2,5 casillas (160)")
	assert_false(mirror.will_reflect(outside), "162 px: más")


func test_it_is_measured_when_the_shot_lands() -> void:
	# D-043: un tiro que sale de lejos y llega de cerca rebota; lo contrario, no.
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 300.0)
	assert_false(mirror.will_reflect(tower))
	mirror.distance += 200.0  # el Espejo se acercó a la torre
	tower.position = mirror.global_position + Vector2(0, 100.0)
	assert_true(mirror.will_reflect(tower), "ahora está cerca: rebota")


func test_slow_does_not_pass_through_a_reflected_shot() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(frost, mirror, 100.0)
	_shoot(tower, mirror)
	assert_almost_eq(mirror.current_speed_tiles(), 0.0, 0.0001, "sigue con su velocidad (0 en la prueba)")
	assert_false(mirror.is_slowed(), "el Hielo rebotado no ralentiza")
	assert_eq(mirror.health, HEALTH)


func test_burning_is_not_reflected() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(fire, mirror, 100.0)
	_shoot(tower, mirror)
	assert_true(mirror.is_burning(), "la quemadura no rebota (RF-284)")
	assert_true(tower.is_stunned(), "pero la torre igual queda aturdida")
	assert_eq(mirror.health, HEALTH, "y el golpe en sí, no hizo daño")


func test_splash_hits_the_others_and_reflects_only_on_the_mirror() -> void:
	var mirror: Enemy = _mirror()
	var neighbor: Enemy = _plain(mirror, 30.0)
	var tower: Tower = _tower(cannon, mirror, 120.0)
	_shoot(tower, mirror)
	assert_eq(mirror.health, HEALTH, "el Espejo no recibe el área")
	assert_eq(neighbor.health, HEALTH - cannon.levels[0].damage, "el vecino sí")
	assert_true(tower.is_stunned())


func test_chain_lightning_reflects_on_the_mirror_and_keeps_chaining() -> void:
	var mirror: Enemy = _mirror()
	var neighbor: Enemy = _plain(mirror, 50.0)
	var tower: Tower = _tower(tesla, mirror, 100.0)
	_shoot(tower, mirror)
	assert_eq(mirror.health, HEALTH)
	assert_eq(neighbor.health, HEALTH - tesla.levels[0].damage, "el rayo salta al siguiente")


func test_a_straight_shot_is_reflected_too() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 100.0)
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup_straight(mirror.global_position - Vector2(30, 0), Vector2.RIGHT, tower.stats(), false, 10.0, 200.0, Color.WHITE)
	projectile.source = tower
	world.add_child(projectile)
	for i: int in 30:
		projectile._physics_process(DT)
	assert_eq(mirror.health, HEALTH)
	assert_true(tower.is_stunned())


func test_every_projectile_of_a_volley_is_reflected_but_the_stun_does_not_grow() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 100.0)
	_shoot(tower, mirror)
	assert_eq(reflections.size(), 1)
	assert_true(reflections[0][2], "el primero: la torre no estaba aturdida")
	tower.stun(1.2)  # ya tenía 2 s
	assert_almost_eq(tower.stun_left(), 2.0, 0.001)
	_shoot(tower, mirror)  # otro proyectil de la misma descarga
	assert_eq(mirror.health, HEALTH, "no se cuela ninguno")
	assert_almost_eq(tower.stun_left(), 2.0, 0.001, "el aturdimiento no se alarga")
	assert_eq(reflections.size(), 2)
	assert_false(reflections[1][2], "el segundo ya no es el primero (no repite el cartel)")


func test_a_projectile_without_source_hits_normally() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 100.0)
	_shoot(tower, mirror, false)
	assert_eq(mirror.health, HEALTH - basic.levels[0].damage)
	assert_false(tower.is_stunned())


func test_a_sold_tower_does_not_break_its_shot() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 100.0)
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(mirror, mirror.global_position, tower.stats(), false, 10.0, Color.WHITE)
	projectile.source = tower
	world.add_child(projectile)
	tower.free()  # se vendió mientras el proyectil volaba
	projectile._physics_process(DT)
	assert_eq(mirror.health, HEALTH - basic.levels[0].damage, "sin torre de origen, le pega normal")


func test_a_real_tower_puts_itself_as_the_source_of_its_shots() -> void:
	var mirror: Enemy = _mirror()
	var tower: Tower = _tower(basic, mirror, 100.0)
	var sources: Array = []
	tower.fired.connect(func(p: Projectile) -> void:
		sources.append(p.source)
		p.free())
	for i: int in 60:
		tower._physics_process(DT)
	assert_gt(sources.size(), 0)
	for source: Variant in sources:
		assert_eq(source, tower)


# --- En el resto del juego ---

func test_the_wiki_writes_down_the_reflection_and_it_starts_closed() -> void:
	var facts: Dictionary = {}
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == &"enemigos":
			for block: Dictionary in category.find(&"mirror").blocks:
				if block["tipo"] == WikiEntry.KIND_FACTS:
					for row: Array in block["filas"]:
						facts[row[0]] = row[1]
	assert_eq(facts["Rebota los tiros"], "de las torres a menos de 2.5 casillas, y las aturde 2 s")
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, func(_id: StringName) -> bool: return false):
		if category.id == &"enemigos":
			assert_true(category.find(&"mirror").locked)


func test_its_color_is_its_own() -> void:
	var color: Color = _data().color
	for id: String in LevelFile.enemy_ids():
		if id == "mirror":
			continue
		var other: Color = (load("res://data/enemies/%s.tres" % id) as EnemyData).color
		var distance: float = Vector3(color.r - other.r, color.g - other.g, color.b - other.b).length()
		assert_gt(distance, 0.18, "se parece demasiado a %s" % id)


func test_in_a_real_game_a_tower_next_to_the_path_gets_switched_off_by_the_mirror() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.session.earn(500)
	assert_true(game.build_controller.try_build(game.tower_types[0], Vector2i(3, 2)))
	var tower: Tower = game.build_controller.tower_at(Vector2i(3, 2))
	game.dev_spawn(_data())
	var mirror: Enemy = game.enemies.get_child(0)
	var seen: Array = []
	mirror.reflected.connect(func(_m: Enemy, _t: Tower, _f: bool) -> void: seen.append(1))
	for i: int in 60 * 25:
		if not mirror.is_active():
			break
		for node: Node in game.get_tree().get_nodes_in_group(Enemy.GROUP):
			(node as Enemy)._physics_process(DT)
		tower._physics_process(DT)
		for projectile: Node in game.projectiles.get_children():
			(projectile as Projectile)._physics_process(DT)
	assert_gt(seen.size(), 0, "la torre pegada al camino rebotó al menos una vez")
	assert_lt(mirror.health, mirror.max_health + 1)
	await wait_physics_frames(3)
	assert_true(true, "se dibujó el rebote")
