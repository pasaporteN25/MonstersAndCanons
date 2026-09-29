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
const ARTICLE_VERSION: int = 1
const ARTICLE_KEYS: PackedStringArray = ["version", "titulo", "subtitulo", "orden", "bloques"]
const DEFAULT_ORDER: int = 100


## Las categorías con sus entradas. Una categoría sin entradas no se incluye (RF-232).
## `campaign` son los niveles de la campaña (para "dónde aparece"); se pasa de afuera para probarlo
## con una campaña de mentira.
static func categories(campaign: Array[LevelData] = []) -> Array[WikiCategory]:
	var result: Array[WikiCategory] = []
	for provider: Dictionary in _providers():
		var build: Callable = provider["build"]
		var entries: Array[WikiEntry] = build.call(campaign)
		if not entries.is_empty():
			result.append(WikiCategory.new(provider["id"], provider["title"], entries))
	return result


static func _providers() -> Array[Dictionary]:
	return [
		{"id": &"enemigos", "title": "Enemigos", "build": _enemy_entries},
		{"id": &"torres", "title": "Torres", "build": _tower_entries},
		{"id": &"guia", "title": "Guía", "build": _article_entries},
	]


# --- Enemigos ---

static func _enemy_entries(campaign: Array[LevelData]) -> Array[WikiEntry]:
	var enemies: Array[EnemyData] = []
	for resource: Resource in _load_all(LevelFile.ENEMIES_DIR):
		if resource is EnemyData:
			enemies.append(resource)
	# Del más débil al más fuerte (RF-233); a igual vida, por nombre, para que el orden no cambie.
	enemies.sort_custom(func(a: EnemyData, b: EnemyData) -> bool:
		return a.max_health < b.max_health or (a.max_health == b.max_health and a.id < b.id))
	var entries: Array[WikiEntry] = []
	for enemy: EnemyData in enemies:
		entries.append(enemy_entry(enemy, enemies, campaign))
	return entries


## La entrada de un enemigo. `all_enemies` sirve para saber quién lo suelta al morir.
static func enemy_entry(enemy: EnemyData, all_enemies: Array[EnemyData], campaign: Array[LevelData]) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = enemy.id
	entry.title = enemy.display_name
	var kind: String = "Vuela" if enemy.is_flying else "Terrestre"
	entry.subtitle = kind + (" · Peligroso" if Rules.is_dangerous(enemy) else "")
	if enemy.texture != null:
		entry.icon.append(enemy.texture)
	if enemy.description != "":
		entry.add_text(enemy.description)
	var facts: Array = [
		["Vida (oleada 1)", str(enemy.max_health)],
		["Velocidad", "%.1f casillas por segundo" % enemy.speed_tiles],
		["Armadura", str(enemy.armor) if enemy.armor > 0 else "ninguna"],
		["Oro al morir", str(enemy.reward)],
		["Vidas que quita", str(enemy.lives_damage)],
		["Vuela", "sí" if enemy.is_flying else "no"],
	]
	if enemy.slow_resistance > 0.0:
		facts.append(["Resistencia a la ralentización", "%d %%" % roundi(enemy.slow_resistance * 100.0)])
	if enemy.regen_percent_per_second > 0.0:
		facts.append(["Se cura", "%.0f %% de su vida por segundo" % enemy.regen_percent_per_second])
	if enemy.death_spawn != null and enemy.death_spawn_count > 0:
		facts.append(["Al morir suelta", "%d × %s" % [enemy.death_spawn_count, enemy.death_spawn.display_name]])
	entry.add_facts(facts)

	entry.add_heading("Dónde aparece")
	var levels: PackedStringArray = _levels_with(enemy, campaign)
	var released_by: PackedStringArray = []
	for other: EnemyData in all_enemies:
		if other.death_spawn != null and other.death_spawn.id == enemy.id and other.death_spawn_count > 0:
			released_by.append(other.display_name)
	if not levels.is_empty():
		entry.add_text("\n".join(levels))
	elif released_by.is_empty():
		entry.add_text("No aparece en la campaña.")
	if not released_by.is_empty():
		entry.add_text("Lo suelta al morir: %s." % ", ".join(released_by))
	return entry


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
			found.append("Nivel %d · %s" % [i + 1, level.display_name])
	return found


# --- Torres ---

