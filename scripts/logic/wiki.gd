# La wiki del juego (spec §10.5, D-035). Arma las categorías y sus entradas leyendo los DATOS:
# agregar un enemigo a data/enemies/, una torre a data/towers/ o un artículo a data/wiki/ lo agrega
# solo. La pantalla (WikiScreen) no sabe qué es un enemigo: dibuja lo que esta clase le da.
#
# Para sumar una categoría nueva (Niveles, Lore…): una función que devuelve sus entradas y una
# línea en `_providers()`.
class_name Wiki
extends RefCounted

const TOWERS_DIR: String = "res://data/towers/"
const ARTICLES_DIR: String = "res://data/wiki/"
## M52 (RF-469): los artículos de Lore viven en una subcarpeta que la Guía no lee.
const LORE_DIR: String = "res://data/wiki/lore/"
const ARTICLE_VERSION: int = 1
const ARTICLE_KEYS: PackedStringArray = ["version", "titulo", "subtitulo", "orden", "bloques"]
## RF-469: los artículos de Lore suman la clave obligatoria "desbloqueo" (el nivel que, al ganarse, los abre).
const LORE_KEYS: PackedStringArray = ["version", "titulo", "subtitulo", "orden", "bloques", "desbloqueo"]
const DEFAULT_ORDER: int = 100
const LOCKED_TITLE: String = "???"


## Las categorías con sus entradas. Una categoría sin entradas no se incluye (RF-232).
## `campaign` son los niveles de la campaña (para "dónde aparece"); se pasa de afuera para probarlo
## con una campaña de mentira. `is_seen` es una función (id del enemigo → bool) que dice si el jugador
## ya lo vio (bestiario, RF-238); sin función, todo está abierto. `is_completed` es una función (id del nivel
## → bool) que dice si el jugador ganó ese nivel (Lore, RF-470); igual, sin función todo está abierto.
static func categories(campaign: Array[LevelData] = [], is_seen: Callable = Callable(),
		is_completed: Callable = Callable()) -> Array[WikiCategory]:
	var result: Array[WikiCategory] = []
	for provider: Dictionary in _providers():
		var build: Callable = provider["build"]
		var entries: Array[WikiEntry] = build.call(campaign, is_seen, is_completed)
		if not entries.is_empty():
			result.append(WikiCategory.new(provider["id"], provider["title"], entries))
	return result


static func _providers() -> Array[Dictionary]:
	return [
		{"id": &"enemigos", "title": Localization.t(&"wiki.cat_enemies"), "build": _enemy_entries},
		{"id": &"torres", "title": Localization.t(&"wiki.cat_towers"), "build": _tower_entries},
		{"id": &"colecciones", "title": Localization.t(&"wiki.cat_collections"), "build": _collection_entries},
		{"id": &"guia", "title": Localization.t(&"wiki.cat_guide"), "build": _article_entries},
		{"id": &"lore", "title": Localization.t(&"wiki.cat_lore"), "build": _lore_entries},  # RF-469
	]


# --- Enemigos ---

static func _enemy_entries(campaign: Array[LevelData], is_seen: Callable, _is_completed: Callable) -> Array[WikiEntry]:
	var enemies: Array[EnemyData] = []
	for resource: Resource in _load_all(LevelFile.ENEMIES_DIR):
		if resource is EnemyData:
			enemies.append(resource)
	# Del más débil al más fuerte (RF-233); a igual vida, por nombre, para que el orden no cambie.
	enemies.sort_custom(func(a: EnemyData, b: EnemyData) -> bool:
		return a.max_health < b.max_health or (a.max_health == b.max_health and String(a.id) < String(b.id)))
	var entries: Array[WikiEntry] = []
	for enemy: EnemyData in enemies:
		if is_seen.is_valid() and not is_seen.call(enemy.id):
			entries.append(locked_enemy_entry(enemy))
		else:
			entries.append(enemy_entry(enemy, enemies, campaign))
	return entries


