# Tablas de récords estilo arcade (RF-191, RF-194, D-029): hasta 5 entradas, de mayor a
# menor puntaje. Cada entrada es un diccionario {"name": "LUC", "points": 1234}.
# Solo cuentas: no guarda nada (eso lo hace SaveManager).
class_name HighScores
extends RefCounted

const MAX_ENTRIES: int = 5
## RF-191: iniciales de los récords de cada nivel.
const LEVEL_NAME_LENGTH: int = 3
## RF-194: nombre del Salón de la fama.
const HALL_NAME_LENGTH: int = 5
const LETTERS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


## ¿Esos puntos entran en la tabla? Con 0 no se entra, y a igual puntaje gana el que ya estaba.
static func qualifies(table: Array, points: int) -> bool:
	if points <= 0:
		return false
	return table.size() < MAX_ENTRIES or points > int(table[table.size() - 1]["points"])


## Agrega la entrada en su lugar (debajo de los que tienen los mismos puntos) y deja solo 5.
## Devuelve la posición en que quedó (0 = primero), o -1 si no entró.
static func insert(table: Array, name: String, points: int) -> int:
	if not qualifies(table, points):
		return -1
	var index: int = table.size()
	for i: int in table.size():
		if points > int(table[i]["points"]):
			index = i
			break
	table.insert(index, {"name": name, "points": points})
	while table.size() > MAX_ENTRIES:
		table.pop_back()
	return index


## Deja solo letras A–Z en mayúsculas, del largo pedido (si faltan, completa con "A").
static func clean_name(text: String, length: int) -> String:
	var result: String = ""
	for character: String in text.to_upper():
		if LETTERS.contains(character):
			result += character
	result = result.left(length)
	while result.length() < length:
		result += "A"
	return result
