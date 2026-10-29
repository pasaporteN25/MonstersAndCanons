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
JuegoA/   # (la carpeta del repositorio no se renombra; el juego es «Monsters & Canons», T237)
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
│   ├── perf_test.gd              ← prueba de rendimiento con ventana (T56, P7)
│   └── perf_levels.gd / .tscn    ← rendimiento de un nivel real con sus oleadas finales (T236, P7)
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
- *(M60, RF-520 a RF-522)* Antes de la primera escritura de cada ejecución, `save()` copia el `save.json` existente a `user://save_respaldo_<versión>.json` (una copia por versión de la build, sin pisar nunca una anterior). Ver la sección M60 más abajo.
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
- **Revisión (T256, D-095):** el modo gana una tabla opcional de porcentajes de vida por mapa y Asedio pasa a 15 mapas; el diseño está en **M56 / T256**, más abajo. Todo lo de esta sección sigue valiendo.

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

### M51 / T215 · Disruptora (RF-438 a RF-452, D-086 y D-087)

**Estado: diseño; todavía no hay código.** Se programa en **T217** (con arte provisional hecho por código, Q-40); el arte final es de Codex (**T216**, ficha en `art/m51-disruptora/FICHA.md`). Depende de **T209** (`resource_cost`) y de **T211** (la colección `disruptor`): sin ellos, T217 **no puede terminar** la parte de disponibilidad. Está escrito para que un Sonnet en esfuerzo medio lo implemente **sin tomar decisiones de diseño**.

#### Datos

- **`scripts/data/tower_level_data.gd`** suma `@export var suppress_seconds: float = 0.0` (RF-439; comentario: "segundos que un enemigo con aura alcanzado por el pulso deja de emitir su aura; 0 = no es una torre de pulso"). **Es la única clase de datos que cambia.** `TowerData` no cambia (usa `reserved`, `required_collection` y, de T209, `resource_cost`).
- **`data/towers/disruptor.tres`** (nuevo, copiar la estructura de `tesla.tres`): `id = &"disruptor"`, `display_name = "Disruptora"`, `description` (una frase: *"Apaga un rato el aura del Guardián y del Curandero. Casi no hace daño."*), `can_hit_air = true`, `reserved = true`, `required_collection = &"disruptor"`, `resource_cost = 2`, `color` blanco azulado (`Color(0.86, 0.92, 1.0)`). Sin `projectile_texture` ni `projectile_speed_tiles` (no dispara). Tres niveles:

  | Nivel | `cost` | `damage` | `fire_rate` | `range_tiles` | `suppress_seconds` |
  |---|---|---|---|---|---|
  | 1 | 130 | 5 | 0.25 | 2.5 | 2.5 |
  | 2 | 100 | 5 | 0.25 | 3.0 | 3.0 |
  | 3 | 150 | 5 | 0.25 | 3.5 | 3.5 |

  Los costos de los niveles 2 y 3 son **provisionales** (RF-446). Sin `turret_atlas` ni `base_texture` hasta T216: la torre cae a la forma de color (RF-156) y T217 le suma el dibujo provisional por código. Con T216, se agregan `turret_atlas`, `turret_texture` y las variantes de nivel 2 y 3, y **solo** esas rutas.
- **`scenes/game/game.tscn`:** `tower_types` suma `disruptor` **al final** (después del Mortero): es la décima. **No se tocan las teclas** (RF-448): la posición en la barra del nivel manda.
- **`CONTENIDO.md`:** una fila nueva en la tabla de campos de torre para `suppress_seconds`, marcada *"todavía no la lee el juego"* hasta T217, y una nota de que la Disruptora necesita su colección y los recursos.
- **El texto de los enemigos con aura** (`has_aura`) **no se escribe a mano**: se lee de los datos (RF-450).

#### Lógica

- **`scenes/enemies/enemy.gd`** (enemigo):
  - `var _suppress_left: float = 0.0` y tres funciones: `suppress(seconds: float)` (si `_is_done` o `not has_aura()`, no hace nada; si no, `_suppress_left = maxf(_suppress_left, seconds)` y `queue_redraw()` si pasó de 0 a mayor), `is_suppressed() -> bool` y `suppress_left() -> float`.
  - **`_update_aura(delta)`:** baja `_suppress_left` con el tiempo del juego (se agrega **antes** de `if not has_aura()`) y, al llegar a 0, `queue_redraw()`. El **timer de emisión** `_aura_pulse_left` **sigue corriendo** durante la supresión, pero `_pulse_aura()` **no se llama** mientras `is_suppressed()`: al vencer, vuelve a emitir en menos de `AURA_TICK` (RF-442). **Una línea**: `if _aura_pulse_left <= 0.0 and not is_suppressed()`; si está suprimido, no recarga el timer hasta que venza (así vuelve a emitir en el acto).
  - **`receive_aura` y las funciones de armadura y cura no cambian** (RF-443).
  - `func is_pulse_immune() -> bool: return data.reflect_range_tiles > 0.0` (RF-444). `Enemy.GROUP` y `is_active()` ya existen.
  - **Dibujo:** en `_draw_aura_ring()`, si `is_suppressed()`: en vez de los anillos marfil o verde, `draw_arc` de **4 arcos separados** (≈ 60° de arco y 30° de hueco) de color `SUPPRESS_COLOR` (blanco azulado, alfa 0,45, **sin latido**, grosor 1,2). En `_draw_aura_icons`: el **ícono de supresión** (3 arcos de un anillo roto sobre un círculo `AURA_INK` de 6,5 px, blanco azulado; se apagan de a uno con `suppress_left() / suppress_total`; hace falta guardar `_suppress_total` para eso) **va en la misma fila**, delante del escudo y la cruz, y **la condición de salida temprana** (`if _aura_armor <= 0 and _aura_heal <= 0.0 and marks.is_empty(): return`) **también tiene que considerar** `is_suppressed()`. El cuerpo **no se tiñe** (`SLOW_MODULATE` queda solo para la ralentización, RF-449).
  - Constantes nuevas: `SUPPRESS_COLOR := Color(0.86, 0.92, 1.0)` y `SUPPRESS_EDGE := Color(0.50, 0.66, 1.0)`.
- **`scenes/towers/tower.gd`** (torre):
  - `signal pulsed(radius_px: float)` (señal **hacia arriba**, P6; `Game` la conecta, como `fired`).
  - `func is_pulse_tower() -> bool: return stats().suppress_seconds > 0.0`.
  - En `_physics_process`, **antes** del `elif _cooldown <= 0.0` de los disparos: `elif _cooldown <= 0.0 and is_pulse_tower(): _fire_pulse()` (después del aturdimiento y de `support_only`, así que una torre aturdida **no pulsa**, RF-445).
  - `func _fire_pulse() -> void`: busca los enemigos activos a menos de `range_px()` (`get_tree().get_nodes_in_group(Enemy.GROUP)`, `is_active()`, `not is_pulse_immune()`); **si ninguno** `has_aura()`, **sale sin tocar** `_cooldown` (RF-440); si hay, a **cada uno** `take_hit(stats().damage)` (sin ralentización y sin combos) y a los `has_aura()`, además, `suppress(stats().suppress_seconds)`; `_cooldown = 1.0 / effective_fire_rate()`; `_flash_left = FLASH_DURATION`; `pulsed.emit(range_px())`. **Se junta la lista primero y se aplica después** (un golpe que mata libera el nodo y no debe romper el recorrido).
  - `can_target`/`find_target` **no se usan** para el pulso. `cycle_targeting` queda sin efecto visible para esta torre: el panel **esconde** el botón de apuntado cuando `is_pulse_tower()` (igual que la Ráfaga si ya lo hace; si no, se deja y se anota).
  - **Dibujo provisional:** si no hay `turret_atlas`, `_draw` pinta una **pila de 3 anillos** que se ensanchan hacia arriba y un **disco** blanco azulado arriba; el disco se enciende cuando `_cooldown <= 0` y hay un emisor en el radio (se calcula cada 0,25 s, no en cada cuadro) y se apaga si está aturdida (RF-449).
- **`scenes/effects/effects_layer.gd`:** `func pulse_ring(position_: Vector2, radius: float)`: **dos** `RingEffect` (el principal con `SUPPRESS_COLOR`, de `radius * 0.2` a `radius`, 0,3 s, grosor 3; y uno más fino y más tenue, de 0,35 s, grosor 1,4), con un tope de **8 anillos** vivos. Lo llama `Game` desde la señal `pulsed`; respeta pausa y velocidad como el resto.
- **`scenes/game/game.gd`:** conecta `tower.pulsed` (como `tower.fired`, línea ~493) a `effects.pulse_ring` y a un **sonido** (reusar el del rayo o uno nuevo chico: el audio es de T217, no bloquea). **No** cambia la creación de torres ni la disponibilidad (T209 y T211 ya lo resolvieron).
- **Texto:** `scripts/logic/tower_text.gd` suma `pulse_line(level: TowerLevelData, emitters: Array[String]) -> String` (arma *"Pulso cada 4 s · radio 2,5 · apaga las auras 2,5 s · 5 de daño"* con `Rules`/números formateados como las otras) y `suppressors_of(enemy: EnemyData, towers: Array[TowerData]) -> Array[String]` (los nombres de las torres con `suppress_seconds > 0` en algún nivel, **solo si el enemigo tiene aura**). `scripts/logic/wiki.gd`: la ficha de la torre usa `pulse_line` y la frase de RF-450; la del enemigo con aura suma *"Contramedida: …"* con `suppressors_of` (**un apartado como el de "Combos"** de RF-317). `data/wiki/efectos.json`: un bloque nuevo sobre la supresión, **sin números**. El panel (`tower_panel`), `effects()` y la barra de construcción llaman a lo mismo.
- **`tools/balance_sim.gd`** (RF-452): una función `_wants_disruptor() -> bool` (disponible + algún grupo de las oleadas con `EnemyData.has_aura`-equivalente: `aura_radius_tiles > 0` y bono o cura > 0 + 3 torres comunes + máximo 2); en `_buy_towers()` de `mix` la compra **por id** (`game.available_towers`), no por posición, **antes** de seguir con `MIX_ORDER`. `sin_recursos` (T214) nunca la compra.
- **`tools/check_level.gd`:** el aviso de RF-421 ya cubre "torre con `resource_cost` en un mapa sin recursos" (T209); T217 comprueba que **nombre a la Disruptora** en el mensaje (se arma con `display_name`, no a mano).
- **`tools/ejemplos/mapa_disruptora.json`** (nuevo): un mapa de ejemplo con `"torres": ["cannon", "frost", "disruptor"]`, una roca con `probabilidad: 100` (para tener los 2 recursos) y grupos con Guardianes y Curanderos. Sirve para el criterio de aceptación del bot y para probarla en el modo de pruebas.

#### Qué toca cada tarea

| Tarea | Archivos nuevos | Archivos que cambia |
|---|---|---|
| **T216** · arte | `art/m51-disruptora/` (fuentes, `prompts.md`, `manifest.json`, `pack.gd`, hojas y capturas), `assets/sprites/towers/rendered/disruptor_atlas.png`, `turret_disruptor.png`, `disruptor_level_2.png`, `disruptor_level_3.png`, una textura de anillo de pulso y el ícono de supresión (32 × 32) | Solo, si T217 ya creó la torre: las rutas de textura de `data/towers/disruptor.tres`. **Ningún código.** |
| **T217** · código | `data/towers/disruptor.tres`, `tools/ejemplos/mapa_disruptora.json`, `tests/test_disruptor_pulse.gd`, `tests/test_disruptor_text.gd` | `scripts/data/tower_level_data.gd`, `scenes/enemies/enemy.gd`, `scenes/towers/tower.gd`, `scenes/effects/effects_layer.gd`, `scenes/game/game.gd` y `game.tscn`, `scenes/ui/tower_panel*` (apuntado), `scripts/logic/tower_text.gd`, `scripts/logic/wiki.gd`, `data/wiki/efectos.json`, `tools/balance_sim.gd`, `tools/check_level.gd` (solo si hace falta), `CONTENIDO.md`, `CHANGELOG.md` |

#### Pruebas que T217 tiene que escribir (todas con GUT, sin cambiar de escena)

1. **Enemigo:** suprimido no emite (el Normal junto al Guardián no recibe el +2 pasados 0,35 s); al vencer vuelve a emitir; refrescar toma el **máximo**; `suppress` en un enemigo **sin aura** no hace nada; en pausa no corre; el timer de emisión no se desfasa.
2. **Torre:** pulsa solo con un emisor a su alcance y no gasta su espera si no hay; **todos** los alcanzados reciben `damage − armadura` (mínimo 1); el **Espejo** no recibe nada y la torre **no** queda aturdida; el Chamán, el Ladrón y el Embestidor reciben el golpe y siguen con su habilidad; un volador sin aura recibe el golpe; **aturdida no pulsa** y al recuperarse pulsa; el **desgaste** espacia los pulsos (40 → cada 6,67 s); el **Mecánico** de nivel 3 la acelera (3,33 s) y con la Disruptora de nivel 3 no hay hueco; un golpe que mata no rompe el recorrido; mejorar a 2 y 3 cambia radio y supresión.
3. **Datos:** `disruptor.tres` cumple RF-446 (3 niveles, números), `reserved`, `required_collection`, `resource_cost = 2`, sin `burst_count`/`extra_targets`/`chain_extra_targets`/`splash_radius_tiles`/ralentización/quemadura (RF-439); **no aparece** en los niveles 1 a 10 y sí en un mapa que la nombra con la colección completa; sin colección no aparece aunque la nombre (RF-395).
4. **Costo:** 130 de oro + 2 recursos juntos o ninguno; mejorar sin recursos; vender devuelve 91 y 1 (RF-418).
5. **Texto y Wiki:** `pulse_line` sale de los datos y cambia si se cambia el `.tres`; el Guardián y el Curandero **nombran** a la Disruptora y la Wiki no la nombra en un enemigo **sin** aura; el artículo de efectos no repite números.
6. **Vista:** el anillo y el ícono se dibujan sin errores (con un Guardián suprimido); el tope de 8 anillos.
7. **Bot:** compra la Disruptora en el mapa de ejemplo con 3 torres y como mucho 2; `sin_recursos` nunca; un mapa sin emisores, nunca.

#### Cómo se comprueba que sirve (RF-452)

Con `tools/ejemplos/mapa_disruptora.json` y **3 semillas** (`seed=`), el bot `mix` **con** y **sin** la Disruptora (`disruptor=0`, una opción nueva de la herramienta, valor por omisión 1). Se anotan en el Resultado de T217 las **vidas perdidas** y la **oleada donde se pierde** de cada corrida. El bot no es determinista en el oro (T203): se mira la **victoria y las vidas**, no el oro final. **Si con la Disruptora no se pierde menos, se frena y se avisa.**

#### Riesgos y límites conocidos

- **Los números de mejora (100 y 150) y la cobertura** no están medidos: son valores iniciales (RF-446).
- **El color blanco azulado y el celeste del Hielo** se parecen: la separación depende de la forma y del lugar (RF-449); hay que mirarlo en una captura real de T216/T217.
- **La décima torre y las teclas** (RF-448): un nivel con más de 9 torres deja a la Disruptora o al Mecánico sin tecla.
- **El Espejo se excluye por `reflect_range_tiles`** (D-087): un enemigo nuevo con rebote queda fuera del pulso sin avisar; es lo buscado, pero hay que recordarlo al crear enemigos.
- **El desgaste** hace que la Disruptora deje de ser útil rápido (un solo impacto la lleva a 20 %): es lo que pide RF-367 para cualquier torre.

### M52 / T227 · Lore en el juego y bloque 3 (RF-464 a RF-480, D-089 a D-091)

**Estado: T228 programada (2026-10-09): textos por nivel, tarjeta, cartel, victoria y Wiki Lore (ver «Lo que cambió al programarla» al final de esta sección); el epílogo, los créditos y el nivel 15 se programaron en T234 (2026-10-09; ver «Lo que cambió al programarla (T234)» al final de esta sección).** Se programó en **T228** (textos, cartel, tarjeta, Wiki Lore) y se programa en **T234** (epílogo y créditos, junto con el nivel 15), después del OK de Lucas a la spec (M52, §7.13 a §7.17) y a los textos (`specs/11-textos-lore.md`). Los niveles 11 a 14 son **solo datos** (T229 a T232). Es todo interfaz y datos: **ninguna regla de combate ni número de balance cambia**.

#### Qué hay hoy (leído en T227)

- `scripts/logic/level_file.gd`: `LEVEL_KEYS` (línea 14) lista las claves permitidas del nivel; una clave que no está es un error (RF-204). `MAX_NAME_LENGTH = 30`. `LevelFile.parse` arma un `LevelData`.
- `scenes/ui/level_select.gd`: `_make_card(index)` arma el texto de la tarjeta (`"Nivel %d\n%s\n%d oleadas\n%s\n\n"`) y `card.disabled = not GameFlow.is_level_unlocked(index)`; la tarjeta mide `CARD_SIZE = (200, 214)`.
- `scripts/autoload/game_flow.gd`: `start_level(index)` cambia a la escena de la partida; «Siguiente nivel» es `GameFlow.next_level`; `has_next_level()` dice si hay otro. `Reintentar` es `restart()` en `scenes/game/game.gd` (línea ~365), que hace `reload_current_scene()`: **no pasa por `start_level`**.
- `scenes/ui/end_screen.gd`: `show_victory(lives_left, stars, has_next, in_campaign, score)` arma «¡Victoria!», estrellas, `Detail` (vidas), puntos y récords; `_next_button` es «Siguiente nivel».
- `scripts/logic/wiki.gd`: `categories()` recorre `_providers()` (cuatro hoy: enemigos, torres, colecciones y guía; el encabezado dice que sumar una categoría es una función y una línea). `articles(dir)` lee todos los `.json` de **una carpeta** (no baja a las subcarpetas) y `parse_article()` valida con `ARTICLE_KEYS`. `WikiEntry.locked` ya existe (bestiario) y `WikiCategory` ya cuenta `has_locked()` y `unlocked_count()`; `wiki_screen.gd` ya escribe «n/m» en la solapa.
- `scripts/autoload/save_manager.gd`: `is_completed(level_id)`; **ya basta** para el desbloqueo, no hace falta ningún campo.
- `data/campaign.json` (`"niveles"`) manda en el orden de la campaña; hoy son 10.

#### Archivos

**Lógica pura** (`scripts/logic/`, sin escena, con tests; P10):

- **`level_texts.gd`** (`class_name LevelTexts`, nuevo): constantes de largo (`LUGAR_MAX = 32`, `ENTRADA_MAX_LINES = 3`, `ENTRADA_MAX_CHARS = 240`, `VICTORIA_MAX_LINES = 2`, `VICTORIA_MAX_CHARS = 160`, `EPILOGO_MIN_LINES = 3`, `EPILOGO_MAX_LINES = 5`, `EPILOGO_MAX_CHARS = 400`, `LINE_MAX = 90`; son de interfaz y no de balance, así que viven en el código, como las de `BarLayout`) y `static func parse(raw: Variant, errors: PackedStringArray) -> Dictionary` que devuelve `{lugar, entrada, victoria, epilogo}` con **cadenas vacías** donde falta. Reusa el estilo de mensajes de `LevelFile` (`_check_keys`, que lista las claves válidas).
- **`lore_unlock.gd`** (`class_name LoreUnlock`, nuevo): `static func is_open(unlock_level: StringName, is_completed: Callable) -> bool`; `static func locked_text(unlock_level: StringName, campaign_ids: Array) -> String` arma *«Se abre al ganar el nivel N.»* con el **número** del nivel en la campaña (nada de su nombre).
- **`scripts/data/level_data.gd`**: nuevo campo `texts: Dictionary` (o cuatro `String`: `place_text`, `intro_text`, `win_text`, `epilogue_text`) y `func has_texts() -> bool`.
- **`scripts/logic/level_file.gd`**: `"textos"` entra en `LEVEL_KEYS`; `parse` lo pasa por `LevelTexts.parse` y lo guarda en el `LevelData`. El **guardado del editor** (`level_file` ↔ `LevelData` para el editor) lo conserva tal cual, como la leyenda (RF-266); buscar dónde se serializa el nivel antes de tocar.
- **`scripts/logic/wiki.gd`**: `ARTICLE_KEYS` no cambia para la Guía. Un parámetro nuevo de `parse_article`/`articles` (`lore: bool`) que, si es verdadero, **exige** y valida `"desbloqueo"` (y la Guía lo rechaza como clave desconocida). Un proveedor nuevo `{"id": &"lore", "title": "Lore", "build": _lore_entries}` **después** de la Guía; `_lore_entries` lee `res://data/wiki/lore/` y marca `locked` cada entrada cuyo nivel no está completo (`LoreUnlock`). Para el aviso de «cerrado», la entrada lleva el texto de `LoreUnlock.locked_text()` y **ningún bloque real**.
- **`scripts/logic/credits.gd`** (`class_name Credits`, nuevo, opcional): lee `data/creditos.json` (`version` y `lineas`) con los mismos controles de forma que los otros JSON de datos.

**Interfaz** (`scenes/ui/` y `scenes/game/`):

- **`scenes/ui/level_select.gd`**: `_make_card` suma, si el nivel está desbloqueado y tiene `place_text`, una línea debajo del nombre. El tamaño de la tarjeta (`CARD_SIZE`) **no cambia**; si no entra, se corta con «…» y el `tooltip_text` lleva el texto completo.
- **`scenes/ui/level_intro.gd`** + `level_intro.tscn` (`class_name LevelIntro`, `CanvasLayer`, nuevo): el cartel de RF-466, modelado sobre `PauseMenu` (mismo panel y atenuado). `open(title, place, lines)`, `signal closed`. Cierra con clic o toque, `Espacio`, `Enter`, `Esc` o el botón «Empezar». No sabe de la partida: solo muestra y avisa.
- **`scenes/game/game.gd`**: en `_ready`, si `GameFlow.intro_pending` y el nivel tiene `intro_text` y no es modo de pruebas ni «Probar», abre `LevelIntro`, **pausa** (`set_paused(true)`, guardando el estado anterior como hace el diálogo de salida de M53) y al `closed` restaura. `GameFlow.intro_pending` es un `bool` de ejecución (no se guarda): lo pone en `true` **`start_level`** (y por lo tanto «Siguiente nivel») y lo consume `Game._ready`; `restart()` no pasa por `start_level`, así que el reintento **no** lo muestra. `start_community`, `start_mode_level` y `play_test` dejan `intro_pending` en `false` salvo que el archivo del mapa traiga `"entrada"` (RF-468; **modo oficial → nunca**).
- **`scenes/ui/end_screen.gd`**: `show_victory` recibe además `win_text: String` y `has_epilogue: bool`; muestra el texto bajo las estrellas (en `Detail` o un `Label` nuevo antes de los puntos) y, si `has_epilogue`, **reemplaza** el texto de `_next_button` por «Epílogo» (señal nueva `epilogue_pressed`). `Game` decide `has_epilogue`: partida de campaña, último nivel de `campaign.json`, `epilogue_text != ""`.
- **`scenes/ui/epilogue_screen.gd`** + `.tscn` (nuevo, T234): imagen de fondo (la de T233, o el cielo provisional dibujado con `_draw`), franja de texto y botones «Créditos» y «Niveles». **`scenes/ui/credits_screen.gd`** + `.tscn` (nuevo): texto centrado con `ScrollContainer`, botón «Volver».
- **`scenes/ui/wiki_screen.gd`**: sin cambios previstos (ya dibuja entradas cerradas y el «n/m»); T228 comprueba que una entrada cerrada **sin dibujo** no rompe `WikiIcon`.
- **Editor** (`scenes/editor/`): conserva `"textos"` (un campo más en lo que se carga y se guarda). **No** hay pantalla de edición.

**Datos:**

- `data/levels/level_01.json` a `level_10.json`: se les suma `"textos"` en T228. `level_11.json` a `level_15.json`: nacen con `"textos"` en T229 a T232 y T234.
- `data/wiki/lore/*.json` (10 artículos, T228) y `data/creditos.json` (T234).
- `data/campaign.json`: suma `level_11` a `level_15` **de a uno**, en cada tarea de nivel (así la campaña nunca apunta a un archivo que no existe).

#### Orden de trabajo

