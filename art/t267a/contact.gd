# Rasteriza los dos bocetos nuevos como referencia de fuente; no es una captura de mapa.
extends SceneTree

const PAIRS: Array[Array] = [
	["estatua", "res://art/t267a/sources/estatua.svg", "res://art/t267a/samples/estatua.svg", 64.0],
	["central", "res://art/t233-final/sources/central_master.svg", "res://art/t267a/sources/central_master_sample.svg", 128.0],
]

func _init() -> void:
	for side: int in [220, 112]:
		for pair: Array in PAIRS:
			for column: int in 2:
				var source: String = FileAccess.get_file_as_string(pair[column + 1])
				var image: Image = Image.new()
				assert(image.load_svg_from_string(source, float(side) / pair[3]) == OK)
				assert(image.save_png("res://art/t267a/review/source_%s_%s_%d.png" % [pair[0], "before" if column == 0 else "after", side]) == OK)
	quit()
