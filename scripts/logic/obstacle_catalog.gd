# Catálogo puro de valores para removibles, extracciones y la demoledora (RF-398).
class_name ObstacleCatalog
extends RefCounted

const PATH: String = "res://data/obstaculos.json"
const ROOT_KEYS: PackedStringArray = ["version", "demoledora", "removibles", "extraccion"]
const MACHINE_KEYS: PackedStringArray = ["precio", "costo_uso_porcentaje", "costo_uso_minimo", "tiempo_porcentaje"]
const REMOVABLE_KEYS: PackedStringArray = ["costo", "tiempo", "recursos", "probabilidad", "recursos_si_recuperado"]
const EXTRACTION_KEYS: PackedStringArray = ["costo", "produccion", "reserva"]
const REMOVABLE_CLASSES: PackedStringArray = ["arbol", "roca", "escombro"]
const EXTRACTION_CLASSES: PackedStringArray = ["mina", "bosque_explotable"]
static var _load_warning_shown: bool = false


static func load_data(path: String = PATH) -> Dictionary:
	var errors: PackedStringArray = []
	if not FileAccess.file_exists(path):
		return _unavailable("No existe el archivo %s." % path)
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return _unavailable("El archivo %s no contiene un objeto JSON válido." % path)
	var data: Dictionary = parser.data
	_check_keys(data, ROOT_KEYS, "", errors)
	if not data.has("version") or not _is_number(data["version"]) or float(data["version"]) != 1.0:
		errors.append("version: tiene que ser 1.")
	_check_machine(data.get("demoledora"), errors)
	_check_classes(data.get("removibles"), REMOVABLE_CLASSES, REMOVABLE_KEYS, "removibles", errors)
	_check_classes(data.get("extraccion"), EXTRACTION_CLASSES, EXTRACTION_KEYS, "extraccion", errors)
	if not errors.is_empty():
		return _unavailable("El archivo %s tiene errores: %s" % [path, "; ".join(errors)])
	return {"data": data, "errors": errors}


static func _unavailable(reason: String) -> Dictionary:
	var errors: PackedStringArray = [reason]
	if not _load_warning_shown:
		push_warning("No se cargaron los removibles: %s. El juego seguirá sin sus valores." % reason)
		_load_warning_shown = true
	return {"data": {}, "errors": errors}


static func removable(class_id: String, data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else load_data()["data"]
	return source.get("removibles", {}).get(class_id, {})


static func extraction(class_id: String, data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else load_data()["data"]
	return source.get("extraccion", {}).get(class_id, {})


static func machine(data: Dictionary = {}) -> Dictionary:
	var source: Dictionary = data if not data.is_empty() else load_data()["data"]
	return source.get("demoledora", {})


static func class_ids(data: Dictionary = {}) -> PackedStringArray:
	var source: Dictionary = data if not data.is_empty() else load_data()["data"]
	var ids: Array[String] = []
	for category: String in ["removibles", "extraccion"]:
		for id: Variant in source.get(category, {}).keys():
			ids.append(String(id))
	ids.sort()
	return PackedStringArray(ids)


static func _check_machine(value: Variant, errors: PackedStringArray) -> void:
	_check_values(value, MACHINE_KEYS, "demoledora", errors)
	if not value is Dictionary:
		return
	for key: String in MACHINE_KEYS:
		if not value.has(key):
			errors.append("demoledora: falta \"%s\"." % key)
		elif not _is_number(value[key]) or float(value[key]) < 0.0:
			errors.append("demoledora.%s: tiene que ser un número de 0 para arriba." % key)
		elif float(value[key]) != floorf(float(value[key])):
			errors.append("demoledora.%s: tiene que ser un número entero." % key)


static func _check_classes(value: Variant, class_ids: PackedStringArray, known: PackedStringArray, where: String, errors: PackedStringArray) -> void:
	if not value is Dictionary:
		errors.append("%s: tiene que ser un objeto." % where)
		return
	for class_id: String in class_ids:
		if not value.has(class_id):
			errors.append("%s: falta la clase \"%s\"." % [where, class_id])
	for class_key: Variant in value.keys():
		var entry: Variant = value[class_key]
		if not entry is Dictionary:
			errors.append("%s.%s: tiene que ser un objeto." % [where, class_key])
			continue
		_check_values(entry, known, "%s.%s" % [where, class_key], errors)
		if not class_ids.has(str(class_key)):
			errors.append("%s: la clase \"%s\" no existe." % [where, class_key])
		var required: PackedStringArray = ["costo", "tiempo", "recursos", "probabilidad"] if where == "removibles" \
			else ["costo", "produccion", "reserva"]
		if class_key == "escombro":
			required.append("recursos_si_recuperado")
		elif entry.has("recursos_si_recuperado"):
			errors.append("%s.%s: \"recursos_si_recuperado\" solo corresponde a escombro." % [where, class_key])
		for key: String in required:
			if not entry.has(key):
				errors.append("%s.%s: falta \"%s\"." % [where, class_key, key])
		for key: String in entry:
			var number: Variant = entry[key]
			if not _is_number(number) or float(number) < 0.0:
				errors.append("%s.%s: tiene que ser un número de 0 para arriba." % [class_key, key])
				continue
			if key in ["costo", "tiempo"] and float(number) <= 0.0:
				errors.append("%s.%s: tiene que ser mayor que 0." % [class_key, key])
			if key != "tiempo" and float(number) != floorf(float(number)):
				errors.append("%s.%s: tiene que ser un número entero." % [class_key, key])
			if key == "probabilidad" and float(number) > 100.0:
				errors.append("%s.probabilidad: no puede superar 100." % class_key)


static func _check_values(value: Variant, known: PackedStringArray, where: String, errors: PackedStringArray) -> void:
	if not value is Dictionary:
		errors.append("%s: tiene que ser un objeto." % where)
		return
	_check_keys(value, known, where, errors)


static func _check_keys(data: Dictionary, known: PackedStringArray, where: String, errors: PackedStringArray) -> void:
	for key: Variant in data.keys():
		if not known.has(str(key)):
			errors.append("%s: clave desconocida \"%s\"." % [where, key])


static func _is_number(value: Variant) -> bool:
	return value is int or value is float
