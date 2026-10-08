# Colecciones por tecnología y hallazgos en ruinas (T211, RF-425 a RF-431).
extends GutTest

const PATH: String = "user://test_collections.json"
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const STANDARD: TowerData = preload("res://data/towers/mechanical_standard.tres")
const RUIN := Vector2i(4, 1)
const ROWS: Array = [
	"....................", "....e...............", "....................", "....................",
	"A##################S", "....................", "....................", "....................", "....................",
]

var old_path: String
var old_index: int
var old_campaign: CampaignData
var old_dev: bool
var old_community: LevelData
var game: Game


func before_each() -> void:
	old_path = SaveManager.save_path
	old_index = GameFlow.current_index
	old_campaign = GameFlow.campaign
	old_dev = DevMode.enabled
	old_community = GameFlow.current_community
	DevMode.enabled = false
	GameFlow.current_community = null
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
	SaveManager.save_path = PATH
	SaveManager.load_save()


func after_each() -> void:
	GameFlow.current_index = old_index
	GameFlow.campaign = old_campaign
	GameFlow.current_community = old_community
	GameFlow.forced_seed = -1
	GameFlow.test_level = null
	DevMode.enabled = old_dev
	SaveManager.save_path = old_path
	SaveManager.load_save()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
	Engine.time_scale = 1.0


## Una campaña de prueba de un solo nivel con una ruina con hallazgo; `id` decide si es fuente.
func _ruin_level(id: StringName = &"level_08", finding: String = "disruptor") -> LevelData:
	var data := {"version": 1, "nombre": "Ruina", "oro": 500, "vidas": 10,
		"leyenda": {"e": {"removible": {"clase": "escombro", "hallazgo": finding}}},
		"mapa": ROWS, "oleadas": [[{"enemigo": "normal", "cantidad": 1, "cada": 1.0}], [{"enemigo": "normal", "cantidad": 1, "cada": 1.0}]]}
	var result: Dictionary = LevelFile.parse(JSON.stringify(data), id)
	assert_eq(result["errors"], PackedStringArray())
	return result["level"]


func _start_campaign(level: LevelData) -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [level] as Array[LevelData]
	GameFlow.current_index = 0
	GameFlow.forced_seed = 3
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func _demolish() -> void:
	assert_true(game.infrastructure.order(RUIN))
	game.infrastructure.field.tick(60.0)


func _finish_wave() -> void:
	game.session.begin_wave()
	game.session.complete_wave()


# --- Definiciones (RF-425) ---

func test_both_collections_coexist_and_technology_is_unchanged() -> void:
	assert_true(CollectionDefinitions.exists(&"technology"))
	assert_true(CollectionDefinitions.exists(&"disruptor"))
	assert_eq(CollectionDefinitions.required(&"technology"), 5)
	assert_eq(CollectionDefinitions.origin(&"technology"), CollectionDefinitions.ORIGIN_CARRIER)
	assert_eq(CollectionDefinitions.sources(&"technology"), PackedStringArray(["level_01", "level_02", "level_03", "level_04", "level_05"]))
	assert_eq(CollectionDefinitions.required(&"disruptor"), 3)
	assert_eq(CollectionDefinitions.origin(&"disruptor"), CollectionDefinitions.ORIGIN_FINDING)
	assert_eq(CollectionDefinitions.name_of(&"disruptor"), "Disruptora")
	assert_eq(CollectionDefinitions.sources(&"disruptor"), PackedStringArray(["level_08", "level_09", "level_10"]))
	assert_eq(CollectionDefinitions.problems(), PackedStringArray(), "required coincide con sources")


func test_collectible_run_wrappers_match_definitions() -> void:
	assert_eq(CollectibleRun.definitions(), CollectionDefinitions.all())
	assert_eq(CollectibleRun.required(&"technology"), 5)
	assert_true(CollectibleRun.eligible(&"technology", &"level_03"))
	assert_false(CollectibleRun.eligible(&"technology", &"level_08"))
	assert_false(CollectibleRun.eligible(&"nope", &"level_08"), "una colección que no existe no tiene fuentes")
	assert_eq(CollectibleRun.required(&"nope"), 0)


func test_collection_of_level_falls_back_to_technology() -> void:
	assert_eq(CollectionDefinitions.collection_of_level(&"level_02"), &"technology")
	assert_eq(CollectionDefinitions.collection_of_level(&"level_09"), &"disruptor")
	assert_eq(CollectionDefinitions.collection_of_level(&"level_06"), &"technology", "no es fuente de ninguna")
	assert_eq(CollectionDefinitions.collection_of_level(&"prueba"), &"technology")


# --- FindingRun (RF-426, RF-427) ---

