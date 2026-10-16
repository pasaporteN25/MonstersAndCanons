# T268a · Verificación del guardado del primer tester

> **Estado: VERIFICACIÓN HECHA CON GUARDADOS ARMADOS A MANO; FALTA PROBAR EL ARCHIVO REAL.** Escrito el 2026-10-16 por Claude (Sonnet 5.5), tarea **T268a** (primera mitad de **T268**, refs **B-39**, **RF-115**, **RF-381**). **No se tocó código ni datos del juego.** Se agregaron un test (`tests/test_tester_save_eras.gd`) y una herramienta de consulta (`tools/verify_save.gd`); ninguno cambia el comportamiento del juego.

## 0. Resumen (para quien lea solo esto)

1. **No tenemos el archivo del tester**, así que no se puede afirmar que *su* progreso se conserva. Lo que sí se comprobó: la versión actual carga **sin errores** los formatos de **todas las builds que pudo haber tenido** (desde la primera, del 28/09, hasta la del 11/10), conserva **todos** los niveles ganados, desbloqueos, vidas, puntajes, opciones, récords y colecciones, y abre el nivel que sigue al último ganado.
2. **El formato nunca cambió de versión:** siempre fue `"version": 1`. Lo único que pasó es que se **agregaron claves** (la lectura es tolerante: lo que falta toma su valor por omisión). No hay migración que pueda fallar.
3. **La carpeta de datos no cambió:** siempre fue `JuegoA`. El 09/10 (T237) se renombró el juego a *Monsters & Canons* y se fijó `custom_user_dir_name="JuegoA"` justamente para no mover el guardado.
4. **Dos riesgos que no son del formato** (ver §5): **si el tester juega en Android**, la build nueva tiene otro identificador de paquete y **no hereda nada**; y **la primera vez que abra la build nueva, el juego reescribe su `save.json`** (muestra la intro y marca `intro_seen`). Por eso el respaldo previo es obligatorio.
5. **Suite de GUT completa en verde:** 117 scripts, 1635 tests, 19704 asserts, 0 `SCRIPT ERROR`.

## 1. Qué claves tiene el guardado y cuándo se agregó cada una

Archivo: `user://save.json` (`SAVE_VERSION = 1`). Fuente: `git log` de `scripts/autoload/save_manager.gd` (9 commits) y `git log -S` por cada clave.

