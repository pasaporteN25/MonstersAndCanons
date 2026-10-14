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
