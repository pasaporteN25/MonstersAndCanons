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
	for name_: String in ["heal", "reflect", "stun", "impact", "music_menu"]:
		assert_true(Audio.has_sound(StringName(name_)), name_)
	var stream: AudioStreamWAV = load("res://assets/audio/music_menu.wav")
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_true(stream.stereo)
	assert_eq(stream.mix_rate, 44100)
	assert_false(Audio.has_sound(&"music_combat"), "RF-751: la pista de combate sintetizada se retiró")


# --- RF-751: música de combate de DST (dos pistas que se turnan) ---

func test_combat_music_alternates_each_time_a_match_starts() -> void:
	var saved: Array = [Audio._in_combat, Audio._combat_index]
	Audio._in_combat = false
	Audio._combat_index = -1
	assert_eq(Audio.COMBAT_TRACKS.size(), 2)
	assert_eq(Audio.music_for_screen(false), Audio.MENU_TRACK, "fuera de la partida, la de menú")
	var first: StringName = Audio.music_for_screen(true)
	assert_eq(first, Audio.COMBAT_TRACKS[0], "la primera partida empieza por la primera pista")
	assert_eq(Audio.music_for_screen(true), first, "dentro de la misma partida (o al reintentar) no cambia")
	assert_eq(Audio.music_for_screen(false), Audio.MENU_TRACK)
	assert_eq(Audio.music_for_screen(true), Audio.COMBAT_TRACKS[1], "la partida siguiente usa la otra pista")
	Audio.music_for_screen(false)
	assert_eq(Audio.music_for_screen(true), first, "y después vuelve a la primera")
	Audio._in_combat = saved[0]
	Audio._combat_index = saved[1]


func test_combat_tracks_are_looping_mp3_and_quieter_than_the_menu() -> void:
	for track: StringName in Audio.COMBAT_TRACKS:
		var music: AudioStreamMP3 = load("res://assets/audio/%s.mp3" % track)
		assert_not_null(music, String(track))
		assert_true(music.loop, "%s vuelve a empezar sola" % track)
		assert_gt(music.get_length(), 60.0, "%s dura más de un minuto" % track)
		assert_lt(Audio.music_volume_db(track), Audio.MUSIC_VOLUME_DB, "%s se baja para no tapar los efectos" % track)
	assert_eq(Audio.music_volume_db(Audio.MENU_TRACK), Audio.MUSIC_VOLUME_DB)


func test_combat_tracks_are_credited_and_their_license_is_documented() -> void:
	var credits: String = "\n".join(Credits.load_file()["lines"])
	var licenses: String = FileAccess.get_file_as_string("res://LICENCIAS-TERCEROS.md")
	var wiki: String = FileAccess.get_file_as_string("res://data/wiki/licencias.json")
	for text: String in [credits, licenses, wiki]:
		assert_string_contains(text, "Tower Defense Theme")
		assert_string_contains(text, "Tower Defense Theme 3")
		assert_string_contains(text, "DST")
		assert_string_contains(text, "CC0")
	for track: StringName in Audio.COMBAT_TRACKS:
		assert_string_contains(licenses, "%s.mp3" % track, "cada archivo figura con su origen")
	assert_string_contains(licenses, "https://opengameart.org/content/tower-defense-theme")
	assert_string_contains(licenses, "https://creativecommons.org/publicdomain/zero/1.0/")

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
