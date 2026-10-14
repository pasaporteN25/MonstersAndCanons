# Un trabajo de demolición en curso (RF-406): celda, duración, tiempo avanzado y oro pagado.
# Lógica pura: el reloj lo mueve quien lo llama con el `delta` de la partida.
class_name DemolitionJob
extends RefCounted

var cell: Vector2i = Vector2i.ZERO
var seconds_total: float = 0.0
var seconds_done: float = 0.0
## RF-406: lo que se pagó al ordenar; es lo que se devuelve si se cancela (RF-407).
var paid: int = 0


func _init(job_cell: Vector2i = Vector2i.ZERO, seconds: float = 0.0, gold_paid: int = 0) -> void:
	cell = job_cell
	seconds_total = maxf(seconds, 0.0)
	paid = gold_paid


func tick(delta: float) -> void:
	seconds_done = minf(seconds_done + maxf(delta, 0.0), seconds_total)


## De 0.0 a 1.0.
func progress() -> float:
	return 1.0 if seconds_total <= 0.0 else seconds_done / seconds_total


func seconds_left() -> float:
	return seconds_total - seconds_done


func is_done() -> bool:
	return seconds_done >= seconds_total