## La entrada cerrada de un enemigo que el jugador todavía no vio (RF-239). Solo guarda su id y su
## dibujo (que la pantalla pinta en silueta): nada del nombre, los datos ni los niveles.
static func locked_enemy_entry(enemy: EnemyData) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = enemy.id
	entry.title = LOCKED_TITLE
	entry.locked = true
	if enemy.texture != null:
		entry.icon.append(enemy.texture)
	entry.add_text(Localization.t(&"wiki.locked_enemy"))
	return entry


## La entrada de un enemigo. `all_enemies` sirve para saber quién lo suelta al morir.
## `towers` = qué torres cuentan para la "Contramedida" (RF-450); si no se pasa, todas las de `data/towers/`.
static func enemy_entry(enemy: EnemyData, all_enemies: Array[EnemyData], campaign: Array[LevelData],
		towers: Array[TowerData] = []) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = enemy.id
	entry.title = enemy.name_text()
	var kind: String = Localization.t(&"wiki.enemy.flies" if enemy.is_flying else &"wiki.enemy.ground")
	entry.subtitle = kind + (Localization.t(&"wiki.enemy.dangerous") if Rules.is_dangerous(enemy) else "")
	if enemy.texture != null:
		entry.icon.append(enemy.texture)
	if enemy.description_text() != "":
		entry.add_text(enemy.description_text())
	var facts: Array = [
		[Localization.t(&"wiki.fact.health"), str(enemy.max_health)],
		[Localization.t(&"wiki.fact.speed"), Localization.t_fmt(&"wiki.fact.speed_value", {"x": "%.1f" % enemy.speed_tiles})],
		[Localization.t(&"wiki.fact.armor"), str(enemy.armor) if enemy.armor > 0 else Localization.t(&"wiki.fact.none")],
		[Localization.t(&"wiki.fact.reward"), str(enemy.reward)],
		[Localization.t(&"wiki.fact.lives"), str(enemy.lives_damage)],
		[Localization.t(&"wiki.fact.flies"), Localization.t(&"common.yes" if enemy.is_flying else &"common.no")],
	]
	if enemy.slow_resistance > 0.0:
		facts.append([Localization.t(&"wiki.fact.slow_resist"), "%d %%" % roundi(enemy.slow_resistance * 100.0)])
	if enemy.regen_percent_per_second > 0.0:
		facts.append([Localization.t(&"wiki.fact.regen"), Localization.t_fmt(&"wiki.fact.regen_value", {"x": "%.0f" % enemy.regen_percent_per_second})])
	if enemy.gold_drain_amount > 0 and enemy.gold_drain_interval > 0.0:
		facts.append([Localization.t(&"wiki.fact.steal"), Localization.t_fmt(&"wiki.fact.steal_value", {"n": enemy.gold_drain_amount, "s": _number(enemy.gold_drain_interval), "floor": enemy.gold_drain_floor})])
	if enemy.charge_distance_tiles > 0.0:
		facts.append([Localization.t(&"wiki.fact.charge"), Localization.t_fmt(&"wiki.fact.charge_value", {"tiles": _number(enemy.charge_distance_tiles), "mult": _number(enemy.charge_multiplier), "slow": _number(enemy.charge_slow_tolerance * 100.0)})])
		facts.append([Localization.t(&"wiki.fact.impact"), Localization.t_fmt(&"wiki.fact.impact_value", {"wear": _number(enemy.charge_wear_percent), "radius": _number(enemy.charge_impact_radius_tiles)})])
	if enemy.death_spawn != null and enemy.death_spawn_count > 0:
		facts.append([Localization.t(&"wiki.fact.death_spawn"), "%d × %s" % [enemy.death_spawn_count, enemy.death_spawn.name_text()]])
	if enemy.stun_interval > 0.0:  # RF-281, RF-287
		facts.append([Localization.t(&"wiki.fact.spell"), Localization.t_fmt(&"wiki.fact.spell_value", {"range": _number(enemy.stun_range_tiles), "s": _number(enemy.stun_seconds), "every": _number(enemy.stun_interval)})])
	if enemy.reflect_range_tiles > 0.0:  # RF-283, RF-287
		facts.append([Localization.t(&"wiki.fact.reflect"), Localization.t_fmt(&"wiki.fact.reflect_value", {"range": _number(enemy.reflect_range_tiles), "s": _number(enemy.reflect_stun_seconds)})])
	if enemy.aura_radius_tiles > 0.0:  # RF-270, RF-277
		var reach: String = Localization.t_fmt(&"wiki.fact.reach", {"r": _number(enemy.aura_radius_tiles)})
		if enemy.aura_armor_bonus > 0:
			facts.append([Localization.t(&"wiki.fact.aura_armor"), Localization.t_fmt(&"wiki.fact.aura_armor_value", {"n": enemy.aura_armor_bonus, "reach": reach})])
		if enemy.aura_heal_percent_per_second > 0.0:
			facts.append([Localization.t(&"wiki.fact.aura_heal"), Localization.t_fmt(&"wiki.fact.aura_heal_value", {"x": _number(enemy.aura_heal_percent_per_second), "reach": reach})])
	var counters: Array[String] = TowerText.suppressors_of(enemy, towers if not towers.is_empty() else _all_towers())
	if not counters.is_empty():  # RF-450: "Contramedida", leída de los datos de las torres
		facts.append([Localization.t(&"wiki.fact.counter"), Localization.t_fmt(&"wiki.fact.counter_value", {"names": TowerText.join_names(counters)})])
	entry.add_facts(facts)

	entry.add_heading(Localization.t(&"wiki.where"))
	var levels: PackedStringArray = _levels_with(enemy, campaign)
	var released_by: PackedStringArray = []
	for other: EnemyData in all_enemies:
		if other.death_spawn != null and other.death_spawn.id == enemy.id and other.death_spawn_count > 0:
			released_by.append(other.name_text())
	if not levels.is_empty():
		entry.add_text("\n".join(levels))
	elif released_by.is_empty():
		entry.add_text(Localization.t(&"wiki.not_in_campaign"))
	if not released_by.is_empty():
		entry.add_text(Localization.t_fmt(&"wiki.released_by", {"names": ", ".join(released_by)}))
	return entry


