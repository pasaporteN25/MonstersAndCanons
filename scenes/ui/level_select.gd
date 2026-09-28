# Selección de nivel (RF-111, RF-112): una tarjeta por nivel de la campaña.
# Los bloqueados no se pueden elegir; los completados muestran su mejor resultado.
extends Control

const CARD_SIZE := Vector2(300, 200)

@onready var _cards: HBoxContainer = %Cards
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	for i: int in GameFlow.level_count():
		_cards.add_child(_make_card(i))


func _make_card(index: int) -> Button:
	var level: LevelData = GameFlow.level(index)
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.add_theme_font_size_override("font_size", 22)
	card.text = "Nivel %d\n%s\n%d oleadas\n\n%s" % [
		index + 1, level.display_name, level.waves.size(), status_text(index)]
	card.disabled = not GameFlow.is_level_unlocked(index)
	card.pressed.connect(GameFlow.start_level.bind(index))
	return card


## Texto de estado de la tarjeta (público para poder testearlo).
func status_text(index: int) -> String:
	var id: StringName = GameFlow.level(index).id
	if not GameFlow.is_level_unlocked(index):
		return "Bloqueado"
	if SaveManager.is_completed(id):
		return "Completado · mejor: %d vidas" % SaveManager.best_lives(id)
	return "¡Jugar!"
