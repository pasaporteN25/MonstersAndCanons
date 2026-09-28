# Tests de las fórmulas del juego (T10). Los valores esperados salen de los
# ejemplos y criterios de aceptación de specs/01-spec.md.
extends GutTest

var cfg: BalanceConfig


func before_each() -> void:
	cfg = load("res://data/balance.tres")


# --- balance.tres tiene los valores de la spec ---

func test_balance_matches_spec() -> void:
	assert_eq(cfg.wave_bonus_base, 20, "RF-22")
	assert_eq(cfg.wave_bonus_per_wave, 5, "RF-22")
	assert_eq(cfg.sell_refund_percent, 70, "RF-72")
	assert_eq(cfg.countdown_seconds, 15.0, "RF-34")
	assert_eq(cfg.health_scale_percent_per_wave, 40, "RF-36")


# --- RF-80: daño con armadura ---

func test_armor_reduces_damage() -> void:
	assert_eq(Rules.damage_after_armor(40, 4), 36, "Francotirador contra Blindado")


func test_armor_always_leaves_at_least_one_damage() -> void:
	assert_eq(Rules.damage_after_armor(5, 4), 1, "Ametralladora contra Blindado")
	assert_eq(Rules.damage_after_armor(2, 10), 1, "armadura mayor que el daño")


func test_no_armor_means_full_damage() -> void:
	assert_eq(Rules.damage_after_armor(12, 0), 12)


# --- RF-36: vida creciente por oleada ---

func test_wave_one_keeps_base_health() -> void:
	assert_eq(Rules.scaled_health(30, 1, cfg), 30)


func test_health_grows_and_rounds_down() -> void:
	assert_eq(Rules.scaled_health(30, 2, cfg), 42, "ejemplo de la spec: 30 × 1.4 = 42")
	assert_eq(Rules.scaled_health(30, 10, cfg), 138, "ejemplo de la spec: 30 × 4.6 = 138")
	assert_eq(Rules.scaled_health(18, 2, cfg), 25, "18 × 1.4 = 25.2 → 25")


func test_health_has_no_rounding_errors_on_exact_results() -> void:
	# 135 × 2.2 = 297 exacto; con decimales podría dar 296.999… → 296.
	assert_eq(Rules.scaled_health(135, 4, cfg), 297)


# --- RF-22: bono de oleada ---

func test_wave_bonus() -> void:
	assert_eq(Rules.wave_bonus(1, cfg), 25)
	assert_eq(Rules.wave_bonus(3, cfg), 35, "criterio de aceptación RF-33")
	assert_eq(Rules.wave_bonus(10, cfg), 70)


# --- RF-72: reembolso al vender ---

func test_sell_refund_spec_example() -> void:
	assert_eq(Rules.sell_refund(110, cfg), 77, "criterio de aceptación RF-72")


func test_sell_refund_rounds_down() -> void:
	assert_eq(Rules.sell_refund(75, cfg), 52, "75 × 0.7 = 52.5 → 52")


func test_sell_refund_has_no_rounding_errors() -> void:
	# Todos los múltiplos de 10 deben dar un resultado exacto.
	for total: int in range(0, 1001, 10):
		assert_eq(Rules.sell_refund(total, cfg), total * 7 / 10, "total = %d" % total)


# --- Ralentización y resistencia (RF-60, Jefe) ---

func test_effective_slow_without_resistance() -> void:
	assert_almost_eq(Rules.effective_slow(0.4, 0.0), 0.4, 0.0001)


func test_boss_resists_half_of_the_slow() -> void:
	assert_almost_eq(Rules.effective_slow(0.4, 0.5), 0.2, 0.0001, "criterio de T36")


# --- Unidades ---

func test_tiles_to_px() -> void:
	assert_eq(Rules.tiles_to_px(3.0), 192.0)
	assert_eq(Rules.tiles_to_px(0.5), 32.0)
