# 02 — Plan técnico (el "CÓMO")

> **Qué es este documento:** explica **cómo** se construye en Godot lo que pide [`01-spec.md`](01-spec.md): la configuración, las carpetas, las escenas, los scripts y cómo se comunican.
>
> **Regla:** este documento **no inventa reglas del juego**. Si al programar descubres que falta una regla, se agrega primero a la spec (constitución P3).

---

## 1. Tecnología

| Qué | Elección | Nota |
|---|---|---|
| Motor | **Godot 4.x**, versión estable más reciente (mínimo **4.3**) | La 4.3 introdujo `TileMapLayer`, que usamos para el mapa. Al instalarlo, anotar la versión exacta en el README. |
| Lenguaje | **GDScript** con tipos estáticos | Constitución P5. |
| Tests | **GUT** (Godot Unit Test), se instala desde la AssetLib del editor | Constitución P10. |
| Control de versiones | **Git** | `.gitignore` estándar de Godot (ignora la carpeta `.godot/`). |

---

## 2. Configuración del proyecto (`project.godot`)

Se configura desde **Proyecto → Configuración del proyecto**:

| Ajuste | Valor | Por qué |
|---|---|---|
| `display/window/size/viewport_width` × `height` | **1280 × 720** | Resolución base 16:9. |
| `display/window/stretch/mode` | `canvas_items` | Si la ventana se agranda, todo se escala proporcionalmente. |
| `display/window/stretch/aspect` | `keep` | Mantiene la proporción (agrega bandas negras si hace falta, no deforma). |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` | Evita que los bordes se vean borrosos al escalar. |
| **Nombres de capas 2D físicas** | 1 = `world`, 2 = `enemies_ground`, 3 = `enemies_air` | Reservadas; por ahora no se usan (D-014). |
| **Mapa de entrada** (*Input Map*) | `build_1`…`build_4`, `cancel`, `start_wave`, `pause`, `toggle_speed`, `upgrade`, `sell` | Nunca se leen teclas "a mano" (`KEY_1`); se usan **acciones**. Así cambiar una tecla es cambiar un ajuste, no el código. |

### Distribución de la pantalla (1280 × 720)

```
┌──────────────────────────────────────────────┐  y = 0
│  HUD superior: Oro · Vidas · Oleada 3/10     │  48 px
├──────────────────────────────────────────────┤  y = 48
│                                              │
│        MAPA: 20 × 9 casillas de 64 px        │  576 px
│              (1280 × 576)                    │
│                                              │
├──────────────────────────────────────────────┤  y = 624
│  HUD inferior: [Torre1][Torre2][Torre3] ...  │  96 px
│                         [Empezar oleada] x1  │
└──────────────────────────────────────────────┘  y = 720
```

El nodo del mapa se coloca en `position = (0, 48)`.

---

## 3. Estructura de carpetas

```
JuegoA/
├── README.md
├── specs/                        ← estos documentos
├── project.godot
├── .gitignore
├── addons/
│   └── gut/                      ← herramienta de tests (se instala)
│
├── scenes/                       ← escenas (.tscn) CON su script (.gd) al lado
│   ├── game/
│   │   ├── game.tscn / game.gd               ← la partida (orquesta todo)
│   │   ├── level_session.gd                  ← oro, vidas, estado de la partida
│   │   ├── wave_spawner.gd                   ← hace salir a los enemigos
│   │   ├── build_controller.gd               ← vista previa y construcción
│   │   └── hud.tscn / hud.gd                 ← interfaz de la partida
│   ├── levels/
│   │   ├── level.gd                          ← script común a todos los mapas
│   │   └── level_decor.gd                    ← decoración dibujada por código (M1.5)
│   │       (M7: no hay escenas de mapa; Level.build() arma el mapa desde el JSON)
│   ├── towers/
│   │   ├── tower.tscn / tower.gd             ← UNA escena para TODAS las torres
│   │   ├── projectile.tscn / projectile.gd
│   │   └── tower_panel.tscn / tower_panel.gd ← (M2) panel mejorar/vender
│   ├── effects/
│   │   └── effects_layer.gd, ring_effect.gd, burst_effect.gd, floating_text.gd  ← (M1.5)
│   ├── enemies/
│   │   └── enemy.tscn / enemy.gd             ← UNA escena para TODOS los enemigos
│   └── ui/                                   ← (M3) menús
│       ├── main_menu, level_select, options, pause_menu, end_screen
│
├── scripts/                      ← scripts que NO son escenas
│   ├── data/                     ← definiciones de los tipos de datos (Resources)
│   │   ├── tower_data.gd, tower_level_data.gd
│   │   ├── enemy_data.gd
│   │   ├── spawn_group.gd, wave_data.gd, level_data.gd
│   │   └── balance_config.gd
│   ├── logic/
│   │   ├── rules.gd              ← fórmulas puras (daño, venta, bono…) → se testean
│   │   ├── map_grid.gd           ← (M7) lee el mapa de letras y calcula los recorridos
│   │   └── level_file.gd         ← (M7) lee el JSON de un nivel y de la campaña
│   └── autoload/                 ← (M3) globales
│       ├── save_manager.gd, game_flow.gd, audio.gd
│
├── data/                         ← LOS NÚMEROS DEL JUEGO (archivos .tres)
│   ├── balance.tres              ← reglas generales (bono de oleada, % de venta…)
│   ├── towers/   basic.tres, cannon.tres, frost.tres, sniper.tres
│   ├── enemies/  normal.tres, fast.tres, tank.tres, flyer.tres, armored.tres, boss.tres
│   ├── campaign.json             ← (M7) los niveles en orden
│   └── levels/   level_01.json … level_06.json   ← (M7) mapa de letras + oleadas (spec §7.8)
│
├── assets/
│   ├── tiles/    tiles.png, tileset.tres   ← casillas provisionales (M1)
│   └── ...                     ← (M3/M4) sonidos, imágenes, fuentes
├── tools/
│   ├── balance_sim.gd            ← bot que juega solo para revisar el balance (spec §7.1)
│   └── perf_test.gd              ← prueba de rendimiento con ventana (T56, P7)
└── tests/
    ├── test_rules.gd
    ├── test_level_paths.gd
    └── test_save_manager.gd      ← (M3)
```

**Diferencia clave entre `scripts/data/` y `data/`:**
- `scripts/data/enemy_data.gd` dice **qué campos** tiene un enemigo (vida, velocidad…). Es el "molde".
- `data/enemies/tank.tres` dice **los valores** de un enemigo concreto (vida 90, velocidad 0.8…). Es "lo que sale del molde".

---

## 4. Datos del juego (Resources)

Un **Resource** es una clase de datos que Godot sabe guardar como archivo `.tres` y mostrar en el **Inspector**. Así los números se editan con el mouse, sin tocar código (constitución P2).

### 4.1 Las clases de datos

Cada clase es un script en `scripts/data/`. **El código real es la referencia**; aquí solo se resume qué representa cada una:

| Clase | Archivo | Representa |
|---|---|---|
| `TowerLevelData` | [`tower_level_data.gd`](../scripts/data/tower_level_data.gd) | Los valores de **un nivel** de una torre: costo, daño, cadencia, alcance, dibujo de la base y sus **comportamientos** (área, ralentización y, desde M5, quemadura, varios objetivos, ráfaga y rayo en cadena). |
| `TowerData` | [`tower_data.gd`](../scripts/data/tower_data.gd) | Un tipo de torre: nombre, frase, si golpea voladores, color, dibujos (torreta y proyectil) y su lista de niveles (índice 0 = nivel 1). |
| `EnemyData` | [`enemy_data.gd`](../scripts/data/enemy_data.gd) | Un tipo de enemigo: vida, velocidad, armadura, oro, vidas que quita, si vuela, resistencia a ralentizar, dibujo (y forma y color de respaldo) y, desde M5, regeneración y crías al morir. |
| `SpawnGroup` | [`spawn_group.gd`](../scripts/data/spawn_group.gd) | "N enemigos de tipo X, cada S segundos, empezando T segundos después, por la entrada E" (RF-31). |
| `WaveData` | [`wave_data.gd`](../scripts/data/wave_data.gd) | Una oleada = lista de `SpawnGroup`. |
| `LevelData` | [`level_data.gd`](../scripts/data/level_data.gd) | Un nivel: mapa (desde M7, las 9 filas de letras: `map_rows`), oro y vidas iniciales, lista de oleadas. Ya no es un `.tres`: lo crea `LevelFile` al leer el JSON. `build_map()` devuelve el `Level` armado. |
| `BalanceConfig` | [`balance_config.gd`](../scripts/data/balance_config.gd) | Reglas generales: bono de oleada, % de venta, cuenta atrás, % de vida por oleada. Sus valores están en `data/balance.tres`. |

**Comportamientos como datos (M5, D-025):** cada comportamiento especial es un campo que vale 0 cuando no se usa. El código pregunta por el comportamiento ("¿quema?"), nunca por la torre o el enemigo ("¿es la Incendiaria?"). Así se combinan libremente y el contenido nuevo no necesita código. La guía [`CONTENIDO.md`](../CONTENIDO.md) explica cada campo.

**Dos reglas para todas las clases de datos:**

1. **Los valores por defecto de balance son `0`** (o vacío). Los números reales viven **solo** en los `.tres` (constitución P2). Además, Godot **no escribe** en el `.tres` un valor igual al de por defecto; si el default fuera `5`, el archivo no lo mostraría y dependería en silencio del código.
2. **Los porcentajes usados en cuentas con enteros se guardan como enteros** (`70` = 70 %), no como decimales (`0.7`). Motivo: en la computadora `0.7` es en realidad 0,69999…, y `170 × 0.7` da 118,99999 → al redondear hacia abajo, **118 en vez de 119**. Ver D-013.

### 4.2 Unidades: casillas en los datos, píxeles en el código

Los datos usan **casillas** porque son fáciles de imaginar ("alcance 3 casillas"). El código convierte a píxeles en un solo lugar:

```gdscript
# scripts/logic/rules.gd
const TILE_SIZE: float = 64.0

static func tiles_to_px(tiles: float) -> float:
    return tiles * TILE_SIZE
