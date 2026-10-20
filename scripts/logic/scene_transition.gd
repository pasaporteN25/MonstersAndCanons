class_name SceneTransition
extends Node
# RF-580 a RF-589 (M64, D-130 a D-134): cambia de escena mostrando una pantalla de carga y bloqueando TODA la
# entrada mientras dura. NÚCLEO GENÉRICO: no nombra nada de este proyecto (ni autoloads, ni guardado, ni
# escenas, ni colores propios), así que se puede copiar tal cual a otro juego de Godot 4.
#
# Cómo se usa (el detalle está en docs/skills-borrador/godot-pantalla-de-carga/SKILL.md):
#   var transition := SceneTransition.new()
#   add_child(transition)            # en un autoload, que vive toda la partida
#   transition.go(ruta_de_la_escena)   # false si ya hay un cambio en curso (se ignora)
#
# Qué hace `go`, en orden:
#   1. Marca el cambio como en curso (`is_busy`) y bloquea la entrada de la ventana principal.
#   2. Muestra la capa de carga (fondo, texto y una barra que se mueve) y espera un cuadro para que se dibuje.
#   3. Carga la escena en un hilo (`ResourceLoader.load_threaded_request`) y mira el estado cada cuadro.
#   4. Espera a que haya pasado el mínimo de tiempo (para que no parpadee).
#   5. Cambia de escena (`swapper`), espera a que la nueva se arme y deja pasar un rato más con la entrada
#      todavía bloqueada: los toques que se juntaron mientras el motor estaba ocupado se descartan.
#   6. Oculta la capa y libera la entrada.
#
# Los tiempos se miden con el reloj real (`Time.get_ticks_msec`), no con delta: la pausa del árbol y
# `Engine.time_scale` no los afectan. Este nodo trabaja aunque el árbol esté en pausa.

## Se emite al empezar un cambio (con la ruta pedida).
signal started(path: String)
## Se emite cuando la escena nueva ya está puesta y la entrada se liberó.
signal finished(path: String)
## Se emite si la escena no se pudo cargar; la entrada se libera y la escena vieja sigue donde estaba.
signal failed(path: String)

## Tiempo mínimo que se ve la capa (segundos), aunque la escena cargue antes.
var min_seconds: float = 0.4
## Cuántos cuadros y cuántos segundos se sigue bloqueando después de cambiar de escena.
var release_frames: int = 2
var release_seconds: float = 0.15
## false = no bloquear la entrada (solo para mostrar la capa; los tests lo usan para comparar).
var blocks_input: bool = true
## true = cargar en un hilo; false = cargar de una vez (se bloquea el motor, pero la capa ya se dibujó).
var use_threads: bool = true
## Lo que se ve en la capa.
var title: String = "Cargando…"
var background_color: Color = Color(0.07, 0.08, 0.1, 1.0)
var text_color: Color = Color(0.9, 0.92, 0.96, 1.0)
var accent_color: Color = Color(1.0, 0.84, 0.3, 1.0)
var font_size: int = 36
## Un tema opcional para la capa (la fuente del juego, por ejemplo).
var ui_theme: Theme
## Cómo se pone la escena. Por omisión, `SceneTree.change_scene_to_packed`. Los tests lo reemplazan.
var swapper: Callable = Callable()
## Cómo se carga la escena. Si es válido, reemplaza a la carga en hilo: `(path: String) -> PackedScene`.
var load_override: Callable = Callable()

var _busy: bool = false
var _progress: float = 0.0
var _started_ms: int = 0
var _layer: CanvasLayer
var _bar: Control
var _previous_disable_input: bool = false
var _input_blocked: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	_build_overlay()


func _exit_tree() -> void:
	_set_input_blocked(false)


func is_busy() -> bool:
	return _busy


## ¿Se está viendo la capa de carga?
func is_overlay_visible() -> bool:
	return _layer != null and _layer.visible


## 0.0 a 1.0: cuánto se cargó de la escena pedida (de la carga en hilo).
func progress() -> float:
	return _progress


## Empieza el cambio a `path`. Devuelve false (y no hace nada) si ya hay uno en curso o si no hay árbol.
func go(path: String) -> bool:
	if _busy or not is_inside_tree():
		return false
	_busy = true
	_progress = 0.0
	_started_ms = Time.get_ticks_msec()
	_show(true)
	_set_input_blocked(blocks_input)
	started.emit(path)
	_run(path)  # corrutina: no se espera, sigue sola cuadro a cuadro
	return true


