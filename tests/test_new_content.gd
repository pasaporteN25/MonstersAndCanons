# Tests del contenido nuevo de M5 (spec §5.6 y §6.1): cada comportamiento es un dato (RF-164).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/enemy.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/towers/projectile.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const DT: float = 1.0 / 60.0

## Proyectiles que disparó la torre de prueba (_tower_at).
var shots: Array[Projectile] = []


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id)


func _enemy_data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


## Un enemigo caminando por un camino recto y largo (no llega a la salida en los tests).
func _walker(data: EnemyData, health: int, from := Vector2(100, 300)) -> Enemy:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(from)
	path.curve.add_point(from + Vector2(4000, 0))
	add_child_autofree(path)
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.setup(data, path, health)
	add_child_autofree(enemy)
	return enemy


func _seconds(node: Node, seconds: float) -> void:
	simulate(node, roundi(seconds / DT), DT)


func _assert_levels(id: String, expected: Array) -> void:
	var tower: TowerData = _tower(id)
	assert_eq(tower.levels.size(), 3, "%s: 3 niveles" % id)
	for i: int in expected.size():
		for field: String in expected[i]:
			assert_almost_eq(float(tower.levels[i].get(field)), float(expected[i][field]), 0.001,
				"%s, nivel %d: %s" % [id, i + 1, field])


# --- Incendiaria y quemadura (RF-160) ---

func test_fire_tower_matches_spec() -> void:
	var fire: TowerData = _tower("fire")
	assert_eq(fire.display_name, "Incendiaria")
	assert_true(fire.can_hit_air)
	_assert_levels("fire", [
		{"cost": 90, "damage": 5, "fire_rate": 1.0, "range_tiles": 2.5, "burn_damage_per_second": 8, "burn_duration": 3.0},
		{"cost": 90, "damage": 7, "burn_damage_per_second": 12, "burn_duration": 3.0},
		{"cost": 140, "damage": 10, "range_tiles": 3.0, "burn_damage_per_second": 18, "burn_duration": 4.0},
	])


func test_burn_deals_its_damage_per_second() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "6 por segundo: dos golpecitos de 3")
	_seconds(enemy, 2.0)
	assert_eq(enemy.health, 982, "3 segundos: 18 en total")
	assert_false(enemy.is_burning(), "se apagó")
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 982, "apagado, ya no quema")


func test_burn_ignores_armor() -> void:
	var enemy: Enemy = _walker(_enemy_data("armored"), 1000)  # armadura 3
	enemy.apply_burn(6, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "cada golpecito de 3 entra entero")


func test_burns_do_not_stack() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 3.0)
	enemy.apply_burn(6, 3.0)
	enemy.apply_burn(4, 3.0)
	_seconds(enemy, 1.0)
	assert_eq(enemy.health, 994, "queda la más fuerte (6), no la suma")


func test_a_new_burn_restarts_the_time() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000)
	enemy.apply_burn(6, 1.0)
	_seconds(enemy, 0.5)
	enemy.apply_burn(6, 1.0)  # ahora dura hasta el segundo 1,5
	_seconds(enemy, 1.5)
	assert_eq(enemy.health, 991, "tres golpecitos: 0,5 s, 1 s y 1,5 s")


func test_burning_to_death_counts_as_a_kill() -> void:
	var enemy: Enemy = _walker(_enemy_data("normal"), 5)
	watch_signals(enemy)
	enemy.apply_burn(10, 3.0)
	_seconds(enemy, 0.6)
	assert_signal_emitted(enemy, "died", "RF-81: da su oro como cualquier muerte")


func test_fire_projectile_sets_the_enemy_on_fire() -> void:
	var enemy: Enemy = _walker(_enemy_data("tank"), 1000, Vector2(200, 300))
	var fire: TowerData = _tower("fire")
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(enemy, Vector2(200, 200), fire.levels[0], true, fire.projectile_speed_tiles, fire.color,
		fire.projectile_texture)
	add_child_autofree(projectile)
	_seconds(projectile, 0.5)
	assert_true(enemy.is_burning(), "RF-160")
	assert_eq(enemy.health, 995, "el golpe hizo 5 (la quemadura todavía no)")
	await wait_process_frames(2)  # se dibujan las llamitas sin errores


# --- Troll y regeneración (RF-165) ---

func test_troll_matches_spec() -> void:
	var troll: EnemyData = _enemy_data("troll")
	assert_eq([troll.max_health, troll.armor, troll.reward, troll.lives_damage], [70, 0, 10, 2])
	assert_almost_eq(troll.speed_tiles, 1.0, 0.001)
	assert_almost_eq(troll.regen_percent_per_second, 4.0, 0.001)
	assert_almost_eq(troll.size_tiles, 0.32, 0.001)
	assert_false(troll.is_flying)


