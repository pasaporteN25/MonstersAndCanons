# Panel de la torre seleccionada (RF-70, RF-74, RF-76): nivel, estadísticas,
# modo de apuntado y botones Mejorar / Vender. Solo MUESTRA y AVISA: no cobra ni vende.
class_name TowerPanel
extends PanelContainer

signal upgrade_pressed
signal sell_pressed
signal targeting_pressed
signal close_pressed

var _tower: Tower
var _sell_value: int = 0
## RF-418: recursos que devuelve la venta.
var _sell_resources: int = 0
var _gold: int = 0
## RF-280: los segundos de aturdimiento que se muestran (para refrescar solo cuando cambian).
var _shown_stun: int = 0
var _shown_support: int = 0
var _shown_wear: float = 0.0
var _shown_repair: float = 0.0
## RF-317: las torres de este nivel, para decir con cuáles combina la seleccionada. Lo pone Game.
var partner_towers: Array[TowerData] = []

@onready var _title: Label = %Title
@onready var _stats: Label = %Stats
const UPGRADE_PREVIEW_TITLE: String = "Al nivel %d:"
const LEVEL_COLORS: Array[Color] = [Color("#94a8b9"), Color("#d7a45b"), Color("#f0d176")]
var _upgrade_preview: Label
var _upgrade_fx_config: UpgradeFxConfig
@onready var _damage: Label = %Damage
@onready var _rate: Label = %Rate
@onready var _range: Label = %Range
@onready var _air: Label = %Air
@onready var _details: ScrollContainer = %Details
@onready var _status: Label = %Status
@onready var _targeting_button: Button = %TargetingButton
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _sell_button: Button = %SellButton
@onready var _close_button: Button = %CloseButton
@onready var _level_card: HBoxContainer = %LevelCard


func _ready() -> void:
	visible = false
	_upgrade_button.pressed.connect(upgrade_pressed.emit)
	_sell_button.pressed.connect(sell_pressed.emit)
	_targeting_button.pressed.connect(targeting_pressed.emit)
	_close_button.pressed.connect(close_pressed.emit)
	_set_mouse_filters(self)
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


## M63 (RF-574): los botones que el tutorial señala.
func upgrade_button() -> Button:
	return _upgrade_button


func sell_button() -> Button:
	return _sell_button


## M68 (RF-616): encima de «Mejorar», lo que cambia al subir de nivel (antes → después). Se crea la primera vez.
func _refresh_upgrade_preview() -> void:
	if _upgrade_preview == null:
		_upgrade_preview = Label.new()
		_upgrade_preview.name = "UpgradePreview"
		_upgrade_preview.add_theme_font_size_override("font_size", 13)
		_upgrade_preview.add_theme_color_override("font_color", Color(0.75, 0.9, 0.6))
		_upgrade_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_upgrade_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_upgrade_button.get_parent().add_child(_upgrade_preview)
		_upgrade_button.get_parent().move_child(_upgrade_preview, _upgrade_button.get_index())
	if _upgrade_fx_config == null:
		_upgrade_fx_config = UpgradeFxConfig.load_from()
	var changes: Array[Dictionary] = UpgradeDeltas.preview(_tower.data.levels, _tower.level_index, _upgrade_fx_config.stats,
			int(_upgrade_fx_config.get_number("max_estadisticas")))
	var other_changes: Array[Dictionary] = []
	var damage_change: Dictionary = {}
	for change: Dictionary in changes:
		if String(change.get("campo", "")) == "damage":
			damage_change = change
		else:
			other_changes.append(change)
	if damage_change.is_empty():
		_damage.text = str(_tower.stats().damage)
	else:
		_damage.text = "%s %s %s" % [
			UpgradeDeltas.format_value(float(damage_change["antes"]), "entero"), UpgradeDeltas.ARROW,
			UpgradeDeltas.format_value(float(damage_change["despues"]), "entero"),
		]
	if other_changes.is_empty():
		_upgrade_preview.visible = false
		return
	var lines: Array[String] = [UPGRADE_PREVIEW_TITLE % (_tower.level_number() + 1)]
	lines.append_array(UpgradeDeltas.rows(other_changes, int(_upgrade_fx_config.get_number("max_por_renglon"))))
	_upgrade_preview.text = "\n".join(lines)
	_upgrade_preview.visible = true


