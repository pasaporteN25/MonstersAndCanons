# Definición de un nivel: su mapa, sus recursos iniciales y sus oleadas. Spec §7.
class_name LevelData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## La escena del mapa (por ejemplo level_01.tscn).
@export var map_scene: PackedScene
@export var starting_gold: int = 0
@export var starting_lives: int = 0
@export var waves: Array[WaveData] = []
