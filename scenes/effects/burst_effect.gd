# Estallido de partículas al morir un enemigo (RF-124).
# Se dibuja a mano (sin CPUParticles2D) para que respete la pausa y la velocidad x2
# igual que el resto del juego, y sea fácil de testear. Se borra solo al terminar.
class_name BurstEffect
extends Node2D

const PARTICLE_COUNT: int = 8
var _facet := PackedVector2Array([Vector2(-1, 0), Vector2(0, -0.6), Vector2(1, 0.2), Vector2(0, 1)])
var _light_facet := PackedVector2Array([Vector2(-1, 0), Vector2(0, -0.6), Vector2(0.1, 0.1)])
const DURATION: float = 0.55
const DRAG: float = 4.0  # cuánto frenan las partículas por segundo

var _color: Color = Color.WHITE
var _time: float = 0.0
var _offsets: Array[Vector2] = []
var _velocities: Array[Vector2] = []
var _sizes: Array[float] = []


func setup(color: Color, radius: float) -> BurstEffect:
	_color = color
	for i: int in PARTICLE_COUNT:
		var angle: float = TAU * i / PARTICLE_COUNT + randf_range(-0.3, 0.3)
		_offsets.append(Vector2.from_angle(angle) * radius * 0.5)
		_velocities.append(Vector2.from_angle(angle) * randf_range(35.0, 80.0))
		_sizes.append(randf_range(2.0, 4.0))
	return self


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	for i: int in _offsets.size():
		_offsets[i] += _velocities[i] * delta
		_velocities[i] *= maxf(0.0, 1.0 - DRAG * delta)
	queue_redraw()


func _draw() -> void:
	var t: float = _time / DURATION
	var color := Color(_color.lightened(0.2), 1.0 - t)
	for i: int in _offsets.size():
		var size: float = _sizes[i] * (1.0 - t * 0.6)
		var p: Vector2 = _offsets[i]
		draw_set_transform(p, 0.0, Vector2.ONE * size)
		draw_colored_polygon(_facet, color)
		draw_colored_polygon(_light_facet, Color(_color.lightened(0.65), (1.0 - t) * 0.8))
	draw_set_transform(Vector2.ZERO)
