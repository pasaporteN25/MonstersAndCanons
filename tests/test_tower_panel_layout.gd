extends GutTest
# RF-349, RF-650, RF-721 (T513, D-214): el panel de torre de la PC mide 270 px de ancho, su alto sale del contenido
# (tope 320 px), no tiene barra de desplazamiento en los casos de RF-686, no muestra lo que no aplica y usa los botones del tema.

const PANEL: PackedScene = preload("res://scenes/ui/tower_panel.tscn")
const TOWER: PackedScene = preload("res://scenes/towers/tower.tscn")
const ALL_TOWERS: Array[String] = ["basic", "burst", "cannon", "disruptor", "fire", "frost", "mechanical_standard", "mortar", "multi", "sniper", "tesla"]

var _panel: TowerPanel


func before_each() -> void:
	_panel = PANEL.instantiate()
	add_child_autofree(_panel)


func _tower(id: String, level_index: int = 0) -> Tower:
	var tower: Tower = TOWER.instantiate()
	tower.setup(load("res://data/towers/%s.tres" % id))
	add_child_autofree(tower)
	tower.level_index = level_index
	return tower


func _show(id: String, level_index: int = 0, gold: int = 9999) -> Tower:
	var tower: Tower = _tower(id, level_index)
	_panel.show_tower(tower, 35, gold)
	await wait_process_frames(4)
	return tower


func _label(unique_name: String) -> Label:
	return _panel.get_node("%" + unique_name) as Label


func _button(unique_name: String) -> Button:
	return _panel.get_node("%" + unique_name) as Button


