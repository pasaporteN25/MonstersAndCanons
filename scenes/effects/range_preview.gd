# Ampliación del alcance de una torre (M75, RF-680 a RF-682, D-195): el círculo del nivel siguiente.
# Tiene dos formas:
# - Vista previa («Mejorar» con el mouse encima en la PC, primer toque en el celular): crece del alcance actual al
#   nuevo y se queda hasta que quien la pidió la saca.
# - Efecto de mejora: el círculo con el alcance ya mejorado, que se desvanece y se borra solo.
# Con `animated` en false (casilla «Animaciones de mejora» apagada) la vista previa sale quieta, ya en el radio nuevo.
# Es solo visual: no toca la torre. Sin `_process`: un Tween mueve `progress` y `_draw` hace el resto. El Tween
# está atado al nodo, así que respeta la pausa y la velocidad del juego (M36).
class_name RangePreview
extends Node2D

var _from_radius: float = 0.0
var _to_radius: float = 0.0
var _duration: float = 0.5
var _animated: bool = true
var _fades_out: bool = false
var _config: RangeDisplayConfig
var _tween: Tween

## 0 a 1. El Tween lo mueve; cada cambio redibuja.
var progress: float = 0.0:
	set(value):
		progress = value
		queue_redraw()


## `from_radius` y `to_radius` en píxeles. `fades_out` es la forma de efecto de mejora (se desvanece y se borra).
func setup(from_radius: float, to_radius: float, duration: float, animated: bool, fades_out: bool = false) -> RangePreview:
	_from_radius = maxf(from_radius, 0.0)
	_to_radius = maxf(to_radius, 0.0)
	_duration = maxf(duration, 0.01)
	_animated = animated
	_fades_out = fades_out
	return self


func is_animated() -> bool:
	return _animated


func fades_out() -> bool:
	return _fades_out


func duration() -> float:
	return _duration


## El radio que se dibuja con ese avance: sin animar, o en la forma de efecto, siempre el nuevo.
func radius_at(amount: float) -> float:
	if not _animated or _fades_out:
		return _to_radius
	var eased: float = 1.0 - pow(1.0 - clampf(amount, 0.0, 1.0), 2.0)
	return lerpf(_from_radius, _to_radius, eased)


## La opacidad (0 a 1) que se dibuja con ese avance: solo el efecto de mejora se desvanece.
func alpha_at(amount: float) -> float:
	if not _animated or not _fades_out:
		return 1.0
	return 1.0 - clampf(amount, 0.0, 1.0)


func current_radius() -> float:
	return radius_at(progress)


func _ready() -> void:
	if not _animated:
		progress = 1.0
		return
	_tween = create_tween()
	_tween.tween_property(self, "progress", 1.0, _duration)
	if _fades_out:
		_tween.finished.connect(queue_free)


func _draw() -> void:
	var radius: float = radius_at(progress)
	if radius <= 0.0:
		return
	if _config == null:
		_config = RangeDisplayConfig.runtime_config()
	var color: Color = BuildController.range_color(_config)
	var alpha: float = alpha_at(progress)
	# Mismo dibujo que el valor «Completo» de la opción de alcance (RF-678), porque la ampliación se ve con cualquier valor.
	draw_circle(Vector2.ZERO, radius, Color(color, _config.get_value("completo", "opacidad_relleno") * alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64,
		Color(color, _config.get_value("completo", "opacidad_borde") * alpha),
		_config.get_value("completo", "grosor_borde_px"))
