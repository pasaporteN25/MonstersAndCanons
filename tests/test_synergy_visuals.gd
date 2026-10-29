# Tests del aviso visual, el panel y la Wiki de las sinergias por estado (M20, T144, spec RF-313).
extends GutTest

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
var TEST_PATH: String = "user://test_save_%d.json" % OS.get_process_id()  # único por proceso (T560)
const DT: float = 1.0 / 60.0

var game: Game
var cannon: TowerData = load("res://data/towers/cannon.tres")
var tesla: TowerData = load("res://data/towers/tesla.tres")
var basic: TowerData = load("res://data/towers/basic.tres")


func before_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = TEST_PATH
	SaveManager.load_save()
	game = GAME_SCENE.instantiate()
	add_child_autofree(game)


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SaveManager.save_path = SaveManager.DEFAULT_PATH
	SaveManager.load_save()


func _spawn(enemy_id: String) -> Enemy:
	var group := SpawnGroup.new()
	group.enemy = load("res://data/enemies/%s.tres" % enemy_id)
	group.count = 1
	var wave := WaveData.new()
	wave.groups.append(group)
	game.spawner.start_wave(wave, 1)
	simulate(game.spawner, 1, DT)
	return game.enemies.get_child(game.enemies.get_child_count() - 1)


## Los textos flotantes de la capa de efectos que dicen exactamente `text`.
func _texts(text: String) -> Array[FloatingText]:
	var found: Array[FloatingText] = []
	for child: Node in game.effects.get_children():
		if child is FloatingText and not child.is_queued_for_deletion() and (child as FloatingText)._text == text:
			found.append(child)
	return found


## Los anillos de la capa de efectos de este color (sin mirar la transparencia).
func _rings(color: Color) -> int:
	var count: int = 0
	for child: Node in game.effects.get_children():
		if child is RingEffect and not child.is_queued_for_deletion():
			var c: Color = (child as RingEffect)._color
			if is_equal_approx(c.r, color.r) and is_equal_approx(c.g, color.g) and is_equal_approx(c.b, color.b):
				count += 1
	return count


func _hit_with(tower: TowerData, enemy: Enemy) -> void:
	var projectile: Projectile = preload("res://scenes/towers/projectile.tscn").instantiate()
	projectile.setup(enemy, enemy.global_position, tower.levels[0], true, 10.0, Color.WHITE)
	game.add_child(projectile)
	projectile._physics_process(DT)


func _slow(enemy: Enemy) -> void:
	enemy.take_hit(1, 0.4, 5.0)  # 1 de daño y queda ralentizado


## Hace pasar el tiempo de la capa de efectos (para la regla de "no amontonar", RF-315).
func _wait(seconds: float) -> void:
	game.effects._process(seconds)


# --- RF-315: el número es el aviso ---

func test_a_combo_hit_shows_its_own_number_in_the_state_color() -> void:
	var enemy: Enemy = _spawn("tank")  # sin armadura y con vida de sobra
	_slow(enemy)
	_hit_with(cannon, enemy)
	var number: Array[FloatingText] = _texts("25!")
	assert_eq(number.size(), 1, "un número de combo: 20 × 1,25 = 25")
	assert_eq(number[0]._color, EffectsLayer.COMBO_SLOWED_COLOR, "celeste: por ralentizado")
	assert_eq(number[0]._font_size, EffectsLayer.COMBO_FONT_SIZE)
	assert_gt(EffectsLayer.COMBO_FONT_SIZE, 15, "más grande que los números comunes")
	assert_eq(_texts("25").size(), 0, "sin un número blanco aparte")
	assert_eq(_rings(EffectsLayer.COMBO_SLOWED_COLOR), 1, "un anillo celeste")
	assert_eq(_texts("¡Combo de hielo!").size(), 1, "la primera vez de la partida, se nombra")


func test_the_combo_is_never_golden() -> void:
	assert_ne(EffectsLayer.COMBO_SLOWED_COLOR, EffectsLayer.GOLD_COLOR)
	assert_ne(EffectsLayer.COMBO_BURNING_COLOR, EffectsLayer.GOLD_COLOR)
	assert_ne(EffectsLayer.COMBO_SLOWED_COLOR, EffectsLayer.DAMAGE_COLOR, "ni blanco como los números comunes")


func test_the_first_time_text_shows_once_per_state() -> void:
	var enemy: Enemy = _spawn("tank")
	_slow(enemy)
	_hit_with(cannon, enemy)
	_wait(0.2)
	_hit_with(cannon, enemy)
	assert_eq(_texts("25!").size(), 2, "el segundo combo también muestra su número")
	assert_eq(_texts("¡Combo de hielo!").size(), 1, "pero ya no se nombra")