```

`TILE_SIZE` **no** es un número de balance (no cambia cómo se juega), así que puede vivir en el código.

### 4.3 Fórmulas puras (`rules.gd`)

Todas las fórmulas de la spec viven en [`scripts/logic/rules.gd`](../scripts/logic/rules.gd), como funciones `static` que **no tocan ningún nodo**. Eso las hace fáciles de testear (P10); sus tests están en [`tests/test_rules.gd`](../tests/test_rules.gd).

| Función | Regla |
|---|---|
| `tiles_to_px(tiles)` | Casillas → píxeles (§4.2). |
| `damage_after_armor(damage, armor)` | RF-80. |
| `scaled_health(base, wave_number, cfg)` | RF-36. |
| `wave_bonus(wave_number, cfg)` | RF-22. |
| `sell_refund(total_invested, cfg)` | RF-72. |
| `effective_slow(slow_amount, resistance)` | RF-60 y resistencia del Jefe. |

---

## 5. La escena de la partida

### 5.1 Árbol de nodos de `game.tscn`

```
Game (Node2D)                        game.gd       ← el "director": crea y conecta todo
├── Level (el mapa)                 level.gd      ← lo arma LevelData.build_map() (M7)
│   ├── Ground (TileMapLayer)                      ← las casillas que se ven
│   ├── Entrances (Node2D)
│   │   ├── GroundPath0 (Path2D)                   ← camino terrestre de la entrada 0
│   │   └── AirPath0 (Path2D)                      ← (M2) línea recta para voladores
│   └── Decor (Node2D)               level_decor.gd ← pasto, bordes, rocas (M1.5)
├── Towers (Node2D)                                ← contenedor de torres
├── Enemies (Node2D)                               ← contenedor de enemigos
├── Projectiles (Node2D)                           ← contenedor de proyectiles
├── Effects (Node2D)                 effects_layer.gd  ← efectos visuales (M1.5, spec §9.3)
├── BuildController (Node2D)         build_controller.gd
├── WaveSpawner (Node)               wave_spawner.gd
├── Session (Node)                   level_session.gd
├── HUD (CanvasLayer)                hud.gd
└── EndScreen (CanvasLayer)          end_screen.gd  ← victoria / derrota (T24)
```

**Por qué contenedores separados:** para poder recorrer "todos los enemigos" o "todas las torres" fácilmente, y para controlar qué se dibuja encima de qué (los proyectiles por encima de los enemigos, etc.).

### 5.2 Quién hace qué

| Nodo | Responsabilidad | NO hace |
|---|---|---|
| **Game** | Carga el nivel. **Conecta las señales** entre todos. Agrega los proyectiles a su contenedor. Al ganar o perder, congela el "mundo" y muestra `EndScreen`. | No calcula daño ni lleva la cuenta del oro. |
| **Level** | Sabe qué casillas son construibles y dónde están los caminos. | No sabe nada de torres ni enemigos. |
| **Session** | Guarda oro, vidas, oleada actual y estado (`BUILDING`, `WAVE_RUNNING`, `COUNTDOWN`, `WON`, `LOST`). Avisa con señales cuando algo cambia. | No dibuja nada. |
| **WaveSpawner** | Recorre los grupos de la oleada y crea enemigos a su tiempo. Avisa cuando la oleada termina. | No da oro ni resta vidas. |
| **BuildController** | Vista previa verde/roja, validar casilla, pedir construir. Registro de casillas ocupadas. | No descuenta el oro él mismo (se lo pide a Session). |
| **Tower** | Busca objetivo en su alcance, dispara según su cadencia. | No sabe dónde está el contenedor de proyectiles: **emite** `fired`. |
| **Enemy** | Avanza por su camino, recibe daño, se ralentiza, muere o escapa. | No suma oro ni resta vidas: **emite** `died` / `reached_exit`. |
| **Projectile** | Persigue al objetivo y aplica el daño al llegar. | — |
| **HUD** | Muestra datos y botones. Al pulsar un botón, **emite** una señal. | No cambia el oro ni construye nada directamente. |

### 5.3 Cómo se comunican (señales)

Constitución P6: **señales hacia arriba, llamadas hacia abajo**. `Game` es el único que conecta a unos con otros.

```
                       ┌────────────┐
      oro/vidas ◄──────┤  Session   │──── gold_changed, lives_changed ────► HUD
      cambian          └─────▲──────┘     wave_changed, state_changed
                             │ earn(), lose_lives(), spend()
                             │
                       ┌─────┴──────┐
                       │    Game    │  (conecta todo en _ready)
                       └─────▲──────┘
          died(reward) │     │     │ fired(projectile)
      reached_exit(n)  │     │     │
                 ┌─────┴─┐ ┌─┴─────┴─┐ ┌─────────────┐
                 │ Enemy │ │  Tower  │ │ WaveSpawner │── wave_finished ──► Game
                 └───────┘ └─────────┘ └─────────────┘
```

Ejemplo del código de `Game` conectando un enemigo recién creado:

```gdscript
func _on_enemy_spawned(enemy: Enemy) -> void:
    enemy.died.connect(_on_enemy_died)
    enemy.reached_exit.connect(_on_enemy_reached_exit)

func _on_enemy_died(enemy: Enemy) -> void:
    session.earn(enemy.data.reward)

func _on_enemy_reached_exit(enemy: Enemy) -> void:
    session.lose_lives(enemy.data.lives_damage)
```

### 5.4 El ciclo de una partida (máquina de estados de `Session`)

```
 ┌──────────┐  pulsar "Empezar oleada"   ┌──────────────┐
 │ BUILDING │ ─────────────────────────► │ WAVE_RUNNING │ ◄────────────┐
 └──────────┘                            └──────┬───────┘              │
                          vidas = 0 ◄───────────┤                      │
                              │                 │ oleada terminada     │ cuenta atrás = 0
                              ▼                 ▼ (RF-33) + bono       │ o pulsar botón
                         ┌────────┐     ¿era la última? ──no──► ┌───────────┐
                         │  LOST  │             │                │ COUNTDOWN │
                         └────────┘             sí               └───────────┘
                                                ▼
                                           ┌────────┐
                                           │  WON   │
                                           └────────┘
```

Se construye en **cualquier** estado excepto `WON`, `LOST` y pausa (RF-44, RF-104).

---

## 6. Piezas en detalle

### 6.1 El mapa (`Level`)

- **`Ground` es un `TileMapLayer`** con un `TileSet` de casillas de 64×64. Al `TileSet` se le agrega una **capa de datos personalizada** (*custom data layer*) llamada `buildable` de tipo `bool`:
  - casilla libre → `buildable = true`;
  - camino y bloqueada → `buildable = false`.
- **Consultar una casilla:**
  ```gdscript
  func is_buildable(cell: Vector2i) -> bool:
      var tile: TileData = ground.get_cell_tile_data(cell)
      return tile != null and tile.get_custom_data("buildable")
  ```
  (Si la casilla está vacía o fuera del mapa, `tile` es `null` → no construible.)
- **Convertir entre píxeles y casillas:** `ground.local_to_map(pos)` y `ground.map_to_local(cell)` (esta última devuelve el **centro** de la casilla).
- **Los caminos son `Path2D`**: cada entrada tiene su `GroundPathN` (sigue el camino de casillas) y, desde M2, su `AirPathN` (solo dos puntos: entrada y salida).
- **Desde M7 el mapa se arma al vuelo** (spec §7.8, D-031): [`MapGrid`](../scripts/logic/map_grid.gd) lee las letras y calcula, con una búsqueda a lo ancho (BFS) desde la salida, la distancia de cada casilla de camino a la salida. El recorrido de una entrada avanza siempre a la vecina que está un paso más cerca; si hay **dos** vecinas así, hay dos recorridos igual de cortos y el mapa es inválido. El recorrido se resume en sus **esquinas**. `Level.build(grid)` crea el `Ground` (una casilla del `TileSet` por letra), un `GroundPathN` por entrada (centros de las esquinas; el primer punto, y el último si la salida está en el borde, se corren una casilla hacia afuera), su `AirPathN` (primer y último punto) y el `Decor`.
- **`LevelFile`** ([`level_file.gd`](../scripts/logic/level_file.gd)) lee el JSON (`JSON.parse_string`), revisa cada clave y cada número, y devuelve `{level, errors}`. Nunca lanza errores: la campaña saltea un nivel inválido y lo anota con `push_error`. Los enemigos se buscan como `res://data/enemies/<nombre>.tres`.
- ⚠️ **El camino se "dibuja" dos veces**: con casillas (lo que se ve) y con `Path2D` (lo que siguen los enemigos). Si no coinciden, los enemigos caminarían por el pasto. Por eso hay un **test** (`test_level_paths.gd`) que recorre cada `GroundPath` y comprueba que cada punto cae sobre una casilla **no** construible.

### 6.2 Enemigos ([`enemy.gd`](../scenes/enemies/enemy.gd))

- **Nodo raíz:** `Node2D`. No necesita colisiones: las torres lo encuentran midiendo distancias (§6.3, D-014).
- **Se dibuja** en `_draw()` con su dibujo (`data.texture`, en espejo si camina hacia la izquierda, RF-151) o, si no tiene, con su forma geométrica (RF-156). Encima: la barra de vida (RF-82), la corona si es peligroso (RF-136) y llamitas si se quema (RF-158). Ralentizado se tiñe de celeste; al recibir un golpe se le superpone una silueta blanca (`EnemyShape.flash_texture()`).
- **Estados (M5):** quemadura (`apply_burn()`, golpecitos cada 0,5 s que ignoran la armadura) y regeneración (si `data.regen_percent_per_second` > 0 y no se está quemando). Avisa lo curado con `healed`, como mucho una vez por segundo.
- **Cómo avanza:** guarda cuántos píxeles lleva recorridos (`distance`) y le pregunta a la curva del `Path2D` dónde está ese punto. Cuando `distance` supera el largo de la curva, llegó a la salida.

  **Por qué así y no con `PathFollow2D`:** `PathFollow2D` obliga a crear un nodo extra por cada enemigo y a meter al enemigo *dentro* del camino. Guardar la distancia a mano es igual de simple, funciona igual para voladores y deja a todos los enemigos juntos en el contenedor `Enemies`. Además, `remaining_distance()` (lo que le falta para llegar) sale directo, y es justo lo que se necesita para apuntar al "Primero".
- **Recibir golpes:** `take_hit(damage, slow_amount, slow_duration)` aplica la armadura (RF-80) y la ralentización (RF-60, RF-61).
- **`is_active()`:** después de morir o escapar, el enemigo llama a `queue_free()`, pero Godot lo borra recién al final del frame. Mientras tanto, `is_active()` devuelve `false` para que nadie lo apunte ni lo cuente dos veces.
- **Grupo:** cada enemigo se agrega al grupo `"enemies"`. Así las torres y el daño en área pueden recorrer todos los enemigos.
- **Señales:** `died(enemy)`, `reached_exit(enemy)`, `hit(enemy, daño, armadura)` y `healed(enemy, cantidad)` (estas dos, solo para efectos).

### 6.3 Torres: detectar y apuntar ([`tower.gd`](../scenes/towers/tower.gd))

- **Una sola escena `tower.tscn`** para todas las torres. Al crearla se le asigna su `TowerData`, y con eso sabe su color, daño, alcance, etc.
- **Detectar (D-014):** cuando la torre puede disparar, recorre el grupo `"enemies"` y se queda con los que cumplen `can_target()`: activos, a una distancia (centro a centro) menor o igual a su alcance y, si vuelan, solo si la torre puede golpear voladores (RF-53).

  > **Por qué no `Area2D`**, como decía la primera versión de este plan: las áreas de colisión de Godot se actualizan solo en frames de física reales, y los tests simulan el tiempo más rápido que eso, así que las torres no "verían" a nadie en los tests. Medir distancias es más simple, igual de correcto y fácil de testear. Costo: ~36.000 cálculos por segundo con 60 torres y 200 enemigos, poco para una computadora; se mide en T39.
- **Elegir objetivo** según el modo (RF-51, RF-54):
  - *Primero* → menor `remaining_distance()` *(el único en M1)*;
  - *Último* → mayor `remaining_distance()`;
  - *Más fuerte* → mayor `health`;
  - *Más cercano* → menor distancia a la torre.
- **Cadencia:** un contador `_cooldown` que baja con `delta`; cuando llega a 0 y hay objetivo, dispara y se reinicia a `1.0 / fire_rate`. Si no hay objetivo, el contador se queda en 0 y dispara apenas entra un enemigo. (Con `delta`, la pausa y la velocidad x2 funcionan solas.)
- **Disparar:** la torre crea el proyectil y **emite** `fired(projectile)`; `Game` lo agrega al contenedor `Projectiles`. Con `extra_targets` dispara a sus N mejores objetivos a la vez (`find_targets()`, RF-161); con `burst_count` lanza púas en círculo si hay alguien en alcance (`_fire_burst()`, RF-162).

### 6.4 Proyectiles ([`projectile.gd`](../scenes/towers/projectile.gd))

- Se mueven hacia el objetivo a `projectile_speed_tiles` (RF-55). Si el objetivo ya no está activo, siguen hacia la última posición conocida (RF-52).
- **Al llegar** (cuando el paso de este frame alcanza para tocar el destino):
  - **Sin área:** golpea al objetivo si sigue activo; si no, desaparece sin hacer daño.
  - **Con área:** golpea a todos los enemigos activos del grupo `"enemies"` dentro del radio (y a los voladores solo si la torre puede golpearlos).
- Guardan los valores de la torre **en el momento del disparo**, así una mejora (M2) no cambia proyectiles ya disparados.
- **Al golpear** (`_hit()`): aplica daño y ralentización, y la quemadura si la torre la tiene (RF-160). Si la torre tiene `chain_extra_targets`, desde el golpeado salta al enemigo más cercano que todavía no golpeó (`_chain_from()`, RF-163) y avisa `chained(puntos)` para el efecto del rayo.
- **Modo en línea recta** (`setup_straight()`, RF-162): no persigue a nadie; avanza hasta su distancia máxima y golpea al primer enemigo que toca.

### 6.5 Oleadas ([`wave_spawner.gd`](../scenes/game/wave_spawner.gd))