1. **T228 · lógica y datos primero:** `LevelTexts`, `LevelData`, `LevelFile`; sus tests. Correr todo.
2. **T228 · selección y victoria:** `level_select` (tarjeta) y `end_screen` (`win_text`); tests con la escena y con un nivel de mentira.
3. **T228 · cartel:** `LevelIntro` y el `intro_pending` de `GameFlow`; test de que `restart()` no lo abre, que pausa y restaura, y que no aparece en modo de pruebas, «Probar» ni Asedio.
4. **T228 · Wiki Lore:** `Wiki` (proveedor, parámetro `lore`), `LoreUnlock`, los 10 artículos y sus tests con un guardado de prueba (`user://test_*.json`).
5. **T228 · cargar los textos aprobados** en los niveles 1 a 10 y en `data/wiki/lore/`, **copiados de `11-textos-lore.md`**. Capturas de PC y de tamaño celular.
6. **T229 a T232:** niveles 11 a 14 (solo datos), cada uno con sus textos y su RF de campaña.
7. **T234:** nivel 15, `EpilogueScreen`, `CreditsScreen`, `data/creditos.json`, el botón «Epílogo».

#### Pruebas que T228 y T234 tienen que escribir

1. **`LevelTexts`:** sin campo → todo vacío y sin errores; cada clave válida sola; una clave desconocida lista las válidas; valor que no es texto; texto vacío; 4 líneas de entrada; 3 de victoria; una línea de 91 caracteres; 241 caracteres de entrada; control `\u0001`; el epílogo de 2 y de 6 líneas.
2. **Niveles oficiales:** los 15 (según vayan existiendo) cumplen los límites y **sus textos son los de `11-textos-lore.md`** (un test lee el documento y compara; si eso resulta frágil, compara contra una copia en `tests/fixtures/`).
3. **Tarjeta:** el lugar aparece en una tarjeta desbloqueada y no en una bloqueada; el tamaño no cambia; sin `"textos"` es idéntica a la de hoy.
4. **Cartel:** aparece al entrar con `start_level`; no al `restart()`; pausa y restaura (cuenta atrás intacta y velocidad conservada); no aparece en el modo de pruebas, probando, ni desde Asedio; sí en un mapa de la comunidad que trae `"entrada"`.
5. **Victoria:** el texto sale bajo las estrellas; en el último nivel de la campaña el botón dice «Epílogo» y no hay «Siguiente nivel»; desde un mapa de la comunidad no.
6. **Wiki Lore:** guardado nuevo → 0/10 y todas cerradas; con el nivel 1 ganado → «El oasis» abierto; el texto de la cerrada dice el número y no el nombre; un artículo sin `"desbloqueo"` falla el test oficial; la Guía conserva sus artículos; modo de pruebas → todo abierto.
7. **Epílogo y créditos (T234):** el flujo victoria → epílogo → créditos → volver; **el guardado no cambia** antes y después de verlo.
8. **Los tests existentes** que cuentan categorías de la Wiki, botones de la victoria o claves de nivel se actualizan; el total no baja de la línea de base.

#### Riesgos y cosas que no se saben

- **La tarjeta:** no se midió si 32 caracteres entran en 200 px a la letra de la tarjeta. Si no entran, se baja el límite o la tarjeta usa dos líneas.
- **El cartel en el celular:** no se probó el tamaño táctil de «Empezar» ni que el cartel no tape el botón de pausa. T228 hace la captura.
- **`Esc` con el cartel abierto:** hoy `Esc` abre el menú de pausa; el cartel debe recibir `Esc` **antes** (igual que `BuildController` recibe `Esc` primero). Hay que confirmarlo con una prueba en la escena real.
- **El guardado de `LevelData` en el editor:** no se miró en esta tarea cómo serializa los campos que no edita. Si el editor reconstruye el nivel campo por campo, `"textos"` se perdería; T228 lo prueba con un nivel real.
- **La central de cuatro dibujos (T233/T234):** el formato de los cuartos (SVG o PNG de 64 × 64, con alfa y anclajes estables) y cómo se ve junto a la salida no se probó. Si T233 propone otro formato, decide Lucas en el concepto.
- **Los niveles 11 a 14 dependen de G4** (§7.13): si la partida de Lucas del 6 al 10 cambia algo de demolición, del Mortero o de la Disruptora, las fichas se ajustan antes de T229.

#### Lo que cambió al programarla (T228, 2026-10-09)

- **Archivos reales:** `scripts/logic/level_texts.gd` (`LevelTexts`: `parse`, límites, mensajes), `scripts/logic/lore_unlock.gd` (`LoreUnlock`: `is_open`, `locked_text`, `level_number`), `scenes/ui/level_intro.gd` y `.tscn` (`LevelIntro`). `LevelData` guarda **cuatro `String`** (`place_text`, `intro_text`, `win_text`, `epilogue_text`) y `has_texts()`. `GameFlow.intro_pending` (se enciende en `start_level`, `start_community` y `start_mode_level`, y se apaga en `play_test`) lo consume `Game._ready`; la regla de si se muestra es `Game.shows_texts()` (no en modo de pruebas ni «Probar», ni en un modo oficial).
- **El cartel** atiende todo en `_input` (así `Esc` le gana al menú de pausa): `Espacio`, `Enter`, `Esc` y el **soltar** del clic cierran; el apretar del clic se traga (el toque del celular llega como clic emulado y no tiene que llegar a la construcción). Mientras está abierto: `set_paused(true)` + `build_controller.input_blocked`, como el diálogo de la flecha.
- **Wiki:** `Wiki.categories(campaign, is_seen, is_completed)` recibe una tercera función; `articles(dir, lore, campaign_ids)` y `parse_article(text, id, lore, campaign_ids)` exigen `"desbloqueo"` y que figure en la campaña; `locked_lore_entry` arma la entrada cerrada. `WikiScreen.is_completed` es la costura de los tests y vale `DevMode.enabled or SaveManager.is_completed`.
- **Editor:** `LevelDraft.from_text` conserva `"textos"` y `to_text` lo escribe en el mismo formato de los niveles oficiales (una clave por renglón), así que abrir y guardar un nivel oficial da el mismo texto (lo comprueba `test_level_draft.gd`).
- **La tarjeta:** el lugar es un `Label` encima de un renglón reservado (U+200C), porque Godot descarta los renglones que solo tienen espacios (los `\n\n` finales de la tarjeta de siempre tampoco ocupan lugar). Ver el Resultado de T228 sobre cómo se ve.

#### Lo que cambió al programarla (T234, 2026-10-09)

- **Archivos reales:** `scripts/logic/credits.gd` (`Credits`: `load_file` y `parse`, con `MAX_LINES = 40` y `LINE_MAX = 90`), `data/creditos.json`, `scenes/ui/epilogue_screen.gd` (`EpilogueScreen`) y `scenes/ui/credits_screen.gd` (`CreditsScreen`). **Las dos pantallas se arman por código, sin `.tscn`**, como `HallOfFame`: son `CanvasLayer` que se agregan encima de la pantalla de victoria **dentro de la misma escena de la partida** (capa 15 el epílogo, 18 los créditos, 20 el Salón de la fama). Por eso «Esc o un toque vuelven a la pantalla de victoria» es solo cerrar la capa: la victoria sigue ahí debajo, con sus récords, y no hay que recargarla.
- **El botón:** `EndScreen.show_victory(…, win_text, has_epilogue)` cambia el texto de `NextButton` a «Epílogo» y emite `epilogue_pressed` (no `next_pressed`); la derrota y las victorias siguientes lo devuelven a «Siguiente nivel». `Game` decide `has_epilogue = shows_texts() and GameFlow.has_epilogue()` (no en modo de pruebas, no probando desde el editor, no en un modo oficial) y `GameFlow.has_epilogue()` pide: campaña (sin modo, comunidad ni `test_level`), último nivel y `epilogue_text` no vacío. `GameFlow.is_campaign_complete()` deduce «campaña terminada» de los niveles completados: **no hay ningún campo nuevo en el guardado** (un test compara el archivo antes y después de ver el epílogo y los créditos).
- **El nivel 15 usa 12 letras de leyenda** (D-093): `LevelFile.MAX_LEGEND` sube de 10 a 12. `MapDrawings` suma 8 dibujos de tipo objeto (`central_1` a `central_4`, `supply_depot`, `supply_line_pole`, `supply_cart`, `supply_conveyor`), con los SVG de T233 por `preload`. **T549 (2026-10-28):** el concepto T527 los reemplazó: las mismas claves `supply_*` apuntan a PNG de 128 × 128 en `assets/sprites/map/rendered/t527/` (nave destruida, taller en ruinas, lingotes) y `supply_conveyor` salió del catálogo.
- **Datos del Coloso (M54):** `data/enemies/colossus.tres` y `colossus_shard.tres` con los números de RF-481 y los parámetros visuales de T244 (`visual_scale` 1.8 y 1.2, `walk_stride_tiles` 1.1 y 0.55). **Ningún campo ni código nuevo.**

#### Lo que M52 no toca

`ObstaclePanel` y la infraestructura, las reglas de combate, los números de `data/enemies`, `data/towers` y `data/obstaculos.json`, el guardado (`save.json` y `progression.json`), el menú de pausa, el menú principal y `ModePacks`. El pedido es de textos, de una categoría de la Wiki, de un epílogo y de la guía de los últimos niveles.

### M53 / T247 · Barra con pestañas y flecha al menú (RF-454 a RF-463, D-088)

**Estado: programado en T248 (2026-10-08)**, con el OK de Lucas a la spec (M53) y a sus preguntas P1 a P8. **Lo que cambió al programarlo respecto del diseño de abajo:** (1) hay un archivo de lógica más, `scripts/logic/infrastructure_text.gd` (`InfrastructureText`: los textos de las tarjetas, `expected_resources` y la lista de puntos de extracción); `InfrastructureController` y `ObstacleField` **no se tocaron**; (2) `ExitText.message(collections, job_active)` recibe una entrada por pieza con el **id de la colección**, no los nombres; (3) `BarLayout.button_width(count, tabs)` y `gap(count, tabs)` reciben si hay pestañas, y sin pestañas con 10 o más torres los botones se achican (73 con 10, 66 con 11); (4) `Game` tiene las costuras `leave_to_menu` y `leave_to_editor` (los tests no pueden cambiar de pantalla) y `BuildController.input_blocked` (con el diálogo abierto, ninguna tecla de torre ni clic llega a la construcción); (5) `Tab` se atiende en `Game._input`, para ganarle al foco del teclado; (6) `Hud` expone `bar_tabs`, `infrastructure_tab`, `setup_bar(tabs)`, `show_tab`, `switch_tab`, `show_job_badge` y `shows_resources()`; elegir una torre (con tecla o con el mouse) vuelve a «Cañones» sin avisar; (7) las pestañas usan 12 pt y márgenes de 3 px (13 pt no entra). La sección de abajo es el diseño original.

Se programa en **T248**, después del OK de Lucas a la spec (M53) y a sus preguntas P1 a P8. Depende de que el código de **T207, T208 y T210** (`InfrastructureController`, `ObstaclePanel`, `InfrastructurePanel`) esté en la rama base, como ya está en `feature/integracion-v1`. Es interfaz pura: **ninguna regla ni dato de balance cambia**.

#### Qué hay hoy (leído en T247)

- `scenes/game/hud.tscn`: `TopBar` (0–48 px; `Stats` de x = 20 a 1000, `PauseButton` 1016–1146, `SpeedButton` 1156–1260), `BottomBar` (624–720; `TowerButtons` de x = 20 a 980 con botones de 76 × 60, `NextWave` en x = 800 a 1004, `StartWaveButton` en 1016 a 1260), `BuildInfo` (y = 592 a 622) y `TowerPanel`.
- `scenes/game/hud.gd`: `setup_towers()` arma un botón por torre y solo le pone etiqueta de tecla `i < 9`; emite `tower_button_pressed(index)`. `_ready()` crea a mano `ObstaclePanel` e `InfrastructurePanel` como hijos del HUD. `show_collection()` y `show_selected_tower()` ya existen.
- `scenes/ui/infrastructure_panel.gd`: un botón «Infraestructura» en (1030, 5) y un panel de 260 × 132 en (1000, 52), con la compra de la demoledora. Señal `buy_pressed`. Lo conecta `game.gd` (línea ~204) a `infrastructure.buy_machine`.
- `scenes/game/build_controller.gd` `_unhandled_input()`: `for i in _tower_types.size(): if event.is_action_pressed("build_%d" % (i + 1))`. **Con 10 torres pregunta por `build_10`, que no existe** y el motor imprime un error (comprobado con un script suelto).
- `scenes/game/game.gd`: `PauseMenu` con `quit_pressed → GameFlow.go_to_main_menu` (o `go_to_editor` al probar); `_commit_collection()` guarda las piezas **solo al mostrar el resultado**; `findings: FindingRun` (`pending()`, `confirmed()`) y el portador de avances (`CollectibleRun`).
- `project.godot`: acciones `build_1` a `build_9` (teclas físicas 49 a 57), `cancel`, `pause`, `toggle_speed`, `start_wave`, `upgrade`, `sell`.

#### Archivos

**Lógica pura** (`scripts/logic/`, sin escena, con tests; P10):

- **`bar_layout.gd`** (`class_name BarLayout`, nuevo): constantes de interfaz (lo único que no va en `data/`, regla de `gdscript.md`) y funciones estáticas:
  - `static func button_width(count: int) -> int`: `clampi(floori((TOWER_AREA_WIDTH - (count - 1) * GAP) / count), MIN_BUTTON_WIDTH, MAX_BUTTON_WIDTH)` con `TOWER_AREA_WIDTH = 674` (x de 118 a 792), `GAP = 4`, `MIN_BUTTON_WIDTH = 56`, `MAX_BUTTON_WIDTH = 76`. Sin pestañas (`tabs == false`) el área es la de hoy y el ancho es **76 siempre** (RF-454).
  - `static func key_label(index: int) -> String`: `"1"`–`"9"`, `"0"` para el índice 9 y `""` desde el 10 (RF-456).
  - `static func action_for(index: int) -> StringName`: `&"build_%d"` (el 10 → `&"build_10"`), solo si `InputMap.has_action`.
- **`exit_text.gd`** (`class_name ExitText`, nuevo): `static func message(pieces: Array[String], job_active: bool) -> String` arma el texto del RF-460 (la línea de siempre, la de las piezas con su cuenta y nombres, la de la demolición y la de «lo que no se pierde»). Los nombres de colección salen de `CollectionDefinitions.name_of()`.
- **`scripts/data/level_data.gd`**: `func uses_infrastructure() -> bool: return machine_enabled or not obstacles.is_empty()` (junto a `uses_resources()`; RF-454). `obstacles` solo trae removibles y puntos de extracción (`ObstacleSpec.Kind` tiene esos dos valores), así que una decoración común no cuenta.
- **`scripts/logic/infrastructure_summary.gd`** (nuevo, opcional si `InfrastructureController` ya expone esto): `static func expected_resources(field: ObstacleField) -> int` (suma de `min(producción, reserva)` de los puntos activos, RF-457 tarjeta 4). **Reusar** lo que haga `ObstacleField.complete_wave()`; no duplicar la regla.

**Interfaz** (`scenes/ui/` y `scenes/game/`):

- **`scenes/ui/bar_tabs.gd`** (`class_name BarTabs`, `Control`, nuevo): la columna de pestañas. `setup(tabs: Array[Dictionary])` con `[{id, text}]`; `select(id)`; `signal tab_selected(id: StringName)`; `func set_badge(id, text)` para el *«Infraestructura · 4 s»* (RF-458). Sin saber nada de torres ni de infraestructura: solo muestra y avisa (principio P6 de la constitución). Dos ids: `&"cannons"` y `&"infrastructure"`.
- **`scenes/ui/infrastructure_tab.gd`** (`class_name InfrastructureTab`, `Control`, nuevo): reemplaza a `InfrastructurePanel`. Las cuatro tarjetas del RF-457. Señales hacia arriba: `buy_pressed`, `cancel_pressed`, `enable_pressed(cell: Vector2i)`, `site_selected(cell: Vector2i)`. Métodos de entrada: `show_job(name, fraction, seconds_left)` / `clear_job()`, `show_machine(enabled, owned, price, gold, effect_text)`, `show_sites(sites: Array[Dictionary])` con `{cell, kind_name, state, price, reserve, max_reserve, production}`, `show_resources(have, expected)`. **No decide nada**: no cobra ni habilita.
- **`scenes/ui/exit_dialog.gd`** + `exit_dialog.tscn` (`class_name ExitDialog`, `CanvasLayer`, nuevo): modelado sobre `PauseMenu` (mismo panel, mismo atenuado, mismo `Audio.add_click_sounds`). `open(text: String)`, `signal confirmed`, `signal cancelled`; `Esc` cancela; el foco inicial va a «Seguir jugando».
- **`scenes/game/hud.gd`**:
  - Elimina la creación de `InfrastructurePanel`; crea `BarTabs` e `InfrastructureTab` en `setup_towers()`/un `setup_bar(level_data)` nuevo, **solo si `level.uses_infrastructure()`** (si no, el HUD queda como hoy).
  - `setup_towers()` usa `BarLayout.button_width()` y `BarLayout.key_label()` (en vez de `i < 9`), y al cambiar de pestaña muestra u oculta `_tower_button_row` y la tarjeta de infraestructura. **No** cambia el orden ni los índices: `tower_button_pressed(index)` conserva su significado.
  - Botón **«← Menú»** (`ExitButton`, 80 × 32 en (8, 8)): `signal menu_pressed`; el texto cambia con `set_exit_text("← Editor")` (igual que `PauseMenu.set_quit_text`). `Stats` se corre a `offset_left = 96` **en `hud.tscn`** (no por código). Se oculta con `hide_exit()` cuando la partida termina.
  - `signal tab_changed(id: StringName)` y `func show_tab(id)`. Cambiar de pestaña **emite hacia arriba**; `Game` decide si cancela la construcción (RF-456).
  - `show_infrastructure(...)`: Game se lo da armado; el HUD no lee el controlador (señales hacia arriba, llamadas hacia abajo).
- **`scenes/game/hud.tscn`**: `Stats` corrido; el resto, igual. El hijo `TowerButtons` pasa a empezar en x = 118 **solo cuando hay pestañas** (por código; sin pestañas queda en x = 20).
- **`scenes/game/build_controller.gd`**: el ciclo de `_unhandled_input` usa `BarLayout.action_for(i)` y **saltea** los índices sin acción (arregla el error de `build_10`). Para cancelar la construcción al cambiar de pestaña, `Game` usa el `cancel()` que ya existe.
- **`scenes/game/game.gd`**:
  - Conecta `hud.tab_changed` (→ `build_controller.cancel()` si pasa a «Infraestructura»), `hud.menu_pressed` (→ `_request_exit()`) y `exit_dialog.confirmed` / `cancelled`.
  - `_request_exit()`: si es «Probar», va directo a `GameFlow.go_to_editor`; si no, junta `findings.pending() + findings.confirmed()` y los avances del portador, arma el texto con `ExitText.message()`, **guarda si estaba en pausa** (`is_paused()`), pausa (`set_paused(true)`) y abre el diálogo. Al cancelar, `set_paused(was_paused)`. Al confirmar, `GameFlow.go_to_main_menu()` **sin** llamar a `_commit_collection()`.
  - `_unhandled_input`: `Esc` con el diálogo abierto lo cierra (antes que el menú de pausa); `Tab` (`switch_tab`) alterna pestañas si el nivel tiene; con el menú de pausa o el diálogo abiertos no hace nada.
  - `_refresh_infrastructure_panel()` pasa a alimentar `InfrastructureTab` desde `infrastructure.changed` (oro, trabajo, extracción, oleada completada).
  - Sin pestañas (`not level_data.uses_infrastructure()`) **no se crea nada** de lo anterior excepto la flecha.
- **`scenes/ui/infrastructure_panel.gd`**: se **borra** (con su `.uid`) y se actualizan los tests que lo mencionan. Buscar `InfrastructurePanel` y `infrastructure_panel` en todo el proyecto antes de borrar.
- **`project.godot`**: dos acciones nuevas, `build_10` (tecla física `0`, código 48) y `switch_tab` (`Tab`, código 4194306). **Editar el archivo con Edit, no con un script que reordene.** Verificar que `Tab` no tiene otro uso en las escenas de la partida (los botones de la barra no toman foco, así que el foco por teclado no interviene).

#### Cómo se arma el trabajo (orden sugerido para T248)

1. **Lógica y datos primero** (sin escena): `BarLayout`, `ExitText`, `LevelData.uses_infrastructure()`; sus tests. Correr todo.
2. **Acciones y `BuildController`**: `build_10`, saltar acciones inexistentes; test que simula 10 torres y comprueba **0 errores del motor** (`SCRIPT ERROR` / `ERROR` nuevos en la salida) y que `0` elige la décima.
3. **`BarTabs` + `InfrastructureTab`** y su conexión en `Hud`/`Game`, reemplazando a `InfrastructurePanel`. Test de las cuatro tarjetas (RF-457) y de que tocar un objeto no cambia la pestaña (RF-458).
4. **Flecha + diálogo** (RF-459 a RF-461).
5. **Captura real** de 1280 × 720 en el nivel 6 (demoledora) y en el 10 (24 × 11 con zoom, mina), con 9 y con 10/11 torres (modo de pruebas con «Habilitar todas las colecciones»). Mirar que nada se pise y que el mapa quede igual. Guardar las capturas en `art/m53-barra/` con un `README.md` breve.
6. **Documentos:** `CHANGELOG.md` (lo ve quien juega), `README.md` y `ONBOARDING.md` (teclas y barra), `CONTENIDO.md` si menciona el panel «Infraestructura».

#### Pruebas que T248 tiene que escribir

1. **`BarLayout`:** el ancho de botón con 1, 8, 9, 10 y 11 torres (sin pestañas siempre 76; con pestañas, 71 / 63 / 57; nunca menos de 56 ni más de 76); `key_label` de 0 a 11.
2. **`LevelData.uses_infrastructure()`:** los niveles 1 a 5 → `false`; los niveles 6 a 10 → `true`; un nivel con solo `demoledora` → `true`; un nivel con decoración pero sin removibles ni extracción → `false`.
3. **HUD sin pestañas:** en el nivel 1 la posición y el tamaño de `TowerButtons` y de sus botones son **idénticos** a los de antes (la prueba que cuida el RF-454), y no existen `BarTabs` ni `InfrastructureTab`.
4. **HUD con pestañas:** en el nivel 6, «Cañones» activa; `Tab` pasa a «Infraestructura» y oculta los botones de torre; con una torre elegida cancela la construcción; una tecla de torre vuelve a «Cañones».
5. **Teclas:** `0` elige la décima torre; `Tab` y `0` en el nivel 1 no hacen nada; **ningún error de acción inexistente** con 10 torres.
6. **Tarjetas:** Demoledora (comprar, gris sin oro, «activa»), Extracción (habilitar, activa, agotada, tres fichas y flechas), Trabajo en curso (progreso, cancelar devuelve el oro), Recursos (esperados). Cada botón llama a la **misma función** que el panel del objeto.
7. **Objeto del mapa:** seleccionar una roca en «Cañones» abre su panel y **no cambia la pestaña**; el título de la pestaña muestra el tiempo del trabajo.
8. **Flecha y diálogo:** sin piezas (solo la línea de siempre), con una pieza pendiente, con una pieza confirmada sin guardar, con demolición en curso; cancelar restaura pausa y velocidad; en «Probar» no hay diálogo y vuelve al editor; confirmar **no escribe nada** en `user://test_*.json` (la colección guardada no cambia); con la partida terminada la flecha no se ve.
9. **Compatibilidad:** un nivel de la comunidad cargado igual; `save.json` de la versión anterior se lee igual.
10. **Los tests existentes** de la barra (`test_tower_bar.gd`) y los que nombran `InfrastructurePanel` se actualizan, y el total no baja de la línea de base (1017 el 2026-10-07; usar el último número de `03-tareas.md`).

#### Riesgos y cosas que no se saben

- **Ancho de 10 y 11 botones:** la cuenta da 63 y 57 px, pero el contenido de un botón (dibujo de 34 px, costo «130 + 2» y la insignia del recurso, más la del Francotirador «o 120 + 1» de 46 px) **no se midió** a esos anchos. Es el primer punto que T248 tiene que mirar en una captura.
- **El texto «Infraestructura» en 96 px** con letra de 13: no se midió. Si no entra, se acorta la letra, no se cambia el texto.
- **El tamaño táctil** (44 px de alto) no se probó en un celular real.
- **Zoom y cámara:** no cambian porque no se toca el área del mapa; aun así, T248 hace la captura del nivel 10 para confirmarlo.
- **La flecha y las estadísticas:** correr `Stats` 76 px supone que su contenido (oro, vidas, puntos, oleada, colección, recursos) mide menos de 904 px; con 6 estadísticas debería sobrar, pero no se midió.
- **`Tab` y el foco:** si algún `Control` de la partida tomara el foco, `Tab` podría moverlo en vez de cambiar la pestaña. Los botones de la barra son `FOCUS_NONE`; hay que confirmarlo con una prueba en la partida real.

