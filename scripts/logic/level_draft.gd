# El nivel que se está editando en el editor de mapas (spec §10.3). Lógica pura: sin pantallas.
#
# Guarda el nivel con el MISMO formato de los archivos de nivel (spec §7.8): lo que se edita, lo
# que se guarda y lo que valida LevelFile son lo mismo, así no hay dos modelos que mantener
# alineados. Cada cambio se puede deshacer (RF-212); un trazo del mouse cuenta como un solo cambio.
class_name LevelDraft
extends RefCounted

enum Tool { GRASS, PATH, BLOCKED, ENTRANCE, EXIT }

## RF-216: dónde se guardan los mapas propios.
const MAPS_DIR: String = "user://maps/"
## RF-212: cuántos pasos se pueden deshacer.
const UNDO_LIMIT: int = 50
const NEW_NAME: String = "Nivel nuevo"
const TEMPLATE_SUFFIX: String = "_copia"
const FILE_ID_MAX: int = 40

## El nivel, como el archivo de §7.8: version, nombre, oro, vidas, [aumento_vida], mapa, oleadas.
var data: Dictionary = {}
## Nombre del archivo (sin .json) donde se guarda; "" = todavía no se guardó.
var file_id: String = ""
## Nombre sugerido al guardar un nivel abierto como plantilla (RF-216).
var suggested_id: String = ""
## Hay cambios sin guardar (RF-218).
var dirty: bool = false

var _undo: Array[Dictionary] = []
var _redo: Array[Dictionary] = []
var _in_stroke: bool = false
var _stroke_recorded: bool = false
var _stroke_snapshot: Dictionary = {}


# --- Crear y leer ---

## El nivel nuevo (RF-215): una recta de la entrada A a la salida y una oleada de ejemplo. Es válido.
static func new_level() -> LevelDraft:
	var rows: Array = []
	for y: int in MapGrid.HEIGHT:
		rows.append(MapGrid.GRASS.repeat(MapGrid.WIDTH))
	var middle: int = MapGrid.HEIGHT / 2
	rows[middle] = MapGrid.ENTRANCE_LETTERS[0] + MapGrid.PATH.repeat(MapGrid.WIDTH - 2) + MapGrid.EXIT
	var draft := LevelDraft.new()
	draft.data = {
		"version": LevelFile.VERSION, "nombre": NEW_NAME, "oro": 200, "vidas": 20,
		"mapa": rows, "oleadas": [[default_group()]],
	}
	return draft


## Lee el texto de un nivel (un archivo propio o uno oficial). Devuelve null si no es un JSON
## de nivel. Un nivel con errores de contenido SÍ se abre (para poder arreglarlo): lo que falta se
## completa y las claves desconocidas se descartan.
static func from_text(text: String, id: String = "") -> LevelDraft:
	var json := JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return null
	var source: Dictionary = json.data
	var draft := LevelDraft.new()
	draft.file_id = id
	draft.data = {
		"version": LevelFile.VERSION,
		"nombre": str(source.get("nombre", "")),
		"oro": _to_int(source.get("oro", 0)),
		"vidas": _to_int(source.get("vidas", 0)),
		"mapa": _clean_rows(source.get("mapa", [])),
		"oleadas": _clean_waves(source.get("oleadas", [])),
	}
	if _to_int(source.get("aumento_vida", 0)) > 0:
		draft.data["aumento_vida"] = _to_int(source["aumento_vida"])
	# El orden de las claves del texto lo fija to_text(), no este diccionario.
	return draft


## Abre un mapa propio de `user://maps/` (o del `dir` que se pase). null si no se puede leer.
static func open_saved(id: String, dir: String = MAPS_DIR) -> LevelDraft:
	var path: String = dir + id + ".json"
	if not FileAccess.file_exists(path):
		return null
	return from_text(FileAccess.get_file_as_string(path), id)


## Abre un nivel oficial como PLANTILLA (RF-216): no queda ligado al oficial, así que guardarlo
## pide otro nombre y no lo pisa.
static func open_official(id: String) -> LevelDraft:
	var path: String = LevelFile.LEVELS_DIR + id + ".json"
	if not FileAccess.file_exists(path):
		return null
	var draft: LevelDraft = from_text(FileAccess.get_file_as_string(path), "")
	if draft != null:
		draft.suggested_id = id + TEMPLATE_SUFFIX
	return draft


