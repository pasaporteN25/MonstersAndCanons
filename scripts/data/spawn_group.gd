# Un grupo dentro de una oleada: "N enemigos de tipo X, cada S segundos,
# empezando T segundos después del inicio de la oleada" (RF-31).
class_name SpawnGroup
extends Resource

@export var enemy: EnemyData
@export var count: int = 0
## Segundos entre un enemigo y el siguiente.
@export var interval: float = 0.0
## Segundos desde que empieza la oleada hasta que sale el primero.
@export var start_delay: float = 0.0
## Por qué entrada salen (el nivel 3 tiene dos).
@export var entrance_index: int = 0

## RF-364: un sorteo por grupo al empezar la oleada.1 conserva los niveles anteriores.
@export_range(0.0, 1.0) var probability: float = 1.0

