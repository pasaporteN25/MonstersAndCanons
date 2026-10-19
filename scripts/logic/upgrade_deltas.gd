# Lo que suma una mejora de torre y dónde se muestra (M65, RF-591, RF-592, D-136).
# Lógica pura: no sabe de escenas (P10). Los números salen de los dos `TowerLevelData` (los .tres), nunca de acá.
class_name UpgradeDeltas
extends RefCounted

## Una diferencia menor que esto cuenta como «no cambió» (los decimales de los .tres).
const TOLERANCE: float = 0.005
const SEPARATOR: String = " · "
const MINUS: String = "−"


## Las estadísticas que cambiaron entre `from` y `to`, en el orden de `table` y hasta `max_stats`.
## Cada una es { "campo", "delta" (ya con la escala), "formato", "texto" } (por ejemplo «+3 daño»).
## `table` es la lista de `UpgradeFxConfig.stats`.
static func compute(from: TowerLevelData, to: TowerLevelData, table: Array[Dictionary], max_stats: int = 4) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if from == null or to == null:
		return result
	for row: Dictionary in table:
		if result.size() >= max_stats:
			break
		var field: String = String(row["campo"])
		var raw_delta: float = float(to.get(field)) - float(from.get(field))
		if absf(raw_delta) < TOLERANCE:
			continue
		var delta: float = raw_delta * float(row.get("escala", 1.0))
		var kind: String = String(row["formato"])
		result.append({
			"campo": field, "delta": delta, "formato": kind,
			"texto": "%s %s" % [format_number(delta, kind), String(row["etiqueta"])],
		})
	return result


## Con signo y coma decimal, sin ceros de más: `+3`, `+0,5`, `−2`, y `+10 %` para el porcentaje.
static func format_number(value: float, kind: String) -> String:
	var sign_text: String = "+" if value >= 0.0 else MINUS
	var magnitude: float = absf(value)
	var text: String
	if kind == "decimal":
		text = _trim(magnitude)
	else:
		text = str(roundi(magnitude))
	if kind == "porcentaje":
		text += " %"
	return sign_text + text


## 2 decimales como mucho, sin ceros finales y con coma.
static func _trim(magnitude: float) -> String:
	var text: String = String.num(snappedf(magnitude, 0.01), 2)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	return text.replace(".", ",")


## «¡Nivel 2!», o «¡Nivel máximo!» en el último nivel.
static func header(level_number: int, is_max: bool) -> String:
	return "¡Nivel máximo!" if is_max else "¡Nivel %d!" % level_number


## Los textos de las estadísticas repartidos en renglones de `per_row`, separados con « · ».
static func rows(deltas: Array[Dictionary], per_row: int = 2) -> Array[String]:
	var lines: Array[String] = []
	var current: PackedStringArray = PackedStringArray()
	for delta: Dictionary in deltas:
		current.append(String(delta["texto"]))
		if current.size() >= maxi(per_row, 1):
			lines.append(SEPARATOR.join(current))
			current = PackedStringArray()
	if not current.is_empty():
		lines.append(SEPARATOR.join(current))
	return lines


## Dónde queda el bloque de texto. `anchor` es el punto de abajo al centro que se quería; `size` el tamaño
## del bloque (con lo que sube); todo en pantalla. Lo corre adentro de `view_rect` y, si cae sobre alguna zona
## prohibida (barra de abajo, tilde, cruz, botones flotantes), lo sube hasta dejarlo libre. Devuelve el nuevo anchor.
static func place_block(anchor: Vector2, size: Vector2, safe_rects: Array[Rect2], view_rect: Rect2) -> Vector2:
	var left: float = anchor.x - size.x / 2.0
	if size.x >= view_rect.size.x:
		left = view_rect.position.x + (view_rect.size.x - size.x) / 2.0
	else:
		left = clampf(left, view_rect.position.x, view_rect.end.x - size.x)
	var top: float = maxf(anchor.y - size.y, view_rect.position.y)
	for _attempt: int in range(safe_rects.size() + 1):
		var block := Rect2(left, top, size.x, size.y)
		var blocker: Variant = null
		for zone: Rect2 in safe_rects:
			if block.intersects(zone):
				blocker = zone
				break
		if blocker == null:
			break
		var moved: float = (blocker as Rect2).position.y - size.y
		if moved < view_rect.position.y or moved >= top:
			top = maxf(moved, view_rect.position.y)
			break
		top = moved
	return Vector2(left + size.x / 2.0, top + size.y)
