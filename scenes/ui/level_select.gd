# Selección de nivel (RF-111, RF-112): una tarjeta por nivel de la campaña.
# Los bloqueados no se pueden elegir; los completados muestran sus estrellas (RF-93)
# y su mejor resultado. Arriba, el total de estrellas de la campaña.
extends Control

## 5 tarjetas de 220 px + 4 espacios de 16 px = 1164 px: entran en los 1280 de la pantalla.
const CARD_SIZE := Vector2(220, 220)
const CARD_STAR_SIZE: float = 26.0

@onready var _cards: HBoxContainer = %Cards
@onready var _back_button: Button = %BackButton
@onready var _total_stars: Label = %TotalStars


func _ready() -> void:
	_back_button.pressed.connect(GameFlow.go_to_main_menu)
	for i: int in GameFlow.level_count():
		_cards.add_child(_make_card(i))
	_total_stars.text = "Estrellas: %d de %d" % [GameFlow.total_stars(), GameFlow.max_stars()]
	Audio.add_click_sounds(self)


## Esc (o "atrás" en Android, RF-142) vuelve al menú principal.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_viewport().set_input_as_handled()
		GameFlow.go_to_main_menu()


func _make_card(index: int) -> Button:
	var level: LevelData = GameFlow.level(index)
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.add_theme_font_size_override("font_size", 20)
	card.text = "Nivel %d\n%s\n%d oleadas\n%s\n\n" % [
		index + 1, level.display_name, level.waves.size(), status_text(index)]
	card.disabled = not GameFlow.is_level_unlocked(index)
	card.pressed.connect(GameFlow.start_level.bind(index))
	# RF-93: estrellas abajo de la tarjeta (huecas si todavía no se ganó).
	var stars := StarsDisplay.new()
	stars.star_size = CARD_STAR_SIZE
	stars.count = GameFlow.level_stars(index)
	stars.visible = GameFlow.is_level_unlocked(index)
	# Posición a mano: la tarjeta todavía no tiene su tamaño final al crearla.
	stars.size = stars.custom_minimum_size
	stars.position = Vector2((CARD_SIZE.x - stars.size.x) / 2.0, CARD_SIZE.y - CARD_STAR_SIZE - 18.0)
	card.add_child(stars)
	return card


## Texto de estado de la tarjeta (público para poder testearlo).
func status_text(index: int) -> String:
	var id: StringName = GameFlow.level(index).id
	if not GameFlow.is_level_unlocked(index):
		return "Bloqueado"
	if SaveManager.is_completed(id):
		return "Mejor: %d vidas" % SaveManager.best_lives(id)
	return "¡Jugar!"
