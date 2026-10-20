# El documento editable de la intro (M62, RF-561 y RF-562): pasa `data/intro/intro.json` a un Markdown fácil de
# retocar a mano (una sección por lámina) y lo vuelve a leer, validando con las mismas reglas que usa el juego
# (`IntroData.parse`). Es lógica pura, sin escena (P10); la herramienta `tools/intro_doc.gd` solo lee y escribe archivos.
# El juego NO lee este documento: sigue leyendo el JSON (D-121). Las notas del documento no van al juego.
# Los errores van en castellano y nombran la línea del documento o la lámina.
class_name IntroDoc
extends RefCounted

const DOC_PATH: String = "res://specs/intro/intro-editable.md"
const SECTION_SETTINGS: String = "Ajustes generales"
const SECTION_SLIDE: String = "Lámina"
const NO_VOICE: Array[String] = ["", "ninguno", "ninguna", "no", "-", "—", "sin voz", "sin sonido"]

const _MODE_FIELDS: int = 0
const _MODE_TEXT: int = 1
const _MODE_NOTES: int = 2


## El título de una lámina para orientarse: «res://assets/intro/01_la_nave.png» → «La nave».
## Solo se muestra en el documento; no se guarda en ningún dato.
static func title_of(image: String) -> String:
	var name: String = image.get_file().get_basename()
	var parts: PackedStringArray = name.split("_")
	if parts.size() > 1 and parts[0].is_valid_int():
		parts.remove_at(0)
	var title: String = " ".join(parts)
	return title.substr(0, 1).to_upper() + title.substr(1) if not title.is_empty() else "sin título"


## El JSON de la intro, con la misma forma y el mismo orden de claves que el archivo oficial (RF-497),
## para que `exportar` + `importar` dejen el archivo idéntico byte por byte.
static func to_json(raw: Dictionary) -> String:
	var out: String = "{\n"
	out += "\t\"version\": %s,\n" % _number(raw.get("version", 1))
	if raw.has("fundido_s"):
		out += "\t\"fundido_s\": %s,\n" % _number(raw["fundido_s"])
	out += "\t\"laminas\": [\n"
	var slides: Array = raw.get("laminas", [])
	for i: int in slides.size():
		var slide: Dictionary = slides[i]
		out += "\t\t{\n"
		out += "\t\t\t\"imagen\": %s,\n" % JSON.stringify(slide.get("imagen", ""))
		out += "\t\t\t\"texto\": %s,\n" % JSON.stringify(slide.get("texto", ""))
		out += "\t\t\t\"segundos\": %s\n" % _number(slide.get("segundos", 0))
		out += "\t\t}%s\n" % ("," if i < slides.size() - 1 else "")
	out += "\t]\n}\n"
	return out


