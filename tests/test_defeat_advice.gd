# Tests del registro de fugas y de la elección del consejo de derrota (T420, M70: RF-631, RF-633, RF-635).
extends GutTest

var data: AdviceData
var log: LeakLog


func before_each() -> void:
	data = AdviceData.load_file()
	log = LeakLog.new()


func _tower(id: String) -> TowerData:
	return load("res://data/towers/%s.tres" % id)


func _enemy(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


func _towers(ids: Array) -> Array[TowerData]:
	var result: Array[TowerData] = []
	for id: Variant in ids:
		result.append(_tower(str(id)))
	return result


## Anota `count` fugas del enemigo, con las vidas que quita de verdad.
func _leak(id: String, count: int) -> void:
	for i: int in count:
		log.record(_enemy(id), _enemy(id).lives_damage)


func _classic() -> Array[TowerData]:
	return _towers(["basic", "cannon", "sniper", "frost", "fire", "multi"])


# --- El registro (RF-631) ---

func test_leak_log_counts_leaks_and_lives_per_type() -> void:
	_leak("flyer", 3)
	_leak("boss", 1)
	assert_eq(log.leaks[_enemy("flyer")], 3)
	assert_eq(log.lives[_enemy("flyer")], 3)
	assert_eq(log.leaks[_enemy("boss")], 1)
	assert_eq(log.lives[_enemy("boss")], 10)
	assert_eq(log.total_lives(), 13)
	assert_eq(log.total_leaks(), 4)


func test_leak_log_ignores_zero_lives_and_null() -> void:
	log.record(_enemy("boss"), 0)
	log.record(_enemy("boss"), -2)
	log.record(null, 5)
	assert_true(log.is_empty(), "con vidas infinitas o partida terminada no se anota nada")


func test_leak_log_records_the_lives_actually_taken() -> void:
	log.record(_enemy("boss"), 1)
	assert_eq(log.lives[_enemy("boss")], 1, "llegó con 1 vida restante: quita 1, no 10")


# --- La elección (RF-633) ---

func test_flyers_suggest_air_towers_of_this_level() -> void:
	_leak("flyer", 6)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _classic())
	assert_eq(tip["id"], "volador")
	assert_string_contains(tip["text"], "Ametralladora")
	assert_string_contains(tip["text"], "Francotirador")
	assert_false(String(tip["text"]).contains("Hielo"), "el Hielo casi no daña")
	assert_false(String(tip["text"]).contains("Cañón"), "no golpea el aire")
	assert_false(String(tip["text"]).contains("{"), "el marcador se reemplaza")


func test_never_names_a_tower_the_level_does_not_offer() -> void:
	_leak("flyer", 6)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _towers(["basic", "cannon"]))
	assert_eq(tip["towers"], PackedStringArray(["basic"]))
	assert_false(String(tip["text"]).contains("Francotirador"))
	assert_false(String(tip["text"]).contains("Múltiple"))


func test_rule_is_skipped_when_the_level_offers_no_matching_tower() -> void:
	_leak("flyer", 6)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _towers(["cannon", "mortar"]))
	assert_true(tip.is_empty(), "ninguna torre del nivel sirve contra voladores: sin consejo, no inventa")
	tip = DefeatAdvice.tower_tip(data, log, {}, _towers(["cannon", "frost"]))
	assert_true(tip.is_empty(), "sin torres de aire no se recomienda Hielo contra voladores")


func test_next_matching_rule_wins_when_the_first_has_no_towers() -> void:
	# Un Troll (regenera): primero el fuego; sin Incendiaria, el golpe alto.
	_leak("troll", 5)
	assert_eq(DefeatAdvice.tower_tip(data, log, {}, _classic())["id"], "regenera_fuego")
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _towers(["basic", "cannon", "frost"]))
	assert_eq(tip["id"], "regenera_golpe")
	assert_string_contains(tip["text"], "Cañón")


func test_armor_suggests_high_hit_or_fire_towers() -> void:
	_leak("armored", 5)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _classic())
	assert_eq(tip["id"], "blindado")
	assert_string_contains(tip["text"], "Cañón y Francotirador", "primero el golpe alto, en el orden de la barra")


func test_boss_is_resistant_to_slow_and_suggests_hard_hits() -> void:
	_leak("boss", 1)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _classic())
	assert_eq(tip["id"], "resistente", "el Jefe es resistente, blindado y grande: gana la regla más específica")
	assert_string_contains(tip["text"], "Hielo")


func test_flyers_do_not_count_as_fast_ground_enemies() -> void:
	# Hallazgo de la medición de T422: Voladores (2,0 de velocidad) y Rápidos sumaban en la regla de los rápidos y le
	# ganaban a la de los voladores, que es la causa real.
	_leak("flyer", 8)
	_leak("fast", 5)
	assert_eq(DefeatAdvice.tower_tip(data, log, {}, _classic())["id"], "volador")


