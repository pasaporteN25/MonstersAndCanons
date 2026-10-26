# Las reglas de la presentación de los jefes (M66, RF-666 a RF-673, D-187 a D-191). Puras: sin escena ni guardado
# (P10), así se prueban sin abrir ventanas. Quien las usa (`Game`) junta los datos y la escena `BossPresentation` los muestra.
#
# Los segundos son de interfaz (cuánto tarda la secuencia en la pantalla), no de balance: la partida está pausada
# mientras dura y el resultado no cambia (D-188).
class_name BossPresentationRules
extends RefCounted

## RF-668: la primera vez que se ve un tipo de jefe en ese guardado.
const FIRST_SECONDS: float = 5.0
## RF-668: las veces siguientes.
const REPEAT_SECONDS: float = 3.0
## RF-669: hasta acá (tiempo real) las entradas se tragan y no saltean, para que el clic que ya estaba en camino no la cierre.
const SKIP_LOCK_SECONDS: float = 0.3
## RF-669: el fundido de salida al saltear.
const FADE_OUT_SECONDS: float = 0.15


## RF-668: cuánto dura. `seen_before` sale de `SaveManager.has_seen_enemy`, que hay que consultar ANTES de marcarlo visto.
static func seconds(seen_before: bool) -> float:
	return REPEAT_SECONDS if seen_before else FIRST_SECONDS


## RF-669: ¿ya se puede saltear? `elapsed` es tiempo real (no depende de ×1 ni ×2).
static func can_skip(elapsed: float) -> bool:
	return elapsed >= SKIP_LOCK_SECONDS


## RF-666: ¿corresponde presentar a este enemigo? Se pasan ya resueltas las condiciones que dependen del juego:
## `dangerous` (RF-135), `option_on` (RF-672), `normal_campaign` (campaña jugada desde el menú: no Asedio, ni modo de
## pruebas, ni editor, ni comunidad, ni escena suelta) y `already_shown` (una sola vez por partida).
static func is_eligible(dangerous: bool, option_on: bool, normal_campaign: bool, already_shown: bool) -> bool:
	return dangerous and option_on and normal_campaign and not already_shown


## RF-667, RF-673: ¿la partida se reanuda al cerrarse? Solo si no estaba en pausa antes, no pasó a segundo plano
## y no se pidió dejarla en pausa (`P` o «Atrás»).
static func should_resume(was_paused_before: bool, interrupted_by_background: bool, keep_paused: bool) -> bool:
	return not was_paused_before and not interrupted_by_background and not keep_paused