#### Lo que M53 no toca

`ObstaclePanel` y sus reglas (RF-404 a RF-410, RF-422 a RF-424), `InfrastructureController`, `ObstacleField`, `FindingRun`, `CollectibleRun`, el menú de pausa, `GameFlow` y el editor. El pedido es solo de interfaz.

### M54 / T243 · El Coloso, jefe supremo del nivel 15 (RF-481 a RF-484, D-092)

**Estado: hecho en T234 (2026-10-09): los dos `.tres`, las oleadas 26, 28 y 30 del nivel 15 y el balance con el bot (ver «Lo que cambió al programarla (T234)» en M52 y el Resultado de T234).** *(Diseño aprobado por Lucas el 2026-10-09.)* Se hace en **T244** (el arte) y **T234** (los dos `.tres`, las oleadas finales y el balance con el bot). Es **solo datos**: no cambia ninguna regla de combate, ningún campo de `EnemyData` ni ninguna pantalla. Todos los números son **iniciales y no se midieron** (ni con el bot ni en partida).

#### Qué hay hoy (leído en T243)

- `scripts/data/enemy_data.gd` ya trae todo lo que hace falta: `death_spawn` y `death_spawn_count` (RF-166), `slow_resistance`, `armor`, `lives_damage`, `size_tiles`, `visual_scale`, `walk_atlas` y `walk_stride_tiles`. **No se agrega ningún campo.**
- `scenes/game/wave_spawner.gd`: `_spawn_enemy` calcula la vida con `Rules.scaled_health_percent(base, oleada, % del nivel)` y, si el enemigo tiene `death_spawn`, conecta `died` a `_on_enemy_died_with_spawn`, que crea los hijos **sumándolos a los vivos antes de que el padre deje el árbol** (así la oleada no termina antes) y los escalona hacia atrás en el camino. Si el enemigo llega a la salida, `died` no se emite: no suelta nada. **Los Pedazos heredan la vida de la oleada en curso** sin código nuevo. `Rules.scaled_health_percent` es `floor(base × (100 + % × (oleada − 1)) / 100)`: con 22 %, oleada 30 → 738 %, o sea Coloso `600 → 4428` y Pedazo `180 → 1328`.
- `scripts/logic/rules.gd`: `is_dangerous` = `lives_damage >= 5` (corona, RF-136): el Coloso sí, el Pedazo no. `scripts/logic/dev_start.gd` `enemy_reward` ya **suma el oro de los hijos** (hasta una profundidad máxima), así que el oro automático (RF-320) cuenta los Pedazos.
- `scripts/logic/wiki.gd`: la entrada de un enemigo ya escribe «Al morir suelta N × Nombre», «Lo suelta al morir: …» y «Dónde aparece» leyendo `data/enemies/` y la campaña; **no hay artículo que escribir a mano**. El bestiario (RF-238) lo abre con `seen_enemies` del guardado: nada nuevo.
- `tests/test_content.gd` revisa **todos** los enemigos: frase de presentación no vacía, `size_tiles` entre 0.05 y 0.5 y que las crías no encadenen más de 10.

#### Archivos

**Datos** (los hace T234; el arte, T244):

- `data/enemies/colossus.tres` y `data/enemies/colossus_shard.tres` (`id` igual al nombre del archivo), con los valores de RF-481. Se copian de `spider.tres` / `spiderling.tres`, que usan el mismo mecanismo:

  | Campo | `colossus` | `colossus_shard` |
  |---|---|---|
  | `display_name` | `"Coloso"` | `"Pedazo"` |
  | `description` | la frase de RF-484 | la frase de RF-484 |
  | `max_health` | 600 | 180 |
  | `speed_tiles` | 0.5 | 1.0 |
  | `armor` | 5 | 0 |
  | `reward` | 200 | 30 |
  | `lives_damage` | 12 | 4 |
  | `slow_resistance` | 0.5 | 0 (el valor por defecto) |
  | `death_spawn` / `death_spawn_count` | `colossus_shard` / 3 | vacío / 0 |
  | `size_tiles` | 0.5 (el máximo que acepta el test) | 0.3 |
  | `visual_scale` | 1.6 (inicial; lo ajusta T244 al ver el arte) | 1.2 |
  | `flip_when_walking_left` | `false` | `false` |
  | `texture`, `walk_atlas`, `walk_stride_tiles`, `walk_art_scale` | los de T244 | los de T244 |
  | `color` | el de la paleta del concepto aprobado (T244) | un tono de la misma familia |

- `data/levels/level_15.json` (T234): el Coloso (`"colossus"`) en las oleadas 26, 28 y 30 y la escolta completa en la 30. El `.json` **nombra** al Coloso; el Pedazo **no se nombra** en ninguna oleada (solo lo suelta).
- `data/wiki/lore/la_central.json` (T234, o T228 si ya lo creó): suma el párrafo del Coloso de `specs/11-textos-lore.md` §4.10, **tal cual**.
- `assets/sprites/enemies/` (SVG de 64 × 64 de respaldo, como los demás) y `assets/sprites/enemies/rendered/`: `colossus.png` y `colossus_shard.png` (256 × 256, una sola vista, luz arriba a la izquierda, sin sombra dibujada, pies en y = 191), `colossus_walk.png` y `colossus_shard_walk.png` (**atlas de 1024 × 1024: 4 poses por fila y 4 filas —derecha, abajo, izquierda, arriba—, cuadros de 256**, M31). Los fija T244; los dos PNG de caminata tienen que pasar los tests de ciclos (16 poses propias, márgenes y apoyo constante).

**Código: ninguno.** Solo se **actualizan listas de pruebas** que nombran los enemigos uno por uno:

- `tests/test_enemy_visual.gd` (tres listas con los quince `id` de hoy: escala visual 1.2, regiones del ciclo, ciclos completos y únicos, ralentización de los pasos). T244 suma `colossus` y `colossus_shard` a las que correspondan; **la de `visual_scale == 1.2` no vale para el Coloso** (su escala es la que decida T244) y esa excepción se escribe en el test, no se esconde.
- `tests/test_editor_panels.gd` (lista de enemigos del editor) y cualquier test que cuente los enemigos de la campaña o de `data/enemies/`: buscar con `git grep "troll\|spiderling"` en `tests/` antes de dar por cerrada la tarea.
- `tools/balance_sim.gd` usa una lista fija de enemigos en la línea de las estrategias (`normal`, `fast`, …, `boss`): **no hace falta tocarla**, porque el bot lee los grupos del nivel; T234 lo confirma jugando el 15.

#### Orden de trabajo

1. **T244 · concepto** (cuerpo y Pedazo, 2 o 3 poses, paleta y silueta contra el Guardián a 34 px), **OK de Lucas**; producción; PNG y atlas; hoja de contacto; captura en una partida con un `.tres` de prueba. Mientras no esté aprobado, T234 usa arte provisional hecho en código (Q-40).
2. **T234 · los dos `.tres`** y la prueba de que cargan (`test_content`), con el arte provisional o el final.
3. **T234 · las oleadas finales** del 15 (26, 28 y 30) y la escolta de la 30, con el bot: 5 semillas, las 5 estrategias.
4. **T234 · balance:** primero la vida de los Pedazos (si queda mal, el bot los deja pasar en masa) y después la armadura del Coloso. Todo cambio de número va a los `.tres` y se anota en el Resultado; **si cambia la cantidad de Pedazos o las vidas, también el texto de RF-484 y la frase del Coloso**.

#### Pruebas que T234 tiene que escribir (además de las de RF-480)

1. **Datos:** `colossus` y `colossus_shard` cargan, tienen los números de RF-481, `colossus.death_spawn` es el Pedazo con cantidad 3 y el Pedazo no suelta nada.
2. **Partir:** un Coloso que **muere** suelta 3 Pedazos con la vida de la oleada en curso (oleada 30 del 15 → 1328), y la oleada **no termina** hasta que mueren o llegan los 3; un Coloso que **llega** quita 12 vidas y no suelta nada.
3. **Vidas:** 3 Pedazos que llegan quitan 12 en total; el Pedazo, 4 cada uno.
4. **Armadura y ralentización:** un golpe de 8 le hace 3 al Coloso y 8 al Pedazo; el Hielo ralentiza al Coloso a la mitad y al Pedazo completo (reusar las pruebas de `slow_resistance` del Jefe).
5. **Nivel 15:** el Coloso está en la 26, la 28 y la 30, la escolta completa solo en la 30, no hay Soberano; ningún otro nivel de la campaña nombra al Coloso.
6. **Wiki:** la entrada del Coloso dice «Al morir suelta 3 × Pedazo» y «Nivel 15 · La Central»; la del Pedazo, «Lo suelta al morir: Coloso»; la corona de peligro aparece en el Coloso y no en el Pedazo; con el guardado nuevo las dos están cerradas.
7. **Lore:** ganar el 15 abre «La Central» y el párrafo del Coloso es el de `11-textos-lore.md`.
8. **Bot:** `check_rule=1 levels=15` «SE CUMPLE», y la tabla del 15 es la más difícil de la campaña (RF-475).

#### Riesgos y cosas que no se saben

- **Ningún número se midió.** La vida de los Pedazos es lo primero a mirar: con ≈ 1330 de vida cada uno y velocidad 1.0, el bot puede dejar pasar los tres juntos y perder 12 vidas de una; con muy poca vida, el Coloso se vuelve un Soberano grande.
- **Las 20 vidas:** una fuga del Coloso deja 8; si T234 ve que el 15 se pierde casi siempre por una sola fuga, lo informa a Lucas con la tabla antes de bajar las 12 vidas (que son una decisión suya).
- **La escolta estirada:** los Pedazos (1.0) corren más que el Guardián (0.7) y se separan del aura; no se probó si eso ayuda o estorba. T234 decide si alinea los `desde` (RF-203).
- **El tamaño:** `size_tiles = 0.5` es el tope que acepta `test_content` («tiene que caber en el camino»). Si el dibujo a ×1.6 tapa casillas vecinas o la barra de vida, lo ajusta T244 con una captura; el radio lógico no se toca.
- **El Pedazo en la lista de «próxima oleada»:** el Pedazo no figura en ninguna oleada, así que no sale en la barra de la próxima oleada, y su tarjeta de presentación (RF-134) sale cuando aparece por primera vez, mitad de la partida. No se probó cómo se ve ni que la tarjeta no tape nada.
- **No se comprobó que `check_level` y los tests acepten un enemigo solo-hijo** (que está en `data/enemies/` pero no en ninguna oleada). La Cría ya es así, así que debería pasar; T234 lo confirma.
- **La frase del Coloso** (~130 caracteres) es más larga que las de hoy; no se midió si entra en la tarjeta de 6 segundos. Si no entra, se acorta.
- **El texto del lore dice «tres».** Es lo único del texto que depende de un número del balance (ver arriba).

#### Lo que M54 no toca

`EnemyData`, `WaveSpawner`, `Rules`, la Wiki (`wiki.gd`), el guardado, el Soberano (`boss.tres`) y el resto de los enemigos. Tampoco las escoltas de los niveles 13 y 14. El pedido es de **dos archivos de datos**, su dibujo y las oleadas finales del 15.

### M55 / T252 · La Cuadrilla: una banda de criaturas independientes (RF-485 a RF-491, D-094)

**Estado: HECHA en T253 (2026-10-10), con arte provisional.** Los datos, las oleadas, el reajuste con el bot, el artículo y los tests son **T253** (Resultado en `specs/03-tareas.md`); el arte, **T257**. *(Lucas aprobó el 2026-10-10 los niveles, los nombres, las frases, el artículo y el arte provisional; Asedio 7, P2, sigue abierta.)* **Lo que cambió al programarla:** (1) ninguna cantidad ni oleada del plan se tocó: las cuatro apariciones de RF-487 pasaron RF-488 tal cual, así que no hubo reajuste ni se movió ningún `aumento_vida`; (2) **`tools/balance_sim.gd` suma la columna «oro robado»** (escucha `gold_stolen`; no cambia ningún resultado); (3) **ningún código del juego**: la Wiki, la tarjeta y la barra de próxima oleada ya aceptaban un enemigo sin `texture` (la Wiki solo omite el dibujo); (4) los tests que pedían dibujo o contaban 10 artículos de Lore (`test_content`, `test_wiki`, `test_bestiary`, `test_level_15`, `test_lore_wiki`) se actualizaron: los dos enemigos están en una lista `PROVISIONAL_ART` que se vacía cuando T257 los dibuje. Es **solo datos**: no cambia ninguna regla de combate, ningún campo de `EnemyData` ni ninguna pantalla. Todos los números son los del informe de T251, **sin tocar**, y la medición que decide los niveles está en `specs/tareas/informes/T252-medicion-cuadrilla.md`.

#### Qué hay hoy (leído en T252)

- `scripts/data/enemy_data.gd` ya trae todo: `gold_drain_amount`, `gold_drain_interval`, `gold_drain_floor` y `optional_wave_limit` (el robo de M39), más `max_health`, `speed_tiles`, `armor`, `reward`, `lives_damage`, `size_tiles`, `color`, `texture` y `walk_atlas`. **No se agrega ningún campo.**
- `scenes/enemies/enemy.gd` (`_update_gold_drain`): **cada enemigo lleva su propio reloj** (`_drain_clock`) y emite `gold_drain` cada `gold_drain_interval` solo mientras **sigue en el camino**; ocho Rateros roban cada uno por su cuenta, no hay un reloj de grupo.
- `scenes/game/level_session.gd` (`steal`): descuenta `min(monto, oro − piso)`, sin crear ni quitar monedas por debajo del piso, y emite `gold_stolen`. `game.gd` conecta la señal y muestra el aviso ámbar (RF-365).
- `scenes/game/wave_spawner.gd` (`start_wave`): el «máximo uno por oleada» (`optional_wave_limit`) **solo** se aplica a grupos con `probability < 1`. Un grupo sin `"probabilidad"` sale **siempre y entero**.
- `scripts/logic/wiki.gd`: la entrada de un enemigo ya escribe la línea **«Robo»** (`:106`) y «Dónde aparece» leyendo la campaña; **no hay entrada escrita a mano**. El bestiario (RF-238) lo abre con `seen_enemies`.
- `scenes/game/hud.gd` (`show_enemy_intro`): las tarjetas de presentación **se encolan** (`_intro_queue`) y salen una tras otra; con dos enemigos nuevos en la misma oleada salen **dos**.
- `scripts/logic/rules.gd` (`is_dangerous`): corona con `lives_damage >= 5`; ni el Ratero (1) ni el Cargador (2) la llevan.
- `tests/test_content.gd` revisa **todos** los enemigos de `data/enemies/` (frase no vacía, `size_tiles` entre 0.05 y 0.5, cadena de crías).

#### Archivos

**Datos** (los hace T253; el arte, T257):

- `data/enemies/ratero.tres` y `data/enemies/cargador.tres` (`id` igual al archivo), con los valores de RF-485. Se copian de `thief.tres` (el robo) y de `fast.tres` / `tank.tres` (el formato):

  | Campo | `ratero` | `cargador` |
  |---|---|---|
  | `display_name` | `"Ratero"` | `"Cargador"` |
  | `description` | la frase de RF-489 | la frase de RF-489 |
  | `max_health` | 14 | 110 |
  | `speed_tiles` | 2.2 | 0.9 |
  | `armor` | 0 | 1 |
  | `reward` | 5 | 30 |
  | `lives_damage` | 1 | 2 |
  | `size_tiles` | 0.20 | 0.33 |
  | `gold_drain_amount` / `gold_drain_interval` / `gold_drain_floor` | 2 / 2.0 / 10 | 4 / 2.0 / 10 |
  | `optional_wave_limit` | 0 | 0 |
  | `color` | un tono de una familia propia, distinto del gris violeta del Ladrón (lo fija T257; provisional en T253) | de la misma familia |
  | `texture`, `walk_atlas`, `walk_stride_tiles`, `walk_art_scale`, `visual_scale` | los de T257; **mientras no haya arte, vacíos** (forma geométrica, RF-156) | ídem |

- `data/levels/level_07.json`, `level_10.json`, `level_13.json` y `level_14.json` (T253): **cuatro apariciones** por nivel, como en la tabla de RF-487 (un grupo `ratero` con `"cada": 0.4` y uno `cargador` con `"cada": 3.0`, sin `"desde"` ni `"probabilidad"`, en la entrada `"A"`). El `.json` **nombra** a los dos enemigos.
- `data/wiki/lore/la_cuadrilla.json` (T253, **solo si Lucas aprueba el texto**): `"desbloqueo": "level_07"`, el texto de `specs/11-textos-lore.md` §4.11 y un `orden` entre el del artículo 5 y el del 6; los artículos 6 a 10 pasan a `orden` 7 a 11.
- `assets/sprites/enemies/rendered/` (T257): `ratero.png`, `cargador.png` y los atlas `ratero_walk.png` y `cargador_walk.png` (256 × 256 y 1024 × 1024, 4 × 4 poses, como el resto, M31).

**Código: ninguno.** Opcional, de **herramienta** y no del juego: una columna de **oro robado** en `tools/balance_sim.gd` (conectar `session.gold_stolen`, está en el apéndice del informe). Las listas de pruebas que nombran los enemigos uno por uno:

- `tests/test_enemy_visual.gd` (listas con los `id` de hoy): sumar `ratero` y `cargador` a las que correspondan **solo cuando haya atlas**, con el mismo recaudo que el Coloso (`ResourceLoader.exists`).
- `tests/test_lore_wiki.gd` (`:68`: «los 10 artículos» pasa a 11; `:180`: la lista de artículos abiertos con el 7 ganado).
- Cualquier test que cuente los archivos de `data/enemies/`: buscar con `git grep "colossus_shard\|spiderling" tests/` antes de cerrar T253.
- `tools/balance_sim.gd` lee los grupos del nivel: **no hace falta tocar** su lista de enemigos (T253 lo confirma jugando el 7).

#### Orden de trabajo

1. **T253 · compuerta** (Lucas contestó P1, P2, P4 y P5).
2. **T253 · los dos `.tres`** y la prueba de que cargan (`test_content`), con arte provisional.
3. **T253 · las oleadas** del 7, el 10, el 13 y el 14, y `check_level`.
4. **T253 · el bot:** 5 semillas, `sin_recursos` y las otras cuatro estrategias; el reajuste (RF-488, punto 5) y **Asedio 7** (P2).
5. **T253 · el artículo y los tests** (§ «Qué hay que hacer» de su ficha), y los documentos.
6. **T257 · el arte** (concepto con OK de Lucas, atlas, hoja de contacto); **no bloquea** a T253.

#### Pruebas que T253 tiene que escribir

Las diez de la ficha (`specs/tareas/T253-cuadrilla-datos-y-reajuste.md`): datos; sin el tope del Ladrón; robo con piso y reloj propio; fuga del Ratero y del Cargador; **solo** los niveles 7, 10, 13 y 14; **sin auras ni jefe** en esas oleadas; la Wiki Enemigos (cerrados con un guardado nuevo); el artículo de Lore que se abre al ganar el 7 y deja intacto al 5; y que no hay ningún campo nuevo de `EnemyData`.

#### Riesgos y cosas que no se saben

- **Una sola intensidad por nivel.** Las cuatro apariciones (6 + 1, 8 + 1, 8 + 1, 10 + 2) y las oleadas salen de una regla fija, no de un diseño por nivel. T253 puede encontrar que un nivel pide menos.
- **El robo depende del oro que tenga el jugador.** El bot nunca mejora torres y deja miles de oro sin gastar al final (T251 §2.5); una persona que mejora torres tiene menos oro «parado» y siente más cada robo, o menos si lo gasta rápido. **No se probó con una persona.**
- **El 13 y el 14 tienen dos entradas** y se midieron con la `"A"`. Repartir la Cuadrilla entre las dos **no se probó**.
- **Asedio 7 hereda la Cuadrilla** y el bot lo pierde nueve oleadas antes (11 de 20 contra 19 o 20). Lo decide Lucas (P2).
- **Dos tarjetas seguidas** (12 s) en una oleada del nivel 7 que ya tiene otros enemigos: no se miró en pantalla cómo se ve ni que no tape nada.
- **Sin dibujo:** que la Wiki, la tarjeta y la barra de «próxima oleada» se vean bien con la forma geométrica es una hipótesis (RF-156 lo prevé, pero no se probó con estos dos).
- **El texto del lore y las frases dependen de los números del robo** (2 y 4 de oro cada 2 s): si T253 los cambia, se corrigen las frases (como la del Ladrón).
- **El precipicio del final** del 8 y el 9 hace que las vidas con la vida igualada (1 a 4) sean ruidosas; por eso esos niveles quedaron fuera y no por una regla de diseño.

#### Lo que M55 no toca

`EnemyData`, `WaveSpawner`, `Rules`, `enemy.gd`, `level_session.gd`, la Wiki (`wiki.gd`), el guardado, el Ladrón, el Soberano, el Coloso, el nivel 15, el artículo 5 de Lore y los textos de nivel. El pedido es de **dos archivos de datos**, su dibujo, las oleadas de cuatro niveles y un artículo.

### M56 / T256 · Asedio con los 15 mapas y porcentaje de vida por mapa (RF-492 a RF-496, D-095)

**Estado: HECHA en T258 (2026-10-10).** Lo de abajo se escribió en T256 como diseño; **lo que cambió al programarla:** (1) `_read_rules` recibe `PackedStringArray` de ids de mapa y la validación vive en `_read_health_by_map`, con el mensaje del mapa o del valor; (2) la lista de políticas del bot quedó en `tools/asedio_politicas.json` (`por_defecto`, `level_02`, `level_04`) y la lógica pura (regla de mejora, elección de la torre, veredicto por mapa y por bloque) en `BalanceArgs`, con tests; (3) el bot suma `vida=N` para remedir un porcentaje sin tocar el `modo.json` y no nombra el tipo `Tower` (usa el grupo `towers`) para compilar con `--check-only`; (4) los mapas 7, 10, 13 y 14 se midieron **con** la Cuadrilla y **solo el 7 pidió bajar** (de 103 % a 101 %, y aun así una semilla queda en 1 vida: pregunta abierta para Lucas). *(La estructura la aprobó Lucas el 2026-10-10; los **valores** de la tabla son los de T255 y quedan «iniciales»; los mapas 7, 10, 13 y 14 se remiden cuando entre La Cuadrilla, T253.)* Es **solo datos y una clave nueva del lector de modos**: no cambia ninguna regla de combate, ningún campo de `LevelData` ni `LevelFile`, ni el generador de oleadas. La medición que respalda los números está en `specs/tareas/informes/T255-curva-dificultad-asedio.md`.

#### Qué hay hoy (leído en T256)

- `scripts/logic/mode_packs.gd`:
  - `KEYS` es la lista de claves de primer nivel del `modo.json` (`version`, `nombre`, `descripcion`, `mapas`, `torres`, `reglas`) y `RULE_KEYS`, la de `reglas` (`oro_inicial_%`, `vidas` y `vida_monstruos_%`). **Una clave desconocida es un error del modo**, con la lista de las que se usan.
  - `_read_settings` lee la lista de `mapas` **antes** que las `reglas`. `_read_rules` valida con `_whole` (entero entre `MIN_PERCENT` = 10 y `MAX_PERCENT` = 1000 para el oro y la vida; 1 a `LevelFile.MAX_LIVES` para las vidas).
  - `_read_map` lee cada mapa con `LevelFile.parse` y llama a `_apply(level, settings)`, que escribe `level.enemy_health_percent = rules["vida_monstruos_%"]` **igual para todos los mapas**.
  - `add_map` y `create` reescriben el `modo.json` con `_write`, que vuelve enteros los números enteros (`_whole_numbers`, recursivo).
- `scripts/data/level_data.gd`: `enemy_health_percent` (100 por omisión) ya está y es lo que consume el generador (`WaveSpawner.setup`, que aplica el % después de la escala por oleada).
- `data/modos/asedio/modo.json`: `mapas` 1 a 9, `oro_inicial_%` 100 y `vida_monstruos_%` 115.
- `tools/balance_sim.gd`: `modo=asedio level=N` lee el mapa **con `ModePacks.map_level`**, o sea que **ya recibe el porcentaje por mapa sin tocar nada**. No tiene mejoras de torres ni política por mapa.