- `start_wave(wave, wave_number)` prepara los grupos de esa oleada. En `_process(delta)` lleva un reloj propio y, para cada grupo, crea un enemigo cuando le toca (`start_delay`, luego cada `interval`).
- Lleva la cuenta de enemigos **vivos** (escucha `tree_exited` de cada uno, que salta tanto si muere como si escapa). Cuando ya salieron todos y los vivos llegan a 0 → emite `wave_finished` (RF-33).
- **Por qué un reloj con `delta` y no `Timer`s o `await`:** con `delta`, la pausa y la velocidad x2 funcionan sin código extra, y no quedan temporizadores "colgando" si se reinicia el nivel.
- La vida de cada enemigo se calcula al crearlo con `Rules.scaled_health(...)` (RF-36).
- **Crías (M5, RF-166):** si un enemigo tiene `death_spawn`, el generador escucha su `died` y crea las crías en su lugar, sobre el mismo camino. Como las suma a los vivos **antes** de que la madre deje el árbol, la oleada no termina antes de tiempo.

### 6.6 Construcción ([`build_controller.gd`](../scenes/game/build_controller.gd))

- Guarda `_occupied: Dictionary` → `{ Vector2i (casilla): Tower }`.
- `select(index)` entra en **modo construcción** (desde un botón del HUD o las teclas 1–3). Elegir la misma torre otra vez, clic derecho o `Esc` lo cancelan.
- Cada frame: pasa el mouse a casilla y dibuja la casilla verde o roja según `can_build()`, la torre fantasma y el círculo de alcance (RF-40, RF-41).
- `can_build(tower, cell)`: la partida no terminó, la casilla es construible, no está ocupada y alcanza el oro (RF-42).
- `try_build(tower, cell)`: si se puede, cobra, **crea la torre** en el contenedor `Towers` y emite `tower_built(tower)`; `Game` la conecta. (La primera versión del plan decía que la creaba `Game`; se movió aquí porque así la casilla se marca ocupada en el mismo lugar donde se crea la torre, y no pueden quedar desincronizadas.)

### 6.7 Pausa y velocidad *(M2)*

- **Pausa:** `get_tree().paused = true`. El `HUD` tiene `process_mode = PROCESS_MODE_ALWAYS` para seguir respondiendo; todo lo demás se congela solo.
- **Velocidad x2:** `Engine.time_scale = 2.0`. Como todo usa `delta`, todo va al doble.
- ⚠️ **Siempre** volver a `Engine.time_scale = 1.0` y `paused = false` al salir de la partida (reintentar, ir al menú). Si no, el menú quedaría acelerado o congelado.

### 6.8 El editor de mapas *(M9, spec §10.3)*

Solo existe en el modo de pruebas (`DevMode.enabled`): el botón del menú principal está oculto si no. Está hecho en capas, de la más pura a la más visual, como el resto del juego (constitución P6):

| Pieza | Archivo | Qué hace | Qué NO sabe |
|---|---|---|---|
| `LevelDraft` | [`level_draft.gd`](../scripts/logic/level_draft.gd) | El nivel que se edita, **en el mismo formato del archivo** (§7.8): pintar casillas, entradas y salida; ajustes; oleadas; deshacer/rehacer; texto; guardar y abrir. Lógica pura: se prueba sin pantallas. | Nada de pantallas. Tampoco las reglas de los mapas: para revisar usa `LevelFile.parse(to_text())`. |
| `MapView` | [`map_view.gd`](../scenes/editor/map_view.gd) | Dibuja el mapa con el **mismo suelo y decoración que la partida** (`Level.make_ground` y `LevelDecor`) y, encima, los recorridos (franjas anidadas), las letras y las casillas sin usar. | Cómo se edita. |
| `MapEditor` | [`map_editor.gd`](../scenes/editor/map_editor.gd) | La pantalla: mouse (trazos con interpolación entre casillas), teclas, botones, mensajes, y los flujos de Nuevo/Abrir/Guardar/Probar/Salir. | Las reglas: pregunta a `LevelDraft.check()`. |
| `EditorPanel` → `SettingsPanel`, `WavesPanel` | [`scenes/editor/`](../scenes/editor/) | Los paneles de ajustes y de oleadas. Editan el borrador y avisan con `edited`. | Cómo se revisa el nivel. |
| `EditorDialog` | [`editor_dialog.gd`](../scenes/editor/editor_dialog.gd) | Confirmar, pedir un nombre (validado mientras se escribe) o elegir de una lista. | Qué se hace después: solo emite `accepted` o `cancelled`. |

**Decisiones de fondo**
- **Un solo modelo.** El borrador es el JSON del nivel (un `Dictionary`). Lo que se edita, lo que se guarda y lo que valida `LevelFile` son lo mismo, así no hay dos representaciones que mantener alineadas. Un test abre cada nivel oficial y lo vuelve a escribir: da **exactamente el mismo texto**.
- **Deshacer con fotos.** Cada cambio guarda una copia del `Dictionary` (hasta 50). Un trazo del mouse es **un** paso: `begin_stroke()` saca la foto y solo el primer cambio real la guarda.
- **Los paneles no se reconstruyen al editar un número**, para no perder el foco del campo (se puede seguir con `Tab`). Solo se reconstruyen al cambiar la estructura (agregar o quitar un grupo) o después de deshacer.
- **Las señales `left` y `test_requested`** hacen de "costura": en el juego se conectan a `GameFlow`; en los tests se desconectan, porque cambiar de escena reemplazaría la de GUT.
- **Probar:** `GameFlow.test_level` (un `LevelData` armado con `LevelFile`) hace que `Game` juegue ese nivel con `testing = true`: no guarda progreso ni récords y los botones de salida vuelven al editor. El borrador vive en `GameFlow.editor_draft`, así sobrevive al cambio de escena.
- **Guarda en `user://maps/`** (`maps_dir` en el editor, para que los tests usen otra carpeta). Un `.exe` exportado no puede escribir en `res://`.
- ⚠️ **Herramientas y autoloads:** un script de `tools/` corre con `-s` **antes** de que existan los autoloads. Si tipa una variable con una clase que usa `GameFlow` o `DevMode` (por ejemplo `MapEditor`), no compila: usar `Node` y llamar sin tipos.
- ⚠️ **`_init` en clases hijas de GDScript:** si la clase hija define su `_init`, el de la base **no se llama solo**: hay que escribir `super()` (`EditorPanel` lo necesita).

### 6.9 Los mapas de la comunidad *(M10, spec §10.4, D-034)*

- [`CommunityMaps`](../scripts/logic/community_maps.gd) (lógica pura) lista los `.json` de `user://maps/` y devuelve, por archivo, `{file, id, level, errors, warnings}`. Lee cada uno con `LevelFile.parse(texto, id)`, con el id `comunidad_<archivo>`. Un archivo roto, con nombre no válido o de más de 200 KB es una entrada con su motivo (y el grande **ni se lee**); se leen hasta 200 archivos.
- **Es la misma carpeta que usa el editor** (`LevelDraft.MAPS_DIR`): un test comprueba que las dos constantes coinciden.
- **Progreso aparte, sin tocar `SaveManager`:** el guardado ya es genérico por id (`record_victory`, `add_score`), así que solo hizo falta el prefijo `comunidad_` para que un archivo llamado `level_03.json` o `hall_of_fame.json` no se confunda con lo oficial.
- `GameFlow`: `current_community` (el mapa que se juega), `played_level()` (el nivel cuyo progreso se guarda: el de la campaña o el de la comunidad), `start_community()`, `community_stars()` y `select_page` (la solapa en la que se estaba, para volver a ella). `level_won`, los récords y la partida (`Game`) usan `played_level()`. Lo que **no** usa `played_level()` es a propósito: el desbloqueo, el total de estrellas y el Salón de la fama miran solo la campaña.
- `LevelSelect` tiene dos solapas y **vuelve a buscar** los mapas cada vez que se abre. `community_dir` y `folder_opener` son "costuras" para los tests (otra carpeta, y un abridor falso que no abre ventanas).
- **Los límites** (`LevelFile.MAX_*`) se comparan como decimal **antes** de convertir a entero (un `1e300` no desborda) y el editor los respeta (`LevelDraft` recorta y devuelve `-1`/`false` al llegar al máximo).
- ⚠️ **Windows y los nombres reservados:** `con`, `nul`, `com1`… no se pueden crear como archivo en Windows. Un mapa con ese nombre no llega a existir; y un test con `con.punto.json` falló por eso.

---

## 7. Globales (autoloads) — solo desde M3

En M1 y M2 **no hay autoloads**: todo el estado vive dentro de la escena de la partida, así "Reintentar" es simplemente recargar la escena y todo empieza limpio.

En M3 se agregan tres, porque hay datos que deben **sobrevivir** al cambiar de escena:

| Autoload | Para qué |
|---|---|
| `GameFlow` ([código](../scripts/autoload/game_flow.gd)) | Recordar qué nivel se juega (`current_index`, -1 = fuera de la campaña) y cambiar de pantalla. Registrar victorias y desbloquear el siguiente nivel. Aplicar pantalla completa al arrancar. |
| `SaveManager` ([código](../scripts/autoload/save_manager.gd)) | Leer y escribir el progreso y las opciones (§7.1). Los tests cambian `save_path` para no tocar el guardado real. |
| `DevMode` ([código](../scripts/autoload/dev_mode.gd)) *(M6)* | Modo de pruebas (spec §10.2, D-028, D-077): se activa desde Opciones (`OptionsMenu`, M48) o al iniciar con `--pruebas`; hasta M48 también con la característica de exportación `pruebas`. Cambia a `save_pruebas.json`, abre todos los niveles, muestra el cartel y hace que `Game` agregue el panel de pruebas. Va después de `SaveManager` y antes de `GameFlow` y `Audio`, así las opciones ya salen del guardado de pruebas. |
| `Audio` ([código](../scripts/autoload/audio.gd)) | Efectos y música. Carga todo `assets/audio/*.wav` y los reproduce por nombre (`Audio.play(&"build")`). 12 "voces" reutilizables (9 disparos/impactos, 3 avisos), un intervalo mínimo por sonido y limitador Master a-1dB (M36). Buses `Master`, `Music`, `SFX` (`default_bus_layout.tres`). Los sonidos se generan con `tools/make_sounds.gd` (D-020). |

> ⚠️ **Los scripts de herramientas (`tools/*.gd`, que se ejecutan con `-s`) se compilan antes de que existan los autoloads.** Por eso no pueden usar `GameFlow`, `SaveManager` ni `Audio` por su nombre, ni declarar variables de tipo `Game` (porque `game.gd` sí los usa): declaran la partida como `Node2D`.

### 7.1 Formato del guardado

Archivo `user://save.json` (Godot lo guarda en la carpeta de datos del usuario, en Windows: `%APPDATA%\Godot\app_userdata\<nombre del proyecto>`).

```json
{
  "version": 1,
  "levels": {
    "level_01": { "unlocked": true,  "completed": true,  "best_lives": 17, "best_score": 2020 },
    "level_02": { "unlocked": true,  "completed": false, "best_lives": 0,  "best_score": 0 }
  },
  "settings": { "music_volume": 0.7, "sfx_volume": 0.8, "fullscreen": false, "damage_numbers": true },
  "seen_enemies": ["normal", "fast"],
  "scores": {
    "level_01": [ { "name": "ANA", "points": 2400 }, { "name": "LUC", "points": 2020 } ],
    "hall_of_fame": [ { "name": "LUCAS", "points": 19100 } ]
  },
  "initials": { "3": "LUC", "5": "LUCAS" },
  "hall_total": 19100
}
```

- El campo `version` permite, en el futuro, reconocer guardados viejos y convertirlos.
- Si el archivo **no existe** o está **corrupto**, se empieza con el progreso por defecto (solo nivel 1 desbloqueado) y **no** se cierra el juego.
- Se guarda al ganar un nivel, al cerrar la pantalla de opciones y al anotar un récord.
- *(M6)* `scores`: el top 5 de cada nivel y del Salón de la fama (`hall_of_fame`); `initials`: las últimas iniciales usadas (3 y 5 letras); `hall_total`: el último total de campaña ya anotado; `best_score`: el mejor puntaje en victoria de cada nivel (se suman para el Salón). Son claves nuevas: un guardado de antes de M6 no las tiene y se lee igual (sigue siendo la versión 1).
- *(M6)* En el modo de pruebas el archivo es `user://save_pruebas.json` (mismo formato).

