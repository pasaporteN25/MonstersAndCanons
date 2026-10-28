# Texto del diálogo de la flecha «← Menú» (RF-725, D-217): título y un único aviso breve.
# Lógica pura, sin escena (P10).
class_name ExitText
extends RefCounted

const TITLE: String = "¿Volver al menú principal?"
## Única advertencia permitida en el cuerpo (RF-725). No enumera oro, oleada, piezas ni demolición.
const WARNING: String = "No se guardará el progreso de esta partida."


## El cuerpo del diálogo: siempre el mismo aviso, sin importar el estado de la partida.
static func message() -> String:
	return WARNING
