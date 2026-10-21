extends SceneTree

const SOURCES: Array[String] = [
	"res://art/t437-banderines/fuentes/tronco.png",
	"res://art/t437-banderines/fuentes/helecho.png",
	"res://art/t437-banderines/fuentes/poste_enemigo.png",
	"res://art/t437-banderines/fuentes/poste_jugador.png",
]
const OUTPUTS: Array[String] = [
	"res://assets/sprites/map/rendered/log.png",
	"res://assets/sprites/map/rendered/fern.png",
	"res://assets/sprites/map/rendered/banner_post_enemy.png",
	"res://assets/sprites/map/rendered/banner_post_player.png",
]


func _initialize() -> void:
	for index: int in SOURCES.size():
		var image := Image.new()
		var source_path: String = ProjectSettings.globalize_path(SOURCES[index])
		var output_path: String = ProjectSettings.globalize_path(OUTPUTS[index])
		var error: Error = image.load(source_path)
		if error != OK:
			push_error("No se pudo cargar la fuente de arte: " + SOURCES[index])
			quit(1)
			return
		image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		error = image.save_png(output_path)
		if error != OK:
			push_error("No se pudo guardar el recurso de arte: " + OUTPUTS[index])
			quit(1)
			return
		print("T437: ", OUTPUTS[index])
	quit()
