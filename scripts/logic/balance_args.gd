# Lectura de los argumentos del bot de balance (T204): rangos de mapas y de semillas.
# Son funciones puras para poder probarlas sin abrir la partida (constitución P10).
class_name BalanceArgs
extends RefCounted

## Semilla que se usa si no se pide ninguna (la de siempre del bot).
const DEFAULT_SEED: int = 12345


## "6" → [6] · "6-9" → [6, 7, 8, 9]. Vacío si el texto no es válido o el rango está al revés.
static func parse_levels(text: String) -> Array[int]:
	var result: Array[int] = []
	var parts: PackedStringArray = text.split("-")
	if parts.size() == 1 and parts[0].is_valid_int():
		result.append(parts[0].to_int())
	elif parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		for n: int in range(parts[0].to_int(), parts[1].to_int() + 1):
			result.append(n)
	return result


## "seeds=3" → [1, 2, 3].
static func seeds_up_to(count: int) -> Array[int]:
	var result: Array[int] = []
	for n: int in range(1, count + 1):
		result.append(n)
	return result


## "mix,smart" → ["mix", "smart"].
static func parse_strategies(text: String) -> Array[String]:
	var result: Array[String] = []
	for part: String in text.split(","):
		if part != "":
			result.append(part)
	return result


# --- T214: estrategias con infraestructura y regla de oro (RF-432) ---

## Las cinco estrategias de M50. Las demás (smart, mix, heavy, basic, naive) siguen como estaban.
const INFRA_STRATEGIES: Array[String] = ["sin_recursos", "demoler", "demoledora", "pieza", "extraer_temprano", "extraer_tarde"]
## RF-432: N semillas y M victorias mínimas. Viven en la herramienta y no en el juego.
const RULE_SEEDS: int = 5
const RULE_MIN_WINS: int = 4


static func is_infra_strategy(name: String) -> bool:
	return INFRA_STRATEGIES.has(name)


## RF-432: ¿un mapa cumple la regla de oro? `wins` victorias en `total` partidas con `sin_recursos`.
## Hace falta haber jugado las N semillas: con menos partidas no se puede afirmar nada.
static func rule_holds(wins: int, total: int) -> bool:
	return total >= RULE_SEEDS and wins >= RULE_MIN_WINS


