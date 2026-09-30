# Los temas del mapa (spec §7.11, RF-260, RF-261): el paisaje de todo un nivel. Es solo visual.
# La paleta y la decoración de cada tema se suman en T123/T124; acá está la lista de temas válidos.
class_name MapThemes
extends RefCounted

## El de siempre: si un nivel no dice tema, es este y se ve exactamente igual que antes de M15.
const DEFAULT: StringName = &"pradera"
const IDS: PackedStringArray = ["pradera", "desierto", "nieve", "volcan", "bosque", "pantano", "ruinas"]


static func is_valid(id: String) -> bool:
	return IDS.has(id)
