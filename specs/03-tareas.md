# 03 — Tareas

> **Qué es este documento:** la lista ordenada de pasos para construir el juego. **Se hacen de arriba a abajo, una a la vez.**
>
> **Cómo se lee cada tarea:**
> - `[ ]` pendiente · `[x]` hecha
> - **Refs:** qué partes de la spec (`RF-xx`) o del plan (`§x`) implementa.
> - **Hecho cuando:** el **criterio de aceptación**. Si no se cumple exactamente, la tarea **no** está hecha.
>
> **Regla (constitución P1):** al terminar cada tarea el juego abre y funciona. Después de cada tarea terminada, se hace un *commit* en git.

---

## M0 — Preparación

- [x] **T00 · Instalar herramientas**
  Instalar Godot 4 (versión estándar, no .NET) y Git. Agregar la carpeta de Godot al `PATH` y crear `godot.cmd` junto a los ejecutables (no renombrar el `_console.exe`: deja de funcionar).
  **Hecho cuando:** en una terminal nueva, `godot --version` y `git --version` muestran sus versiones. La versión de Godot queda anotada en el README.

- [x] **T01 · Crear el proyecto Godot**
  Crear el proyecto en esta carpeta (renderizador *Compatibility* o *Forward+*, cualquiera sirve para 2D). Aplicar la configuración de §2 (resolución, estiramiento, filtro, nombres de capas 2D).
  **Refs:** plan §2.
  **Hecho cuando:** F5 abre una ventana gris de 1280×720 y, al agrandarla, el contenido se escala sin deformarse.

- [x] **T02 · Carpetas, git y `.gitignore`**
  Crear la estructura de carpetas de §3 (vacías). Crear el `.gitignore` de Godot (ignora `.godot/`). `git init` y primer commit.
  **Refs:** plan §3.
  **Hecho cuando:** `git status` no muestra la carpeta `.godot/` y existe un commit inicial.

- [x] **T03 · Instalar GUT y un test de prueba**
  Instalar GUT desde la AssetLib. Crear `tests/test_sanity.gd` con un test que compruebe `1 + 1 == 2`.
  **Refs:** plan §8, constitución P10.
  **Hecho cuando:** el test pasa, tanto desde el panel de GUT como desde la consola (comando de §8).

- [x] **T04 · Mapa de entrada**
  Crear las acciones del Input Map (§2) con sus teclas (spec §9.2).
  **Hecho cuando:** las acciones aparecen en *Proyecto → Configuración → Mapa de entrada* con sus teclas.

---

## M1 — Núcleo jugable (MVP)

> Objetivo: 1 mapa, 3 torres, 3 enemigos, 10 oleadas, ganar y perder.

### Fundaciones

- [x] **T10 · Clases de datos y `rules.gd`**
  Crear todos los scripts de `scripts/data/` (§4.1) y `scripts/logic/rules.gd` (§4.2, §4.3).
  Crear `data/balance.tres` con los valores de la spec.
  **Refs:** RF-22, RF-36, RF-72, RF-80; plan §4.
  **Hecho cuando:** `tests/test_rules.gd` pasa con, al menos, los ejemplos de la spec:
  `damage_after_armor(5, 4) == 1`, `damage_after_armor(40, 4) == 36`, `scaled_health(20, 10, cfg) == 34`, `wave_bonus(3, cfg) == 35`, `sell_refund(110, cfg) == 77` (con `cfg` = `data/balance.tres`).

- [x] **T11 · Datos de enemigos y torres del M1**
  Crear `data/enemies/normal.tres`, `fast.tres`, `tank.tres` y `data/towers/basic.tres`, `cannon.tres`, `frost.tres` (solo nivel 1 de cada torre por ahora) con los valores de las tablas de la spec.
  **Refs:** spec §5.3, §6.
  **Hecho cuando:** `tests/test_data_files.gd` pasa (compara cada `.tres` con las tablas de la spec).

### El mapa

- [x] **T12 · TileSet y mapa del nivel 1**
  Crear un `TileSet` de 64×64 con 3 casillas de colores (verde = libre, beige = camino, gris = bloqueada) y la capa de datos `buildable`. Crear `scenes/levels/level_01.tscn` con un `TileMapLayer` de 20×9 y un camino en forma de "S".
  **Refs:** RF-01, RF-02; plan §6.1.
  **Hecho cuando:** al ejecutar la escena se ve el mapa completo, sin huecos, con el camino desde un borde hasta otro.

- [x] **T13 · Camino `Path2D` y test de coincidencia**
  Agregar `GroundPath0` (`Path2D`) siguiendo el centro de las casillas del camino. Crear `level.gd` con `is_buildable(cell)`. Crear `tests/test_level_paths.gd`.
  **Refs:** RF-03, RF-04; plan §6.1.
  **Hecho cuando:** el test pasa. Y si se mueve a propósito un punto del `Path2D` al pasto, el test falla.

### Enemigos

- [x] **T14 · Escena `game.tscn` + un enemigo que camina**
  Crear `game.tscn` con el árbol de §5.1 (los nodos que aún no se usan pueden quedar vacíos). Crear `enemy.tscn`/`enemy.gd`: se dibuja según su forma y color, y recorre el camino. (Se hizo junto con T15–T17, así que el enemigo sale directamente de la oleada 1.)
  **Refs:** RF-04; plan §5.1, §6.2.
  **Hecho cuando:** al pulsar F5, un círculo gris recorre el camino de principio a fin a 1.5 casillas/s (≈ 96 px/s) y desaparece al llegar a la salida.

- [x] **T15 · Sesión: vidas y oro + HUD mínimo**
  Crear `level_session.gd` (oro, vidas, señales). Crear `hud.tscn` con la barra superior (oro, vidas). Conectar `reached_exit` → `lose_lives`.
  **Refs:** RF-10, RF-11, RF-20, RF-100; plan §5.2, §5.3.
  **Hecho cuando:** el HUD muestra "Oro 150 · Vidas 20"; cuando el enemigo de prueba llega a la salida, pasa a "Vidas 19".

### Oleadas

- [x] **T16 · `WaveSpawner` y botón "Empezar oleada"**
  Implementar el spawner (§6.5) y el botón (y la tecla `Espacio`). Crear `data/levels/level_01.tres` con **solo las oleadas 1 y 2** de la spec. Quitar el enemigo temporal de T14.
  **Refs:** RF-30 a RF-35; plan §5.4, §6.5.
  **Hecho cuando:** no sale ningún enemigo hasta pulsar el botón; salen 8 Normales separados 1 s; al terminar la oleada se suma el bono (+25), empieza la cuenta atrás de 15 s y luego sale la oleada 2 sola. El HUD muestra "Oleada 1/2", "Oleada 2/2".

- [x] **T17 · Vida creciente por oleada**
  Aplicar `Rules.scaled_health` al crear cada enemigo.
  **Refs:** RF-36.
  **Hecho cuando:** (con un `print` temporal o el depurador) un Normal de la oleada 2 tiene 21 de vida.

### Torres

- [x] **T18 · Construir torres**
  Crear `tower.tscn` (solo se dibuja; todavía no dispara) y `build_controller.gd`: botones de torre en el HUD inferior + teclas 1–3, vista previa verde/roja con círculo de alcance, construir con clic izquierdo, cancelar con clic derecho/Esc.
  **Refs:** RF-40 a RF-44, RF-101, RF-23; plan §6.6.
  **Hecho cuando:** se cumple el criterio de RF-42 de la spec; no se puede construir dos torres en la misma casilla; el oro baja al construir; los botones se ven grises si no alcanza el oro.

- [x] **T19 · Disparar: Ametralladora**
  Detección con `RangeArea` y capas (§6.3), modo "Primero", cadencia, `projectile.tscn`, daño, muerte del enemigo y recompensa.
  **Refs:** RF-50 a RF-52, RF-80, RF-81, RF-21; plan §6.3, §6.4.
  **Hecho cuando:** una Ametralladora junto al camino mata a los Normales de la oleada 1; cada muerte suma 5 de oro; siempre dispara al enemigo más adelantado; no hay errores en la consola si el objetivo muere mientras el proyectil vuela.

- [x] **T20 · Barra de vida de los enemigos**
  **Refs:** RF-82.
  **Hecho cuando:** los enemigos sin daño no muestran barra; al recibir el primer golpe aparece y baja proporcionalmente.

- [x] **T21 · Cañón (daño en área)**
  **Refs:** spec §5.3 (Cañón), plan §6.4.
  **Hecho cuando:** un disparo del Cañón sobre un grupo apretado daña a todos los enemigos a 1 casilla o menos del impacto, y a ninguno más lejos.

- [x] **T22 · Hielo (ralentización)**
  **Refs:** RF-60 a RF-62.
  **Hecho cuando:** los enemigos golpeados se ven azules y van al 60 % de su velocidad durante 2 s; dos torres de Hielo juntas **no** los frenan más que una.

### Cerrar el nivel

- [x] **T23 · Las 10 oleadas del nivel 1**
  Completar `level_01.tres` con la tabla de oleadas de la spec §7.
  **Refs:** spec §7.
  **Hecho cuando:** el HUD muestra "Oleada x/10" y las 10 oleadas salen con los enemigos correctos.

- [x] **T24 · Victoria, derrota y reintentar**
  Pantallas simples de "¡Victoria!" y "Derrota" con botón **Reintentar** (recarga la escena).
  **Refs:** RF-12, RF-90, RF-91, RF-92.
  **Hecho cuando:** sin construir nada, se pierde en la oleada 2–3 y aparece "Derrota"; al reintentar todo vuelve a 150 de oro, 20 vidas, sin torres. Ganando las 10 oleadas aparece "¡Victoria!".

- [x] **T25 · Primera partida de prueba y ajuste de balance**
  Jugar el nivel completo al menos 3 veces. Ajustar números **en los `.tres` y en la spec a la vez**.
  **Hecho cuando:** el nivel se puede ganar con una estrategia razonable pero no sin pensar, y la spec refleja los números finales.
  **Estado:** ✅ revisado con el bot (`tools/balance_sim.gd`, spec §7.1) y confirmado jugando por Lucas ("bien, justa").

> 🎉 **Fin de M1: ya tienes un tower defense jugable.** Buen momento para mostrárselo a alguien.

---

## M1.5 — Pulido visual *(adelantado, D-016)*

> Objetivo: que el juego dé gusto mirar, sin cambiar ninguna regla (spec §9.3). Cada tarea se comprueba con una captura de pantalla y con los tests existentes, que deben seguir pasando sin cambios en sus valores.

- [x] **T50 · Capa de efectos, muerte y oro flotante**
  Nodo `Effects` en la partida para efectos que sobreviven al enemigo (que ya se borró). Estallido de partículas y "+N" dorado.
  **Refs:** RF-124.
  **Hecho cuando:** al morir un enemigo se ven sus partículas y el "+N" con el oro que dio; al escapar un enemigo **no** aparece nada.

- [x] **T51 · Torres que apuntan, retroceso y destello**
  **Refs:** RF-120, RF-121.
  **Hecho cuando:** el cañón de cada torre sigue a su objetivo y retrocede con destello en cada disparo.

- [x] **T52 · Impactos por tipo de torre y parpadeo al golpear**
  **Refs:** RF-122, RF-123.
  **Hecho cuando:** cada torre tiene su impacto distinto; la onda del Cañón llega exactamente hasta su radio de área; los enemigos parpadean en blanco al recibir daño.

- [x] **T53 · Enemigos con movimiento**
  **Refs:** RF-125.
  **Hecho cuando:** los enemigos se bambolean y los triángulos apuntan hacia donde caminan, también al doblar las esquinas.

- [x] **T54 · Mapa más vistoso y sombras**
  Nueva imagen de casillas (sigue generada por código, sin dibujos externos).
  **Refs:** RF-126.
  **Hecho cuando:** el pasto no se ve como una cuadrícula repetida; el camino tiene bordes; torres y enemigos tienen sombra; `test_level_paths.gd` sigue pasando.

- [x] **T55 · Avisos de interfaz: oleada, vidas, oro y construcción**
  **Refs:** RF-127 a RF-130.
  **Hecho cuando:** aparece el cartel de oleada; perder vidas sacude la pantalla y hace parpadear las vidas; el oro hace "pop"; las torres aparecen creciendo.

- [x] **T56 · Rendimiento con efectos**
  Escena de prueba con 200 enemigos, 60 torres y todos los efectos.
  **Refs:** RF-131, constitución P7.
  **Hecho cuando:** se mantienen ~60 FPS. (Adelanta la parte de efectos de T39.)
  **Resultado (2026-09-28):** `tools/perf_test.gd` → 153 FPS de promedio, frame más lento 15,3 ms. ✅

---

## M2 — Profundidad

- [x] **T30 · Seleccionar torre + panel**
  Clic sobre una torre construida → se resalta y se abre `tower_panel` con sus estadísticas. Clic en otro lado o `Esc` lo cierra.
  **Refs:** RF-70.
  **Hecho cuando:** el panel muestra nombre, nivel y estadísticas correctas de la torre seleccionada.

- [x] **T31 · Mejorar torres (niveles 2 y 3)**
  Agregar los niveles 2 y 3 a los `.tres` de las torres. Botón **Mejorar** y tecla `U`.
  **Refs:** RF-71, tabla de mejoras.
  **Hecho cuando:** mejorar descuenta el costo correcto y cambia las estadísticas; en nivel 3 el botón desaparece o se desactiva; el círculo de alcance se actualiza.

- [x] **T32 · Vender torres**
  **Refs:** RF-72.
  **Hecho cuando:** se cumple el criterio de aceptación de RF-72 y se puede volver a construir en esa casilla.

- [x] **T33 · Modos de apuntado**
  **Refs:** RF-54.
  **Hecho cuando:** con 3 enemigos distintos en rango, cambiar de modo cambia visiblemente a cuál se dispara.

- [x] **T34 · Francotirador**
  **Refs:** spec §5.3; tecla `4`.
  **Hecho cuando:** se puede construir y alcanza enemigos a 6 casillas.

- [x] **T35 · Voladores**
  `AirPath0` en el nivel 1, `data/enemies/flyer.tres`, capa de colisión 3.
  **Refs:** RF-05, RF-53.
  **Hecho cuando:** los voladores cruzan en línea recta; el Cañón los ignora por completo (ni apunta ni daña con área); las demás torres les disparan.

- [x] **T36 · Blindado y Jefe**
  `armored.tres`, `boss.tres` (con `slow_resistance = 0.5`).
  **Refs:** RF-80, tabla de enemigos.
  **Hecho cuando:** se cumple el criterio de aceptación de RF-80; el Jefe con Hielo nivel 1 va al 80 % de su velocidad (40 % × 0.5 = 20 % de ralentización).

- [x] **T37 · Pausa y velocidad x2**
  **Refs:** RF-103, RF-104; plan §6.7.
  **Hecho cuando:** en pausa todo se congela pero se puede seleccionar torres; x2 lo acelera todo (incluida la cuenta atrás); al reintentar, la velocidad vuelve a x1.

- [x] **T38 · Rediseñar oleadas del nivel 1 con los nuevos enemigos**
  Actualizar la tabla de oleadas en la spec **y** en `level_01.tres`.
  **Hecho cuando:** voladores, blindados y un Jefe (en la última oleada) aparecen en el nivel 1, y el nivel sigue siendo ganable.

- [x] **T39 · Prueba de rendimiento**
  Escena de prueba con 200 enemigos y 60 torres.
  **Refs:** constitución P7; plan §8.
  **Hecho cuando:** el monitor de Godot muestra ~60 FPS estables. (Si no, se crea una tarea de optimización **midiendo primero** qué es lo lento.)
  **Resultado (2026-09-28, con todo M2):** `tools/perf_test.gd` → 140 FPS de promedio, frame más lento 15,6 ms. ✅

---

## M3 — Juego completo

- [x] **T40 · Autoloads `GameFlow` y `SaveManager`**
  Con `tests/test_save_manager.gd` (guardar, cargar, archivo inexistente, archivo corrupto).
  **Refs:** RF-115; plan §7.
  **Hecho cuando:** los tests pasan.

- [x] **T41 · Menú principal**
  **Refs:** RF-110.
  **Hecho cuando:** el juego arranca en el menú; "Salir" cierra el juego.

- [x] **T42 · Selección de nivel y desbloqueo**
  **Refs:** RF-111, RF-112, RF-90 (Siguiente nivel / Menú).
  **Hecho cuando:** se cumple el criterio de aceptación de RF-115.

- [x] **T43 · Nivel 2 — Desfiladero**
  Mapa, caminos, `level_02.tres` con 15 oleadas.
  **Hecho cuando:** pasa `test_level_paths.gd` y es ganable.

- [x] **T44 · Soporte de varias entradas**
  Revisar que `WaveSpawner` use `entrance_index` correctamente.
  **Refs:** plan §4.1 (`SpawnGroup.entrance_index`).
  **Hecho cuando:** en un mapa de prueba con 2 entradas, cada grupo sale por la entrada indicada.

- [x] **T45 · Nivel 3 — Encrucijada**
  Mapa con 2 entradas, `level_03.tres` con 20 oleadas.
  **Hecho cuando:** pasa `test_level_paths.gd` y es ganable.

- [x] **T46 · Menú de pausa**
  **Refs:** RF-114.
  **Hecho cuando:** `Esc` (sin nada seleccionado ni construcción activa) abre el menú y todas sus opciones funcionan.

- [x] **T47 · Opciones**
  Buses de audio `Master`/`Music`/`SFX`, pantalla completa.
  **Refs:** RF-113.
  **Hecho cuando:** los cambios se aplican al momento y se mantienen al reiniciar el juego.

- [x] **T48 · Sonido y música**
  Autoload `Audio`. Sonidos sintetizados con código (`tools/make_sounds.gd`, D-020).
  **Refs:** RF-116.
  **Hecho cuando:** suenan todos los eventos de RF-116 y la música no se corta al cambiar de pantalla.

- [x] **T49 · Exportar el juego**
  Exportar un `.exe` para Windows.
  **Hecho cuando:** el `.exe` funciona en otra carpeta, sin tener Godot abierto, y guarda el progreso.
  **Resultado:** `build/JuegoA.exe` (110 MB) exportado y probado por Lucas fuera de Godot ("fue excelente").

> 🎉 **Fin de M3: el juego mediano está terminado.**

---

## MA — Android *(prueba, D-021)*

> Objetivo: instalar y jugar el juego en un celular, con las adaptaciones mínimas de la spec §9.4. No es un rediseño táctil.

- [x] **TA1 · Adaptaciones mínimas**
  Horizontal fijo, botón "atrás" = Esc sin cerrar el juego (GameFlow simula la acción `cancel`), "atrás" en la selección de nivel vuelve al menú.
  **Refs:** RF-141, RF-142.
  **Hecho cuando:** `test_android_back_button_opens_the_pause_menu` pasa.

- [x] **TA2 · Exportar el `.apk`**
  Configuración `Android` en `export_presets.cfg` (paquete `com.juegoa.towerdefense`, solo arm64, sin Gradle). Requiere en el editor: *Configuración del Editor → Exportar → Android → Ruta del SDK de Java* = `C:\Program Files\Android\Android Studio\jbr`.
  **Refs:** RF-140.
  **Hecho cuando:** `godot --headless --path . --export-debug "Android" build/JuegoA.apk` genera el archivo sin errores.
  **Resultado:** `build/JuegoA.apk` (28,7 MB), firmado con la clave de depuración de Godot, paquete `com.juegoa.towerdefense` 1.0, arm64. Hizo falta además activar ETC2/ASTC y agregar un ícono (`assets/icon.png`).

- [x] **TA3 · Probar en un celular**
  **Refs:** RF-140 a RF-143.
  **Hecho cuando:** Lucas instala el `.apk`, el juego abre en horizontal, se puede construir tocando, y "atrás" abre el menú de pausa sin cerrar el juego.
  **Resultado:** Lucas lo probó en su celular (2026-09-29): "funcionó bien como concepto". Quedan mejoras para más adelante (sin detallar todavía).

---

## M4 — Pulido *(opcional)*

### Niveles 4 y 5 *(pedidos por Lucas)*

- [x] **T60 · La salida se ve y entradas por arriba o abajo**
  `LevelDecor` dibuja una puerta en las salidas que quedan dentro del mapa. El generador de mapas acepta caminos que entran o salen por cualquier borde.
  **Refs:** RF-06.
  **Hecho cuando:** en la captura del nivel 4 se ve la puerta en el centro; los niveles 1 a 3 no cambian.

- [x] **T61 · Nivel 4 — Espiral**
  Mapa, `level_04.tres` con 15 oleadas, agregado a la campaña. Tarjetas de la selección de nivel más angostas para que entren 5.
  **Refs:** spec §7.5.
  **Hecho cuando:** pasan `test_level_paths.gd` y `test_levels.gd`, y las 5 tarjetas entran en la pantalla.

- [x] **T62 · Nivel 5 — Fortaleza**
  Mapa con 3 entradas (una desde arriba), `level_05.tres` con 20 oleadas.
  **Refs:** spec §7.6.
  **Hecho cuando:** pasan los tests y cada grupo sale por su entrada.

- [x] **T63 · Balance de los niveles 4 y 5**
  Con el bot, elegir el aumento de vida por oleada de cada uno.
  **Refs:** spec §7.4, D-019.
  **Hecho cuando:** el bot que mezcla torres gana pensando, y el que pone torres al azar pierde; la tabla de §7.4 queda completa.
  **Resultado:** Espiral 20 %, Fortaleza 10 % (spec §7.4). Se tomó el mejor bot como referencia; de paso se arregló un error del bot cuando el mapa se llena de torres.


### Estrellas y números de daño *(pedidos por Lucas)*

- [x] **T64 · Estrellas por nivel**
  `Rules.stars_for()`, umbrales en `balance.tres`, estrellas dibujadas por código en la pantalla de victoria y en las tarjetas, total de la campaña.
  **Refs:** RF-93, RF-111.
  **Hecho cuando:** los tests de umbrales pasan (20 → 3, 18 → 3, 17 → 2, 10 → 2, 9 → 1) y la captura muestra las estrellas en la victoria y en la selección de nivel.

- [x] **T65 · Números de daño flotantes**
  Señal `hit` del enemigo con el daño real; números en la capa de efectos (grises si la armadura quitó la mitad o más); máximo 40 a la vez; opción para apagarlos.
  **Refs:** RF-132, RF-113.
  **Hecho cuando:** los tests pasan (aparece el número, gris con armadura, no aparece con la opción apagada, nunca más de 40) y la prueba de rendimiento sigue sobre 60 FPS.
  **Resultado:** 150 FPS con números y 156 sin ellos (200 enemigos, 60 torres); frames de más de 16,6 ms: 0 a 2 de ~900 en ambos casos, es decir, ruido del sistema.
### Avisos de enemigos *(pedido por Lucas)*

- [x] **T66 · Descripciones y marca de peligro**
  `EnemyData.description` con las frases de la spec; dibujo de las formas compartido (`EnemyShape`) para usarlo también en la interfaz; corona sobre los enemigos peligrosos.
  **Refs:** RF-134 (frases), RF-136.
  **Hecho cuando:** los 6 enemigos tienen su frase (test) y la captura muestra la corona sobre el Jefe.

- [x] **T67 · Próxima oleada y cartel del Jefe**
  **Refs:** RF-133, RF-135.
  **Hecho cuando:** los tests comprueban la composición de la próxima oleada (tipos y cantidades) y el texto del cartel en la oleada 10 del nivel 1.

- [x] **T68 · Presentación de enemigos**
  Tarjeta la primera vez que aparece cada tipo; "enemigos vistos" en el guardado.
  **Refs:** RF-134, RF-117.
  **Hecho cuando:** los tests comprueban que sale una sola vez por tipo, que se guarda y se vuelve a leer, y que fuera de la campaña no se escribe en disco.

### Arte provisional *(pedido por Lucas, D-023)*

- [x] **T70 · Torres con dibujos**
  SVG de las 3 bases y las 4 torretas; `TowerLevelData.base_texture` y `TowerData.turret_texture`; `tower.gd` dibuja base + torreta (con retroceso y destello); los botones del HUD muestran la torreta.
  **Refs:** RF-150, RF-155, RF-156.
  **Hecho cuando:** los tests comprueban que cada torre y cada nivel tienen su dibujo de 128×128, y la captura muestra las 4 torres en los 3 niveles.
  **Resultado:** el botón muestra la base de madera con la torreta (`Tower.make_icon()`), porque la torreta sola quedaba chica y la del Cañón no se veía sobre el fondo oscuro. La torre fantasma al construir también usa los dibujos. Los botones pasaron de 176 a 184 px de ancho (y "Próxima oleada" se corrió a la derecha) para que todos los íconos tengan el mismo tamaño.

- [x] **T71 · Enemigos con dibujos**
  SVG de los 6 enemigos; `EnemyData.texture`; miran hacia donde caminan; golpe (parpadeo), ralentizado (tinte + escarcha); íconos de "Próxima oleada" y de la presentación.
  **Refs:** RF-151, RF-152, RF-155, RF-156.
  **Hecho cuando:** los tests comprueban que cada enemigo tiene su dibujo, que se da vuelta al caminar hacia la izquierda (y no al subir o bajar), y la captura muestra los 6 enemigos, uno ralentizado.
  **Resultado:** el parpadeo blanco se hace con una **silueta blanca** de cada dibujo (`EnemyShape.flash_texture()`), porque este renderizador no aclara al multiplicar el color por más de 1. Se arma la primera vez que se golpea a cada tipo (unos 3 ms, una sola vez). De paso se encontró que "Próxima oleada" no tenía lugar para 4 tipos (la oleada 10 del nivel 1 se salía por abajo, desde T67): ahora el número va debajo del dibujo y hay un test que lo comprueba.

- [x] **T72 · Proyectiles y mapa**
  `TowerData.projectile_texture`, orientado hacia donde viaja; rocas, árbol, arbusto y puerta en `LevelDecor`.
  **Refs:** RF-153, RF-154.
  **Hecho cuando:** los tests comprueban que el proyectil apunta hacia su objetivo y que cada casilla bloqueada elige siempre la misma decoración, y las capturas de los 5 niveles se ven bien.
  **Resultado:** las rocas salen el doble de seguido que el árbol y el arbusto, porque el jugador ya las reconoce como "acá no se construye". Se borró el código que dibujaba la roca y la puerta a mano.

- [x] **T73 · Cierre del arte provisional**
  Prueba de rendimiento, exportar `.exe` y `.apk`, y explicar en el README cómo cambiar un dibujo.
  **Refs:** RF-157, D-023.
  **Hecho cuando:** la prueba de rendimiento sigue sobre 60 FPS y las dos exportaciones terminan sin errores.
  **Resultado:** 222 FPS con 200 enemigos y 60 torres (antes, 150): dibujar imágenes le cuesta menos a la placa de video que armar cada figura con código. Frames de más de 16,6 ms: 0 de 1329. La caché de siluetas blancas pasó de una variable estática a un dato extra ("meta") de cada dibujo, porque la variable estática dejaba un aviso de "recursos en uso" al cerrar. README (sección "Dibujos") y ONBOARDING (problemas conocidos) explican cómo cambiar o agregar un dibujo.

- [x] **T74 · Enemigos rediseñados (menos infantiles)**
  A Lucas los enemigos de T71 le parecieron "medio infantiles"; el Tanque sí le gustó. Se redibujan los otros 5 con el estilo del Tanque: bestias de costado, ojos chicos y rasgados, colmillos, garras, púas.
  **Refs:** RF-151.
  **Hecho cuando:** la hoja de dibujos y una captura en el juego muestran los 6 enemigos con el mismo estilo, se reconocen por su color y su silueta a tamaño de juego, y pasan los tests.
  **Resultado:** lobo gris con crin, lagarto corredor amarillo, murciélago de alas en punta, escarabajo rinoceronte de metal azul y bestia roja con cuernos y púas (pariente del Tanque). Solo cambiaron los SVG: el código y los datos siguen iguales.

- [x] **T75 · Volador rediseñado**
  Lucas aprobó los enemigos de T74 salvo el Volador. Era el único dibujado de frente; ahora es un **dragón alado violeta** (wyvern) de costado, con las alas levantadas, cola con púa y cuerno.
  **Refs:** RF-151.
  **Hecho cuando:** la hoja de dibujos y la captura en el juego lo muestran con el mismo estilo que los demás, y pasan los tests.

## M5 — Contenido nuevo *(pedido por Lucas, D-025)*

> Cada comportamiento nuevo es un **dato** (RF-164): las tareas agregan campos a los datos y el código que los usa, nunca casos especiales por torre o enemigo.

- [x] **T76 · Ícono del juego**
  `tools/make_icon.gd` arma el ícono con los dibujos (una torre frente a una bestia). El mismo ícono en la ventana, el `.exe` y el `.apk`.
  **Refs:** RF-159.
  **Hecho cuando:** `assets/icon.png` muestra los dibujos y el `.exe` exportado tiene ese ícono.
  **Resultado:** la torre de nivel 3 con el Cañón disparándole al Jefe, sobre pasto. Godot 4.7 pone el ícono en el `.exe` sin herramientas externas (`application/icon` en `export_presets.cfg`); se comprobó sacándolo del archivo exportado.

- [x] **T77 · Barra para 8 torres**
  Botones compactos (dibujo, costo, tecla), `TowerData.description` y el cartel con nombre, costo y frase al elegir una torre; teclas 5–8.
  **Refs:** RF-170, RF-171, RF-40, D-026.
  **Hecho cuando:** un test con 8 torres comprueba que los botones entran sin tapar "Próxima oleada", que las teclas 1–8 eligen cada torre y que el cartel muestra la frase.
  **Resultado:** botones de 86×60 (dibujo, costo y tecla). El cartel de la torre elegida es una sola línea de texto con contorno, sin fondo, encima de la barra: un panel con fondo tapaba casi dos filas del mapa y la vista previa.

- [x] **T78 · Incendiaria (quemadura)**
  `TowerLevelData.burn_damage_per_second` y `burn_duration`; el enemigo se quema (golpecitos cada 0,5 s que ignoran la armadura, sin sumarse); llamitas; dibujos de la torre y la bola de fuego; sonido.
  **Refs:** RF-160, RF-158.
  **Hecho cuando:** los tests comprueban el daño por segundo, que ignora la armadura, que no se suma y que se apaga al terminar.
  **Resultado:** además, `project.godot` ahora importa **solos** los SVG nuevos al doble y con mipmaps (`[importer_defaults]`): agregar un dibujo ya no requiere tocar el panel Importar. `make_sounds.gd` acepta nombres (`-- shot_fire`) para generar solo esos sonidos, y su ruido sale siempre igual.

- [x] **T79 · Troll (regeneración)**
  `EnemyData.regen_percent_per_second`; no se regenera mientras se quema; "+N" verdes; dibujo.
  **Refs:** RF-165, RF-167.
  **Hecho cuando:** los tests comprueban cuánto se cura por segundo, que no pasa de su máximo y que quemándose no se cura.
  **Resultado:** el "+N" verde sale como mucho una vez por segundo (con lo curado en ese segundo), para no llenar la pantalla. El primer dibujo parecía una tortuga (lomo redondo con manchas); el definitivo es un troll encorvado con nariz grande, colmillos, taparrabos y garrote.

- [x] **T80 · Araña y Crías**
  `EnemyData.death_spawn` y `death_spawn_count`; el generador de oleadas crea las crías en el lugar de la madre y las cuenta para terminar la oleada; dibujos.
  **Refs:** RF-166, RF-167.
  **Hecho cuando:** los tests comprueban que al morir salen 4 crías donde estaba, con la vida de la oleada; que llegando a la salida no suelta nada; y que la oleada termina recién cuando mueren todas.
  **Resultado:** las crías las crea el generador de oleadas (`WaveSpawner`), igual que a cualquier enemigo: por eso tienen la vida de la oleada, dan oro, se presentan con su tarjeta y cuentan para terminarla. Salen separadas 10 px hacia atrás en el camino.

- [x] **T81 · Múltiple (varios objetivos)**
  `TowerLevelData.extra_targets`; la torre dispara a sus N mejores objetivos; dibujos y sonido.
  **Refs:** RF-161.
  **Hecho cuando:** los tests comprueban que con 5 enemigos en alcance dispara a 2 (nivel 1) distintos, elegidos según el modo de apuntado, y con 1 enemigo dispara 1 solo proyectil.
  **Resultado:** la torreta quedó gris azulada (la de cobre casi no se distinguía de la base de madera). Las torres de un solo objetivo siguen buscando solo al mejor, sin ordenar a todos.