static func default_group() -> Dictionary:
	return {"enemigo": "normal", "cantidad": 10, "cada": 0.8}


## Los ids de los mapas propios guardados, en orden.
static func saved_ids(dir: String = MAPS_DIR) -> PackedStringArray:
	var ids: PackedStringArray = []
	if not DirAccess.dir_exists_absolute(dir):
		return ids  # todavía no se guardó ningún mapa
	for file: String in DirAccess.get_files_at(dir):
		if file.ends_with(".json"):
			ids.append(file.get_basename())
	ids.sort()
	return ids


# --- El mapa (RF-212) ---

func rows() -> PackedStringArray:
	return PackedStringArray(data["mapa"])


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < MapGrid.WIDTH and cell.y < MapGrid.HEIGHT


## La letra de una casilla ("" fuera del mapa).
func letter_at(cell: Vector2i) -> String:
	return (data["mapa"][cell.y] as String)[cell.x] if in_bounds(cell) else ""


## Cuántas entradas tiene el mapa.
func entrance_count() -> int:
	var count: int = 0
	for letter: String in MapGrid.ENTRANCE_LETTERS:
		if _has_letter(letter):
			count += 1
	return count


## Usa una herramienta en una casilla. Devuelve true si el mapa cambió.
## Un trazo del mouse se agrupa con begin_stroke() y end_stroke().
func apply_tool(tool: Tool, cell: Vector2i) -> bool:
	if not in_bounds(cell):
		return false
	var current: String = letter_at(cell)
	var wanted: String
	match tool:
		Tool.GRASS:
			wanted = MapGrid.GRASS
		Tool.PATH:
			wanted = MapGrid.PATH
		Tool.BLOCKED:
			wanted = MapGrid.BLOCKED
		Tool.ENTRANCE:
			var free: String = _first_free_entrance_letter()
			if _is_entrance(current) or free == "":
				return false
			wanted = free
		_:
			wanted = MapGrid.EXIT
	if current == wanted:
		return false
	_record()
	if _is_entrance(current):
		_remove_entrance(current)
	if wanted == MapGrid.EXIT:
		_clear_exit()
	_set_letter(cell, wanted)
	return true


## Empieza un trazo: todos los cambios hasta end_stroke() se deshacen juntos.
func begin_stroke() -> void:
	_in_stroke = true
	_stroke_recorded = false
	_stroke_snapshot = data.duplicate(true)


func end_stroke() -> void:
	_in_stroke = false
	_stroke_snapshot = {}


# --- Ajustes del nivel (RF-214) ---

func level_name() -> String:
	return str(data["nombre"])


func set_level_name(value: String) -> void:
	value = value.left(LevelFile.MAX_NAME_LENGTH)  # RF-223
	if value != level_name():
		_record()
		data["nombre"] = value


func gold() -> int:
	return int(data["oro"])


func set_gold(value: int) -> void:
	value = mini(value, LevelFile.MAX_GOLD)  # RF-223
	if value != gold():
		_record()
		data["oro"] = value


func lives() -> int:
	return int(data["vidas"])


func set_lives(value: int) -> void:
	value = mini(value, LevelFile.MAX_LIVES)  # RF-223
	if value != lives():
		_record()
		data["vidas"] = value


## % de vida extra por oleada; 0 = usar el general (spec §7.4).
func health_scale() -> int:
	return int(data.get("aumento_vida", 0))


func set_health_scale(value: int) -> void:
	value = mini(value, LevelFile.MAX_HEALTH_SCALE)  # RF-223
	if value == health_scale():
		return
	_record()
	if value > 0:
		data["aumento_vida"] = value
	else:
		data.erase("aumento_vida")


# --- Oleadas (RF-215) ---

func wave_count() -> int:
	return (data["oleadas"] as Array).size()


func group_count(wave: int) -> int:
	return (data["oleadas"][wave] as Array).size()