---

## 8. Cómo se prueba

| Tipo | Qué cubre | Cómo se ejecuta |
|---|---|---|
| **Tests automáticos (GUT)** | Fórmulas de `rules.gd`, que los `Path2D` coincidan con las casillas, guardado/carga. | Desde el panel de GUT en el editor, o por consola (ver abajo). |
| **Criterios de aceptación** | Cada tarea de `03-tareas.md` dice cómo comprobarla jugando. | A mano, abriendo el juego (F5). |
| **Prueba de rendimiento** | P7: 60 FPS con 200 enemigos y 60 torres. | Una escena de prueba con esas cantidades + el monitor de FPS de Godot. |

Ejecutar los tests por consola (requiere Godot en el `PATH`; la primera vez hay que abrir el proyecto en el editor o ejecutar `godot --headless --import` para que importe los recursos):

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

**En GitHub (D-030):** el workflow [`.github/workflows/tests.yml`](../.github/workflows/tests.yml) hace lo mismo en cada *push* a `main` y en cada *pull request*: baja Godot 4.7.2 para Linux (queda en caché), ejecuta `--import`, revisa con `--check-only` que compilen los scripts de `tools/` y corre GUT. Falla si algún test falla o si el registro tiene errores de script (GUT saltea sin avisar un test que no compila). El resultado se ve en la pestaña **Actions** del repositorio y como ✅/❌ al lado de cada commit.

---

## 9. Riesgos conocidos y cómo se evitan

| Riesgo | Qué pasaría | Cómo se evita |
|---|---|---|
| Camino de casillas ≠ `Path2D` | Enemigos caminando fuera del camino. | Test `test_level_paths.gd` (§6.1). |
| Un proyectil o torre usa un enemigo que ya murió | Error "*previously freed instance*". | Comprobar siempre `is_instance_valid(target)` antes de usarlo. |
| Quedarse en x2 o en pausa al salir | Menús acelerados o congelados. | Restaurar `time_scale` y `paused` al salir (§6.7). |
| Números de balance esparcidos por el código | Balancear se vuelve una pesadilla. | Constitución P2 + revisar en cada tarea que no haya números "mágicos". |
| Muchos enemigos → lentitud | Menos de 60 FPS. | Medir con la prueba de rendimiento (§8) **antes** de optimizar nada. |

### 6.10 La wiki *(M11, D-035)*

- `Wiki` ([código](../scripts/logic/wiki.gd)) devuelve `categories() -> Array[WikiCategory]`. Cada categoría tiene `id`, `title` y `entries: Array[WikiEntry]`. Cada `WikiEntry` (`id`, `title`, `subtitle`, `icon` = capas de texturas, `blocks`) es **solo datos**. Un bloque es un diccionario: `{"tipo": "titulo", "texto": …}`, `{"tipo": "texto", "texto": …}`, `{"tipo": "datos", "filas": [[nombre, valor], …]}` o `{"tipo": "tabla", "filas": [[…], …]}` (la primera fila es el encabezado).
- **Proveedores:** `Wiki.PROVIDERS` lista las categorías (id, título y la función que arma sus entradas). Los enemigos y las torres se **descubren** leyendo `data/enemies/` y `data/towers/` (con `.remap` en el exportado, igual que `LevelFile.enemy_ids()`); los artículos, leyendo `data/wiki/*.json`. Sumar una categoría = una función y una línea en `PROVIDERS`.
- `Wiki.campaign` (los niveles de la campaña) se pasa por parámetro: así se prueba "aparece en los niveles…" con una campaña de mentira.
- `TowerText` ([código](../scripts/logic/tower_text.gd)): las líneas de estadísticas de un nivel de torre. Las usan `TowerPanel` y la wiki.
- `WikiScreen` ([escena](../scenes/ui/wiki_screen.tscn)): solapas de categoría, lista de entradas y detalle con desplazamiento; `WikiIcon` dibuja las capas de un dibujo.
- **Artículos:** `data/wiki/*.json`, con claves en castellano como los niveles (§7.8): `version`, `titulo`, `orden`, `bloques`. `Wiki.parse_article` devuelve la entrada o la lista de errores.

### 6.11 Mapas de tamaño variable *(M13, D-037)*

- `MapGrid` ya no usa `WIDTH`/`HEIGHT` fijos: `width` y `height` salen de las filas del mapa. `MapGrid.MIN_*` (20×9) y `MapGrid.MAX_*` (26×12) son los topes de RF-250. `is_inside` e `is_on_border` usan el tamaño real.
- `Rules.map_zoom(ancho, alto)` calcula el zoom de RF-251 y `Rules.map_camera_center(...)` el punto que la cámara mira, de modo que el mapa quede centrado entre las barras (con 20×9 da el mismo encuadre de siempre).
- `Game` agrega una `Camera2D` **solo si el zoom es menor que 1**. Como la cámara no cambia las coordenadas del mundo, `BuildController`, las torres, los enemigos y los proyectiles no se tocan.
- `LevelDraft` conserva el tamaño del mapa (antes cortaba o rellenaba a 20×9) y `MapEditor` le pone un zoom al `MapView` para verlo entero.
- ⚠️ Los `CanvasLayer` (HUD, pausa, pantalla final) no se achican con la cámara. Todo lo que se dibuje **directo en el mundo** sí.

### 6.12 Leyenda y temas *(M15, D-039)*

- `LevelData` gana `theme: StringName` (vacío = pradera) y `legend: Dictionary` (letra → `{"dibujo", "construible"}`). `LevelFile` los lee y valida; `LEVEL_KEYS` suma `tema` y `leyenda`.
- `MapGrid.parse(rows, legend)`: una letra de la leyenda es `Cell.GRASS` (construible) o `Cell.BLOCKED`, y se recuerda en `legend_cells` (casilla → letra). **Nada de `_find_routes` cambia.**
- `MapThemes` (lógica pura): los siete temas con su paleta y su lista de decoración de `X`. `MapDrawings`: el catálogo de dibujos de la leyenda (nombre → textura o función de dibujo, y si es "suelo" u "objeto").
- `LevelDecor.paint(ground, exit_cells, theme, legend_cells)`: pinta cada casilla con la paleta del tema; sin tema (pradera) usa las mismas constantes de hoy, así que los niveles actuales quedan **idénticos** (un test compara el dibujo).
- `MapView` (editor) pasa el mismo tema y leyenda a `LevelDecor` para que el editor se vea como la partida, y `LevelDraft` conserva `tema` y `leyenda` al abrir y guardar. Los botones del editor para elegirlos van en M16.

### 6.13 Auras de los enemigos *(M17, D-042)*

- `EnemyData` gana `aura_radius_tiles`, `aura_armor_bonus` y `aura_heal_percent_per_second`.
- `Enemy` tiene dos caras: **portador** (`_pulse_aura`, cada `AURA_TICK` = 0,25 s, busca en el grupo `Enemy.GROUP` a los demás dentro del radio) y **receptor** (`receive_aura(armadura, cura)`: guarda el mayor valor y lo hace caducar en `AURA_DURATION` = 0,35 s). `armor()` devuelve la armadura propia más la del aura y `take_hit` la usa; `_update_regen` suma la cura del aura a la propia.
- La parte visual (anillo del portador, ícono del afectado) vive en `Enemy._draw`. Los datos de aura los muestra `Wiki.enemy_entry`.
- Los enemigos nuevos (`data/enemies/guardian.tres`, `healer.tres`) se agregan solos a la Wiki, al bestiario y al panel de pruebas (todo sale de listar `data/enemies/`).

### 6.14 Torres aturdidas, Chamán y Espejo *(M18, D-043)*

- `Tower`: `GROUP = &"towers"`, `stun(seconds)` (queda el mayor tiempo), `is_stunned()`, `stun_left()`. En `_physics_process`, si está aturdida **no dispara** (el cooldown sigue corriendo). `_draw` dibuja aro roto y descargas localizadas; el brillo de mejora se apaga (M36). `TowerPanel` muestra "Aturdida (N s)" y se refresca mientras dura.
- `EnemyData` gana `stun_interval`, `stun_seconds`, `stun_range_tiles` (Chamán) y `reflect_range_tiles`, `reflect_stun_seconds` (Espejo).
- `Enemy`: el Chamán cuenta `_stun_cast_left`; al llegar a 0 busca la torre más cercana (`Tower.GROUP`) sin aturdir dentro del alcance y le hace `stun()`; si no hay, espera. Avisa con `cast_stun(from, tower)` (solo visual). `will_reflect(tower)` / `reflect(tower)` implementan el rebote y avisan con `reflected(enemy, tower)`.
- `Projectile`: `source: Tower`. En `_hit`, si el enemigo rebota el tiro de `source`, no llama a `take_hit` (sí aplica la quemadura).
- `Game` conecta `cast_stun` y `reflected` a `EffectsLayer` (rayo magenta, destello y "¡Rebote!"). `LightningEffect` acepta un color.

### 6.15 Torres de 2×2: el Mortero *(M19, D-044)*

- `TowerData.footprint: int = 1` (lado en casillas). `Tower` guarda `origin_cell` (la casilla de arriba a la izquierda) y `footprint`; `cells()` devuelve todas las casillas que ocupa. Su `position` es el **centro** del cuadrado.
- `BuildController`: `footprint_cells(origin, footprint)` (estática, sin escena, para probarla) y `_occupied` guarda la torre en **cada** casilla. `can_build` exige que todas sean construibles, estén dentro del mapa y libres. `sell` libera **todas** (hoy usa `cell_at(tower.global_position)`, que con el centro en una esquina no sirve). `tower_at(cell)` ya funciona para cualquiera de las cuatro.
- **Vista previa:** la casilla de origen es `cell_at(mouse - (footprint - 1) * TILE_SIZE / 2)`: con `footprint` 1 da la de siempre y con 2 centra el cuadrado en el mouse. Se pintan todas las casillas, el dibujo **escalado** por `footprint` y el alcance desde el centro.
- `Tower._draw` escala con `footprint` la base, la sombra, la torreta, la placa/remaches, el aturdimiento y la longitud del cañón; el anillo de construcción usa el tamaño. `HUD`/`input`: acción `build_9` en `project.godot` y el límite de la barra sube a 9.
- Datos: `data/towers/mortar.tres` (reusa `base_1..3`), `assets/sprites/towers/turret_mortar.svg` y `assets/sprites/projectiles/mortar.svg`; se agrega al final de `Tower Types` en `game.tscn`. La Wiki escribe "Tamaño: 2×2 casillas" leyendo `footprint`.
- **Bot de balance:** las estrategias de hoy usan solo los índices 0–7, así que **no cambian**; se suma una (`mortar`) que compra Morteros donde haya 2×2 libres.
- **Torres reservadas (D-045, RF-300):** `TowerData.reserved`; `LevelData.extra_towers` se lee de `"torres_extra"` (`LevelFile._read_extra_towers`, con `LevelFile.tower_ids()`) y `LevelData.available_towers(todas)` filtra. `Game.available_towers` alimenta a `BuildController` y al HUD; `tower_types` sigue siendo la lista completa. `LevelDraft` conserva y escribe el campo.

- **Torres por mapa (D-079, RF-393 a RF-397, T203):** `LevelData.towers` se lee de `"torres"` (`LevelFile._read_towers`, mismos mensajes que `torres_extra`). `LevelData.available_towers` recorre las torres en el orden de `Game.tower_types` (el canónico), así que la lista del archivo no cambia el orden; con `towers` no vacío manda sobre `extra_towers` y la colección se sigue mirando. El modo escribe su propio `allowed_towers` (RF-388): el filtro aplica los dos (intersección) y `ModePacks._towers_conflict` convierte una intersección vacía en error del mapa. `TowerOffer` (lógica pura) calcula qué ofrece cada nivel y dónde debuta cada torre; `level_select.gd` dibuja los íconos con `Tower.make_icon`. `LevelDraft` conserva el campo.

### 6.16 Sinergias: reacciones por estado *(M20, D-046)*

