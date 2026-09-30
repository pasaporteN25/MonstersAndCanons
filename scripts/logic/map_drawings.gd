# El catálogo de dibujos que una leyenda puede pedir (spec §7.11, RF-263). Es una lista CERRADA: un
# archivo de nivel elige un nombre, no trae imágenes (D-039). Cómo se pinta cada uno lo hace LevelDecor.
class_name MapDrawings
extends RefCounted

## "suelo" cubre toda la casilla y se une con los vecinos iguales; "objeto" se dibuja sobre el suelo del tema.
const KIND_GROUND: String = "suelo"
const KIND_OBJECT: String = "objeto"

const KINDS: Dictionary = {
	"roca": KIND_OBJECT, "arbol": KIND_OBJECT, "arbusto": KIND_OBJECT, "flores": KIND_OBJECT,
	"cactus": KIND_OBJECT, "pino": KIND_OBJECT, "columna": KIND_OBJECT, "tronco": KIND_OBJECT,
	"helecho": KIND_OBJECT, "junco": KIND_OBJECT, "hongo": KIND_OBJECT, "estatua": KIND_OBJECT,
	"agua": KIND_GROUND, "hielo": KIND_GROUND, "lava": KIND_GROUND, "barro": KIND_GROUND,
}


static func ids() -> PackedStringArray:
	return PackedStringArray(KINDS.keys())


static func is_valid(id: String) -> bool:
	return KINDS.has(id)


static func kind(id: String) -> String:
	return KINDS.get(id, "")