## Agrega una oleada con el grupo de ejemplo y devuelve su posición (-1 si ya hay el máximo, RF-223).
func add_wave() -> int:
	if wave_count() >= LevelFile.MAX_WAVES:
		return -1
	_record()
	(data["oleadas"] as Array).append([default_group()])
	return wave_count() - 1


## Quita una oleada. La última no se quita: un nivel necesita al menos una.
func remove_wave(wave: int) -> bool:
	if wave < 0 or wave >= wave_count() or wave_count() <= 1:
		return false
	_record()
	(data["oleadas"] as Array).remove_at(wave)
	return true


## Copia una oleada justo después de sí misma y devuelve la posición de la copia.
func duplicate_wave(wave: int) -> int:
	if wave < 0 or wave >= wave_count() or wave_count() >= LevelFile.MAX_WAVES:
		return -1
	_record()
	(data["oleadas"] as Array).insert(wave + 1, (data["oleadas"][wave] as Array).duplicate(true))
	return wave + 1


## Agrega un grupo de ejemplo a una oleada. Devuelve false si ya tiene el máximo (RF-223).
func add_group(wave: int) -> bool:
	if group_count(wave) >= LevelFile.MAX_GROUPS:
		return false
	_record()
	(data["oleadas"][wave] as Array).append(default_group())
	return true


func remove_group(wave: int, index: int) -> bool:
	if wave < 0 or wave >= wave_count() or index < 0 or index >= group_count(wave):
		return false
	_record()
	(data["oleadas"][wave] as Array).remove_at(index)
	return true


## Un grupo tal como se guarda, con los valores por defecto completados.
func group(wave: int, index: int) -> Dictionary:
	var source: Dictionary = data["oleadas"][wave][index]
	return {
		"enemigo": str(source.get("enemigo", "")),
		"cantidad": _to_int(source.get("cantidad", 0)),
		"cada": float(source.get("cada", 0.0)),
		"desde": float(source.get("desde", 0.0)),
		"entrada": str(source.get("entrada", MapGrid.ENTRANCE_LETTERS[0])),
	}


## Cambia un dato de un grupo. `key`: enemigo, cantidad, cada, desde o entrada.
## Devuelve true si algo cambió. Lo que vale lo mismo que "no escribirlo" (desde 0, entrada A) no se guarda.
func set_group(wave: int, index: int, key: String, value: Variant) -> bool:
	if wave < 0 or wave >= wave_count() or index < 0 or index >= group_count(wave):
		return false
	var current: Dictionary = group(wave, index)
	var normalized: Variant
	match key:
		"enemigo", "entrada":
			normalized = str(value)
		"cantidad":
			normalized = mini(_to_int(value), LevelFile.MAX_COUNT)  # RF-223
		"cada", "desde":
			var top: float = LevelFile.MAX_EVERY if key == "cada" else LevelFile.MAX_FROM
			normalized = minf(snappedf(float(value), 0.01), top)
		_:
			return false
	if normalized == current[key]:
		return false
	_record()
	var target: Dictionary = data["oleadas"][wave][index]
	var is_default: bool = (key == "desde" and normalized == 0.0) \
		or (key == "entrada" and normalized == MapGrid.ENTRANCE_LETTERS[0])
	if is_default:
		target.erase(key)
	else:
		target[key] = normalized
	return true


## Cuántos enemigos trae una oleada (RF-215).
func enemy_total(wave: int) -> int:
	var total: int = 0
	for i: int in group_count(wave):
		total += int(group(wave, i)["cantidad"])
	return total


# --- Revisar (RF-213) ---

## El mapa leído con las reglas de §7.8 (recorridos, avisos, errores).
func grid() -> MapGrid:
	return MapGrid.parse(rows())


## El nivel revisado con TODAS las reglas de §7.8, igual que al leer un archivo.
## Devuelve {"level": LevelData o null, "errors": ..., "warnings": ...}.
func check() -> Dictionary:
	return LevelFile.parse(to_text(), StringName(file_id if file_id != "" else "borrador"))


# --- Texto y archivo (RF-216) ---

