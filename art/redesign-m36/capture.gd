# Muestras de todos los tipos, estados y efectos; APPDATA aislado.
extends Node
var game: Game

func _ready() -> void:
	SaveManager.save_path = "user://test_m36_capture.json"
	call_deferred("run")

func run() -> void:
	game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.session.earn(100000)
	game.hud.hide()
	var title := Label.new()
	title.position = Vector2(30, 8)
	title.add_theme_font_size_override("font_size", 23)
	add_child(title)
	var towers: Array[Tower] = []
	for row: int in 3:
		for i: int in game.tower_types.size():
			var tower: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
			tower.setup(game.tower_types[i])
			game.tower_container.add_child(tower)
			tower.position = Vector2(90 + i * 130, 150 + row * 165)
			for upgrade: int in row:
				tower.apply_upgrade()
			tower.set_physics_process(false)
			towers.append(tower)
			var label := Label.new()
			label.position = tower.position + Vector2(-48, 48)
			label.text = "%s · %d" % [tower.data.display_name, row + 1]
			label.add_theme_font_size_override("font_size", 12)
			add_child(label)
	title.text = "B-20 · Niveles 1 / 2 / 3 · Placa y remaches integrados en la base"
	await get_tree().create_timer(0.4).timeout
	await shot("torres_niveles")
	for tower: Tower in towers:
		tower.stun(0.5)
		tower._stun_anim = 0.3
		tower.queue_redraw()
	title.text = "B-25 · Aturdidas · Nivel legible con el brillo apagado"
	await shot("torres_aturdidas")
	for tower: Tower in towers:
		tower._physics_process(0.6)
		tower.queue_redraw()
	title.text = "B-25 · Recuperación · Destello breve sobre el mecanismo"
	await shot("torres_recuperacion")
	for tower: Tower in towers:
		tower.queue_free()
	for node: Node in get_children():
		if node is Label and node != title:
			node.queue_free()
	await get_tree().process_frame
	var ids: PackedStringArray = LevelFile.enemy_ids()
	var enemies: Array[Enemy] = []
	for i: int in ids.size():
		game.spawner.spawn_now(load("res://data/enemies/%s.tres" % ids[i]))
		var enemy: Enemy = game.enemies.get_child(game.enemies.get_child_count() - 1)
		enemy.set_physics_process(false)
		enemy.position = Vector2(90 + (i % 7) * 175, 210 + (i / 7) * 190)
		enemy.distance = 24
		enemy._animate(0.0)
		enemies.append(enemy)
		var label := Label.new()
		label.position = enemy.position + Vector2(-45, 55)
		label.text = enemy.data.display_name
		add_child(label)
	title.text = "B-24 · Bestiario completo · Poses vivas de referencia"
	await shot("bestiario_vivo")
	SaveManager.set_setting("damage_numbers", false)
	for enemy: Enemy in enemies:
		enemy.take_hit(100000)
	for effect: Node in game.effects.get_children():
		effect._process(0.1)
		effect.set_process(false)
	title.text = "B-24 · Muertes · Pose actual, desintegración y fragmentos facetados"
	await shot("bestiario_muertes")
	for effect: Node in game.effects.get_children():
		effect._process(0.16)
	title.text = "B-24 · Muertes · Fase intermedia sin colisión ni recompensa adicional"
	await shot("bestiario_muertes_media")
	for effect: Node in game.effects.get_children():
		effect.queue_free()
	game.dev_kill_all()  # la Araña dejó crías: no mezclarlas con la muestra de cura
	for node: Node in get_children():
		if node is Label and node != title:
			node.queue_free()
	await get_tree().process_frame
	SaveManager.set_setting("damage_numbers", true)
	game.spawner.spawn_now(load("res://data/enemies/healer.tres"))
	var healer: Enemy = game.enemies.get_child(0)
	healer.position = Vector2(450, 300)
	healer.set_physics_process(false)
	for i: int in 4:
		game.spawner.spawn_now(load("res://data/enemies/tank.tres"))
		var target: Enemy = game.enemies.get_child(i + 1)
		target.position = Vector2(370 + i * 65, 360)
		target.set_physics_process(false)
		target.health = target.max_health / 2
		target.receive_aura(0, 3)
		if i == 2:
			target.apply_burn(1, 3)
		if i == 3:
			target.health = target.max_health
		target.queue_redraw()
		if i < 2:
			game.effects.heal_number(target.position, 4)
	game.spawner.spawn_now(load("res://data/enemies/mirror.tres"))
	var mirror: Enemy = game.enemies.get_child(game.enemies.get_child_count() - 1)
	mirror.position = Vector2(810, 290)
	mirror.set_physics_process(false)
	var tower: Tower = preload("res://scenes/towers/tower.tscn").instantiate()
	tower.setup(game.tower_types[0])
	game.tower_container.add_child(tower)
	tower.position = Vector2(1040, 360)
	tower.set_physics_process(false)
	mirror.reflect(tower)
	tower.queue_redraw()
	for effect: Node in game.effects.get_children():
		effect._process(0.08)
		effect.set_process(false)
	title.text = "B-25/26 · Aura, cura efectiva, fuego y vida completa · Rebote con trayectoria"
	await shot("cura_rebote")
	get_tree().quit()

func shot(id: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m36/" + id + ".png")
