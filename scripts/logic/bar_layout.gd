# Reparto de la barra de torres de abajo (M53, RF-454 a RF-456). Solo cuentas y textos de interfaz:
# no sabe nada de escenas, así que se prueba sin abrir ventanas (P10).
class_name BarLayout
extends RefCounted

## Lienzo base de 1280 × 720 (ventana por defecto). Las medidas son las de la spec.
## Sin pestañas la fila arranca donde siempre (x = 20); con pestañas, a la derecha de su columna (x = 118).
const LEFT_NO_TABS: int = 20
const LEFT_WITH_TABS: int = 118
## «Próxima oleada» arranca en x = 800: la fila nunca pasa de acá.
const RIGHT_EDGE: int = 792
## RF-170: el botón de siempre. Con pocas torres no crece más que esto.
const MAX_BUTTON_WIDTH: int = 76
## RF-455: el piso. Con 11 torres y pestañas miden 57.
const MIN_BUTTON_WIDTH: int = 56
## La separación de siempre entre botones, y la apretada cuando no entran.
const GAP_WIDE: int = 10
const GAP_TIGHT: int = 4
## Ancho de la columna de pestañas y alto de cada una (RF-455).
const TAB_SIZE := Vector2(96, 44)
## Teclas de torre: `1` a `9`, y `0` para la décima (RF-456).
const KEYED_TOWERS: int = 10


## Dónde arranca la fila de botones.
static func left(tabs: bool) -> int:
	return LEFT_WITH_TABS if tabs else LEFT_NO_TABS


## El ancho útil de la fila (con pestañas: 674).
static func area_width(tabs: bool) -> int:
	return RIGHT_EDGE - left(tabs)


## La separación: la de siempre (10) si los botones de 76 entran así; si no, la apretada (4).
static func gap(count: int, tabs: bool) -> int:
	if count <= 1:
		return GAP_WIDE
	var needed: int = count * MAX_BUTTON_WIDTH + (count - 1) * GAP_WIDE
	return GAP_WIDE if needed <= area_width(tabs) else GAP_TIGHT


## RF-455: el ancho de cada botón. 76 mientras entren; si no, lo que reparte el espacio, con piso de 56.
## Sin pestañas y hasta 9 torres es 76 siempre: la barra de los niveles 1 a 5 no cambia (RF-454).
static func button_width(count: int, tabs: bool) -> int:
	if count <= 1:
		return MAX_BUTTON_WIDTH
	var space: int = area_width(tabs) - (count - 1) * gap(count, tabs)
	return clampi(floori(space / float(count)), MIN_BUTTON_WIDTH, MAX_BUTTON_WIDTH)


## RF-456: la etiqueta de tecla del botón número `index` (0 = el primero): "1".."9", "0" para el décimo
## y vacía desde el undécimo.
static func key_label(index: int) -> String:
	if index < 0 or index >= KEYED_TOWERS:
		return ""
	return str((index + 1) % 10)


## RF-456: la acción de entrada que elige la torre `index`, o `&""` si esa torre no tiene tecla. Así
## `BuildController` no pregunta por acciones que no existen (el motor imprimía un error con `build_10`).
static func action_for(index: int) -> StringName:
	if index < 0 or index >= KEYED_TOWERS:
		return &""
	var action := StringName("build_%d" % (index + 1))
	return action if InputMap.has_action(action) else &""
