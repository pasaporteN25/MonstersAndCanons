# Un enemigo: avanza por su camino, recibe golpes, se ralentiza, muere o escapa (plan §6.2).
# No suma oro ni resta vidas: avisa con señales y Game decide (constitución P6).
class_name Enemy
extends Node2D

## Murió por daño (RF-81). Quien escuche decide cuánto oro dar.
signal died(enemy: Enemy)
## Llegó a la salida (RF-11). Quien escuche decide cuántas vidas restar.
signal reached_exit(enemy: Enemy)
## Recibió un golpe (solo para efectos visuales, RF-132). `damage` es el daño real,
## después de la armadura; `armor_blocked_most` = la armadura quitó la mitad o más;
## `combo` = el golpe aprovechó un estado del enemigo (RF-315: el número es el aviso del combo).
signal hit(enemy: Enemy, damage: int, armor_blocked_most: bool, combo: Combo)
## Se curó `amount` de vida (RF-165). Se avisa como mucho una vez por segundo, con lo que
## se curó en ese tiempo, para no llenar la pantalla de números.
signal healed(enemy: Enemy, amount: int)
## El Chamán lanzó su hechizo a una torre (RF-282). Solo para los efectos: la torre ya quedó aturdida.
signal cast_stun(shaman: Enemy, tower: Tower)
## Un tiro de `tower` rebotó en este enemigo (RF-284). `first` = la torre no estaba aturdida antes (para no llenar la
## pantalla de "¡Rebote!" cuando una descarga de varios proyectiles rebota toda junta). Solo para los efectos.
signal reflected(enemy: Enemy, tower: Tower, first: bool)

## RF-315: qué estado del enemigo aprovechó un golpe con bonus (NONE = ninguno, un golpe común).
enum Combo { NONE, SLOWED, BURNING }

const GROUP: StringName = &"enemies"
## Color al que se tiñe un enemigo ralentizado (RF-62).
const SLOW_TINT := Color(0.45, 0.72, 1.0)
const HEALTH_BAR_HEIGHT: float = 5.0
## Duración del parpadeo blanco al recibir un golpe (RF-123).
const HIT_FLASH_DURATION: float = 0.08
## Cuánto se estira y aplasta al caminar (RF-125). 0.08 = 8 %.
const BOB_AMOUNT: float = 0.08
## RF-151: se da vuelta cuando camina claramente hacia un costado (no al subir o bajar).
## 0.3 ≈ la dirección se aparta más de 17° de la vertical.
const FACING_THRESHOLD: float = 0.3
## Dibujos: al recibir un golpe, una silueta blanca casi opaca encima (RF-123);
## ralentizado, se tiñe de celeste (RF-152).
const HIT_FLASH_COLOR := Color(1, 1, 1, 0.85)
const SLOW_MODULATE := Color(0.62, 0.85, 1.0)
## RF-152: mancha de escarcha en el piso, debajo del enemigo ralentizado.
const FROST_PATCH := Color(0.82, 0.95, 1.0, 0.55)
## RF-160: la quemadura hace daño de a golpecitos, uno cada BURN_TICK segundos.
const BURN_TICK: float = 0.5
## RF-273: un portador de aura emite cada AURA_TICK segundos, y cada emisión dura AURA_DURATION.
## Así, si el portador muere o se va, el efecto caduca solo en menos de medio segundo (D-042).
const AURA_TICK: float = 0.25
const AURA_DURATION: float = 0.35
## RF-274: colores del aura (marfil dorado = armadura, verde amarillento = cura) y del contorno de los íconos.
const AURA_ARMOR_COLOR := Color(0.94, 0.85, 0.63)
const AURA_HEAL_COLOR := Color(0.72, 0.89, 0.29)
const AURA_INK := Color(0.125, 0.137, 0.188)

var data: EnemyData
var max_health: int = 0
var health: int = 0
## Píxeles recorridos desde el inicio del camino.
var distance: float = 0.0

