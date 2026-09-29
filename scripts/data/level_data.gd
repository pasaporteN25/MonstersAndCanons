# Definición de un nivel: su mapa, sus recursos iniciales y sus oleadas. Spec §7.
class_name LevelData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## La escena del mapa (por ejemplo level_01.tscn).
@export var map_scene: PackedScene
## M7 (spec §7.8): las 9 filas de letras del mapa. Si tiene filas, se usan en vez de map_scene.
@export var map_rows: PackedStringArray = []
@export var starting_gold: int = 0
@export var starting_lives: int = 0
@export var waves: Array[WaveData] = []
## % de vida extra por oleada en ESTE nivel (RF-36). 0 = usar el de BalanceConfig.
## Los niveles largos necesitan un aumento menor, o el final sería imposible (D-019).
@export var health_scale_percent_per_wave: int = 0


## El mapa listo para agregar a la escena (un `Level`). Desde M7 se arma con las filas de letras.
func build_map() -> Level:
	if not map_rows.is_empty():
		return Level.build(MapGrid.parse(map_rows))
	return map_scene.instantiate()


## El % de vida por oleada que rige en este nivel.
func health_scale_percent(balance: BalanceConfig) -> int:
	return health_scale_percent_per_wave if health_scale_percent_per_wave > 0 \
		else balance.health_scale_percent_per_wave
