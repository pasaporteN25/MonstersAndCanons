class_name GameVersion
extends RefCounted
# RF-554 (M61, D-117): la versión del juego vive en un solo lugar, `config/version` de `project.godot`, y esta clase
# decide cómo se muestra. Mientras el juego está en beta se ve «Beta» (o «Beta 0.3.0» con un número menor a 1);
# desde la 1.0.0, «Versión 1.0.0». Lógica pura (P10): `label` no lee el proyecto, solo formatea.

const SETTING: String = "application/config/version"
const BETA: String = "Beta"


## La versión escrita en `project.godot` («» si falta).
static func raw() -> String:
	return String(ProjectSettings.get_setting(SETTING, ""))


## El texto que ve el jugador para `version`.
static func label(version: String) -> String:
	var text: String = version.strip_edges()
	if text == "" or text.to_lower() == "beta":
		return BETA
	var parts: Dictionary = parse(text)
	if parts.is_empty():
		return "%s %s" % [BETA, text]  # no se entiende: se muestra tal cual, todavía como beta
	if int(parts["major"]) >= 1 and String(parts["suffix"]) == "":
		return Localization.t_fmt(&"version.release", {"version": text})
	return "%s %s" % [BETA, text]


## `X.Y.Z` o `X.Y.Z-sufijo` (también `+sufijo`) → `{major, minor, patch, suffix}`; `{}` si no tiene esa forma.
static func parse(version: String) -> Dictionary:
	var regex := RegEx.new()
	regex.compile("^(\\d+)\\.(\\d+)\\.(\\d+)(?:[-+](.+))?$")
	var found: RegExMatch = regex.search(version)
	if found == null:
		return {}
	return {
		"major": found.get_string(1).to_int(),
		"minor": found.get_string(2).to_int(),
		"patch": found.get_string(3).to_int(),
		"suffix": found.get_string(4),
	}