var _path: Path2D
var _slow_amount: float = 0.0
var _slow_left: float = 0.0
## RF-160: quemadura en curso (daño por segundo y segundos que le quedan).
var _burn_dps: int = 0
var _burn_left: float = 0.0
var _burn_tick_left: float = 0.0
## RF-165: vida recuperada que todavía no llegó a 1 punto entero, y lo curado sin avisar.
var _regen_accum: float = 0.0
var _healed_unreported: int = 0
var _heal_report_left: float = 0.0
## RF-271, RF-272: lo que recibe de las auras de otros enemigos, y cuánto le queda.
var _aura_armor: int = 0
var _aura_armor_left: float = 0.0
var _aura_heal: float = 0.0
var _aura_heal_left: float = 0.0
## Cuánto falta para la próxima emisión, si este enemigo tiene aura.
var _aura_pulse_left: float = 0.0
## RF-282: cuánto falta para el próximo hechizo (si tiene). Llega a 0 y espera hasta que haya una torre.
var _stun_cast_left: float = 0.0
## RF-318: qué estados aprovecha alguna torre del mapa (lo avisa Game con set_exploitable).
var _exploit_slowed: bool = false
var _exploit_burning: bool = false
## Evita actuar dos veces: tras queue_free() el nodo sigue vivo hasta el final del frame.
var _is_done: bool = false
# Solo visual (spec §9.3):
var _hit_flash_left: float = 0.0
var _anim_time: float = 0.0
## Hacia dónde camina, en radianes (0 = derecha).
var _heading: float = 0.0
## RF-151: el dibujo mira a la izquierda (se dibuja en espejo).
var _facing_left: bool = false


## Se llama ANTES de agregar el enemigo al árbol.
## `scaled_health` ya viene calculada según la oleada (RF-36).
func setup(enemy_data: EnemyData, path: Path2D, scaled_health: int) -> void:
	data = enemy_data
	_path = path
	max_health = scaled_health
	health = scaled_health


func _ready() -> void:
	add_to_group(GROUP)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS  # D-023
	_update_position()
	_stun_cast_left = data.stun_interval  # RF-282: el primer hechizo, un intervalo después de aparecer
	_heading = _path_direction()
	_update_facing()
	# Cada enemigo empieza su bamboleo en un momento distinto, así no se mueven todos igual.
	_anim_time = randf() * 10.0


func _physics_process(delta: float) -> void:
	if _is_done:
		return
	_update_slow(delta)
	_update_burn(delta)
	if _is_done:
		return  # la quemadura lo mató
	_update_regen(delta)
	_update_aura(delta)
	_update_stun_spell(delta)
	distance += Rules.tiles_to_px(current_speed_tiles()) * delta
	_update_position()
	_animate(delta)
	if distance >= _path.curve.get_baked_length():
		_is_done = true
		reached_exit.emit(self)
		queue_free()


## El camino que sigue (RF-166: las crías siguen el mismo).
func path() -> Path2D:
	return _path


## false si ya murió o escapó (aunque el nodo todavía no se haya borrado).
func is_active() -> bool:
	return not _is_done


func is_slowed() -> bool:
	return _slow_left > 0.0


## RF-60: velocidad × (1 − ralentización).
func current_speed_tiles() -> float:
	return data.speed_tiles * (1.0 - _slow_amount)


## Píxeles que le faltan para llegar a la salida. Sirve para apuntar al "Primero" (RF-51).
func remaining_distance() -> float:
	return _path.curve.get_baked_length() - distance


## RF-151: true si el dibujo mira a la izquierda.
func is_facing_left() -> bool:
	return _facing_left


## RF-330: true si el dibujo se refleja en espejo (mira a la izquierda y su dibujo lo permite).
func is_drawn_mirrored() -> bool:
	return _facing_left and data.flip_when_walking_left and data.walk_atlas == null and data.flight_atlas == null


## RF-82: la barra de vida solo aparece después del primer golpe.
func is_health_bar_visible() -> bool:
	return health < max_health


