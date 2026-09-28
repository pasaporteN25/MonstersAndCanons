# Ícono chico de un tipo de enemigo: su forma y, si se indica, cuántos vienen ("×8").
# Se usa en "Próxima oleada" (RF-133) y en la presentación de enemigos (RF-134).
class_name EnemyIcon
extends Control

const RADIUS: float = 12.0
const FONT_SIZE: int = 16

var enemy: EnemyData
## Cuántos vienen. 0 = no mostrar el número.
var count: int = 0


func setup(enemy_data: EnemyData, enemy_count: int = 0) -> EnemyIcon:
	enemy = enemy_data
	count = enemy_count
	custom_minimum_size = Vector2(58 if count > 0 else 30, 36)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_text = enemy.display_name
	return self


func _draw() -> void:
	if enemy == null:
		return
	var center := Vector2(15, size.y / 2.0 + 2.0)
	draw_set_transform(center)
	EnemyShape.draw(self, enemy.shape, RADIUS, enemy.color, enemy.color.darkened(0.45))
	if Rules.is_dangerous(enemy):
		EnemyShape.draw_crown(self, Vector2(0, -RADIUS - 1.0), RADIUS * 1.1)  # RF-136
	draw_set_transform(Vector2.ZERO)
	if count > 0:
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(30, center.y + 6.0), "×%d" % count, HORIZONTAL_ALIGNMENT_LEFT, -1,
			FONT_SIZE, Color(1, 1, 1, 0.9))
