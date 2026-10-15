# Cuándo se muestra la intro y a dónde se va al terminarla (M57, RF-498 y RF-500). Lógica pura, sin escena
# (P10): la decisión es una tabla que se prueba sin abrir ventanas. Quien la usa (el menú) hace la navegación.
class_name IntroFlow
extends RefCounted

## A dónde se va cuando la intro (abierta desde «Jugar») termina o se omite.
enum Destination {
	LEVEL_1,       ## el guardado no tiene ningún nivel ganado: se abre el nivel 1, con su cartel de entrada
	LEVEL_SELECT,  ## ya hay niveles ganados: la selección de niveles, como siempre
}


## RF-498: ¿«Jugar» abre la intro sola? Solo si el guardado no la marcó como vista, fuera del modo de pruebas
## y con un archivo válido (una intro rota nunca bloquea jugar).
static func should_auto_show(intro_seen: bool, dev_enabled: bool, data_valid: bool) -> bool:
	return not intro_seen and not dev_enabled and data_valid


## RF-500: terminar y omitir hacen exactamente lo mismo.
static func after_finish(has_won_levels: bool) -> Destination:
	return Destination.LEVEL_SELECT if has_won_levels else Destination.LEVEL_1
