class_name MobileHud
extends CanvasLayer

signal confirm_placement_pressed
signal cancel_placement_pressed
signal view_all_pressed
signal demolish_pressed
signal exit_pressed
signal catalog_opened(open: bool)
signal tower_chosen(index: int, use_alt_payment: bool)
signal infrastructure_tool_chosen(tool: StringName, class_id: StringName)
signal upgrade_pressed
signal sell_pressed
signal targeting_pressed
## M75 (RF-681): «Mejorar» quedó armado (primer toque) o se desarmó. Game muestra o saca la ampliación del alcance.
signal upgrade_armed_changed(armed: bool)
signal clear_selection_pressed

var _config: MobileUiConfig
var _prefs: UiPrefs
var _confirm_button: Button
var _cancel_button: Button
var _view_all_button: Button
var _cart_button: Button
## M68 (RF-610): la partida está en pausa (el carrito y la demolición no hacen nada).
var _paused: bool = false
var _upgrade_fx_config: UpgradeFxConfig
var _exit_button: Button
var _demolish_button: Button
var _demolish_available: bool = false
var _catalog_panel: PanelContainer
var _catalog_dim: ColorRect
var _catalog_scroll: ScrollContainer
var _tower_grid: GridContainer
var _catalog_populated: bool = false
var _icon_cache: Dictionary = {}
var _available_towers: Array[TowerData] = []
var _machine_option: Dictionary = {}
var _catalog_gold: int = 0
var _catalog_resources: int = 0
var _catalog_uses_resources: bool = false
var _catalog_open: bool = false
var _game_over: bool = false
var _modal_open: bool = false
var _ghost_visible: bool = false
var _world_position: Vector2 = Vector2.ZERO
var _ghost_size: Vector2 = Vector2.ONE * Rules.TILE_SIZE
var _float_button_size: Vector2
# Posición guardada de los botones flotantes: 0 carrito, 1 salida, 2 demolición (RF-542).
var _base_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var _drag_button: Button
var _drag_index: int = -1
## RF-552: separa el mouse real del eco de un toque.
var _pointer_filter := PointerFilter.new()
var _drag_start: Vector2 = Vector2.ZERO
var _drag_start_position: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _layout_tween: Tween
var _target_positions: Array[Vector2] = [Vector2(-1000.0, -1000.0), Vector2(-1000.0, -1000.0), Vector2(-1000.0, -1000.0)]
var _status_bar: Control
var _status_label: Label
var _upgrade_button: Button
var _upgrade_styles: Array[StyleBoxFlat] = []  # T514: los estilos de «Mejorar» (para dejar o no lugar a la parte de abajo)
var _upgrade_coin: TextureRect  # T514: la moneda pegada al costo del título de «Mejorar»
var _tower_name_line: String = ""  # T514: los renglones del texto de la torre elegida («Hielo ●○○», «Aturdida», «Daño 2 · …»)
var _tower_state_line: String = ""
var _tower_stats_line: String = ""
var _upgrade_change: Label  # T514 (RF-722): la parte de abajo de «Mejorar», lo que se compra
var _target_button: Button
var _sell_button: Button
var _status_state: String = "empty"
var _selected_placed: Tower
var _sell_armed: bool = false
var _sell_arm_left: float = 0.0
var _sell_elapsed: float = 0.0
var _upgrade_lock_left: float = 0.0
var _upgrade_level_text: String = ""
## M75 (RF-681): primer toque dado en «Mejorar» sobre `_armed_tower`; el segundo confirma.
var _upgrade_armed: bool = false
var _armed_tower: Tower
var _armed_tower_level: int = -1
var _selected_sell_value: int = 0
var _selected_resource_value: int = 0
var _bottom_confirm: Button
var _bottom_cancel: Button
var _sell_gap: Control
var _status_touch_button: Button
var _status_touch_index: int = -1
var _status_touch_start: Vector2
var _status_touch_moved: bool = false
var _ghost_status_text: String = ""
var _mobile_theme: Theme

const MOBILE_THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const CART_ICON: Texture2D = preload("res://assets/ui/mobile_cart.svg")
const CONFIRM_ICON: Texture2D = preload("res://assets/ui/mobile_confirm.svg")
const CLOSE_ICON: Texture2D = preload("res://assets/ui/mobile_close.svg")
const DEMOLISH_ICON: Texture2D = preload("res://assets/ui/mobile_demolish.svg")
## T464: lupa de «Ver todo» (aprobada por Lucas el 2026-10-26; muestra en art/t464-muestra-lupa/).
const GOLD_ICON: Texture2D = preload("res://assets/sprites/ui/stat_gold.svg")
## T514: la mira de «Apuntar». Provisoria: dibujada con figuras simples (trazo de 1,6 como los íconos de la maqueta)
## hasta que arte apruebe un ícono; no es un asset del juego.
const AIM_SVG: String = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="#f0e8d9" stroke-width="1.6" stroke-linecap="round"><circle cx="8" cy="8" r="5"/><path d="M8 1v3M8 12v3M1 8h3M12 8h3"/></svg>'
const UPGRADE_AFTER_COLOR: Color = Color("bfe699")  # el «después» de la maqueta (--next)
const UPGRADE_MUTED_COLOR: Color = Color("a39d92")
const VIEW_ALL_ICON: Texture2D = preload("res://assets/ui/mobile_view_all.svg")


func _ready() -> void:
	_config = MobileUiConfig.load_from()
	_pointer_filter.configure(int(_config.get_value("puntero_duplicado_ms")), float(_config.get_value("puntero_duplicado_px")))
	_mobile_theme = MOBILE_THEME.duplicate(true) as Theme
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var style: StyleBoxFlat = _mobile_theme.get_stylebox(state, "Button") as StyleBoxFlat
		style.set_corner_radius_all(14)
	_prefs = SaveManager.get_ui_prefs()
	layer = 3
	_build_placement_buttons()
	_build_view_all_button()
	_build_floating_buttons()
	_build_status_bar()
	_build_empty_catalog()
	set_placement_visible(false)
	_apply_saved_positions()


