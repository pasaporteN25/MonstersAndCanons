# La presentación del jefe a pantalla completa en el celular (T571, RF-738, D-224). Usa el anfitrión real dentro de un
# SubViewport del tamaño de cada teléfono simulado; no cambia de escena ni toca el guardado.
extends GutTest

const HOST_SCENE: PackedScene = preload("res://scenes/host/presentation_host.tscn")
const PROPORTIONS: Dictionary = {
	"16:9": Vector2i(1920, 1080), "19.5:9": Vector2i(2340, 1080),
	"20:9": Vector2i(2400, 1080), "21:9": Vector2i(2520, 1080),
}

var _holder: SubViewport
var _host: Control


func before_each() -> void:
	Localization.reset()


func after_each() -> void:
	Localization.reset()
	if _holder != null and is_instance_valid(_holder):
		_holder.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_holder = null
	_host = null


func _host_at(size_: Vector2i) -> void:
	_holder = SubViewport.new()
	_holder.size = size_
	_holder.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_holder)
	_host = HOST_SCENE.instantiate() as Control
	_holder.add_child(_host)
	await get_tree().process_frame
	await get_tree().process_frame


func _data(id: String) -> EnemyData:
	return load("res://data/enemies/%s.tres" % id)


func _open(id: String = "boss", mobile: bool = true, seconds_: float = 5.0) -> BossPresentation:
	var data: EnemyData = _data(id)
	var presentation: BossPresentation = BossPresentation.new().setup(data, seconds_, mobile, null, BossPresentationArt.backdrop_for(id))
	_host.get_content_viewport().add_child(presentation)
	await get_tree().process_frame
	return presentation


func _skip_after_lock(presentation: BossPresentation, keep_paused: bool) -> void:
	presentation.advance_clock_for_test(0.5)
	presentation.skip(keep_paused)
	presentation.advance_clock_for_test(1.0)
	await get_tree().process_frame
	await get_tree().process_frame


# --- Geometría ---

func test_logical_surface_rect_extends_the_frame_by_the_strips() -> void:
	var rect: Rect2 = PresentationGeometry.logical_surface_rect(Vector2(2400.0, 1080.0))
	assert_almost_eq(rect.size.x, 2400.0 / 1.5, 0.01)
	assert_almost_eq(rect.size.y, 720.0, 0.01)
	assert_almost_eq(rect.position.x, -(2400.0 - 1920.0) / 2.0 / 1.5, 0.01)
	assert_almost_eq(rect.position.y, 0.0, 0.01)
	assert_true(rect.encloses(Rect2(Vector2.ZERO, PresentationGeometry.LOGICAL_SIZE)))
	assert_eq(PresentationGeometry.logical_surface_rect(Vector2.ZERO), Rect2(Vector2.ZERO, PresentationGeometry.LOGICAL_SIZE))


# --- El fondo cubre toda la superficie y se va al cerrar ---

func test_backdrop_covers_the_whole_surface_in_every_proportion() -> void:
	for label: String in PROPORTIONS:
		var size_: Vector2i = PROPORTIONS[label]
		await _host_at(size_)
		var presentation: BossPresentation = await _open("boss")
		assert_true(_host.has_presentation_backdrop(), label)
		var outer: Control = _host.get_node("PresentationBackdrop")
		assert_eq(outer.get_global_rect(), Rect2(Vector2.ZERO, Vector2(size_)), "%s: cubre franjas y marco" % label)
		assert_lt(outer.get_index(), _host.get_node("ContentFrame").get_index(), "%s: debajo del marco" % label)
		assert_gt(outer.get_index(), _host.get_node("BackgroundTexture").get_index(), "%s: encima del terreno" % label)
		assert_null(outer.material, "%s: sin el apagado de RF-726" % label)
		var inner: Control = presentation.find_child("BackdropLayer", true, false)
		var expected: Rect2 = PresentationGeometry.logical_surface_rect(Vector2(size_))
		assert_eq(inner.position, expected.position, label)
		assert_eq(inner.size, expected.size, label)
		_holder.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame


func test_colossus_art_is_in_both_places() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("colossus")
	assert_not_null(_host.get_node("PresentationBackdrop").find_child("BackdropArt", true, false))
	assert_not_null(_host.get_node("PresentationBackdrop").find_child("TextShade", true, false))
	assert_not_null(presentation.find_child("BackdropArt", true, false))


func test_without_art_it_uses_the_tinted_color() -> void:
	await _host_at(PROPORTIONS["20:9"])
	await _open("boss")
	var outer: Node = _host.get_node("PresentationBackdrop")
	assert_null(outer.find_child("BackdropArt", true, false))
	var base: ColorRect = outer.find_child("Backdrop", true, false)
	assert_eq(base.color, Color(0.05, 0.04, 0.06).lerp(_data("boss").color, 0.18))


