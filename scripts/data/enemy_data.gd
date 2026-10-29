# Definición de un tipo de enemigo. Spec §6.
# Los valores por defecto son 0 a propósito: los números reales viven en los .tres (constitución P2).
class_name EnemyData
extends Resource

## Forma provisional con la que se dibuja (D-002).
enum Shape { CIRCLE, TRIANGLE, SQUARE, DIAMOND, HEXAGON }

@export var id: StringName = &""
@export var display_name: String = ""
## RF-134: frase que se muestra la primera vez que aparece este enemigo.
@export_multiline var description: String = ""
## Vida en la oleada 1; después crece según RF-36.
@export var max_health: int = 0
## Casillas por segundo.
@export var speed_tiles: float = 0.0
## Se resta a cada golpe recibido (RF-80).
@export var armor: int = 0
## Oro que da al morir (RF-21).
@export var reward: int = 0
## Vidas que quita al llegar a la salida (RF-11).
@export var lives_damage: int = 0
## Vuela en línea recta e ignora el camino (RF-05).
@export var is_flying: bool = false
## Qué parte de la ralentización ignora: 0.5 = solo le afecta la mitad (Jefe).
@export_range(0.0, 1.0) var slow_resistance: float = 0.0
@export var shape: Shape = Shape.CIRCLE
## Color del enemigo: se usa en los efectos (estallido al morir) y, sin dibujo, para la forma.
@export var color: Color = Color.WHITE
## Solo visual (RF-151): el dibujo, mirando a la derecha. Vacío = se usa `shape` (RF-156).
@export var texture: Texture2D
## RF-339: solo el dibujo crece; radio lógico y selección no cambian.
@export_range(0.1, 3.0) var visual_scale: float = 1.0
## Cuatro poses por fila, filas derecha/abajo/izquierda/arriba, cuadros de256.
@export var walk_atlas: Texture2D
## Distancia de un ciclo completo, en casillas; la ralentización mueve las patas más lento.
@export var walk_stride_tiles: float = 0.0
## Compensa la diferencia de enmarcado entre el atlas y la pose estática aprobada.
@export_range(0.1, 3.0) var walk_art_scale: float = 1.0
## Cuatro poses de vuelo en2×2. Usa tiempo físico y se detiene con la pausa.
@export var flight_atlas: Texture2D
@export var flight_frame_seconds: float = 0.16
## Solo visual (RF-330): si el dibujo se refleja en espejo al caminar hacia la izquierda (RF-151). Un
## dibujo con luz propia (los PNG de una sola vista) no se refleja: el espejo le cambiaría la luz de lado.
@export var flip_when_walking_left: bool = true
## Radio visual, en casillas.
@export var size_tiles: float = 0.0

# --- Comportamientos (M5, RF-164). Todos valen 0 = apagado, y se pueden combinar. ---

## RF-165: % de su vida máxima que recupera por segundo. No se regenera mientras se quema.
@export var regen_percent_per_second: float = 0.0
## RF-166: qué enemigo suelta al morir por daño (por ejemplo, las Crías de la Araña). Vacío = nada.
@export var death_spawn: EnemyData
## RF-166: cuántos suelta.
@export var death_spawn_count: int = 0

# --- Aura (M17, RF-270): hace más fuertes a los enemigos que caminan cerca. Todos valen 0 = apagado. ---

## Hasta dónde llega el aura de este enemigo, en casillas. 0 = no tiene aura.
@export var aura_radius_tiles: float = 0.0
## RF-271: armadura extra que da a los demás enemigos dentro del radio.
@export var aura_armor_bonus: int = 0
## RF-272: % de su vida máxima por segundo que hace recuperar a los demás dentro del radio.
@export var aura_heal_percent_per_second: float = 0.0

# --- Hechizo del Chamán (M18, RF-281): apaga torres. Todos valen 0 = apagado. ---

## Cada cuántos segundos lanza su hechizo. 0 = no lanza.
@export var stun_interval: float = 0.0
## Cuántos segundos deja aturdida (sin disparar) a la torre que alcanza.
@export var stun_seconds: float = 0.0
## A qué distancia llega el hechizo, en casillas. Menor que el alcance del Francotirador.
@export var stun_range_tiles: float = 0.0

# --- Rebote del Espejo (M18, RF-283): devuelve los tiros de las torres cercanas. Todos valen 0 = apagado. ---

## A qué distancia de él rebota el tiro de una torre, en casillas. 0 = no rebota nada.
@export var reflect_range_tiles: float = 0.0
## Cuántos segundos deja aturdida a la torre cuyo tiro rebotó.
@export var reflect_stun_seconds: float = 0.0

# --- Drenaje económico (RF-363) y encuentros opcionales (RF-364). Cero = apagado. ---
@export var gold_drain_amount: int = 0
@export var gold_drain_interval: float = 0.0
@export var gold_drain_floor: int = 0
@export var optional_wave_limit: int = 0


# --- Carga al extremo de rectas (RF-366). Cero = apagado. ---
@export var charge_distance_tiles: float = 0.0
@export var charge_multiplier: float = 0.0
@export var charge_slow_tolerance: float = 0.0
@export var charge_impact_radius_tiles: float = 0.0
@export var charge_wear_percent: float = 0.0


## T534: el nombre y la frase en el idioma activo (en español, los del `.tres`; en inglés, `enemy.<id>.name`/`.description`).
func name_text() -> String:
	return Localization.data_text("enemy", id, "name", display_name)


func description_text() -> String:
	return Localization.data_text("enemy", id, "description", description)
