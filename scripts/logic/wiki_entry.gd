# Una entrada de la wiki (spec §10.5): un enemigo, una torre, un artículo… La pantalla no sabe de
# qué es: solo dibuja su título, su dibujo y sus bloques. Es puro dato, así se prueba sin ventanas.
#
# Un bloque es un diccionario con la clave "tipo":
#   {"tipo": "titulo", "texto": "…"}                     un subtítulo
#   {"tipo": "texto", "texto": "…"}                      un párrafo
#   {"tipo": "datos", "filas": [["Vida", "40"], …]}      pares nombre / valor
#   {"tipo": "tabla", "filas": [["Nivel", "Costo"], …]}  la primera fila es el encabezado
class_name WikiEntry
extends RefCounted

const KIND_HEADING: String = "titulo"
const KIND_TEXT: String = "texto"
const KIND_FACTS: String = "datos"
const KIND_TABLE: String = "tabla"

var id: StringName = &""
var title: String = ""
var subtitle: String = ""
## Las capas del dibujo, de atrás para adelante (una torre: base y torreta). Vacío = sin dibujo.
var icon: Array[Texture2D] = []
var blocks: Array[Dictionary] = []
## Entrada cerrada del bestiario (RF-239): el jugador todavía no la descubrió. No lleva ningún dato
## real, solo el aviso; el dibujo se ve en silueta.
var locked: bool = false


func add_heading(text: String) -> WikiEntry:
	blocks.append({"tipo": KIND_HEADING, "texto": text})
	return self


func add_text(text: String) -> WikiEntry:
	blocks.append({"tipo": KIND_TEXT, "texto": text})
	return self


func add_facts(rows: Array) -> WikiEntry:
	blocks.append({"tipo": KIND_FACTS, "filas": rows})
	return self


func add_table(rows: Array) -> WikiEntry:
	blocks.append({"tipo": KIND_TABLE, "filas": rows})
	return self


## Todo el texto de la entrada junto (para los tests y para un buscador futuro, B-15).
func plain_text() -> String:
	var parts: PackedStringArray = [title, subtitle]
	for block: Dictionary in blocks:
		if block.has("texto"):
			parts.append(String(block["texto"]))
		for row: Variant in block.get("filas", []):
			parts.append(" ".join(PackedStringArray(row)))
	return "\n".join(parts)