- [x] **T82 · Ráfaga (púas en círculo)**
  `TowerLevelData.burst_count`; proyectiles en línea recta que golpean al primer enemigo que tocan; dibujos y sonido.
  **Refs:** RF-162, RF-55.
  **Hecho cuando:** los tests comprueban que lanza 8 púas repartidas en círculo, que cada una golpea a un solo enemigo, que se pierde si no toca a nadie y que no dispara si no hay enemigos en alcance.
  **Resultado:** el proyectil tiene un segundo modo, "en línea recta" (`Projectile.setup_straight()`). La torreta gira media separación en cada ráfaga, así las púas no salen siempre por el mismo lugar. Si un proyectil recto tuviera además área (RF-164), explotaría donde toca.

- [x] **T83 · Eléctrica (rayo en cadena)**
  `TowerLevelData.chain_extra_targets` y `chain_range_tiles`; el rayo salta al enemigo más cercano no golpeado; efecto de zigzag; dibujos y sonido.
  **Refs:** RF-163, RF-158.
  **Hecho cuando:** los tests comprueban que golpea a 3 enemigos (objetivo + 2 saltos) sin repetir, que no salta más lejos que su distancia y que con un solo enemigo golpea solo a ese.
  **Resultado:** el salto lo hace el proyectil al impactar (`Projectile._chain_from()`), así que cualquier torre con `chain_extra_targets` salta, aunque además queme o frene (RF-164). La torreta tiene anillos amarillos para no confundirse con la Incendiaria.

- [x] **T84 · Nivel 6 — Nido y balance**
  Mapa, `level_06.tres`, campaña; el bot usa las torres nuevas; aumento de vida por oleada del nivel 6; revisar que los niveles 1–5 no queden regalados con las torres nuevas.
  **Refs:** spec §7.7, §7.4.
  **Hecho cuando:** el bot que mezcla torres gana el nivel 6 y el que pone torres al azar pierde; los niveles 1–5 siguen perdiéndose con el bot al azar.
  **Resultado:** nivel 6 con +30 % de vida por oleada: el bot con las 8 torres ("mix", nuevo) gana con 10 vidas, el de las 4 viejas con 6 y el de torres al azar pierde en la oleada 5. Las 4 torres nuevas se reforzaron porque rendían menos que la Ametralladora (spec §5.6). El generador pasó a llamarse `tools/make_levels.gd` y acepta qué niveles regenerar (`-- 6`). Las tarjetas de la selección de nivel pasaron de 220 a 190 px para que entren 6.

- [x] **T85 · Guía para crear contenido y cierre de M5**
  `CONTENIDO.md` (cómo agregar un enemigo, una torre o un nivel, con todos los campos), tests que revisan **todos** los archivos de `data/` (así, si a algo nuevo le falta un dato, un test avisa), prueba de rendimiento y exportaciones.
  **Refs:** RF-164, RF-157, D-025.
  **Hecho cuando:** la guía explica cada campo, los tests de contenido recorren las carpetas solos, el rendimiento sigue sobre 60 FPS y las exportaciones terminan sin errores.
  **Resultado:** `CONTENIDO.md` y `tests/test_content.gd` (revisa todos los enemigos, torres y niveles; por ejemplo, que cada torre esté en la lista del juego y tenga su sonido). Rendimiento con las 8 torres: primero dio **57 FPS**; se corrigieron dos cosas: las llamitas pasaron de polígonos a un dibujo (con la Incendiaria sola: de 42 a 110 FPS) y cada púa de la Ráfaga revisa solo a los enemigos cercanos. Resultado final: **98 FPS**, frame más lento 23 ms. Queda un caso extremo, 60 Ráfagas construidas a la vez (todas disparan en el mismo cuadro: picos de 137 ms), que no pasa jugando porque las torres se construyen de a una.

## M6 — Modo de pruebas y récords *(pedido por Lucas, D-028, D-029)*

- [x] **T86 · Modo de pruebas: activación y guardado aparte**
  Autoload `DevMode` (activo con la característica `pruebas` o, en el editor, con `--pruebas`); preset de exportación "Windows (pruebas)"; `save_pruebas.json`; cartel "MODO PRUEBAS"; todos los niveles abiertos.
  **Refs:** RF-180, RF-181, RF-182, RF-183.
  **Hecho cuando:** los tests comprueban que sin el modo nada cambia, que con el modo se usa el otro guardado y se abren todos los niveles, y que el `.exe` de pruebas exporta sin errores.
  **Resultado:** se comprobó corriendo el `JuegoA_pruebas.exe` exportado: el log dice "Modo de pruebas activado. Guardado: user://save_pruebas.json". Un test revisa que solo el preset de pruebas tenga la característica `pruebas`.

- [x] **T87 · Panel de pruebas**
  Botón "Pruebas" y tecla F1 en la partida (solo en modo pruebas) con: +1000 de oro, vidas infinitas, saltar oleada, matar a todos, ganar, perder, velocidad x4, aparecer un enemigo, FPS.
  **Refs:** RF-184.
  **Hecho cuando:** un test prueba cada acción del panel, y sin modo de pruebas el panel no existe.
  **Resultado:** los enemigos que saca el panel desaparecen sin morir (`Enemy.vanish()`): no dan oro ni sueltan crías. "Saltar oleada" completa la oleada como siempre (con su bono). El cartel "MODO PRUEBAS" se movió abajo del todo, porque arriba tapaba la tarjeta "Nuevo enemigo".

- [x] **T88 · Puntos**
  `LevelSession.score`; puntos por enemigo muerto (oro × 10) y por vida al ganar (× 100), con los dos números en `balance.tres`; "Puntos" en la barra de arriba.
  **Refs:** RF-190, RF-100.
  **Hecho cuando:** los tests comprueban los puntos al matar (también crías), al ganar, y que el panel de pruebas no da puntos.
  **Resultado:** "Puntos" va antes que "Oleada" en la barra de arriba, porque el texto de la oleada se alarga al completarla. El bonus de vidas se suma justo antes de avisar la victoria, así la pantalla final ya tiene el total.

- [x] **T89 · Récords de cada nivel (3 letras)**
  Top 5 por nivel en el guardado; entrada de letras estilo arcade; la pantalla final pide las letras si se entra y muestra el top 5.
  **Refs:** RF-191, RF-192, RF-193, RF-196.
  **Hecho cuando:** los tests comprueban el orden (con empates), que se descarta el sexto, que con 0 puntos no se entra, que se guarda y se vuelve a leer, y que fuera de la campaña no se escribe nada; la captura muestra la entrada de letras y el top 5.
  **Resultado:** `HighScores` (cuentas puras), `NameEntry` y `ScoreTable` (controles reutilizables para el Salón de la fama y la pantalla de récords). Mientras se piden las iniciales, los botones de la pantalla final se esconden. El guardado sigue siendo la versión 1: los récords y las últimas iniciales son claves nuevas que un guardado viejo simplemente no tiene.

- [x] **T90 · Salón de la fama (5 letras)**
  Total de la campaña (suma del mejor puntaje en victoria de cada nivel), pedido de 5 letras cuando el total sube y entra, estética dorada.
  **Refs:** RF-194.
  **Hecho cuando:** los tests comprueban que no existe hasta ganar todos los niveles, que el total es la suma de los mejores, que solo se pide cuando el total sube, y la captura muestra el Salón.
  **Resultado:** el guardado suma, por nivel, el mejor puntaje en victoria (`best_score`) y el último total anotado (`hall_total`). El Salón se abre encima de la pantalla final, después del récord del nivel: fondo oscuro, marco dorado con brillo, trofeo (`assets/sprites/ui/trophy.svg`) y 5 letras.

- [x] **T91 · Pantalla "Récords" y cierre de M6**
  Botón "Récords" en el menú principal; top 5 de cada nivel y Salón de la fama; README/ONBOARDING (cómo exportar y usar el `.exe` de pruebas); exportar los tres ejecutables.
  **Refs:** RF-195, RF-110.
  **Hecho cuando:** se ve la pantalla de récords, pasan todos los tests y las exportaciones terminan sin errores.
  **Resultado:** se exportaron los tres (`JuegoA.exe`, `JuegoA_pruebas.exe` y `JuegoA.apk`) y se comprobó corriéndolos: el normal no activa el modo de pruebas y el de pruebas sí. README ("El ejecutable de pruebas"), ONBOARDING (6.1) y el plan técnico (autoload `DevMode` y formato del guardado) quedaron al día.

## MC — Tests automáticos en GitHub *(pedido por Lucas, D-030)*

- [x] **T92 · Workflow de GitHub Actions**
  `.github/workflows/tests.yml`: baja Godot 4.7.2 (con caché), importa el proyecto, revisa `tools/` y corre GUT en cada *push* a `main` y en cada *pull request*. Insignia en el README.
  **Refs:** plan §8, D-030.
  **Hecho cuando:** la corrida en GitHub termina en verde con los 276 tests, y se comprobó (en un clon limpio) que un test que falla o que no compila deja la corrida en rojo.
  **Resultado:** la corrida en GitHub terminó en verde (Lucas lo confirmó). Se usan `actions/checkout@v7` y `actions/cache@v6` (Node 24; las v4 daban aviso de Node 20 obsoleto) y el runner fijo en `ubuntu-24.04`, porque `ubuntu-latest` pasa a Ubuntu 26 en octubre de 2026.

## M7 — Niveles en archivos de texto *(pedido por Lucas, B-04 escalón 1, D-031)*

- [x] **T93 · Leer el mapa de letras (`MapGrid`)**
  Clase pura que lee las 9 filas de 20 letras: tipo de cada casilla, entradas (`A`, `B`…), salida (`S`) y el recorrido más corto de cada entrada, con sus esquinas. Errores en castellano.
  **Refs:** RF-201, RF-202, RF-204.
  **Hecho cuando:** los tests comprueban las letras, el recorrido más corto con uniones (como el nivel 6), que un empate es un error, y cada error del mapa (tamaño, letra desconocida, sin salida, dos salidas, entrada sin camino, letra salteada, sin pasto).
  **Resultado:** [`map_grid.gd`](../scripts/logic/map_grid.gd): primero mide, desde la salida, cuántos pasos hay de cada casilla de camino a la salida; después cada entrada avanza siempre a la vecina un paso más cerca (si hay dos, es un empate). Los mensajes dicen fila y columna contadas desde 1, como el Bloc de notas. Se admiten hasta 8 entradas (`A` a `H`). 12 tests.

- [x] **T94 · Leer el archivo del nivel (`LevelFile`) y armar el mapa al vuelo**
  `LevelFile` lee el JSON y devuelve un `LevelData` (con sus oleadas) o la lista de errores. `Level.build()` arma el `TileMapLayer`, los caminos (terrestre y aéreo) y la decoración a partir del `MapGrid`. `LevelData.build_map()`.
  **Refs:** RF-200, RF-203, RF-204.
  **Hecho cuando:** los tests leen un nivel de ejemplo, comprueban cada error de datos (clave mal escrita, enemigo que no existe, entrada que el mapa no tiene, números fuera de rango, JSON roto) y que el mapa armado tiene las casillas y los caminos esperados.
  **Resultado:** [`level_file.gd`](../scripts/logic/level_file.gd) y `Level.build()` / `Level.route_curve()`. El mapa del nivel 6 armado desde las letras da **los mismos puntos** que `level_06.tscn` (sin los puntos intermedios que no son esquinas). La partida y el fondo del menú ya usan `LevelData.build_map()`, que sigue aceptando la escena vieja hasta T96. Un nombre de enemigo solo puede tener minúsculas, números y `_` (no puede apuntar a otra carpeta). El test de la campaña pasó a T95, porque necesita los archivos de los niveles. 13 tests.

- [x] **T95 · Pasar los 6 niveles y la campaña a JSON**
  Herramienta de conversión desde los `.tscn`/`.tres` actuales; `data/campaign.json`; `GameFlow`, la partida, el fondo del menú, el bot y los tests usan los archivos nuevos.
  **Refs:** RF-205, spec §7.8.
  **Hecho cuando:** un test compara, nivel por nivel, que los mapas nuevos tienen las mismas casillas, los mismos recorridos (misma forma y largo) y las mismas oleadas que las escenas viejas; el bot da los mismos resultados en los 6 niveles.
  **Resultado:** `tools/levels_to_json.gd` escribió los 6 `data/levels/level_0N.json` y `data/campaign.json`. `test_levels_json.gd` comparó todo (1171 comprobaciones: casillas, puertas, esquinas, largos, vuelos, oleadas, oro, vidas y aumento): todo igual. Punto por punto, los caminos coinciden salvo en el nivel 6 (entrada A) y el 5 (entrada C), donde los viejos tenían un punto de más en medio de una recta: la diferencia es de 0,0005 px. El bot (`smart` y `mix`, niveles 1 a 6) dio **11 de 12 resultados idénticos**; en el nivel 6, `smart` ganó con 5 vidas en vez de 6, por ese redondeo (la simulación es cuadro por cuadro, y una diferencia mínima cambia qué torre mata a qué enemigo). `GameFlow.campaign` sale de `LevelFile.load_campaign()`; `game.tscn` ya no trae un nivel fijo (sin campaña, juega el primero); el bot lee la campaña nueva (`gold=` se aplica al nivel elegido).

- [x] **T96 · Retirar lo viejo, `check_level` y guía**
  Borrar las escenas y `.tres` de niveles, `campaign.tres` y `make_levels.gd`; `tools/check_level.gd`; CONTENIDO.md ("Cómo hacer un nivel"), README y plan técnico; exportar y comprobar que los `.json` viajan dentro del ejecutable.
  **Refs:** RF-206, D-031.
  **Hecho cuando:** pasan todos los tests, `check_level` muestra el recorrido de un nivel y el error de uno roto, y el `.exe` exportado carga los 6 niveles.
  **Resultado:** se borraron las 6 escenas, los 6 `.tres` de niveles, `campaign.tres`, `make_levels.gd`, la herramienta de conversión y el test de comparación (ya cumplieron). `LevelData` ya no tiene `map_scene`. [`check_level.gd`](../tools/check_level.gd) muestra el recorrido de cada entrada marcado con `*` y termina con código 1 si hay errores (sirve para GitHub). CONTENIDO.md tiene la sección "Agregar un nivel" nueva (letras, oleadas, errores comunes). Se exportaron los tres: los 7 `.json` están dentro del `.exe`, del `.exe` de pruebas y del `.apk`, y el `.exe` arranca sin errores de campaña. 303 tests.

## M8 — Nivel 7 y versión para Linux *(pedido por Lucas, D-032)*

- [x] **T97 · Nivel 7 — Cruce**
  `data/levels/level_07.json` (mapa con la salida en el centro, dos entradas, 20 oleadas), agregado a `campaign.json`; tarjetas de la selección de nivel de 190 a 168 px para que entren 7; aumento de vida elegido con el bot.
  **Refs:** spec §7.9, RF-200 a RF-205.
  **Hecho cuando:** `check_level` no da errores, pasan los tests (la campaña ahora es de 7 niveles) y el bot da resultados razonables.
  **Resultado:** aumento de vida **24 %**: el bot que mezcla las 8 torres gana con 7 vidas, el de las 4 viejas pierde en la oleada 18 y el de torres al azar, en la 4 (con 15 % y 20 % era regalado; con 30 % nadie pasaba la 18). Con la salida en el centro y los dos recorridos cortos (30 y 29 casillas), una defensa central cubre todo, por eso hace falta más vida por oleada que en el nivel 6. Crear el nivel llevó un archivo de texto y una línea en la campaña, sin tocar código (salvo el ancho de las tarjetas).

- [x] **T98 · Exportar para GNU/Linux**
  Preset "Linux" en `export_presets.cfg` (un solo archivo, con los datos adentro) y `.tar.gz` que conserva el permiso de ejecución; README y ONBOARDING.
  **Refs:** D-032.
  **Hecho cuando:** la exportación termina sin errores y el archivo es un ejecutable de Linux de 64 bits con los niveles adentro.
  **Resultado:** `build/JuegoA.x86_64` (74 MB, ELF x86-64, con los 7 niveles adentro) y `build/JuegoA_linux.tar.gz` (29 MB). **Falta probarlo en una computadora Linux real:** en esta PC (Windows, sin WSL) no se pudo abrir.

## M9 — Base para el editor y los mapas de la comunidad *(pedido por Lucas, D-033)*

- [x] **T99 · Selección de nivel para cualquier cantidad de niveles**
  Las tarjetas pasan de una fila fija a una grilla que se acomoda (filas de hasta 5, centradas) dentro de un área que se desplaza. Tarjetas de 200×214 px.
  **Refs:** RF-116, RF-111, D-033.
  **Hecho cuando:** los tests comprueban que con 7, 13 y 40 niveles ninguna tarjeta se sale de la pantalla, que con 7 no hace falta desplazar y que con más sí; y la captura muestra 7 y 13 niveles.
  **Resultado:** `HFlowContainer` (acomoda y centra las filas de hasta 5) dentro de un `ScrollContainer` que sigue al foco del teclado. El alto del área se ajusta a las filas que hay (hasta 2): con 5 niveles o menos hay una sola fila. La separación vertical de la pantalla bajó de 32 a 18 px para que el botón "Volver" no toque el cartel de "MODO PRUEBAS". 4 tests nuevos (7, 13 y 40 niveles; filas de a 5; cuándo hay que desplazar; una sola fila).

- [x] **T100 · Aviso de atajo (`MapGrid`, `LevelFile` y `check_level`)**
  `MapGrid` calcula las casillas de camino que ningún recorrido usa y arma un aviso; `LevelFile` lo devuelve como `warnings` (y la campaña lo anota en el registro); `check_level` lo muestra con ⚠ y marca esas casillas con `?`.
  **Refs:** RF-207, B-09.
  **Hecho cuando:** los tests comprueban que los 7 niveles no tienen avisos, que un mapa con un tramo que se puede saltear avisa (y sigue siendo válido) y que un mapa con errores no calcula avisos; y `check_level` muestra el aviso en un nivel de prueba.
  **Resultado:** `MapGrid.unused_cells` y `MapGrid.warnings`; `LevelFile` devuelve `warnings` junto a `errors` (y la campaña los anota con `push_warning`). Prueba real: en el nivel 6, una sola casilla `#` de más en la fila 7 hace que la entrada A pase de 56 a 34 casillas y el aviso marca con `?` las 23 casillas del tramo salteado. Los 7 niveles oficiales no tienen avisos (un test lo vigila). Un mapa con errores no calcula avisos: sin recorridos no se sabe qué sobra. 8 tests nuevos.

- [x] **T101 · El borrador del nivel (`LevelDraft`)**
  Lógica pura, sin pantallas: el nivel que se edita como datos (mismo formato que §7.8), con pintar casillas, entradas y salida (RF-212), ajustes y oleadas (RF-214, RF-215), texto ordenado como los niveles oficiales, revisión con las reglas de §7.8, guardar y leer en `user://maps/` (RF-216) y deshacer/rehacer.
  **Refs:** RF-212, RF-214, RF-215, RF-216.
  **Hecho cuando:** los tests comprueban cada operación, que el texto que se guarda vuelve a leerse igual con `LevelFile`, que las entradas se renumeran al quitar una (con sus oleadas), que el nivel nuevo es válido y que un nivel oficial abierto como plantilla no se puede guardar encima del oficial.
  **Resultado:** [`level_draft.gd`](../scripts/logic/level_draft.gd) guarda el nivel **en el mismo formato del archivo** (un solo modelo: lo que se edita, lo que se guarda y lo que valida `LevelFile` son lo mismo). Prueba fuerte: abrir cada nivel oficial y volver a escribirlo da **exactamente el mismo texto**. Un trazo del mouse es un solo paso de deshacer (`begin_stroke`/`end_stroke`); lo que no cambia nada no se puede deshacer. Los tests encontraron un defecto: listar los mapas sin que exista `user://maps/` dejaba un error en el registro. Un mapa con errores se puede abrir y guardar (RF-213). 37 tests.

- [x] **T102 · La pantalla del editor: pintar el mapa**
  Botón "Editor de mapas" en el menú (solo modo de pruebas); pantalla con el mapa, las herramientas y la línea de mensajes; recorridos y casillas sin usar dibujados; teclas y `Ctrl+Z`/`Ctrl+Y`.
  **Refs:** RF-210, RF-211, RF-212, RF-213.
  **Hecho cuando:** los tests comprueban que el botón solo existe en el modo de pruebas y que pintar cambia el mapa y los mensajes; la captura muestra un mapa válido con sus recorridos y uno con errores.
  **Resultado:** `MapEditor` (pantalla) y `MapView` (dibuja el mismo suelo y decoración que la partida, gracias a `Level.make_ground()`, más los recorridos, las letras y las casillas sin usar). Los recorridos se dibujan como **franjas anidadas** (la entrada A, la más ancha; las siguientes, más finas y encima) para que se vean todos donde comparten tramo. Arrastrar pinta también las casillas que el mouse se saltea (línea entre la anterior y la nueva); la entrada y la salida se ponen de a una. El borrador vive en `GameFlow.editor_draft`, así que al salir y volver se retoma. Las capturas encontraron dos defectos que se corrigieron: el botón de la herramienta anterior no se soltaba, y el elegido casi no se distinguía. 18 tests.

- [x] **T103 · Ajustes del nivel y oleadas**
  Paneles con el nombre, oro, vidas y aumento de vida, y el editor de oleadas y grupos.
  **Refs:** RF-214, RF-215.
  **Hecho cuando:** los tests comprueban cada cambio contra el borrador y que las entradas del selector son las del mapa; la captura muestra ambos paneles.
  **Resultado:** `SettingsPanel` y `WavesPanel` (sobre la base `EditorPanel`), anclados arriba a la derecha para que el mapa de la izquierda siga a la vista y editable; solo uno abierto a la vez. **Decisiones para no romper la escritura:** editar un número **no reconstruye** la fila (se perdería el foco y no se podría seguir con Tab; hay un test), y el nombre se guarda al terminar de escribir, no letra por letra (cada letra sería un paso de deshacer). Al deshacer o pintar, el panel abierto se actualiza (por ejemplo, las entradas que se pueden elegir). Un enemigo que no existe en un archivo se muestra como `trol (no existe)` y el editor avisa el error. **Dos defectos encontrados:** (1) las clases hijas de GDScript **no** llaman solas al `_init` de la base cuando tienen el suyo: hay que escribir `super()`; (2) **el panel de pruebas listaba los enemigos con `ends_with(".tres")`, y en el `.exe` exportado los recursos aparecen como `.tres.remap`**, así que esa lista salía **vacía** en `JuegoA_pruebas.exe` desde T87. Nueva `LevelFile.enemy_ids()` que entiende los dos nombres; la usan el panel de pruebas y el editor. `DevMode` deja en el registro "Enemigos disponibles: N" para poder comprobarlo en el ejecutable. 24 tests nuevos.

- [x] **T104 · Guardar, abrir y probar**
  Nuevo, Abrir (mapas propios y oficiales como plantilla), Guardar (nombre de archivo, confirmaciones) y Probar (se juega el borrador sin guardar nada y se vuelve al editor).
  **Refs:** RF-216, RF-217, RF-218.
  **Hecho cuando:** los tests comprueban que probar no guarda progreso ni récords, que se vuelve al editor con el borrador intacto y que no se puede probar un nivel con errores; y se guarda un mapa, se revisa con `check_level` y se juega de verdad.
  **Resultado:** `EditorDialog` (confirmar, pedir un nombre o elegir de una lista; tapa la pantalla y Esc lo cierra sin salir del editor) y las acciones Nuevo, Abrir, Guardar, Probar y Salir en `MapEditor`. El nombre de archivo se revisa **mientras se escribe** (minúsculas, números y `_`; no acepta el nombre de un nivel oficial; avisa si va a reemplazar un mapa propio) y el mensaje dice la ruta completa donde quedó el archivo. "Abrir" lista los mapas propios y los oficiales como plantilla (al guardar pide otro nombre). Probar usa `GameFlow.test_level`: la partida no guarda progreso, estrellas ni récords (un test lo comprueba: ni siquiera se crea el archivo de guardado), el botón final y el de la pausa dicen "Volver al editor" y el borrador queda intacto. Un nivel con **errores** no se puede probar; con **avisos** sí. `Ctrl+S` guarda. **Prueba de punta a punta:** un mapa armado con el borrador (dos entradas, una casilla bloqueada, dos grupos), guardado, revisado con `check_level` y jugado de verdad: los enemigos salieron por la entrada B, recorrieron el camino y llegaron a la salida. Un defecto propio corregido al escribir los tests: el doble clic en la lista no habilitaba "Abrir" si no había un clic simple antes. 39 tests nuevos.

- [x] **T105 · Cierre de M9: documentación y exportaciones**
  README, ONBOARDING, CONTENIDO.md (cómo usar el editor y cómo volver oficial un mapa), plan técnico; exportar los cuatro ejecutables.
  **Refs:** D-033.
  **Hecho cuando:** pasan todos los tests y el `.exe` de pruebas exportado abre el editor; el `.exe` normal no.
  **Resultado:** plan técnico §6.8 (cómo está armado el editor, con las decisiones y las dos trampas de GDScript que aparecieron), CONTENIDO.md (cómo se usa y **cómo volver oficial un mapa**), README y ONBOARDING al día. Se exportaron los cuatro (`.exe`, `.exe` de pruebas, `.apk` y Linux, con `.tar.gz`). **En el ejecutable exportado se comprobó** que la lista de enemigos ya no sale vacía: el registro dice "Enemigos disponibles: 9", y un experimento aparte mostró que el juego exportado ve los archivos como `armored.tres.remap`, `boss.tres.remap`…, con lo que el código viejo del panel de pruebas (`ends_with(".tres")`) habría dado una lista **vacía**: el defecto era real. El `.exe` normal no muestra nada del modo de pruebas.

## M10 — Mapas de la comunidad *(pedido por Lucas, D-034)*

- [x] **T106 · Leer los mapas de la comunidad (`CommunityMaps`) y los límites**
  `CommunityMaps.scan()` lista los `.json` de `user://maps/` (nombre de archivo, tamaño, errores) con su `LevelData`; `LevelFile` pone los topes de RF-223 y el editor los respeta.
  **Refs:** RF-220, RF-222, RF-223.
  **Hecho cuando:** los tests comprueban el orden, que un archivo roto, con nombre no válido o demasiado grande da una entrada con su motivo y no rompe a los demás, cada límite (uno por uno, en el borde y pasado), y que los niveles oficiales cumplen los límites.
  **Resultado:** [`community_maps.gd`](../scripts/logic/community_maps.gd) devuelve una entrada por archivo (`file`, `id`, `level`, `errors`, `warnings`); un archivo roto, con nombre no válido o de más de 200 KB es una entrada con su motivo, y **no se lee** el de más de 200 KB. Se leen como máximo 200 archivos. El id lleva el prefijo `comunidad_` (un archivo `level_03.json` o `hall_of_fame.json` no se confunde con lo oficial en el guardado). Los topes de RF-223 están en `LevelFile` y se comparan como decimal **antes** de convertir a entero (un `1e300` no desborda); el borrador del editor los respeta, y sus botones de agregar oleada, copiar y agregar grupo se apagan en el máximo. Un dato curioso: en Windows `con` es un nombre reservado del sistema, así que un test que creaba `con.punto.json` fallaba por eso, no por el código. 26 tests nuevos.

- [x] **T107 · Jugar un mapa de la comunidad: progreso, récords y salida**
  `GameFlow` sabe jugar un mapa de la comunidad (`start_community`); la partida guarda su mejor resultado, estrellas y top 5 con el id `comunidad_<archivo>` y **nada más**; al terminar, "Niveles" vuelve a la solapa de la comunidad.
  **Refs:** RF-224, RF-225.
  **Hecho cuando:** los tests comprueban que ganar un mapa de la comunidad guarda su progreso y sus récords, y **no** desbloquea niveles, no cambia las estrellas de la campaña, no cuenta para el Salón de la fama; y que la campaña sigue igual.
  **Resultado:** `GameFlow.current_community`, `played_level()` (el nivel cuyo progreso se guarda: el de la campaña o el mapa de la comunidad), `start_community()` y `community_stars()`. `level_won`, los récords y la partida usan `played_level()`, así que el mapa de la comunidad guarda mejor resultado, estrellas y top 5 con su id y **nada más**: un test comprueba que ganarlo no desbloquea niveles, no suma a las estrellas ni al total de la campaña y **no abre el Salón de la fama** aunque toda la campaña esté ganada (un mapa fácil hecho a medida no puede regalar el ranking). Dos mapas tienen progreso y récords separados. `select_page` recuerda la solapa para que "Niveles" vuelva a la comunidad. 14 tests nuevos.

- [x] **T108 · Las solapas de la selección de nivel**
  Solapas "Campaña" y "Mapas de la comunidad (N)", tarjetas con estrellas, tarjetas con errores, mensaje cuando no hay mapas y botón "Abrir carpeta".
  **Refs:** RF-221, RF-222, RF-226.
  **Hecho cuando:** los tests comprueban las dos solapas, el orden, las tarjetas con errores (con su motivo), el mensaje vacío y que se vuelve a buscar al abrir la pantalla; las capturas muestran la solapa con mapas, con un error y vacía.
  **Resultado:** solapas **Campaña** y **Mapas de la comunidad (N)** en la misma barra que el total de estrellas (así la pantalla no crece: con 2 filas de tarjetas entra justo, y se achicaron los espacios para que "Volver" no toque el cartel de pruebas). La solapa de la comunidad busca los archivos **cada vez que se abre la pantalla** (RF-226), muestra estrellas y "Mejor: N vidas", pone las tarjetas con errores deshabilitadas y en rojo con el motivo en el tooltip (`Con errores`), hace bajar de renglón los nombres largos, y cuando no hay mapas dice **en qué carpeta** ponerlos. "Abrir carpeta de mapas" la crea si no existe y la abre en el explorador (en el celular no se ofrece). Los tests usan una carpeta y un "abridor" falsos. 18 tests nuevos.

- [x] **T109 · Cierre de M10: documentación y exportaciones**
  README, ONBOARDING, CONTENIDO.md (cómo instalar y compartir un mapa), plan técnico; exportar los cuatro ejecutables.
  **Refs:** D-034.
  **Hecho cuando:** pasan todos los tests y, en el `.exe` normal exportado, un mapa copiado a la carpeta aparece en el menú.
  **Resultado:** CONTENIDO.md ("Mapas de la comunidad: instalar y compartir", con las carpetas de Windows y Linux, los motivos de error y la tabla de límites), plan técnico §6.9, README y ONBOARDING al día. Se exportaron los cuatro. **Comprobación con el paquete exportado del juego normal:** se copió un mapa a `%APPDATA%\Godot\app_userdata\JuegoA\maps` y la solapa dijo "Mapas de la comunidad (1)" (con el juego en modo normal: sin cartel de pruebas y con los niveles 2 a 7 bloqueados). **Límite honesto de la prueba:** el `.exe` de release no admite `--scene` (lo trae desactivado), así que se cargó el paquete de datos exportado con el Godot de desarrollo (`--main-pack`): son los mismos archivos convertidos que ve el juego real, pero no el binario de release. La carpeta y el archivo de prueba se borraron después, y el `save.json` quedó como estaba.

### Otras ideas de pulido *(sin fecha)*

- Decidir ambientación y arte definitivo (ver "Preguntas abiertas" de la spec y B-02). *Los dibujos provisionales ya están (T70–T73).*
- Balance fino de todos los niveles.

---

## M11 — Wiki en el juego *(pedido por Lucas, D-035)*

- [x] **T110 · El modelo de la wiki: `Wiki`, entradas de enemigos y torres, y `TowerText`**
  `WikiEntry`, `WikiCategory` y `Wiki.categories()` con Enemigos y Torres leídos de los datos; `TowerText` compartido con el panel de la torre.
  **Refs:** RF-233, RF-234, RF-237, D-035.
  **Hecho cuando:** los tests comprueban que hay una entrada por cada enemigo y cada torre de `data/`, el orden, los datos de cada una salidos del recurso, "aparece en los niveles…" con una campaña de prueba, lo que suelta la Araña, y que el panel de la torre dice lo mismo que antes.
  **Resultado:** [`wiki.gd`](../scripts/logic/wiki.gd) (`Wiki.categories()`), [`wiki_entry.gd`](../scripts/logic/wiki_entry.gd) y [`wiki_category.gd`](../scripts/logic/wiki_category.gd): solo datos, con bloques `titulo`, `texto`, `datos` y `tabla`. Enemigos y torres se descubren leyendo `data/` (con `.remap` en el exportado) y se ordenan por vida y por costo. El texto de estadísticas de la torre pasó a [`tower_text.gd`](../scripts/logic/tower_text.gd) y lo usan el panel y la wiki. La carpeta de artículos que todavía no existe no da error. 16 tests nuevos (507 en total).

