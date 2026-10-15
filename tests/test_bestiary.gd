# Tests del bestiario que se va llenando (T114, RF-238 a RF-240, D-036).
extends GutTest

## T253: la Cuadrilla usa arte provisional (la forma geométrica, RF-156) hasta que T257 la dibuje. Cuando tengan
## dibujo, sacarlos de esta lista para que el chequeo vuelva a valer para todos.
const PROVISIONAL_ART: Array[StringName] = []  # T259: la Cuadrilla ya tiene arte; la lista queda para el próximo arte pendiente

const TEST_PATH: String = "user://test_save_bestiary.json"
const SCREEN: PackedScene = preload("res://scenes/ui/wiki_screen.tscn")

var _dev_before: bool


func before_each() -> void:
	_dev_before = DevMode.enabled
	DevMode.enabled = false
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()


func after_each() -> void:
	DevMode.enabled = _dev_before
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _seen_only(ids: Array) -> Callable:
	return func(id: StringName) -> bool: return ids.has(String(id))


func _category(id: StringName, is_seen: Callable) -> WikiCategory:
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels, is_seen):
		if category.id == id:
			return category
	return null


# --- El modelo ---

func test_a_seen_enemy_is_open_and_an_unseen_one_is_locked() -> void:
	var enemies: WikiCategory = _category(&"enemigos", _seen_only(["normal"]))
	assert_false(enemies.find(&"normal").locked)
	assert_true(enemies.find(&"boss").locked)
	assert_eq(enemies.find(&"normal").title, "Normal")
	assert_eq(enemies.find(&"boss").title, "???")


func test_a_locked_entry_leaks_no_real_data() -> void:
	# Que la pantalla no pueda filtrar nada: la entrada cerrada simplemente no lo tiene.
	var enemies: WikiCategory = _category(&"enemigos", _seen_only([]))
	for id: String in LevelFile.enemy_ids():
		var entry: WikiEntry = enemies.find(StringName(id))
		var enemy: EnemyData = load("res://data/enemies/%s.tres" % id)
		var text: String = entry.plain_text()
		assert_true(entry.locked, id)
		assert_false(text.contains(enemy.display_name), "%s: filtra el nombre" % id)
		if enemy.description != "":
			assert_false(text.contains(enemy.description), "%s: filtra la descripción" % id)
		assert_false(text.contains("Nivel "), "%s: filtra dónde aparece" % id)
		assert_false(text.contains("Vida"), "%s: filtra los datos" % id)
		assert_eq(entry.blocks.size(), 1, "solo el aviso")
		assert_eq(entry.subtitle, "")


func test_a_locked_entry_keeps_its_id_its_drawing_and_its_place() -> void:
	var open: WikiCategory = _category(&"enemigos", Callable())
	var locked: WikiCategory = _category(&"enemigos", _seen_only([]))
	assert_eq(locked.entries.size(), open.entries.size())
	for i: int in open.entries.size():
		assert_eq(locked.entries[i].id, open.entries[i].id, "el orden no cambia al abrir enemigos")
		var expected_icons: int = 0 if locked.entries[i].id in PROVISIONAL_ART else 1
		assert_eq(locked.entries[i].icon.size(), expected_icons, "el dibujo se ve en silueta")


func test_towers_and_the_guide_are_never_locked() -> void:
	for id: StringName in [&"torres", &"guia"]:
		for entry: WikiEntry in _category(id, _seen_only([])).entries:
			assert_false(entry.locked, "%s no se cierra" % entry.id)


func test_without_a_seen_function_everything_is_open() -> void:
	for entry: WikiEntry in _category(&"enemigos", Callable()).entries:
		assert_false(entry.locked)


func test_the_category_counts_its_open_entries() -> void:
	var total: int = LevelFile.enemy_ids().size()
	var none: WikiCategory = _category(&"enemigos", _seen_only([]))
	assert_eq(none.unlocked_count(), 0)
	assert_true(none.has_locked())
	var two: WikiCategory = _category(&"enemigos", _seen_only(["normal", "boss"]))
	assert_eq(two.unlocked_count(), 2)
	var all: WikiCategory = _category(&"enemigos", _seen_only(LevelFile.enemy_ids()))
	assert_eq(all.unlocked_count(), total)
	assert_false(all.has_locked())


# --- La pantalla ---

func _screen(is_seen: Callable) -> Control:
	var screen: Control = SCREEN.instantiate()
	screen.is_seen = is_seen
	screen.on_leave = func() -> void: pass
	add_child_autofree(screen)
	return screen


func test_the_screen_shows_question_marks_and_the_counter() -> void:
	var screen: Control = _screen(_seen_only(["normal", "fast"]))
	await wait_physics_frames(1)
	assert_eq(screen.tab_text(&"enemigos"), "Enemigos 2/%d" % LevelFile.enemy_ids().size())
	assert_eq(screen.tab_text(&"torres"), "Torres", "sin contador: nunca tiene cerradas")
	screen.show_entry(&"boss")
	var text: String = screen.detail_text()
	assert_string_contains(text, "???")
	assert_string_contains(text, "Todavía no te cruzaste")
	assert_false(text.contains("Jefe"))
	assert_false(text.contains("300"))
	screen.show_entry(&"normal")
	assert_string_contains(screen.detail_text(), "Normal")


func test_the_counter_disappears_when_all_are_seen() -> void:
	var screen: Control = _screen(_seen_only(LevelFile.enemy_ids()))
	await wait_physics_frames(1)
	assert_eq(screen.tab_text(&"enemigos"), "Enemigos")


func test_every_locked_entry_can_be_opened() -> void:
	var screen: Control = _screen(_seen_only([]))
	await wait_physics_frames(1)
	for id: StringName in screen.entry_ids():
		screen.show_entry(id)
		assert_eq(screen.current_entry(), id)


# --- Conectado con el guardado ---

func test_seeing_an_enemy_in_a_game_opens_it_in_the_wiki() -> void:
	var screen: Control = SCREEN.instantiate()  # con la función de verdad, la del guardado
	screen.on_leave = func() -> void: pass
	assert_false(screen.is_seen.call(&"troll"))
	SaveManager.mark_enemy_seen(&"troll")
	assert_true(screen.is_seen.call(&"troll"))
	screen.free()


func test_the_test_mode_sees_everything() -> void:
	var screen: Control = SCREEN.instantiate()
	assert_false(screen.is_seen.call(&"boss"))
	DevMode.enabled = true
	assert_true(screen.is_seen.call(&"boss"), "RF-240")
	screen.free()