## Cuenta las victorias de `sin_recursos` por mapa. `rows` son las filas del informe del bot.
## Devuelve mapa → {"wins": int, "total": int}.
static func rule_summary(rows: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for row: Dictionary in rows:
		if row["strategy"] != "sin_recursos":
			continue
		var entry: Dictionary = result.get(row["level"], {"wins": 0, "total": 0})
		entry["total"] += 1
		if row["won"]:
			entry["wins"] += 1
		result[row["level"]] = entry
	return result


## Código de salida de `check_rule=1`: 0 si todos los mapas cumplen la regla, 1 si alguno no (o si no se jugó ninguno).
static func rule_exit_code(rows: Array[Dictionary]) -> int:
	var summary: Dictionary = rule_summary(rows)
	if summary.is_empty():
		return 1
	for level: int in summary:
		if not rule_holds(summary[level]["wins"], summary[level]["total"]):
			return 1
	return 0


# --- T258: mejoras del bot y perfil de Asedio (RF-495) ---

## Reglas de mejoras de torres del bot (T255 §2). Vacío = no mejora (como siempre).
const UPGRADE_FILL: String = "llenar"
const UPGRADE_EARLY: String = "temprana"
const UPGRADE_MODES: Array[String] = ["", UPGRADE_FILL, UPGRADE_EARLY]
## T255 §2.1: con `temprana` mejora desde que hay esta cantidad de torres, aunque queden casillas libres.
const EARLY_UPGRADE_TOWERS: int = 3
## RF-495: el perfil de Asedio juega 5 semillas y pide ganar las 5 con al menos 3 vidas.
const ASEDIO_SEEDS: int = 5
const ASEDIO_MIN_LIVES: int = 3
## Los bloques con los que se mira la curva: mapas 1–5, 6–10 y 11–15 (primero y último de cada uno).
const ASEDIO_BLOCKS: Array[Vector2i] = [Vector2i(1, 5), Vector2i(6, 10), Vector2i(11, 15)]


static func is_upgrade_mode(mode: String) -> bool:
	return UPGRADE_MODES.has(mode)


## ¿Toca mejorar una torre ahora? `llenar`: ya no queda ninguna casilla libre. `temprana`: hay 3 torres o más.
static func wants_upgrade(mode: String, towers_built: int, free_cells: int) -> bool:
	if mode == UPGRADE_FILL:
		return free_cells == 0
	if mode == UPGRADE_EARLY:
		return towers_built >= EARLY_UPGRADE_TOWERS
	return false


## La torre a mejorar: la de menor nivel y, entre ellas, la de menor costo de mejora; si empatan, la primera.
## `candidates` son {"level": int, "cost": int}. Devuelve el índice, o -1 si no hay ninguna.
static func pick_upgrade(candidates: Array[Dictionary]) -> int:
	var best: int = -1
	for index: int in candidates.size():
		if best < 0 or candidates[index]["level"] < candidates[best]["level"] \
				or (candidates[index]["level"] == candidates[best]["level"] and candidates[index]["cost"] < candidates[best]["cost"]):
			best = index
	return best


## El archivo de políticas por mapa (tools/asedio_politicas.json): {"por_defecto": {...}, "level_02": {...}}.
## Cada política es {"estrategia": String, "mejoras": String}. Devuelve {"policies": Dictionary, "error": String}.
static func parse_policies(text: String) -> Dictionary:
	var json := JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return {"policies": {}, "error": "no es un JSON con { }"}
	var policies: Dictionary = {}
	for key: Variant in (json.data as Dictionary).keys():
		var entry: Variant = json.data[key]
		if not entry is Dictionary or not (entry as Dictionary).get("estrategia") is String:
			return {"policies": {}, "error": "'%s' necesita {\"estrategia\": ..., \"mejoras\": ...}" % str(key)}
		var upgrades: Variant = (entry as Dictionary).get("mejoras", "")
		if not upgrades is String or not is_upgrade_mode(upgrades):
			return {"policies": {}, "error": "'%s': \"mejoras\" tiene que ser llenar o temprana" % str(key)}
		policies[str(key)] = {"estrategia": entry["estrategia"], "mejoras": upgrades}
	if not policies.has("por_defecto"):
		return {"policies": {}, "error": "falta \"por_defecto\""}
	return {"policies": policies, "error": ""}


## La política de un mapa (por su id, "level_02"): la suya o, si no tiene, la "por_defecto".
static func policy_for(policies: Dictionary, map_id: String) -> Dictionary:
	return policies.get(map_id, policies.get("por_defecto", {"estrategia": "sin_recursos", "mejoras": UPGRADE_FILL}))


## RF-495: el veredicto del perfil. `rows` son las filas del bot. Devuelve
## {"levels": {mapa: {"wins", "total", "min_lives", "holds"}}, "blocks": Array[float] (-1 si el bloque no se jugó entero),
##  "blocks_rise": bool, "exit_code": int}.
static func asedio_verdict(rows: Array[Dictionary]) -> Dictionary:
	var levels: Dictionary = {}
	for row: Dictionary in rows:
		var entry: Dictionary = levels.get(row["level"], {"wins": 0, "total": 0, "min_lives": 999, "holds": false})
		entry["total"] += 1
		if row["won"]:
			entry["wins"] += 1
			entry["min_lives"] = mini(entry["min_lives"], row["lives"])
		levels[row["level"]] = entry
	var ok: bool = not levels.is_empty()
	for level: int in levels:
		var entry: Dictionary = levels[level]
		entry["holds"] = entry["total"] >= ASEDIO_SEEDS and entry["wins"] == entry["total"] \
			and entry["min_lives"] >= ASEDIO_MIN_LIVES
		ok = ok and entry["holds"]
	var blocks: Array[float] = []
	for block: Vector2i in ASEDIO_BLOCKS:
		blocks.append(_block_average(rows, block))
	var rises: bool = false
	for index: int in range(1, blocks.size()):
		if blocks[index] >= 0.0 and blocks[index - 1] >= 0.0 and blocks[index] > blocks[index - 1] + 0.0001:
			rises = true
	return {"levels": levels, "blocks": blocks, "blocks_rise": rises, "exit_code": 0 if ok and not rises else 1}


## Promedio de vidas del bloque: primero por semilla (los mapas del bloque) y después entre semillas.
## -1 si falta algún mapa del bloque en alguna semilla.
static func _block_average(rows: Array[Dictionary], block: Vector2i) -> float:
	var by_seed: Dictionary = {}
	for row: Dictionary in rows:
		if row["level"] < block.x or row["level"] > block.y:
			continue
		var entry: Dictionary = by_seed.get(row["seed"], {"sum": 0, "count": 0})
		entry["sum"] += row["lives"] if row["won"] else 0
		entry["count"] += 1
		by_seed[row["seed"]] = entry
	if by_seed.is_empty():
		return -1.0
	var total: float = 0.0
	for seed_n: Variant in by_seed:
		if by_seed[seed_n]["count"] != block.y - block.x + 1:
			return -1.0
		total += float(by_seed[seed_n]["sum"]) / by_seed[seed_n]["count"]
	return total / by_seed.size()
