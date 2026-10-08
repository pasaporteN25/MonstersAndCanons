# Datos ya resueltos de un removible o un punto de extracción del nivel.
class_name ObstacleSpec
extends RefCounted

enum Kind { REMOVABLE, EXTRACTION }

var cell: Vector2i = Vector2i.ZERO
var letter: StringName = &""
var kind: Kind = Kind.REMOVABLE
var class_id: StringName = &""
var cost: int = 0
var seconds: float = 0.0
var reward_amount: int = 0
var chance_percent: int = 0
var finding_collection: StringName = &""
var repeat_reward: int = 0
var production: int = 0
var reserve: int = 0
