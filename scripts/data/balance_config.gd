# Reglas generales que valen para todos los niveles.
# Los porcentajes son ENTEROS (70 = 70 %) para que las cuentas no tengan errores
# de redondeo: con decimales, 110 × 0.7 puede dar 76.999… y redondear a 76 (D-013).
class_name BalanceConfig
extends Resource

## Bono fijo al terminar una oleada (RF-22).
@export var wave_bonus_base: int = 0
## Bono extra por número de oleada (RF-22).
@export var wave_bonus_per_wave: int = 0
## Porcentaje del oro invertido que se devuelve al vender (RF-72).
@export_range(0, 100) var sell_refund_percent: int = 0
## Segundos de cuenta atrás entre oleadas (RF-34).
@export var countdown_seconds: float = 0.0
## Porcentaje de vida extra que gana cada enemigo por cada oleada (RF-36).
@export var health_scale_percent_per_wave: int = 0
## RF-93: % de las vidas iniciales que hay que conservar para ganar 3 estrellas.
@export_range(0, 100) var star_3_lives_percent: int = 0
## RF-93: % de las vidas iniciales que hay que conservar para ganar 2 estrellas.
@export_range(0, 100) var star_2_lives_percent: int = 0
## RF-190: puntos por cada moneda de oro que vale un enemigo al morir.
@export var points_per_gold: int = 0
## RF-190: puntos por cada vida que queda al ganar.
@export var points_per_life: int = 0