- `TowerLevelData` gana `bonus_vs_slowed_percent` y `bonus_vs_burning_percent`.
- `Rules.damage_with_bonus(damage, percent)` (estática, sin escena): `roundi(damage × (100 + percent) / 100)`.
- `Projectile._hit` (el único lugar por donde pasan los golpes directos, de área, de cadena y de ráfaga): suma los bonus según `enemy.is_slowed()` / `enemy.is_burning()` **antes** de aplicar los efectos del golpe, y llama `enemy.take_hit(daño_con_bonus, ..., combo)`.
- `Enemy.take_hit` gana un parámetro `combo` y emite `combo_hit(enemy)` (solo visual); `Game` lo conecta a `EffectsLayer.combo` ("¡Combo!" dorado con el mismo tope que los números). *(Cambió en §6.17: ahora el combo viaja en la señal `hit` y el aviso es el propio número.)*
- `TowerText.effects` escribe los bonus (panel y Wiki).

### 6.17 Que el combo se lea y se descubra *(M20, D-047)*

- **Una sola señal por golpe:** `Enemy` gana `enum Combo { NONE, SLOWED, BURNING }` y la señal `hit` suma un cuarto dato, `combo`. `combo_hit` desaparece. `take_hit(daño, ralentización, duración, combo)` lo pasa a `_lose_health`; los tics de quemadura van siempre con `NONE`. Así el efecto recibe el daño **real** (después de la armadura) y sabe que es combo: no hace falta un número blanco aparte.
- `Projectile._hit` calcula por separado el bonus por ralentizado y el bonus por quemado; el combo es el estado que dio **más** bonus (empate: `SLOWED`). La cuenta del daño no cambia (RF-311).
- `EffectsLayer.combo(posición, daño, combo)`: número `"N!"` de 20 px en `COMBO_SLOWED_COLOR` (celeste) o `COMBO_BURNING_COLOR` (naranja), anillo del mismo color, "¡Combo de hielo/fuego!" la primera vez (un diccionario `_combo_seen` en la capa: dura lo que dura la partida) y agrupación con un reloj propio de la capa (`_clock`, avanza en `_process`) y una lista de los combos recientes (posición y momento). El número respeta la opción de números de daño y su propio tope (`MAX_COMBO_NUMBERS = 12`); el anillo y el texto de la primera vez, no. Se borra `COMBO_COLOR`.
- `Game._on_enemy_spawned`: la conexión de `hit` decide: si `combo` es `NONE`, `damage_number` como siempre; si no, `effects.combo(...)` y `Audio.play(&"combo", COMBO_SOUND_GAP)`. `Audio.play` gana un intervalo mínimo opcional (por defecto el de siempre, 0,05 s).
- Sonido: `tools/make_sounds.gd` sintetiza `combo` (dos senos agudos que suben, ~90 ms) y escribe `assets/audio/combo.wav`.
- **Desde la torre que pone el estado:** `TowerText.combo_partners(torre, torres)` (estática, sin escena) arma las líneas "Combo: Cañón, Francotirador y Mortero +25 % a los que frena" leyendo `slow_amount` / `burn_damage_per_second` del nivel 1 de la torre y los `bonus_vs_*_percent` del nivel 1 de las demás (agrupa por porcentaje). `TowerText.combo_hint(torre, torres)` da la frase corta de la barra. `TowerPanel` recibe de `Game` la lista de torres del nivel (`partner_towers`, llamada hacia abajo); `Wiki.tower_entry` usa todas las torres de `data/towers/`; `Hud.show_selected_tower` usa las de la barra.
- **Marca de "vulnerable":** `Enemy.set_exploitable(ralentizados, quemados)` guarda qué estados aprovecha alguna torre del mapa; `_draw_aura_icons` (ahora "íconos de arriba") dibuja la dianita celeste o naranja si además el enemigo **está** en ese estado. `Game._refresh_exploitable()` recorre las torres (sin contar las que se están borrando) al construir, mejorar y vender, y se lo pasa a todos los enemigos; uno nuevo lo recibe al aparecer.


### 6.18 Probar oleadas finales y combos *(M22, D-048)*

- **Datos (RF-324):** `scripts/data/dev_config.gd` (`DevConfig`, un `Resource`) con `gold_step` (1000) y `speeds` (`PackedFloat32Array`: 0,25 · 0,5 · 1 · 2 · 4), y `data/dev_config.tres`. `DevMode` lo carga; `Game.DEV_GOLD` y `Game.DEV_FAST_SPEED` desaparecen.
- **Lógica sin escena (P10):** `scripts/logic/dev_start.gd` (`DevStart`), estática: `clamp_wave(n, total)`; `skipped_gold(level, balance, wave)` (recompensas de los enemigos de las oleadas `1..wave-1`, sumando recursivamente `death_spawn × death_spawn_count`, más `Rules.wave_bonus` de cada una); `start_gold(level, balance, wave, manual)` (`manual < 0` = automático = `level.starting_gold + skipped_gold`). Se prueba sin abrir ventanas.
- **Qué se eligió:** `DevMode.start_wave` (1 por defecto) y `DevMode.start_gold` (-1 = automático). La franja de `level_select.gd` los escribe (solo si `DevMode.enabled`); `GameFlow.next_level` y `go_to_main_menu` los reinician. `Game._ready` los usa solo si el nivel viene de la campaña o de la comunidad (no del editor, ni de F6, ni de un test que no los pida), **sin borrarlos**, así `restart()` (recarga la escena) repite la misma partida.
- **Saltar a la oleada N:** `LevelSession.jump_to_wave(n)` pone `wave = n - 1` y emite `wave_changed` (el HUD ya muestra `waves[wave]` como próxima); no toca el estado (`BUILDING`). El oro se fija con `DevStart.start_gold` justo después de `session.start`.
- **Sin progreso (RF-321):** `GameFlow.dev_partial_run()` (verdadero si `DevMode.enabled`, `start_wave > 1` y se juega desde la campaña o la comunidad); `played_level()`, `level_won`, `record_level_score` y la presentación de enemigos de `Game._on_enemy_spawned` (que guarda en `SaveManager`) lo consultan para no guardar. Un test por cada punto donde hoy se guarda.
- **Velocidades (RF-322):** `Game.dev_set_speed(speed)` reemplaza a `dev_set_fast` y llama a `set_speed`; `Game.set_speed` avisa a `DevMode.show_speed(speed)` (hacia abajo, a un autoload) que reescribe el cartel (se ensancha y se vuelve a centrar) y emite `speed_changed`. `Hud.show_speed` deja de redondear (formato "x0,5" con coma). `Game._exit_tree` y `_on_state_changed` ya vuelven a 1: suman `DevMode.show_speed(1.0)`. `toggle_speed` pasa a "si va a x1 → x2, si no → x1" (idéntico en el juego normal, que solo tiene 1 y 2). En el panel, una fila de cinco botones con el activo marcado.
- **Atajos (RF-323):** `DevMode.register_actions()` (se llama al activarse) crea en el `InputMap` (F5 queda libre: la usa Godot) `dev_kill_all` (F2), `dev_skip_wave` (F3), `dev_infinite_lives` (F4), `dev_slower` (F6), `dev_faster` (F7) con `physical_keycode`, y `DevMode.ACTIONS` es la lista nombre → tecla → texto. `Game._unhandled_input` los atiende (junto al `F1` de hoy, y no con el menú de pausa abierto). El panel escribe la tecla en cada botón leyendo `ACTIONS`. `tests/test_dev_shortcuts.gd` recorre `InputMap.get_actions()`: sin teclas repetidas entre acciones (con y sin el modo), ninguna en `KEY_1`-`KEY_9`, cada acción existe en el panel y llama a lo mismo que su botón. Sin dependencia de `godot-remappable-controls`: el juego no tiene pantalla de controles.
- **Estadísticas (RF-325):** `scripts/logic/dev_stats.gd` (`DevStats`, sin escena) guarda las filas por oleada y arma el diccionario (`to_dict(result)`). `Game` le avisa en `wave_completed`, al terminar la partida (`_on_state_changed`) y al salir (`_exit_tree`, con `"left"` si no había terminado); `DevMode` escribe el archivo en `stats_path` (los tests lo cambian a `user://test_*.json`). El tiempo suma el `delta` del juego, así no cuenta la pausa.
- **Lo que no se hace:** no se restaura una defensa armada, no se guardan "puntos de control", no se toca el juego normal.

### 6.19 Arte renderizado direccional (M23, D-049)

- Fuentes PNG transparentes de ocho vistas (4 columnas × 2 filas) en art/redesign-m23/sources; atlas normalizado de 4×2 cuadros de 128 px y vista derecha en assets/sprites/towers/rendered.
- Orden: derecha, abajo-derecha, abajo, abajo-izquierda, izquierda, arriba-izquierda, arriba, arriba-derecha. TowerData incorpora turret_atlas opcional. La selección y rectángulo de cuadro viven en TowerVisual, independientes de escenas. El dibujo con atlas no rota el lienzo: solo el vector de retroceso sigue aim_angle. Destello y salida del proyectil siguen el ángulo continuo.
- Tower.make_icon compone la base con el cuadro hacia arriba del atlas; la Wiki recibe la vista derecha. Se conservan los dibujos SVG para datos antiguos.
- Bases renderizadas compartidas por nivel, PNG de 128×128. Proyectiles con siluetas pequeñas y efectos temporales de frío/explosión junto a fuego/rayo existentes.
- Pruebas de límites angulares, datos, atlas, íconos, mejoras, efectos y suite completa. Capturas reales y hoja de contacto del conjunto, con límites de calidad documentados.

### 6.20 Monstruos y menú M24 (D-050)

- **Producción:** `tools/prepare_monster_sprites.gd` lee `art/redesign-m24/sources/{normal_B,fast_A,tank_A}.png`, recorta el cuerpo (opacidad > 0,1), lo escala para que quepa en un 98 % de ancho y un 63,4 % de alto (el alto que `EnemyShape.sprite_top` espera para la corona y la barra de vida) y lo apoya en un lienzo de 256×256 con los pies al 74,55 % del alto: con `SPRITE_SCALE` 2,8 eso cae sobre la sombra del suelo. Salida: `assets/sprites/enemies/rendered/{normal,fast,tank}.png` (RGBA, mipmaps). Los SVG anteriores se conservan como están.
- **Datos:** `EnemyData.flip_when_walking_left` (bool, `true` por defecto). `normal.tres`, `fast.tres` y `tank.tres` apuntan a los PNG y lo apagan; nada más cambia. `Enemy._draw` solo refleja el dibujo si el dato lo permite; el parpadeo, el tinte, la escarcha, las llamas, la barra y la corona se dibujan igual que antes.
- **Menú:** `assets/ui/logo.png` (copia de `logo_corrected.png` a 1024 px de ancho, mismo alfa) en un `TextureRect` que reemplaza a `Title` y `Subtitle`. `MainMenu.logo_height(alto_de_ventana, alto_de_botones)` (estática, sin escena) calcula el alto del logo para que todo entre. `assets/ui/menu_theme.tres` es un `Theme` con `StyleBoxFlat` para `Button` (normal, hover, pressed, focus, disabled) aplicado solo a las filas del menú.
- **Evoluciones:** no se integran. Formato pedido para la siguiente entrega, en `art/FORMATO_PROXIMA_ENTREGA_M24.md`.

### Integración M26 · RF-334, D-051
Copiar ocho materiales y cinco objetos a assets; conectar MapThemes y LevelDecor, retirar el detalle procedural de suelo reemplazado y conservar las superficies de leyenda. Verificar los siete temas, recursos y suite GUT.

### M27 · RF-335, RF-336, D-052
Producir nueve hojas de evoluciones, separar niveles y normalizar ocho cuadros de 128; extraer iconos hacia arriba. Validar alfa, contenido, orden y escala con muestras. Después producir cinco especiales y enmarcarlos como M24. Conservar fuentes, prompts, manifest y guía de integración.

### Integración M27 · RF-337, D-053
Copiar atlas y monstruos a assets, asignar atlas en niveles2/3 y resolverlo en Tower. Cambiar textura/flip de los cinco especiales. Verificar mejoras, fallback, ocho vistas y combate con capturas y GUT.

