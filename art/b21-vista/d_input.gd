# B-21 v2 · Prototipo: en la maqueta 3D (D) recibe la entrada del mapa ANTES que la partida, en el lugar
# del BuildController (va justo después de él entre los hijos de Game), y la pasa al laboratorio.
extends Node

var handler: Callable


func _unhandled_input(event: InputEvent) -> void:
	handler.call(event)
