# El nivel que se está editando en el editor de mapas (spec §10.3). Lógica pura: sin pantallas.
#
# Guarda el nivel con el MISMO formato de los archivos de nivel (spec §7.8): lo que se edita, lo
# que se guarda y lo que valida LevelFile son lo mismo, así no hay dos modelos que mantener
# alineados. Cada cambio se puede deshacer (RF-212); un trazo del mouse cuenta como un solo cambio.
class_name LevelDraft
extends RefCounted

enum Tool { GRASS, PATH, BLOCKED, ENTRANCE, EXIT, TREE, ROCK, RUBBLE, MINE, FOREST }

## RF-216: dónde se guardan los mapas propios.
const MAPS_DIR: String = "user://maps/"
## RF-212: cuántos pasos se pueden deshacer.
const UNDO_LIMIT: int = 50
## El nombre de un nivel nuevo en español (el que se guarda en los tests); `new_name()` lo da en el idioma activo.
const NEW_NAME: String = "Nivel nuevo"
const TEMPLATE_SUFFIX: String = "_copia"
const FILE_ID_MAX: int = 40
## RF-434: qué crea cada pincel de objetos: la parte de la leyenda ("removible" o "extraccion"), la clase de
## `data/obstaculos.json` y la letra que se prefiere (las del ejemplo de RF-399; si está ocupada, otra libre).
const OBSTACLE_TOOLS: Dictionary = {
	Tool.TREE: {"categoria": "removible", "clase": "arbol", "letra": "t"},
	Tool.ROCK: {"categoria": "removible", "clase": "roca", "letra": "r"},
	Tool.RUBBLE: {"categoria": "removible", "clase": "escombro", "letra": "u"},
	Tool.MINE: {"categoria": "extraccion", "clase": "mina", "letra": "m"},
	Tool.FOREST: {"categoria": "extraccion", "clase": "bosque_explotable", "letra": "b"},
}
## Letras que se prueban, en orden, cuando la preferida del pincel ya está en uso.
const SPARE_LETTERS: String = "abcdefghijklmnopqrstuvwxyz0123456789"
## RF-434: lo que se puede sobrescribir por letra (RF-399).
const REMOVABLE_FIELDS: PackedStringArray = ["costo", "tiempo", "recursos", "probabilidad"]
const EXTRACTION_FIELDS: PackedStringArray = ["costo", "produccion", "reserva"]
## Topes del panel de propiedades (la validación de LevelFile solo exige que no sean negativos ni cero donde corresponde).
const OBSTACLE_VALUE_MAX: int = 9999
const OBSTACLE_TIME_MAX: float = 600.0

## El nivel, como el archivo de §7.8: version, nombre, oro, vidas, [aumento_vida], mapa, oleadas.
var data: Dictionary = {}
## Nombre del archivo (sin .json) donde se guarda; "" = todavía no se guardó.
var file_id: String = ""
## Nombre sugerido al guardar un nivel abierto como plantilla (RF-216).
var suggested_id: String = ""
## RF-392: el modo propio donde se guarda (su id). "" = mapa suelto de la comunidad (user://maps/).
var mode_id: String = ""
## Hay cambios sin guardar (RF-218).
var dirty: bool = false
## RF-435: el borrador salió de un nivel de la campaña (se abrió como plantilla). Mientras no se guarde
## como mapa de la comunidad o de un modo, sus ruinas pueden llevar un hallazgo.
var from_campaign: bool = false
## Por qué la última herramienta usada no pintó (por ejemplo, la leyenda ya tiene 10 letras). "" = nada que avisar.
var last_problem: String = ""

var _undo: Array[Dictionary] = []
var _redo: Array[Dictionary] = []
var _in_stroke: bool = false
var _stroke_recorded: bool = false
var _stroke_snapshot: Dictionary = {}


# --- Crear y leer ---

## T534: el nombre de un nivel nuevo en el idioma activo (en español es `NEW_NAME`).
static func new_name() -> String:
	return Localization.t(&"draft.new_name")