| Cuándo | Commit / tarea | Qué se agregó | Si el archivo no la tiene |
|---|---|---|---|
| 2026-09-28 07:01 | `c2a33cf` · T40-T42 | `version`, `levels` (`unlocked`, `completed`, `best_lives`) y `settings` (`music_volume`, `sfx_volume`, `fullscreen`) | — (es la base) |
| 2026-09-28 18:21 | `51c11ee` · T65 | opción `damage_numbers` dentro de `settings` | toma `true` |
| 2026-09-28 18:52 | `001d669` · T68 | `seen_enemies` (enemigos ya presentados) | lista vacía: se vuelven a mostrar las tarjetas |
| 2026-09-29 03:09 | `25dd8cf` · T89 | `scores` (top 5 por nivel) e `initials` | sin récords; iniciales por omisión |
| 2026-09-29 03:13 | `d212f45` · T90 | `hall_total` y `best_score` dentro de cada nivel | `0` (ver límite en §5) |
| 2026-10-03 | `7497fe3`/`f05f43a` · T183 (revertido en `714c988` el mismo día y vuelto a integrar por el PR #3, 2026-10-07) | `collections` (fuentes por colección; entonces solo `technology`) | colecciones vacías |
| 2026-10-08 | `4c6698a` · T211 | segunda colección, `disruptor` (en `data/progression.json`, no en el código de guardado) | vacía |
| 2026-10-11 | `26b8e1d` · T242 | `intro_seen` | `false`: se muestra la intro |

Las claves que el pedido nombra y **no son claves del guardado**:

- **`estrellas`:** no se guardan. Salen de `best_lives` (RF-93), así que cualquier archivo con `best_lives` ya las tiene.
- **`avances`:** son la colección `technology` (*Avances tecnológicos*, `collections.technology`).
- **`piezas`:** son las fuentes de cada colección (`collections.<id>`); las piezas recogidas en una partida sin terminar **no se guardan** (RF-427: solo se confirman al completar la oleada).
- **`modos`:** los modos propios y los mapas de la comunidad guardan su progreso **dentro de `levels`**, con otro `id` (por ejemplo `comunidad_miMapa`), y sus archivos viven en `user://modos/` y `user://maps/`. Se probó un caso con ids de ese tipo (fila X2).

Otras cosas que cambiaron en el tiempo y pueden pesar en un archivo viejo: los niveles pasaron de 1 a 15 (ids siempre `level_01` … `level_15`, sin renombrar), y el mapa de fuentes de `technology` (`level_01` a `level_05`) no cambió desde T183.

## 2. Cómo se probó

1. **Guardados de prueba fuera del repo** (script de Python en el directorio temporal de la sesión, no versionado): 10 archivos por época (E1 a E8 más dos casos extra) y 10 dañados. Cada uno tiene exactamente las claves que escribía `save()` en ese commit, con el progreso que era posible en esa fecha (E1 solo el nivel 1; E5, 6 niveles; E7, 9 niveles; E8, 10 niveles).
2. **Un runner de Godot headless** (`godot --headless --path . -s <runner>`) cargó cada archivo con el `SaveManager` actual por ruta absoluta (nunca el `user://` real de la máquina) y comparó, clave por clave, lo que dice el JSON contra lo que devuelve la API pública. También guardó y recargó **sobre una copia** y comprobó que el archivo original no cambia de hash al cargar y consultar.
3. **Un test permanente** (`tests/test_tester_save_eras.gd`, 7 tests, 750 asserts) con las mismas épocas inline, escritas en `user://test_tester_eras.json` según `.claude/rules/tests.md`. Complementa a `tests/test_old_saves.gd` (T236), que ya cubría T40, antes de M50, colecciones completas y modo de pruebas.

## 3. Tabla de casos

Leyenda de la columna «Resultado»: ✅ = carga sin errores del motor, nada perdido (comparado clave por clave), archivo intacto al cargar y consultar, ida y vuelta (guardar y recargar) idéntica.

| # | Caso (build que lo escribió) | Ganados → abiertos al cargar | Resultado |
|---|---|---|---|
| E1 | T40 (28/09): solo niveles y 3 opciones | 1 → 1, 2 | ✅ |
| E2 | T65 (28/09): + `damage_numbers` | 1-3 → 1-4 | ✅ |
| E3 | T68 (28/09): + `seen_enemies` | 1-4 → 1-5 | ✅ |
| E4 | T89 (29/09): + `scores`, `initials` | 1-5 → 1-6 | ✅ |
| E5 | T90 (29/09): + `best_score`, `hall_total`, Salón de la fama | 1-6 → 1-7 | ✅ |
| E6 | T183 (03/10): + `collections.technology` (3 de 5) | 1-8 → 1-9 | ✅ |
| E7 | T211 (08/10): + `disruptor` (1 de 3), technology completa | 1-9 → 1-10 | ✅ |
| E8 | T242 (11/10): + `intro_seen`, ambas colecciones completas | 1-10 → 1-11 | ✅ |
| X1 | Campaña entera ganada (1-15) | 1-15 → 1-15 | ✅ |
| X2 | Progreso de modos/comunidad mezclado con la campaña (`comunidad_miMapa`, `modo_demo__m1`) | 1-2 → 1-3 (los ids ajenos se conservan en el archivo) | ✅ |
| D1 | Archivo vacío | 0 → 1 | empieza de cero, sin errores; archivo intacto |
| D2 | Truncado a la mitad (corte de escritura) | 0 → 1 | ídem |
| D3 | Basura binaria | 0 → 1 | ídem |
| D4 | JSON válido con BOM UTF-8 al inicio (lo agrega el Bloc de notas viejo) | 1-10 → 1-11 | ✅ se lee entero |
| D5 | `"version": 2` | 0 → 1 | empieza de cero, ídem |
| D6 | Sin clave `version` | 0 → 1 | ídem |
| D7 | `"levels": null` con el resto bien | 0 → 1 | niveles vacíos; el resto (Salón, colecciones, intro) **sí** se conserva |
| D8 | Raíz que es una lista (`[1,2,3]`) | 0 → 1 | empieza de cero, ídem |
| D9 | JSON válido seguido de bytes NUL | 1-10 → 1-11 | ✅ se lee (comportamiento del parser de Godot 4.7.2; no se fijó en el test) |
| D10 | Dos documentos pegados | 0 → 1 | empieza de cero, ídem |

Todos los dañados «empiezan de cero» con un `push_warning` y **no cierran el juego**; el archivo dañado **no se modifica al cargar**. El aviso de `push_warning` sale cuando el archivo no es un objeto o no es versión 1; en D7 (`levels: null`) no sale aviso aunque se pierdan los niveles.

Casos que ya cubría `tests/test_old_saves.gd` y no se repitieron: modo de pruebas con guardado aparte (`save_pruebas.json`), campos con tipo equivocado uno por uno, colecciones con una fuente que ya no cuenta.

## 4. Lo que quedó comprobado

- **Niveles ganados, vidas, puntajes y desbloqueos** se conservan exactamente (comparados nivel por nivel).
- **Estrellas:** se recalculan desde `best_lives`; el total coincide con lo esperado (por ejemplo, E8: 23 estrellas).
- **RF-381:** en todas las épocas el nivel siguiente al último ganado queda abierto aunque el archivo no tenga su entrada `unlocked`, y **no** se abre uno más (no se saltea un nivel sin victoria).
- **Cargar y consultar no reescribe el archivo.** Solo escriben las acciones del jugador (ganar, Opciones, abrir la intro).
- **Guardar después de cargar no pierde nada** y **no cambia `version`**.
- **Primer arranque con la build nueva (viniendo de una anterior a T242):** `intro_seen` no está, se muestra la intro y se guarda enseguida; después de ese guardado todo lo anterior sigue igual (test `test_first_launch_intro_rewrite_keeps_the_old_progress`).

## 5. Límites: qué NO se puede garantizar sin el archivo real

1. **No se vio el archivo del tester.** Se probaron formatos plausibles, no el suyo. Un archivo editado a mano, dañado por un corte de luz en pleno guardado, o con campos que ninguna build escribió, puede comportarse distinto (los dañados de §3 muestran que el peor caso es «empieza de cero», nunca un cierre).
2. **No sabemos qué build jugó ni en qué plataforma.** Hubo ejecutables de Windows del 04/10 (B31), del 07/10 (T196: una sola app, modo de pruebas en Opciones) y del 09/10 (T237: `MonstersCanons.exe`), más APK de Android (`build/JuegoA.apk`). Confirmarlo con el tester o con la fecha del archivo.
3. **Android no hereda el progreso.** T237 cambió el paquete de `com.juegoa.towerdefense` a `com.monsterscanons.v1`. Una APK nueva se instala como **otra app**, con datos vacíos; el progreso viejo queda en la app vieja y no hay sincronización (B-39). **No se probó en un celular** (no hay uno acá). Si el tester usa Android, hay que avisarle que empezará de cero o que conserve la app vieja instalada.
4. **No hay ningún «reanudar partida»:** el guardado es solo progreso de campaña. Lo que estaba a mitad de nivel (oleada, torres, oro) **no existe** en el archivo y no se puede recuperar; las piezas recogidas en una partida sin terminar tampoco (RF-427).
5. **Puntajes anteriores a T90 (29/09):** esos niveles no tienen `best_score` (valen 0) y el Salón de la fama arranca en 0 para ellos; el tester tendría que volver a ganarlos para sumar puntos. Las estrellas, las vidas y los desbloqueos no se ven afectados.
6. **Una clave que no conoce la build actual se pierde al primer guardado** (el guardado reescribe solo las claves que conoce). Ninguna build conocida escribió claves extra, pero por eso el respaldo del original es obligatorio.
7. **Un archivo dañado se pisa en el próximo guardado.** Cargarlo no lo toca, pero cuando el jugador gane un nivel o cambie una opción, el progreso vacío reemplaza el archivo roto. Mismo motivo para respaldar *antes* de abrir el juego.
8. **Los mapas y modos propios** (`user://maps/`, `user://modos/`) son archivos aparte: la build nueva los lee, pero su compatibilidad no se probó con archivos reales del tester (sin evidencia de que los use).
9. **Windows, Defender y rutas:** no se probó en Windows (esta máquina es Linux). El motor usa la misma lógica de `user://`, pero la ruta exacta, los permisos y un posible redireccionamiento de `%APPDATA%` (OneDrive, perfiles de empresa) solo se comprueban allá.

## 6. Pasos exactos para que Lucas respalde y pruebe el archivo real (Windows)

**Regla de oro:** el original **nunca** se prueba. Se respalda, se verifica el respaldo y se prueba una copia.

1. **Pedirle al tester el archivo.** Que cierre el juego (cerrarlo con la X, y comprobar en el Administrador de tareas que no quedan `MonstersCanons.exe` ni `JuegoA.exe`). Después que abra el Explorador, pegue en la barra de direcciones `%APPDATA%\Godot\app_userdata\JuegoA` y presione Enter. La carpeta puede tener:
   - `save.json` → **el progreso de la campaña (modo normal)**. Es el que importa.
   - `save_pruebas.json` → el progreso del **modo de pruebas** (RF-181); solo existe si activó el modo de pruebas. **No es el progreso real**; si es el único archivo que hay, el tester jugó en modo de pruebas.
   - `pruebas_stats.json` → informe del bot de pruebas, no hace falta.
   - carpetas `maps` y `modos` (si usó el editor o modos propios).
   Que mande **`save.json`** (y, por si acaso, `save_pruebas.json` y las carpetas `maps`/`modos` si existen), por un canal que no los modifique (zip por mail o drive).
2. **Si el tester tiene otra ruta:** si no existe `%APPDATA%\Godot\app_userdata\JuegoA`, buscar `%APPDATA%\Godot\app_userdata\` y anotar qué carpetas hay: una build anterior al 28/09 con otro nombre sería un hallazgo nuevo. En Windows con OneDrive, `%APPDATA%` suele ser `C:\Users\<usuario>\AppData\Roaming`.
3. **Respaldo intocable (en la PC de Lucas).** Con PowerShell, en una carpeta de respaldo que no sea la de datos del juego:
   ```powershell
   mkdir $HOME\Documents\respaldo-tester
   Copy-Item .\save.json $HOME\Documents\respaldo-tester\save_ORIGINAL_tester.json
   Get-FileHash $HOME\Documents\respaldo-tester\save_ORIGINAL_tester.json -Algorithm SHA256
   ```
   Anotar el hash y el tamaño; marcar el archivo como solo lectura (`Set-ItemProperty $HOME\Documents\respaldo-tester\save_ORIGINAL_tester.json -Name IsReadOnly -Value $true`). Guardar una segunda copia en otro disco.
4. **Aislar tu propio guardado (Lucas juega con el mismo nombre de carpeta).** Con el juego cerrado:
   ```powershell
   Rename-Item "$env:APPDATA\Godot\app_userdata\JuegoA" JuegoA_lucas_NO_BORRAR
   mkdir "$env:APPDATA\Godot\app_userdata\JuegoA"
   Copy-Item $HOME\Documents\respaldo-tester\save_ORIGINAL_tester.json "$env:APPDATA\Godot\app_userdata\JuegoA\save.json"
   ```
   Así la build nueva ve **solo** el archivo del tester, y el propio queda guardado.
5. **Verificación previa sin abrir el juego (opcional, en Linux o con Godot instalado):** sobre una copia,
   `godot --headless --path . -s tools/verify_save.gd -- /ruta/a/copia_save.json`
   imprime niveles ganados y abiertos, estrellas, colecciones y confirma que el archivo no se modificó. Debe coincidir con lo que el tester recuerda haber ganado.
6. **Abrir la build de envío** (el `MonstersCanons.exe` candidato, identificada por su SHA256 en el registro de T268b). Modo normal (no activar el modo de pruebas). Comprobar, anotando cada respuesta:
   - ¿La selección de niveles muestra los niveles ganados con sus estrellas?
   - ¿Está abierto el nivel siguiente al último ganado, y ningún otro?
   - Opciones: volumen, pantalla completa y números de daño como los dejó.
   - Salón de la fama y récords: iniciales y tablas.
   - Colecciones/Avances: piezas ya obtenidas.
   - **La primera vez se verá la intro** (el archivo viejo no tiene `intro_seen`): es lo esperado. A partir de ahí `save.json` queda reescrito.
7. **Cerrar el juego** y comparar `save.json` actual con el original: los `levels` ganados deben seguir (puede haber claves nuevas, p. ej. `intro_seen`). `Get-FileHash` del original debe seguir igual al anotado.
8. **Restaurar lo tuyo:**
   ```powershell
   Remove-Item "$env:APPDATA\Godot\app_userdata\JuegoA" -Recurse
   Rename-Item "$env:APPDATA\Godot\app_userdata\JuegoA_lucas_NO_BORRAR" JuegoA
   ```
   (Solo después de haber copiado a otro lado, si hace falta, el `save.json` ya reescrito para el informe.)
9. **Si algo falla:** no seguir jugando sobre esa copia, guardar el archivo y la salida de `verify_save.gd`, y pasarlos a Claude.
10. **Si la plataforma del tester es Android:** aplicar §5.3; no hay pasos de recuperación.
11. **Decisión de campaña nueva:** Lucas ya aceptó (B-39) pedir una campaña nueva si hace falta, **después** de T266/T267. Aun entonces, el respaldo del paso 3 se conserva y se registra qué build se envía.

## 7. Qué quedó hecho y qué falta de T268

- **Hecho (T268a):** formato real documentado, claves y fechas, 10 épocas y 10 casos dañados probados, un test permanente nuevo, `tools/verify_save.gd`, pasos de respaldo para Windows.
- **Falta (T268b y el reenvío):** el archivo real del tester, qué build y plataforma jugó, la prueba en Windows con la copia (§6), la identificación de la build de envío con su hash, y que **T266 y T267** estén resueltas y validadas. T268 sigue **pendiente** en `specs/03-tareas.md`.