- [x] **T111 · Los artículos de la Guía (`data/wiki/*.json`)**
  `Wiki.parse_article`, la carpeta de artículos y los artículos iniciales.
  **Refs:** RF-235, RF-236.
  **Hecho cuando:** los tests comprueban que cada artículo oficial se lee sin errores, que uno roto da su motivo sin impedir los demás, el orden y que los ids no se repiten.
  **Resultado:** `Wiki.parse_article` y `Wiki.articles(carpeta)` (un artículo roto se salta y deja su motivo; los tests exigen que los oficiales no tengan errores). 7 artículos en [`data/wiki/`](../data/wiki/): cómo se juega, construir/mejorar/vender, enemigos especiales, armadura y daño, efectos, puntos y estrellas, teclas. No repiten números de los datos (un test lo vigila). Dos detalles que mordieron: comparar `StringName` con `<` **no** ordena alfabéticamente (se usa `String(a) < String(b)`) y un `2` de JSON llega como `2.0` (se muestra "2"). 18 tests nuevos.

- [x] **T112 · La pantalla Wiki y el botón del menú**
  `WikiScreen` (solapas, lista, detalle con desplazamiento), `WikiIcon`, `GameFlow.go_to_wiki()` y el botón "Wiki".
  **Refs:** RF-230, RF-231, RF-232.
  **Hecho cuando:** los tests comprueban las solapas, elegir una entrada y ver su detalle, el teclado, que la categoría vacía no se muestra y que el botón del menú existe; las capturas muestran un enemigo, una torre y un artículo, y el menú con el botón nuevo.
  **Resultado:** [`wiki_screen.gd`](../scenes/ui/wiki_screen.gd) (solapas, lista con dibujo y nombre, detalle con desplazamiento; ◄/► cambian de categoría, ▲/▼ recorren la lista y al pasar se ve el detalle; Esc y Volver salen) y [`wiki_icon.gd`](../scenes/ui/wiki_icon.gd) (dibuja las capas). La pantalla solo dibuja bloques: no sabe qué es un enemigo. `show_target(categoría, entrada)` deja listo el enlace desde otros lados (B-15). `GameFlow.go_to_wiki()` y el botón "Wiki" entre Récords y Opciones. Las capturas mostraron dos cosas que se arreglaron: títulos largos que se cortaban en la lista (ahora llevan puntos suspensivos) y el texto pegado al borde del panel. 14 tests nuevos (530 en total).

- [x] **T113 · Cierre de M11: documentación y exportaciones**
  README, ONBOARDING, CONTENIDO.md (cómo escribir un artículo y qué se agrega solo); exportar los cuatro ejecutables.
  **Refs:** D-035.
  **Hecho cuando:** pasan todos los tests y, en el `.exe` normal exportado, la wiki muestra los enemigos y las torres (los `.tres` exportados se leen).
  **Resultado:** CONTENIDO.md (sección "La Wiki: qué se agrega solo y cómo escribir un artículo", con el formato de los bloques), README, ONBOARDING y la lista rápida al día. Se exportaron los cuatro. **Comprobación con el paquete exportado del juego normal** (cargado con el Godot de desarrollo, igual que en M10): la wiki muestra los enemigos con su dibujo y sus datos, y aparece la solapa "Guía" (los artículos `.json` se leen). **Sin probar:** el `.exe` de release abierto a mano, y el Linux en una computadora Linux.

---

## M12 — Bestiario que se va llenando *(pedido por Lucas, D-036)*

- [x] **T114 · Entradas cerradas en la wiki**
  `WikiEntry.locked`, `Wiki.categories(campaña, ¿lo vio?)`, silueta y "???" en la pantalla, contador en la solapa, y todo abierto en el modo de pruebas.
  **Refs:** RF-238, RF-239, RF-240, D-036.
  **Hecho cuando:** los tests comprueban que un enemigo no visto está cerrado y **su texto no contiene ningún dato real**, que uno visto está abierto, que torres y Guía nunca se cierran, que el orden no cambia, el contador, que en modo de pruebas todo está abierto, y que ver un enemigo en una partida lo abre en la wiki; las capturas muestran la lista con "???" y la entrada cerrada.
  **Resultado:** `WikiEntry.locked`, `Wiki.locked_enemy_entry()` (solo lleva el id, el dibujo y el aviso: **ni el nombre ni los datos existen** en la entrada cerrada, así la pantalla no puede filtrarlos; un test lo comprueba para los 9 enemigos), `Wiki.categories(campaña, ¿lo vio?)`, `WikiCategory.unlocked_count()`. La pantalla pinta la silueta (`WikiIcon`), pone el contador "Enemigos 4/9" mientras falte alguno y usa `SaveManager.has_seen_enemy` (o todo abierto si `DevMode.enabled`). **No hubo que guardar nada nuevo:** el juego ya anotaba cada enemigo visto (RF-134). 11 tests nuevos (541 en total).

- [x] **T115 · Cierre de M12: documentación y exportaciones**
  README, ONBOARDING, CONTENIDO.md; exportar los cuatro ejecutables.
  **Refs:** D-036.
  **Hecho cuando:** pasan todos los tests y las exportaciones se comprueban.
  **Resultado:** README, ONBOARDING y CONTENIDO.md al día. Se exportaron los cuatro. **Comprobación con el paquete exportado del juego normal** (cargado con el Godot de desarrollo): la wiki leyó el guardado real de Lucas y mostró "Enemigos 6/9", con los tres no vistos en silueta. **Un tropiezo:** `JuegoA_pruebas.exe` estaba abierto (Lucas probando el editor) y Windows no deja reemplazar un programa en uso; **no se cerró**: la versión nueva quedó en `build/JuegoA_pruebas_nuevo.exe`.

---

## M13 — Mapas de tamaño variable *(pedido por Lucas, D-037)*

- [x] **T116 · `MapGrid` y `LevelFile` con tamaño variable**
  `MapGrid` lee el tamaño de las filas (20×9 a 26×12); `Level.make_ground`, `check_level` y los topes de RF-223 lo respetan.
  **Refs:** RF-250, RF-253.
  **Hecho cuando:** los tests comprueban un mapa de 26×12 válido, los bordes (26×12 sí; 27×12, 26×13 y 19×9 no), filas de distinto largo, entradas en el borde real, el recorrido y el suelo del tamaño correcto; los 7 niveles oficiales dan exactamente lo mismo que antes.
  **Resultado:** `MapGrid` ya no tiene ancho y alto fijos: `width` y `height` salen de las filas, con `MIN_*` (20×9) y `MAX_*` (26×12). Los mensajes dicen el tamaño que se recibió y el permitido; `is_inside`, `is_on_border` (que decide si el enemigo entra desde afuera), el suelo (`Level.make_ground`) y `check_level` usan el tamaño real. `LevelDraft` conserva el tamaño del mapa que abre (antes cortaba a 20×9; lo dejé listo acá porque dejó de compilar sin `MapGrid.WIDTH`). Los 7 niveles oficiales siguen midiendo 20×9 (un test lo vigila). Un dato que confirma la decisión D-037: `check_level` del nivel 7 da exactamente lo mismo que antes. 13 tests nuevos (554 en total).

- [x] **T117 · Zoom del mundo en la partida**
  `Rules.map_zoom`, `Rules.map_camera_center` y la `Camera2D` en `Game`.
  **Refs:** RF-251, RF-252.
  **Hecho cuando:** los tests comprueban la fórmula (20×9 → 1, 26×12 → 0,75, casos intermedios), que con 20×9 **no hay cámara**, que con 26×12 el mapa queda dentro del área entre las barras y centrado, que la casilla bajo el puntero es la correcta con zoom (esquinas y centro) y que el alcance de una torre alcanza lo mismo; una captura muestra un mapa de 26×12 jugándose.
  **Resultado:** `Rules.map_zoom` y `Rules.map_camera_center` (fórmula de RF-251) y una `Camera2D` que `Game._fit_map()` agrega **solo si el mapa es más grande que 20×9** (con 20×9 no hay cámara: nada cambia). Se comprobó con una captura de un mapa de 26×12 jugándose: entra entero, queda centrado entre las dos barras (con unos 16 px libres a cada lado), la barra de arriba y la de torres no se achican, y las torres y los enemigos funcionan. Los tests comprueban que la posición de una torre y su alcance en el mundo dan exactamente lo mismo con y sin zoom, que la casilla bajo un punto de la pantalla es la correcta (centros y bordes), y que una oleada completa se juega en un mapa grande. **Lo que confirma la elección de D-037:** no hubo que tocar ni `BuildController`, ni torres, ni enemigos, ni proyectiles. 13 tests nuevos (567 en total).

- [x] **T118 · El editor respeta el tamaño**
  `LevelDraft` conserva el tamaño; `MapEditor` muestra el mapa entero con su zoom y convierte bien el clic.
  **Refs:** RF-254.
  **Hecho cuando:** los tests comprueban que abrir, editar y guardar un mapa de 26×12 no lo recorta, que el clic pinta la casilla correcta con zoom y que un mapa de 20×9 se ve como siempre; una captura muestra el editor con un mapa grande.
  **Resultado:** `MapView` se ajusta solo al tamaño del mapa (`_fit`: mismo zoom que en la partida y centrado en el área del mapa; con 20×9 queda exactamente como antes) y `cell_at_area()` convierte el punto del mouse en casilla con el zoom incluido. `LevelDraft` conserva el tamaño (`map_width()`, `map_height()`), corrige uno imposible al más cercano permitido y guardar y reabrir un mapa de 26×12 no lo recorta. La captura del editor con el mapa de ejemplo se ve entera, con el recorrido de 68 casillas y la casilla resaltada bajo el mouse. **Sigue sin poder cambiarse el tamaño desde el editor** (RF-254): un mapa grande se hace escribiendo el archivo o partiendo de uno existente. 11 tests nuevos (578 en total).

- [x] **T119 · Mapa de ejemplo y una partida completa**
  Un mapa de ejemplo de 26×12 (fuera del juego) y una partida completa con el bot en un mapa grande.
  **Refs:** RF-255.
  **Hecho cuando:** el bot juega una partida completa en el mapa de ejemplo sin errores, y el mapa se puede copiar a la carpeta de mapas de la comunidad y jugarlo.
  **Resultado:** `tools/ejemplos/mapa_grande.json` (26×12, camino de 68 casillas, 10 oleadas con casi todos los enemigos; **sin balancear**, es solo de ejemplo y queda fuera del juego exportado). `check_level` lo da por bueno sin avisos y el bot (`balance_sim`, que ahora acepta `file=ruta` para jugar cualquier archivo de nivel) lo juega entero: 10 oleadas, **victoria con 20 vidas** (demasiado fácil, pero no es un nivel del juego). Un test comprueba que el archivo es válido y que aparece en la carpeta de los mapas de la comunidad sin errores. 2 tests nuevos (580 en total).

- [x] **T120 · Cierre de M13: documentación y exportaciones**
  README, ONBOARDING, CONTENIDO.md; exportar los cuatro ejecutables.
  **Refs:** D-037.
  **Hecho cuando:** pasan todos los tests y el mapa de ejemplo se juega en el paquete exportado.
  **Resultado:** CONTENIDO.md (tamaño del mapa y el ejemplo), README y ONBOARDING (una prueba manual nueva, 6.1.05) al día. Se exportaron los cuatro (el de pruebas se pudo reemplazar esta vez: ya no estaba abierto). **Comprobación con el paquete exportado del juego normal:** el nivel 1 se ve idéntico a siempre, sin zoom ni errores. **Límite honesto:** el mapa grande **no se pudo jugar en el paquete exportado** sin copiar un archivo a la carpeta de mapas de Lucas (que tiene un mapa suyo, `test01.json`, y no quise tocarla); se comprobó con los tests, con la captura de la partida y del editor y con el bot, todos en el proyecto y no en el exportado. Además, **nadie probó todavía el zoom con el mouse o el dedo**.

---

## M14 — El editor de mapas para todos *(pedido por Lucas, D-038)*

- [x] **T121 · El botón "Editor de mapas" en el juego normal**
  El botón se ve siempre, salvo en el celular (donde solo se ve en el modo de pruebas).
  **Refs:** RF-210, D-038.
  **Hecho cuando:** los tests comprueban que el botón está en el menú normal y en el de pruebas, que no está en el celular (salvo modo de pruebas), y que el editor abierto desde el juego normal no cambia el progreso ni los niveles desbloqueados, y guarda en la carpeta de mapas; las exportaciones se comprueban.
  **Resultado:** El botón "Editor de mapas" está siempre en el menú, salvo en el celular (`MainMenu.editor_available`); el modo de pruebas lo ve siempre. Un test comprueba que abrirlo en el juego normal no cambia el progreso ni desbloquea niveles y que guarda en la carpeta de mapas. Se exportaron los cuatro y se comprobó con el paquete exportado del juego normal: el menú muestra Jugar, Récords, Wiki, **Editor de mapas**, Opciones y Salir, y entra en pantalla. 2 tests nuevos y 1 cambiado (582 en total).

---

## M15 — Leyenda y temas *(pedido por Lucas, D-039)*

- [x] **T122 · `tema` y `leyenda` en el archivo del nivel (sin dibujo todavía)**
  `LevelFile`, `LevelData` y `MapGrid` leen y validan los dos campos; una letra de leyenda es pasto o bloqueada; `LevelDraft` los conserva al abrir y guardar.
  **Refs:** RF-262, RF-264, RF-265, RF-266, RF-267.
  **Hecho cuando:** los tests comprueban cada error (letra prohibida, repetida, sin declarar, declarada y sin usar, tema o dibujo desconocido, más de 10 letras), que una letra construible se puede construir y una no, que los recorridos son **idénticos** con y sin leyenda, que abrir y guardar en el editor no pierde tema ni leyenda, y que los 7 niveles oficiales dan lo mismo que antes.
  **Resultado:** `MapThemes` (los siete temas) y `MapDrawings` (el catálogo de 22 dibujos y si cada uno es suelo u objeto) dan las listas válidas. `LevelFile` lee y valida `tema` y `leyenda` con un mensaje claro por error (letra prohibida, de más de un carácter, dibujo desconocido con el catálogo, clave mal escrita, más de 10 letras); `MapGrid.parse(filas, leyenda)` trata cada letra como pasto (construible) o bloqueada y **nunca como camino**: un test comprueba que recorridos, entradas, salida y casillas sin usar son **idénticos** con y sin leyenda. Una letra usada sin declarar dice que existe la leyenda; una declarada y sin usar es un aviso. `LevelData` y `Level` guardan el tema y los dibujos por casilla. `LevelDraft` los conserva al abrir y guardar (y guardar dos veces da el mismo texto). Los 7 niveles oficiales siguen sin tema ni leyenda. Todavía no se **ve** nada distinto: los dibujos son T123 a T125. 21 tests nuevos (603 en total).

- [x] **T123 · Los temas: base, desierto, nieve y volcán**
  `MapThemes` (los siete, con su paleta), `LevelDecor` con paleta y decoración de `X` por tema; el arte de desierto, nieve y volcán.
  **Refs:** RF-260, RF-261, RF-267.
  **Hecho cuando:** los tests comprueban que `pradera` da el mismo dibujo de siempre y que cada tema tiene sus colores y su decoración; las capturas muestran el mismo mapa en cada tema, para que Lucas las apruebe.
  **Resultado:** `MapThemes` ([código](../scripts/logic/map_themes.gd)) con la paleta y la decoración de **los siete temas** (los tres primeros trabajos, T123 y T124, salieron juntos: la paleta, la decoración del suelo y los dibujos de las casillas bloqueadas son la misma pieza de código), y `LevelDecor` pinta según el tema: fondo del suelo y del camino, y un detalle propio del suelo (arcos de duna, destellos de nieve, grietas con brasas, hojas caídas, barro con charcos, adoquines). Desierto, nieve y volcán llevan cactus, huesos, pinos, abetos, rocas rojas/nevadas/negras, grietas y columnas. **La pradera no cambió ni un píxel:** se comparó el dibujo de los niveles 1, 3 y 7 antes y después y hay **0 píxeles distintos**. Un test comprueba además que la paleta de la pradera son los números de siempre. El camino se lee sobre el suelo en todos los temas (un test mide la diferencia de claridad; **detectó** que en el bosque y el pantano el camino casi se confundía y se corrigió).

- [x] **T124 · Los temas: bosque, pantano y ruinas**
  El arte y la decoración de los tres temas que pidió Lucas.
  **Refs:** RF-260, RF-261.
  **Hecho cuando:** los tests del tema pasan para los siete; las capturas muestran los siete temas juntos, para que Lucas las apruebe.
  **Resultado:** Bosque (árboles, troncos, helechos, hojas caídas), pantano (juncos, troncos, hongos, barro con charcos) y ruinas (columnas rotas, bloques caídos, estatuas, adoquines). **Se hicieron 16 dibujos nuevos** en `assets/sprites/map/` con el estilo de los existentes (contorno `#2b2233`, sombra suave en el suelo, una faceta de luz). La hoja con los enemigos sobre el suelo y el camino de cada tema, a tamaño de juego, muestra que **todos se distinguen** gracias a su contorno oscuro (guía de arte §4). Un detalle de Godot que costó un rato: en una prueba con ventana, un `load()` en tiempo de ejecución de un SVG recién importado se dibuja **blanco**; con `preload` (como usa el juego) se ve bien. 15 tests nuevos (615 en total).

- [x] **T125 · Los dibujos de la leyenda**
  `MapDrawings` (catálogo), el arte de los dibujos y su pintado en `LevelDecor` (suelo que se une con los vecinos, objetos sobre el suelo).
  **Refs:** RF-263.
  **Hecho cuando:** los tests comprueban que cada dibujo del catálogo existe y se pinta, y que un dibujo desconocido es un error; las capturas muestran un mapa con lago, hielo, lava, barro y objetos.
  **Resultado:** `MapDrawings` ([código](../scripts/logic/map_drawings.gd)): el catálogo inicial de 16 dibujos (12 **objetos** y 4 **suelos**, vigentes al cerrar T125); T218 lo amplía a 22 dibujos, 18 objetos y los mismos 4 suelos. `LevelDecor` pinta un objeto sobre el suelo del tema y un suelo cubriendo la casilla, con su detalle (reflejos del agua, grietas del hielo, venas de la lava, manchas de barro) y **un borde donde la mancha termina** (no entre dos casillas iguales). El editor dibuja lo mismo (`MapView`). Las capturas de los siete mapas de ejemplo muestran un lago, un oasis, una laguna helada, un río de lava, flores, cactus, pinos y columnas sobre el paisaje de cada tema. 10 tests nuevos (625 en total).

- [x] **T126 · Cierre de M15: mapas de ejemplo, documentación y exportaciones**
  Un mapa de ejemplo por tema (fuera del juego), CONTENIDO.md, README, ONBOARDING; exportar los cuatro.
  **Refs:** D-039.
  **Hecho cuando:** pasan todos los tests y se ven los siete temas en el paquete exportado.
  **Resultado:** Un mapa de ejemplo por tema en `tools/ejemplos/tema_<tema>.json` (el nivel 4 con parches de leyenda; fuera del juego exportado, y un test comprueba que son válidos, sin avisos y con **los mismos recorridos** que el original). CONTENIDO.md (sección de temas y leyenda), README, ONBOARDING (una prueba manual nueva), guía de arte y **CHANGELOG.md**. Se exportaron los cuatro.

## M16 — El editor con temas y leyenda *(pedido por Lucas: "en otra etapa"; sin fecha)*

- [ ] **T128 · Tema y leyenda en el editor de mapas**
  Selector de tema en Ajustes, un botón por letra de la leyenda y "agregar letra".
  **Refs:** RF-266.
  **Hecho cuando:** los tests comprueban pintar con una letra de leyenda, agregarla y quitarla y cambiar el tema; una captura muestra el editor con un mapa temático.

---

## Mejora visual de enemigos (pedido por Lucas)

- [x] **T127 · Rediseño de los nueve sprites de enemigos**
  Siluetas diferenciadas, volumen y materiales, conservando especie, color, vista lateral y SVG de 64 × 64 (RF-151, RF-155, RF-167).
  **Hecho cuando:** los nueve SVG se importan en Godot, se revisan juntos a escala de juego e interfaz y pasan los tests de sprites y contenido.

  **Resultado:** nueve SVG rediseñados y renderizados con Godot 4.7.2; comparativa visual antes/después revisada, incluyendo lectura a 34 px. Los 67 tests existentes de sprites, contenido nuevo, catálogo y datos pasan (879 aserciones). Se conservan rutas, dimensiones, transparencia y parámetros de importación; no cambia el balance.

## Herramientas de trabajo *(pedido por Lucas, D-040)*

- [x] **T129 · Guía de arte y reglas por carpeta**
  `specs/05-guia-de-arte.md` y cinco reglas en `.claude/rules/`.
  **Refs:** D-040.
  **Hecho cuando:** la guía describe la técnica y la paleta reales de los enemigos redibujados y las reglas coinciden con la constitución.

  **Resultado:** la guía sale de los SVG reales (contorno `#202330` de ancho 2, degradé de 3 paradas, hueso `#fff0ce → #ab8c69`, ojos `#ffe19a`, apoyo en y≈57) y de la paleta del generador de los enemigos (`build/enemy-redesign/redesign.py`, no versionado). Incluye los **tonos libres** para enemigos nuevos y una regla de los temas del mapa (ningún enemigo puede perderse sobre ningún suelo; se aprueba con una hoja de contacto). Las reglas recogen los errores que ya nos pasaron. **No es código:** los tests no cambian (582).

---

## M17 — Enemigos con aura: Guardián y Curandero *(pedido por Lucas, D-041, D-042)*

- [x] **T130 · La mecánica del aura**
  Los tres datos de `EnemyData`, `Enemy.receive_aura` / `_pulse_aura`, armadura efectiva y cura extra.
  **Refs:** RF-270 a RF-273.
  **Hecho cuando:** los tests comprueban el daño con y sin aura (RF-80 con +2), que la quemadura la ignora, que no afecta al portador ni a los que están fuera del radio (borde incluido), que no se suman dos auras, que **caduca** en menos de 0,5 s al morir el portador y que la cura se suma a la regeneración y se corta al quemarse.
  **Resultado:** Los tres datos de aura en `EnemyData`; en `Enemy`, `receive_aura` (guarda el mayor valor y caduca), `_pulse_aura` (cada 0,25 s, a los demás dentro del radio), `armor()` (armadura propia + aura, la que usa `take_hit`) y la cura del aura sumada a la regeneración propia. 20 tests nuevos (645 en total): daño con +2 (criterio de aceptación: 5 → 3), mínimo de 1, suma con la armadura propia, dentro y fuera del radio (casi en el borde y un poco más allá; se probó con un margen porque comparar píxeles justo en el borde depende de decimales), también a los de atrás y a los voladores, la quemadura la ignora, dos auras iguales **no** se suman, gana la más fuerte, **caduca en menos de medio segundo** al morir el portador o al irse el enemigo, una débil no mantiene viva a una fuerte muerta, la cura tiene tope, se suma a la regeneración y se corta al quemarse, y el portador no se cura a sí mismo. Un detalle que costó un intento: `Enemy.setup` toma la vida como vida **máxima**, así que para probar a un enemigo herido hay que bajarle la vida después.

- [x] **T131 · Cómo se ve un aura**
  Anillo del portador e íconos del afectado en `Enemy._draw`.
  **Refs:** RF-274.
  **Hecho cuando:** una captura muestra un Guardián con su anillo y enemigos con el escudo, y un Curandero con el suyo y enemigos con la cruz, sobre dos temas distintos.
  **Resultado:** `Enemy._draw_aura_ring` dibuja un **círculo real** (el radio se mide en el plano del mapa) suave y que late, marfil dorado para armadura y verde amarillento para cura (dos anillos casi juntos si da las dos cosas), y `_draw_aura_icons` pone un **escudo** y/o una **cruz verde** chicos al costado del enemigo afectado. Una captura de una partida real sobre el tema de nieve muestra el anillo del Guardián, el del Curandero y las cruces sobre los enemigos cercanos, y el cartel de presentación del Guardián (RF-134) funciona solo.

- [x] **T132 · Los enemigos Guardián y Curandero**
  `data/enemies/guardian.tres` y `healer.tres`, sus dibujos y las líneas de aura en la Wiki.
  **Refs:** RF-275 a RF-277.
  **Hecho cuando:** pasan los tests de contenido y de la wiki para los dos, aparecen en el panel de pruebas, y la hoja de contacto los muestra junto a los otros nueve a 34 px sin confundirse con ninguno.
  **Resultado:** `data/enemies/guardian.tres` y `healer.tres`, con sus dibujos (`guardian.svg`, un gólem marfil con un escudo dorado remachado; `healer.svg`, una criatura flaca verde amarillenta con púas, colmillos y un bulbo luminoso). El primer intento del Curandero salió **demasiado simpático** (parecía una rana con una cruz) y lo rehice más anguloso, con púas y colmillos, siguiendo la guía de arte. La Wiki escribe su aura ("+2 de armadura a los enemigos a menos de 2 casillas"), el bestiario los muestra cerrados, y el panel de pruebas y el editor los ofrecen solos. **Como todavía no debutan en ningún nivel** (D-041), el test de la Wiki que exige que cada enemigo aparezca en un nivel tiene ahora una lista de "todavía no" con los dos, que se vacía cuando existan los niveles 8 y 9. 12 tests nuevos (657 en total).

- [x] **T133 · Una partida con auras y cierre de M17**
  Un mapa de ejemplo con los dos enemigos, una partida completa del bot, documentación, CHANGELOG y exportaciones.
  **Refs:** D-042.
  **Hecho cuando:** el bot juega el mapa de ejemplo sin errores y se ve cómo cambia el resultado con y sin el Guardián; pasan todos los tests.
  **Resultado:** `tools/ejemplos/mapa_auras.json` (el nivel 4 con tema bosque y diez oleadas con los dos enemigos; **sin balancear**, de ejemplo). **El bot lo gana con 20 vidas** con las estrategias `mix`, `basic` y `smart`, y con la misma partida cambiando los dos enemigos por un Tanque y un Troll el resultado es el mismo: el mapa es demasiado fácil para que el bot lo note, así que **el balance fino queda para el nivel 8 y el 9**, donde debutan (D-041). Lo que sí se mide es el **efecto del +2 de armadura** sobre cada torre nivel 1: Ametralladora 5 → 3 (−40 %), Hielo 2 → 1 (−50 %), Múltiple 7 → 5 (−29 %), Ráfaga 10 → 8 (−20 %), Eléctrica 13 → 11 (−15 %), Cañón 20 → 18 (−10 %) y Francotirador 40 → 38 (−5 %): castiga a las torres de golpe chico, como se diseñó. CONTENIDO.md, guía de arte, CHANGELOG y ONBOARDING al día; se exportaron los cuatro.

---

## M18 — Torres aturdidas: Chamán y Espejo *(pedido por Lucas, D-041, D-043)*

- [x] **T134 · La torre aturdida**
  `Tower.stun`, el grupo `Tower.GROUP`, dejar de disparar, el aspecto apagado y "Aturdida (N s)" en el panel.
  **Refs:** RF-280.
  **Hecho cuando:** los tests comprueban que una torre aturdida no dispara y vuelve a disparar sola al pasar el tiempo, que no se suma (queda el mayor), que se puede mejorar y vender, que la pausa la congela, y que el panel lo dice; una captura muestra una torre apagada.
  **Resultado:** `Tower` gana el grupo `Tower.GROUP`, `stun(segundos)` (queda el mayor, no se suma), `is_stunned()` y `stun_left()`. Aturdida **no dispara** (el enfriamiento sigue corriendo, así dispara casi enseguida al recuperarse) pero se puede mejorar, vender y cambiar de apuntado. Se ve **apagada** (más oscura) con tres chispas que giran encima, y el panel dice "Aturdida (N s)" con la cuenta atrás. La pausa la congela porque las torres son del mundo "pausable" (un test lo comprueba con `can_process()`; primero probé esperando con el juego pausado y **colgó la corrida de tests**, porque GUT también se detiene: por eso se prueba la propiedad y no el tiempo). 12 tests nuevos (669 en total).

- [x] **T135 · El Chamán**
  Datos, hechizo, rayo magenta, dibujo, Wiki.
  **Refs:** RF-281, RF-282, RF-285, RF-286, RF-287.
  **Hecho cuando:** los tests comprueban el intervalo (el primer hechizo tras un intervalo), que elige la torre más cercana y no la ya aturdida, el alcance (dentro, en el borde y fuera), que espera si no hay torres y que un Francotirador (alcance mayor) lo mata antes; una captura muestra el rayo y la torre apagada.
  **Resultado:** `stun_interval`, `stun_seconds` y `stun_range_tiles` en `EnemyData`; `Enemy._update_stun_spell` (primer hechizo un intervalo después de aparecer; apaga la torre **más cercana** dentro del alcance que **no esté ya aturdida**; si no hay, espera sin acumular y lanza apenas aparece una) y la señal `cast_stun`; `EffectsLayer.stun_bolt` dibuja un rayo magenta del Chamán a la torre y un anillo en ella (`LightningEffect` acepta color). `data/enemies/shaman.tres` y `shaman.svg` (encapuchado magenta con un bastón que chispea: usa uno de los dos tonos libres de la guía). La Wiki escribe su "Hechizo". Una captura de una partida real sobre el tema de ruinas muestra el cartel de presentación, la torre apagada (oscura, con chispas y anillo magenta). 15 tests nuevos (684 en total): datos, intervalo, repetición, la más cercana, saltear la ya aturdida, alcance (255 px sí, 258 px no), espera sin torres, si muere no lanza, si se vende la torre no falla, y una partida real. El Francotirador (6 casillas) alcanza más que el hechizo (4).

- [x] **T136 · El Espejo**
  El proyectil recuerda su torre; rebote, aturdimiento, destello y "¡Rebote!"; dibujo, Wiki.
  **Refs:** RF-283, RF-284, RF-285, RF-286, RF-287.
  **Hecho cuando:** los tests comprueban el criterio de aceptación (una torre cercana rebota y una lejana no), área, cadena y ráfaga, que la ralentización tampoco pasa, que la quemadura sí, y que una torre ya aturdida no vuelve a rebotar; una captura muestra el rebote.
  **Resultado:** `reflect_range_tiles` y `reflect_stun_seconds` en `EnemyData`; `Projectile.source` (la torre que disparó; `Tower` lo pone en cada disparo y cada púa); `Enemy.will_reflect` / `reflect` / señal `reflected`; en `Projectile._hit`, si el Espejo rebota el tiro no llama a `take_hit` (sin daño ni ralentización), **la quemadura sí se aplica** y la torre queda aturdida. `EffectsLayer.reflect`: anillo cian, y la primera vez el texto **"¡Rebote!"**. `data/enemies/mirror.tres` y `mirror.svg` (tortuga de cristal cian con placas facetadas; el otro tono libre de la guía). La Wiki escribe su rebote. La hoja de los 13 enemigos a 34 px muestra que el Chamán y el Espejo **se distinguen de todos**. 18 tests nuevos (702 en total): datos, el criterio de aceptación (una torre a 2 casillas rebota, una a 4 no), el borde a 2,5 casillas, medir al impactar, el Hielo no ralentiza, el fuego sí quema, el área, la cadena y la púa recta, una descarga entera rebota sin alargar el aturdimiento, sin torre de origen o con la torre vendida le pega normal, y una partida real. **Un error lo encontró un test:** pasar una torre ya borrada a una función que pide una `Tower` hace fallar el motor; ahora se comprueba antes con `is_instance_valid`. **Cambio a la spec:** RF-284 decía que una torre ya aturdida no volvía a rebotar, pero eso dejaba **colarse** los demás proyectiles de una descarga; ahora **todos rebotan** sin alargar el aturdimiento.

- [x] **T137 · Cierre de M18**
  Un mapa de ejemplo con los dos enemigos, una partida del bot, documentación, CHANGELOG y exportaciones.
  **Refs:** D-043.
  **Hecho cuando:** pasan todos los tests y las exportaciones se comprueban.
  **Resultado:** `tools/ejemplos/mapa_torres_apagadas.json` (el nivel 4 con tema de ruinas y diez oleadas con los dos enemigos; **sin balancear**). **Esta vez el bot sí los nota.** Con la misma partida cambiando el Chamán por un Troll y el Espejo por un Tanque: la estrategia `mix` termina con **10 vidas en vez de 20**, `smart` con 18 en vez de 20 y `basic` (solo Ametralladoras, todas cerca del camino) con **2 vidas en vez de 20**. Es lo que se diseñó: castigan a las defensas pegadas al camino y de poco alcance, y las mezcladas aguantan mejor. El balance fino queda para el nivel 10, donde debutan (D-041). CONTENIDO.md (los cinco datos nuevos), guía de arte (los dos últimos tonos), CHANGELOG, ONBOARDING y B-06/B-07 al día; se exportaron los cuatro.

## M19 — Torres de 2×2: el Mortero *(pedido por Lucas, D-041, D-044)*

