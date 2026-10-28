# Auditoría de recursos (T236, sugerencia «Auditoría de recursos» de la spec §13, aprobada).
# Revisa que todo lo que los datos nombran existe: rutas de imágenes y sonidos, ids de enemigos, torres,
# niveles y colecciones, y los artículos de la Wiki. También avisa si aparece un dibujo o un sonido que nadie usa.
# No abre escenas: solo lee archivos de texto (P10).
extends GutTest

const ROOTS: Array[String] = ["res://data", "res://scenes", "res://scripts", "res://assets"]
const PATH_PATTERN: String = "res://[A-Za-z0-9_./\\-]+\\.(?:svg|png|wav|ogg|mp3|jpg|webp|tres|tscn|gdshader|gd|json|ttf|otf)"
## Dibujos que están en el repositorio pero el juego todavía no usa (hallazgo de T236, 2026-10-09). Salen de las
## tareas de arte T219, T220, T249 y M43: los objetos de mapa se dibujan hoy con `_draw`, los SVG de «trabajo»
## y «agotado» esperan a que alguien los enchufe, y el ícono de supresión y los anillos de la Disruptora quedaron
## sin cablear. Si se usan, se sacan de esta lista; si se borran, también. Un dibujo NUEVO sin uso hace fallar el test.
const KNOWN_UNUSED: Array[String] = [
	# T524 reemplazó la roca plana del desierto; se conserva el SVG histórico en el proyecto.
	"res://assets/sprites/map/roca_roja.svg",
	# T375 / D-170: arte aprobado disponible; faltan entradas futuras sin inventar textos de novedades.
	"res://assets/ui/novedades/news_header_plain.png",
	"res://assets/ui/novedades/news_icon_upgrade.png",
	"res://assets/sprites/ui/coleccion_disruptor.svg", "res://assets/sprites/ui/stat_resources.svg",
	"res://assets/sprites/towers/rendered/disruptor_suppression_icon.png",
	"res://assets/sprites/towers/rendered/cannon_level_3_icon.png",
	"res://assets/sprites/towers/rendered/disruptor_suppression_arc_2.png",
	"res://assets/sprites/towers/rendered/disruptor_suppression_arc_3.png",
	"res://assets/sprites/towers/rendered/cannon_level_2_icon.png",
	"res://assets/sprites/towers/rendered/disruptor_suppression_arc_1.png",
	"res://assets/sprites/towers/rendered/disruptor_pulse_ring.png",
]

var _files: Dictionary = {}   # { ruta: texto } de todo lo que puede nombrar un recurso


func before_all() -> void:
	for root: String in ROOTS:
		_collect(root)
	for extra: String in ["res://project.godot", "res://default_bus_layout.tres", "res://export_presets.cfg"]:
		_files[extra] = FileAccess.get_file_as_string(extra)


func _collect(dir: String) -> void:
	for sub: String in DirAccess.get_directories_at(dir):
		_collect(dir.path_join(sub))
	for file: String in DirAccess.get_files_at(dir):
		var ext: String = file.get_extension()
		if ext in ["tres", "tscn", "gd", "gdshader", "json", "cfg"]:
			_files[dir.path_join(file)] = FileAccess.get_file_as_string(dir.path_join(file))


func _exists(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


func _all_assets() -> Array[String]:
	var found: Array[String] = []
	var pending: Array[String] = ["res://assets"]
	while not pending.is_empty():
		var dir: String = pending.pop_back()
		for sub: String in DirAccess.get_directories_at(dir):
			pending.append(dir.path_join(sub))
		for file: String in DirAccess.get_files_at(dir):
			if file.get_extension() in ["svg", "png", "wav", "ogg", "tres", "gdshader"]:
				found.append(dir.path_join(file))
	found.sort()
	return found


# --- Toda ruta que un archivo nombra existe ---

func test_every_res_path_named_by_data_scenes_and_scripts_exists() -> void:
	var regex := RegEx.create_from_string(PATH_PATTERN)
	var checked: int = 0
	for source: String in _files:
		for match: RegExMatch in regex.search_all(_files[source]):
			var path: String = match.get_string()
			if path.contains("%"):
				continue
			checked += 1
			assert_true(_exists(path), "%s nombra %s, que no existe" % [source, path])
	assert_gt(checked, 300, "se revisaron las rutas de verdad")


func test_every_tres_resource_loads() -> void:
	var loaded: int = 0
	for source: String in _files:
		if source.ends_with(".tres") and not source.begins_with("res://addons"):
			loaded += 1
			assert_not_null(load(source), "%s no se pudo cargar" % source)
	assert_gt(loaded, 30)


# --- Ids sueltos ---

func test_every_enemy_and_tower_named_by_a_level_exists() -> void:
	var enemies: Array = Array(LevelFile.enemy_ids())
	var towers: Array[String] = []
	for file: String in DirAccess.get_files_at("res://data/towers"):
		towers.append(file.trim_suffix(".remap").get_basename())
	assert_gt(enemies.size(), 15)
	for id: String in LevelFile.campaign_ids():
		var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(LevelFile.LEVELS_DIR + id + ".json"))
		assert_true(raw is Dictionary, id)
		for wave: Variant in (raw as Dictionary).get("oleadas", []):
			for group: Variant in wave:
				assert_has(enemies, str(group.get("enemigo", "")), "%s: enemigo de una oleada" % id)
		for tower: Variant in (raw as Dictionary).get("torres", []):
			assert_has(towers, str(tower), "%s: torre ofrecida" % id)


