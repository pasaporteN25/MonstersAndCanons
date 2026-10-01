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
	if level.bonus_vs_slowed_percent > 0:  # RF-313
		lines.append("+%d %% de daño a ralentizados" % level.bonus_vs_slowed_percent)
	if level.bonus_vs_burning_percent > 0:
		lines.append("+%d %% de daño a quemados" % level.bonus_vs_burning_percent)
	if level.slow_amount > 0.0:
		lines.append("Ralentiza %d %% durante %.0f s" % [roundi(level.slow_amount * 100.0), level.slow_duration])
	return lines


## RF-317: lo que dice del combo la torre que PONE el estado (el Hielo frena, la Incendiaria quema):
## qué torres de `towers` le pegan más fuerte a esos enemigos. Se arma leyendo los datos (RF-164):
## una torre que gane un bonus aparece sola. Vacío si la torre no pone ningún estado.
static func combo_partners(tower: TowerData, towers: Array[TowerData]) -> Array[String]:
	var lines: Array[String] = []
	if tower.levels.is_empty():
		return lines
	var first: TowerLevelData = tower.levels[0]
	if first.slow_amount > 0.0:
		var line: String = _partners_line(tower, towers, &"bonus_vs_slowed_percent", "a los que frena")
		if line != "":
			lines.append(line)
	if first.burn_damage_per_second > 0:
		var line: String = _partners_line(tower, towers, &"bonus_vs_burning_percent", "a los que quema")
		if line != "":
			lines.append(line)
	return lines


## RF-317: la frase corta de la barra de construcción: con qué combina la torre, de los dos lados.
## Vacía si la torre no tiene nada que ver con los combos.
static func combo_hint(tower: TowerData, towers: Array[TowerData]) -> String:
	if tower.levels.is_empty():
		return ""
	var sentences: Array[String] = []
	var first: TowerLevelData = tower.levels[0]
	if first.bonus_vs_slowed_percent > 0:
		sentences.append("Combo: +%d %% a ralentizados." % first.bonus_vs_slowed_percent)
	if first.bonus_vs_burning_percent > 0:
		sentences.append("Combo: +%d %% a quemados." % first.bonus_vs_burning_percent)
	for line: String in combo_partners(tower, towers):
		sentences.append(line + ".")
	return " ".join(sentences)


## "Combo: Cañón y Francotirador +25 % a los que frena". Las torres van de la más barata a la más cara
## (como en la Wiki) y se agrupan por porcentaje. Vacío si ninguna aprovecha ese estado.
static func _partners_line(tower: TowerData, towers: Array[TowerData], field: StringName, who: String) -> String:
	var partners: Array[TowerData] = []
	for other: TowerData in towers:
		if other != tower and not other.levels.is_empty() and int(other.levels[0].get(field)) > 0:
			partners.append(other)
	if partners.is_empty():
		return ""
	partners.sort_custom(func(a: TowerData, b: TowerData) -> bool:
		var cost_a: int = a.levels[0].cost
		var cost_b: int = b.levels[0].cost
		return cost_a < cost_b or (cost_a == cost_b and String(a.id) < String(b.id)))
	var names_by_percent: Dictionary = {}  # porcentaje → nombres, en el orden de arriba
	for other: TowerData in partners:
		var percent: int = int(other.levels[0].get(field))
		if not names_by_percent.has(percent):
			var names: Array[String] = []
			names_by_percent[percent] = names
		(names_by_percent[percent] as Array[String]).append(other.display_name)
	var groups: Array[String] = []
	for percent: int in names_by_percent:
		groups.append("%s +%d %%" % [join_names(names_by_percent[percent]), percent])
	return "Combo: %s %s" % [", ".join(groups), who]


## "Cañón", "Cañón y Francotirador", "Cañón, Francotirador y Mortero".
static func join_names(names: Array[String]) -> String:
	if names.size() <= 1:
		return "" if names.is_empty() else names[0]
	return "%s y %s" % [", ".join(names.slice(0, names.size() - 1)), names[names.size() - 1]]


## Todo el texto del panel: daño, cadencia, alcance, efectos y si golpea voladores.
static func describe(level: TowerLevelData, can_hit_air: bool) -> String:
	var lines: Array[String] = [
		"Daño: %d   ·   Cadencia: %.1f/s" % [level.damage, level.fire_rate],
		"Alcance: %.1f casillas" % level.range_tiles,
	]
	lines.append_array(effects(level))
	lines.append("Golpea voladores: %s" % ("sí" if can_hit_air else "no"))
	return "\n".join(lines)
