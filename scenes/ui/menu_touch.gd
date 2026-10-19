class_name MenuTouch
extends Node
# RF-550 y RF-551 (M61, D-115): adapta una pantalla de menú al modo celular. Cuelga de la pantalla y, mientras
# exista, deja a todo botón de al menos `boton_alto_px` de alto, a los deslizadores de `menu_deslizador_alto_px`
# y a cada `ScrollContainer` con su `TouchScroller` y una barra más ancha. Se ocupa también de lo que la pantalla
# agregue después (la lista de la Wiki, las tarjetas de nivel). En el modo PC no hace nada: no se agrega.
#
# Uso: `MenuTouch.attach(self)` al final de `_ready` de la pantalla.

const SKIP_META: StringName = &"menu_touch_skip"

var _root: Node
var _button_height: float = 56.0
var _slider_height: float = 44.0
var _bar_width: float = 22.0


## Agrega la ayuda táctil a `root` si el modo es celular. Devuelve la ayuda (o null en PC).
static func attach(root: Node) -> MenuTouch:
	if not UiMode.is_mobile():
		return null
	var helper := MenuTouch.new()
	helper.name = "MenuTouch"
	root.add_child(helper)
	return helper


func _ready() -> void:
	_root = get_parent()
	var config: MobileUiConfig = MobileUiConfig.load_from()
	_button_height = float(config.get_value("boton_alto_px"))
	_slider_height = float(config.get_value("menu_deslizador_alto_px"))
	_bar_width = float(config.get_value("scroll_barra_px"))
	get_tree().node_added.connect(_on_node_added)
	apply_to(_root)


## Pasa por toda la pantalla (para lo que ya estaba armado).
func apply_to(root: Node) -> void:
	_adapt(root)
	for node: Node in root.find_children("*", "", true, false):
		_adapt(node)


func _on_node_added(node: Node) -> void:
	if _root != null and _root.is_ancestor_of(node):
		# Diferido: la pantalla termina de dimensionar el nodo antes de que se lo suba al mínimo.
		_adapt.call_deferred(node)


func _adapt(node: Node) -> void:
	if not is_instance_valid(node) or node.has_meta(SKIP_META):
		return
	if node is BaseButton:
		var button: Control = node as Control
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, _button_height)
	elif node is Slider:
		var slider: Control = node as Control
		slider.custom_minimum_size.y = maxf(slider.custom_minimum_size.y, _slider_height)
	elif node is ScrollContainer:
		var scroll: ScrollContainer = node as ScrollContainer
		_thicken(scroll.get_v_scroll_bar(), true)
		_thicken(scroll.get_h_scroll_bar(), false)
		if scroll.find_child("TouchScroller", false, false) == null:
			var scroller := TouchScroller.new()
			scroller.name = "TouchScroller"
			scroll.add_child(scroller)


## Barra más ancha. El ancho que el `ScrollContainer` le reserva al contenido sale del estilo «scroll» de la barra
## (no de `custom_minimum_size`, que no cuenta ahí y la dejaba tapando el borde de las tarjetas): por eso el grosor
## se pone como margen del estilo.
func _thicken(bar: ScrollBar, vertical: bool) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.055, 0.06, 0.075, 0.85)
	track.set_corner_radius_all(int(_bar_width / 2.0))
	if vertical:
		track.content_margin_left = _bar_width
	else:
		track.content_margin_top = _bar_width
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("scroll_focus", track)
	for state: String in ["grabber", "grabber_highlight", "grabber_pressed"]:
		var grabber := StyleBoxFlat.new()
		grabber.bg_color = Color(0.52, 0.36, 0.17) if state == "grabber" else Color(0.86, 0.59, 0.22)
		grabber.set_corner_radius_all(int(_bar_width / 2.0))
		bar.add_theme_stylebox_override(state, grabber)