func _build_status_bar() -> void:
	var height: float = float(_config.get_value("barra_baja_px"))
	_status_bar = Control.new()
	_status_bar.name = "MobileStatusBar"
	_status_bar.theme = _mobile_theme
	_status_bar.position = Vector2.ZERO
	_status_bar.size = Vector2(Rules.SCREEN_SIZE.x, height)
	_status_bar.position.y = Rules.SCREEN_SIZE.y - height
	_status_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE  # T288: no tapa a «Empezar oleada» del HUD (capa 1)
	add_child(_status_bar)
	var row := HBoxContainer.new()
	var margin_x: float = float(_config.get_value("barra_margen_x_px"))
	var margin_y: float = float(_config.get_value("barra_margen_y_px"))
	row.position = Vector2(margin_x, margin_y)
	row.size = Vector2(Rules.SCREEN_SIZE.x - margin_x * 2.0, height - margin_y * 2.0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE  # T288
	row.add_theme_constant_override("separation", int(_config.get_value("separacion_px")))
	_status_bar.add_child(row)
	_status_label = Label.new()
	_status_label.name = "StatusText"
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.custom_minimum_size.x = float(_config.get_value("barra_texto_min_ancho_px"))
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # fuera del estado «torre»; ahí son dos renglones sin partir
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_label.add_theme_font_size_override("font_size", int(_config.get_value("barra_fuente_px")))
	_status_label.resized.connect(func() -> void:
		if _status_state == "tower":
			_fit_status_font())
	row.add_child(_status_label)
	_bottom_confirm = Button.new()
	_bottom_confirm.name = "BottomConfirmPlacement"
	_bottom_confirm.text = "✓"
	_style_icon_button(_bottom_confirm, CONFIRM_ICON, true)
	_bottom_confirm.custom_minimum_size = Vector2(float(_config.get_value("tilde_ancho_px")), float(_config.get_value("tilde_alto_px")))
	_bottom_confirm.pressed.connect(confirm_placement_pressed.emit)
	row.add_child(_bottom_confirm)
	_bottom_cancel = Button.new()
	_bottom_cancel.name = "BottomCancelPlacement"
	_bottom_cancel.text = "×"
	_style_icon_button(_bottom_cancel, CLOSE_ICON)
	_bottom_cancel.custom_minimum_size = Vector2(float(_config.get_value("cruz_lado_px")), float(_config.get_value("cruz_lado_px")))
	_bottom_cancel.pressed.connect(_on_bottom_cancel_pressed)
	row.add_child(_bottom_cancel)
	_target_button = Button.new()
	_target_button.name = "MobileTargeting"
	_target_button.custom_minimum_size = Vector2(float(_config.get_value("apuntar_ancho_px")), float(_config.get_value("apuntar_alto_px")))
	_target_button.add_theme_font_size_override("font_size", int(_config.get_value("apuntar_fuente_px")))
	_target_button.icon = _aim_texture()
	_target_button.expand_icon = false
	_target_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_target_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	_target_button.clip_text = true
	_target_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # T514: miden su alto (84), no el de la fila
	_target_button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # un solo dueño del toque: _handle_status_touch (T291)
	_target_button.pressed.connect(_on_target_pressed)
	row.add_child(_target_button)
	_upgrade_button = Button.new()
	_upgrade_button.name = "MobileUpgrade"
	_upgrade_button.custom_minimum_size = Vector2(float(_config.get_value("mejorar_ancho_px")), float(_config.get_value("mejorar_alto_px")))
	_upgrade_button.add_theme_font_size_override("font_size", int(_config.get_value("accion_fuente_px")))
	_upgrade_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # T514: miden su alto (84), no el de la fila
	_upgrade_button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # un solo dueño del toque: _handle_status_touch (T291)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	_style_upgrade_button()
	row.add_child(_upgrade_button)
	_sell_gap = Control.new()
	_sell_gap.name = "SellSeparation"
	_sell_gap.custom_minimum_size.x = _catalog_virtual_mm(float(_config.get_value("vender_separacion_mm")))
	_sell_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_sell_gap)
	_sell_button = Button.new()
	_sell_button.name = "MobileSell"
	_sell_button.custom_minimum_size = Vector2(float(_config.get_value("vender_ancho_px")), float(_config.get_value("vender_alto_px")))
	_sell_button.add_theme_font_size_override("font_size", int(_config.get_value("accion_fuente_px")))
	_sell_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # T514: miden su alto (84), no el de la fila
	_sell_button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # un solo dueño del toque: _handle_status_touch (T291)
	_sell_button.pressed.connect(_on_sell_pressed)
	row.add_child(_sell_button)
	_set_empty_status()


## T514 (RF-722): la mira de «Apuntar» como textura (provisoria, ver `AIM_SVG`).
func _aim_texture() -> Texture2D:
	var image := Image.new()
	if image.load_svg_from_string(AIM_SVG, float(_config.get_value("apuntar_icono_px")) / 16.0) != OK:
		return null
	return ImageTexture.create_from_image(image)


## T514 (RF-722): «Mejorar» de dos partes. Arriba (el texto del botón) «Mejorar → N2» con el costo y la moneda; abajo,
## un rótulo hijo con lo que se compra, en el verde del «después». El texto se sube dejando lugar abajo con el margen
## del estilo, así `_upgrade_button.text` sigue siendo el título (los toques y los estados no cambian).
func _style_upgrade_button() -> void:
	var change_h: float = float(_config.get_value("mejorar_cambio_alto_px"))
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var style: StyleBoxFlat = _mobile_theme.get_stylebox(state, "Button").duplicate() as StyleBoxFlat
		style.content_margin_left = 6.0
		style.content_margin_right = 6.0
		style.content_margin_top = 4.0
		style.content_margin_bottom = change_h + 6.0
		_upgrade_button.add_theme_stylebox_override(state, style)
		_upgrade_styles.append(style)
	var coin_px: float = float(_config.get_value("mejorar_moneda_px"))
	_upgrade_coin = TextureRect.new()
	_upgrade_coin.name = "MobileUpgradeCoin"
	_upgrade_coin.texture = GOLD_ICON
	_upgrade_coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_upgrade_coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_upgrade_coin.custom_minimum_size = Vector2(coin_px, coin_px)
	_upgrade_coin.size = Vector2(coin_px, coin_px)
	_upgrade_coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_upgrade_button.add_child(_upgrade_coin)
	_upgrade_change = Label.new()
	_upgrade_change.name = "MobileUpgradeChange"
	_upgrade_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_upgrade_change.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_upgrade_change.clip_text = true
	_upgrade_change.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_upgrade_change.anchor_left = 0.0
	_upgrade_change.anchor_right = 1.0
	_upgrade_change.anchor_top = 1.0
	_upgrade_change.anchor_bottom = 1.0
	_upgrade_change.offset_left = 6.0
	_upgrade_change.offset_right = -6.0
	_upgrade_change.offset_bottom = -8.0
	_upgrade_change.offset_top = -8.0 - change_h
	_upgrade_button.add_child(_upgrade_change)


## M68 (RF-610): con la partida en pausa no se construye; la línea de abajo lo dice.
const EMPTY_TEXT: String = "Tocá el carrito para elegir una torre"
const PAUSED_TEXT: String = "En pausa: seguí la partida para construir"


func _set_empty_status() -> void:
	clear_upgrade_arm()
	_status_state = "empty"
	_fit_status_font()  # T511: letra normal fuera del estado «torre»
	_status_label.text = PAUSED_TEXT if _paused else EMPTY_TEXT
	_status_label.visible = true
	_target_button.hide()
	_upgrade_button.hide()
	_sell_button.hide()
	_sell_gap.hide()
	_bottom_confirm.hide()
	_bottom_cancel.hide()


## RF-543: la herramienta de demoler/habilitar está elegida. La línea dice qué hacer (o el motivo del último
## toque que no sirvió) y la cruz la suelta.
func show_tool_status(message: String = "") -> void:
	clear_upgrade_arm()
	_status_state = "tool"
	_fit_status_font()  # T511: letra normal fuera del estado «torre»
	_status_label.text = message if message != "" else "Demoler o habilitar: tocá un objeto del mapa"
	_status_label.visible = true
	_target_button.hide()
	_upgrade_button.hide()
	_sell_button.hide()
	_sell_gap.hide()
	_bottom_confirm.hide()
	_bottom_cancel.show()


func show_ghost_status(tower_name: String, cost_text: String) -> void:
	clear_upgrade_arm()
	_status_state = "ghost"
	_fit_status_font()  # T511: letra normal fuera del estado «torre»
	_ghost_status_text = "%s  ·  %s" % [tower_name, cost_text]
	_status_label.text = _ghost_status_text
	_status_label.visible = true
	_target_button.hide()
	_upgrade_button.hide()
	_sell_button.hide()
	_sell_gap.hide()
	_bottom_confirm.show()
	_bottom_cancel.show()
	_bottom_confirm.disabled = _confirm_button.disabled


