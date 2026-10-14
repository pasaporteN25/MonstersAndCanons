# Capturas reales de Godot de la integración M24 (monstruos y menú). Se corre con ventana y con
# APPDATA aislado, para no tocar el guardado del jugador:
#   godot --path . res://tools/capture_m24.tscn -- menu|monstruos|wiki
extends Node

const OUT := "res://art/m24-integracion/"
## Se cargan en tiempo de ejecución: la revisión de sintaxis de CI compila este script sin los autoloads.
const GAME_PATH: String = "res://scenes/game/game.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var mode: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "monstruos"
	match mode:
		"menu":
			await capture_menu()
		"wiki":
			await capture_wiki()
		_:
			await capture_monsters()
	get_tree().quit()


func shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT + file)
	print("guardada ", file)


func capture_menu() -> void:
	var menu: Control = (load(MENU_PATH) as PackedScene).instantiate()
	add_child(menu)
	await get_tree().create_timer(0.6).timeout
	await shot("menu_reposo.png")
	# Hover sobre "Récords": el foco del teclado queda en "Jugar" y el mouse en el segundo botón.
	var records: Button = menu.get_node("%RecordsButton")
	records.grab_focus()
	await get_tree().create_timer(0.3).timeout
	await shot("menu_foco.png")
	menu.queue_free()


func capture_wiki() -> void:
	var wiki: Control = (load("res://scenes/ui/wiki_screen.tscn") as PackedScene).instantiate()
	wiki.is_seen = func(_enemy_id: StringName) -> bool: return true
	add_child(wiki)
	await get_tree().create_timer(0.4).timeout
	for id: StringName in [&"tank", &"fast", &"normal"]:
		wiki.show_target(&"enemigos", id)
		await get_tree().create_timer(0.3).timeout
		await shot("wiki_%s.png" % id)
	wiki.queue_free()


func capture_monsters() -> void:
	var game = (load(GAME_PATH) as PackedScene).instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	for i: int in 3:
		game.build_controller.try_build(game.tower_types[i], Vector2i(3 + i * 4, 2))
	var ids: Array[String] = ["normal", "fast", "tank"]
	var spots: Array[float] = [60.0, 190.0, 330.0, 470.0, 610.0, 760.0, 900.0, 1100.0, 1300.0, 1500.0, 1700.0, 1900.0]
	var spawned: Array = []
	for i: int in spots.size():
		game.spawner.spawn_now(load("res://data/enemies/%s.tres" % ids[i % 3]))
	for node: Node in game.enemies.get_children():
		spawned.append(node)
	for i: int in spawned.size():
		spawned[i].distance = spots[i]
	# Estados: golpeado (barra de vida), ralentizado, quemado.
	for i: int in spawned.size():
		match i % 4:
			1:
				spawned[i].take_hit(4)
			2:
				spawned[i].take_hit(2, 0.5, 30.0)
			3:
				spawned[i].apply_burn(1, 30.0)
				spawned[i].take_hit(3)
	for tower: Node in game.tower_container.get_children():
		tower.set_physics_process(false)  # las torres no disparan: la captura es de los dibujos
	game.set_process(false)
	for enemy in spawned:
		enemy.set_physics_process(false)
		enemy._update_position()
		enemy._animate(0.1)
	await get_tree().create_timer(5.0).timeout  # que se vaya el cartel de "Nuevo enemigo"
	await get_tree().create_timer(0.3).timeout
	await shot("monstruos_mapa.png")
	var image: Image = get_viewport().get_texture().get_image()
	var zoom: Image = image.get_region(Rect2i(0, 80, 1280, 300))
	zoom.resize(2560, 600, Image.INTERPOLATE_LANCZOS)
	zoom.save_png(OUT + "monstruos_zoom.png")
	game.queue_free()
