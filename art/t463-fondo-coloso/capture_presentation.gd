# T463: capturas REALES de la presentación pausada (BossPresentation) a 1280 × 720, con ventana:
#   godot --path . --resolution 1280x720 res://art/t463-fondo-coloso/capture_presentation.tscn
# Saca la composición vigente (provisional) del Jefe y del Coloso, y el Coloso con cada muestra de fondo pasada por
# `setup(..., backdrop)`, que es el único punto de integración que existe hoy. Todo queda en context/ (fuera de assets/).
extends Node

const OUT: String = "res://art/t463-fondo-coloso/context/"
const BACKDROPS: Dictionary = {
	"muestra_01": "res://art/t463-fondo-coloso/muestra_01_claro.png",
	"muestra_02": "res://art/t463-fondo-coloso/muestra_02_sombrio.png",
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")


func run() -> void:
	var boss: EnemyData = load("res://data/enemies/boss.tres")
	var colossus: EnemyData = load("res://data/enemies/colossus.tres")
	await present(boss, null, "vigente_jefe")
	await present(colossus, null, "vigente_coloso")
	for key: String in BACKDROPS:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(BACKDROPS[key]))
		await present(colossus, ImageTexture.create_from_image(image), "coloso_con_" + key)
	# T548: el fondo integrado, tal como lo pasa Game (con la franja de contraste), al tamaño real de la ventana.
	# El WM puede dar una ventana de otro tamaño: la captura se normaliza (Lanczos, 16:9) a 1280×720 y 1920×1080.
	await present(colossus, BossPresentationArt.backdrop_for(colossus.id), "t548_coloso", [Vector2i(1280, 720), Vector2i(1920, 1080)])
	await present(boss, BossPresentationArt.backdrop_for(boss.id), "t548_jefe_sin_fondo", [Vector2i(1280, 720)])
	var audio: Node = get_node("/root/Audio")
	audio.set_process(false)
	for frame: int in 5:
		await get_tree().process_frame
	get_tree().quit()


func present(data: EnemyData, backdrop: Texture2D, label: String, sizes: Array[Vector2i] = []) -> void:
	var presentation: BossPresentation = BossPresentation.new().setup(data, 5.0, false, null, backdrop)
	add_child(presentation)
	# Dentro de la ventana de movimiento (la ilustración crece de 0,9 a 1,04) y con el fundido de entrada terminado.
	presentation.advance_clock_for_test(0.0)
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if sizes.is_empty():
		assert(image.save_png(OUT + label + ".png") == OK)
	for size: Vector2i in sizes:
		var scaled: Image = image.duplicate()
		scaled.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
		assert(scaled.save_png(OUT + "%s_%dx%d.png" % [label, size.x, size.y]) == OK)
	print("T463: ", label)
	presentation.queue_free()
	await get_tree().process_frame