## Recibe un golpe (RF-80) y, si lo trae, una ralentización (RF-60, RF-61).
## `combo` = el golpe vino potenciado por un estado del enemigo (RF-315); solo cambia cómo se ve.
func take_hit(damage: int, slow_amount: float = 0.0, slow_duration: float = 0.0, combo: Combo = Combo.NONE) -> void:
	if _is_done:
		return
	var dealt: int = Rules.damage_after_armor(damage, armor())
	_hit_flash_left = HIT_FLASH_DURATION
	if slow_amount > 0.0:
		_apply_slow(Rules.effective_slow(slow_amount, data.slow_resistance), slow_duration)
	_lose_health(dealt, dealt * 2 <= damage, combo)


## RF-80, RF-271: la armadura que cuenta al recibir un golpe: la propia más la que le da un aura.
func armor() -> int:
	return data.armor + _aura_armor


## RF-271: armadura extra que recibe ahora de un aura (0 = ninguna).
func aura_armor() -> int:
	return _aura_armor


## RF-272: % de vida por segundo que recibe ahora de un aura (0 = ninguna).
func aura_heal() -> float:
	return _aura_heal


## RF-270: true si este enemigo da algún aura a los que lo rodean.
func has_aura() -> bool:
	return data.aura_radius_tiles > 0.0 and (data.aura_armor_bonus > 0 or data.aura_heal_percent_per_second > 0.0)


## RF-271, RF-272: un aura de otro enemigo lo alcanza. Queda el valor MÁS FUERTE (no se suman); un aura
## más débil no refresca a una más fuerte, así que cuando el portador fuerte muere, su valor caduca.
func receive_aura(armor_bonus: int, heal_percent: float) -> void:
	if _is_done:
		return
	if armor_bonus > 0 and (_aura_armor_left <= 0.0 or armor_bonus >= _aura_armor):
		if armor_bonus != _aura_armor:
			queue_redraw()
		_aura_armor = armor_bonus
		_aura_armor_left = AURA_DURATION
	if heal_percent > 0.0 and (_aura_heal_left <= 0.0 or heal_percent >= _aura_heal):
		if not is_equal_approx(heal_percent, _aura_heal):
			queue_redraw()
		_aura_heal = heal_percent
		_aura_heal_left = AURA_DURATION


## RF-184 (modo de pruebas): desaparece sin morir: no da oro, ni puntos, ni suelta crías.
func vanish() -> void:
	if _is_done:
		return
	_is_done = true
	queue_free()


## RF-160: lo prende fuego. No se suma: queda la más fuerte y el tiempo se reinicia.
func apply_burn(damage_per_second: int, duration: float) -> void:
	if _is_done or damage_per_second <= 0 or duration <= 0.0:
		return
	if not is_burning():
		_burn_tick_left = BURN_TICK  # el primer golpecito, dentro de medio segundo
	_burn_dps = maxi(_burn_dps, damage_per_second)
	_burn_left = duration
	queue_redraw()


func is_burning() -> bool:
	return _burn_left > 0.0


## Resta vida, avisa (números de daño, RF-132) y, si llega a 0, muere (RF-81).
func _lose_health(amount: int, armor_blocked_most: bool, combo: Combo = Combo.NONE) -> void:
	health = maxi(0, health - amount)
	hit.emit(self, amount, armor_blocked_most, combo)
	queue_redraw()
	if health == 0:
		_is_done = true
		died.emit(self)
		queue_free()


## RF-165: recupera un % de su vida máxima por segundo, salvo mientras se quema.
func _update_regen(delta: float) -> void:
	_heal_report_left -= delta
	if _healed_unreported > 0 and _heal_report_left <= 0.0:
		healed.emit(self, _healed_unreported)
		_healed_unreported = 0
	# RF-272: la cura de un aura se suma a la propia regeneración.
	var heal_percent: float = data.regen_percent_per_second + _aura_heal
	if heal_percent <= 0.0 or is_burning() or health >= max_health:
		_regen_accum = 0.0
		return
	_regen_accum += max_health * heal_percent / 100.0 * delta
	# Margen: 60 cuadros de 4/60 suman 3,9999…, que tiene que contar como 4.
	var whole: int = int(_regen_accum + 0.0001)
	var amount: int = mini(whole, max_health - health)
	if amount <= 0:
		return
	_regen_accum = maxf(0.0, _regen_accum - whole)
	health += amount
	if _healed_unreported == 0 and _heal_report_left <= 0.0:
		_heal_report_left = 1.0
	_healed_unreported += amount


