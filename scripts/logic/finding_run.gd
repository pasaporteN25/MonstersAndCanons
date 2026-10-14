# Las piezas de colección que se recogen en ruinas durante una partida (RF-427). Nada se persiste acá:
# el juego guarda `confirmed()` al terminar. Convive con `CollectibleRun`, que sigue siendo el
# portador de `technology` sin cambios.
class_name FindingRun
extends RefCounted

## Pieza id (`<colección>:<nivel>`, RF-426) → oleada cuya finalización la confirma.
var _pending: Dictionary = {}
var _confirmed: Dictionary = {}


## RF-426: el id único de una pieza.
static func piece_id(collection: StringName, source: StringName) -> String:
	return "%s:%s" % [collection, source]


## Recoge la pieza (queda pendiente). Devuelve false si el nivel no es fuente de esa colección o si
## la pieza ya está recogida en esta partida: repetir no duplica.
func pick(collection: StringName, source: StringName, wave_to_confirm: int) -> bool:
	if not CollectionDefinitions.eligible(collection, source):
		return false
	var id: String = piece_id(collection, source)
	if _pending.has(id) or _confirmed.has(id):
		return false
	_pending[id] = {"collection": collection, "source": source, "wave": wave_to_confirm}
	return true


## RF-427: completar la oleada confirma las piezas que esperaban esa oleada; cada una por separado.
func complete_wave(wave: int) -> void:
	for id: String in _pending.keys():
		if int(_pending[id]["wave"]) <= wave:
			_confirmed[id] = _pending[id]
			_pending.erase(id)


## Piezas recogidas que todavía no se confirmaron: [{collection, source, wave}].
func pending() -> Array[Dictionary]:
	return _as_list(_pending)


## Piezas confirmadas: lo único que se guarda al terminar la partida.
func confirmed() -> Array[Dictionary]:
	return _as_list(_confirmed)


## Cuántas piezas de `collection` hay (recogidas, confirmadas o no): para la barra.
func count_of(collection: StringName, confirmed_only: bool = false) -> int:
	var total: int = 0
	for list: Dictionary in ([_confirmed] if confirmed_only else [_confirmed, _pending]):
		for piece: Dictionary in list.values():
			if piece["collection"] == collection:
				total += 1
	return total


func has_piece(collection: StringName, source: StringName) -> bool:
	var id: String = piece_id(collection, source)
	return _pending.has(id) or _confirmed.has(id)


func is_confirmed(collection: StringName, source: StringName) -> bool:
	return _confirmed.has(piece_id(collection, source))


static func _as_list(source: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for piece: Dictionary in source.values():
		result.append(piece)
	return result