func test_a_burning_combo_is_orange() -> void:
	var enemy: Enemy = _spawn("tank")
	enemy.apply_burn(8, 5.0)
	_hit_with(tesla, enemy)
	var number: Array[FloatingText] = _texts("17!")
	assert_eq(number.size(), 1, "13 × 1,3 = 16,9 → 17")
	assert_eq(number[0]._color, EffectsLayer.COMBO_BURNING_COLOR)
	assert_eq(_rings(EffectsLayer.COMBO_BURNING_COLOR), 1)
	assert_eq(_texts("¡Combo de fuego!").size(), 1)
	assert_eq(_texts("¡Combo de hielo!").size(), 0)


func test_a_normal_hit_shows_no_combo() -> void:
	var enemy: Enemy = _spawn("tank")
	_hit_with(cannon, enemy)
	assert_eq(_texts("20").size(), 1, "el número blanco de siempre")
	assert_eq(_texts("20!").size(), 0)
	assert_eq(_rings(EffectsLayer.COMBO_SLOWED_COLOR), 0)


func test_with_the_numbers_off_the_ring_and_the_text_stay() -> void:
	SaveManager.set_setting("damage_numbers", false)
	var enemy: Enemy = _spawn("tank")
	_slow(enemy)
	_hit_with(cannon, enemy)
	assert_eq(_texts("25!").size(), 0, "RF-132: sin números")
	assert_eq(_rings(EffectsLayer.COMBO_SLOWED_COLOR), 1, "pero el combo no desaparece entero")
	assert_eq(_texts("¡Combo de hielo!").size(), 1)


func test_an_area_combo_on_a_group_shows_one_number_and_every_ring() -> void:
	var first: Enemy = _spawn("tank")
	var second: Enemy = _spawn("tank")
	second.distance = first.distance + 10.0  # pegados: dentro del área del Cañón
	second._update_position()
	_slow(first)
	_slow(second)
	_hit_with(cannon, first)
	assert_eq(_texts("25!").size(), 1, "un solo número para el grupo")
	assert_eq(_rings(EffectsLayer.COMBO_SLOWED_COLOR), 2, "un anillo por enemigo")


func test_combos_apart_in_time_or_space_show_their_numbers() -> void:
	var at := Vector2(300, 300)
	assert_true(game.effects.combo(at, 25, Enemy.Combo.SLOWED))
	assert_false(game.effects.combo(at + Vector2(39, 0), 25, Enemy.Combo.SLOWED), "a menos de 40 px y enseguida: no")
	assert_true(game.effects.combo(at + Vector2(41, 0), 25, Enemy.Combo.SLOWED), "a más de 40 px: sí")
	_wait(0.16)
	assert_true(game.effects.combo(at, 25, Enemy.Combo.SLOWED), "pasados 0,15 s: sí")


func test_combo_numbers_have_their_own_limit() -> void:
	for i: int in EffectsLayer.MAX_COMBO_NUMBERS:
		assert_true(game.effects.combo(Vector2(50 * i, 0), 25, Enemy.Combo.SLOWED))
	assert_false(game.effects.combo(Vector2(0, 500), 25, Enemy.Combo.SLOWED), "con 12 en pantalla, no hay número")
	assert_eq(game.effects.combo_numbers_alive(), EffectsLayer.MAX_COMBO_NUMBERS)
	assert_eq(game.effects.damage_numbers_alive(), 0, "no ocupan lugar de los números blancos")
	assert_true(game.effects.damage_number(Vector2(0, 600), 5, false), "y los blancos siguen saliendo")


func test_the_panel_and_the_wiki_say_the_bonus() -> void:
	assert_string_contains(TowerText.describe(cannon.levels[0], false), "+25 % de daño a ralentizados")
	assert_string_contains(TowerText.describe(tesla.levels[0], true), "+30 % de daño a quemados")
	assert_false(TowerText.describe(basic.levels[0], true).contains("de daño a"), "las demás no lo dicen")
	var cannon_wiki: String = JSON.stringify(Wiki.tower_entry(cannon).blocks)
	assert_string_contains(cannon_wiki, "+25 % de daño a ralentizados")
	assert_string_contains(JSON.stringify(Wiki.tower_entry(tesla).blocks), "+30 % de daño a quemados")
	assert_false(JSON.stringify(Wiki.tower_entry(basic).blocks).contains("de daño a ralentizados"))
