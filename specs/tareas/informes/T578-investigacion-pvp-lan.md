# T578 · Investigación: PvP en tiempo real por red local

- **Fecha:** 2026-11-02 · **Autor:** Claude (Opus) · **Base:** `main` en `e3ad3d1` (merge del PR #177).
- **Pedido:** D-230. Solo investigar. **No se cambió nada del juego**: ni código, ni datos, ni escenas, ni `export_presets.cfg`.
- **Límite honesto:** **no se probó nada en dos dispositivos.** Nadie en esta ronda tiene un teléfono y no se armó una red entre dos máquinas. Todo lo que diga de latencia, ancho de banda, Wi-Fi o Android es **estimado** o sale de la documentación, salvo donde se marca **[medido]**. La única prueba que se corrió fue la del determinismo del punto 3, en una sola PC y en una copia del proyecto fuera del repositorio.

Convención del informe:

- **[verificado en el código]**: lo leí en `main`, con archivo y línea.
- **[medido]**: lo corrí y doy el número.
- **[documentación]**: lo dice una fuente externa, citada al final con enlace y fecha de consulta.
- **[estimado]**: es mi cálculo o mi criterio; nadie lo midió.

---

## Resumen en cinco líneas

1. El modo que conviene, si alguna vez se hace, es **«enviar enemigos al rival»**: cada uno juega su mapa en su dispositivo y por la red solo viajan **eventos** chicos (empezó, mandé tres Normales, perdí dos vidas, terminé). Es el clásico de los *tower defense* competitivos y **no necesita que la simulación sea idéntica** en los dos aparatos.
2. El **mapa compartido** (los dos en el mismo tablero) es **mucho más caro**: el juego se repite igual en el mismo aparato, pero **con otros FPS o con el ×2 la misma partida termina distinta** (medido con el bot: en Cañadón cambia hasta quién gana, punto 3.6). Hacerlo determinista entre aparatos es rehacer el bucle de la partida.
3. La red en sí es lo fácil: Godot 4.7 trae `ENetMultiplayerPeer` y RPC listos. Lo difícil está **alrededor**: que los dos aparatos se encuentren en el Wi-Fi, los permisos de Android (hoy el APK **no pide `INTERNET`**), el firewall de Windows, la pausa automática al pasar a segundo plano y el ×2.
4. Costo estimado: **carrera en paralelo ≈ 6 tareas**, **enviar enemigos ≈ 10 tareas**, **mapa compartido ≈ 18 tareas o más**, con riesgo alto.
5. **Recomendación: posponer** (el multijugador sigue fuera de la V1, §11). El primer paso más barato es una **prueba de humo de red fuera del repositorio**, en la PC y el teléfono de Lucas, antes de escribir una sola línea de spec.

---

## 1. Modos posibles, de menor a mayor costo

| Modo | Qué ve cada jugador | Qué viaja por la red | ¿Necesita determinismo? | ¿Es divertido para este juego? |
|---|---|---|---|---|
| **A. Carrera en paralelo** | Su propio mapa, el mismo nivel y la misma semilla que el rival. Un marcador chico con las vidas y la oleada del otro. | Inicio, semilla, y cada tanto un resumen (vidas, oleada, puntos). Final. | **No.** Cada uno simula su partida. | **Poco.** Es jugar solo con un marcador al lado. Las decisiones del otro no te afectan. Sirve como «¿quién saca más estrellas?», pero no da la sensación de competir en vivo. |
| **B. Enviar enemigos al rival** | Su propio mapa. Un botón o panel para **mandarle monstruos** al otro, pagando con oro o con lo que se decida. Lo que el otro te manda aparece por tu entrada. | Lo de A, más un evento por cada envío («3 × Normal en la entrada 0»). | **No.** Cada uno es dueño de su tablero. | **Sí, es el que más encaja.** Agrega una decisión nueva (¿gasto en defenderme o en atacar?) sin tocar el núcleo: torres, caminos y oleadas siguen igual. Es el formato de los TD competitivos conocidos (estilo «Bloons TD Battles» o «Legion TD»). |
| **C. Mapa compartido** | Un solo mapa con las torres de los dos (cooperando o compitiendo por oro o por casillas). | O bien **todo el estado** (posición y vida de hasta 200 enemigos, proyectiles) varias veces por segundo, o bien **solo las acciones** con una simulación idéntica en los dos lados (*lockstep*). | **Sí**, si se mandan solo las acciones. Si se manda el estado, no, pero el cliente pasa a ser un «televisor» con retraso. | **Dudoso como competencia:** en un TD de camino fijo los dos defienden el mismo camino, así que es más un cooperativo que un PvP. Y en el celular los dos tendrían que ver y tocar el mismo mapa en pantallas chicas. |

**[estimado]** Mi criterio de diversión es de diseño, no de una prueba con jugadores. Para que B funcione, el envío tiene que ser una decisión con costo: si mandar monstruos es gratis o barato, gana el que manda más; si es caro, nadie manda. Eso se balancea con datos (P2) y con el bot (ver punto 7).

---

## 2. Arquitectura

### Quién manda

- **Para A y B: anfitrión y cliente, cada uno con autoridad sobre su propio tablero.** **[estimado]** El anfitrión (el que crea la partida) es el *peer* 1 de Godot y solo coordina: acepta al otro, compara versiones, sortea la semilla, dice «empiezan» y declara el resultado. Nadie simula el tablero del otro. Un par a par «puro» no aporta nada con dos jugadores, y la API de alto nivel de Godot ya está pensada como servidor más clientes **[documentación: Godot, *High-level multiplayer*]**.
- **Para C, dos caminos:**
  - **Servidor autoritativo con sincronización de estado:** el anfitrión simula todo y le manda al cliente posiciones y vidas. Funciona sin determinismo, pero el cliente ve con retraso y sus acciones (construir, mejorar) tardan un viaje de ida y vuelta.
  - **Lockstep (solo acciones):** los dos simulan lo mismo y solo se mandan las órdenes, con el número de *tick* en que se aplican. Usa poquísima red, pero exige determinismo total (punto 3), que hoy no existe.

### Qué transporte

- **`MultiplayerAPI` + `ENetMultiplayerPeer`** es lo indicado. ENet viene por defecto, usa **solo UDP** y ofrece envío confiable, no confiable y no confiable ordenado, y canales separados **[documentación: Godot, *High-level multiplayer* y `ENetMultiplayerPeer`]**. Los eventos de A y B van como **RPC confiables** (no se puede perder un «te mandé 3 monstruos»).
- **WebSocket** solo hace falta para una exportación web (el navegador no tiene UDP) **[documentación]**. El proyecto no tiene preset web (`export_presets.cfg` trae Windows, Android y Linux) **[verificado en el código]**, así que no aplica.
- Una regla a tener en cuenta: en Godot, los RPC tienen que existir **con la misma firma y en la misma ruta de nodo** en los dos lados **[documentación]**. Eso obliga a que las dos instalaciones tengan **la misma versión del juego** (punto 5).

### Ancho de banda y latencia

| Modo | Ancho de banda | Latencia que tolera |
|---|---|---|
| A | Un resumen por segundo o por oleada, de unas decenas de bytes. **< 1 KB/s.** | Mucha: un marcador con un segundo de retraso no molesta. |
| B | Lo de A más un mensaje por envío (decenas de bytes). **< 1 KB/s.** | Mucha: un monstruo enviado que aparece 100 o 300 ms después no se nota, porque igual tarda en caminar. |
| C con estado | 200 enemigos × (id, posición, vida ≈ 12 a 16 bytes) × 20 envíos por segundo ≈ **50 a 65 KB/s**, más proyectiles y efectos. | Poca: más de ~100 ms se nota al construir y al ver los impactos. |
| C con lockstep | Una orden cada tanto (decenas de bytes). **< 1 KB/s.** | Media: cada orden se agenda con unos *ticks* de margen. Si un aparato se atrasa, **los dos** esperan. |

Todo el cuadro es **[estimado]**: son cuentas de servilleta. **No medí ninguna red real.** En una Wi-Fi hogareña, una latencia de 2 a 20 ms entre dos aparatos es lo habitual, pero en el celular puede haber picos de cientos de ms cuando la radio ahorra energía; eso solo se sabe midiendo en el teléfono de Lucas.

---

## 3. Determinismo

La pregunta es: si los dos aparatos reciben las mismas órdenes, ¿llegan exactamente al mismo resultado? **Hoy, no.** Esto es lo que lo rompe, medido sobre `main`:

### 3.1 Dos relojes distintos

- **Torres, enemigos y proyectiles** avanzan en `_physics_process` (paso fijo de 1/60 s): `scenes/towers/tower.gd:200`, `scenes/enemies/enemy.gd:127`, `scenes/towers/projectile.gd:86` **[verificado en el código]**.
- **La salida de los enemigos** (`WaveSpawner`, `scenes/game/wave_spawner.gd:90-98`), **la cuenta atrás entre oleadas** (`scenes/game/level_session.gd:58-64`), **la demolición** (`scenes/game/infrastructure_controller.gd:63`) y la capa de obstáculos (`scenes/levels/obstacle_layer.gd:51`) avanzan en `_process`, con el `delta` **del cuadro dibujado**, que depende de los FPS del aparato **[verificado en el código]**.
- Consecuencia: un enemigo sale en el primer cuadro en que el reloj pasa su hora. A 60 FPS ese cuadro cae en otro momento que a 30 o a 144 FPS, así que **la oleada puede salir con otros espacios** según el aparato. La prueba del punto 3.6 muestra que, con otros FPS, la partida termina distinta (aunque no separa cuánto se debe a esto y cuánto al bot).

### 3.2 La velocidad ×2

- `game.gd:791-800` cambia `Engine.time_scale` (×1 o ×2) **[verificado en el código]**. La documentación de Godot dice que eso escala el `delta`, **no** cambia la cantidad de pasos de física por segundo, y que «por encima de 1.0 la simulación de física puede volverse menos precisa» **[documentación: `Engine`]**. O sea: la misma partida a ×1 y a ×2 no da el mismo resultado paso a paso.

### 3.3 Aparatos lentos

- Si un teléfono no llega a dibujar a la velocidad de la física, Godot limita los pasos por cuadro (`max_physics_steps_per_frame`) y **el juego entero se ralentiza**, «aunque se use `delta`» **[documentación: `Engine`]**. Para el modo B esto es importante **aunque no haya lockstep**: el jugador con el teléfono lento ve sus oleadas más despacio en tiempo real. Para una carrera, eso es injusto.
- `project.godot` no fija `physics_jitter_fix`, así que usa el valor por defecto; la documentación recomienda ponerlo en 0 para juegos en red **[verificado en el código + documentación]**.

### 3.4 Sorteos (RF-417 y otros)

| Sorteo | Dónde | Semilla hoy | ¿Afecta la partida? |
|---|---|---|---|
| Drop de recursos de los removibles (RF-417) | `game.gd:263-268` → `scripts/logic/obstacle_field.gd:52` | `GameFlow.forced_seed` si existe; si no, al azar | Sí |
| Grupos con probabilidad de una oleada (RF-364) | `wave_spawner.gd:47` y `:58` | **Siempre al azar** (`rng.randomize()`) | Sí: cambia **qué** monstruos salen |
| Qué monstruo lleva la pieza de Tecnología | `game.gd:1327-1330` → `scripts/logic/collectible_run.gd:26` | Siempre al azar | No en la batalla (solo la pieza) |
| Temblor de pantalla | `game.gd:541`, `randf_range` global | Global | No (es visual) |
| Fase de la animación del enemigo | `enemy.gd:124`, `randf()` global | Global | No (es visual) |

**[verificado en el código]** El bot de balance **ya demuestra que todo se puede fijar con una semilla**: `tools/balance_sim.gd:260-266` fija la global y `GameFlow.forced_seed`, y `:421-424` le pisa la semilla al `WaveSpawner`. Para A y B alcanza con que el anfitrión mande una semilla y los dos la usen así (para que el mismo nivel salga igual en los dos lados). No hace falta más.

### 3.5 Flotantes y orden de recorrido

- Posiciones y distancias son `Vector2` (flotantes de 32 bits) con `distance_to`, `move_toward`, `lerp_angle` y trigonometría (`tower.gd:391`, `projectile.gd:94-105`, `enemy.gd:469`) **[verificado en el código]**.
- La elección de objetivo recorre `get_tree().get_nodes_in_group(Enemy.GROUP)` (`tower.gd:248`, `:317`; `projectile.gd:126`) y desempata por distancia (`tower.gd:327-335`) **[verificado en el código]**. El orden del grupo depende del orden en que se agregaron los nodos.
- **[estimado]** Entre una PC x86 y un teléfono ARM, las funciones trigonométricas y algunas operaciones de flotantes pueden diferir en el último bit. En una simulación de 10 minutos, un bit distinto alcanza para que una torre elija otro objetivo y la partida se separe. **No lo medí entre arquitecturas** (no hay teléfono).

### 3.6 Prueba de determinismo [medido]

**Dónde y cómo.** En la PC Linux de Lucas (Godot 4.7.2), sobre una **copia** del proyecto sacada con `git archive` de `e3ad3d1` a la carpeta temporal de la sesión, **fuera del repositorio** (el worktree no tenía `.godot/` e importar ahí podía reescribir los SVG). Se usó el bot de balance tal cual, con la semilla fija `12345` y la estrategia `mix`, cambiando solo `--fixed-fps` (cuántas veces por segundo se dibuja y corre `_process`; la física sigue a 60 pasos por segundo). Para el ×2 se hizo, **solo en la copia**, `tools/balance_sim_x2.gd`: el mismo bot con `Engine.time_scale = 2` mientras dura la partida. Ese archivo no existe en el repositorio.

**Repetibilidad (control).** Misma máquina, mismos FPS, misma semilla → **mismo resultado, oleada por oleada**: nivel 3 a 60 FPS dos veces (16 vidas las dos) y nivel 7 a 60 FPS dos veces (12 vidas y 284 de oro robado las dos). El envoltorio del ×2 corriendo a ×1 también dio idéntico al bot original. O sea: **en una sola máquina la partida es repetible.**

**Cambiando los FPS (misma semilla):**

| Nivel | 60 FPS | 30 FPS | 144 FPS |
|---|---|---|---|
| 3 · (resumen por oleada) | Victoria, 16 vidas | **Idéntico** | **Idéntico** |
| 6 · Nido | Victoria, 9 vidas | Victoria, 10 | Victoria, 10 |
| 7 · Cruce | Victoria, 12 vidas | Victoria, 9 | Victoria, 8 |
| 8 · Bastión | Victoria, 14 vidas | Victoria, **20** | Victoria, 18 |
| 9 · Taller asediado | Victoria, 11 vidas | Victoria, 12 | Victoria, 9 |
| 10 · La mina vieja | Victoria, 7 vidas | Victoria, 9 | Victoria, 9 |
| 11 · Puesto seco | Derrota en la oleada 20 | Derrota en la 20 | Derrota en la **14** |
| 12 · Cañadón | **Victoria**, 4 vidas | **Derrota** en la 23 | **Victoria**, 2 vidas |
| 13 · Paso alto | Derrota en la 14 | Derrota en la 14 | Derrota en la 14 |
| 14 · Poblados | (cortado por tiempo) | Derrota en la 26 | Derrota en la 26 |
| 15 · Central | (cortado por tiempo) | Derrota en la 30 | Derrota en la 28 |

(La corrida de 60 FPS de los niveles 6 a 15 se cortó por el límite de tiempo de 580 s en el nivel 14; las de 30 y 144 FPS tenían 900 s.)

**Cambiando solo el ×2 (nivel 3, 60 FPS):** a ×1 termina con **16 vidas**; a ×2, con **17**, y el oro difiere desde la oleada 7. Repetido dos veces a ×2: idéntico entre sí.

**Qué significa:**

- **En el mismo aparato, la partida se repite.** Eso alcanza para los modos A y B (cada uno es dueño de su tablero).
- **Con otra cadencia de cuadros o con el ×2, la partida es otra**: de los 11 niveles comparados, en 8 cambian las vidas o la oleada de la derrota (solo el 3, el 13 y el 14 dieron igual), y en uno (Cañadón) cambia **quién gana**. Dos aparatos reales no dibujan nunca al mismo ritmo, así que **un *lockstep* que solo mande las acciones se separaría** casi seguro, incluso entre dos PC iguales.
- **Límite de la prueba:** el bot también decide en `_process` (`tools/balance_sim.gd:429`), una vez por cuadro. Con otros FPS, el bot construye en otros momentos, y eso por sí solo ya cambia la partida. **No separé** cuánto de la diferencia es del bot y cuánto de los relojes del juego (punto 3.1). Para el lockstep da igual: las órdenes de un jugador humano tampoco llegan en el mismo cuadro, y los relojes en `_process` del juego siguen ahí. Tampoco medí x86 contra ARM.
- Por qué el nivel 3 no cambió y los demás sí **[estimado]**: los enemigos solo avanzan en los pasos de física, así que una salida «tarde» por los FPS se redondea al paso siguiente; en un nivel simple eso no alcanza a cambiar nada visible en el resumen. En los niveles con más tipos de enemigos, ladrones, removibles y más torres, las pequeñas diferencias se amplifican.

### 3.7 ¿Qué tan viable es sincronizar solo las acciones?

- **Para A y B: no hace falta.** Cada uno simula su tablero; las acciones del rival no se re-simulan, solo llegan sus efectos (un envío de monstruos, un marcador).
- **Para C con lockstep: hoy no es viable.** Habría que (1) pasar todo el bucle de la partida a un *tick* fijo propio, independiente de los FPS y del `time_scale` (el ×2 se haría corriendo dos *ticks* por paso, no cambiando el `delta`); (2) sembrar todos los sorteos; (3) fijar el orden de recorrido de enemigos (por un id creciente, no por el árbol); y (4) probar que PC y teléfono no se separan, idealmente con números de punto fijo en lo que decide el juego. Eso toca `tower.gd`, `enemy.gd`, `projectile.gd`, `wave_spawner.gd`, `level_session.gd`, `infrastructure_controller.gd` y `game.gd`, y pone en riesgo los ~1000 tests y el balance del bot.

---

## 4. Red local en la práctica

### Cómo se encuentran dos dispositivos

| Opción | Cómo funciona | Pros | Contras |
|---|---|---|---|
| **Difusión UDP** (*broadcast*) | El anfitrión grita «estoy acá» cada segundo a `255.255.255.255`; el otro lo escucha y lo muestra en una lista. Godot lo hace con `PacketPeerUDP.set_broadcast_enabled(true)`. | Cero escritura para el jugador. | **En Android puede no llegar:** la documentación de Godot dice que «algunos dispositivos Android pueden requerir el permiso `CHANGE_WIFI_MULTICAST_STATE`» para recibir difusiones **[documentación: `PacketPeerUDP`]**. Android filtra esos paquetes salvo que la app tome un *MulticastLock*, que además gasta batería **[documentación: Android `WifiManager.MulticastLock`]**. **No encontré** una forma de tomar ese *lock* desde GDScript sin un *plugin* de Android **[estimado, no verificado]**. Varias redes (de invitados, públicas) bloquean las difusiones. |
| **Código corto** | El anfitrión muestra su IP local codificada en 4 a 6 letras o números; el otro la escribe. | Funciona siempre que haya ruta entre los dos. No necesita permisos extra. | Hay que escribir. |
| **QR** | El anfitrión muestra un QR con IP y puerto; el otro lo escanea. | Rápido entre teléfonos. | Exige cámara, permiso `CAMERA` y una librería o *plugin* para leer QR. En la PC no hay cámara casi nunca. |

**[estimado]** Lo práctico: **difusión como primer intento y código corto como respaldo siempre visible.** El QR no compensa su costo.

### Permisos de Android

- **[verificado en el código]** El preset Android de `export_presets.cfg` (sección `[preset.1.options]`) **no tiene ninguna línea `permissions/…`**, así que el APK de release **no pide `INTERNET`**. La documentación de Godot avisa que sin ese permiso Android **bloquea toda comunicación de red** **[documentación: *High-level multiplayer* y `PacketPeerUDP`]**.
- Habría que agregar `INTERNET` y, para la difusión, `CHANGE_WIFI_MULTICAST_STATE` (y probablemente `ACCESS_WIFI_STATE` / `ACCESS_NETWORK_STATE` para saber la IP local) **[estimado]**. Son permisos «normales» (no se le preguntan al usuario), pero **cambian lo que muestra la tienda** del APK. Eso es una decisión de Lucas.

### Wi-Fi con aislamiento de clientes

- Muchos routers de invitados, de bares o de facultades tienen **aislamiento de clientes**: dos aparatos en la misma red no se pueden ver. **[estimado]** Ahí ni la difusión ni el código sirven. La salida es que uno de los dos **comparta datos como punto de acceso** (*hotspot*) y el otro se conecte a él. Habría que decirlo en un cartel de ayuda.

### Firewall de Windows

- **[estimado]** La primera vez que el juego abre un puerto para escuchar (cuando la PC es anfitriona), Windows muestra el aviso del firewall. Si el jugador elige «Cancelar», o si la red está marcada como «Pública», el teléfono no llega. Si la PC es **cliente**, en general no hay aviso porque las conexiones salientes están permitidas. Conviene que, en una partida PC contra teléfono, la ayuda sugiera que el **teléfono** sea el anfitrión o explique el aviso.

### PC contra teléfono

- Para A y B **no cambia nada de la arquitectura**: cada uno simula lo suyo. Lo distinto es la interfaz (la del celular, `mobile_hud.gd`, y la de la PC, `hud.gd`) y la velocidad del aparato (punto 3.3). Para C con lockstep, PC contra teléfono es **el peor caso** (x86 contra ARM).

---

## 5. Reglas de la partida

Propuesta para A y B **[estimado: son reglas de diseño, no probadas]**:

| Situación | Hoy en el juego | Regla propuesta para PvP |
|---|---|---|
| **Pausa** | `game.gd:776-789` pausa el árbol entero (RF-104). | **No hay pausa.** El menú se abre sin congelar la partida, o se permite una pausa corta acordada (por ejemplo 2 por jugador, de hasta 30 s, que pausa a los dos). |
| **×2** | `game.gd:791-800` cambia `Engine.time_scale`. | **Desactivado.** Los dos juegan a ×1 en tiempo real; si uno acelera, llega antes a las oleadas y el envío pierde sentido. |
| **Salir del juego** | Confirmación de salida (`game.gd:738-770`). | Salir **es rendirse**: gana el otro. El cartel lo dice. |
| **Desconexión** | No existe. | Se avisa en pantalla; el que quedó sigue jugando. Si el otro **no vuelve en 30 s**, gana el que quedó. |
| **Reconexión** | No existe. | En B se puede: el estado de cada tablero es local, solo hay que volver a enganchar la sesión y reenviar el marcador. Los envíos hechos durante el corte se pierden o se encolan (decisión de diseño). |
| **Segundo plano en Android** | `game.gd:547-563` pausa la partida al recibir `NOTIFICATION_APPLICATION_PAUSED` o, en móvil, `FOCUS_OUT` (RF-544). | En PvP no se puede pausar. **[estimado]** Android además puede cortar la red de una app en segundo plano. Lo más simple: **pasar a segundo plano cuenta como desconexión**, con los mismos 30 s de gracia. |
| **Versiones distintas** | `project.godot` tiene `config/version="beta"` y el APK `version/code=3` **[verificado en el código]**: no alcanzan para distinguir dos compilaciones. | Al conectar se comparan **una versión de protocolo** y **una huella** (hash) de los datos que deciden la partida (`data/towers`, `data/enemies`, el nivel elegido). Si no coinciden, no se juega y se dice cuál actualizar. |
| **Mapas de la comunidad** | `GameFlow.start_community` (`game_flow.gd:337`) y `LevelFile.load_level` (`scripts/logic/level_file.gd:37`). | Primera versión: **solo mapas de la campaña.** Después, el anfitrión puede mandar el JSON del mapa y su huella; el otro lo valida con `LevelFile` antes de aceptar. |

---

## 6. Qué sirve y qué hay que cambiar del código (medido sobre `main`)

### Lo que ya sirve

| Pieza | Por qué sirve |
|---|---|
| `scenes/game/level_session.gd` (205 líneas) | Ya es un **estado puro con señales** (`gold_changed`, `lives_changed`, `wave_changed`, `state_changed`). Para el marcador del rival alcanza con escuchar esas señales y mandar un resumen. |
| `WaveSpawner.spawn_now(data)` (`wave_spawner.gd:85-87`) | Ya hace aparecer un enemigo cuando se lo piden (lo usa el modo de pruebas, `game.gd:956-957`). Es **la base del envío de monstruos** del modo B: falta elegir la entrada y que sume a la oleada en curso. |
| `BuildController.try_build`, `try_upgrade`, `sell` y `InfrastructureController.order`, `enable`, `buy_machine` | Las acciones del jugador ya son **órdenes discretas** con parámetros simples (torre, casilla, forma de pago). Para C con lockstep serían los «comandos» a enviar. |
| Semillas de `tools/balance_sim.gd:260-266` y `:421-424` | Muestran cómo fijar todo el azar de una partida. |
| El bot de balance | Se puede extender para simular «dos jugadores que se mandan monstruos» y balancear el costo del envío sin red. |

### Lo que habría que cambiar o agregar (modo B)

| Archivo | Cambio | Tamaño **[estimado]** |
|---|---|---|
| **Nuevo** `scripts/autoload/net_match.gd` (o un nodo de la partida) | Crear o unirse a la sesión ENet, apretón de manos con versión y huella, semilla, inicio, marcador, envíos, fin, desconexión. | Grande |
| **Nuevo** `scenes/ui/lan_lobby.*` | Pantalla para crear o buscar partida, lista por difusión y campo de código. | Mediano |
| `scripts/autoload/game_flow.gd` (531 líneas) | Un `start_pvp(level, seed)` como los de la comunidad y los modos, y el resultado al terminar. | Chico |
| `scenes/game/game.gd` (1441 líneas) | Rama PvP: sin pausa ni ×2 (`:776-800`), segundo plano como desconexión (`:547-563`), salir es rendirse (`:738-770`), semilla del anfitrión (`:263-268`, `:1317-1330`), conectar envíos recibidos a `spawner`. | Mediano, y riesgoso porque es el archivo central |
| `scenes/game/wave_spawner.gd` | Aceptar una semilla de afuera (hoy `setup` hace `rng.randomize()` en `:47`) y monstruos «extra» que cuentan para terminar la oleada. | Chico |
| `scenes/game/hud.gd` y `scenes/game/mobile_hud.gd` | Marcador del rival y panel de envío. `mobile_hud.gd` (1367 líneas) está en plena reforma por M89 (rieles, T566 a T570): tocarlo ahora chocaría. | Mediano |
| `export_presets.cfg` (preset Android) | `permissions/internet=true` y, si hay difusión, `permissions/change_wifi_multicast_state=true`. | Chico, pero lo decide Lucas |
| `data/` | Costos del envío, qué monstruos se pueden mandar, cooldowns (P2). | Chico |
| Tests | Lo de red no se prueba en GUT de punta a punta; se prueba la lógica (marcador, reglas de desconexión, validación de versión) como funciones puras, y la conexión con dos instancias locales. | Mediano |

### Lo que habría que cambiar (modo C con lockstep), además

`tower.gd` (615 líneas), `enemy.gd` (722), `projectile.gd`, `wave_spawner.gd`, `level_session.gd`, `infrastructure_controller.gd` y `game.gd` pasan a un *tick* fijo propio; el ×2 se reescribe; todos los sorteos se siembran; el orden de enemigos se fija por id. **[estimado]** Es una refactorización del corazón del juego.

---

## 7. Costo

**[estimado]** Las tareas son del tamaño habitual del proyecto (P8: una sesión cada una).

### Modo A · Carrera en paralelo ≈ 6 tareas

| Tarea | Ejecutor | Riesgo |
|---|---|---|
| 📜 Spec y decisión del modo (RF, D, reglas del punto 5) | Opus, alto | Bajo |
| Sesión ENet + apretón de manos con versión y semilla | Sonnet, alto | Medio |
| Sala: crear, buscar por difusión y unirse por código | Sonnet, alto | **Alto en Android** (difusión) |
| Reglas en `game.gd` (sin pausa ni ×2, segundo plano, salir, desconexión) | Sonnet, alto | Medio |
| Marcador del rival en `hud.gd` y `mobile_hud.gd` | Sonnet, medio | Bajo, si se hace **después** de M89 |
| Permisos Android y prueba en dos aparatos | Sonnet, medio + **Lucas** con dos dispositivos | Medio |

### Modo B · Enviar enemigos ≈ A + 4 = 10 tareas

| Tarea extra | Ejecutor | Riesgo |
|---|---|---|
| 📜 Economía del envío (qué, cuánto cuesta, límites) | Opus, alto | Medio |
| Envío y recepción (`spawn_now` en la oleada en curso) | Sonnet, alto | Medio |
| Panel de envío en PC y celular | Sonnet, medio | Medio (espacio en pantalla) |
| Bot de dos jugadores para balancear | Sonnet, alto | **Alto** (balance) |

### Modo C · Mapa compartido ≈ 18 tareas o más

B entero, más: *tick* fijo propio en todo el bucle (3 a 4 tareas, Opus), sorteos y orden de enemigos (1 a 2), prueba de igualdad PC contra teléfono con suma de verificación por *tick* (2), interfaz de dos jugadores en un mapa (2 a 3). **Riesgo alto**: puede cambiar el balance de los 15 niveles y obliga a revisar muchos tests.

### Qué rompería de la V1 actual

- **A y B, bien aislados como un modo nuevo detrás de un botón del menú:** nada de la campaña debería cambiar. Lo que sí cambia para todos: los **permisos del APK** (un juego sin red pasa a pedir `INTERNET`) y más ramas en `game.gd`. Un error en esas ramas podría afectar la pausa o el ×2 de la campaña; eso se cuida con tests.
- **Con M89 en curso:** tocar `game.gd`, `hud.gd` y `mobile_hud.gd` ahora pisaría T566, T567, T570 y T573. **No se debería empezar antes de cerrar M89.**
- **C:** toca la simulación entera; rompería el balance medido de los 15 niveles hasta re-medirlo.

---

## 8. Parte 2 y versión 3D

- **[estimado]** Si el PvP es algo que Lucas quiere para el futuro, **lo que más conviene guardar para la 3D (o para una parte 2) es la decisión de arquitectura**: diseñar la simulación **desde el primer día** con un *tick* fijo propio, separada del dibujo, con sorteos sembrados y sin depender de `Engine.time_scale`. Hacerlo así desde el principio cuesta poco; agregarlo después, como muestra el punto 6, es caro. Eso es lo que haría posible el modo C en la 3D.
- El **modo B**, en cambio, no depende de esa arquitectura y **se podría hacer en esta versión 2D** después de publicar la V1, como contenido de una parte 2. La parte de red (sala, permisos, apretón de manos) se reutilizaría casi igual en la 3D si también es Godot.
- Recomiendo **no** hacer el modo C en la 2D.

---

## 9. Recomendación

**Posponer.** No hacerlo en la V1: está excluido en §11 y en D-230, M89 está tocando los mismos archivos y nadie probó todavía la red en el teléfono de Lucas.

Si Lucas quiere seguir, el orden más barato es:

1. **Prueba de humo de red, fuera del repositorio** (1 tarea, Sonnet medio, más ~20 minutos de Lucas): un proyecto Godot 4.7 mínimo de una escena, con un botón «Crear», otro «Buscar» y un campo de código. Usa `ENetMultiplayerPeer` y una difusión con `PacketPeerUDP`, manda un *ping* por segundo y muestra la latencia. Se exporta a la PC y a un APK con `INTERNET` y `CHANGE_WIFI_MULTICAST_STATE`. Lucas la prueba **teléfono↔PC** y, si consigue otro, **teléfono↔teléfono**, en su Wi-Fi y en un *hotspot*. Contesta con números lo que este informe solo estima: ¿se encuentran por difusión?, ¿salta el firewall?, ¿qué latencia hay?, ¿se corta al pasar a segundo plano?
2. Con esos números, **Lucas decide** si quiere el modo B para una parte 2. Si sí, recién ahí va una tarea 📜 (Opus) con la spec y las decisiones, después del cierre de M89 y de la V1.
3. En paralelo y gratis: anotar en el documento de la 3D (`specs/06-monsters-canons-3d.md`) que la simulación nazca con *tick* fijo y sorteos sembrados. Eso lo decide Lucas; este informe no lo escribe.

---

## Fuentes

Todas consultadas el **2026-11-02**.

- Godot Engine 4.7, *High-level multiplayer*: <https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html> (ENet por defecto, WebSocket y WebRTC; solo UDP; permiso `INTERNET` en Android; reglas de RPC iguales en los dos lados; modos de envío y canales).
- Godot Engine 4.7, clase `ENetMultiplayerPeer`: <https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html> (firmas de `create_server` y `create_client`; solo UDP).
- Godot Engine 4.7, clase `PacketPeerUDP`: <https://docs.godotengine.org/en/stable/classes/class_packetpeerudp.html> (`set_broadcast_enabled`; en Android «algunos dispositivos pueden requerir el permiso `CHANGE_WIFI_MULTICAST_STATE`»).
- Godot Engine 4.7, clase `Engine`: <https://docs.godotengine.org/en/stable/classes/class_engine.html> (`time_scale` escala el `delta` pero no los pasos de física y vuelve menos precisa la simulación por encima de 1.0; `max_physics_steps_per_frame` ralentiza el juego en aparatos lentos; `physics_jitter_fix` en 0 recomendado para juegos en red).
- Android Developers, `WifiManager.MulticastLock`: <https://developer.android.com/reference/android/net/wifi/WifiManager.MulticastLock> (el Wi-Fi filtra los paquetes no dirigidos al aparato; el *lock* los deja pasar y gasta batería).
- Godot Asset Library, *Network Broadcast Discovery Godot Example*: <https://godotengine.org/asset-library/asset/5533> (ejemplo comunitario de descubrimiento por difusión; **no revisé** si resuelve el *MulticastLock* de Android).

## Qué se verificó y qué no

- **Verificado:** todo lo marcado con archivo y línea, leído en `main` (`e3ad3d1`). La prueba de determinismo del punto 3.6, en una PC Linux y en una copia del proyecto fuera del repositorio: 2 controles de repetibilidad, 3 cadencias (30, 60 y 144 FPS) sobre los niveles 3 y 6 a 15, y ×1 contra ×2 en el nivel 3. Ninguna corrida imprimió `SCRIPT ERROR`.
- **No se corrieron los tests de GUT:** no se tocó código, datos ni escenas; el diff es solo documental.
- **No verificado:** cualquier cosa de red real (latencia, ancho de banda, difusión, firewall, aislamiento de clientes), cualquier cosa en Android, el determinismo entre x86 y ARM, la diversión de los modos. Todo eso está marcado como **[estimado]** o **[documentación]**.
