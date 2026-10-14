# T236: guardados viejos con la escena REAL en una ventana. Se escribe un guardado de antes de M50 (niveles 1 a 9
# ganados, `technology` completa, sin `disruptor`; es el mismo de `tests/test_old_saves.gd`), se abre la selección de
# nivel como la ve el jugador, se saca una captura, se comprueba con las tarjetas de verdad qué está abierto y un clic real
# sobre la tarjeta del nivel 10 abre la partida del 10 (RF-381: ganar el 9 abre el 10 aunque el guardado no lo diga).
#
#   godot --path . --resolution 1280x720 art/regression-t236/oldsave.tscn
extends Node

const SELECT_SCENE: PackedScene = preload("res://scenes/ui/level_select.tscn")
const OLD_SAVES: GDScript = preload("res://tests/test_old_saves.gd")
const OUT: String = "res://art/regression-t236/"
const SAVE: String = "user://regression_t236_old.json"


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


func run() -> void:
	DevMode.enabled = false
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(OLD_SAVES.SAVE_BEFORE_M50)
	file.close()
	SaveManager.save_path = SAVE
	SaveManager.load_save()
	GameFlow.select_page = &"campaign"
	print("T236 guardado viejo cargado: nivel 9 ganado=%s con %d vidas; 10 desbloqueado en el archivo=%s; technology=%d piezas; disruptor=%d" % [
		SaveManager.is_completed(&"level_09"), SaveManager.best_lives(&"level_09"), SaveManager.is_unlocked(&"level_10"),
		SaveManager.collected_sources(&"technology").size(), SaveManager.collected_sources(&"disruptor").size()])
	var select: Control = SELECT_SCENE.instantiate()
	add_child(select)
	await _frames(8)
	var cards: Control = select.get_node("%Cards")
	var states: PackedStringArray = []
	for i: int in cards.get_child_count():
		states.append("%d:%s" % [i + 1, "cerrado" if (cards.get_child(i) as Button).disabled else "abierto"])
	print("T236 tarjetas (%d): %s" % [cards.get_child_count(), " ".join(states)])
	await _shot("seleccion_guardado_viejo")
	var ten: Button = cards.get_child(9)
	print("T236 tarjeta del 10: cerrada=%s; texto: %s" % [ten.disabled, ten.text.replace("\n", " | ")])
	print("T236 tarjeta del 11: cerrada=%s" % (cards.get_child(10) as Button).disabled)
	var scroll: ScrollContainer = select.find_children("*", "ScrollContainer", true, false)[0]
	scroll.ensure_control_visible(ten)
	await _frames(6)
	await _shot("seleccion_guardado_viejo_10")
	Watcher.start(get_tree())
	await _click(ten.get_global_rect().get_center())


## Mira lo que pasa después del clic, ya en la escena de la partida (el nodo de arriba no sobrevive al cambio).
class Watcher extends RefCounted:
	var tree: SceneTree

	static func start(scene_tree: SceneTree) -> void:
		var watcher := Watcher.new()
		watcher.tree = scene_tree
		scene_tree.root.set_meta("t236_watcher", watcher)
		scene_tree.root.child_entered_tree.connect(watcher._on_child)

	func _on_child(node: Node) -> void:
		if node.name != "Game":
			return
		tree.root.child_entered_tree.disconnect(_on_child)
		tree.create_timer(1.0).timeout.connect(_check.bind(node))

	func _check(node: Node) -> void:
		var game: Game = node as Game
		print("T236 tras el clic: nivel abierto %s (esperado level_10); torres en la barra: %d" % [game.level_data.id, game.available_towers.size()])
		await tree.process_frame
		await RenderingServer.frame_post_draw
		tree.root.get_viewport().get_texture().get_image().save_png(OUT + "partida_nivel_10.png")
		if FileAccess.file_exists(SAVE):
			DirAccess.remove_absolute(SAVE)
		tree.quit()