func test_troll_regenerates_a_percent_per_second() -> void:
	var troll: Enemy = _walker(_enemy_data("troll"), 100)
	troll.take_hit(50)
	_seconds(troll, 1.0)
	assert_eq(troll.health, 54, "4 % de 100 por segundo")
	_seconds(troll, 1.0)
	assert_eq(troll.health, 58)


func test_regeneration_stops_at_max_health() -> void:
	var troll: Enemy = _walker(_enemy_data("troll"), 100)
	troll.take_hit(2)
	_seconds(troll, 3.0)
	assert_eq(troll.health, 100, "nunca más que su vida máxima")


func test_burning_troll_does_not_regenerate() -> void:
	var troll: Enemy = _walker(_enemy_data("troll"), 100)
	troll.take_hit(50)
	troll.apply_burn(2, 2.0)  # 1 por golpecito
	_seconds(troll, 2.0)
	assert_eq(troll.health, 46, "RF-165: quemándose solo pierde vida (4 golpecitos de 1)")
	_seconds(troll, 1.0)
	assert_eq(troll.health, 50, "apagado, vuelve a curarse")


func test_healing_is_reported_at_most_once_per_second() -> void:
	var troll: Enemy = _walker(_enemy_data("troll"), 100)
	watch_signals(troll)
	troll.take_hit(50)
	_seconds(troll, 2.5)
	assert_signal_emit_count(troll, "healed", 2, "un \"+N\" por segundo, no uno por cuadro")
	assert_signal_emitted_with_parameters(troll, "healed", [troll, 4])


# --- Araña y Crías (RF-166) ---

## Una partida con una oleada de una sola Araña, ya en el mapa.
func _spider_game() -> Game:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	var group := SpawnGroup.new()
	group.enemy = _enemy_data("spider")
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.session.begin_wave()
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game


func _alive(game: Game) -> Array[Enemy]:
	var list: Array[Enemy] = []
	for node: Node in game.enemies.get_children():
		if (node as Enemy).is_active():
			list.append(node as Enemy)
	return list


func test_spider_and_spiderling_match_spec() -> void:
	var spider: EnemyData = _enemy_data("spider")
	assert_eq([spider.max_health, spider.reward, spider.lives_damage], [60, 6, 2])
	assert_almost_eq(spider.speed_tiles, 1.2, 0.001)
	assert_eq(spider.death_spawn, _enemy_data("spiderling"))
	assert_eq(spider.death_spawn_count, 4)
	var kid: EnemyData = _enemy_data("spiderling")
	assert_eq([kid.max_health, kid.reward, kid.lives_damage], [8, 1, 1])
	assert_almost_eq(kid.speed_tiles, 2.4, 0.001)
	assert_null(kid.death_spawn, "las crías no sueltan más crías")


func test_spider_leaves_four_spiderlings_where_it_died() -> void:
	var game: Game = _spider_game()
	var spider: Enemy = _alive(game)[0]
	simulate(spider, 60, DT)  # camina un segundo
	var died_at: float = spider.distance
	spider.take_hit(100000)
	var kids: Array[Enemy] = _alive(game)
	assert_eq(kids.size(), 4, "RF-166")
	for kid: Enemy in kids:
		assert_eq(kid.data.id, &"spiderling")
		assert_between(kid.distance, died_at - 31.0, died_at + 0.1, "en su lugar, un poco hacia atrás")
		assert_eq(kid.max_health, 8, "vida de la oleada 1")
		assert_eq(kid.path(), spider.path(), "siguen el mismo camino")


func test_wave_ends_only_when_the_spiderlings_die() -> void:
	var game: Game = _spider_game()
	watch_signals(game.spawner)
	_alive(game)[0].take_hit(100000)
	await wait_process_frames(2)  # la madre ya dejó el árbol
	assert_signal_not_emitted(game.spawner, "wave_finished", "quedan 4 crías vivas")
	for kid: Enemy in _alive(game):
		kid.take_hit(100000)
	await wait_process_frames(2)
	assert_signal_emitted(game.spawner, "wave_finished", "RF-33: ahora sí")


func test_spider_reaching_the_exit_leaves_nothing() -> void:
	var game: Game = _spider_game()
	var spider: Enemy = _alive(game)[0]
	spider.distance = spider.path().curve.get_baked_length() - 1.0
	simulate(spider, 5, DT)
	assert_eq(_alive(game).size(), 0, "RF-166: solo suelta crías si muere por daño")


# --- Torres de prueba: una torre y enemigos parados en un mismo camino ---

