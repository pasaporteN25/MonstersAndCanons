# Tests del modelo de la wiki (T110, RF-233, RF-234, RF-237, D-035).
extends GutTest


func _category(id: StringName) -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == id:
			return category
	return null


func _facts(entry: WikiEntry) -> Dictionary:
	var facts: Dictionary = {}
	for block: Dictionary in entry.blocks:
		if block["tipo"] == WikiEntry.KIND_FACTS:
			for row: Array in block["filas"]:
				facts[row[0]] = row[1]
	return facts


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id) as EnemyData


# --- Enemigos ---

func test_there_is_one_entry_per_enemy_file() -> void:
	var enemies: WikiCategory = _category(&"enemigos")
	assert_not_null(enemies)
	assert_eq(enemies.entries.size(), LevelFile.enemy_ids().size())
	for id: String in LevelFile.enemy_ids():
		assert_not_null(enemies.find(StringName(id)), "falta el enemigo %s" % id)


func test_enemies_go_from_weakest_to_strongest() -> void:
	var previous: int = -1
	for entry: WikiEntry in _category(&"enemigos").entries:
		var health: int = _enemy(String(entry.id)).max_health
		assert_gte(health, previous, "%s está fuera de orden" % entry.id)
		previous = health


func test_enemy_numbers_come_from_the_data() -> void:
	# RF-237: nada escrito a mano. Si se rebalancea el jefe, la wiki cambia sola.
	var boss: EnemyData = _enemy("boss")
	var entry: WikiEntry = _category(&"enemigos").find(&"boss")
	var facts: Dictionary = _facts(entry)
	assert_eq(facts["Vida (oleada 1)"], str(boss.max_health))
	assert_eq(facts["Oro al morir"], str(boss.reward))
	assert_eq(facts["Vidas que quita"], str(boss.lives_damage))
	assert_eq(facts["Armadura"], str(boss.armor))
	assert_eq(entry.title, boss.display_name)
	assert_string_contains(entry.plain_text(), boss.description)


func test_a_flying_or_dangerous_enemy_says_so() -> void:
	var flyer: WikiEntry = _category(&"enemigos").find(&"flyer")
	assert_eq(flyer.subtitle, "Vuela")
	assert_eq(_facts(flyer)["Vuela"], "sí")
	var boss: WikiEntry = _category(&"enemigos").find(&"boss")
	assert_string_contains(boss.subtitle, "Peligroso")
	assert_eq(_category(&"enemigos").find(&"normal").subtitle, "Terrestre")


func test_enemy_extras_only_show_when_they_apply() -> void:
	var normal: Dictionary = _facts(_category(&"enemigos").find(&"normal"))
	assert_false(normal.has("Se cura"))
	assert_false(normal.has("Al morir suelta"))
	var troll: Dictionary = _facts(_category(&"enemigos").find(&"troll"))
	assert_true(troll.has("Se cura"), "el Troll se cura solo")
	var boss: Dictionary = _facts(_category(&"enemigos").find(&"boss"))
	assert_true(boss.has("Resistencia a la ralentización"))


func test_the_spider_says_what_it_drops_and_the_spiderling_who_drops_it() -> void:
	var spider: WikiEntry = _category(&"enemigos").find(&"spider")
	var spawn: EnemyData = _enemy("spider").death_spawn
	assert_eq(_facts(spider)["Al morir suelta"], "%d × %s" % [_enemy("spider").death_spawn_count, spawn.display_name])
	var spiderling: WikiEntry = _category(&"enemigos").find(&"spiderling")
	assert_string_contains(spiderling.plain_text(), "Lo suelta al morir: %s" % _enemy("spider").display_name)


func test_where_an_enemy_appears_uses_the_campaign_it_is_given() -> void:
	var normal: EnemyData = _enemy("normal")
	var tank: EnemyData = _enemy("tank")
	var group := SpawnGroup.new()
	group.enemy = tank
	var wave := WaveData.new()
	wave.groups = [group]
	var first := LevelData.new()
	first.display_name = "Uno"
	var second := LevelData.new()
	second.display_name = "Dos"
	second.waves = [wave]
	var campaign: Array[LevelData] = [first, second]
	var all: Array[EnemyData] = [normal, tank]
	assert_string_contains(Wiki.enemy_entry(tank, all, campaign).plain_text(), "Nivel 2 · Dos")
	assert_string_contains(Wiki.enemy_entry(normal, all, campaign).plain_text(), "No aparece en la campaña.")
	assert_false(Wiki.enemy_entry(tank, all, campaign).plain_text().contains("Nivel 1"))


