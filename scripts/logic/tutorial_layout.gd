# Dónde va la tarjeta del tutorial (M63, RF-574). Lógica pura, sin escena (P10): dado el tamaño de la tarjeta,
# lo que se está señalando y el área libre de la pantalla, elige un lugar donde la tarjeta NO tape lo señalado.
class_name TutorialLayout
extends RefCounted

## Separación entre la tarjeta y el borde del área, y entre la tarjeta y lo señalado.
const MARGIN: float = 8.0
const GAP: float = 12.0
## Desde qué ancho un botón cuenta como «ancho» para la flecha lateral.
const WIDE_MIN_PX: float = 150.0


## El rectángulo de la tarjeta. `area` es la zona entre las barras (el mapa); `screen` es la pantalla entera.
## Si `over_bottom_bar` es `true` (el catálogo del celular tapa la barra de abajo con su sombra), también se
## puede apoyar sobre la barra de abajo. Se prefiere el lugar más lejos de lo señalado, centrado de lado a lado.
static func card_rect(card_size: Vector2, targets: Array[Rect2], area: Rect2, screen: Rect2, over_bottom_bar: bool = false) -> Rect2:
	var x: float = clampf(area.get_center().x - card_size.x / 2.0, screen.position.x + MARGIN, maxf(screen.position.x + MARGIN, screen.end.x - card_size.x - MARGIN))
	var candidates: Array[Rect2] = []
	candidates.append(Rect2(Vector2(x, area.end.y - card_size.y - MARGIN), card_size))  # abajo del mapa
	candidates.append(Rect2(Vector2(x, area.position.y + MARGIN), card_size))  # arriba del mapa
	if over_bottom_bar:
		candidates.push_front(Rect2(Vector2(x, screen.end.y - card_size.y - MARGIN), card_size))
	var best: Rect2 = candidates[0]
	var best_score: float = -INF
	for candidate: Rect2 in candidates:
		var score: float = _score(candidate, targets)
		if score > best_score + 0.001:  # a igual puntaje gana el primero (el de abajo)
			best_score = score
			best = candidate
	return best


## Más alto es mejor: sin tapar nada vale por la distancia mínima a lo señalado; tapando, es negativo.
static func _score(card: Rect2, targets: Array[Rect2]) -> float:
	if targets.is_empty():
		return 0.0
	var covered: float = 0.0
	var nearest: float = INF
	for target: Rect2 in targets:
		var padded: Rect2 = target.grow(GAP)
		var overlap: Rect2 = card.intersection(padded)
		covered += overlap.size.x * overlap.size.y
		nearest = minf(nearest, _distance(card, target))
	return -covered if covered > 0.0 else nearest


static func _distance(a: Rect2, b: Rect2) -> float:
	var dx: float = maxf(0.0, maxf(a.position.x - b.end.x, b.position.x - a.end.x))
	var dy: float = maxf(0.0, maxf(a.position.y - b.end.y, b.position.y - a.end.y))
	return sqrt(dx * dx + dy * dy)


## Dónde apoya la flecha: del lado de lo señalado que mira a la tarjeta, apuntándole. Devuelve el triángulo
## (tres puntos) o vacío si no hay nada señalado. `size` es el largo de la flecha.
static func arrow_points(target: Rect2, card: Rect2, size: float, screen: Rect2) -> PackedVector2Array:
	if target.size == Vector2.ZERO:
		return PackedVector2Array()
	# Un botón ancho y bajo (como «Mejorar» entre otros botones): la flecha entra por la izquierda, apuntando a la
	# derecha, para no tapar al vecino de arriba o de abajo.
	if target.size.x >= WIDE_MIN_PX and target.size.x > target.size.y * 2.0 and target.position.x > size * 1.5 + GAP:
		var middle: float = target.get_center().y
		var tip_x: float = target.position.x - GAP / 2.0
		var base_x: float = tip_x - size
		return PackedVector2Array([Vector2(tip_x, middle), Vector2(base_x, middle - size * 0.6), Vector2(base_x, middle + size * 0.6)])
	var below: bool = card.get_center().y > target.get_center().y  # la tarjeta está abajo: la flecha va debajo y apunta arriba
	var tip_y: float
	var base_y: float
	if below:
		tip_y = target.end.y + GAP / 2.0
		base_y = tip_y + size
	else:
		tip_y = target.position.y - GAP / 2.0
		base_y = tip_y - size
	var cx: float = clampf(target.get_center().x, screen.position.x + size, screen.end.x - size)
	var points := PackedVector2Array([Vector2(cx, tip_y), Vector2(cx - size * 0.6, base_y), Vector2(cx + size * 0.6, base_y)])
	return points