## Enemigos sobre UN camino recto (y = 300), a esas distancias del comienzo (x = distancia).
## Se congelan (process_mode) para que no se muevan mientras la torre dispara.
func _enemies_at(distances: Array, data: EnemyData = null) -> Array[Enemy]:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(0, 300))
	path.curve.add_point(Vector2(4000, 300))
	add_child_autofree(path)
	var list: Array[Enemy] = []
	for d: float in distances:
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.setup(data if data != null else _enemy_data("tank"), path, 1000)
		enemy.distance = d
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		add_child_autofree(enemy)
		list.append(enemy)
	return list


## Una torre en `at`, en el nivel `level` (1 a 3). Sus proyectiles se guardan en `shots`.
func _tower_at(id: String, at: Vector2, level: int = 1) -> Tower:
	shots.clear()
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(_tower(id))
	for i: int in level - 1:
		tower.apply_upgrade()
	tower.position = at
	tower.fired.connect(func(p: Projectile) -> void:
		shots.append(p)
		add_child_autofree(p))
	add_child_autofree(tower)
	return tower


func _shot_targets() -> Array[Enemy]:
	var targets: Array[Enemy] = []
	for p: Projectile in shots:
		targets.append(p._target)
	return targets


# --- Múltiple (RF-161) ---

func test_multi_tower_matches_spec() -> void:
	assert_eq(_tower("multi").display_name, "Múltiple")
	_assert_levels("multi", [
		{"cost": 100, "damage": 7, "fire_rate": 1.3, "range_tiles": 3.0, "extra_targets": 1},
		{"cost": 90, "damage": 9, "fire_rate": 1.3, "extra_targets": 2},
		{"cost": 140, "damage": 12, "fire_rate": 1.3, "range_tiles": 3.5, "extra_targets": 3},
	])


func test_multi_shoots_its_two_best_targets_at_once() -> void:
	var e: Array[Enemy] = _enemies_at([200.0, 250.0, 300.0, 350.0, 400.0])
	var tower: Tower = _tower_at("multi", Vector2(300, 250))
	simulate(tower, 1, DT)
	assert_eq(shots.size(), 2, "nivel 1: a 2 enemigos")
	assert_eq(_shot_targets(), [e[4], e[3]] as Array[Enemy], "los dos más cerca de la salida (\"Primero\")")


func test_multi_level_3_shoots_four() -> void:
	_enemies_at([200.0, 250.0, 300.0, 350.0, 400.0])
	var tower: Tower = _tower_at("multi", Vector2(300, 250), 3)
	simulate(tower, 1, DT)
	assert_eq(shots.size(), 4)


func test_multi_with_one_enemy_shoots_once() -> void:
	var e: Array[Enemy] = _enemies_at([300.0])
	var tower: Tower = _tower_at("multi", Vector2(300, 250))
	simulate(tower, 1, DT)
	assert_eq(_shot_targets(), [e[0]] as Array[Enemy])


# --- Ráfaga (RF-162) ---

func _run_shots(seconds: float) -> void:
	for i: int in roundi(seconds / DT):
		for p: Projectile in shots:
			if is_instance_valid(p):
				p._physics_process(DT)


func test_burst_tower_matches_spec() -> void:
	var burst: TowerData = _tower("burst")
	assert_eq(burst.display_name, "Ráfaga")
	assert_false(burst.can_hit_air, "no le pega a los voladores")
	assert_almost_eq(burst.projectile_speed_tiles, 6.0, 0.001)
	_assert_levels("burst", [
		{"cost": 110, "damage": 10, "fire_rate": 0.8, "range_tiles": 2.0, "burst_count": 8},
		{"cost": 100, "damage": 13, "fire_rate": 0.9, "burst_count": 10},
		{"cost": 150, "damage": 17, "fire_rate": 1.0, "range_tiles": 2.5, "burst_count": 12},
	])


func test_burst_fires_eight_spikes_evenly_around() -> void:
	_enemies_at([400.0])
	var tower: Tower = _tower_at("burst", Vector2(300, 300))
	simulate(tower, 1, DT)
	assert_eq(shots.size(), 8)
	var angles: Array[float] = []
	for p: Projectile in shots:
		assert_true(p.is_straight(), "en línea recta, no persiguen")
		angles.append(fposmod(p._direction.angle(), TAU))
	angles.sort()
	for i: int in range(1, angles.size()):
		assert_almost_eq(angles[i] - angles[i - 1], TAU / 8.0, 0.001, "repartidas en círculo")


func test_burst_does_not_fire_without_enemies_in_range() -> void:
	_enemies_at([3000.0])  # lejísimos
	var tower: Tower = _tower_at("burst", Vector2(300, 300))
	simulate(tower, 5, DT)
	assert_eq(shots.size(), 0)


