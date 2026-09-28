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
| **Nombres de capas 2D físicas** | 1 = `world`, 2 = `enemies_ground`, 3 = `enemies_air` | Ver §6.3. |
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
│   │   └── level_01.tscn, level_02.tscn, ...
│   ├── towers/
│   │   ├── tower.tscn / tower.gd             ← UNA escena para TODAS las torres
│   │   ├── projectile.tscn / projectile.gd
│   │   └── tower_panel.tscn / tower_panel.gd ← (M2) panel mejorar/vender
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
| `TowerLevelData` | [`tower_level_data.gd`](../scripts/data/tower_level_data.gd) | Los valores de **un nivel** de una torre: costo, daño, cadencia, alcance, área, ralentización. |
| `TowerData` | [`tower_data.gd`](../scripts/data/tower_data.gd) | Un tipo de torre: nombre, si golpea voladores, color y su lista de niveles (índice 0 = nivel 1). |
| `EnemyData` | [`enemy_data.gd`](../scripts/data/enemy_data.gd) | Un tipo de enemigo: vida, velocidad, armadura, oro, vidas que quita, si vuela, resistencia a ralentizar, forma y color. |
| `SpawnGroup` | [`spawn_group.gd`](../scripts/data/spawn_group.gd) | "N enemigos de tipo X, cada S segundos, empezando T segundos después, por la entrada E" (RF-31). |
| `WaveData` | [`wave_data.gd`](../scripts/data/wave_data.gd) | Una oleada = lista de `SpawnGroup`. |
| `LevelData` | [`level_data.gd`](../scripts/data/level_data.gd) | Un nivel: escena del mapa, oro y vidas iniciales, lista de oleadas. |
| `BalanceConfig` | [`balance_config.gd`](../scripts/data/balance_config.gd) | Reglas generales: bono de oleada, % de venta, cuenta atrás, % de vida por oleada. Sus valores están en `data/balance.tres`. |

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
│   └── ...
├── Towers (Node2D)                                ← contenedor de torres
├── Enemies (Node2D)                               ← contenedor de enemigos
├── Projectiles (Node2D)                           ← contenedor de proyectiles
├── BuildController (Node2D)         build_controller.gd
├── WaveSpawner (Node)               wave_spawner.gd
├── Session (Node)                   level_session.gd
└── HUD (CanvasLayer)                hud.gd
```

**Por qué contenedores separados:** para poder recorrer "todos los enemigos" o "todas las torres" fácilmente, y para controlar qué se dibuja encima de qué (los proyectiles por encima de los enemigos, etc.).

### 5.2 Quién hace qué

| Nodo | Responsabilidad | NO hace |
|---|---|---|
| **Game** | Carga el nivel. Crea torres y enemigos en sus contenedores. **Conecta las señales** entre todos. | No calcula daño ni lleva la cuenta del oro. |
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

### 6.2 Enemigos

- **Nodo raíz:** `Area2D` (para que las torres lo detecten), con un `CollisionShape2D` circular.
- **Se dibuja con código** en `_draw()` según `data.shape` y `data.color` (círculo, triángulo…). No hace falta ninguna imagen.
- **Cómo avanza:** el enemigo guarda cuántos píxeles lleva recorridos (`distance`) y le pregunta a la curva del `Path2D` dónde está ese punto:

  ```gdscript
  func _physics_process(delta: float) -> void:
      distance += _current_speed_px() * delta
      global_position = path.to_global(path.curve.sample_baked(distance))
      if distance >= path.curve.get_baked_length():
          reached_exit.emit(self)
          queue_free()

  func remaining_distance() -> float:     # usado para apuntar al "Primero"
      return path.curve.get_baked_length() - distance
  ```

  **Por qué así y no con `PathFollow2D`:** `PathFollow2D` obliga a crear un nodo extra por cada enemigo y a meter al enemigo *dentro* del camino. Guardar la distancia a mano es igual de simple, funciona igual para voladores y deja a todos los enemigos juntos en el contenedor `Enemies`.
- **Grupo:** cada enemigo se agrega al grupo `"enemies"` (sirve para el daño de área).
- **Señales:** `died(enemy)`, `reached_exit(enemy)`.

### 6.3 Torres: detectar y apuntar

- **Una sola escena `tower.tscn`** para todas las torres. Al crearla se le asigna su `TowerData`, y con eso sabe su color, daño, alcance, etc.
- **Detectar:** la torre tiene un hijo `RangeArea` (`Area2D` con un círculo del radio del alcance). Usa **capas de colisión** para decidir a quién "ve":

  | Capa | Quién está en ella |
  |---|---|
  | 2 — `enemies_ground` | enemigos terrestres |
  | 3 — `enemies_air` | enemigos voladores |

  El `RangeArea` de la torre **mira** (*mask*) la capa 2 y, si `can_hit_air`, también la 3. Así el Cañón literalmente **no ve** a los voladores (RF-53) sin escribir ni un `if`.
- **Elegir objetivo:** en cada disparo se revisan `range_area.get_overlapping_areas()` y se elige según el modo (RF-51, RF-54):
  - *Primero* → menor `remaining_distance()`;
  - *Último* → mayor `remaining_distance()`;
  - *Más fuerte* → mayor `health`;
  - *Más cercano* → menor distancia a la torre.
- **Cadencia:** un contador `cooldown` que baja con `delta`; cuando llega a 0 y hay objetivo, dispara y se reinicia a `1.0 / fire_rate`. (Con `delta`, la pausa y la velocidad x2 funcionan solas.)
- **Disparar:** la torre crea el proyectil y **emite** `fired(projectile)`; `Game` lo agrega al contenedor `Projectiles`.

### 6.4 Proyectiles

- Se mueven hacia `target.global_position` a `projectile_speed`. Si el objetivo ya no existe (`not is_instance_valid(target)`), siguen hacia la última posición conocida (RF-52).
- **Al llegar** (a menos de ~8 px):
  - **Sin área:** `target.take_damage(damage)` (si sigue vivo) y se aplica ralentización si tiene.
  - **Con área:** se recorren los nodos del grupo `"enemies"` y se daña a todos los que estén dentro del radio (y que la torre pueda golpear: voladores solo si `can_hit_air`).
- Después, `queue_free()`.

### 6.5 Oleadas (`WaveSpawner`)

- `start_wave(index)` prepara los grupos de esa oleada. En `_process(delta)` lleva un reloj propio y, para cada grupo, crea un enemigo cuando le toca (`start_delay`, luego cada `interval`).
- Lleva la cuenta de enemigos **vivos**. Cuando ya salieron todos y los vivos llegan a 0 → emite `wave_finished` (RF-33).
- **Por qué un reloj con `delta` y no `Timer`s o `await`:** con `delta`, la pausa y la velocidad x2 funcionan sin código extra, y no quedan temporizadores "colgando" si se reinicia el nivel.
- La vida de cada enemigo se calcula al crearlo con `Rules.scaled_health(...)` (RF-36).

### 6.6 Construcción (`BuildController`)

- Guarda `occupied: Dictionary` → `{ Vector2i (casilla): Tower }`.
- Cuando el HUD avisa "elegí la torre X": entra en **modo construcción** y muestra una torre fantasma semitransparente + círculo de alcance.
- Cada frame: pasa el mouse a casilla, coloca el fantasma en el **centro** de esa casilla y lo tiñe de verde o rojo según `can_build(cell)`:
  ```gdscript
  func can_build(cell: Vector2i) -> bool:
      return level.is_buildable(cell) \
          and not occupied.has(cell) \
          and session.can_afford(selected_tower.levels[0].cost)
  ```
- Clic izquierdo válido → `session.spend(costo)` → emite `tower_build_requested(data, cell)` → `Game` crea la torre.

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
| `GameFlow` | Recordar qué nivel eligió el jugador y cambiar de pantalla (`change_scene_to_file`). |
| `SaveManager` | Leer y escribir el progreso y las opciones. |
| `Audio` | Reproducir efectos y música; la música no se corta al cambiar de escena. Buses de audio: `Master`, `Music`, `SFX`. |

### 7.1 Formato del guardado

Archivo `user://save.json` (Godot lo guarda en la carpeta de datos del usuario, en Windows: `%APPDATA%\Godot\app_userdata\<nombre del proyecto>\`).

```json
{
  "version": 1,
  "levels": {
    "level_01": { "unlocked": true,  "completed": true,  "best_lives": 17 },
    "level_02": { "unlocked": true,  "completed": false, "best_lives": 0 }
  },
  "settings": { "music_volume": 0.8, "sfx_volume": 1.0, "fullscreen": false }
}
```

- El campo `version` permite, en el futuro, reconocer guardados viejos y convertirlos.
- Si el archivo **no existe** o está **corrupto**, se empieza con el progreso por defecto (solo nivel 1 desbloqueado) y **no** se cierra el juego.
- Se guarda al ganar un nivel y al cerrar la pantalla de opciones.

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
