# Presentación de escritorio sin cambiar las coordenadas del mapa lógico.
class_name DesktopWindow
extends RefCounted

const FULL_HD := Vector2i(1920, 1080)
const BORDER_MARGIN := Vector2i(32, 48)

static func fitted_size(available: Vector2i) -> Vector2i:
	var usable: Vector2i = (available - BORDER_MARGIN).max(Vector2i.ONE)
	var factor: float = minf(1.0, minf(float(usable.x) / FULL_HD.x, float(usable.y) / FULL_HD.y))
	return Vector2i(maxi(1, floori(FULL_HD.x * factor)), maxi(1, floori(FULL_HD.y * factor)))

static func apply() -> void:
	if DisplayServer.get_name() == "headless" or OS.get_name() not in ["Windows", "Linux"]:
		return
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return
	# Respetar una resolución elegida explícitamente por herramientas de captura.
	if "--resolution" in OS.get_cmdline_args():
		return
	var screen: int = DisplayServer.window_get_current_screen()
	var area: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	var size_: Vector2i = fitted_size(area.size)
	DisplayServer.window_set_size(size_)
	DisplayServer.window_set_position(area.position + (area.size - size_) / 2)
