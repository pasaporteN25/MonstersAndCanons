# Texto y Wiki de la Disruptora (T217, RF-450): todo sale de los datos.
extends GutTest

var disruptor: TowerData = load("res://data/towers/disruptor.tres")
var guardian: EnemyData = load("res://data/enemies/guardian.tres")
var healer: EnemyData = load("res://data/enemies/healer.tres")
var normal: EnemyData = load("res://data/enemies/normal.tres")


func test_pulse_line_is_built_from_the_numbers() -> void:
	assert_eq(TowerText.pulse_line(disruptor.levels[0]), "Pulso cada 4 s · radio 2,5 · apaga las auras 2,5 s · 5 de daño")
	assert_eq(TowerText.pulse_line(disruptor.levels[2]), "Pulso cada 4 s · radio 3,5 · apaga las auras 3,5 s · 5 de daño")


func test_pulse_line_follows_a_changed_number() -> void:
	var level: TowerLevelData = disruptor.levels[0].duplicate()
	level.suppress_seconds = 4.0
	level.fire_rate = 0.5
	assert_eq(TowerText.pulse_line(level), "Pulso cada 2 s · radio 2,5 · apaga las auras 4 s · 5 de daño")


func test_pulse_line_is_empty_for_a_common_tower() -> void:
	assert_eq(TowerText.pulse_line((load("res://data/towers/basic.tres") as TowerData).levels[0]), "")
	assert_eq(TowerText.effects((load("res://data/towers/basic.tres") as TowerData).levels[0]).size(), 0)


func test_the_panel_effects_include_the_pulse() -> void:
	var lines: Array[String] = TowerText.effects(disruptor.levels[0])
	assert_eq(lines[0], TowerText.pulse_line(disruptor.levels[0]))


func test_emitters_are_found_in_the_data_and_pluralized() -> void:
	var enemies: Array[EnemyData] = [normal, healer, guardian]
	assert_eq(TowerText.emitter_names(enemies), ["Guardianes", "Curanderos"], "por id: guardian antes que healer")
	var line: String = TowerText.pulse_line(disruptor.levels[0], TowerText.emitter_names(enemies))
	assert_string_contains(line, "Apaga el aura de Guardianes y Curanderos.")


func test_suppressors_are_listed_only_for_enemies_with_aura() -> void:
	var towers: Array[TowerData] = [disruptor, load("res://data/towers/tesla.tres")]
	assert_eq(TowerText.suppressors_of(guardian, towers), ["Disruptora"])
	assert_eq(TowerText.suppressors_of(healer, towers), ["Disruptora"])
	assert_eq(TowerText.suppressors_of(normal, towers), [])
	assert_eq(TowerText.suppressors_of(guardian, [load("res://data/towers/tesla.tres")] as Array[TowerData]), [])


func test_the_wiki_names_the_countermeasure_on_the_aura_enemies_only() -> void:
	var all: Array[EnemyData] = [normal, guardian, healer]
	var campaign: Array[LevelData] = []
	assert_string_contains(Wiki.enemy_entry(guardian, all, campaign).plain_text(), "Contramedida")
	assert_string_contains(Wiki.enemy_entry(healer, all, campaign).plain_text(), "Disruptora")
	assert_false(Wiki.enemy_entry(normal, all, campaign).plain_text().contains("Contramedida"))


func test_the_wiki_tower_entry_shows_pulse_and_limits() -> void:
	var text: String = Wiki.tower_entry(disruptor).plain_text()
	assert_string_contains(text, "Pulso cada 4 s")
	assert_string_contains(text, "No alcanza al Espejo y no apaga otras habilidades.")
	assert_string_contains(text, "130 de oro + 2 recursos")


func test_the_effects_article_explains_suppression_without_numbers() -> void:
	var entries: Array[WikiEntry] = Wiki.articles(Wiki.ARTICLES_DIR)["entries"]
	var found: String = ""
	for entry: WikiEntry in entries:
		if entry.title == "Efectos de las torres":
			found = entry.plain_text()
	assert_string_contains(found, "Supresión de auras")
	var section: String = found.substr(found.find("Supresión de auras"))
	var digits: RegEx = RegEx.create_from_string("[0-9]")
	assert_null(digits.search(section), "sin números: los números están en la entrada de la torre")
