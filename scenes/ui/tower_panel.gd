# Panel de la torre seleccionada (RF-70, RF-74, RF-76): nivel, estadísticas,
# modo de apuntado y botones Mejorar / Vender. Solo MUESTRA y AVISA: no cobra ni vende.
class_name TowerPanel
extends PanelContainer

signal upgrade_pressed
signal sell_pressed
signal targeting_pressed

var _tower: Tower
var _sell_value: int = 0
var _gold: int = 0
## RF-280: los segundos de aturdimiento que se muestran (para refrescar solo cuando cambian).
var _shown_stun: int = 0
## RF-317: las torres de este nivel, para decir con cuáles combina la seleccionada. Lo pone Game.
var partner_towers: Array[TowerData] = []

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


## RF-280: mientras la torre está aturdida, la cuenta atrás del título se va actualizando.
func _process(_delta: float) -> void:
	if _tower != null and visible and ceili(_tower.stun_left()) != _shown_stun:
		refresh(_gold)


func refresh(gold: int) -> void:
	if _tower == null:
		return
	_gold = gold
	var s: TowerLevelData = _tower.stats()
	_shown_stun = ceili(_tower.stun_left())
	_title.text = "%s · Nivel %d" % [_tower.data.display_name, _tower.level_number()]
	if _shown_stun > 0:
		_title.text += " · Aturdida (%d s)" % _shown_stun  # RF-280
	_stats.text = TowerText.describe(s, _tower.data.can_hit_air)
	for line: String in TowerText.combo_partners(_tower.data, partner_towers):  # RF-317
		# Espacio que no corta: si la línea no entra, que no quede "+25" arriba y "%" abajo.
		_stats.text += "\n" + line.replace(" %", " %")
	_targeting_button.text = "Apuntar: %s" % _tower.targeting_name()
	var next: TowerLevelData = _tower.next_level_stats()
	if next == null:
		_upgrade_button.text = "Nivel máximo"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "Mejorar (%d)  [U]" % next.cost
		_upgrade_button.disabled = gold < next.cost
	_sell_button.text = "Vender (+%d)  [S]" % _sell_value