func show_selected_tower(tower: Tower, gold: int, sell_value: int, resource_value: int,
		can_upgrade: bool, disabled_reason: String = "") -> void:
	if tower == null:
		_selected_placed = null
		clear_sell_arm()
		_set_empty_status()
		return
	if _selected_placed != tower:
		clear_sell_arm()
		clear_upgrade_arm()
	_selected_placed = tower
	_selected_sell_value = sell_value
	_selected_resource_value = resource_value
	_status_state = "tower"
	var dots: String = "●".repeat(tower.level_number()) + "○".repeat(maxi(0, tower.data.levels.size() - tower.level_number()))
	_tower_state_line = ""
	if tower.stun_left() > 0.0:
		_tower_state_line = "Aturdida"
	elif tower.wear_percent > 0:
		_tower_state_line = "Desgaste %d %%" % tower.wear_percent
	var stats: TowerLevelData = tower.stats()
	# T514 (RF-722): dos renglones cortos. Arriba el nombre con los puntos de nivel (y el estado de la torre);
	# abajo el estado actual abreviado, con la coma decimal y el alcance con su decimal (`TowerText`, como la PC).
	_tower_name_line = "%s %s" % [tower.data.display_name, dots]
	_tower_stats_line = TowerText.bar_state(stats.damage, tower.effective_fire_rate(), stats.range_tiles, tower.data.support_only)
	_status_label.text = _tower_text(true)
	_status_label.visible = true
	_fit_status_font()
	_bottom_cancel.show()
	# RF-722: «Apuntar» es un ícono con el modo y no se agrega si la torre no apunta (apoyo, pulso).
	_target_button.visible = not (tower.data.support_only or tower.is_pulse_tower())
	_target_button.text = tower.targeting_name()
	_target_button.tooltip_text = "Apuntar: %s" % tower.targeting_name()
	_target_button.disabled = false
	_upgrade_button.show()
	if _upgrade_lock_left > 0.0:
		_set_upgrade_texts(_upgrade_level_text, "", false)
		_upgrade_button.disabled = true
	elif not tower.can_upgrade():
		clear_upgrade_arm()
		_set_upgrade_texts("Nivel máximo", "", false)
		_upgrade_button.disabled = true
	elif not can_upgrade:
		clear_upgrade_arm()  # RF-681: si falta oro, se cancela
		var missing: String = disabled_reason if disabled_reason != "" else "Faltan %d de oro" % maxi(0, tower.next_level_stats().cost - gold)
		_set_upgrade_texts(missing, _upgrade_change_text(tower), false)
		_upgrade_change.add_theme_color_override("font_color", UPGRADE_MUTED_COLOR)
		_upgrade_button.disabled = true
	else:
		if _upgrade_armed and _armed_tower_level != tower.level_index:
			clear_upgrade_arm()  # la torre cambió de nivel por otro camino: la ampliación mostrada ya no vale
		_refresh_upgrade_button(tower)
		_upgrade_button.disabled = false
	_sell_button.show()
	_sell_gap.show()
	_bottom_confirm.hide()
	if resource_value > 0:
		_sell_button.tooltip_text = "Devuelve %d de oro y %d recursos" % [sell_value, resource_value]
	else:
		_sell_button.tooltip_text = "Devuelve %d de oro" % sell_value
	_refresh_sell_button(sell_value, resource_value)


## T514 (RF-722): en el estado «torre» el texto son dos renglones que no se parten (cada uno entra en una línea). Si el
## más ancho no entra en el lugar que dejan los botones, la letra baja de a un punto desde `barra_torre_fuente_px`
## hasta `barra_torre_fuente_min_px`; no se corta nada (`clip_text` solo es la red de seguridad). Fuera del estado
## «torre» vuelve la letra normal y el texto que se parte en renglones.
func _fit_status_font() -> void:
	if _status_state != "tower":
		_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_status_label.clip_text = false
		_status_label.add_theme_font_size_override("font_size", int(_config.get_value("barra_fuente_px")))
		return
	_status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_status_label.clip_text = true
	var size_px: int = int(_config.get_value("barra_torre_fuente_px"))
	var min_px: int = int(_config.get_value("barra_torre_fuente_min_px"))
	var font: Font = _status_label.get_theme_font("font")
	var merged: String = _tower_text(true)
	var split: String = _tower_text(false)
	var width: float = _status_label.size.x
	# 1.º el estado (aturdida, desgaste) va en el renglón del nombre; si ni a la letra mínima entra, pasa a un renglón
	# propio (tres renglones cortos, que caben en los 92 px de la fila) antes que cortarse.
	var text: String = merged
	if widest_line(font, merged, min_px) > width:
		text = split
	var available_h: float = float(_config.get_value("barra_baja_px")) - float(_config.get_value("barra_margen_y_px")) * 2.0
	while size_px > min_px and (widest_line(font, text, size_px) > width \
			or float(text.count("\n") + 1) * font.get_height(size_px) > available_h):
		size_px -= 1
	_status_label.text = text
	_status_label.add_theme_font_size_override("font_size", size_px)


## El texto de la torre elegida: nombre (con el estado, si `merged`), y el estado actual abreviado.
func _tower_text(merged: bool) -> String:
	if _tower_state_line == "":
		return "%s\n%s" % [_tower_name_line, _tower_stats_line]
	if merged:
		return "%s · %s\n%s" % [_tower_name_line, _tower_state_line, _tower_stats_line]
	return "%s\n%s\n%s" % [_tower_name_line, _tower_state_line, _tower_stats_line]


## El ancho en px del renglón más ancho de `text` con la letra `font` a `size_px`.
static func widest_line(font: Font, text: String, size_px: int) -> float:
	var widest: float = 0.0
	for line: String in text.split("\n"):
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x)
	return widest


## T514 (RF-722, RF-617 enmendado): lo que se compra con «Mejorar», hasta 2 estadísticas («alcance 2,5 → 3 · …»), para
## la parte de abajo del botón. Los números salen de los dos niveles de la torre y de la tabla de
## `data/ui/mejoras.json` (RF-618: un solo origen, el mismo de las animaciones de mejora), con la coma decimal de
## `TowerText.decimal`. Vacío en el nivel máximo.
func _upgrade_change_text(tower: Tower) -> String:
	if _upgrade_fx_config == null:
		_upgrade_fx_config = UpgradeFxConfig.load_from()
	var changes: Array[Dictionary] = UpgradeDeltas.preview(tower.data.levels, tower.level_index, _upgrade_fx_config.stats,
			int(_config.get_value("mejorar_cambio_max")))
	if changes.is_empty():
		return ""
	return UpgradeDeltas.SEPARATOR.join(UpgradeDeltas.rows(changes, changes.size()))


## Escribe las dos partes de «Mejorar»: el título (con la moneda si lleva costo) y lo que se compra. La letra de la
## parte de abajo baja de a un punto si no entra en el ancho del botón.
func _set_upgrade_texts(title: String, change: String, with_cost: bool) -> void:
	_upgrade_button.text = title
	# sin parte de abajo («Nivel máximo», «¡Nivel 2!») el título se centra en todo el botón
	var title_height: float = float(_config.get_value("mejorar_alto_px")) - (float(_config.get_value("mejorar_cambio_alto_px")) + 6.0 if change != "" else 4.0)
	for style: StyleBoxFlat in _upgrade_styles:
		style.content_margin_bottom = float(_config.get_value("mejorar_alto_px")) - title_height
	_upgrade_coin.visible = with_cost
	if with_cost:
		# la moneda va justo después del costo: el título está centrado en la parte de arriba del botón
		var title_font: Font = _upgrade_button.get_theme_font("font")
		var title_w: float = title_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, int(_config.get_value("accion_fuente_px"))).x
		_upgrade_coin.position = Vector2((float(_config.get_value("mejorar_ancho_px")) + title_w) / 2.0 + 6.0,
				(4.0 + title_height) / 2.0 - _upgrade_coin.size.y / 2.0)
	_upgrade_change.text = change
	_upgrade_change.visible = change != ""
	_upgrade_change.add_theme_color_override("font_color", UPGRADE_AFTER_COLOR)
	var size_px: int = int(_config.get_value("mejorar_cambio_fuente_px"))
	var font: Font = _upgrade_change.get_theme_font("font")
	var width: float = float(_config.get_value("mejorar_ancho_px")) - 12.0
	while size_px > 12 and widest_line(font, change, size_px) > width:
		size_px -= 1
	_upgrade_change.add_theme_font_size_override("font_size", size_px)