- [x] **T138 · Torres de más de una casilla: datos y ocupación**
  `TowerData.footprint`, `Tower.origin_cell`/`cells()`, registro de ocupación por casilla, `can_build`, seleccionar y vender.
  **Refs:** RF-290, RF-291, RF-293, RF-294, D-044.
  **Hecho cuando:** los tests comprueban con una torre de prueba de `footprint` 2 el criterio de aceptación de RF-291 (tres casillas libres y una de camino: no se construye y no se cobra; cuatro libres: se construye), que un clic en cualquiera de las cuatro la selecciona, que ninguna se puede reusar, que vender devuelve el 70 % y libera las cuatro, el borde del mapa, y que las ocho torres de hoy no cambian.
  **Resultado:** `TowerData.footprint` (lado en casillas, 1 por defecto; las ocho torres de hoy no cambian). `Tower.origin_cell` y `cells()`; `BuildController.footprint_cells` (estática), `origin_for` (la casilla de origen para el mouse: con lado 1 es la de siempre y con lado 2 centra el cuadrado) y `cells_free`; `can_build` exige las cuatro casillas construibles y libres; `try_build` pone la torre en el **centro** del cuadrado y anota las cuatro casillas; `sell` las libera todas (antes calculaba la casilla desde la posición de la torre, que con el centro en una esquina habría fallado). Seleccionar, mejorar y vender funcionan igual. 13 tests nuevos (715 en total) con una torre de prueba de 2×2: construye en cuatro libres y ocupa las cuatro, en el centro, tres libres y una de camino **no** construye ni cobra, no se superpone con otra (ni con una chica en una sola casilla), bordes del mapa, falta 1 de oro, un clic en cualquiera de las cuatro la selecciona, vender devuelve el 70 % y libera las cuatro, mejorar. Todavía **sin vista previa ni dibujo** de la torre grande (T139): por ahora no hay nada en el juego que use `footprint` 2.

- [x] **T139 · Vista previa y dibujo de la torre grande**
  Vista previa centrada en el mouse con cuatro casillas verdes o rojas; `Tower._draw` escalado; anillo y aturdimiento escalados.
  **Refs:** RF-292, RF-295.
  **Hecho cuando:** los tests comprueban la casilla de origen para `footprint` 1 y 2 (mismo resultado de siempre para 1) y que el Chamán y el Espejo miden hasta el centro; una captura muestra la vista previa roja y verde y la torre construida.
  **Resultado:** La **vista previa** usa `origin_for` (centrada en el mouse para el 2×2, igual que siempre para 1×1), pinta **cada** casilla de la torre de verde o rojo, dibuja la torre fantasma del tamaño entero y el alcance desde el centro. `Tower._draw` escala con `footprint` (`_scale_factor`): base, sombra, torreta, cañón, retroceso, puntitos de nivel y chispas del aturdimiento; el anillo de construcción y el de venta crecen con el lado (`EffectsLayer.tower_built/tower_sold` con un `footprint` opcional). 4 tests nuevos (719 en total): origen para 1×1 y 2×2 (con mouse corrido media casilla), el dibujo del doble de tamaño, y que el Espejo mide hasta el **centro** (rebota a 2,4 casillas del centro y no a 2,6). **La captura de la vista previa roja y verde con la torre real queda para T140**, cuando exista el Mortero: hasta ahora solo hay una torre de prueba dentro de los tests.

- [x] **T140 · El Mortero y la barra de 9 torres**
  `mortar.tres`, torreta y bomba, tecla 9, barra y Wiki.
  **Refs:** RF-296, RF-297, RF-298, RF-299.
  **Hecho cuando:** los tests comprueban los datos (RF-296), la tecla 9, que la barra no tapa "Próxima oleada" y que la Wiki anota el tamaño; capturas de la barra, del Mortero construido en un mapa real y de su disparo con área.
  **Resultado:** `data/towers/mortar.tres` (footprint 2, con los números de RF-296, reusa `base_1..3`), torreta nueva `turret_mortar.svg` (tubo ancho de bronce sobre una placa redonda con remaches) y bomba `mortar.svg` (esfera oscura con mecha encendida), sonido `shot_mortar.wav` (golpe grave, sintetizado con `tools/make_sounds.gd`), acción `build_9` (tecla 9) y el Mortero como novena torre en `game.tscn`. **La barra**: con 9 botones de 86 px el último tapaba "Próxima oleada" (un test lo detectó), así que los botones pasan a 76 px y la separación a 10. Al elegirlo el HUD agrega "Necesita 2×2 casillas libres" (sale de `footprint`, no es un caso especial) y la Wiki anota "Tamaño: 2×2 casillas". La primera descripción era tan larga que se cortaba en la pantalla; se acortó. 14 tests nuevos (729 en total): datos, dibujos y sonido, tecla 9, la barra, el aviso, construir una real y su costo, dispara una bomba de área desde 4 casillas y la Wiki; se ajustaron los tests de la barra (9 torres), del límite de contenido y el de dibujos por nivel (el Mortero busca su cuadrado libre). **Capturas de una partida real** (nivel 1): vista previa **verde** sobre un 2×2 libre, **roja** sobre uno con una casilla de camino, el Mortero construido con su panel "Mortero · Nivel 1 (Daño 90, Cadencia 0.3/s, Alcance 5.0, Área: radio 1.5, Mejorar 250, Vender +210)" y la barra de 9 sin tapar nada. **No vi la bomba en vuelo** en ninguna captura (dispara cada 4 s y no la pesqué): solo la comprueba un test. Las cuatro casillas se ven bien pero el octógono de la base se ve un poco grande y simple al doble de tamaño; queda para la mejora de dibujos.

- [x] **T141 · Cierre de M19**
  Una estrategia del bot que compra Morteros, balance de partida, documentación, CHANGELOG y exportaciones.
  **Refs:** RF-296, D-044.
  **Hecho cuando:** pasan todos los tests, el bot muestra si el Mortero vale la pena contra enemigos duros (por ejemplo, el mapa de auras), los números de RF-296 se ajustan si hace falta y se comprueban las exportaciones.
  **Resultado:** El bot gana la estrategia **`heavy`** (como `mix` más un Mortero cada tanto, puesto donde el cuadrado libre cubre más camino; las estrategias de antes no cambian porque la búsqueda solo se ajusta para torres grandes). **Resultado honesto: el Mortero con estos números NO es una mejora automática.** Vidas al terminar, `mix` contra `heavy`: nivel 3 → 16 / **18**; nivel 4 → 6 / **derrota**; nivel 5 → 13 / 6; nivel 6 → 10 / 2; nivel 7 → 7 / **derrota**; mapa de auras → 20 / 20 (muy fácil); mapa de torres apagadas → 10 / **14**. Es decir: **ayuda donde hay Espejo y Chamán** (su alcance de 5 casillas supera al del hechizo, 4, y al del rebote, 2,5) y en el nivel 3, pero en los niveles con voladores (4 a 7) gastar 300 de oro en una torre que **no les pega** y que dispara cada 4 s deja al bot peor. Es razonable para una torre pensada contra blindados y jefes, y además el bot es tosco (la compra en un orden fijo); **no se tocaron los números** y el balance fino queda para los niveles 8 a 10, donde se combinan con los enemigos nuevos (D-041). README, CONTENIDO (`footprint` y la estrategia `heavy`), CHANGELOG y ONBOARDING (cómo probar el Mortero) al día; se exportaron los cuatro ejecutables y el de Windows arranca sin errores de script y trae `mortar.tres`. **Sin probar:** el Mortero a mano (solo capturas y tests), Linux y celular.

- [x] **T142 · El Mortero solo donde el nivel lo pide**
  `TowerData.reserved`, `"torres_extra"` en el archivo de nivel, barra y teclas filtradas, editor que lo conserva.
  **Refs:** RF-300, D-045.
  **Hecho cuando:** los tests comprueban que un nivel común tiene 8 torres y uno que habilita el Mortero tiene 9, la lectura del campo (válido, id que no existe, forma incorrecta, repetido), que el editor lo conserva y que el mapa de ejemplo lo usa.
  **Resultado:** `TowerData.reserved` (el Mortero lo es); `LevelData.extra_towers` y `available_towers()`; `LevelFile` lee `"torres_extra"` (con mensajes claros y la lista de torres que existen); `Game.available_towers` alimenta la barra y las teclas; `LevelDraft` conserva y escribe el campo. `tools/ejemplos/mapa_torres_apagadas.json` lo habilita (sirve para probarlo) y el bot `heavy` lo activa solo. 6 tests nuevos (735 en total) y se ajustaron los de la barra y de dibujos. **Hasta que exista el nivel 10, el Mortero no se puede jugar en la campaña.** La restricción es solo de interfaz (un test o el bot pueden construirlo directo).

## M20 — Sinergias, etapa A: reacciones por estado *(pedido por Lucas, D-041, D-046)*

- [x] **T143 · Los datos y el daño con bonus**
  `bonus_vs_slowed_percent` / `bonus_vs_burning_percent`, `Rules.damage_with_bonus`, `Projectile._hit`, los valores de Cañón, Francotirador, Mortero y Eléctrica.
  **Refs:** RF-310, RF-311, RF-312, D-046.
  **Hecho cuando:** los tests comprueban el criterio de aceptación (Cañón 25 contra ralentizado y 20 contra no; Eléctrica 17 contra quemado), que se suman los dos estados, el redondeo, que la armadura resta **después**, que un golpe de Hielo no se ayuda a sí mismo, y área, cadena y ráfaga; que un golpe rebotado no tiene bonus; y los datos de las cuatro torres.
  **Resultado:** `TowerLevelData.bonus_vs_slowed_percent` y `bonus_vs_burning_percent` (enteros, 0 = apagado); `Rules.damage_with_bonus` (redondeo al más cercano, antes de la armadura); `Projectile._hit` suma los bonus según el estado del enemigo **antes** de aplicar lo que trae el golpe y le pasa el daño ya calculado a `Enemy.take_hit`, que ahora recibe un `combo` y emite `combo_hit` (solo visual). Datos: Cañón, Francotirador y Mortero +25 % contra ralentizados en los tres niveles; Eléctrica +30 % contra quemados. 12 tests nuevos (747 en total): la cuenta, el criterio de aceptación (Cañón 25 contra 20; Eléctrica 17 contra 13), que cada torre solo aprovecha su estado, los dos estados suman (20 → 31), el bonus va antes de la armadura (25 − 3 contra 20 − 3), un golpe no se potencia con su propia ralentización, la señal solo sale con bonus, área y cadena miran a cada enemigo por separado, un golpe rebotado por el Espejo no tiene bonus, y los datos de **todas** las torres (solo esas cuatro tienen bonus). Todavía **sin aviso visual** (T144).

- [x] **T144 · Aviso visual, panel y Wiki**
  "¡Combo!" dorado, línea en el panel de la torre y en la Wiki.
  **Refs:** RF-313.
  **Hecho cuando:** los tests comprueban la señal, el texto del panel y de la Wiki y que la opción de números lo apaga; una captura muestra el combo.
  **Resultado:** `EffectsLayer.combo` dibuja **"¡Combo!"** dorado y un anillo chico sobre el enemigo (con las reglas de los números de daño: se apaga con la opción y tiene tope); `Game` lo conecta a la señal `combo_hit`. `TowerText.effects` escribe "+25 % de daño a ralentizados" / "+30 % de daño a quemados", así lo muestran **solos** el panel de la torre y la Wiki. 4 tests nuevos (751 en total): el texto dorado, que un golpe normal no lo muestra, que la opción de números lo apaga, y el panel y la Wiki (y que las demás torres no lo dicen). Captura de una partida real (Cañón + enemigos ralentizados): se ve el "¡Combo!" y el anillo sobre el enemigo golpeado; **queda algo amontonado con el número de daño** cuando varios golpes caen juntos (en la captura además yo ralentizaba a todos con golpes de 1 de daño para forzarlo).

- [x] **T145 · Cierre de M20**
  El bot compara partidas con y sin los bonus, documentación, CHANGELOG y exportaciones.
  **Refs:** D-046, RF-314.
  **Hecho cuando:** pasan todos los tests, el bot muestra cuánto cambian los niveles 1 a 7 y se revisan las exportaciones.
  **Resultado:** El bot jugó los siete niveles **sin** y **con** los bonus (vidas al terminar, sin → con). **`mix`** (las 8 torres): nivel 1 9 → 19, nivel 2 derrota → derrota, nivel 3 16 → 16, nivel 4 6 → 8, nivel 5 13 → 13, nivel 6 10 → 10, nivel 7 7 → **17**. **`smart`** (las 4 viejas, solo Cañón y Francotirador aprovechan): nivel 1 13 → 14, nivel 2 17 → 17, nivel 3 9 → 9, niveles 4 y 5 derrota → derrota, nivel 6 5 → **11**, nivel 7 derrota en la oleada 18 → derrota en la 11. **Lectura honesta:** ayuda sobre todo a `mix`, que sí compra Hielo, Incendiaria y Eléctrica; **ningún nivel se volvió trivial** ni se rompió, así que no se tocaron los números ni las oleadas. Dos cosas raras que **no investigué**: `smart` en el nivel 7 empeora (el bot compra en un orden fijo y el bonus cambia a qué enemigos mata primero), y el 9 → 19 de `mix` en el nivel 1 es un salto grande para un bot que tiene un solo Hielo; el bot es tosco y con un solo corrida por caso, no es una medición fina. README, CONTENIDO (los dos campos nuevos), CHANGELOG y ONBOARDING (cómo probarlo) al día; se exportaron los cuatro. **Sin probar:** jugarlo a mano, Linux y celular.

### M20, segunda parte — Que el combo se lea y se descubra *(pedido por Lucas, D-047)*

- [x] **T146 · El combo se ve y suena**
  El número de daño es el aviso (grande, "!", celeste o naranja), anillo del color del estado, "¡Combo de hielo/fuego!" la primera vez, sin amontonar, tope propio, visible con los números apagados, y el sonido `combo`.
  **Refs:** RF-315, RF-316, D-047.
  **Hecho cuando:** los tests comprueban el criterio de aceptación de RF-315 y RF-316: un golpe con combo muestra **un** número "N!" del color del estado y **no** el número blanco; el anillo; el texto de la primera vez sale una sola vez por estado; el naranja con una Eléctrica contra un quemado; con los dos estados manda el de más bonus; dos combos pegados en 0,15 s dan un número y dos anillos (y pasado ese tiempo, dos números); con los números apagados no hay número pero sí anillo y texto; el tope de 12; que el sonido existe y que `Audio.play` respeta el intervalo pedido. Se ajustan los tests de T143 y T144. Una captura de una partida real muestra el combo nuevo.
  **Resultado:** `Enemy.Combo` (`NONE`, `SLOWED`, `BURNING`) viaja como cuarto dato de la señal `hit`, y `combo_hit` desapareció: así el efecto recibe el daño **real** y sabe que es combo. `Projectile._hit` separa el bonus por ralentizado del bonus por quemado y elige el que dio más (si empatan, el ralentizado); la cuenta del daño no cambió. `EffectsLayer.combo(posición, daño, combo)` dibuja **"25!"** de 20 px en celeste (`COMBO_SLOWED_COLOR`) o naranja (`COMBO_BURNING_COLOR`), un anillo del mismo color, "¡Combo de hielo!" / "¡Combo de fuego!" la primera vez de cada uno en la partida, no repite el número a menos de 40 px y 0,15 s de otro (con un reloj propio de la capa), tiene su propio tope de 12, y con los números apagados deja el anillo y el texto. Se borró el dorado `COMBO_COLOR`. `Game._on_enemy_hit` elige entre el número blanco y el combo, y hace sonar `combo.wav` (dos notas agudas que suben, sintetizado con `tools/make_sounds.gd`) como mucho cada 0,15 s: `Audio.play` ganó un intervalo mínimo opcional. `tools/perf_test.gd` se ajustó a la señal nueva. 10 tests más (761 en total): los de T144 se reescribieron (número y color, nunca dorado ni blanco, la primera vez una sola vez, naranja con la Eléctrica, golpe común sin combo, números apagados, área sobre un grupo = un número y dos anillos, agrupación por distancia y por tiempo, tope propio que no ocupa lugar de los blancos) y se sumaron: qué estado aprovechó cada golpe, con los dos estados manda el mayor (y el Cañón contra un quemado y ralentizado cuenta solo el ralentizado), un tic de fuego nunca es combo, y el intervalo del sonido. **Capturas de partidas reales:** en el nivel 1 (Hielo y Cañón alternados) el primer combo muestra "¡Combo de hielo!" y "25!" celeste, claros; en el nivel 3, oleada 8, un "22!" celeste sobre un Blindado ralentizado se distingue a simple vista del "17" blanco de su vecino. **Lo que todavía se encima:** dos combos **seguidos** sobre el mismo enemigo con más de 0,15 s de diferencia (dos Cañones alternados) siguen mostrando dos números, y si el segundo lo mata, el "+5" dorado del oro sale encima; la regla de 0,15 s es para los golpes de área simultáneos, como pide RF-315. **No escuché** el sonido (no hay salida de audio en las pruebas): solo se comprobó que existe y su intervalo.

- [x] **T147 · El combo se descubre**
  `TowerText.combo_partners` y `combo_hint`, panel, Wiki, barra de construcción, artículo "Efectos de las torres" y la marca de "vulnerable".
  **Refs:** RF-317, RF-318, D-047.
  **Hecho cuando:** los tests comprueban el criterio de aceptación de RF-317 y RF-318: las líneas del Hielo (con y sin Mortero según el nivel) y de la Incendiaria, que una torre sin estado no dice nada, que se arman desde los datos (una torre de prueba con bonus aparece sola), el panel, la Wiki, la barra, el artículo; la marca aparece solo si el enemigo está en el estado **y** hay una torre que lo aprovecha, aparece al construir y se va al vender. Capturas del panel del Hielo, de la barra y de la marca en una partida real.
  **Resultado:** `TowerText.combo_partners(torre, torres)` arma "Combo: Cañón, Francotirador y Mortero +25 % a los que frena" / "Combo: Eléctrica +30 % a los que quema" leyendo los datos (de la más barata a la más cara, agrupadas por porcentaje; `join_names` une "A, B y C"); `combo_hint` da la frase corta de la barra desde los dos lados ("Combo: +25 % a ralentizados." en el Cañón). El **panel** recibe de `Game` las torres del nivel (`partner_towers`), así en el nivel 1 el Hielo nombra solo al Cañón y al Francotirador; la **Wiki** suma un apartado "Combos" en la ficha del Hielo y de la Incendiaria (con todas las torres, también el Mortero); la **barra** agrega la frase; el artículo "Efectos de las torres" explica los combos sin números. **Marca de "vulnerable":** `Enemy.set_exploitable` y `shows_vulnerable_mark`; una dianita celeste o naranja en la fila de los íconos de aura; `Game._refresh_exploitable` la recalcula al construir, mejorar y vender (sin contar la torre que se está vendiendo) y un enemigo nuevo la recibe al aparecer. **Dos arreglos que salieron de las capturas:** la línea del combo era más larga que las otras y **el panel se salía de la pantalla** por la derecha; ahora las estadísticas hacen salto de línea (`autowrap` en `tower_panel.tscn`) y el panel crece hacia arriba, con un espacio que no corta entre el número y el "%" (si no, quedaba "+25" en una línea y "%" en la otra). Y la dianita pisaba la punta de la barra de vida: se corrió 2 px. 17 tests nuevos (778 en total): las líneas del Hielo con y sin Mortero, la Incendiaria, torres que no dicen nada, una torre de prueba con bonus que aparece sola, cómo se unen los nombres, la frase de la barra de los dos lados, la ficha de la Wiki, el artículo sin números, el panel en el nivel 1, que la línea de la barra **entra** para las 9 torres (medida con la fuente real), que el panel no corta el "%", la barra; la marca con el estado y un Cañón (aparece al construir y se va al vender), sin el estado no hay marca, un enemigo nuevo ya la sabe, la naranja necesita una Eléctrica, y que se dibuja sin errores junto a los íconos de aura. Se ajustó un test de la barra (ahora la frase del Cañón termina con su combo). **Capturas de una partida real** (nivel 1): el panel del Hielo dice "Combo: Cañón y Francotirador / +25 % a los que frena" en dos líneas, dentro de la pantalla; las frases de la barra del Hielo, el Cañón y la Incendiaria entran; los enemigos ralentizados muestran la dianita celeste al lado de la barra de vida. **No vi en una captura** la dianita naranja (solo la comprueba un test) ni la barra con el Mortero (solo la mide un test).

- [x] **T148 · Cierre de la segunda parte de M20**
  Todos los tests, el bot (que el balance no cambió), README, CONTENIDO, CHANGELOG, ONBOARDING (cómo probarlo) y exportaciones.
  **Refs:** D-047.
  **Hecho cuando:** pasan todos los tests, el bot da los mismos resultados que antes en los niveles 1 a 7 (no se tocó el balance), la documentación dice cómo se ve y suena el combo ahora y se revisan las exportaciones.
  **Resultado:** Pasan los **778** tests. El bot original (`tools/balance_sim.gd`, corridas de a una para no sumar el ruido del temblor de pantalla, D-047) da **exactamente lo mismo que en T145** en los 14 casos: `mix` nivel 1 → 19 vidas, 2 → derrota, 3 → 16, 4 → 8, 5 → 13, 6 → 10, 7 → 17; `smart` nivel 1 → 14, 2 → 17, 3 → 9, 4 y 5 → derrota, 6 → 11, 7 → derrota en la oleada 11. El balance no cambió. ONBOARDING (6.1.10, cómo probar el combo a mano y qué mirar con ojo crítico), CHANGELOG, CONTENIDO (qué muestra el juego solo con poner el dato) y README al día. Se exportaron los cuatro (Windows, Windows de pruebas, Linux con su `.tar.gz` y Android de prueba), sin errores; el `.exe` arranca sin errores de script y trae `combo.wav`. **Sin probar:** jugarlo a mano (tiempo real, escuchar el "tin"), Linux y celular. **Lo que sigue (D-047):** que Lucas lo pruebe; si el combo todavía no pesa, especificar el "quiebre" (el combo frena en seco al enemigo un instante) y medirlo con el bot.


## M22 — Modo de pruebas: oleadas finales, velocidades y atajos *(pedido por Lucas, D-048)*

**Estado: hecho (2026-10-01), en la rama `m22-modo-pruebas`, con un PR. Lo aprobó Lucas.**

- [x] **T149 · Los datos y la lógica de la oleada inicial**
  `DevConfig` y `data/dev_config.tres`, `DevStart` (`clamp_wave`, `skipped_gold`, `start_gold`), `LevelSession.jump_to_wave`.
  **Refs:** RF-319, RF-320, RF-324, D-048.
  **Hecho cuando:** los tests comprueban el criterio de aceptación de RF-319 y RF-320 con los datos reales del nivel 1 (oleada 1 = oro del nivel; oleada 6 = oro del nivel + recompensas de las oleadas 1 a 5 + sus bonos), que las crías de la Araña suman, que un valor mayor que el total se ajusta, el oro a mano de 0, y que `jump_to_wave` deja la oleada, el estado y la señal bien y el HUD con la próxima oleada correcta. Nada de números nuevos en el código.
  **Resultado:** `DevConfig` (`scripts/data/dev_config.gd`) y `data/dev_config.tres` con el oro del botón (1000) y las cinco velocidades; `DevMode.config` lo carga y `Game.DEV_GOLD` / `DEV_FAST_SPEED` desaparecieron. `DevStart` (`scripts/logic/dev_start.gd`, sin escenas): `clamp_wave`, `enemy_reward` (suma las crías recursivamente, con un tope de 8 generaciones por si un dato se cierra en círculo), `skipped_gold` y `start_gold` (automático con un valor negativo; a mano desde 0). `LevelSession.jump_to_wave(n)` deja `wave = n-1`, avisa con `wave_changed`, no da oro y solo vale antes de la primera oleada. **Salió de probarlo:** el HUD, al recibir un salto, mostraba el cartel "Oleada 5" y la etiqueta "Oleada 5/10", como si la 5 empezara; ahora, si la oleada no es la siguiente a la anterior, no hay cartel y dice **"Próxima: oleada 6/10"**. 15 tests nuevos (793 en total, sin `SCRIPT ERROR`): los límites de `clamp_wave`, oro con la oleada 1 / 2 / 3, valor mayor al total, oro a mano de 0, crías (y crías de crías), el lazo de crías no cuelga, el nivel 1 real calculado por otro camino, que la Araña suma crías, los números de `dev_config.tres`, `jump_to_wave` (con sus bordes) y el HUD mostrando la oleada 6 como próxima. Se ajustaron dos asserts de `test_dev_panel.gd` que nombraban las constantes borradas. **Todavía no:** nada de esto se ve en el juego; la elección en pantalla es T150.

- [x] **T150 · Elegir la oleada y el oro al elegir nivel**
  Franja "Pruebas" en la selección de nivel, `Game` la aplica, esa partida no guarda progreso, y el oro automático se contrasta con el bot.
  **Refs:** RF-319, RF-321, D-048.
  **Hecho cuando:** los tests comprueban el criterio de aceptación de RF-319 y RF-321: la franja solo está en el modo de pruebas, la partida arranca con la oleada y el oro elegidos (campaña y comunidad), reintentar los repite, "Siguiente nivel" y volver los reinician, y no se guarda victoria, récord ni "enemigo visto" en una partida desde la oleada 2. Captura del selector. El resultado dice, con números, cuánto difiere el oro automático de lo que el bot juntó en los niveles 1 a 7.
  **Resultado:** `DevMode.start_wave` / `start_gold` guardan lo elegido (y `applied_wave`, la oleada con la que arrancó de verdad, ya ajustada al total) y `reset_start()` lo olvida. `level_select.gd` arma en código la franja **"Pruebas"** (Oleada inicial, Oro inicial con casilla "Automático" y un número a mano, y la aclaración "Si pasa del total del nivel, se usa la última oleada"), solo con `DevMode.enabled`; el tope del número es el nivel más largo (campaña y comunidad). `Game._apply_dev_start` salta a la oleada (`jump_to_wave`) y fija el oro (`LevelSession.set_gold`) solo si el nivel viene de la campaña o de un mapa de la comunidad: el editor, F6 y los tests quedan como antes. `GameFlow.dev_partial_run()` hace que `played_level()` devuelva `null`, `level_won` no guarde y `hall_of_fame_pending` sea falso, así no se guarda victoria, estrellas, desbloqueo, récords ni "enemigo visto"; la pantalla final igual deja salir. `GameFlow.forget_dev_start()` se llama en `next_level`, `go_to_main_menu` y `go_to_level_select`. 15 tests nuevos (808 en total, sin `SCRIPT ERROR`): la franja solo en el modo de pruebas y lo que escribe, el tope, que abrir la selección reinicia, oleada y oro automático / a mano / 0, oleada 1 = como siempre, 99 = última, mapa de la comunidad, sin nivel del menú no se aplica, reintentar repite, `forget_dev_start`, y que una partida desde la 6 no guarda victoria, puntos, desbloqueo, récord, Salón ni enemigos vistos (mientras una entera sí). **Captura** de la selección real: la franja entra entre las solapas y las tarjetas y todo cabe en 720 px.
  **Oro automático contra el bot** (estrategia `mix`, una copia del bot que suma todo el oro ganado, niveles 1 a 7, al terminar la oleada N-1; fórmula = lo que daría elegir la oleada N): nivel 1 oleada 5 → 513 contra 518, oleada 10 → 1711 contra 1716; nivel 2 → 652/652, 1691/1691, 3421/3451; nivel 3 → 620/620, 1635/1655, 3171/3191, 4591/4611; nivel 4 → 727/727, 1973/1973, 3949/3981; nivel 5 → 642/646, 1701/1705, 3526/3530, 5026/5030; nivel 6 → 618/618, 1733/1753, 3550/3618; nivel 7 → 966/970, 2269/2289, 4093/4113, 5673/5693. **Lectura honesta:** la fórmula nunca queda por debajo del bot y la diferencia es de 0 a 68 de oro (menos del 2 %, siempre explicada por enemigos que el bot dejó escapar), así que sí es un techo bastante ajustado. No se tocó la fórmula para que coincida.
  **Sin probar:** hacer clic de verdad en una tarjeta y jugar (las funciones que cambian de pantalla no se llaman en los tests); que `next_level` / `go_to_level_select` reinicien lo elegido se comprueba solo a través de `forget_dev_start`, no desde ellas.

- [x] **T151 · Cinco velocidades**
  Fila de botones x0,25 a x4 en el panel, la velocidad en el cartel y en el HUD, vuelta a x1, y la regla de `F`.
  **Refs:** RF-322, RF-324, D-048.
  **Hecho cuando:** los tests comprueban el criterio de aceptación de RF-322: cada botón fija `Engine.time_scale`, el cartel y el HUD dicen "x0,5" (no "x0"), al salir o terminar vuelve a 1 y el cartel se limpia, `F` en el juego normal sigue alternando 1 y 2, y desde x0,5 vuelve a 1. Se ajustan los tests de `dev_set_fast`. Captura del cartel con una velocidad.
  **Resultado:** El panel cambió el interruptor "Velocidad x4" por una fila **x0,25 · x0,5 · x1 · x2 · x4** (sale de `data/dev_config.tres`; el botón activo queda marcado, también cuando la velocidad cambia con la tecla `F` o al terminar la partida; un clic en el activo no lo apaga). `Game.dev_set_fast` pasó a `dev_set_speed(velocidad)`, y `Game.set_speed` le avisa a `DevMode.show_speed`, que reescribe el cartel ("MODO PRUEBAS · F1: panel · x0,5"; con x1 queda igual que antes; el cartel se ensanchó de 200 a 360 px y sigue centrado). `Rules.speed_text` escribe las velocidades con coma y **arregló el botón del HUD, que redondeaba y habría dicho "x0"**. `_reset_time` (salir, reintentar) y el fin de la partida devuelven la velocidad a x1 y limpian el cartel. `F` ahora hace "x1 → x2, cualquier otra → x1" (en el juego normal es igual que siempre). 12 tests nuevos (820 en total, sin `SCRIPT ERROR`; se quitó `test_speed_x4`): cómo se escribe cada velocidad, el botón del HUD (x0,5 y x0,25, no x0), un botón por velocidad, cada botón fija `Engine.time_scale`, solo el actual marcado, el marcado sigue a `F`, el cartel en cada velocidad y que el texto más largo entra y sigue centrado, salir y terminar vuelven a x1 y limpian el cartel, `F` desde x1 / x0,25 / x0,5 / x4, y el juego normal intacto. Un test escribió "x1,0" antes de arreglarlo: `String.num(1.0)` da "1.0". **Captura de una partida real a x0,5:** el panel muestra la fila con x0,5 marcado, el botón de arriba dice "x0,5 [F]" y el cartel de abajo "MODO PRUEBAS · F1: panel · x0,5". **No probé:** cómo se siente jugar a x0,25 durante minutos ni el audio a esa velocidad (no hay salida de audio en las pruebas).

- [x] **T152 · Atajos de teclado**
  Acciones `dev_*` en el `InputMap`, `F2` a `F4`, `F6` y `F7` (`F5` la usa Godot), las teclas escritas en el panel.
  **Refs:** RF-323, D-048.
  **Hecho cuando:** `test_dev_shortcuts.gd` comprueba que ninguna tecla de pruebas se repite con otra acción (con el modo prendido y apagado), que ninguna es `1`-`9`, que el juego normal no tiene las acciones, y que cada atajo hace lo mismo que su botón (matar, saltar, vidas, velocidad más lenta y más rápida, con sus bordes: en x0,25 no baja más y en x4 no sube más) y no actúa con el menú de pausa abierto.
  **Resultado:** `DevMode.ACTIONS` lista los cinco atajos (acción, tecla, texto) y `register_actions()` / `unregister_actions()` los crean y borran del `InputMap` al prender y apagar el modo, así el juego normal no los tiene; `DevMode.key_label` da el nombre de la tecla para el panel. `Game._handle_dev_shortcut` los atiende (con el panel abierto o cerrado, y no con el menú de pausa abierto) y hace lo mismo que cada botón: **`F2`** matar a todos, **`F3`** saltar oleada, **`F4`** vidas infinitas (el interruptor del panel se actualiza con la nueva señal `dev_infinite_lives_changed`), **`F6`** velocidad más lenta, **`F7`** más rápida (`DevStart.step_speed`, que no pasa de x0,25 ni de x4). El panel escribe cada tecla junto a su botón. **Cambio respecto de la spec, que salió del test:** el test que recorre el `InputMap` encontró que **`F5` ya la usa Godot** (`ui_filedialog_refresh`, los cuadros de archivos), así que las teclas quedaron `F2`, `F3`, `F4`, `F6` y `F7`; spec (RF-323), D-048 y plan se corrigieron. 15 tests nuevos (835 en total, sin `SCRIPT ERROR`): cada atajo tiene una sola tecla de función; **ningún atajo comparte tecla con ninguna otra acción** (las del juego y todas las `ui_*` de Godot, recorriendo el `InputMap` real; solo hay una `ui_*` con tecla de función y era la que chocaba); ninguno es `1`–`9` ni `F1`; las teclas del juego siguen donde estaban (`Esc`, `Espacio`, `P`, `F`, `U`, `S`, `1`–`9`), para que el test avise si se mueven; el juego normal no tiene las acciones y registrarlas dos veces no duplica la tecla; qué hace cada atajo (con el borde de que no baja de x0,25 ni sube de x4); funcionan con el panel cerrado; no actúan con el menú de pausa abierto; el juego normal ignora `F7`; el panel escribe las teclas; y `step_speed` con una velocidad fuera de la lista y con la lista vacía.
  **No probé:** apretar las teclas en una ventana real (los tests mandan el evento a `_unhandled_input`, que es por donde entra la tecla de verdad).

