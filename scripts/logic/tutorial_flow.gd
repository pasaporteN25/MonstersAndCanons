# El tutorial del nivel 1 (M63): cuándo se muestra solo (RF-570) y en qué paso va (RF-574). Lógica pura, sin
# escena (P10): una tabla de decisión y una máquina de pasos que se prueban sin abrir ventanas. Quien la usa
# (`TutorialController`) mira la partida, le avisa los eventos y dibuja el paso actual.
class_name TutorialFlow
extends RefCounted

## El paso cambió (o terminó): `TutorialController` redibuja la tarjeta.
signal step_changed
## Terminó: `completed` es `true` si se llegó al final y `false` si se saltó.
signal finished(completed: bool)

var _steps: Array[Dictionary] = []
var _index: int = 0
var _done: bool = false


## RF-570: ¿el nivel arranca con el tutorial? Solo en el nivel que dice el archivo, jugado desde el menú (no en
## el modo de pruebas ni probando desde el editor), con la opción prendida, sin haberlo completado o saltado
## antes y con un archivo válido (un tutorial roto nunca bloquea jugar).
static func should_auto_show(enabled: bool, done: bool, dev_enabled: bool, testing: bool, is_tutorial_level: bool,
		data_valid: bool) -> bool:
	return enabled and not done and not dev_enabled and not testing and is_tutorial_level and data_valid


func _init(steps: Array[Dictionary] = []) -> void:
	_steps = steps.duplicate()
	_done = _steps.is_empty()


func is_finished() -> bool:
	return _done


func count() -> int:
	return _steps.size()


## El número del paso actual, empezando en 1 (el total de la lista si ya terminó).
func number() -> int:
	return mini(_index + 1, _steps.size())


## El paso actual: `{"paso", "texto"}`; vacío si terminó.
func current() -> Dictionary:
	return {} if _done else _steps[_index]


func current_id() -> String:
	return "" if _done else String(_steps[_index]["paso"])


## ¿El paso actual es de lectura (se pasa con «Siguiente») y no de acción?
func is_reading() -> bool:
	return not _done and TutorialData.event_of(current_id()) == TutorialData.EVENT_NONE


## ¿Es el último paso? (el botón dice «¡A jugar!» en vez de «Siguiente»)
func is_last() -> bool:
	return not _done and _index == _steps.size() - 1


## Un paso de lectura pasa con «Siguiente»; el último termina el tutorial. En un paso de acción no hace nada
## (hay que hacer la acción) y devuelve `false`.
func next() -> bool:
	if not is_reading():
		return false
	_advance()
	return true


## La partida avisa que pasó algo. Si es lo que espera el paso actual, pasa al siguiente. Devuelve si pasó.
func notify(event: StringName) -> bool:
	if _done or event == TutorialData.EVENT_NONE or TutorialData.event_of(current_id()) != event:
		return false
	_advance()
	return true


## Salta el tutorial (RF-574): termina sin completarlo. Si ya había terminado no hace nada.
func skip() -> void:
	if _done:
		return
	_done = true
	finished.emit(false)


## Pasa al siguiente paso que todavía haga falta. `satisfied` dice si un paso de acción ya se cumplió antes de
## llegar a él (por ejemplo, quien construyó la torre durante un paso de lectura): se lo saltea.
func skip_satisfied(satisfied: Callable) -> void:
	while not _done and not is_reading() and bool(satisfied.call(current_id())):
		_advance()


## Vuelve a un paso anterior de la lista (por ejemplo, si el jugador soltó la torre que había elegido). Devuelve
## `false` si el paso no está en la lista, si no es anterior al actual o si el tutorial ya terminó.
func rewind_to(step_id: String) -> bool:
	if _done:
		return false
	for i: int in _index:
		if String(_steps[i]["paso"]) == step_id:
			_index = i
			return true
	return false


func _advance() -> void:
	_index += 1
	if _index >= _steps.size():
		_done = true
		finished.emit(true)
		return
	step_changed.emit()
