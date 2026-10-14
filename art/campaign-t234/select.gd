# T234: la selección de nivel con la campaña de 15 niveles, con la escena REAL en una ventana: se gana el 14 (los niveles
# 1 a 14 figuran ganados), se mira la tarjeta del 15 («La Central», con su lugar), y un clic real sobre ella abre la partida
# con el cartel de entrada (el camino que hace el jugador: GameFlow.start_level). Después se vuelve a mirar el nivel 15 sin
# haber ganado el 14, para ver su tarjeta bloqueada.
#
#   godot --path . --resolution 1280x720 art/campaign-t234/select.tscn
extends Node

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const OUT: String = "res://art/campaign-t234/"

var _problems: PackedStringArray = []


func _ready() -> void:
	reparent_to_root.call_deferred()


func reparent_to_root() -> void:
	# El nodo pasa a la raíz para sobrevivir al cambio de escena que hace GameFlow.start_level.
	var parent: Node = get_parent()
	if parent != get_tree().root:
		parent.remove_child(self)
		get_tree().root.add_child(self)
	run.call_deferred()


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT + name + ".png")


func _click(pos: Vector2) -> void:
	var window_pos: Vector2 = get_viewport().get_final_transform() * pos
	Input.warp_mouse(window_pos)
	await _frames(3)
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = window_pos
		click.global_position = window_pos
		Input.parse_input_event(click)
		await _frames(1)


func _problem(text: String) -> void:
	print("T234 PROBLEMA ", text)
	_problems.append(text)


func run() -> void:
	DevMode.enabled = false
	SaveManager.save_path = "user://play_t234_select.json"
	if FileAccess.file_exists(SaveManager.save_path):
		DirAccess.remove_absolute(SaveManager.save_path)
	SaveManager.load_save()
	GameFlow.select_page = &"campaign"
	# 1) Sin haber ganado el 14: el 15 se ve bloqueado.
	for i: int in 13:
		SaveManager.record_victory(GameFlow.level(i).id, 12, 1000)
	var select: Control = SELECT_SCENE.instantiate()
	add_child(select)
	await _frames(8)
	var cards: Control = select.get_node("%Cards")
	print("T234 la selección tiene %d tarjetas (la campaña: %d niveles)" % [cards.get_child_count(), GameFlow.level_count()])
	print("T234 el 15 sin ganar el 14: bloqueado=%s" % (cards.get_child(14) as Button).disabled)
	await _shot("seleccion_15_bloqueado")
	# 2) Ganando el 14: se abre.
	SaveManager.record_victory(GameFlow.level(13).id, 3, 1000)
	select.show_page(&"campaign")
	await _frames(8)
	var card: Button = cards.get_child(14)
	print("T234 el 15 tras ganar el 14: bloqueado=%s; texto de la tarjeta: %s" % [card.disabled, card.text.replace("\n", " | ")])
	var place: Label = card.get_node_or_null("Place")
	print("T234 lugar en la tarjeta: %s" % (place.text if place != null else "(sin etiqueta)"))
	if card.disabled:
		_problem("la tarjeta del 15 sigue bloqueada tras ganar el 14")
	await _shot("seleccion_15_abierto")
	# 3) Clic real sobre la tarjeta: abre la partida del nivel 15 con el cartel. GameFlow.start_level cambia la escena y
	# libera este nodo, así que lo que pasa después lo mira un observador que no es un nodo (sobrevive al cambio).
	var scroll: ScrollContainer = select.find_children("*", "ScrollContainer", true, false)[0]
	scroll.ensure_control_visible(card)  # el 15 está en la tercera fila: se baja la lista, como haría el jugador
	await _frames(6)
	await _shot("seleccion_15_visible")
	Watcher.start(get_tree(), OUT, _problems)
	await _click(card.get_global_rect().get_center())


## Mira lo que pasa después del clic, ya en la escena de la partida.
class Watcher extends RefCounted:
	var tree: SceneTree
	var out: String
	var problems: PackedStringArray

	static func start(scene_tree: SceneTree, out_dir: String, found: PackedStringArray) -> void:
		var watcher := Watcher.new()
		watcher.tree = scene_tree
		watcher.out = out_dir
		watcher.problems = found
		scene_tree.root.set_meta("t234_watcher", watcher)  # un RefCounted solo vive si alguien lo guarda
		scene_tree.root.child_entered_tree.connect(watcher._on_child)

	func _on_child(node: Node) -> void:
		if node.name != "Game":
			return
		tree.root.child_entered_tree.disconnect(_on_child)
		tree.create_timer(1.0).timeout.connect(_check.bind(node))

	func _check(node: Node) -> void:
		var game: Game = node as Game
		print("T234 escena actual tras el clic: %s" % tree.current_scene.name)
		print("T234 nivel abierto: %s; cartel abierto=%s; partida en pausa=%s" % [game.level_data.id, game.level_intro.is_open(), game.is_paused()])
		if game.level_data.id != &"level_15":
			print("T234 PROBLEMA el clic abrió otro nivel (%s)" % game.level_data.id)
			problems.append("otro nivel")
		if not game.level_intro.is_open():
			print("T234 PROBLEMA el cartel de entrada no se abrió desde la selección")
			problems.append("sin cartel")
		await RenderingServer.frame_post_draw
		tree.root.get_viewport().get_texture().get_image().save_png(out + "cartel_desde_seleccion.png")
		if FileAccess.file_exists(SaveManager.save_path):
			DirAccess.remove_absolute(SaveManager.save_path)
		print("T234_FIN ", JSON.stringify({"problems": problems}))
		tree.quit()
