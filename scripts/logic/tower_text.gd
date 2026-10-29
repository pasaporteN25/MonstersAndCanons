# Las líneas de estadísticas de un nivel de torre, en castellano. Las usan el panel de la torre
# (RF-70) y la wiki (RF-234), así no hay dos versiones del mismo texto que se desincronicen.
class_name TowerText
extends RefCounted


## Los efectos especiales del nivel (área, rayo, púas, quemadura…). Vacío si es una torre común.
static func effects(level: TowerLevelData) -> Array[String]:
	return effect_phrases(level, null, false)


## T513 (RF-721): las frases de los efectos con el cambio ADENTRO («El rayo salta a 2 → 3 enemigos más»).
## `next` es el nivel al que se mejora: cada número que cambia sale «antes → después» y el que no, igual que siempre.
## Con `next` null (último nivel) no hay flechas y la salida es la de `effects`. `panel` = true usa la frase corta
## del pulso (daño, cadencia y alcance ya tienen su fila). Un solo lugar para la PC y el celular; los números
## salen de los dos `TowerLevelData`, las plantillas son las de siempre y la coma decimal es `decimal`.
static func effect_phrases(level: TowerLevelData, next: TowerLevelData = null, panel: bool = true) -> Array[String]:
	var lines: Array[String] = []
	if level.suppress_seconds > 0.0 or (next != null and next.suppress_seconds > 0.0):  # RF-450
		if panel:
			lines.append(Localization.t_fmt(&"towertext.pulse_panel", {"x": _change(level, next, "suppress_seconds")}))
		else:
			lines.append(pulse_line(level))
	if _has(level, next, "support_rate_percent"):
		lines.append(Localization.t_fmt(&"towertext.support", {"x": _change(level, next, "support_rate_percent")}))
	if _has(level, next, "support_repair_per_second"):
		lines.append(Localization.t_fmt(&"towertext.repair", {"x": _change(level, next, "support_repair_per_second")}))
	if _has(level, next, "splash_radius_tiles"):
		lines.append(Localization.t_fmt(&"towertext.area", {"x": _change(level, next, "splash_radius_tiles")}))  # RF-677: coma decimal (antes «1.5»)
	if _has(level, next, "chain_extra_targets"):
		lines.append(Localization.t_fmt(&"towertext.chain", {"x": _change(level, next, "chain_extra_targets")}))
	if _has(level, next, "burst_count"):
		lines.append(Localization.t_fmt(&"towertext.burst", {"x": _change(level, next, "burst_count")}))
	if _has(level, next, "extra_targets"):
		lines.append(Localization.t_fmt(&"towertext.extra_targets", {"x": _change(level, next, "extra_targets", 1.0)}))
	if _has(level, next, "burn_damage_per_second"):
		lines.append(Localization.t_fmt(&"towertext.burn", {"x": _change(level, next, "burn_damage_per_second"), "y": _change(level, next, "burn_duration")}))
	if _has(level, next, "bonus_vs_slowed_percent"):  # RF-313
		lines.append(Localization.t_fmt(&"towertext.vs_slowed", {"x": _change(level, next, "bonus_vs_slowed_percent")}))
	if _has(level, next, "bonus_vs_burning_percent"):
		lines.append(Localization.t_fmt(&"towertext.vs_burning", {"x": _change(level, next, "bonus_vs_burning_percent")}))
	if _has(level, next, "slow_amount"):
		lines.append(Localization.t_fmt(&"towertext.slow", {"x": _change(level, next, "slow_amount", 0.0, 100.0), "y": _change(level, next, "slow_duration")}))
	return lines


## ¿El efecto existe en este nivel o en el siguiente? (Así una mejora que lo agrega o lo quita no lo pierde.)
static func _has(level: TowerLevelData, next: TowerLevelData, field: String) -> bool:
	return float(level.get(field)) > 0.0 or (next != null and float(next.get(field)) > 0.0)


## El valor de `field` en `level` y, si `next` lo cambia, «antes → después». `offset` y `scale` se aplican a los dos
## lados antes de formatear (el «a la vez» suma 1; el frenado pasa de 0,4 a 40 %).
static func _change(level: TowerLevelData, next: TowerLevelData, field: String, offset: float = 0.0, scale: float = 1.0) -> String:
	var before: String = decimal((float(level.get(field)) + offset) * scale)
	if next == null:
		return before
	var after: String = decimal((float(next.get(field)) + offset) * scale)
	return before if before == after else "%s %s %s" % [before, UpgradeDeltas.ARROW, after]


## T514 (RF-722): el estado actual abreviado de la barra del celular, «Daño 5 · 0,6/s · Alc. 3». Una torre de apoyo
## no tiene daño ni cadencia propios: solo «Alc. 2,5». Coma decimal y alcance con su decimal, el mismo `decimal` de la PC.
static func bar_state(damage: int, fire_rate: float, range_tiles: float, support_only: bool) -> String:
	if support_only:
		return Localization.t_fmt(&"towertext.bar_support", {"range": decimal(range_tiles)})
	return Localization.t_fmt(&"towertext.bar_state", {"damage": damage, "rate": decimal(fire_rate), "range": decimal(range_tiles)})


