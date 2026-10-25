class_name CampaignMap
extends RefCounted
## Modelo puro del selector planetario (M72, RF-645, RF-647, D-178, D-179): el estilo elegido y el estado
## visual de cada región. No guarda nada: todo sale del desbloqueo y de las estrellas que ya existen.

enum State { LOCKED, AVAILABLE, REBEL, TAKEN }

const STYLE_CARDS: int = 0
const STYLE_MAP: int = 1
const REGION_COUNT: int = 15

## Zonas de descubrimiento del atlas (M78, RF-709, D-209): A = niveles 1–5, B = 6–10, C = 11–15. Son índices
## de región (desde 0): la zona B empieza en el nivel 6 (índice 5) y la C en el 11 (índice 10).
const ZONE_A: int = 0
const ZONE_B: int = 1
const ZONE_C: int = 2
const ZONE_COUNT: int = 3
const ZONE_B_FIRST_REGION: int = 5
const ZONE_C_FIRST_REGION: int = 10

## Coordenadas de la muestra aprobada (`art/t427-mapa-propuesta/mapa.svg`, 1280×720). El recuadro del mapa
## empieza en `SEA_ORIGIN` y mide `SEA_SIZE`.
const SEA_ORIGIN := Vector2(20, 90)
const SEA_SIZE := Vector2(1240, 472)
const LANDER := Vector2(181, 465)
const REGION_POINTS: Array[Vector2] = [
	Vector2(251, 397), Vector2(347, 337), Vector2(456, 314), Vector2(560, 371), Vector2(663, 300),
	Vector2(752, 398), Vector2(851, 335), Vector2(953, 276), Vector2(1058, 321), Vector2(1066, 407),
	Vector2(956, 448), Vector2(846, 466), Vector2(716, 467), Vector2(597, 455), Vector2(498, 421),
]
const LAND_COORDS: Array[float] = [
	101, 316, 120, 268, 157, 236, 177, 196, 231, 176, 271, 143, 321, 151, 354, 125, 405, 143, 442, 125, 487, 151,
	523, 136, 561, 164, 602, 156, 635, 179, 684, 163, 730, 184, 776, 170, 812, 190, 856, 182, 898, 208, 943, 206,
	982, 232, 1034, 232, 1066, 256, 1114, 250, 1149, 278, 1170, 314, 1153, 350, 1164, 381, 1139, 412, 1110, 425,
	1083, 461, 1043, 471, 1008, 492, 967, 483, 941, 513, 902, 503, 865, 523, 829, 507, 788, 532, 750, 511, 710, 525,
	673, 501, 636, 511, 600, 480, 555, 488, 526, 456, 481, 469, 444, 442, 399, 452, 369, 424, 331, 427, 306, 399,
	265, 408, 233, 383, 196, 388, 166, 359, 128, 360,
]


## El estilo guardado en `settings`. Sin clave, o con un valor que no sea 0 o 1 (guardado viejo o dañado),
## vale tarjetas (D-178).
static func style_from(raw: Variant) -> int:
	if typeof(raw) in [TYPE_INT, TYPE_FLOAT] and float(raw) == float(int(raw)) and int(raw) == STYLE_MAP:
		return STYLE_MAP
	return STYLE_CARDS


## ¿`raw` es un estilo guardado válido (0 o 1, también como float de JSON)? (RF-689)
static func is_valid_style(raw: Variant) -> bool:
	return typeof(raw) in [TYPE_INT, TYPE_FLOAT] and float(raw) == float(int(raw)) and int(raw) in [STYLE_CARDS, STYLE_MAP]


## El estado de una región (D-179). Completado con 1–2 estrellas deja presencia rebelde; con 3, zona tomada.
static func state_of(unlocked: bool, completed: bool, stars: int) -> State:
	if not unlocked:
		return State.LOCKED
	if not completed:
		return State.AVAILABLE
	return State.TAKEN if stars >= 3 else State.REBEL


