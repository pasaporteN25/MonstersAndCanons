# El dibujo de una entrada de la wiki: sus capas de textura, de atrás para adelante, ocupando todo
# el espacio (los dibujos del juego son cuadrados). Una torre son dos capas: base y torreta.
class_name WikiIcon
extends Control

var layers: Array[Texture2D] = []
## Se dibuja todo negro (entrada cerrada del bestiario, RF-239).
var silhouette: bool = false


func setup(textures: Array[Texture2D], icon_size: float, as_silhouette: bool = false) -> WikiIcon:
	layers = textures
	silhouette = as_silhouette
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	return self


func _draw() -> void:
	for texture: Texture2D in layers:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false, Color(0, 0, 0, 0.85) if silhouette else Color.WHITE)
