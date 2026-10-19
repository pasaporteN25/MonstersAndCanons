# Pasa los textos de la intro a un documento fácil de editar y de vuelta (spec M62, RF-561 y RF-562).
#
# Uso (desde la carpeta del proyecto):
#   godot --headless --path . -s tools/intro_doc.gd -- export          data/intro/intro.json -> specs/intro/intro-editable.md
#   godot --headless --path . -s tools/intro_doc.gd -- import --dry    valida el documento y muestra qué cambiaría, sin escribir
#   godot --headless --path . -s tools/intro_doc.gd -- import          valida el documento y reescribe data/intro/intro.json
# Opciones: --doc=res://ruta.md  --json=res://ruta.json (por omisión, las oficiales).
#
# `import` con errores no escribe nada y termina con código 1. Si agregaste una clase nueva (`class_name`),
# corré antes `godot --headless --import`.
extends SceneTree


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var doc_path: String = IntroDoc.DOC_PATH
	var json_path: String = IntroData.DEFAULT_PATH
	var dry: bool = false
	var command: String = ""
	for arg: String in args:
		if arg.begins_with("--doc="):
			doc_path = arg.trim_prefix("--doc=")
		elif arg.begins_with("--json="):
			json_path = arg.trim_prefix("--json=")
		elif arg == "--dry":
			dry = true
		elif command.is_empty():
			command = arg
	match command:
		"export":
			quit(_export(doc_path, json_path))
		"import":
			quit(_import(doc_path, json_path, dry))
		_:
			print("Uso: -- export | import [--dry]   (más detalle en el encabezado de tools/intro_doc.gd)")
			quit(1)


func _export(doc_path: String, json_path: String) -> int:
	var raw: Variant = _read_json(json_path)
	if not raw is Dictionary:
		return 1
	var notes: Dictionary = {}
	if FileAccess.file_exists(doc_path):
		notes = IntroDoc.parse_markdown(FileAccess.get_file_as_string(doc_path))["notes"]
	if not _write(doc_path, IntroDoc.to_markdown(raw, notes)):
		return 1
	var count: int = (raw as Dictionary).get("laminas", []).size()
	print("Listo: %d láminas de %s pasadas a %s (%d notas conservadas)." % [count, json_path, doc_path, notes.size()])
	return 0


func _import(doc_path: String, json_path: String, dry: bool) -> int:
	if not FileAccess.file_exists(doc_path):
		printerr("No existe el documento %s (¿corriste `export`?)." % doc_path)
		return 1
	var result: Dictionary = IntroDoc.parse_markdown(FileAccess.get_file_as_string(doc_path))
	for warning: String in result["warnings"]:
		print("AVISO: ", warning)
	var errors: PackedStringArray = result["errors"]
	if not errors.is_empty():
		for error: String in errors:
			printerr("ERROR: ", error)
		printerr("\n%d %s. No se escribió nada: %s sigue igual." % [errors.size(), "error" if errors.size() == 1 else "errores", json_path])
		return 1
	var new_raw: Dictionary = result["raw"]
	var old_raw: Variant = _read_json(json_path, true)
	var changes: PackedStringArray = IntroDoc.describe_changes(old_raw, new_raw) if old_raw is Dictionary else ["no había archivo"]
	var text: String = IntroDoc.to_json(new_raw)
	if FileAccess.file_exists(json_path) and FileAccess.get_file_as_string(json_path) == text:
		print("Sin cambios: %s ya dice lo mismo que el documento." % json_path)
		return 0
	for change: String in changes:
		print("CAMBIA: ", change)
	if dry:
		print("\n(--dry) Todo válido; no se escribió nada.")
		return 0
	if not _write(json_path, text):
		return 1
	print("\nListo: %s actualizado. Corré los tests (o abrí la intro desde la Wiki) para verla." % json_path)
	return 0


func _read_json(path: String, quiet: bool = false) -> Variant:
	if not FileAccess.file_exists(path):
		if not quiet:
			printerr("No existe %s." % path)
		return null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		if not quiet:
			printerr("%s no es un JSON válido (línea %d: %s)." % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data


func _write(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("No se pudo escribir %s (error %d)." % [path, FileAccess.get_open_error()])
		return false
	file.store_string(text)
	return true