## Un número sin ceros de más: 2.0 → "2", 2.5 → "2.5".
static func _number(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, roundf(value)) else "%.1f" % value


## "Nivel 3 · Encrucijada", uno por cada nivel donde algún grupo lo trae.
static func _levels_with(enemy: EnemyData, campaign: Array[LevelData]) -> PackedStringArray:
	var found: PackedStringArray = []
	for i: int in campaign.size():
		var level: LevelData = campaign[i]
		var appears: bool = false
		for wave: WaveData in level.waves:
			for group: SpawnGroup in wave.groups:
				if group.enemy != null and group.enemy.id == enemy.id:
					appears = true
		if appears:
			found.append(Localization.t_fmt(&"wiki.level_line", {"n": i + 1, "name": level.display_name}))
	return found


# --- Torres ---

static func _tower_entries(_campaign: Array[LevelData], _is_seen: Callable, _is_completed: Callable) -> Array[WikiEntry]:
	var towers: Array[TowerData] = _all_towers()
	# De la más barata a la más cara (RF-234).
	towers.sort_custom(func(a: TowerData, b: TowerData) -> bool:
		var cost_a: int = a.levels[0].cost
		var cost_b: int = b.levels[0].cost
		return cost_a < cost_b or (cost_a == cost_b and String(a.id) < String(b.id)))
	var entries: Array[WikiEntry] = []
	for tower: TowerData in towers:
		entries.append(tower_entry(tower, towers))
	return entries


## Todos los enemigos de `data/enemies/`.
static func _all_enemies() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
	for resource: Resource in _load_all(LevelFile.ENEMIES_DIR):
		if resource is EnemyData:
			enemies.append(resource)
	return enemies


## Todas las torres de `data/towers/` (las que tienen niveles).
static func _all_towers() -> Array[TowerData]:
	var towers: Array[TowerData] = []
	for resource: Resource in _load_all(TOWERS_DIR):
		if resource is TowerData and not (resource as TowerData).levels.is_empty():
			towers.append(resource)
	return towers


