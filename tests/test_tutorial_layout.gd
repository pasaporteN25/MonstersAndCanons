# Tests de dónde va la tarjeta del tutorial y la flecha (T331, M63: RF-574). Lógica pura, sin escenas.
extends GutTest


func test_the_card_goes_to_the_side_that_does_not_cover_the_target() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var area := Rect2(0, 48, 1280, 576)
	var card := Vector2(660, 150)
	var target_low := Rect2(600, 500, 64, 64)  # abajo del mapa
	var rect_a: Rect2 = TutorialLayout.card_rect(card, [target_low], area, screen)
	assert_false(rect_a.intersects(target_low.grow(TutorialLayout.GAP)), "no tapa lo señalado")
	assert_lt(rect_a.position.y, target_low.position.y, "va arriba")
	var target_high := Rect2(600, 60, 64, 64)
	var rect_b: Rect2 = TutorialLayout.card_rect(card, [target_high], area, screen)
	assert_false(rect_b.intersects(target_high.grow(TutorialLayout.GAP)))
	assert_gt(rect_b.position.y, target_high.position.y, "va abajo")


func test_the_card_stays_inside_the_screen_and_centered() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var area := Rect2(0, 64, 1280, 560)
	var rect: Rect2 = TutorialLayout.card_rect(Vector2(660, 150), [], area, screen)
	assert_true(screen.encloses(rect))
	assert_almost_eq(rect.get_center().x, 640.0, 0.5)
	var wide: Rect2 = TutorialLayout.card_rect(Vector2(2000, 150), [], area, screen)
	assert_eq(wide.position.x, TutorialLayout.MARGIN, "más ancha que la pantalla: no se va a la izquierda")


func test_the_card_can_sit_over_the_bottom_bar_when_asked() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var area := Rect2(0, 64, 1280, 560)
	var target := Rect2(300, 150, 200, 100)  # el catálogo del celular: arriba y al medio
	var rect: Rect2 = TutorialLayout.card_rect(Vector2(660, 120), [target], area, screen, true)
	assert_gt(rect.end.y, area.end.y, "usa la barra de abajo")
	assert_true(screen.encloses(rect))


func test_when_both_sides_are_covered_it_picks_the_one_that_covers_less() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var area := Rect2(0, 48, 1280, 576)
	var tall := Rect2(300, 50, 600, 560)  # ocupa todo el alto
	var rect: Rect2 = TutorialLayout.card_rect(Vector2(660, 150), [tall], area, screen)
	assert_true(screen.encloses(rect), "igual queda dentro de la pantalla")


func test_the_arrow_points_at_the_target_from_the_card_side() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var target := Rect2(600, 300, 64, 64)
	var below: PackedVector2Array = TutorialLayout.arrow_points(target, Rect2(300, 500, 660, 150), 26.0, screen)
	assert_eq(below.size(), 3)
	assert_gt(below[0].y, target.end.y, "la punta apoya debajo y apunta hacia arriba")
	assert_gt(below[1].y, below[0].y)
	var above: PackedVector2Array = TutorialLayout.arrow_points(target, Rect2(300, 60, 660, 150), 26.0, screen)
	assert_lt(above[0].y, target.position.y, "la punta apoya arriba y apunta hacia abajo")
	assert_eq(TutorialLayout.arrow_points(Rect2(), Rect2(300, 60, 660, 150), 26.0, screen).size(), 0, "sin objetivo no hay flecha")


func test_the_arrow_comes_from_the_left_for_a_wide_button() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var wide := Rect2(1014, 530, 242, 36)  # «Mejorar» en el panel de la torre, entre otros botones
	var points: PackedVector2Array = TutorialLayout.arrow_points(wide, Rect2(300, 60, 660, 150), 26.0, screen)
	assert_eq(points.size(), 3)
	assert_lt(points[0].x, wide.position.x, "la punta apoya a la izquierda")
	assert_almost_eq(points[0].y, wide.get_center().y, 0.01, "a la altura del botón")
	assert_lt(points[1].x, points[0].x, "y la base queda más a la izquierda: apunta a la derecha")
	var at_edge: PackedVector2Array = TutorialLayout.arrow_points(Rect2(10, 530, 242, 36), Rect2(300, 60, 660, 150), 26.0, screen)
	assert_almost_eq(at_edge[0].x, 131.0, 0.01, "sin lugar a la izquierda vuelve a la flecha vertical, sobre el centro")
	assert_lt(at_edge[0].y, 530.0, "arriba del botón (la tarjeta está arriba)")
