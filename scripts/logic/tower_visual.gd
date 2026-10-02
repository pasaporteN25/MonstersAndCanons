# Selección de vistas renderizadas. No depende de escenas ni de reglas de combate.
class_name TowerVisual
extends RefCounted

const DIRECTION_COUNT: int = 8
const ATLAS_COLUMNS: int = 4
const ATLAS_ROWS: int = 2
## RF-340: encastre C, en píxeles del lienzo lógico (sprite128 dibujado a64).
const MOUNT_OFFSET := Vector2(0, -12)

static func mounted_rect(tile_rect: Rect2, factor: float, recoil: Vector2 = Vector2.ZERO) -> Rect2:
	return Rect2(tile_rect.position + MOUNT_OFFSET * factor - recoil, tile_rect.size)

## Mismo encastre en los iconos; espacio adicional para no cortar el arma mirando arriba.
static func mounted_icon(base_texture: Texture2D, turret_texture: Texture2D) -> Texture2D:
	if base_texture == null or turret_texture == null:
		return null
	var base: Image = base_texture.get_image().duplicate()
	var turret: Image = turret_texture.get_image().duplicate()
	for image: Image in [base, turret]:
		image.decompress()
		image.clear_mipmaps()
		image.convert(Image.FORMAT_RGBA8)
	var composite: Image = Image.create(160, 160, false, Image.FORMAT_RGBA8)
	composite.blend_rect(base, Rect2i(Vector2i.ZERO, base.get_size()), Vector2i(16, 28))
	composite.blend_rect(turret, Rect2i(Vector2i.ZERO, turret.get_size()), Vector2i(16, 28) + Vector2i(MOUNT_OFFSET * 2))
	composite.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	composite.generate_mipmaps()
	return ImageTexture.create_from_image(composite)

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
