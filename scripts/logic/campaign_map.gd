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

## Coordenadas del atlas aprobado (T485, ruta B de T484; `art/t485-atlas-biomas/`, 1280×720; M76/T471). El recuadro del
## mapa empieza en `SEA_ORIGIN` y mide `SEA_SIZE`. Modelo y fondo (`assets/ui/campaign_map_background.svg`) salen de la
## misma fuente con `art/t471-geografia/build_background.py`. La muestra anterior (T427/T428) queda como antecedente.
const SEA_ORIGIN := Vector2(20, 90)
const SEA_SIZE := Vector2(1240, 472)
const LANDER := Vector2(177, 310)
const REGION_POINTS: Array[Vector2] = [
	Vector2(242, 345), Vector2(297, 299), Vector2(368, 250), Vector2(443, 262), Vector2(492, 317),
	Vector2(557, 343), Vector2(603, 389), Vector2(682, 389), Vector2(759, 342), Vector2(835, 321),
	Vector2(895, 323), Vector2(951, 292), Vector2(1000, 287), Vector2(1065, 312), Vector2(1124, 362),
]
## Curva de cada tramo del recorrido, de oeste a este: tres puntos por tramo (control 1, control 2 y destino). El
## tramo `i` va desde `LANDER` (i = 0) o desde `REGION_POINTS[i - 1]` hasta `REGION_POINTS[i]` (Bézier cúbica).
const ROUTE_CONTROLS: Array[Vector2] = [
	Vector2(198, 315), Vector2(218, 334), Vector2(242, 345),
	Vector2(261, 348), Vector2(281, 324), Vector2(297, 299),
	Vector2(315, 270), Vector2(340, 249), Vector2(368, 250),
	Vector2(397, 250), Vector2(419, 252), Vector2(443, 262),
	Vector2(469, 273), Vector2(478, 299), Vector2(492, 317),
	Vector2(507, 332), Vector2(536, 329), Vector2(557, 343),
	Vector2(579, 357), Vector2(582, 382), Vector2(603, 389),
	Vector2(626, 397), Vector2(653, 390), Vector2(682, 389),
	Vector2(712, 388), Vector2(738, 360), Vector2(759, 342),
	Vector2(786, 320), Vector2(813, 320), Vector2(835, 321),
	Vector2(858, 319), Vector2(874, 326), Vector2(895, 323),
	Vector2(919, 321), Vector2(933, 300), Vector2(951, 292),
	Vector2(968, 284), Vector2(984, 280), Vector2(1000, 287),
	Vector2(1023, 293), Vector2(1044, 299), Vector2(1065, 312),
	Vector2(1086, 326), Vector2(1107, 344), Vector2(1124, 362),
]
## La costa del continente, aplanada de la fuente (cada curva en cuatro tramos).
const LAND_COORDS: Array[float] = [
	108, 318, 111.5, 301.1, 120.1, 287.6, 131.2, 275.1, 142, 261, 153, 235, 163.5, 221.4, 177.4, 211.9, 192.5,
	203.6, 207, 194, 226, 169, 239.6, 162.7, 254.2, 159.9, 269.3, 157.6, 284, 153, 297.1, 146.4, 309.8, 139.2,
	322.8, 134.7, 337, 136, 358, 144, 370.2, 142.1, 381.9, 137.4, 394.1, 133.2, 408, 133, 438, 149, 455.4,
	155.6, 471.8, 158.9, 486.9, 163.5, 501, 174, 511.3, 187.9, 519.2, 201.2, 528.3, 212, 542, 218, 557.1, 215.5,
	569.5, 208, 581.9, 199.7, 597, 195, 618, 200, 631.2, 196.1, 640.1, 188.4, 648.5, 180.5, 660, 176, 675,
	177.6, 686.5, 182.9, 698, 188, 713, 189, 734, 183, 745.3, 187.2, 755.2, 194.5, 766.3, 201.8, 781, 206,
	800.2, 210.4, 814, 217.2, 826.3, 223.7, 841, 227, 854.9, 225, 867.1, 220.1, 878.8, 216.2, 891, 217, 910,
	224, 921.6, 224.9, 931.2, 220.5, 939.8, 213.9, 948, 208, 964, 190, 975.2, 188.7, 985.6, 193.9, 996.2, 201.1,
	1008, 206, 1026, 201, 1034.9, 206.1, 1041.1, 215.1, 1047.5, 225, 1057, 233, 1070, 248, 1077.8, 258.8,
	1084.2, 269.4, 1091.1, 278.2, 1100, 284, 1112.2, 288.9, 1122.5, 297.5, 1132.1, 307.6, 1142, 317, 1150.9,
	327.2, 1156.1, 339.5, 1157, 353.3, 1153, 368, 1142, 385, 1131.8, 394.5, 1118.5, 402.4, 1105.2, 411.6, 1095,
	425, 1070, 448, 1058.3, 454.3, 1045, 457.2, 1030.9, 459.8, 1017, 465, 998, 478, 986.1, 481, 973.9, 478.1,
	960.7, 473.9, 946, 473, 931.2, 478.1, 920.4, 485, 910.1, 490.4, 897, 491, 869, 477, 856.8, 475.7, 845.9,
	479.4, 834, 483.6, 819, 484, 801.9, 479, 787.1, 472.1, 773.3, 467, 759, 467, 736, 473, 722.7, 469.3, 712.4,
	462.1, 701.8, 455.1, 688, 452, 665, 460, 650.7, 457.1, 639.2, 449.5, 628.2, 441.2, 615, 436, 594, 444, 584,
	440, 574.1, 431.9, 562.9, 423.6, 549, 419, 526, 425, 511.9, 421, 502, 414.5, 492.8, 409.5, 481, 410, 466.5,
	415.1, 455.4, 419.9, 444, 422.2, 429, 420, 406, 405, 393.6, 405.1, 383.4, 409.9, 373, 414.4, 360, 414, 335,
	394, 321.8, 393.4, 309.8, 397.2, 297.3, 400.8, 283, 399, 273.4, 393, 264.5, 387, 254.9, 383.2, 243, 384,
	223, 389, 213.1, 386.2, 204.5, 379.9, 195.2, 373.4, 183, 370, 164, 375, 153.2, 370.7, 146.5, 362.1, 139.8,
	353.8, 129, 350, 122.2, 347, 117.4, 339.2, 113.1, 328.9,
]


## Los puntos de la curva del tramo `index` (0 a 14) del recorrido, incluidos los extremos: `steps` + 1 puntos.
static func route_polyline(index: int, steps: int = 12) -> PackedVector2Array:
	var from: Vector2 = LANDER if index == 0 else REGION_POINTS[index - 1]
	var c1: Vector2 = ROUTE_CONTROLS[index * 3]
	var c2: Vector2 = ROUTE_CONTROLS[index * 3 + 1]
	var to: Vector2 = ROUTE_CONTROLS[index * 3 + 2]
	var points := PackedVector2Array()
	for i: int in steps + 1:
		points.append(from.bezier_interpolate(c1, c2, to, float(i) / float(steps)))
	return points


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
