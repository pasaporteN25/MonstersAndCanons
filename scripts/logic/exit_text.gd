# Texto del diálogo de la flecha «← Menú» (M53, RF-460): qué se pierde al abandonar la partida.
# Lógica pura, sin escena (P10).
class_name ExitText
extends RefCounted

const TITLE: String = "¿Volver al menú principal?"
const ALWAYS: String = "Se abandona esta partida. El oro, las torres y la oleada actual no se guardan."
const JOB: String = "La demolición en curso se pierde y no devuelve el oro."
## Como lo llama la barra de arriba (`Hud.show_collection`).
const TECHNOLOGY_NAME: String = "Avances tecnológicos"
const KEPT: String ="Lo que ya ganaste (niveles, estrellas, récords y piezas guardadas) se conserva."


## `collections` trae una entrada por cada pieza recogida en esta partida (pendiente o confirmada pero sin
## guardar), con el id de su colección. Los nombres salen de los datos.
static func message(collections: Array[String], job_active: bool) -> String:
	var lines: Array[String] = [ALWAYS]
	if not collections.is_empty():
		lines.append(pieces_line(collections))
	if job_active:
		lines.append(JOB)
	lines.append(KEPT)
	return "\n\n".join(lines)


## «Perdés 2 piezas de colección recogidas en esta partida (Avances tecnológicos, Disruptora). Se guardan
## recién al terminar la partida.»
static func pieces_line(collections: Array[String]) -> String:
	var names: Array[String] = []
	for id: String in collections:
		var name: String = collection_name(StringName(id))
		if not names.has(name):
			names.append(name)
	var count: int = collections.size()
	var noun: String = "1 pieza de colección recogida" if count == 1 else "%d piezas de colección recogidas" % count
	return "Perdés %s en esta partida (%s). Se guardan recién al terminar la partida." % [noun, ", ".join(names)]


## El nombre de la colección: el de los datos, y «Avances tecnológicos» para la de siempre (que no trae `nombre`).
static func collection_name(collection: StringName) -> String:
	if collection == CollectionDefinitions.DEFAULT_COLLECTION:
		return TECHNOLOGY_NAME
	return CollectionDefinitions.name_of(collection)
