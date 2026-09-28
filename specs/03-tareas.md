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

- [ ] **T43 · Nivel 2 — Desfiladero**
  Mapa, caminos, `level_02.tres` con 15 oleadas.
  **Hecho cuando:** pasa `test_level_paths.gd` y es ganable.

- [ ] **T44 · Soporte de varias entradas**
  Revisar que `WaveSpawner` use `entrance_index` correctamente.
  **Refs:** plan §4.1 (`SpawnGroup.entrance_index`).
  **Hecho cuando:** en un mapa de prueba con 2 entradas, cada grupo sale por la entrada indicada.

- [ ] **T45 · Nivel 3 — Encrucijada**
  Mapa con 2 entradas, `level_03.tres` con 20 oleadas.
  **Hecho cuando:** pasa `test_level_paths.gd` y es ganable.

- [ ] **T46 · Menú de pausa**
  **Refs:** RF-114.
  **Hecho cuando:** `Esc` (sin nada seleccionado ni construcción activa) abre el menú y todas sus opciones funcionan.

- [ ] **T47 · Opciones**
  Buses de audio `Master`/`Music`/`SFX`, pantalla completa.
  **Refs:** RF-113.
  **Hecho cuando:** los cambios se aplican al momento y se mantienen al reiniciar el juego.

- [ ] **T48 · Sonido y música**
  Autoload `Audio`. Sonidos con licencia libre (por ejemplo CC0) o generados con herramientas como *jsfxr*.
  **Refs:** RF-116.
  **Hecho cuando:** suenan todos los eventos de RF-116 y la música no se corta al cambiar de pantalla.

- [ ] **T49 · Exportar el juego**
  Exportar un `.exe` para Windows.
  **Hecho cuando:** el `.exe` funciona en otra carpeta, sin tener Godot abierto, y guarda el progreso.

> 🎉 **Fin de M3: el juego mediano está terminado.**

---

## M4 — Pulido *(opcional; las tareas se detallan al llegar aquí)*

- Decidir ambientación y arte (ver "Preguntas abiertas" de la spec).
- Reemplazar formas por sprites.
- Animaciones de disparo y muerte, partículas.
- Números de daño flotantes, sacudida de pantalla.
- Niveles 4 y 5.
- Balance fino de todos los niveles.
