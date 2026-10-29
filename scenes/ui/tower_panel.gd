# Panel de la torre seleccionada (RF-70, RF-74, RF-76; ficha PC-A de T513, RF-721, D-214): nivel, estadísticas,
# modo de apuntado y botones Mejorar / Vender. Solo MUESTRA y AVISA: no cobra ni vende.
# 270 px de ancho; el alto sale del contenido (tope `MAX_HEIGHT`) y la lista solo desplaza si lo pasa.
class_name TowerPanel
extends PanelContainer

signal upgrade_pressed
signal sell_pressed
signal targeting_pressed
signal close_pressed
## M75 (RF-680): el mouse entró o salió de «Mejorar». Game decide si hay algo que mostrar (oro, nivel máximo).
signal upgrade_hover_changed(hovered: bool)

var _tower: Tower
var _sell_value: int = 0
## RF-418: recursos que devuelve la venta.
var _sell_resources: int = 0
var _gold: int = 0
var _upgrade_hovered: bool = false
## RF-280: los segundos de aturdimiento que se muestran (para refrescar solo cuando cambian).
var _shown_stun: int = 0
var _shown_support: int = 0
var _shown_wear: float = 0.0
var _shown_repair: float = 0.0
## RF-317: las torres de este nivel, para decir con cuáles combina la seleccionada. Lo pone Game.
var partner_towers: Array[TowerData] = []

## RF-721: ancho fijo y tope del alto (px lógicos). Pasado el tope, y solo ahí, la lista desplaza.
const WIDTH: float = 270.0
const MAX_HEIGHT: float = 320.0
const LEVEL_COLORS: Array[Color] = [Color("#d7a45b"), Color("#94a8b9"), Color("#f0d176")]
## RF-721 punto 6: «Vender» conserva un borde ladrillo apagado para no confundirse con «Mejorar».
const SELL_BORDER: Color = Color(0.5, 0.26, 0.21)
const UPGRADE_BORDER: Color = Color(0.74, 0.52, 0.24)
const HALF_BUTTON_MARGIN: float = 6.0

var _upgrade_fx_config: UpgradeFxConfig
var _fit_queued: bool = false

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = $Margin/Rows
@onready var _stats: Label = %Stats
@onready var _facts: GridContainer = %Facts
@onready var _damage_caption: Label = %DamageCaption
@onready var _damage: Label = %Damage
@onready var _rate_caption: Label = %RateCaption
@onready var _rate: Label = %Rate
@onready var _range: Label = %Range
@onready var _air: TextureRect = %Air
@onready var _air_strike: Line2D = %AirStrike
@onready var _details: ScrollContainer = %Details
@onready var _content: VBoxContainer = %Content
@onready var _status: Label = %Status
@onready var _targeting_button: Button = %TargetingButton
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _upgrade_info: HBoxContainer = %UpgradeInfo
@onready var _missing: Label = %Missing
@onready var _cost: Label = %Cost
@onready var _key: Label = %Key
@onready var _sell_button: Button = %SellButton
@onready var _close_button: Button = %CloseButton
@onready var _level_card: HBoxContainer = %LevelCard


func _ready() -> void:
	visible = false
	Localization.apply(self, {"%DamageCaption": &"tower_panel.damage", "%RateCaption": &"tower_panel.rate", "%RangeCaption": &"tower_panel.range"})
	(%RangeCaption as Label).tooltip_text = Localization.t(&"tower_panel.range_tip")
	_close_button.tooltip_text = Localization.t(&"tower_panel.close_tip")
	_sell_button.tooltip_text = Localization.t(&"tower_panel.sell_tip")
	_upgrade_button.pressed.connect(upgrade_pressed.emit)
	_sell_button.pressed.connect(sell_pressed.emit)
	_targeting_button.pressed.connect(targeting_pressed.emit)
	_close_button.pressed.connect(close_pressed.emit)
	_upgrade_button.mouse_entered.connect(_set_upgrade_hovered.bind(true))
	_upgrade_button.mouse_exited.connect(_set_upgrade_hovered.bind(false))
	visibility_changed.connect(_on_visibility_changed)
	_title.resized.connect(_refresh_title_tooltip)
	_title.resized.connect(_queue_fit)
	_content.minimum_size_changed.connect(_queue_fit)
	_set_mouse_filters(self)
	# Los íconos con tooltip lo necesitan: PASS no se queda con los clics, que siguen hacia el mapa (RF-74).
	_air.mouse_filter = Control.MOUSE_FILTER_PASS
	_level_card.mouse_filter = Control.MOUSE_FILTER_PASS
	_style_panel()
	_style_buttons()


