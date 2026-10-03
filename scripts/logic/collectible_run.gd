# Colección de una partida: nada se persiste antes del resultado (RF-358/359).
class_name CollectibleRun
extends RefCounted

var collection: StringName = &""
var source: StringName = &""
var carrier_index: int = -1
var spawned: int = 0
var picked_wave: int = -1
var confirmed: bool = false

static func definitions() -> Dictionary:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string("res://data/progression.json")) != OK:
		return {}
	return json.data if json.data is Dictionary else {}

static func eligible(collection_id: StringName, source_id: StringName) -> bool:
	var definition: Dictionary = definitions().get(String(collection_id), {})
	return (definition.get("sources", []) as Array).has(String(source_id))

static func required(collection_id: StringName) -> int:
	return int((definitions().get(String(collection_id), {}) as Dictionary).get("required", 0))

func setup(collection_id: StringName, source_id: StringName, enemy_count: int, rng: RandomNumberGenerator) -> void:
	collection = collection_id
	source = source_id
	if enemy_count > 0 and eligible(collection, source):
		carrier_index = rng.randi_range(0, enemy_count - 1)

func next_enemy_is_carrier() -> bool:
	var matches: bool = spawned == carrier_index
	spawned += 1
	return matches

func pick(wave: int) -> void:
	if carrier_index >= 0 and picked_wave < 0 and wave > 0:
		picked_wave = wave

func complete_wave(wave: int) -> void:
	if picked_wave == wave:
		confirmed = true

func result_sources(finished: bool) -> PackedStringArray:
	return PackedStringArray([String(source)]) if finished and confirmed else PackedStringArray()