### M28 · RF-338, D-054
Visor aislado de enemigos y tamaños; GIF de caminata y vuelo; comparación de bases con montaje ajustado y dos conceptos integrados. Capturas1920×1080 desde copia temporal del proyecto. Registrar propuestas en changelog y sección de descripción PR, dejando explícito lo pendiente de aprobación.

### M29 · RF-339 a RF-341, D-055
Copiar cinco físicos, tres atlas de caminar y el vuelo a assets. Añadir escala y atlas opcionales en EnemyData, selección pura en EnemyVisual y anclaje de pies en EnemyShape. Enemy dibuja cuadros con parpadeo, estados y barras existentes. Producir bases y cañón C, empaquetar en Godot, compartir offset de encastre/contacto entre Tower y make_icon. Ajustar ventana de escritorio desde GameFlow mediante cálculo puro DesktopWindow y omitir headless/móvil. Validar cuatro direcciones, pasos/ralentización/pausa, escala sin cambio lógico, encastre, capturas reales y suite GUT. Exportar Windows de pruebas.

El atlas de caminar tiene enmarcado diferente a la pose fija; walk_art_scale conserva el tamaño del cuerpo aprobado antes de aplicar el20%. Cotas por pose cacheadas sitúan la barra sobre la cabeza/alas. La silueta blanca usa ajuste nativo de RGB conservando alfa para evitar recorrer atlas grandes en GDScript al primer golpe.

### M30 · RF-342/RF-343, D-056
Tower crea una capa Sprite2D con AtlasTexture reutilizable y ShaderMaterial propio. Comparte cuadro/posición/escala del mecanismo, ajusta intensidad/color por nivel, oculta al aturdir o sin atlas y congela tiempo con física. Shader usa alfa y luminosidad originales para reflejos localizados. Validar selección por nivel, pose/retroceso, pausa/aturdimiento y capturas reales; actualizar changelog y estado de ciclos pendientes.

### M31 · RF-344, D-057
Producir nueve fuentes transparentes y conservar prompts. Empaquetar144cuadros de256 en nueve atlas1024, validar alfa/orden/poses únicas/apoyo y calibrar tamaño. Conectar nueve EnemyData con distancias de ciclo propias sin modificar balance. Generalizar tests de selección/ralentización/pausa y fallback, comprobar regeneración/aura/crías/hechizo/rebote existentes con GUT. Capturas reales y GIF de ciclos y direcciones; exportar Windows/Linux, actualizar documentos/changelog y subir al PR#1.

### M32 · RF-345/RF-346, D-058
Compactar textos y tooltips; reutilizar tema de botones y estilo de panel propio, agregar secciones admin. Monitor Label en HUD, señal desde DevPanel y actualización por intervalo real. Verificar valores/oleadas y monitor independiente del panel, captura y GUT.

### M33 · RF-347, D-059
Inventario de submenús: Opciones, niveles, Wiki, récords, final, Salón/iniciales, editor y diálogos. Tema compartido y panel hierro-bronce; SVG propios para casillas/deslizador. Agrupar Opciones, revisar capturas y navegación/guardado existentes con GUT, actualizar B-19 y push.

### M34 · RF-348, D-060
Agregar preset Android pruebas, paquetes distintos y versión1.1-pr1/code2. Exportar APK de instalación local, validar firmas/manifest/recursos y SHA256; documentar limitación iOS y ausencia de ejecución física si no hay dispositivo disponible.

### M35 · Panel de torre (RF-349, D-061)
TowerPanel conserva show_tower/refresh y sus tres señales. Tres valores de estadísticas fuera de ScrollContainer; descripción, TowerText.effects, combo_partners y capacidad aérea dentro. Botones fuera del desplazamiento, tema local menu_theme y game_panel_style. Se reinicia el desplazamiento al seleccionar otra torre, no al cambiar oro o cuenta atrás. Datos de combate, TowerText compartido con Wiki y guardados intactos.

### M36 · RF-350 a RF-357
Tower dibuja placa/remaches antes del mecanismo, y aturdimiento con trazos localizados. Enemy dibuja límite de aura y brotes en receptores capaces de curarse; EffectsLayer muestra pulso de cura efectiva y limita residuos de muerte. DeathEffect captura textura/región/escala de Enemy, sin referencias al enemigo borrado; shader con progreso de CPU conserva pausa. Audio mantiene buses, añade perfiles de mezcla, música por pantalla, variación determinista y separación entre disparos/avisos. Generador original produce WAV y manifiesto de picos/RMS. Investigación y muestras viven en art/redesign-m36; no se incluyen en exportación.

### Depuración del backlog (D-063)
B-02 cerrado; B-15 retirado. Lore/Wiki de Épocas en B-03; documentación de mods y comunidad separada en B-29/B-30, dependiente de B-04 y sin añadir sistemas por anticipado. B-21/22/23 son estudios preliminares abiertos: elegir y validar antes de diseñar producción. Esta reorganización documental no cambia código, datos, guardados ni exportaciones.

### M37 · Colección y torres de apoyo (D-064)
CollectibleRun mantiene portador/pickup/confirmación por oleada fuera del guardado; colección de SaveManager es diccionario id→fuentes únicas, con lectura defensiva y campos opcionales versión1. Game conecta nacimiento/muerte/fin de oleada/resultado y excluye admin/editor/comunidad. Solo el resultado guarda fuentes confirmadas. La disponibilidad de TowerData usa requisito de colección y permiso del nivel; admin puede agregar catálogo reservado sin cambiar archivo ni desbloqueo persistente. SupportRules calcula el aura mayor a partir de torres activas y radios, sin apilar ni referencias permanentes a torres vendidas; cadencia efectiva se calcula antes de cada disparo. No altera recursos de niveles1–5;6/7 solo agregan permiso del mecánico. Pruebas deterministas de fuente/drop/límites/guardado/aura, integración normal/admin y balance local6/7 con y sin apoyo; captura inicial para revisión de arte.

### M38 · HUD de colección
TechnologyStat en TopBar/Stats usa el icono existente, tipografía22 y ayuda por foco/puntero. Game actualiza Hud.show_collection después de pickup/confirmación/resultado y al arrancar cualquier modo, sin agregar otro control sobre el mapa.

### M39 / T184
EnemyData: gold_drain_amount/interval/floor y optional_wave_limit apagados por defecto. Enemy.clock de física solicita oro; LevelSession calcula el descuento acotado. SpawnGroup.probability y WaveSpawner.rng inyectable sortean al inicio y limitan enemigos opcionales por tipo. LevelFile valida0–1, LevelDraft conserva/serializa/deshace; pruebas de piso, ingresos, muerte/salida, sorteo/cap, persistencia editorial y campaña.


### M40 / T185
ChargeRules extrae rectas del Curve2D de camino y calcula extremos/proximidad. EnemyData configura distancia, aceleración, tolerancia a slow, alcance e impacto; Enemy usa delta/distancia y señal de impacto. WearRules aplica/clampa desgaste, Tower lo guarda por instancia y calcula cadencia/prestaciones; BalanceConfig.wear_max_percent limita. Panel y marca de base separan daño de stun. Pruebas de geometría, extremos, cercanía, slow, persistencia al mejorar, tope y coexistencia con apoyo/stun.


### M41 / T186
TowerLevelData.support_repair_per_second; WearRules.repair pura; búsqueda de mayor fuente sin asignar diccionarios por receptor. Tower registra repair_rate_received para lectura visual/UI, consulta solo SUPPORT_GROUP cuando desgastada, descarta self/stun/sale y reduce tasa por condición del reparador. Reparación antes del retorno de stun permite curar una torre apagada sin despertarla. Clocks de física respetan pausa/velocidad. Laboratorio reproducible con semillas, conteo de Ladrones/Embestidores/robo/impactos/reparación y capturas de panel/estado; pruebas y exportaciones independientes del progreso real.


La validación de rendimiento detectó costo de triangulación de marcas por frame. M41 usa dos texturas SVG compartidas (grieta ámbar/herramienta cian), intensidad proporcional a desgaste y sin geometría adicional por cuadro; alcanza 103 FPS en la carga P7 extendida.

### M42 / T188
DevPanel mantiene el catálogo dinámico y OptionButton. PopupMenu.max_size limita altura y activa scroll nativo; StyleBoxFlat duplicados locales eliminan transparencia/sombra recortada sin alterar el tema compartido. gui_input discrimina rueda presionada, acota selección y conserva clic. Tests de extremos, eventos ajenos, invocación del seleccionado y captura real del popup. Rediseños en B-31, producción futura con muestras comparativas.

### M43 / T189 · B-31
Fuentes RGBA en art/redesign-m43/sources; empaquetado por figuras/celdas con escala uniforme y apoyo a191 en atlas 1024×1024, estáticas256×256 para Wiki; Mecánico128×128 sin sombra/base incrustada. Recursos EnemyData/TowerData referencian los nuevos PNG conservando todos los parámetros jugables. Capturas comparativas a34/112px, cuatro direcciones y movimiento con Enemy real, además de mapa y Wiki. Verificar GUT e importación/exportación Windows de pruebas. La aprobación artística final se pide solo con imágenes integradas revisables.

### T190 · Entrega aprobada M43
Exportar Windows Desktop/Windows (pruebas) release y Android/Android (pruebas) debug. Usar configuración local de SDK/Java y APPDATA aislado. Verificar arranque de ambos Windows, paquetes/feature y firma APK con herramientas SDK, SHA256/tamaño. Preservar cambios locales M34 fuera del commit.

### T191 · Comparación6/7
Extender balance_sim sin tocar su estrategia original. Perfiles sin apoyo/con apoyo temprano/tardío, mejoras y ubicaciones por cobertura/valor de aliados. Registrar compras, oleadas, vida, robo, impactos y reparación. Ablación de especiales y frecuencia reforzada solo en laboratorio; semillas controladas y escenarios de impacto sobre caminos reales. Informe JSON y conclusiones con límites antes de cambiar datos oficiales.

T191 también corrige cierre de reparación con is_zero_approx y transición positiva→0 fuera del guard aproximado. Test de regresión con pasos pequeños y residuo; reexportar las cuatro variantes y verificar boot Windows/firma e identidad APK. Evidencia en art/balance-m44 y logs/paquetes locales build/t191.

### M45 / T192 · Niveles8/9
Agregar JSON20×9, una entrada8 y dos9, recorridos con rectas/exposición legal. Oleadas escalan grupos y vida local, introducen Guardián/Curandero antes de combinaciones tardías. Append en campaign.json; desbloqueo/menu/Wiki por datos existentes. Tests de contratos, aparición ordenada, pasos de campaña y geometría de carga/reparación sin cambiar pantalla. Laboratorio hereda políticas M44, fija RNG global/spawner y aisla APPDATA; conserva resultados y capturas de mapas reales. No exportaciones.

T192 extiende is_level_unlocked con victoria del anterior para guardados previos sin marca de desbloqueo del nuevo nivel. Laboratorio M45 conserva controles M44 y agrega puntaje de cobertura aérea a mejoras, sin cambiar bot original ni lógica del juego. JSON se serializa con LevelDraft.to_text para conservar roundtrip del editor.

### M46 / T193 · Estudio de vista B-21 v2
Laboratorio aislado en `art/b21-vista/` (fuera de los paquetes exportados, igual que `art/`). Instancia `game.tscn` sin tocar sus scripts y cambia solo la presentación.
- **B:** `relief_layer.gd` reemplaza el dibujo de `LevelDecor` (mismos materiales). Dibuja taludes al norte del camino, sombra proyectada al sureste y labios iluminados, y le suma una textura de luz multiplicada. Torres, monstruos y decoración (Sprite2D por casilla bloqueada) quedan bajo un nodo con `y_sort_enabled`. Para medir, el suelo se hornea una vez en un SubViewport al doble de resolución.
- **C:** agrega una Camera2D con `zoom = (1; 0,8)`, canto delantero y fondo. Lo que está de pie se escala (1; 1,25), y las torres después de su animación de aparición. Los clics siguen pasando por `get_global_mouse_position()`.
- **D:** `diorama_3d.gd` arma un ArrayMesh por casilla (pasto 0,28, camino 0, canto −0,55), una DirectionalLight3D con sombras y sesgo chico (la escena mide ~20 unidades) y una Camera3D en perspectiva (30°, 55°) encuadrada entre las barras del HUD. Torres, monstruos, decoración y proyectiles son Sprite3D inclinados hacia la cámara, apoyados en su pie. Las barras de vida van en 2D con `unproject_position`. Los clics usan un rayo al plano del pasto (`d_input.gd` recibe la entrada antes que Game). La partida 2D sigue corriendo oculta.
- **Modos:** `capturas`, `medidas`, `rendimiento` (carga de `tools/perf_test.gd`, con opciones `horneado`, `sin_orden` y `ocultar_actores`) y `jugar` (con `autoprueba`). Guarda en `user://test_b21_vista.json`; conviene correrlo con `APPDATA` aislado.

