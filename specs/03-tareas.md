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
  **Resultado:** `MapThemes` (los siete temas) y `MapDrawings` (el catálogo de 16 dibujos y si cada uno es suelo u objeto) dan las listas válidas. `LevelFile` lee y valida `tema` y `leyenda` con un mensaje claro por error (letra prohibida, de más de un carácter, dibujo desconocido con el catálogo, clave mal escrita, más de 10 letras); `MapGrid.parse(filas, leyenda)` trata cada letra como pasto (construible) o bloqueada y **nunca como camino**: un test comprueba que recorridos, entradas, salida y casillas sin usar son **idénticos** con y sin leyenda. Una letra usada sin declarar dice que existe la leyenda; una declarada y sin usar es un aviso. `LevelData` y `Level` guardan el tema y los dibujos por casilla. `LevelDraft` los conserva al abrir y guardar (y guardar dos veces da el mismo texto). Los 7 niveles oficiales siguen sin tema ni leyenda. Todavía no se **ve** nada distinto: los dibujos son T123 a T125. 21 tests nuevos (603 en total).

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
  **Resultado:** `MapDrawings` ([código](../scripts/logic/map_drawings.gd)): el catálogo de 16 dibujos, 12 **objetos** (roca, árbol, arbusto, flores, cactus, pino, columna, tronco, helecho, junco, hongo, estatua) y 4 **suelos** (agua, hielo, lava, barro). `LevelDecor` pinta un objeto sobre el suelo del tema y un suelo cubriendo la casilla, con su detalle (reflejos del agua, grietas del hielo, venas de la lava, manchas de barro) y **un borde donde la mancha termina** (no entre dos casillas iguales). El editor dibuja lo mismo (`MapView`). Las capturas de los siete mapas de ejemplo muestran un lago, un oasis, una laguna helada, un río de lava, flores, cactus, pinos y columnas sobre el paisaje de cada tema. 10 tests nuevos (625 en total).

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

- [ ] **T141 · Cierre de M19**
  Una estrategia del bot que compra Morteros, balance de partida, documentación, CHANGELOG y exportaciones.
  **Refs:** RF-296, D-044.
  **Hecho cuando:** pasan todos los tests, el bot muestra si el Mortero vale la pena contra enemigos duros (por ejemplo, el mapa de auras), los números de RF-296 se ajustan si hace falta y se comprueban las exportaciones.
