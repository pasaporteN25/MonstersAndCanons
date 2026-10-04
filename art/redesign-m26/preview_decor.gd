# Decoración de muestra sobre la grilla real. No modifica LevelDecor ni TileSet.
extends Node2D

var ground: TileMapLayer
var theme: String = "pradera"
var textures: Dictionary = {}
var props: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for name_: String in ["ground_" + theme, "path"]:
		var image: Image = Image.load_from_file("res://art/redesign-m26/textures/" + name_ + ".png")
		image.generate_mipmaps()
		textures[name_] = ImageTexture.create_from_image(image)
	for name_: String in ["rock_a", "rock_b", "tree", "bush", "gate"]:
		var image: Image = Image.load_from_file("res://art/redesign-m26/props/" + name_ + ".png")
		image.generate_mipmaps()
		props[name_] = ImageTexture.create_from_image(image)
	queue_redraw()

func _draw() -> void:
	if ground == null:
		return
	for cell: Vector2i in ground.get_used_cells():
		var tile: Vector2i = ground.get_cell_atlas_coords(cell)
		var origin: Vector2 = Vector2(cell) * 64.0
		var path: bool = tile == Vector2i(1, 0)
		draw_texture_rect(textures["path" if path else "ground_" + theme], Rect2(origin, Vector2(64, 64)), false)
		if path:
			_draw_edges(cell, origin)
		else:
			# El selector de construcción puede superponer su grilla sin fijarla al arte.
			if tile == Vector2i(2, 0):
				var names: Array[String] = ["rock_a", "rock_b", "tree", "rock_a", "bush", "rock_b"]
				var name_: String = names[posmod(hash(cell), names.size())]
				draw_texture_rect(props[name_], Rect2(origin, Vector2(64, 64)), false)

func _draw_edges(cell: Vector2i, origin: Vector2) -> void:
	for direction: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if ground.get_cell_atlas_coords(cell + direction) == Vector2i(1, 0) or ground.get_cell_source_id(cell + direction) < 0:
			continue
		var start: Vector2 = origin + Vector2(maxi(direction.x, 0), maxi(direction.y, 0)) * 64.0
		var along: Vector2 = Vector2(absi(direction.y), absi(direction.x))
		var inward: Vector2 = Vector2(-direction)
		# Dos líneas discretas conservan lectura del borde sin una cuadrícula dura.
		draw_line(start + inward * 1.5, start + along * 64.0 + inward * 1.5, Color(0.23, 0.20, 0.12, 0.32), 3.0)
		draw_line(start + inward * 4.0, start + along * 64.0 + inward * 4.0, Color(0.83, 0.76, 0.52, 0.18), 2.0)
