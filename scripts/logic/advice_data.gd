# Los datos del consejo de la pantalla de derrota (M70, RF-632): lee y valida `data/consejos/consejos.json`
# (ajustes, criterios de torre, reglas por comportamiento de enemigo). Lógica pura, sin
# escena (P10). Los errores van en castellano y nombran la regla o el criterio. Un archivo con errores no se usa:
# la derrota se muestra sin consejo (RF-635).
class_name AdviceData
extends RefCounted

const DEFAULT_PATH: String = "res://data/consejos/consejos.json"
const SUPPORTED_VERSION: int = 1
## Claves que entiende cada lado (qué se mira de la torre o del enemigo vive acá; los valores, en el archivo).
const TOWER_BOOL_KEYS: PackedStringArray = ["golpea_aire", "multi", "pulso"]
const TOWER_NUMBER_KEYS: PackedStringArray = ["danio_min", "quema_min", "area_min", "ralentiza_min", "alcance_min"]
const ENEMY_BOOL_KEYS: PackedStringArray = ["vuela", "en_tierra", "aturde", "rebota", "roba_oro", "embiste", "suelta_crias"]
const ENEMY_NUMBER_KEYS: PackedStringArray = ["armadura_min", "resiste_ralentizar_min", "regenera_min", "cura_min",
		"aura_armadura_min", "velocidad_min", "vida_min"]
const SETTING_KEYS: PackedStringArray = ["peso_oleada", "participacion_minima_pct", "vidas_minimas", "max_torres",
		"max_caracteres"]
## Para calcular el peor largo de un texto antes de conocer las torres: letras de un nombre largo («Ametralladora»).
const NAME_CHARS: int = 13
const SEPARATOR_CHARS: int = 3
const PLACEHOLDER_TOWERS: String = "{torres}"

var draft: bool = true
var wave_weight: float = 0.0
var min_share_pct: int = 0
var min_lives: int = 0
var max_towers: int = 0
var max_chars: int = 0
## { nombre: {clave: valor} }
var criteria: Dictionary = {}
## [{"id": String, "enemy": Dictionary, "towers": PackedStringArray, "text": String}]
var rules: Array[Dictionary] = []
var errors: PackedStringArray = []


static func load_file(path: String = DEFAULT_PATH) -> AdviceData:
	var data := AdviceData.new()
	if not FileAccess.file_exists(path):
		data.errors.append("consejos: no existe el archivo %s." % path)
		return data
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		data.errors.append("consejos: no se pudo abrir %s." % path)
		return data
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		data.errors.append("consejos: %s no es un JSON válido (línea %d: %s)." % [path, json.get_error_line(), json.get_error_message()])
		return data
	return parse(json.data)


static func parse(raw: Variant) -> AdviceData:
	var data := AdviceData.new()
	if not raw is Dictionary:
		data.errors.append("consejos: el archivo tiene que ser un objeto con \"ajustes\", \"criterios\", \"reglas\".")
		return data
	var dict: Dictionary = raw
	if not _is_number(dict.get("version")) or float(dict["version"]) != float(SUPPORTED_VERSION):
		data.errors.append("consejos: \"version\" tiene que ser %d." % SUPPORTED_VERSION)
	if typeof(dict.get("borrador")) != TYPE_BOOL:
		data.errors.append("consejos: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).")
	else:
		data.draft = dict["borrador"]
	data._parse_settings(dict.get("ajustes"))
	data._parse_criteria(dict.get("criterios"))
	data._parse_rules(dict.get("reglas"))
	return data


func is_valid() -> bool:
	return errors.is_empty() and not rules.is_empty()


## ¿La torre cumple el criterio `name`? Mira el nivel 1 (lo que se construye). Una torre de apoyo nunca cumple.
func tower_fits(criterion: String, tower: TowerData) -> bool:
	if not criteria.has(criterion):
		return false
	return tower_matches(criteria[criterion], tower)


static func tower_matches(criterion: Dictionary, tower: TowerData) -> bool:
	if tower == null or tower.support_only or tower.levels.is_empty():
		return false
	var stats: TowerLevelData = tower.levels[0]
	for key: String in criterion:
		var wanted: Variant = criterion[key]
		match key:
			"golpea_aire":
				if tower.can_hit_air != bool(wanted):
					return false
			"multi":
				var is_multi: bool = stats.extra_targets > 0 or stats.burst_count > 0 or stats.chain_extra_targets > 0
				if is_multi != bool(wanted):
					return false
			"pulso":
				if (stats.suppress_seconds > 0.0) != bool(wanted):
					return false
			"danio_min":
				if float(stats.damage) < float(wanted):
					return false
			"quema_min":
				if float(stats.burn_damage_per_second) < float(wanted):
					return false
			"area_min":
				if stats.splash_radius_tiles < float(wanted):
					return false
			"ralentiza_min":
				if stats.slow_amount < float(wanted):
					return false
			"alcance_min":
				if stats.range_tiles < float(wanted):
					return false
			_:
				return false
	return true