## RF-450: el pulso de la Disruptora, armado con los números del nivel (RF-164):
## "Pulso cada 4 s · radio 2,5 · apaga las auras 2,5 s · 5 de daño". Con `emitters` (los nombres de los
## enemigos con aura, en plural) suma "Apaga el aura de Guardianes y Curanderos." Vacío si no es de pulso.
static func pulse_line(level: TowerLevelData, emitters: Array[String] = []) -> String:
	if level.suppress_seconds <= 0.0:
		return ""
	var period: float = 1.0 / level.fire_rate if level.fire_rate > 0.0 else 0.0
	var line: String = Localization.t_fmt(&"towertext.pulse_line", {"period": decimal(period), "radius": decimal(level.range_tiles),
			"seconds": decimal(level.suppress_seconds), "damage": level.damage})
	if not emitters.is_empty():
		line += ". " + Localization.t_fmt(&"towertext.pulse_auras", {"names": join_names(emitters)})
	return line


## "2,5" y "4": coma decimal y sin ceros de más.
static func decimal(value: float) -> String:
	var text: String = String.num(snappedf(value, 0.01), 2)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	return text.replace(".", ",")


## RF-450: ¿es un enemigo con aura? Lo mismo que `Enemy.has_aura()`, pero sobre los datos.
static func has_aura(enemy: EnemyData) -> bool:
	return enemy.aura_radius_tiles > 0.0 and (enemy.aura_armor_bonus > 0 or enemy.aura_heal_percent_per_second > 0.0)


## RF-450: los nombres en plural de los enemigos con aura de `enemies` ("Guardianes", "Curanderos").
static func emitter_names(enemies: Array[EnemyData]) -> Array[String]:
	var sorted: Array[EnemyData] = []
	for enemy: EnemyData in enemies:
		if has_aura(enemy):
			sorted.append(enemy)
	sorted.sort_custom(func(a: EnemyData, b: EnemyData) -> bool: return String(a.id) < String(b.id))
	var names: Array[String] = []
	for enemy: EnemyData in sorted:
		names.append(plural(enemy.name_text()))
	return names


## Plural simple en castellano: "Guardián" → "Guardianes", "Curandero" → "Curanderos". En inglés basta una «s».
static func plural(word: String) -> String:
	if word.is_empty():
		return word
	if Localization.language != Localization.DEFAULT_LANGUAGE:
		return word + "s"
	var last: String = word.substr(word.length() - 1)
	if last in ["á", "é", "í", "ó", "ú"] or last in ["a", "e", "o"]:
		return word + "s"
	if word.ends_with("án") or word.ends_with("én") or word.ends_with("ín") or word.ends_with("ón"):
		var plain: String = word.substr(0, word.length() - 2) + word.substr(word.length() - 2, 1).replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o") + "n"
		return plain + "es"
	if last in ["n", "r", "l", "z", "d", "j"]:
		return word + "es"
	return word + "s"


## RF-450: las torres de `towers` que apagan el aura de `enemy` (alguna con `suppress_seconds` > 0).
## Vacío si el enemigo no tiene aura. Se lee de los datos, de los dos lados, como el combo (RF-317).
static func suppressors_of(enemy: EnemyData, towers: Array[TowerData]) -> Array[String]:
	var names: Array[String] = []
	if not has_aura(enemy):
		return names
	for tower: TowerData in towers:
		for level: TowerLevelData in tower.levels:
			if level.suppress_seconds > 0.0:
				names.append(tower.name_text())
				break
	names.sort()
	return names


## RF-317: lo que dice del combo la torre que PONE el estado (el Hielo frena, la Incendiaria quema):
## qué torres de `towers` le pegan más fuerte a esos enemigos. Se arma leyendo los datos (RF-164):
## una torre que gane un bonus aparece sola. Vacío si la torre no pone ningún estado.
static func combo_partners(tower: TowerData, towers: Array[TowerData]) -> Array[String]:
	var lines: Array[String] = []
	if tower.levels.is_empty():
		return lines
	var first: TowerLevelData = tower.levels[0]
	if first.slow_amount > 0.0:
		var line: String = _partners_line(tower, towers, &"bonus_vs_slowed_percent", Localization.t(&"towertext.who_slowed"))
		if line != "":
			lines.append(line)
	if first.burn_damage_per_second > 0:
		var line: String = _partners_line(tower, towers, &"bonus_vs_burning_percent", Localization.t(&"towertext.who_burning"))
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
		sentences.append(Localization.t_fmt(&"towertext.combo_slowed", {"x": first.bonus_vs_slowed_percent}))
	if first.bonus_vs_burning_percent > 0:
		sentences.append(Localization.t_fmt(&"towertext.combo_burning", {"x": first.bonus_vs_burning_percent}))
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
		(names_by_percent[percent] as Array[String]).append(other.name_text())
	var groups: Array[String] = []
	for percent: int in names_by_percent:
		groups.append(Localization.t_fmt(&"towertext.combo_group", {"names": join_names(names_by_percent[percent]), "x": percent}))
	return Localization.t_fmt(&"towertext.combo_line", {"groups": ", ".join(groups), "who": who})