## `towers` = con qué torres puede combinar (RF-317); si no se pasa, todas las de `data/towers/`.
static func tower_entry(tower: TowerData, towers: Array[TowerData] = []) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = tower.id
	entry.title = tower.name_text()
	entry.subtitle = Localization.t(&"wiki.tower.support") if tower.support_only else Localization.t(&"wiki.tower.air" if tower.can_hit_air else &"wiki.tower.ground_only")
	var first: TowerLevelData = tower.levels[0]
	var icon: Texture2D = TowerVisual.mounted_icon(first.base_texture,
		TowerVisual.frame_texture(tower.turret_atlas, -PI / 2.0) if tower.turret_atlas != null else tower.turret_texture)
	if icon != null:
		entry.icon.append(icon)
	if tower.description_text() != "":
		entry.add_text(tower.description_text())
	var facts: Array = [[Localization.t(&"wiki.fact.function"), Localization.t(&"wiki.fact.function_support")]] if tower.support_only \
			else [[Localization.t(&"wiki.tower.air"), Localization.t(&"common.yes" if tower.can_hit_air else &"common.no")]]
	if tower.required_collection != &"":
		facts.append([Localization.t(&"wiki.fact.requirement"), Localization.t_fmt(&"wiki.fact.requirement_value", {"n": CollectionDefinitions.required(tower.required_collection), "word": Localization.t(&"wiki.word.advances" if CollectionDefinitions.origin(tower.required_collection) == CollectionDefinitions.ORIGIN_CARRIER else &"wiki.word.pieces")})])
	if first.suppress_seconds > 0.0:  # RF-444, RF-450
		facts.append([Localization.t(&"wiki.fact.pulse"), TowerText.pulse_line(first, TowerText.emitter_names(_all_enemies()))])
		facts.append([Localization.t(&"wiki.fact.limits"), Localization.t(&"wiki.fact.limits_value")])
	if tower.footprint > 1:  # RF-298
		facts.append([Localization.t(&"wiki.fact.size"), Localization.t_fmt(&"wiki.fact.size_value", {"n": tower.footprint})])
	facts.append_array(TowerText.cost_facts(tower))  # RF-437
	entry.add_facts(facts)
	entry.add_heading(Localization.t(&"wiki.levels"))
	var rows: Array = [[Localization.t(&"wiki.col.level"), Localization.t(&"wiki.col.gold"), Localization.t(&"wiki.col.damage"), Localization.t(&"wiki.col.rate"),
			Localization.t(&"wiki.col.dps"), Localization.t(&"wiki.col.range")]]
	for i: int in tower.levels.size():
		var level: TowerLevelData = tower.levels[i]
		rows.append([
			"%d (%s)" % [i + 1, Localization.t(&"wiki.level_build" if i == 0 else &"wiki.level_upgrade")],
			str(level.cost),
			str(level.damage),
			"%.1f/s" % level.fire_rate,
			"%.1f" % (level.damage * level.fire_rate),
			"%.1f" % level.range_tiles,
		])
	entry.add_table(rows)
	var has_effects: bool = false
	for i: int in tower.levels.size():
		var effects: Array[String] = TowerText.effects(tower.levels[i])
		if not effects.is_empty():
			if not has_effects:
				entry.add_heading(Localization.t(&"wiki.effects"))
				has_effects = true
			entry.add_text(Localization.t_fmt(&"wiki.effects_line", {"n": i + 1, "effects": " · ".join(effects)}))
	# RF-317: la torre que pone un estado dice con quién combina (en la Wiki, con todas las torres).
	var partners: Array[String] = TowerText.combo_partners(tower, towers if not towers.is_empty() else _all_towers())
	if not partners.is_empty():
		entry.add_heading(Localization.t(&"wiki.combos"))
		for line: String in partners:
			entry.add_text(line)
	return entry


# --- Colecciones (RF-431) ---

static func _collection_entries(_campaign: Array[LevelData], _is_seen: Callable, _is_completed: Callable) -> Array[WikiEntry]:
	var entries: Array[WikiEntry] = []
	# SaveManager es un autoload: se lo busca por el árbol para que `tools/` (que se compila antes que los
	# autoloads) pueda cargar este script. Sin autoload (herramientas), el progreso es 0.
	for id: StringName in CollectionDefinitions.ids():
		entries.append(collection_entry(id, _collected_count(id), _all_towers()))
	return entries


