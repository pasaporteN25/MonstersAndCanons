# «Novedades de esta versión» (M67, RF-604): pantalla completa sobre el menú, con un panel de hierro y bronce: cabecera
# opcional, título, subtítulo, la versión, la lista de novedades (hasta 8, con desplazamiento) y «Entendido» siempre
# a la vista. Solo muestra y avisa (`closed`): cuándo sale y a dónde se vuelve lo decide quien la abre (P6).
#
# Los nodos se crean al abrirse y se borran al cerrarse; no hay `_process` ni animación salvo un fundido de 0,2 s.
# Las imágenes (cabecera e íconos) se cargan al abrir con `load`, no con `preload`: no pesan en el arranque.
# Arte aprobado (T375): cabecera proporcional y medallones de 48/64 px; sin ícono se conserva el rombo de bronce.
class_name NewsScreen
extends CanvasLayer

## Se cerró la pantalla (por «Entendido», `Esc` o el «atrás» de Android).
signal closed

const GOLD := Color(1.0, 0.84, 0.3)
const BRONZE := Color(0.72, 0.5, 0.24)
const TEXT_COLOR := Color(0.92, 0.92, 0.96)
const MUTED_COLOR := Color(0.7, 0.72, 0.78)
const DIM_COLOR := Color(0.03, 0.035, 0.05, 0.97)
const THEME: Theme = preload("res://assets/ui/menu_theme.tres")
const PANEL_STYLE: StyleBox = preload("res://assets/ui/game_panel_style.tres")
## Medidas de interfaz (RF-604), no de balance.
const PANEL_WIDTH_PC: float = 720.0
const PANEL_WIDTH_MOBILE: float = 880.0
const ICON_SIZE_PC: float = 48.0
const ICON_SIZE_MOBILE: float = 64.0
const ROW_MIN_HEIGHT: float = 56.0
const BUTTON_HEIGHT_PC: float = 44.0
const BUTTON_HEIGHT_MOBILE: float = 56.0
const TITLE_FONT: int = 34
const TITLE_FONT_MOBILE: int = 36
const ITEM_TITLE_FONT_PC: int = 20
const ITEM_TITLE_FONT_MOBILE: int = 22
const TEXT_FONT_PC: int = 18
const TEXT_FONT_MOBILE: int = 20
const SMALL_FONT_PC: int = 18
const SMALL_FONT_MOBILE: int = 20
const SCREEN_MARGIN: float = 24.0
const FADE_S: float = 0.2

var _root: Control
var _panel: PanelContainer
var _scroll: ScrollContainer
var _rows: VBoxContainer
var _button: Button
var _mobile: bool = false
var _opened: bool = false


func _init() -> void:
	layer = 17  # sobre el menú; quien la abre desde la pausa (capa 20) le sube la capa
	visible = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # también se puede abrir desde la pausa
	get_node("/root/Audio").call("add_click_sounds", self)


## Abre la pantalla con una entrada ya validada de `NewsData` y sus rótulos (`NewsData.labels`). Si la entrada
## está en borrador, lo dice con el rótulo «Borrador» arriba a la derecha (RF-607).
func open(entry: Dictionary, labels: Dictionary) -> void:
	_clear()
	_mobile = UiMode.is_mobile()
	_build(entry, labels)
	_opened = true
	visible = true
	if is_inside_tree():
		var tween: Tween = create_tween()
		_root.modulate.a = 0.0
		tween.tween_property(_root, "modulate:a", 1.0, FADE_S)
		_fit_scroll.call_deferred()
	_button.grab_focus()


func is_open() -> bool:
	return _opened


## Cierra, borra los nodos y avisa. Si ya estaba cerrada no hace nada (así `closed` sale una sola vez).
func close() -> void:
	if not _opened:
		return
	_opened = false
	visible = false
	_clear()
	closed.emit()


## El botón «Entendido» (para los tests).
func button() -> Button:
	return _button


## Cuántas novedades se ven (para los tests).
func item_count() -> int:
	return 0 if _rows == null else _rows.get_child_count()


func scroll() -> ScrollContainer:
	return _scroll


func panel() -> PanelContainer:
	return _panel


## Con la pantalla abierta, `Esc` (o el «atrás» de Android) la cierra y no llega a nadie más. El clic y el toque no
## pasan al menú de abajo: el fondo oscuro los detiene (`MOUSE_FILTER_STOP`) y «Entendido» cierra al soltar.
func _input(event: InputEvent) -> void:
	if _opened and event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func _clear() -> void:
	if _root != null:
		_root.queue_free()
	_root = null
	_panel = null
	_scroll = null
	_rows = null
	_button = null


