# Sustitución visual exclusiva de esta escena de revisión; no se conecta al juego.
extends LevelDecor

const SAMPLES: Dictionary = {
	"mina": preload("res://art/t267a/samples/mina.svg"),
	"bosque_explotable": preload("res://art/t267a/samples/bosque_explotable.svg"),
	"escombro": preload("res://art/t267a/samples/escombro.svg"),
	"estatua": preload("res://art/t267a/samples/estatua.svg"),
	"central_1": preload("res://art/t267a/samples/central_1.svg"),
	"central_2": preload("res://art/t267a/samples/central_2.svg"),
	"central_3": preload("res://art/t267a/samples/central_3.svg"),
	"central_4": preload("res://art/t267a/samples/central_4.svg"),
}

func _draw_legend(cell: Vector2i, origin: Vector2, rng: RandomNumberGenerator, drawing: String) -> void:
	if not SAMPLES.has(drawing):
		super._draw_legend(cell, origin, rng, drawing)
		return
	_draw_ground(origin, rng)
	draw_texture_rect(SAMPLES[drawing], Rect2(origin, Vector2.ONE * Rules.TILE_SIZE), false)
	if _removable_cells.has(cell):
		_draw_removable_mark(origin, Rules.TILE_SIZE)
