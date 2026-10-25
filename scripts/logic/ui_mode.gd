class_name UiMode
extends RefCounted

const AUTOMATIC: int = 0
const MOBILE: int = 1
const PC: int = 2


static func read_setting(raw: Variant) -> int:
	if typeof(raw) not in [TYPE_INT, TYPE_FLOAT] or float(raw) != floorf(float(raw)) or int(raw) < AUTOMATIC or int(raw) > PC:
		return AUTOMATIC
	return int(raw)


static func resolve(setting: int, has_mobile_feature: bool) -> bool:
	var valid_setting: int = read_setting(setting)
	if valid_setting == MOBILE:
		return true
	if valid_setting == PC:
		return false
	return has_mobile_feature


static func is_mobile() -> bool:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var save_manager: Node = (main_loop as SceneTree).root.get_node_or_null("SaveManager")
		if save_manager != null:
			var saved_mode: Variant = save_manager.call("get_setting", "ui_mode")
			return resolve(read_setting(saved_mode), OS.has_feature("mobile"))
	return OS.has_feature("mobile")