## RF-283: true si este enemigo devuelve los tiros de las torres cercanas (el Espejo).
func can_reflect() -> bool:
	return data.reflect_range_tiles > 0.0 and data.reflect_stun_seconds > 0.0


## RF-284: ¿el tiro de `tower` rebota ahora? Solo si la torre existe y está a menos de `reflect_range_tiles`.
## Se mide al IMPACTAR (D-043). Un tiro sin torre de origen no rebota.
func will_reflect(tower: Tower) -> bool:
	if not can_reflect() or tower == null or not is_instance_valid(tower):
		return false
	return global_position.distance_to(tower.global_position) <= Rules.tiles_to_px(data.reflect_range_tiles)


## RF-284: el tiro rebota: sin daño para este enemigo y la torre queda aturdida (el tiempo no se suma).
func reflect(tower: Tower) -> void:
	var first: bool = not tower.is_stunned()
	tower.stun(data.reflect_stun_seconds)
	_hit_flash_left = HIT_FLASH_DURATION * 2.0
	reflected.emit(self, tower, first)


## RF-281: true si este enemigo lanza el hechizo que apaga torres (el Chamán).
func has_stun_spell() -> bool:
	return data.stun_interval > 0.0 and data.stun_seconds > 0.0 and data.stun_range_tiles > 0.0


## RF-282: cada `stun_interval` segundos apaga la torre más cercana que esté a tiro y no esté ya aturdida.
## Si no hay ninguna, espera (no acumula hechizos) y lo lanza apenas aparezca una.
func _update_stun_spell(delta: float) -> void:
	if not has_stun_spell():
		return
	_stun_cast_left -= delta
	if _stun_cast_left > 0.0:
		return
	var tower: Tower = _nearest_castable_tower()
	if tower == null:
		_stun_cast_left = 0.0
		return
	tower.stun(data.stun_seconds)
	_stun_cast_left = data.stun_interval
	cast_stun.emit(self, tower)


func _nearest_castable_tower() -> Tower:
	var reach: float = Rules.tiles_to_px(data.stun_range_tiles)
	var best: Tower = null
	var best_distance: float = reach
	for node: Node in get_tree().get_nodes_in_group(Tower.GROUP):
		var tower := node as Tower
		if tower == null or tower.is_stunned():
			continue
		var distance_to_tower: float = global_position.distance_to(tower.global_position)
		if distance_to_tower <= best_distance:
			best = tower
			best_distance = distance_to_tower
	return best


## RF-273: lo que recibe caduca (si nadie lo refresca) y, si tiene aura, emite cada AURA_TICK.
func _update_aura(delta: float) -> void:
	if _aura_armor_left > 0.0:
		_aura_armor_left -= delta
		if _aura_armor_left <= 0.0001:
			_aura_armor_left = 0.0
			_aura_armor = 0
			queue_redraw()
	if _aura_heal_left > 0.0:
		_aura_heal_left -= delta
		if _aura_heal_left <= 0.0001:
			_aura_heal_left = 0.0
			_aura_heal = 0.0
			queue_redraw()
	if not has_aura():
		return
	_aura_pulse_left -= delta
	if _aura_pulse_left <= 0.0:
		_aura_pulse_left += AURA_TICK
		_pulse_aura()


## RF-271, RF-272: les da el aura a los DEMÁS enemigos que están dentro del radio (no a sí mismo).
func _pulse_aura() -> void:
	var reach: float = Rules.tiles_to_px(data.aura_radius_tiles)
	for node: Node in get_tree().get_nodes_in_group(GROUP):
		var other := node as Enemy
		if other == null or other == self or not other.is_active():
			continue
		if global_position.distance_to(other.global_position) <= reach:
			other.receive_aura(data.aura_armor_bonus, data.aura_heal_percent_per_second)


