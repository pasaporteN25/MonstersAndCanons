class_name EmptyCellDoubleTap
extends RefCounted
# T573 (RF-740, D-227): decide si dos toques o clics seguidos son un «doble toque» sobre una casilla vacía.
# Es pura: no sabe de escenas ni de torres. Quien la usa le dice, en cada toque, si la casilla es elegible
# (pasto construible, sin torre ni objeto, sin fantasma ni herramienta, sin pausa, modal ni partida terminada).
# Un toque no elegible olvida el anterior, así que el segundo toque nunca "hereda" un primero inválido.
# Sirve para la PC y para el celular: solo cambia qué hace quien la escucha.

const NO_CELL: Vector2i = Vector2i(-1000, -1000)

var _last_cell: Vector2i = NO_CELL
var _last_ms: int = -1000000


## `true` si este toque completa un doble toque: misma casilla que el toque elegible anterior y dentro de `window_ms`.
## Al completarse, la memoria se vacía (un tercer toque no cuenta como otro doble).
func register(cell: Vector2i, eligible: bool, time_ms: int, window_ms: int) -> bool:
	if not eligible:
		reset()
		return false
	var matched: bool = _last_cell == cell and time_ms - _last_ms < window_ms
	_last_cell = NO_CELL if matched else cell
	_last_ms = -1000000 if matched else time_ms
	return matched


func reset() -> void:
	_last_cell = NO_CELL
	_last_ms = -1000000
