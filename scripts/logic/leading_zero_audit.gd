class_name LeadingZeroAudit
extends RefCounted
## Auditoría de números con cero inicial en lo que se ve (T474, RF-695): recorre los textos y tooltips de un árbol
## de nodos y devuelve cada «01», «05», «09»… suelto. Un `0,5`, un `0.60/s`, un `1:05`, un `10` o un id `level_01`
## no cuentan: solo un cero seguido de una cifra, sin nada pegado que lo vuelva parte de otro número o identificador.

const PATTERN: String = "(?<![\\w.,:/\\-])0\\d+(?![\\w])"

static var _regex: RegEx = RegEx.create_from_string(PATTERN)


## Los números con cero inicial que hay en `text` (vacío si no hay ninguno).
static func in_text(text: String) -> PackedStringArray:
	var found := PackedStringArray()
	for hit: RegExMatch in _regex.search_all(text):
		found.append(hit.get_string())
	return found


## Recorre `root` y sus hijos: por cada texto o tooltip con un cero inicial, una línea «ruta: "texto"».
static func scan(root: Node) -> PackedStringArray:
	var problems := PackedStringArray()
	_scan_node(root, root, problems)
	return problems


static func _scan_node(root: Node, node: Node, problems: PackedStringArray) -> void:
	var texts: Array[String] = []
	if node is Label or node is Button or node is RichTextLabel:
		texts.append(String(node.get("text")))
	if node is Control:
		texts.append((node as Control).tooltip_text)
	for text: String in texts:
		if not in_text(text).is_empty():
			problems.append("%s: \"%s\"" % [root.get_path_to(node), text.replace("\n", " / ")])
	for child: Node in node.get_children():
		_scan_node(root, child, problems)
