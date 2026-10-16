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
	return resolve(read_setting(SaveManager.get_setting("ui_mode")), OS.has_feature("mobile"))
