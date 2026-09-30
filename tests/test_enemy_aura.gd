# Tests de la mecánica del aura (T130, RF-270 a RF-273, D-042).
# Los enemigos no se mueven (velocidad 0): así las distancias entre ellos son las que se piden.
extends GutTest

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const DT: float = 1.0 / 60.0
## Un tramo recto del camino del nivel 1, lejos de las esquinas.
const BASE_DISTANCE: float = 200.0
const TILE: float = 64.0

var world: Node2D
var level: Level


func before_each() -> void:
	world = Node2D.new()
	add_child_autofree(world)
	level = GameFlow.level(0).build_map()
	world.add_child(level)


func _data(health: int = 100, armor: int = 0, regen: float = 0.0, flying: bool = false) -> EnemyData:
	var data := EnemyData.new()
	data.id = &"prueba"
	data.display_name = "Prueba"
	data.max_health = health
	data.speed_tiles = 0.0
	data.armor = armor
	data.regen_percent_per_second = regen
	data.is_flying = flying
	data.size_tiles = 0.3
	return data


func _emitter(radius: float, armor_bonus: int, heal: float = 0.0) -> EnemyData:
	var data: EnemyData = _data(200)
	data.aura_radius_tiles = radius
	data.aura_armor_bonus = armor_bonus
	data.aura_heal_percent_per_second = heal
	return data


## Un enemigo quieto a `tiles` casillas (por el camino) del punto de partida de la prueba.
func _spawn(data: EnemyData, tiles_from_base: float = 0.0, health: int = -1) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, level.get_ground_path(0), data.max_health)
	if health >= 0:
		enemy.health = health  # herido: la vida máxima sigue siendo la de los datos
	enemy.distance = BASE_DISTANCE + tiles_from_base * TILE
	world.add_child(enemy)
	return enemy


func _step(seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		for node: Node in get_tree().get_nodes_in_group(Enemy.GROUP):
			var enemy := node as Enemy
			if enemy.is_active():
				enemy._physics_process(DT)


# --- Los datos ---

func test_aura_data_is_off_by_default() -> void:
	var data := EnemyData.new()
	assert_eq(data.aura_radius_tiles, 0.0)
	assert_eq(data.aura_armor_bonus, 0)
	assert_eq(data.aura_heal_percent_per_second, 0.0)
	assert_false(_spawn(_data()).has_aura())
	assert_true(_spawn(_emitter(2.0, 2)).has_aura())
	assert_false(_spawn(_emitter(0.0, 2)).has_aura(), "sin radio no hay aura")
	assert_false(_spawn(_emitter(2.0, 0)).has_aura(), "sin nada que dar tampoco")


# --- Aura de armadura (RF-271) ---

func test_the_armor_bonus_reduces_the_damage_of_a_tower() -> void:
	var guardian: Enemy = _spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.5)
	_step(0.3)
	assert_eq(target.aura_armor(), 2)
	assert_eq(target.armor(), 2)
	target.take_hit(5)
	assert_eq(target.health, 97, "5 − 0 − 2 = 3 (criterio de aceptación)")
	assert_eq(guardian.aura_armor(), 0, "el portador no se da el aura a sí mismo")


func test_the_minimum_damage_still_applies() -> void:
	_spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.0)
	_step(0.3)
	target.take_hit(2)
	assert_eq(target.health, 99, "nunca menos de 1 (RF-80)")


func test_the_aura_adds_to_the_own_armor() -> void:
	_spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(100, 3), 1.0)
	_step(0.3)
	assert_eq(target.armor(), 5)
	target.take_hit(10)
	assert_eq(target.health, 95, "10 − (3 + 2)")


func test_only_enemies_inside_the_radius_get_it() -> void:
	_spawn(_emitter(2.0, 2))  # radio = 128 px
	var at_border: Enemy = _spawn(_data(), 1.97)
	var just_outside: Enemy = _spawn(_data(), 2.06)
	var far: Enemy = _spawn(_data(), 4.0)
	_step(0.3)
	assert_eq(at_border.aura_armor(), 2, "casi en el borde, adentro")
	assert_eq(just_outside.aura_armor(), 0, "un poquito más allá, afuera")
	assert_eq(far.aura_armor(), 0)


func test_the_aura_reaches_enemies_behind_and_flying_ones() -> void:
	_spawn(_emitter(2.0, 2), 0.0)
	var behind: Enemy = _spawn(_data(), -1.5)
	var flyer: Enemy = _spawn(_data(100, 0, 0.0, true), 1.0)
	_step(0.3)
	assert_eq(behind.aura_armor(), 2, "también a los que van atrás")
	assert_eq(flyer.aura_armor(), 2, "y a los voladores")


func test_burning_ignores_the_armor_of_the_aura() -> void:
	_spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.0)
	_step(0.3)
	target.apply_burn(4, 1.0)
	var before: int = target.health
	_step(1.0)
	assert_eq(before - target.health, 4, "2 por golpecito, dos golpecitos: el fuego no lo frena el escudo")


