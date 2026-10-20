# El destello de la entrada de un jefe (M66, RF-597): polvo, un resplandor teñido con el color del enemigo y una
# grieta en el suelo, en la entrada del camino. Dura 0,7 s y no hace nada más (RF-598).
#
# Arte PROVISIONAL dibujado con `_draw` (T368). Cuando Lucas apruebe el arte de T367, T369 lo reemplaza por un
# `Sprite2D` con el atlas sin cambiar el comportamiento. Sin `_process`: un `Tween` mueve `progress` y se
# congela con la pausa y acompaña la velocidad, como el resto de los efectos del mundo.
class_name BossEntranceBurst
extends Node2D

const GLOW_RADIUS: float = 64.0
const CRACK_LENGTH: float = 58.0
const DUST_COUNT: int = 10

var _color: Color = Color.WHITE
var _duration: float = 0.7
## 0 al nacer, 1 al terminar.
var progress: float = 0.0:
	set(value):
		progress = value
		queue_redraw()
## Direcciones fijas de las ramas de la grieta y del polvo (no cambian cuadro a cuadro).
var _cracks: Array[Vector2] = []


func setup(color: Color, duration: float) -> BossEntranceBurst:
	_color = color
	process_mode = Node.PROCESS_MODE_PAUSABLE  # la partida corre en pausa (RF-104), pero el destello se congela
	_duration = maxf(duration, 0.05)
	for i: int in 6:
		var angle: float = TAU * float(i) / 6.0 + 0.35 * float(i % 2)
		_cracks.append(Vector2(cos(angle), sin(angle)))
	return self


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress", 1.0, _duration)
	tween.finished.connect(queue_free)


func _draw() -> void:
	var t: float = clampf(progress, 0.0, 1.0)
	var fade: float = 1.0 - t
	# La grieta: queda en el suelo casi todo el destello y se apaga al final.
	var crack_alpha: float = clampf((1.0 - t) * 1.6, 0.0, 1.0)
	var grow: float = clampf(t * 3.0, 0.0, 1.0)
	for dir: Vector2 in _cracks:
		var tip: Vector2 = dir * CRACK_LENGTH * grow
		draw_line(Vector2.ZERO, tip, Color(0.05, 0.03, 0.03, crack_alpha), 4.0)
		draw_line(Vector2.ZERO, tip, Color(_color.lightened(0.3), crack_alpha * 0.7), 1.5)
	# El resplandor: un círculo que crece y se apaga, teñido con el color del enemigo.
	var glow_radius: float = GLOW_RADIUS * (0.4 + 0.6 * (1.0 - pow(fade, 3.0)))
	draw_circle(Vector2.ZERO, glow_radius, Color(_color, 0.35 * fade))
	draw_arc(Vector2.ZERO, glow_radius, 0.0, TAU, 40, Color(_color.lightened(0.45), 0.9 * fade), 3.0)
	# El polvo: motas que salen hacia afuera y suben un poco.
	for i: int in DUST_COUNT:
		var angle: float = TAU * float(i) / float(DUST_COUNT) + 0.2
		var distance: float = (18.0 + 46.0 * (1.0 - pow(fade, 2.0))) * (0.8 + 0.1 * float(i % 3))
		var mote: Vector2 = Vector2(cos(angle), sin(angle) * 0.6) * distance + Vector2(0.0, -14.0 * t)
		draw_circle(mote, 4.0 + 3.0 * t, Color(0.78, 0.7, 0.58, 0.55 * fade))
