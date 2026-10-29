# Objetos del mapa (spec RF-434, RF-435): los valores de cada removible y de cada punto de extracción que
# hay en la leyenda. Se elige una letra y se sobrescribe lo que cambia para TODAS las casillas con esa letra;
# lo que no se toca sale de la clase (data/obstaculos.json), que el panel muestra como valor por omisión.
# El hallazgo de una ruina solo se escribe en un nivel de la campaña (Q-31).
class_name ObjectsPanel
extends EditorPanel

const CLASS_NAME_KEYS: Dictionary = {
	"arbol": &"editor.class.arbol", "roca": &"editor.class.roca", "escombro": &"editor.class.escombro",
	"mina": &"editor.class.mina", "bosque_explotable": &"editor.class.bosque_explotable",
}
## Lo que se ve de cada dato: texto, sufijo, mínimo, máximo y paso.
const FIELD_LABEL_KEYS: Dictionary = {
	"costo": &"editor.field.costo", "tiempo": &"editor.field.tiempo", "recursos": &"editor.field.recursos", "probabilidad": &"editor.field.probabilidad",
	"produccion": &"editor.field.produccion", "reserva": &"editor.field.reserva",
}

var _letter: String = ""
var _letter_option := OptionButton.new()
var _empty_note: Label
var _fields_box := VBoxContainer.new()
var _field_rows: Dictionary = {}  # dato → {"label": Label, "spin": SpinBox}
var _finding_row := HBoxContainer.new()
var _finding_option := OptionButton.new()
var _finding_note: Label


## T534: lo que se ve de cada dato: sufijo según el idioma.
static func field_suffix(key: String) -> String:
	match key:
		"costo":
			return Localization.t(&"editor.suffix_gold")
		"tiempo":
			return Localization.t(&"editor.suffix_seconds")
		"probabilidad":
			return Localization.t(&"editor.suffix_percent")
	return ""


static func finding_locked_text() -> String:
	return Localization.t(&"editor.finding_locked")


