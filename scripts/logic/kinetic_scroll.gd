class_name KineticScroll
extends RefCounted
# RF-551 (M61, D-115): las cuentas del desplazamiento con un dedo, sin tocar la escena (P10).

## ¿El dedo se movió lo bastante como para que sea un arrastre y no un toque?
static func is_drag(distance: float, threshold: float) -> bool:
	return distance > threshold


## La velocidad (px/s) tras `delta` segundos de frenado exponencial: `v · e^(−fricción · delta)`.
static func decay(velocity: float, friction: float, delta: float) -> float:
	return velocity * exp(-friction * delta)


## ¿Ya va tan lento que conviene parar? (evita arrastrarse décimas de píxel durante segundos)
static func is_stopped(velocity: Vector2, minimum: float) -> bool:
	return velocity.length() < minimum


## Velocidad del dedo en px/s a partir de lo que se movió en `dt` segundos. `dt` se acota por abajo (8 ms)
## para que dos eventos del mismo cuadro no den una velocidad disparatada.
static func finger_velocity(relative: Vector2, dt: float) -> Vector2:
	return relative / maxf(dt, 0.008)
