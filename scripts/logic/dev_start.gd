# Cuentas del modo de pruebas para "empezar en la oleada N" (spec RF-319, RF-320, D-048).
# Sin escenas (P10): solo lee los datos del nivel y del balance, así se prueba sin abrir ventanas.
class_name DevStart
extends RefCounted

## Tope de generaciones de crías al sumar recompensas (un dato mal armado no cuelga el juego).
const MAX_SPAWN_DEPTH: int = 8


## RF-319: la oleada inicial que se usa de verdad: entre 1 y el total del nivel.
static func clamp_wave(wave: int, total_waves: int) -> int:
	return clampi(wave, 1, maxi(total_waves, 1))


## Oro que da matar a un enemigo de este tipo, contando las crías que suelta al morir (RF-166).
static func enemy_reward(enemy: EnemyData, depth: int = 0) -> int:
	if enemy == null:
		return 0
	var total: int = enemy.reward
	if enemy.death_spawn != null and enemy.death_spawn_count > 0 and depth < MAX_SPAWN_DEPTH:
		total += enemy.death_spawn_count * enemy_reward(enemy.death_spawn, depth + 1)
	return total


## RF-320: oro de las oleadas 1 a `wave - 1`: lo que da cada enemigo (con sus crías) más el bono de cada oleada.
static func skipped_gold(level: LevelData, balance: BalanceConfig, wave: int) -> int:
	var total: int = 0
	var last: int = mini(wave - 1, level.waves.size())
	for index: int in last:
		for group: SpawnGroup in level.waves[index].groups:
			total += group.count * enemy_reward(group.enemy)
		total += Rules.wave_bonus(index + 1, balance)
	return total


## RF-320: el oro con el que arranca la partida. `manual` negativo = automático
## (oro del nivel + lo de las oleadas saltadas); desde 0 es el valor elegido a mano.
static func start_gold(level: LevelData, balance: BalanceConfig, wave: int, manual: int = -1) -> int:
	if manual >= 0:
		return manual
	return level.starting_gold + skipped_gold(level, balance, wave)
