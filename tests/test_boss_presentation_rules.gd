# Las reglas puras de la presentación de los jefes (T461, M66: RF-666, RF-668, RF-669, RF-673). Sin escena.
extends GutTest


func test_the_first_time_lasts_five_seconds_and_the_next_ones_three() -> void:
	assert_eq(BossPresentationRules.seconds(false), 5.0)
	assert_eq(BossPresentationRules.seconds(true), 3.0)


func test_it_cannot_be_skipped_before_0_3_seconds_and_can_from_then() -> void:
	assert_false(BossPresentationRules.can_skip(0.0))
	assert_false(BossPresentationRules.can_skip(0.299))
	assert_true(BossPresentationRules.can_skip(0.3))
	assert_true(BossPresentationRules.can_skip(4.0))


func test_it_is_eligible_only_when_every_condition_holds() -> void:
	assert_true(BossPresentationRules.is_eligible(true, true, true, false))
	assert_false(BossPresentationRules.is_eligible(false, true, true, false), "no es un jefe")
	assert_false(BossPresentationRules.is_eligible(true, false, true, false), "la opción está apagada")
	assert_false(BossPresentationRules.is_eligible(true, true, false, false), "no es la campaña normal")
	assert_false(BossPresentationRules.is_eligible(true, true, true, true), "ya se mostró en esta partida")


func test_it_resumes_only_when_nothing_asked_to_keep_the_pause() -> void:
	assert_true(BossPresentationRules.should_resume(false, false, false))
	assert_false(BossPresentationRules.should_resume(true, false, false), "ya estaba en pausa")
	assert_false(BossPresentationRules.should_resume(false, true, false), "pasó a segundo plano")
	assert_false(BossPresentationRules.should_resume(false, false, true), "se cerró con P o Atrás")
	assert_false(BossPresentationRules.should_resume(true, true, true))