## RF-160: cada BURN_TICK segundos, un golpecito que ignora la armadura.
func _update_burn(delta: float) -> void:
	if not is_burning():
		return
	var elapsed: float = minf(delta, _burn_left)
	_burn_left -= delta
	_burn_tick_left -= elapsed
	while _burn_tick_left <= 0.0001 and not _is_done:
		_burn_tick_left += BURN_TICK
		_lose_health(maxi(1, roundi(_burn_dps * BURN_TICK)), false)
	if _burn_left <= 0.0001:  # margen: sumar muchos deltas deja restos diminutos
		_burn_left = 0.0
		_burn_dps = 0
		queue_redraw()


## RF-61: las ralentizaciones no se suman; queda la más fuerte y la duración se reinicia.
func _apply_slow(amount: float, duration: float) -> void:
	_slow_amount = maxf(_slow_amount, amount)
	_slow_left = duration


func _update_slow(delta: float) -> void:
	if _slow_left <= 0.0:
		return
	_slow_left -= delta
	if _slow_left <= 0.0:
		_slow_left = 0.0
		_slow_amount = 0.0
		queue_redraw()


func _update_position() -> void:
	global_position = _path.to_global(_path.curve.sample_baked(distance))


# --- Animación y dibujo (solo visual, spec §9.3) ---

## Dirección del camino en el punto actual (mirando un poco hacia adelante).
func _path_direction() -> float:
	var here: Vector2 = _path.curve.sample_baked(distance)
	var ahead: Vector2 = _path.curve.sample_baked(distance + 6.0)
	return _heading if here.is_equal_approx(ahead) else (ahead - here).angle()


func _animate(delta: float) -> void:
	_anim_time += delta
	_hit_flash_left = maxf(0.0, _hit_flash_left - delta)
	# RF-125: gira suavemente hacia donde camina (también al doblar esquinas).
	_heading = lerp_angle(_heading, _path_direction(), minf(1.0, 12.0 * delta))
	_update_facing()
	queue_redraw()


## RF-151: mira a la izquierda o a la derecha según hacia dónde camina. Al subir o bajar
## (dirección casi vertical) sigue mirando hacia donde miraba.
func _update_facing() -> void:
	var sideways: float = cos(_heading)
	if sideways < -FACING_THRESHOLD:
		_facing_left = true
	elif sideways > FACING_THRESHOLD:
		_facing_left = false


## Cuadro actual: camina por distancia, vuela por tiempo físico. No crea recursos por frame.
func visual_frame_region() -> Rect2:
	if data.walk_atlas != null:
		return EnemyVisual.walk_region(distance, Rules.tiles_to_px(data.walk_stride_tiles), _heading)
	if data.flight_atlas != null:
		return EnemyVisual.flight_region(_anim_time, data.flight_frame_seconds)
	return Rect2()

func visual_texture() -> Texture2D:
	if data.walk_atlas != null:
		return data.walk_atlas
	if data.flight_atlas != null:
		return data.flight_atlas
	return data.texture

func visual_draw_scale() -> float:
	return data.visual_scale * (data.walk_art_scale if data.walk_atlas != null else 1.0)

func _draw_visual(texture: Texture2D, radius: float, color_: Color) -> void:
	var region: Rect2 = visual_frame_region()
	if region.has_area():
		draw_texture_rect_region(texture, EnemyShape.sprite_rect(radius, visual_draw_scale()), region, color_)
	else:
		EnemyShape.draw_sprite(self, texture, radius, color_, data.visual_scale)

