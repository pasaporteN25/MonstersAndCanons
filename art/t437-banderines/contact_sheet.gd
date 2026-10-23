extends SceneTree

const SOURCES: Array[String] = [
	"res://art/t437-banderines/fuentes/tronco.png",
	"res://art/t437-banderines/fuentes/helecho.png",
	"res://art/t437-banderines/fuentes/poste_enemigo.png",
	"res://art/t437-banderines/fuentes/poste_jugador.png",
]
const GROUND: String = "res://assets/tiles/rendered/ground_bosque.png"
const OUTPUT: String = "res://art/t437-banderines/muestras/contacto_220_34.png"


func _initialize() -> void:
	var canvas := Image.create(1200, 390, false, Image.FORMAT_RGBA8)
	var ground := Image.new()
	var error: Error = ground.load(ProjectSettings.globalize_path(GROUND))
	if error != OK:
		push_error("No se pudo cargar el suelo del bosque para la hoja de contacto.")
		quit(1)
		return
	for y: int in range(0, canvas.get_height(), ground.get_height()):
		for x: int in range(0, canvas.get_width(), ground.get_width()):
			var width: int = mini(ground.get_width(), canvas.get_width() - x)
			var height: int = mini(ground.get_height(), canvas.get_height() - y)
			canvas.blit_rect(ground, Rect2i(Vector2i.ZERO, Vector2i(width, height)), Vector2i(x, y))
	for index: int in SOURCES.size():
		var source := Image.new()
		error = source.load(ProjectSettings.globalize_path(SOURCES[index]))
		if error != OK:
			push_error("No se pudo cargar la fuente de arte: " + SOURCES[index])
			quit(1)
			return
		var large: Image = source.duplicate()
		large.resize(220, 220, Image.INTERPOLATE_LANCZOS)
		canvas.blend_rect(large, Rect2i(Vector2i.ZERO, Vector2i(220, 220)), Vector2i(index * 300 + 40, 20))
		var small: Image = source.duplicate()
		small.resize(34, 34, Image.INTERPOLATE_LANCZOS)
		canvas.blend_rect(small, Rect2i(Vector2i.ZERO, Vector2i(34, 34)), Vector2i(index * 300 + 133, 310))
	error = canvas.save_png(ProjectSettings.globalize_path(OUTPUT))
	if error != OK:
		push_error("No se pudo guardar la hoja de contacto de T437.")
		quit(1)
		return
	print("T437: ", OUTPUT)
	quit()