func test_each_spike_hits_only_the_first_enemy_it_touches() -> void:
	# Dos enemigos en fila a la derecha y uno a la izquierda de la torre.
	var e: Array[Enemy] = _enemies_at([200.0, 360.0, 400.0])
	var tower: Tower = _tower_at("burst", Vector2(300, 300))
	tower.aim_angle = -PI / 8.0  # al disparar gira PI/8: una púa sale justo a la derecha y otra a la izquierda
	simulate(tower, 1, DT)
	_run_shots(1.5)
	assert_eq(e[0].health, 1000 - 10, "el de la izquierda recibe una púa")
	var right_hits: int = (1000 - e[1].health) + (1000 - e[2].health)
	assert_eq(right_hits, 10, "a la derecha, una sola púa: golpea al primero y desaparece")
	for p: Projectile in shots:
		assert_true(p._is_done, "las púas que no tocaron a nadie se perdieron")


func test_burst_spikes_ignore_flyers() -> void:
	# A la derecha: un volador y, detrás, uno de tierra. La púa atraviesa al volador.
	var flyer: Enemy = _enemies_at([350.0], _enemy_data("flyer"))[0]
	var walker: Enemy = _enemies_at([410.0])[0]
	var tower: Tower = _tower_at("burst", Vector2(300, 300))
	tower.aim_angle = -PI / 8.0
	simulate(tower, 1, DT)
	_run_shots(1.5)
	assert_eq(flyer.health, 1000, "RF-53: al volador no le pega")
	assert_eq(walker.health, 990, "sigue de largo y le pega al de tierra")


# --- Eléctrica (RF-163) ---

## La torre dispara y el rayo llega (va a 20 casillas por segundo). Devuelve los puntos
## del zigzag (vacío si no saltó).
func _fire_tesla(at: Vector2) -> PackedVector2Array:
	var tower: Tower = _tower_at("tesla", at)
	simulate(tower, 1, DT)
	# Una lista y no una variable suelta: las funciones anónimas copian las variables locales.
	var chains: Array[PackedVector2Array] = []
	for p: Projectile in shots:
		p.chained.connect(func(points: PackedVector2Array) -> void: chains.append(points))
	_run_shots(0.5)
	return chains[0] if not chains.is_empty() else PackedVector2Array()


func _damaged(enemies: Array[Enemy]) -> Array[bool]:
	var result: Array[bool] = []
	for e: Enemy in enemies:
		result.append(e.health < 1000)
	return result


func test_tesla_tower_matches_spec() -> void:
	var tesla: TowerData = _tower("tesla")
	assert_eq(tesla.display_name, "Eléctrica")
	assert_true(tesla.can_hit_air)
	assert_almost_eq(tesla.projectile_speed_tiles, 20.0, 0.001)
	_assert_levels("tesla", [
		{"cost": 130, "damage": 13, "fire_rate": 0.75, "range_tiles": 2.5, "chain_extra_targets": 2, "chain_range_tiles": 1.5},
		{"cost": 120, "damage": 19, "fire_rate": 0.85, "chain_extra_targets": 3},
		{"cost": 180, "damage": 27, "fire_rate": 0.95, "range_tiles": 3.0, "chain_extra_targets": 4},
	])


func test_lightning_jumps_to_the_two_nearest() -> void:
	var e: Array[Enemy] = _enemies_at([300.0, 340.0, 380.0, 420.0])
	var chain: PackedVector2Array = _fire_tesla(Vector2(360, 250))
	assert_eq(_damaged(e), [false, true, true, true], "el primero (420) y dos saltos: 380 y 340")
	assert_eq(e[3].health, 987, "cada salto hace el mismo daño (13)")
	assert_eq(e[1].health, 987)
	assert_eq(chain.size(), 3, "el zigzag une a los 3 golpeados")


func test_lightning_never_hits_the_same_enemy_twice() -> void:
	var e: Array[Enemy] = _enemies_at([340.0, 380.0])
	_fire_tesla(Vector2(360, 250))
	assert_eq([e[0].health, e[1].health], [987, 987], "cada uno una sola vez, aunque sobren saltos")


func test_lightning_does_not_jump_too_far() -> void:
	var e: Array[Enemy] = _enemies_at([300.0, 420.0])  # a 120 px: más que 1,5 casillas (96 px)
	var chain: PackedVector2Array = _fire_tesla(Vector2(360, 250))
	assert_eq(_damaged(e), [false, true], "solo el objetivo")
	assert_eq(chain.size(), 0, "sin saltos no hay zigzag")
