## Arranca el bot después de que Godot registre los autoloads de la partida.
## Ejemplo: godot --headless --path . --fixed-fps 60 -s tools/run_balance_sim.gd -- sin_recursos level=15
extends SceneTree


func _initialize() -> void:
	call_deferred("_run_balance")


func _run_balance() -> void:
	var simulator: Script = load("res://tools/balance_sim.gd") as Script
	if simulator == null or not simulator.can_instantiate():
		push_error("No se pudo cargar el bot de balance.")
		quit(2)
		return
	set_script(simulator)
	call("_initialize")
