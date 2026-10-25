extends GutTest

const HOST_SCENE: PackedScene = preload("res://scenes/host/presentation_host.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const EXPECTED_THEMES: PackedStringArray = ["pradera", "bosque", "ruinas", "desierto", "nieve", "volcan", "pantano"]


func test_runtime_catalog_maps_every_approved_theme_to_a_texture() -> void:
	var file: FileAccess = FileAccess.open(PresentationBackgroundCatalog.CATALOG_PATH, FileAccess.READ)
	assert_not_null(file)
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(file.get_as_text()), OK)
	for theme: String in EXPECTED_THEMES:
		var path: String = PresentationBackgroundCatalog.path_for_theme(parser.data, StringName(theme))
		assert_true(path.begins_with("res://assets/backgrounds/stripes/"), theme)
		assert_true(ResourceLoader.exists(path), theme)
		assert_not_null(PresentationBackgroundCatalog.load_for_theme(StringName(theme)), theme)


func test_invalid_theme_or_catalog_entry_uses_the_solid_fallback() -> void:
	assert_null(PresentationBackgroundCatalog.load_for_theme(&"sin_tema"))
	assert_eq(PresentationBackgroundCatalog.path_for_theme(null, &"pradera"), "")
	assert_eq(PresentationBackgroundCatalog.path_for_theme({"temas": []}, &"pradera"), "")
	assert_eq(PresentationBackgroundCatalog.path_for_theme({"temas": {"pradera": 12}}, &"pradera"), "")
	assert_eq(PresentationBackgroundCatalog.path_for_theme({"temas": {"pradera": ""}}, &"pradera"), "")
	assert_null(PresentationBackgroundCatalog.parse_catalog("{"))
	assert_null(PresentationBackgroundCatalog.load_texture("res://data/balance.tres"))
	assert_null(PresentationBackgroundCatalog.load_texture("res://assets/backgrounds/stripes/no-existe.png"))


func test_host_shows_the_theme_texture_and_returns_to_solid_when_unavailable() -> void:
	var host: Control = HOST_SCENE.instantiate() as Control
	add_child_autofree(host)
	var background: TextureRect = host.get_node("BackgroundTexture") as TextureRect
	assert_eq(background.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(background.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	host.call("set_background_theme", &"nieve")
	assert_true(background.visible)
	assert_not_null(background.texture)
	host.call("set_background_theme", &"sin_tema")
	assert_false(background.visible)
	assert_null(background.texture)


func test_host_receives_the_resolved_game_theme_before_game_ready() -> void:
	var host: Control = HOST_SCENE.instantiate() as Control
	add_child_autofree(host)
	host.call("install_scene", GAME_SCENE)
	await get_tree().process_frame
	var background: TextureRect = host.get_node("BackgroundTexture") as TextureRect
	assert_true(background.visible)
	assert_eq(background.texture.resource_path, "res://assets/backgrounds/stripes/pradera.png")


func test_game_backdrop_is_full_viewport_and_independent_of_camera() -> void:
	var game: Game = Game.new()
	game.level = Level.new()
	game.level.theme = &"pantano"
	game._add_theme_backdrop()
	var layer: CanvasLayer = game.get_node("ThemeBackdrop") as CanvasLayer
	var image: TextureRect = layer.get_node("ThemeImage") as TextureRect
	assert_false(layer.follow_viewport_enabled)
	assert_eq(layer.layer, -10)
	assert_eq(image.anchor_right, 1.0)
	assert_eq(image.anchor_bottom, 1.0)
	assert_eq(image.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	assert_eq(image.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	game.level.free()
	game.free()
