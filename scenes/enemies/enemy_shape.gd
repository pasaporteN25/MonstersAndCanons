# Dibujo de los enemigos, compartido entre el enemigo en el mapa y los íconos de la interfaz
# (próxima oleada, presentación de enemigos, RF-133 y RF-134): sus dibujos (RF-151) o,
# si no tienen, sus formas geométricas (D-002, RF-156).
# Dibuja centrado en (0, 0) del `canvas`; quien llama decide la posición, el giro y la escala
# con draw_set_transform().
class_name EnemyShape
extends RefCounted

const CROWN_COLOR := Color(1.0, 0.84, 0.3)
## RF-158: llamita del enemigo que se quema.
const FLAME: Texture2D = preload("res://assets/sprites/effects/rendered/flame.png")
## RF-151: lado del dibujo comparado con el radio del enemigo. Con 2.8, el cuerpo del dibujo
## (unas 20 de sus 64 unidades de radio) mide lo mismo que el círculo de antes.
const SPRITE_SCALE: float = 2.8

## RF-123: la silueta blanca ya armada se guarda como dato extra ("meta") del propio dibujo:
## así vive lo mismo que él y se libera junto con él al cerrar el juego.
const FLASH_META: StringName = &"flash_silhouette"


## Dibuja el sprite de un enemigo centrado en (0, 0). En los SVG el cuerpo está 2 unidades
## (de 64) por debajo del centro de la imagen: se sube un poco para que quede centrado.
static func draw_sprite(canvas: CanvasItem, texture: Texture2D, radius: float,
		modulate: Color = Color.WHITE, visual_scale: float = 1.0) -> void:
	canvas.draw_texture_rect(texture, sprite_rect(radius, visual_scale), false, modulate)

## La fila191 de los pies conserva su posición aunque cambie el tamaño visual.
static func sprite_rect(radius: float, visual_scale: float = 1.0) -> Rect2:
	var side: float = radius * SPRITE_SCALE * visual_scale
	var foot: float = radius * SPRITE_SCALE * (191.0 / 256.0 - 0.5 - 1.0 / 32.0)
	return Rect2(-side / 2.0, foot - side * 191.0 / 256.0, side, side)


## Distancia desde el centro hasta arriba del dibujo (orejas, cuernos): ahí va la corona.
static func sprite_top(radius: float, visual_scale: float = 1.0) -> float:
	return radius * SPRITE_SCALE * 0.42 * visual_scale + radius * SPRITE_SCALE * (191.0 / 256.0 - 0.5 - 1.0 / 32.0) * (visual_scale - 1.0)


## RF-123: silueta blanca del dibujo, para el parpadeo al recibir un golpe. Se arma la primera
## vez que se pide y se guarda. (Multiplicar el color por más de 1 no aclara con este renderizador.)
static func flash_texture(texture: Texture2D) -> Texture2D:
	if texture.has_meta(FLASH_META):
		return texture.get_meta(FLASH_META)
	var image: Image = texture.get_image().duplicate()  # copia: no tocar la del dibujo
	image.decompress()
	image.clear_mipmaps()
	image.convert(Image.FORMAT_RGBA8)
	# Operaciones nativas: contraste cero lleva RGB a gris uniforme y brillo triple a blanco.
	# Ambas conservan el alfa, sin recorrer el atlas entero en GDScript al primer golpe.
	var white: Image = image.duplicate()
	white.adjust_bcs(1.0, 0.0, 1.0)
	white.adjust_bcs(3.0, 1.0, 1.0)
	white.generate_mipmaps()
	var flash := ImageTexture.create_from_image(white)
	texture.set_meta(FLASH_META, flash)
	return flash




static func draw(canvas: CanvasItem, shape: EnemyData.Shape, radius: float, fill: Color,
		outline: Color) -> void:
	match shape:
		EnemyData.Shape.CIRCLE:
			canvas.draw_circle(Vector2.ZERO, radius, fill)
			canvas.draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, outline, 2.0)
		EnemyData.Shape.SQUARE:
			var rect := Rect2(-radius, -radius, radius * 2.0, radius * 2.0)
			canvas.draw_rect(rect, fill)
			canvas.draw_rect(rect, outline, false, 2.0)
		EnemyData.Shape.TRIANGLE:
			_draw_regular_polygon(canvas, 3, radius, fill, outline)
		EnemyData.Shape.DIAMOND:
			_draw_regular_polygon(canvas, 4, radius, fill, outline)
		EnemyData.Shape.HEXAGON:
			_draw_regular_polygon(canvas, 6, radius, fill, outline)


## RF-136: corona dorada de los enemigos peligrosos. `base` es el centro de su borde de abajo.
static func draw_crown(canvas: CanvasItem, base: Vector2, width: float) -> void:
	var h: float = width * 0.55
	var w: float = width / 2.0
	var points := PackedVector2Array([
		base + Vector2(-w, 0), base + Vector2(-w, -h), base + Vector2(-w * 0.5, -h * 0.45),
		base + Vector2(0, -h * 1.1), base + Vector2(w * 0.5, -h * 0.45), base + Vector2(w, -h),
		base + Vector2(w, 0),
	])
	canvas.draw_colored_polygon(points, CROWN_COLOR)
	points.append(points[0])
	canvas.draw_polyline(points, CROWN_COLOR.darkened(0.5), 1.5)


static func _draw_regular_polygon(canvas: CanvasItem, sides: int, radius: float, fill: Color,
		outline: Color) -> void:
	var points := PackedVector2Array()
	for i: int in sides:
		points.append(Vector2.from_angle(-PI / 2.0 + TAU * i / sides) * radius)
	canvas.draw_colored_polygon(points, fill)
	points.append(points[0])
	canvas.draw_polyline(points, outline, 2.0)


## RF-158: tres llamitas sobre el cuerpo, que titilan con el tiempo (`time`, en segundos).
## Son un dibujo y no polígonos: con 200 enemigos quemándose, triangular polígonos en cada
## cuadro bajaba el juego a 42 FPS (T85).
static func draw_flames(canvas: CanvasItem, radius: float, time: float) -> void:
	var spots: Array[Vector2] = [Vector2(-0.45, -0.1), Vector2(0.05, -0.5), Vector2(0.5, -0.05)]
	for i: int in spots.size():
		var base: Vector2 = spots[i] * radius
		var height: float = radius * (0.75 + 0.15 * sin(time * 17.0 + i * 2.1))
		var width: float = radius * 0.55
		canvas.draw_texture_rect(FLAME, Rect2(base.x - width / 2.0, base.y - height, width, height), false)
