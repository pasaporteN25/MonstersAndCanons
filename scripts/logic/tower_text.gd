# Las líneas de estadísticas de un nivel de torre, en castellano. Las usan el panel de la torre
# (RF-70) y la wiki (RF-234), así no hay dos versiones del mismo texto que se desincronicen.
class_name TowerText
extends RefCounted


## Los efectos especiales del nivel (área, rayo, púas, quemadura…). Vacío si es una torre común.
static func effects(level: TowerLevelData) -> Array[String]:
	var lines: Array[String] = []
	if level.splash_radius_tiles > 0.0:
		lines.append("Área: radio %.1f" % level.splash_radius_tiles)
	if level.chain_extra_targets > 0:
		lines.append("El rayo salta a %d enemigos más" % level.chain_extra_targets)
	if level.burst_count > 0:
		lines.append("Lanza %d púas en círculo" % level.burst_count)
	if level.extra_targets > 0:
		lines.append("Dispara a %d enemigos a la vez" % (1 + level.extra_targets))
	if level.burn_damage_per_second > 0:
		lines.append("Quema: %d por segundo durante %.0f s" % [level.burn_damage_per_second, level.burn_duration])
	if level.slow_amount > 0.0:
		lines.append("Ralentiza %d %% durante %.0f s" % [roundi(level.slow_amount * 100.0), level.slow_duration])
	return lines


## Todo el texto del panel: daño, cadencia, alcance, efectos y si golpea voladores.
static func describe(level: TowerLevelData, can_hit_air: bool) -> String:
	var lines: Array[String] = [
		"Daño: %d   ·   Cadencia: %.1f/s" % [level.damage, level.fire_rate],
		"Alcance: %.1f casillas" % level.range_tiles,
	]
	lines.append_array(effects(level))
	lines.append("Golpea voladores: %s" % ("sí" if can_hit_air else "no"))
	return "\n".join(lines)
