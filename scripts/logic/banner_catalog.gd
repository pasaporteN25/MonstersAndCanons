class_name BannerCatalog
extends RefCounted
## RF-662: catálogo cerrado de paletas y emblemas abstractos para el banderín del jugador.
## Los ids son estables (se guardan en disco): no se renombran ni se reusan; solo se agregan.
## Las etiquetas (en español; el inglés está en el catálogo `banner_palette.*`/`banner_emblem.*`) son para la interfaz; los sprites cerrados se resuelven en MapDrawings.

const DEFAULT_PALETTE: String = "meridiana"
const DEFAULT_EMBLEM: String = "chevron"

const PALETTES: Dictionary = {
	"meridiana": "Meridiana",
	"brasa": "Brasa",
	"musgo": "Musgo",
	"marea": "Marea",
}

const EMBLEMS: Dictionary = {
	"chevron": "Chevron",
	"rombo": "Rombo",
	"estrella": "Estrella",
	"franja": "Franja",
}


static func palette_ids() -> Array[String]:
	var ids: Array[String] = []
	for id: String in PALETTES:
		ids.append(id)
	return ids


static func emblem_ids() -> Array[String]:
	var ids: Array[String] = []
	for id: String in EMBLEMS:
		ids.append(id)
	return ids


static func has_palette(id: Variant) -> bool:
	return id is String and PALETTES.has(id)


static func has_emblem(id: Variant) -> bool:
	return id is String and EMBLEMS.has(id)


static func palette_label(id: String) -> String:
	return Localization.data_text("banner_palette", StringName(id), "name", str(PALETTES.get(id, "")))


static func emblem_label(id: String) -> String:
	return Localization.data_text("banner_emblem", StringName(id), "name", str(EMBLEMS.get(id, "")))
