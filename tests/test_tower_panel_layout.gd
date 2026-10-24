# RF-349: textos largos no desplazan las acciones fuera del panel.
extends GutTest

const PANEL: PackedScene = preload("res://scenes/ui/tower_panel.tscn")
const TOWER: PackedScene = preload("res://scenes/towers/tower.tscn")

func test_description_is_removed_actions_fit_and_scroll_resets_on_selection() -> void:
	var panel: TowerPanel = PANEL.instantiate()
	add_child_autofree(panel)
	var tower: Tower = TOWER.instantiate()
	tower.setup(load("res://data/towers/basic.tres"))
	add_child_autofree(tower)
	tower.data = tower.data.duplicate(true)
	tower.data.description = "Descripción extensa para comprobar el desplazamiento y la lectura. ".repeat(40)
	panel.show_tower(tower, 35, 59)
	await wait_process_frames(5)
	assert_almost_eq(panel.size.x, 270.0, 1.0)
	assert_lt(panel.size.y, 356.0, "quitar la descripción reduce el panel")
	assert_null(panel.find_child("Description", true, false), "no se muestra la descripción redundante")
	var sell: Button = panel.get_node("%SellButton")
	assert_lte(sell.get_global_rect().end.y, panel.get_global_rect().end.y)
	assert_eq(sell.focus_mode, Control.FOCUS_ALL)
	assert_true((panel.get_node("%UpgradeButton") as Button).disabled)
	assert_eq((panel.get_node("%Damage") as Label).text, "5 → 8")
	var level_card: HBoxContainer = panel.get_node("%LevelCard")
	assert_eq((level_card.get_child(0) as ColorRect).color, Color("#d7a45b"), "bronce")
	var inactive_silver := Color("#94a8b9").darkened(0.72)
	inactive_silver.a = 0.6
	assert_eq((level_card.get_child(1) as ColorRect).color, inactive_silver, "plata")
	var inactive_gold := Color("#f0d176").darkened(0.72)
	inactive_gold.a = 0.6
	assert_eq((level_card.get_child(2) as ColorRect).color, inactive_gold, "oro")
	var rate: Label = panel.get_node("%Rate")
	rate.text = "0,75 → 0,85/s"
	var font: Font = rate.get_theme_font("font")
	assert_lte(font.get_string_size(rate.text, HORIZONTAL_ALIGNMENT_LEFT, -1, rate.get_theme_font_size("font_size")).x,
		rate.size.x, "la cadencia más larga entra en la columna de 270 px")
	var details: ScrollContainer = panel.get_node("%Details")
	details.scroll_vertical = 80
	panel.refresh(200)
	assert_eq(details.scroll_vertical, 0, "Sin descripción no hace falta desplazar el panel")
	panel.show_tower(null, 0, 0)
	panel.show_tower(tower, 35, 200)
	assert_eq(details.scroll_vertical, 0, "Otra selección empieza arriba")


func test_panel_passes_map_clicks_through_passive_regions_but_keeps_buttons_interactive() -> void:
	var panel: TowerPanel = PANEL.instantiate()
	add_child_autofree(panel)
	await wait_process_frames(2)
	assert_eq(panel.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((panel.get_node("%Title") as Label).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((panel.get_node("%Stats") as Label).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((panel.get_node("%Details") as ScrollContainer).mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_eq((panel.get_node("%UpgradeButton") as Button).mouse_filter, Control.MOUSE_FILTER_STOP)
	assert_eq((panel.get_node("%CloseButton") as Button).mouse_filter, Control.MOUSE_FILTER_STOP)
