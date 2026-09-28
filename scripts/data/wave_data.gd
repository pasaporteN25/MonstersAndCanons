# Una oleada: uno o más grupos de enemigos (RF-31).
class_name WaveData
extends Resource

@export var groups: Array[SpawnGroup] = []


## RF-133: cuántos enemigos de cada tipo trae la oleada, en el orden en que aparecen
## por primera vez en la lista de grupos. { EnemyData: cantidad }
func enemy_counts() -> Dictionary:
	var counts: Dictionary = {}
	for group: SpawnGroup in groups:
		counts[group.enemy] = counts.get(group.enemy, 0) + group.count
	return counts