## El nivel nuevo (RF-215): una recta de la entrada A a la salida y una oleada de ejemplo. Es válido.
static func new_level() -> LevelDraft:
	var rows: Array = []
	for y: int in MapGrid.MIN_HEIGHT:
		rows.append(MapGrid.GRASS.repeat(MapGrid.MIN_WIDTH))
	var middle: int = MapGrid.MIN_HEIGHT / 2
	rows[middle] = MapGrid.ENTRANCE_LETTERS[0] + MapGrid.PATH.repeat(MapGrid.MIN_WIDTH - 2) + MapGrid.EXIT
	var draft := LevelDraft.new()
	draft.data = {
		"version": LevelFile.VERSION, "nombre": new_name(), "oro": 200, "vidas": 20,
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
	# M15: el tema y la leyenda se conservan tal cual (check() los revisa). Los objetos de la leyenda se editan
	# con los pinceles y el panel de objetos (RF-434).
	if source.get("tema") is String:
		draft.data["tema"] = source["tema"]
	if source.get("leyenda") is Dictionary:
		draft.data["leyenda"] = (source["leyenda"] as Dictionary).duplicate(true)
	# RF-300: las torres extra se conservan tal cual.
	if source.get("torres_extra") is Array:
		draft.data["torres_extra"] = (source["torres_extra"] as Array).duplicate()
	# RF-394: la lista de torres del nivel se edita en Ajustes (RF-434); al abrir se conserva tal cual.
	if source.get("torres") is Array:
		draft.data["torres"] = (source["torres"] as Array).duplicate()
	# RF-411: se conserva tal cual al guardar (aunque no sea true/false: check() lo marca).
	if source.has("demoledora"):
		draft.data["demoledora"] = source["demoledora"]
	# M52 (RF-464): los textos del nivel se conservan tal cual (el editor no los edita; check() los revisa).
	if source.has("textos"):
		draft.data["textos"] = source["textos"].duplicate(true) if source["textos"] is Dictionary else source["textos"]
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
		draft.from_campaign = true  # RF-435
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


## RF-254: el tamaño lo dan las filas del mapa (el nivel nuevo es de 20×9, uno abierto conserva el suyo).
func map_width() -> int:
	return (data["mapa"][0] as String).length()


func map_height() -> int:
	return (data["mapa"] as Array).size()


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_width() and cell.y < map_height()


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
## Si no pudo pintar por un motivo que conviene decir (RF-434: la leyenda llegó al tope), queda en `last_problem`.
## Un trazo del mouse se agrupa con begin_stroke() y end_stroke().
func apply_tool(tool: Tool, cell: Vector2i) -> bool:
	last_problem = ""
	if not in_bounds(cell):
		return false
	if OBSTACLE_TOOLS.has(tool):
		return _apply_obstacle_tool(tool, cell)
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
	_forget_unused_obstacle_letter(current)
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
		"probabilidad": float(source.get("probabilidad", 1.0)),
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
		"probabilidad":
			normalized = clampf(snappedf(float(value), 0.01), 0.0, 1.0)
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
		or (key == "entrada" and normalized == MapGrid.ENTRANCE_LETTERS[0]) \
		or (key == "probabilidad" and normalized == 1.0)
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


# --- Objetos del mapa: removibles y extracción (RF-434, RF-435) ---

## Las letras de la leyenda que son un removible o un punto de extracción, en el orden del archivo.
func obstacle_letters() -> PackedStringArray:
	var letters: PackedStringArray = []
	for letter: Variant in _legend().keys():
		if obstacle_category(str(letter)) != "":
			letters.append(str(letter))
	return letters


## "removible", "extraccion" o "" si la letra no es un objeto.
func obstacle_category(letter: String) -> String:
	var entry: Variant = _legend().get(letter)
	if not entry is Dictionary:
		return ""
	for category: String in ["removible", "extraccion"]:
		if (entry as Dictionary).get(category) is Dictionary:
			return category
	return ""


## La clase de la letra ("arbol", "roca", "mina"…) o "".
func obstacle_class(letter: String) -> String:
	var category: String = obstacle_category(letter)
	return str(_legend()[letter][category].get("clase", "")) if category != "" else ""


## Los datos que se pueden sobrescribir en esa letra (RF-399).
func obstacle_fields(letter: String) -> PackedStringArray:
	match obstacle_category(letter):
		"removible":
			return REMOVABLE_FIELDS
		"extraccion":
			return EXTRACTION_FIELDS
		_:
			return PackedStringArray()


## El valor de la clase para `key` (el que rige si el mapa no lo sobrescribe). 0 si no hay.
func obstacle_default(letter: String, key: String) -> float:
	var class_id: String = obstacle_class(letter)
	var defaults: Dictionary = ObstacleCatalog.removable(class_id) if obstacle_category(letter) == "removible" \
		else ObstacleCatalog.extraction(class_id)
	return _to_float(defaults.get(key, 0))


## El valor que rige para esa letra: el que escribió el mapa o, si no, el de la clase.
func obstacle_value(letter: String, key: String) -> float:
	var category: String = obstacle_category(letter)
	if category == "" or not obstacle_fields(letter).has(key):
		return 0.0
	var body: Dictionary = _legend()[letter][category]
	return _to_float(body[key]) if body.has(key) else obstacle_default(letter, key)


## ¿La letra sobrescribe este dato (RF-434)?
func obstacle_overrides(letter: String, key: String) -> bool:
	var category: String = obstacle_category(letter)
	return category != "" and (_legend()[letter][category] as Dictionary).has(key)


## Sobrescribe un dato de TODAS las casillas con esa letra (RF-434). Un valor igual al de la clase no se escribe:
## se borra la sobrescritura. Los valores se acomodan al rango que acepta LevelFile. Devuelve true si algo cambió.
func set_obstacle_value(letter: String, key: String, value: float) -> bool:
	if not obstacle_fields(letter).has(key):
		return false
	var wanted: float
	match key:
		"tiempo":
			wanted = clampf(snappedf(value, 0.1), 0.1, OBSTACLE_TIME_MAX)
		"probabilidad":
			wanted = clampf(roundf(value), 0.0, 100.0)
		"costo":
			wanted = clampf(roundf(value), 1.0, OBSTACLE_VALUE_MAX)
		_:
			wanted = clampf(roundf(value), 0.0, OBSTACLE_VALUE_MAX)
	var body: Dictionary = _legend()[letter][obstacle_category(letter)]
	var is_default: bool = is_equal_approx(wanted, obstacle_default(letter, key))
	if is_default and not body.has(key):
		return false
	if not is_default and body.has(key) and is_equal_approx(_to_float(body[key]), wanted):
		return false
	_record()
	if is_default:
		body.erase(key)
	else:
		body[key] = wanted  # decimal, como lo devuelve el lector de JSON: guardar y reabrir no cambia el texto
	return true


## RF-435: ¿se puede escribir el hallazgo? Solo en una ruina (escombro) y solo mientras el borrador es un
## nivel de la campaña (abierto como plantilla y todavía sin guardar como mapa de la comunidad o de un modo).
func is_campaign() -> bool:
	return from_campaign and file_id == "" and mode_id == ""


func can_edit_finding(letter: String) -> bool:
	return is_campaign() and obstacle_category(letter) == "removible" and obstacle_class(letter) == "escombro"


## La colección del hallazgo de esa letra ("" = sin hallazgo).
func finding(letter: String) -> String:
	if obstacle_category(letter) != "removible":
		return ""
	return str(_legend()[letter]["removible"].get("hallazgo", ""))


## Pone (o con "" quita) el hallazgo de una ruina. No hace nada si el borrador no es de la campaña (RF-435).
func set_finding(letter: String, collection: String) -> bool:
	if not can_edit_finding(letter) or collection == finding(letter):
		return false
	_record()
	var body: Dictionary = _legend()[letter]["removible"]
	if collection == "":
		body.erase("hallazgo")
	else:
		body["hallazgo"] = collection
	return true


# --- Demoledora y torres del mapa (RF-434) ---

## `"demoledora": true` (RF-411). Sin el campo, o con otra cosa, es false.
func machine_enabled() -> bool:
	return data.get("demoledora", false) == true


## Activa la demoledora; apagarla borra el campo (vale lo mismo que no escribirlo).
func set_machine_enabled(on: bool) -> bool:
	if on == machine_enabled():
		return false
	_record()
	if on:
		data["demoledora"] = true
	else:
		data.erase("demoledora")
	return true


## ¿El nivel dice qué torres ofrece (`"torres"`)? Si no, ofrece las de siempre (RF-393).
func has_tower_list() -> bool:
	return data.get("torres") is Array


## Los ids de las torres que ofrece el nivel, en el orden de `all_towers` (el canónico). Sin lista, las que
## ofrece un nivel sin el campo: las comunes más las de `"torres_extra"` (RF-300).
func offered_tower_ids(all_towers: Array[TowerData]) -> PackedStringArray:
	var ids: PackedStringArray = []
	var listed: Array = data["torres"] if has_tower_list() else []
	var extra: Array = data["torres_extra"] if data.get("torres_extra") is Array else []
	for tower: TowerData in all_towers:
		var id: String = String(tower.id)
		var offered: bool = listed.has(id) if has_tower_list() else (not tower.reserved or extra.has(id))
		if offered:
			ids.append(id)
	return ids


## Marca o desmarca una torre. La primera vez escribe la lista completa de lo que ya se ofrecía, así que el
## resto no cambia. No deja la lista vacía (RF-394): quitar la última no hace nada. Los ids que el juego no
## conoce y ya estaban escritos se conservan al final (los marca check()). Devuelve true si algo cambió.
func set_tower_offered(tower_id: String, on: bool, all_towers: Array[TowerData]) -> bool:
	var current: PackedStringArray = offered_tower_ids(all_towers)
	if current.has(tower_id) == on and has_tower_list():
		return false
	var wanted: PackedStringArray = current.duplicate()
	if on and not wanted.has(tower_id):
		wanted.append(tower_id)
	elif wanted.has(tower_id):
		wanted.remove_at(wanted.find(tower_id))
	var unknown: Array = []
	if has_tower_list():
		for id: Variant in data["torres"]:
			if not _tower_ids_of(all_towers).has(str(id)):
				unknown.append(id)
	if wanted.is_empty() and unknown.is_empty():
		return false
	var ordered: Array = []
	for tower: TowerData in all_towers:
		if wanted.has(String(tower.id)):
			ordered.append(String(tower.id))
	ordered.append_array(unknown)
	_record()
	data["torres"] = ordered
	return true


## Vuelve a "las de siempre": borra el campo `"torres"`.
func use_default_towers() -> bool:
	if not has_tower_list():
		return false
	_record()
	data.erase("torres")
	return true


# --- Revisar (RF-213) ---

## El paisaje del mapa (RF-260): el `tema` del archivo, o la pradera si no lo dice o no existe.
func theme() -> StringName:
	var id: String = str(data.get("tema", MapThemes.DEFAULT))
	return StringName(id) if MapThemes.is_valid(id) else MapThemes.DEFAULT


## El mapa leído con las reglas de §7.8 (recorridos, avisos, errores).
func grid() -> MapGrid:
	return MapGrid.parse(rows(), LevelFile.parse_legend(data))


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
	if data.has("tema"):
		lines.append("  \"tema\": %s," % JSON.stringify(data["tema"]))
	if data.has("leyenda"):
		var legend: Dictionary = data["leyenda"]
		var entries: PackedStringArray = []
		for letter: Variant in legend.keys():
			entries.append("    %s: %s" % [JSON.stringify(str(letter)), JSON.stringify(legend[letter])])
		lines.append("  \"leyenda\": {\n" + ",\n".join(entries) + "\n  },")
	if data.has("torres_extra"):
		lines.append("  \"torres_extra\": %s," % JSON.stringify(data["torres_extra"]))
	if data.has("torres"):
		lines.append("  \"torres\": %s," % JSON.stringify(data["torres"]))
	if data.has("demoledora"):
		lines.append("  \"demoledora\": %s," % JSON.stringify(data["demoledora"]))
	if data.has("textos"):
		lines.append(_texts_text())
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


## M52 (RF-464): el campo "textos" como lo escriben los niveles oficiales, una clave por renglón. Lo que no es un
## objeto, o trae claves de más, se escribe igual (check() lo marca): el editor conserva lo que no edita.
func _texts_text() -> String:
	if not data["textos"] is Dictionary:
		return "  \"textos\": %s," % JSON.stringify(data["textos"])
	var texts: Dictionary = data["textos"]
	var keys: Array = []
	for key: String in LevelTexts.KEYS:
		if texts.has(key):
			keys.append(key)
	for key: Variant in texts.keys():
		if not keys.has(key):
			keys.append(key)
	var entries: PackedStringArray = []
	for key: Variant in keys:
		entries.append("    %s: %s" % [JSON.stringify(str(key)), JSON.stringify(texts[key])])
	return "  \"textos\": {\n" + ",\n".join(entries) + "\n  },"


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
		return Localization.t(&"draft.file_name_chars")
	if is_official_id(file_id):
		return Localization.t_fmt(&"draft.official_name", {"name": file_id})
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(dir + file_id + ".json", FileAccess.WRITE)
	if file == null:
		return Localization.t_fmt(&"draft.write_failed", {"code": FileAccess.get_open_error()})
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
	for y: int in map_height():
		var x: int = (data["mapa"][y] as String).find(MapGrid.EXIT)
		if x >= 0:
			_set_letter(Vector2i(x, y), MapGrid.GRASS)


## Quita una entrada: su casilla pasa a pasto, las letras que venían después bajan un lugar y
## las oleadas se acomodan (las de la entrada quitada pasan a la A).
func _remove_entrance(letter: String) -> void:
	var index: int = MapGrid.ENTRANCE_LETTERS.find(letter)
	for y: int in map_height():
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


## RF-434: pinta un objeto (removible o extracción). Crea o reusa la letra de la leyenda con esa clase y sin
## sobrescrituras; si hace falta una nueva y la leyenda ya tiene el máximo (RF-262), avisa en `last_problem`.
func _apply_obstacle_tool(tool: Tool, cell: Vector2i) -> bool:
	var spec: Dictionary = OBSTACLE_TOOLS[tool]
	var current: String = letter_at(cell)
	var letter: String = _plain_obstacle_letter(spec["categoria"], spec["clase"])
	var is_new: bool = letter == ""
	if not is_new and current == letter:
		return false
	if is_new:
		# Pintar encima de la última casilla de otro objeto libera su letra, así que ese lugar cuenta.
		var freed: int = 1 if _is_last_obstacle_cell(current) else 0
		if _legend().size() - freed >= LevelFile.MAX_LEGEND:
			last_problem = Localization.t_fmt(&"draft.legend_full", {"max": LevelFile.MAX_LEGEND})
			return false
		letter = _spare_letter(spec["letra"])
		if letter == "":
			last_problem = Localization.t(&"draft.no_letters")
			return false
	_record()
	if is_new:
		if not data.get("leyenda") is Dictionary:
			data["leyenda"] = {}
		data["leyenda"][letter] = {spec["categoria"]: {"clase": spec["clase"]}}
	if _is_entrance(current):
		_remove_entrance(current)
	_set_letter(cell, letter)
	_forget_unused_obstacle_letter(current)
	return true


## La letra que ya tiene exactamente ese objeto, sin sobrescrituras (RF-434: "si ya hay una con los mismos valores, la reusa").
func _plain_obstacle_letter(category: String, class_id: String) -> String:
	for letter: Variant in _legend().keys():
		var entry: Variant = _legend()[letter]
		if not entry is Dictionary or obstacle_category(str(letter)) != category:
			continue
		var body: Dictionary = entry[category]
		var plain: bool = body.size() == 1 and body.get("clase") == class_id
		for key: Variant in (entry as Dictionary).keys():
			if key == "dibujo":
				plain = plain and entry[key] == class_id
			elif key == "construible":
				plain = plain and entry[key] == false
			elif key != category:
				plain = false
		if plain:
			return str(letter)
	return ""


## Una letra libre para la leyenda: la preferida o, si está ocupada, la primera de SPARE_LETTERS que ni
## esté en la leyenda ni aparezca en el mapa. "" si no queda ninguna.
func _spare_letter(preferred: String) -> String:
	for letter: String in preferred + SPARE_LETTERS:
		if not _legend().has(letter) and not _has_letter(letter):
			return letter
	return ""


func _legend() -> Dictionary:
	return data["leyenda"] if data.get("leyenda") is Dictionary else {}


func _count_letter(letter: String) -> int:
	var total: int = 0
	for row: String in data["mapa"]:
		total += row.count(letter)
	return total


## ¿Esa letra es un objeto y esta es su única casilla?
func _is_last_obstacle_cell(letter: String) -> bool:
	return letter != "" and obstacle_category(letter) != "" and _count_letter(letter) <= 1


## Si `letter` era un objeto y ya no queda ninguna casilla con ella, sale de la leyenda (si no, quedaría una letra
## declarada y sin usar, RF-265, ocupando uno de los 10 lugares). Solo toca la letra que acaba de dejar de usarse.
func _forget_unused_obstacle_letter(letter: String) -> void:
	if letter == "" or obstacle_category(letter) == "" or _has_letter(letter):
		return
	(data["leyenda"] as Dictionary).erase(letter)
	if (data["leyenda"] as Dictionary).is_empty():
		data.erase("leyenda")


func _tower_ids_of(all_towers: Array[TowerData]) -> PackedStringArray:
	var ids: PackedStringArray = []
	for tower: TowerData in all_towers:
		ids.append(String(tower.id))
	return ids


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
	if g["probabilidad"] != 1.0:
		parts.append("\"probabilidad\": %s" % _seconds(g["probabilidad"]))
	return "{" + ", ".join(parts) + "}"


## 1.0, 0.8, 0.25… (un decimal si alcanza, como en los niveles oficiales).
static func _seconds(value: float) -> String:
	return "%.1f" % value if is_equal_approx(value * 10.0, roundf(value * 10.0)) else str(value)


static func _to_int(value: Variant) -> int:
	return int(value) if value is int or value is float else 0


static func _to_float(value: Variant) -> float:
	return float(value) if value is int or value is float else 0.0


## Filas de igual largo: lo que falta se completa con pasto y lo que sobra se corta. El tamaño es
## el del mapa (RF-254), corregido al más cercano permitido si era imposible (menos de 20×9 o más de 26×12).
static func _clean_rows(value: Variant) -> Array:
	var source: Array = value if value is Array else []
	var height: int = clampi(source.size(), MapGrid.MIN_HEIGHT, MapGrid.MAX_HEIGHT)
	var first_length: int = str(source[0]).length() if not source.is_empty() else 0
	var width: int = clampi(first_length, MapGrid.MIN_WIDTH, MapGrid.MAX_WIDTH)
	var rows_out: Array = []
	for y: int in height:
		var row: String = str(source[y]) if y < source.size() else ""
		rows_out.append(row.left(width).rpad(width, MapGrid.GRASS))
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
			if group_source.has("probabilidad"):
				cleaned["probabilidad"] = _to_float(group_source["probabilidad"])
			groups.append(cleaned)
		waves.append(groups)
	return waves
