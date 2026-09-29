# Los mapas de la comunidad (spec §10.4, RF-220 a RF-223, D-034): todo .json de user://maps/.
# Es la misma carpeta donde guarda el editor de mapas. Solo lee datos (JSON, spec §7.8): un mapa
# ajeno nunca puede traer código. Nunca corta el juego: un archivo roto es una entrada más, con el
# motivo, y los demás se ven igual.
class_name CommunityMaps
extends RefCounted

const DIR: String = "user://maps/"
## RF-224: el id de progreso de un mapa de la comunidad. El prefijo evita que un archivo llamado
## "level_03" o "hall_of_fame" se confunda, en el guardado, con un nivel oficial o con el Salón.
const ID_PREFIX: String = "comunidad_"
## RF-222: un archivo más grande que esto se ignora (un mapa real pesa 2 o 3 KB).
const MAX_FILE_BYTES: int = 200_000
## Cuántos archivos como máximo se leen (la pantalla no puede llenarse con miles de tarjetas).
const MAX_MAPS: int = 200


## Un entrada por cada .json de la carpeta, en orden alfabético del nombre de archivo:
## {"file": "mi_mapa", "id": &"comunidad_mi_mapa", "level": LevelData o null,
##  "errors": PackedStringArray, "warnings": PackedStringArray}
## `level` es null si el archivo no se puede jugar; `errors` dice por qué (RF-222).
static func scan(dir: String = DIR) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if not DirAccess.dir_exists_absolute(dir):
		return entries  # todavía no hay carpeta: no hay mapas
	var files: PackedStringArray = []
	for file: String in DirAccess.get_files_at(dir):
		if file.get_extension().to_lower() == "json":
			files.append(file)
	files.sort()
	for file: String in files.slice(0, MAX_MAPS):
		entries.append(_read(dir, file))
	return entries


static func id_for(file_id: String) -> StringName:
	return StringName(ID_PREFIX + file_id)


## Solo los que se pueden jugar (los otros no tienen `level`).
static func playable(entries: Array[Dictionary]) -> Array[LevelData]:
	var levels: Array[LevelData] = []
	for entry: Dictionary in entries:
		if entry["level"] != null:
			levels.append(entry["level"])
	return levels


## La carpeta como la ve la persona (para decirle dónde poner los archivos).
static func folder_path(dir: String = DIR) -> String:
	return ProjectSettings.globalize_path(dir)


static func _read(dir: String, file: String) -> Dictionary:
	var file_id: String = file.get_basename()
	var entry: Dictionary = {
		"file": file_id, "id": id_for(file_id), "level": null,
		"errors": PackedStringArray(), "warnings": PackedStringArray(),
	}
	if not LevelDraft.is_valid_file_id(file_id):
		entry["errors"] = PackedStringArray([
			"Nombre de archivo no válido: solo minúsculas, números y _ (hasta %d letras)." % LevelDraft.FILE_ID_MAX])
		return entry
	var size: int = _size(dir + file)
	if size > MAX_FILE_BYTES:
		entry["errors"] = PackedStringArray([
			"El archivo es demasiado grande (%d KB; el máximo es %d KB)." % [ceili(size / 1000.0), MAX_FILE_BYTES / 1000]])
		return entry
	var result: Dictionary = LevelFile.parse(FileAccess.get_file_as_string(dir + file), entry["id"])
	entry["level"] = result["level"]
	entry["errors"] = result["errors"]
	entry["warnings"] = result["warnings"]
	return entry


static func _size(path: String) -> int:
	var opened := FileAccess.open(path, FileAccess.READ)
	if opened == null:
		return 0
	var length: int = opened.get_length()
	opened.close()
	return length