#### Archivos

**Código** (lo hace T258):

- `scripts/logic/mode_packs.gd`: constante `RULE_HEALTH_BY_MAP = "vida_monstruos_por_mapa_%"` (en `RULE_KEYS`); `_read_rules` recibe la lista de mapas y valida la tabla (objeto; cada clave **en `mapas`**; cada valor entero entre 10 y 1000, con `_whole`); `_apply` recibe el id del mapa y elige **tabla → global → 100**. Nada más del archivo cambia. **Es la única pieza de código del juego.**
- `tools/balance_sim.gd`: `mejoras=llenar|temprana` (apagado por omisión), una política por mapa en un archivo de datos de la herramienta y una corrida de perfil que imprime la tabla y los promedios por bloque. **Debe compilar con `--check-only`** (T254).

**Datos:**

- `data/modos/asedio/modo.json`: `level_01` a `level_15`, `vida_monstruos_%` 115 y la tabla de **13 excepciones** de RF-494.
- La política del bot por mapa (en `tools/`, no en el juego): `level_02` → `smart` + `llenar`; `level_04` → `sin_recursos` + `temprana`; el resto → `sin_recursos` + `llenar`.

#### Cómo se decide la vida de un mapa (referencia para quien programa)

```
vida efectiva de un enemigo en un mapa del modo
  = max(1, percent_of( scaled_health_percent(vida base, oleada), P ))
    (dos redondeos, igual que hoy: primero la escala por oleada, `Rules.scaled_health_percent`, que da un
     entero; después `Rules.percent_of`, al entero más cercano; `wave_spawner.gd:112`)

  P = reglas["vida_monstruos_por_mapa_%"][id del mapa]     si el mapa está en la tabla
      reglas["vida_monstruos_%"]                           si no, y el modo lo trae
      100                                                  si no
```

#### Orden de trabajo

1. **T258 · dependencias** (T253 hecha o no: decide si 7, 10, 13 y 14 se miden o quedan «a remedir»).
2. **T258 · la clave y su validación** (`ModePacks`), con sus tests de errores y de compatibilidad.
3. **T258 · los datos** del modo Asedio y los tests del Asedio oficial.
4. **T258 · el bot** (mejoras y política por mapa) y las 75 partidas.
5. **T258 · los documentos** (`CONTENIDO.md`, `README.md`, `ONBOARDING.md`, `CHANGELOG.md`, M56, `03-tareas.md`, plan 08).

#### Pruebas que T258 tiene que escribir

Las de la ficha (`specs/tareas/T258-asedio-porcentajes-por-mapa.md`, paso 6): tabla y global; tabla sin global; cada error con su motivo; tabla vacía; compatibilidad con los modos que ya existen; oro y vidas intactos; `add_map` conserva la tabla; el Asedio oficial con 15 mapas, las mismas oleadas que la campaña y los 15 porcentajes de RF-494; 15 tarjetas en la selección; el 10 se abre al ganar el 9; sin textos ni piezas en los 15.

#### Riesgos y cosas que no se saben

- *(Resuelto en T258: se remidieron con la Cuadrilla; 10, 13 y 14 pasan igual y el 7 queda en 101 % con una semilla en 1 vida.)* **Las cuatro filas «a remedir»** (7, 10, 13 y 14) estaban medidas **sin La Cuadrilla**. Con ella el bot ya pasó de perder Asedio 7 en la oleada 19–20 a perderlo en la 11 (T252, al 115 %). Si T258 se hace antes de T253, esos cuatro números **no valen** hasta repetirlos.
- **Una persona no jugó nada.** Los porcentajes salen del bot, que **no mejora, vende ni repara como lo haría quien juega**; las vidas son un indicador de margen, no una escala de dificultad. La progresión **por bloques** baja (16,00 · 11,72 · 6,84) pero **no es estricta mapa por mapa**. Se juega en G5.
- **Los porcentajes bajos (101 %) casi no cambian la vida** de los enemigos chicos por el redondeo: el 101 % del mapa 13 no lo hace «más difícil» que la campaña en todo el nivel (T255 §4.1). **«Mayor que 100» es una condición de formato, no una garantía de dificultad.**
- **Una semilla no alcanza.** El mapa 14 al 122 % ganaba la semilla 1 y perdía las otras cuatro. Por eso el criterio es **cinco semillas** (RF-495).
- **El bot elige la política por mapa** (`smart` en el 2, mejoras tempranas en el 4): son decisiones del instrumento fijadas antes de medir, y si cambian, la tabla puede cambiar. Están en un archivo aparte para que se vean.
- **Una versión anterior del juego rechaza** un modo con la tabla. Es un cambio de formato compatible hacia atrás solamente: los paquetes viejos cargan en la versión nueva, no al revés.
- **El editor no edita la tabla** (la conserva). Un modo propio con la tabla se arma a mano.

#### Lo que M56 no toca

La campaña y sus 15 niveles, `LevelFile`, `LevelData`, `WaveSpawner`, `Rules`, el guardado, la Wiki, los textos del lore, el arte, las tablas del bot de la regla de oro (`sin_recursos` sin mejoras, RF-432 y RF-475) y el selector de modos (más allá de listar 15 tarjetas en vez de 9).

---

### M57 / T240 · La intro de láminas (RF-497 a RF-501, D-096)

> **Estado: especificada en T240 y aprobada por Lucas (G6, 2026-10-11); programada en T242 con láminas provisorias (falta el paso 6: las láminas de T241, medir el texto y reexportar).** La spec es **M57** (`01-spec.md`); el guion, `specs/intro/guion.md`; la ficha de código, `specs/tareas/T242-intro-integracion.md`. Los nombres de archivos y de funciones de abajo son **propuestos**: T242 los confirma al leer el código.

#### Qué hay hoy (leído en el código, no supuesto)

- **«Jugar»** (`scenes/ui/main_menu.gd`, en `_ready`): `_play_button.pressed.connect(GameFlow.go_to_level_select)`. No hay nada entre el botón y la selección.
- **Overlays que «solo muestran y avisan»:** `EpilogueScreen` (`scenes/ui/epilogue_screen.gd`) y `LevelIntro` (`scenes/ui/level_intro.gd`) son `CanvasLayer` con una señal (`closed`); **quien los abre decide qué pasa después** (constitución P6). `LevelIntro` atiende todo en `_input` y traga el clic. `EpilogueScreen` pone la imagen con `STRETCH_KEEP_ASPECT_COVERED` y una franja de texto abajo. **El modelo de la intro es ese.**
- **Guardado** (`scripts/autoload/save_manager.gd`): `save()` arma un diccionario fijo con las claves de siempre; `load_save()` lee cada clave con su `_read_*` y **ignora las desconocidas**; si `version != SAVE_VERSION` empieza de cero (por eso la clave nueva **no** sube la versión). El modo de pruebas usa otro archivo (`DevMode.SAVE_PATH`, RF-181).
- **Música** (`scripts/autoload/audio.gd`, `_process`): toda escena que no sea `game.tscn` reproduce `music_menu`. Un overlay sobre el menú **no la corta**.
- **Wiki** (`scenes/ui/wiki_screen.gd`): arma la interfaz por código (`_build_layout`), las solapas con `_add_tab`, y tiene `on_leave: Callable` y `show_category`. La solapa Lore la sirve `Wiki.categories(...)`.
- **Textos:** `LevelTexts` (`scripts/logic/level_texts.gd`) es el modelo de un validador de texto con mensajes en castellano: **lógica pura, límites como constantes** (son de interfaz, no de balance).
- **Qué no hay:** ningún archivo `intro`, ninguna imagen de intro y ninguna clave de guardado para esto.

#### Qué se agrega

| Archivo (propuesto) | Qué es |
|---|---|
| `data/intro/intro.json` | Los datos (RF-497): `version`, `fundido_s`, `laminas[]` con `imagen`, `texto`, `segundos`. **Los números van acá**, no en el código. |
| `scripts/logic/intro_data.gd` | `IntroData` (`RefCounted`, lógica pura): `load_file(path) -> IntroData` con `laminas`, `fundido_s`, `errors` y `is_valid()`. Valida cantidad (5 a 8), líneas y caracteres (los de `LevelTexts.WIN_*` y `LINE_MAX_CHARS`: reusarlos, no copiarlos), `segundos` (4 a 12), `fundido_s` (0 a 2), que la imagen exista, `version`. Mensajes en castellano que nombran la lámina. |
| `scripts/logic/intro_flow.gd` | `IntroFlow` (lógica pura, **testeable sin cambiar de escena**): `should_auto_show(intro_seen, dev_enabled, data_valid) -> bool` (RF-498) y `after_finish(has_won_levels) -> Destination` (`LEVEL_1` o `LEVEL_SELECT`, RF-500). |
| `scenes/ui/intro_screen.gd` | `IntroScreen` (`CanvasLayer`, por código como `EpilogueScreen`): `open(data)`, `signal finished`, `is_open()`. La imagen con `KEEP_ASPECT` y barras oscuras; franja de texto abajo; botón «Omitir»; fundido con `Tween`; avance por clic, `Espacio`, `Enter`, `→` y por tiempo (`_process` con un reloj propio, para que el test no espere). **No sabe a dónde se va después.** |
| `assets/intro/01_*.webp` a `07_*.webp` | Las láminas (T241). 1920 × 1080. |

**Qué cambia:**
- `save_manager.gd`: la clave `"intro_seen"` (leer: solo `true` booleano cuenta; escribir en `save()`), `intro_seen() -> bool` y `mark_intro_seen()` (que guarda enseguida). `load_save()` la resetea a `false` junto con el resto.
- `main_menu.gd`: «Jugar» deja de ir directo a `GameFlow.go_to_level_select`: llama a un método propio que, según `IntroFlow.should_auto_show`, abre el overlay o va a la selección. Al `finished`: `IntroFlow.after_finish` → `GameFlow.start_level(0)` o `GameFlow.go_to_level_select()`.
- `wiki_screen.gd`: el botón «Ver la intro» arriba de la lista de la solapa Lore; abre el mismo overlay; al `finished` solo lo cierra (la Wiki queda como estaba).
- **Sin cambios:** `GameFlow` (salvo que T242 prefiera ponerle un método), `Audio`, los niveles, el editor, los modos, la Wiki y el guardado de los demás datos.

#### Orden de trabajo (T242)

1. **Datos y lector:** `data/intro/intro.json` con los textos del guion y `IntroData`, con sus tests (cada error). Las imágenes pueden ser **provisorias** (un PNG liso de 1920 × 1080) hasta que T241 entregue.
2. **Guardado:** la clave y sus tests (nuevo, con la clave, sin la clave, no booleana, guardado anterior, no toca el resto).
3. **`IntroFlow`** y su tabla de decisiones.
4. **`IntroScreen`** y sus tests de manejo.
5. **Conectar** «Jugar» y la Wiki.
6. **Con las láminas de T241:** medir el texto en 1280 × 720 y en tamaño de celular, y exportar otra vez (T237).

#### Pruebas que T242 tiene que escribir

- **`IntroData`:** el archivo oficial sin errores; 4 y 9 láminas; línea de 91; 3 líneas; 161 caracteres; texto vacío; `segundos` 3 y 13; `fundido_s` 3; imagen inexistente; `version` 2; el error nombra la lámina.
- **Datos oficiales:** cada imagen existe y mide 1920 × 1080; **cada texto es el de `specs/intro/guion.md`** (el test lee el documento y compara, como `test_level_texts.gd` con `11-textos-lore.md`); sin vocabulario vetado ni «Cántaro»; cada duración cumple `2 + caracteres/20`.
- **Guardado:** `intro_seen` en `save.json` y su lectura; `1`, `"si"` y `null` → no vista; el resto del guardado no cambia; **un guardado de antes** (formato real, como en `test_old_saves.gd`).
- **`IntroFlow`:** guardado nuevo → se muestra; con la clave → no; modo de pruebas → no; archivo roto → no; sin niveles ganados → nivel 1; con niveles ganados → selección.
- **`IntroScreen`:** un toque, `Espacio`, `Enter` y `→` pasan; el tiempo pasa (reloj inyectado); un toque durante el fundido salta; la última termina; «Omitir» y `Esc` terminan **una sola vez** (`finished`); el clic final no llega a lo de atrás; la lámina se ve entera en 16:9, 20:9 y 4:3.
- **Menú y Wiki, sin cambiar de escena** (`.claude/rules/tests.md`): «Jugar» emite lo que corresponde y no navega con la intro abierta; el botón «Ver la intro» existe en la solapa Lore, abre el overlay y no toca `intro_seen`. **Ojo:** `test_menus_and_flow.gd` y `test_main_menu_style.gd` usan `%PlayButton`: revisar que no asuman que «Jugar» va directo a la selección.

#### Riesgos y cosas que no se saben

- **El peso.** Siete PNG de 1920 × 1080 pintados pueden pasar de 3 MB cada uno (≈ 20 MB). T242 lo mide y lo anota; si es mucho, se optimizan (o se importan comprimidos) **sin cambiar la resolución** sin avisarle a Lucas.
- **Que el texto entre en la franja** a 1280 × 720 y en el celular con la misma fuente del epílogo (22 pt): no se midió. Dos líneas de 90 caracteres es el peor caso.
- **El «atrás» de Android** y `Esc`: hay que atenderlos en `_input` antes que el menú, como hace `LevelIntro`.
- **El modo de pruebas.** Al encender o apagar el modo, el menú se recarga (`go_to_main_menu`): con el overlay abierto no debería poder pasar (no hay acceso a Opciones), pero T242 lo comprueba.
- **Una sola lámina rota** (imagen que no carga en la exportación) no tiene que tumbar la intro: se omite esa lámina y se avisa en la salida. *(Propuesta de T242; no está en RF-497 y queda a su criterio.)*
- **El estilo de las láminas depende de Lucas** (P3): ningún código cambia con él.

#### Lo que M57 no toca

La campaña y sus niveles, `LevelFile`, la Wiki más allá de un botón, el epílogo, los créditos, los modos, el editor, la música y los efectos, y el formato del guardado salvo la clave nueva.

### M58 / T269 · Interfaz para el celular (RF-502 a RF-515, D-097 y D-098)

> **Estado: especificada en T269 (borrador, a la espera del OK de Lucas); sin programar.** La spec es **M58** (`01-spec.md`), las decisiones **D-097** y **D-098**, y las tareas **T270 a T277** (`03-tareas.md`). Los informes con las medidas y las capturas son los de **T262 a T265**. Los nombres de archivo de abajo son **propuestos**; los que ya existen están marcados.

#### Qué hay hoy (leído en el código, no supuesto)

- **Entrada táctil:** el juego no lee toques propios; Godot los convierte en clics del mouse (`emulate_mouse_from_touch`). `scenes/game/build_controller.gd` (existe) construye con el clic al **apoyar**, toma la casilla de `get_global_mouse_position()` y la vista previa sale de ahí (T262: P-02, P-12).
- **Cámara:** `scenes/game/game.gd` (existe) crea una `Camera2D` con el zoom automático de RF-251; los alcances y los disparos no dependen de ella (D-037).
- **Interfaz de la partida:** `scenes/game/hud.gd` y `hud.tscn` (existen) arman la barra de arriba (oro, vidas, oleada, Pausa, x1/x2 y «← Menú»), la de abajo (`BarLayout` en `scripts/logic/bar_layout.gd`, con torres, pestañas `bar_tabs.gd`, «Próxima oleada» y «Empezar oleada») y las muestran sobre una capa que **no** pasa por la cámara. `scenes/ui/tower_panel.gd` (existe) es el panel de torre de la derecha.
- **Salir:** `game.gd` abre `scenes/ui/exit_dialog.gd` (existe) desde «← Menú» (RF-460).
- **Guardado:** `scripts/autoload/save_manager.gd` (existe) tiene `DEFAULT_SETTINGS` (solo números y booleanos, `_read_settings` descarta lo demás) y claves aditivas como `_intro_seen` y `_collections`, que se leen con tolerancia.
- **Detección:** `OS.has_feature("mobile")` ya se usa en `scenes/ui/main_menu.gd` (RF-210). No hay un «modo de interfaz».
- **Tarjetas:** `scenes/ui/level_select.gd` (existe) arma el bloque de torres disponibles de cada tarjeta.
- **Qué no hay:** zoom del jugador, ningún botón flotante, ninguna torre fantasma, ninguna clave `ui_mode` ni `ui_prefs`.

#### Qué se agrega

| Archivo (propuesto) | Qué es |
|---|---|
| `data/ui/mobile_ui.json` | **Los números** de M58 (RF-503, RF-504, RF-506, RF-507, RF-509, RF-512, RF-513): `boton_alto_px` 56, `barra_alta_px` 64, `separacion_px` 8, `flotante_min_px` 64, `flotante_min_mm` 6.0, `toque_max_mm` 2, `pinza_gracia_ms` 150, `opacidad_con_fantasma` 0.45, `corrimiento_s` 0.2, `vender_rearmar_s` 3, `vender_min_s` 0.4, `mejorar_bloqueo_s` 0.35, `zoom_casilla_max_px` 64 (RF-506, enmienda D-205), `fantasma_distancia_botones` 1. Lo lee un `MobileUiConfig` (`RefCounted`) con valores por omisión y mensajes en castellano; **un archivo dañado usa los valores por omisión** (no bloquea el juego). |
| `scripts/logic/ui_mode.gd` | `UiMode` (lógica pura, **testeable sin escena**): `resolve(setting: int, has_mobile_feature: bool) -> bool` (¿modo celular?; un valor fuera de 0 a 2 vale 0) y `read_setting(raw) -> int`. Una función estática `is_mobile()` que lee el `SaveManager` y se usa donde haga falta. |
| `scripts/logic/touch_gesture.gd` | `TouchGesture` (lógica pura): recibe `down(index, pos, t)`, `move(index, pos, t)` y `up(index, pos, t)` y devuelve el gesto: `TAP`, `DRAG`, `PINCH`, `PAN` o `NONE`, aplicando RF-504 (un dedo que se movió más de `toque_max_mm`, dos dedos en algún momento, gracia de `pinza_gracia_ms`). **Sin nodos**, para probar cada regla con secuencias de toques armadas a mano. |
| `scripts/logic/ghost_placement.gd` | `GhostPlacement` (lógica pura): el estado del fantasma (`cell`, `tower_id`, `valid`, `reason`, `size` 1 o 2), `move_by_cells(delta)`, `clamp_inside(map_size)` (el 2 × 2 hacia adentro, RF-505) y `can_confirm(gold, resources) -> {ok, motivo, faltan}`. Reusa la validez de `BuildController` y el cálculo de `origin_for` (RF-292). |
| `scripts/logic/float_button_layout.gd` | `FloatButtonLayout` (lógica pura): `snap(pos, view) -> {side, y}` (el borde más cercano y la altura 0 a 1), `avoid(ghost_rect, buttons) -> {offsets}` (los corrimientos de RF-509 punto 2 y el choque entre botones) y `tick_side(...)` (de qué lado se abre la tilde). |
| `scripts/logic/ui_prefs.gd` | `UiPrefs` (`RefCounted`): `read(raw) -> UiPrefs` con los cuatro campos y los **valores por omisión por campo** (RF-508), y `to_dict()`. Lo usan `SaveManager` (`ui_prefs`, clave aditiva, `SAVE_VERSION` no cambia) y los botones flotantes. |
| `scenes/game/mobile_hud.gd` | `MobileHud` (`CanvasLayer` propio, por código como `IntroScreen`): los botones flotantes, el catálogo, la barra de la torre elegida y «Ver todo». Solo se crea si `UiMode.is_mobile()`. |
| `scenes/game/camera_controller.gd` | `CameraController`: el zoom y el desplazamiento de la `Camera2D` de `game.gd` (RF-506): pinza y dos dedos en el celular, rueda y botón central en PC. Límites desde `MobileUiConfig` y el zoom de RF-251. |
| `scenes/ui/level_select.gd` (existe) | Se redibuja el bloque de torres de la tarjeta con las Insignias (RF-514), sin cambiar qué torres aparecen. |

**Qué cambia:**

- `scripts/autoload/save_manager.gd`: `DEFAULT_SETTINGS` suma `"ui_mode": 0` (entero; `_read_settings` ya acepta enteros, y un valor fuera de 0 a 2 se lee como 0 en `UiMode.read_setting`); se suma la clave aditiva **`ui_prefs`** (`_ui_prefs: UiPrefs`, `get_ui_prefs()`, `set_ui_prefs()`), que se lee con tolerancia, **no sube `SAVE_VERSION`** y se escribe solo al soltar un botón arrastrado. Mismo patrón que `_intro_seen` (RF-498).
- `scenes/ui/options_menu.gd` (existe): el selector «Interfaz».
- `scenes/game/hud.gd` (existe): en el modo celular no crea «← Menú», sube el alto de Pausa y x1/x2, saca los atajos de los rótulos y agrega la cuenta atrás junto a la oleada; en PC no cambia ninguna línea de su comportamiento.
- `scenes/game/build_controller.gd` (existe): en el modo celular **deja de construir al apoyar** y de usar el mouse emulado: delega el toque en `TouchGesture` y el fantasma en `GhostPlacement`; el camino de la PC (RF-43) queda intacto y se cubre con los tests actuales.
- `scenes/game/game.gd` (existe): crea `CameraController` y `MobileHud` según el modo y pasa la altura de la barra de arriba al zoom automático.
- `scenes/ui/tower_panel.gd` (existe): en el modo celular no se muestra; su contenido lo dibuja la barra de la torre elegida.

#### Orden y dependencias

1. **T270 · Tarjetas con Insignias** (RF-514): independiente; sirve en PC y celular.
2. **T271 · Modo de interfaz, botones táctiles y barra de arriba** (RF-502, RF-503): base de todo lo del celular.
3. **T272 · Gestos y torre fantasma** (RF-504, RF-505) y **T273 · Zoom** (RF-506): después de T271. Pueden ir en paralelo; el fantasma con zoom se prueba al final.
4. **T274 · Botones flotantes y preferencia guardada** (RF-507 a RF-509, RF-511) y **T275 · Carrito y catálogo** (RF-510): necesitan T272; T275 necesita también T274.
5. **T276 · Barra de la torre elegida** (RF-512, RF-513): después de T272.
6. **T277 · Estatuas de torres** (RF-515, 🎨): independiente.

*(Si la numeración difiere de `03-tareas.md`, vale el tablero.)*

#### Cómo se prueba

- **Lógica pura con tests de GUT** (sin cambiar de escena, `tests/*.gd`): `UiMode` (valores 0, 1, 2 y basura), `TouchGesture` (un toque justo, uno que se corre 1 y 3 mm, una pinza, una pinza con un dedo que se levanta antes, el dedo rezagado dentro de los 150 ms), `GhostPlacement` (1 × 1 y 2 × 2, borde, casilla ocupada, sin oro), `FloatButtonLayout` (adhesión, corrimiento, choque entre botones, lado de la tilde) y `UiPrefs` (ausente, tipo malo, lado inválido, altura fuera de rango, guardado viejo, ida y vuelta). Los guardados de prueba son `user://test_*.json` (`.claude/rules/tests.md`).
- **Con la herramienta de toques** de T262 (`tools/mobile_probe.gd`, existe): secuencias de toques simulados sobre la partida real del nivel 1 y del 15, para confirmar que no se compra al apoyar, que la pinza y el arrastre no construyen y que 8 px debajo de «Mejorar» no venden.
- **PC:** los tests existentes y el bot de balance (`tools/balance_sim.gd`) dan **lo mismo** que antes de M58 (RF-515 último criterio). Cualquier diferencia es un error.
- **Capturas** en 1280 × 720 y en 20:9, con «Interfaz: Celular» en la PC.
- **No se prueba** (no hay celular): el tacto real, la pinza con dedos de verdad, los milímetros físicos, la muesca, el rendimiento. Eso es el kit de T262 §6, en la máquina de Lucas, y hasta entonces todo queda como «analizado en escritorio con la proporción del celular».

#### Riesgos

