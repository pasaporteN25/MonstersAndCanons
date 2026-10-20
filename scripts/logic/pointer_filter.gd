class_name PointerFilter
extends RefCounted
# RF-552 (M61, D-116): quién manda en el modo celular no es la plataforma sino el dispositivo que generó el evento.
# - Un toque (`InputEventScreenTouch`) siempre es un dedo: se avisa con `note_touch`.
# - El clic que Godot fabrica a partir de un toque trae `device = DEVICE_ID_EMULATION`: se descarta.
# - Un clic de mouse real es un dedo de índice -1 (`MOUSE_FINGER`).
# - Red de seguridad: un clic sin marca que cae muy cerca, en tiempo y en lugar, de un toque es su duplicado.
# Lógica pura (P10): no mira la plataforma ni la escena.

## Índice con el que el mouse real hace de dedo en `TouchGesture`.
const MOUSE_FINGER: int = -1

var _window_ms: int = 500
var _radius_px: float = 32.0
var _has_touch: bool = false
var _last_touch_pos: Vector2 = Vector2.ZERO
var _last_touch_ms: int = 0


func configure(window_ms: int, radius_px: float) -> void:
	_window_ms = window_ms
	_radius_px = radius_px


## Un toque real apoyó o se soltó en `pos`.
func note_touch(pos: Vector2, now_ms: int) -> void:
	_has_touch = true
	_last_touch_pos = pos
	_last_touch_ms = now_ms


## ¿Este clic o movimiento de mouse es un mouse de verdad y no el eco de un toque?
func accepts_mouse(device: int, pos: Vector2, now_ms: int) -> bool:
	if device == InputEvent.DEVICE_ID_EMULATION:
		return false
	if _has_touch and now_ms - _last_touch_ms <= _window_ms and pos.distance_to(_last_touch_pos) <= _radius_px:
		return false
	return true