## El documento a partir del contenido del JSON. `notes` es `{imagen: texto}` (las notas que ya había).
static func to_markdown(raw: Dictionary, notes: Dictionary = {}) -> String:
	var out: PackedStringArray = []
	out.append("# Intro del juego: textos y tiempos")
	out.append("")
	out.append("Este documento es una **vista editable** de `data/intro/intro.json`. El juego lee ese JSON, no este archivo.")
	out.append("")
	out.append("**Cómo se usa** (más detalle en `CONTENIDO.md`):")
	out.append("")
	out.append("1. Cambiá lo que quieras: el texto de cada lámina, los segundos, el fundido o la imagen.")
	out.append("2. Para ver si quedó bien sin guardar nada: `godot --headless --path . -s tools/intro_doc.gd -- import --dry`.")
	out.append("3. Para pasarlo al juego: `godot --headless --path . -s tools/intro_doc.gd -- import`. Si hay un error, lo dice con el número de línea y **no cambia nada**.")
	out.append("4. Para volver a empezar desde lo que carga el juego: `... -- export` (conserva las notas).")
	out.append("")
	out.append("**Reglas** (las mismas que revisa el juego): de 5 a 8 láminas; el texto, de 1 o 2 líneas, hasta %d caracteres por línea y %d en total; los segundos, un número entero de %d a %d; el fundido, de 0 a %s segundos; la imagen, un archivo que exista (`res://assets/intro/...`)." % [
			LevelTexts.LINE_MAX_CHARS, LevelTexts.WIN_MAX_CHARS, IntroData.MIN_SECONDS, IntroData.MAX_SECONDS, _number(IntroData.MAX_FADE_S)])
	out.append("Cada línea del texto empieza con `> `. Las **notas** son solo para vos: no se cargan al juego. La intro no tiene voces ni sonidos propios, así que «Voz o sonido» queda en «ninguno».")
	out.append("")
	out.append("## %s" % SECTION_SETTINGS)
	out.append("")
	out.append("- Versión del formato: %s" % _number(raw.get("version", 1)))
	if raw.has("fundido_s"):
		out.append("- Fundido entre láminas (segundos): %s" % _number(raw["fundido_s"]))
	out.append("")
	var slides: Array = raw.get("laminas", [])
	for i: int in slides.size():
		var slide: Dictionary = slides[i]
		var image: String = String(slide.get("imagen", ""))
		out.append("## %s %d · %s" % [SECTION_SLIDE, i + 1, title_of(image)])
		out.append("")
		out.append("- Imagen: %s" % image)
		out.append("- Segundos: %s" % _number(slide.get("segundos", 0)))
		out.append("- Voz o sonido: ninguno")
		out.append("")
		out.append("Texto:")
		out.append("")
		for line: String in String(slide.get("texto", "")).split("\n"):
			out.append("> " + line if not line.is_empty() else ">")
		out.append("")
		out.append("Notas:")
		out.append("")
		var note: String = String(notes.get(image, "")).strip_edges()
		if not note.is_empty():
			out.append(note)
			out.append("")
	return "\n".join(out)


## Lee el documento. Devuelve `{"raw": Dictionary, "errors": PackedStringArray, "warnings": PackedStringArray,
## "notes": Dictionary}`. `raw` tiene la forma de `intro.json`; si hay errores, no hay que escribirlo.
static func parse_markdown(text: String) -> Dictionary:
	var errors: PackedStringArray = []
	var warnings: PackedStringArray = []
	var settings: Dictionary = {}  # "version" y "fundido" como texto
	var settings_line: int = 0
	var slides: Array[Dictionary] = []  # {"imagen", "segundos", "voz", "lines", "has_text", "notes", "line", "heading_number"}
	var current: Dictionary = {}
	var section: String = ""  # "", "ajustes" o "lamina"
	var mode: int = _MODE_FIELDS
	var lines: PackedStringArray = text.replace("\r\n", "\n").split("\n")
	for index: int in lines.size():
		var number: int = index + 1
		var line: String = lines[index]
		if line.begins_with("## "):
			var heading: String = line.substr(3).strip_edges()
			var lowered: String = heading.to_lower()
			mode = _MODE_FIELDS
			if lowered.begins_with(SECTION_SETTINGS.to_lower()):
				section = "ajustes"
				settings_line = number
			elif lowered.begins_with("lámina") or lowered.begins_with("lamina"):
				section = "lamina"
				current = {"line": number, "lines": [], "notes": [], "has_text": false,
						"heading_number": _heading_number(heading)}
				slides.append(current)
			else:
				section = ""
				errors.append("línea %d: no entiendo la sección «%s» (tiene que ser «%s» o «%s N»)." % [number, heading, SECTION_SETTINGS, SECTION_SLIDE])
			continue
		if section == "":
			continue  # la presentación de arriba y lo que no es de ninguna lámina
		if section == "lamina" and mode == _MODE_NOTES:
			(current["notes"] as Array).append(line)
			continue
		var plain: String = line.replace("*", "").strip_edges()
		if plain.is_empty():
			continue
		if section == "lamina" and _is_label(plain, "texto"):
			if current["has_text"]:
				errors.append("línea %d: la lámina %d tiene dos bloques «Texto:»." % [number, slides.size()])
			current["has_text"] = true
			mode = _MODE_TEXT
			continue
		if section == "lamina" and _is_label(plain, "notas"):
			mode = _MODE_NOTES
			continue
		if section == "lamina" and mode == _MODE_TEXT:
			var raw_line: String = line.strip_edges()  # el texto conserva sus asteriscos (`plain` no)
			if raw_line.begins_with(">"):
				(current["lines"] as Array).append(raw_line.substr(1).strip_edges())
			else:
				errors.append("línea %d: en la lámina %d cada línea del texto tiene que empezar con «> » (o escribí «Notas:» antes de las notas)." % [number, slides.size()])
			continue
		_read_field(plain, number, section, settings if section == "ajustes" else current, slides.size(), errors)
	return _finish(settings, settings_line, slides, errors, warnings)


