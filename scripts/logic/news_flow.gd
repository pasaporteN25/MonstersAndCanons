# Cuándo se muestra «Novedades de esta versión» (M67, RF-603). Lógica pura, sin escena (P10): la decisión es una
# tabla que se prueba sin abrir ventanas. Quien la usa (el menú principal) abre la pantalla y marca la versión.
class_name NewsFlow
extends RefCounted

enum Decision {
	NOTHING,        ## no sale y no se marca nada
	SHOW,           ## sale sola (y se marca al abrirse)
	MARK_SILENTLY,  ## no sale, pero la versión se marca como vista (mejoras para un guardado nuevo)
}


## RF-603. `entry` es la entrada de `version` en el archivo (`{}` si no hay); `data_valid` dice si el archivo no
## tiene errores. `dev_enabled`, `in_editor` y `standalone_scene` son los lugares donde nunca sale (RF-608).
static func decide(version: String, seen_version: String, entry: Dictionary, data_valid: bool,
		dev_enabled: bool, in_editor: bool, standalone_scene: bool, new_save: bool) -> Decision:
	if version.is_empty() or version == seen_version:
		return Decision.NOTHING
	if dev_enabled or in_editor or standalone_scene or not data_valid:
		return Decision.NOTHING
	if entry.is_empty() or bool(entry.get("borrador", true)):
		return Decision.NOTHING
	if String(entry.get("tipo", "")) == NewsData.TYPE_IMPROVEMENTS and new_save:
		return Decision.MARK_SILENTLY
	return Decision.SHOW


static func should_auto_show(version: String, seen_version: String, entry: Dictionary, data_valid: bool,
		dev_enabled: bool, in_editor: bool, standalone_scene: bool, new_save: bool) -> bool:
	return decide(version, seen_version, entry, data_valid, dev_enabled, in_editor, standalone_scene, new_save) == Decision.SHOW


## RF-603 (4): un guardado nuevo no tiene ningún nivel ganado y no vio la intro.
static func is_new_save(has_won_levels: bool, intro_seen: bool) -> bool:
	return not has_won_levels and not intro_seen
