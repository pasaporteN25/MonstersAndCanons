# Capturas reales de la intro (M57, T242 paso 6): abre `IntroScreen` con los datos oficiales y con un peor caso
# inventado (dos líneas de 90 caracteres) y guarda un PNG por lámina, con el tamaño de ventana que se pida.
# Se corre con ventana (no `--headless`: sin dibujo no hay imagen) y con la carpeta de salida FUERA del repo:
#   godot --path . res://tools/capture_intro.tscn -- /ruta/de/salida 1280x720
# El tamaño es el de la ventana (el contenido se escala como en el juego: 1280 × 720 virtuales, `canvas_items`).
# Imprime, por cada lámina, las líneas que ocupa el texto y el alto y la posición de la franja.
extends Node

## Se carga en tiempo de ejecución: la revisión de sintaxis compila este script sin los autoloads (`Audio`).
const INTRO_PATH: String = "res://scenes/ui/intro_screen.gd"
const WORST_LINE_A: String = "Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio y sus herramientas."
const WORST_LINE_B: String = "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var out: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "user://capturas"
	DirAccess.make_dir_recursive_absolute(out)
	if OS.get_cmdline_user_args().size() > 1:
		var parts: PackedStringArray = OS.get_cmdline_user_args()[1].split("x")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		get_window().size = Vector2i(int(parts[0]), int(parts[1]))
		get_window().position = Vector2i.ZERO
		for _i: int in 10:
			await get_tree().process_frame
	var size: Vector2i = get_window().size
	print("ventana %dx%d, contenido %s" % [size.x, size.y, get_window().content_scale_size])
	var intro: Node = (load(INTRO_PATH) as GDScript).new()
	add_child(intro)
	var data: IntroData = IntroData.load_file()
	await _capture_all(intro, data, out, "lamina")
	var worst := IntroData.new()
	worst.fade_s = 0.0
	var image: String = String(data.slides[0]["imagen"])
	for text: String in [
		WORST_LINE_A.substr(0, 90) + "\n" + WORST_LINE_A.substr(0, 90),  # el tope del lector: 2 × 90
		WORST_LINE_B.substr(0, 90) + "\n" + WORST_LINE_B.substr(0, 90),  # el peor glifo posible
	]:
		worst.slides.append({"imagen": image, "texto": text, "segundos": 9})
	await _capture_all(intro, worst, out, "peor_caso")
	get_tree().quit()


func _capture_all(intro: Node, data: IntroData, out: String, prefix: String) -> void:
	for i: int in data.slides.size():
		intro.open(data)
		for _step: int in i:
			intro.next()
			if intro.is_fading():
				intro.next()  # completa el fundido
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var label: Label = intro._text
		var strip: Control = label.get_parent()
		var screen: Vector2 = get_viewport().get_visible_rect().size
		print("%s %d: %d línea(s), franja y=%.0f..%.0f de %.0f (alto %.0f, %.0f%% de la pantalla), texto %s" % [
			prefix, i + 1, label.get_line_count(), strip.global_position.y, strip.global_position.y + strip.size.y,
			screen.y, strip.size.y, 100.0 * strip.size.y / screen.y, label.get_global_rect()])
		get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [out, prefix, i + 1])
		intro.finish()