func test_two_armor_auras_do_not_add_up() -> void:
	_spawn(_emitter(2.0, 2), -0.5)
	_spawn(_emitter(2.0, 2), 0.5)
	var target: Enemy = _spawn(_data(), 0.0)
	_step(0.5)
	assert_eq(target.aura_armor(), 2, "dos guardianes iguales: sigue siendo +2")


func test_the_strongest_armor_aura_wins() -> void:
	_spawn(_emitter(2.0, 1), -0.5)
	_spawn(_emitter(2.0, 3), 0.5)
	var target: Enemy = _spawn(_data(), 0.0)
	_step(0.6)
	assert_eq(target.aura_armor(), 3)


# --- Caduca (RF-273) ---

func test_the_aura_fades_in_under_half_a_second_when_the_carrier_dies() -> void:
	var guardian: Enemy = _spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.5)
	_step(0.3)
	assert_eq(target.aura_armor(), 2)
	guardian.vanish()
	_step(0.1)
	assert_eq(target.aura_armor(), 2, "todavía dura un ratito")
	_step(0.4)
	assert_eq(target.aura_armor(), 0, "menos de medio segundo después, ya no")
	target.take_hit(5)
	assert_eq(target.health, 95, "vuelve a recibir los 5 (criterio de aceptación)")


func test_the_aura_fades_when_the_target_leaves_the_radius() -> void:
	_spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.0)
	_step(0.3)
	assert_eq(target.aura_armor(), 2)
	target.distance = BASE_DISTANCE + 5.0 * TILE
	_step(0.5)
	assert_eq(target.aura_armor(), 0)


func test_a_weak_aura_does_not_keep_a_dead_strong_one_alive() -> void:
	var strong: Enemy = _spawn(_emitter(2.0, 3), 0.5)
	_spawn(_emitter(2.0, 1), -0.5)
	var target: Enemy = _spawn(_data(), 0.0)
	_step(0.5)
	assert_eq(target.aura_armor(), 3)
	strong.vanish()
	_step(0.6)
	assert_eq(target.aura_armor(), 1, "cuando caduca la fuerte, entra la débil")


func test_time_stopped_means_aura_stopped() -> void:
	# En pausa el mundo no procesa: el aura no caduca ni se emite de más. Sin _physics_process no cambia nada.
	_spawn(_emitter(2.0, 2))
	var target: Enemy = _spawn(_data(), 1.0)
	_step(0.3)
	var armor: int = target.aura_armor()
	await wait_frames(3)  # pasan cuadros, pero nadie llamó a _physics_process a mano
	assert_eq(target.aura_armor(), armor)


# --- Aura de cura (RF-272) ---

func test_the_heal_aura_recovers_a_percent_of_max_health_per_second() -> void:
	_spawn(_emitter(2.5, 0, 10.0))
	var target: Enemy = _spawn(_data(100), 1.0, 50)
	_step(1.0)
	assert_between(target.health, 58, 61, "10 % de 100 por segundo, desde 50")
	assert_almost_eq(target.aura_heal(), 10.0, 0.001)


func test_the_heal_never_goes_over_the_maximum() -> void:
	_spawn(_emitter(2.5, 0, 10.0))
	var target: Enemy = _spawn(_data(100), 1.0, 95)
	_step(3.0)
	assert_eq(target.health, 100)


func test_the_heal_adds_to_the_own_regeneration() -> void:
	_spawn(_emitter(2.5, 0, 3.0))
	var troll: Enemy = _spawn(_data(100, 0, 4.0), 1.0, 30)
	_step(1.0)
	assert_between(troll.health, 36, 38, "4 % propio + 3 % del aura = 7 %")


func test_a_burning_enemy_is_not_healed_by_the_aura() -> void:
	_spawn(_emitter(2.5, 0, 10.0))
	var target: Enemy = _spawn(_data(100), 1.0, 50)
	_step(0.3)
	target.apply_burn(2, 2.0)
	var before: int = target.health
	_step(2.0)
	assert_lte(target.health, before, "mientras se quema no se cura (RF-165), solo baja por el fuego")


func test_the_carrier_is_not_healed_by_its_own_aura() -> void:
	var healer: Enemy = _spawn(_emitter(2.5, 0, 10.0), 0.0, 100)
	_step(1.0)
	assert_eq(healer.health, 100, "no se cura solo por su aura")
	assert_eq(healer.aura_heal(), 0.0)
	healer.take_hit(50)
	_step(1.0)
	assert_eq(healer.health, 50, "y herido tampoco se cura")


func test_one_carrier_can_give_armor_and_heal_at_once() -> void:
	_spawn(_emitter(2.0, 2, 5.0))
	var target: Enemy = _spawn(_data(100), 1.0, 60)
	_step(0.3)
	assert_eq(target.aura_armor(), 2)
	assert_almost_eq(target.aura_heal(), 5.0, 0.001)


func test_two_heal_auras_do_not_add_up() -> void:
	_spawn(_emitter(2.5, 0, 3.0), -0.5)
	_spawn(_emitter(2.5, 0, 3.0), 0.5)
	var target: Enemy = _spawn(_data(100), 0.0, 50)
	_step(1.0)
	assert_between(target.health, 52, 54, "3 % y no 6 %")
