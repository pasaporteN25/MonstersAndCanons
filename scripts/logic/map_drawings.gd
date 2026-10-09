# El catálogo de dibujos que una leyenda puede pedir (spec §7.11, RF-263). Es una lista CERRADA: un
# archivo de nivel elige un nombre, no trae imágenes (D-039). Cómo se pinta lo hace LevelDecor:
# los "objetos" son un dibujo sobre el suelo del tema; los "suelos" (agua, hielo, lava, barro) cubren
# toda la casilla y se dibujan por código, con un borde donde termina la mancha.
class_name MapDrawings
extends RefCounted

const KIND_GROUND: String = "suelo"
const KIND_OBJECT: String = "objeto"

const KINDS: Dictionary = {
	"roca": KIND_OBJECT, "arbol": KIND_OBJECT, "arbusto": KIND_OBJECT, "flores": KIND_OBJECT,
	"cactus": KIND_OBJECT, "pino": KIND_OBJECT, "columna": KIND_OBJECT, "tronco": KIND_OBJECT,
	"helecho": KIND_OBJECT, "junco": KIND_OBJECT, "hongo": KIND_OBJECT, "estatua": KIND_OBJECT,
	"escombro": KIND_OBJECT, "mina": KIND_OBJECT, "bosque_explotable": KIND_OBJECT,
	"roca_marcada": KIND_OBJECT, "sendero": KIND_OBJECT, "herramienta": KIND_OBJECT,
	"poste_cintas": KIND_OBJECT, "simbolo_ruina": KIND_OBJECT, "campamento_vacio": KIND_OBJECT,
	"central_1": KIND_OBJECT, "central_2": KIND_OBJECT, "central_3": KIND_OBJECT, "central_4": KIND_OBJECT,
	"supply_depot": KIND_OBJECT, "supply_line_pole": KIND_OBJECT, "supply_cart": KIND_OBJECT,
	"supply_conveyor": KIND_OBJECT,
	"agua": KIND_GROUND, "hielo": KIND_GROUND, "lava": KIND_GROUND, "barro": KIND_GROUND,
}

const FLOWERS: Texture2D = preload("res://assets/sprites/map/flores.svg")
const SIGNAL_ROCK: Texture2D = preload("res://assets/sprites/map/roca_marcada.svg")
const SIGNAL_PATH: Texture2D = preload("res://assets/sprites/map/sendero.svg")
const SIGNAL_TOOL: Texture2D = preload("res://assets/sprites/map/herramienta.svg")
const SIGNAL_RIBBONS: Texture2D = preload("res://assets/sprites/map/poste_cintas.svg")
const SIGNAL_RUIN: Texture2D = preload("res://assets/sprites/map/simbolo_ruina.svg")
const SIGNAL_CAMP: Texture2D = preload("res://assets/sprites/map/campamento_vacio.svg")
## T234 (RF-480): la central de energía del nivel 15, en cuatro cuartos de 64 × 64 (noroeste, noreste, suroeste y
## sureste) sobre cuatro casillas contiguas, y las piezas de la cadena de abastecimiento. Son decoración permanente.
const CENTRAL_1: Texture2D = preload("res://assets/sprites/map/central_1.svg")
const CENTRAL_2: Texture2D = preload("res://assets/sprites/map/central_2.svg")
const CENTRAL_3: Texture2D = preload("res://assets/sprites/map/central_3.svg")
const CENTRAL_4: Texture2D = preload("res://assets/sprites/map/central_4.svg")
const SUPPLY_DEPOT: Texture2D = preload("res://assets/sprites/map/supply_depot.svg")
const SUPPLY_LINE_POLE: Texture2D = preload("res://assets/sprites/map/supply_line_pole.svg")
const SUPPLY_CART: Texture2D = preload("res://assets/sprites/map/supply_cart.svg")
const SUPPLY_CONVEYOR: Texture2D = preload("res://assets/sprites/map/supply_conveyor.svg")

## El dibujo de cada objeto. Van con `preload` (se cargan con el script).
const TEXTURES: Dictionary = {
	"roca": MapThemes.ROCK_A, "arbol": MapThemes.TREE, "arbusto": MapThemes.BUSH, "flores": FLOWERS,
	"cactus": MapThemes.CACTUS, "pino": MapThemes.PINE, "columna": MapThemes.COLUMN, "tronco": MapThemes.LOG,
	"helecho": MapThemes.FERN, "junco": MapThemes.REEDS, "hongo": MapThemes.MUSHROOM, "estatua": MapThemes.STATUE,
	"roca_marcada": SIGNAL_ROCK, "sendero": SIGNAL_PATH, "herramienta": SIGNAL_TOOL,
	"poste_cintas": SIGNAL_RIBBONS, "simbolo_ruina": SIGNAL_RUIN, "campamento_vacio": SIGNAL_CAMP,
	"central_1": CENTRAL_1, "central_2": CENTRAL_2, "central_3": CENTRAL_3, "central_4": CENTRAL_4,
	"supply_depot": SUPPLY_DEPOT, "supply_line_pole": SUPPLY_LINE_POLE, "supply_cart": SUPPLY_CART,
	"supply_conveyor": SUPPLY_CONVEYOR,
}

## Los colores de cada suelo: el fondo, un tono claro (reflejos), uno oscuro (fondo, sombras) y el borde.
const GROUNDS: Dictionary = {
	"agua": {"base": Color("#3f86c7"), "light": Color("#9ccdf2"), "dark": Color("#2b64a3"), "edge": Color("#1f4a7a")},
	"hielo": {"base": Color("#bfe3f2"), "light": Color("#f4fcff"), "dark": Color("#8fc0d8"), "edge": Color("#5f95b0")},
	"lava": {"base": Color("#d84a1b"), "light": Color("#ffc25a"), "dark": Color("#8f2a12"), "edge": Color("#3d1710")},
	"barro": {"base": Color("#6b5433"), "light": Color("#8f7448"), "dark": Color("#4b3a22"), "edge": Color("#33270f")},
}


static func ids() -> PackedStringArray:
	return PackedStringArray(KINDS.keys())


static func is_valid(id: String) -> bool:
	return KINDS.has(id)


static func kind(id: String) -> String:
	return KINDS.get(id, "")


## El dibujo de un objeto (null si es un suelo o no existe).
static func texture(id: String) -> Texture2D:
	return TEXTURES.get(id)


## Los colores de un suelo (vacío si es un objeto o no existe).
static func ground_colors(id: String) -> Dictionary:
	return GROUNDS.get(id, {})