## Muestra la torre (o se oculta si es null). `gold` decide si Mejorar está activo.
func show_tower(tower: Tower, sell_value: int, gold: int, sell_resources: int = 0) -> void:
	if tower != _tower:
		_details.scroll_vertical = 0
	_tower = tower
	_sell_value = sell_value
	_sell_resources = sell_resources
	visible = tower != null
	if tower != null:
		refresh(gold)


## RF-280: mientras la torre está aturdida, la cuenta atrás del título se va actualizando.
func _process(_delta: float) -> void:
	if _tower != null and visible and (ceili(_tower.stun_left()) != _shown_stun or _tower.support_bonus() != _shown_support or not is_equal_approx(_tower.wear_percent, _shown_wear) or not is_equal_approx(_tower.repair_rate_received,_shown_repair)):
		refresh(_gold)


## M75 (RF-680): ¿el mouse está sobre «Mejorar» y el botón está activo? Apagado (sin oro o nivel máximo) no cuenta.
func is_upgrade_hovered() -> bool:
	return _upgrade_hovered and visible and not _upgrade_button.disabled


func _set_upgrade_hovered(hovered: bool) -> void:
	if _upgrade_hovered == hovered:
		return
	_upgrade_hovered = hovered
	upgrade_hover_changed.emit(hovered)


## Si el panel se esconde con el mouse encima, no siempre llega el `mouse_exited`: se da por salido.
func _on_visibility_changed() -> void:
	if not visible:
		_set_upgrade_hovered(false)


## M63 (RF-574): los botones que el tutorial señala.
func upgrade_button() -> Button:
	return _upgrade_button


func sell_button() -> Button:
	return _sell_button


## RF-721 punto 3: Daño, Cadencia y Alcance son filas rótulo-valor y, si la mejora los cambia, dicen «antes → después».
## Una torre de apoyo no tiene Daño ni Cadencia (la fila no se muestra). Los efectos van en `_refresh_effects`.
func _refresh_metrics(next: TowerLevelData) -> void:
	if _upgrade_fx_config == null:
		_upgrade_fx_config = UpgradeFxConfig.load_from()
	var metric_changes: Dictionary = {}
	for change: Dictionary in UpgradeDeltas.preview(_tower.data.levels, _tower.level_index, _upgrade_fx_config.stats, 99):
		metric_changes[String(change.get("campo", ""))] = change
	var shoots: bool = not _tower.data.support_only
	for node: Control in [_damage_caption, _damage, _rate_caption, _rate]:
		node.visible = shoots
	_damage.text = _metric_text("damage", "entero", int(_tower.stats().damage), metric_changes)
	_rate.text = "%s/s" % _metric_text("fire_rate", "decimal", _tower.effective_fire_rate(), metric_changes)
	_range.text = _metric_text("range_tiles", "decimal", _tower.stats().range_tiles, metric_changes)


func _metric_text(field: String, kind: String, current: float, changes: Dictionary) -> String:
	if not changes.has(field):
		return UpgradeDeltas.format_value(current, kind)
	var change: Dictionary = changes[field]
	return "%s %s %s" % [UpgradeDeltas.format_value(float(change["antes"]), kind), UpgradeDeltas.ARROW,
		UpgradeDeltas.format_value(float(change["despues"]), kind)]


