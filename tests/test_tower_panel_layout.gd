# RF-349: textos largos no desplazan las acciones fuera del panel.
extends GutTest

const PANEL: PackedScene = preload("res://scenes/ui/tower_panel.tscn")
const TOWER: PackedScene = preload("res://scenes/towers/tower.tscn")

func test_long_description_keeps_actions_inside_and_resets_scroll_on_selection() -> void:
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
	assert_almost_eq(panel.size.y, 356.0, 1.0)
	var sell: Button = panel.get_node("%SellButton")
	assert_lte(sell.get_global_rect().end.y, panel.get_global_rect().end.y)
	assert_eq(sell.focus_mode, Control.FOCUS_ALL)
	assert_true((panel.get_node("%UpgradeButton") as Button).disabled)
	assert_eq((panel.get_node("%Damage") as Label).text, str(tower.stats().damage))
	var details: ScrollContainer = panel.get_node("%Details")
	details.scroll_vertical = 80
	panel.refresh(200)
	assert_eq(details.scroll_vertical, 80, "Cambiar oro conserva la lectura")
	panel.show_tower(null, 0, 0)
	panel.show_tower(tower, 35, 200)
	assert_eq(details.scroll_vertical, 0, "Otra selección empieza arriba")