- [x] **T153 · Estadísticas de la partida de pruebas**
  `DevStats` (lógica sin escena que arma el diccionario) y su escritura en `user://pruebas_stats.json`.
  **Refs:** RF-325, D-048.
  **Hecho cuando:** los tests (con una ruta `user://test_*.json`) comprueban el criterio de aceptación de RF-325: los nombres, una fila por oleada, `"won"`, `"lost"` y `"left"`, que el archivo se reemplaza, que se lee con `JSON.new().parse`, y que el juego normal no escribe nada. Se compara con lo que imprime el bot en una situación concreta.
  **Resultado:** `DevStats` (`scripts/logic/dev_stats.gd`, sin escenas) junta una fila por oleada terminada y arma el informe con `level`, `start_wave`, `wave`, `total_waves`, `lives`, `gold`, `towers`, `result` (`won` / `lost` / `left`), `waves` (cada fila: `wave`, `lives`, `gold`, `towers`), `seconds` y `started_at`; `DevStats.write` lo guarda con `JSON.stringify` y reemplaza el archivo. `Game` lo arranca solo con el modo de pruebas, anota cada oleada al completarse (el oro ya trae el bono, como la línea del bot), lo escribe **una sola vez**: al ganar o perder, o al salir si no había terminado (`left`). El tiempo suma el `delta` de `_process` mientras no esté en pausa ni terminada la partida (es tiempo de juego: a x2 corre el doble). `DevMode.stats_path` es `user://pruebas_stats.json`; con un guardado de prueba (`set_enabled(true, ruta)`) es otro archivo al lado, así los tests no pisan el informe del jugador. **Salió de probarlo:** los tests que dejaban un `Game` para que GUT lo libere *después* de `after_each` escribían el informe `left` en el archivo real (apareció un `pruebas_stats.json` en la carpeta del jugador; lo borré); ahora `Game` no escribe si el modo ya se apagó, y hay un test para eso. 18 tests nuevos (853 en total, sin `SCRIPT ERROR`): los nombres documentados (y que no hay otros), los tres resultados, sin filas, el redondeo a décimas, que el informe no cambia después de armado, que escribir reemplaza y se lee con `JSON.new().parse`, una ruta imposible da `false`, dónde se escribe, ganar / perder / salir (`left`), salir después de terminar no pisa `won`, una fila por oleada con los números de ese momento (oro con el bono, 1 torre), una partida desde la oleada 6, cada partida reemplaza a la anterior, el tiempo no cuenta pausa ni partida terminada, y que el juego normal no escribe nada.
  **Comparado con el bot** (una copia del bot con el modo de pruebas prendido, `mix`, nivel 1, victoria con 19 vidas): las diez filas del informe (`gold`, `lives`, `towers` de cada oleada) y el resultado final coinciden **exactamente** con las diez líneas "oleada N terminada" que imprime el bot (por ejemplo la oleada 1: vidas 20, oro 65, torres 3; la 10: vidas 19, oro 236, torres 23). El informe da además 414 s de tiempo de juego, que el bot no mide.
  **No probé:** abrir el informe con otra herramienta (solo `JSON.new().parse` del propio juego) ni qué pasa si el disco está lleno (devuelve `false` y deja un aviso en el log, probado con una ruta imposible).

- [x] **T154 · `CLAUDE.md` en la raíz** *(aparte, chico)*
  Hoy no existe: lo que Claude necesita saber al abrir el proyecto, en un solo lugar.
  **Refs:** D-040 (reglas por carpeta), D-048.
  **Hecho cuando:** `CLAUDE.md` dice cómo correr Godot y GUT (con `--import` antes de los tests nuevos), el flujo SDD (spec, decisión, plan, tareas, código, commit; los números de RF y D no se reusan), la regla de "Sugerencias de Claude (consultar antes de implementar)" y que las reglas por carpeta están en `.claude/rules/` (con la lista); es corto (no repite la constitución) y todo lo que afirma se comprobó (los comandos se corrieron).
  **Resultado:** `CLAUDE.md` en la raíz (47 líneas): cómo se corre Godot y GUT (los comandos, el de importar, el del bot y el de la exportación de pruebas, con la diferencia entre PowerShell y Git Bash), el flujo SDD con la regla de no reusar números y el commit por tarea con `git push`, la regla de **"Sugerencias de Claude"**, la tabla de las cinco reglas de `.claude/rules/` y dónde está cada documento. No repite la constitución ni el contenido de las reglas. **Comprobado:** corrí los comandos de importar, de un test y de todos los tests (853 en verde), el bot (`balance_sim.gd`, varios niveles) y que `godot` se resuelve a `C:\Tools\Godot\godot.cmd` en PowerShell y no en Git Bash; la exportación se prueba en T155. **Sumé una advertencia que no estaba en ningún lado y encontré en esta sesión:** `godot --import` reescribe sin avisar algunos SVG de `assets/sprites/` y hay que mirar `git status` antes de cada commit. **No probé:** que Claude Code cargue el archivo en una sesión nueva.

- [x] **T155 · Cierre de M22**
  Todos los tests, sin `SCRIPT ERROR`, documentación y exportaciones.
  **Refs:** D-048.
  **Hecho cuando:** pasa GUT completo en verde y sin `SCRIPT ERROR`, se exporta **"Windows (pruebas)"** y se abre unos segundos sin errores, README, CONTENIDO, CHANGELOG y ONBOARDING (cómo probar la oleada final y mirar un combo a x0,25) quedan al día, y el resultado dice qué **no** se probó.
  **Resultado:** GUT completo: **853 tests en verde, sin `SCRIPT ERROR`** (partimos de 778 antes de M22). Exportado **"Windows (pruebas)"** (`build/JuegoA_pruebas.exe`, 117 MB, sin errores) y abierto con `--quit-after`: arranca, dice "Modo de pruebas activado", lista los 13 enemigos y no imprime ningún error de script (sí los avisos de recursos sin liberar al cerrar, que también salen en la corrida de GUT antes de M22). README (estado M22 y el modo de pruebas), CHANGELOG, CONTENIDO (`data/dev_config.tres`) y ONBOARDING (6.1.11: cómo probar la oleada final y mirar un combo a x0,25) al día. **Capturas de partidas y pantallas reales:** la selección de nivel con la franja "Pruebas" (T150) y una partida a x0,5 con el panel, el botón de arriba y el cartel (T151). **El oro automático coincide con lo que juntó el bot** (diferencia de 0 a 68 de oro en los siete niveles, T150) y **el informe coincide exactamente con las líneas del bot** (T153). **No probé:** hacer clic de verdad en una tarjeta del `.exe` exportado y jugar desde la oleada 10 (el exportado solo se abrió unos segundos; el flujo se probó con tests y capturas en el editor), apretar las teclas `F2` a `F7` en la ventana real, jugar a x0,25 con un combo a la vista (lo que motivó todo esto: queda para Lucas), ni las versiones de Linux y Android (no se tocaron los exportables ni los presets).

## M23 · Torres renderizadas (tres sprints, RF-326 a RF-328, D-049)

### Sprint 1 · Dirección y producción
- [x] **T156 · Producir las nueve torretas y tres bases.**
  **Refs:** RF-326, RF-328, D-049.
  **Hecho cuando:** fuentes conservadas, ocho vistas de cada mecanismo y tres bases transparentes, recorte reproducible y hoja de contacto a 64/34 px. Se actualiza la guía de arte para PNG y las tres familias.
  **Resultado:** nueve atlas RGBA de 512×256 (72 vistas de 128 px), nueve vistas independientes, tres bases y fuentes originales conservadas. Recorte por componentes de alfa, porque las hojas generadas cruzaban las celdas: no se cortan tubos ni cristales. Herramienta Godot reproducible; guía §7 actualizada. Hoja conjunta y ocho direcciones revisadas a tamaño de mapa/HUD. Los tests confirman que todos los cuadros tienen cuerpo y margen transparente. Las vistas son ilustraciones generadas, no geometría 3D: hay pequeñas variaciones de detalle entre ellas que quedan sujetas a la revisión visual de Lucas.

### Sprint 2 · Integración y efectos
- [x] **T157 · Integrar los atlas, disparos y efectos.**
  **Refs:** RF-327, RF-328, D-049.
  **Hecho cuando:** los nueve datos apuntan al nuevo arte; HUD/Wiki, ocho direcciones, retroceso y mejoras funcionan; disparos y efectos acompañan el estilo; tests relevantes pasan sin errores de script.
  **Resultado:** TowerVisual selecciona cuadros por ángulo con envoltura correcta; Tower dibuja la vista sin rotar la luz y mantiene retroceso/destello. HUD usa la vista norte y Wiki la textura renderizada. Los nueve datos usan PNG para mecanismo, base y proyectil; los SVG y formas simples siguen como compatibilidad para datos antiguos. Nueve proyectiles y cuatro texturas de impacto; frío/explosión suman sprites temporales, fuego usa llama renderizada también sobre enemigos, Tesla suma chispas violetas al rayo existente. Se incluyen los cuatro emblemas del HUD ya aceptado. 18 tests de sprites y seis tests nuevos de vistas, recursos y efectos pasan; las mejoras se comprobaron en escena real. Ningún número de balance cambió.

### Sprint 3 · Revisión del conjunto
- [x] **T158 · Revisar el juego y documentar la siguiente etapa.**
  **Refs:** RF-326 a RF-328, D-049.
  **Hecho cuando:** suite completa en verde, capturas reales del grupo y combate, documentación de formatos y lista de siguientes assets a rediseñar con prioridad. El resultado declara lo comprobado y los límites pendientes de revisión de Lucas.
  **Resultado:** 859/859 tests, 6599 asserts, 65 scripts, sin SCRIPT ERROR. Capturas reales de Godot del grupo de nivel 1, mejoras a nivel 3 y oleada, más una comparación preparada de impactos en la misma escena. Hoja conjunta a 64/34 px y revisión de las 72 vistas. Exportado `build/JuegoA_m23.exe` (113798512 bytes) y abierto en segundo plano: salida 0, modo de pruebas activado, sin errores de script. Las fuentes y muestras de `art/` se excluyen de las cuatro exportaciones. README, CONTENIDO, ONBOARDING y CHANGELOG actualizados; prioridades siguientes en `art/redesign-m23/README.md` y guía §7. Los avisos existentes de certificados/recursos al cerrar siguen apareciendo. **No probado:** una partida completa manual con este arte, estrés gráfico de 200 enemigos/60 torres, ni nuevos exportables Linux/Android. El giro visual es de ocho pasos; se conserva la puntería continua y la compatibilidad sin atlas. Se entregan fuentes y muestras para que Lucas revise variaciones pequeñas entre vistas y ajuste artístico futuro.

### Corrección del PR #1 · Validación de GUT
- [x] **T159 · Corregir recursos del HUD y limpiar la corrida de tests.**
  **Refs:** RF-319, RF-326, D-030, D-049. Pedido por Lucas, 2026-10-02.
  **Hecho cuando:** los cuatro iconos del HUD están versionados; no quedan llamadas obsoletas a wait_frames; el test con EnemyData circular libera su dato; una copia limpia de los archivos versionados importa, compila tools y pasa GUT sin errores de scripts/recursos inexistentes. Se actualiza el PR #1 y se revisa su CI. Los avisos residuales del motor se investigan y se declaran sin ocultarlos.

  **Resultado:** cuatro iconos del HUD y sus importaciones versionados en T157; 18 llamadas obsoletas migradas conservando el reloj de física. El test circular rompe su referencia y comprueba con WeakRef que el dato se libera. perf_test carga la escena y usa Node2D durante la ejecución para evitar compilar dependencias de autoloads antes de registrarlos. Copia limpia importada: 859/859 tests, 6600 asserts, sin deprecaciones ni errores de scripts o recursos inexistentes; seis tools revisados. La corrida local no mostró fugas; la copia limpia mostró dos objetos de audio de music_loop al cerrar, sin fallo de tests. No se oculta ese aviso. La CI remota no pudo leerse: GitHub devuelve 404 en el navegador sin sesión; se verifica el envío por la referencia Git del PR.

### M24 · Tanda 1 de diseño
- [x] **T160 · Preparar propuestas de monstruos, logo y evoluciones.**
  **Refs:** plan artístico art/PLAN_REDISENO_M24.md; pedido de Lucas, 2026-10-02.
  **Hecho cuando:** dos variantes para Normal, Rápido y Tanque; Cañón e Hielo con tres niveles; muestra del logo en el menú y comparación de escala sobre el mapa. Ningún recurso de producción se reemplaza antes de la selección.
  **Resultado:** seis PNG de monstruos, dos hojas de evoluciones y logo con escritura Monsters & Canons. Hojas comparativas y dos capturas reales de Godot; fuentes y prompts conservados. La escena de muestra carga sprites estáticos: no implica animación, habilidades ni integración de combate. Conserva menú y datos de producción. Pendientes selección, vistas direccionales, animaciones y estados. El nivel 1 de las evoluciones generadas es referencia; conservar el atlas aprobado al producir. Validación: 859 tests pasan, sin errores de scripts; captura sale con código 0. Persisten los avisos previos del motor sobre certificados y dos objetos/un recurso al cerrar GUT; no hubo errores de scripts.

### M24 · Tanda 2 · Integración de monstruos, logo y menú (RF-329 a RF-333, D-050)
- [x] **T161 · Spec, decisión, formato de la próxima entrega y copias de producción de los monstruos.**
  **Refs:** RF-329, RF-330, RF-333, D-050. Pedido por Lucas, 2026-10-02 (selección: `normal_B`, `fast_A`, `tank_A`, `logo_corrected`).
  **Hecho cuando:** la spec (§15), la decisión D-050 y el plan (§6.20) están escritos; `art/FORMATO_PROXIMA_ENTREGA_M24.md` dice qué hace falta pedir para vistas, animaciones y evoluciones; una herramienta de Godot reproducible genera los tres PNG de producción en `assets/sprites/enemies/rendered/` sin tocar `art/redesign-m24/sources/`, con alfa, el cuerpo recortado, escalado a un mismo marco y los pies a la misma altura.
  **Resultado:** `tools/prepare_monster_sprites.gd` recorta el cuerpo por opacidad (> 0,1), lo achica premultiplicando el alfa (sin halos en el borde) y lo apoya en un lienzo de 256×256 con los pies al 74,55 % del alto y el cuerpo a lo sumo al 63,4 % de alto y 98 % de ancho. Generó `normal.png`, `fast.png` y `tank.png` (RGBA, 53/54/78 KB) desde las fuentes de 1314×1197, 1536×1024 y 1328×1184. Miré el PNG de la bestia y los pies caen donde se esperaba. Las fuentes, prompts y muestras de `art/redesign-m24/` no se tocaron. **Todavía no** se usan en el juego (T162). **No probé:** la herramienta con otra versión de Godot.

- [x] **T162 · Integrar Normal, Rápido y Tanque en partida, Wiki, próxima oleada y presentación.**
  **Refs:** RF-329, RF-330, D-050.
  **Hecho cuando:** los tres datos usan los PNG de producción; sus números, IDs, tamaño y habilidades no cambian; no se reflejan en espejo; el parpadeo, la ralentización, la quemadura y la barra de vida siguen funcionando; tests en verde sin `SCRIPT ERROR`; captura real en Godot.
  **Resultado:** `normal.tres`, `fast.tres` y `tank.tres` apuntan a `assets/sprites/enemies/rendered/*.png` y suman `flip_when_walking_left = false` (campo nuevo de `EnemyData`, `true` por defecto, así que los otros diez enemigos no cambian). `Enemy.is_drawn_mirrored()` decide el espejo y `_draw` lo usa. La Wiki, "Próxima oleada" y la presentación de enemigos usan `enemy.texture`, así que se actualizaron solas (`EnemyShape` y `WikiIcon` dibujan una textura cuadrada). Para que la barra de vida quede donde estaba, el cuerpo se achicó al 63,4 % del lienzo (`MAX_BODY_HEIGHT`); `tools/prepare_monster_sprites.gd` se volvió a correr. Tests: 864 en verde, 6664 asserts, sin `SCRIPT ERROR`. Nuevos: PNG con alfa y márgenes, pies en la misma fila (191) y cabeza por debajo de `sprite_top`, el espejo (apagado en los tres, encendido en los otros tres probados), los números de balance de los tres iguales a los de antes (tomados del commit anterior; ninguno tiene armadura), y que se dibujan golpeados, ralentizados y quemados. Se ajustó el test del parpadeo blanco (ahora mira el centro del PNG de 256 px). **Captura real** (`tools/capture_m24.tscn`, `art/m24-integracion/monstruos_mapa.png` y `monstruos_zoom.png`): doce monstruos sobre el camino con torres al lado, con barra de vida, escarcha y tinte celeste, llamitas y dianita de combo; los pies caen sobre la sombra. **Límites:** son imágenes estáticas: miran siempre hacia el mismo lado (a la derecha en los tres) aunque caminen a la izquierda, no tienen cuadros de caminar, daño ni desaparición, solo el bamboleo y el parpadeo del juego; ninguno de los tres tiene armadura ni corona (el Tanque quita 2 vidas, menos que el umbral de 5), así que esas dos lecturas no se vieron con estos dibujos (se vieron con los otros enemigos, sin cambios); el diablillo es rojo y el tinte celeste de la ralentización lo oscurece más que a los otros dos.

- [x] **T163 · Logo Monsters & Canons y botones del menú.**
  **Refs:** RF-331, RF-332, D-050.
  **Hecho cuando:** el menú muestra el logo aprobado en lugar de "JuegoA" y "Tower Defense"; los botones tienen acabado de hierro, borde de bronce, relieve y acento ámbar al pasar el mouse o recibir el foco; texto legible, teclado y adaptación a la ventana, con tests y capturas reales.
  **Resultado:** `tools/prepare_logo.gd` genera `assets/ui/logo.png` (1024×487, con alfa) desde `logo_corrected.png` (la fuente no se toca). `main_menu.tscn` cambia los dos rótulos por un `TextureRect` `Logo` que conserva la proporción (con filtro de mipmaps, D-023) y `MainMenu.logo_height()` (estática) lo achica si la ventana es baja. `assets/ui/menu_theme.tres` es un `Theme` solo para las filas del menú (el resto del juego no cambia): hierro oscuro, borde de bronce de 2 px con el de abajo de 4 px (relieve) y sombra, hover con borde y texto ámbar y un resplandor suave, foco con un contorno ámbar de 3 px que no tapa el texto, presionado más oscuro, desactivado apagado. Botones de 52 px de alto. `tests/test_main_menu_style.gd` (8 tests): no quedan los títulos, el logo tiene alfa y proporción, `logo_height` baja con ventanas bajas y nunca desaparece, logo y botones entran en la pantalla sin superponerse, estilos de hierro/bronce/ámbar, **contraste del texto ≥ 4,5:1 en cada estado (3:1 el desactivado), calculado con la fórmula WCAG**, tema solo del menú y navegación con flechas (Jugar con foco al abrir, cada botón enfocable, cada flecha abajo va al siguiente). Suite completa: 872 en verde, sin `SCRIPT ERROR`. Capturas reales (`art/m24-integracion/menu_reposo.png`, `menu_foco.png`). **Límites:** el contraste del hover no es una medición de píxeles, es de los colores del tema; el menú se vio solo a 1280×720 (el juego escala todo con `canvas_items`, así que otras ventanas ven la misma composición ampliada); las pantallas que se abren desde el menú (opciones, selección de nivel…) conservan sus botones de siempre.

- [x] **T164 · Cierre de la tanda M24 de monstruos y menú.**
  **Refs:** RF-329 a RF-333, D-050.
  **Hecho cuando:** suite completa en verde y sin `SCRIPT ERROR`/`Parse Error`; importación y tests desde una copia limpia de los archivos versionados; ejecutable Windows de pruebas exportado y abierto sin errores; capturas reales de menú, monstruos en el mapa y Wiki; documentación al día; límites declarados.
  **Resultado:** Suite completa en el proyecto: **872 tests, 6726 asserts, sin `SCRIPT ERROR` ni `Parse Error`** (partimos de 859 antes de esta tanda). **Copia limpia** (`git archive` del commit a una carpeta nueva, `--import` y GUT completo): 872/872 en verde, sin errores de scripts ni recursos inexistentes; los `ERROR`/`WARNING` que se ven son los ya conocidos (un `push_error` esperado de un nivel inexistente, el guardado ilegible de prueba, el error de certificados de mbedtls y los dos objetos que quedan al cerrar), no los oculté. Exportado **"Windows (pruebas)"** → `build/JuegoA_m24.exe` (114 902 376 bytes, SHA-256 `83C0D185…9F13CE9`): abre con `--quit-after`, dice "Modo de pruebas activado", lista los 13 enemigos y no imprime errores de script. Capturas reales de Godot en `art/m24-integracion/`: menú en reposo y con foco, doce monstruos en el mapa (ralentizado, quemado, con barra de vida) y la Wiki de Tanque, Rápido y Normal. README, CONTENIDO, ONBOARDING, CHANGELOG y guía de arte (§8) al día. **Evoluciones (RF-333):** se revisó `upgrades_comparison.png` y **no se integró nada**: son hojas de una sola dirección y las torres usan atlas de ocho vistas; el nivel 1 conserva el atlas de M23 y el formato que falta pedir quedó en `art/FORMATO_PROXIMA_ENTREGA_M24.md`. **Coordinación:** no se tocó `art/redesign-m24/sources/`, sus prompts ni muestras, ni `art/redesign-m25/` ni `art/prototypes/`; los `.import` que Godot creó en esas carpetas no se versionaron. **No probé:** jugar una partida entera ni mirar el menú a mano en el `.exe` exportado (solo arrancó unos segundos y los tests y capturas se hicieron en el editor), pasar el mouse por los botones (el hover se probó por sus colores y el foco en una captura real), Android ni Linux, ni mirar los monstruos a otros zooms del mapa. Siguen los límites de T162: imágenes fijas que miran siempre al mismo lado, sin cuadros de caminar, daño ni desaparición.


### M25 · Animaciones y segunda tanda de monstruos
- [x] **T165 · Producir locomoción de los tres elegidos y cinco conceptos físicos.**
  **Refs:** RF-329, RF-330, formato art/FORMATO_PROXIMA_ENTREGA_M24.md; pedido de Lucas, 2026-10-02.
  **Hecho cuando:** Normal B, Rápido A y Tanque A tienen cuatro direcciones y cuatro pasos; se entregan atlas normalizados y visor de Godot; Blindado, Troll, Volador, Araña y Cría tienen propuestas para selección; Claude recibe guía de formato sin tocar su integración.
  **Resultado:** tres atlas RGBA de 1024x1024, cuadros de 256x256, 48 cuadros distintos con contenido y margen transparente; pies (128,191), cuerpo máximo 63,3 %. Fuentes generadas con image_gen conservadas. Separación de 16 figuras por alfa corrige la cuadrícula irregular original sin arrastrar fragmentos vecinos. GIF de comparación, captura real y visor animado de Godot, cinco propuestas y HANDOFF_CLAUDE.md. 872/872 tests, 6726 asserts, sin SCRIPT ERROR ni Parse Error; empaquetador y visor salen con código 0. Avisos previos de certificados y dos objetos/un recurso al cerrar persisten. No se modificó código o datos de producción. Pendientes: integración de las animaciones en ruta real, selección de las cinco criaturas nuevas; no se produjeron ciclos independientes de golpe/muerte ni el resto del bestiario/evoluciones, que corresponden a las siguientes tandas. Variaciones pequeñas entre poses generadas requieren revisión en combate.

### M26 · Fondos y aprobación de la segunda tanda
- [x] **T166 · Producir suelos y decoración con volumen, y preparar las criaturas aprobadas.**
  **Refs:** RF-126, RF-154, RF-260, RF-261, RF-329, RF-330; autorización de Lucas, 2026-10-02.
  **Hecho cuando:** siete suelos, camino y un grupo de decoración tienen recursos preparados; se revisan repetición y contraste en Godot; las cinco criaturas de M25 quedan registradas como aprobadas; Claude recibe fuentes, formatos y límites de integración.
  **Resultado:** ocho texturas opacas 256x256 con lados opuestos iguales, cinco objetos RGBA128 (rocas A/B, árbol, arbusto, puerta), y cinco monstruos aprobados RGBA256 preparados mediante la herramienta de M24. Fuentes y prompts de image_gen conservados; franjas de borde suavizadas y reducción de objetos con alfa premultiplicado. Hojas de repetición y decoración, capturas reales del Game antes/después y MainMenu con la pradera nueva, manifest y HANDOFF_CLAUDE.md. 872/872 tests, 6726 asserts, sin SCRIPT ERROR/Parse Error. Tamaños, opacidad, alfa y continuidad de los ocho materiales comprobados. Las escenas de producción y datos no se modificaron; las muestras usan instancias temporales y retratos estáticos. No se exportó un exe ni se probaron todos los niveles, zooms, móviles o estrés. Objetos específicos de otros paisajes y suelos de leyenda aún conservan arte anterior. Las cinco criaturas aceptadas todavía necesitan animaciones e integración. Persisten avisos previos de certificados y dos objetos/un recurso al cerrar.

- [x] **T167 · Integrar fondos y decoración M26.**
  **Refs:** RF-334, D-051.
  **Hecho cuando:** partida, menú y editor usan los materiales nuevos; los siete temas se dibujan y GUT pasa sin errores de scripts.

  **Resultado:** ocho materiales y cinco objetos copiados a assets y conectados a MapThemes/LevelDecor. Se retiraron los detalles procedurales de suelo sustituidos; leyendas especiales y TileSet lógico intactos. 873/873 tests, 6735 asserts, incluidos dibujo de los siete temas y fallback de recursos, sin SCRIPT ERROR/Parse Error. Importación correcta. Persisten los avisos previos de certificados y dos objetos/un recurso al cerrar. No se integraron los monstruos/animaciones pendientes ni se exportó un nuevo ejecutable.

### M27 · Evoluciones y monstruos especiales
- [x] **T168 · Producir evoluciones de las nueve torres y cinco monstruos especiales.**
  **Refs:** RF-335, RF-336, D-052.
  **Hecho cuando:** hojas e iconos de niveles 2/3 y cinco conceptos están guardados, revisados y acompañados por muestras, prompts y límites honestos de integración.

  **Resultado:** 18 atlas RGBA512×256, 144 cuadros distintos de128×128 con margen transparente y 18 iconos N, conservando nivel1. Cinco especiales estáticos RGBA256 con enmarcado M24. Fuentes y prompts de image_gen guardados; cuatro hojas rehechas por margen/transparencia antes de empaquetar. Validación de dimensiones, contenido, cuadros únicos y pies; visor de ocho vistas y cuatro capturas reales de Godot, dos usando escenas Tower/Enemy y copias temporales de datos. Preparadores y visores salen0; 873/873 tests, 6735 asserts, sin SCRIPT ERROR/Parse Error. Persisten errores locales de certificados y avisos intermitentes de recursos al cerrar herramientas. **Límites:** propuestas pendientes de aprobación e integración; no se cambiaron datos/escenas de producción ni balance, no se exportó.exe; no se probaron disparos/retroceso con nuevos atlas ni se produjeron animaciones de los cinco especiales. La diferencia2→3 es discreta en varias familias y puede ajustarse después de la revisión visual.

- [x] **T169 · Aplicar evoluciones y cinco especiales a la partida.**
  **Refs:** RF-337, D-053.
  **Hecho cuando:** mejoras usan los18 atlas nuevos, los cinco especiales usan sus PNG, y pruebas/capturas verifican la integración sin cambiar balance.

  **Resultado:**18 atlas y cinco monstruos copiados a assets e importados. Atlas opcional en TowerLevelData, selección por nivel en Tower con fallback al atlas original y asignaciones en nueve tipos; cinco especiales sin reflejo. Capturas usando los datos reales en art/m27-integracion. Suite875/875,6975 asserts; tests nuevos de selección/fallback y recursos, y contrato de sprites extendido a los especiales. Sin SCRIPT ERROR/Parse Error. No se modificaron estadísticas, habilidades, colisiones ni proyectiles; persistieron avisos previos de certificados y dos objetos/un recurso al cerrar. No se exportó nuevo.exe ni se añadieron animaciones a los especiales.

- [x] **T170 · Muestras de escala, movimiento, resolución y montaje.**
  **Refs:** RF-338, D-054.
  **Hecho cuando:** se entregan comparaciones de los cuatro problemas sin cambiar producción, changelog al día y descripción del PR a cargo de Lucas, según su indicación posterior.

  **Resultado:** comparaciones de13 enemigos con tamaños actual/+20%/+35%, GIF de24 cuadros de caminar y vuelo, capturas reales1280×720/1920×1080, montaje A en tres familias/tres vistas y conceptos B/C. Prototipo de vuelo con cabeza estabilizada, fuentes y prompts conservados. Changelog al día. Producción intacta; propuestas pendientes de aprobación. La descripción del PR queda a cargo de Lucas por pedido explícito; no se modificó. No se probaron Linux/celular ni nuevas colisiones o transiciones; no se exportó.exe.

  **Verificación T170:**875/875 tests,6975 asserts; sin SCRIPT ERROR/Parse Error. Capturas y empaquetado salen0.

### M29 · Cambios aprobados en partida
- [x] **T171 · Integrar escala, ciclos, migraciones, encastre C y escritorio Full HD.**
  **Refs:** RF-339 a RF-341, D-055.
  **Hecho cuando:** los trece diseños están conectados; +20 % no altera radios; ciclos existentes y vuelo se dibujan por cuadro; las nueve torres encastran con C; iconos coherentes; escritorio se adapta a1920×1080; capturas, pruebas y changelog disponibles, commit y push al PR #1. La descripción del PR queda a cargo de Lucas.

  **Resultado T171:** los13 diseños renderizados están conectados; aumento visual20% independiente del radio y con pies anclados. Tres atlas de cuatro direcciones/poses por distancia y cuatro poses de vuelo; nueve restantes siguen estáticos, sin deformación global. Cotas por pose para barras y silueta blanca nativa conservando alfa. Tres bases C compartidas,24 vistas nuevas del Cañón e iconos compuestos HUD/Wiki; otras ocho torres conservan sus mecanismos con asiento/contacto nuevos. Ventana de escritorio objetivo1920×1080, limitada al monitor, lienzo1280×720 conservado y móvil/headless respetados. Fuentes, prompts y capturas reales con GIF de24cuadros. **883/883 tests GUT,7178 asserts,67 scripts**, sin SCRIPT ERROR/Parse Error ni fallos. Captura sale0; Windows de pruebas exporta y arranca headless con13 enemigos, salida0; Linux exporta y se empaqueta pero no se ejecutó. Persisten avisos previos del almacén de certificados del entorno. No se produjeron ciclos para los nueve estáticos ni se ejecutó móvil. Changelog/README/CONTENIDO/ONBOARDING al día. La descripción del PR queda a cargo de Lucas.

  **Ventana real Windows:**1920×1080 sobre monitor con área útil2560×1400; lienzo lógico confirmado1280×720. Capturas Full HD y arranque exportado correctos.

### M30 · Brillo de mejoras
- [x] **T172 · Hacer legibles las mejoras con reflejos programáticos.**
  **Refs:** RF-342/RF-343, D-056.
  **Hecho cuando:** las nueve torres distinguen niveles2/3 con reflejos localizados sin cambiar sombras o balance, se verifica pausa/aturdimiento/pose, hay captura y GUT en verde y se sube al PR#1.

  **Resultado T172:** reflejo aditivo localizado por luminosidad original y alfa, intensidad por nivel y color por familia, en las nueve torres. AtlasTexture/material reutilizados, pose/retroceso/huella coherentes; pausa física congela pulso y aturdimiento apaga la capa. Atlas y sombras intactos. Captura real1920×1080 revisada, shader sin errores. **886/886 tests GUT,7230 asserts,68 scripts**, sin SCRIPT ERROR/Parse Error/SHADER ERROR. Windows de pruebas exportado y arrancado headless, salida0; Linux exportado y empaquetado, sin ejecutar. Changelog y documentación al día; nueve enemigos pendientes de ciclos propios registrados (no se produjeron animaciones en esta tarea). Descripción del PR a cargo de Lucas.

