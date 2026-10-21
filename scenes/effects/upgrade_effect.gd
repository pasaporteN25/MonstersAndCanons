# Efecto de mejora de una torre (M65, RF-590, RF-625, D-135, D-165): el atlas aprobado en T362 sobre el mecanismo.
# Nivel 2 «refuerzo» (0,5 s) y nivel 3 «maestría» (0,7 s, más grande y lleno): 8 cuadros de 192 × 192 px, centro en
# (96, 96), claros y neutros; se importan al 50 % con escala compensada (RF-643).
# El juego los tiñe con el color de la torre (`modulate`, mezcla normal).
# Es solo visual: no toca la torre y se borra solo. Sin `_process`: un Tween mueve `progress` y el cuadro sale de él.
class_name UpgradeEffect
extends Node2D

const ATLAS_REFUERZO: Texture2D = preload("res://assets/sprites/effects/mejora/upgrade_l2.png")
const ATLAS_MAESTRIA: Texture2D = preload("res://assets/sprites/effects/mejora/upgrade_l3.png")
const COLUMNS: int = 4
const ROWS: int = 2
const FRAMES: int = COLUMNS * ROWS

var _color: Color = Color.WHITE
var _radius: float = 32.0
var _duration: float = 0.5
var _is_mastery: bool = false
var _art_scale: float = 1.0
var _sprite: Sprite2D
var _tween: Tween

## 0 a 1. El Tween lo mueve; cada cambio elige el cuadro del atlas.
var progress: float = 0.0:
	set(value):
		progress = value
		_show_frame()


## `color` es el de la torre (`TowerVisual.upgrade_glow_color`); `radius` ya incluye la escala de la variante
## y el tamaño (`footprint`) de la torre; `art_scale` es el `footprint` (el atlas se ve a 1:1 en una torre de 1 × 1).
func setup(color: Color, radius: float, duration: float, is_mastery: bool, art_scale: float = 1.0) -> UpgradeEffect:
	_color = color
	_radius = radius
	_duration = maxf(duration, 0.01)
	_is_mastery = is_mastery
	_art_scale = maxf(art_scale, 0.1)
	return self


func is_mastery() -> bool:
	return _is_mastery


func radius() -> float:
	return _radius


func duration() -> float:
	return _duration


## El cuadro (0 a 7) que se está mostrando.
func frame() -> int:
	return _sprite.frame if _sprite != null else 0


func art_scale() -> float:
	return _art_scale


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = ATLAS_MAESTRIA if _is_mastery else ATLAS_REFUERZO
	_sprite.hframes = COLUMNS
	_sprite.vframes = ROWS
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # sin mipmaps (RF-628)
	_sprite.scale = Vector2.ONE * _art_scale * 2.0  # RF-643: compensa la importación al 50 %
	_sprite.modulate = _color
	add_child(_sprite)
	_show_frame()
	_tween = create_tween()
	_tween.tween_property(self, "progress", 1.0, _duration)
	_tween.finished.connect(queue_free)


func _show_frame() -> void:
	if _sprite != null:
		_sprite.frame = clampi(int(progress * float(FRAMES)), 0, FRAMES - 1)