static func _tower_entries(_campaign: Array[LevelData]) -> Array[WikiEntry]:
	var towers: Array[TowerData] = []
	for resource: Resource in _load_all(TOWERS_DIR):
		if resource is TowerData and not (resource as TowerData).levels.is_empty():
			towers.append(resource)
	# De la más barata a la más cara (RF-234).
	towers.sort_custom(func(a: TowerData, b: TowerData) -> bool:
		var cost_a: int = a.levels[0].cost
		var cost_b: int = b.levels[0].cost
		return cost_a < cost_b or (cost_a == cost_b and a.id < b.id))
	var entries: Array[WikiEntry] = []
	for tower: TowerData in towers:
		entries.append(tower_entry(tower))
	return entries


static func tower_entry(tower: TowerData) -> WikiEntry:
	var entry := WikiEntry.new()
	entry.id = tower.id
	entry.title = tower.display_name
	entry.subtitle = "Golpea voladores" if tower.can_hit_air else "Solo terrestres"
	var first: TowerLevelData = tower.levels[0]
	if first.base_texture != null:
		entry.icon.append(first.base_texture)
	if tower.turret_texture != null:
		entry.icon.append(tower.turret_texture)
	if tower.description != "":
		entry.add_text(tower.description)
	entry.add_facts([["Golpea voladores", "sí" if tower.can_hit_air else "no"]])
	entry.add_heading("Niveles")
	var rows: Array = [["Nivel", "Oro", "Daño", "Cadencia", "Daño/s", "Alcance"]]
	for i: int in tower.levels.size():
		var level: TowerLevelData = tower.levels[i]
		rows.append([
			"%d (%s)" % [i + 1, "construir" if i == 0 else "mejorar"],
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
				entry.add_heading("Efectos")
				has_effects = true
			entry.add_text("Nivel %d: %s" % [i + 1, " · ".join(effects)])
	return entry


# --- Guía (artículos en data/wiki/*.json) ---

static func _article_entries(_campaign: Array[LevelData]) -> Array[WikiEntry]:
	return articles(ARTICLES_DIR)["entries"]


## Lee todos los artículos de una carpeta. Devuelve {"entries": Array[WikiEntry] (ordenadas),
## "errors": PackedStringArray}. Un artículo roto se salta y deja su motivo en `errors` (RF-236):
## el juego lo ignora, pero los tests exigen que la lista esté vacía con los artículos oficiales.
static func articles(dir: String) -> Dictionary:
	var entries: Array[WikiEntry] = []
	var errors: PackedStringArray = []
	if not DirAccess.dir_exists_absolute(dir):
		return {"entries": entries, "errors": errors}
	var files: PackedStringArray = DirAccess.get_files_at(dir)
	files.sort()
	var orders: Dictionary = {}
	for file: String in files:
		if not file.ends_with(".json"):
			continue
		var parsed: Dictionary = parse_article(FileAccess.get_file_as_string(dir.path_join(file)), StringName(file.get_basename()))
		for error: String in parsed["errors"]:
			errors.append("%s: %s" % [file, error])
		if parsed["entry"] != null:
			var entry: WikiEntry = parsed["entry"]
			entries.append(entry)
			orders[entry.id] = parsed["order"]
	entries.sort_custom(func(a: WikiEntry, b: WikiEntry) -> bool:
		if orders[a.id] != orders[b.id]:
			return orders[a.id] < orders[b.id]
		return a.id < b.id)
	return {"entries": entries, "errors": errors}


## Lee el texto de un artículo. Devuelve {"entry": WikiEntry o null, "order": int, "errors": PackedStringArray}.
static func parse_article(text: String, id: StringName) -> Dictionary:
	var errors: PackedStringArray = []
	var json := JSON.new()  # parse() y no parse_string(): un texto roto no debe imprimir errores del motor
	if json.parse(text) != OK:
		return _article_failed(["No es un JSON válido (línea %d): %s" % [json.get_error_line(), json.get_error_message()]])
	if not json.data is Dictionary:
		return _article_failed(["El archivo tiene que empezar con { y terminar con }."])
	var data: Dictionary = json.data
	for key: Variant in data.keys():
		if not ARTICLE_KEYS.has(str(key)):
			errors.append("La clave \"%s\" no existe (las válidas: %s)." % [key, ", ".join(ARTICLE_KEYS)])
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
	var entry := WikiEntry.new()
	entry.id = id
	entry.title = title
	entry.subtitle = subtitle
	entry.blocks = blocks
	return {"entry": entry, "order": order, "errors": errors}


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
					cells.append(str(cell))
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


static func _article_failed(errors: PackedStringArray) -> Dictionary:
	return {"entry": null, "order": DEFAULT_ORDER, "errors": errors}


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
