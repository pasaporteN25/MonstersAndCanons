# Los temas del mapa (spec §7.11, RF-260, RF-261): el paisaje de todo un nivel. Es solo visual.
# Cada tema es una paleta y una lista de dibujos para las casillas bloqueadas (`X`). LevelDecor las
# usa para pintar; nada de esto cambia por dónde van los enemigos ni qué se puede construir.
# Los dibujos van con `preload` (no `load`): así se cargan junto con el script y siempre están listos.
class_name MapThemes
extends RefCounted

## El de siempre: si un nivel no dice tema, es este. RF-334 actualiza su material visual.
const DEFAULT: StringName = &"pradera"
const IDS: PackedStringArray = ["pradera", "desierto", "nieve", "volcan", "bosque", "pantano", "ruinas"]

const PATH_TEXTURE: Texture2D = preload("res://assets/tiles/rendered/path.png")
const GROUNDS: Dictionary = {
	&"pradera": preload("res://assets/tiles/rendered/ground_pradera.png"),
	&"desierto": preload("res://assets/tiles/rendered/ground_desierto.png"),
	&"nieve": preload("res://assets/tiles/rendered/ground_nieve.png"),
	&"volcan": preload("res://assets/tiles/rendered/ground_volcan.png"),
	&"bosque": preload("res://assets/tiles/rendered/ground_bosque.png"),
	&"pantano": preload("res://assets/tiles/rendered/ground_pantano.png"),
	&"ruinas": preload("res://assets/tiles/rendered/ground_ruinas.png"),
}

const ROCK_A: Texture2D = preload("res://assets/sprites/map/rendered/rock_a.png")
const ROCK_B: Texture2D = preload("res://assets/sprites/map/rendered/rock_b.png")
const TREE: Texture2D = preload("res://assets/sprites/map/rendered/tree.png")
const BUSH: Texture2D = preload("res://assets/sprites/map/rendered/bush.png")
const CACTUS: Texture2D = preload("res://assets/sprites/map/cactus.svg")
const RED_ROCK: Texture2D = preload("res://assets/sprites/map/roca_roja.svg")
const BONES: Texture2D = preload("res://assets/sprites/map/huesos.svg")
const PINE: Texture2D = preload("res://assets/sprites/map/pino.svg")
const FIR: Texture2D = preload("res://assets/sprites/map/abeto.svg")
const SNOW_ROCK: Texture2D = preload("res://assets/sprites/map/roca_nieve.svg")
const BLACK_ROCK: Texture2D = preload("res://assets/sprites/map/roca_negra.svg")
const CRACK: Texture2D = preload("res://assets/sprites/map/grieta.svg")
const COLUMN: Texture2D = preload("res://assets/sprites/map/columna.svg")
const BLOCK: Texture2D = preload("res://assets/sprites/map/bloque.svg")
const STATUE: Texture2D = preload("res://assets/sprites/map/estatua.svg")
const LOG: Texture2D = preload("res://assets/sprites/map/tronco.svg")
const FERN: Texture2D = preload("res://assets/sprites/map/helecho.svg")
const REEDS: Texture2D = preload("res://assets/sprites/map/junco.svg")
const MUSHROOM: Texture2D = preload("res://assets/sprites/map/hongo.svg")

## Lo que puede aparecer en una casilla bloqueada de cada tema. Lo que se repite sale más seguido
## (RF-154: en la pradera, las rocas son "acá no se construye").
const BLOCKED: Dictionary = {
	&"pradera": [ROCK_A, ROCK_B, TREE, ROCK_A, BUSH, ROCK_B],
	&"desierto": [CACTUS, RED_ROCK, BONES, CACTUS, RED_ROCK],
	&"nieve": [PINE, SNOW_ROCK, PINE, FIR, SNOW_ROCK, PINE],
	&"volcan": [BLACK_ROCK, CRACK, COLUMN, BLACK_ROCK, CRACK],
	&"bosque": [TREE, TREE, LOG, FERN, BUSH, TREE, FERN],
	&"pantano": [REEDS, LOG, MUSHROOM, REEDS, MUSHROOM, REEDS],
	&"ruinas": [COLUMN, BLOCK, STATUE, BLOCK, COLUMN, BLOCK],
}

