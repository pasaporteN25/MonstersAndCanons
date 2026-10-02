# Selección de vistas renderizadas. No depende de escenas ni de reglas de combate.
class_name TowerVisual
extends RefCounted

const DIRECTION_COUNT: int = 8
const ATLAS_COLUMNS: int = 4
const ATLAS_ROWS: int = 2

## Derecha = 0. Los ángulos de Godot crecen hacia abajo en pantalla.
static func direction_index(angle: float) -> int:
	return posmod(roundi(wrapf(angle, 0.0, TAU) / TAU * DIRECTION_COUNT), DIRECTION_COUNT)

static func frame_rect(texture: Texture2D, angle: float) -> Rect2:
	if texture == null:
		return Rect2()
	var size_: Vector2 = texture.get_size() / Vector2(ATLAS_COLUMNS, ATLAS_ROWS)
	var index: int = direction_index(angle)
	return Rect2(Vector2(index % ATLAS_COLUMNS, index / ATLAS_COLUMNS) * size_, size_)

static func frame_texture(texture: Texture2D, angle: float) -> AtlasTexture:
	if texture == null:
		return null
	var frame := AtlasTexture.new()
	frame.atlas = texture
	frame.region = frame_rect(texture, angle)
	frame.filter_clip = true
	return frame