## Cuántas piezas juntó el jugador. Se busca el autoload por nombre (no se lo nombra en el código) porque los
## scripts de `tools/` se compilan antes que los autoloads y esta clase los arrastra (gdscript.md).
static func _collected_count(id: StringName) -> int:
	var tree := Engine.get_main_loop() as SceneTree
	var save: Node = tree.root.get_node_or_null("SaveManager") if tree != null else null
	return 0 if save == null else (save.call("collected_sources", id) as PackedStringArray).size()


## RF-431: una colección con su progreso y qué torre desbloquea. `collected` se pasa de afuera para probarla.
static func collection_entry(id: StringName, collected: int, towers: Array[TowerData]) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = id
	entry.title = CollectionDefinitions.name_of(id)
	var icon_path: String = CollectionDefinitions.icon_of(id)
	if ResourceLoader.exists(icon_path):
		entry.icon.append(load(icon_path) as Texture2D)
	var from_finding: bool = CollectionDefinitions.origin(id) == CollectionDefinitions.ORIGIN_FINDING
	entry.subtitle = Localization.t(&"wiki.collection.pieces" if from_finding else &"wiki.collection.advances")
	var unlocks := PackedStringArray()
	for tower: TowerData in towers:
		if tower.required_collection == id:
			unlocks.append(tower.name_text())
	entry.add_text(Localization.t_fmt(&"wiki.collection.how", {"n": CollectionDefinitions.required(id)}))
	entry.add_facts([
		[Localization.t(&"wiki.collection.progress"), "%d/%d" % [collected, CollectionDefinitions.required(id)]],
		[Localization.t(&"wiki.collection.unlocks"), ", ".join(unlocks) if not unlocks.is_empty() else Localization.t(&"wiki.collection.no_tower")],
	])
	return entry


# --- Guía (artículos en data/wiki/*.json) ---

static func _article_entries(_campaign: Array[LevelData], _is_seen: Callable, _is_completed: Callable) -> Array[WikiEntry]:
	return articles(ARTICLES_DIR)["entries"]


# --- Lore (RF-469, RF-470; artículos en data/wiki/lore/*.json) ---

## Los artículos de Lore, en su orden. Los que todavía no se abrieron (el nivel de su "desbloqueo" no figura
## ganado) se ven cerrados: «???» y el aviso «Se abre al ganar el nivel N.», sin título ni texto del artículo.
static func _lore_entries(_campaign: Array[LevelData], _is_seen: Callable, is_completed: Callable) -> Array[WikiEntry]:
	var campaign_ids: Array = Array(LevelFile.campaign_ids())
	var loaded: Dictionary = articles(LORE_DIR, true, campaign_ids)
	var unlocks: Dictionary = loaded["unlocks"]
	var entries: Array[WikiEntry] = []
	for entry: WikiEntry in loaded["entries"]:
		if LoreUnlock.is_open(unlocks[entry.id], is_completed):
			entries.append(entry)
		else:
			entries.append(locked_lore_entry(entry.id, unlocks[entry.id], campaign_ids))
	return entries


## La entrada cerrada de un artículo de Lore (RF-470): nada de su título ni su texto, solo el número del nivel.
static func locked_lore_entry(id: StringName, unlock_level: StringName, campaign_ids: Array) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = id
	entry.title = LOCKED_TITLE
	entry.locked = true
	entry.add_text(LoreUnlock.locked_text(unlock_level, campaign_ids))
	return entry


## Lee todos los artículos de una carpeta. Devuelve {"entries": Array[WikiEntry] (ordenadas),
## "errors": PackedStringArray, "unlocks": {id → nivel que lo abre}}. Un artículo roto se salta y deja su
## motivo en `errors` (RF-236): el juego lo ignora, pero los tests exigen que la lista esté vacía con los
## artículos oficiales. Con `lore` (RF-469) cada artículo trae "desbloqueo", que tiene que ser un nivel de
## `campaign_ids`.
static func articles(dir: String, lore: bool = false, campaign_ids: Array = []) -> Dictionary:
	var entries: Array[WikiEntry] = []
	var errors: PackedStringArray = []
	var unlocks: Dictionary = {}
	if not DirAccess.dir_exists_absolute(dir):
		return {"entries": entries, "errors": errors, "unlocks": unlocks}
	var files: PackedStringArray = DirAccess.get_files_at(dir)
	files.sort()
	var orders: Dictionary = {}
	for file: String in files:
		if not file.ends_with(".json"):
			continue
		var parsed: Dictionary = parse_article(FileAccess.get_file_as_string(dir.path_join(file)), StringName(file.get_basename()), lore, campaign_ids)
		for error: String in parsed["errors"]:
			errors.append("%s: %s" % [file, error])
		if parsed["entry"] != null:
			var entry: WikiEntry = parsed["entry"]
			entries.append(entry)
			orders[entry.id] = parsed["order"]
			unlocks[entry.id] = parsed["unlock"]
	entries.sort_custom(func(a: WikiEntry, b: WikiEntry) -> bool:
		if orders[a.id] != orders[b.id]:
			return orders[a.id] < orders[b.id]
		return String(a.id) < String(b.id))
	return {"entries": entries, "errors": errors, "unlocks": unlocks}