func _refresh_level_card() -> void:
	var level: int = _tower.level_number()
	_level_card.tooltip_text = "Nivel actual: %d de 3" % level
	for index: int in _level_card.get_child_count():
		var segment: ColorRect = _level_card.get_child(index) as ColorRect
		var color: Color = LEVEL_COLORS[index]
		if index >= level:
			color = color.darkened(0.72)
			color.a = 0.6
		segment.color = color


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


func _style_buttons() -> void:
	_style_button(_targeting_button, Color("#48535d"))
	_style_button(_upgrade_button, Color("#526c4b"))
	_style_button(_sell_button, Color("#755144"))
	_style_button(_close_button, Color("#66533a"))


func _style_button(button: Button, base_color: Color) -> void:
	button.add_theme_color_override("font_color", Color("#f5f0df"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#a7a39b"))
	var normal: StyleBoxFlat = _button_style(base_color, 0.96)
	var hover: StyleBoxFlat = _button_style(base_color.lightened(0.16), 1.0)
	var pressed: StyleBoxFlat = _button_style(base_color.darkened(0.16), 1.0)
	var disabled: StyleBoxFlat = _button_style(base_color.darkened(0.42), 0.62)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)


func _button_style(color: Color, alpha: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, alpha)
	style.border_color = color.lightened(0.18)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style


func refresh(gold: int) -> void:
	if _tower == null:
		return
	_gold = gold
	var s: TowerLevelData = _tower.stats()
	_shown_stun = ceili(_tower.stun_left())
	_title.text = _tower.data.display_name
	_title.tooltip_text = _title.text
	_refresh_level_card()
	_shown_wear = _tower.wear_percent
	_shown_repair = _tower.repair_rate_received
	var states: PackedStringArray = []
	if _shown_stun > 0:
		states.append("Aturdida (%d s)" % _shown_stun)
	if _shown_wear > 0.0:
		states.append("Desgaste %.0f %%" % _shown_wear)
	_status.visible = not states.is_empty()
	_status.text = " · ".join(states)
	_shown_support = _tower.support_bonus()
	_rate.text = "Apoyo" if _tower.data.support_only else "%.2f/s" % _tower.effective_fire_rate()
	_range.text = "%.1f" % s.range_tiles
	_air.text = "Voladores: %s" % ("sí" if _tower.data.can_hit_air else "no")
	_stats.text = "\n".join(TowerText.effects(s))
	var invested: String = TowerText.invested_line(_tower.data, _tower.resources_invested)  # RF-418
	if invested != "":
		_stats.text += "\n" + invested
	if _shown_repair > 0:
		_stats.text += "\nReparación recibida: %.1f puntos/s" % _shown_repair
	if _tower.data.support_only and _shown_wear > 0:
		_stats.text += "\nPrestaciones actuales: %.0f %%" % (WearRules.ratio(_shown_wear) * 100.0)
	if _shown_support > 0:
		_stats.text += "\nApoyo recibido: +%d %% cadencia" % _shown_support
	for line: String in TowerText.combo_partners(_tower.data, partner_towers):  # RF-317
		# Espacio que no corta: si la línea no entra, que no quede "+25" arriba y "%" abajo.
		_stats.text += "\n" + line.replace(" %", " %")
	_stats.text = _stats.text.strip_edges()
	_stats.visible = not _stats.text.is_empty()
	_targeting_button.disabled = _tower.data.support_only or _tower.is_pulse_tower()  # RF-438: el pulso no apunta
	_targeting_button.text = "Apuntar: %s" % _tower.targeting_name()
	var next: TowerLevelData = _tower.next_level_stats()
	_refresh_upgrade_preview()
	if next == null:
		_upgrade_button.text = "Nivel máximo"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "Mejorar a nivel %d (%d)  [U]" % [_tower.level_number() + 1, next.cost]
		_upgrade_button.disabled = gold < next.cost
	_upgrade_button.tooltip_text = "Nivel máximo alcanzado" if next == null else ("Faltan %d de oro" % (next.cost - gold) if gold < next.cost else "Mejorar torre · U")
	_sell_button.text = "Vender (+%s)  [S]" % TowerText.refund_text(_sell_value, _sell_resources)