## Los estados de todas las regiones, en el orden de los niveles. Los tres arreglos tienen el mismo largo.
static func states(unlocked: Array, completed: Array, stars: Array) -> Array[State]:
	var result: Array[State] = []
	for i: int in unlocked.size():
		result.append(state_of(bool(unlocked[i]), bool(completed[i]), int(stars[i])))
	return result


## La región que arranca seleccionada: la primera habilitada sin victoria; si no hay, la última habilitada.
static func default_selection(region_states: Array[State]) -> int:
	var last_open: int = 0
	for i: int in region_states.size():
		if region_states[i] == State.AVAILABLE:
			return i
		if region_states[i] != State.LOCKED:
			last_open = i
	return last_open


static func state_text(state: State) -> String:
	match state:
		State.LOCKED:
			return "Bloqueada"
		State.AVAILABLE:
			return "Disponible"
		State.REBEL:
			return "Presencia rebelde"
	return "Zona tomada"


## Si la región se puede abrir (RF-111): todo menos bloqueada.
static func is_open(state: State) -> bool:
	return state != State.LOCKED


static func land_polygon() -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in range(0, LAND_COORDS.size(), 2):
		points.append(Vector2(LAND_COORDS[i], LAND_COORDS[i + 1]))
	return points


## La zona (ZONE_A, ZONE_B o ZONE_C) a la que pertenece la región `index`. Fuera de 0–14 no hay zona: devuelve -1.
static func zone_of(index: int) -> int:
	if index < 0 or index >= REGION_COUNT:
		return -1
	if index >= ZONE_C_FIRST_REGION:
		return ZONE_C
	return ZONE_B if index >= ZONE_B_FIRST_REGION else ZONE_A


## La zona más lejana descubierta (RF-709, RF-711). Es derivada: la A siempre; la B si alguna región de la 6 en
## adelante figura desbloqueada; la C si lo está alguna de la 11 en adelante. Solo cuenta `true` booleano:
## un `unlocked` que no sea arreglo, o con elementos no booleanos, se trata como bloqueado. Solo mira las
## primeras `REGION_COUNT` posiciones. No modifica `unlocked` ni guarda nada.
static func furthest_discovered_zone(unlocked: Variant) -> int:
	if typeof(unlocked) != TYPE_ARRAY:
		return ZONE_A
	var list: Array = unlocked
	var furthest: int = ZONE_A
	for i: int in mini(list.size(), REGION_COUNT):
		if typeof(list[i]) == TYPE_BOOL and list[i]:
			furthest = maxi(furthest, zone_of(i))
	return furthest


## ¿La región `index` está en una zona descubierta? (RF-709, RF-710). Una región oculta no se dibuja con detalle,
## no recibe foco y no se puede seleccionar.
static func is_region_discovered(unlocked: Variant, index: int) -> bool:
	var zone: int = zone_of(index)
	return zone >= 0 and zone <= furthest_discovered_zone(unlocked)


## Para cada una de las `REGION_COUNT` regiones, si su zona está descubierta. Siempre devuelve 15 valores,
## sin importar el largo de `unlocked`.
static func discovered_regions(unlocked: Variant) -> Array[bool]:
	var result: Array[bool] = []
	var furthest: int = furthest_discovered_zone(unlocked)
	for i: int in REGION_COUNT:
		result.append(zone_of(i) <= furthest)
	return result


## Los índices de las regiones que admiten foco con las flechas y selección (RF-710), en orden. Descubrir una
## zona no abre niveles: que se pueda jugar sigue dependiendo de `unlocked` (RF-111).
static func focusable_regions(unlocked: Variant) -> Array[int]:
	var result: Array[int] = []
	var furthest: int = furthest_discovered_zone(unlocked)
	for i: int in REGION_COUNT:
		if zone_of(i) <= furthest:
			result.append(i)
	return result
