# Definición de un nivel: su mapa, sus recursos iniciales y sus oleadas. Spec §7.
class_name LevelData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
## M7 (spec §7.8): las 9 filas de letras del mapa (RF-201). Las escribe LevelFile al leer el JSON.
@export var map_rows: PackedStringArray = []
@export var starting_gold: int = 0
@export var starting_lives: int = 0
@export var waves: Array[WaveData] = []
## % de vida extra por oleada en ESTE nivel (RF-36). 0 = usar el de BalanceConfig.
## Los niveles largos necesitan un aumento menor, o el final sería imposible (D-019).
@export var health_scale_percent_per_wave: int = 0
## RF-300: ids de las torres reservadas que este nivel habilita (`"torres_extra"` del archivo).
@export var extra_towers: PackedStringArray = []
## M15 (spec §7.11, RF-260): el paisaje del mapa. `pradera` = el de siempre.
@export var theme: StringName = MapThemes.DEFAULT
## M15 (RF-262): letras extra del mapa. Cada una: {"dibujo": nombre del catálogo, "construible": bool}.
@export var legend: Dictionary = {}


## El mapa listo para agregar a la escena (un `Level`), armado con las filas de letras.
func build_map() -> Level:
	return Level.build(MapGrid.parse(map_rows, legend), theme)


## El % de vida por oleada que rige en este nivel.
func health_scale_percent(balance: BalanceConfig) -> int:
	return health_scale_percent_per_wave if health_scale_percent_per_wave > 0 \
		else balance.health_scale_percent_per_wave


## RF-300: las torres que se ven en la barra de este nivel: todas las comunes y las reservadas que el nivel habilita.
func available_towers(all_towers: Array[TowerData]) -> Array[TowerData]:
	var result: Array[TowerData] = []
	for tower: TowerData in all_towers:
		if not tower.reserved or extra_towers.has(String(tower.id)):
			result.append(tower)
	return result