### T194 · Prueba de cámara libre para Monsters & Canons 3D
`diorama_3d.gd` suma `orbit(giro, inclinación, distancia, objetivo)`: la cámara se ubica rotando `(0, sen φ, cos φ) · d` alrededor del eje vertical. Los Sprite3D pasan a *billboard* completo. Torres y monstruos eligen su cuadro sumando el giro de la cámara al ángulo de puntería o de marcha (`frame_rect(atlas, aim + giro)`, `walk_region(..., heading + giro)`). El sol queda fijo en el mundo. `vista_lab.tscn -- camara` saca seis vistas de la escena de referencia (sin HUD) y una hoja de 3 × 2 (`_sheet` admite títulos y columnas). Es investigación: no toca producción.

### M48 / T196 · Modo de pruebas en Opciones, una sola app y licencia
- **`DevMode.detect()`** solo mira el argumento `--pruebas` en cualquier ejecutable (sin la característica de exportación ni la restricción al editor). Se elimina la constante `FEATURE`.
- **`OptionsMenu`** suma la sección "Administración" (rótulo, botón y una fila de confirmación con "Sí, activar" y "Cancelar", dentro del mismo panel, sin ventanas emergentes):
  - `admin_available` (falso por defecto) la muestra; `MainMenu` lo prende, y el menú de pausa no.
  - `set_dev_mode(on)` llama a `DevMode.set_enabled(on, dev_save_path)`, aplica volúmenes y pantalla del guardado que queda activo y emite `dev_mode_changed(on)`.
  - `dev_save_path` vacío usa el guardado de pruebas real; los tests pasan uno propio.
- **`MainMenu`** escucha `dev_mode_changed` y recarga el menú principal (`GameFlow.go_to_main_menu()`), así se actualizan el botón del editor en el celular y el resto de la pantalla. Los tests no recargan escenas: prueban la señal.
- **`export_presets.cfg`** queda con Windows Desktop, Android y Linux (índices 0, 1 y 2). Las APK y EXE de pruebas viejos quedan en `build/` como archivos sueltos.
- **Licencia:** `LICENSE` con el texto oficial de gnu.org sin cambios; artículo `data/wiki/licencias.json` (orden 8) con los avisos del juego y de Godot.
- **Tests:** presets sin la característica `pruebas`; Opciones (visibilidad, confirmar, cancelar, volver, guardado real intacto); `LICENSE` y el artículo de la Wiki.

### M49 / T197 · Prueba de modos
Diseño en spec RF-388 a RF-392 y D-078.
- **`ModePacks`** (`scripts/logic/mode_packs.gd`, lógica pura como `CommunityMaps`):
  - `all(oficiales, propios)` escanea las subcarpetas de `res://data/modos/` y `user://modos/`. `read()` valida `modo.json` (claves, versión, nombre, mapas, torres, reglas, topes) y lee cada mapa (carpeta del modo → `data/levels/`) con `LevelFile.parse`, el id `modo_<modo>_<mapa>` y las reglas aplicadas.
  - `is_open` / `previous_playable` / `next_playable` resuelven el desbloqueo, y `create` / `name_problem` / `add_map` sirven al editor. Al reescribir, los números enteros vuelven a guardarse como enteros.
- **`LevelData`** suma `enemy_health_percent` y `allowed_towers`. `available_towers` filtra por `allowed_towers`.
- **`Rules.percent_of`** redondea al entero más cercano. `WaveSpawner.setup` recibe el % de vida (100 por defecto) y lo aplica después de la escala por oleada, con un mínimo de 1.
- **`GameFlow`:**
  - `current_mode` / `current_mode_index`, `current_mode_level()`, `is_mode_level_unlocked()` (el modo de pruebas abre todo) y `start_mode_level()`.
  - `played_level()`, `has_next_level()`, `next_level()` y `level_won()` contemplan el modo; ganar desbloquea el siguiente del mismo modo.
  - Toda función que cambia de pantalla limpia el modo (`_clear_mode`). `select_page` usa `&"mode:<id>"`.
- **`Game`:** toma el mapa del modo después de la campaña y la comunidad, y pasa el % de vida al generador. La colección no corre porque `current_index` es -1.
- **Selección de nivel:**
  - Arma solapas dinámicas: las oficiales después de "Campaña" y las propias después de "Comunidad".
  - `_show_mode` pone tarjetas de mapa, de error o un mensaje si el modo está vacío, y las estrellas del modo.
  - El botón de carpeta abre la del modo propio. Las carpetas se cambian desde los tests (`modes_official_dir`, `modes_user_dir`).
- **Editor:**
  - El botón `SaveModeButton` ("En un modo…") llama a `save_to_mode`: elegir modo o crear uno, y después pedir el nombre del archivo. El borrador recuerda `mode_id` recién al aceptar.
  - `_dir_for()` decide la carpeta y `_write()` suma el mapa a la lista del modo.
  - "Abrir" lista los mapas de cada modo propio, sin `modo.json`. Las carpetas `modes_dir` y `official_modes_dir` se cambian desde los tests.
- **Bot:** `balance_sim.gd -- mix modo=asedio level=N`.
- **Datos:** `data/modos/asedio/modo.json`.
- **Tests:** `test_mode_packs`, `test_mode_flow`, `test_mode_select` y `test_editor_modes`, siempre en carpetas `user://test_*`. `test_editor_files` fija una carpeta de modos de prueba para no leer la del jugador.

### M50 / T205 · Infraestructura: demolición, recursos y hallazgos (RF-398 a RF-437, D-080 a D-085)

**Estado: diseño, a la espera del OK de Lucas (G3).** Se programa en T206 a T214 (código) con arte provisional hecho por código (Q-40); el arte final es de Codex (T219 a T221). Este plan está escrito para que un Sonnet en esfuerzo medio pueda implementar cada tarea **sin tomar decisiones de diseño**: si algo no está acá ni en la spec, se frena y se pregunta (`specs/tareas/README.md` §5).

#### Datos

- **`data/obstaculos.json`** (nuevo, RF-398). Lo lee `ObstacleCatalog` (lógica pura, `scripts/logic/obstacle_catalog.gd`), que valida claves y tipos, y devuelve los números de cada clase. Estructura:
  ```json
  {
    "version": 1,
    "demoledora": {"precio": 180, "costo_uso_porcentaje": 10, "costo_uso_minimo": 5, "tiempo_porcentaje": 80},
    "removibles": {
      "arbol":    {"costo": 40, "tiempo": 4.0,  "recursos": 1, "probabilidad": 50},
      "roca":     {"costo": 60, "tiempo": 6.0,  "recursos": 1, "probabilidad": 50},
      "escombro": {"costo": 90, "tiempo": 10.0, "recursos": 0, "probabilidad": 0, "recursos_si_recuperado": 1}
    },
    "extraccion": {
      "mina":              {"costo": 100, "produccion": 2, "reserva": 8},
      "bosque_explotable": {"costo": 100, "produccion": 2, "reserva": 8}
    }
  }
  ```
  Todos son valores iniciales. Un test de datos comprueba que cada clase del archivo tiene su dibujo en `MapDrawings` (mismo nombre) y que no sobra ninguna clave.
- **`data/progression.json`** (RF-425): se suma `disruptor` (`origen: "hallazgo"`, `nombre`, 3 fuentes). `technology` no cambia (puede ganar `nombre`).
- **`TowerData`** (`scripts/data/tower_data.gd`): `resource_cost: int = 0`, `alt_gold_cost: int = 0`, `alt_resource_cost: int = 0`. En `mortar.tres`: `resource_cost = 3`. En `sniper.tres`: `alt_gold_cost = 120`, `alt_resource_cost = 1`. Un test de datos comprueba RF-419 (no los dos a la vez, `alt_gold_cost` menor que el costo de oro).
- **`LevelData`**: `obstacles: Array[ObstacleSpec]` (ya resueltos), `machine_enabled: bool`, y `uses_resources() -> bool` (RF-416: algún removible con `probabilidad` y `recursos` mayores que 0, o algún punto de extracción).
- **`ObstacleSpec`** (`RefCounted`, `scripts/data/obstacle_spec.gd`): `cell: Vector2i`, `letter`, `kind` (`REMOVABLE` o `EXTRACTION`), `class_id`, `cost`, `seconds`, `reward_amount`, `chance_percent`, `finding_collection` (`&""` si no hay), `repeat_reward`, `production`, `reserve`. Lo arma `LevelFile` cruzando la leyenda con las casillas del mapa, **con los números de la clase y las sobrescrituras ya aplicadas**; así el resto del código nunca vuelve a mirar el catálogo.

#### Clases nuevas

| Clase | Tipo | Dónde | Qué hace |
|---|---|---|---|
| `ObstacleCatalog` | lógica pura, estático | `scripts/logic/` | Lee y valida `data/obstaculos.json`; `removable(class)`, `extraction(class)`, `machine()`, `class_ids()`. |
| `ObstacleSpec` | datos | `scripts/data/` | Ver arriba. |
| `ObstacleField` | `RefCounted`, lógica pura | `scripts/logic/` | **El estado de la partida de cada obstáculo** y las reglas de demolición y extracción. Sin nodos: se prueba con GUT. |
| `DemolitionJob` | `RefCounted` | `scripts/logic/` | **Un trabajo activo**: celda, segundos totales, transcurridos, oro pagado. `tick(delta)`, `progress()`, `is_done()`. |
| `CollectionDefinitions` | lógica pura, estático | `scripts/logic/` | Generaliza `CollectibleRun.definitions()`: `all()`, `required(id)`, `eligible(id, source)`, `origin(id)`, `name_of(id)`, `icon_of(id)`, `collection_of_level(level_id)`. `CollectibleRun.definitions/eligible/required` quedan como **envoltorios** que lo llaman (los tests de M37 y M38 no cambian). |
| `FindingRun` | `RefCounted`, lógica pura | `scripts/logic/` | Las **piezas** de una partida: `pick(collection, source, wave_to_confirm)`, `complete_wave(wave)`, `pending()`, `confirmed()`. **No toca `CollectibleRun`** (el portador de `technology` queda idéntico). |
| `InfrastructureController` | `Node` | `scenes/game/` | El pegamento con la partida: dueño del `ObstacleField`, cobra y reembolsa en `LevelSession`, escucha `wave_completed`, y emite las señales que usan la vista y el panel. Hermano de `BuildController`. |
| `ObstaclePanel` | `Control` | `scenes/ui/` | El panel de un removible o de un punto de extracción (RF-404, RF-422). Estilo hierro y bronce, copia de `tower_panel.gd`. |
| `InfrastructurePanel` | `Control` | `scenes/ui/` | El botón y el panel "Infraestructura" con la demoledora (RF-411). |
| `ObstacleLayer` | `Node2D` | `scenes/levels/` | Dibuja el **estado** de cada obstáculo sobre el suelo: marca, barra de progreso, despejado, mina activa o agotada y reserva. Escucha al `InfrastructureController`. |

