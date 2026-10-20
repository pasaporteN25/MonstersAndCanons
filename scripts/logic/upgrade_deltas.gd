# Lo que suma una mejora de torre y dónde se muestra (M65, RF-591, RF-592, D-136).
# Lógica pura: no sabe de escenas (P10). Los números salen de los dos `TowerLevelData` (los .tres), nunca de acá.
class_name UpgradeDeltas
extends RefCounted

## Una diferencia menor que esto cuenta como «no cambió» (los decimales de los .tres).
const TOLERANCE: float = 0.005
const SEPARATOR: String = " · "
const MINUS: String = "−"
const ARROW: String = "→"


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


## M68 (RF-616, RF-617, D-163): lo mismo que `compute`, pero cada estadística dice cómo está **antes** y cómo queda
## **después** (por ejemplo «daño 5 → 8»). Usa la misma tabla (`data/ui/mejoras.json`), el mismo orden, la misma
## tolerancia y el mismo tope, así que nunca muestra una estadística que el efecto de la mejora no mostraría.
## Cada una es { "campo", "antes", "despues" (ya con la escala), "formato", "texto" }.
static func before_after(from: TowerLevelData, to: TowerLevelData, table: Array[Dictionary], max_stats: int = 4) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for delta: Dictionary in compute(from, to, table, max_stats):
		var field: String = String(delta["campo"])
		var scale: float = 1.0
		var label: String = field
		for row: Dictionary in table:
			if String(row["campo"]) == field:
				scale = float(row.get("escala", 1.0))
				label = String(row["etiqueta"])
				break
		var kind: String = String(delta["formato"])
		var before: float = float(from.get(field)) * scale
		var after: float = float(to.get(field)) * scale
		result.append({
			"campo": field, "antes": before, "despues": after, "formato": kind,
			"texto": "%s %s %s %s" % [label, format_value(before, kind), ARROW, format_value(after, kind)],
		})
	return result


## Lo que cambia al pasar del nivel `level_index` (empieza en 0) al siguiente; vacío en el último nivel (RF-616).
static func preview(levels: Array[TowerLevelData], level_index: int, table: Array[Dictionary], max_stats: int = 4) -> Array[Dictionary]:
	if level_index < 0 or level_index + 1 >= levels.size():
		return []
	return before_after(levels[level_index], levels[level_index + 1], table, max_stats)


## Un valor sin signo: `5`, `1,5`, `30 %`.
static func format_value(value: float, kind: String) -> String:
	var text: String = _trim(absf(value)) if kind == "decimal" else str(roundi(absf(value)))
	if kind == "porcentaje":
		text += " %"
	return ("%s%s" % [MINUS, text]) if value < 0.0 and text != "0" else text


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
## prohibida (barra de abajo, tilde, cruz, botones flotantes), lo sube hasta dejarlo libre; si arriba no hay
## lugar (una torre pegada al borde de arriba) prueba al costado y, al final, abajo. Devuelve el nuevo anchor.
static func place_block(anchor: Vector2, size: Vector2, safe_rects: Array[Rect2], view_rect: Rect2) -> Vector2:
	var base: Vector2 = _clamp_corner(Vector2(anchor.x - size.x / 2.0, anchor.y - size.y), size, view_rect)
	var best: Vector2 = base
	if _is_blocked(base, size, safe_rects):
		var best_cost: float = INF
		var frontier: Array[Vector2] = [base]
		for _depth: int in range(3):
			var next: Array[Vector2] = []
			for corner: Vector2 in frontier:
				var block := Rect2(corner, size)
				for zone: Rect2 in safe_rects:
					if not block.intersects(zone):
						continue
					for candidate: Vector2 in [Vector2(corner.x, zone.position.y - size.y), Vector2(corner.x, zone.end.y),
							Vector2(zone.end.x, corner.y), Vector2(zone.position.x - size.x, corner.y)]:
						candidate = _clamp_corner(candidate, size, view_rect)
						if _is_blocked(candidate, size, safe_rects):
							next.append(candidate)
							continue
						# Subir es lo preferido; bajar o correr al costado, un poco menos.
						var moved_up: float = base.y - candidate.y
						var cost: float = absf(candidate.x - base.x) * 1.5 + (moved_up if moved_up > 0.0 else -moved_up * 2.0)
						if cost < best_cost:
							best_cost = cost
							best = candidate
			if best_cost < INF:
				break
			frontier = next
	return Vector2(best.x + size.x / 2.0, best.y + size.y)


static func _clamp_corner(corner: Vector2, size: Vector2, view_rect: Rect2) -> Vector2:
	var x: float = view_rect.position.x + (view_rect.size.x - size.x) / 2.0
	if size.x < view_rect.size.x:
		x = clampf(corner.x, view_rect.position.x, view_rect.end.x - size.x)
	var y: float = view_rect.position.y
	if size.y < view_rect.size.y:
		y = clampf(corner.y, view_rect.position.y, view_rect.end.y - size.y)
	return Vector2(x, y)


static func _is_blocked(corner: Vector2, size: Vector2, safe_rects: Array[Rect2]) -> bool:
	var block := Rect2(corner, size)
	for zone: Rect2 in safe_rects:
		if block.intersects(zone):
			return true
	return false
