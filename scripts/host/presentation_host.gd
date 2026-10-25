extends Control

const MAIN_MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const LOGICAL_SIZE: Vector2i = Vector2i(1280, 720)

@onready var content_frame: SubViewportContainer = $ContentFrame
@onready var content_viewport: SubViewport = $ContentFrame/ContentViewport
@onready var background_texture: TextureRect = $BackgroundTexture

var active_screen: Node
var _previous_content_scale_mode: int = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
var _previous_content_scale_aspect: int = Window.CONTENT_SCALE_ASPECT_KEEP


func _enter_tree() -> void:
	# La raíz representa la superficie física; solo el contenido interno usa escala lógica.
	_previous_content_scale_mode = get_tree().root.content_scale_mode
	_previous_content_scale_aspect = get_tree().root.content_scale_aspect
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	content_viewport.size_2d_override = LOGICAL_SIZE
	content_viewport.size_2d_override_stretch = true
	content_viewport.handle_input_locally = true
	content_viewport.process_mode = Node.PROCESS_MODE_PAUSABLE
	GameFlow.attach_presentation(self)
	install_scene(MAIN_MENU_SCENE)
	_update_frame()


func _exit_tree() -> void:
	GameFlow.detach_presentation(self)
	var scene_tree: SceneTree = get_tree()
	var root: Window = scene_tree.root if scene_tree != null else null
	if root != null:
		root.content_scale_mode = _previous_content_scale_mode
		root.content_scale_aspect = _previous_content_scale_aspect


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_frame()


func install_scene(scene: PackedScene) -> void:
	if scene == null:
		return
	set_background_texture(null)
	for child: Node in content_viewport.get_children():
		content_viewport.remove_child(child)
		child.queue_free()
	active_screen = scene.instantiate()
	if active_screen.has_signal("level_theme_selected"):
		active_screen.connect("level_theme_selected", Callable(self, "set_background_theme"))
	content_viewport.add_child(active_screen)
	Audio.add_click_sounds(active_screen)


func get_active_screen() -> Node:
	return active_screen


func get_content_viewport() -> SubViewport:
	return content_viewport


func set_background_theme(theme: StringName) -> void:
	set_background_texture(PresentationBackgroundCatalog.load_for_theme(theme))


func set_background_texture(texture: Texture2D) -> void:
	background_texture.texture = texture
	background_texture.visible = texture != null


func _update_frame() -> void:
	var frame: Rect2 = PresentationGeometry.frame_rect(get_viewport_rect().size)
	content_frame.position = frame.position
	content_frame.size = frame.size
	GameFlow.update_presentation_scale(PresentationGeometry.frame_scale(frame.size))