## "Cañón", "Cañón y Francotirador", "Cañón, Francotirador y Mortero".
static func join_names(names: Array[String]) -> String:
	if names.size() <= 1:
		return "" if names.is_empty() else names[0]
	return "%s%s%s" % [", ".join(names.slice(0, names.size() - 1)), Localization.t(&"common.and"), names[names.size() - 1]]


## Todo el texto del panel: daño, cadencia, alcance, efectos y si golpea voladores.
static func describe(level: TowerLevelData, can_hit_air: bool) -> String:
	var lines: Array[String] = [
		Localization.t_fmt(&"towertext.describe_stats", {"damage": level.damage, "rate": "%.1f" % level.fire_rate}),
		Localization.t_fmt(&"towertext.describe_range", {"x": "%.1f" % level.range_tiles}),
	]
	lines.append_array(effects(level))
	lines.append(Localization.t_fmt(&"towertext.describe_air", {"answer": Localization.t(&"common.yes" if can_hit_air else &"common.no")}))
	return "\n".join(lines)


# --- Costo en recursos (RF-418 y RF-419): el texto sale de los datos (RF-164) ---

## "recurso" o "recursos" según la cantidad.
static func resources_word(amount: int) -> String:
	return Localization.t_plural(&"towertext.resource", amount)


## "300 de oro + 3 recursos" o, sin recursos, "150 de oro". `alt` = la segunda forma de pago.
static func cost_text(tower: TowerData, alt: bool = false) -> String:
	var text: String = Localization.t_fmt(&"towertext.gold", {"x": tower.build_gold(alt)})
	var resources: int = tower.build_resources(alt)
	if resources > 0:
		text += " + %d %s" % [resources, resources_word(resources)]
	return text


## El precio en el botón de la barra: "300 + 3" (el ícono del recurso lo pone el HUD) o "150".
static func bar_text(tower: TowerData, alt: bool = false) -> String:
	var text: String = str(tower.build_gold(alt))
	if tower.build_resources(alt) > 0:
		text += " + %d" % tower.build_resources(alt)
	return text


## true si alguna forma de pago de la torre pide recursos.
static func uses_resources(tower: TowerData) -> bool:
	return tower.resource_cost > 0 or tower.has_alt_payment()


## Por qué no se puede pagar con esa forma ("Faltan 2 recursos", "Este mapa no tiene recursos"), o "" si se puede.
static func missing_text(tower: TowerData, alt: bool, gold: int, resources: int, map_has_resources: bool) -> String:
	var gold_cost: int = tower.build_gold(alt)
	var resource_cost: int = tower.build_resources(alt)
	var parts: Array[String] = []
	if gold < gold_cost:
		parts.append(Localization.t_fmt(&"towertext.gold", {"x": gold_cost - gold}))
	if resource_cost > resources:
		if not map_has_resources:
			parts.append(Localization.t(&"towertext.no_resources_map"))
		else:
			parts.append("%d %s" % [resource_cost - resources, resources_word(resource_cost - resources)])
	return "" if parts.is_empty() else Localization.t_fmt(&"towertext.missing", {"parts": Localization.t(&"common.and").join(parts)})


## RF-418: "70 de oro" o "210 y 2 recursos" para el botón Vender del panel.
static func refund_text(gold: int, resources: int) -> String:
	if resources <= 0:
		return str(gold)
	return Localization.t_fmt(&"towertext.refund_both", {"gold": gold, "resources": resources, "word": resources_word(resources)})


## RF-418: la línea del panel con lo que costó la torre en recursos. Vacía si no costó ninguno
## y la torre tampoco tiene una forma de pago con recursos.
static func invested_line(tower: TowerData, resources_invested: int) -> String:
	if not uses_resources(tower):
		return ""
	return Localization.t_fmt(&"towertext.invested", {"x": resources_invested})


## RF-437: los datos de costo para la ficha de la Wiki: [[rótulo, valor], ...]. Vacío si la torre solo usa oro.
static func cost_facts(tower: TowerData) -> Array:
	var facts: Array = []
	if tower.resource_cost > 0:
		facts.append([Localization.t(&"towertext.fact_build_cost"), cost_text(tower)])
	if tower.has_alt_payment():
		facts.append([Localization.t(&"towertext.fact_payment"), Localization.t_fmt(&"towertext.payment_or", {"a": cost_text(tower), "b": cost_text(tower, true)})])
	return facts
