# Tests de los datos del consejo de derrota (T420, M70: RF-632 y RF-638): el lector `AdviceData`, los criterios de
# torre, las condiciones de enemigo y el archivo oficial `data/consejos/consejos.json` contra los datos reales.
extends GutTest


func _raw(overrides: Dictionary = {}) -> Dictionary:
	var raw: Dictionary = {
		"version": 1, "borrador": true,
		"ajustes": {"peso_oleada": 0.25, "participacion_minima_pct": 30, "vidas_minimas": 3, "max_torres": 2, "max_caracteres": 96},
		"criterios": {"aire": {"golpea_aire": true, "danio_min": 5}},
		"reglas": [{"id": "volador", "enemigo": {"vuela": true}, "torres": ["aire"], "texto": "Voladores: {torres}."}],
	}
	for key: String in overrides:
		raw[key] = overrides[key]
	return raw


func _errors_text(raw: Variant) -> String:
	return "\n".join(AdviceData.parse(raw).errors)


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id)


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


func _all(dir_path: String) -> Array:
	var result: Array = []
	for file_name: String in DirAccess.get_files_at(dir_path):
		var res_name: String = file_name.trim_suffix(".remap")
		if res_name.ends_with(".tres"):
			result.append(load("%s/%s" % [dir_path, res_name]))
	return result


# --- El formato ---

func test_a_valid_file_has_no_errors() -> void:
	var data: AdviceData = AdviceData.parse(_raw())
	assert_eq(data.errors.size(), 0, "\n".join(data.errors))
	assert_true(data.is_valid())
	assert_eq(data.rules.size(), 1)
	assert_eq(data.max_towers, 2)


func test_not_an_object_is_an_error() -> void:
	assert_false(AdviceData.parse([]).is_valid())
	assert_string_contains(_errors_text(42), "objeto")


func test_missing_file_is_an_error_and_never_crashes() -> void:
	var data: AdviceData = AdviceData.load_file("res://data/consejos/no_existe.json")
	assert_false(data.is_valid())
	assert_string_contains("\n".join(data.errors), "no existe")


func test_wrong_version_and_missing_draft() -> void:
	assert_string_contains(_errors_text(_raw({"version": 2})), "version")
	assert_string_contains(_errors_text(_raw({"borrador": "si"})), "borrador")


func test_settings_are_checked() -> void:
	var settings: Dictionary = {"peso_oleada": 0.25, "participacion_minima_pct": 130, "vidas_minimas": 3, "max_torres": 2, "max_caracteres": 96}
	assert_string_contains(_errors_text(_raw({"ajustes": settings})), "participacion_minima_pct")
	settings["participacion_minima_pct"] = 30
	settings["extra"] = 1
	assert_string_contains(_errors_text(_raw({"ajustes": settings})), "extra")
	assert_string_contains(_errors_text(_raw({"ajustes": {}})), "ajustes")
	settings.erase("extra")
	settings["max_torres"] = 0
	assert_string_contains(_errors_text(_raw({"ajustes": settings})), "max_torres")


func test_unknown_criterion_is_named() -> void:
	var raw: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": true}, "torres": ["no_existe"], "texto": "A {torres}."}]})
	var text: String = _errors_text(raw)
	assert_string_contains(text, "no_existe")
	assert_string_contains(text, "\"x\"")


func test_rule_without_placeholder_text_or_enemy_is_an_error() -> void:
	var no_placeholder: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": true}, "torres": ["aire"], "texto": "Sin marcador."}]})
	assert_string_contains(_errors_text(no_placeholder), "{torres}")
	var no_text: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": true}, "torres": ["aire"]}]})
	assert_string_contains(_errors_text(no_text), "texto")
	var no_enemy: Dictionary = _raw({"reglas": [{"id": "x", "torres": ["aire"], "texto": "A {torres}."}]})
	assert_string_contains(_errors_text(no_enemy), "enemigo")
	var no_towers: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": true}, "texto": "A {torres}."}]})
	assert_string_contains(_errors_text(no_towers), "torres")


