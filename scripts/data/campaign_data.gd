# La campaña: los niveles en orden (spec §7, RF-112).
# Ganar el nivel N desbloquea el N+1.
class_name CampaignData
extends Resource

@export var levels: Array[LevelData] = []