## RF-650 (T512): tres rectángulos en fila, bronce, plata y oro; los que faltan llevan el contorno del metal, sin relleno.
func _refresh_level_card() -> void:
	var level: int = _tower.level_number()
	_level_card.tooltip_text = Localization.t_fmt(&"tower_panel.level_tip", {"n": level})
	for index: int in _level_card.get_child_count():
		var segment: Panel = _level_card.get_child(index) as Panel
		segment.add_theme_stylebox_override("panel", _level_style(LEVEL_COLORS[index], index < level))


static func _level_style(color: Color, filled: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.draw_center = filled
	style.border_color = color if filled else color.darkened(0.12)
	style.set_border_width_all(2)
	style.set_corner_radius_all(2)
	return style


func _refresh_title_tooltip() -> void:
	_title.tooltip_text = _title.text if _title.get_line_count() > _title.get_visible_line_count() else ""


func _set_mouse_filters(node: Node) -> void:
	if node is Control:
		var control: Control = node as Control
		if control is Button:
			control.mouse_filter = Control.MOUSE_FILTER_STOP
		elif control is ScrollContainer:
			control.mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_set_mouse_filters(child)


func _style_panel() -> void:
	var panel_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel_style.bg_color.a = 0.82
	panel_style.border_color.a = 0.9
	add_theme_stylebox_override("panel", panel_style)


## RF-650 (T512), RF-721 punto 6: los botones son los del tema de los menús (hierro oscuro, borde bronce, texto ámbar
## con el mouse). Solo se ajustan los márgenes de los chicos, el borde de «Vender» y el bronce más claro de «Mejorar».
func _style_buttons() -> void:
	_tune_button(_close_button, 4.0, Color.TRANSPARENT)
	_tune_button(_targeting_button, HALF_BUTTON_MARGIN, Color.TRANSPARENT)
	_tune_button(_sell_button, HALF_BUTTON_MARGIN, SELL_BORDER)
	_tune_button(_upgrade_button, 12.0, UPGRADE_BORDER)
	for button: Button in [_targeting_button, _sell_button, _upgrade_button, _close_button]:
		button.add_theme_constant_override("outline_size", 0)


func _tune_button(button: Button, margin: float, border: Color) -> void:
	for state: String in ["normal", "disabled"]:
		var style: StyleBoxFlat = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.content_margin_left = margin
		style.content_margin_right = margin
		if border.a > 0.0:
			style.border_color = border if state == "normal" else border.darkened(0.5)
		button.add_theme_stylebox_override(state, style)
	for state: String in ["hover", "pressed", "hover_pressed"]:
		var style: StyleBoxFlat = button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.content_margin_left = margin
		style.content_margin_right = margin
		button.add_theme_stylebox_override(state, style)


## RF-721 punto 1: el alto sale del contenido. La lista (`Details`) toma el alto de lo que contiene y solo desplaza
## si todo el panel pasaría de `MAX_HEIGHT`. El borde de abajo queda fijo y el panel crece hacia arriba.
func _queue_fit() -> void:
	if _fit_queued:
		return
	_fit_queued = true
	_fit_height.call_deferred()


func _fit_height() -> void:
	_fit_queued = false
	if not is_inside_tree() or not visible or _tower == null:
		return
	_details.custom_minimum_size.y = 0.0
	var chrome: float = get_combined_minimum_size().y
	var wanted: float = minf(_content.get_combined_minimum_size().y, maxf(MAX_HEIGHT - chrome, 0.0))
	if absf(_details.custom_minimum_size.y - wanted) > 0.01:
		_details.custom_minimum_size.y = wanted
	var top: float = offset_bottom - (chrome + wanted)
	if absf(offset_top - top) > 0.01:
		offset_top = top


func refresh(gold: int) -> void:
	if _tower == null:
		return
	_gold = gold
	var s: TowerLevelData = _tower.stats()
	var next: TowerLevelData = _tower.next_level_stats()
	_shown_stun = ceili(_tower.stun_left())
	_title.text = _tower.data.name_text()
	_refresh_title_tooltip()
	_refresh_level_card()
	_shown_wear = _tower.wear_percent
	_shown_repair = _tower.repair_rate_received
	var states: PackedStringArray = []
	if _shown_stun > 0:
		states.append(Localization.t_fmt(&"tower_panel.status_stunned", {"n": _shown_stun}))
	if _shown_wear > 0.0:
		states.append(Localization.t_fmt(&"tower_panel.status_wear", {"n": "%.0f" % _shown_wear}))
	_status.visible = not states.is_empty()
	_status.text = " · ".join(states)
	_shown_support = _tower.support_bonus()
	# RF-721 punto 2: «Voladores» es un ícono con tooltip en el encabezado, tachado si la torre no los golpea.
	_air.tooltip_text = Localization.t(&"tower_panel.hits_air" if _tower.data.can_hit_air else &"tower_panel.no_air")
	_air.modulate = Color.WHITE if _tower.data.can_hit_air else Color(0.62, 0.62, 0.62, 0.7)
	_air_strike.visible = not _tower.data.can_hit_air
	_refresh_metrics(next)
	# RF-721 punto 4: la frase de cada efecto lleva su cambio adentro (una función de TowerText, un solo lugar).
	var effect_lines: Array[String] = TowerText.effect_phrases(s, next)
	_stats.text = "\n".join(effect_lines)
	var invested: String = TowerText.invested_line(_tower.data, _tower.resources_invested)  # RF-418
	if invested != "":
		_stats.text += "\n" + invested
	if _shown_repair > 0:
		_stats.text += "\n" + Localization.t_fmt(&"tower_panel.repair_received", {"x": TowerText.decimal(_shown_repair)})
	if _tower.data.support_only and _shown_wear > 0:
		_stats.text += "\n" + Localization.t_fmt(&"tower_panel.performance", {"n": "%.0f" % (WearRules.ratio(_shown_wear) * 100.0)})
	if _shown_support > 0:
		_stats.text += "\n" + Localization.t_fmt(&"tower_panel.support_received", {"n": _shown_support})
	for line: String in TowerText.combo_partners(_tower.data, partner_towers):  # RF-317
		# Espacio que no corta: si la línea no entra, que no quede "+25" arriba y "%" abajo.
		_stats.text += "\n" + line.replace(" %", " %")
	_stats.text = _stats.text.strip_edges()
	_stats.visible = not _stats.text.is_empty()
	# RF-721 punto 5: una torre que no apunta (apoyo, pulso: RF-438) no muestra «Apuntar», ni apagado.
	_targeting_button.visible = not (_tower.data.support_only or _tower.is_pulse_tower())
	_targeting_button.text = _tower.targeting_name()
	_targeting_button.tooltip_text = Localization.t_fmt(&"tower_panel.aim_tip", {"mode": _tower.targeting_name()})
	_refresh_upgrade_button(next, gold)
	_sell_button.text = Localization.t_fmt(&"tower_panel.sell", {"x": TowerText.refund_text(_sell_value, _sell_resources)})
	_queue_fit()


## RF-721 punto 7: «Mejorar a nivel N» con la moneda y el costo y la tecla; sin oro queda apagado y dice «faltan N» a la vista.
func _refresh_upgrade_button(next: TowerLevelData, gold: int) -> void:
	if next == null:
		_upgrade_button.text = Localization.t(&"tower_panel.max_level")
		_upgrade_button.disabled = true
		_upgrade_info.visible = false
		_upgrade_button.tooltip_text = Localization.t(&"tower_panel.max_level_tip")
		return
	var short: int = next.cost - gold
	_upgrade_button.text = Localization.t_fmt(&"tower_panel.upgrade_to", {"n": _tower.level_number() + 1})
	_upgrade_button.disabled = short > 0
	_upgrade_info.visible = true
	_cost.text = str(next.cost)
	_missing.visible = short > 0
	_missing.text = Localization.t_fmt(&"tower_panel.missing", {"n": maxi(short, 0)})
	_key.visible = short <= 0
	_upgrade_button.tooltip_text = Localization.t_fmt(&"tower_panel.missing_gold", {"n": short}) if short > 0 else Localization.t(&"tower_panel.upgrade_tip")