func test_the_heaviest_rule_wins() -> void:
	_leak("flyer", 3)  # 3 vidas
	_leak("armored", 8)  # 8 vidas
	assert_eq(DefeatAdvice.tower_tip(data, log, {}, _classic())["id"], "blindado")


func test_ties_go_to_the_rule_listed_first_in_the_file() -> void:
	_leak("flyer", 4)
	_leak("armored", 4)
	assert_eq(DefeatAdvice.tower_tip(data, log, {}, _classic())["id"], "volador")


func test_the_losing_wave_completes_but_leaks_come_first() -> void:
	_leak("armored", 3)
	# La oleada final traía 40 Voladores: 0,25 × 1 × 40 = 10 de peso contra 3 + 0,25 × 1 × 0 de los Blindados.
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {_enemy("flyer"): 40}, _classic())
	assert_eq(tip["id"], "volador")
	# Con pocos en la oleada, mandan las fugas.
	tip = DefeatAdvice.tower_tip(data, log, {_enemy("flyer"): 4}, _classic())
	assert_eq(tip["id"], "blindado")


func test_enemies_without_a_rule_dilute_and_can_leave_no_advice() -> void:
	_leak("normal", 14)
	_leak("fast", 2)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _classic())
	assert_true(tip.is_empty(), "los Rápidos son el 12 % del peso, menos que el piso del 30 %")


func test_share_floor_is_exactly_the_setting() -> void:
	_leak("normal", 7)
	_leak("fast", 3)  # 30 % justo
	assert_eq(DefeatAdvice.tower_tip(data, log, {}, _classic())["id"], "rapido")
	_leak("normal", 1)  # ahora 3 de 11
	assert_true(DefeatAdvice.tower_tip(data, log, {}, _classic()).is_empty())


func test_not_enough_data_gives_no_advice() -> void:
	assert_true(DefeatAdvice.tower_tip(data, log, {}, _classic()).is_empty(), "sin fugas")
	assert_true(DefeatAdvice.tower_tip(data, log, {_enemy("flyer"): 30}, _classic()).is_empty(), "solo la oleada no alcanza")
	_leak("flyer", 2)
	assert_true(DefeatAdvice.tower_tip(data, log, {}, _classic()).is_empty(), "2 vidas son menos que el mínimo (3)")
	_leak("flyer", 1)
	assert_false(DefeatAdvice.tower_tip(data, log, {}, _classic()).is_empty())


func test_invalid_or_missing_data_gives_no_advice() -> void:
	_leak("flyer", 6)
	assert_true(DefeatAdvice.tower_tip(null, log, {}, _classic()).is_empty())
	assert_true(DefeatAdvice.tower_tip(AdviceData.parse([]), log, {}, _classic()).is_empty())
	assert_true(DefeatAdvice.tower_tip(data, null, {}, _classic()).is_empty())


func test_support_towers_are_never_suggested() -> void:
	_leak("flyer", 6)
	var offered: Array[TowerData] = _towers(["mechanical_standard", "cannon"])
	assert_true(DefeatAdvice.tower_tip(data, log, {}, offered).is_empty())


func test_names_are_limited_to_the_setting() -> void:
	_leak("flyer", 6)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _classic())
	assert_eq((tip["towers"] as PackedStringArray).size(), data.max_towers)


func test_join_names() -> void:
	assert_eq(DefeatAdvice.join_names(_towers(["basic"])), "Ametralladora")
	assert_eq(DefeatAdvice.join_names(_towers(["basic", "cannon"])), "Ametralladora y Cañón")
	assert_eq(DefeatAdvice.join_names(_towers(["basic", "cannon", "fire"])), "Ametralladora, Cañón y Incendiaria")
	assert_eq(DefeatAdvice.join_names([] as Array[TowerData]), "")


func test_disruptor_is_suggested_only_where_offered_for_auras() -> void:
	_leak("guardian", 4)
	var tip: Dictionary = DefeatAdvice.tower_tip(data, log, {}, _towers(["basic", "disruptor", "sniper"]))
	assert_eq(tip["id"], "guardian_aura")
	assert_string_contains(tip["text"], "Disruptora")
	tip = DefeatAdvice.tower_tip(data, log, {}, _towers(["basic", "sniper"]))
	assert_eq(tip["id"], "guardian_largo")


func test_every_official_rule_can_win_with_the_full_catalog() -> void:
	var all_towers: Array[TowerData] = []
	for file_name: String in DirAccess.get_files_at("res://data/towers"):
		var res_name: String = file_name.trim_suffix(".remap")
		if res_name.ends_with(".tres"):
			all_towers.append(load("res://data/towers/%s" % res_name))
	for rule: Dictionary in data.rules:
		var fits: bool = not DefeatAdvice.suggested_towers(data, rule, all_towers).is_empty()
		assert_true(fits, "la regla %s no tiene torre en el catálogo completo" % rule["id"])
