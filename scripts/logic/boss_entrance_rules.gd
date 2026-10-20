# Cuándo un enemigo hace su entrada (M66, RF-597, RF-601): reglas puras, sin escena (P10). Quien las usa
# (`Game`) lleva la cuenta del último momento y de los tipos ya presentados en la oleada.
class_name BossEntranceRules
extends RefCounted

## «Nunca se mostró»: un momento tan atrás que cualquier intervalo ya pasó.
const NEVER: float = -1.0e9


## ¿El nivel está en la lista de la entrada? Lista vacía = todos (RF-601).
static func level_allowed(entrance: BossEntranceData, level_id: String) -> bool:
	if entrance == null:
		return false
	return entrance.levels.is_empty() or entrance.levels.has(level_id)


## ¿Sale la entrada de este enemigo? `shown_types` son los ids ya presentados en esta oleada; `last_s` es el
## momento de la última entrada y `now_s` el de ahora (mismo reloj); `min_gap_s` el intervalo mínimo.
static func should_show(enemy: EnemyData, level_id: String, option_on: bool, now_s: float, last_s: float,
		shown_types: Array, min_gap_s: float = 8.0) -> bool:
	if enemy == null or enemy.entrance == null or not option_on:
		return false
	if not level_allowed(enemy.entrance, level_id):
		return false
	if shown_types.has(enemy.id) or shown_types.has(String(enemy.id)):
		return false
	return now_s - last_s >= min_gap_s


## La frase del cartel: la propia de la entrada o, si está vacía, la descripción del enemigo.
static func line_for(enemy: EnemyData) -> String:
	if enemy.entrance != null and enemy.entrance.line.strip_edges() != "":
		return enemy.entrance.line
	return enemy.description


## Los errores de una entrada, en castellano. `level_ids` y `sound_ids` son los que existen de verdad.
static func validate(enemy_id: String, entrance: BossEntranceData, level_ids: PackedStringArray,
		sound_ids: PackedStringArray) -> PackedStringArray:
	var errors := PackedStringArray()
	if entrance == null:
		return errors
	for level_id: String in entrance.levels:
		if not level_ids.has(level_id):
			errors.append("%s: la entrada nombra el nivel «%s», que no existe." % [enemy_id, level_id])
	if entrance.line.length() > BossEntranceData.MAX_LINE_CHARS:
		errors.append("%s: la frase de la entrada tiene %d caracteres y el máximo es %d." % [
			enemy_id, entrance.line.length(), BossEntranceData.MAX_LINE_CHARS])
	if entrance.sound != &"" and not sound_ids.has(String(entrance.sound)):
		errors.append("%s: la entrada nombra el sonido «%s», que no existe en Audio." % [enemy_id, entrance.sound])
	return errors
