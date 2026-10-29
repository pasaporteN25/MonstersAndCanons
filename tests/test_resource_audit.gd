# Auditoría de recursos (T236, sugerencia «Auditoría de recursos» de la spec §13, aprobada).
# Revisa que todo lo que los datos nombran existe: rutas de imágenes y sonidos, ids de enemigos, torres,
# niveles y colecciones, y los artículos de la Wiki. También avisa si aparece un dibujo o un sonido que nadie usa.
# No abre escenas: solo lee archivos de texto (P10).
extends GutTest

const ROOTS: Array[String] = ["res://data", "res://scenes", "res://scripts", "res://assets"]
## Extensiones que se cuentan como «dibujo» y deben nombrarse por ruta completa o `uid` (T551). El audio y los
## shaders siguen por nombre porque se arman con "%s" (`shot_` + id de la torre, `music_`, etc.).
const DRAWING_EXTENSIONS: Array[String] = ["svg", "png", "webp", "jpg", "jpeg"]
const PATH_PATTERN: String = "res://[A-Za-z0-9_./\\-]+\\.(?:svg|png|wav|ogg|mp3|jpg|webp|tres|tscn|gdshader|gd|json|ttf|otf)"
## Dibujos que están en el repositorio pero el juego no usa. Un dibujo NUEVO sin uso hace fallar el test; si se usa o
## se borra, se saca de esta lista. Un recurso cuenta como usado si algún archivo de texto de `data/`, `scenes/`,
## `scripts/`, `assets/` o `tools/` nombra su ruta `res://` completa o su `uid` (T551, H5 de T538): ya no alcanza con
## que su nombre aparezca suelto en otro lado. Hay tres grupos.
const KNOWN_UNUSED: Array[String] = [
	# 1) Arte aprobado o histórico que espera ser enchufado (hallazgo de T236, 2026-10-09; tareas T219, T220, T249 y M43):
	# los SVG de «trabajo» y «agotado» esperan a alguien que los use, y el ícono de supresión y los anillos de la
	# Disruptora quedaron sin cablear. No se retiran sin pedido de Lucas.
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
	# 2) SVG fuente heredados (H4 de T538): los reemplazaron los PNG de `rendered/` o los objetos que MapDrawings
	# dibuja con `_draw`. NO se retiran ni se mueven hasta que Lucas resuelva D5 (¿a `art/` o se borran?).
	# Los que `tools/` precarga (boss, base_3, turret_cannon, flyer) no figuran: sí tienen un uso.
	# SVG fuente de «effects»:
	"res://assets/sprites/effects/flame.svg",
	# SVG fuente de «enemies»:
	"res://assets/sprites/enemies/armored.svg", "res://assets/sprites/enemies/fast.svg",
	"res://assets/sprites/enemies/guardian.svg", "res://assets/sprites/enemies/healer.svg",
	"res://assets/sprites/enemies/mirror.svg", "res://assets/sprites/enemies/normal.svg",
	"res://assets/sprites/enemies/shaman.svg", "res://assets/sprites/enemies/spider.svg",
	"res://assets/sprites/enemies/spiderling.svg", "res://assets/sprites/enemies/tank.svg",
	"res://assets/sprites/enemies/thief.svg", "res://assets/sprites/enemies/troll.svg",
	# SVG fuente de «map»:
	"res://assets/sprites/map/bloque.svg", "res://assets/sprites/map/bosque_explotable.svg",
	"res://assets/sprites/map/bush.svg", "res://assets/sprites/map/cactus.svg",
	"res://assets/sprites/map/campamento_vacio.svg", "res://assets/sprites/map/columna.svg",
	"res://assets/sprites/map/estatua.svg", "res://assets/sprites/map/flores.svg",
	"res://assets/sprites/map/gate.svg", "res://assets/sprites/map/helecho.svg",
	"res://assets/sprites/map/mina.svg", "res://assets/sprites/map/poste_cintas.svg",
	"res://assets/sprites/map/rock_a.svg", "res://assets/sprites/map/rock_b.svg",
	"res://assets/sprites/map/tree.svg", "res://assets/sprites/map/tronco.svg",
	# SVG fuente de «projectiles»:
	"res://assets/sprites/projectiles/basic.svg", "res://assets/sprites/projectiles/burst.svg",
	"res://assets/sprites/projectiles/cannon.svg", "res://assets/sprites/projectiles/fire.svg",
	"res://assets/sprites/projectiles/frost.svg", "res://assets/sprites/projectiles/mortar.svg",
	"res://assets/sprites/projectiles/multi.svg", "res://assets/sprites/projectiles/sniper.svg",
	"res://assets/sprites/projectiles/tesla.svg",
	# SVG fuente de «towers»:
	"res://assets/sprites/towers/base_1.svg", "res://assets/sprites/towers/base_2.svg",
	"res://assets/sprites/towers/mechanical_standard.svg", "res://assets/sprites/towers/turret_basic.svg",
	"res://assets/sprites/towers/turret_burst.svg", "res://assets/sprites/towers/turret_fire.svg",
	"res://assets/sprites/towers/turret_frost.svg", "res://assets/sprites/towers/turret_mortar.svg",
	"res://assets/sprites/towers/turret_multi.svg", "res://assets/sprites/towers/turret_sniper.svg",
	"res://assets/sprites/towers/turret_tesla.svg",
	# SVG fuente de «ui»:
	"res://assets/sprites/ui/demoledora.svg",
	# Retirados por T551 (aislados en `art/t551-retirados/`, ya no están en `assets/`): enemies/rammer.png y
	# enemies/rendered/healer.png (H3 de T538). El test los detectaría de nuevo si volvieran a `assets/` sin uso.
]

