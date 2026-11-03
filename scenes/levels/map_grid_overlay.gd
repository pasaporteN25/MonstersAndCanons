extends Node2D

const CONFIG_PATH: String = "res://data/ui/cuadricula.json"
const DEFAULT_OPACITY: float = 0.55
const DEFAULT_WIDTH: float = 1.0

var _grid: MapGrid
var _enabled: bool = false
var _line_color: Color = Color("e8e4c8")
var _opacity: float = DEFAULT_OPACITY
var _line_width: float = DEFAULT_WIDTH


static func load_config() -> Dictionary:
	var config: Dictionary = {"color": "#e8e4c8", "opacity": DEFAULT_OPACITY, "width": DEFAULT_WIDTH}
	if not FileAccess.file_exists(CONFIG_PATH):
		return config
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return config
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not parser.data is Dictionary:
		return config
	var raw: Dictionary = parser.data
	var color_value: Variant = raw.get("color", config["color"])
	var opacity_value: Variant = raw.get("opacity", config["opacity"])
	var width_value: Variant = raw.get("width", config["width"])
	if color_value is String and Color.html_is_valid(String(color_value)):
		config["color"] = color_value
	if typeof(opacity_value) in [TYPE_INT, TYPE_FLOAT] and float(opacity_value) >= 0.0 and float(opacity_value) <= 1.0:
		config["opacity"] = float(opacity_value)
	if typeof(width_value) in [TYPE_INT, TYPE_FLOAT] and float(width_value) > 0.0 and float(width_value) <= 8.0:
		config["width"] = float(width_value)
	return config


func setup(grid: MapGrid) -> void:
	_grid = grid
	var config: Dictionary = load_config()
	_line_color = Color(String(config["color"]))
	_opacity = float(config["opacity"])
	_line_width = float(config["width"])
	_enabled = SaveManager.map_grid_enabled()
	SaveManager.setting_changed.connect(_on_setting_changed)
	queue_redraw()


func _exit_tree() -> void:
	if SaveManager.setting_changed.is_connected(_on_setting_changed):
		SaveManager.setting_changed.disconnect(_on_setting_changed)


func line_count(size: Vector2i) -> int:
	return size.x + 1 + size.y + 1


func _on_setting_changed(key: String, value: Variant) -> void:
	if key != "map_grid":
		return
	_enabled = typeof(value) == TYPE_BOOL and value
	queue_redraw()


func _draw() -> void:
	if not _enabled or _grid == null:
		return
	var size: Vector2i = _grid.map_size()
	var transform: Transform2D = get_viewport_transform()
	var screen_scale: float = maxf(transform.x.length(), transform.y.length())
	var width: float = maxf(_line_width, 1.0 / maxf(screen_scale, 0.001))
	var color: Color = _line_color
	color.a = _opacity
	for x: int in range(size.x + 1):
		var px: float = float(x * Rules.TILE_SIZE)
		draw_line(Vector2(px, 0.0), Vector2(px, float(size.y * Rules.TILE_SIZE)), color, width, true)
	for y: int in range(size.y + 1):
		var py: float = float(y * Rules.TILE_SIZE)
		draw_line(Vector2(0.0, py), Vector2(float(size.x * Rules.TILE_SIZE), py), color, width, true)