### M31 · Animaciones pendientes
- [x] **T173 · Producir e integrar los nueve ciclos restantes.**
  **Refs:** RF-344, D-057.
  **Hecho cuando:** nueve hojas y atlas de16poses propios, conectados en partida con apoyo/tamaño/velocidad coherentes, habilidades conservadas, capturas/GIF y suite GUT en verde, documentación y changelog al día, exportación y push al PR#1.

  **Resultado T173:** nueve fuentes y atlas integrados,144poses únicas, apoyo fila191 y escala constante por especie; doce caminantes más el vuelo existente. Balance y habilidades comparados con HEAD sin diferencias. Captura real1920×1080 y GIF revisados;889/889 tests GUT,8048 asserts,68 scripts, sin SCRIPT ERROR/Parse Error. Windows y Linux exportados; arranque Windows headless comprobado, Linux sin ejecutar. Persisten avisos de certificados y de limpieza (2 ObjectDB/1 recurso) al cerrar la suite/captura. No se añadieron ataques/muerte ni se cambiaron sombras. Documentos/changelog actualizados; descripción del PR a cargo de Lucas.

### Registro de backlog · 2026-10-02
- [x] **T174 · Registrar prioridades de interfaz, presentación y futuras mecánicas.**
  **Refs:** backlog §13, B-10 y B-17 a B-23; propuesta B1 existente.
  **Hecho cuando:** propuestas de Lucas anotadas con prioridad media, niveles8–10 relegados, investigaciones y revisión previa al merge explícitas; sin implementar cambios de juego.
  **Resultado T174:** siete entradas agregadas al backlog existente, prioridad baja para completar campaña y vínculo con B1 sin duplicar la mecánica. Solo documentación revisada; no se modificaron escenas, assets, datos ni código y no se ejecutó GUT porque no hay cambios de ejecución.

### M32 · Interfaz compacta
- [x] **T175 · Implementar B-17/B-18.**
  **Refs:** RF-345/RF-346, D-058.
  **Hecho cuando:** HUD compacto con ayudas, barra/pausa/admin renovados, FPS/ms sobre partida independiente del panel, captura y GUT correctos, docs y push.

  **Resultado T175:** iconos y cifras con tooltip y ayuda por foco; oleada compacta, bonus en ayuda de estado. Barra/pausa/admin hierro-bronce, controles agrupados. Monitor local sin fondo, independiente del panel, dos refrescos por segundo, FPS y ms estimados (1000/FPS), sin búsquedas de actores ni envío remoto. Capturas Full HD revisadas;891/891 GUT,8065 asserts,68 scripts, sin SCRIPT ERROR/Parse Error. Windows/Linux exportados, arranque Windows headless salida0; Linux y móvil sin ejecutar. Persisten avisos previos de certificados/limpieza al cerrar. Otros submenús siguen pendientes B-19.

### M33 · Submenús
- [x] **T176 · Renovar Opciones y demás submenús.**
  **Refs:** B-19, RF-347, D-059.
  **Hecho cuando:** inventario renovado, controles/foco/funciones conservados, capturas y GUT correctos, backlog tachado, documentos y PR#1 actualizados.

  **Resultado T176:** tema local ampliado con casillas, deslizadores, desplegables/entradas y paneles hierro-bronce. Opciones agrupadas; selección campaña/comunidad, Wiki, récords, final, iniciales/Salón y editor/diálogos renovados sin cambiar lógica/guardados. Siete capturas Full HD revisadas,891/891 GUT,8065 asserts,68 scripts; sin SCRIPT ERROR/Parse Error. Windows/Linux exportados; Windows arranca headless con salida0, Linux/móvil sin ejecutar. B-19 tachado y B-17/B-18 también señalados como completos; resto intacto. Aviso de certificados del entorno persiste.

### Registro de backlog · Efectos, audio y panel de torre
- [x] **T177 · Anotar mejoras pendientes de efectos, audio y panel de torre.**
  **Refs:** B-24 a B-28, RF-280/RF-284 existentes.
  **Hecho cuando:** pedidos registrados sin duplicados, prioridad media y alcance claros, sin implementación; documentación subida al PR#1.
  **Resultado T177:** cinco entradas pendientes: muerte, rebote/aturdimiento, curación, música/sonidos y panel de información/mejoras. Se diferencia aturdimiento de ralentización y panel de torre de submenús ya completados. Solo documentación; sin cambios de assets/código/datos ni ejecución de tests.

### Archivo de materiales anteriores
- [x] **T178 · Revisar y versionar los archivos pendientes.**
  **Refs:** revisión de Lucas de archivos sin commit, archivo de arte.
  **Hecho cuando:** se identifica todo lo pendiente, se conservan bocetos/herramientas/UID útiles, se excluyen temporales/proyecto vacío y se sube al PR#1.
  **Resultado T178:** materiales históricos de branding, torres3D y full-pass archivados, incluidas alternativas descartadas; UID de herramientas previas conservados. Logs y `.import` de art ignorados, proyecto secundario vacío excluido sin eliminarlo. No hay cambios de producción ni integración de bocetos. Verificación de inventario y `git diff --check`; GUT no se repite al no cambiar ejecución.

### M34 · APK
- [x] **T179 · Exportar Android normal y de pruebas con el PR#1.**
  **Refs:** RF-348, D-060.
  **Hecho cuando:** ambas APK firmadas, variantes y contenido verificados, docs al día y push; límites de Android/iOS declarados.

  **Resultado T179:** dos APK arm64 firmadas para instalación local (clave de depuración), Android7/API24 o superior, versión1.1-pr1/code2. Paquetes com.juegoa.towerdefense y com.juegoa.towerdefense.pruebas; feature pruebas confirmada solo en la segunda al decodificar project.binary. Firmas v2/v3 verificadas, integridad ZIP y presencia de los doce atlas de caminata/submenús actuales comprobadas; exclusión art/tests/tools/GUT confirmada. Cada APK49429778bytes; hashes en build/m34/apk_manifest.json. Exportación con todos los cambios hasta T178 del PR#1 y presets nuevos. No había dispositivos conectados, no se instaló/jugó en Android ni se reejecutó GUT (solo presets/documentos). iOS bloqueado por entorno Windows: requiere macOS/Xcode y firma Apple; no se generó IPA.

### M35 · Panel de información y mejoras
- [x] **T180 · Renovar el panel de torre (B-28).**
  **Refs:** RF-349, D-061.
  **Hecho cuando:** métricas/detalle/acciones agrupados con hierro-bronce, textos largos desplazables, foco y estados de nivel1–3/sin oro/aturdida/sinergias verificados, capturas revisadas, GUT y exportaciones correctos. Conservar cambios Android previos fuera del commit.

  **Resultado T180:** panel hierro/bronce de270×356 píxeles lógicos, tres métricas, descripción/efectos/sinergias desplazables, acciones fijas, estado de aturdimiento separado y foco visible.892/892 GUT,8074 asserts,69 scripts; sin SCRIPT ERROR/Parse Error. Doce capturas reales revisadas en1920×1080 y1280×720. Windows normal/pruebas y Linux exportados; arranque Windows comprobado. Sin ejecución física Linux/Android. Aviso previo de certificados persiste. Cambios M34 anteriores conservados fuera del commit.

### M36 · Cerrar todo el rango de mejoras
- [x] **T181 · Completar B-20 a B-27.**
  **Refs:** RF-350 a RF-357, D-062.
  **Hecho cuando:** ocho entregables completos: remaches de nivel, rebote/aturdimiento, aura/cura, muerte de las trece especies, audio/menu/combate, tres prototipos de profundidad, candidatos/desbloqueos y recetas/ensayo de vecindad. Revisar capturas/audio/análisis, GUT y60FPS con200 enemigos/60 torres, exportar Windows/Linux, registrar límites y push. Preservar M34 pendiente fuera del commit.

  **Resultado T181:** ocho entregables completos. B-20/24/25/26/27 integrados (placa/remaches, muerte con pose actual, rebote/aturdimiento, cura y audio). B-21/22/23 con muestras, candidatos y laboratorio de36 casos; elegir/activar esas mecánicas sigue pendiente, conforme al alcance de investigación.898/898 GUT,8150 asserts,70 scripts; sin SCRIPT ERROR/Parse Error. Diez capturas revisadas. Rendimiento200 enemigos/60 torres con nuevos residuos:100FPS promedio,28,8ms peor cuadro,7/601 cuadros por encima de16,6ms. Windows normal/pruebas y Linux exportados; ambos Windows arrancan con salida0. Sin ejecución física Linux/Android ni evaluación auditiva humana; aviso previo de certificados y limpieza de recursos al cerrar herramientas declarados. Evidencia/reproducción en art/redesign-m36/README.md. M34 previo conservado fuera del commit.

### T182 · Depurar el backlog con Lucas
- [x] **T182 · Cerrar B-02 y reorganizar B-03/B-15.**
  **Refs:** D-063, backlog §13. No añade requisitos de juego.
  **Hecho cuando:** B-02 cerrado; B-15 retirado sin buscador/enlaces/Niveles/imágenes; lore/Épocas trasladados a B-03 y Wiki de mods/comunidad separada sin duplicar B-04; estudios B-21–B-23 explícitamente abiertos/preliminares; pendientes restantes identificados.
  **Resultado:** documentación y referencias actualizadas; conservados los números históricos. Revisión de cambios y referencias, sin ejecución de tests por no modificar juego ni datos. Cambios M34 anteriores conservados fuera del commit.

### M37 · Primera etapa de B-07/B-22
- [x] **T183 · Avances genéricos y Estandarte mecánico.**
  **Refs:** RF-358–361, D-064.
  **Hecho cuando:** colección5 fuentes, checkpoint de oleada y guardado solo al resultado, disponibilidad6/7 más requisito, apoyo sin apilar, admin explícito, UI/Wiki/iconos; pruebas, exportación y muestras revisables. Documentar balance y límites honestos.
  **Resultado T183:** primera etapa funcional:5 fuentes únicas, portador aleatorio original, confirmación al cerrar oleada, guardado solo victoria/derrota, colección+permiso6/7 y habilitación admin genérica, apoyo10/15/20% sin apilar ni disparar, UI/Wiki y diseño vectorial inicial revisable.918/918 GUT,8251 asserts,71 scripts, sin SCRIPT ERROR/Parse Error.106FPS con200 enemigos/60 torres incluyendo apoyo, peor cuadro33,3ms y6/638 cuadros sobre16,6ms (RX6900XT). Cuatro capturas revisadas. Bot mix semilla12345: nivel6 sin apoyo gana10 vidas, con compra temprana pierde12/15; nivel7 gana16/13 vidas sin/con apoyo. No es balance definitivo: este bot solo compra nivel1, una sola estrategia/semilla y apoyo no obligatorio. Windows normal/pruebas y Linux exportados; arranque de ambos Windows verificado. No ejecución en Linux/Android ni aprobación visual final de Lucas. Cambios M34 previos conservados fuera del commit. Evidencia art/progression-m37/.
- [x] **T184 · Ladrón periódico.** Refs RF-363–365/D-066. Resultado: drenaje3/2s/piso10 por señal, encuentros limitados en6/7, editor preserva probabilidad, Wiki/admin automáticos y aviso de robo efectivo. Pruebas de límites/ingresos/escape/muerte/sorteo/editor/campaña y regresión. Diseño y balance iniciales; integración de desgaste/reparación continúa en T185–186.
- [x] **T185 · Embestidor y desgaste.** Refs RF-366–368/D-067. Resultado: rectas fusionadas, preparación/aceleración y slow, impacto único al extremo en torre próxima, desgaste limitado50% que conserva mejoras y stun independiente. Panel, marca y aviso; datos presentes solo6/7.73 pruebas de geometría/cercanía/topes/contenido/progresión/editor verdes. Reutiliza Bestia B como arte inicial; balance conjunto y reparación se verifican en T186.
- [x] **T186 · Reparación del mecánico.** Refs RF-369–370/D-068. Resultado: reparación automática 2/3/4 puntos/s, mayor fuente activa, sin autorreparación; desgaste del apoyo reduce prestaciones, stun separado. Wiki/panel/ayudas y marcas compartidas; 943/943 GUT, 8459 asserts, 74 scripts; 35 pruebas finales de UI/contenido. Impacto y reparación verificados sobre caminos 6/7; 12 simulaciones (3 semillas, con/sin apoyo), 103 FPS con 200 enemigos/60 torres desgastadas. Windows normal/pruebas y Linux exportados; arranque Windows código 0. Nivel6 pierde con compra temprana del apoyo y gana sin ella; nivel7 gana en ambos casos. Bot mata Embestidores antes del impacto; escenarios controlados verifican ese efecto. Balance/arte iniciales, sin QA física Linux/Android. Evidencia art/mechanics-m41; cambios Android M34 ajenos conservados.

- [x] **T187 · Integrar avances en la barra superior.** Refs RF-362/D-065. Hecho cuando icono/valor, ayudas y estados quedan integrados sin cambiar persistencia ni superponer controles. Resultado: control uniforme, cartel del mapa retirado; pruebas de colección/HUD y captura, descripción PR1 preparada. Ramas feature/ registradas.

- [x] **T188 · Registrar rediseños y corregir selector de enemigos.** Refs B-31/RF-371–372/D-069. Hecho cuando los cuatro rediseños y la propuesta Curandero→Embestidor quedan registrados; desplegable no recorta, permite scroll y clic, rueda sobre selector cambia con límites y Aparecer respeta selección. Verificar pruebas y captura; no sustituir assets en esta tarea.


  **Resultado T188:** B-31 registra los cuatro rediseños y la propuesta Curandero→Embestidor, sin reasignar recursos. Popup opaco con máximo efectivo de 320 píxeles lógicos y scroll, hover sin sombra recortada; rueda sobre selector cerrado cambia con límites. Pasan 948/948 tests (8477 asserts), sin SCRIPT ERROR ni Parse Error. Capturas reales y reproducción en `art/ui-m42/`; Windows (pruebas) reexportado, arranque headless código 0. Persisten avisos conocidos de certificados/limpieza de Godot. No se hizo sesión manual con rueda física ni se produjo arte nuevo.

- [x] **T189 · Producir e integrar rediseños B-31.** Refs B-31/RF-373–376/D-070. Hecho cuando Embestidor/Curandero tienen nuevas siluetas y ciclos, Ladrón/Mecánico usan render compatibles, fuentes/prompts y capturas quedan conservados, balance intacto y pruebas pasan. Integración técnica completa separada de aprobación visual final por Lucas.


  **Resultado T189:** cuatro diseños integrados,48 poses de marcha, PNG estáticos/Wiki y Mecánico renderizado. Fuentes, prompts normalizados, pack/manifest, preview animada y capturas mapa/Wiki en art/redesign-m43. 948/948 tests,8693 asserts; parámetros jugables idénticos. Windows (pruebas) exportado y arranque0. Carga200 enemigos/60 torres:114FPS en este equipo. Bot6/7 semilla42 con compra temprana Mecánico conserva resultados M41 (6 derrota12/15,7 victoria15vidas,18 monedas robadas). No se cambió balance ni niveles1–5. Pendiente aprobación artística de Lucas, estrategias con mejoras/juego humano y prueba Linux/Android; límites completos en README de evidencia.

- [x] **T190 · Exportar entrega visual aprobada.** Refs B31/D071/RF376. Hecho cuando aprobación queda registrada y los dos EXE y dos APK se generan y verifican; informar límites de ejecución y siguiente etapa. No cambiar balance ni configuración local ajena.

  **Resultado T190:** aprobación B31 registrada. Windows Desktop/Windows (pruebas) release y Android/Android (pruebas) debug regenerados; ambos EXE arrancan0 y solo pruebas activa DevMode. APK arm64 Android7+, firmas v2/v3 válidas e idénticas aM34, paquetes separados; feature pruebas solo en la variante de pruebas, ZIP íntegro y los cuatro recursos M43 presentes. SHA256/tamaños y logs en build/t190. Se reutilizaron plantillas y clave anteriores en entorno aislado. No hay prueba física Android, instalación en dispositivo ni cambio de lógica; GUT948/948 deT189 sigue vigente. Se conservaron cambios locales Android sin incluirlos en commit.

- [x] **T191 · Comparar y afinar balance6/7.** Refs B07/B22/D072/RF377. Hecho cuando se comparan momento/ubicación del Mecánico, mejoras y presión de especiales con corridas reproducibles; se informan criterios para8/9 y se conserva balance1–5. Cambios oficiales solo si los datos los justifican; documentar límites del bot y prueba humana pendiente.

**Resultado T191:**38 corridas con semillas global/spawner controladas y una repetición completa idéntica; siete perfiles, mejoras, ubicación y presión de especiales. Se conservan números oficiales6/7: evidencia favorece apoyo tardío agrupado en7, no compra temprana con torres básicas en6. Variantes reforzadas producen impactos/reparación natural en7, pero recompensas y compras confunden interpretación de vidas. Dos escenarios con caminos reales:20 desgaste, reparación10/6,7/5s. Corregido residuo terminal y estado de reparación;949/949 GUT,8698 asserts,74 scripts, sin SCRIPT ERROR/Parse Error. Dos EXE release y dos APK debug regenerados: arranque Windows0, paquetes/feature/firma APK válidos e iguales aT190. Evidencia art/balance-m44 y logs/manifest local build/t191. Niveles1–5 intactos; no balance humano definitivo ni QA física Android. B22 abierto; criterios para8/9 documentados. Cambios locales M34 conservados fuera del commit.

- [x] **T192 · Integrar y balancear primera versión de niveles8/9.** Refs RF378–381/D073/B10/B22. Hecho cuando campaña se amplía con debuts de auras, preparación y encuentros/combinaciones de robo/desgaste, disponibilidad del apoyo y rutas válidas; pruebas, varias semillas/estrategias y evidencia documentada. Niveles1–7 y stats globales intactos; no EXE/APK ni afirmar balance humano definitivo.

**Resultado T192:** Bastión18 oleadas/una entrada y Taller asediado20/dos entradas integrados en campaña; Guardián8/Curandero9, robos opcionales desde6 y embestidas8 antes de combinaciones, Mecánico con permiso+5avances. Escala local32%/40% tras dos exploraciones;24 corridas finales en tres semillas y repetición idéntica.8 gana en perfiles comparados,9 gana con defensa variada11 vidas/compra tardía8; heurística de mejoras puede perder y apoyo por daño no cubre siempre extremos. Dos encuentros oficiales con defensa mínima causan/reparan40 puntos por mapa sin forzar efectos; dos exposiciones y capturas revisadas. Compatibilidad de acceso al nuevo nivel por victoria anterior sin escribir guardado.954/954 GUT,8939 asserts,75 scripts;62/62 verificaciones finales tras ajuste local8,1241 asserts; carga/caminos/texto canónico e importación válidos, sin SCRIPT ERROR/Parse Error. Niveles1–7/stats globales y hashes de los cuatro paquetes intactos. No exportaciones por instrucción de Lucas, ni balance humano definitivo/QA física móvil. B10/B22 parciales:10–15 y otros candidatos pendientes. Evidencia art/campaign-m45; cambios M34 conservados fuera del commit.

### M46 · Estudio de vista B-21 v2
- [x] **T193 · Nuevo análisis y pruebas de una vista con más sensación de 3D (B-21).**
  **Refs:** RF-382, D-074, B-21.
  **Hecho cuando:** las cuatro presentaciones (actual, relieve en la misma cuadrícula, oblicua al 80 % y maqueta 3D) se arman sobre la partida real con la misma escena; hay capturas completas y de detalle, modo jugable con autoprueba por vista, medidas de casillas, superficie y clics, rendimiento con la carga de P7 en tres rondas y un informe con costos, riesgos, límites y una recomendación que incluye no cambiar nada; producción, mapas y guardados quedan intactos y GUT pasa en verde.

  **Resultado T193:**
  - **Laboratorio:** `art/b21-vista/` (`vista_lab`, `relief_layer`, `diorama_3d` y `d_input`), montado sobre `game.tscn` sin tocar los scripts de producción. Escena de referencia: nivel 1 con 7 torres, 14 monstruos y la vista previa de la Incendiaria. Entrega las cuatro vistas completas, la hoja de detalle y una foto en pleno combate por vista.
  - **Casillas, superficie y clics:** A y B 64 × 64 px y 100 %; C 64 × 51 px y 80 %; D 53 × 38 px al fondo y 64 × 56 px adelante, 66 %. En las cuatro vistas, 615/615 clics de ida y vuelta caen en la casilla correcta (en D, con el rayo nuevo).
  - **Rendimiento** (RX 6900 XT, 1920 × 1080, tres rondas):

    | Vista | FPS | ms por cuadro |
    |---|---|---|
    | A | 92 | 10,8 |
    | B con relieve dibujado en cada cuadro | 73 | 13,7 |
    | B horneado | 92 | 11,0 |
    | B horneado sin orden por profundidad | 92 | 10,9 |
    | C horneado | 95 | 10,5 |
    | D | 203 | 4,9 |

    El número de D no es comparable: omite casi todos los detalles por enemigo. El control (A sin dibujar torres ni monstruos) da 520 FPS y 1,9 ms, o sea que unos 9 ms de cada cuadro son el dibujo 2D de torres y monstruos. Quedó anotado como sugerencia, sin tocar nada.
  - **Autoprueba jugando:** en las cuatro vistas se construyen 3/3 torres (en D por clic simulado), Escape sale del modo construcción y la oleada 1 corre sin `SCRIPT ERROR`.
  - **Recomendación (D-074):** no cambiar la proyección. Si se quiere más profundidad, B por etapas; C como alternativa con PR *breaking change*; D descartada para este juego; A también es válida.
  - **Tests:** 954/954 GUT, 8939 asserts, 75 scripts, sin `SCRIPT ERROR` ni `Parse Error`.
  - **Lo que no se probó:** ningún celular (ni rendimiento, ni toque, ni memoria). Solo la Pradera en 20 × 9. El arte de relieve y maqueta es de prototipo. En C la torre fantasma sale aplastada y los efectos no están corregidos. En D faltan efectos, coronas, auras y placas, los monstruos entran flotando por el borde y la decoración tiene sombra doble. Al cerrar el laboratorio, Godot avisa de 2 objetos sin liberar.
  - **Pendiente:** la decisión de Lucas. Los cambios M34 se conservaron fuera del commit.

### M47 · Monsters & Canons 3D: concepto
- [x] **T194 · Documento de concepto de Monsters & Canons 3D y prueba de cámara libre.**
  **Refs:** D-075, B-21, B-32, backlog §13. No añade requisitos de juego.
  **Hecho cuando:** existe un documento que junta la investigación 3D, lo que se conserva de la V1, el diseño del espacio, la cámara, el arte, PC y celular, el lore, el relevamiento completo de lo pendiente en la V1 con un orden propuesto y un plan por hitos con riesgos y preguntas; la sección de cámara se apoya en una prueba real de cámara giratoria; B-21 queda resuelto y B-32 registrado.

  **Resultado T194:**
  - **Documento:** `specs/06-monsters-canons-3d.md`.
  - **Prueba de cámara:** seis vistas de la maqueta con los dibujos actuales (`art/b21-vista/camara_*.jpg`). Aguantan giros de ±30°, la cámara baja y el acercamiento; desde 90° y sobre todo desde 180° se rompen (luz pintada contra sol, frentes pintados, puntos de apoyo corridos y paredes que tapan). Conclusión: cámara de estratega con el arte actual; el giro libre pide modelos.
  - **Relevamiento de la V1:** todo el backlog abierto, más plataformas y sugerencias, con tamaño y relación con el 3D.
  - **Pruebas:** solo se cambió el laboratorio de `art/` y documentos. GUT pasa 954/954 (8939 asserts, 75 scripts, sin `SCRIPT ERROR` ni `Parse Error`), y la prueba de cámara corrió sin `SCRIPT ERROR`. No se midió rendimiento con cámara libre ni se probó en celular.
  - Los cambios M34 se conservaron fuera del commit.

- [x] **T195 · Trasladar Épocas al backlog de M&C 3D y registrar el estado de la V1.**
  **Refs:** D-076, B-01, B-05, B-13, B-32. No añade requisitos de juego.
  **Hecho cuando:** B-01 queda marcado como trasladado y su contenido completo está en el backlog de M&C 3D (§15 del documento 06); B-05 y B-13 registran las propuestas de Lucas; el relevamiento de la V1 refleja que la APK ya se probó y que el lore está en curso.

  **Resultado T195:**
  - Épocas ya forma parte del backlog de M&C 3D como entrada 3D-01, con sus variantes, cuidados y pasos previos.
  - El documento 06 tiene la tabla de pendientes, el orden y las preguntas actualizados.
  - El README registra la prueba de la APK hecha por Lucas.
  - B-03 no se tocó: lo trabaja otro agente.
  - Solo cambiaron documentos, así que no se corrió GUT.
  - Los cambios M34 se conservaron fuera del commit.

### M48 · Modo de pruebas en Opciones, una sola app y licencia
- [x] **T196 · Modo de pruebas desde Opciones, una sola exportación por plataforma y licencia GPL.**
  **Refs:** RF-180, RF-383 a RF-387, D-077, B-13.
  **Hecho cuando:**
  - Opciones del menú principal activa el modo de pruebas (con confirmación) y lo desactiva sin tocar el guardado real; desde la pausa no aparece.
  - El juego siempre arranca normal y `--pruebas` sigue sirviendo.
  - Quedan los presets Windows, Android y Linux, sin la característica `pruebas`.
  - Están `LICENSE` con la GPL-3.0 y el artículo Licencias en la Wiki.
  - Los documentos están al día, los tests en verde y las exportaciones verificadas.

  **Resultado T196:**
  - **Opciones:** tiene la sección "Administración". La confirmación ocupa el panel entero, así no se pasa de 720 px de alto (la primera versión se cortaba; se corrigió).
  - **Menú principal:** se vuelve a armar al cambiar de modo.
  - **`DevMode.detect()`:** solo mira `--pruebas`.
  - **Exportaciones:** se eliminaron los presets "Windows (pruebas)" y "Android (pruebas)".
  - **Licencia:** `LICENSE` es el texto oficial de gnu.org (SHA-256 3972dc97…). El artículo Licencias de la Wiki lleva la licencia del juego, el aviso de Godot copiado del propio motor, el crédito de FreeType y la aclaración sobre GUT.
  - **Tests:** 965/965 GUT (8994 asserts, 77 scripts, sin `SCRIPT ERROR` ni `Parse Error`), con 11 tests nuevos (9 de Opciones y 2 de licencia) y el de presets reescrito.
  - **Prueba en el menú real:** confirmar activa el modo y muestra el cartel; Opciones ofrece "Volver al juego normal" y al tocarlo vuelve al guardado real.
  - **Exportaciones verificadas:**
    - `build/JuegoA.exe` arranca con salida 0, normal por defecto y en modo de pruebas con `-- --pruebas`.
    - `build/JuegoA.x86_64` se exportó.
    - `build/JuegoA.apk` es la APK debug única, con paquete `com.juegoa.towerdefense`, firma de depuración verificada con apksigner, Android 7+, versión 1.1-pr1 (code 2, de la configuración local de M34) e incluye el artículo de licencias.
  - **Lo que no se probó:**
    - La APK no se instaló en un celular (la prueba física queda para Lucas).
    - Linux no se abrió en una máquina real.
    - No se hizo una sesión manual con mouse y teclado: los clics de la prueba son simulados.
  - **Pendientes:**
    - En `build/` quedan los EXE y APK de pruebas viejos, ya obsoletos.
    - El repositorio es privado: antes de publicar hay que ofrecer el código fuente (D-077).
  - Los cambios M34 se conservaron fuera del commit.

### M49 · Prueba de modos
- [x] **T197 · Prueba de modos unificada con el gestor de mapas (B-05).**
  **Refs:** RF-388 a RF-392, D-078.
  **Hecho cuando:**
  - Los paquetes de modo (oficiales y propios) se leen y validan solo como datos.
  - La selección de nivel ofrece Campaña, Asedio, Comunidad y modos propios, con progreso y récords por modo, sin tocar campaña, Salón ni colección.
  - El editor guarda en un modo propio.
  - Asedio se ofrece con valores iniciales y una corrida del bot sobre sus primeros mapas.
  - Hay tests de formato, errores, ids, desbloqueo y editor en carpetas de prueba.

  **Resultado T197:**
  - **Paquetes:** `ModePacks` lee y valida `modo.json` (solo datos). Los mapas se buscan en la carpeta del modo o entre los oficiales, se aplican las reglas (oro %, vidas, vida % y torres) y el id es `modo_<modo>_<mapa>`. Un modo propio con el nombre de uno oficial queda con error.
  - **Partida:** la vida del modo llega al generador de oleadas (`Rules.percent_of`, mínimo 1). El progreso y el top 5 van por modo y no tocan la campaña, el Salón ni los avances. "Siguiente nivel" sigue dentro del modo.
  - **Selección de nivel:** solapas dinámicas, tarjetas con bloqueo en los modos oficiales, error o mensaje si el modo está vacío, y carpeta del modo propio.
  - **Editor:** "En un modo…" crea o elige el modo y después pide el nombre; el destino cambia recién al aceptar. "Guardar" no cambió y "Abrir" lista los mapas de los modos.
  - **Bot:** acepta `modo=asedio`.
  - **Asedio, ajustado con el bot `mix`:**
    - La propuesta de vida 150 % y oro 80 % perdía en la oleada 4 de los mapas 1 a 3, y con 125 % y el mismo oro también perdía temprano.
    - Con reglas neutras da lo mismo que la campaña, oleada por oleada.
    - Final: vida 115 %, el mismo oro.

    | Mapa | Campaña | Asedio 115 % |
    |---|---|---|
    | 1 | gana con 20 vidas | gana con 3 |
    | 2 | pierde en la oleada 15 | pierde en la 12 |
    | 3 | gana con 16 | gana con 6 |
    | 4 | gana con 10 | pierde en la última oleada (15) |
    | 5 | gana con 13 | gana con 4 |
    | 6 | gana con 10 | pierde en la oleada 7 |
    | 7 | gana con 16 | pierde en la 19 de 20 |
    | 8 | gana con 20 | pierde en la última oleada (18) |
    | 9 | gana con 11 | pierde en la 16 de 20 |

    El bot es simple: falta probarlo jugando, y 110 % es la alternativa si resulta demasiado.
  - **Tests:** 1017/1017 GUT (9256 asserts, 81 scripts, sin `SCRIPT ERROR` ni `Parse Error`), con 51 nuevos. Se revisó en capturas la selección con Asedio, dos modos propios y la página de un modo propio.
  - **Lo que no se probó:**
    - Una partida manual en Asedio, ni en celular.
    - Con más de dos modos propios, las solapas no entran en la fila.
    - Los récords de los modos no aparecen en la pantalla de Récords (sí al terminar cada partida).
  - No se regeneraron EXE/APK. Los cambios M34 se conservaron fuera del commit.

### Registro de lore y cierre de V1
- [x] **T198 · Registrar las decisiones de B-03 y el plan de primera entrega.**
  **Refs:** B-03, B-10, B-22, D-075/D-076, specs/07-lore-y-cierre-v1.md.
  **Hecho cuando:** toda la conversación queda registrada, separando acuerdos, descartes y preguntas; backlog y documento de segunda entrega enlazan el plan, sin implementar mecánicas.
  **Resultado:** documento completo con lore, campaña de 15 niveles, tres bloques, demolición global, recursos opcionales, extracción finita por oleadas, colecciones científicas por tecnología, torres, mapas/assets, orden de desarrollo y criterio de entrega. Referencias en B-03/B-10/B-22 y documento 06. Lectura del archivo guardado, 17 comprobaciones de contenido y revisión de formato del diff. Sin cambios de ejecución; no se corrió GUT para esta tarea documental. Los cambios previos de Android y T197 se conservan fuera del commit.

### Plan de cierre de la V1 (plan 08)
- [x] **T199 · Plan de cierre de la V1 dividido en tareas, cuestionario de decisiones y fichas de delegación.**
  **Refs:** B-03, B-10, B-22, `specs/07-lore-y-cierre-v1.md`, `specs/08-plan-cierre-v1.md`, `specs/09-decisiones-pendientes-v1.md`, `specs/tareas/`.
  **Hecho cuando:** el 07 y el estado real del repositorio están analizados; hay un plan por fases con compuertas de Lucas; las decisiones abiertas tienen una recomendación en un cuestionario; y cada tarea tiene una ficha que se le puede pasar a otro agente (Sonnet, Codex o Qwen).
  **Resultado:**
  - **Plan 08:**
    - estado real del repositorio;
    - piezas existentes que conviene extender (leyenda, `allowed_towers`, `CollectibleRun` y RF-359);
    - cinco tensiones detectadas (§11 contra la intro y los textos, recursos sin uso en 6–9, B-14/B-23/B-08/B-09 antes o después, marca `JuegoA` y fuente GPL, nombres inconsistentes);
    - definición de "base para la franquicia";
    - propuesta de fichas de los 15 mapas;
    - tablero T200–T242 con ejecutor, modelo, dependencias y compuertas.
  - **Cuestionario 09:** 40 preguntas, todas con recomendación.
  - **Fichas:** `specs/tareas/README.md` (protocolo común, entorno Linux, Codex y Qwen) y 40 fichas.
  - **CLAUDE.md:** nota para Linux y enlaces a los documentos 08 y 09.
  - **Qué se probó:** línea de base de tests en esta máquina (Linux, Godot 4.7.2): 1017/1017, sin `SCRIPT ERROR`.
  - **Qué no:** no se implementó ninguna mecánica, mapa ni arte. Las fichas de mapa y los valores numéricos son propuestas, no decisiones.