func _build(entry: Dictionary, labels: Dictionary) -> void:
	_root = Control.new()
	_root.theme = THEME
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size.x = PANEL_WIDTH_MOBILE if _mobile else PANEL_WIDTH_PC
	_panel.add_theme_stylebox_override("panel", PANEL_STYLE)
	center.add_child(_panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24 if side in ["left", "right"] else 18)
	_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var small: int = SMALL_FONT_MOBILE if _mobile else SMALL_FONT_PC
	if String(entry.get("cabecera", "")) != "":
		var header := TextureRect.new()
		header.name = "Header"
		header.mouse_filter = Control.MOUSE_FILTER_IGNORE
		header.texture = load(String(entry["cabecera"]))
		header.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		header.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# El ancho interior descuenta el margen propio y el del estilo del panel.
		var width: float = _panel.custom_minimum_size.x - 48.0 - PANEL_STYLE.get_minimum_size().x
		header.custom_minimum_size.y = width * header.texture.get_height() / header.texture.get_width()
		column.add_child(header)
	var is_improvements: bool = String(entry.get("tipo", "")) == NewsData.TYPE_IMPROVEMENTS
	var title_text: String = String(labels.get("titulo_mejoras", "")) if is_improvements else String(entry.get("titulo", ""))
	var subtitle_text: String = String(entry.get("subtitulo", ""))
	if is_improvements and subtitle_text == "":
		subtitle_text = String(entry.get("titulo", ""))
	var title: Label = _label(title_text, TITLE_FONT_MOBILE if _mobile else TITLE_FONT, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	column.add_child(title)
	if subtitle_text != "":
		var subtitle: Label = _label(subtitle_text, small, TEXT_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
		subtitle.name = "Subtitle"
		column.add_child(subtitle)
	var version: Label = _label(GameVersion.label(String(entry.get("id", ""))), small, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	version.name = "Version"
	column.add_child(version)
	_scroll = ScrollContainer.new()
	_scroll.name = "Scroll"
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 10)
	_scroll.add_child(_rows)
	for item: Dictionary in entry.get("novedades", []):
		_rows.add_child(_make_row(item))
	_button = Button.new()
	_button.name = "Understood"
	_button.text = String(labels.get("entendido", "Entendido"))
	_button.custom_minimum_size = Vector2(240.0, BUTTON_HEIGHT_MOBILE if _mobile else BUTTON_HEIGHT_PC)
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.add_theme_font_size_override("font_size", ITEM_TITLE_FONT_MOBILE if _mobile else ITEM_TITLE_FONT_PC)
	_button.pressed.connect(close)
	# El foco se queda en «Entendido»: las flechas y Tab no se escapan al menú de abajo.
	_button.focus_neighbor_left = NodePath(".")
	_button.focus_neighbor_right = NodePath(".")
	_button.focus_neighbor_top = NodePath(".")
	_button.focus_neighbor_bottom = NodePath(".")
	_button.focus_next = NodePath(".")
	_button.focus_previous = NodePath(".")
	column.add_child(_button)
	if bool(entry.get("borrador", false)):
		var tag: Label = _label(String(labels.get("borrador", "Borrador")), small, Color(1.0, 0.55, 0.35), HORIZONTAL_ALIGNMENT_RIGHT)
		tag.name = "DraftTag"
		tag.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		tag.offset_left = -200.0
		tag.offset_right = -(SCREEN_MARGIN + 8.0)
		tag.offset_top = SCREEN_MARGIN
		tag.offset_bottom = SCREEN_MARGIN + 36.0
		_root.add_child(tag)
	if _mobile:
		MenuTouch.attach(_root)  # RF-550, RF-551: botón de 56 px y desplazamiento de un dedo


func _make_row(item: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.name = "Item"
	row.custom_minimum_size.y = ROW_MIN_HEIGHT
	row.add_theme_constant_override("separation", 14)
	if String(item.get("icono", "")) != "":
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = load(String(item["icono"]))
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var icon_size: float = ICON_SIZE_MOBILE if _mobile else ICON_SIZE_PC
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
	else:
		row.add_child(_marker())
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texts.add_theme_constant_override("separation", 2)
	row.add_child(texts)
	var title: Label = _label(String(item.get("titulo", "")), ITEM_TITLE_FONT_MOBILE if _mobile else ITEM_TITLE_FONT_PC, GOLD)
	title.name = "ItemTitle"
	texts.add_child(title)
	var text: Label = _label(String(item.get("texto", "")), TEXT_FONT_MOBILE if _mobile else TEXT_FONT_PC, TEXT_COLOR)
	text.name = "ItemText"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texts.add_child(text)
	return row


## El rombo de bronce para una novedad que no tiene ícono (RF-641).
func _marker() -> Control:
	var marker := Control.new()
	marker.name = "Marker"
	var marker_size: float = (ICON_SIZE_MOBILE if _mobile else ICON_SIZE_PC) * 0.5
	marker.custom_minimum_size = Vector2(marker_size, marker_size)
	marker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.draw.connect(func() -> void:
		var c: Vector2 = marker.size / 2.0
		var r: float = minf(c.x, c.y) * 0.6
		marker.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), BRONZE))
	return marker


## Como `OptionsMenu._fit_scroll` (RF-555): la lista se desplaza si el panel no entra en la ventana; si entra, el
## panel mide lo que mide su contenido y el título y «Entendido» quedan siempre a la vista.
func _fit_scroll() -> void:
	if _root == null or _panel == null or not is_inside_tree():
		return
	_scroll.custom_minimum_size.y = 0.0
	var content: float = _rows.get_combined_minimum_size().y
	var chrome: float = _panel.get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y
	var available: float = _root.size.y - SCREEN_MARGIN * 2.0 - chrome
	_scroll.custom_minimum_size.y = minf(content, maxf(available, ROW_MIN_HEIGHT * 2.0))


func _label(text: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
