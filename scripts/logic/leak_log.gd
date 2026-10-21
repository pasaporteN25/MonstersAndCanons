# Registro de fugas de una partida (M70, RF-631): cuántos enemigos de cada tipo llegaron a la salida y cuántas
# vidas quitaron de verdad. Se toca solo cuando un enemigo llega, nunca por cuadro. No se guarda en ningún archivo.
# Lógica pura, sin escena (P10).
class_name LeakLog
extends RefCounted

## { EnemyData: cuántos de ese tipo llegaron a la salida }
var leaks: Dictionary = {}
## { EnemyData: vidas que de verdad quitaron (sin pasar de las que quedaban) }
var lives: Dictionary = {}


## Anota una fuga que quitó `lives_taken` vidas. Con 0 o menos (vidas infinitas, partida terminada) no anota nada.
func record(enemy: EnemyData, lives_taken: int) -> void:
	if enemy == null or lives_taken <= 0:
		return
	leaks[enemy] = int(leaks.get(enemy, 0)) + 1
	lives[enemy] = int(lives.get(enemy, 0)) + lives_taken


func total_lives() -> int:
	var total: int = 0
	for amount: Variant in lives.values():
		total += int(amount)
	return total


func total_leaks() -> int:
	var total: int = 0
	for amount: Variant in leaks.values():
		total += int(amount)
	return total


func is_empty() -> bool:
	return leaks.is_empty()
