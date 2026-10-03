# Panel de pruebas (RF-184, D-028). Solo existe en el modo de pruebas: Game lo crea si
# DevMode.enabled. Se abre y cierra con F1 o con el botón "Pruebas" de la barra de arriba.
# Solo avisa a Game qué hacer (constitución P6): las acciones están en game.gd (dev_…).
class_name DevPanel
extends PanelContainer

signal metrics_toggled(enabled: bool)

const PANEL_STYLE: StyleBox = preload("res://assets/ui/game_panel_style.tres")

var _game: Game
var _enemy_choice: OptionButton
var _enemy_types: Array[EnemyData] = []
var _speed_buttons: Array[Button] = []
var _lives_toggle: CheckButton


func setup(game: Game) -> DevPanel:
	theme = preload("res://assets/ui/menu_theme.tres")
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
	box.add_child(_section("Recursos"))
	box.add_child(_button("+1000 de oro", game.dev_add_gold))
	var support_toggle: CheckButton = _toggle("Habilitar estandartes", game.dev_enable_support)
	support_toggle.set_pressed_no_signal(DevMode.support_unlocked)
	box.add_child(support_toggle)
	_lives_toggle = _toggle("Vidas infinitas  [%s]" % DevMode.key_label(&"dev_infinite_lives"), game.dev_set_infinite_lives)
	box.add_child(_lives_toggle)
	game.dev_infinite_lives_changed.connect(_lives_toggle.set_pressed_no_signal)
	box.add_child(_section("Partida"))
	box.add_child(_button("Saltar oleada  [%s]" % DevMode.key_label(&"dev_skip_wave"), game.dev_skip_wave))
	box.add_child(_button("Matar a todos  [%s]" % DevMode.key_label(&"dev_kill_all"), game.dev_kill_all))
	box.add_child(_button("Ganar", game.dev_finish.bind(true)))
	box.add_child(_button("Perder", game.dev_finish.bind(false)))
	box.add_child(_section("Simulación"))
	box.add_child(_speed_row())
	game.speed_changed.connect(_on_speed_changed)
	box.add_child(_enemy_row())
	box.add_child(_toggle("Mostrar FPS", metrics_toggled.emit))
	return self


## RF-322: una fila de botones con las velocidades de `data/dev_config.tres`; el activo queda marcado.
func _speed_row() -> Control:
	var column := VBoxContainer.new()
	var title := Label.new()
	title.text = "Velocidad  [%s / %s]" % [DevMode.key_label(&"dev_slower"), DevMode.key_label(&"dev_faster")]
	column.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	for speed: float in DevMode.config.speeds:
		var button := Button.new()
		button.text = Rules.speed_text(speed)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(func() -> void:
			_game.dev_set_speed(speed)
			_on_speed_changed(Engine.time_scale))  # un clic en el activo no lo apaga
		row.add_child(button)
		_speed_buttons.append(button)
	column.add_child(row)
	_on_speed_changed(Engine.time_scale)
	return column


## Marca el botón de la velocidad actual (también cuando cambia con la tecla F o termina la partida).
func _on_speed_changed(speed: float) -> void:
	for i: int in _speed_buttons.size():
		_speed_buttons[i].set_pressed_no_signal(is_equal_approx(DevMode.config.speeds[i], speed))


func speed_buttons() -> Array[Button]:
	return _speed_buttons


func toggle() -> void:
	visible = not visible


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

func _section(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.9, 0.72, 0.4))
	return label
