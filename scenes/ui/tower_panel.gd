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
	_stats.text = _describe(s)
	_targeting_button.text = "Apuntar: %s" % _tower.targeting_name()
	var next: TowerLevelData = _tower.next_level_stats()
	if next == null:
		_upgrade_button.text = "Nivel máximo"
		_upgrade_button.disabled = true
	else:
		_upgrade_button.text = "Mejorar (%d)  [U]" % next.cost
		_upgrade_button.disabled = gold < next.cost
	_sell_button.text = "Vender (+%d)  [S]" % _sell_value


func _describe(s: TowerLevelData) -> String:
	var lines: Array[String] = [
		"Daño: %d   ·   Cadencia: %.1f/s" % [s.damage, s.fire_rate],
		"Alcance: %.1f casillas" % s.range_tiles,
	]
	if s.splash_radius_tiles > 0.0:
		lines.append("Área: radio %.1f" % s.splash_radius_tiles)
	if s.burst_count > 0:
		lines.append("Lanza %d púas en círculo" % s.burst_count)
	if s.extra_targets > 0:
		lines.append("Dispara a %d enemigos a la vez" % (1 + s.extra_targets))
	if s.burn_damage_per_second > 0:
		lines.append("Quema: %d por segundo durante %.0f s" % [s.burn_damage_per_second, s.burn_duration])
	if s.slow_amount > 0.0:
		lines.append("Ralentiza %d %% durante %.0f s" % [roundi(s.slow_amount * 100.0), s.slow_duration])
	lines.append("Golpea voladores: %s" % ("sí" if _tower.data.can_hit_air else "no"))
	return "\n".join(lines)