- **Clics emulados y toques reales a la vez:** si el mapa sigue leyendo clics emulados, un toque se procesa dos veces (G8). T272 tiene que apagar el camino emulado **solo en el mapa** y dejar los botones como están.
- **La barra de arriba más alta (64 px)** reduce el mapa: se recalcula el zoom de RF-251; en el nivel 15 la casilla puede bajar de 48 a 47 px. Se mide en T271.
- **El catálogo abierto con la partida en marcha** puede tapar un ataque. Es la decisión por defecto 1; si molesta, el cambio es una línea.
- **Infraestructura dentro del catálogo:** M53 arma sus pestañas con `bar_tabs.gd`; T275 comprueba que el flujo de demoler y extraer funciona con el catálogo cerrado.
- **Un guardado con `ui_prefs` roto** no puede impedir jugar: la prueba de guardados dañados de T268a (`tools/verify_save.gd`) se amplía con ese caso.

### M59 / T278 · Balance de los niveles 2 y 7 (RF-516 a RF-519, D-099)

> **Estado: especificada en T278 (decidida por Lucas en G7; sin programar).** La spec es **M59** (`01-spec.md`), la decisión **D-099** y las tareas **T279** (aplicar y medir) y **T280** (partidas de Lucas). El informe con todas las mediciones es `specs/tareas/informes/T266-auditoria-dificultad.md`.

#### Qué hay hoy

- Los niveles son archivos de texto (`data/levels/level_02.json` y `level_07.json`, RF-203): cada oleada es una lista de grupos `{enemigo, cantidad, cada, desde, entrada}`. Cambiar una cantidad **no necesita código**.
- El bot `tools/balance_sim.gd` lee el nivel de la campaña (`level=N`) o un archivo (`file=`), con `seed=`, `mejoras=` y `report=`; `check_rule=1` comprueba la regla de oro (RF-432). Los archivos de T266 (`tools/t266/*.json`) **no están en el repositorio**: se hicieron en una copia (variantes `l02_final_suave` y `l07_o2_o11_o18`).
- Asedio carga los mismos mapas con `data/modos/asedio/modo.json` (porcentaje de vida por mapa, T258).

#### Qué se cambia

| Archivo | Cambio |
|---|---|
| `data/levels/level_02.json` | Oleada 15: `boss.cantidad` 2 → 1; se quita el grupo `armored` (12, cada 0.8, desde 10.0). |
| `data/levels/level_07.json` | Oleada 2: los dos grupos `fast` 15 → 10. Oleada 11: `fast` (entrada A) 30 → 22. Oleada 18: `fast` 40 → 30 y `flyer` (entrada B) 25 → 20. |

Nada más: ni `balance.json`, ni `.tres`, ni código, ni assets, ni los niveles 13 a 15 (RF-518).

#### Cómo se prueba

1. **Antes** (con los archivos sin tocar) y **después**, con `nice -n 19` y a lo sumo 4 procesos a la vez: niveles 2 y 7 con **5 semillas** (1 a 5) y las estrategias de la tabla de T266 §5.1 y §5.2 (`mix`, `smart`, `basic`, `naive` en el 2; `mix`, `smart`, `demoler`, `naive` en el 7; con y sin `mejoras=llenar` y `temprana`). Se compara con la referencia de T266 (criterio de aceptación de M59).
2. **Regla de oro:** `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1`, 5 semillas, toda la campaña: «REGLA DE ORO: SE CUMPLE» y los mínimos del 13, 14 y 15 iguales que antes (hay que correrla **antes** también para tener con qué comparar).
3. **Asedio:** `modo=asedio level=2` y `level=7` con la política de T258 (mapa 2 `smart`, mapa 7 `sin_recursos`, mejoras al llenar) y 5 semillas.
4. **Tests de GUT:** la suite completa (los tests de niveles y de oleadas leen estos archivos: si alguno cuenta enemigos de la oleada 15 del 2 o de las 2, 11 o 18 del 7, **se actualiza ese número**, no el dato).
5. **Partidas humanas (T280, las juega Lucas):** 1 → 2 → 3, 6 → 7 → 8 y las seis partidas de T266 §7. No las reemplaza ningún bot.
6. **No se prueba** (límites): el tacto y el ojo humano (T280), el rendimiento y el celular.

#### Riesgos

- **Tests que cuentan enemigos** de esas oleadas (arriba, punto 4).
- **El 7 de Asedio queda más parejo, no más fácil:** T266 midió 5 de 5 con 6 vidas (antes 1 a 10); una explicación posible, no verificada, es que con menos Rápidos el bot cobra menos oro. Se remide en T279.
- **Que una partida humana contradiga al bot:** por RF-518 manda la partida humana y se pasa a la variante B del 2 (D-100) o se reabre el 7.

### T287 · Correcciones del HUD móvil tras probar el PR #10

1. Centralizar la captura de toque y mouse de los controles móviles; un gesto tiene un solo propietario, sin doble activación por mouse emulado. Cancelar al arrastrar; guardar solo al terminar el arrastre flotante.
2. Aplicar el tema existente a catálogo y barra; íconos SVG propios en botones redondeados. Medidas desde mobile_ui.json y sus valores de respaldo. Mantener costo en catálogo/barra y motivo inválido en barra.
3. Pintar detrás del mapa una textura de suelo del tema, sin cambiar la grilla, y dibujar un solo borde superior en su altura correcta.
4. Regresión con eventos de entrada completos (mouse y toque), ambos bordes, arrastre y colocación; GUT completo y capturas 16:9/20:9. Exportar EXE/APK de prueba, sin dar por validado el tacto real.

### M60 / T300 · HUD celular: catálogo único, demolición, pausa y «Ver todo» (RF-540 a RF-545, D-110 a D-113)

**Dónde:** `scenes/game/mobile_hud.gd`, `scenes/game/game.gd`, `scenes/game/build_controller.gd`, `scenes/game/camera_controller.gd`, `scripts/logic/ui_prefs.gd`, `scripts/logic/float_button_layout.gd`, `data/ui/mobile_ui.json`, `assets/ui/mobile_demolish.svg`.

1. **T301 · Catálogo único.** Se quita el `TabContainer`: queda un `ScrollContainer` con la grilla `TowerCards`. `set_catalog_data(available, gold, resources, uses_resources, machine_option)` arma un descriptor por torre **elegible** (la lista que ya tiene `Game.available_towers`, en su orden) y, si hay Demoledora sin comprar, uno más. `_sync_catalog_grid` (T290) sigue actualizando en el lugar. Al abrir se lleva el scroll al principio. `_infrastructure_options` desaparece del HUD; `Game._mobile_infrastructure_options` se reduce a la opción de la máquina.
2. **T302 · Botón de demolición.** `UiPrefs` suma `demolish_side` y `demolish_y` (valores por omisión en `mobile_ui.json`: `demoler_lado_default`, `demoler_y_default`). `FloatButtonLayout.avoid` cuenta tres botones y aplica la separación solo entre los del mismo lado. `MobileHud` crea `DemolishButton` (ícono `mobile_demolish.svg`), solo si `Game` se lo pide (`set_demolish_available`). Una herramienta nueva `&"obstacle"` en `BuildController.select_mobile_infrastructure_tool`; `Game._on_mobile_infrastructure_targeted` mira `infrastructure.obstacle_at(cell)`: `REMOVABLE` → `order`, `EXTRACTION` → `enable`; si sale bien, `cancel()`; si no, le pasa el motivo a `MobileHud.show_tool_message`. El estado de la barra `"tool"` (línea + cruz) lo dibuja `show_tool_status`, que `Game._process` llama cada cuadro mientras `mobile_action_active()`; el HUD clásico oculta los controles de oleada también en ese caso.
3. **T303 · Segundo plano.** `Game._notification`: `APPLICATION_PAUSED` siempre; `APPLICATION_FOCUS_OUT` solo si `OS.has_feature("mobile")`. Ambos llaman `pause_for_background()` (no hace nada si ya está en pausa, si la partida terminó o si hay un diálogo abierto, porque ya pausa).
4. **T304 · «Ver todo».** `CameraController` recuerda la posición de encuadre (`_fit_position`, la misma cuenta de `view_all`), llama `_update_view_all()` también después de correr (`_pan_by_screen_delta`) y muestra el botón si el zoom pasa el mínimo o la posición difiere en más de medio píxel. Sin `MobileHud` (PC), crea un botón propio, en el mismo lugar, que solo se ve con el zoom mínimo y el encuadre corrido.

Los textos, números de tamaño y posiciones nuevos viven en `mobile_ui.json` (P2), y el mínimo (`MobileUiConfig.DEFAULTS`) trae los mismos valores. **Qué no se prueba:** el tacto, la legibilidad, la posición del tercer botón con un dedo y el aviso real de Android.


### M61 / T310 · Menús del celular, entrada por dispositivo y «Créditos y versión» (RF-550 a RF-555, D-115 a D-117)

#### Cómo se hace

1. **Entrada por dispositivo (T311).** Lógica pura `scripts/logic/pointer_filter.gd` (`PointerFilter`): `note_touch(pos, now_ms)` guarda el último toque; `accepts_mouse(device, pos, now_ms)` es falso para `DEVICE_ID_EMULATION` y para un clic a ≤ 500 ms y ≤ 32 px de un toque. `BuildController._handle_mobile_input` y `MobileHud._input` usan una instancia cada uno (llaman `note_touch` con cada `InputEventScreenTouch` y filtran los `InputEventMouseButton/Motion`) y pierden las condiciones `OS.has_feature("mobile")` de los caminos de mouse. Los números van a `data/ui/mobile_ui.json` (`puntero_duplicado_ms`, `puntero_duplicado_px`).
2. **Desplazamiento táctil (T312).** `scripts/logic/kinetic_scroll.gd` (`KineticScroll`, puro): umbral de arrastre, frenado exponencial y velocidad mínima. `scenes/ui/touch_scroller.gd` (`TouchScroller`, un `Node` hijo del `ScrollContainer`): en `_input` toma `InputEventScreenTouch/Drag` dentro del rectángulo del contenedor (no si el dedo apoya en un `Range`: deslizador o barra), mueve `scroll_vertical`/`scroll_horizontal`, marca el evento como atendido, **traga los clics emulados mientras dura el arrastre** (el orden de Godot es clic emulado primero, T289 A.4) y le saca el foco al botón apoyado para que no quede «apretado». `scenes/ui/menu_touch.gd` (`MenuTouch.attach(root)`): en modo celular sube los botones de la pantalla a 56 px, engrosa las barras y cuelga un `TouchScroller` de cada `ScrollContainer`, y lo repite para lo que se agregue después (`SceneTree.node_added`).
3. **Distribución del celular (T313, T314).** `MainMenu`: en modo celular arma dos columnas (logo / botones). `OptionsMenu`: se reestructura la escena (`Frame` con título, `Scroll` con dos columnas y «Volver»); en PC las dos columnas se juntan en una. El resto de las pantallas solo llama a `MenuTouch.attach(self)`.
4. **Versión (T315).** `scripts/logic/game_version.gd` (`GameVersion`): `raw()` lee `application/config/version`; `label(raw)` da el texto (RF-554). Opciones agrega la sección. `export_presets.cfg`: versiones vacías.
5. **Verificación.** `tools/capture_menus.gd` (T310): capturas reales con ventana por pantalla y modo, e informe de botones fuera de la ventana. Tests de GUT por tarea; suite completa sin `SCRIPT ERROR` ni `Parse Error`.
### M62 · Peso de la intro y documento editable (RF-560 a RF-563, D-120, D-121)

1. **Peso (T320, T390):** primero `mipmaps/generate=false` (sin pérdida, 17,88 MiB). Después (D-150, T390) las láminas son `assets/intro/*.webp` sin pérdida con `compress/mode=1` y `compress/lossy_quality=0.9` en los siete `.webp.import` (4,00 MiB); el archivo es sin pérdida para no comprimir dos veces. El peso real es el de los `.ctex` de `.godot/imported/`; `art/intro-v1/peso.py` los mide por variante y arma `art/intro-v1/peso/comparison.html`. La variante WebP q0,90 se aplicó con el OK de Lucas (D-150).
2. **Documento editable (T321):** `scripts/logic/intro_doc.gd` (`IntroDoc`, lógica pura): `to_markdown`, `parse_markdown` (que valida con `IntroData.parse`), `to_json` (mismo formato y orden de claves que el archivo oficial) y `describe_changes`. `tools/intro_doc.gd` solo lee y escribe archivos (`export`, `import`, `import --dry`). Tests en `tests/test_intro_doc.gd`: ida y vuelta byte por byte, el documento versionado coincide con el JSON, y cada error con su mensaje.

### M63 / T330 y T331 · El tutorial del nivel 1 (RF-570 a RF-578, D-125 a D-128)

**Piezas** (la lógica pura se prueba sin ventanas, P10; las escenas solo muestran y avisan, P6):

| Pieza | Qué es |
|---|---|
| `data/tutorial/tutorial.json` | Los pasos y los textos: dos listas (`pc`, `celular`), los rótulos de la tarjeta y `"borrador"`. |
| `scripts/logic/tutorial_data.gd` (`TutorialData`) | Lee y valida el archivo (errores en castellano que nombran el paso). Trae la tabla `STEPS`: qué evento espera cada paso y en qué modo se usa. |
| `scripts/logic/tutorial_flow.gd` (`TutorialFlow`) | `should_auto_show(...)` (RF-570) y la máquina de pasos: `next()`, `notify(evento)`, `skip()`, `skip_satisfied(...)`, `rewind_to(...)`. Emite `step_changed` y `finished(completado)`. |
| `scripts/logic/tutorial_layout.gd` (`TutorialLayout`) | Dónde va la tarjeta para no tapar lo señalado y dónde apoya la flecha. |
| `scenes/ui/tutorial_overlay.gd` (`TutorialOverlay`, `CanvasLayer` capa 12) | La tarjeta, el recuadro y la flecha. Armada en código. Solo la tarjeta recibe el mouse y los toques. Consulta en cada cuadro **de dónde** sacar lo señalado (`targets_provider`, `fills_provider`). |
| `scenes/game/tutorial_controller.gd` (`TutorialController`) | El director: escucha las señales de la partida (`BuildController`, `LevelSession`, `Game.pause_changed`, `speed_changed`, `MobileHud.catalog_opened`), se las pasa a `TutorialFlow` y le dice a la tarjeta qué mostrar y qué señalar. Elige la casilla sugerida. |
| `Hud.target_control`, `MobileHud.target_control`, `TowerPanel.upgrade_button/sell_button` | Descriptores de **qué control señalar**: el tutorial no busca nodos por ruta. |
| `Game._start_tutorial_if_due()` | Decide si arma el tutorial (lo barato primero; el archivo solo se lee si hace falta) y lo arranca al cerrarse el cartel de entrada. |
| `SaveManager` | `tutorial_done()`, `tutorial_enabled()`, `mark_tutorial_done()`, `reset_tutorial()`; la clave `tutorial_done` y la opción `tutorial_enabled`. |
| `OptionsMenu` | La fila «Tutorial del nivel 1» / «Volver a verlo» y el contenedor con desplazamiento. |
| `tools/check_tutorial.gd`, `tools/capture_tutorial.tscn` | El validador por consola y las capturas reales (un PNG por paso, PC y celular). |

**Cómo se señala algo.** Cada paso pide, en cada cuadro, los rectángulos en **pantalla** de lo que señala: para un control, `get_global_rect()`; para una casilla, su posición en el mundo pasada por `get_canvas_transform()` (así vale con zoom y con cámara). Un control que no se ve ahora (el catálogo cerrado, el panel de una torre que no está elegida) devuelve `null` y no se dibuja nada: **no hay coordenadas escritas a mano**.

**Cómo se pasa de paso.** Los pasos de acción esperan un evento de `TutorialData` (`tower_selected`, `tower_built`, `catalog_opened`, `wave_started`, `placed_selected`, `speed_changed`, `paused`, `resumed`). Al llegar a un paso, `skip_satisfied` consulta si ya se cumplió (el jugador se adelantó). Si el jugador suelta la torre o cierra el catálogo, `rewind_to` vuelve a un paso anterior (tabla `REWIND_ON_DESELECT`).

**Qué no toca.** Ningún dato de nivel ni de balance, `BuildController` (solo se conecta a sus señales y llama `select_placed` para volver a elegir la torre construida), el HUD (solo se le suma `target_control`), el modo de pruebas ni el editor (`Game._start_tutorial_if_due` sale antes si `testing` o `DevMode.enabled`).

**Cómo se prueba.**
1. `tests/test_tutorial_data.gd`: el lector, **cada** error, los límites exactos y el archivo oficial.
2. `tests/test_tutorial_flow.gd`: `should_auto_show` (una condición por vez), la máquina de pasos, `rewind_to`, el guardado y la compatibilidad con guardados viejos.
3. `tests/test_tutorial_layout.gd`: la tarjeta no tapa lo señalado y queda dentro de la pantalla; la flecha.
4. `tests/test_tutorial_game.gd`: **la escena real** (`game.tscn`) recorrida entera en PC y en el celular (botones del HUD, catálogo, toques sobre el mapa, tilde y doble toque), más saltar, no repetir, apagar, guardado viejo, modo de pruebas, otro nivel, F6, editor, cartel de entrada y fin de partida.
5. `tests/test_tutorial_options.gd`: la fila de Opciones y que el panel entre en 720.
6. `tests/test_old_saves.gd`: la clave nueva con los guardados de cada época.
7. Capturas reales: `godot --path . res://tools/capture_tutorial.tscn -- <carpeta fuera del repo> 1280x720`.

**Riesgos.** (1) Un cambio futuro en los nombres de los controles del HUD se nota en los tests (los descriptores devuelven `null`). (2) `MobileHud` maneja los toques de su barra con código propio: la tarjeta queda **fuera** de esa barra y de los botones flotantes (se ubica entre las barras). (3) Solo se probó en una PC (RF-502): el tacto y la legibilidad en un celular real quedan para Lucas.

### M64 / T340 y T341 · Pantalla de carga general (RF-580 a RF-589, D-130 a D-134)

| Pieza | Qué es |
|---|---|
| `scripts/logic/scene_transition.gd` (`SceneTransition`) | **Núcleo genérico**, sin nombres del proyecto. `go(path)`, `is_busy()`, `progress()`, señales `started`/`finished`/`failed`; propiedades de tiempos, colores, tema y las costuras `swapper` y `load_override`. Corrutina `_run`: dibuja la capa, carga en hilo, espera el mínimo, cambia, espera cuadros y gracia, libera. |
| `GameFlow.transition`, `is_changing()`, `_change_scene()`, `reload_current()` | **Capa fina:** crea el núcleo con el tema de los menús, el mínimo y los colores; todo `go_to_*`/`start_*` pasa por ahí y sale antes de tocar el estado si hay un cambio en curso. |
| `Game.restart` | Llama a `GameFlow.reload_current()`. |
| `docs/skills-borrador/godot-pantalla-de-carga/SKILL.md` | Borrador de skill (T341). No se instala. |

**Cómo se bloquea la entrada:** `get_tree().root.set_disable_input(true)` (corta `_input`, la GUI y las acciones), una capa con `MOUSE_FILTER_STOP` y `GameFlow._notification` ignorando el «atrás» de Android. **Cómo se prueba:** `tests/test_scene_transition.gd` (núcleo, con `swapper` falso, eventos reales y experimentos de control) y `tests/test_loading_flow.gd` (la selección real, tarjetas tocadas durante el cambio). Suite completa sin `SCRIPT ERROR` ni `Parse Error`.
### M65 / T360 a T364 · Animaciones de mejora de torres (RF-590 a RF-596, D-135 a D-137)

**Estado: programado con arte provisional (T361, T363); falta el arte (T362) y su integración (T364).** Presentación pura: ningún cambio en `Tower`, `TowerData`, `BuildController.try_upgrade` ni en el balance. Lo implementado: `FloatingText` ganó un retraso opcional (`delay`) para el escalonado, `EffectsLayer.tower_upgraded(tower, canvas, safe_rects, view_rect)` devuelve `false` si no mostró nada (opción apagada, tope) y entonces `Game` dibuja el anillo de siempre, `MobileHud.forbidden_rects()` da las zonas de pantalla y `SaveManager.upgrade_fx_enabled()` lee la opción (un valor que no es booleano vale prendida). Las capturas las hace `tools/capture_upgrade.tscn`.

1. **Datos** (T361). `data/ui/mejoras.json` (duraciones, cuadros, escala, aclarado, fuente, escalonado, máximos, tabla de estadísticas) y `scripts/data/upgrade_fx_config.gd` (lector con valores por omisión si falta o está mal, como `MobileUiConfig`). `tools/check_mejoras.gd` valida y nombra el campo con error.
2. **Lógica pura** (T361). `scripts/logic/upgrade_deltas.gd` (`UpgradeDeltas`): `compute(from: TowerLevelData, to: TowerLevelData, table) -> Array[Dictionary]` (campo, delta, texto), `format_number(value, kind) -> String` (signo, coma decimal, sin ceros de más), `header(level, is_max) -> String` y `place_block(anchor, size, safe_rects, view_rect) -> Vector2` (corre el bloque dentro de la pantalla y fuera de las zonas prohibidas). Todo sin escena (P10).
3. **Efecto** (T363). `scenes/effects/upgrade_effect.gd` (`UpgradeEffect`, `Node2D` con un `Sprite2D` hijo y un `Tween`). `EffectsLayer.tower_upgraded(tower, level)` lo crea con el tope de RF-595 y los `FloatingText` de la cabecera y los renglones. `Game._on_tower_upgraded` llama a esa función en lugar de `tower_built` **solo si** `SaveManager.get_setting("upgrade_fx")`; si no, queda el anillo de hoy. Arte provisional con `_draw` hasta T364 (nunca se espera al arte).
4. **Zonas prohibidas** (T363). `Game` le pasa a la capa los rectángulos de la barra de abajo, la tilde, la cruz y los botones flotantes que ya conoce `MobileHud` (señal o consulta hacia abajo, P6); el tamaño de la fuente se compensa con el zoom de `CameraController`.
5. **Opciones** (T363). Casilla `UpgradeFxCheck` debajo de `DamageNumbersCheck`; clave `"upgrade_fx": true` en `DEFAULT_SETTINGS`.
6. **Arte** (T362, T364). Dos atlas PNG en `assets/sprites/effects/mejora/` (ficha `specs/tareas/T362-arte-animacion-mejoras.md`). Integración tras el OK de Lucas.
7. **Pruebas.** `tests/test_upgrade_deltas.gd` (los 11 `.tres` reales, 1→2 y 2→3: nunca un delta cero, nunca un campo fuera de la tabla), `tests/test_upgrade_fx.gd` (efecto y textos nacen y se borran; tope de 8; la opción apagada no crea nada; sin escena nueva: se instancia `EffectsLayer`), `tests/test_old_saves.gd` (clave aditiva), `tests/test_options_*` (la casilla entra en 720). Capturas reales: `tools/capture_upgrade.gd` (nuevo, como `capture_tutorial.gd`), en PC y en modo celular, fuera del repo. Rendimiento: `tools/perf_test.gd` con 60 torres y 10 mejoras.

**Riesgos.** (1) Una torre nueva con un campo de `TowerLevelData` que no está en la tabla: no se muestra y un test lo avisa. (2) El tinte puede dar un color poco legible sobre algunos suelos (la nieve): se revisa en la hoja de T362 sobre los siete temas. (3) El efecto y el brillo permanente se pisan visualmente: el efecto va en la capa de efectos, por encima, y es breve. (4) `Engine.time_scale` hace correr el `Tween` más rápido a velocidad doble: es lo buscado.

### M66 / T457, T461–T463 · Presentación animada de jefes (RF-666 a RF-673, D-187 a D-191)

