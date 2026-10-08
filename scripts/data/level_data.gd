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
## RF-393: las torres que ofrece este nivel (`"torres"` del archivo). Vacío = las comunes más `extra_towers`.
@export var towers: PackedStringArray = []
## M15 (spec §7.11, RF-260): el paisaje del mapa. `pradera` = el de siempre.
@export var theme: StringName = MapThemes.DEFAULT
## M15 (RF-262): letras extra del mapa. Cada una: {"dibujo": nombre del catálogo, "construible": bool}.
@export var legend: Dictionary = {}
## M49 (RF-388): % de la vida de los monstruos que aplica un modo (`"vida_monstruos_%"`). 100 = como siempre.
@export var enemy_health_percent: int = 100
## M49 (RF-388): torres que permite un modo (`"torres"`). Vacío = las de siempre.
@export var allowed_towers: PackedStringArray = []


## El mapa listo para agregar a la escena (un `Level`), armado con las filas de letras.
func build_map() -> Level:
	return Level.build(MapGrid.parse(map_rows, legend), theme)


## El % de vida por oleada que rige en este nivel.
func health_scale_percent(balance: BalanceConfig) -> int:
	return health_scale_percent_per_wave if health_scale_percent_per_wave > 0 \
		else balance.health_scale_percent_per_wave


## RF-300: las torres que se ven en la barra de este nivel: todas las comunes y las reservadas que el nivel habilita.
## RF-393: con `towers`, solo esas. El orden es siempre el de `all_towers` (el canónico), no el del archivo.
func available_towers(all_towers: Array[TowerData], is_collected: Callable = Callable()) -> Array[TowerData]:
	var result: Array[TowerData] = []
	for tower: TowerData in all_towers:
		var allowed: bool = not tower.reserved or extra_towers.has(String(tower.id))
		if not towers.is_empty():
			allowed = towers.has(String(tower.id))  # RF-393: la lista del nivel manda; nombrar una reservada la habilita
		if not allowed_towers.is_empty() and not allowed_towers.has(String(tower.id)):
			allowed = false  # RF-388: el modo limita las torres
		var collected: bool = tower.required_collection == &"" or (is_collected.is_valid() and is_collected.call(tower.required_collection))
		if allowed and collected:
			result.append(tower)
	return result