func _run(path: String) -> void:
	await get_tree().process_frame  # un cuadro para que la capa se dibuje antes de lo pesado
	var scene: PackedScene = await _load(path)
	if scene == null:
		push_warning("SceneTransition: no se pudo cargar «%s»." % path)
		_close()
		failed.emit(path)
		return
	_progress = 1.0
	while _elapsed() < min_seconds:
		await get_tree().process_frame
	_swap(scene)
	for i: int in release_frames:
		await get_tree().process_frame
	var after_swap_ms: int = Time.get_ticks_msec()
	while _since(after_swap_ms) < release_seconds:
		await get_tree().process_frame
	_close()
	finished.emit(path)


func _load(path: String) -> PackedScene:
	if load_override.is_valid():
		return load_override.call(path) as PackedScene
	if not ResourceLoader.exists(path):
		return null
	if not use_threads or ResourceLoader.load_threaded_request(path) != OK:
		return ResourceLoader.load(path) as PackedScene
	while true:
		var info: Array = []
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path, info)
		if not info.is_empty():
			_progress = float(info[0])
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			return ResourceLoader.load_threaded_get(path) as PackedScene
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return null
		await get_tree().process_frame
	return null


func _swap(scene: PackedScene) -> void:
	if swapper.is_valid():
		swapper.call(scene)
	else:
		get_tree().change_scene_to_packed(scene)


func _close() -> void:
	Input.flush_buffered_events()
	_show(false)
	_set_input_blocked(false)
	_busy = false


func _elapsed() -> float:
	return _since(_started_ms)


func _since(ms: int) -> float:
	return float(Time.get_ticks_msec() - ms) / 1000.0


func _set_input_blocked(blocked: bool) -> void:
	var root: Window = get_tree().root if is_inside_tree() else null
	if root == null:
		_input_blocked = false
		return
	if blocked and not _input_blocked:
		_previous_disable_input = root.is_input_disabled()
		root.set_disable_input(true)
		Input.flush_buffered_events()
		_input_blocked = true
	elif not blocked and _input_blocked:
		root.set_disable_input(_previous_disable_input)
		_input_blocked = false


# --- La capa de carga (dibujada por código, sin escenas ni imágenes) ---

func _show(visible_now: bool) -> void:
	if _layer == null:
		_build_overlay()
	_layer.visible = visible_now
	if _bar != null:
		_bar.set_process(visible_now)


func _build_overlay() -> void:
	if _layer != null:
		return
	_layer = CanvasLayer.new()
	_layer.name = "LoadingLayer"
	_layer.layer = 128
	_layer.visible = false
	add_child(_layer)
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP  # también frena el toque si el bloqueo del viewport faltara
	if ui_theme != null:
		root.theme = ui_theme
	_layer.add_child(root)
	var back := ColorRect.new()
	back.name = "Background"
	back.color = background_color
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(back)
	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var column := VBoxContainer.new()
	column.name = "Column"
	column.add_theme_constant_override("separation", 18)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(column)
	var label := Label.new()
	label.name = "Title"
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(label)
	_bar = _LoadingBar.new()
	_bar.name = "Bar"
	_bar.owner_transition = self
	column.add_child(_bar)
	_bar.set_process(false)


## La barra: un riel y un tramo que va y viene. Si hay progreso real, el riel se llena hasta ahí.
class _LoadingBar extends Control:
	const BAR_SIZE := Vector2(360, 10)
	const SEGMENT: float = 0.3
	const SPEED: float = 1.2  # recorridos por segundo
	var owner_transition: SceneTransition

	func _init() -> void:
		custom_minimum_size = BAR_SIZE
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		if owner_transition == null:
			return
		var accent: Color = owner_transition.accent_color
		var rail := Rect2(Vector2.ZERO, size)
		draw_rect(rail, Color(accent.r, accent.g, accent.b, 0.18))
		var filled: float = clampf(owner_transition.progress(), 0.0, 1.0)
		if filled > 0.0:
			draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * filled, size.y)), Color(accent.r, accent.g, accent.b, 0.35))
		var phase: float = fposmod(float(Time.get_ticks_msec()) / 1000.0 * SPEED, 2.0)
		var t: float = phase if phase <= 1.0 else 2.0 - phase  # ida y vuelta
		var seg_w: float = size.x * SEGMENT
		draw_rect(Rect2(Vector2((size.x - seg_w) * t, 0.0), Vector2(seg_w, size.y)), accent)