**`ObstacleField` (API que fijan los tests de T207):**
- `setup(specs: Array[ObstacleSpec], rng: RandomNumberGenerator, recovered: Dictionary)`. Sortea **ahora** el drop de cada removible (RF-417), en **orden de fila y columna**, con `rng.randi_range(1, 100) <= chance_percent`. `recovered` dice qué hallazgos ya están recuperados o no se recogen en este contexto (RF-428, RF-429).
- Estado de cada celda: `Removable { INTACT, WORKING, CLEARED }` o `Site { DISABLED, ACTIVE, DEPLETED }`, con `state_of(cell)`.
- `can_order(cell) -> StringName`: `&""` si se puede, o el motivo (`&"busy"`, `&"cleared"`, `&"not_removable"`).
- `cost_of(cell) -> int` y `seconds_of(cell) -> float`: **con la máquina** si la hay (RF-413).
- `order(cell) -> DemolitionJob`: **el cobro lo hace el llamador** (`InfrastructureController`), que ya comprobó el oro. Guarda el costo pagado en el trabajo.
- `tick(delta)`: avanza el trabajo; al terminar, despeja y emite `job_finished(cell, reward)`.
- `cancel() -> int`: devuelve el oro pagado y deja el objeto `INTACT`.
- `buy_machine()` / `has_machine`, `machine_price()`.
- `reward_of(cell) -> Dictionary` (solo al terminar): `{"resources": int, "finding": {"collection": StringName, "source": StringName}}`.
- `enable_site(cell)`, `complete_wave() -> Dictionary` (celda → recursos producidos) y `reserve_left(cell)`.
- Señales: `job_started(cell)`, `job_progress(cell, fraction)`, `job_finished(cell, reward)`, `job_cancelled(cell, refund)`, `site_changed(cell)`.
- `discard_job()`: al terminar la partida (RF-409).

**`LevelSession` (RF-415, `scenes/game/level_session.gd`):** agrega `resources: int`, la señal `resources_changed(resources: int)`, `add_resources(n)`, `can_afford_both(gold, resources)` y `spend_both(gold, resources) -> bool` (**atómico**: o cobra los dos o ninguno). `spend(cost)` y `can_afford(cost)` **no cambian**. El reinicio vuelve `resources` a 0.

**`Tower`:** guarda `resources_invested: int` (RF-418). `BuildController.sell_value` devuelve el oro como hoy y se suma `sell_resource_value(tower) = Rules.sell_refund(tower.resources_invested, cfg)` (el mismo `floori`, así que redondea hacia abajo). `try_build(tower_data, cell, pay_alt := false)` cobra con `spend_both`.

#### La semilla (RF-417)

`Game` crea un `RandomNumberGenerator` por partida: `randomize()` por omisión, o `seed = N` si se lo piden (`GameFlow.forced_seed`, usado por el bot y los tests). **Ese generador solo se usa para el drop** y se consume una vez por removible, en orden de fila y columna, al empezar. No se mezcla con el generador del portador (`CollectibleRun`) ni con el del `WaveSpawner`, así que `technology` y las oleadas **no cambian** con M50.

#### Reglas del flujo (qué llama a qué)

1. **Elegir.** `BuildController._handle_selection_input` pregunta al `InfrastructureController` `obstacle_at(cell)` antes de mirar torres; si hay uno, lo selecciona y emite `obstacle_selected(spec, state)` (el HUD abre el `ObstaclePanel`). Deselecciona lo demás (RF-73) y `Esc` o un clic fuera lo cierran. En modo construcción, el clic sobre un removible **selecciona**, no construye.
2. **Demoler.** `ObstaclePanel` emite `demolish_pressed(cell)`. El controlador comprueba `can_order` y `session.can_afford(cost_of(cell))`, **cobra con `session.spend`**, llama a `field.order(cell)` y empieza a llamar a `field.tick(delta)` desde su `_process`. El controlador se crea con `process_mode = PAUSABLE`, igual que los nodos del mundo (se suma a `Game._world_nodes()`, junto a `enemies` y `tower_container`, y también al congelado de `_on_state_changed`), y `Engine.time_scale` ya escala el `delta`: así la **pausa y la velocidad se respetan sin código extra**.
3. **Terminar.** `job_finished` → el controlador llama a `MapGrid.clear_cell(cell)`, suma recursos a la sesión (`add_resources`), y si hay hallazgo y se recoge (RF-429) llama a `FindingRun.pick(colección, nivel, wave_to_confirm)` con `wave_to_confirm = wave` si el estado es `WAVE_RUNNING` y `wave + 1` en cualquier otro. Emite un aviso flotante (`floating_text.gd`) y un sonido ya existente.
4. **Cancelar.** `session.earn(refund)` (el reembolso no es ganancia: no entra en estadísticas de oro ganado, si las hay) y `field.cancel()`.
5. **Oleada completa.** El controlador escucha `session.wave_completed`: `field.complete_wave()` devuelve lo que produjo cada punto y lo suma a `session.add_resources`; `FindingRun.complete_wave(wave)` confirma. **No** escucha `jump_to_wave` (que no emite `wave_completed`).
6. **Fin de partida.** En `Game._on_state_changed` (WON/LOST), `field.discard_job()` y, junto a `_commit_collection`, se llama a `_commit_findings()`: guarda las piezas confirmadas con `SaveManager.collect_source` (y `SaveManager.save()` como hoy) si **no** `DevMode.enabled`, **no** `testing`, hay campaña (`GameFlow.current_index >= 0`), ni comunidad ni modo.

#### Archivos que toca cada tarea

| Tarea | Crea | Modifica |
|---|---|---|
| **T206** · formato | `data/obstaculos.json`, `scripts/logic/obstacle_catalog.gd`, `scripts/data/obstacle_spec.gd`, `tools/ejemplos/mapa_removibles.json`, tests | `scripts/logic/level_file.gd` (`LEGEND_KEYS`, `_read_legend`, claves `demoledora`), `scripts/data/level_data.gd`, `scripts/logic/map_grid.gd` (`clear_cell`), `scripts/logic/map_drawings.gd` (3 dibujos), `scenes/levels/level_decor.gd`, `tools/check_level.gd`, `scripts/logic/level_draft.gd` (conserva campos), `CONTENIDO.md` |
| **T207** · demolición | `scripts/logic/obstacle_field.gd`, `scripts/logic/demolition_job.gd`, `scenes/game/infrastructure_controller.gd`, `scenes/ui/obstacle_panel.gd`, `scenes/levels/obstacle_layer.gd`, tests | `scenes/game/game.gd` (crea el controlador, la semilla, el fin de partida), `scenes/game/build_controller.gd` (selección), `scenes/game/hud.gd` (abre el panel) |
| **T208** · demoledora | `scenes/ui/infrastructure_panel.gd` | `obstacle_field.gd` (`buy_machine`, `cost_of`, `seconds_of`), `hud.gd`, `obstacle_panel.gd` (muestra "Con la demoledora…") |
| **T209** · recursos | tests | `level_session.gd` (`resources`, `spend_both`), `tower_data.gd`, `tower.gd`, `build_controller.gd`, `hud.gd` (contador, barra, ayuda de construcción con los dos botones de pago), `tower_panel.gd`, `tower_text.gd`, `wiki.gd`, `data/towers/mortar.tres`, `data/towers/sniper.tres`, `check_level.gd` (aviso RF-421), `CONTENIDO.md` |
| **T210** · extracción | tests | `obstacle_field.gd` (`enable_site`, `complete_wave`), `infrastructure_controller.gd`, `obstacle_panel.gd`, `obstacle_layer.gd` (estados y reserva) |
| **T211** · colecciones | `scripts/logic/collection_definitions.gd`, `scripts/logic/finding_run.gd`, tests | `collectible_run.gd` (envoltorios), `save_manager.gd` (solo lo que haga falta; el formato **no cambia**), `data/progression.json`, `game.gd` (`_commit_findings`), `hud.gd` (la barra elige la colección del nivel), `scripts/logic/wiki.gd` |
| **T212** · editor | tests | `scripts/logic/level_draft.gd`, `scenes/editor/map_editor.gd`, `editor_panel.gd`, `settings_panel.gd`, `map_view.gd` |
| **T213** · pruebas | tests | `scenes/game/dev_panel.gd`, `scripts/autoload/dev_mode.gd`, `scenes/game/game.gd` (los atajos) |
| **T214** · bot | tests | `tools/balance_sim.gd` (estrategias, `seeds=`, `check_rule=1`) |

`T215` y `T217` (Disruptora) **reusan** `resource_cost` (2 recursos, 130 de oro) y la colección `disruptor`. `T223` a `T225` usan `obstaculos.json` y la regla de oro. `T219` a `T221` usan la lista de estados que sigue.

#### Estados visuales que dibuja Codex (T219 a T221)

La vista decide qué dibujar así: la **clase** del obstáculo (`arbol`, `roca`, `escombro`, `mina`, `bosque_explotable`) y su **estado**. Todo es SVG de **64 × 64** con sombra suave en el suelo (Q-38, guía §4). Mientras no llegue el arte, `ObstacleLayer` dibuja los mismos estados con figuras simples. Los nombres son una propuesta para que Codex y el código se pongan de acuerdo; se guardan en `assets/sprites/map/` salvo los íconos.

| Estado | Archivo propuesto | Cuándo se ve | Notas |
|---|---|---|---|
| Árbol removible, **intacto** | `arbol_removible.svg` | Letra con `removible` de clase `arbol`, sin trabajo | Distinto del árbol permanente. Lleva la **marca ámbar** (cinta o estaca). |
| Árbol removible, **en trabajo** | `arbol_removible_trabajo.svg` | Mientras dura el trabajo | Andamio, hacha clavada o cortes. |
| Roca removible, intacta / en trabajo | `roca_removible.svg`, `roca_removible_trabajo.svg` | Ídem con `roca` | Misma marca ámbar. Cuñas y grietas en trabajo. |
| Escombro, intacto / en trabajo | `escombro.svg`, `escombro_trabajo.svg` | Ídem con `escombro` | Piedra de ruina con el símbolo (T218). Marca ámbar. |
| **Pieza pendiente** | `marca_pieza.svg` (32 × 32) | Sobre un escombro con hallazgo **pendiente** | Brillo plateado. No se ve si ya está recuperada o si no se recogen piezas. |
| **Despejado** | `despejado_<tema>.svg` para `pradera`, `bosque`, `ruinas` y `desierto` | Casilla ya despejada | Suelo con tocón o restos chatos, **construible** (que no parezca bloqueado). Un tema sin archivo usa `despejado_pradera.svg`. |
| Mina, **sin habilitar** / **activa** / **agotada** | `mina.svg`, `mina_activa.svg`, `mina_agotada.svg` | Estados `DISABLED`, `ACTIVE`, `DEPLETED` | Boca con tablas; vagoneta y brillo de mineral; tapiada. **No se confunde con una torre.** |
| Bosque explotable, **sin habilitar** / **activo** / **agotado** | `bosque_explotable.svg`, `bosque_explotable_activo.svg`, `bosque_explotable_agotado.svg` | Ídem | Árboles marcados; troncos apilados; tocones. Distinto del árbol removible. |
| **Reserva legible** | `reserva_llena.svg`, `reserva_vacia.svg` (8 × 8) | Sobre un punto de extracción habilitado | 8 segmentos; legibles a 34 px. |
| Máquina trabajando *(opcional)* | `demoledora_trabajo.svg` (2 a 4 cuadros) | Sobre el removible durante un trabajo **con** la máquina | Solo si Lucas lo pide en la ficha de arte. |
| Íconos | `assets/sprites/ui/stat_resources.svg`, `coleccion_disruptor.svg`, `demoledora.svg` | Contador de recursos y costos; barra de la colección y panel; botón "Infraestructura" | Mismo formato que `stat_gold.svg` y el avance plateado (Q-39). |

La **barra de progreso** del trabajo y el aviso flotante los dibuja el código (no son arte).

#### Riesgos y límites conocidos

- **El tope de 10 letras** de la leyenda (RF-262) puede quedar corto en un nivel con muchos tipos de objeto: se resuelve en la tarea del nivel (punto 6 de "Para revisar en G3").
- **`tiempo_porcentaje` (80 %) y las probabilidades** (50 %) no están medidos: salen del 09 y de la intuición, no del bot. T214 y T223 los revisan.
- **`FindingRun` y `CollectibleRun`** conviven. Si en T211 resulta más claro unificarlos, se hace sin cambiar el comportamiento ni los tests de M37 y M38, y se anota.
- El **bot** (`balance_sim.gd`) no es determinista en el oro (se vio en T203); para la regla de oro se usa el resultado de victoria, no el oro final.
