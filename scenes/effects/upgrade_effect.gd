# Efecto de mejora de una torre (M65, RF-590, D-135): un anillo de luz que sube desde la base y chispas.
# Nivel 2 «refuerzo» (chico) y nivel 3 «maestría» (más grande: doble anillo, destello en cruz y chispas en abanico).
# Es solo visual: se tiñe con el color de la torre, no toca la torre y se borra solo.
#
# ARTE PROVISIONAL (T363): se dibuja con `_draw`. Cuando Lucas apruebe los atlas de T362, T364 cambia solo
# `_draw` por un `Sprite2D` con la región del atlas; el comportamiento (un Tween, sin `_process`) no cambia.
# Sin `_process`: el único trabajo por cuadro es el del Tween mientras dura (sin animación, costo cero).
class_name UpgradeEffect
extends Node2D

const SPARKS_REFUERZO: int = 6
const SPARKS_MAESTRIA: int = 10

var _color: Color = Color.WHITE
var _radius: float = 32.0
var _duration: float = 0.5
var _is_mastery: bool = false
var _tween: Tween

## 0 a 1. El Tween lo mueve; cada cambio pide redibujar.
var progress: float = 0.0:
	set(value):
		progress = value
		queue_redraw()


## `color` es el de la torre (`TowerVisual.upgrade_glow_color`); `radius` ya incluye la escala de la variante
## y el tamaño (`footprint`) de la torre.
func setup(color: Color, radius: float, duration: float, is_mastery: bool) -> UpgradeEffect:
	_color = color
	_radius = radius
	_duration = maxf(duration, 0.01)
	_is_mastery = is_mastery
	return self


func is_mastery() -> bool:
	return _is_mastery


func radius() -> float:
	return _radius


func duration() -> float:
	return _duration


func _ready() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "progress", 1.0, _duration)
	_tween.finished.connect(queue_free)


func _draw() -> void:
	var t: float = progress
	var rise: float = 1.0 - pow(1.0 - t, 3.0)
	var fade: float = 1.0 - t * t
	var light: Color = _color.lerp(Color.WHITE, 0.45)
	# Resplandor suave del color de la torre debajo del anillo (que el efecto se note aunque sea breve).
	draw_circle(Vector2(0, -_radius * 0.15 * rise), _radius * (0.45 + 0.4 * rise), Color(_color, 0.22 * fade))
	# Anillo que sube desde la base: aplastado (perspectiva) y cada vez más arriba.
	_ring(Vector2(0, _radius * (0.35 - 0.7 * rise)), _radius * (0.45 + 0.55 * rise), Color(light, fade), 3.0)
	if _is_mastery:
		_ring(Vector2(0, _radius * (0.5 - 0.9 * rise)), _radius * (0.3 + 0.5 * rise), Color(_color, fade * 0.9), 2.0)
		# Destello en cruz: aparece enseguida y se achica.
		var flash: float = maxf(0.0, 1.0 - t * 2.5)
		if flash > 0.0:
			var arm: float = _radius * (0.4 + 0.8 * flash)
			var flash_color := Color(1, 1, 1, flash)
			draw_line(Vector2(-arm, 0), Vector2(arm, 0), flash_color, 3.0)
			draw_line(Vector2(0, -arm), Vector2(0, arm), flash_color, 3.0)
	_sparks(rise, fade, light)


func _ring(center: Vector2, ring_radius: float, color: Color, width: float) -> void:
	# Elipse: el aplastado vertical da la sensación de un anillo en el suelo.
	var points := PackedVector2Array()
	for step: int in range(25):
		var angle: float = TAU * float(step) / 24.0
		points.append(center + Vector2(cos(angle) * ring_radius, sin(angle) * ring_radius * 0.5))
	draw_polyline(points, color, width)


func _sparks(rise: float, fade: float, light: Color) -> void:
	var count: int = SPARKS_MAESTRIA if _is_mastery else SPARKS_REFUERZO
	var spread: float = 1.1 if _is_mastery else 0.6  # la maestría sale en abanico
	for index: int in range(count):
		var ratio: float = float(index) / float(count - 1) - 0.5
		var angle: float = -PI / 2.0 + ratio * spread * PI
		var distance: float = _radius * (0.3 + 0.9 * rise) * (0.8 + 0.2 * float((index * 7) % 3))
		draw_circle(Vector2.from_angle(angle) * distance, 2.5 * (1.0 - 0.5 * rise), Color(light, fade))