func test_every_official_enemy_appears_in_some_level_or_is_dropped() -> void:
	# Un enemigo que no aparece en ningún lado no debería existir: la wiki lo delataría.
	# Salvo los que todavía no debutaron: el Guardián y el Curandero entran en los niveles 8 y 9 (D-041).
	# Cuando debuten, esta lista se vacía.
	var not_yet: Array = [&"guardian", &"healer"]
	for entry: WikiEntry in _category(&"enemigos").entries:
		if not_yet.has(entry.id):
			continue
		var text: String = entry.plain_text()
		assert_true(text.contains("Nivel ") or text.contains("Lo suelta al morir"), "%s no aparece en ningún lado" % entry.id)


# --- Torres ---

func _tower_files() -> int:
	var count: int = 0
	for file: String in DirAccess.get_files_at(Wiki.TOWERS_DIR):
		if file.trim_suffix(".remap").ends_with(".tres"):
			count += 1
	return count


func test_there_is_one_entry_per_tower_file() -> void:
	assert_eq(_category(&"torres").entries.size(), _tower_files())


func test_towers_go_from_cheapest_to_most_expensive() -> void:
	var previous: int = -1
	for entry: WikiEntry in _category(&"torres").entries:
		var cost: int = (load("res://data/towers/%s.tres" % entry.id) as TowerData).levels[0].cost
		assert_gte(cost, previous, "%s está fuera de orden" % entry.id)
		previous = cost


func test_the_tower_table_has_one_row_per_level_with_the_real_numbers() -> void:
	var data: TowerData = load("res://data/towers/cannon.tres")
	var entry: WikiEntry = _category(&"torres").find(&"cannon")
	var table: Array = []
	for block: Dictionary in entry.blocks:
		if block["tipo"] == WikiEntry.KIND_TABLE:
			table = block["filas"]
	assert_eq(table.size(), data.levels.size() + 1, "el encabezado y un renglón por nivel")
	assert_eq(table[0][0], "Nivel")
	assert_eq(table[1][1], str(data.levels[0].cost))
	assert_eq(table[2][2], str(data.levels[1].damage))
	assert_eq(table[1][0], "1 (construir)")
	assert_eq(table[2][0], "2 (mejorar)")


func test_a_tower_lists_its_effects_and_whether_it_hits_air() -> void:
	var fire: WikiEntry = _category(&"torres").find(&"fire")
	assert_string_contains(fire.plain_text(), "Quema")
	var tesla: WikiEntry = _category(&"torres").find(&"tesla")
	assert_string_contains(tesla.plain_text(), "rayo salta")
	var cannon: WikiEntry = _category(&"torres").find(&"cannon")
	assert_eq(_facts(cannon)["Golpea voladores"], "no")
	assert_eq(cannon.subtitle, "Solo terrestres")


func test_a_tower_entry_has_its_drawing_layers() -> void:
	var entry: WikiEntry = _category(&"torres").find(&"basic")
	assert_eq(entry.icon.size(), 2, "base y torreta")
	for texture: Texture2D in entry.icon:
		assert_not_null(texture)


func test_every_entry_has_a_title_a_drawing_and_something_to_read() -> void:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		var ids: Dictionary = {}
		for entry: WikiEntry in category.entries:
			assert_ne(entry.title, "", "%s sin título" % entry.id)
			assert_false(entry.blocks.is_empty(), "%s sin contenido" % entry.id)
			assert_false(ids.has(entry.id), "id repetido: %s" % entry.id)
			ids[entry.id] = true
			if category.id != &"guia":
				assert_false(entry.icon.is_empty(), "%s sin dibujo" % entry.id)


func test_an_empty_category_is_left_out() -> void:
	for category: WikiCategory in Wiki.categories([]):
		assert_false(category.entries.is_empty())


# --- TowerText (compartido con el panel de la torre) ---

func test_tower_text_describes_a_level() -> void:
	var fire: TowerData = load("res://data/towers/fire.tres")
	var text: String = TowerText.describe(fire.levels[0], fire.can_hit_air)
	assert_string_contains(text, "Daño: %d" % fire.levels[0].damage)
	assert_string_contains(text, "Quema: %d por segundo" % fire.levels[0].burn_damage_per_second)
	assert_string_contains(text, "Golpea voladores: %s" % ("sí" if fire.can_hit_air else "no"))
	var basic: TowerData = load("res://data/towers/basic.tres")
	assert_true(TowerText.effects(basic.levels[0]).is_empty(), "la Ametralladora no tiene efectos")
