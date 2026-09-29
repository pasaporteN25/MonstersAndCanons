# Un enemigo: avanza por su camino, recibe golpes, se ralentiza, muere o escapa (plan §6.2).
# No suma oro ni resta vidas: avisa con señales y Game decide (constitución P6).
class_name Enemy
extends Node2D

## Murió por daño (RF-81). Quien escuche decide cuánto oro dar.
signal died(enemy: Enemy)
## Llegó a la salida (RF-11). Quien escuche decide cuántas vidas restar.
signal reached_exit(enemy: Enemy)
## Recibió un golpe (solo para efectos visuales, RF-132). `damage` es el daño real,
## después de la armadura; `armor_blocked_most` = la armadura quitó la mitad o más.
signal hit(enemy: Enemy, damage: int, armor_blocked_most: bool)

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
	distance += Rules.tiles_to_px(current_speed_tiles()) * delta
	_update_position()
	_animate(delta)
	if distance >= _path.curve.get_baked_length():
		_is_done = true
		reached_exit.emit(self)
		queue_free()


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


## RF-82: la barra de vida solo aparece después del primer golpe.
func is_health_bar_visible() -> bool:
	return health < max_health


## Recibe un golpe (RF-80) y, si lo trae, una ralentización (RF-60, RF-61).
func take_hit(damage: int, slow_amount: float = 0.0, slow_duration: float = 0.0) -> void:
	if _is_done:
		return
	var dealt: int = Rules.damage_after_armor(damage, data.armor)
	_hit_flash_left = HIT_FLASH_DURATION
	if slow_amount > 0.0:
		_apply_slow(Rules.effective_slow(slow_amount, data.slow_resistance), slow_duration)
	_lose_health(dealt, dealt * 2 <= damage)


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
func _lose_health(amount: int, armor_blocked_most: bool) -> void:
	health = maxi(0, health - amount)
	hit.emit(self, amount, armor_blocked_most)
	queue_redraw()
	if health == 0:
		_is_done = true
		died.emit(self)
		queue_free()


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


func _draw() -> void:
	var r: float = Rules.tiles_to_px(data.size_tiles)
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
		# RF-151: el dibujo mira hacia donde camina (se da vuelta en espejo).
		var flip := Vector2(-1.0 if _facing_left else 1.0, 1.0)
		draw_set_transform(bob, 0.0, squash * flip)
		EnemyShape.draw_sprite(self, data.texture, r, SLOW_MODULATE if is_slowed() else Color.WHITE)
		if _hit_flash_left > 0.0:
			EnemyShape.draw_sprite(self, EnemyShape.flash_texture(data.texture), r, HIT_FLASH_COLOR)
		top = EnemyShape.sprite_top(r)
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
	if Rules.is_dangerous(data):
		# RF-136: corona encima (y encima de la barra de vida, si se ve).
		var crown_base: float = bar_top - 3.0 if is_health_bar_visible() else -top - 3.0
		EnemyShape.draw_crown(self, Vector2(0, crown_base), r * 0.9)


## RF-82: barra verde sobre fondo rojo oscuro, encima del enemigo. `top` = borde de arriba.
func _draw_health_bar(r: float, top: float) -> void:
	var width: float = maxf(r * 2.0, 24.0)
	var top_left := Vector2(-width / 2.0, top)
	draw_rect(Rect2(top_left, Vector2(width, HEALTH_BAR_HEIGHT)), Color(0.35, 0.05, 0.05))
	var ratio: float = float(health) / float(max_health)
	draw_rect(Rect2(top_left, Vector2(width * ratio, HEALTH_BAR_HEIGHT)), Color(0.3, 0.9, 0.3))
