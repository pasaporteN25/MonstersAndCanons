# Invariantes de RF-351/352/353/354: pausa, límites, desaparición y avisos audibles.
extends GutTest

const GAME: PackedScene = preload("res://scenes/game/game.tscn")
var game: Game

func before_each() -> void:
	game = GAME.instantiate()
	add_child_autofree(game)

func after_each() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0

func test_death_residue_preserves_pose_and_is_capped_without_losing_rewards() -> void:
	game.spawner.spawn_now(load("res://data/enemies/normal.tres"))
	var enemy: Enemy = game.enemies.get_child(0)
	for i: int in 30:
		game.effects.enemy_died(enemy.global_position, enemy.data.color, 16, 5, enemy)
	assert_eq(game.effects._death_residues_alive, EffectsLayer.MAX_DEATH_RESIDUES)
	var residue: DeathEffect
	for node: Node in game.effects.get_children():
		if node is DeathEffect:
			residue = node
			break
	assert_eq(residue._body.texture, enemy.visual_texture())
	assert_eq(residue._body.region_rect, enemy.visual_frame_region())
	get_tree().paused = true
	await wait_process_frames(3)
	assert_eq(residue._time, 0.0, "La pausa conserva la pose")
	get_tree().paused = false
	simulate(game.effects, 90, 1.0 / 60.0)
	await wait_process_frames(2)
	assert_eq(game.effects._death_residues_alive, 0)

func test_healing_has_visual_feedback_without_damage_numbers_and_is_capped() -> void:
	var previous: bool = bool(SaveManager.get_setting("damage_numbers"))
	SaveManager.set_setting("damage_numbers", false)
	for i: int in 30:
		game.effects.heal_number(Vector2(200, 200), 1)
	assert_eq(game.effects._heal_pulses_alive, EffectsLayer.MAX_HEAL_PULSES)
	SaveManager.set_setting("damage_numbers", previous)
	simulate(game.effects, 90, 1.0 / 60.0)
	await wait_process_frames(2)
	assert_eq(game.effects._heal_pulses_alive, 0)

func test_shots_cannot_replace_alert_voices() -> void:
	Audio._last_played.clear()
	Audio._next_alert_voice = 9
	assert_true(Audio.play(&"reflect"))
	var alert: AudioStream = Audio._voices[9].stream
	for i: int in 30:
		Audio._last_played.erase(&"shot_basic")
		Audio.play(&"shot_basic")
	assert_eq(Audio._voices[9].stream, alert)

func test_new_sounds_and_both_music_loops_are_imported() -> void:
	for name_: String in ["heal", "reflect", "stun", "impact", "music_menu", "music_combat"]:
		assert_true(Audio.has_sound(StringName(name_)), name_)
	for name_: String in ["music_menu", "music_combat"]:
		var stream: AudioStreamWAV = load("res://assets/audio/%s.wav" % name_)
		assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
		assert_true(stream.stereo)
		assert_eq(stream.mix_rate, 44100)

func test_master_limits_simultaneous_voices_and_sources_have_headroom() -> void:
	var limiter: AudioEffectHardLimiter = AudioServer.get_bus_effect(0, 0)
	assert_almost_eq(limiter.ceiling_db, -1.0, 0.001)
	assert_true(AudioServer.is_bus_effect_enabled(0, 0))
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/redesign-m36/audio_manifest.json"))
	for name_: String in report:
		assert_gt(float(report[name_].peak), 0.0, name_)
		assert_lte(float(report[name_].peak), 0.75, name_)

func test_requesting_the_same_music_keeps_playback() -> void:
	Audio.play_music(&"music_menu")
	if Audio._music_tween != null and Audio._music_tween.is_valid():
		Audio._music_tween.kill()
	Audio._music.stream = load("res://assets/audio/music_menu.wav")
	Audio._music.play()
	var stream: AudioStream = Audio._music.stream
	Audio.play_music(&"music_menu")
	assert_eq(Audio._music.stream, stream)