## El texto del archivo, ordenado como los niveles oficiales (para que se lea bien y se vea
## qué cambió en git): el mapa fila por fila y cada oleada en su línea.
func to_text() -> String:
	var lines: PackedStringArray = ["{", "  \"version\": %d," % LevelFile.VERSION]
	lines.append("  \"nombre\": %s," % JSON.stringify(level_name()))
	lines.append("  \"oro\": %d," % gold())
	lines.append("  \"vidas\": %d," % lives())
	if health_scale() > 0:
		lines.append("  \"aumento_vida\": %d," % health_scale())
	lines.append("  \"mapa\": [")
	var map_rows: PackedStringArray = rows()
	for y: int in map_rows.size():
		lines.append("    \"%s\"%s" % [map_rows[y], "," if y < map_rows.size() - 1 else ""])
	lines.append("  ],")
	lines.append("  \"oleadas\": [")
	for w: int in wave_count():
		var groups: PackedStringArray = []
		for g: int in group_count(w):
			groups.append(_group_text(w, g))
		var end: String = "," if w < wave_count() - 1 else ""
		lines.append("    [" + ",\n     ".join(groups) + "]" + end)
	lines.append("  ]")
	lines.append("}")
	return "\n".join(lines) + "\n"


## Un nombre de archivo válido: minúsculas, números y "_" (RF-216).
static func is_valid_file_id(id: String) -> bool:
	var valid := RegEx.create_from_string("^[a-z0-9_]+$")
	return id.length() <= FILE_ID_MAX and valid.search(id) != null


## Convierte lo que escribió la persona en un nombre de archivo válido ("Mi Mapa 2" → "mi_mapa_2").
static func clean_file_id(text: String) -> String:
	var lowered: String = text.strip_edges().to_lower().replace(" ", "_")
	var kept: String = ""
	for c: String in lowered:
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9") or c == "_":
			kept += c
	return kept.left(FILE_ID_MAX)


## Un nivel oficial usa ese nombre (RF-216: no se pisan).
static func is_official_id(id: String) -> bool:
	return FileAccess.file_exists(LevelFile.LEVELS_DIR + id + ".json")


## Guarda el borrador como `file_id` (RF-216). Devuelve "" si salió bien o el motivo si no.
func save(dir: String = MAPS_DIR) -> String:
	if not is_valid_file_id(file_id):
		return "El nombre del archivo solo puede tener minúsculas, números y _."
	if is_official_id(file_id):
		return "'%s' es el nombre de un nivel oficial: elegí otro para no pisarlo." % file_id
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(dir + file_id + ".json", FileAccess.WRITE)
	if file == null:
		return "No se pudo escribir el archivo (error %d)." % FileAccess.get_open_error()
	file.store_string(to_text())
	file.close()
	dirty = false
	return ""


# --- Deshacer y rehacer (RF-212) ---

func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


func undo() -> bool:
	if _undo.is_empty():
		return false
	_redo.append(data.duplicate(true))
	data = _undo.pop_back()
	dirty = true
	return true


func redo() -> bool:
	if _redo.is_empty():
		return false
	_undo.append(data.duplicate(true))
	data = _redo.pop_back()
	dirty = true
	return true


# --- Por dentro ---

## Se llama ANTES de cada cambio real: guarda cómo estaba para poder deshacerlo.
## Dentro de un trazo, solo el primer cambio guarda (con la foto que se sacó al empezarlo).
func _record() -> void:
	dirty = true
	if _in_stroke:
		if _stroke_recorded:
			return
		_stroke_recorded = true
		_push_undo(_stroke_snapshot)
	else:
		_push_undo(data.duplicate(true))


func _push_undo(snapshot: Dictionary) -> void:
	_undo.append(snapshot)
	if _undo.size() > UNDO_LIMIT:
		_undo.pop_front()
	_redo.clear()


func _set_letter(cell: Vector2i, letter: String) -> void:
	var row: String = data["mapa"][cell.y]
	data["mapa"][cell.y] = row.left(cell.x) + letter + row.substr(cell.x + 1)


func _is_entrance(letter: String) -> bool:
	return letter != "" and MapGrid.ENTRANCE_LETTERS.contains(letter)


func _has_letter(letter: String) -> bool:
	for row: String in data["mapa"]:
		if row.contains(letter):
			return true
	return false


