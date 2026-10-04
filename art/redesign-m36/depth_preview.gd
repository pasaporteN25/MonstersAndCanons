# B-21: tres muestras aisladas del mismo mapa. No altera escenas de producción.
extends Node

var _floor: Texture2D
var _icons: Array[Texture2D] = []
var _spots: Array[Vector2] = [Vector2(224, 160), Vector2(480, 288), Vector2(800, 416)]

func _ready() -> void:
	SaveManager.save_path = "user://test_m36_depth.json"
	call_deferred("run")

func run() -> void:
	var game: Game = preload("res://scenes/game/game.tscn").instantiate()
	add_child(game)
	game.hud.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
	_floor = ImageTexture.create_from_image(image.get_region(Rect2i(0, 48, 1280, 576)))
	for i: int in 3:
		_icons.append(Tower.make_icon(game.tower_types[i]))
	game.queue_free()
	await get_tree().process_frame
	for oblique: bool in [false, true]:
		var view := Node2D.new()
		add_child(view)
		var floor_sprite := Sprite2D.new()
		floor_sprite.texture = _floor
		floor_sprite.centered = false
		var transform_: Transform2D = Transform2D(Vector2(0.72, 0), Vector2(0.18 if oblique else 0, 0.58 if oblique else 0.72), Vector2(60, 130))
		floor_sprite.transform = transform_
		# Relieve en2D: canto físico aparente bajo el tablero, conservando su proyección lógica.
		var edge := Polygon2D.new()
		edge.polygon = PackedVector2Array([transform_ * Vector2(0, 576), transform_ * Vector2(1280, 576), transform_ * Vector2(1280, 576) + Vector2(0, 8), transform_ * Vector2(0, 576) + Vector2(0, 8)])
		edge.color = Color(0.19, 0.14, 0.1)
		view.add_child(edge)
		view.add_child(floor_sprite)
		for i: int in _icons.size():
			var sprite := Sprite2D.new()
			sprite.texture = _icons[i]
			sprite.position = transform_ * _spots[i] + Vector2(0, -13)
			sprite.scale = Vector2.ONE * 0.55
			view.add_child(sprite)
		await shot("profundidad_oblicua2d" if oblique else "profundidad_relieve2d")
		view.queue_free()
		await get_tree().process_frame
	var sub := SubViewport.new()
	sub.size = Vector2i(1280, 720)
	sub.own_world_3d = true
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sub)
	var floor3d := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(20, 9)
	floor3d.mesh = mesh
	floor3d.position = Vector3(10, 0, 4.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _floor
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	floor3d.material_override = mat
	sub.add_child(floor3d)
	for i: int in _icons.size():
		var sprite := Sprite3D.new()
		sprite.texture = _icons[i]
		sprite.pixel_size = 0.012
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.no_depth_test = false
		sprite.position = Vector3(_spots[i].x / 64.0, 0.48, _spots[i].y / 64.0)
		sub.add_child(sprite)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 15.5
	camera.position = Vector3(13, 16, 18)
	sub.add_child(camera)
	camera.look_at(Vector3(10, 0, 4.5))
	camera.current = true
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	sub.get_texture().get_image().save_png("res://art/redesign-m36/profundidad_suelo3d.png")
	get_tree().quit()

func shot(id: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://art/redesign-m36/" + id + ".png")
