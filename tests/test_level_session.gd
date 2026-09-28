# Tests de LevelSession: oro, vidas y fases de la partida (T15, T16).
extends GutTest

var session: LevelSession


func _make_level(wave_count: int) -> LevelData:
	var level := LevelData.new()
	level.starting_gold = 150
	level.starting_lives = 20
	for i: int in wave_count:
		level.waves.append(WaveData.new())
	return level


func before_each() -> void:
	session = LevelSession.new()
	add_child_autofree(session)
	session.start(_make_level(2), load("res://data/balance.tres"))


# --- Inicio ---

func test_starts_with_level_values() -> void:
	assert_eq(session.gold, 150, "RF-20")
	assert_eq(session.lives, 20, "RF-10")
	assert_eq(session.wave, 0)
	assert_eq(session.state, LevelSession.State.BUILDING, "RF-32")


# --- Oro ---

func test_spend_when_affordable() -> void:
	assert_true(session.spend(50))
	assert_eq(session.gold, 100)


func test_cannot_spend_more_than_you_have() -> void:
	assert_false(session.spend(151), "RF-23")
	assert_eq(session.gold, 150, "RF-24: el oro no cambia ni queda negativo")


func test_earn() -> void:
	session.earn(5)
	assert_eq(session.gold, 155)


# --- Vidas ---

func test_lose_lives() -> void:
	session.lose_lives(2)
	assert_eq(session.lives, 18, "criterio de aceptación RF-11")


func test_lives_never_go_below_zero_and_game_is_lost() -> void:
	session.lose_lives(25)
	assert_eq(session.lives, 0)
	assert_eq(session.state, LevelSession.State.LOST, "RF-12")


# --- Oleadas ---

func test_begin_wave() -> void:
	assert_eq(session.begin_wave(), 1)
	assert_eq(session.state, LevelSession.State.WAVE_RUNNING)


func test_cannot_start_a_wave_while_one_is_running() -> void:
	session.begin_wave()
	assert_false(session.can_start_wave(), "RF-35")


func test_completing_a_wave_gives_bonus_and_starts_countdown() -> void:
	session.begin_wave()
	session.complete_wave()
	assert_eq(session.gold, 175, "RF-22: 20 + 5 × 1")
	assert_eq(session.state, LevelSession.State.COUNTDOWN, "RF-34")
	assert_eq(session.countdown_left, 15.0)
	assert_true(session.can_start_wave(), "RF-34: se puede adelantar la oleada")


func test_countdown_emits_finished() -> void:
	session.begin_wave()
	session.complete_wave()
	watch_signals(session)
	simulate(session, 16, 1.0)
	assert_signal_emitted(session, "countdown_finished")


func test_completing_the_last_wave_wins() -> void:
	session.begin_wave()
	session.complete_wave()
	session.begin_wave()
	session.complete_wave()
	assert_eq(session.state, LevelSession.State.WON, "RF-90")
	assert_false(session.can_start_wave())


func test_nothing_changes_after_losing() -> void:
	session.begin_wave()
	session.lose_lives(20)
	session.complete_wave()
	assert_eq(session.state, LevelSession.State.LOST)
	assert_eq(session.gold, 150, "no hay bono si ya perdiste")
