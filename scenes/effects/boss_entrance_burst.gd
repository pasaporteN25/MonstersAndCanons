# El destello de la entrada de un jefe (M66, RF-597, RF-626, D-138, D-165): el atlas aprobado en T367 (aro, luz que
# sube, polvo y esquirlas, 8 cuadros de 256 × 256 px) teñido con el color del enemigo, sobre la grieta del suelo
# (192 × 96, sin teñir) que se apaga en los mismos 0,7 s. El origen del nodo es el punto de los pies del jefe: la
# entrada del camino. No hace nada más (RF-598).
#
# Sin `_process`: un `Tween` mueve `progress` y se congela con la pausa y acompaña la velocidad, como el resto
# de los efectos del mundo.
class_name BossEntranceBurst
extends Node2D

const ATLAS: Texture2D = preload("res://assets/sprites/effects/jefe/boss_burst.png")
const CRACK: Texture2D = preload("res://assets/sprites/effects/jefe/boss_crack.png")
const COLUMNS: int = 4
const ROWS: int = 2
const FRAMES: int = COLUMNS * ROWS
## Punto de los pies del jefe dentro de cada cuadro de 256 × 256.
const FEET: Vector2 = Vector2(128, 176)

var _color: Color = Color.WHITE
var _duration: float = 0.7
var _burst: Sprite2D
var _crack: Sprite2D
## 0 al nacer, 1 al terminar.
var progress: float = 0.0:
	set(value):
		progress = value
		_update()


func setup(color: Color, duration: float) -> BossEntranceBurst:
	_color = color
	process_mode = Node.PROCESS_MODE_PAUSABLE  # la partida corre en pausa (RF-104), pero el destello se congela
	_duration = maxf(duration, 0.05)
	return self


## El cuadro (0 a 7) del destello que se está mostrando.
func frame() -> int:
	return _burst.frame if _burst != null else 0


## La transparencia de la grieta (1 al nacer, 0 al terminar).
func crack_alpha() -> float:
	return _crack.modulate.a if _crack != null else 0.0


func _ready() -> void:
	# La grieta primero: queda debajo del destello.
	_crack = Sprite2D.new()
	_crack.texture = CRACK
	_crack.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # sin mipmaps (RF-628)
	add_child(_crack)
	_burst = Sprite2D.new()
	_burst.texture = ATLAS
	_burst.hframes = COLUMNS
	_burst.vframes = ROWS
	_burst.centered = false
	_burst.offset = -FEET
	_burst.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_burst.modulate = _color
	add_child(_burst)
	_update()
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress", 1.0, _duration)
	tween.finished.connect(queue_free)


func _update() -> void:
	if _burst == null:
		return
	var t: float = clampf(progress, 0.0, 1.0)
	_burst.frame = clampi(int(t * float(FRAMES)), 0, FRAMES - 1)
	_crack.modulate.a = 1.0 - t
