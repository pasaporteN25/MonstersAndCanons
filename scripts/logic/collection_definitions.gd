# Las colecciones de `data/progression.json` (RF-425): qué piezas tiene cada una y de dónde salen.
# Generaliza lo que hacía `CollectibleRun.definitions()`; `technology` queda idéntica porque `origen`
# vale `"portador"` por omisión.
class_name CollectionDefinitions
extends RefCounted

const PATH: String = "res://data/progression.json"
const ORIGIN_CARRIER: StringName = &"portador"
const ORIGIN_FINDING: StringName = &"hallazgo"
## Colección que muestra la barra cuando el nivel no es fuente de ninguna (RF-431).
const DEFAULT_COLLECTION: StringName = &"technology"
## El disco plateado de siempre: lo usa toda colección que no trae su propio `icono` (la silueta propia
## de cada colección llega con el arte, Q-39).
const DEFAULT_ICON: String = "res://assets/ui/technology_token.svg"


## Todo el archivo: {id de colección: definición}. Vacío si no se puede leer.
static func all() -> Dictionary:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(PATH)) != OK:
		return {}
	return json.data if json.data is Dictionary else {}


static func ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for key: Variant in all():
		result.append(StringName(key))
	return result


static func exists(collection_id: StringName) -> bool:
	return all().has(String(collection_id))


static func _definition(collection_id: StringName) -> Dictionary:
	return all().get(String(collection_id), {})


static func required(collection_id: StringName) -> int:
	return int(_definition(collection_id).get("required", 0))


static func sources(collection_id: StringName) -> PackedStringArray:
	return PackedStringArray(_definition(collection_id).get("sources", []))


static func eligible(collection_id: StringName, source_id: StringName) -> bool:
	return sources(collection_id).has(String(source_id))


## RF-425: `"portador"` (el valor por omisión) o `"hallazgo"`.
static func origin(collection_id: StringName) -> StringName:
	return StringName(_definition(collection_id).get("origen", String(ORIGIN_CARRIER)))


static func name_of(collection_id: StringName) -> String:
	return String(_definition(collection_id).get("nombre", String(collection_id).capitalize()))


## La ruta del `icono` de los datos, o la del disco plateado si la colección no trae uno.
static func icon_of(collection_id: StringName) -> String:
	return String(_definition(collection_id).get("icono", DEFAULT_ICON))


## RF-431: la colección de la que `level_id` es fuente, o `technology` si no es fuente de ninguna.
static func collection_of_level(level_id: StringName) -> StringName:
	for id: StringName in ids():
		if eligible(id, level_id):
			return id
	return DEFAULT_COLLECTION


## RF-425: un `required` que no coincide con la cantidad de `sources` es un error. Devuelve los
## mensajes (vacío si todo está bien); los tests exigen que con los datos oficiales no haya ninguno.
static func problems() -> PackedStringArray:
	var result := PackedStringArray()
	for id: StringName in ids():
		if required(id) != sources(id).size():
			result.append("La colección \"%s\" pide %d piezas pero tiene %d fuentes." % [id, required(id), sources(id).size()])
		if origin(id) != ORIGIN_CARRIER and origin(id) != ORIGIN_FINDING:
			result.append("La colección \"%s\" tiene un origen desconocido: \"%s\"." % [id, origin(id)])
	return result