## Cuántos cambios hay entre dos contenidos de la intro, uno por línea, para mostrarlos antes de escribir.
static func describe_changes(old_raw: Dictionary, new_raw: Dictionary) -> PackedStringArray:
	var changes: PackedStringArray = []
	if _number(old_raw.get("fundido_s", "")) != _number(new_raw.get("fundido_s", "")):
		changes.append("fundido entre láminas: %s → %s" % [_number(old_raw.get("fundido_s", "por omisión")), _number(new_raw.get("fundido_s", "por omisión"))])
	var old_slides: Array = old_raw.get("laminas", [])
	var new_slides: Array = new_raw.get("laminas", [])
	if old_slides.size() != new_slides.size():
		changes.append("cantidad de láminas: %d → %d" % [old_slides.size(), new_slides.size()])
	for i: int in mini(old_slides.size(), new_slides.size()):
		var before: Dictionary = old_slides[i]
		var after: Dictionary = new_slides[i]
		for key: String in ["imagen", "segundos", "texto"]:
			if _number(before.get(key)) != _number(after.get(key)):
				changes.append("lámina %d, %s: %s → %s" % [i + 1, key, _number(before.get(key)).replace("\n", " / "), _number(after.get(key)).replace("\n", " / ")])
	return changes


# --- Armado y lectura ---

static func _finish(settings: Dictionary, settings_line: int, slides: Array[Dictionary], errors: PackedStringArray, warnings: PackedStringArray) -> Dictionary:
	var raw: Dictionary = {}
	var notes: Dictionary = {}
	if settings_line == 0:
		errors.append("falta la sección «%s» (con la versión del formato)." % SECTION_SETTINGS)
	elif not settings.has("version"):
		errors.append("línea %d: en «%s» falta «Versión del formato»." % [settings_line, SECTION_SETTINGS])
	else:
		var version: Variant = _to_number(settings["version"])
		if version == null:
			errors.append("«Versión del formato» tiene que ser un número (dice «%s»)." % settings["version"])
		else:
			raw["version"] = version
	if settings.has("fundido"):
		var fade: Variant = _to_number(settings["fundido"])
		if fade == null:
			errors.append("«Fundido entre láminas» tiene que ser un número de segundos (dice «%s»)." % settings["fundido"])
		else:
			raw["fundido_s"] = fade
	var list: Array = []
	for i: int in slides.size():
		var slide: Dictionary = slides[i]
		var label: int = i + 1
		var entry: Dictionary = {}
		if slide["heading_number"] > 0 and slide["heading_number"] != label:
			warnings.append("línea %d: el título dice «Lámina %d» pero es la %d.ª del documento; se usa el orden del documento." % [slide["line"], slide["heading_number"], label])
		if not slide.has("imagen"):
			errors.append("la lámina %d (línea %d) no tiene «Imagen»." % [label, slide["line"]])
		else:
			entry["imagen"] = slide["imagen"]
		if not slide["has_text"]:
			errors.append("la lámina %d (línea %d) no tiene «Texto:»." % [label, slide["line"]])
		else:
			entry["texto"] = "\n".join(PackedStringArray(slide["lines"]))
		if not slide.has("segundos"):
			errors.append("la lámina %d (línea %d) no tiene «Segundos»." % [label, slide["line"]])
		else:
			var seconds: Variant = _to_number(slide["segundos"])
			if seconds == null:
				errors.append("la lámina %d (línea %d): «Segundos» tiene que ser un número entero (dice «%s»)." % [label, slide["line"], slide["segundos"]])
			else:
				entry["segundos"] = seconds
		if slide.has("voz") and not NO_VOICE.has(String(slide["voz"]).to_lower()):
			warnings.append("la lámina %d: «Voz o sonido» dice «%s», pero la intro no tiene voces ni sonidos (RF-499): no se carga." % [label, slide["voz"]])
		list.append(entry)
		var note: String = "\n".join(PackedStringArray(slide["notes"])).strip_edges()
		if slide.has("imagen") and not note.is_empty():
			notes[slide["imagen"]] = note
	raw["laminas"] = list
	if errors.is_empty():
		var data: IntroData = IntroData.parse(raw)
		errors.append_array(data.errors)
		if data.errors.is_empty():
			for i: int in list.size():
				var needed: int = IntroData.reading_seconds(String(list[i]["texto"]))
				if int(list[i]["segundos"]) < needed:
					warnings.append("la lámina %d dura %d s y su texto pide al menos %d s para leerse (regla del guion); el juego la acepta igual." % [i + 1, int(list[i]["segundos"]), needed])
	return {"raw": raw, "errors": errors, "warnings": warnings, "notes": notes}


