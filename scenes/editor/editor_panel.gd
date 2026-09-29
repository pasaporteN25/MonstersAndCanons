# Base de los paneles del editor de mapas (ajustes y oleadas, spec §10.3): un recuadro que se abre
# encima del mapa, con título. Solo edita el borrador (LevelDraft) y avisa con `edited`; no revisa
# nada: eso lo hace MapEditor con LevelFile.
class_name EditorPanel
extends PanelContainer

## Se cambió algo desde el panel: el editor tiene que revisar el nivel y actualizar los mensajes.
signal edited

const PANEL_STYLE: StyleBox = preload("res://assets/ui/panel_style.tres")
const TITLE_COLOR := Color(1.0, 0.84, 0.3)
const HEADER_COLOR := Color(0.7, 0.72, 0.78)

var draft: LevelDraft
## true mientras el panel se llena a sí mismo desde el borrador: eso no es una edición.
var _filling: bool = false

var _body := VBoxContainer.new()
var _title_label := Label.new()


func _init() -> void:
	add_theme_stylebox_override("panel", PANEL_STYLE)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	_body.add_theme_constant_override("separation", 10)
	margin.add_child(_body)
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", TITLE_COLOR)
	_body.add_child(_title_label)


func set_title(text: String) -> void:
	_title_label.text = text


## Le da el borrador al panel y lo llena.
func bind(new_draft: LevelDraft) -> void:
	draft = new_draft
	refresh()


## Vuelve a llenar el panel con lo que hay en el borrador (por ejemplo, después de deshacer).
func refresh() -> void:
	_filling = true
	_fill()
	_filling = false


## Lo que cada panel llena. `_filling` está en true: los controles no cuentan como ediciones.
func _fill() -> void:
	pass


func _header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", HEADER_COLOR)
	label.add_theme_font_size_override("font_size", 14)
	return label


## Un número editable. `on_change` recibe el valor nuevo (solo cuando lo cambia la persona).
func _spin(minimum: float, maximum: float, step: float, suffix: String, on_change: Callable) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.suffix = suffix
	spin.select_all_on_focus = true
	spin.value_changed.connect(func(value: float) -> void:
		if not _filling and draft != null:
			on_change.call(value)
			edited.emit())
	return spin
