# Panel de la torre seleccionada (RF-70, RF-74, RF-76): nivel, estadísticas,
# modo de apuntado y botones Mejorar / Vender. Solo MUESTRA y AVISA: no cobra ni vende.
class_name TowerPanel
extends PanelContainer

signal upgrade_pressed
signal sell_pressed
signal targeting_pressed

var _tower: Tower
var _sell_value: int = 0
## RF-418: recursos que devuelve la venta.
var _sell_resources: int = 0
var _gold: int = 0
## RF-280: los segundos de aturdimiento que se muestran (para refrescar solo cuando cambian).
var _shown_stun: int = 0
var _shown_support: int = 0
var _shown_wear: float = 0.0
var _shown_repair: float = 0.0
## RF-317: las torres de este nivel, para decir con cuáles combina la seleccionada. Lo pone Game.
var partner_towers: Array[TowerData] = []

@onready var _title: Label = %Title
@onready var _stats: Label = %Stats
@onready var _description: Label = %Description
@onready var _damage: Label = %Damage
@onready var _rate: Label = %Rate
@onready var _range: Label = %Range
@onready var _air: Label = %Air
@onready var _details: ScrollContainer = %Details
@onready var _status: Label = %Status
@onready var _targeting_button: Button = %TargetingButton
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _sell_button: Button = %SellButton


func _ready() -> void:
	visible = false
	_upgrade_button.pressed.connect(upgrade_pressed.emit)
	_sell_button.pressed.connect(sell_pressed.emit)
	_targeting_button.pressed.connect(targeting_pressed.emit)


## Muestra la torre (o se oculta si es null). `gold` decide si Mejorar está activo.
func show_tower(tower: Tower, sell_value: int, gold: int, sell_resources: int = 0) -> void:
	if tower != _tower:
		_details.scroll_vertical = 0
	_tower = tower
	_sell_value = sell_value
	_sell_resources = sell_resources
	visible = tower != null
	if tower != null:
		refresh(gold)


## RF-280: mientras la torre está aturdida, la cuenta atrás del título se va actualizando.
func _process(_delta: float) -> void:
	if _tower != null and visible and (ceili(_tower.stun_left()) != _shown_stun or _tower.support_bonus() != _shown_support or not is_equal_approx(_tower.wear_percent, _shown_wear) or not is_equal_approx(_tower.repair_rate_received,_shown_repair)):
		refresh(_gold)


func refresh(gold: int) -> void:
	if _tower == null:
		return
	_gold = gold
	var s: TowerLevelData = _tower.stats()
	_shown_stun = ceili(_tower.stun_left())
	_title.text = "%s · Nivel %d" % [_tower.data.display_name, _tower.level_number()]
	_title.tooltip_text = _title.text
	_shown_wear = _tower.wear_percent
	_shown_repair = _tower.repair_rate_received
	var states: PackedStringArray = []
	if _shown_stun > 0:
		states.append("Aturdida (%d s)" % _shown_stun)
	if _shown_wear > 0.0:
		states.append("Desgaste %.0f %%" % _shown_wear)
	_status.visible = not states.is_empty()
	_status.text = " · ".join(states)
	_damage.text = str(s.damage)
	_shown_support = _tower.support_bonus()
	_rate.text = "Apoyo" if _tower.data.support_only else "%.2f/s" % _tower.effective_fire_rate()
	_range.text = "%.1f" % s.range_tiles
	_description.text = _tower.data.description
	_description.visible = not _description.text.is_empty()
	_air.text = "Voladores: %s" % ("sí" if _tower.data.can_hit_air else "no")
	_stats.text = "\n".join(TowerText.effects(s))
	var invested: String = TowerText.invested_line(_tower.data, _tower.resources_invested)  # RF-418
	if invested != "":
		_stats.text += "\n" + invested
	if _shown_repair > 0:
		_stats.text += "\nReparación recibida: %.1f puntos/s" % _shown_repair
	if _tower.data.support_only and _shown_wear > 0:
		_stats.text += "\nPrestaciones actuales: %.0f %%" % (WearRules.ratio(_shown_wear) * 100.0)
	if _shown_support > 0:
		_stats.text += "\nApoyo recibido: +%d %% cadencia" % _shown_support
	for line: String in TowerText.combo_partners(_tower.data, partner_towers):  # RF-317
		# Espacio que no corta: si la línea no entra, que no quede "+25" arriba y "%" abajo.
		_stats.text += "\n" + line.replace(" %", " %")
	_stats.text = _stats.text.strip_edges()
	_stats.visible = not _stats.text.is_empty()
	_targeting_button.disabled = _tower.data.support_only or _tower.is_pulse_tower()  # RF-438: el pulso no apunta
	_targeting_button.text = "Apuntar: %s" % _tower.targeting_name()
	var next: TowerLevelData = _tower.next_level_stats()
	if next == null:
		_upgrade_button.text = "Nivel máximo"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "Mejorar (%d)  [U]" % next.cost
		_upgrade_button.disabled = gold < next.cost
	_upgrade_button.tooltip_text = "Nivel máximo alcanzado" if next == null else ("Faltan %d de oro" % (next.cost - gold) if gold < next.cost else "Mejorar torre · U")
	_sell_button.text = "Vender (+%s)  [S]" % TowerText.refund_text(_sell_value, _sell_resources)