**Estado:** T457 fijó la spec (aprobada por Lucas con el PR #61). T461 implementó el comportamiento con composición provisional (2026-10-23); el arte final sigue esperando T367/T243. **T548 (2026-10-28)** integró el fondo del Coloso (muestra 02): `data/ui/boss_presentation.json` + `BossPresentationArt` (`scripts/data/`) + franja de contraste en `BossPresentation`; `Game` pasa `backdrop` solo si el dato lo tiene. No cambia la spec ni el balance. PR #59 ya está mergeado en la base `398c016` y establece que la tarjeta RF-134 se omite para el jefe; esta rama solo lo refleja en la spec.

1. **Disparador y modo:** integrar solo en campaña normal iniciada desde el menú, primera oleada con jefe por partida. Omitir en Asedio, modo de pruebas, editor, comunidad y escenas sueltas. El flujo introductorio del tutorial no se excluye si forma parte de la campaña normal. Reintento equivale a partida nueva.
2. **Pausa/modal:** el controlador de presentación toma una instantánea del estado previo de pausa, pausa el árbol desde el nacimiento y anima con reloj real. No cambiar `Engine.time_scale`, la cámara ni las reglas del enemigo. Al terminar, solo reanudar si la app no pasó a segundo plano y no había pausa previa; `P` saltea y deja pausa. D-112 manda al perder foco.
3. **Duración y guardado:** consultar el registro aditivo `seen_enemies` existente antes de `mark_enemy_seen`; 5 s en primera vista del jefe y 3 s luego. No añadir clave ni modificar `SAVE_VERSION`. El salteo también registra al enemigo como visto.
4. **HUD:** congelar tweens del cartel de oleada y apariciones pendientes durante el modal; reanudar la cola al cerrarlo. El propio jefe no recibe «Nuevo enemigo» (PR #59). Asegurar que `balance_sim` no itere un árbol pausado ni quede esperando una señal de presentación.
5. **Datos y arte:** recursos de presentación con identificador, ilustración y fondo por jefe; movimiento mediante `Tween`/código. Fondos del Jefe y Coloso sujetos a aprobación visual. El jefe supremo del 15 no se produce hasta T243; después, T463 agrega su arte. No generar assets finales ni integrar sin aprobación de Lucas.
6. **Opción:** rescatar la clave `boss_entrance` existente (o verificar la clave real en el repo al implementar), cambiar etiqueta y reubicar la fila en el grupo «Partida y ayudas» como «Presentación de los jefes», mantener compatibilidad de guardados. No conservar restos del piloto que queden sin uso: destello, cartel con marco, tres PNG viejos, perf_test `entrada_jefe` y lectores/configuración obsoletos; auditar referencias antes de retirar.
7. **Verificación (T461):** pruebas unitarias y de escena para pausa, salteo tras 0,3 s, `P`, pausa previa, segundo plano D-112, ×2, guardado viejo/nuevo, cola de HUD, omisión RF-134 al jefe, modo prueba/Asedio excluidos, opción apagada y ausencia en escenas sueltas. `balance_sim` debe completar sin colgarse. Capturas de ventana en PC y modo celular simulado a 1280×720. No equivalen a prueba en teléfono real.
8. **Arte e integración (T367/T369):** T367 produce muestras fuera de `assets/` una vez fijada la guía; Lucas aprueba antes de integrar. T369 mide en PC con máquina libre y anota resolución, hardware, `uptime`/carga y build. El teléfono real queda bajo T454 y la prueba de Lucas. No afirmar rendimiento hasta tener registro limpio.

**Riesgos:** `D-112` puede dejar reanudación indebida; tweens del HUD pueden avanzar en pausa; un modal pausado puede dejar `balance_sim` esperando; la entrada no debe duplicar ni demorar el cartel de oleada; no reintroducir el límite viejo de 8 s.

### M71 / T410 a T415 · Integración histórica del arte (RF-625 a RF-629, D-165)

La integración M71 incluyó los atlas de mejora aprobados y el piloto anterior de jefes. Ese piloto no define el M66 nuevo. T461 auditará las referencias y retirará en el mismo PR las piezas viejas que no se reutilicen (destello, cartel/marco, PNG y `perf_test entrada_jefe`). La medición histórica de T414 no certifica los umbrales de la presentación nueva ni sustituye una medición limpia PC o la prueba real de T454.

### M67 / T370 a T375 · «Novedades de esta versión» (RF-603 a RF-609, D-141 a D-144)

**Estado: pantalla y datos implementados; T375 integra el arte aprobado. Sigue pendiente el OK de Lucas a los textos.** No cambia la partida, el balance ni el progreso. Sigue el molde de la intro (M57, `IntroData`/`IntroFlow`/`IntroScreen`) y del tutorial (M63, `TutorialData`/guardado aditivo).

1. **Datos y validador** (T371). `data/novedades/novedades.json` (nace con la lista de versiones vacía, que es válida y no muestra nada, hasta que T374 cargue la 1.0.0); `scripts/logic/news_data.gd` (`NewsData`: `parse`, `load_file`, `entry_for(version)`, `latest()`, `errors`, límites de RF-605); `tools/check_novedades.gd` (errores y avisos en castellano); `tests/test_news_data.gd`.
2. **Reglas puras** (T371). `scripts/logic/news_flow.gd` (`NewsFlow.should_auto_show(...)`, `NewsFlow.is_new_save(...)`; sin escena, P10) y `tests/test_news_flow.gd` con todos los casos de RF-603 (beta, vacía, igual, distinta, borrador, sin entrada, modo de pruebas, editor, «mejoras» con guardado nuevo y con guardado viejo, «presentacion» con guardado nuevo).
3. **Guardado** (T371). `SaveManager`: `_news_version: String`, `news_version_seen()`, `mark_news_seen(version)`; lectura tolerante en `load_save` y escritura en `save`; `tests/test_old_saves.gd` con los guardados de cada época.
4. **La pantalla** (T373). `scenes/ui/news_screen.gd` (`NewsScreen`, `CanvasLayer` capa 17, estilo de `CreditsScreen`): fondo oscuro, panel hierro y bronce, cabecera opcional, título, subtítulo, versión (`GameVersion.label`), lista dentro de un `ScrollContainer` con `MenuTouch.attach` y `TouchScroller` en el celular (M61), y «Entendido» fijo. Señal `closed`. `open(entry, draft_label)` crea los nodos; al cerrar se borran. Se traga el toque que cierra (RF-466/RF-499).
5. **El enganche** (T373). `MainMenu._ready` (al final): `NewsFlow.should_auto_show(...)` con costuras para los tests (ruta del archivo, versión, banderas); si da verdadero, `SaveManager.mark_news_seen` y `news_screen.open`. `OptionsMenu`: botón `NewsButton` debajo de `CreditsButton` que abre la entrada de RF-607 y devuelve el foco al cerrar; deshabilitado con «No hay novedades» si el archivo no sirve.
6. **Contenido** (T374). Las entradas de la 1.0.0 con el OK de Lucas; `CONTENIDO.md` («Cómo agregar las novedades de una versión»), `CHANGELOG.md`, `README.md` y `ONBOARDING.md`.
7. **Arte** (T372, T375). Cabecera, íconos y variante sobria (ficha `specs/tareas/T372-arte-novedades.md`). Hasta el OK de Lucas, la pantalla usa `_draw` sencillo y ningún ícono (nunca se espera al arte).
8. **Pruebas.** Unidad: `news_data`, `news_flow`, `old_saves`. De escena sin cambiar de escena (`.claude/rules/tests.md`): `tests/test_news_screen.gd` instancia `NewsScreen` sola (abre, lista de 8, se cierra con «Entendido» y con `Esc`, borra sus nodos, el toque que cierra no pasa) y `tests/test_news_options.gd` (el botón, deshabilitado sin archivo, no toca el guardado; Opciones entra en 720 en modo celular). Capturas reales con `tools/capture_news.gd` (nuevo, como `capture_tutorial.gd`) en PC y en modo celular 1280 × 720, con 8 novedades y con 1.

**Riesgos.** (1) Olvidarse de subir `config/version` o de agregar la entrada al publicar: lo cubre `tools/check_novedades.gd` (aviso) y la lista de T375. (2) La pantalla y la intro no compiten (la intro es al tocar «Jugar»), pero sí en el primer arranque de un guardado nuevo: la presentación va primero y se cierra con un toque. (3) En el celular, el panel de 880 px con 8 filas de 56 px o más necesita desplazamiento: se prueba con la lista completa. (4) Las imágenes pesan en la APK (M62): sin mipmaps y con el peso importado anotado.

### M68 / T400 a T405 · Pausa que bloquea el carrito, «Ver todo» con tecla propia y «Mejorar» con antes → después (RF-610 a RF-619, D-160 a D-164)

**Estado: implementado (2026-10-20).** No cambia el balance ni las reglas de la partida, y no sube `SAVE_VERSION`.

1. **Pausa y carrito** (T401). `MobileHud.set_paused(bool)` (variable `_paused`): cierra el catálogo, apaga `CartButton` y `DemolishButton` (`disabled`) y corta sus acciones: `_on_cart_pressed` (que usa también el toque soltado), el toque soltado sobre la demolición y `open_catalog`. La línea vacía de la barra pasa a `PAUSED_TEXT` y vuelve a `EMPTY_TEXT`. `Game` conecta `pause_changed` con `mobile_hud.set_paused`. `BuildController.can_build` ya negaba construir en pausa (RF-104) y `Game.set_paused(true)` ya suelta el fantasma.
2. **La tecla** (T402). `scripts/logic/view_all_binding.gd` (`ViewAllBinding`, lógica pura): `apply(keycode)` deja una sola tecla en la acción `view_all` de `InputMap`, `conflict(keycode)` dice qué acción ya la usa (recorre `InputMap`, más `F1` a `F12` y las reservadas), `current_key()` y `key_text()`. La acción nace en `project.godot` con la V (código 86). `UiPrefs.view_all_key` (campo aditivo, lectura defensiva) y `SaveManager` aplican la tecla al cargar y en `set_ui_prefs`. `Game._unhandled_input` llama a `camera_controller.view_all()` con la acción (después de la guarda de menús abiertos). `CameraController._update_view_all` muestra el botón de la PC con `zoomed or is_view_displaced()` y le pone la ayuda con la tecla (`view_all_tooltip`).
3. **Opciones** (T402). `OptionsMenu._build_view_all_row()` (solo si la interfaz no es la del celular): una `VBoxContainer` `ViewAllRow` con el botón `ViewAllKeyButton`, `ViewAllRestoreButton` y el aviso `ViewAllNote`, justo debajo de «Entrada de los jefes». `set_view_all_key(keycode) -> bool` es la costura de los tests; `_input` toma la próxima tecla mientras espera (y se queda con `Esc` para cancelar sin cerrar).
4. **Antes → después** (T403, T404). `UpgradeDeltas.before_after(from, to, table, max_stats)` (usa `compute`, así comparte orden, tolerancia y tope), `preview(levels, level_index, table, max_stats)` (vacío en el último nivel) y `format_value`. `TowerPanel._refresh_upgrade_preview()` crea el `Label` `UpgradePreview` encima de «Mejorar» y `MobileHud._upgrade_preview_text()` suma el renglón «Al mejorar: …» a la barra. Ambos leen `UpgradeFxConfig.load_from()` una vez y la guardan.
5. **Documentos** (T405). Ver RF-619 y D-164. Se borra `franja_px` de `data/ui/mobile_ui.json` y `MobileUiConfig`.
6. **Pruebas.** `tests/test_pause_lock.gd`, `tests/test_view_all_binding.gd`, `tests/test_upgrade_preview.gd`, y casos nuevos en `tests/test_view_all_displaced.gd` (el de la rueda en PC cambia: ahora el botón aparece).

**Riesgos.** (1) `InputMap` es global: los tests que cambian la tecla la restauran en `after_each`. (2) El panel de la PC crece unas dos líneas con la preview; crece hacia arriba (`grow_vertical`), pero no se midió con una captura. (3) Otras acciones de teclado nuevas tendrían que sumarse a `ViewAllBinding.label_for_action` para que el aviso las nombre.

### M60 / T268b · Copia de seguridad automática del guardado (RF-520 a RF-522, D-102)

> **Estado: especificada (2026-10-16); sin programar.** La spec es **M60** (`01-spec.md`), la decisión **D-102** y la tarea **T281** (`03-tareas.md`).

#### Qué hay hoy

- `SaveManager.save()` (`scripts/autoload/save_manager.gd`) abre `save_path` con `FileAccess.WRITE` y escribe todo el diccionario: es **lo único** que escribe `save.json`. `load_save()` solo lee.
- `save_path` vale `DEFAULT_PATH` (`user://save.json`); el modo de pruebas lo cambia a `user://save_pruebas.json` (`DevMode.set_enabled`), y los tests a `user://test_*.json`.
- `mark_intro_seen()` llama a `save()` al abrirse la intro: por eso la **primera apertura** de una build nueva sobre un guardado sin `intro_seen` ya reescribe el archivo (T268a §0.4).

#### Qué se cambia

| Archivo | Cambio |
|---|---|
| `scripts/autoload/save_manager.gd` | Una función privada que se llama **al principio de `save()`** (una vez por ejecución, bandera en memoria): decide si corresponde, arma el nombre `<prefijo><versión>.json`, copia byte a byte a `.tmp` y renombra. Dos variables públicas para los tests: la ruta que se respalda (por omisión `DEFAULT_PATH`) y el prefijo (`user://save_respaldo_`). `save()` sigue devolviendo lo mismo de siempre. |
| `project.godot` | Se agrega `config/version="1.0.0"` en `[application]`. |
| `tests/test_save_backup.gd` | Test nuevo con los casos del criterio de M60 (todos en `user://test_*`). |

Nada más: ni `SAVE_VERSION`, ni el formato del guardado, ni `dev_mode.gd`, ni datos, ni escenas, ni assets.

#### Cómo se decide si se copia (en orden)

1. Si ya se miró en esta ejecución → no.
2. Si `save_path` no es la ruta que se respalda → no (modo de pruebas y tests); **no** se marca como mirado.
3. Se marca como mirado.
4. Si `save.json` no existe o mide 0 bytes → no.
5. Si el respaldo de esta versión ya existe → no.
6. Si ya hay 10 respaldos → `push_warning` y no.
7. Se copia a `.tmp` (pisando un `.tmp` viejo) y se renombra al nombre final; si algo falla → `push_warning`, se borra el `.tmp` y se sigue.

#### A comprobar al programar (no se asume)

- Si `DirAccess.rename` pisa un destino existente en Godot 4.7.2 en Linux: aunque pise, el paso 5 ya garantizó que no existe; solo hay que anotarlo.
- Cómo reproducir «la copia falla» en un test sin tocar la carpeta real: un directorio con el nombre del `.tmp` o del respaldo final dentro de `user://test_*/`.
- El tope de 10 es de formato (como el nombre), va como constante en el código.

#### Cómo se prueba

1. `godot --headless --import` y luego `tests/test_save_backup.gd` y la suite completa de GUT (sin `SCRIPT ERROR`).
2. Antes y después de la suite: `ls ~/.local/share/JuegoA/` **no** muestra ningún `save_respaldo_*.json` nuevo (los tests no ensucian la carpeta real).
3. Con un `save.json` de prueba copiado a una carpeta de usuario aparte, abrir el juego y comprobar el respaldo con `sha256sum` (límite: en esta máquina Linux, no en Windows).
4. **No se prueba:** Windows, Android, ni el archivo real del tester (eso es la parte manual de T268).


### M61 / T282 · El Mortero alcanzable en el nivel 9 (RF-523 a RF-525, D-103)

> **Estado: especificada (2026-10-16); sin programar.** La spec es **M61** (`01-spec.md`), la decisión **D-103** y las tareas **T282** (Codex) y **T283** (Lucas) en `03-tareas.md`.

#### Qué hay hoy

- `data/levels/level_09.json`: la leyenda `e` es `{"removible":{"clase":"escombro","probabilidad":50.0,"recursos":1.0}}` y se usa en tres casillas, (3,2), (14,2) y (7,8). La `u` es la ruina con la pieza de la Disruptora (11,6).
- `data/obstaculos.json`: la clase `escombro` cuesta 90 de oro y 10 s, con `recursos` 0, `probabilidad` 0 y `recursos_si_recuperado` 1. La leyenda del mapa la sobrescribe por letra (RF-398).
- `data/towers/mortar.tres`: `cost = 300`, `resource_cost = 3`, `reserved = true`. El 9 lo habilita con `"torres_extra"`.
- Al empezar la partida se sortea, por cada removible y en orden de fila y columna, si entrega su recurso, con un generador con semilla (RF-417). Con `probabilidad` 100 siempre entrega.

#### Qué se cambia

| Archivo | Cambio |
|---|---|
| `data/levels/level_09.json` | `"probabilidad":50.0` → `"probabilidad":100.0` en la letra `e`. Una línea. |
| `tools/balance_sim.gd`, `scripts/logic/balance_args.gd`, su test, `ONBOARDING.md` | **Solo si** `demoler` no demuele los tres escombros: la estrategia `mortero` (RF-524, punto 5). |

Nada más: ningún otro nivel, ni `obstaculos.json`, ni `mortar.tres`, ni código del juego, ni escenas, ni assets.

#### A comprobar al programar (no se asume)

- Si algún test o documento exige el 50 % del 9 (`tests/test_levels_8_9.gd`, `CONTENIDO.md`): se ajusta a 100 y se anota. El 8 y los demás se mantienen.
- Que `LevelFile.parse` acepte `100.0` (el tope es «mayor que 100 = error», RF-398).
- Que el editor de mapas conserve el valor al abrir y guardar el nivel (ida y vuelta).

#### Cómo se prueba

1. `godot --headless --import` y la suite de GUT completa (sin `SCRIPT ERROR`).
2. Bot, 5 semillas: `check_rule=1` con `levels=6-9`, `levels=10-12` y `levels=13-15`; luego `sin_recursos`, `mix`, `demoler` y `demoledora` en el 9, con la tabla por semilla de RF-524.
3. **No se prueba:** una partida humana (T283), ni el Mortero visto en pantalla en el 9, ni Windows ni celular.
### M70 / T420 a T422 · El consejo de la pantalla de derrota (RF-630 a RF-639, D-171 a D-175)

| Pieza | Qué es |
|---|---|
| `data/consejos/consejos.json` | Ajustes, criterios de torre, reglas por enemigo. Borrador hasta el OK de Lucas. |
| `scripts/logic/advice_data.gd` (`AdviceData`) | Lee y valida el archivo (errores en castellano). Evalúa un criterio contra una `TowerData` y una condición contra una `EnemyData`. |
| `scripts/logic/leak_log.gd` (`LeakLog`) | El registro de fugas: `record(enemy, lives)`, `leaks`, `lives`, `total_lives()`. |
| `scripts/logic/defeat_advice.gd` (`DefeatAdvice`) | `tower_tip(data, log, wave_counts, offered)` (RF-633). Pura: sin escena ni autoloads. |
| `Game` | Crea el `LeakLog`, lo alimenta en `_on_enemy_reached_exit`, al perder arma el texto y se los pasa a `EndScreen.show_defeat`. |
| `EndScreen` | Un `Label` con salto de línea debajo del detalle; solo muestra (P6). |
| `tools/check_consejos.gd` | Validador por consola (no usa autoloads). |
| `tools/balance_sim.gd` | Opción `consejo=1`: al perder, imprime el consejo y las fugas (T422). |

**Costo.** Una suma en un diccionario por enemigo que llega; al perder, un recorrido por 15 reglas × 19 enemigos × 11 torres. Nada por cuadro.

**Riesgos.** (1) Un tipo de enemigo sin regla (Normal, Cría…) diluye el peso: el piso del 30 % evita un consejo por un detalle. (2) La medición con bot de RF-639 no reemplaza partidas humanas.

#### T433 · Preferencia para ocultar los consejos (RF-644, D-177)

`SaveManager.DEFAULT_SETTINGS` suma `defeat_advice: true`; el getter defensivo devuelve `true` si la clave falta o no es booleana. `OptionsMenu` agrega «Consejos en la derrota» a las casillas de visualización y lee/escribe esa preferencia desde el mismo menú usado por el menú principal y pausa. `Game` consulta la preferencia antes de cargar o evaluar los consejos; apagada, la derrota recibe texto vacío. La clave se guarda en `settings` sin subir `SAVE_VERSION`.

**Pruebas:** casilla prendida por omisión, apagar/cerrar/abrir y persistencia, guardado antiguo, valor inválido, apertura desde los dos menús, modo celular con altura y área táctil válidas; derrota sin cálculo cuando está apagada y victoria sin consejo. Suite GUT completa.

### T375 · Arte de Novedades (RF-640 a RF-642, D-170)

1. Copiar los diez PNG aprobados a `assets/ui/novedades/`, sin alterar fuentes ni muestras. Importación `compress/mode=0`, `mipmaps/generate=false`; registrar bytes de origen y `.ctex` en `art/t375-integration/import_report.json`.
2. Conectar en `novedades.json` la cabecera 4:1 y los siete medallones correspondientes. Mantener textos, `borrador`, versión y presets. La banda 8:1 y `upgrade` quedan disponibles para datos posteriores; declararlos con motivo en `KNOWN_UNUSED` de la auditoría de recursos, sin excluir el resto de la carpeta.
3. `NewsScreen`: cabecera al ancho interior y altura según proporción de la textura; nombres de nodos para comprobar la conexión. Íconos 48/64 según modo, carga al abrir; conservar el rombo para datos sin imagen. Títulos debajo de la ilustración sobre el panel oscuro, sin superposición.
4. GUT: contenido oficial con arte en ambos modos, proporción de las dos cabeceras, mezcla con/sin ícono, lista larga y botón visible. Importar antes de probar; devolver únicamente los SVG de `assets/` reescritos accidentalmente por el importador. Correr la suite completa y revisar errores del motor además del total.
5. Capturar con `tools/capture_news.tscn` la entrada oficial y el final de la lista en PC y celular; registrar límites de la prueba y lista de publicación sin ejecutarla. Actualizar solo T375 en el tablero, más changelog y guías afectadas.

### M72 / T425 a T432 · Pulido desktop del selector, entrada y panel de torre

1. **T425 fija contratos y división** (RF-645 a RF-654, D-178 a D-180). La opción de selector es una preferencia de interfaz guardada en `settings`, separada de progreso; los estados del mapa se derivan de la campaña y del mejor resultado existente. No subir `SAVE_VERSION`.
2. **T426 trabaja en el selector de tarjetas por separado.** Auditar `LevelSelect` y sus estilos antes de cambiar escenas compartidas; conservar RF-111 y las insignias de torres de RF-514. Ajustar grilla para 15 niveles a 1280×720 sin scroll. Los fondos temáticos quedan detrás de T427/aprobación y no bloquean la estructura funcional.
3. **T427 prepara y presenta muestras del mapa** (sin integrar ni cambiar el juego). Hoja de lectura a 1280×720, aterrizaje, 15 zonas y estados superpuestos; incluir fuente, procedencia y contraste.
4. **T428 integra el modo planetario** después de T425 y de aprobar la dirección de T427. Crear un modelo visual puro desde `CampaignProgress`/los registros actuales; no guardar estados de zona. La navegación comparte la selección habilitada de tarjetas.
5. **T429 aborda la tarjeta de entrada** después del lenguaje visual de T426; separar el flujo desktop del táctil y cubrir una sola continuación por evento.
6. **T430 rediseña el panel de torre** en una rama propia. Antes de editar, revisar `TowerPanel`, `UpgradeDeltas`, el mapa de input y selección; decidir si resolver bajo el panel por reubicación, ocultamiento temporal o foco explícito. El alfa no es una solución de input.
7. **T431 es diagnóstico de arte solamente**. Leer atlas y regla D-049 antes de sugerir espejado; comparar personajes y poses a escala del juego, memoria/importación y costo de producción. Lucas aprueba una opción antes de producir ciclos.
8. **T432 es análisis de balance/uso sin editar datos.** Reproducir niveles 1–4 con varias estrategias y semillas existentes; informar vida final/estrellas, torres ofrecidas y decisiones observadas del bot. Separar con claridad el test humano de Lucas y sus límites. Cualquier ajuste posterior requiere una spec propia.
9. Para cambios funcionales: tests focales (estados de campaña, input mouse/teclado, modo, torre cubierta y continuación), importación Godot y suite GUT completa; capturas a 1280×720 y 1920×1080. Evitar ejecutar pruebas de rendimiento junto con el import/test suite. Restaurar solo los SVG reescritos accidentalmente por importación.
10. **Límite de paralelismo:** T426/T427 pueden avanzar en estructura y propuesta de arte tras acordar T425; T428 espera aprobación visual. T429 espera la dirección visual de T426. T430, T431 y T432 son independientes entre sí y no editan escenas del selector. Los PRs se mantienen separados por tarea/componente.

### M74 / T439–T443 · Hub Herramientas y editor de banderines

1. **T439 fija contratos y tareas** (RF-660 a RF-665, D-184 a D-186). El alcance inicial es desktop; se aprovechan los dos editores como escenas separadas. No se modifica progreso ni SAVE_VERSION.
2. **T440 presenta la dirección de catálogo visual** para paletas y emblemas abstractos, usando la estética dimensional de T277/T437. Debe mostrar vista a 220 px y 34 px, opciones distinguibles sin depender solo del color y fuentes editables. La muestra queda para aprobación de Lucas antes de declarar final el catálogo.
3. **T441 crea el hub Herramientas** y redirige el acceso actual. Mantener la condición de disponibilidad del editor de mapas y restaurar `MapEditor` al regresar de «Probar» con borrador intacto; cambiar solo la salida normal para volver al hub.
4. **T442 implementa `BannerRecipe`/catálogo y persistencia dedicada**, validados por lógica pura y aislada de autoloads. Leer ids de catálogo; escritura atómica si el patrón existente lo permite. Datos ausentes, inválidos o desconocidos vuelven al preset inicial.
5. **T443 integra el editor desktop** con preview grande y a 34 px; cambios en borrador hasta «Aplicar», «Cancelar»/Escape y «Restaurar». La visual del poste se personaliza solo si Game establece explícitamente el contexto de campaña completada para el nivel 6. En los demás contextos no leer preferencias ni variar el emblema enemigo.
6. Validar navegación con mouse/teclado, foco visible, flujo «Probar» y regreso, almacenamiento aislado y estados de contexto. Importar Godot antes de GUT; ejecutar suite completa y capturar hub/editor a 1280×720 y 1920×1080. Restaurar guardados temporales y registrar qué no se verificó en hardware real.
7. T440 no bloquea la arquitectura ni el hub; la aprobación de Lucas sí bloquea integrar el catálogo final. Los recursos de muestra no se tratan como arte aprobado.

### M76 / T459 · Selector, mapa, Asedio y postes (RF-687 a RF-698, D-198 a D-203)

**Contrato previo al código:** Lucas revisa T459. La aprobación funcional no aprueba arte ni posiciones: T469 presenta muestra del planeta/insignias; T475 registra OK por cada uno de los 15 mapas. No se integra una posición faltante por inferencia.

1. **T470, selección y preferencias.** `CampaignMap` conserva el modelo puro de estados. `CampaignRegion` separa el input de puntero de `ui_accept`: clic/toque selecciona sin emitir inicio; Enter confirma una vez; `double_click` no inicia. La vista emite selección/inicio hacia LevelSelect (P6), que verifica acceso de nuevo. Separar lienzo desplazable y ficha fija con Jugar. Reutilizar `MenuTouch` y sus umbrales, medir si hace falta scroll con ancho disponible; no introducir zoom ni cámara de partida. Marcadores táctiles ≥56 px, sin hitboxes solapadas, foco visible y scroll que sigue foco. En PC, ofrecer barra/rueda horizontal; en celular un dedo. No tocar `game.gd`/`camera_controller.gd` en esta tarea.
2. **Migración del estilo en T470.** `SaveManager` valida `settings.selector_map_migrated` como booleano y `selector_style` como enum. Si la marca falta/es falsa/inválida, mapa y marca en el siguiente guardado exitoso; si es verdadera, preferencia válida. Mantener `SAVE_VERSION=1` y los otros campos. Tests con guardado viejo, nuevo, corrupto, migrado que eligió tarjetas, fallo de escritura y los dos archivos normal/pruebas aislados. T461/T458 también editan SaveManager: serializar esas tareas o sincronizar antes del PR, sin dos agentes sobre el archivo.
3. **T469 → T471, muestra y geografía.** T469 prepara en `art/t469-mapa-propuesta/` una revisión del mapa planetario integrado por T428, cuya muestra base es T427, sin tocar assets runtime: fuente editable, procedencia, paleta/biomas canónicos, estados y capturas PC/celular a escala. Mantiene los elementos aprobados de T428 y aplica la dirección ya decidida por Lucas; solo los cambios visuales de esa muestra esperan su aprobación antes de integrarse. No fijar por comodidad las coordenadas propuestas en T449: son punto de partida, no aprobación. Después del OK, T471 actualiza `CampaignMap` y fondo a partir de la misma geometría aprobada; tests de punto-en-polígono, margen de costa de marcadores, no cruces de mar/ruta y orden oeste→este. La opacidad gris y banderas son capas de UI según progreso, no fondos duplicados por guardado.
4. **T472, acceso de Asedio.** Agregar regla pura de elegibilidad específica para id oficial `asedio`: normal = victoria en campaña correspondiente OR derecho heredado; pruebas = todos. Otros modos conservan comportamiento. `GameFlow.level_won` deja de desbloquear siguiente Asedio por victoria de Asedio; no toca avance de campaña ni otros modos. La migración se ejecuta por archivo válido una vez: identifica evidencia real en registros/estrellas/puntajes de Asedio, calcula conjunto permitido por la regla vieja (incluido primer mapa y siguiente al ganado), lo une a ids ya abiertos y persiste solo ids válidos. Un `unlocked` genérico creado automáticamente sin evidencia de juego no se usa para dar acceso a un usuario nuevo. Recuperar récords aunque un registro de nivel falte; no borrar datos desconocidos de otros modos. Tests con guardado nuevo, antiguo jugado/no jugado, nivel ganado fuera de orden, archivo inválido, reentrada y cambio normal→pruebas→normal. No registrar victorias de pruebas en archivo normal.
5. **T473, remanente de T235.** Una fila de solapas desplazable mantiene el orden RF-389 y `GameFlow.select_page` estable (`mode:<id>`). Récords toma catálogo de `ModePacks` y usa ids compuestos existentes, sin copiar puntajes. Mostrar modos inválidos con el diagnóstico vigente; no intentar cargar registros de un modo que no existe. Con cinco propios se prueba acceso por mouse, teclado y touch simulado y retorno a misma solapa. T235 queda absorbida por esta tarea, nunca declarada funcionalmente completa solo por transferirla.
6. **T474, insignias y numeración.** Reutilizar receta/paleta validadas del editor para la parte del jugador y arte rebelde fijo. T469 entrega muestra del círculo rebelde/partido/jugador antes de integrar. Centralizar formato del número visible desde índice/id de campaña; auditar selector, entrada, HUD, victoria/derrota, Wiki y Récords, preservando nombres/textos canónicos, ids y rutas. Mantener candado y razón accesible del bloqueo aun sin rótulos redundantes. No editar textos de lore para reemplazos globales `01→1`.
7. **T475, postes tras OK por mapa.** La ficha contiene candidatos iniciales comprobados por lectura de JSON, aún no aprobados. Preparar captura o plano con grilla/coord de cada nivel para Lucas y anotar su decisión individual; comprobar de nuevo contra el commit base antes de integrar. Dibujar postes como decoración visual superpuesta en coordenadas aprobadas de casillas ya bloqueadas permanentes, preservando la decoración/señal existente y sin convertir `.`, camino, entrada/salida, removibles ni extracción. Si se oculta una señal o no cabe, proponer otra ubicación y volver a pedir OK de ese mapa. Usar datos visuales dedicados, no números de balance en código. Game pasa contexto de campaña+estrellas hacia `LevelDecor`; los hijos no leen SaveManager. Solo 3 estrellas concede variante jugador y receta; los demás contextos no heredan progreso normal.

**Serialización y revisión:** T470, T471, T473 y T474 comparten selector/mapa y van en serie. T472 comparte SaveManager/GameFlow con T461; T475 comparte `game.gd` con jefes y carga/franjas: se coordina un propietario a la vez. Hasta dos agentes de código en worktrees distintos con conjuntos de archivos disjuntos; Opus para arquitectura/revisión pesada, Sonnet implementación acotada, Gemini independiente si está disponible, Codex arte tras fijar estilo y compuerta; modelos locales solo Git rutinario.

**Verificación común:** importación si hay clases/recursos nuevos, reversión solo de assets generados no intencionales; `.uid` propio de cada test versionado. Tests focales y suite GUT sin errores de script; salida 139 de import se relanza e informa. Capturas PC 1280×720/1920×1080 y celular simulado, indicando límites; teléfono real T454/T238 queda a Lucas. Una comparación estructural antes/después de todos los JSON/nodos de mapa prueba igual camino, entradas, salidas, casillas construibles y recursos: si difiere, no se entrega como cosmético ni se rebalancea por inferencia. No se corre bot para sustituir las partidas T453.

### M75 / T458, T464–T468 · «Ver todo», panel de mejora, alcance y Opciones (RF-674 a RF-686, D-192 a D-197)

**Estado:** T458 fija la spec y este plan (solo documentos). Ningún código se escribe antes del OK de Lucas. Todo sale del informe `specs/tareas/informes/T451-camara-panel-opciones.md`, que da el estado de hoy con archivo y línea (leído sin correr Godot). No cambia balance, niveles, torres, enemigos ni `SAVE_VERSION`. Las tareas de código y sus archivos están en la ficha `specs/tareas/T458-ficha-camara-panel-opciones.md`. **Las líneas de T451 se verifican al empezar**: el código pudo moverse.

1. **«Ver todo»** (T464, RF-674 a RF-676). `CameraController`: se saca `_build_pc_view_all_button` y su ayuda; el botón flotante queda solo para celular y `_update_view_all` lo muestra únicamente con zoom (no con desplazamiento solo). En la PC solo queda `Game._unhandled_input` con la acción `view_all` (sin cambios). Ícono de lupa en `assets/ui/` (SVG propio, con el antecedente `mobile_demolish.svg`; aprobada por Lucas el 2026-10-26 e integrada como `mobile_view_all.svg`). Aviso: `CameraController` emite únicamente cuando aumenta el zoom; alejar o desplazar sin acercar no lo activa (D-207). `Game` consulta `UiPrefs.view_all_hint_seen` y usa los textos aprobados de RF-676 en la misma franja de avisos que «Tecla ya usada…» (T451 no pudo comprobar si es un componente reutilizable: si no lo es, un `Label` temporal en `ViewAllLayer`). El texto PC muestra la tecla configurada (V por omisión). Campo aditivo `view_all_hint_seen` en `scripts/logic/ui_prefs.gd` con lectura defensiva, y `SaveManager` lo guarda sin subir la versión. No sale con el tutorial (RF-574), un menú abierto ni sin cámara.
2. **Panel de torre** (T465, RF-677). `scenes/ui/tower_panel.gd`/`.tscn`: se saca `UpgradePreview`; las filas DAÑO, CADENCIA y ALCANCE aceptan «a → b» con el `UpgradeDeltas` que ya existe (`before_after`, `format_value`); las líneas de efectos (`TowerText.effects`) toman el «antes → después» de la misma tabla (`data/ui/mejoras.json`). **Una sola función de formato decimal con coma** en `scripts/logic/tower_text.gd` (hoy cadencia y alcance usan punto). `pulse_line` deja de repetir cadencia, radio y daño. La tarjeta de nivel (`_refresh_level_card`) pasa a tres metales: los colores salen de la paleta de bronce, plata y oro que ya usa la UI (T451 la ubica en `specs/05-guia-de-arte.md` y en las constantes del panel; **no se inventan colores**: si faltan, se muestran a Lucas con una captura). El cálculo de «antes → después» es el mismo del celular (`MobileHud._upgrade_preview_text`): se comparte en lógica pura (R9 de T451).
3. **Opción de alcance, fantasma y arco** (T466, RF-678, RF-679, RF-683, RF-685). `SaveManager.DEFAULT_SETTINGS["range_display"] = 0` con lectura defensiva (`_read_settings`); fila en `options_menu.gd`. `BuildController._draw_range` pasa a recibir el estilo; el fantasma lo llama siempre en el estilo completo y la torre seleccionada lo hace según la opción. Los números de dibujo (opacidades y grosores de Sutil y Completo) van a un archivo de `data/ui/` con valores iniciales de RF-678. `Tower._draw` (`tower.gd`, arco de apoyo): cambia `if support_only` por la opción; con Oculto no dibuja.
4. **Ampliación, dos toques y animación** (T467, RF-680 a RF-682). Un nodo de presentación `RangePreview` (un `Tween` y `_draw`, sin `_process`, como `UpgradeEffect`) en la capa de efectos: recibe centro, radio actual y radio nuevo, crece y se desvanece; respeta pausa y velocidad (M36). La PC lo dispara con `mouse_entered`/`mouse_exited` del botón «Mejorar» del panel (solo si está activo). El efecto de mejora (`EffectsLayer.tower_upgraded`) lo llama con el alcance nuevo. En `MobileHud`, un estado `_upgrade_armed` por torre elegida: el primer toque lo arma (muestra `RangePreview` y cambia el texto del botón), el segundo llama a `try_upgrade`; se desarma con cualquier otro evento de RF-681 punto 3. Se conserva el bloqueo de 0,35 s. `upgrade_fx` queda prendido por omisión; apagado, la ampliación se dibuja quieta (sin `Tween`) y el efecto de mejora no la dibuja. El paso `upgrade` de `data/tutorial/tutorial.json` se actualiza para explicar el primer toque de vista previa y el segundo de confirmación; no cambia los criterios humanos pendientes de T453.
5. **Opciones** (T468/T481, RF-684/RF-708). Se conservan las cinco categorías y filas de D-197; T481 las presenta con una fila de botones seleccionables antes de `ScrollContainer`, y una página `VBoxContainer` por categoría dentro del área desplazable. Una sola página queda visible. En PC hay cinco solapas; en celular cuatro, sin «Controles». El panel se dimensiona al espacio disponible; «Volver» y las solapas quedan fuera del scroll. Al confirmar el modo de pruebas, se ocultan solapas y páginas y se presenta la confirmación; al cancelar se restaura la página activa. Los nodos de cada fila y las claves guardadas mantienen su nombre/valor. No cambian preferencias ni SAVE_VERSION. **Coordinación con M66:** T461 renombra la fila de jefes («Presentación de los jefes», D-190); T468/T481 la ubican dentro de «Partida y ayudas».
6. **Pruebas.** Tests nuevos: `test_view_all_hint.gd` (una sola vez, no con el tutorial, guardado viejo, aviso solo ante un aumento efectivo del zoom (no al alejar ni con paneo solo)), `test_range_display.gd` (cada valor y qué dibuja el fantasma, la torre seleccionada y el arco), `test_range_preview.gd` (ampliación en PC y dos toques en el celular, cancelaciones, 0,35 s), `test_options_groups.gd` (orden por grupo y que «Controles» no existe en el celular). Tests que cambian: `test_upgrade_preview.gd` (`:133` y `:137`), `test_tower_panel_layout.gd`, `test_upgrade_fx.gd`, `test_view_all_displaced.gd`, `test_view_all_binding.gd`, `test_old_saves.gd`, `test_tutorial_options.gd` (`:52-53`), `test_boss_entrance_options.gd`, `test_defeat_advice_options.gd`, `test_menu_layout.gd`, `test_mobile_ui.gd`, `test_options_admin.gd`, `test_news_menu.gd`, `test_game_version.gd`. Un test de ancho mide el texto más largo del panel (Tesla de nivel 1) con la fuente del juego.
7. **Panel de torre en la PC: PC-A** (T513, RF-721, D-214; enmienda el punto 2). `scripts/logic/tower_text.gd` gana **una función de frase «antes → después»** por efecto (usa las plantillas de `TowerText.effects` y los números de los dos `TowerLevelData`; el «después» lleva el color de resalte; en el último nivel devuelve la frase simple); es el único lugar, para que PC y celular no se desalineen. `scenes/ui/tower_panel.gd`/`.tscn`: se saca el nodo `UpgradePreview` y el filtro que borraba el renglón del efecto; filas rótulo-valor (Daño, Cadencia, Alcance) a la misma letra; sin filas que no aplican (apoyo, sin Apuntar); «Voladores» como ícono con tooltip; la tarjeta de nivel horizontal con contorno del metal que falta; botones con el tema de los menús (`menu_theme.tres`: hierro, borde bronce de 2 px y 4 abajo, radio 6) en vez de los `StyleBoxFlat` verde, ladrillo y pizarra; ancho fijo de 270 px y alto según `get_combined_minimum_size()` con tope de 320 (sin `ScrollContainer` en los 12 casos). «Mejorar» sin oro muestra «faltan N» a la vista. Tests: se reescriben `tests/test_upgrade_preview.gd` (hoy `test_panel_shows_each_upgrade_value_once_…` **exige** borrar la frase del efecto: protege lo contrario de RF-677.1; los textos esperados pasan a la frase con la flecha adentro) y `tests/test_tower_panel_layout.gd` (alto según contenido, sin scroll, ancho 270, tope 320, Estandarte sin DAÑO ni Apuntar, ícono de voladores, botones de hierro y bronce); el test de ancho del texto más largo se conserva. Capturas de RF-686 (Cañón, Tesla, Hielo y Disruptora, niveles 1 a 3, a 1280 × 720 y 1920 × 1080). Atención a la tensión que T510 vio entre RF-74 («los clics del panel no llegan al mapa») y `test_panel_passes_map_clicks_through_passive_regions…`: precisarla al implementar.
8. **Barra del celular: CEL-B** *(hecho en T514)* (T514, RF-722, D-214; enmienda el punto 4 en lo que toca a la barra). `scenes/game/mobile_hud.gd` (`_refresh_tower_*`, hoy `mobile_hud.gd:250-297`): el texto pasa a dos renglones cortos (nombre con puntos de nivel y estado; estado actual abreviado) con `TowerText.decimal`; se retira el renglón «Al mejorar:»; «Mejorar» pasa a un botón de 320 × 84 de dos partes (título y costo / cambio que se compra, hasta 2 estadísticas, con la misma función de frase de T513, o `UpgradeDeltas` mientras T513 no esté); «Apuntar» se reduce a un ícono con el modo (112 px) y no se agrega si la torre no apunta; separación de seguridad entre «Mejorar» y «Vender» (hoy 35 mm ≈ 376 px lógicos, ver el límite de RF-722). Tests: posiciones de la barra (`tests/test_mobile_ui.gd` y los `test_mobile_*` que fijan el orden), ningún hijo fuera de 96 px ni de la pantalla, la separación mínima entre «Mejorar» y «Vender», los textos de «Mejorar» desarmado, armado y sin oro (RF-681) y la coma decimal. T514 puede ir en paralelo con T513 (comparten solo la función de frase de `TowerText`: coordinar). **T511** (PR #106) corrige antes el formato y el desborde de la barra actual.

**Orden y paralelismo.** T464 y T465 pueden ir en paralelo (comparten solo `mobile_hud.gd`: coordinar). T466 después de T465 no es necesario, pero **T467 depende de T465 y T466**. T468 va al final y después de T461. Las tareas que tocan `save_manager.gd` u `options_menu.gd` (T464, T466, T468) **no van más de dos a la vez**. `project.godot` no se toca.

**Riesgos.** (1) **Ancho del panel:** «0,75 → 0,85/s» puede no entrar en 270 px; T451 no lo midió. (2) **Sutil sobre fondos claros** (nieve, arena): no se probó. (3) **Dos toques en el celular** y el tutorial del nivel 1; ningún celular real probó nada. (4) **Estado armado olvidado:** si no se cancela en todos los eventos de RF-681, el botón queda en «Confirmar» y un toque accidental gasta oro; la ficha lista los eventos y un test los cubre. (5) **Reorden de Opciones:** los tests fijan posiciones relativas; si T461 cambia la forma de la fila de jefes antes, hay que rebasar. (6) **El arco del Estandarte** pasa a Oculto por omisión: un jugador nuevo no ve a quién apoya (aceptado por Lucas, D-196). (7) **Ícono de la lupa:** es arte nuevo y espera la aprobación de Lucas. (8) `--import` reescribe a veces los SVG: revisar `git status` antes del commit.

### M77 / T460 · Marco fijo, franjas y láminas de carga (RF-699–707, D-204–206)

**Diagnóstico confirmado por lectura:** `project.godot` declara `canvas_items` y 1280×720 sin aspecto explícito; `DesktopWindow` mantiene ventana 16:9 inicial, pero pantalla completa puede tener otra relación. Las franjas están fuera del viewport; `MapBackdrop` dentro de Game solo cubre márgenes internos. T450 midió transformaciones headless, no capturas; no usar ese informe para afirmar observación ni rendimiento móvil. Hay `DISPLAY=:0` para capturar ventana en las tareas futuras.

**T476 · Superficie de presentación, con revisión de arquitectura.** Propuesta recomendada para cumplir «no expandir el juego»: contenedor persistente de presentación física sin letterbox del sistema, con fondo a tamaño de ventana y un viewport lógico alojado dentro, centrado y escalado uniformemente. El tamaño del render target debe adaptarse o usar un mecanismo equivalente que mantenga nítidos HUD/texto a 1920×1080 y en móvil; no queda fijado en 1280×720. La superficie exterior completa la ventana; el contenido conserva la geometría lógica de HUD y `Rules.MAP_AREA`, sin sustituirlos por tamaño físico. Es una propuesta sometida al OK de T460 y a revisión pesada, no un cambio ya aprobado a project.godot.

- Si Lucas aprueba el mecanismo, implementar un modelo puro de geometría/transformaciones y la presentación; empezar con respaldo liso. La configuración física de la raíz se modifica solo para alojar esa superficie, **no** para activar `expand` del contenido. Documentar configuración exacta probada antes del PR; no llamar a este sistema `keep` raíz si ya no lo es: `keep` se reproduce en el contenido lógico.
- Si Lucas aprueba el host, definir quién lo posee y cómo deriva cambios de escena; el `swapper` que SceneTransition ya admite es un punto de partida, no una decisión. Preservar referencia estable de escena activa, señales y ruta para reintentar. Auditar `SceneTree.current_scene`/`reload_current_scene`, `get_tree().root` y `get_viewport()` en autoloads y escenas antes de elegir el punto de montaje. La escena inicial entra por el mismo host; no deben coexistir una copia raíz y otra dentro. F6/headless/tests reciben host opcional o camino de reserva explícito, sin obligar a abrir ventana.
- Si el host se aprueba, verificar que el mecanismo elegido transforme la entrada una sola vez; el adaptador filtra puntos de franjas y respeta capturas/arrastres iniciados dentro. Probar mouse, rueda, toque/pinza, emulación de mouse, foco/teclado y Atrás. No reenviar manualmente eventos ya reenviados por el contenedor. La cámara de Game sigue en coordenadas de su viewport lógico.
- Si el host se aprueba, revisar si hace falta generalizar la dependencia de bloqueo de SceneTransition con un destino/lista de Viewports inyectada, valor por omisión raíz para su uso standalone. Registrar y restaurar `disable_input` previo por destino y limpiar eventos en inicio/cierre/fallo/salida. El adaptador del juego pasa raíz y viewport lógico, sin nombres del juego en el núcleo. La capa de carga debe conservar su cobertura y legibilidad con el mecanismo elegido, con texto/barra coherentes; las capas de juego/HUD/tutorial/jefes permanecen en lógico.
- Conservar pausa y `PROCESS_MODE_ALWAYS`; comprobar que CanvasLayers y overlays queden en el destino correcto. No agrandar barras, mover hitboxes lógicas ni cambiar zoom por una regresión del host. Si la adaptación supera una sesión o necesita cambiar una mecánica, subdividir antes de entregar y someter el ajuste de scope; no resolver por inferencia con `expand` jugable.

**T477 → T478 · Fondo por terreno.** T477 prepara una muestra de «más allá del mapa» según temas comprobados en los 15 JSON, con guía vigente y fuente/procedencia. Codex muestra 16:10, 21:9, 4:3 y 20:9, mapa superpuesto, límites y recortes, sin finales antes del OK por terreno. T478 integra los aprobados en el fondo físico y en los pequeños márgenes internos sin depender de Camera2D. Game emite el tema después de resolver el nivel y PresentationHost lo aplica antes de montar el resto del contenido (P6). No generar fondo por nivel si comparten terreno, ni introducir otro terreno para menús: respaldo liso exterior. Ajuste equivalente a `KEEP_ASPECT_COVERED`, focal point si lo aprueba la muestra. Un catálogo visual validado en `data/ui/` asocia temas a rutas/encuadres, con respaldo liso si falta/recurso inválido. Conservar arte existente y el zoom máximo absoluto 1,0 en PC y celular; no tocar grilla/economía.

**T479 · Fondos rotativos de carga, bloqueada hasta T454 + OK.** Primero se mide en celular real con una build de main identificada y las imágenes actuales de intro: frío/repetido, primer cuadro, carga/decodificación y memoria observable; se informa qué no se pudo medir. Las cifras/estimaciones de T450 no fijan el presupuesto. Lucas aprueba o pide alternativa con esos datos. No se implementa esta parte mientras falte la medición.

Solo tras la compuerta, si T479 queda aprobada, GameFlow lee solo rutas válidas del catálogo oficial de intro, mantiene una bolsa/última en memoria (sin guardado), y elige cuando el pedido de transición es aceptado. Un modelo puro prueba exclusión consecutiva, barajado, 0/1/N entradas y pedidos busy sin consumir elección. Solicitar una textura de forma asíncrona, nunca el conjunto; asignar identificador de transición para descartar completadas tarde. SceneTransition recibe textura/proveedor genérico sin conocer rutas. Color/barra se muestran al primer cuadro, imagen solo si llega durante la transición; la escena no espera por ella y su fundido no cambia `min_seconds=0.4` ni gracia. Velo/recorte revisados por Lucas para legibilidad; ausencia/fallo vuelve a liso. Liberar referencia de textura al cerrar (sin afirmar que el caché interno de Godot libera toda memoria inmediatamente). No agregar precarga permanente ni cambiar compresión/resolución para maquillar costo sin nueva decisión.

**Conflictos:** T476 edita GameFlow/SceneTransition/project.godot; T478 podría editar Game/cámara y comparte cámara con T464, jefes T461 y postes T475; T479 edita GameFlow/SceneTransition. Van en serie cuando compartan archivos, desde origin/main actualizado. T268 también toca project.godot para versión. T477 puede preparar muestra con arte separado, respetando compuerta y como máximo dos agentes de código; una tarea 📜 a la vez.

**Pruebas:** importación y suite sin errores de script, ids `.uid` propios, devolver assets accidentales. Flujo completo menú→selector→partida→pausa→niveles, reintentar, editor/probar/regreso, modo de pruebas, comunidad, jefes y fallo de transición. Comparar 16:9 antes/después: mismo layout lógico/input; capturar además 16:10/21:9/4:3/20:9, mínimos y máximos de cámara, resize/fullscreen. Las capturas físicas con ventana van fuera del repo salvo las del PR; no confundirlas con simulación de teléfono. Si import retorna 139, relanzar e informar. Medición PC solo con resolución/hardware/uptime/build; teléfono real y G5 siguen con Lucas.

### M78 / T486–T488 · Atlas con descubrimiento por zonas (RF-709 a RF-711, D-209)

**Estado actualizado (2026-10-26, T517):** T486 se aprobó al mergear el PR #80; T487/T488 y la máscara G2 están integradas en `main` (PR #85, #92 y #102). El orden que sigue es el plan original de implementación; no queda trabajo de M78 pendiente. La regla es derivada: no toca `SaveManager`, `SAVE_VERSION` ni los JSON de nivel.

1. **T487, modelo puro y tests.** En `scripts/logic/campaign_map.gd` (sin escenas, P10) una función estática que, dado el arreglo `unlocked` de los 15 niveles, devuelve la zona descubierta de cada región (`ZONE_A/B/C`) y los índices cuyo foco está permitido. Reglas: A siempre; B si alguna región de 6–15 está desbloqueada; C si alguna de 11–15 lo está; `unlocked` no booleano = bloqueado. Los límites 6 y 11 van como constantes del modelo, no repartidos por la vista. Tests en `tests/test_campaign_map.gd` (o un archivo nuevo si la ficha de T471 lo está editando): guardado nuevo, nivel 6 abierto, nivel 11 abierto, guardado raro (11 abierto y 6 cerrado), datos dañados, modo de pruebas y que ninguna función modifica `unlocked`. Se hace sobre `origin/main` y **espera a T471 solo si ambas editan el mismo archivo** (propietario único).
2. **T488, vista.** `scenes/ui/campaign_map_view.gd` y `campaign_region.gd`: las regiones de zonas sin descubrir no son focalizables ni seleccionables y no dibujan número, candado ni estrellas; el fondo oculta esas zonas con la máscara gris aprobada. Depende de T471 (geografía y fondo integrados) y de T487. Las máscaras son del arte aprobado por Lucas (T485/T469), sin inventar otras. El recorrido con flechas salta las regiones ocultas (RF-688). Capturas de los tres estados en PC y celular simulado.
3. **Serialización (plan original).** T471, T473, T474, T487 y T488 compartían el selector/mapa: se planificó hacerlas una a la vez. **Estado 2026-10-26 (T517):** T471, T473, T487 y T488 están en `main`; T474 sigue abierta parcialmente, y T469/T475 conservan sus compuertas. T487 ya no necesita esperar a T471.
4. **Riesgos.** (1) El gris de lo oculto sobre el relieve nuevo puede verse como «bloqueado» y confundirse con el candado: lo juzga Lucas en la muestra. (2) Foco por teclado que empieza en una región oculta: se prueba. (3) El modo de pruebas cambia de archivo de guardado en la misma sesión: la zona se recalcula al reabrir el mapa.

### M79 / T490–T498 · Mejora de assets de los niveles altos (RF-712 a RF-714, D-210)

**Estado al redactar (2026-10-25):** T490 fijaba la spec y el plan, a la espera de revisión de Lucas. **Actualización T517 (2026-10-26):** el PR #89 de T490 está mergeado; los PR #96/T493 y #97/T494 entregaron las muestras, y T497/T498 integraron las variantes elegidas en `main`. T495 quedó cerrada en T522 con las ocho preguntas resueltas por elecciones, resultados de integración o decisiones de alcance fechadas. Todo cumple la estética actual (atlas M76/T471, postes T437/T475, decoración renderizada T277, UI de `main`).

1. **T491, inventario.** Haiku, solo lectura: tabla en `art/m79-inventario/inventario.md` con, por nivel 8 a 15, tema, dibujos de decoración y señales (`MapThemes.BLOCKED`, leyendas de `MapDrawings`), cuántas casillas `X` o señales hay, el archivo, si es plano (SVG M4/M5) o dimensional (PNG T277) y capturas del motor real a 1280×720 del «antes». No modifica `assets/`, `scripts/` ni `data/`.
2. **T492 a T494, muestras.** Sonnet, tres carpetas separadas que no se pisan: `art/m79-muestras/piedra-a/` (RF-713 a), `art/m79-muestras/nieve/` (b) y `art/m79-muestras/cabezas/` (c, mínimo cuatro más la línea de base). Cada una: PNG RGBA de 128×128 por variante, hoja de contacto a 220 px y 34 px sobre el suelo del tema, y una captura sobre el mapa real con el arte **puesto fuera del juego** (composición en la herramienta de captura, sin tocar `assets/sprites/map/`). La técnica y la luz son las de T277. Las tres pueden ir en paralelo (carpetas distintas).
3. **T495, 🎨 aprobación.** Lucas elige una variante por caso, contesta las ocho preguntas de M79 y queda registrado en la entrada de T495 y en D-210. Sin esto, T496 a T498 no empiezan.
4. **T496 a T498, integración.** Sonnet, una a la vez (comparten `map_drawings.gd`, `map_themes.gd` y `tests/test_map_themes.gd`): T496 la piedra con la A (`MapDrawings`), T497 la nieve (`MapThemes`) y T498 las cabezas (`MapThemes`). Cada una copia el PNG aprobado a `assets/sprites/map/rendered/`, cambia el `preload`, actualiza los tests que listan el dibujo y la guía de arte §4, y no toca `data/`. Capturas a 1280×720 y celular simulado, con y sin poste (T475) donde corresponda; GUT completo sin `SCRIPT ERROR`; `--import` puede reescribir SVG de `assets/`, así que se revisa `git status`.
5. **Riesgos.** (1) El arte renderizado pesa más: no se afirma rendimiento. (2) La A debe seguir leyéndose a 34 px. (3) Una cabeza «alienígena» puede leerse como enemigo (pregunta 6). (4) Los tests de `test_map_themes.gd` exigen que los archivos sean cuadrados y existan.

**Actualización del 2026-10-26.** Lucas descartó las muestras de la piedra (PR #95): T492 queda descartada y T496 reemplazada por M80 (T504 a T509). T497 queda habilitada con pino 01, abeto 01 y roca nevada 01 (PR #96) y T498 con la cabeza 01, dos pares de cuernos (PR #97). **Estado T524 (2026-10-27):** los PR #96 y #97 y T497/T498 están en `main`; T495 quedó cerrada con las ocho preguntas registradas. T523/T525/T526 produjeron y mostraron las seis muestras; Lucas eligió cactus 02 y campamento vacío 02 el 2026-10-27, y los otros cuatro motivos ya estaban aprobados. T524 integró los seis en sus usos existentes sin alterar mapas ni datos.

### M80 / T503–T509 · Rocas genéricas y marcas sobre el sistema de postes (RF-716 a RF-719, D-212)

**Estado actualizado (2026-10-26, T509):** T503 (#100), las muestras (#115), T507 (#126) y T508 (#127) están mergeados. T508 cambió `rubble_idle.png` a H G2, integró las señales y retiró los SVG reemplazados. Lucas aprobó el canon A→H y G2 en T506; T509 actualiza ahora el canon después de la integración. Para las señales nevadas del nivel 13 eligió roca oscura; la roca nevada decorativa se conserva. **M80 reemplaza el punto de la piedra de M79 (T492 y T496).**

1. **Cómo funcionan hoy los postes (lo que se reutiliza).** `data/ui/postes_campana.json` guarda las casillas por nivel (dato visual, sin balance); `CampaignPosts` (`scripts/logic/campaign_posts.gd`) las lee tolerando archivo ausente o dañado; `Game` calcula el contexto y lo baja por `LevelData.build_map` → `Level.build` → `LevelDecor.paint(..., post_cells)`; `LevelDecor._draw` dibuja la capa al final y `overlay_post_cells()` devuelve las casillas donde de verdad hay poste, para que el suelo se dibuje **sin** el ítem de atrás. Un test recorre los 15 niveles y compara con el JSON. Informe: `specs/tareas/informes/T475-integracion-postes.md`.
2. **T504, muestras de rocas.** Codex (`gpt-6.1-sol`, esfuerzo medio). Carpeta `art/m80-rocas/` con `sources/`, `prompts.md`, `manifest.json`, 2 o 3 modelos en tres colores (PNG RGBA 128×128, luz arriba a la izquierda, sombra de apoyo mínima), hoja a 220 y 34 px sobre los cinco suelos y una captura (arte compuesto en la herramienta de captura; no se toca `assets/`). Sin símbolo en la roca.
3. **T505, muestras del glifo y de las marcas.** Codex (`gpt-6.1-sol`, esfuerzo medio). Carpeta `art/m80-marcas/` con la misma estructura. Tres variantes del glifo (una H rara, de estilo gótico, reconocible a 34 px, que no sea la letra de una tipografía ni una lápida) y los tipos de marca: **grabada** (decal sobre la roca de T504), **estela** (piedra baja exenta) y **pintada** (sobre muro o suelo). El glifo se prueba sobre las rocas de T504, no solo ampliado.
4. **T506, 🎨 aprobación (completada 2026-10-26).** Lucas eligió modelos, colores, glifo y tipos, respondió las seis preguntas y confirmó por escrito el cambio de canon. T507/T508 habilitadas; T509 espera que T508 integre.
5. **T507, sistema de marcas.** Sonnet. Archivo `data/ui/marcas_campana.json` (`version`, `niveles: { level_NN: [ {celda: [x, y], tipo: "..."} ] }`; nombres propuestos), clase `CampaignMarks` (o equivalente) en `scripts/logic/` con la misma tolerancia que `CampaignPosts`, el contexto pasado hacia abajo por la misma cadena, y una capa en `LevelDecor` junto a `_draw_campaign_posts`. Un método `overlay_mark_cells()` análogo al de los postes oculta el ítem de atrás. **Validación de datos (test sobre los 15 niveles):** cada marca cae en una casilla `X`, dentro del mapa, y no en camino, entrada, salida, construible, removible, extracción, marca de pieza, casilla con dibujo de leyenda, poste de `postes_campana.json` ni otra marca. Las marcas son estáticas y no leen el guardado. El archivo se crea vacío o con las marcas que Lucas apruebe: **no se agrega ninguna marca sin su OK**.
6. **T508, rocas por niveles.** Sonnet. Los PNG aprobados van a `assets/sprites/map/rendered/`; `MapDrawings` resuelve `roca_marcada` y `simbolo_ruina` (ids sin cambio) a la roca del color del tema más la marca «grabada». El modelo de cada casilla sale de un hash estable de la casilla (como el reparto de `MapThemes.blocked_decor`), sin consumir el azar del juego. Se actualizan `tests/test_map_drawings.gd`, `tests/test_map_themes.gd` y la tabla de la guía de arte §4. Los SVG viejos `roca_marcada.svg`, `simbolo_ruina.svg` y `escombro.svg` se retiran al integrar sus reemplazos por aprobación de Lucas; preservar su historial Git.
7. **T509, canon.** Sonnet, solo documentos, tras T508 integrada y con el OK escrito ya recibido: se editan las menciones marcadas «cambiar» en D-212 (`10-universo.md` primero), se repite la búsqueda y se aprovecha la entrada de CHANGELOG incorporada con T508, sin duplicarla. `11-textos-lore.md` y `data/` no nombran la letra y no se tocan.
8. **Riesgos.** (1) La H puede leerse como letra de fuente, como la A de PR #95. (2) El arte renderizado pesa más que el SVG: no se afirma rendimiento. (3) Las marcas ocultan el ítem de atrás de una `X`, cambiando la densidad visual del tema. (4) Una mención del símbolo A pudo quedar fuera de la búsqueda. (5) Los niveles 8 y 9 siguen con el poste frenado en `(0, 4)`. (6) T507 y T508 comparten archivos: una a la vez. Los PR #96 y #97 ya están mergeados y T497/T498 completadas (estado T517, 2026-10-26).

### M81 / T519 · Selector de niveles, Mesa de mando (RF-723, D-215)

T519 registra la elección de Lucas del 2026-10-26 y limita el rediseño al marco global de `level_select.tscn` y sus textos de navegación. T520 reorganiza nodos existentes para una composición de mesa de mando en el viewport apaisado 1280×720: navegación lateral en espacio amplio y fila horizontal desplazable cuando el ancho no permita el rail, área de contenido flexible, progreso y acciones agrupadas. Usar la paleta de `menu_theme.tres` y los fondos actuales, sin producir arte. En mobile mantener `MenuTouch.attach`, mínimos táctiles y `TouchScroller` en cada lista; no tomar la maqueta vertical de T518 como orientación real.

Preservar `CampaignMapView` y las tarjetas como contenido: no cambiar dibujo, datos, hitboxes ni lógica de selección/inicio. Mantener orden y páginas dinámicas de RF-694, navegación por teclado, scroll hacia la solapa activa, DevMode, carpeta de comunidad, selector Mapa/Tarjetas y progreso. Etiquetar la pestaña como «Comunidad» sin cantidad en el botón; la cantidad total sigue en el indicador existente. Actualizar pruebas de UI y textos, añadir cobertura de bounds y solapas con más modos que el ancho visible. Capturas del motor a 1280×720 para PC y celular simulado, con campaña mapa/tarjetas, Comunidad y al menos una página de modo. Ver `specs/tareas/T520-implementar-selector-mesa-de-mando.md`.

### M82 / T530–T534 · Presentación, coherencia del selector e idioma inglés (RF-724 a RF-727, D-217)

T530 fija la regla antes del código. T531 usa la misma fuente de desbloqueo que el mapa para omitir tarjetas bloqueadas y reduce RF-460 al título, botones y una advertencia opcional; prueba que el diálogo siga pausando/restaurando y que salir descarte la partida. T532 ajusta brillo/saturación del fondo de las franjas actuales sin cambiar viewport, cámara ni área jugable; compara nieve y otros temas a relaciones anchas. **Implementación T532:** `PresentationHost` aplica un `ShaderMaterial` (`assets/shaders/strip_tone.gdshader`) solo a `BackgroundTexture`; los valores salen de `data/ui/presentation_backgrounds.json` (`franjas`). `ContentFrame`/viewport, cámara, input y el fondo interno de `Game` no se tocan. T533 audita el texto mostrado por todas las escenas y datos (incluidos errores, tooltips, textos dinámicos, Wiki, tutorial y resultados) y prepara el catálogo, sin exponer un modo inglés incompleto. Lucas revisa el inventario antes de T534. T534 incorpora todas las traducciones inglesas y recién ahí habilita el selector persistente Español/Inglés, con español por omisión. Se validan placeholders, pluralización, persistencia, PC y celular simulado; GUT completo y `--import` sin errores en los cambios de código. No usar reinicio de guardados de progreso ni añadir `SAVE_VERSION`; probar persistencia en la preferencia de opciones. No afirmar prueba real en celular.

**Estado T533 (2026-10-28):** `Localization` (`scripts/logic/localization.gd`) y `LocalizationCatalog` (`scripts/logic/localization_catalog.gd`) ya existen, con catálogos `data/i18n/es.json` y `data/i18n/en.json` (lista de `{clave, texto}`, marcadores `{nombre}`, plurales `.one`/`.other`). `LocalizationCatalog.validate(base, otro, require_complete)` informa claves ausentes (solo si `require_complete`; T534 lo pone en `true`), duplicadas, mal formadas, huérfanas, placeholders distintos y textos vacíos. El idioma es `settings.language` (`es` por omisión) vía `SaveManager.language()`, sin tocar `SAVE_VERSION`. `Localization.SELECTOR_ENABLED = false` mantiene oculto el selector. Inventario: `specs/tareas/informes/T533-inventario-textos.md` (regenerable con `python3 tools/localization_inventory.py`).

**Estado T534 (2026-10-28, D-222):** migración por tandas. `Localization.apply(root, {nodo: clave})` pone los textos fijos de las escenas `.tscn`; el código usa `Localization.t/t_fmt`. Cada escena que cambia de idioma en vivo escucha `SaveManager.setting_changed` (`language`) y vuelve a poner sus textos. `SaveManager` aplica el idioma guardado al cargar (`load_save`) y `DevMode.set_enabled` lo conserva al cambiar de guardado. Migrado: menú principal, Herramientas, Opciones (con el selector oculto), pausa, salida, Récords, Salón de la fama, versión y nombres de acciones de teclas. `tests/test_localization_en.gd` escanea el código buscando claves `&"dominio.clave"` y exige que existan en `es.json` y `en.json`, y que el inglés no contenga marcas de español. `tools/capture_menus.gd` acepta un cuarto argumento `es|en` para comparar (y ahora también captura el resultado y el HUD). **Segunda tanda (2026-10-29):** `Localization.data_text(dominio, id, campo, español)` devuelve el texto del archivo de `data/` en español y, en otro idioma, la clave `<dominio>.<id>.<campo>` del catálogo; `TowerData`/`EnemyData` exponen `name_text()` y `description_text()` (todo el juego los usa en lugar de `display_name`/`description`); lo mismo para etiquetas de mejoras (`UpgradeDeltas.stat_label`), consejos de derrota (`advice.<regla>.text`), tutorial (`TutorialData.steps_for`/`ui_text`), novedades (`NewsData.localized_entry`/`localized_labels`), artículos de la Guía (`Wiki._translate_blocks`), modos oficiales y removibles. Los textos armados con piezas sueltas pasaron a frases con marcadores (`towertext.*`, `hud.*`, `select.*`, `wiki.*`…) y los plurales a `.one`/`.other`. **Tercera tanda (2026-10-29):** el editor de mapas (`scenes/editor/*.gd`) y el de banderines leen el catálogo (`editor.*`, `banner.*`; los nombres de paletas y emblemas por `Localization.data_text`); las listas de herramientas, clases y datos del editor pasaron de textos a claves (`TOOL_NAME_KEYS`, `TOOL_TIP_KEYS`, `CLASS_NAME_KEYS`, `FIELD_LABEL_KEYS`); los mensajes de `LevelFile`, `MapGrid`, `LevelDraft`, `ModePacks`, `CommunityMaps`, `LevelTexts` y `ObstacleCatalog` usan `Localization.t_fmt`/`t_plural` con claves `lvlfile.*`, `grid.*`, `draft.*`, `modepack.*`, `communitymap.*`, `leveltexts.*`, `obstaclecat.*`; el panel y el cartel del modo de pruebas usan `dev.*`. Los mensajes de validación de los datos de desarrollo siguen en español (D-222, tercera tanda). `tools/localization_inventory.py --auditoria` produce la lista de lo que queda fuera del catálogo. **Pendiente:** el Lore y la habilitación del selector (decide Lucas).


### M86 / T546 · El final con dos variantes de imagen (RF-729, D-219)

**Implementado (2026-10-28).** Enmienda de Lucas: la luminosa es la imagen vigente `epilogue.png` (sin cambios; T547 **no** debe retirarla) y la oscura es `epilogue_dark.png` (muestra «Oscura 01»). Quedó así: `GameFlow.is_campaign_perfect()` junto a `is_campaign_complete()`; `Game.open_epilogue()` llama `epilogue.open(texto, GameFlow.is_campaign_perfect())`; `EpilogueScreen` carga la textura al abrirse con `ResourceLoader.exists` y, si falta el archivo, deja un fondo liso (`ColorRect`) y avisa por consola. Las rutas son `EpilogueScreen.BRIGHT_PATH` y `DARK_PATH` (constantes de interfaz, no de balance). Captura: `tools/capture_epilogue.tscn`. El plan original, abajo, quedó con estas diferencias (nombres de archivo y arte nuevo).

Plan original:

- **Condición:** `GameFlow.is_campaign_perfect() -> bool` junto a `is_campaign_complete()`: `false` si `level_count() == 0`; si no, exige `level_stars(i) == StarsDisplay.MAX_STARS` en todos los niveles. No agrega campos al guardado, no sube `SAVE_VERSION` y no escribe al verse el epílogo. Se evalúa al abrir (`Game.open_epilogue()`), después de `record_victory` del 15.
- **Pantalla:** `EpilogueScreen.open(text)` recibe además la variante (por ejemplo `open(text, perfect: bool)`) y elige entre dos constantes `preload` (`epilogue_bright.png` y `epilogue_dark.png`, nombres a confirmar con las muestras). La pantalla solo muestra (constitución P6): la decisión la toma `Game`/`GameFlow`. El fondo provisional de código de RF-471 queda como respaldo si falta un archivo.
- **Dependencias:** (1) **T545** (revisión de textos e imágenes de lore) cierra la frase del epílogo y sus líneas antes de programar. (2) **T547** retira `assets/sprites/story/epilogue.png`, que hoy precarga `epilogue_screen.gd`: T546 y T547 tocan la misma constante y el mismo archivo, así que se coordinan en orden (T546 carga las dos nuevas y deja de precargar la vieja; T547 borra el archivo y `art/t233-final/` sin dejar referencias rotas), o van en un mismo PR si Lucas lo prefiere. (3) **Arte:** las muestras de las dos imágenes se producen **fuera de `assets/`** (en `art/`) y entran solo con **OK escrito de Lucas**; respetan la familia visual vigente de `05-guia-de-arte.md` y su «Compuerta de estilo antes de producir muestras» (tres recursos activos de la familia, captura reciente, técnica, perspectiva, iluminación y paleta registradas, revisión a escala real y montaje rotulado). La imagen de T233 sirve solo de idea de composición.
- **Pruebas esperadas (GUT):** `is_campaign_perfect` con guardado nuevo, 14 de 15 niveles con 3 estrellas, los 15 con 3 estrellas, los 15 completados pero uno con 2 estrellas, un nivel sin ganar y campaña vacía; el nivel 15 como último que falta (cuenta); mejorar la marca no la baja; `EpilogueScreen` elige la textura correcta en cada caso y no falla si falta un archivo (usa el respaldo); el modo de pruebas, la comunidad, los modos y el editor siguen sin botón «Epílogo»; el guardado y `SAVE_VERSION` son idénticos antes y después de ver el epílogo. Captura del motor de ambas variantes con la franja de texto encima.
- **Fuera de alcance:** campos nuevos de guardado, acceso nuevo al epílogo, imagen intermedia (pregunta Q2), cambios de créditos, de texto o de balance.


### M87 / T550 · Qué entra en el paquete exportado (RF-730, D-220)

`export_presets.cfg`: los tres presets (Windows Desktop, Android, Linux) usan `exclude_filter="tests/*, tools/*, specs/*, addons/gut/*, art/*, Capturas/*"`. `Capturas/.gdignore` (archivo vacío) evita la importación de las capturas. Cómo medir el paquete sin plantillas de Windows: `godot --headless --path . --export-pack "Linux" <ruta>.pck` y leer la tabla del `.pck` (formato 4: cabecera de 32 B, desplazamiento del directorio, 64 B reservados, y por archivo largo de ruta, ruta, desplazamiento, tamaño, md5 y banderas). Los archivos importados se llaman `<archivo>-<md5 de res://ruta>.ctex`, así se atribuye cada uno a su carpeta. Si se agrega un preset nuevo, repetir el filtro; si se agrega otra carpeta de documentación o arte fuente, sumarla acá y en los presets.
