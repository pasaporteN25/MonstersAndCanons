# Texto del diálogo de la flecha «← Menú» (RF-725, D-217): título y un único aviso breve.
# Lógica pura, sin escena (P10).
class_name ExitText
extends RefCounted

## T534: los textos viven en el catálogo de idiomas (`exit.title`, `exit.warning`).
static func title() -> String:
	return Localization.t(&"exit.title")


## El cuerpo del diálogo: siempre el mismo aviso breve (RF-725), sin importar el estado de la partida. No enumera oro,
## oleada, piezas ni demolición.
static func message() -> String:
	return Localization.t(&"exit.warning")