func test_the_terrain_background_comes_back_when_it_times_out() -> void:
	await _host_at(PROPORTIONS["20:9"])
	_host.set_background_texture(PlaceholderTexture2D.new())
	var presentation: BossPresentation = await _open("boss", true, 1.0)
	presentation.advance_clock_for_test(2.0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_false(_host.has_presentation_backdrop(), "por tiempo")
	assert_true((_host.get_node("BackgroundTexture") as TextureRect).visible, "vuelve el fondo del terreno")
	assert_not_null((_host.get_node("BackgroundTexture") as TextureRect).texture)


func test_the_backdrop_is_removed_when_skipped() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("boss")
	await _skip_after_lock(presentation, false)
	assert_false(_host.has_presentation_backdrop(), "por salteo")


func test_the_backdrop_is_removed_with_back() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("boss")
	var back := InputEventAction.new()
	back.action = "cancel"
	back.pressed = true
	presentation.advance_clock_for_test(0.5)
	presentation._input(back)
	presentation.advance_clock_for_test(1.0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_false(_host.has_presentation_backdrop(), "por «Atrás»")


func test_the_backdrop_is_removed_if_the_presentation_is_freed_midway() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("boss")
	presentation.free()
	assert_false(_host.has_presentation_backdrop(), "si se libera la partida con la capa abierta")


func test_the_backdrop_alpha_follows_the_fade() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("boss")
	await get_tree().process_frame
	var outer: Control = _host.get_node("PresentationBackdrop")
	assert_almost_eq(outer.modulate.a, (presentation.find_child("Root", true, false) as Control).modulate.a, 0.35)


func test_the_surface_follows_a_resize() -> void:
	await _host_at(PROPORTIONS["16:9"])
	var presentation: BossPresentation = await _open("boss")
	_holder.size = PROPORTIONS["21:9"]
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var inner: Control = presentation.find_child("BackdropLayer", true, false)
	assert_eq(inner.size, PresentationGeometry.logical_surface_rect(Vector2(PROPORTIONS["21:9"])).size)


# --- La PC y lo que no cambia ---

func test_desktop_is_unchanged() -> void:
	await _host_at(PROPORTIONS["20:9"])
	var presentation: BossPresentation = await _open("boss", false)
	assert_false(_host.has_presentation_backdrop(), "en la PC el anfitrión no dibuja nada")
	var inner: Control = presentation.find_child("BackdropLayer", true, false)
	assert_eq(inner.anchor_right, 1.0)
	assert_eq(inner.anchor_bottom, 1.0)
	assert_eq(BossPresentationArt.layout(false), BossPresentationArt.DEFAULT_LAYOUT)


func test_without_a_host_the_backdrop_fills_the_frame() -> void:
	var presentation: BossPresentation = BossPresentation.new().setup(_data("boss"), 5.0, true)
	add_child_autofree(presentation)
	await get_tree().process_frame
	assert_eq((presentation.find_child("BackdropLayer", true, false) as Control).anchor_right, 1.0)


# --- Composición: entra en 720 px, letra mínima, español e inglés ---

func test_the_layout_fits_in_the_frame_for_every_dangerous_enemy_and_language() -> void:
	await _host_at(PROPORTIONS["21:9"])
	var ids: Array[String] = []
	var dir: DirAccess = DirAccess.open("res://data/enemies")
	for file: String in dir.get_files():
		if file.ends_with(".tres"):
			var data: EnemyData = load("res://data/enemies/" + file)
			if Rules.is_dangerous(data):
				ids.append(file.get_basename())
	assert_gt(ids.size(), 1, "hay jefes para recorrer")
	for language: String in ["es", "en"]:
		Localization.set_language(language)
		for id: String in ids:
			var presentation: BossPresentation = await _open(id)
			await get_tree().process_frame
			var frame := Rect2(Vector2.ZERO, PresentationGeometry.LOGICAL_SIZE)
			var previous_bottom: float = -1.0
			for label_name: String in ["Title", "Illustration", "Name", "Line", "Hint"]:
				var control: Control = presentation.find_child(label_name, true, false)
				var rect: Rect2 = Rect2(control.position + (control.get_parent() as Control).position, control.size)
				assert_true(frame.encloses(rect), "%s/%s/%s se sale del marco: %s" % [language, id, label_name, rect])
				assert_gte(rect.position.y, previous_bottom - 0.5, "%s/%s/%s pisa al anterior" % [language, id, label_name])
				previous_bottom = rect.end.y
				var label := control as Label
				if label != null:
					assert_gte(label.get_theme_font_size("font_size"), 16, "%s/%s/%s: letra de 16 px o más" % [language, id, label_name])
			presentation.queue_free()
			await get_tree().process_frame


func test_mobile_font_never_drops_below_the_minimum() -> void:
	var small: Dictionary = {"composicion": {"celular": {"letra_pista": 9, "letra_texto": 12}, "pc": {"letra_pista": 9}}}
	assert_eq(BossPresentationArt.layout(true, small)["letra_pista"], BossPresentationArt.LETRA_MINIMA)
	assert_eq(BossPresentationArt.layout(true, small)["letra_texto"], BossPresentationArt.LETRA_MINIMA)
	assert_eq(BossPresentationArt.layout(false, small)["letra_pista"], 9, "la PC respeta su dato")


func test_layout_ignores_malformed_data() -> void:
	assert_eq(BossPresentationArt.layout(true, "x")["ancho_texto"], 900.0)
	assert_eq(BossPresentationArt.layout(true, {"composicion": {"celular": {"alto_retrato": -1, "ancho_texto": "ancho"}}})["alto_retrato"], 0.5)
	assert_eq(BossPresentationArt.layout(false, {"composicion": 4})["letra_nombre"], 52)