#### Pendientes (ver el tablero del plan 08 y su ficha en `specs/tareas/`)
- [x] **T200** · 🚦 G1 · Lucas responde el cuestionario 09 y aprueba las fichas de mapa.
  **Resultado (2026-10-08):**
  - **Respondió las 40 preguntas** (Q-01 a Q-40; la numeración salta del 31 al 33 porque el 09 así lo tenía). Las respuestas con fecha están en la columna "Tu respuesta" del 09.
  - **Aceptó la recomendación en 36 de 40** y cambió 4 (✎: Q-10, Q-18, Q-21 y Q-32); Q-34 la aprobó con un reparto nuevo. De Q-21 salió además una regla nueva:
    - **Q-10:** la máquina baja el precio **y también un poco el tiempo** de demolición (cuánto, lo fija T205 con el bot).
    - **Q-18:** los recursos caen **al azar con semilla desde el nivel 7**, no desde el 10. Única excepción a "sin sorteos".
    - **Q-21:** el Mortero debuta en el **nivel 9** (enmienda de RF-300), y el Francotirador se compra por **150 de oro o por 120 + 1 recurso**, las dos formas a la vez, nunca indispensable.
    - **Q-32:** el nivel 15 tiene un **jefe supremo nuevo** con escolta.
    - **Q-34 ✔:** fichas aprobadas como dirección, con el reparto del bloque 2 (7: demoledora + primer drop + Francotirador con recurso; 8: Guardián, pieza 1/3, símbolo A; 9: Curandero, pieza 2/3 y Mortero; 10: mina explotable y pieza 3/3).
  - **Fichas ajustadas:** plan 08 (§2.2, §5 y tablero), T205, T209, T223, T224, T225, T227 y T234. **Tareas nuevas:** T243 (spec del jefe supremo) y T244 (su arte).
  - **Qué se probó:** nada de código; es solo documentación.
  - **Qué no:** los valores (probabilidad del drop, precio de la máquina, tiempo que baja, Mortero y Francotirador) son iniciales y no se probaron con el bot. El diseño del jefe supremo no existe todavía.
- [x] **T203** · Torres por mapa y aviso en la selección.
  **Refs:** RF-393 a RF-397, D-079 (Q-29 y Q-30).
  **Resultado (2026-10-08):**
  - **Spec y decisión:** RF-393 a RF-397 en `01-spec.md` (subsección "Torres por mapa (rotación)", después de RF-300), D-079 en `04-decisiones.md` (descarta la lista "a quitar" y la pantalla de mazo) y el cómo en `02-plan-tecnico.md`. `CONTENIDO.md` explica el campo con ejemplo y `CHANGELOG.md` lo anota.
  - **Código:** campo `"torres"` en `LEVEL_KEYS`, `LevelFile._read_towers` (error con la lista de ids, repetidos cuentan una vez, lista vacía es error), `LevelData.towers` y `available_towers` (orden canónico, la lista manda sobre `torres_extra`, la colección sigue mandando). El modo sigue escribiendo `allowed_towers` y el filtro aplica los dos (intersección); `ModePacks._towers_conflict` hace error del mapa la intersección vacía. `LevelDraft` conserva y escribe el campo. Clase nueva `TowerOffer` (lógica pura) y tarjetas de `level_select.gd` con los íconos de `Tower.make_icon` y un punto naranja en la torre que debuta (el "Nueva" completo sale en el tooltip). `Game` agrega una torre de apoyo nombrada en `"torres"`. Ejemplo: `tools/ejemplos/mapa_torres_por_mapa.json`.
  - **Qué se probó:** `tests/test_map_towers.gd` (16 tests): sin campo igual que hoy, con campo y orden canónico, reservada, id malo, forma mala, lista vacía, repetido, el editor conserva el campo, el ejemplo, la colección, intersección con un modo (incluida la vacía), "Nueva" con niveles armados y con la campaña real, y la tarjeta real (íconos y marca). Suite completa: **1033/1033** (1017 + 16), 0 `SCRIPT ERROR`/`Parse Error`. `check_level` acepta el ejemplo con `"torres"`. Bot `mix`: `level=6` da exactamente la misma salida antes y después; `level=9` da la misma victoria (oleada 20/20, 11 vidas, mismas torres por oleada), pero el **oro de las últimas oleadas varía entre corridas** (155 / 164 / 170 en tres corridas, una de ellas con el código original limpio), así que ese bot no es determinista en el oro y no es un efecto de este cambio.
  - **Qué no:** no se miró la tarjeta en pantalla (solo por tests; el tamaño de los íconos y del punto es a ojo, 22 px, y entran 8 en el ancho de 200 px, pero con 9 o más se cortarían). En el nivel 1 todas las torres figuran como "Nueva" por la regla literal de la ficha. Ningún nivel oficial usa todavía `"torres"` (eso es de la rotación, bloque 3). No se probó un modo propio con `"torres"` en la pantalla real, solo la lógica. No hubo push (la instrucción de la coordinación).

- [x] **T201** · 🚦 G2 · Biblia del universo (`specs/10-universo.md`).
  **Estado (2026-10-08): borrador listo para la revisión de Lucas; sigue en `[ ]` hasta su OK (G2).**
  **Resultado (borrador):**
  - **Qué se hizo:** `specs/10-universo.md` (377 líneas) con las 10 secciones de la ficha, más una sección 0 con lo que Lucas tiene que decidir y un apéndice de fuentes y límites. Cada afirmación lleva una marca (**CANON** / **PROPUESTA** / **OPCIÓN** / **SEMILLA**) para que se vea qué acordó Lucas y qué propuse yo. Sale del 07, 08 y 09 y usa los nombres del informe de T202. No contradice el 07. Enlazado desde `CLAUDE.md` ("Dónde está cada cosa") y desde el 07 §14.
  - **Lo que tiene que elegir Lucas (G2):** tres nombres con 3 opciones cada uno (Q-03): planeta (Sosiego / Cántaro / Varadero), colonia (Arraigo / La Posta / Compañía Meridiana) y cómo llaman los colonos a las comunidades (Moradores / Marcados / Primeros). Más 7 preguntas abiertas (P-1 a P-7) con mi recomendación: alianza de tres pueblos o uno con tres oficios, el Soberano como tipo o individuo, el origen de los cinco avances, quién dejó las ruinas, las categorías Bestia/Criatura, la señal `hito` para el 11–13 y el doble sentido Canons/cánones.
  - **Decisiones de Lucas respetadas:** nivel 15 con jefe supremo nuevo que **no** se define acá (lo hace T243; solo se dejan restricciones de coherencia, Q-32); textos de hasta 3 y 2 líneas y sin diálogos (Q-01); ruinas y señales con el mismo símbolo A (plan 08 §5); Lanzamisiles y Épocas fuera.
  - **Qué se probó:** nada de código (es solo documentación; no se corrieron los tests). Se revisó a mano que las 10 secciones existan, que los niveles, lugares y debuts coincidan con el plan 08 §5 y las respuestas del 09, y que ningún ejemplo de tono pase de 3 líneas (entrada) y 2 (victoria).
  - **Qué no:** no se abrió el juego ni se miró ningún PNG (el aspecto de cada especie sale de los documentos de arte y de T202, que tampoco lo verificó a ojo; el Volador queda "por confirmar", Q-5 de T202). No se escribió ningún texto final de nivel (es T227/T228). Los nombres propuestos no se buscaron en otras obras ni se comprobó que estén libres como marca. Las líneas "qué busca" de cada especie y todo lo marcado PROPUESTA son criterio mío, no hechos del juego.
  - **OK de Lucas (G2, 2026-10-08):** planeta **Cántaro**, colonia **Compañía Meridiana**, comunidades **Moradores**; P-1 a P-7 aceptadas con la recomendación. Se desbloquean T218 y T227. No se hizo merge a `main`.
- [x] **T202** · Auditoría de nombres y glosario canónico.
  **Resultado:** informe en `specs/tareas/informes/T202-glosario.md` con la tabla de las 10 torres, los 15 enemigos, los 7 temas y los conceptos (juego, avance/pieza/fuente, colección, Estandarte, desgaste, aturdimiento, modo de pruebas), 9 preguntas para Lucas (G2) y la lista de archivos que habría que cambiar. Hallazgos principales: el Normal, el Rápido y el Tanque tienen en la guía §3 una especie y un color que ya no son los del dibujo (M24); el Curandero cambió en M43; la tabla de §3 tiene 13 filas para 15 enemigos (faltan Embestidor y Ladrón); la torre de apoyo tiene cuatro nombres (Estandarte mecánico, Estandarte, Mecánico, estatua); "Monsters & Canons" puede ser un error de "Cannons". **Qué se probó:** nada de código (es solo documentación; no se corrieron los tests). **Qué no:** no se abrió el juego ni se miró cada PNG; lo del "dibujo ya no coincide" sale de lo que dicen los documentos de arte y de las aprobaciones de Lucas, no de ver el arte actual. No se cambió ningún archivo del juego ni de la spec.
- [x] **T203** · Torres por mapa y aviso en la selección.
  **Refs:** RF-393 a RF-397, D-079 (Q-29 y Q-30).
  **Resultado (2026-10-08):**
  - **Spec y decisión:** RF-393 a RF-397 en `01-spec.md` (subsección "Torres por mapa", después de RF-300), D-079 en `04-decisiones.md`; `CONTENIDO.md` explica el campo con ejemplo y `CHANGELOG.md` lo anota.
  - **Código:** campo `"torres"` en `LEVEL_KEYS`, `LevelFile._read_towers`, `LevelData.towers` y `available_towers`; `LevelDraft` conserva y escribe el campo. Se agregó `TowerOffer` y tarjetas en `level_select.gd`; `Game` agrega la torre de apoyo nombrada en `"torres"`.
  - **Qué se probó:** `tests/test_map_towers.gd` (16 tests) y suite completa: **1033/1033**, 0 `SCRIPT ERROR`/`Parse Error`. `check_level` acepta el ejemplo. Bot `mix`: nivel 6 conserva salida; nivel 9 gana 20/20 con 11 vidas y las mismas torres por oleada, aunque el oro final varía entre corridas.
  - **Qué no:** no se miró la tarjeta en pantalla (solo por tests); niveles oficiales aún no usan `"torres"`; no se probó un modo propio en pantalla. No hubo push (instrucción de la coordinación).
- [x] **T205** · 🚦 G3 · Spec de removibles, demolición, demoledora, recursos, extracción y colecciones (M50).
  **Refs:** M50 (RF-398 a RF-437), D-080 a D-085, Q-08 a Q-27 y Q-31 del 09. **Estado: spec escrita y APROBADA por Lucas (G3, 2026-10-08).** Por eso la tarea sigue **sin marcar**: "Hecho cuando" pide ese OK. Cuando Lucas lo dé, anotar acá la fecha y marcar `[x]`.
  **M50 · Infraestructura: demolición, recursos y hallazgos** reúne T205 a T214: T205 spec (esta), T206 removibles: formato y validación, T207 demolición directa, T208 demoledora global, T209 recursos locales y torres con costo en recursos, T210 extracción finita, T211 colecciones por tecnología, T212 editor, T213 modo de pruebas, T214 bot con estrategias y regla de oro.
  **Resultado parcial (2026-10-08):**
  - **Spec (`01-spec.md`, "M50"):** RF-398 a RF-437, en subsecciones: formato de removibles y extracción (RF-398 a RF-403), demolición directa (RF-404 a RF-410), demoledora (RF-411 a RF-414), recursos (RF-415 a RF-421), extracción (RF-422 a RF-424), colecciones (RF-425 a RF-431), regla de oro (RF-432 y RF-433), editor, pruebas y Wiki (RF-434 a RF-437), "Lo que M50 no incluye" y "Para revisar en G3". Enmiendas con nota en el lugar: RF-262 (`dibujo` opcional), RF-263 (3 dibujos), RF-300 (el Mortero debuta en el 9) y RF-362 (la barra elige la colección del nivel).
  - **Decisiones (`04-decisiones.md`):** D-080 (formato), D-081 (demolición), D-082 (demoledora), D-083 (recursos, Francotirador, Mortero y regla de oro), D-084 (extracción) y D-085 (colecciones), cada una con la pregunta del 09 y la fecha 2026-10-08.
  - **Plan técnico (`02-plan-tecnico.md`, "M50"):** `data/obstaculos.json` completo, las clases nuevas (`ObstacleCatalog`, `ObstacleSpec`, `ObstacleField`, `DemolitionJob`, `CollectionDefinitions`, `FindingRun`, `InfrastructureController`, `ObstaclePanel`, `InfrastructurePanel`, `ObstacleLayer`), la API de `ObstacleField`, el flujo entre las piezas, qué archivos toca cada tarea de T206 a T213 (y T214) y la tabla de estados visuales con nombres de archivo para Codex (T219 a T221).
  - **Otros documentos:** `CONTENIDO.md` explica el formato nuevo de la leyenda con un ejemplo (marcado como "todavía no lo lee el juego"). Se ajustaron las fichas T206 a T214 y T219 a T221 para que apunten a los RF y no contradigan la spec (en T213 los RF ya no los escribe la tarea). `CHANGELOG.md` no cambia: nada de esto lo ve quien juega todavía.
  - **Qué se probó:** nada de código; es solo documentación. Se verificó a mano la consistencia de números (RF y D sin saltos ni repeticiones: del RF-398 al RF-437 y del D-080 al D-085) y de los cruces entre RF, y que los ejemplos de amortización de RF-414 dan las cuentas que dicen. **No se corrió la suite de tests** (no se tocó código; la línea de base es 1033/1033 de T203).
  - **Qué no:** (1) **el tiempo que baja la demoledora no lo fijó el bot**, como pidió Lucas en Q-10, porque el bot no puede medir una demolición que todavía no existe: quedó 80 % provisional. (2) La lectura de "semilla del mapa" (Q-18) como una semilla nueva por partida es mía, y hay otra posible. (3) La probabilidad inicial del drop (50 %) y todos los números del archivo de datos son iniciales y no están medidos. (4) La forma de elegir el pago del Francotirador (dos botones) y los otros puntos de "Para revisar en G3" son elecciones de T205 que Lucas tiene que mirar. (5) No se probó nada del juego: es diseño. (6) No se abrió PR (la coordinación pidió solo commit y push de la rama).
- [x] **T206** · Removibles: formato y validación.
  **Resultado (2026-10-08):** se agregó `data/obstaculos.json` y el lector puro `ObstacleCatalog`; `LevelFile` valida las clases, sobrescrituras, dibujos, hallazgos, la bandera `demoledora` y arma `LevelData.obstacles` con valores resueltos. `MapGrid.clear_cell()` libera una casilla sin tocar `routes`; se sumaron dibujos provisionales, marca ámbar, conservación en el editor, el ejemplo `tools/ejemplos/mapa_removibles.json` y la actualización de `CONTENIDO.md`.
  - **Qué se probó:** `godot --headless --import` sin errores; GUT completo **1041/1041**, 0 `SCRIPT ERROR`/`Parse Error`. `check_level` acepta el ejemplo y muestra **3 removibles, 1 mina**, con el recorrido A→S intacto. Los tests incluyen formato válido e inválido, clase inexistente, claves mal escritas, límites, dibujos, hallazgos duplicados, campo `demoledora`, compatibilidad de los nueve niveles, conservación del editor y rutas sin cambios al despejar.
  - **Qué no:** no se verificó visualmente el mapa en una ventana del juego ni se midió balance; la demolición todavía corresponde a T207.
- [x] **T207** · Demolición directa.
  **Resultado (2026-10-08):** un removible se elige con un clic (también en el modo construcción, donde no construye), abre el panel "Demoler" con costo, tiempo y recompensa sin mostrar el sorteo, y al pulsar se cobra y arranca un trabajo con el reloj de la partida. Se puede cancelar con reembolso total; al terminar la casilla queda pasto construible y el panel se cierra. Lógica pura nueva: `DemolitionJob`, `ObstacleField` (con el sorteo del drop al empezar, en orden de fila y columna, con semilla) y `ObstacleText`. Conexión: `InfrastructureController` (cobro, reembolso, aviso flotante, sonido `build`), `ObstacleLayer` (barra de progreso y velo que se desvanece), `ObstaclePanel` en el HUD, `Level.clear_removable` (usa `MapGrid.clear_cell` de T206) y la selección en `BuildController`. `GameFlow.forced_seed` fija la semilla (bot y tests).
  - **Qué se probó:** `godot --headless --import` sin errores; GUT completo **1065/1065** (24 tests nuevos en `tests/test_demolition.gd`), 0 `SCRIPT ERROR`/`Parse Error`; los dos `ERROR` de la línea de base (`no_existe` y "resources still in use") siguen igual. Cubren: cobrar al ordenar, sin oro, una sola a la vez, cancelar con reembolso total, terminar y construir, no repetir la recompensa, el sorteo con semilla (mismo resultado, 0 % y 100 %, sin re-sortear al cancelar), la oleada que termina con el trabajo en curso, el fin de partida que lo descarta sin devolver oro, la pausa (`can_process()` falso), velocidad ×2 (medida en tiempo real) y el reintento. Captura con el ejemplo `mapa_removibles.json` en `art/m50/demolicion.png` (roca en trabajo con barra y panel "Cancelar").
  - **Qué no:** (1) el clic real del mouse sobre un removible **no está probado automáticamente** (en headless no se puede mover el mouse): los tests usan la misma función que llama el clic, y a mano solo se vio la captura, no se jugó una partida entera con clics. (2) El bot en los niveles 6 y 9 **no se corrió**: los niveles oficiales no tienen removibles y los 1065 tests pasan, pero no medí que el bot dé lo mismo. (3) Los recursos **no se suman a la sesión** (es T209: solo se muestra "+1 recurso") y la **pieza de colección no se recoge** (T211); por ahora `recovered` llega vacío, así que una ruina con hallazgo siempre dice "pendiente". (4) Los puntos de extracción todavía no se eligen (T210). (5) La demoledora no altera el costo ni el tiempo (T208): `cost_of`/`seconds_of` devuelven los de la clase. (6) No se creó PR (la coordinación pidió solo commit y push de la rama).
- [x] **T208** · Demoledora global.
  **Resultado (2026-10-08):** `ObstacleField` registra la compra única y calcula el precio mínimo del 10 % y el 80 % del tiempo usando `data/obstaculos.json`; el controlador habilita y cobra los 180 de oro solo en niveles que lo permiten. El HUD muestra el botón y panel **Infraestructura** solo cuando corresponde, informa el ahorro por removible y refleja el estado activo; una orden previa conserva lo pagado y su duración, y al reiniciar se pierde la compra. Se agregó `tools/ejemplos/mapa_demoledora.json`, jugable con cinco removibles y cuatro rocas para comprobar la amortización, además de pruebas de fórmulas, mínimo sin subir el precio, precios globales, compra sin oro y duplicada, nivel sin habilitar, amortización RF-414, panel y trabajo iniciado antes de comprar.
  - **Qué se probó:** `godot --headless --import` terminó correctamente; GUT completo **1071/1071**, sin `SCRIPT ERROR` ni `Parse Error`. En esta corrida apareció el error esperado de línea de base del nivel `no_existe`; no apareció el mensaje final `resources still in use`. `check_level` acepta el ejemplo e informa **5 removibles y 1 mina**, con el recorrido intacto. Los tests automáticos cubren las reglas y la integración lógica del HUD.
  - **Qué no:** no se jugó una partida interactuando con el botón en una ventana ni se midió el balance del 80 %; ese valor sigue provisional hasta T214/T223. No se creó PR: la coordinación indicó solo commit y push de la rama.
- [x] **T209** · Recursos locales y torres con costo en recursos.
  **Refs:** RF-415 a RF-421, D-083 (Q-18, Q-21 a Q-24).
  **Resultado (2026-10-08):**
  - **Código:** `LevelSession` lleva `resources` (0 al empezar y al reiniciar), `resources_changed`, `add_resources`, `can_afford_both` y `spend_both` (atómico). `TowerData` gana `resource_cost`, `alt_gold_cost`, `alt_resource_cost` y los ayudantes `build_gold(alt)`/`build_resources(alt)`. `Tower` guarda `resources_invested`; `BuildController.try_build(…, alt)` cobra con `spend_both`, `sell_resource_value` devuelve el mismo % redondeado hacia abajo y `set_pay_alt` guarda la forma de pago (arranca en solo oro y vuelve a eso al cambiar o cancelar). `InfrastructureController` suma la recompensa de la demolición a la sesión (una sola vez: la casilla ya no se puede volver a demoler). HUD: contador con ícono provisional dibujado (solo si `LevelData.uses_resources()`), barra con "300 + 3" y el ícono, deshabilitada con el motivo en el tooltip (el Francotirador solo se apaga si no alcanza ninguna de las dos formas) y dos botones chicos de pago en la ayuda de construcción. Panel de torre (botón Vender con los recursos y línea "Recursos invertidos") y ficha de la Wiki leen los datos mediante `TowerText` (`cost_text`, `bar_text`, `missing_text`, `refund_text`, `cost_facts`). `LevelFile` avisa (RF-421) si el mapa ofrece una torre con `resource_cost` y no tiene recursos. Datos: `mortar.tres` con `resource_cost = 3` y `sniper.tres` con 120 de oro + 1 recurso.
  - **Ejemplo jugable:** `tools/ejemplos/mapa_recursos.json` (tres removibles que dan 1 recurso cada uno, Mortero y Francotirador). `CONTENIDO.md`, `ONBOARDING.md` y `CHANGELOG.md` actualizados.
  - **Qué se probó:** `tests/test_resources.gd` (32 tests nuevos): datos de las dos torres y que ninguna mezcla `resource_cost` con `alt_*`, sesión (0 al empezar y reiniciar, `spend_both` atómico, borde costo 0), construir con 2 y con 3 recursos y con 299 de oro, mejorar sin cobrar recursos, vender (210 y 2; el Francotirador con recurso devuelve 0), la recompensa entra una sola vez y con probabilidad 0 no entra, el contador oculto/visible, la barra y los dos botones de pago (con el motivo), el panel, la Wiki y el aviso de `check_level`. Se corrigieron 4 tests viejos del Mortero (`test_mortar`, `test_sprites`) que construían solo con oro. Suite completa: **1097/1097** (1065 + 32), 0 `SCRIPT ERROR`/`Parse Error`; los dos `ERROR` de la línea de base siguen. `check_level` acepta `mapa_recursos.json` sin avisos y avisa en `mapa_torres_apagadas.json` (Mortero sin recursos).
  - **Qué no:** (1) **no se jugó con el mouse real**: la barra, los botones de pago y el contador se probaron por código, no a ojo (posición del ícono chico en el botón, tamaño y que entren los botones en la línea de ayuda con descripciones largas son a ojo). (2) **Bot:** `mix` en los niveles 3, 6 y 9 corre sin errores, pero **no comparé los números contra el código anterior** (el bot no es determinista en el oro, ver T203); los niveles 1 a 9 no ofrecen el Mortero ni usan la segunda forma del Francotirador, y el bot compra con la forma de oro, que no cambió. (3) El Mortero **no se habilitó en el nivel 9**: eso es de T224; sigue `reserved`. (4) El bot no sabe usar recursos (T214). (5) La señal `BuildController.tower_sold` ganó un tercer parámetro (`resource_refund`). (6) Sin PR (la coordinación pidió commit y push de la rama).
- [x] **T210** · Extracción finita.
  **Refs:** RF-422 a RF-424, D-084 (Q-19 y Q-20).
  **Resultado (2026-10-08):**
  - **Código:** `ObstacleField` lleva la reserva de cada punto y gana `is_extraction`, `can_enable`, `enable_site`, `complete_wave()` (devuelve celda → recursos producidos, `min(producción, reserva)`, y deja agotado al que llega a 0), `reserve_left`, `extraction_cells` y la señal `site_changed`. `InfrastructureController` ahora deja elegir los puntos de extracción en cualquier estado, tiene `enable(cell)` (cobra el oro y habilita, sin cancelar) y escucha `LevelSession.wave_completed`: suma los recursos a la sesión y muestra "+N recursos" con `FloatingText`. `jump_to_wave` no emite `wave_completed`, así que el salto (RF-319) no produce. `ObstaclePanel` muestra los tres estados ("Habilitar extracción (100 de oro)", "Produce 2 recursos por oleada · Reserva N/M", "Agotada") con la señal `enable_pressed`; los textos están en `ObstacleText`. `ObstacleLayer` dibuja de forma provisional el estado (velo gris y marco ámbar / marco verde / velo oscuro) y la reserva en segmentos (hasta 8). Los números siguen en `data/obstaculos.json`.
  - **Qué se probó:** `tests/test_extraction.gd` (20 tests nuevos): no produce sin habilitar, 2-2-2-2 y agotada, nunca supera la reserva (reserva 1 con producción 2; reserva impar 5), reserva 0 nace agotada, no se habilita dos veces ni agotada ni un removible, el reinicio (`setup`) restaura, varios puntos independientes; en partida: se elige en todos los estados, habilitar cobra al instante, sin oro no cambia nada, el ejemplo jugable (4 oleadas con 2 recursos cada una), esperar y `jump_to_wave` no producen, la oleada en curso al habilitar cuenta, el aviso flotante aparece y el panel en los tres estados y sin oro. Suite completa: **1117/1117** (1097 + 20), 0 `SCRIPT ERROR`/`Parse Error`; los dos `ERROR` de la línea de base siguen.
  - **Para el balance (T214, sin tocar números):** habilitar cuesta 100 de oro y devuelve 8 recursos en total. En oro puro **solo se recupera si los recursos valen más de 12,5 de oro cada uno**. Contra el Francotirador (cada recurso ahorra 30 de oro: 150 contra 120) los 8 valen 240, así que se recupera con holgura; contra el Mortero (3 recursos por torre, 300 de oro) el valor depende de cuánto valga esa torre y no lo medí.
  - **Qué no:** (1) no se jugó con el mouse real: el panel y los segmentos se probaron por código, no a ojo (que los segmentos se lean a 34 px es a ojo). (2) No hay captura de pantalla de los tres estados. (3) El bot no sabe habilitar puntos (es T214). (4) El editor y el modo de pruebas no tienen nada nuevo (T212 y T213). (5) Sin PR (la coordinación pidió solo commit y push de la rama).
- [x] **T204** · Bot de balance con varias semillas.
  - **Resultado (2026-10-08):** `tools/balance_sim.gd` ahora acepta `seed=N`, `seeds=N`, `levels=A-B`, varias estrategias separadas por coma (`mix,smart`) y `report=ruta.json`. Juega una cola de partidas en un solo proceso y, al final, imprime la tabla (mapa, estrategia, semilla, resultado, vidas, oleada y oro sobrante) y, si se pide, la guarda en JSON. La lectura de rangos vive en `scripts/logic/balance_args.gd` (nuevo, funciones puras) con `tests/test_balance_args.gd` (5 tests). Documentado en el encabezado del script y en `ONBOARDING.md`.
  - **Azar fijado (sin tocar el juego):** (1) el temblor de pantalla (RF-128) y el resto de los `randf` sueltos del juego usan el generador global: el bot llama a `seed(N)` antes de cada partida; (2) el sorteo de grupos (RF-364) usa `WaveSpawner.rng`, que se mezcla con `randomize()` en su `setup()`: el bot le fija la semilla ya armada la partida (solo inyecta el generador, sin cambiar código del juego); (3) las casillas al azar de `naive` usan el `rng` propio del bot. El portador del avance (`game.gd`, `_setup_collection`) no corre en el bot (exige `GameFlow.current_index >= 0`) y el robo del Ladrón no usa números al azar en el código (`grep randf|randi` no lo encontró), así que no hubo nada que fijar ahí.
  - **Qué se probó:** `mix level=7 seed=3` corrido dos veces seguidas dio lo mismo (VICTORIA, 16 vidas, 358 de oro). La corrida `mix levels=1-9 seeds=3` terminó (27 partidas) con 0 `SCRIPT ERROR`. Tests completos: 1022/1022 (1017 + 5 nuevos), 0 `SCRIPT ERROR`/`Parse Error`. Hallazgo: antes de arreglar el azar del `WaveSpawner`, el mismo caso daba 355 y 358 de oro; el arreglo lo hace repetible.
  - **Línea de base `mix` (mapas 1–9 × semillas 1–3), para T223 y T224** (vidas / oleada / oro sobrante):

    | Mapa | Semilla 1 | Semilla 2 | Semilla 3 |
    |---|---|---|---|
    | 1 | ✔ 20 · 10/10 · 241 | ✔ 20 · 10/10 · 241 | ✔ 20 · 10/10 · 241 |
    | 2 | ✘ 0 · 15/15 · 33 | ✘ 0 · 15/15 · 33 | ✘ 0 · 15/15 · 33 |
    | 3 | ✔ 16 · 20/20 · 310 | ✔ 16 · 20/20 · 310 | ✔ 16 · 20/20 · 310 |
    | 4 | ✔ 10 · 15/15 · 316 | ✔ 10 · 15/15 · 316 | ✔ 10 · 15/15 · 316 |
    | 5 | ✔ 13 · 20/20 · 283 | ✔ 13 · 20/20 · 283 | ✔ 13 · 20/20 · 283 |
    | 6 | ✔ 10 · 15/15 · 275 | ✔ 10 · 15/15 · 275 | ✔ 10 · 15/15 · 275 |
    | 7 | ✔ 16 · 20/20 · 346 | ✔ 16 · 20/20 · 358 | ✔ 16 · 20/20 · 358 |
    | 8 | ✔ 20 · 18/18 · 337 | ✔ 20 · 18/18 · 273 | ✔ 20 · 18/18 · 273 |
    | 9 | ✔ 11 · 20/20 · 351 | ✔ 11 · 20/20 · 364 | ✔ 11 · 20/20 · 273 |

    24 victorias de 27. **Aviso para Lucas:** con `mix` el mapa 2 se **pierde** en la última oleada (15/15) con las 3 semillas; no se investigó si es esperado o un problema de balance (no era parte de T204). Las semillas solo cambian el oro en los mapas 7–9; en 1–6 no hay sorteos que dependan de ellas.
  - **Qué no:** no se probaron las otras estrategias (`smart`, `heavy`, `basic`, `naive`) en la corrida larga, ni `report=` con una ruta que no sea `user://`, ni `levels=` con `file=` o `modo=` (con esos, `level=N` sigue siendo un solo mapa). Al salir, Godot imprime advertencias de objetos sin liberar (`ObjectDB instances were leaked`): ya salían antes de este cambio con el script original. No se actualizó `CHANGELOG.md` porque no cambia nada de lo que ve quien juega.
- [x] **T211** · Colecciones por tecnología.
  **Resultado (2026-10-08):** `data/progression.json` admite varias colecciones: `technology` queda idéntica y se suma `disruptor` (3 piezas, `origen: "hallazgo"`, niveles 8 a 10). Lógica pura nueva: `CollectionDefinitions` (`all`, `required`, `eligible`, `origin`, `name_of`, `icon_of`, `collection_of_level`, `problems`) y `FindingRun` (`pick`, `complete_wave`, `pending`, `confirmed`, id único `<colección>:<nivel>`); `CollectibleRun.definitions/eligible/required` son envoltorios. `Game` recoge la pieza al terminar la demolición (`demolished`), la confirma con la oleada en curso o la siguiente, y la guarda al terminar la partida (`_commit_findings`); el formato del guardado no cambió (`SaveManager` quedó sin tocar: ya aceptaba cualquier colección con fuentes oficiales). Fuera de la campaña (modos, comunidad, editor, pruebas) la ruina se comporta como "ya recuperada" y el panel dice "Aquí no se recogen piezas". La barra muestra la colección del nivel y la Wiki tiene la solapa **Colecciones** (progreso y torre que desbloquea). El nombre de la colección sale de los datos y reemplaza el provisorio de `ObstacleText`.
  - **Qué se probó:** `godot --headless --import` sin errores; GUT completo **1089/1089** (24 tests nuevos en `tests/test_collections.gd`), 0 `SCRIPT ERROR`/`Parse Error`; solo aparece el `ERROR` de línea de base de `no_existe`. Los tests de M37 y M38 pasan sin cambios. Cubren: las dos colecciones conviven, `technology` igual, un guardado v1 literal carga, colecciones desconocidas y niveles ajenos se ignoran, el guardado conserva la versión, repetir no duplica, pendiente/confirmada, varias pendientes, derrota antes de confirmar pierde la pieza y derrota después la conserva, el panel dice "pendiente"/"ya recuperada"/"Aquí no se recogen piezas", editor/comunidad/pruebas no guardan, la barra (1/3 y 2/3) y completar la colección habilita una torre de test. El mapa de ejemplo se arma en memoria con una campaña falsa de un nivel (`level_08`) y entrega, confirma y guarda la pieza en `user://test_collections.json`.
  - **Ajuste a tests existentes (justificado):** `tests/test_wiki_screen.gd` cambia en dos aserciones porque la Wiki tiene una solapa más (Colecciones); no es de M37 ni M38.
  - **Qué no:** (1) no se jugó una partida entera con clics reales; todo va por las mismas funciones que llama la interfaz. (2) `required_collection = &"disruptor"` en la Disruptora queda para T217; no hay mapas oficiales con ruinas (los niveles 8 y 9 no traen escombros), así que la colección empieza vacía. (3) El ícono propio de cada colección no existe: `icono` es opcional y se usa el disco plateado para todas hasta que llegue el arte (Q-39). (4) La tarjeta de la selección de nivel no menciona la pieza de la Disruptora. (5) Los recursos de la ruina ya recuperada (`recursos_si_recuperado`) siguen sin sumarse a la sesión: es T209. (6) No se creó PR (la coordinación pidió solo commit y push de la rama).
