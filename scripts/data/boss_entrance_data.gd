# La entrada de un jefe (M66, RF-601, D-139): un dato opcional que cuelga de `EnemyData.entrance`.
# Un enemigo sin `entrance` no hace entrada. El retrato, el nombre y el color del destello salen del propio
# enemigo; acá solo se elige en qué niveles sale, qué frase dice y si suena algo. No define animaciones ni
# condiciones (sería armar un lenguaje de scripts, P4): qué hace la animación es del código.
class_name BossEntranceData
extends Resource

## Largo máximo de la frase propia del cartel.
const MAX_LINE_CHARS: int = 80

## Ids de los niveles donde sale. Vacía = en todos.
@export var levels: PackedStringArray = PackedStringArray()
## Frase del cartel. Vacía = se usa `EnemyData.description`.
@export var line: String = ""
## Id de un sonido que ya existe en `Audio`. Vacío = ninguno.
@export var sound: StringName = &""
