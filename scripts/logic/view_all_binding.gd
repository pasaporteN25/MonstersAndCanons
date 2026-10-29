# La tecla de «Ver todo» (M68, RF-613, RF-614, D-161, D-162). Lógica pura: no sabe de escenas (P10).
# La acción de input `view_all` vive en `project.godot` con la V por omisión; acá se la cambia en tiempo de
# ejecución según lo que el jugador eligió en Opciones (se guarda en `ui_prefs`, RF-615).
class_name ViewAllBinding
extends RefCounted

const ACTION: StringName = &"view_all"
const DEFAULT_KEY: int = KEY_V
## Teclas que no se pueden elegir aunque ninguna acción de `InputMap` las use: el panel de pruebas (F1 a F12) y
## los modificadores, que solos no son una tecla.
const RESERVED_KEYS: Array[int] = [KEY_ESCAPE, KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_CAPSLOCK, KEY_UNKNOWN]


## ¿Es un código de tecla física que se puede guardar? (positivo y no reservado; F1 a F12 sí valen para el
## guardado, pero `conflict` las rechaza al elegir).
static func is_valid_key(keycode: int) -> bool:
	return keycode > 0 and not RESERVED_KEYS.has(keycode)


## El nombre de la acción de teclado que ya usa esa tecla (para avisar «ya la usa …»), o "" si está libre.
## Las teclas F1 a F12 y las reservadas cuentan como ocupadas (el panel de pruebas, F1, y sus atajos).
static func conflict(keycode: int) -> String:
	if not is_valid_key(keycode):
		return Localization.t(&"options.controls.reserved_key")
	if keycode >= KEY_F1 and keycode <= KEY_F12:
		return Localization.t(&"options.controls.test_panel")
	for action: StringName in InputMap.get_actions():
		if action == ACTION or String(action).begins_with("ui_"):
			continue
		for event: InputEvent in InputMap.action_get_events(action):
			var key := event as InputEventKey
			if key != null and key.physical_keycode == keycode:
				return label_for_action(action)
	return ""


## Cómo se llama cada acción de teclado en los avisos de Opciones.
static func label_for_action(action: StringName) -> String:
	var names: Dictionary = {
		&"switch_tab": &"options.controls.action_switch_tab", &"cancel": &"options.controls.action_cancel",
		&"start_wave": &"options.controls.action_start_wave", &"pause": &"options.controls.action_pause",
		&"toggle_speed": &"options.controls.action_toggle_speed", &"upgrade": &"options.controls.action_upgrade",
		&"sell": &"options.controls.action_sell",
	}
	if names.has(action):
		return Localization.t(names[action])
	if String(action).begins_with("build_"):
		return Localization.t(&"options.controls.action_build")
	return String(action)


## Cambia la tecla de la acción `view_all`: deja una sola, la elegida.
static func apply(keycode: int) -> void:
	var key: int = keycode if is_valid_key(keycode) else DEFAULT_KEY
	if not InputMap.has_action(ACTION):
		InputMap.add_action(ACTION)
	InputMap.action_erase_events(ACTION)
	var event := InputEventKey.new()
	event.physical_keycode = key as Key
	InputMap.action_add_event(ACTION, event)


## La tecla de hoy de la acción (0 si no tiene).
static func current_key() -> int:
	if not InputMap.has_action(ACTION):
		return 0
	for event: InputEvent in InputMap.action_get_events(ACTION):
		var key := event as InputEventKey
		if key != null:
			return key.physical_keycode as int
	return 0


## El nombre de la tecla para mostrar («V», «Tab», «Espacio»).
static func key_text(keycode: int) -> String:
	if keycode == KEY_SPACE:
		return Localization.t(&"options.controls.key_space")
	return OS.get_keycode_string(keycode)
