# Estadísticas de una partida de pruebas (spec RF-325, D-048). Sin escenas (P10): junta las filas por
# oleada y arma el diccionario que se escribe en `user://pruebas_stats.json`. Usa los mismos datos
# que el informe del bot (`tools/balance_sim.gd`: oleada, vidas, oro, torres, resultado), con los
# nombres en inglés.
class_name DevStats
extends RefCounted

const RESULT_WON: String = "won"
const RESULT_LOST: String = "lost"
## Se salió de la partida antes de que terminara.
const RESULT_LEFT: String = "left"

var level: String = ""
var start_wave: int = 1
var started_at: String = ""
## Tiempo de juego en segundos (con la velocidad aplicada; la pausa no cuenta).
var seconds: float = 0.0
var waves: Array[Dictionary] = []


func begin(level_id: String, first_wave: int) -> void:
	level = level_id
	start_wave = first_wave
	started_at = Time.get_datetime_string_from_system()


## Una fila por oleada terminada, igual que la línea "oleada N terminada" del bot.
func record_wave(wave: int, lives: int, gold: int, towers: int) -> void:
	waves.append({"wave": wave, "lives": lives, "gold": gold, "towers": towers})


## El informe. `wave`, `lives`, `gold` y `towers` son los de este momento.
func to_dict(result: String, wave: int, total_waves: int, lives: int, gold: int, towers: int) -> Dictionary:
	return {
		"level": level,
		"start_wave": start_wave,
		"wave": wave,
		"total_waves": total_waves,
		"lives": lives,
		"gold": gold,
		"towers": towers,
		"result": result,
		"waves": waves.duplicate(true),
		"seconds": snappedf(seconds, 0.1),
		"started_at": started_at,
	}


## Escribe el informe en `path` (reemplaza el archivo). Devuelve false si no se pudo.
static func write(report: Dictionary, path: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(report, "\t"))
	return true
