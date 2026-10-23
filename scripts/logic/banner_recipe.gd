class_name BannerRecipe
extends RefCounted
## RF-662/RF-664: receta cosmética del banderín del jugador (ids estables del `BannerCatalog`).
## Lógica pura: no toca disco ni escenas. La persistencia está en `BannerRecipeStore`.

const VERSION: int = 1

var palette: String = BannerCatalog.DEFAULT_PALETTE
var emblem: String = BannerCatalog.DEFAULT_EMBLEM


static func default_recipe() -> BannerRecipe:
	return BannerRecipe.new()


static func make(palette_id: String, emblem_id: String) -> BannerRecipe:
	## Receta con esos ids; si alguno no está en el catálogo, la predeterminada.
	var recipe := BannerRecipe.new()
	if BannerCatalog.has_palette(palette_id) and BannerCatalog.has_emblem(emblem_id):
		recipe.palette = palette_id
		recipe.emblem = emblem_id
	return recipe


func is_valid() -> bool:
	return BannerCatalog.has_palette(palette) and BannerCatalog.has_emblem(emblem)


func is_default() -> bool:
	return palette == BannerCatalog.DEFAULT_PALETTE and emblem == BannerCatalog.DEFAULT_EMBLEM


func equals(other: BannerRecipe) -> bool:
	return other != null and palette == other.palette and emblem == other.emblem


func to_dict() -> Dictionary:
	return {"version": VERSION, "palette": palette, "emblem": emblem}


static func from_dict(raw: Variant) -> BannerRecipe:
	## Receta validada: cualquier dato ausente, de otro tipo, de otra versión o con ids
	## desconocidos da la predeterminada (sin errores ni avisos del motor).
	if not raw is Dictionary:
		return default_recipe()
	var values: Dictionary = raw
	var version: Variant = values.get("version")
	# JSON entrega los enteros como float: 1.0 vale 1, pero 1.5 no.
	if typeof(version) not in [TYPE_INT, TYPE_FLOAT] or float(version) != float(VERSION):
		return default_recipe()
	var palette_id: Variant = values.get("palette")
	var emblem_id: Variant = values.get("emblem")
	if not BannerCatalog.has_palette(palette_id) or not BannerCatalog.has_emblem(emblem_id):
		return default_recipe()
	return make(palette_id, emblem_id)
