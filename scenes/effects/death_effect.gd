# Residuo de la pose real, solo visual: ninguna referencia al enemigo ya eliminado.
class_name DeathEffect
extends Node2D

const DURATION: float = 0.48
const SHADER: Shader = preload("res://assets/shaders/enemy_dissolve.gdshader")
var _time: float = 0.0
var _body: Sprite2D
var _material: ShaderMaterial

func setup(enemy: Enemy) -> DeathEffect:
	_body = Sprite2D.new()
	_body.texture = enemy.visual_texture()
	var region: Rect2 = enemy.visual_frame_region()
	var source_size: Vector2 = _body.texture.get_size()
	if region.has_area():
		_body.region_enabled = true
		_body.region_rect = region
		_body.region_filter_clip_enabled = true
		source_size = region.size
	var rect: Rect2 = EnemyShape.sprite_rect(Rules.tiles_to_px(enemy.data.size_tiles), enemy.visual_draw_scale())
	_body.position = rect.get_center()
	_body.scale = rect.size / source_size
	_body.flip_h = enemy.is_drawn_mirrored()
	_body.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("ember", enemy.data.color.lightened(0.4))
	_body.material = _material
	add_child(_body)
	return self

func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	_material.set_shader_parameter("progress", _time / DURATION)