func test_piece_id_is_collection_and_level() -> void:
	assert_eq(FindingRun.piece_id(&"disruptor", &"level_09"), "disruptor:level_09")


func test_piece_is_pending_then_confirmed_with_the_wave() -> void:
	var run := FindingRun.new()
	assert_true(run.pick(&"disruptor", &"level_08", 2))
	assert_eq(run.pending().size(), 1)
	assert_true(run.confirmed().is_empty())
	run.complete_wave(1)
	assert_true(run.confirmed().is_empty(), "una oleada anterior no la confirma")
	run.complete_wave(2)
	assert_true(run.pending().is_empty())
	assert_eq(run.confirmed().size(), 1)
	assert_true(run.is_confirmed(&"disruptor", &"level_08"))


func test_repeating_a_piece_does_not_duplicate() -> void:
	var run := FindingRun.new()
	assert_true(run.pick(&"disruptor", &"level_08", 1))
	assert_false(run.pick(&"disruptor", &"level_08", 1), "ya pendiente")
	run.complete_wave(1)
	assert_false(run.pick(&"disruptor", &"level_08", 2), "ya confirmada")
	assert_eq(run.confirmed().size(), 1)
	assert_eq(run.count_of(&"disruptor"), 1)


func test_a_level_that_is_not_a_source_gives_no_piece() -> void:
	var run := FindingRun.new()
	assert_false(run.pick(&"disruptor", &"level_06", 1))
	assert_false(run.pick(&"nope", &"level_08", 1))
	assert_true(run.pending().is_empty())


func test_several_pending_pieces_confirm_separately() -> void:
	var run := FindingRun.new()
	run.pick(&"disruptor", &"level_08", 1)
	run.pick(&"disruptor", &"level_09", 3)
	run.complete_wave(1)
	assert_eq(run.confirmed().size(), 1)
	assert_eq(run.pending().size(), 1)
	assert_eq(run.count_of(&"disruptor", true), 1)
	assert_eq(run.count_of(&"disruptor"), 2)


# --- Guardado (RF-430) ---

func test_old_version_one_save_loads_and_disruptor_starts_empty() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"levels":{"level_01":{"completed":true,"best_lives":17}},"collections":{"technology":["level_01","level_02"]}}')
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"technology"), PackedStringArray(["level_01", "level_02"]))
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())
	assert_eq(SaveManager.best_lives(&"level_01"), 17)


func test_both_collections_are_saved_side_by_side() -> void:
	SaveManager.collect_source(&"technology", &"level_01")
	SaveManager.collect_source(&"disruptor", &"level_08")
	SaveManager.collect_source(&"disruptor", &"level_08")
	assert_true(SaveManager.save())
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"technology"), PackedStringArray(["level_01"]))
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08"]), "sin duplicados")
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	assert_eq(int(parsed["version"]), 1, "la versión del guardado no cambia")


func test_save_with_unknown_collection_and_foreign_levels_loads_without_breaking() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"collections":{"disruptor":["level_08","level_01",7],"futura":["level_08"]}}')
	file.close()
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08"]))
	assert_true(SaveManager.collected_sources(&"futura").is_empty())


func test_completing_the_collection_enables_a_test_tower() -> void:
	var tower: TowerData = STANDARD.duplicate()
	tower.required_collection = &"disruptor"
	var level: LevelData = GameFlow.level(5)
	assert_false(level.available_towers([tower] as Array[TowerData], SaveManager.collection_complete).has(tower))
	SaveManager.collect_source(&"disruptor", &"level_08")
	SaveManager.collect_source(&"disruptor", &"level_09")
	assert_false(SaveManager.collection_complete(&"disruptor"), "con 2 de 3 todavía no")
	SaveManager.collect_source(&"disruptor", &"level_10")
	assert_true(SaveManager.collection_complete(&"disruptor"))
	assert_true(level.available_towers([tower] as Array[TowerData], SaveManager.collection_complete).has(tower))
	assert_false(SaveManager.collection_complete(&"technology"), "la otra colección no se completa sola")


# --- La partida ---

func test_campaign_ruin_gives_a_piece_that_is_confirmed_and_saved() -> void:
	_start_campaign(_ruin_level())
	assert_true(game.infrastructure.field.finding_recovered(RUIN) == false)
	_demolish()
	assert_eq(game.findings.pending().size(), 1)
	assert_eq(game.findings.pending()[0]["wave"], 1, "demolida en preparación: se confirma con la 1.ª oleada")
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty(), "nada se guarda antes del resultado")
	_finish_wave()
	assert_eq(game.findings.confirmed().size(), 1)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())
	game.session.lose_lives(1000)  # una derrota después de confirmar conserva la pieza
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08"]))
	SaveManager.load_save()
	assert_eq(SaveManager.collected_sources(&"disruptor"), PackedStringArray(["level_08"]), "quedó en el archivo")


