# T448 · Presentación de jefes a pantalla completa que pausa la partida (frente E, B-57)

**Fecha:** 2026-10-23 · **Base:** `origin/main` = `250e724` · **Tipo:** análisis y propuesta de spec. **No cambia** código, datos, balance, reglas, canon ni arte. Nada de lo propuesto acá está aprobado: todas las D y RF de este informe son **candidatas, PENDIENTES DE LUCAS**.

**El pedido, según la aclaración de Lucas (2026-10-23, `03-tareas.md:29` y `:2350`):** una **presentación animada** de **3 o 5 s**, **a pantalla completa**, que **pausa la partida**. El destello con grieta y el cartel de 720 × 120 que hay en `main` (T366/T368, D-138, RF-597 a RF-602) y las muestras de T367 (PR #48, cerrado) **no están aprobados** y no representan esa idea.

**Cómo se hizo:** leí M66 (`01-spec.md:3668-3742`), §11 (`:1331`), RF-104, RF-127, RF-134 y RF-135, D-089, D-090, D-112, D-138 a D-140, D-160 y D-161, el plan de M66 (`02-plan-tecnico.md:1521`), las fichas T367 a T369 y este código: `game.gd` (pausa, velocidad, entrada, `_maybe_boss_entrance`, `_open_intro_if_pending`, `_request_exit`), `hud.gd` (la cola), `level_intro.gd`, `boss_entrance_*`, `balance_sim.gd` y `perf_test.gd`. Conté los jefes por oleada en los 15 `data/levels/level_*.json` con un script de Python de solo lectura. Con un proyecto vacío en la carpeta temporal, comprobé que Godot 4.7.2 tiene `Tween.set_ignore_time_scale` y `Tween.set_pause_mode`.
**No se hizo:** no corrí GUT ni el juego, no medí FPS, no hice capturas y no probé nada en un celular. Los costos de arte y de rendimiento de este informe son **estimaciones**, no mediciones.

---

## 0. Resumen en 10 líneas

1. Lo que se pide choca con tres textos vigentes: **D-138** (que dice «no pausa, cartel chico, sin pantallazo completo»), **RF-598** («no bloquea ni pausa») y **§11 / D-089** («siguen excluidas las cinemáticas animadas»). Antes del arte hacen falta una enmienda de §11 y una D que reemplace a D-138 (§1).
2. **Pausa:** se recomienda la pausa que ya existe (`Game.set_paused` → `get_tree().paused`), igual que el cartel de entrada del nivel (D-090), y **no** `Engine.time_scale = 0` (§3).
3. **Duración:** se recomienda la variante **5 s la primera vez en la vida para cada tipo de jefe y 3 s las siguientes**, con la frecuencia «**la primera oleada con jefe de cada partida**». Con la regla de hoy, una por oleada con jefe, el nivel 14 pausaría 6 veces (§2).
4. **Salteo:** cualquier tecla, clic, toque o «atrás». Durante los primeros 0,3 s (en tiempo real) la entrada se traga y no saltea (§4).
5. **Continuidad:** la partida vuelve a la misma velocidad (la presentación corre en tiempo real), la cámara no se toca, la tarjeta «Nuevo enemigo» espera y el cartel de oleada se congela y sigue después. Si durante la presentación la app pasa a segundo plano (D-112), la partida queda en pausa al terminar (§5).
6. **Se rescata** `BossEntranceData`, `EnemyData.entrance`, `BossEntranceRules` (con ajustes), el lector y el validador del JSON, la opción `boss_entrance`, el disparador con su guarda de campaña y la cola de la tarjeta. **Se reemplazan** el cartel, el destello y la regla de esperar al cartel de oleada (§6).
7. **Plan:** cinco tareas, con una compuerta antes del arte (§7). La maqueta 3 s contra 5 s va con rectángulos y un cronograma (§8).

---

## 1. Conflictos de spec y enmienda propuesta

### 1.1 Qué dice hoy y por qué choca

| Texto vigente | Qué dice | Choque con el pedido |
|---|---|---|
| **§11** (`01-spec.md:1331`), desde **D-089** (`04-decisiones.md:713`) | «Siguen excluidos los diálogos entre personajes, **las cinemáticas animadas** y las voces.» La cita es la respuesta de Lucas a Q-01. | Una secuencia animada de 3 a 5 s a pantalla completa, que corta la partida, es lo que cualquiera llamaría una cinemática corta. La constitución (P3, y D-089 citando P4) pide **enmendar §11 antes** de agregar algo excluido. |
| **D-138** (`04-decisiones.md:1229`) | La entrada es un destello y un cartel de 1,6 s que **no pausa**. Descarta expresamente «Pausar o frenar el juego (cinemática)» y «Un pantallazo completo con el jefe en grande». | Lo que se pide son justo las dos alternativas que D-138 descartó. La premisa de D-138 («Lucas pidió que no pause de más», 2026-10-19) queda corregida por la aclaración del 2026-10-23. |
| **RF-597** | El destello y el cartel, con su orden (el cartel de aparición espera al de oleada) y el límite de una entrada por oleada y por tipo, y de una cada 8 s. | Cambian la forma y el orden. El límite hay que revisarlo, porque ahora cada entrada pausa. |
| **RF-598** | «No bloquea ni pausa la partida», cartel de 720 × 120 como máximo, los toques fuera del cartel llegan al mapa, a ×2 dura la mitad. | Contradicción directa en los cuatro puntos. |
| **RF-599** | Se saltea solo con un toque o clic sobre el cartel. **«No hay teclas nuevas.»** | Con la pantalla completa, todo es «el cartel». Con la partida pausada, las teclas no tienen otro dueño (§4). |
| **RF-602** | Rendimiento: 6 nodos de interfaz y un `Sprite2D`. Mide «200 enemigos con la entrada». | El mundo queda congelado durante la presentación: hay que redefinir qué se mide. |
| **M66, «Lo que no incluye»** (`01-spec.md:3737`) | «Retrasar o **pausar** la oleada, **bloquear** la partida…». «**Animar el modelo** del jefe.» | El primer punto se invierte. El segundo depende de lo que se decida en P-E5 (§9). |
| **P-66-2, P-66-5 y P-66-6** | Decididas provisionalmente con la recomendación de Claude: «cada vez», «quieto con pulso» y «sin cámara». | Se reabren las tres: frecuencia, cuánto se anima y si se toca la cámara. |

**Lo que no choca y se conserva:** RF-600 (la opción, con la clave aditiva `boss_entrance`; solo cambia el texto), RF-601 (los datos en `EnemyData.entrance`, con nuevas claves en el JSON de números), **D-139** (la entrada es un dato del enemigo, con piloto en el nivel 1) y **D-140** (la casilla y la cola con la tarjeta RF-134; cambia la parte del cartel de oleada).

**Hay un precedente a favor:** **D-090** ya acepta un cartel que **pausa** mientras se lee (el cartel de entrada del nivel). Su argumento fue: «un cartel que no pausa obliga a leer con la cuenta atrás corriendo». La presentación del jefe puede usar el mismo mecanismo (`_open_intro_if_pending` en `game.gd:622-635`).

### 1.2 Cómo encuadrarla frente a §11: tres alternativas

| Alternativa | Qué implica | Contra |
|---|---|---|
| **A · Enmienda explícita y acotada de §11** *(recomendada)* | §11 sigue excluyendo las cinemáticas animadas **en general**, con **una excepción con nombre**: la presentación de jefes, con límites (ver D-187). | Toca un texto que Lucas aprobó (Q-01). Por eso tiene que decidirlo él. |
| B · Llamarla «presentación con láminas o sprites» y no tocar §11 | Se apoya en la letra de M57 («el fundido es una transición, no una animación de personajes»). | **Es un rodeo.** Lucas pidió *animada*. Si la secuencia se anima de verdad (un golpe, un rugido, un revelado), la exclusión la alcanza y queda una contradicción escondida en la spec. |
| C · Sacar «cinemáticas animadas» de §11 | Simplifica el texto. | Abre la puerta a la intro animada, a las escenas de victoria, etc., que Lucas dejó fuera a propósito en D-089. |

### 1.3 Texto candidato de las decisiones (PENDIENTE DE LUCAS)

> Numeración provisional. La matriz de frentes también propone **D-187** para el frente A (el mapa por omisión) y RF desde **RF-666**. La tarea 📜 de la ronda 2, que es una sola por vez, asigna los números definitivos. Acá se usan los pedidos en la consigna.

**D-187 · Se enmienda §11 por segunda vez: entra la «presentación de jefe», una secuencia animada breve que se puede saltear; siguen fuera los diálogos, las voces y las demás cinemáticas** — *PENDIENTE DE LUCAS*
- **Qué:** la línea de §11 pasa a decir «Diálogos entre personajes, cinemáticas animadas (**salvo la presentación de jefes de M66, D-187**) y voces». La excepción tiene **límites cerrados**:
  - dura **5 s como máximo**, en tiempo real;
  - se saltea con cualquier entrada;
  - sale solo para enemigos con `entrance` en sus datos;
  - **no tiene diálogo** (como mucho, título, nombre y una frase de 80 caracteres, RF-601) ni **voces**;
  - se puede apagar en Opciones;
  - no cambia el resultado de la partida.
- **Por qué:** Lucas lo pidió explícitamente (2026-10-23). P3 pide enmendar antes de programar. Una excepción con nombre conserva la intención de Q-01, que era no convertir el juego en uno narrativo.
- **Alternativas descartadas:** B y C de la tabla 1.2.

**D-188 · La presentación del jefe ocupa toda la pantalla y pausa la partida con la pausa de siempre; reemplaza a D-138** — *PENDIENTE DE LUCAS*
- **Qué:** cuando corresponde (RF-666), el jefe **nace en el mismo instante que hoy**, en la entrada de su camino. En ese mismo cuadro, `Game` pausa con `set_paused(true)` (el mismo `get_tree().paused` de RF-104, D-090 y D-160) y abre una capa que cubre los 1280 × 720 virtuales. Al terminar o al saltearla, la partida vuelve al estado que tenía antes. La animación corre en **tiempo real**, sin depender de ×1, ×2 ni de las velocidades del modo de pruebas.
- **Por qué:**
  - Con la pausa de siempre se apagan el carrito y la demolición en el celular (D-160), se corta la construcción (RF-104) y el reloj de la partida se detiene sin código nuevo.
  - **El balance no cambia**: todo el mundo (`_world_nodes`, `game.gd:762`) queda congelado y vuelve igual, como con el cartel de entrada del nivel.
- **Alternativas descartadas:**
  - `Engine.time_scale = 0` (§3.1).
  - Retrasar el nacimiento del jefe hasta que termine (cambia el tiempo de la oleada).
  - Mantener el cartel chico y agrandarlo (no es lo pedido).
  - Pausar solo el `WaveSpawner` (las torres seguirían disparando: el balance cambia).
- **Reemplaza:** D-138 entera, que queda como «reemplazada por D-188» sin borrarla. **Enmienda:** D-140, en la parte del orden con el cartel de oleada (RF-670).

**D-189 · Duración y frecuencia de la presentación** — *PENDIENTE DE LUCAS (es la elección de §2)*
- **Opción recomendada:** **5 s la primera vez en la vida del jugador para cada tipo de jefe y 3 s las siguientes**, y **solo en la primera oleada con jefe de cada partida**. Las oleadas siguientes con jefe dejan la corona (RF-136) y «¡Llega el Jefe!» en el cartel de oleada (RF-135), como hoy.
- **Cómo saber si es «la primera vez»:** se usa `SaveManager.has_seen_enemy(id)`, que ya existe (RF-134). `_maybe_boss_entrance` corre **antes** de `mark_enemy_seen` (`game.gd:937-940`). **No hace falta ninguna clave nueva en el guardado.**
- **Alternativas:** las de la tabla 2.1.

**D-190 · Salteo con cualquier entrada, protegido 0,3 s; continuidad al volver** — *PENDIENTE DE LUCAS*
- **Qué:** las reglas de §4 y §5.
- **Por qué:** es el molde de `LevelIntro` (cualquier tecla, clic o toque; `_input` se traga todo), que el jugador ya conoce desde el nivel 1. La protección evita que un clic de construcción que llega justo en el cuadro del nacimiento saltee la presentación sin querer.
- **Alternativas descartadas:**
  - Solo un botón «Saltar»: es un blanco chico en el celular y cuesta encontrarlo.
  - Una tecla dedicada: todas las teclas están ocupadas (D-161) y, con la partida en pausa, no hace falta.
  - Sin protección: se saltea sola con el clic que el jugador ya estaba haciendo.

### 1.4 Texto candidato de los requisitos (PENDIENTE DE LUCAS)

Reemplazan a RF-597, RF-598, RF-599 y RF-602, que quedan marcados como «reemplazados por RF-666 a RF-671» y **no se reusan**. RF-600 y RF-601 se enmiendan en el lugar.

- **RF-666 · Qué es y cuándo sale** *(D-187, D-188, D-189)*.
  - Cuando nace un enemigo con `entrance`, se cumplen las cuatro condiciones de `BossEntranceRules` (la opción está prendida, el nivel está en `levels`, la partida es de campaña jugada desde el menú y corresponde por frecuencia, RF-669) y no hay otra presentación abierta, la partida **se pausa** y se abre la **presentación**:
    - una capa que cubre toda la pantalla, con un fondo oscurecido sobre el mapa congelado (o la lámina de fondo del jefe, cuando haya arte);
    - el **retrato grande** del jefe;
    - «**¡Llega el Jefe!**», su **nombre** y su **frase** (`line_for`);
    - la pista «Tocá para seguir» o «Clic o cualquier tecla para seguir», que aparece después de la protección.
  - **Criterio:** **Dado** el nivel 1 jugado desde el menú, con la opción prendida y un guardado nuevo → **Cuando** nace el Jefe de la oleada 10 → **Entonces** en ese mismo cuadro la partida queda pausada, la presentación ocupa la pantalla entera y dura la versión larga (RF-669); al terminar, la partida sigue con el Jefe en la entrada del camino, en la misma posición que al nacer.

- **RF-667 · Pausa la partida y no la cambia** *(D-188)*.
  - Pausa con `Game.set_paused(true)`: el mundo se congela, la cuenta atrás no corre, el carrito y la demolición se apagan (D-160) y no se construye, mejora ni vende. Se ve con `show_paused(true, false)`, **sin** el cartel «PAUSA».
  - Al terminar, la partida vuelve al estado anterior: corriendo, o en pausa si así estaba antes o si se pidió la pausa durante la presentación (RF-670).
  - El **resultado** de una partida con presentación y sin ella, con la misma semilla y las mismas acciones, es **idéntico** (oro, vidas, puntaje y estrellas).
  - **Criterio:** **Dado** la misma partida con y sin la opción, con la misma semilla → **Entonces** los resultados finales son iguales. **Dado** la presentación abierta en modo celular → **Entonces** el carrito está apagado y la barra dice «En pausa…».

- **RF-668 · Salteo** *(D-190)*.
  - Cualquier tecla (sin repetición), clic soltado, toque soltado o «atrás» (acción `cancel`) la cierra con un fundido de 0,15 s.
  - Durante los primeros **0,3 s** (tiempo real, `salteo_bloqueo_s` en el JSON) las entradas **se tragan y no saltean**. Un soltar sin su apretar dentro de la presentación no cuenta.
  - Ninguna entrada llega a la partida mientras está abierta.
  - Saltear no se guarda.
  - **Criterio:** **Dado** un clic a los 0,1 s → **Entonces** no pasa nada. **Dado** un clic a los 0,5 s → **Entonces** se cierra y la partida sigue. **Dado** Esc a los 0,5 s → **Entonces** se cierra y **no** se abre el menú de pausa.

- **RF-669 · Duración y frecuencia** *(D-189)*.
  - La versión **larga** (5 s) sale si el jugador nunca vio a ese enemigo (`has_seen_enemy` es falso). La **corta** (3 s) sale en los demás casos.
  - Sale **una vez por partida y por tipo**, en la primera oleada que trae a ese jefe. «Reintentar» es otra partida.
  - Las fases (entrada, revelado, quieto, salida) y sus segundos viven en `data/ui/entrada_jefes.json`.
  - **Criterio:** **Dado** el nivel 3 (jefes en las oleadas 10, 15, 18 y 20) → **Entonces** sale una sola presentación, en la oleada 10.

- **RF-670 · Continuidad** *(D-190)*. Las reglas de §5: la velocidad, la cámara, la tarjeta RF-134, el cartel de oleada, el segundo plano (D-112), el modo de pruebas y salir a mitad de la presentación.

- **RF-671 · Dónde sale y qué se mide**.
  - **Sale** en la campaña jugada desde el menú (PC y celular) y en el modo de pruebas (con el panel F1 o al llegar a la oleada).
  - **No sale** en el editor («Probar»), en los mapas de la comunidad, en la escena suelta ni en `balance_sim`. **Asedio, según P-E7.**
  - Rendimiento:
    - con 200 enemigos congelados debajo, la presentación mantiene 60 FPS en PC (P7) según `perf_test.gd -- entrada_jefe`;
    - al abrirse no hay un cuadro de más de 33 ms, para lo cual las texturas grandes se cargan al empezar un nivel que tiene un jefe con entrada;
    - el peso de las texturas queda anotado para la APK.

- **RF-600 (enmienda):** la casilla pasa a llamarse «**Presentación de los jefes**». La clave sigue siendo `boss_entrance`: sin migración, y un guardado viejo la lee prendida.
- **RF-601 (enmienda):** en `entrada_jefes.json` salen `destello_s`, `cartel_*`, `arriba_*` e `intervalo_min_s`, y entran `larga_s`, `corta_s`, las fases, `salteo_bloqueo_s` y `salida_s`. `BossEntranceData` puede sumar, de forma opcional, `portrait` y `backdrop` (texturas grandes; vacías = retrato y fondo provisionales). En los dos casos, sin lenguaje de scripts (P4).

---

## 2. 3 s contra 5 s

### 2.1 Cuántas veces pausa según la frecuencia (datos reales de `data/levels/`)

Oleadas con jefe en cada nivel (con la regla de hoy, una presentación por oleada y por tipo):

| Nivel | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Oleadas con jefe | 1 | 3 | 4 | 3 | 4 | 3 | 4 | 3 | 4 | 4 | 4 | 4 | 4 | **6** | 3 (Coloso) |
| Total de oleadas | 10 | 15 | 20 | 15 | 20 | 15 | 20 | 18 | 20 | 20 | 22 | 24 | 24 | 26 | 30 |

La campaña entera, jugada una vez y sin perder, suma **54 oleadas con jefe**. Hay dos tipos: el Jefe en los niveles 1 a 14 y el Coloso en el 15.

| Frecuencia | Presentaciones (campaña una vez) | 3 s fijos | 5 s fijos | 5 s la primera vez, 3 s después |
|---|---|---|---|---|
| **F1** Cada oleada con jefe (la regla de hoy) | 54 | 162 s · nivel 14: 18 s | 270 s · nivel 14: 30 s | 2×5 + 52×3 = **166 s** · nivel 14: 18 s |
| **F2** La primera oleada con jefe de cada partida *(recomendada)* | 15 | 45 s | 75 s | 2×5 + 13×3 = **49 s** |
| **F3** Solo la primera vez en la vida | 2 | 6 s | 10 s | 10 s |

*Cada reintento suma una presentación más con F1 (de 3 a 6 en un mismo nivel) o una con F2. Las cuentas son a duración completa, sin saltear.*

### 2.2 Comparación

| Criterio | **3 s** | **5 s** | **Variante 5 s la primera vez, 3 s después** |
|---|---|---|---|
| **Ritmo** | Es un golpe: oscurece, entra el retrato, nombre, sigue. Entra bien en medio de una oleada sin cortar la tensión. Alcanza para leer el nombre y una frase corta, pero no los 80 caracteres completos con calma. | Hay lugar para un revelado (silueta → retrato), el título y la frase leída sin apuro. Con la partida pausada en plena oleada final, 5 s se sienten largos la segunda vez. | La primera vez tiene la ceremonia y la lectura, y las siguientes son un recordatorio rápido. Es el patrón de RF-134 (la primera vez se explica). |
| **Repetición por nivel** | Con F1, el nivel 14 suma 18 s y corta 6 veces. Con F2, 3 s por partida. | Con F1, 30 s en el nivel 14: **se va a apagar la opción**. Con F2, 5 s por partida, aceptable. | Con F2 es lo mínimo con ceremonia (49 s en toda la campaña). Con F1 es igual a 3 s fijos salvo las dos primeras. |
| **Costo de arte** *(estimación)* | Por jefe, un retrato grande y un fondo, o un fondo genérico teñido. El movimiento se hace por código (tweens de posición, escala, sacudida de la lámina y fundidos). Sin cuadros de animación. | Lo mismo y además algo que llene los 2 s extra sin que parezca quieto: una **silueta** o una capa de primer plano (polvo) para el revelado, o un ciclo corto de 4 a 8 cuadros (el rugido de P-66-5). Es más del doble de trabajo de animación. | El arte de la versión de 5 s. La de 3 s es un corte de la misma línea de tiempo (sin el revelado), así que **no suma arte**, solo una segunda lista de fases en el JSON. |
| **Mobile** | A pantalla completa en 1280 × 720 virtual se lee bien. El blanco es toda la pantalla. Se carga una sola textura grande. | Igual, pero con más capas y quizás un atlas de cuadros, así que hay más memoria y más riesgo de un tirón al abrir. **No medido.** | Igual que 5 s en memoria, porque las texturas son las mismas. |
| **Peso (APK)** *(referencia, no medición)* | Si el fondo es una lámina 16:9 como las de la intro (7 láminas suman unos 4 MiB, D-150, alrededor de 0,6 MiB cada una), son de 0,6 a 1,2 MiB por jefe. | De 1 a 2 MiB por jefe, con la silueta o el atlas. | Igual que 5 s. |
| **Riesgo de spec** | Bajo, porque es la excepción más chica de §11. | Medio: más animación, más cerca de una «cinemática». | Medio, con el mismo límite de 5 s. |

**Recomendación de Claude:** la **variante con F2**. Si Lucas prefiere una sola duración por simplicidad, **3 s con F2**.

---

## 3. Pausa

### 3.1 `get_tree().paused` contra `Engine.time_scale = 0`

| | `get_tree().paused` (vía `Game.set_paused`) *(recomendada)* | `Engine.time_scale = 0` |
|---|---|---|
| Qué congela | Lo que es `PROCESS_MODE_PAUSABLE`: los `_world_nodes` (nivel, torres, enemigos, proyectiles, efectos, spawner, sesión, infraestructura y obstáculos; `game.gd:124-126` y `:762`). `Game` y el HUD siguen vivos (`ALWAYS`). | Todo lo que usa `delta` escalado, **incluida la propia presentación** y los tweens del HUD, salvo los que tengan `set_ignore_time_scale(true)`. |
| Velocidad ×1/×2 | **Intacta**: `time_scale` no se toca, así que al volver sigue a ×2 sin guardar nada. | Hay que guardar y restaurar la velocidad. `set_speed` emite `speed_changed` y cambia el cartel del modo de pruebas (`DevMode.show_speed`): un ×0 aparecería en la interfaz y en `dev_stats`. |
| D-160 (carrito) | **Gratis**: `pause_changed` ya llega a `MobileHud.set_paused` (`game.gd:154`). | No hay señal, así que el carrito queda vivo y se puede «planear» en una pausa disfrazada, justo lo que D-160 prohíbe. |
| RF-104 (no construir) | `set_paused(true)` ya llama a `build_controller.cancel()`. | Hay que repetirlo a mano. |
| Física y división por `delta` | Sin riesgo. | Con `delta = 0` puede haber divisiones por cero en código que divida por `delta`. No auditado. |
| Precedente | El cartel de entrada del nivel (D-090), el diálogo de salida y el menú de pausa. | Ninguno en el proyecto. |

**Detalle importante.** El HUD es `ALWAYS`, así que sus tweens **siguen corriendo en pausa**: el cartel de oleada (`hud.gd:802-814`) y la tarjeta «Nuevo enemigo» (6 s, `hud.gd:373-378`) se consumirían debajo de la presentación. La presentación tiene que **pausar esos tweens o hacerlos esperar** (§5).

### 3.2 Convivencia con lo demás

| Caso | Regla propuesta |
|---|---|
| **Menú de pausa (Esc)** | No se abre durante la presentación: Esc la saltea (RF-668), como en `LevelIntro`. El jefe no puede nacer con el menú abierto, porque el spawner está congelado en pausa. |
| **Tecla P o botón Pausa** | P es «una tecla más»: saltea. **Alternativa (P-E9):** P o el botón Pausa saltean **y dejan la partida en pausa**, para quien quiere pensar después de ver al jefe. Recomendación: **la alternativa**, porque se programa con la misma marca de D-112 (abajo) y respeta la intención del jugador. |
| **Diálogo de salida («← Menú»)** | Su botón queda debajo de la capa y no se puede tocar. Esc saltea. |
| **D-112 (segundo plano)** | Si llega `NOTIFICATION_APPLICATION_PAUSED` con la presentación abierta, `pause_for_background` hoy no hace nada (`is_paused()` ya es verdadero, `game.gd:529-532`), y **al terminar la presentación la partida se reanudaría sola**. Hay que agregar una marca, `_resume_paused = true`, para que al cerrar quede en pausa. La animación puede terminar o no mientras la app está en segundo plano: lo que se garantiza es el estado final. |
| **Pausa previa** | Si la partida ya estaba en pausa cuando nace el jefe (solo puede pasar con `spawn_now` del panel F1), se guarda ese estado y se restaura, como `_exit_was_paused` (`game.gd:699` y `:711`). |
| **Tutorial (M63)** | `TutorialOverlay` es la capa 12 y `ALWAYS`. Si quedara un paso abierto en la oleada 10, la presentación (capa 19 propuesta, entre el tutorial y la pausa, que es la 20) lo tapa y el paso espera. **No verificado:** si el tutorial del nivel 1 puede seguir abierto en la oleada 10. |
| **`balance_sim` idéntico** | Instancia `game.tscn` con HUD (`balance_sim.gd:267`), pero sin `GameFlow.current_level()` (es null), así que `_maybe_boss_entrance` sale en la guarda (`game.gd:953-956`). **Con pausa es todavía más importante:** si se disparara, el bot quedaría colgado en una partida pausada. Propuesta: mantener la guarda, agregar un test que lo fije («sin nivel de campaña no hay presentación») y en T4xx-c comparar el JSON del bot antes y después en los niveles 1, 3 y 15 con la misma semilla. Eso no se hizo en T368. |

---

## 4. Salteo

| Entrada | 0 a 0,3 s (protección) | Después de 0,3 s |
|---|---|---|
| Tecla (no repetida) | Se traga | Saltea (P: ver P-E9) |
| Clic izquierdo | Se traga | Saltea **al soltar**, si el apretar también fue dentro de la presentación y después de la protección |
| Rueda, clic derecho, movimiento | Se tragan | Se tragan (no saltean) |
| Toque (`InputEventScreenTouch`) | Se traga | Saltea al soltar (el celular emula el clic, como en `LevelIntro`) |
| «Atrás» de Android (`cancel`) | Se traga | Saltea |
| Pellizco o arrastre que venía de antes | El soltar huérfano se traga | Se traga |

- **Dónde:** en `_input` de la capa nueva, como `LevelIntro._input` (`level_intro.gd:79-98`), para que nada llegue al `_unhandled_input` de `Game` ni a la cámara.
- **El reloj:** la protección y la animación usan tweens con `set_ignore_time_scale(true)` y `TWEEN_PAUSE_PROCESS`, con la capa en `PROCESS_MODE_ALWAYS`. Comprobé que la API existe en 4.7.2. Así 0,3 s son 0,3 s a ×1, a ×2 y a ×8.
- **La pista** («Tocá para seguir» o «Clic o cualquier tecla para seguir») aparece **al terminar la protección**. Así no invita a tocar cuando todavía no responde.
- **Riesgo para el celular (no probado):** un pellizco de zoom en curso cuando nace el jefe. La cámara podría quedarse en estado de «arrastrando» si se traga su soltar. Hay que probarlo con toques simulados y después en un celular real.

---

## 5. Continuidad

| Tema | Propuesta | Alternativa |
|---|---|---|
| **Velocidad ×1, ×2 y las del modo de pruebas** | No se toca: la partida vuelve a la misma. La presentación dura lo mismo a cualquier velocidad (tiempo real). Es un cambio respecto de RF-598, donde a ×2 duraba la mitad. | Que a ×2 dure la mitad: castiga con una presentación de 1,5 s, ilegible, justo a quien va rápido. |
| **Cámara** | No se mueve ni se acerca: el mapa congelado se ve **igual** antes y después (P-66-6 se mantiene). | P-E8: un recorte del mapa, sin mover la cámara, que muestra «dónde entra» al final (§6, el destello). |
| **Tarjeta «Nuevo enemigo» (RF-134)** | Espera a que termine la presentación y sale con sus 6 s, como hoy (D-140). Si estaba en pantalla por otro enemigo, su tween **se pausa** y sigue después. | P-E6: en la versión larga, como la frase ya está en pantalla, se marca vista y **no** sale. Ahorra 6 s de texto repetido, pero D-140 la había querido conservar. |
| **Cartel de oleada (RF-127, RF-135)** | En el nivel 1 el jefe nace **en el segundo 0** de la oleada 10, el mismo instante en que arranca el cartel «Oleada 10 · ¡Llega el Jefe!». La presentación **no espera**: abre en el cuadro del nacimiento, el tween del cartel se pausa y el cartel termina después. | Esperar a que el cartel se retire (como mucho 1,5 s, lo que hace hoy D-140): mientras tanto el jefe camina y la partida corre, y la pausa llega «tarde». |
| **Asedio** | Hoy **no sale** (guarda `GameFlow.current_level()`). P-E7: no sale en Asedio (es un modo para repetir los mapas, y la opción ya existe para quien quiera apagarla en la campaña). | Que salga, solo en versión corta con F2. |
| **Modo de pruebas (RF-602)** | Se mantiene: sale con el panel F1 («hacer aparecer») y al llegar a la oleada, con la frecuencia F2 por tipo. Para verla de nuevo, se reintenta. | *Sugerencia de Claude, no pedida (consultar antes de implementar):* un botón «Ver presentación» en el panel F1 que la abra sin hacer nacer un jefe y con las dos duraciones. No se implementa sin el OK de Lucas. |
| **Opción de Opciones** | La misma casilla y la misma clave `boss_entrance`; cambia el texto a «Presentación de los jefes». Apagada, el jefe aparece como siempre (cartel de oleada, corona y tarjeta) y **sin pausa**. | Un selector de tres estados («Siempre / Solo la primera vez / Nunca») con una clave nueva: es una fila más en Opciones, que choca con la reorganización del frente C. |
| **Salir a mitad (← Menú, cerrar o test)** | `_exit_tree` ya llama a `_reset_time()` (pausa en falso, ×1). La capa se borra con la escena y no deja nodos (lo cubre el test que ya existe y hay que adaptar). | — |
| **Límite de 8 s (`intervalo_min_s`)** | **Se retira:** con F2 no hace falta. Además mide con `Time.get_ticks_msec()` (`game.gd:962`), que cuenta el tiempo en pausa. Con la presentación pausando, el reloj contaría su propia duración. | Mantenerlo y medirlo con el tiempo de la partida: solo sirve con F1. |
| **El retrato y el canon** | El nombre y la frase salen de los datos (P-66-4). Ningún texto nuevo de lore, salvo que Lucas lo pida en `11-textos-lore.md`. | — |

---

## 6. Qué rescatar del código de T366/T368 y qué reemplazar

| Pieza | Destino | Nota |
|---|---|---|
| `scripts/data/boss_entrance_data.gd` (`levels`, `line`, `sound`) | **Se conserva** | Opcionalmente suma `portrait` y `backdrop` (RF-601, enmendado). |
| `EnemyData.entrance`; `boss.tres` con `levels = ["level_01"]` | **Se conserva** | El piloto sigue en el nivel 1. |
| `BossEntranceRules.level_allowed`, `line_for` y `validate` | **Se conservan** | — |
| `BossEntranceRules.should_show` | **Se adapta** | Sale `min_gap_s` y entra la frecuencia (F1/F2/F3) con los tipos ya presentados **en la partida**, no en la oleada. Suma `is_long(seen_before) -> bool`. Sus 10 tests se reescriben en parte. |
| `scripts/data/boss_entrance_config.gd` y `data/ui/entrada_jefes.json` | **Se adaptan** | Mismo lector y mismos mensajes; cambian las claves (RF-601, enmendado). Salen `MAX_WIDTH_PX` y `MAX_HEIGHT_PX`; `MAX_SECONDS = 5.0` ya coincide con el tope de D-187. |
| `tools/check_entrada_jefes.gd` y `test_boss_entrance_data.gd` (11) | **Se conservan** | Se ajustan a las claves nuevas. |
| `SaveManager.boss_entrance_enabled()`, `DEFAULT_SETTINGS` y los 2 casos de `test_old_saves.gd` | **Se conservan** | — |
| `OptionsMenu._build_boss_entrance_check` y `test_boss_entrance_options.gd` (7) | **Se conservan** | Cambia el texto. Hay que coordinar con el frente C (reagrupar Opciones). |
| `Game._maybe_boss_entrance` (la guarda de campaña y el disparo en `_on_enemy_spawned`) | **Se adapta** | Deja de crear el destello y el cartel, y llama a un `_open_boss_presentation(enemy)` hecho como `_open_intro_if_pending`: `input_blocked`, `set_paused(true)`, `show_paused(true, false)`, `mobile_hud.set_modal_open(true)` y las marcas de §3.2. |
| La cola del HUD (`_entrance_pending`, `entrance_blocks_intro`, la espera de `_show_next_intro`) | **Se conserva la idea** | La tarjeta RF-134 sigue esperando. **Sale** la espera del cartel de oleada (`_wave_banners_active` en `_try_open_entrance`) y entra «pausar los tweens del HUD que estén corriendo y reanudarlos al cerrar». |
| `scenes/ui/boss_entrance_card.gd` (cartel de 720 × 120, `PAUSABLE`, la ✕) | **Se reemplaza** | Por `scenes/ui/boss_presentation.gd` (`BossPresentation`): `CanvasLayer` (capa 19 propuesta), `ALWAYS`, tweens en tiempo real, `_input` como `LevelIntro`, señal `closed` (P6). Los nodos se crean al abrir y se borran al cerrar (cero costo fuera). |
| `scenes/effects/boss_entrance_burst.gd` y `EffectsLayer.boss_entrance` | **Se retiran** (o P-E8) | Con la partida pausada, el destello no se vería: quedaría congelado debajo. Si Lucas quiere marcar «dónde entra», puede volver como un aviso de 0,7 s **después** de reanudar. |
| `tests/test_boss_entrance_hud.gd` (23) | **Se reescribe en su mayoría** | Se pueden conservar, adaptados: opción apagada, nivel 2, escena suelta, enemigo sin entrada, Coloso por datos, modo de pruebas, salir a mitad, uno por oleada (pasa a ser uno por partida). Se tiran: «no pausa», «1,6 s», «cartel chico», «clic sobre el cartel», «✕ en PC», «el destello» y «sigue la velocidad». |
| `tools/capture_boss_entrance.gd` y `perf_test.gd -- entrada_jefe` | **Se adaptan** | La medición pasa a ser «200 enemigos congelados y la capa encima», más el pico del cuadro de apertura. |
| **PR #22** (T412, T413 y parte de T410 y T414, según la matriz §2) | **No se integra** | Integra el concepto viejo. Lo que se rescata de esa rama es solo lo de mejoras (T411). Cerrarlo o rehacerlo lo decide Lucas. |

---

## 7. Flujo y plan de tareas

### 7.1 Estados de la secuencia

```
                   enemy_spawned (Game._on_enemy_spawned)
                                │
               ¿entrance? ¿campaña desde el menú? ¿opción? ¿nivel en levels?
               ¿frecuencia (F2: primer jefe de ese tipo en la partida)?
                  │ no                                   │ sí
                  ▼                                      ▼
        (sigue como hoy: corona,          ┌──────────── ABRIENDO ─────────────┐
         cartel de oleada, RF-134)        │ guarda pausa previa               │
                                          │ set_paused(true) · input_blocked  │
                                          │ show_paused(true,false)           │
                                          │ mobile_hud.set_modal_open(true)   │
                                          │ pausa tweens del HUD (oleada/RF-134)│
                                          │ elige larga (5 s) o corta (3 s)   │
                                          └───────────────┬───────────────────┘
                                                          ▼
                                     PROTEGIDA (0–0,3 s): entradas se tragan
                                                          │ 0,3 s (tiempo real)
                                                          ▼
                       ┌──────── REPRODUCIENDO (pista visible) ────────┐
                       │ fases del JSON · tiempo real · ×1/×2 no cuenta │
                       │ NOTIFICATION_APPLICATION_PAUSED → _resume_paused = true
                       │ P / botón Pausa (si P-E9) → _resume_paused = true
                       └───────┬───────────────────────────┬───────────┘
                     fin del tiempo                tecla/clic/toque/atrás
                               └─────────────┬─────────────┘
                                             ▼
                                  CERRANDO (fundido 0,15–0,4 s)
                                             ▼
                       ┌────────────── REANUDANDO ──────────────┐
                       │ borra la capa · input_blocked = false  │
                       │ set_paused(pausa previa OR _resume_paused)
                       │ si quedó en pausa: show_paused(true) (cartel «PAUSA»)
                       │ reanuda tweens del HUD: termina «Oleada N»
                       │ y sale la tarjeta RF-134 si esperaba    │
                       └──────────────────┬─────────────────────┘
                                          ▼
                                        INACTIVA
   En cualquier estado: _exit_tree → _reset_time() y la capa se borra con la escena.
```

### 7.2 Tareas para M66 reespecificada

Los números de T367 y T369 se **conservan**, con alcance nuevo (están abiertas). T368 está `[x]` y **no se reabre**: la reimplementación es una tarea nueva. Los `T4xx` los asigna el tablero (los libres empiezan en T447; T448 es este informe).

| Tarea | Qué | Depende de | Hecho cuando |
|---|---|---|---|
| **T4xx-a · 📜 Spec de M66 v2** | Escribir D-187 a D-190 y RF-666 a RF-671 con lo que Lucas elija en §9. Marcar D-138, RF-597, RF-598, RF-599 y RF-602 como «reemplazados» (sin borrar ni reusar). Enmendar RF-600, RF-601, D-140, §11 y «Lo que M66 no incluye». Reescribir la ficha `T367-arte-entrada-jefes.md`. Actualizar el plan (`02`) y el tablero (`03`). | El OK de Lucas a §9 | Las respuestas de Lucas están citadas en cada D; no queda ninguna frase en 01 a 04 que diga «no pausa» para M66; `CONTENIDO.md` y `README.md` no prometen el cartel viejo; el diff es solo de documentos. |
| **T4xx-b · Maqueta 3 s contra 5 s** (§8) | Una escena de herramienta en `tools/`, con rectángulos y texto provisional, sin arte. | T4xx-a o, si Lucas prefiere elegir antes, va primero | Lucas eligió la duración, la frecuencia y el estilo del revelado mirándola, y su elección quedó anotada en D-189. |
| **T367 (redefinida) · 🎨 Arte de la presentación del Jefe** | Retrato grande, fondo a pantalla completa o fondo genérico teñido y, si sale la versión de 5 s, la silueta o el ciclo corto. Con fuentes, prompts, `manifest.json` y una hoja a escala real en PC y celular. | T4xx-a, T4xx-b y el visto bueno de la guía de arte | Las muestras están en `art/jefes-m66/` (nada en `assets/`); se anotó el peso; **Lucas dio su OK por escrito**. |
| **T4xx-c · Código con rectángulos** | `BossPresentation` provisional; `Game._open_boss_presentation` con pausa, salteo y continuidad (§3 a §5); se retiran `BossEntranceCard` y `BossEntranceBurst`; se adaptan las reglas, el JSON, el validador y los tests de §6. | T4xx-a (no espera al arte, P4) | En el nivel 1 desde el menú, la oleada 10 pausa en el cuadro del nacimiento y abre la presentación larga con un guardado nuevo y la corta con uno que ya vio al Jefe. La protección de 0,3 s, el salteo con tecla, clic, toque y «atrás», Esc sin menú de pausa, P según P-E9, D-112 (queda en pausa), ×2 conservado, la cámara igual, la tarjeta RF-134 después y el cartel de oleada que termina después tienen tests. Con la opción apagada, en el nivel 2 y en la escena suelta no pasa nada. `balance_sim` da **el mismo JSON** antes y después en los niveles 1, 3 y 15 con la misma semilla. Hay capturas reales en PC y modo celular a 1280 × 720. GUT completo en verde y sin `SCRIPT ERROR`. |
| **T369 (redefinida) · Integrar el arte aprobado y medir** | Reemplazar los rectángulos por el arte de T367 sin cambiar el comportamiento; precarga al empezar el nivel; `perf_test -- entrada_jefe`. | T367 y T4xx-c | 60 FPS en PC con 200 enemigos y la capa; sin cuadro de más de 33 ms al abrir (con la máquina libre); peso anotado; `CHANGELOG`, `CONTENIDO` (cómo darle presentación a otro jefe) y `README` al día. **El celular real queda pendiente**, dicho explícitamente. |
| **T4xx-d · Extender por datos** (después, P3) | `entrance` para el Coloso y `levels = []` para el Jefe, con su arte propio. | T369 y el OK de Lucas | Sin tocar ningún `.gd`. Con F2: una presentación por partida en los 15 niveles. |

**Orden y solapes (matriz §5):** T4xx-a va en la ronda 2 (📜 de a una). T4xx-c **∥** el frente A (solo comparten `save_manager.gd` y `test_old_saves.gd`, y **esta propuesta no agrega claves**) y **antes** que el frente C (los dos tocan `options_menu.gd` y `hud.gd`). La pantalla completa depende del frente B: con `aspect` en `keep` hay franjas negras, y la capa tiene que cubrir **toda** la ventana, no solo los 1280 × 720.

---

## 8. Maqueta comparativa 3 s contra 5 s (propuesta, sin arte final)

**Qué sería (T4xx-b):** una escena de herramienta, `tools/boss_presentation_mock.tscn`, que no se exporta. Sobre una captura quieta del nivel 1 en la oleada 10 (o un rectángulo verde si no la hay), reproduce las líneas de tiempo con **rectángulos de colores planos y texto provisional**:

- retrato: un rectángulo carmesí `#ba403e` de 360 × 360;
- silueta: el mismo rectángulo, negro al 80 %;
- título, nombre y frase: rótulos;
- oscurecido: un `ColorRect` negro.

Debajo hay una **barra de cronograma** con las fases marcadas y una aguja de tiempo real.

**Controles:**
- `1`: corta de 3 s.
- `2`: larga de 5 s.
- `3`: variante (larga y después corta, una detrás de otra).
- `4`: simulación del nivel 14 con F1 (seis cortas separadas por 4 s de «partida»).
- `Espacio`: repetir.
- Clic: probar el salteo con la protección de 0,3 s.
- `M`: alternar el modo celular (la misma interfaz, la pista «Tocá para seguir»).

Los segundos salen del mismo `entrada_jefes.json` propuesto, así que lo que Lucas apruebe se copia tal cual. **No se produce en esta tarea.**

**Cronograma propuesto** (tiempo real; la protección dura de 0 a 0,3 s en las dos):

```
CORTA · 3,0 s
0,0      0,3      0,6            1,0                              2,6      3,0
|oscurece|retrato entra (desliza + golpe de la lámina)|título+nombre|  quieto: frase, pulso   |sale|
|▓▓▓▓▓▓▓▓|████████████████████████████|▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒|░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|▓▓▓▓▓▓|
 └ protección ┘ pista «Clic para seguir» desde 0,3 s ───────────────────────────────────────┘

LARGA · 5,0 s
0,0     0,4         1,2          1,8         2,4                                   4,4     5,0
|oscurece|silueta crece (revelado)|retrato: golpe|título+nombre|  quieto: frase leída con calma  |sale|
|▓▓▓▓▓▓▓|░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒|██████████████|▒▒▒▒▒▒▒▒▒▒▒▒|░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|▓▓▓▓▓▓|
 └ protección ┘

VARIANTE: la primera vez en la vida para ese tipo = LARGA; las siguientes partidas = CORTA
(la corta es la larga sin el «revelado», 0,4 → 1,2 s, y con el «quieto» recortado).

NIVEL 14 con F1 y CORTA: ▓3s▓──4s──▓3s▓──...── seis veces (18 s pausados).
NIVEL 14 con F2:         ▓3s▓ una sola vez, en la oleada 11.
```

**Qué tiene que mirar Lucas:** si 3 s alcanzan para leer el nombre y la frase; si 5 s cansan la segunda vez; si el revelado vale el arte extra; si la pista y la protección se sienten bien; y cómo se ve en el modo celular.

---

## 9. Decisiones que Lucas debe tomar antes del arte

| # | Pregunta | Recomendación de Claude |
|---|---|---|
| **P-E1** | ¿Se enmienda §11 con una **excepción con nombre** para la presentación de jefes (D-187, alternativa A), o preferís B o C? | **A**: es honesta con la palabra «animada» y no abre otras cinemáticas. |
| **P-E2** | ¿La presentación **reemplaza** al destello y al cartel de T368 (D-188 reemplaza a D-138)? | **Sí**, entera. El destello solo vuelve si elegís P-E8. |
| **P-E3** | ¿Duración: **3 s**, **5 s** o **5 s la primera vez por jefe y 3 s después**? | **La variante.** |
| **P-E4** | ¿Frecuencia: **cada oleada con jefe** (F1), **la primera de cada partida** (F2) o **solo la primera vez en la vida** (F3)? | **F2.** Con F1, el nivel 14 pausa 6 veces. |
| **P-E5** | ¿Cuánta animación: **movimiento por código sobre ilustraciones quietas** (retrato y fondo con deslizamiento, golpe y pulso), o **cuadros animados** del jefe (rugido, 4 a 8 cuadros)? | **Por código** para el piloto. Los cuadros, solo si la maqueta muestra que 5 s quedan quietos. |
| **P-E6** | Con la versión larga, ¿sigue saliendo después la tarjeta «Nuevo enemigo» (RF-134), o la presentación la reemplaza esa vez? | **Que siga** (D-140, sin tocar RF-134), salvo que en la maqueta te parezca repetida. |
| **P-E7** | ¿Sale en **Asedio**? | **No** por ahora (hoy tampoco sale). |
| **P-E8** | ¿Se marca **dónde entra** el jefe al volver (un aviso de 0,7 s en la entrada del camino, reusando la idea del destello)? | **No** en el piloto: la cámara no se mueve y el jefe está a la vista en la entrada. |
| **P-E9** | La **P** o el botón Pausa durante la presentación: ¿saltea y sigue la partida, o saltea y **la deja en pausa**? | **La deja en pausa.** |
| **P-E10** | ¿Fondo **propio por jefe** (una lámina 16:9, de 0,6 a 1,2 MiB estimados cada una) o **uno genérico teñido** con el color del enemigo? | **Genérico teñido** para el piloto: un solo encargo y menos peso en la APK. |
| **P-E11** | ¿El texto de la opción pasa a «**Presentación de los jefes**» con la misma clave, o querés un selector de tres estados? | **El mismo texto y la misma casilla**, renombrada. |
| **P-E12** | ¿Querés ver primero la **maqueta de rectángulos** (T4xx-b) y recién después aprobar la spec, o al revés? | **Primero la maqueta**: decide P-E3, P-E4 y P-E5 con algo a la vista y no con números. |

**Hasta que Lucas conteste P-E1 a P-E5 y P-E10 no se encarga arte (T367).** El código con rectángulos (T4xx-c) puede esperar solo a P-E1 a P-E4, P-E6, P-E7 y P-E9.

## Decisiones de Lucas (2026-10-23)

> Registradas por Claude a partir de las respuestas de Lucas en la sesión. **Todavía no son D ni RF** y nada está implementado; los números de D/RF los fija la tarea de spec. Lo que dice «a aclarar» queda abierto.

1. **Excepción a §11/D-089:** autorizada, **solo para la presentación de jefes**, con nombre propio. La regla «sin cinemáticas animadas» sigue valiendo para todo lo demás.
2. **Reemplazo de T368:** el destello y el cartel de T368 se reemplazan enteros (no estaban aprobados, según las instrucciones de Lucas).
3. **Duración:** **5 s la primera vez** que se ve a ese jefe y **3 s después**. Consecuencia: el guardado necesita un dato aditivo con los jefes ya vistos.
4. **Frecuencia:** la **primera oleada con jefe de cada partida** (15 en la campaña). Reaparece si se reintenta el nivel.
5. **Salteo:** cualquier tecla o toque tras **0,3 s** de protección.
6. **Tarjeta «Nuevo enemigo»:** sigue saliendo, **después** de la presentación.
7. **Asedio:** la presentación **no sale**.
8. **Tecla P:** saltea y **deja la partida en pausa**.
9. **Fondo:** **propio por jefe** (elegido contra la recomendación de un fondo genérico teñido). Hoy hay un solo tipo de jefe en los niveles (`boss.tres`, 64 apariciones) más el Coloso, así que son pocos fondos; **a aclarar** cuáles cuentan como jefe.
10. **Animación:** **por código sobre ilustraciones quietas**.
11. **Marca de por dónde entra el jefe al volver:** no.
12. **Opciones:** la misma casilla, renombrada **«Presentación de los jefes»**, en «Partida y ayudas».
13. **Maqueta de rectángulos 3 s vs 5 s:** **no**; se aprueba la spec directo. El arte final sigue sin producirse hasta aprobar esa spec.

### Ampliación de las decisiones de Lucas (2026-10-23, segunda tanda)

- **Fondos propios por jefe (aclara el punto 9):** para el **Jefe actual, el Coloso y el jefe supremo del 15**. El fondo del jefe supremo queda **pendiente** hasta que se diseñe el personaje (T243).

### Tercera tanda de decisiones de Lucas (2026-10-23)

- **Tarjeta «Nuevo enemigo» (reemplaza el punto 6):** **se quita tras la presentación del jefe**: con el cartel del jefe y la animación nueva alcanza. *A aclarar en la spec:* si también se quita para los demás enemigos nuevos (RF-134); hoy la tarjeta sigue para ellos.
- **Arte del piloto viejo:** **se conserva** (`boss_burst.png`, `boss_crack.png`, `boss_card_frame.png`); puede reutilizarse en la presentación nueva. Lo que se reemplaza es el código del piloto, no el arte.
