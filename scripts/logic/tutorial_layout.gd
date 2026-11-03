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


# --- T574 (RF-739): el efecto de foco. Todo esto es geometría pura; `TutorialOverlay` solo lo dibuja. ---

## Cuánto se agranda el anillo respecto del recuadro, en píxeles, cuando termina de expandirse.
const RING_REACH: float = 28.0
## Alto extra del rótulo respecto del texto, y el espacio entre el rótulo y lo señalado.
const LABEL_PAD: Vector2 = Vector2(14.0, 8.0)


## Dónde está el anillo en su ciclo (0 a 1). Se calcula con el reloj, no con el tiempo de juego: la partida
## puede estar en pausa o a ×2 y el efecto tiene que verse igual. `msec` viene de `Time.get_ticks_msec()`.
static func ring_phase(msec: int, seconds: float) -> float:
	if seconds <= 0.0:
		return 0.0
	return fposmod(float(msec) / 1000.0, seconds) / seconds


## El agujero del oscurecido: un solo rectángulo que cubre lo señalado (más `grow` de aire), recortado a la pantalla.
## Si cubrir todo pide más que `max_fraction` de la pantalla, o no hay nada que cubrir, devuelve un `Rect2` vacío:
## en ese caso no se oscurece (un agujero enorme no enfoca nada).
static func focus_hole(targets: Array[Rect2], grow: float, screen: Rect2, max_fraction: float) -> Rect2:
	if targets.is_empty():
		return Rect2()
	var hole: Rect2 = targets[0].grow(grow)
	for i: int in range(1, targets.size()):
		hole = hole.merge(targets[i].grow(grow))
	hole = hole.intersection(screen)
	if hole.size.x <= 0.0 or hole.size.y <= 0.0:
		return Rect2()
	if hole.get_area() > screen.get_area() * max_fraction:
		return Rect2()
	return hole


## Los cuatro rectángulos que oscurecen todo menos el agujero: [arriba, abajo, izquierda, derecha]. Sin agujero
## (`hole` vacío) oscurece la pantalla entera: arriba la cubre y los otros tres quedan vacíos.
static func shade_rects(hole: Rect2, screen: Rect2) -> Array[Rect2]:
	if hole.size == Vector2.ZERO:
		return [screen, Rect2(), Rect2(), Rect2()]
	var top := Rect2(screen.position, Vector2(screen.size.x, hole.position.y - screen.position.y))
	var bottom := Rect2(Vector2(screen.position.x, hole.end.y), Vector2(screen.size.x, screen.end.y - hole.end.y))
	var left := Rect2(Vector2(screen.position.x, hole.position.y), Vector2(hole.position.x - screen.position.x, hole.size.y))
	var right := Rect2(Vector2(hole.end.x, hole.position.y), Vector2(screen.end.x - hole.end.x, hole.size.y))
	return [top, bottom, left, right]


## Dónde va el rótulo («Tocá acá») junto a lo señalado: prefiere el lado opuesto a la tarjeta (arriba o abajo),
## después los costados, y nunca tapa la tarjeta ni se sale de la pantalla. Si nada entra, lo aprieta contra la pantalla.
static func label_rect(label_size: Vector2, target: Rect2, card: Rect2, screen: Rect2) -> Rect2:
	var cx: float = target.get_center().x - label_size.x / 2.0
	var cy: float = target.get_center().y - label_size.y / 2.0
	var above := Rect2(Vector2(cx, target.position.y - GAP - label_size.y), label_size)
	var below := Rect2(Vector2(cx, target.end.y + GAP), label_size)
	var right := Rect2(Vector2(target.end.x + GAP, cy), label_size)
	var left := Rect2(Vector2(target.position.x - GAP - label_size.x, cy), label_size)
	var candidates: Array[Rect2] = []
	if card.get_center().y < target.get_center().y:
		candidates.append_array([below, above, right, left])
	else:
		candidates.append_array([above, below, right, left])
	for candidate: Rect2 in candidates:
		var inside := Rect2(candidate.position.clamp(screen.position, screen.end - label_size), label_size)
		if inside.is_equal_approx(candidate) and not candidate.intersects(card) and not candidate.intersects(target):
			return candidate
	var fallback: Rect2 = candidates[0]
	fallback.position = fallback.position.clamp(screen.position, screen.end - label_size)
	return fallback


## El rótulo de un botón del riel, que queda fuera del marco: se apoya en el borde del marco del lado del riel,
## a la altura del botón, dejando `arrow_room` entre el borde y el rótulo para la flecha. `rail_rect` está en coordenadas del marco (puede tener x negativa o pasarse del ancho).
static func rail_label_rect(label_size: Vector2, rail_rect: Rect2, screen: Rect2, arrow_room: float = 0.0) -> Rect2:
	var on_left: bool = rail_rect.get_center().x < screen.get_center().x
	var x: float = screen.position.x + MARGIN + arrow_room if on_left else screen.end.x - MARGIN - arrow_room - label_size.x
	var y: float = clampf(rail_rect.get_center().y - label_size.y / 2.0, screen.position.y + MARGIN, screen.end.y - MARGIN - label_size.y)
	return Rect2(Vector2(x, y), label_size)