## La paleta de cada tema. `fill_grass` y `fill_path` son el color de fondo de las casillas de suelo
## y de camino (null = se ve el color del TileSet, como siempre en la pradera). `detail` elige cómo
## se decora el suelo (LevelDecor): tufts, dunes, snow, cracks, leaves, mud o cobbles.
const PALETTES: Dictionary = {
	&"pradera": {
		"fill_grass": null, "fill_path": null, "detail": "tufts",
		"tuft": Color(0.28, 0.5, 0.2), "accent": Color(0.28, 0.5, 0.2),
		"flowers": [Color(1, 0.95, 0.6), Color(1, 0.75, 0.85), Color(0.95, 0.95, 1)], "flower_chance": 0.18,
		"edge": Color(0.62, 0.5, 0.3), "pebble": Color(0.7, 0.6, 0.42),
	},
	&"desierto": {
		"fill_grass": Color("#dcbc7c"), "fill_path": Color("#a9643f"), "detail": "dunes",
		"tuft": Color("#c49a55"), "accent": Color("#c49a55"), "flowers": [], "flower_chance": 0.0,
		"edge": Color("#7a452b"), "pebble": Color("#c98b5c"),
	},
	&"nieve": {
		"fill_grass": Color("#e9f0f8"), "fill_path": Color("#75604d"), "detail": "snow",
		"tuft": Color("#b5c9e0"), "accent": Color("#b5c9e0"), "flowers": [], "flower_chance": 0.0,
		"edge": Color("#4b3c31"), "pebble": Color("#93826f"),
	},
	&"volcan": {
		"fill_grass": Color("#4a4650"), "fill_path": Color("#9c9289"), "detail": "cracks",
		"tuft": Color("#34313c"), "accent": Color("#34313c"), "flowers": [], "flower_chance": 0.0,
		"edge": Color("#5a534e"), "pebble": Color("#b7aea5"),
	},
	&"bosque": {
		"fill_grass": Color("#28502f"), "fill_path": Color("#a07a4e"), "detail": "leaves",
		"tuft": Color("#1f4626"), "accent": Color("#1f4626"),
		"flowers": [Color("#c8792d"), Color("#e0b43a"), Color("#a5502a")], "flower_chance": 0.5,
		"edge": Color("#4a331f"), "pebble": Color("#937048"),
	},
	&"pantano": {
		"fill_grass": Color("#44503a"), "fill_path": Color("#a58a5c"), "detail": "mud",
		"tuft": Color("#5f8072"), "accent": Color("#3d4830"), "flowers": [], "flower_chance": 0.0,
		"edge": Color("#4d4028"), "pebble": Color("#5b4e36"),
	},
	&"ruinas": {
		"fill_grass": Color("#a29e91"), "fill_path": Color("#d5cfbd"), "detail": "cobbles",
		"tuft": Color("#6f8a4a"), "accent": Color("#7c786c"), "flowers": [], "flower_chance": 0.0,
		"edge": Color("#6d695e"), "pebble": Color("#b3ad9b"),
	},
}


static func is_valid(id: String) -> bool:
	return IDS.has(id)


## La paleta de un tema (uno desconocido usa la pradera).
static func palette(id: StringName) -> Dictionary:
	return PALETTES.get(id, PALETTES[DEFAULT])


## El dibujo de una casilla bloqueada (`X`): depende solo de la casilla y del tema, así el mapa
## siempre se ve igual (RF-154).
static func blocked_decor(id: StringName, cell: Vector2i) -> Texture2D:
	var list: Array = BLOCKED.get(id, BLOCKED[DEFAULT])
	return list[posmod(hash(cell), list.size())]


## Material del suelo; un tema desconocido usa la pradera.
static func ground_texture(id: StringName) -> Texture2D:
	return GROUNDS.get(id, GROUNDS[DEFAULT])
