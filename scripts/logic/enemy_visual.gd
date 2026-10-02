# Cuadros de movimiento reales: no deforma ni refleja la luz del monstruo.
class_name EnemyVisual
extends RefCounted

const FRAME_SIZE: int = 256
const STEP_COUNT: int = 4

## Cotas por pose calculadas una sola vez. Las barras siguen la cabeza, no el margen del atlas.
static func body_bounds(texture: Texture2D, region: Rect2) -> Rect2i:
	const META: StringName = &"pose_body_bounds"
	var bounds: Dictionary = texture.get_meta(META, {})
	var key: Vector2 = region.position
	if not bounds.has(key):
		var image: Image = texture.get_image()
		image.decompress()
		image.clear_mipmaps()
		bounds[key] = image.get_region(Rect2i(region)).get_used_rect()
		texture.set_meta(META, bounds)
	return bounds[key]

static func walk_frame(distance_px: float, stride_px: float) -> int:
	if stride_px <= 0.0:
		return 0
	return posmod(floori(distance_px / stride_px * STEP_COUNT), STEP_COUNT)

## Filas: derecha, abajo, izquierda, arriba. La luz está pintada en cada vista.
static func direction_row(angle: float) -> int:
	return posmod(roundi(wrapf(angle, 0.0, TAU) / (PI / 2.0)), 4)

static func walk_region(distance_px: float, stride_px: float, angle: float) -> Rect2:
	return Rect2(Vector2(walk_frame(distance_px, stride_px), direction_row(angle)) * FRAME_SIZE,
		Vector2.ONE * FRAME_SIZE)

static func flight_region(time: float, frame_seconds: float) -> Rect2:
	var index: int = posmod(floori(time / maxf(frame_seconds, 0.001)), STEP_COUNT)
	return Rect2(Vector2(index % 2, index / 2) * FRAME_SIZE, Vector2.ONE * FRAME_SIZE)