## Lee el texto de un artículo. Devuelve {"entry": WikiEntry o null, "order": int, "unlock": StringName,
## "errors": PackedStringArray}. `lore`: es un artículo de Lore y exige "desbloqueo" (RF-469).
static func parse_article(text: String, id: StringName, lore: bool = false, campaign_ids: Array = []) -> Dictionary:
	var errors: PackedStringArray = []
	var json := JSON.new()  # parse() y no parse_string(): un texto roto no debe imprimir errores del motor
	if json.parse(text) != OK:
		return _article_failed(["No es un JSON válido (línea %d): %s" % [json.get_error_line(), json.get_error_message()]])
	if not json.data is Dictionary:
		return _article_failed(["El archivo tiene que empezar con { y terminar con }."])
	var data: Dictionary = json.data
	var known_keys: PackedStringArray = LORE_KEYS if lore else ARTICLE_KEYS
	for key: Variant in data.keys():
		if not known_keys.has(str(key)):
			errors.append("La clave \"%s\" no existe (las válidas: %s)." % [key, ", ".join(known_keys)])
	var unlock: StringName = &""
	if lore:
		var raw_unlock: Variant = data.get("desbloqueo")
		if not LoreUnlock.is_level_id(raw_unlock):
			errors.append("Falta \"desbloqueo\": el id del nivel que abre el artículo, como \"level_08\".")
		elif not campaign_ids.has(raw_unlock) and not campaign_ids.has(StringName(raw_unlock)):
			errors.append("\"desbloqueo\": el nivel \"%s\" no figura en la campaña." % raw_unlock)
		else:
			unlock = StringName(raw_unlock)
	if not data.has("version") or not _is_whole(data["version"]) or int(data["version"]) != ARTICLE_VERSION:
		errors.append("Falta \"version\": %d." % ARTICLE_VERSION)
	var title: String = str(data.get("titulo", "")).strip_edges() if data.get("titulo") is String else ""
	if title == "":
		errors.append("Falta \"titulo\" (un texto).")
	var order: int = DEFAULT_ORDER
	if data.has("orden"):
		if _is_whole(data["orden"]):
			order = int(data["orden"])
		else:
			errors.append("\"orden\" tiene que ser un número entero.")
	var subtitle: String = ""
	if data.has("subtitulo"):
		if data["subtitulo"] is String:
			subtitle = data["subtitulo"]
		else:
			errors.append("\"subtitulo\" tiene que ser un texto.")
	var blocks: Array[Dictionary] = []
	if not data.get("bloques") is Array or (data["bloques"] as Array).is_empty():
		errors.append("Falta \"bloques\" (una lista con al menos un bloque).")
	else:
		var raw: Array = data["bloques"]
		for i: int in raw.size():
			var block: Variant = _read_block(raw[i], "bloque %d" % (i + 1), errors)
			if block != null:
				blocks.append(block)
	if not errors.is_empty():
		return _article_failed(errors)
	if not lore and Localization.language != Localization.DEFAULT_LANGUAGE:  # T534: el Lore queda en español (D-222)
		title = Localization.data_text("wiki", id, "title", title)
		subtitle = Localization.data_text("wiki", id, "subtitle", subtitle)
		blocks = _translate_blocks(id, blocks)
	var entry := WikiEntry.new()
	entry.id = id
	entry.title = title
	entry.subtitle = subtitle
	entry.blocks = blocks
	return {"entry": entry, "order": order, "unlock": unlock, "errors": errors}