- [x] **T201** · 🚦 G2 · Biblia del universo (`specs/10-universo.md`).
  **Estado (2026-10-08): borrador listo para la revisión de Lucas; sigue en `[ ]` hasta su OK (G2).**
  **Resultado (borrador):**
  - **Qué se hizo:** `specs/10-universo.md` (377 líneas) con las 10 secciones de la ficha, más una sección 0 con lo que Lucas tiene que decidir y un apéndice de fuentes y límites. Cada afirmación lleva una marca (**CANON** / **PROPUESTA** / **OPCIÓN** / **SEMILLA**) para que se vea qué acordó Lucas y qué propuse yo. Sale del 07, 08 y 09 y usa los nombres del informe de T202. No contradice el 07. Enlazado desde `CLAUDE.md` ("Dónde está cada cosa") y desde el 07 §14.
  - **Lo que tiene que elegir Lucas (G2):** tres nombres con 3 opciones cada uno (Q-03): planeta (Sosiego / Cántaro / Varadero), colonia (Arraigo / La Posta / Compañía Meridiana) y cómo llaman los colonos a las comunidades (Moradores / Marcados / Primeros). Más 7 preguntas abiertas (P-1 a P-7) con mi recomendación: alianza de tres pueblos o uno con tres oficios, el Soberano como tipo o individuo, el origen de los cinco avances, quién dejó las ruinas, las categorías Bestia/Criatura, la señal `hito` para el 11–13 y el doble sentido Canons/cánones.
  - **Decisiones de Lucas respetadas:** nivel 15 con jefe supremo nuevo que **no** se define acá (lo hace T243; solo se dejan restricciones de coherencia, Q-32); textos de hasta 3 y 2 líneas y sin diálogos (Q-01); ruinas y señales con el mismo símbolo A (plan 08 §5); Lanzamisiles y Épocas fuera.
  - **Qué se probó:** nada de código (es solo documentación; no se corrieron los tests). Se revisó a mano que las 10 secciones existan, que los niveles, lugares y debuts coincidan con el plan 08 §5 y las respuestas del 09, y que ningún ejemplo de tono pase de 3 líneas (entrada) y 2 (victoria).
  - **Qué no:** no se abrió el juego ni se miró ningún PNG (el aspecto de cada especie sale de los documentos de arte y de T202, que tampoco lo verificó a ojo; el Volador queda "por confirmar", Q-5 de T202). No se escribió ningún texto final de nivel (es T227/T228). Los nombres propuestos no se buscaron en otras obras ni se comprobó que estén libres como marca. Las líneas "qué busca" de cada especie y todo lo marcado PROPUESTA son criterio mío, no hechos del juego.
  - **OK de Lucas (G2, 2026-10-08):** planeta **Cántaro**, colonia **Compañía Meridiana**, comunidades **Moradores**; P-1 a P-7 aceptadas con la recomendación. Se desbloquean T218 y T227. No se hizo merge a `main`.
- [x] **T202** · Auditoría de nombres y glosario canónico.
  **Resultado:** informe en `specs/tareas/informes/T202-glosario.md` con la tabla de las 10 torres, los 15 enemigos, los 7 temas y los conceptos (juego, avance/pieza/fuente, colección, Estandarte, desgaste, aturdimiento, modo de pruebas), 9 preguntas para Lucas (G2) y la lista de archivos que habría que cambiar. Hallazgos principales: el Normal, el Rápido y el Tanque tienen en la guía §3 una especie y un color que ya no son los del dibujo (M24); el Curandero cambió en M43; la tabla de §3 tiene 13 filas para 15 enemigos (faltan Embestidor y Ladrón); la torre de apoyo tiene cuatro nombres (Estandarte mecánico, Estandarte, Mecánico, estatua); "Monsters & Canons" puede ser un error de "Cannons". **Qué se probó:** nada de código (es solo documentación; no se corrieron los tests). **Qué no:** no se abrió el juego ni se miró cada PNG; lo del "dibujo ya no coincide" sale de lo que dicen los documentos de arte y de las aprobaciones de Lucas, no de ver el arte actual. No se cambió ningún archivo del juego ni de la spec.
- [x] **T212** · Editor: sistemas nuevos.
  **Refs:** RF-434 y RF-435 (amplían RF-266 y RF-394), Q-31, D-080.
  **Resultado (2026-10-08):**
  - **Pinceles:** `LevelDraft.Tool` suma `TREE`, `ROCK`, `RUBBLE`, `MINE` y `FOREST` (botones "Árbol", "Roca", "Escombro", "Mina" y "Bosque", teclas 6 a 9 y 0). Cada uno **reusa** la letra de la leyenda que sea exactamente `{"removible": {"clase": …}}` (o `extraccion`), sin sobrescrituras, o **crea** una (prefiere `t r u m b`, si no la primera letra libre `a`…`9` que no esté en la leyenda ni en el mapa). En el tope de 10 letras (RF-262) no pinta, no deja paso de deshacer y deja el motivo en `LevelDraft.last_problem`, que el editor muestra debajo del estado del nivel. Borrar o pintar encima de la última casilla de un objeto **saca su letra** de la leyenda (si no, quedaba una letra sin usar ocupando uno de los 10 lugares); solo se saca la letra que se acaba de dejar de usar, nunca las que el archivo ya traía sin usar.
  - **Panel "Objetos"** (`scenes/editor/objects_panel.gd`, botón nuevo en la barra): se elige una letra y se sobrescriben `costo`, `tiempo`, `recursos`, `probabilidad` (o `costo`, `produccion`, `reserva`) para todas sus casillas, mostrando el valor de la clase; escribir el valor de la clase borra la sobrescritura; los valores se acomodan a lo que acepta `LevelFile` (costo ≥ 1, probabilidad 0 a 100, tiempo ≥ 0,1). Campo **hallazgo** del escombro con las colecciones de `progression.json`.
  - **Ajustes:** casilla "Demoledora disponible" (apagarla borra el campo) y "Torres del mapa" (una casilla por torre en el orden canónico, `TowerOffer.canonical_towers()`). La primera vez que se marca o desmarca una, se escribe la lista completa de lo que ya se ofrecía; no deja la lista vacía (la última casilla vuelve a marcarse); los ids desconocidos ya escritos se conservan al final; "Usar las de siempre" borra `"torres"`.
  - **RF-435:** `LevelDraft.is_campaign()` es verdadero mientras el borrador viene de un nivel oficial abierto como plantilla (`from_campaign`) y todavía no se guardó como mapa de la comunidad o de un modo (`file_id` y `mode_id` vacíos). Fuera de eso, el campo está deshabilitado con *"Las piezas de colección solo se consiguen en la campaña"*, `set_finding` no hace nada y un hallazgo ya escrito **se conserva siempre**. El editor sigue sin escribir en `data/`.
  - **Decisión mía a confirmar:** RF-435 dice "mientras el borrador es un nivel de la campaña" sin definir cuándo lo es. Elegí la definición de arriba, porque el editor nunca guarda en `data/` y la única forma de tener un nivel de la campaña en el editor es abrirlo como plantilla. Consecuencia: **un mapa nuevo desde cero nunca puede llevar hallazgo**, y al guardar una plantilla de la campaña como mapa propio el campo se cierra. Si Lucas quiere otra cosa (por ejemplo, un interruptor "este mapa es de la campaña"), es un cambio chico.
  - **Ida y vuelta:** abrir y guardar conserva todo. El texto de los 9 niveles oficiales sigue saliendo **idéntico** (test que ya existía) y los 15 archivos de `tools/ejemplos/` más los 9 niveles dan el mismo JSON, los mismos errores y los mismos avisos que al leerlos directo. `tools/ejemplos/mapa_removibles.json` (el de T206 y T210) se **rearma solo con pinceles, valores y ajustes** y el JSON resultante es igual al del ejemplo. Los números de la leyenda se guardan como decimales (`50.0`, como los lee el cargador y como ya están los niveles 6 y 7): para el juego es lo mismo, pero un archivo escrito a mano con `50` queda con `50.0` al guardarlo desde el editor.
  - **Qué se probó:** `godot --headless --import` sin errores; suite GUT completa **1204/1204** (38 tests nuevos en `tests/test_editor_objects.gd`: pinceles, reuso, límite de letras en el borde 10 y 11, trazo como un paso de deshacer, valores por letra y sus topes, hallazgo en campaña, comunidad y tras guardar, demoledora, torres, ida y vuelta de todos los ejemplos, el panel y los Ajustes en la escena, y "Probar" entrega el nivel con los objetos), 0 `SCRIPT ERROR`/`Parse Error`; solo los dos `ERROR` de la línea de base. En `test_map_editor.gd` se actualizó el conteo de botones (de 5 a 10 herramientas). `--import` no reescribió ningún SVG.
  - **Qué no:** (1) **no vi el editor en pantalla**: el ancho de la barra con 10 herramientas, el panel de Ajustes con las 11 casillas de torres (puede ser alto) y el panel de Objetos se probaron por código, no a ojo. (2) "Probar" se probó hasta que entrega el `LevelData` con removibles, extracción y demoledora; **no jugué una partida** desde el editor con el mouse. (3) No hay un botón para quitar a mano una sobrescritura: se logra escribiendo el valor de la clase. (4) Ningún pincel pone un `hallazgo`; eso se hace en el panel. (5) Sin PR (la coordinación pidió solo commit y push de la rama).
- [ ] **T213** · Modo de pruebas: sistemas nuevos.
- [x] **T214** · Bot: estrategias con recursos y regla de oro.
  **Refs:** RF-432 y RF-433, D-083.
  **Resultado (2026-10-08):**
  - **Código:** `tools/balance_sim.gd` suma las estrategias `sin_recursos`, `demoler`, `demoledora`, `extraer_temprano` y `extraer_tarde` (se pueden combinar con `seeds=`, `levels=`, `file=`), `check_rule=1` y cinco columnas nuevas (oleada de compra de la máquina, recursos obtenidos y sobrantes, oro invertido en infraestructura y oleada de la primera torre con recursos), también en el JSON de `report=`. El bot fija `GameFlow.forced_seed` con la semilla de la partida, así que el drop de los removibles es repetible. Las lecturas puras (nombres de estrategias, N = 5, M = 4, veredicto y código de salida) están en `scripts/logic/balance_args.gd` con 8 tests nuevos. Las estrategias viejas (`smart`, `mix`, `heavy`, `basic`, `naive`) no cambiaron.
  - **Decisiones de diseño del bot (herramienta, no del juego; elegí lo más simple):** (1) las cinco usan el orden de `mix` pero solo con las torres que el mapa ofrece (las viejas ignoran la lista `torres`). (2) Un removible "vale la pena" si desde su casilla la primera torre del orden alcanzaría más camino que desde la mejor casilla libre que queda. (3) Para juntar oro, el bot deja de comprar torres después de las 2 primeras hasta pagar la máquina, la demolición o la extracción. (4) `demoledora` compra la máquina cuando quedan 4 o más removibles que valen la pena; con menos, demuele sin ella. (5) Las de extracción habilitan los puntos de a uno, el de más reserva primero: `temprano` desde la oleada 1, `tarde` desde la mitad de las oleadas. (6) Torre con recursos: la primera del mapa que alcance, con la segunda forma de pago si la tiene (Francotirador: 120 + 1) y si no con su costo (Mortero). Solo las usan las de extracción.
  - **Mapa de ejemplo:** T210 no dejó un archivo en `tools/ejemplos/`, así que creé `tools/ejemplos/mapa_extraccion.json` (30 removibles pegados al camino, una mina, un bosque explotable, demoledora, Mortero y Francotirador, 6 oleadas, 500 de oro). Un primer intento con el mapa abierto no servía: el bot nunca demolía porque siempre sobraba una casilla libre igual de buena.
  - **Tabla 5 estrategias × 3 semillas en ese mapa** (vidas · oro sobrante · máquina · recursos obtenidos/sobrantes · oro de infraestructura · 1.ª torre con recursos; las 3 semillas dieron VICTORIA y 6/6 oleadas):

    | Estrategia | Semilla 1 | Semilla 2 | Semilla 3 |
    |---|---|---|---|
    | `sin_recursos` | 16 · 81 · — · 0/0 · 0 · — | 16 · 81 · — · 0/0 · 0 · — | 16 · 81 · — · 0/0 · 0 · — |
    | `demoler` | 14 · 96 · — · 0/0 · 120 · — | 14 · 96 · — · 0/0 · 120 · — | 14 · 96 · — · 2/2 · 120 · — |
    | `demoledora` | 12 · 154 · o3 · 1/1 · 197 · — | 12 · 154 · o3 · 1/1 · 197 · — | 12 · 154 · o3 · 3/3 · 197 · — |
    | `extraer_temprano` | 12 · 151 · — · 16/16 · 200 · — | 12 · 151 · — · 16/16 · 200 · — | 12 · 151 · — · 16/16 · 200 · — |
    | `extraer_tarde` | 14 · 166 · — · 10/10 · 200 · — | 14 · 166 · — · 10/10 · 200 · — | 14 · 166 · — · 10/10 · 200 · — |

    **Lectura honesta:** en este mapa ninguna estrategia con infraestructura mejora a `sin_recursos` (pierde 2 a 4 vidas). Los recursos de la extracción llegan al final de cada oleada y el oro no alcanza para gastarlos: **ninguna extracción construyó una torre con recursos** (todos quedaron sobrantes). Con otros números (más oro, minas con más producción, o más oleadas) puede cambiar; no lo toqué porque son de T223 en adelante. Solo `demoler` y `demoledora` cambian con la semilla (el drop de los árboles).
  - **`check_rule=1`:** `file=tools/ejemplos/mapa_extraccion.json` → 5 de 5, "CUMPLE", **código de salida 0**; el mismo mapa con `hp=20` → 0 de 5, "NO CUMPLE", **código de salida 1**. Sin mapas con recursos en la campaña (hoy ninguno) dice que no hay nada que comprobar y sale con 0 (los niveles 11 a 15 todavía no existen).
  - **Qué se probó:** `godot --headless --import` sin errores; GUT completo **1161/1161** (8 tests nuevos de la regla de oro en `tests/test_balance_args.gd`), 0 `SCRIPT ERROR`/`Parse Error`; solo los dos `ERROR` de la línea de base. Control: `mix levels=3-4 seed=1` da lo mismo que la línea de base de T204 (16 vidas con 310 de oro; 10 con 316). Se corrieron las 5 estrategias sin errores en `mapa_recursos`, `mapa_demoledora` y `mapa_removibles` (todas ganan sin diferencias: tienen 1 o 2 oleadas y son abiertos).
  - **Arreglo ajeno a la ficha (importante):** `tools/balance_sim.gd` y `check_level.gd` **no compilaban** desde T211: `Wiki._collection_entries` nombraba el autoload `SaveManager` y los scripts de `tools/` se compilan antes que los autoloads (error `Identifier not found: SaveManager`). Los tests no lo notaban. En `scripts/logic/wiki.gd` ahora busca el autoload por el árbol (sin autoload, progreso 0). Mismo motivo: el bot no declara variables de tipo `InfrastructureController` (usa `Node`).
  - **Qué no:** (1) no hay ningún mapa de la campaña con recursos, así que `check_rule=1` sobre la campaña no comprobó nada real todavía (es para T223 en adelante). (2) El bot no usa los recursos de `demoler` ni de `demoledora`. (3) La tabla sale de **un** mapa que armé yo y no es evidencia de balance. (4) No se probó `levels=` con `file=`/`modo=` (sigue siendo un solo mapa). (5) Sin PR (la coordinación pidió commit y push de la rama).
- [x] **T215** · 📜 Spec de la Disruptora (M51).
  **Refs:** M51 (RF-438 a RF-452), D-086 y D-087, Q-33, Q-25 y Q-29 del 09, 07 §9.
  **Resultado (2026-10-08):**
  - **Spec (`01-spec.md`, "M51 · Disruptora"):** RF-438 a RF-452 con criterio Dado/Cuando/Entonces, en subsecciones: el pulso (RF-438 a RF-448: qué es, datos, cuándo pulsa, a quién le pega, supresión, lo ya recibido, lo que no hace, interacciones con Chamán, Embestidor y Mecánico, números y mejoras, disponibilidad y barra), cómo se lee (RF-449 y RF-450), dibujo (RF-451) y bot (RF-452). Más "Lo que M51 no incluye" y "Para revisar" (7 puntos). **No cambia ningún RF existente** (RF-284 queda igual: el Espejo se deja fuera del pulso, RF-444). Un campo nuevo de datos: `suppress_seconds` en `TowerLevelData`.
  - **Decisiones (`04-decisiones.md`):** D-086 (por qué suprimir al emisor y no cortar el aura en el receptor, comparada con la Eléctrica, con el Aislador relegado y con las alternativas descartadas) y D-087 (reglas de borde: espera a un emisor, el Espejo queda fuera, lo ya recibido no se corta, la décima torre).
  - **Plan técnico (`02-plan-tecnico.md`, "M51"):** datos, cambios en `enemy.gd` y `tower.gd`, efecto, texto, bot, qué archivos toca T216 y T217, las 7 familias de pruebas que T217 tiene que escribir y cómo comprobar que la torre sirve (3 semillas, con y sin Disruptora).
  - **Arte:** la ficha para Codex está en `art/m51-disruptora/FICHA.md` (tabla "cómo se distingue de la Eléctrica", entregables, colores y estados). Las fichas `T216` y `T217` apuntan a los RF y a esa ficha. `07 §9` anota que las reglas quedaron cerradas.
  - **Valores:** salvo lo que Q-33 no decía, son los de Lucas (pulso cada 4 s, radio 2,5/3/3,5, supresión 2,5/3/3,5 s, daño 5, 130 de oro + 2 recursos).
  - **Qué se probó:** nada del juego (es documentación). Se verificó a mano que RF-438 a RF-452 y D-086/D-087 son los siguientes libres, sin saltos ni repeticiones; que los números citados (91 de oro y 1 recurso al vender, cobertura 62,5/75/87,5 %, 3,33 s con el Mecánico de nivel 3, 6,67 s con 40 de desgaste, ≈13 % del daño por segundo de la Eléctrica) dan las cuentas que dicen; y que los nombres de funciones y campos del código que cita el plan existen (`has_aura`, `receive_aura`, `_pulse_aura`, `AURA_DURATION`, `stun`, `effective_fire_rate`, `reserved`, `required_collection`, `RingEffect`). Suite completa: **1033/1033**, 0 `SCRIPT ERROR`/`Parse Error` (la misma línea de base de T203); `--import` no reescribió ningún SVG.
  - **Qué no:** (1) **no hay código ni se probó nada en pantalla**: la lectura del pulso y de la marca de supresión (blanco azulado frente al celeste del Hielo) es una propuesta que hay que ver en una captura real. (2) **El costo de mejorar (100 y 150) lo puse yo**: Q-33 no lo fija; es provisional. (3) **Tres lecturas mías de Q-33** que Lucas tiene que mirar (puntos 1, 3 y 4 de "Para revisar"): el Espejo queda fuera del pulso y los otros tres enemigos reciben el golpe bajo pero conservan su habilidad; solo pulsa si hay un emisor; lo ya recibido no se corta. (4) La **décima torre** y las teclas (punto 5): no se agregó una tecla nueva. (5) El **Aislador** no tiene reglas escritas en 07, así que la comparación de D-086 es solo con lo que el 07 dice. (6) El bot no está probado con la Disruptora (no existe todavía). (7) Le consulté los puntos 1 a 3 a la coordinación y **no hubo respuesta**: seguí con lo escrito. (8) No se abrió PR (la coordinación pidió solo commit y push de la rama).
- [ ] **T216** · 🎨 Arte de la Disruptora (Codex).
  **Entrega provisional (2026-10-08; compuerta pendiente):** se generaron la hoja de tres conceptos, atlas y variantes de niveles, vista independiente, anillo de pulso, marca de supresión y comparaciones a 112/34 px; fuentes y empaquetador quedan en `art/m51-disruptora/`. Se corrieron `godot --headless --import` (exit 0) y GUT completo (**1033/1033**, 9311 asserts, sin `SCRIPT ERROR` ni `Parse Error`; aparece el `ERROR` esperado de `no_existe`). No se probó en una partida ni en la Wiki porque T217 todavía no creó la torre; la aprobación de Lucas sigue pendiente y por eso T216 continúa sin marcar como terminada.
- [ ] **T217** · Disruptora: código.
- [ ] **T218** · 🎨 Señales de los habitantes (Codex).
  **Resultado provisional (2026-10-08):** seis SVG de 64 × 64 (`roca_marcada`, `sendero`, `herramienta`, `poste_cintas`, `simbolo_ruina`, `campamento_vacio`) con alfa, fuente original y comentario en castellano. El mismo símbolo A está tallado en la roca marcada y en la piedra de ruina. `MapDrawings` los registra como objetos precargados y `LevelDecor` los pinta con el mecanismo actual de leyenda; ninguna regla de juego cambió. Hojas a 220 y 34 px sobre pradera, bosque y ruinas, y captura de partida con `tools/ejemplos/tema_ruinas.json` más leyenda de prueba. **La aprobación de Lucas sigue pendiente:** por eso el arte y esta tarea permanecen provisionales/en `[ ]`. Se probó `test_map_drawings.gd` (11/11, 157 asserts) y la suite completa (1018/1018, 9310 asserts), sin `SCRIPT ERROR` ni `Parse Error`; el primer barrido detectó que un test aún esperaba 16 dibujos y se actualizó a 22. No se probó exportación de Windows ni revisión artística de Lucas.
- [ ] **T219** · 🎨 Removibles y ruinas (Codex).
  **Resultado provisional (2026-10-08):** once SVG: árbol, roca y escombro intactos/en trabajo; marca de pieza de 32 × 32; y cuatro suelos despejados. Fuentes, prompts normalizados, manifest y hojas de contacto a 220 y 34 px en `art/t219-removibles/`. El símbolo A del escombro coincide con la señal T218 y la marca ámbar identifica los removibles. La aprobación de Lucas queda pendiente; no frena T206/T207. **Qué se probó:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, sin `SCRIPT ERROR` ni `Parse Error`. **Qué no:** no hay nodos de obstáculos T206/T207 donde integrar los dibujos ni se pudo capturar una demolición en partida; no se probó exportación de Windows ni se recibió la revisión artística de Lucas.
- [ ] **T220** · 🎨 Mina y bosque explotable (Codex).
  **Resultado provisional (2026-10-08):** ocho SVG: tres estados de mina, tres de bosque explotable y dos segmentos 8 × 8 de reserva; fuentes, prompts, manifest y hojas 220/34 px sobre tres suelos en `art/t220-extraccion/`. El bosque con cinta ámbar es un grupo, distinto del árbol removible; la mina activa muestra vagoneta y mineral, sin silueta de torre. Aprobación de Lucas pendiente; el arte no bloquea T210. **Qué se probó:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, sin `SCRIPT ERROR` ni `Parse Error`. Godot sí informó al cerrar que quedó un recurso en uso, además de errores esperados por un test. **Qué no:** como T210 aún no integra extracción, no hay captura de esos estados dentro de una partida; no se probó exportación Windows ni revisión artística de Lucas.
- [ ] **T221** · 🎨 Íconos: recurso, piezas y demoledora (Codex).
- [x] **T222** · Niveles 1 a 5: señales (apto Qwen).
  - **Resultado (2026-10-08):** los niveles 1 a 5 ganaron `"tema": "pradera"` y una `"leyenda"` (todas las letras **sin** `construible`). Solo se cambiaron casillas que eran `X`: nivel 1 → 1 señal `m` (estatua) + 2 flores + 1 agua; nivel 2 → 1 señal `s` (columna) + 2 agua; nivel 3 → 1 señal `h` (estatua) + 2 flores + 1 agua; nivel 4 → 1 señal `p` (tronco) + 1 agua (el pozo) + 1 flores; nivel 5 → 3 señales `m` (estatua) + 1 flores. **Dibujos provisionales** (`estatua`, `columna`, `tronco`) porque T218 todavía no está hecha; cuando llegue se cambia el nombre del dibujo en la leyenda. RF-267 lleva la nota de Q-36 (sin RF nuevo).
  - **`check_level` antes y después:** idéntico en los 5 niveles (largos 52 · 44 · 32/32 · 72 · 26/26/14), sin avisos ni errores. Para poder verlo hubo que arreglar `tools/check_level.gd`, que parseaba el mapa **sin** la leyenda (una línea: ahora pasa `level.legend`); antes de ese arreglo un nivel con leyenda se mostraba sin recorridos.
  - **Tests:** 1018/1018 en verde y 0 `SCRIPT ERROR`. Test nuevo `tests/test_levels_signals.gd` (casillas bloqueadas, de camino y largos de recorrido de los niveles 1 a 5, con los números de antes, y que ninguna letra sea construible). Se ajustaron 3 tests viejos que suponían niveles 1 a 5 sin leyenda (`test_map_legend`, `test_map_size`, `test_map_drawings`: ahora parsean con la leyenda).
  - **Qué no se hizo / no se probó:** (1) **no hay capturas** `art/campaign-v1/bloque1/level_0N.png`: la máquina corre Godot sin pantalla y no se pudo sacar una captura renderizada; hay que mirar los 5 mapas en el juego. (2) **T204 todavía no existe**, así que no hay línea de base de `mix levels=1-5 seeds=3`; se comparó `mix level=N` antes y después a mano: los niveles 1, 2, 4 y 5 dieron igual, y el 3 dio VICTORIA con 16 vidas en tres corridas con los datos nuevos y 16 con los viejos, salvo una corrida con 18 (el bot no es estable corrida a corrida en el nivel 3; no se investigó la causa y el mapa jugable es idéntico). (3) Falta ver si el lugar elegido para cada señal se lee natural a la vista. (4) Textos/subtítulos de lugar del plan 08 no son parte de esta tarea.
  **Resultado provisional (2026-10-08):** tres SVG transparentes de 64 × 64 (`stat_resources`, `coleccion_disruptor`, `demoledora`), con fuentes, prompts, manifest y hojas de contacto a 220 y 34 px en `art/t221-iconos/`. El recurso genérico usa lingotes de hierro y bronce; la pieza de colección conserva el disco plateado y lleva bobina con anillos; la demoledora se representa como ariete compacto con ruedas. Aprobación de Lucas pendiente; no bloquea T209/T211. **Qué se probó:** `godot --headless --import`; suite GUT **1034/1034**, 9365 asserts, sin `SCRIPT ERROR` ni `Parse Error`. **Qué no:** el HUD/panel aún no consume los iconos (T209/T211); no se pudo capturar un HUD real, ni se probó exportación de Windows o la revisión artística de Lucas.
- [x] **T223** · Niveles 6 y 7: bosque, removibles y primer drop de recursos.
  - **Resultado (2026-10-08):** `level_06.json` (Nido) y `level_07.json` (Cruce) pasan a `"tema": "bosque"`. **Nivel 6:** 3 removibles (2 árboles en (13,4) y (7,6), 1 roca en (12,6); coordenadas columna, fila), con `probabilidad` 0 (sin recursos, Q-18); un poste con cintas y un helecho reemplazan dos `X`. **Nivel 7:** `"demoledora": true` y 6 removibles (3 árboles, 3 rocas) con 1 recurso al 50 %, todos sobre casillas que ya eran `X`; una roca marcada (símbolo A) y un helecho reemplazan dos `X`. Ningún camino cambia (largos 56/47 y 30/29) y no se tocaron las oleadas. El Francotirador ya cuesta 150 o 120 + 1 recurso por T209 (dato global), así que el 7 no necesitó nada más. Los removibles quedan en el corredor entre las rectas (la zona de más cobertura), lejos de las esquinas del camino (casillas de impacto del Embestidor, RF-379).
  - **Bot, `mix`, semillas 1 a 5** (vidas / oleada / oro sobrante; antes de T223 era 10 · 15/15 · 275 y 16 · 20/20 · 346–358):

    | Mapa | Semillas 1 a 5 |
    |---|---|
    | 6 | ✔ 9 · 15/15 · 267 (las 5 iguales) |
    | 7 | ✔ 16 · 20/20 (las 5 iguales) |

    Primer intento descartado: con una roca extra sobre una casilla **libre** del corredor del 7 (6,9), el bot ganaba con 3 vidas; se movió a una `X` y volvió a 16. En el 6 una primera ubicación tapaba una casilla de impacto del Embestidor (el test nuevo lo detectó) y se corrió.
  - **Cambios fuera de la ficha (necesarios):** `Wiki._collection_entries` usaba el autoload `SaveManager` como identificador, y eso **no compila** en `check_level.gd` ni en `balance_sim.gd` (`-s`); ahora lo busca por nombre en el árbol. Sin esto las dos herramientas daban `Compile Error` y `check_level` fallaba en cualquier nivel sin recursos (nació en T211). Tests: **1159/1159** en verde, 0 `SCRIPT ERROR`/`Parse Error` (los dos `ERROR` de línea de base aparte); `test_levels_6_7.gd` (nuevo, 5 tests) y se ajustaron `test_map_legend.gd` y `test_obstacles_format.gd`, que exigían los niveles 6 y 7 sin tema ni removibles.
  - **Qué no se probó:** (1) **No se midieron `demoler` ni `demoledora`**: T214 no existe y el bot no sabe demoler, así que el `mix` de arriba juega con los removibles intactos (equivale a `sin_recursos`, y sí gana 5 de 5 en ambos). Por eso **no se comprobó que demoler ayude ni que no sea una ventaja excesiva**, y no se ajustó ningún precio en la leyenda; queda para T214 o el G4. (2) El «Nivel 7 gana sin comprar el Francotirador con recurso» tampoco se midió a propósito: `mix` no usa recursos. (3) **Sin capturas** de los mapas: la máquina corre Godot sin pantalla. (4) La elección de casillas se hizo con un puntaje de cobertura propio (casillas de camino a ≤ 2,5 casillas): en el corredor todas puntúan casi igual, así que despejar suma **capacidad** más que una casilla claramente mejor; conviene que Lucas lo mire jugando. (5) Sin PR (la coordinación pidió commit y push de la rama).
- [ ] **T224** · Niveles 8 y 9: ruinas, piezas y debut del Mortero.
- [ ] **T225** · Nivel 10: la mina vieja.
- [ ] **T226** · 🚦 G4 · Lucas juega del 6 al 10.
- [ ] **T227** · Spec del lore en el juego, del bloque 3 y del final (M52).
- [ ] **T228** · Textos por nivel y Lore en la Wiki.
- [ ] **T229 · T230 · T231 · T232** · Niveles 11, 12, 13 y 14.
- [ ] **T233** · 🎨 Central, abastecimiento e imagen del final (Codex).
- [ ] **T243** · 📜 🚦 Spec del jefe supremo del nivel 15.
- [ ] **T244** · 🎨 Arte del jefe supremo (Codex).
- [ ] **T234** · Nivel 15 y epílogo.
- [ ] **T235** · Asedio con 15 mapas y pulido de modos.
- [ ] **T236** · Regresión, guardados, rendimiento y auditoría.
- [ ] **T237** · Marca y exportaciones.
- [ ] **T238** · 🚦 G5 · Lucas juega del 1 al 15.
- [ ] **T239** · Publicación.
- [ ] **T240** · 🚦 G6 · Guion de la intro.
- [ ] **T241** · 🎨 Láminas de la intro (Codex).
- [ ] **T242** · Intro: integración.
