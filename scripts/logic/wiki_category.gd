# Una categoría de la wiki (Enemigos, Torres, Guía…): un título y sus entradas.
class_name WikiCategory
extends RefCounted

var id: StringName = &""
var title: String = ""
var entries: Array[WikiEntry] = []


func _init(category_id: StringName = &"", category_title: String = "", category_entries: Array[WikiEntry] = []) -> void:
	id = category_id
	title = category_title
	entries = category_entries


func find(entry_id: StringName) -> WikiEntry:
	for entry: WikiEntry in entries:
		if entry.id == entry_id:
			return entry
	return null


## Cuántas entradas ya están abiertas (todas, salvo las cerradas del bestiario).
func unlocked_count() -> int:
	var count: int = 0
	for entry: WikiEntry in entries:
		if not entry.locked:
			count += 1
	return count


func has_locked() -> bool:
	return unlocked_count() < entries.size()