## RF-681: el texto de «Mejorar» activo. Armado, pide confirmar y conserva el costo a la vista.
func _refresh_upgrade_button(tower: Tower) -> void:
	var cost: int = tower.next_level_stats().cost
	var change: String = _upgrade_change_text(tower)
	if _upgrade_armed:
		_set_upgrade_texts("Tocá para confirmar  %d" % cost, change, true)
		_upgrade_button.add_theme_color_override("font_color", Color(1.0, 0.8, 0.25))
	else:
		_set_upgrade_texts("Mejorar → N%d  %d" % [tower.level_number() + 1, cost], change, true)
		_upgrade_button.remove_theme_color_override("font_color")


func is_upgrade_armed() -> bool:
	return _upgrade_armed


## La torre para la que «Mejorar» espera el segundo toque (null si no está armado).
func armed_tower() -> Tower:
	return _armed_tower if _upgrade_armed else null


## RF-681 punto 3: el botón vuelve a «Mejorar a nivel N» y la ampliación se va. Sin efecto si no estaba armado.
func clear_upgrade_arm() -> void:
	if not _upgrade_armed:
		return
	_upgrade_armed = false
	_armed_tower = null
	_upgrade_button.remove_theme_color_override("font_color")
	if _selected_placed != null and _selected_placed.can_upgrade():
		_refresh_upgrade_button(_selected_placed)
	upgrade_armed_changed.emit(false)


func begin_upgrade_lock(level_number: int) -> void:
	_upgrade_lock_left = float(_config.get_value("mejorar_bloqueo_s"))
	_upgrade_level_text = "¡Nivel %d!" % level_number


func clear_sell_arm() -> void:
	_sell_armed = false
	_sell_arm_left = 0.0
	_sell_elapsed = 0.0
	if _selected_placed != null:
		_refresh_sell_button(_selected_sell_value, _selected_resource_value)


func _refresh_sell_button(sell_value: int, resource_value: int = 0) -> void:
	if _sell_armed:
		var refund: String = TowerText.refund_text(sell_value, resource_value)
		_sell_button.text = "Vender por %s\nConfirmar venta" % refund
		_sell_button.add_theme_color_override("font_color", Color(1.0, 0.8, 0.25))
		_sell_button.add_theme_stylebox_override("normal", _double_border_style())
	else:
		# RF-722: lo que devuelve va abajo, corto («+70» o «+210 +2» si también devuelve recursos).
		_sell_button.text = "Vender\n+%d%s" % [sell_value, " +%d" % resource_value if resource_value > 0 else ""]
		_sell_button.remove_theme_color_override("font_color")
		_sell_button.remove_theme_stylebox_override("normal")


func _double_border_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.34, 0.18, 0.08)
	style.border_color = Color(1.0, 0.77, 0.25)
	style.set_border_width_all(int(_config.get_value("vender_borde_px")))
	style.set_corner_radius_all(int(_config.get_value("vender_radio_px")))
	style.content_margin_left = float(_config.get_value("vender_padding_x_px"))
	style.content_margin_right = float(_config.get_value("vender_padding_x_px"))
	style.content_margin_top = float(_config.get_value("vender_padding_y_px"))
	style.content_margin_bottom = float(_config.get_value("vender_padding_y_px"))
	return style


func _on_upgrade_pressed() -> void:
	if _upgrade_lock_left > 0.0 or _upgrade_button.disabled or _selected_placed == null:
		return
	if not _upgrade_armed:
		# RF-681: el primer toque no cobra ni sube la torre: muestra la ampliación y espera la confirmación.
		_upgrade_armed = true
		_armed_tower = _selected_placed
		_armed_tower_level = _selected_placed.level_index
		_refresh_upgrade_button(_selected_placed)
		upgrade_armed_changed.emit(true)
		return
	clear_upgrade_arm()
	upgrade_pressed.emit()


func _on_target_pressed() -> void:
	clear_upgrade_arm()
	targeting_pressed.emit()


func _on_bottom_cancel_pressed() -> void:
	if _status_state == "tower":
		clear_upgrade_arm()
		clear_selection_pressed.emit()
	else:
		cancel_placement_pressed.emit()


func _on_sell_pressed() -> void:
	if _selected_placed == null:
		return
	clear_upgrade_arm()
	if not _sell_armed:
		_sell_armed = true
		_sell_elapsed = 0.0
		_sell_arm_left = float(_config.get_value("vender_rearmar_s"))
		_refresh_sell_button(_selected_sell_value, _selected_resource_value)
		return
	if _sell_elapsed < float(_config.get_value("vender_min_s")):
		return
	clear_sell_arm()
	sell_pressed.emit()


func _build_placement_buttons() -> void:
	_confirm_button = Button.new()
	_confirm_button.name = "ConfirmPlacement"
	_confirm_button.text = "✓"
	_style_icon_button(_confirm_button, CONFIRM_ICON, true)
	_confirm_button.add_theme_font_size_override("font_size", 32)
	_confirm_button.custom_minimum_size = Vector2(
		float(_config.get_value("tilde_ancho_px")), float(_config.get_value("tilde_alto_px")))
	_confirm_button.pressed.connect(confirm_placement_pressed.emit)
	add_child(_confirm_button)
	_cancel_button = Button.new()
	_cancel_button.name = "CancelPlacement"
	_cancel_button.text = "×"
	_style_icon_button(_cancel_button, CLOSE_ICON)
	_cancel_button.add_theme_font_size_override("font_size", 32)
	var cancel_size: float = float(_config.get_value("cruz_lado_px"))
	_cancel_button.custom_minimum_size = Vector2(cancel_size, cancel_size)
	_cancel_button.pressed.connect(cancel_placement_pressed.emit)
	add_child(_cancel_button)


func _build_view_all_button() -> void:
	_view_all_button = Button.new()
	_view_all_button.name = "ViewAll"
	# Botón redondo con la lupa, sin texto visible (T464): mismo estilo que carrito, X y demolición.
	_style_icon_button(_view_all_button, VIEW_ALL_ICON)
	# A diferencia de los otros, este se toca directo (no se arrastra): recupera el filtro del mouse.
	_view_all_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_view_all_button.tooltip_text = "Ver todo"
	_view_all_button.accessibility_name = "Ver todo"
	var floating_size: float = float(_config.get_value("flotante_min_px"))
	_view_all_button.custom_minimum_size = Vector2(floating_size, floating_size)
	_view_all_button.position = Vector2(
		float(_config.get_value("ver_todo_x_px")), float(_config.get_value("ver_todo_y_px")))
	_view_all_button.visible = false
	_view_all_button.pressed.connect(view_all_pressed.emit)
	add_child(_view_all_button)
	# El tamaño se fija ya dentro del árbol: antes, el ícono le sumaba un mínimo provisorio (72 px).
	_view_all_button.size = _view_all_button.custom_minimum_size


func _build_floating_buttons() -> void:
	var minimum_size: float = _minimum_touch_size()
	_float_button_size = Vector2.ONE * minimum_size
	_cart_button = _floating_button("CartButton", CART_ICON)
	_cart_button.tooltip_text = "Elegir torre"
	_exit_button = _floating_button("ExitButton", CLOSE_ICON)
	_exit_button.tooltip_text = "Salir al menú"
	_demolish_button = _floating_button("DemolishButton", DEMOLISH_ICON)
	_demolish_button.tooltip_text = "Demoler o habilitar"
	_demolish_button.visible = false
	_cart_button.pressed.connect(_on_cart_pressed)
	_exit_button.pressed.connect(exit_pressed.emit)
	_demolish_button.pressed.connect(demolish_pressed.emit)
	if _confirm_button != null:
		_confirm_button.custom_minimum_size.x = maxf(_confirm_button.custom_minimum_size.x, minimum_size)
		_confirm_button.custom_minimum_size.y = maxf(_confirm_button.custom_minimum_size.y, minimum_size)
		_cancel_button.custom_minimum_size = Vector2.ONE * maxf(_cancel_button.custom_minimum_size.x, minimum_size)
		_confirm_button.size = _confirm_button.custom_minimum_size
		_cancel_button.size = _cancel_button.custom_minimum_size