## ¿El enemigo cumple todas las condiciones? (Una condición vacía no aplica a nadie.)
static func enemy_matches(cond: Dictionary, enemy: EnemyData) -> bool:
	if enemy == null or cond.is_empty():
		return false
	for key: String in cond:
		var wanted: Variant = cond[key]
		match key:
			"vuela":
				if enemy.is_flying != bool(wanted):
					return false
			"en_tierra":
				if (not enemy.is_flying) != bool(wanted):
					return false
			"aturde":
				if (enemy.stun_interval > 0.0) != bool(wanted):
					return false
			"rebota":
				if (enemy.reflect_range_tiles > 0.0) != bool(wanted):
					return false
			"roba_oro":
				if (enemy.gold_drain_amount > 0) != bool(wanted):
					return false
			"embiste":
				if (enemy.charge_distance_tiles > 0.0) != bool(wanted):
					return false
			"suelta_crias":
				if (enemy.death_spawn_count > 0 and enemy.death_spawn != null) != bool(wanted):
					return false
			"armadura_min":
				if float(enemy.armor) < float(wanted):
					return false
			"resiste_ralentizar_min":
				if enemy.slow_resistance < float(wanted):
					return false
			"regenera_min":
				if enemy.regen_percent_per_second < float(wanted):
					return false
			"cura_min":
				if enemy.aura_heal_percent_per_second < float(wanted):
					return false
			"aura_armadura_min":
				if float(enemy.aura_armor_bonus) < float(wanted):
					return false
			"velocidad_min":
				if enemy.speed_tiles < float(wanted):
					return false
			"vida_min":
				if float(enemy.max_health) < float(wanted):
					return false
			_:
				return false
	return true


## Cuántos caracteres puede tener una frase con `{torres}` ya reemplazado por los nombres más largos.
func worst_case_length(text: String, name_chars: int = NAME_CHARS) -> int:
	var names: int = maxi(max_towers, 1)
	var replacement: int = names * name_chars + (names - 1) * SEPARATOR_CHARS
	return text.replace(PLACEHOLDER_TOWERS, "x".repeat(replacement)).length()


# --- Lectura y validación ---

func _parse_settings(raw: Variant) -> void:
	if not raw is Dictionary:
		errors.append("consejos: falta \"ajustes\" (un objeto con %s)." % ", ".join(SETTING_KEYS))
		return
	var settings: Dictionary = raw
	for key: String in settings:
		if not SETTING_KEYS.has(key):
			errors.append("consejos: \"ajustes\" no conoce la clave \"%s\" (las válidas: %s)." % [key, ", ".join(SETTING_KEYS)])
	for key: String in SETTING_KEYS:
		if not _is_number(settings.get(key)):
			errors.append("consejos: \"ajustes.%s\" tiene que ser un número." % key)
			return
	wave_weight = float(settings["peso_oleada"])
	min_share_pct = int(settings["participacion_minima_pct"])
	min_lives = int(settings["vidas_minimas"])
	max_towers = int(settings["max_torres"])
	max_chars = int(settings["max_caracteres"])
	if wave_weight < 0.0 or wave_weight > 5.0:
		errors.append("consejos: \"peso_oleada\" tiene que estar entre 0 y 5.")
	if min_share_pct < 0 or min_share_pct > 100:
		errors.append("consejos: \"participacion_minima_pct\" tiene que estar entre 0 y 100.")
	if min_lives < 1:
		errors.append("consejos: \"vidas_minimas\" tiene que ser 1 o más.")
	if max_towers < 1 or max_towers > 4:
		errors.append("consejos: \"max_torres\" tiene que estar entre 1 y 4.")
	if max_chars < 30 or max_chars > 120:
		errors.append("consejos: \"max_caracteres\" tiene que estar entre 30 y 120 (si no, el texto no entra en 2 líneas).")


