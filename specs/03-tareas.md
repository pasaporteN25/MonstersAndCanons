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

- [ ] **TA3 · Probar en un celular**
  **Refs:** RF-140 a RF-143.
  **Hecho cuando:** Lucas instala el `.apk`, el juego abre en horizontal, se puede construir tocando, y "atrás" abre el menú de pausa sin cerrar el juego.

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

- [ ] **T83 · Eléctrica (rayo en cadena)**
  `TowerLevelData.chain_extra_targets` y `chain_range_tiles`; el rayo salta al enemigo más cercano no golpeado; efecto de zigzag; dibujos y sonido.
  **Refs:** RF-163, RF-158.
  **Hecho cuando:** los tests comprueban que golpea a 3 enemigos (objetivo + 2 saltos) sin repetir, que no salta más lejos que su distancia y que con un solo enemigo golpea solo a ese.

- [ ] **T84 · Nivel 6 — Nido y balance**
  Mapa, `level_06.tres`, campaña; el bot usa las torres nuevas; aumento de vida por oleada del nivel 6; revisar que los niveles 1–5 no queden regalados con las torres nuevas.
  **Refs:** spec §7.7, §7.4.
  **Hecho cuando:** el bot que mezcla torres gana el nivel 6 y el que pone torres al azar pierde; los niveles 1–5 siguen perdiéndose con el bot al azar.

- [ ] **T85 · Guía para crear contenido y cierre de M5**
  `CONTENIDO.md` (cómo agregar un enemigo, una torre o un nivel, con todos los campos), tests que revisan **todos** los archivos de `data/` (así, si a algo nuevo le falta un dato, un test avisa), prueba de rendimiento y exportaciones.
  **Refs:** RF-164, RF-157, D-025.
  **Hecho cuando:** la guía explica cada campo, los tests de contenido recorren las carpetas solos, el rendimiento sigue sobre 60 FPS y las exportaciones terminan sin errores.

### Otras ideas de pulido *(sin fecha)*

- Decidir ambientación y arte definitivo (ver "Preguntas abiertas" de la spec y B-02). *Los dibujos provisionales ya están (T70–T73).*
- Balance fino de todos los niveles.
