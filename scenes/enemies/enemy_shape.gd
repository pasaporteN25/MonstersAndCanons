# Dibujo de las formas de los enemigos (D-002), compartido entre el enemigo en el mapa
# y los íconos de la interfaz (próxima oleada, presentación de enemigos, RF-133 y RF-134).
# Dibuja centrado en (0, 0) del `canvas`; quien llama decide la posición, el giro y la escala
# con draw_set_transform().
class_name EnemyShape
extends RefCounted

const CROWN_COLOR := Color(1.0, 0.84, 0.3)


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
