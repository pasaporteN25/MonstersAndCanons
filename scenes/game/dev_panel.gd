# Panel de pruebas (RF-184, D-028). Solo existe en el modo de pruebas: Game lo crea si
# DevMode.enabled. Se abre y cierra con F1 o con el botón "Pruebas" de la barra de arriba.
# Solo avisa a Game qué hacer (constitución P6): las acciones están en game.gd (dev_…).
class_name DevPanel
extends PanelContainer

const PANEL_STYLE: StyleBox = preload("res://assets/ui/panel_style.tres")

var _game: Game
var _fps_label: Label
var _show_fps: bool = false
var _enemy_choice: OptionButton
var _enemy_types: Array[EnemyData] = []


func setup(game: Game) -> DevPanel:
	_game = game
	visible = false
	position = Vector2(20, 60)
	custom_minimum_size = Vector2(240, 0)
	add_theme_stylebox_override("panel", PANEL_STYLE)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)
	var title := Label.new()
	title.text = "Pruebas"
	title.add_theme_color_override("font_color", Color(1, 0.55, 0.3))
	title.add_theme_font_size_override("font_size", 20)
	box.add_child(title)
	box.add_child(_button("+1000 de oro", game.dev_add_gold))
	box.add_child(_toggle("Vidas infinitas", game.dev_set_infinite_lives))
	box.add_child(_button("Saltar oleada", game.dev_skip_wave))
	box.add_child(_button("Matar a todos", game.dev_kill_all))
	box.add_child(_button("Ganar", game.dev_finish.bind(true)))
	box.add_child(_button("Perder", game.dev_finish.bind(false)))
	box.add_child(_toggle("Velocidad x4", game.dev_set_fast))
	box.add_child(_enemy_row())
	box.add_child(_toggle("Mostrar FPS", func(on: bool) -> void:
		_show_fps = on
		_fps_label.visible = on))
	_fps_label = Label.new()
	_fps_label.visible = false
	box.add_child(_fps_label)
	return self


func toggle() -> void:
	visible = not visible


func _process(_delta: float) -> void:
	if _show_fps:
		_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


## Elegir un enemigo de cualquier tipo (todos los de data/enemies) y hacerlo aparecer.
func _enemy_row() -> Control:
	var row := HBoxContainer.new()
	_enemy_choice = OptionButton.new()
	_enemy_choice.focus_mode = Control.FOCUS_NONE
	_enemy_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# LevelFile.enemy_ids() entiende los nombres del ejecutable exportado (.tres.remap).
	for id: String in LevelFile.enemy_ids():
		_enemy_types.append(LevelFile.find_enemy(id))
	_enemy_types.sort_custom(func(a: EnemyData, b: EnemyData) -> bool: return a.display_name < b.display_name)
	for enemy: EnemyData in _enemy_types:
		_enemy_choice.add_item(enemy.display_name)
	row.add_child(_enemy_choice)
	row.add_child(_button("Aparecer", func() -> void:
		_game.dev_spawn(_enemy_types[_enemy_choice.selected])))
	return row


func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	return button


func _toggle(text: String, action: Callable) -> CheckButton:
	var check := CheckButton.new()
	check.text = text
	check.focus_mode = Control.FOCUS_NONE
	check.toggled.connect(action)
	return check