func _minimum_touch_size() -> float:
	var fallback: float = float(_config.get_value("flotante_min_px"))
	if not OS.has_feature("mobile"):
		return fallback
	var dpi: float = float(DisplayServer.screen_get_dpi())
	var stretch: Transform2D = get_viewport().get_stretch_transform()
	var canvas_scale: float = stretch.x.length() * get_viewport().get_window().content_scale_factor
	return FloatButtonLayout.minimum_button_size(dpi, canvas_scale,
		float(_config.get_value("flotante_min_mm")), fallback)


func _floating_button(button_name: String, icon: Texture2D) -> Button:
	var button := Button.new()
	button.name = button_name
	_style_icon_button(button, icon)
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = _float_button_size
	button.add_theme_font_size_override("font_size", 32)
	add_child(button)
	return button


func _style_icon_button(button: Button, icon: Texture2D, confirm: bool = false) -> void:
	button.theme = _mobile_theme
	button.text = ""
	button.icon = icon
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", 28)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.focus_mode = Control.FOCUS_NONE
	# El gesto se resuelve una sola vez en _input; el mouse emulado no vuelve a pulsarlo.
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var style: StyleBoxFlat = MOBILE_THEME.get_stylebox(state, "Button").duplicate() as StyleBoxFlat
		style.set_corner_radius_all(int(_config.get_value("icono_radio_px")))
		style.set_content_margin_all(float(_config.get_value("icono_padding_px")))
		if confirm and state != "disabled":
			style.bg_color = Color("#29382a") if state == "normal" else Color("#3b5134")
			style.border_color = Color("#a5b776")
		button.add_theme_stylebox_override(state, style)


func _build_empty_catalog() -> void:
	_catalog_dim = ColorRect.new()
	_catalog_dim.name = "CatalogDim"
	_catalog_dim.color = Color(0.0, 0.0, 0.0, 0.55)
	_catalog_dim.size = Rules.SCREEN_SIZE
	_catalog_dim.visible = false
	_catalog_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_catalog_dim)
	var width: float = float(_config.get_value("catalogo_ancho_px"))
	var height: float = float(_config.get_value("catalogo_alto_px"))
	_catalog_panel = PanelContainer.new()
	_catalog_panel.name = "CatalogPanel"
	_catalog_panel.theme = _mobile_theme
	var panel_style: StyleBoxFlat = preload("res://assets/ui/game_panel_style.tres").duplicate() as StyleBoxFlat
	panel_style.set_content_margin_all(16.0)
	_catalog_panel.add_theme_stylebox_override("panel", panel_style)
	_catalog_panel.position = (Rules.SCREEN_SIZE - Vector2(width, height)) / 2.0
	_catalog_panel.custom_minimum_size = Vector2(width, height)
	_catalog_panel.visible = false
	_catalog_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_catalog_panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", int(_config.get_value("catalogo_separacion_px")))
	_catalog_panel.add_child(rows)
	var heading := HBoxContainer.new()
	rows.add_child(heading)
	var title := Label.new()
	title.text = "Elegí una opción"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", int(_config.get_value("catalogo_titulo_fuente_px")))
	heading.add_child(title)
	var close_button := Button.new()
	close_button.name = "CloseCatalog"
	close_button.text = "×"
	_style_icon_button(close_button, CLOSE_ICON)
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	close_button.custom_minimum_size = Vector2.ONE * _minimum_touch_size()
	close_button.pressed.connect(close_catalog)
	heading.add_child(close_button)
	# RF-540: una sola grilla de torres, sin pestañas; siempre abre en la primera fila.
	_catalog_scroll = ScrollContainer.new()
	_catalog_scroll.name = "CatalogScroll"
	_catalog_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rows.add_child(_catalog_scroll)
	_tower_grid = GridContainer.new()
	_tower_grid.name = "TowerCards"
	_tower_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tower_grid.columns = int(_config.get_value("catalogo_columnas"))
	_catalog_scroll.add_child(_tower_grid)
	_refresh_catalog()


## `available` son las torres que el nivel ofrece, en el orden de la barra de PC (RF-541). `machine_option`
## es la compra de la Demoledora ({} si el nivel no la ofrece o ya está comprada): va de última (RF-540).
func set_catalog_data(available: Array[TowerData], gold: int, resources: int, uses_resources: bool,
		machine_option: Dictionary = {}) -> void:
	_available_towers = available.duplicate()
	_catalog_gold = gold
	_catalog_resources = resources
	_catalog_uses_resources = uses_resources
	_machine_option = machine_option.duplicate(true)
	_catalog_populated = true
	_refresh_catalog()


func _refresh_catalog() -> void:
	if _tower_grid == null:
		return
	var card_width: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_ancho_mm")))
	var separation: float = float(_config.get_value("catalogo_separacion_px"))
	var content_width: float = float(_config.get_value("catalogo_ancho_px")) - separation * 2.0
	var fit_columns: int = maxi(1, floori((content_width + separation) / (card_width + separation)))
	_tower_grid.columns = mini(int(_config.get_value("catalogo_columnas")), fit_columns)
	var descriptors: Array[Dictionary] = []
	for i: int in _available_towers.size():
		var tower: TowerData = _available_towers[i]
		var primary_reason: String = TowerText.missing_text(tower, false,
			_catalog_gold, _catalog_resources, _catalog_uses_resources)
		var use_alt: bool = false
		var reason: String = ""
		if primary_reason != "":
			var alternate_reason: String = TowerText.missing_text(tower, true,
				_catalog_gold, _catalog_resources, _catalog_uses_resources)
			if tower.has_alt_payment() and alternate_reason == "":
				use_alt = true
			else:
				reason = primary_reason
				if tower.has_alt_payment() and alternate_reason != "":
					reason = alternate_reason if alternate_reason.length() < primary_reason.length() else primary_reason
		var cost_text: String = TowerText.cost_text(tower, use_alt)
		if tower.has_alt_payment():
			cost_text = "%s / %s" % [TowerText.cost_text(tower), TowerText.cost_text(tower, true)]
		descriptors.append({"key": "tower:%s" % tower.id, "title": tower.display_name,
			"cost": cost_text, "reason": reason, "icon": _tower_icon(tower),
			"tower_index": i, "use_alt": use_alt, "tool": &""})
	if not _machine_option.is_empty():
		descriptors.append({"key": "tool:machine", "title": String(_machine_option.get("name", "Demoledora")),
			"cost": String(_machine_option.get("cost_text", "")), "reason": String(_machine_option.get("disabled_reason", "")),
			"icon": _machine_option.get("icon"), "tower_index": -1, "use_alt": false, "tool": &"machine"})
	_sync_catalog_grid(_tower_grid, descriptors)


## Deja la grilla igual a los descriptores. Si las tarjetas son las mismas (misma clave y orden)
## las actualiza en el lugar: no se destruye ninguna, así que un toque en curso no se pierde (T290, H-03).
func _sync_catalog_grid(grid: GridContainer, descriptors: Array[Dictionary]) -> void:
	var same_structure: bool = grid.get_child_count() == descriptors.size()
	if same_structure:
		for i: int in descriptors.size():
			if grid.get_child(i).get_meta("key", "") != descriptors[i]["key"]:
				same_structure = false
				break
	if same_structure:
		for i: int in descriptors.size():
			_apply_card(grid.get_child(i) as Button, descriptors[i])
		return
	for child: Node in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for descriptor: Dictionary in descriptors:
		grid.add_child(_make_catalog_card(descriptor))