func test_collections_point_to_real_levels_and_towers() -> void:
	var campaign: PackedStringArray = LevelFile.campaign_ids()
	for collection: StringName in CollectionDefinitions.ids():
		var sources: PackedStringArray = CollectionDefinitions.sources(collection)
		assert_gte(sources.size(), CollectionDefinitions.required(collection), "%s: hay piezas de sobra para completarla" % collection)
		for source: String in sources:
			assert_has(campaign, source, "%s: la fuente %s es un nivel de la campaña" % [collection, source])
		assert_true(_exists(CollectionDefinitions.icon_of(collection)), "%s: ícono" % collection)
	for file: String in DirAccess.get_files_at("res://data/towers"):
		var tower: TowerData = load("res://data/towers/" + file.trim_suffix(".remap")) as TowerData
		if tower != null and tower.required_collection != &"":
			assert_true(CollectionDefinitions.exists(tower.required_collection), "%s: pide una colección que no existe" % tower.id)


func test_wiki_and_lore_articles_have_no_errors_and_unlock_real_levels() -> void:
	var campaign: Array = Array(LevelFile.campaign_ids())
	var lore: Dictionary = Wiki.articles(Wiki.LORE_DIR, true, campaign)
	assert_eq(lore["errors"], PackedStringArray(), "artículos de Lore")
	assert_gt((lore["entries"] as Array).size(), 5)
	for id: Variant in lore["unlocks"]:
		assert_has(campaign, String(lore["unlocks"][id]), "%s: nivel que lo abre" % id)
	var ids: Dictionary = {}
	for entry: WikiEntry in lore["entries"]:
		assert_false(ids.has(entry.id), "%s repetido" % entry.id)
		ids[entry.id] = true
	assert_eq(Wiki.articles("res://data/wiki/", false)["errors"], PackedStringArray(), "artículos fijos")


# --- Recursos sin uso ---

func test_no_new_unused_drawing_or_sound() -> void:
	var orphans: Array[String] = []
	var haystack: String = ""
	for source: String in _files:
		haystack += _files[source] + "\n"
	for asset: String in _all_assets():
		if asset.get_extension() == "tres" or KNOWN_UNUSED.has(asset):
			continue
		var file: String = asset.get_file()
		# Cada torre suena «shot_» + su id (game.gd): el nombre se arma en el código y no aparece escrito.
		if file.begins_with("shot_") and FileAccess.file_exists("res://data/towers/%s.tres" % file.get_basename().trim_prefix("shot_")):
			continue
		# Se mira el nombre completo y, como muchos se arman con "%s", también el nombre sin extensión.
		if haystack.contains(file) or haystack.contains(file.get_basename()):
			continue
		orphans.append(asset)
	assert_eq(orphans, [] as Array[String], "dibujos o sonidos que nadie nombra (agregarlos a KNOWN_UNUSED si es a propósito)")


func test_known_unused_list_is_not_stale() -> void:
	var haystack: String = ""
	for source: String in _files:
		haystack += _files[source] + "\n"
	for asset: String in KNOWN_UNUSED:
		assert_true(_exists(asset), "%s ya no existe: sacarlo de KNOWN_UNUSED" % asset)
		assert_false(haystack.contains(asset.get_file()), "%s ahora SÍ se usa: sacarlo de KNOWN_UNUSED" % asset)
