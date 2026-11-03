# Tests de la marca de la torre elegida en el celular (T564, RF-737, D-226).
extends GutTest

const TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower.tscn")
const MORTAR: TowerData = preload("res://data/towers/mortar.tres")
const BASIC: TowerData = preload("res://data/towers/basic.tres")
const MOBILE_UI_PATH: String = "res://data/ui/mobile_ui.json"


func _tower(tower_data: TowerData = BASIC) -> Tower:
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(tower_data)
	add_child_autofree(tower)
	return tower


# --- Solo una torre lleva la marca ---

func test_only_the_chosen_tower_is_marked_between_two_equal_ones() -> void:
	var first: Tower = _tower()
	var second: Tower = _tower()
	Tower.move_marker(null, first)
	assert_true(first.has_selected_marker(), "la torre elegida lleva la marca")
	assert_false(second.has_selected_marker(), "la torre igual, sin elegir, no la lleva")


func test_marker_moves_to_the_newly_chosen_tower() -> void:
	var first: Tower = _tower()
	var second: Tower = _tower()
	Tower.move_marker(null, first)
	Tower.move_marker(first, second)
	assert_false(first.has_selected_marker(), "la anterior pierde la marca")
	assert_true(second.has_selected_marker(), "la nueva la recibe")


func test_marker_goes_away_when_the_tower_is_deselected() -> void:
	var tower: Tower = _tower()
	Tower.move_marker(null, tower)
	Tower.move_marker(tower, null)
	assert_false(tower.has_selected_marker(), "al soltarla se apaga")


func test_marker_on_a_freed_tower_does_not_break_the_next_choice() -> void:
	# Al vender, la torre se libera: la marca nueva tiene que poder elegirse igual.
	var sold: Tower = _tower()
	var other: Tower = _tower()
	Tower.move_marker(null, sold)
	sold.free()
	Tower.move_marker(sold, other)
	assert_true(other.has_selected_marker(), "la torre nueva queda marcada tras vender la anterior")


func test_choosing_the_same_tower_again_keeps_it_marked() -> void:
	var tower: Tower = _tower()
	Tower.move_marker(null, tower)
	Tower.move_marker(tower, tower)
	assert_true(tower.has_selected_marker(), "volver a tocar la misma no la apaga (caso de borde)")


# --- Gasta solo mientras está marcada ---

func test_marked_tower_processes_and_unmarked_one_does_not() -> void:
	var tower: Tower = _tower()
	assert_false(tower.is_processing(), "sin marca no hay pulso ni _process")
	tower.set_selected_marker(true)
	assert_true(tower.is_processing(), "con marca corre el pulso")
	tower.set_selected_marker(false)
	assert_false(tower.is_processing(), "al apagarla deja de gastar")


# --- Tamaño: el Mortero marca sus cuatro casillas ---

func test_marker_covers_the_whole_footprint_of_the_mortar() -> void:
	var basic: Tower = _tower(BASIC)
	var mortar: Tower = _tower(MORTAR)
	assert_eq(basic.marker_side_px(), Rules.TILE_SIZE, "la torre común ocupa una casilla")
	assert_eq(mortar.marker_side_px(), Rules.TILE_SIZE * 2.0, "el Mortero ocupa 2 × 2 casillas")


# --- Los números van en datos ---

func test_marker_settings_are_in_the_mobile_ui_data() -> void:
	var parser := JSON.new()
	assert_eq(parser.parse(FileAccess.get_file_as_string(MOBILE_UI_PATH)), OK, "mobile_ui.json se lee")
	var raw: Dictionary = parser.data
	for key: String in ["marca_torre_color", "marca_torre_grosor_px", "marca_torre_esquina",
			"marca_torre_pulso_velocidad", "marca_torre_opacidad_min"]:
		assert_true(raw.has(key), "%s está en mobile_ui.json" % key)
	var config: MobileUiConfig = MobileUiConfig.load_from()
	assert_eq(String(config.get_value("marca_torre_color")), "#ffd400", "color por omisión de la marca")
	assert_true(float(config.get_value("marca_torre_opacidad_min")) < 1.0, "el pulso baja la opacidad, no la deja fija")