func test_unknown_or_badly_typed_conditions_are_errors() -> void:
	var bad_enemy: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"raro": true}, "torres": ["aire"], "texto": "A {torres}."}]})
	assert_string_contains(_errors_text(bad_enemy), "raro")
	var false_enemy: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": false}, "torres": ["aire"], "texto": "A {torres}."}]})
	assert_string_contains(_errors_text(false_enemy), "vuela")
	var zero_number: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"armadura_min": 0}, "torres": ["aire"], "texto": "A {torres}."}]})
	assert_string_contains(_errors_text(zero_number), "armadura_min")
	assert_string_contains(_errors_text(_raw({"criterios": {"aire": {"golpea_aire": "si"}}})), "golpea_aire")
	assert_string_contains(_errors_text(_raw({"criterios": {"aire": {"rara": 1}}})), "rara")
	assert_string_contains(_errors_text(_raw({"criterios": {"aire": {}}})), "aire")


func test_duplicate_rule_id_is_an_error() -> void:
	var rule: Dictionary = {"id": "x", "enemigo": {"vuela": true}, "torres": ["aire"], "texto": "A {torres}."}
	assert_string_contains(_errors_text(_raw({"reglas": [rule, rule]})), "repetido")


func test_texts_that_do_not_fit_in_two_lines_are_errors() -> void:
	var long_text: String = "Este texto es demasiado largo para entrar en dos líneas del panel de la derrota: {torres}, otra vez."
	var raw: Dictionary = _raw({"reglas": [{"id": "x", "enemigo": {"vuela": true}, "torres": ["aire"], "texto": long_text}]})
	assert_string_contains(_errors_text(raw), "2 líneas")


func test_air_criterion_takes_towers_that_hit_air_and_damage() -> void:
	var data: AdviceData = AdviceData.parse(_raw())
	assert_true(data.tower_fits("aire", _tower("basic")))
	assert_true(data.tower_fits("aire", _tower("sniper")))
	assert_false(data.tower_fits("aire", _tower("cannon")), "el Cañón no golpea el aire")
	assert_false(data.tower_fits("aire", _tower("frost")), "el Hielo golpea el aire pero casi no daña")
	assert_false(data.tower_fits("aire", _tower("mechanical_standard")), "el apoyo nunca")
	assert_false(data.tower_fits("no_existe", _tower("basic")))


func test_criteria_read_the_real_numbers_of_level_one() -> void:
	var data: AdviceData = AdviceData.load_file()
	assert_true(data.is_valid(), "\n".join(data.errors))
	assert_true(data.tower_fits("golpe_alto", _tower("cannon")))
	assert_true(data.tower_fits("golpe_alto", _tower("sniper")))
	assert_false(data.tower_fits("golpe_alto", _tower("basic")), "5 de daño no es golpe alto")
	assert_false(data.tower_fits("golpe_alto", _tower("disruptor")), "el pulso no cuenta")
	assert_true(data.tower_fits("fuego", _tower("fire")))
	assert_false(data.tower_fits("fuego", _tower("cannon")))
	assert_true(data.tower_fits("frena", _tower("frost")))
	assert_true(data.tower_fits("largo", _tower("sniper")))
	assert_true(data.tower_fits("apaga_auras", _tower("disruptor")))
	assert_true(data.tower_fits("varios", _tower("multi")))
	assert_true(data.tower_fits("varios", _tower("burst")))
	assert_false(data.tower_fits("varios", _tower("cannon")))
	assert_true(data.tower_fits("area", _tower("cannon")))


# --- Condiciones de enemigo ---

