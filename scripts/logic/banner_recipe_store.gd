class_name BannerRecipeStore
extends RefCounted
## RF-664 / D-186: guarda la receta del banderín en su propio archivo `user://`,
## aparte de `SaveManager`, de las opciones y de `SAVE_VERSION`.
## Nunca bloquea el juego: un archivo ausente o dañado da la receta predeterminada.

const DEFAULT_PATH: String = "user://banner.json"


static func load_recipe(path: String = DEFAULT_PATH) -> BannerRecipe:
	if not FileAccess.file_exists(path):
		return BannerRecipe.default_recipe()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return BannerRecipe.default_recipe()
	var text: String = file.get_as_text()
	file.close()
	# JSON.new().parse() en vez de JSON.parse_string(): un archivo roto no imprime errores del motor.
	var json := JSON.new()
	if json.parse(text) != OK:
		return BannerRecipe.default_recipe()
	return BannerRecipe.from_dict(json.data)


static func save_recipe(recipe: BannerRecipe, path: String = DEFAULT_PATH) -> bool:
	## Escribe en un temporal y lo renombra, para no dejar un archivo a medias.
	## Una receta inválida no se guarda. Devuelve si pudo guardar.
	if recipe == null or not recipe.is_valid():
		return false
	var temporary_path: String = path + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(recipe.to_dict(), "  "))
	file.close()
	var rename_error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(path))
	if rename_error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return false
	return true