func _draw() -> void:
	var r: float = Rules.tiles_to_px(data.size_tiles)
	if has_aura():
		_draw_aura_ring()  # RF-274: debajo de todo, en el suelo
	# Sombra (RF-126): una elipse aplastada debajo, sin bamboleo.
	# Los voladores la tienen más lejos y más tenue: así se nota que van por el aire.
	var shadow_offset := Vector2(10, r * 2.2) if data.is_flying else Vector2(3, r * 0.55)
	draw_set_transform(shadow_offset, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, r, Color(0, 0, 0, 0.15 if data.is_flying else 0.25))
	if is_slowed() and data.texture != null:
		# RF-152: mancha de escarcha en el piso, donde está la sombra.
		draw_circle(Vector2.ZERO, r * 1.3, FROST_PATCH)
		draw_arc(Vector2.ZERO, r * 1.3, 0.0, TAU, 24, Color(1, 1, 1, 0.85), 2.5)
	# RF-125: bamboleo (se estira y se aplasta) al ritmo de su velocidad.
	var wave: float = sin(_anim_time * TAU * current_speed_tiles() * 1.2)
	var squash := Vector2(1.0 + BOB_AMOUNT * wave, 1.0 - BOB_AMOUNT * wave)
	var bob := Vector2(0, -absf(wave) * 2.0)
	# Hasta dónde llega el dibujo hacia arriba: encima van la barra de vida y la corona.
	var top: float = r
	if data.texture != null:
		# RF-151: el dibujo mira hacia donde camina (se da vuelta en espejo), salvo que tenga luz
		# propia que el espejo movería de lado (RF-330).
		var flip := Vector2(-1.0 if is_drawn_mirrored() else 1.0, 1.0)
		# Poses reales: el cuerpo no se aplasta. El vuelo tiene un leve desplazamiento vertical.
		var flight_bob := Vector2(0, sin(_anim_time * 3.0) * 0.6) if data.is_flying else Vector2.ZERO
		draw_set_transform(flight_bob, 0.0, flip)
		var texture: Texture2D = visual_texture()
		_draw_visual(texture, r, SLOW_MODULATE if is_slowed() else Color.WHITE)
		if _hit_flash_left > 0.0:
			_draw_visual(EnemyShape.flash_texture(texture), r, HIT_FLASH_COLOR)
		var region: Rect2 = visual_frame_region()
		if region.has_area():
			var rect: Rect2 = EnemyShape.sprite_rect(r, visual_draw_scale())
			var bounds: Rect2i = EnemyVisual.body_bounds(texture, region)
			top = -rect.position.y - rect.size.y * bounds.position.y / region.size.y
		else:
			top = EnemyShape.sprite_top(r, data.visual_scale)
	else:
		# RF-156: sin dibujo, la forma de antes. Triángulos y rombos apuntan hacia donde caminan.
		var fill: Color = data.color.lerp(SLOW_TINT, 0.6) if is_slowed() else data.color
		if _hit_flash_left > 0.0:
			fill = Color.WHITE  # RF-123
		var pointy: bool = data.shape == EnemyData.Shape.TRIANGLE or data.shape == EnemyData.Shape.DIAMOND
		draw_set_transform(bob, _heading + PI / 2.0 if pointy else 0.0, squash)
		EnemyShape.draw(self, data.shape, r, fill, fill.darkened(0.45))
	if is_burning():
		EnemyShape.draw_flames(self, r, _anim_time)  # RF-158 (se mueven con el bamboleo)
	draw_set_transform(Vector2.ZERO)
	var bar_top: float = -top - HEALTH_BAR_HEIGHT - 4.0
	if is_health_bar_visible():
		_draw_health_bar(r, bar_top)
	_draw_aura_icons(top)  # RF-274: lo que recibe de un aura, al lado de la barra de vida
	if Rules.is_dangerous(data):
		# RF-136: corona encima (y encima de la barra de vida, si se ve).
		var crown_base: float = bar_top - 3.0 if is_health_bar_visible() else -top - 3.0
		EnemyShape.draw_crown(self, Vector2(0, crown_base), r * 0.9)


## RF-274: un anillo suave en el suelo que llega justo hasta donde llega el aura (un círculo real:
## el mapa se ve desde arriba y el radio se mide en el plano). Late despacito para que se note.
func _draw_aura_ring() -> void:
	var radius: float = Rules.tiles_to_px(data.aura_radius_tiles)
	var pulse: float = 0.5 + 0.15 * sin(_anim_time * 3.0)
	var rings: Array[Color] = []
	if data.aura_armor_bonus > 0:
		rings.append(AURA_ARMOR_COLOR)
	if data.aura_heal_percent_per_second > 0.0:
		rings.append(AURA_HEAL_COLOR)
	for i: int in rings.size():
		var ring_radius: float = radius - i * 3.0  # si da las dos cosas, dos anillos casi juntos
		draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 72, Color(rings[i], pulse * 0.6), 1.2, true)
		if rings[i] == AURA_HEAL_COLOR:
			for petal: int in 12:
				var angle: float = TAU * petal / 12.0
				var p: Vector2 = Vector2.from_angle(angle) * ring_radius
				draw_line(p - Vector2.from_angle(angle) * 3, p + Vector2.from_angle(angle) * 3,
					Color(0.82, 0.97, 0.52, 0.35 + pulse * 0.3), 2.0, true)