## T534: los bloques de un artículo de la Guía en el idioma activo. Los textos son `wiki.<id>.b<n>` (n desde 1); las celdas
## de una tabla o de datos, `wiki.<id>.b<n>.r<fila>c<columna>` (desde 1 y 0). Lo que no tiene traducción queda como está.
static func _translate_blocks(id: StringName, blocks: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i: int in blocks.size():
		var block: Dictionary = blocks[i].duplicate(true)
		if block.has("texto"):
			block["texto"] = Localization.data_text("wiki", id, "b%d" % (i + 1), String(block["texto"]))
		else:
			var rows: Array = block["filas"]
			for r: int in rows.size():
				var cells: Array = rows[r]
				for c: int in cells.size():
					cells[c] = Localization.data_text("wiki", id, "b%d.r%dc%d" % [i + 1, r + 1, c], str(cells[c]))
		result.append(block)
	return result


static func _read_block(raw: Variant, where: String, errors: PackedStringArray) -> Variant:
	if not raw is Dictionary:
		errors.append("%s: tiene que ser un objeto { }." % where)
		return null
	var block: Dictionary = raw
	var kind: String = str(block.get("tipo", ""))
	match kind:
		WikiEntry.KIND_HEADING, WikiEntry.KIND_TEXT:
			if not block.get("texto") is String or (block["texto"] as String).strip_edges() == "":
				errors.append("%s (%s): falta \"texto\"." % [where, kind])
				return null
			return {"tipo": kind, "texto": block["texto"]}
		WikiEntry.KIND_FACTS, WikiEntry.KIND_TABLE:
			if not block.get("filas") is Array or (block["filas"] as Array).is_empty():
				errors.append("%s (%s): falta \"filas\" (una lista de filas)." % [where, kind])
				return null
			var rows: Array = []
			var width: int = -1
			for row: Variant in block["filas"]:
				if not row is Array or (row as Array).is_empty():
					errors.append("%s (%s): cada fila tiene que ser una lista de textos." % [where, kind])
					return null
				var cells: Array = []
				for cell: Variant in row:
					cells.append(_cell_text(cell))
				if kind == WikiEntry.KIND_FACTS and cells.size() != 2:
					errors.append("%s (datos): cada fila tiene 2 textos (nombre y valor)." % where)
					return null
				if width >= 0 and cells.size() != width:
					errors.append("%s (tabla): todas las filas tienen que tener la misma cantidad de columnas." % where)
					return null
				width = cells.size()
				rows.append(cells)
			return {"tipo": kind, "filas": rows}
	errors.append("%s: el tipo \"%s\" no existe (los válidos: titulo, texto, datos, tabla)." % [where, kind])
	return null


## Un valor de una celda como texto: el 2 de un JSON llega como 2.0 y se ve "2".
static func _cell_text(value: Variant) -> String:
	if _is_whole(value):
		return str(int(value))
	return str(value)


static func _article_failed(errors: PackedStringArray) -> Dictionary:
	return {"entry": null, "order": DEFAULT_ORDER, "unlock": &"", "errors": errors}


## Un número entero (JSON lo lee como decimal: 3 llega como 3.0).
static func _is_whole(value: Variant) -> bool:
	return (value is float or value is int) and float(value) == floorf(float(value))


# --- Descubrir recursos de una carpeta ---

## Carga todos los recursos de una carpeta. En el ejecutable exportado los archivos se llaman
## `*.tres.remap`: se listan sin el `.remap`, igual que LevelFile.enemy_ids().
static func _load_all(dir: String) -> Array[Resource]:
	var found: Dictionary = {}
	for file: String in DirAccess.get_files_at(dir):
		var clean: String = file.trim_suffix(".remap")
		if clean.ends_with(".tres") or clean.ends_with(".res"):
			found[clean] = true
	var names: Array = found.keys()
	names.sort()
	var result: Array[Resource] = []
	for file_name: String in names:
		var resource: Resource = load(dir.path_join(file_name))
		if resource != null:
			result.append(resource)
	return result