func _tower_icon(tower: TowerData) -> Texture2D:
	if not _icon_cache.has(tower.id):
		_icon_cache[tower.id] = Tower.make_icon(tower)
	return _icon_cache[tower.id]


func _make_catalog_card(descriptor: Dictionary) -> Button:
	var minimum_width: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_ancho_mm")))
	var minimum_height: float = _catalog_virtual_mm(float(_config.get_value("catalogo_tarjeta_alto_mm")))
	var card := Button.new()
	var title: String = descriptor["title"]
	var safe_title: String = title.to_snake_case().replace("·", "").replace("__", "_").trim_prefix("_").trim_suffix("_")
	card.name = "CatalogCard_%s" % safe_title
	card.custom_minimum_size = Vector2(minimum_width, minimum_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_NONE
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	card.expand_icon = true
	card.add_theme_constant_override("icon_max_width", int(_config.get_value("catalogo_icono_ancho_px")))
	card.add_theme_font_size_override("font_size", int(_config.get_value("catalogo_tarjeta_fuente_px")))
	card.pressed.connect(_on_catalog_card_pressed.bind(card))
	_apply_card(card, descriptor)
	return card


func _apply_card(card: Button, descriptor: Dictionary) -> void:
	var title: String = descriptor["title"]
	var cost: String = descriptor["cost"]
	var reason: String = descriptor["reason"]
	var text: String = "%s\n%s" % [title, cost]
	if reason != "":
		text += "\n%s" % reason
	var tooltip: String = reason if reason != "" else "%s · %s" % [title, cost]
	card.set_meta("key", descriptor["key"])
	card.set_meta("tower_index", descriptor["tower_index"])
	card.set_meta("use_alt", descriptor["use_alt"])
	card.set_meta("tool", descriptor["tool"])
	if card.text != text:
		card.text = text
	if card.tooltip_text != tooltip:
		card.tooltip_text = tooltip
	if descriptor["icon"] is Texture2D and card.icon != descriptor["icon"]:
		card.icon = descriptor["icon"]
	card.disabled = reason != ""


func _on_catalog_card_pressed(card: Button) -> void:
	var tower_index: int = card.get_meta("tower_index", -1)
	if tower_index >= 0:
		_on_tower_card_pressed(tower_index, card.get_meta("use_alt", false))
	else:
		_on_infrastructure_card_pressed(card.get_meta("tool", &""))


func _on_tower_card_pressed(index: int, use_alt_payment: bool) -> void:
	tower_chosen.emit(index, use_alt_payment)
	close_catalog()


func _on_infrastructure_card_pressed(tool: StringName) -> void:
	infrastructure_tool_chosen.emit(tool, &"")
	close_catalog()


func _catalog_virtual_mm(millimeters: float) -> float:
	var minimum_mm: float = float(_config.get_value("flotante_min_mm"))
	var fallback: float = float(_config.get_value("flotante_min_px")) * millimeters / minimum_mm
	if not OS.has_feature("mobile"):
		return fallback
	var dpi: float = float(DisplayServer.screen_get_dpi())
	var canvas_scale: float = get_viewport().get_stretch_transform().x.length() * get_viewport().get_window().content_scale_factor
	return millimeters * dpi / 25.4 / canvas_scale if dpi > 0.0 and canvas_scale > 0.0 else fallback


func show_placement(world_position: Vector2, cost_text: String, valid: bool, reason: String,
		ghost_size: Vector2 = Vector2.ONE * Rules.TILE_SIZE) -> void:
	_world_position = world_position
	_ghost_size = ghost_size
	_ghost_visible = true
	_confirm_button.disabled = not valid
	_confirm_button.tooltip_text = "Confirmar construcción" if valid else reason
	_status_label.text = _ghost_status_text if valid else "%s  ·  %s" % [_ghost_status_text, reason]
	_cancel_button.tooltip_text = "Cancelar construcción"
	_bottom_confirm.visible = true
	_bottom_cancel.visible = true
	_bottom_confirm.disabled = _confirm_button.disabled
	set_placement_visible(true)
	_update_placement_position()
	_update_floating_layout()


func set_placement_visible(enabled: bool) -> void:
	_ghost_visible = enabled
	if _confirm_button != null:
		_confirm_button.visible = enabled
	if _cancel_button != null:
		_cancel_button.visible = enabled
	if _cart_button != null:
		var opacity: float = float(_config.get_value("opacidad_con_fantasma")) if enabled else 1.0
		for button: Button in [_cart_button, _exit_button, _demolish_button]:
			button.modulate.a = opacity
	if not enabled:
		if _bottom_confirm != null:
			_bottom_confirm.hide()
			_bottom_cancel.hide()
		_update_floating_layout()


func show_view_all(enabled: bool) -> void:
	if _view_all_button != null:
		_view_all_button.visible = enabled


## M68 (RF-610, RF-611, D-160): en pausa el carrito y el botón de demolición quedan apagados (se ven grises) y no
## hacen nada; si el catálogo estaba abierto, se cierra. Al seguir, vuelven. Los botones se pueden seguir arrastrando.
func set_paused(paused: bool) -> void:
	if _paused == paused:
		return
	_paused = paused
	if paused:
		clear_upgrade_arm()
		close_catalog()
	for button: Button in [_cart_button, _demolish_button]:
		if button != null:
			button.disabled = paused
	if _status_state == "empty":
		_status_label.text = PAUSED_TEXT if paused else EMPTY_TEXT


func is_paused() -> bool:
	return _paused


## Un toque en un botón apagado por la pausa explica por qué; si hay una torre elegida, la línea no se pisa.
func _show_paused_hint() -> void:
	if _status_state == "empty":
		_status_label.text = PAUSED_TEXT
		_status_label.visible = true


func set_cart_active(active: bool) -> void:
	if _cart_button != null:
		_cart_button.self_modulate = Color("#ffe0a0") if active else Color.WHITE


## RF-542: el botón de demolición solo existe en los niveles con removibles o puntos de extracción.
func set_demolish_available(available: bool) -> void:
	if _demolish_available == available:
		return
	_demolish_available = available
	_update_floating_visibility()
	_resolve_button_collision()
	_update_floating_layout()


func set_demolish_active(active: bool) -> void:
	if _demolish_button != null:
		_demolish_button.self_modulate = Color("#ffe0a0") if active else Color.WHITE


func set_game_over(over: bool) -> void:
	_game_over = over
	if over:
		clear_sell_arm()
		close_catalog()
	_update_floating_visibility()


func set_modal_open(open: bool) -> void:
	_modal_open = open
	if open:
		clear_sell_arm()
	_update_floating_visibility()


func _update_floating_visibility() -> void:
	_cart_button.visible = not _game_over and not _modal_open
	_exit_button.visible = not _game_over and not _modal_open
	_demolish_button.visible = _demolish_available and not _game_over and not _modal_open


## M63 (RF-574): el control que señala el tutorial (null si no existe o no se ve ahora). Nombres: `cart`,
## `first_card` (la primera torre que se puede elegir del catálogo abierto), `confirm` (la tilde: la que está
## junto al fantasma o, si no se ve, la de la barra de abajo), `upgrade` y `sell`.
func target_control(target: StringName) -> Control:
	var control: Control = null
	match target:
		&"cart":
			control = _cart_button
		&"first_card":
			if _catalog_open and _tower_grid != null:
				for card: Node in _tower_grid.get_children():
					if int((card as Button).get_meta("tower_index", -1)) >= 0 and not (card as Button).disabled:
						control = card as Button
						break
		&"confirm":
			control = _confirm_button if _confirm_button != null and _confirm_button.is_visible_in_tree() else _bottom_confirm
		&"upgrade":
			control = _upgrade_button
		&"sell":
			control = _sell_button
	return control if control != null and control.is_visible_in_tree() else null


## M65, RF-592: los rectángulos de pantalla (píxeles virtuales) que el texto de una mejora no puede pisar: la barra
## de abajo, la tilde, la cruz y los botones flotantes. Solo cuenta los que se ven ahora.
func forbidden_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for control: Control in [_status_bar, _confirm_button, _cancel_button, _bottom_confirm, _bottom_cancel,
			_cart_button, _exit_button, _demolish_button, _view_all_button]:
		if control != null and control.is_visible_in_tree():
			rects.append(control.get_global_rect())
	return rects


func is_catalog_open() -> bool:
	return _catalog_open


## Hay tarjetas ya armadas (el primer armado se hace aun cerrado; después solo se actualiza abierto).
func is_catalog_populated() -> bool:
	return _catalog_populated


func open_catalog() -> void:
	if _paused:
		return  # M68 (RF-610): con la partida en pausa no se elige torre
	clear_sell_arm()
	_catalog_open = true
	_catalog_scroll.scroll_vertical = 0  # RF-540: siempre abre en la primera fila
	_catalog_dim.show()
	_catalog_panel.show()
	catalog_opened.emit(true)


func close_catalog() -> void:
	if not _catalog_open:
		return
	_catalog_open = false
	_catalog_dim.hide()
	_catalog_panel.hide()
	catalog_opened.emit(false)


func is_interactive_at(screen_pos: Vector2) -> bool:
	if _catalog_open and (_catalog_panel.get_global_rect().has_point(screen_pos) or _catalog_dim.get_global_rect().has_point(screen_pos)):
		return true
	for button: Button in [_confirm_button, _cancel_button, _view_all_button, _cart_button, _exit_button,
			_demolish_button, _upgrade_button, _target_button, _sell_button]:
		if button != null and button.visible and button.get_global_rect().has_point(screen_pos):
			return true
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and _catalog_open:
		close_catalog()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		_pointer_filter.note_touch(touch.position, Time.get_ticks_msec())
		if not _catalog_open and _handle_status_touch(touch.index, touch.position, touch.pressed):
			return
		_handle_drag_touch(touch.index, touch.position, touch.pressed)
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if _status_touch_button != null and drag.index == _status_touch_index:
			_status_touch_moved = _status_touch_moved or drag.position.distance_to(_status_touch_start) > float(_config.get_value("toque_max_px"))
			get_viewport().set_input_as_handled()
			return
		if _drag_button != null and drag.index == _drag_index:
			_update_drag(drag.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		# RF-552: manda el dispositivo, no la plataforma. El clic emulado de un toque se descarta (el toque ya
		# actuó); un mouse real, también en Android, hace de dedo.
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if not _pointer_filter.accepts_mouse(mouse.device, mouse.position, Time.get_ticks_msec()):
				return
			if not _catalog_open and _handle_status_touch(PointerFilter.MOUSE_FINGER, mouse.position, mouse.pressed):
				return
			_handle_drag_touch(PointerFilter.MOUSE_FINGER, mouse.position, mouse.pressed)
	elif event is InputEventMouseMotion and _status_touch_button != null:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		if not _pointer_filter.accepts_mouse(motion.device, motion.position, Time.get_ticks_msec()):
			return
		_status_touch_moved = _status_touch_moved or motion.position.distance_to(_status_touch_start) > float(_config.get_value("toque_max_px"))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _drag_button != null:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		if not _pointer_filter.accepts_mouse(motion.device, motion.position, Time.get_ticks_msec()):
			return
		_update_drag(motion.position)
		get_viewport().set_input_as_handled()


func _handle_status_touch(index: int, pos: Vector2, pressed: bool) -> bool:
	if pressed:
		for button: Button in [_confirm_button, _cancel_button, _bottom_confirm, _bottom_cancel, _target_button, _upgrade_button, _sell_button]:
			if button != null and button.visible and button.get_global_rect().has_point(pos):
				_status_touch_button = button
				_status_touch_index = index
				_status_touch_start = pos
				_status_touch_moved = false
				get_viewport().set_input_as_handled()
				return true
		return false
	if _status_touch_button == null or _status_touch_index != index:
		return false
	var button: Button = _status_touch_button
	_status_touch_button = null
	_status_touch_index = -1
	if not _status_touch_moved and button.visible and not button.disabled and button.get_global_rect().has_point(pos):
		button.pressed.emit()
	get_viewport().set_input_as_handled()
	return true


func _handle_drag_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		if _drag_button != null:
			return
		if _catalog_open and not _catalog_panel.get_global_rect().has_point(pos):
			close_catalog()
			get_viewport().set_input_as_handled()
			return
		var button: Button = _float_button_at(pos)
		if button == null:
			return
		_drag_button = button
		_drag_index = index
		_drag_start = pos
		_drag_start_position = button.position
		_dragging = false
		get_viewport().set_input_as_handled()
		return
	if _drag_button == null or _drag_index != index:
		return
	if _dragging:
		_finish_drag(pos)
	else:
		if _drag_button.get_global_rect().has_point(pos):
			if _drag_button == _cart_button:
				_on_cart_pressed()
			elif _drag_button == _demolish_button:
				if _paused:
					_show_paused_hint()
				else:
					demolish_pressed.emit()
			else:
				exit_pressed.emit()
	_drag_button = null
	_drag_index = -1
	_dragging = false
	get_viewport().set_input_as_handled()


func _float_button_at(pos: Vector2) -> Button:
	if _cart_button.visible and _cart_button.get_global_rect().has_point(pos):
		return _cart_button
	if _exit_button.visible and _exit_button.get_global_rect().has_point(pos):
		return _exit_button
	if _demolish_button.visible and _demolish_button.get_global_rect().has_point(pos):
		return _demolish_button
	return null


func _update_drag(pos: Vector2) -> void:
	var threshold: float = float(_config.get_value("toque_max_px"))
	if not _dragging and pos.distance_to(_drag_start) <= threshold:
		return
	_dragging = true
	var bounds := Rect2(0.0, float(_config.get_value("barra_alta_px")), Rules.SCREEN_SIZE.x,
		Rules.SCREEN_SIZE.y - float(_config.get_value("barra_alta_px")) - float(_config.get_value("barra_baja_px")))
	var next: Vector2 = pos - _float_button_size / 2.0
	_drag_button.position = Vector2(clampf(next.x, bounds.position.x, bounds.end.x - _float_button_size.x),
		clampf(next.y, bounds.position.y, bounds.end.y - _float_button_size.y))
	get_viewport().set_input_as_handled()


func _finish_drag(pos: Vector2) -> void:
	var snap: Dictionary = FloatButtonLayout.snap(pos, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")), _float_button_size)
	var side: String = String(snap["side"])
	var y: float = float(snap["y"])
	var snapped_position: Vector2 = FloatButtonLayout.position_for(side, y, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")), _float_button_size)
	# Otros cambios del HUD (por ejemplo, el aviso «Ver todo») pueden haber actualizado las preferencias
	# después de crear este nodo. Partimos del guardado vigente para no pisar campos ajenos al movimiento.
	_prefs = SaveManager.get_ui_prefs()
	if _drag_button == _cart_button:
		_prefs.cart_side = side
		_prefs.cart_y = y
		_base_positions[0] = snapped_position
	elif _drag_button == _demolish_button:
		_prefs.demolish_side = side
		_prefs.demolish_y = y
		_base_positions[2] = snapped_position
	else:
		_prefs.exit_side = side
		_prefs.exit_y = y
		_base_positions[1] = snapped_position
	SaveManager.set_ui_prefs(_prefs)
	_resolve_button_collision()
	_apply_float_positions(_base_positions.duplicate(), false)


## Los botones que cuentan para acomodarse: el carrito y la salida siempre, la demolición solo si el nivel la tiene.
func _active_float_indices() -> Array[int]:
	var indices: Array[int] = [0, 1]
	if _demolish_available:
		indices.append(2)
	return indices


func _float_sides() -> Array[String]:
	return [_prefs.cart_side, _prefs.exit_side, _prefs.demolish_side]


## Acomoda los botones y devuelve las posiciones de los tres (el inactivo conserva la suya).
func _arranged_positions(ghost_rect: Rect2, distance: float) -> Array[Vector2]:
	var indices: Array[int] = _active_float_indices()
	var rects: Array[Rect2] = []
	var sides: Array[String] = []
	for index: int in indices:
		rects.append(Rect2(_base_positions[index], _float_button_size))
		sides.append(_float_sides()[index])
	var results: Array[Vector2] = FloatButtonLayout.avoid(ghost_rect, rects, sides, Rules.SCREEN_SIZE,
		float(_config.get_value("barra_alta_px")), float(_config.get_value("barra_baja_px")),
		_float_button_size, distance)
	var positions: Array[Vector2] = _base_positions.duplicate()
	for i: int in indices.size():
		positions[indices[i]] = results[i]
	return positions


func _resolve_button_collision() -> void:
	_base_positions = _arranged_positions(Rect2(Vector2(-1000.0, -1000.0), Vector2.ZERO), 0.0)


func _apply_saved_positions() -> void:
	var top: float = float(_config.get_value("barra_alta_px"))
	var bottom: float = float(_config.get_value("barra_baja_px"))
	_base_positions = [
		FloatButtonLayout.position_for(_prefs.cart_side, _prefs.cart_y, Rules.SCREEN_SIZE, top, bottom, _float_button_size),
		FloatButtonLayout.position_for(_prefs.exit_side, _prefs.exit_y, Rules.SCREEN_SIZE, top, bottom, _float_button_size),
		FloatButtonLayout.position_for(_prefs.demolish_side, _prefs.demolish_y, Rules.SCREEN_SIZE, top, bottom, _float_button_size)]
	_resolve_button_collision()
	_apply_float_positions(_base_positions.duplicate(), false)


func _apply_float_positions(targets: Array[Vector2], animate: bool) -> void:
	var buttons: Array[Button] = [_cart_button, _exit_button, _demolish_button]
	var unchanged: bool = true
	for i: int in 3:
		unchanged = unchanged and targets[i].is_equal_approx(_target_positions[i])
	if unchanged:
		return
	_target_positions = targets.duplicate()
	if _layout_tween != null and _layout_tween.is_running():
		_layout_tween.kill()
	var duration: float = float(_config.get_value("corrimiento_s")) if animate else 0.0
	var moves: bool = false
	for i: int in 3:
		moves = moves or not buttons[i].position.is_equal_approx(targets[i])
	if animate and moves:
		_layout_tween = create_tween()
		_layout_tween.set_parallel(true)
		for i: int in 3:
			_layout_tween.tween_property(buttons[i], "position", targets[i], duration)
	else:
		for i: int in 3:
			buttons[i].position = targets[i]


func _update_floating_layout() -> void:
	if _cart_button == null:
		return
	if not _ghost_visible:
		_apply_float_positions(_base_positions.duplicate(), true)
		return
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _world_position
	var ghost_rect := Rect2(screen_pos - _ghost_size / 2.0, _ghost_size)
	_apply_float_positions(_arranged_positions(ghost_rect, float(_config.get_value("fantasma_distancia_botones"))), true)


func _on_cart_pressed() -> void:
	if _paused:
		if _catalog_open:
			close_catalog()
		_show_paused_hint()
		return
	if _catalog_open:
		close_catalog()
	else:
		open_catalog()


func _process(delta: float) -> void:
	if _upgrade_lock_left > 0.0:
		_upgrade_lock_left = maxf(0.0, _upgrade_lock_left - delta)
	if _sell_armed:
		_sell_elapsed += delta
		_sell_arm_left -= delta
		if _sell_arm_left <= 0.0:
			clear_sell_arm()
	if _ghost_visible:
		_update_placement_position()
		_update_floating_layout()


func _update_placement_position() -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _world_position
	var separation: float = float(_config.get_value("gestos_separacion_px"))
	var confirm_size: Vector2 = _confirm_button.size
	var cancel_size: Vector2 = _cancel_button.size
	var above: float = float(_config.get_value("fantasma_botones_arriba_px"))
	var float_rects: Array[Rect2] = [Rect2(_cart_button.position, _float_button_size), Rect2(_exit_button.position, _float_button_size)]
	if _demolish_available:
		float_rects.append(Rect2(_demolish_button.position, _float_button_size))
	var side: String = FloatButtonLayout.tick_side(Rect2(screen_pos - _ghost_size / 2.0, _ghost_size),
		float_rects, Rules.SCREEN_SIZE.x, float(_config.get_value("flotante_min_px")))
	if side == "right":
		_confirm_button.position = screen_pos + Vector2(separation / 2.0, -confirm_size.y - above)
		_cancel_button.position = screen_pos + Vector2(separation / 2.0 + confirm_size.x + separation, -cancel_size.y - above)
	else:
		_confirm_button.position = screen_pos + Vector2(-separation / 2.0 - confirm_size.x, -confirm_size.y - above)
		_cancel_button.position = screen_pos + Vector2(-separation / 2.0 - confirm_size.x - separation - cancel_size.x, -cancel_size.y - above)
	_clamp_placement_buttons(screen_pos)


## Mantiene la tilde y la cruz dentro del área del mapa (entre las barras y los bordes de la pantalla),
## juntas. Si arriba del fantasma no entran, pasan abajo (T291, H-06): así nunca pisan los botones de la
## barra de arriba y un toque tiene un solo dueño (RF-504 punto 5).
func _clamp_placement_buttons(screen_pos: Vector2) -> void:
	var top: float = float(_config.get_value("barra_alta_px"))
	var bottom: float = Rules.SCREEN_SIZE.y - float(_config.get_value("barra_baja_px"))
	var above: float = float(_config.get_value("fantasma_botones_arriba_px"))
	var height: float = maxf(_confirm_button.size.y, _cancel_button.size.y)
	var delta_y: float = 0.0
	if _confirm_button.position.y < top:
		var below_y: float = screen_pos.y + _ghost_size.y / 2.0 + above
		if below_y + height <= bottom:
			delta_y = below_y - _confirm_button.position.y
	_confirm_button.position.y += delta_y
	_cancel_button.position.y += delta_y
	var min_y: float = minf(_confirm_button.position.y, _cancel_button.position.y)
	var max_y: float = maxf(_confirm_button.position.y + _confirm_button.size.y, _cancel_button.position.y + _cancel_button.size.y)
	var shift_y: float = 0.0
	if min_y < top:
		shift_y = top - min_y
	elif max_y > bottom:
		shift_y = bottom - max_y
	_confirm_button.position.y += shift_y
	_cancel_button.position.y += shift_y
	var left: float = minf(_confirm_button.position.x, _cancel_button.position.x)
	var right: float = maxf(_confirm_button.position.x + _confirm_button.size.x, _cancel_button.position.x + _cancel_button.size.x)
	var shift_x: float = 0.0
	if left < 0.0:
		shift_x = -left
	elif right > Rules.SCREEN_SIZE.x:
		shift_x = Rules.SCREEN_SIZE.x - right
	_confirm_button.position.x += shift_x
	_cancel_button.position.x += shift_x