## Una línea «- Clave: valor» de una lámina (`target` es la lámina o los ajustes).
static func _read_field(plain: String, number: int, section: String, target: Dictionary, slide_number: int, errors: PackedStringArray) -> void:
	var body: String = plain
	if body.begins_with("-"):
		body = body.substr(1).strip_edges()
	var colon: int = body.find(":")
	if colon < 0:
		errors.append("línea %d: no entiendo «%s» (se espera «- Clave: valor»)." % [number, plain])
		return
	var key: String = body.substr(0, colon).strip_edges().to_lower()
	var value: String = body.substr(colon + 1).strip_edges().trim_prefix("`").trim_suffix("`").strip_edges()
	var field: String = ""
	if section == "ajustes":
		if key.begins_with("versi"):
			field = "version"
		elif key.begins_with("fundido"):
			field = "fundido"
	else:
		if key.begins_with("imagen"):
			field = "imagen"
		elif key.begins_with("segundos") or key.begins_with("duraci"):
			field = "segundos"
		elif key.begins_with("voz") or key.begins_with("sonido"):
			field = "voz"
	if field.is_empty() and (key.begins_with("texto") or key.begins_with("notas")):
		errors.append("línea %d: «Texto:» y «Notas:» van solas en su línea y lo que escribas va debajo (el texto, con «> » adelante)." % number)
	elif field.is_empty():
		errors.append("línea %d: no conozco el campo «%s»." % [number, body.substr(0, colon).strip_edges()])
	elif target.has(field):
		errors.append("línea %d: «%s» está repetido%s." % [number, body.substr(0, colon).strip_edges(), " en la lámina %d" % slide_number if section == "lamina" else " en los ajustes"])
	else:
		target[field] = value


static func _is_label(plain: String, word: String) -> bool:
	var lowered: String = plain.to_lower()
	return lowered.begins_with(word) and lowered.ends_with(":") and not lowered.contains(": ")


static func _heading_number(heading: String) -> int:
	for part: String in heading.split(" "):
		if part.is_valid_int():
			return part.to_int()
	return 0


## «7», «7 s», «0,6» o «0.6» → número; cualquier otra cosa → null.
static func _to_number(value: String) -> Variant:
	var text: String = value.strip_edges().to_lower().trim_suffix("segundos").trim_suffix("s").strip_edges().replace(",", ".")
	if not text.is_valid_float():
		return null
	var number: float = text.to_float()
	if is_equal_approx(number, roundf(number)) and not text.contains("."):
		return int(number)
	return number


## Un número o un texto, tal como se escribe (entero sin «.0»).
static func _number(value: Variant) -> String:
	if typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), roundf(float(value))):
		return str(int(value))
	return str(value)
