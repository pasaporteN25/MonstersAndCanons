# Ícono chico de un tipo de enemigo: su dibujo y, si se indica, cuántos vienen ("×8").
# Se usa en "Próxima oleada" (RF-133) y en la presentación de enemigos (RF-134).
class_name EnemyIcon
extends Control

const RADIUS: float = 12.0
const FONT_SIZE: int = 15
## Con número, el número va DEBAJO del dibujo: así entran 4 tipos en una fila
## (el máximo de una oleada) en el espacio de "Próxima oleada".
const SIZE_WITH_COUNT := Vector2(40, 52)
const SIZE_ALONE := Vector2(30, 36)

var enemy: EnemyData
## Cuántos vienen. 0 = no mostrar el número.
var count: int = 0
var uncertain: bool = false


func setup(enemy_data: EnemyData, enemy_count: int = 0) -> EnemyIcon:
	enemy = enemy_data
	count = enemy_count
	custom_minimum_size = SIZE_WITH_COUNT if count > 0 else SIZE_ALONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	tooltip_text = enemy.display_name
	return self


func _draw() -> void:
	if enemy == null:
		return
	var center := Vector2(size.x / 2.0, 20.0 if count > 0 else size.y / 2.0 + 2.0)
	draw_set_transform(center)
	var top: float = RADIUS
	if enemy.texture != null:
		EnemyShape.draw_sprite(self, enemy.texture, RADIUS)  # RF-155
		top = EnemyShape.sprite_top(RADIUS)
	else:
		EnemyShape.draw(self, enemy.shape, RADIUS, enemy.color, enemy.color.darkened(0.45))
	if Rules.is_dangerous(enemy):
		EnemyShape.draw_crown(self, Vector2(0, -top + 1.0), RADIUS * 1.1)  # RF-136
	draw_set_transform(Vector2.ZERO)
	if count > 0:
		draw_string(ThemeDB.fallback_font, Vector2(0, size.y - 2.0), ("≤%d?" if uncertain else "×%d") % count,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, FONT_SIZE, Color(1, 1, 1, 0.9))
