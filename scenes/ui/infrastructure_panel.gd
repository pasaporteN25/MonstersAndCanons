# Panel global de compra de la demoledora (RF-411 y RF-412).
class_name InfrastructurePanel
extends Control

signal buy_pressed

var _button: Button
var _panel: PanelContainer
var _status: Label
var _buy_button: Button
var _price: int = 0
var _gold: int = 0
var _owned: bool = false


func _ready() -> void:
	_button = Button.new()
	_button.text = "Infraestructura"
	_button.position = Vector2(1030, 5)
	_button.size = Vector2(230, 38)
	_button.pressed.connect(_toggle_panel)
	add_child(_button)
	_panel = PanelContainer.new()
	_panel.theme = preload("res://assets/ui/menu_theme.tres")
	_panel.add_theme_stylebox_override("panel", preload("res://assets/ui/game_panel_style.tres"))
	_panel.position = Vector2(1000, 52)
	_panel.size = Vector2(260, 132)
	_panel.visible = false
	add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	for side: String in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	_panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	margin.add_child(rows)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_status)
	_buy_button = Button.new()
	_buy_button.custom_minimum_size = Vector2(0, 36)
	_buy_button.pressed.connect(buy_pressed.emit)
	rows.add_child(_buy_button)
	visible = false


## Solo se muestra si el nivel habilita la máquina.
func setup(enabled: bool, price: int, gold: int, owned: bool) -> void:
	visible = enabled
	_price = price
	_gold = gold
	_owned = owned
	_refresh()


func update_state(gold: int, owned: bool) -> void:
	_gold = gold
	_owned = owned
	_refresh()


func update_gold(gold: int) -> void:
	_gold = gold
	_refresh()


func _refresh() -> void:
	if _status == null:
		return
	_status.text = "Demoledora activa" if _owned else "Demoledora: %d de oro" % _price
	_buy_button.text = "Comprada" if _owned else "Comprar (%d)" % _price
	_buy_button.disabled = _owned or _gold < _price
	_buy_button.tooltip_text = "Demoledora activa" if _owned else "Te faltan %d de oro" % (_price - _gold) if _gold < _price else "Comprar la demoledora"


func _toggle_panel() -> void:
	_panel.visible = not _panel.visible