func _init() -> void:
	super()
	set_title(Localization.t(&"editor.objects_title"))
	_empty_note = _header(Localization.t(&"editor.objects_empty"))
	_empty_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_note.custom_minimum_size = Vector2(380, 0)
	_body.add_child(_empty_note)
	_letter_option.custom_minimum_size = Vector2(300, 0)
	_letter_option.item_selected.connect(_on_letter_selected)
	_letter_option.tooltip_text = Localization.t(&"editor.letter_tip")
	_body.add_child(_letter_option)
	_fields_box.add_theme_constant_override("separation", 8)
	_body.add_child(_fields_box)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 8)
	_fields_box.add_child(grid)
	for key: String in ["costo", "tiempo", "recursos", "probabilidad", "produccion", "reserva"]:
		var label := Label.new()
		label.text = Localization.t(FIELD_LABEL_KEYS[key])
		var spin: SpinBox = _spin(0.0, LevelDraft.OBSTACLE_VALUE_MAX, 1.0, field_suffix(key),
			func(value: float) -> void: draft.set_obstacle_value(_letter, key, value))
		spin.name = "Spin_" + key
		grid.add_child(label)
		grid.add_child(spin)
		_field_rows[key] = {"label": label, "spin": spin}
	(_field_rows["tiempo"]["spin"] as SpinBox).step = 0.5
	(_field_rows["tiempo"]["spin"] as SpinBox).max_value = LevelDraft.OBSTACLE_TIME_MAX
	(_field_rows["probabilidad"]["spin"] as SpinBox).max_value = 100.0
	var finding_label := Label.new()
	finding_label.text = Localization.t(&"editor.finding_label")
	_finding_row.add_theme_constant_override("separation", 16)
	_finding_row.add_child(finding_label)
	_finding_option.item_selected.connect(_on_finding_selected)
	_finding_row.add_child(_finding_option)
	_fields_box.add_child(_finding_row)
	_finding_note = _header(finding_locked_text())
	_finding_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_finding_note.custom_minimum_size = Vector2(380, 0)
	_fields_box.add_child(_finding_note)
	var note := _header(Localization.t(&"editor.objects_note"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(380, 0)
	_fields_box.add_child(note)


func _fill() -> void:
	var letters: PackedStringArray = draft.obstacle_letters()
	_empty_note.visible = letters.is_empty()
	_letter_option.visible = not letters.is_empty()
	_fields_box.visible = not letters.is_empty()
	_letter_option.clear()
	if letters.is_empty():
		_letter = ""
		return
	if not letters.has(_letter):
		_letter = letters[0]
	for i: int in letters.size():
		var class_id: String = draft.obstacle_class(letters[i])
		_letter_option.add_item("%s · %s" % [letters[i], Localization.t(CLASS_NAME_KEYS[class_id]) if CLASS_NAME_KEYS.has(class_id) else class_id])
		_letter_option.set_item_metadata(i, letters[i])
		if letters[i] == _letter:
			_letter_option.select(i)
	_fill_fields()


func _fill_fields() -> void:
	var fields: PackedStringArray = draft.obstacle_fields(_letter)
	for key: String in _field_rows:
		var shown: bool = fields.has(key)
		var label: Label = _field_rows[key]["label"]
		var spin: SpinBox = _field_rows[key]["spin"]
		label.visible = shown
		spin.visible = shown
		if not shown:
			continue
		spin.set_value_no_signal(draft.obstacle_value(_letter, key))
		var default_value: float = draft.obstacle_default(_letter, key)
		label.text = Localization.t_fmt(&"editor.field_with_class", {"field": Localization.t(FIELD_LABEL_KEYS[key]), "value": _shown_number(default_value)})
		spin.tooltip_text = Localization.t_fmt(&"editor.from_class_tip", {"value": _shown_number(default_value), "suffix": field_suffix(key)})
	_fill_finding()


func _fill_finding() -> void:
	var is_rubble: bool = draft.obstacle_category(_letter) == "removible" and draft.obstacle_class(_letter) == "escombro"
	_finding_row.visible = is_rubble
	_finding_note.visible = is_rubble and not draft.can_edit_finding(_letter)
	if not is_rubble:
		return
	_finding_option.clear()
	_finding_option.add_item(Localization.t(&"editor.no_finding"))
	_finding_option.set_item_metadata(0, "")
	var current: String = draft.finding(_letter)
	var known: Array[StringName] = CollectionDefinitions.ids()
	if current != "" and not known.has(StringName(current)):
		known.append(StringName(current))  # un hallazgo escrito a mano que no se reconoce se muestra igual: no se pierde
	for id: StringName in known:
		_finding_option.add_item(CollectionDefinitions.name_of(id) if CollectionDefinitions.exists(id) else String(id))
		_finding_option.set_item_metadata(_finding_option.item_count - 1, String(id))
		if String(id) == current:
			_finding_option.select(_finding_option.item_count - 1)
	if current == "":
		_finding_option.select(0)
	_finding_option.disabled = not draft.can_edit_finding(_letter)
	_finding_option.tooltip_text = finding_locked_text() if _finding_option.disabled else Localization.t(&"editor.finding_tip")


func _on_letter_selected(index: int) -> void:
	_letter = str(_letter_option.get_item_metadata(index))
	_filling = true
	_fill_fields()
	_filling = false


func _on_finding_selected(index: int) -> void:
	if _filling or draft == null:
		return
	if draft.set_finding(_letter, str(_finding_option.get_item_metadata(index))):
		edited.emit()


## La letra que se está editando ("" si no hay objetos).
func selected_letter() -> String:
	return _letter


func select_letter(letter: String) -> void:
	var letters: PackedStringArray = draft.obstacle_letters()
	if letters.has(letter):
		_letter = letter
		refresh()


func spin_for(key: String) -> SpinBox:
	return _field_rows[key]["spin"]


func field_label(key: String) -> Label:
	return _field_rows[key]["label"]


func finding_option() -> OptionButton:
	return _finding_option


func finding_note() -> Label:
	return _finding_note


func letter_option() -> OptionButton:
	return _letter_option


## 4, 4.5: sin ceros de más.
static func _shown_number(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, roundf(value)) else str(snappedf(value, 0.1))