var _files: Dictionary = {}   # { ruta: texto } de todo lo que puede nombrar un recurso
var _tools_text: String = ""  # `tools/` también «usa» dibujos (make_icon.gd), pero no se le revisan las rutas


func before_all() -> void:
	for root: String in ROOTS:
		_collect(root)
	for extra: String in ["res://project.godot", "res://default_bus_layout.tres", "res://export_presets.cfg"]:
		_files[extra] = FileAccess.get_file_as_string(extra)
	for file: String in DirAccess.get_files_at("res://tools"):
		if file.get_extension() == "gd":
			_tools_text += FileAccess.get_file_as_string("res://tools/" + file) + "\n"


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
			if file.get_extension() in DRAWING_EXTENSIONS + ["wav", "ogg", "tres", "gdshader"]:
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

func _haystack() -> String:
	var text: String = _tools_text
	for source: String in _files:
		text += _files[source] + "\n"
	return text


## El `uid` que Godot guardó en el `.import` del dibujo (vacío si no hay).
func _uid_of(asset: String) -> String:
	var import_file: String = asset + ".import"
	if not FileAccess.file_exists(import_file):
		return ""
	var found: RegExMatch = RegEx.create_from_string("uid=\"(uid://[a-z0-9]+)\"").search(FileAccess.get_file_as_string(import_file))
	return "" if found == null else found.get_string(1)


## Un dibujo está usado si el texto nombra su ruta `res://` completa o su `uid`; el nombre suelto no alcanza
## (así `rammer.png` ya no se salva por `data/enemies/rammer.tres`). El audio y los shaders siguen por nombre.
func _is_used(asset: String, haystack: String, uid: String) -> bool:
	if asset.get_extension() in DRAWING_EXTENSIONS:
		return haystack.contains(asset) or (uid != "" and haystack.contains(uid))
	var file: String = asset.get_file()
	# Cada torre suena «shot_» + su id (game.gd): el nombre se arma en el código y no aparece escrito.
	if file.begins_with("shot_") and FileAccess.file_exists("res://data/towers/%s.tres" % file.get_basename().trim_prefix("shot_")):
		return true
	return haystack.contains(file) or haystack.contains(file.get_basename())


func test_no_new_unused_drawing_or_sound() -> void:
	var orphans: Array[String] = []
	var haystack: String = _haystack()
	for asset: String in _all_assets():
		if asset.get_extension() == "tres" or KNOWN_UNUSED.has(asset):
			continue
		if not _is_used(asset, haystack, _uid_of(asset)):
			orphans.append(asset)
	assert_eq(orphans, [] as Array[String], "dibujos o sonidos que nadie nombra por ruta completa o uid (agregarlos a KNOWN_UNUSED con su motivo si es a propósito)")


func test_known_unused_list_is_not_stale() -> void:
	var haystack: String = _haystack()
	for asset: String in KNOWN_UNUSED:
		assert_true(_exists(asset), "%s ya no existe: sacarlo de KNOWN_UNUSED" % asset)
		assert_false(_is_used(asset, haystack, _uid_of(asset)), "%s ahora SÍ se usa: sacarlo de KNOWN_UNUSED" % asset)


func test_unused_detection_needs_full_path_or_uid_not_the_bare_name() -> void:
	var asset: String = "res://assets/sprites/enemies/rammer.png"
	# El nombre suelto (como en `data/enemies/rammer.tres`) no es un uso.
	assert_false(_is_used(asset, "id = \"rammer\"\nrammer.png\nrendered/rammer_m43.png", ""), "nombre suelto")
	assert_true(_is_used(asset, "path=\"" + asset + "\"", ""), "ruta completa")
	assert_true(_is_used(asset, "uid://abc123", "uid://abc123"), "uid")
	assert_false(_is_used(asset, "uid://otro", "uid://abc123"), "uid distinto")
	assert_false(_is_used(asset, "", ""), "vacío")
	for ext: String in ["webp", "jpg", "svg"]:
		var other: String = "res://assets/x/y.%s" % ext
		assert_false(_is_used(other, "y.%s y" % ext, ""), "%s: nombre suelto" % ext)
		assert_true(_is_used(other, other, ""), "%s: ruta completa" % ext)
	assert_has(DRAWING_EXTENSIONS, "webp")
	assert_has(DRAWING_EXTENSIONS, "jpg")


func test_retired_png_stay_out_of_assets() -> void:
	# T551 / H3: aislados en `art/t551-retirados/` (con `.gdignore`, sin borrarlos del repositorio).
	for path: String in ["res://assets/sprites/enemies/rammer.png", "res://assets/sprites/enemies/rendered/healer.png"]:
		assert_false(FileAccess.file_exists(path), "%s volvió a assets/" % path)
	assert_true(FileAccess.file_exists("res://art/t551-retirados/.gdignore"))
	# Nadie los nombra por ruta completa: si volvieran a `assets/` sin uso, el detector los marcaría.
	var haystack: String = _haystack()
	assert_false(haystack.contains("sprites/enemies/rammer.png"))
	assert_false(haystack.contains("sprites/enemies/rendered/healer.png"))


func test_known_unused_svg_sources_are_listed() -> void:
	# H4 / D5: los SVG fuente sin uso están listados (no movidos); sin esa lista, el test de arriba fallaría.
	var svg: int = 0
	for asset: String in KNOWN_UNUSED:
		if asset.get_extension() == "svg":
			svg += 1
	assert_gt(svg, 40, "los SVG fuente heredados figuran en KNOWN_UNUSED")
	assert_has(KNOWN_UNUSED, "res://assets/sprites/enemies/armored.svg")
