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
│   │   ├── level_decor.gd                    ← decoración dibujada por código (M1.5)
│   │   └── level_01.tscn, level_02.tscn, ...
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
│   │   └── rules.gd              ← fórmulas puras (daño, venta, bono…) → se testean
│   └── autoload/                 ← (M3) globales
│       ├── save_manager.gd, game_flow.gd, audio.gd
│
├── data/                         ← LOS NÚMEROS DEL JUEGO (archivos .tres)
│   ├── balance.tres              ← reglas generales (bono de oleada, % de venta…)
│   ├── towers/   basic.tres, cannon.tres, frost.tres, sniper.tres
│   ├── enemies/  normal.tres, fast.tres, tank.tres, flyer.tres, armored.tres, boss.tres
│   └── levels/   level_01.tres, level_02.tres, level_03.tres
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
| `LevelData` | [`level_data.gd`](../scripts/data/level_data.gd) | Un nivel: escena del mapa, oro y vidas iniciales, lista de oleadas. |
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
├── Level (instancia del mapa)       level.gd      ← se carga desde LevelData.map_scene
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

---

## 7. Globales (autoloads) — solo desde M3

En M1 y M2 **no hay autoloads**: todo el estado vive dentro de la escena de la partida, así "Reintentar" es simplemente recargar la escena y todo empieza limpio.

En M3 se agregan tres, porque hay datos que deben **sobrevivir** al cambiar de escena:

| Autoload | Para qué |
|---|---|
| `GameFlow` ([código](../scripts/autoload/game_flow.gd)) | Recordar qué nivel se juega (`current_index`, -1 = fuera de la campaña) y cambiar de pantalla. Registrar victorias y desbloquear el siguiente nivel. Aplicar pantalla completa al arrancar. |
| `SaveManager` ([código](../scripts/autoload/save_manager.gd)) | Leer y escribir el progreso y las opciones (§7.1). Los tests cambian `save_path` para no tocar el guardado real. |
| `DevMode` ([código](../scripts/autoload/dev_mode.gd)) *(M6)* | Modo de pruebas (spec §10.2, D-028): se activa con la característica de exportación `pruebas` (`JuegoA_pruebas.exe`) o, en el editor, con `--pruebas`. Cambia a `save_pruebas.json`, abre todos los niveles, muestra el cartel y hace que `Game` agregue el panel de pruebas. Va después de `SaveManager` y antes de `GameFlow` y `Audio`, así las opciones ya salen del guardado de pruebas. |
| `Audio` ([código](../scripts/autoload/audio.gd)) | Efectos y música. Carga todo `assets/audio/*.wav` y los reproduce por nombre (`Audio.play(&"build")`). 12 "voces" reutilizables y un intervalo mínimo por sonido. Buses `Master`, `Music`, `SFX` (`default_bus_layout.tres`). Los sonidos se generan con `tools/make_sounds.gd` (D-020). |

> ⚠️ **Los scripts de herramientas (`tools/*.gd`, que se ejecutan con `-s`) se compilan antes de que existan los autoloads.** Por eso no pueden usar `GameFlow`, `SaveManager` ni `Audio` por su nombre, ni declarar variables de tipo `Game` (porque `game.gd` sí los usa): declaran la partida como `Node2D`.

### 7.1 Formato del guardado

Archivo `user://save.json` (Godot lo guarda en la carpeta de datos del usuario, en Windows: `%APPDATA%\Godot\app_userdata\<nombre del proyecto>\`).

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

---

## 9. Riesgos conocidos y cómo se evitan

| Riesgo | Qué pasaría | Cómo se evita |
|---|---|---|
| Camino de casillas ≠ `Path2D` | Enemigos caminando fuera del camino. | Test `test_level_paths.gd` (§6.1). |
| Un proyectil o torre usa un enemigo que ya murió | Error "*previously freed instance*". | Comprobar siempre `is_instance_valid(target)` antes de usarlo. |
| Quedarse en x2 o en pausa al salir | Menús acelerados o congelados. | Restaurar `time_scale` y `paused` al salir (§6.7). |
| Números de balance esparcidos por el código | Balancear se vuelve una pesadilla. | Constitución P2 + revisar en cada tarea que no haya números "mágicos". |
| Muchos enemigos → lentitud | Menos de 60 FPS. | Medir con la prueba de rendimiento (§8) **antes** de optimizar nada. |
