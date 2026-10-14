# Qué torres ofrece cada nivel de la campaña y en cuál debuta cada una (RF-397). Lógica pura: recibe las
# torres y los niveles, así los tests no necesitan cambiar de escena. Nada de esto se guarda (D-079).
class_name TowerOffer
extends RefCounted

const GAME_SCENE: String = "res://scenes/game/game.tscn"


## Las torres del juego en su orden canónico: el de la barra de construcción (`tower_types` de la escena
## del juego), más las de apoyo (RF-360) al final. Es el orden de los íconos de la tarjeta.
static func canonical_towers() -> Array[TowerData]:
	var result: Array[TowerData] = []
	var state: SceneState = (load(GAME_SCENE) as PackedScene).get_state()
	for prop: int in state.get_node_property_count(0):
		if state.get_node_property_name(0, prop) == &"tower_types":
			for tower: Variant in state.get_node_property_value(0, prop):
				result.append(tower)
	for support: TowerData in Wiki._all_towers():
		if support.support_only and not result.has(support):
			result.append(support)
	return result


## Las torres que ofrece `level`, según sus datos y en el orden de `all_towers`. No mira las colecciones del
## jugador: la tarjeta avisa qué hay en el nivel, aunque todavía falte conseguir una pieza.
static func offered(level: LevelData, all_towers: Array[TowerData]) -> Array[TowerData]:
	return level.available_towers(all_towers, func(_collection: StringName) -> bool: return true)


## Los ids de las torres que debutan en `levels[index]`: las que ofrece y que ningún nivel anterior ofrecía.
static func new_tower_ids(levels: Array[LevelData], index: int, all_towers: Array[TowerData]) -> PackedStringArray:
	var result: PackedStringArray = []
	var earlier: Dictionary = {}
	for i: int in index:
		for tower: TowerData in offered(levels[i], all_towers):
			earlier[tower.id] = true
	for tower: TowerData in offered(levels[index], all_towers):
		if not earlier.has(tower.id):
			result.append(String(tower.id))
	return result