## La primera letra de entrada que el mapa todavía no usa ("" si están todas).
func _first_free_entrance_letter() -> String:
	for letter: String in MapGrid.ENTRANCE_LETTERS:
		if not _has_letter(letter):
			return letter
	return ""


## La salida es una sola: la vieja pasa a pasto.
func _clear_exit() -> void:
	for y: int in MapGrid.HEIGHT:
		var x: int = (data["mapa"][y] as String).find(MapGrid.EXIT)
		if x >= 0:
			_set_letter(Vector2i(x, y), MapGrid.GRASS)


## Quita una entrada: su casilla pasa a pasto, las letras que venían después bajan un lugar y
## las oleadas se acomodan (las de la entrada quitada pasan a la A).
func _remove_entrance(letter: String) -> void:
	var index: int = MapGrid.ENTRANCE_LETTERS.find(letter)
	for y: int in MapGrid.HEIGHT:
		var fixed: String = ""
		for c: String in (data["mapa"][y] as String):
			var i: int = MapGrid.ENTRANCE_LETTERS.find(c)
			if c == letter:
				fixed += MapGrid.GRASS
			elif i > index:
				fixed += MapGrid.ENTRANCE_LETTERS[i - 1]
			else:
				fixed += c
		data["mapa"][y] = fixed
	for wave: Array in data["oleadas"]:
		for group_data: Dictionary in wave:
			var used: int = MapGrid.ENTRANCE_LETTERS.find(str(group_data.get("entrada", MapGrid.ENTRANCE_LETTERS[0])))
			if used < 0 or used < index:
				continue
			var now: int = 0 if used == index else used - 1
			if now == 0:
				group_data.erase("entrada")
			else:
				group_data["entrada"] = MapGrid.ENTRANCE_LETTERS[now]


func _group_text(wave: int, index: int) -> String:
	var g: Dictionary = group(wave, index)
	var parts: PackedStringArray = [
		"\"enemigo\": %s" % JSON.stringify(g["enemigo"]),
		"\"cantidad\": %d" % g["cantidad"],
		"\"cada\": %s" % _seconds(g["cada"]),
	]
	if g["desde"] > 0.0:
		parts.append("\"desde\": %s" % _seconds(g["desde"]))
	if g["entrada"] != MapGrid.ENTRANCE_LETTERS[0]:
		parts.append("\"entrada\": %s" % JSON.stringify(g["entrada"]))
	return "{" + ", ".join(parts) + "}"


## 1.0, 0.8, 0.25… (un decimal si alcanza, como en los niveles oficiales).
static func _seconds(value: float) -> String:
	return "%.1f" % value if is_equal_approx(value * 10.0, roundf(value * 10.0)) else str(value)


static func _to_int(value: Variant) -> int:
	return int(value) if value is int or value is float else 0


static func _to_float(value: Variant) -> float:
	return float(value) if value is int or value is float else 0.0


## Nueve filas de veinte letras: lo que falta se completa con pasto y lo que sobra se corta.
static func _clean_rows(value: Variant) -> Array:
	var source: Array = value if value is Array else []
	var rows_out: Array = []
	for y: int in MapGrid.HEIGHT:
		var row: String = str(source[y]) if y < source.size() else ""
		rows_out.append(row.left(MapGrid.WIDTH).rpad(MapGrid.WIDTH, MapGrid.GRASS))
	return rows_out


static func _clean_waves(value: Variant) -> Array:
	var waves: Array = []
	for wave: Variant in (value if value is Array else []):
		var groups: Array = []
		for group_source: Variant in (wave if wave is Array else []):
			if not group_source is Dictionary:
				continue
			var cleaned: Dictionary = {
				"enemigo": str(group_source.get("enemigo", "")),
				"cantidad": _to_int(group_source.get("cantidad", 0)),
				"cada": _to_float(group_source.get("cada", 0.0)),
			}
			if _to_float(group_source.get("desde", 0.0)) > 0.0:
				cleaned["desde"] = _to_float(group_source["desde"])
			var letter: String = str(group_source.get("entrada", MapGrid.ENTRANCE_LETTERS[0]))
			if letter != MapGrid.ENTRANCE_LETTERS[0]:
				cleaned["entrada"] = letter
			groups.append(cleaned)
		waves.append(groups)
	return waves
