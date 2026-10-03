# Muestras reales de RF-349. Ejecutar con APPDATA aislado en build/t180-user.
extends Node

var _suffix: String = ""

func _ready() -> void:
	SaveManager.save_path = "user://test_m35_capture.json"
	if "small" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1280, 720))
		_suffix = "_1280"
	call_deferred("run")

func run() -> void:
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	game.session.earn(10000)
	game.build_controller.try_build(game.tower_types[0], Vector2i(4, 2))
	var tower: Tower = game.build_controller.tower_at(Vector2i(4, 2))
	game.build_controller.select_placed(tower)
	await shot("nivel1")
	game.build_controller.try_upgrade(tower)
	game.session.spend(game.session.gold)
	await shot("nivel2_sin_oro")
	game.session.earn(10000)
	game.build_controller.try_upgrade(tower)
	await shot("nivel3")
	tower.stun(20.0)
	await shot("aturdida")
	tower.data = tower.data.duplicate(true)
	tower.data.display_name = "Torre con nombre muy largo de la comunidad"
	tower.data.description = "Descripción larga para comprobar el desplazamiento sin ocultar Mejorar, Vender ni la prioridad de apuntado. ".repeat(15)
	game.hud.tower_panel.refresh(game.session.gold)
	(game.hud.tower_panel.get_node("%SellButton") as Button).grab_focus()
	await shot("texto_largo_foco")
	game.build_controller.try_build(game.tower_types[2], Vector2i(7, 2))
	game.build_controller.select_placed(game.build_controller.tower_at(Vector2i(7, 2)))
	await shot("hielo_sinergias")
	get_tree().quit()

func shot(id: String) -> void:
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m35/" + id + _suffix + ".png")
