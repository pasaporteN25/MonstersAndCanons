# Qué artículo de Lore está abierto (M52, RF-470). Lógica pura, sin escena (P10): un artículo se abre
# cuando el nivel de su `"desbloqueo"` figura como completado en el guardado; no hay campos nuevos.
class_name LoreUnlock
extends RefCounted

const CLOSED_PREFIX: String = "Se abre al ganar el nivel "


## ¿Está abierto? `is_completed` es una función (id del nivel → bool). Sin función, todo está abierto
## (herramientas y tests de forma); el modo de pruebas lo resuelve quien llama (RF-470).
static func is_open(unlock_level: StringName, is_completed: Callable) -> bool:
	return not is_completed.is_valid() or bool(is_completed.call(unlock_level))


## «Se abre al ganar el nivel N.» con el NÚMERO del nivel (nunca su nombre ni nada de su contenido).
## El número sale del lugar del nivel en la campaña; si el nivel todavía no está en `campaign.json`
## (los del 11 al 15 se suman de a uno), sale del número del id (`level_11` → 11).
static func locked_text(unlock_level: StringName, campaign_ids: Array) -> String:
	var number: int = level_number(unlock_level, campaign_ids)
	if number <= 0:
		return "Se abre al ganar un nivel de la campaña."
	return "%s%d." % [CLOSED_PREFIX, number]


## El número del nivel (desde 1). 0 si el id no parece de nivel.
static func level_number(unlock_level: StringName, campaign_ids: Array) -> int:
	var index: int = campaign_ids.find(String(unlock_level))
	if index < 0:
		index = campaign_ids.find(unlock_level)
	if index >= 0:
		return index + 1
	var parsed := RegEx.create_from_string("^level_(\\d+)$").search(String(unlock_level))
	return int(parsed.get_string(1)) if parsed != null else 0


## ¿Tiene la forma de un id de nivel de la campaña (`level_NN`)?
static func is_level_id(value: Variant) -> bool:
	return value is String and RegEx.create_from_string("^level_\\d+$").search(value) != null