func test_defeat_before_confirming_loses_the_piece() -> void:
	_start_campaign(_ruin_level())
	_demolish()
	assert_eq(game.findings.pending().size(), 1)
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())


func test_piece_taken_during_a_wave_confirms_with_that_wave() -> void:
	_start_campaign(_ruin_level())
	game.session.begin_wave()
	_demolish()
	assert_eq(game.findings.pending()[0]["wave"], 1)
	game.session.complete_wave()
	assert_eq(game.findings.confirmed().size(), 1)


func test_repeating_the_ruin_does_not_duplicate_and_the_panel_says_so() -> void:
	SaveManager.collect_source(&"disruptor", &"level_08")
	_start_campaign(_ruin_level())
	assert_true(game.infrastructure.field.finding_recovered(RUIN))
	game.infrastructure.select(RUIN)
	assert_string_contains(game.hud.obstacle_panel._reward.text, "ya recuperada")
	_demolish()
	assert_true(game.findings.pending().is_empty(), "la pieza ya estaba")
	game.session.lose_lives(1000)
	assert_eq(SaveManager.collected_sources(&"disruptor").size(), 1)


func test_panel_says_pending_before_demolishing() -> void:
	_start_campaign(_ruin_level())
	game.infrastructure.select(RUIN)
	assert_string_contains(game.hud.obstacle_panel._reward.text, "Pieza de la Disruptora: pendiente")


func test_a_level_that_is_not_a_source_behaves_as_a_plain_ruin() -> void:
	_start_campaign(_ruin_level(&"level_06"))
	_demolish()
	assert_true(game.findings.pending().is_empty())
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())


func test_outside_the_campaign_no_pieces_are_collected() -> void:
	GameFlow.campaign = CampaignData.new()
	GameFlow.campaign.levels = [_ruin_level()] as Array[LevelData]
	GameFlow.current_index = -1
	GameFlow.test_level = _ruin_level()  # el editor ("Probar")
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	game.infrastructure.select(RUIN)
	assert_string_contains(game.hud.obstacle_panel._reward.text, "Aquí no se recogen piezas")
	_demolish()
	assert_true(game.findings.pending().is_empty())
	game.session.lose_lives(1000)
	assert_true(SaveManager.collected_sources(&"disruptor").is_empty())


func test_community_and_test_mode_do_not_collect() -> void:
	GameFlow.current_index = -1
	GameFlow.current_community = _ruin_level(&"level_08")
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)
	_demolish()
	assert_true(game.findings.pending().is_empty())
	game.queue_free()
	await get_tree().process_frame
	GameFlow.current_community = null
	_start_campaign(_ruin_level())
	DevMode.enabled = true
	assert_false(game._collects_pieces(), "el modo de pruebas no recoge")


func test_hud_bar_shows_the_collection_of_the_level() -> void:
	SaveManager.collect_source(&"disruptor", &"level_09")
	_start_campaign(_ruin_level())
	assert_eq((game.hud.get_node("%TechnologyLabel") as Label).text, "1/3")
	_demolish()
	assert_eq((game.hud.get_node("%TechnologyLabel") as Label).text, "2/3", "la pendiente se suma a la barra")
	GameFlow.campaign.levels = [GameFlow.level(0)] as Array[LevelData]


func test_technology_level_keeps_showing_technology_in_the_bar() -> void:
	SaveManager.collect_source(&"technology", &"level_02")
	_start_campaign(_ruin_level(&"level_01"))
	assert_eq((game.hud.get_node("%TechnologyLabel") as Label).text, "1/5")


# --- Textos y Wiki (RF-431) ---

func test_wiki_shows_each_collection_with_progress_and_tower() -> void:
	var tower: TowerData = STANDARD.duplicate()
	tower.required_collection = &"disruptor"
	var entry: WikiEntry = Wiki.collection_entry(&"disruptor", 2, [tower] as Array[TowerData])
	assert_eq(entry.title, "Disruptora")
	assert_string_contains(entry.plain_text(), "2/3")
	assert_string_contains(entry.plain_text(), tower.display_name)
	var empty: WikiEntry = Wiki.collection_entry(&"disruptor", 0, [] as Array[TowerData])
	assert_string_contains(empty.plain_text(), "todavía ninguna torre")


func test_wiki_has_a_collections_category() -> void:
	var found: bool = false
	for category: WikiCategory in Wiki.categories(GameFlow.campaign.levels):
		if category.id == &"colecciones":
			found = true
			assert_eq(category.entries.size(), CollectionDefinitions.ids().size())
	assert_true(found)
