# Comprueba, dentro del paquete exportado, que la intro carga (M57, T242 paso 6): los datos oficiales son válidos,
# cada lámina se carga como textura de 1920 × 1080 y `IntroScreen` abre, avanza hasta la última y termina.
# Se corre como escena, con el proyecto o con un ejecutable exportado, sin ventana. Sale con 0 si todo está bien y
# con 1 si algo falla:
#   godot --headless --path . res://tools/check_intro_pack.tscn
#   MonstersCanons.x86_64 --headless res://tools/check_intro_pack.tscn
# Ojo: los presets de exportación excluyen `tools/*`, así que un ejecutable oficial NO trae esta escena; para
# probar el paquete hay que exportar una build de verificación con ese filtro quitado (ver el Resultado de T242).
extends Node

## Se carga en tiempo de ejecución: la revisión de sintaxis compila este script sin los autoloads (`Audio`).
const INTRO_PATH: String = "res://scenes/ui/intro_screen.gd"
const EXPECTED_SIZE := Vector2i(1920, 1080)

var _failures: int = 0
var _finished: int = 0


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	var data: IntroData = IntroData.load_file()
	_check(data.is_valid(), "los datos de la intro son válidos %s" % [data.errors])
	_check(data.slides.size() == 7, "hay 7 láminas (hay %d)" % data.slides.size())
	for slide: Dictionary in data.slides:
		var path: String = String(slide["imagen"])
		var texture := load(path) as Texture2D
		_check(texture != null, "carga %s" % path)
		if texture != null:
			var size: Vector2i = texture.get_image().get_size() if texture.get_image() != null else Vector2i.ZERO
			_check(size == EXPECTED_SIZE, "%s mide %s" % [path, size])
	var script := load(INTRO_PATH) as GDScript
	if script == null or not script.can_instantiate():
		print("FALLA no se pudo compilar %s" % INTRO_PATH)
		get_tree().quit(1)
		return
	var intro: Node = script.new()
	intro.manual_clock = true
	add_child(intro)
	intro.finished.connect(func() -> void: _finished += 1)
	intro.open(data)
	for i: int in data.slides.size():
		_check(intro.current_index() == i, "la intro está en la lámina %d" % (i + 1))
		_check(intro.current_image().texture != null, "la lámina %d tiene imagen" % (i + 1))
		intro.next()
		if intro.is_fading():
			intro.next()
	_check(_finished == 1, "la intro terminó una sola vez (%d)" % _finished)
	print("check_intro_pack: %d falla(s)" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
	print("%s %s" % ["ok   " if ok else "FALLA", what])