func _text_width(label: Label, text: String) -> float:
	return label.get_theme_font("font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x


## RF-721 punto 1 y RF-686: 270 de ancho, alto según el contenido (tope 320), sin barra y sin nada cortado,
## para las 11 torres en sus 3 niveles (los 12 casos de RF-686 están adentro).
func test_every_tower_and_level_is_270_wide_fits_without_scrollbar_and_under_the_cap() -> void:
	for id: String in ALL_TOWERS:
		for level_index: int in 3:
			var tower: Tower = await _show(id, level_index)
			var message: String = "%s nivel %d" % [id, level_index + 1]
			var details: ScrollContainer = _panel.get_node("%Details")
			var content: Control = _panel.get_node("%Content")
			assert_almost_eq(_panel.size.x, TowerPanel.WIDTH, 1.0, "%s: ancho" % message)
			assert_lte(_panel.size.y, TowerPanel.MAX_HEIGHT + 0.5, "%s: tope de alto (%d)" % [message, _panel.size.y])
			assert_false(details.get_v_scroll_bar().visible, "%s: sin barra de desplazamiento" % message)
			assert_gte(details.size.y + 0.5, content.get_combined_minimum_size().y, "%s: la lista entra entera" % message)
			assert_lte(_button("SellButton").get_global_rect().end.y, _panel.get_global_rect().end.y, "%s: Vender adentro" % message)
			for name: String in ["Damage", "Rate", "Range", "Cost", "Missing"]:
				var label: Label = _label(name)
				if label.is_visible_in_tree():
					assert_lte(_text_width(label, label.text), label.size.x + 1.0, "%s: %s no pasa de su columna" % [message, name])
			tower.queue_free()


func test_height_follows_the_content_and_is_shorter_than_the_old_fixed_320() -> void:
	await _show("tesla", 0)
	var electric: float = _panel.size.y
	assert_lt(electric, 320.0, "la Eléctrica 1 ya no mide 320 de alto")
	await _show("basic", 0, 0)
	assert_lt(_panel.size.y, electric, "la Ametralladora, con menos efectos, es más baja")
	assert_almost_eq(_panel.get_global_rect().end.y, 580.0, 1.0, "el borde de abajo queda fijo; el panel crece hacia arriba")


## Pasado el tope, y solo ahí, la lista desplaza (una torre futura con muchos efectos).
func test_over_the_cap_the_list_scrolls_and_the_panel_stops_at_320() -> void:
	await _show("tesla", 0)
	_label("Stats").text += "\nOtro efecto de una torre futura".repeat(30)
	await wait_process_frames(4)
	assert_almost_eq(_panel.size.y, TowerPanel.MAX_HEIGHT, 1.0)
	assert_true((_panel.get_node("%Details") as ScrollContainer).get_v_scroll_bar().visible, "ahí sí desplaza")


func test_the_longest_text_of_the_panel_fits_in_270_px() -> void:
	await _show("tesla", 0)
	var rate: Label = _label("Rate")
	assert_eq(rate.text, "0,75 → 0,85/s")
	assert_lte(_text_width(rate, rate.text), rate.size.x, "la cadencia más larga entra en su columna, sin achicar la letra")
	var damage: Label = _label("Damage")
	assert_eq(rate.get_theme_font_size("font_size"), damage.get_theme_font_size("font_size"), "las tres filas, a la misma letra")
	assert_eq(rate.get_theme_font_size("font_size"), _label("Range").get_theme_font_size("font_size"))


func test_support_tower_shows_no_damage_no_cadence_and_no_aim_button() -> void:
	await _show("mechanical_standard", 0)
	assert_false(_label("Damage").visible, "sin «DAÑO 0»")
	assert_false(_label("DamageCaption").visible)
	assert_false(_label("Rate").visible, "sin «CADENCIA Apoyo»")
	assert_false(_label("RateCaption").visible)
	assert_false(_button("TargetingButton").visible, "sin «Apuntar», ni apagado")
	assert_true(_label("Range").is_visible_in_tree())
	assert_string_contains(_label("Stats").text, "Apoyo: +10 → 15 % de cadencia")
	assert_string_contains(_label("Stats").text, "Repara 2 → 3 puntos de desgaste/s")
	assert_true(_button("SellButton").is_visible_in_tree())
	assert_almost_eq(_button("SellButton").size.x, _panel.get_node("%ActionRow").size.x, 1.0, "Vender solo, a todo el ancho")


func test_pulse_tower_has_no_aim_button_and_a_shooting_tower_has_it_at_half_width() -> void:
	await _show("disruptor", 0)
	assert_false(_button("TargetingButton").visible, "la Disruptora no apunta (RF-438)")
	await _show("cannon", 0)
	var aim: Button = _button("TargetingButton")
	var sell: Button = _button("SellButton")
	assert_true(aim.visible)
	assert_eq(aim.text, "Primero")
	assert_almost_eq(aim.size.x, sell.size.x, 1.5, "Apuntar y Vender, a media anchura cada uno")
	assert_lt(aim.size.x, _button("UpgradeButton").size.x * 0.55)
	assert_almost_eq(aim.get_global_rect().position.y, sell.get_global_rect().position.y, 1.0, "en la misma fila")
	assert_gt(_button("UpgradeButton").get_global_rect().end.y, 0.0)
	assert_lt(_button("UpgradeButton").get_global_rect().end.y, aim.get_global_rect().position.y + 0.5, "Mejorar va arriba, a todo el ancho")


func test_flying_icon_is_in_the_header_with_a_tooltip_and_crossed_out_when_it_does_not_apply() -> void:
	await _show("frost", 0)
	var air: TextureRect = _panel.get_node("%Air")
	assert_not_null(_panel.find_child("Air", true, false))
	assert_eq(air.tooltip_text, "Golpea voladores")
	assert_false((_panel.get_node("%AirStrike") as Line2D).visible)
	assert_ne(air.mouse_filter, Control.MOUSE_FILTER_IGNORE, "con IGNORE el tooltip no aparece")
	assert_eq(air.get_parent().name, "TitleRow", "en el encabezado")
	await _show("cannon", 0)
	assert_eq(air.tooltip_text, "No golpea voladores")
	assert_true((_panel.get_node("%AirStrike") as Line2D).visible, "tachado")
	assert_false(_panel.get_node("%Stats").text.contains("Voladores"), "ya no es un renglón de texto")


## RF-721 punto 7: sin oro, «Mejorar» queda apagado y dice «faltan N» a la vista; con oro muestra la tecla.
func test_upgrade_without_gold_says_how_much_is_missing_and_never_overlaps_its_label() -> void:
	var tower: Tower = await _show("basic", 0, 35)
	var upgrade: Button = _button("UpgradeButton")
	var cost: int = tower.next_level_stats().cost
	assert_true(upgrade.disabled)
	assert_true(_label("Missing").is_visible_in_tree())
	assert_eq(_label("Missing").text, "faltan %d" % (cost - 35))
	assert_eq(_label("Cost").text, str(cost), "el costo sigue a la vista")
	assert_false(_label("Key").visible, "apagado no ofrece la tecla")
	var font: Font = upgrade.get_theme_font("font")
	var text_end: float = upgrade.get_global_rect().position.x + 12.0 + font.get_string_size(upgrade.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	assert_lte(text_end, (_panel.get_node("%Missing") as Label).get_global_rect().position.x, "«faltan N» no pisa a «Mejorar a nivel N»")
	_panel.refresh(9999)
	assert_false(upgrade.disabled)
	assert_false(_label("Missing").visible)
	assert_true(_label("Key").visible)
	assert_eq(upgrade.tooltip_text, "Mejorar torre · U")


func test_max_level_says_max_and_hides_the_cost() -> void:
	await _show("cannon", 2)
	assert_eq(_button("UpgradeButton").text, "Nivel máximo")
	assert_true(_button("UpgradeButton").disabled)
	assert_false((_panel.get_node("%UpgradeInfo") as Control).visible)


## RF-650 (T512): botones del tema de los menús (hierro y bronce), no los rellenos verde, ladrillo y pizarra de antes.
func test_buttons_use_the_menu_theme_iron_and_bronze_not_the_old_flat_colors() -> void:
	await _show("cannon", 0)
	var theme: Theme = load("res://assets/ui/menu_theme.tres")
	var iron: StyleBoxFlat = theme.get_stylebox("normal", "Button") as StyleBoxFlat
	for name: String in ["UpgradeButton", "TargetingButton", "SellButton", "CloseButton"]:
		var style: StyleBoxFlat = _button(name).get_theme_stylebox("normal") as StyleBoxFlat
		assert_eq(style.bg_color, iron.bg_color, "%s: fondo de hierro del tema" % name)
		assert_eq(style.border_width_bottom, 4, "%s: borde de 4 px abajo, como los menús" % name)
		assert_eq(style.corner_radius_top_left, 6, "%s: radio 6" % name)
		for old: String in ["#526c4b", "#755144", "#48535d"]:
			assert_ne(style.bg_color.to_html(false), old.trim_prefix("#"), "%s: ya no es %s" % [name, old])
	assert_eq((_button("SellButton").get_theme_stylebox("normal") as StyleBoxFlat).border_color, TowerPanel.SELL_BORDER, "Vender: borde ladrillo apagado")
	assert_eq((_button("TargetingButton").get_theme_stylebox("normal") as StyleBoxFlat).border_color, iron.border_color, "Apuntar: bronce del tema")
	assert_eq((_button("UpgradeButton").get_theme_stylebox("hover") as StyleBoxFlat).border_color, (theme.get_stylebox("hover", "Button") as StyleBoxFlat).border_color, "el hover es el ámbar del tema")


## RF-650 (T512): la tarjeta de nivel son tres rectángulos en fila horizontal; los que faltan, con contorno del metal.
func test_level_card_is_a_horizontal_row_with_outlines_for_the_missing_metals() -> void:
	await _show("cannon", 1)
	var card: HBoxContainer = _panel.get_node("%LevelCard")
	assert_eq(card.get_child_count(), 3)
	assert_eq(card.tooltip_text, "Nivel actual: 2 de 3")
	var colors: Array[Color] = [Color("#d7a45b"), Color("#94a8b9"), Color("#f0d176")]
	var previous_x: float = -1.0
	for index: int in 3:
		var segment: Panel = card.get_child(index) as Panel
		assert_gt(segment.size.x, segment.size.y, "rectángulo horizontal, no una barrita")
		assert_gt(segment.get_global_rect().position.x, previous_x, "en fila")
		previous_x = segment.get_global_rect().position.x
		var style: StyleBoxFlat = segment.get_theme_stylebox("panel") as StyleBoxFlat
		if index < 2:
			assert_true(style.draw_center, "nivel %d: lleno" % (index + 1))
			assert_eq(style.bg_color, colors[index])
		else:
			assert_false(style.draw_center, "el oro que falta: solo contorno, sin relleno oscuro")
			assert_almost_eq(style.border_color.h, colors[index].h, 0.02, "el contorno es del metal que falta")
		assert_eq(style.border_width_left, 2)


func test_description_is_removed_and_the_selection_starts_at_the_top() -> void:
	var tower: Tower = _tower("basic")
	tower.data = tower.data.duplicate(true)
	tower.data.description = "Descripción extensa para comprobar el desplazamiento y la lectura. ".repeat(40)
	_panel.show_tower(tower, 35, 59)
	await wait_process_frames(4)
	assert_almost_eq(_panel.size.x, 270.0, 1.0)
	assert_lt(_panel.size.y, 320.0, "la descripción no se muestra y el panel no crece")
	assert_null(_panel.find_child("Description", true, false), "no se muestra la descripción redundante")
	assert_true(_button("UpgradeButton").disabled)
	var details: ScrollContainer = _panel.get_node("%Details")
	details.scroll_vertical = 80
	_panel.refresh(200)
	assert_eq(details.scroll_vertical, 0, "sin necesidad de desplazar no queda corrido")
	_panel.show_tower(null, 0, 0)
	_panel.show_tower(tower, 35, 200)
	assert_eq(details.scroll_vertical, 0, "otra selección empieza arriba")


func test_panel_passes_map_clicks_through_passive_regions_but_keeps_buttons_interactive() -> void:
	await wait_process_frames(2)
	# RF-74: lo pasivo deja pasar los clics al mapa; solo los botones (y los íconos con tooltip, que no los frenan) los reciben.
	assert_eq(_panel.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(_label("Title").mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(_label("Stats").mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((_panel.get_node("%Details") as ScrollContainer).mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_eq((_panel.get_node("%Air") as Control).mouse_filter, Control.MOUSE_FILTER_PASS, "PASS: muestra el tooltip y no se queda con el clic")
	for name: String in ["UpgradeButton", "SellButton", "TargetingButton", "CloseButton"]:
		assert_eq(_button(name).mouse_filter, Control.MOUSE_FILTER_STOP)
