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
