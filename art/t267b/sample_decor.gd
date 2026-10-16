# Sustitución visual exclusiva de la revisión; no cambia el estado jugable.
extends LevelDecor

var review_state: int = 0
const MINE: Array[Texture2D] = [preload("res://art/t267b/sprites/mine_idle.png"), preload("res://art/t267b/sprites/mine_active.png"), preload("res://art/t267b/sprites/mine_depleted.png")]
const FOREST: Array[Texture2D] = [preload("res://art/t267b/sprites/forest_idle.png"), preload("res://art/t267b/sprites/forest_active.png"), preload("res://art/t267b/sprites/forest_depleted.png")]
const RUBBLE: Array[Texture2D] = [preload("res://art/t267b/sprites/rubble_idle.png"), preload("res://art/t267b/sprites/rubble_working.png")]
const STATUES: Array[Texture2D] = [preload("res://art/t267b/sprites/statue_cannon_moss.png"), preload("res://art/t267b/sprites/statue_sniper_moss.png"), preload("res://art/t267b/sprites/statue_basic_moss.png")]
const CENTRAL: Dictionary = {
	"central_1": preload("res://art/t267b/sprites/central_1.png"),
	"central_2": preload("res://art/t267b/sprites/central_2.png"),
	"central_3": preload("res://art/t267b/sprites/central_3.png"),
	"central_4": preload("res://art/t267b/sprites/central_4.png"),
}

func _draw_legend(cell: Vector2i, origin: Vector2, rng: RandomNumberGenerator, drawing: String) -> void:
	if frost_preview:
		super._draw_legend(cell, origin, rng, drawing)
		return
	var texture: Texture2D
	match drawing:
		"mina": texture = MINE[review_state]
		"bosque_explotable": texture = FOREST[review_state]
		"escombro": texture = RUBBLE[mini(review_state, 1)]
		"estatua": texture = STATUES[review_state]
		_: texture = CENTRAL.get(drawing)
	if texture == null:
		super._draw_legend(cell, origin, rng, drawing)
		return
	_draw_ground(origin, rng)
	draw_texture_rect(texture, Rect2(origin, Vector2.ONE * Rules.TILE_SIZE), false)
	if _removable_cells.has(cell):
		_draw_removable_mark(origin, Rules.TILE_SIZE)

# Muestrario explícito sobre nieve: el nivel 13 no contiene estatuas en sus datos.
var frost_preview: bool = false
const FROST: Array[Texture2D] = [preload("res://art/t267b/sprites/statue_cannon_frost.png"), preload("res://art/t267b/sprites/statue_sniper_frost.png"), preload("res://art/t267b/sprites/statue_basic_frost.png")]

func _draw() -> void:
	super._draw()
	if not frost_preview:
		return
	var chosen: Array[Vector2i] = []
	for cell: Vector2i in _ground.get_used_cells():
		if _ground.get_cell_atlas_coords(cell) != Level.ATLAS_BLOCKED or _legend_cells.has(cell) or cell.y < 2:
			continue
		var separated: bool = true
		for other: Vector2i in chosen:
			if cell.distance_to(other) < 3.0:
				separated = false
		if not separated:
			continue
		chosen.append(cell)
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(cell)
		var origin: Vector2 = Vector2(cell) * Rules.TILE_SIZE
		_draw_ground(origin, rng)
		draw_texture_rect(FROST[chosen.size() - 1], Rect2(origin, Vector2.ONE * Rules.TILE_SIZE), false)
		if chosen.size() == 3:
			break
