# Revisa TODO el contenido de data/ (T85, RF-164, D-025). Recorre las carpetas solo: si se
# agrega un enemigo, una torre o un nivel y le falta algo, estos tests dicen qué y dónde.
# Los números de cada pieza (que coincidan con la spec) se revisan en test_data_files y
# test_new_content; aquí solo se revisa que cada pieza esté COMPLETA y sea coherente.
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
## RF-170: la barra y las teclas 1–8 no admiten más.
const MAX_TOWERS: int = 8


func _resources_in(dir: String) -> Array[Resource]:
	var list: Array[Resource] = []
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".tres"):
			list.append(load(dir + file))
	return list


func _file_id(resource: Resource) -> String:
	return resource.resource_path.get_file().get_basename()


# --- Enemigos (data/enemies/) ---

func test_every_enemy_is_complete() -> void:
	var enemies: Array[Resource] = _resources_in("res://data/enemies/")
	assert_gt(enemies.size(), 0)
	for resource: Resource in enemies:
		var e := resource as EnemyData
		var who: String = "enemigo '%s'" % _file_id(e)
		assert_eq(String(e.id), _file_id(e), who + ": el id es el nombre del archivo")
		assert_ne(e.display_name, "", who + ": nombre")
		assert_ne(e.description, "", who + ": frase de presentación (RF-134)")
		assert_not_null(e.texture, who + ": dibujo (RF-151)")
		assert_gt(e.max_health, 0, who + ": vida")
		assert_gt(e.speed_tiles, 0.0, who + ": velocidad")
		assert_gte(e.reward, 0, who + ": oro")
		assert_gte(e.lives_damage, 1, who + ": vidas que quita")
		assert_between(e.size_tiles, 0.05, 0.5, who + ": tamaño (tiene que caber en el camino)")
		assert_between(e.regen_percent_per_second, 0.0, 100.0, who + ": regeneración")
		if e.death_spawn_count > 0:
			assert_not_null(e.death_spawn, who + ": dice cuántas crías suelta, pero no cuáles")


func test_death_spawns_never_loop() -> void:
	# Una Araña que suelta Arañas que sueltan Arañas… nunca terminaría la oleada.
	for resource: Resource in _resources_in("res://data/enemies/"):
		var chain: Array[EnemyData] = [resource as EnemyData]
		while chain[-1].death_spawn != null and chain.size() <= 10:
			chain.append(chain[-1].death_spawn)
		assert_lte(chain.size(), 10, "enemigo '%s': sus crías sueltan crías sin fin" % _file_id(resource))


# --- Torres (data/towers/) ---

func test_every_tower_is_complete() -> void:
	var towers: Array[Resource] = _resources_in("res://data/towers/")
	assert_gt(towers.size(), 0)
	for resource: Resource in towers:
		var t := resource as TowerData
		var who: String = "torre '%s'" % _file_id(t)
		assert_eq(String(t.id), _file_id(t), who + ": el id es el nombre del archivo")
		assert_ne(t.display_name, "", who + ": nombre")
		assert_ne(t.description, "", who + ": frase (RF-171)")
		assert_not_null(t.turret_texture, who + ": dibujo de la torreta (RF-150)")
		assert_not_null(t.projectile_texture, who + ": dibujo del proyectil (RF-153)")
		assert_gt(t.projectile_speed_tiles, 0.0, who + ": velocidad del proyectil")
		assert_true(Audio.has_sound(StringName("shot_%s" % t.id)), who + ": sonido shot_%s.wav (RF-116)" % t.id)
		assert_eq(t.levels.size(), 3, who + ": 3 niveles (RF-71)")
		for i: int in t.levels.size():
			var l: TowerLevelData = t.levels[i]
			var lvl: String = "%s, nivel %d" % [who, i + 1]
			assert_gt(l.cost, 0, lvl + ": costo")
			assert_gt(l.damage, 0, lvl + ": daño")
			assert_gt(l.fire_rate, 0.0, lvl + ": cadencia")
			assert_gt(l.range_tiles, 0.0, lvl + ": alcance")
			assert_not_null(l.base_texture, lvl + ": dibujo de la base")
			if l.burn_damage_per_second > 0:
				assert_gt(l.burn_duration, 0.0, lvl + ": quema, pero no dice cuánto dura")
			if l.chain_extra_targets > 0:
				assert_gt(l.chain_range_tiles, 0.0, lvl + ": el rayo salta, pero no dice hasta dónde")


func test_every_tower_is_in_the_game() -> void:
	var game: Game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	var ids: Array[StringName] = []
	for tower: TowerData in game.tower_types:
		ids.append(tower.id)
	for resource: Resource in _resources_in("res://data/towers/"):
		assert_has(ids, (resource as TowerData).id,
			"torre '%s': falta agregarla a Game → Tower Types (game.tscn)" % _file_id(resource))
	assert_lte(game.tower_types.size(), MAX_TOWERS, "RF-170: entran hasta 8 torres (teclas 1–8)")


# --- Niveles (data/levels/) ---

func test_every_level_is_complete_and_in_the_campaign() -> void:
	var campaign: CampaignData = load("res://data/campaign.tres")
	for resource: Resource in _resources_in("res://data/levels/"):
		var l := resource as LevelData
		var who: String = "nivel '%s'" % _file_id(l)
		assert_eq(String(l.id), _file_id(l), who + ": el id es el nombre del archivo")
		assert_has(campaign.levels, l, who + ": está en la campaña (tools/make_levels.gd la arma)")
		assert_ne(l.display_name, "", who + ": nombre")
		assert_not_null(l.map_scene, who + ": mapa")
		assert_gt(l.starting_gold, 0, who + ": oro inicial")
		assert_gt(l.starting_lives, 0, who + ": vidas")
		assert_gt(l.waves.size(), 0, who + ": oleadas")
		for w: int in l.waves.size():
			assert_gt(l.waves[w].groups.size(), 0, "%s, oleada %d: tiene enemigos" % [who, w + 1])
			for group: SpawnGroup in l.waves[w].groups:
				assert_not_null(group.enemy, "%s, oleada %d: grupo sin enemigo" % [who, w + 1])
				assert_gt(group.count, 0, "%s, oleada %d: cantidad" % [who, w + 1])
				assert_gte(group.interval, 0.0, "%s, oleada %d: intervalo" % [who, w + 1])
