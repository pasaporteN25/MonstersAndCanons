# Panel de la torre seleccionada (RF-70, RF-74, RF-76): nivel, estadísticas,
# modo de apuntado y botones Mejorar / Vender. Solo MUESTRA y AVISA: no cobra ni vende.
class_name TowerPanel
extends PanelContainer

signal upgrade_pressed
signal sell_pressed
signal targeting_pressed

var _tower: Tower
var _sell_value: int = 0

@onready var _title: Label = %Title
@onready var _stats: Label = %Stats
@onready var _targeting_button: Button = %TargetingButton
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _sell_button: Button = %SellButton


func _ready() -> void:
	visible = false
	_upgrade_button.pressed.connect(upgrade_pressed.emit)
	_sell_button.pressed.connect(sell_pressed.emit)
	_targeting_button.pressed.connect(targeting_pressed.emit)


## Muestra la torre (o se oculta si es null). `gold` decide si Mejorar está activo.
func show_tower(tower: Tower, sell_value: int, gold: int) -> void:
	_tower = tower
	_sell_value = sell_value
	visible = tower != null
	if tower != null:
		refresh(gold)


func refresh(gold: int) -> void:
	if _tower == null:
		return
	var s: TowerLevelData = _tower.stats()
	_title.text = "%s · Nivel %d" % [_tower.data.display_name, _tower.level_number()]
	_stats.text = TowerText.describe(s, _tower.data.can_hit_air)
	_targeting_button.text = "Apuntar: %s" % _tower.targeting_name()
	var next: TowerLevelData = _tower.next_level_stats()
	if next == null:
		_upgrade_button.text = "Nivel máximo"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "Mejorar (%d)  [U]" % next.cost
		_upgrade_button.disabled = gold < next.cost
	_sell_button.text = "Vender (+%d)  [S]" % _sell_value