func test_enemy_conditions_read_real_enemy_data() -> void:
	assert_true(AdviceData.enemy_matches({"vuela": true}, _enemy("flyer")))
	assert_false(AdviceData.enemy_matches({"vuela": true}, _enemy("normal")))
	assert_true(AdviceData.enemy_matches({"armadura_min": 2}, _enemy("armored")))
	assert_true(AdviceData.enemy_matches({"armadura_min": 2}, _enemy("rammer")))
	assert_false(AdviceData.enemy_matches({"armadura_min": 2}, _enemy("guardian")), "armadura 1")
	assert_true(AdviceData.enemy_matches({"resiste_ralentizar_min": 0.5}, _enemy("boss")))
	assert_true(AdviceData.enemy_matches({"regenera_min": 1}, _enemy("troll")))
	assert_true(AdviceData.enemy_matches({"cura_min": 1}, _enemy("healer")))
	assert_true(AdviceData.enemy_matches({"aura_armadura_min": 1}, _enemy("guardian")))
	assert_true(AdviceData.enemy_matches({"aturde": true}, _enemy("shaman")))
	assert_true(AdviceData.enemy_matches({"rebota": true}, _enemy("mirror")))
	assert_true(AdviceData.enemy_matches({"roba_oro": true}, _enemy("thief")))
	assert_true(AdviceData.enemy_matches({"embiste": true}, _enemy("rammer")))
	assert_true(AdviceData.enemy_matches({"suelta_crias": true}, _enemy("spider")))
	assert_true(AdviceData.enemy_matches({"velocidad_min": 2.0}, _enemy("fast")))
	assert_true(AdviceData.enemy_matches({"velocidad_min": 2.0}, _enemy("flyer")))
	assert_true(AdviceData.enemy_matches({"velocidad_min": 2.0, "en_tierra": true}, _enemy("fast")))
	assert_false(AdviceData.enemy_matches({"velocidad_min": 2.0, "en_tierra": true}, _enemy("flyer")), "el Volador tiene su regla")
	assert_false(AdviceData.enemy_matches({"en_tierra": true}, _enemy("flyer")))
	assert_true(AdviceData.enemy_matches({"vida_min": 130}, _enemy("tank")))
	assert_false(AdviceData.enemy_matches({"vida_min": 130}, _enemy("normal")))


func test_empty_or_unknown_condition_matches_nobody() -> void:
	assert_false(AdviceData.enemy_matches({}, _enemy("flyer")))
	assert_false(AdviceData.enemy_matches({"raro": true}, _enemy("flyer")))
	assert_false(AdviceData.enemy_matches({"vuela": true}, null))


func test_all_conditions_must_hold() -> void:
	assert_true(AdviceData.enemy_matches({"armadura_min": 2, "vida_min": 100}, _enemy("boss")))
	assert_false(AdviceData.enemy_matches({"armadura_min": 2, "vida_min": 100}, _enemy("armored")), "30 de vida")


func test_a_new_enemy_with_armor_is_taken_without_touching_the_file() -> void:
	var enemy := EnemyData.new()
	enemy.armor = 4
	assert_true(AdviceData.enemy_matches({"armadura_min": 2}, enemy))


# --- El archivo oficial ---

func test_official_file_is_valid() -> void:
	var data: AdviceData = AdviceData.load_file()
	assert_eq(data.errors.size(), 0, "\n".join(data.errors))
	assert_true(data.is_valid())
	assert_true(data.draft, "los textos son borrador hasta el OK de Lucas")


func test_every_official_rule_applies_to_some_enemy_and_some_tower() -> void:
	var data: AdviceData = AdviceData.load_file()
	var enemies: Array = _all("res://data/enemies")
	var towers: Array = _all("res://data/towers")
	for rule: Dictionary in data.rules:
		var applies: bool = false
		for enemy: Variant in enemies:
			applies = applies or AdviceData.enemy_matches(rule["enemy"], enemy as EnemyData)
		assert_true(applies, "la regla %s no aplica a ningún enemigo" % rule["id"])
		var fits: bool = false
		for criterion: String in rule["towers"]:
			for tower: Variant in towers:
				fits = fits or data.tower_fits(criterion, tower as TowerData)
		assert_true(fits, "la regla %s no la cumple ninguna torre" % rule["id"])


func test_every_flying_or_armored_enemy_is_covered_by_a_rule() -> void:
	var data: AdviceData = AdviceData.load_file()
	for enemy: Variant in _all("res://data/enemies"):
		var data_enemy := enemy as EnemyData
		if data_enemy.is_flying or data_enemy.armor >= 2:
			var covered: bool = false
			for rule: Dictionary in data.rules:
				covered = covered or AdviceData.enemy_matches(rule["enemy"], data_enemy)
			assert_true(covered, "%s no tiene regla" % data_enemy.id)


func test_official_texts_fit_with_the_longest_real_tower_names() -> void:
	var data: AdviceData = AdviceData.load_file()
	var longest: int = 0
	for tower: Variant in _all("res://data/towers"):
		if not (tower as TowerData).support_only:
			longest = maxi(longest, (tower as TowerData).display_name.length())
	for rule: Dictionary in data.rules:
		assert_lte(data.worst_case_length(rule["text"], longest), data.max_chars, rule["id"])