func _parse_criteria(raw: Variant) -> void:
	if not raw is Dictionary or (raw as Dictionary).is_empty():
		errors.append("consejos: falta \"criterios\" (qué torres cuentan como «de golpe alto», «que golpean el aire»…).")
		return
	for name_raw: Variant in raw:
		var name: String = String(name_raw)
		var body: Variant = (raw as Dictionary)[name_raw]
		if not body is Dictionary or (body as Dictionary).is_empty():
			errors.append("consejos: el criterio \"%s\" tiene que ser un objeto con al menos una condición." % name)
			continue
		var ok: bool = true
		for key: String in body:
			var value: Variant = (body as Dictionary)[key]
			if TOWER_BOOL_KEYS.has(key):
				if typeof(value) != TYPE_BOOL:
					errors.append("consejos: en el criterio \"%s\", \"%s\" tiene que ser true o false." % [name, key])
					ok = false
			elif TOWER_NUMBER_KEYS.has(key):
				if not _is_number(value) or float(value) < 0.0:
					errors.append("consejos: en el criterio \"%s\", \"%s\" tiene que ser un número de 0 o más." % [name, key])
					ok = false
			else:
				errors.append("consejos: el criterio \"%s\" no conoce la condición \"%s\" (las válidas: %s)." % [
						name, key, ", ".join(TOWER_BOOL_KEYS + TOWER_NUMBER_KEYS)])
				ok = false
		if ok:
			criteria[name] = (body as Dictionary).duplicate()


func _parse_rules(raw: Variant) -> void:
	if not raw is Array or (raw as Array).is_empty():
		errors.append("consejos: falta \"reglas\" (una lista con al menos una regla).")
		return
	var seen: Dictionary = {}
	var index: int = 0
	for item: Variant in raw:
		index += 1
		if not item is Dictionary:
			errors.append("consejos: la regla %d tiene que ser un objeto." % index)
			continue
		var rule: Dictionary = item
		var id: String = String(rule.get("id", "")).strip_edges()
		var label: String = "la regla \"%s\"" % id if id != "" else "la regla %d" % index
		if id == "":
			errors.append("consejos: %s no tiene \"id\"." % label)
		elif seen.has(id):
			errors.append("consejos: el id \"%s\" está repetido." % id)
		seen[id] = true
		var enemy: Dictionary = _parse_enemy_condition(rule.get("enemigo"), label)
		var towers: PackedStringArray = []
		var towers_raw: Variant = rule.get("torres")
		if not towers_raw is Array or (towers_raw as Array).is_empty():
			errors.append("consejos: %s necesita \"torres\" (la lista de criterios que sirven)." % label)
		else:
			for criterion: Variant in towers_raw:
				if not criterion is String or not criteria.has(criterion):
					errors.append("consejos: %s nombra el criterio \"%s\", que no existe en \"criterios\"." % [label, str(criterion)])
				else:
					towers.append(criterion)
		var text: String = String(rule.get("texto", "")).strip_edges()
		if text == "":
			errors.append("consejos: %s no tiene \"texto\"." % label)
		elif not text.contains(PLACEHOLDER_TOWERS):
			errors.append("consejos: el texto de %s tiene que llevar %s donde van los nombres de las torres." % [label, PLACEHOLDER_TOWERS])
		elif max_chars > 0 and worst_case_length(text) > max_chars:
			errors.append("consejos: el texto de %s mide hasta %d caracteres con %d nombres largos y el máximo es %d (no entraría en 2 líneas)." % [
					label, worst_case_length(text), max_towers, max_chars])
		if id != "" and not enemy.is_empty() and not towers.is_empty() and text != "":
			rules.append({"id": id, "enemy": enemy, "towers": towers, "text": text})


func _parse_enemy_condition(raw: Variant, label: String) -> Dictionary:
	if not raw is Dictionary or (raw as Dictionary).is_empty():
		errors.append("consejos: %s necesita \"enemigo\" (a qué enemigos aplica, por ejemplo {\"vuela\": true})." % label)
		return {}
	var result: Dictionary = {}
	var ok: bool = true
	for key: String in raw:
		var value: Variant = (raw as Dictionary)[key]
		if ENEMY_BOOL_KEYS.has(key):
			if typeof(value) != TYPE_BOOL or not bool(value):
				errors.append("consejos: en %s, \"%s\" solo puede ser true." % [label, key])
				ok = false
		elif ENEMY_NUMBER_KEYS.has(key):
			if not _is_number(value) or float(value) <= 0.0:
				errors.append("consejos: en %s, \"%s\" tiene que ser un número mayor que 0." % [label, key])
				ok = false
		else:
			errors.append("consejos: %s no conoce la condición de enemigo \"%s\" (las válidas: %s)." % [
					label, key, ", ".join(ENEMY_BOOL_KEYS + ENEMY_NUMBER_KEYS)])
			ok = false
		result[key] = value
	return result if ok else {}



static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
