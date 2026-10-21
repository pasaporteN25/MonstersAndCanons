# Qué consejo se le da a quien perdió (M70, RF-633 y RF-634). Lógica pura, sin escena ni autoloads (P10): recibe el
# registro de fugas, lo que traía la oleada de la derrota y las torres que ofrece el nivel, y devuelve texto.
class_name DefeatAdvice
extends RefCounted


## El consejo de torre (RF-633). Devuelve `{}` si no hay datos suficientes o ninguna regla cuenta; si no, un
## diccionario con `"id"` (la regla), `"text"` (listo para mostrar), `"towers"` (ids), `"score"` y `"share"` (% del peso).
## `wave_counts`: { EnemyData: cuántos traía la oleada en que se perdió }. `offered`: las torres de ESTE nivel.
static func tower_tip(data: AdviceData, log: LeakLog, wave_counts: Dictionary, offered: Array[TowerData]) -> Dictionary:
	if data == null or not data.is_valid() or log == null or log.total_lives() < data.min_lives:
		return {}
	var weights: Dictionary = enemy_weights(data, log, wave_counts)
	var total: float = 0.0
	for weight: Variant in weights.values():
		total += float(weight)
	if total <= 0.0:
		return {}
	var best: Dictionary = {}
	var best_score: float = 0.0
	for rule: Dictionary in data.rules:
		var score: float = 0.0
		for enemy: Variant in weights:
			if AdviceData.enemy_matches(rule["enemy"], enemy as EnemyData):
				score += float(weights[enemy])
		if score <= 0.0 or score * 100.0 < float(data.min_share_pct) * total:
			continue
		if score <= best_score:
			continue  # empate: gana la regla que está primero en el archivo
		var towers: Array[TowerData] = suggested_towers(data, rule, offered)
		if towers.is_empty():
			continue
		var ids: PackedStringArray = []
		for tower: TowerData in towers:
			ids.append(String(tower.id))
		best_score = score
		best = {"id": rule["id"], "text": String(rule["text"]).replace(AdviceData.PLACEHOLDER_TOWERS, join_names(towers)),
				"towers": ids, "score": score, "share": score * 100.0 / total}
	return best


## El peso de cada tipo de enemigo (D-175): las vidas que de verdad quitó + `peso_oleada` × lo que quitaría la
## oleada final si todos llegaran. { EnemyData: float }
static func enemy_weights(data: AdviceData, log: LeakLog, wave_counts: Dictionary) -> Dictionary:
	var weights: Dictionary = {}
	for enemy: Variant in log.lives:
		weights[enemy] = float(log.lives[enemy])
	for enemy: Variant in wave_counts:
		var data_enemy := enemy as EnemyData
		if data_enemy == null:
			continue
		weights[enemy] = float(weights.get(enemy, 0.0)) + data.wave_weight * float(data_enemy.lives_damage) * float(wave_counts[enemy])
	return weights


## Las torres que ofrece el nivel y sirven para la regla, en el orden de sus criterios y luego el de la barra,
## sin repetir y hasta `max_torres`. Nunca una torre de apoyo ni una que el nivel no ofrece.
static func suggested_towers(data: AdviceData, rule: Dictionary, offered: Array[TowerData]) -> Array[TowerData]:
	var result: Array[TowerData] = []
	for criterion: String in rule["towers"]:
		for tower: TowerData in offered:
			if result.size() >= data.max_towers:
				return result
			if not result.has(tower) and data.tower_fits(criterion, tower):
				result.append(tower)
	return result


## «A», «A y B», «A, B y C».
static func join_names(towers: Array[TowerData]) -> String:
	var names: PackedStringArray = []
	for tower: TowerData in towers:
		names.append(tower.display_name)
	if names.size() <= 1:
		return "".join(names)
	return "%s y %s" % [", ".join(names.slice(0, names.size() - 1)), names[names.size() - 1]]