## RF-274: un escudo (recibe armadura de un aura) y/o una cruz verde (recibe cura), chicos, a un costado.
## RF-318: en la misma fila, la dianita de "vulnerable" (celeste o naranja).
func _draw_aura_icons(top: float) -> void:
	var marks: Array[Combo] = []
	for kind: Combo in [Combo.SLOWED, Combo.BURNING]:
		if shows_vulnerable_mark(kind):
			marks.append(kind)
	if _aura_armor <= 0 and _aura_heal <= 0.0 and marks.is_empty():
		return
	var r: float = Rules.tiles_to_px(data.size_tiles)
	var x: float = maxf(r, 12.0) + 6.0
	var y: float = -top - 6.0
	if _aura_armor > 0:
		var shield := PackedVector2Array([Vector2(x - 5, y - 5), Vector2(x + 5, y - 5), Vector2(x + 5, y + 1), Vector2(x, y + 6), Vector2(x - 5, y + 1)])
		draw_colored_polygon(shield, AURA_ARMOR_COLOR)
		draw_polyline(shield + PackedVector2Array([shield[0]]), AURA_INK, 1.4)
		x += 13.0
	if _aura_heal > 0.0 and health < max_health and not is_burning():
		draw_line(Vector2(x - 5, y), Vector2(x + 5, y), AURA_INK, 4.6)
		draw_line(Vector2(x, y - 5), Vector2(x, y + 5), AURA_INK, 4.6)
		draw_line(Vector2(x - 4, y), Vector2(x + 4, y), AURA_HEAL_COLOR, 2.4)
		draw_line(Vector2(x, y - 4), Vector2(x, y + 4), AURA_HEAL_COLOR, 2.4)
		x += 13.0
	for kind: Combo in marks:
		# +2: la dianita es un poco más ancha que el escudo y si no, pisa la punta de la barra de vida.
		_draw_vulnerable_mark(Vector2(x + 2.0, y), EffectsLayer.combo_color(kind))
		x += 17.0


## RF-318: una dianita: círculo oscuro, aro del color del estado y cuatro marcas que lo cruzan.
func _draw_vulnerable_mark(center: Vector2, color: Color) -> void:
	draw_circle(center, 6.5, AURA_INK)
	draw_arc(center, 4.5, 0.0, TAU, 20, color, 2.0, true)
	for angle: float in [0.0, PI / 2.0, PI, PI * 1.5]:
		var direction := Vector2.from_angle(angle)
		draw_line(center + direction * 2.0, center + direction * 7.5, color, 1.8)


## RF-318: Game avisa qué estados aprovecha alguna torre del mapa (llamada hacia abajo, P6).
func set_exploitable(slowed: bool, burning: bool) -> void:
	if slowed != _exploit_slowed or burning != _exploit_burning:
		queue_redraw()
	_exploit_slowed = slowed
	_exploit_burning = burning


## RF-318: true si muestra la marca de "vulnerable" de ese estado: lo tiene Y alguna torre del mapa lo aprovecha.
func shows_vulnerable_mark(kind: Combo) -> bool:
	match kind:
		Combo.SLOWED:
			return _exploit_slowed and is_slowed()
		Combo.BURNING:
			return _exploit_burning and is_burning()
	return false


## RF-82: barra verde sobre fondo rojo oscuro, encima del enemigo. `top` = borde de arriba.
func _draw_health_bar(r: float, top: float) -> void:
	var width: float = maxf(r * 2.0, 24.0)
	var top_left := Vector2(-width / 2.0, top)
	draw_rect(Rect2(top_left, Vector2(width, HEALTH_BAR_HEIGHT)), Color(0.35, 0.05, 0.05))
	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(top_left, Vector2(width * ratio, HEALTH_BAR_HEIGHT)), Color(0.3, 0.9, 0.3))
