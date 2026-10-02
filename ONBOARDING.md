# Onboarding — cómo preparar una computadora para trabajar en JuegoA

> **Para quién es:** para ti en una computadora nueva, o para cualquier persona que se sume al proyecto.
> **Qué cubre:** todo lo que hay que instalar y configurar **fuera del código** (programas, rutas, ajustes del editor) para poder abrir, probar, balancear y exportar el juego. Cada paso dice **cómo comprobar que quedó bien**.
>
> Para entender **qué es** el juego y **cómo está hecho**, leer después el [README](README.md) y la carpeta [`specs/`](specs/).

---

## Resumen (checklist)

| # | Paso | Obligatorio | Se comprueba con |
|---|---|---|---|
| 1 | [Instalar Git y conectarlo a GitHub](#1-git-y-github) | Sí | `ssh -T git@github.com` |
| 2 | [Instalar Godot 4.7.2 y ponerlo en el `PATH`](#2-godot) | Sí | `godot --version` |
| 3 | [Clonar el repositorio y abrir el proyecto](#3-clonar-y-abrir-el-proyecto) | Sí | F5 abre el menú principal |
| 4 | [Comprobar los tests (GUT)](#4-tests-gut) | Sí | 145 tests en verde |
| 5 | [Plantillas de exportación](#5-plantillas-de-exportación) | Para exportar | aparece `export_templates/4.7.2.stable` |
| 6 | [Exportar para Windows](#6-exportar-para-windows-exe) | Para exportar | se crea `build/JuegoA.exe` |
| 7 | [Preparar Android](#7-android-apk) | Solo para el celular | se crea `build/JuegoA.apk` |

Las versiones exactas con las que se hizo el proyecto están en [Versiones de referencia](#versiones-de-referencia).

---

## 1. Git y GitHub

1. Instalar **Git para Windows**: <https://git-scm.com/download/win>. Trae también **Git Bash**, una terminal donde funcionan los comandos de esta guía.
2. Configurar tu nombre y correo (aparecen en cada commit):
   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "tu@correo.com"
   ```
3. El repositorio es **privado** y se accede por **SSH**. Si esta computadora no tiene una clave SSH registrada en GitHub, crear una y agregarla en *GitHub → Settings → SSH and GPG keys* (guía oficial: <https://docs.github.com/es/authentication/connecting-to-github-with-ssh>).

**✅ Comprobar:**
```bash
ssh -T git@github.com
```
Tiene que responder `Hi <tu usuario>! You've successfully authenticated…`.

---

## 2. Godot

1. Descargar **Godot 4.7.2, versión estándar** (⚠️ **no** la ".NET/Mono", que es para C#): <https://godotengine.org/download/archive/>.
2. Crear la carpeta `C:\Tools\Godot` y poner ahí los dos ejecutables del zip:
   - `Godot_v4.7.2-stable_win64.exe` → el **editor** (con ventanas).
   - `Godot_v4.7.2-stable_win64_console.exe` → el mismo programa, pero **muestra mensajes en la terminal**. Es el que se usa para tests y exportaciones.
3. Crear, en esa misma carpeta, un archivo **`godot.cmd`** con esta única línea:
   ```bat
   @"%~dp0Godot_v4.7.2-stable_win64_console.exe" %*
   ```
   Así el comando `godot` funciona desde cualquier terminal.

   > ⚠️ **Trampa conocida:** **no** renombrar `…_console.exe` a `godot.exe`. Ese archivo es un "lanzador" que busca al Godot real usando su propio nombre; si se le cambia, responde *"Invalid wrapper executable name"* y no arranca. Por eso se usa el `godot.cmd`.

4. Agregar `C:\Tools\Godot` al `PATH` del usuario (PowerShell):
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";C:\Tools\Godot", "User")
   ```
5. **Cerrar y volver a abrir la terminal**: el `PATH` nuevo solo se ve en terminales nuevas.
6. (Opcional) Crear un acceso directo en el escritorio a `C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`.

**✅ Comprobar** (en una terminal nueva):
```bash
godot --version
```
Tiene que mostrar `4.7.2.stable.official…`.

---

## 3. Clonar y abrir el proyecto

1. Clonar:
   ```bash
   git clone git@github.com:pasaporteN25/TDv1.git JuegoA
   ```
2. Abrir el **editor** de Godot → en el Gestor de proyectos, **Importar** → elegir `JuegoA/project.godot` → **Importar y editar**.
   La primera vez tarda unos segundos: Godot "importa" las imágenes y sonidos y crea la carpeta `.godot/`. Esa carpeta es un caché local y **no** se sube a git.

**✅ Comprobar:** pulsar **F5**. Tiene que abrirse el **menú principal** (título "JuegoA" con el mapa de fondo).

> 💡 **F5 vs F6:** F5 abre el juego desde el menú, igual que lo ve un jugador. **F6** ejecuta solo la escena abierta en el editor; sirve para probar una partida directo (`scenes/game/game.tscn`), pero así **no se guarda el progreso** (spec RF-117).

---

## 4. Tests (GUT)

El proyecto usa **GUT** (Godot Unit Test). Ya viene incluido en el repositorio (`addons/gut/`) y activado en `project.godot`, así que **no hay que instalar nada**.

**✅ Comprobar** desde la carpeta del proyecto:
```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```
Al final tiene que decir `---- All tests passed! ----`. Hay 145 tests al momento de escribir esta guía.

También se pueden correr desde el editor: panel **GUT** (abajo) → **Run All**. Si el panel no aparece: *Proyecto → Configuración del proyecto → Plugins* → activar **Gut**.

> ℹ️ Los tests **no tocan tu progreso real**: usan un archivo aparte (`user://test_save.json`) que borran al terminar.

---

## 5. Plantillas de exportación

Para crear el `.exe` o el `.apk`, Godot necesita sus **plantillas de exportación**: versiones del motor ya compiladas para cada sistema. Se descargan **una sola vez** por computadora (~1 GB).

En el editor: **Editor → Administrar plantillas de exportación** → **Descargar e instalar**.

**✅ Comprobar:** tiene que existir la carpeta
`%APPDATA%\Godot\export_templates\4.7.2.stable` con archivos como `windows_release_x86_64.exe` y `android_debug.apk`.

---

## 6. Exportar para Windows (`.exe`)

La configuración ya está en el repositorio (`export_presets.cfg`, preset **"Windows Desktop"**). Deja fuera del juego los tests, las herramientas, las specs y GUT.

```bash
godot --headless --path . --export-release "Windows Desktop" build/JuegoA.exe
```

**✅ Comprobar:** se crea `build/JuegoA.exe` (~110 MB, casi todo es el motor). Copiarlo a otra carpeta y abrirlo: tiene que funcionar sin Godot.

> ℹ️ La carpeta `build/` no se sube a git.

### 6.1 El ejecutable de pruebas

Para probar todos los niveles y el contenido sin ganar cada nivel (spec §10.2):

```bash
godot --headless --path . --export-release "Windows (pruebas)" build/JuegoA_pruebas.exe
```

**✅ Comprobar:** al abrirlo, abajo al centro dice "MODO PRUEBAS · F1: panel", todos los niveles se pueden elegir, y en la partida `F1` abre el panel de pruebas. En el log de esa ejecución aparece "Modo de pruebas activado". Usa su propio guardado (`save_pruebas.json`), así que no toca el progreso ni los récords del `.exe` normal.

El botón **"Editor de mapas"** (spec §10.3) está en **todas las versiones de escritorio** (desde M14, D-038; el celular no lo ofrece): se dibujan niveles con el mouse, se prueban al instante y se guardan en `%APPDATA%\Godot\app_userdata\JuegoA\maps`. Comprobá que también está en el `.exe` normal y que abrirlo no cambia el progreso. Cómo se usa y cómo volver oficial un mapa: [`CONTENIDO.md`](CONTENIDO.md).

### 6.1.0 La Wiki (en todas las versiones)

Menú principal → **Wiki**. Comprobá que hay tres solapas (Enemigos, Torres, Guía), que cada enemigo y cada torre tienen su dibujo y sus números, y que se puede recorrer con el mouse y con el teclado (▲/▼ entre entradas, ◄/► entre solapas, Esc para volver). Los enemigos que todavía no viste en una partida salen como "???" (con el contador "Enemigos 4/9"): en el `.exe` normal empiezan cerrados y se abren al cruzártelos; en el de pruebas se ve todo. Un enemigo o una torre nuevos deberían aparecer sin tocar nada más; los artículos de la Guía están en `data/wiki/*.json` ([`CONTENIDO.md`](CONTENIDO.md)).

### 6.1.05 Mapas más grandes (zoom)

Copiá `tools/ejemplos/mapa_grande.json` a la carpeta de mapas de la comunidad (ver más abajo) y jugalo desde **Jugar → Mapas de la comunidad**. Tiene que verse **entero**, centrado entre las dos barras, con las torres y los enemigos algo más chicos que en los otros niveles y la interfaz igual. Construí una torre haciendo clic en una casilla: tiene que aparecer **justo en esa casilla**. Con el ratón y, en el celular, con el dedo. Abrilo también en el editor de mapas (versión de pruebas): se ve entero y se puede pintar sin errores de puntería.

### 6.1.06 Temas y leyenda

Copiá los siete `tools/ejemplos/tema_*.json` a la carpeta de mapas de la comunidad y jugá cada uno. Se tiene que ver: el **paisaje** propio de cada tema, el **camino bien distinto del suelo**, los enemigos claros sobre cualquier suelo, un **lago / oasis / laguna helada / río de lava / barro** que **no se puede construir**, las **flores** (que sí) y la decoración del tema. Los enemigos siguen el **mismo camino** que en el nivel 4 (son ese nivel con parches). Abrilos también en el editor: se ven igual y se guardan sin perder el tema.

### 6.1.07 Guardián y Curandero (versión de pruebas)

Abrí una partida en `JuegoA_pruebas.exe`, `F1` (panel de pruebas) y hacé aparecer un **Guardián**, un **Curandero** y varios enemigos comunes. Tiene que verse: el **anillo** de cada uno en el suelo (marfil dorado el Guardián, verde el Curandero); un **escudo** sobre los enemigos que están dentro del anillo del Guardián y una **cruz verde** sobre los del Curandero; el **número de daño gris** cuando la armadura se come el golpe; y que al **matar al portador** el escudo o la cruz desaparecen en menos de un segundo. Con una Incendiaria, el enemigo que se quema no recupera vida aunque esté dentro del anillo verde.

### 6.1.10 Combos por estado

En el nivel 1 poné un **Hielo** y, un poco más adelante en el camino, un **Cañón**. Qué tiene que pasar (RF-315 a RF-318):

- **Antes del golpe:** un enemigo ralentizado (tinte **celeste** y escarcha en el piso) muestra una **dianita celeste** al lado de su barra de vida, porque hay un Cañón en el mapa. Si vendés el Cañón, la dianita desaparece.
- **El golpe:** cuando el Cañón le pega, el número de daño sale **"25!"**, **celeste y más grande** (en vez del "20" blanco), con un **anillo celeste** y un **"tin"**. El primer combo de la partida dice además **"¡Combo de hielo!"**; los siguientes, no.
- **Con fuego:** con una **Incendiaria** y una **Eléctrica**, el enemigo en llamas muestra una dianita **naranja**, el número sale **naranja** ("17!") y la primera vez dice "¡Combo de fuego!".
- **Los textos:** seleccioná el Hielo: el panel dice "Combo: Cañón y Francotirador +25 % a los que frena" (en el nivel 1 no hay Mortero). Elegí el Cañón en la barra: la frase de abajo termina con "Combo: +25 % a ralentizados.". En la Wiki, la ficha del Hielo tiene un apartado "Combos" y el artículo "Efectos de las torres" los explica.
- **Números apagados** (Opciones): no hay número, pero el anillo, el "tin" y el texto de la primera vez siguen.

Qué mirar con ojo crítico: si el "tin" se vuelve molesto en una oleada cargada, y si el combo **pesa** lo suficiente. Si falta peso, lo decidido es una regla nueva (el combo frena en seco al enemigo un instante, D-047), no subir los porcentajes.

### 6.1.09 El Mortero (2×2)

El Mortero es una torre **reservada** (solo el nivel 10 la tendrá): para probarla, abrí el mapa `tools/ejemplos/mapa_torres_apagadas.json` (copialo a la carpeta de mapas de la comunidad). Elegí el **Mortero** (novena torre, tecla **9**, 300 de oro) y pasá el mouse por el mapa: el cuadrado de **2×2** queda centrado en el mouse y se ve **verde** donde entra y **rojo** si una de las cuatro casillas es camino, roca u otra torre. Construilo: ocupa las cuatro casillas, un clic en cualquiera lo selecciona, dispara una bomba cada 4 segundos con daño de área, y al **venderlo** devuelve el 70 % y libera las cuatro casillas. La barra de abajo debe mostrar las 9 torres sin tapar "Próxima oleada".

### 6.1.08 Chamán y Espejo (versión de pruebas)

En `JuegoA_pruebas.exe`, `F1`, hacé aparecer un **Chamán** cerca de varias torres y esperá unos 8 segundos: tiene que salir un **rayo magenta** hacia la torre más cercana, que se ve **apagada** (oscura, con chispas) y **no dispara** unos 3 segundos; si la seleccionás, el panel dice **"Aturdida (N s)"** con la cuenta atrás. Después, un **Espejo** al lado de una torre pegada al camino: el primer disparo tiene que mostrar **"¡Rebote!"**, el Espejo no pierde vida y la torre queda apagada 2 segundos; una torre lejos (por ejemplo un Francotirador) le pega normal. Con una Incendiaria pegada, el Espejo se quema igual.


### 6.1.11 Probar oleadas finales y mirar un combo (modo de pruebas)

En `JuegoA_pruebas.exe`, **Jugar**: arriba de las tarjetas hay una franja **"Pruebas"**. Poné **Oleada inicial** en 10 (por ejemplo) y dejá el oro en **Automático**, y elegí el **Nivel 1**.

**✅ Comprobar:**
- La partida arranca sin torres, con bastante más oro que el normal (lo que se habría juntado en las oleadas 1 a 9), el HUD dice **"Próxima: oleada 10/10"** y al apretar *Empezar oleada* salen los enemigos de la última. Con **Oro inicial** a mano (sacá la tilde de "Automático") arranca con el número que escribas, también con 0. Un número mayor al total usa la última oleada.
- Ganar o perder esa partida **no** cambia estrellas, récords ni niveles desbloqueados (mirá la pantalla de selección al volver). **Reintentar** vuelve a la oleada 10 con el mismo oro.
- `F1` abre el panel: la fila **Velocidad** tiene **x0,25 · x0,5 · x1 · x2 · x4**. Elegí x0,25 con un Hielo y un Cañón en el camino: el aviso de combo (número celeste con "!") se lee con calma. El cartel de abajo dice "MODO PRUEBAS · F1: panel · x0,25", el botón de arriba dice "x0,25 [F]", y al salir de la partida vuelve a x1.
- **Atajos** (con el panel abierto o cerrado): `F2` mata a todos, `F3` salta la oleada, `F4` prende y apaga las vidas infinitas, `F6` y `F7` bajan y suben la velocidad un paso. Las teclas `1`–`9` siguen construyendo torres.
- Al terminar (o al salir) se escribe `%APPDATA%\Godot\app_userdata\JuegoA\pruebas_stats.json` con la oleada, las vidas, el oro y las torres de cada oleada terminada y el resultado (`won`, `lost` o `left`).

### 6.1.1 Mapas de la comunidad (en todas las versiones)

Los `.json` de `%APPDATA%\Godot\app_userdata\JuegoA\maps` (la misma carpeta donde guarda el editor) aparecen en **Jugar → Mapas de la comunidad**, en el `.exe` normal y en el de pruebas. Para comprobarlo: guardar un mapa desde el editor (en cualquiera de los dos `.exe`) y buscarlo en la solapa. Cada versión tiene su propio guardado, así que el progreso en esos mapas no se comparte entre el `.exe` normal y el de pruebas. Detalles en [`CONTENIDO.md`](CONTENIDO.md).

### 6.2 La versión para GNU/Linux

```bash
godot --headless --path . --export-release "Linux" build/JuegoA.x86_64
tar --mode=755 -czf build/JuegoA_linux.tar.gz -C build JuegoA.x86_64
```

**✅ Comprobar:** se crea `build/JuegoA.x86_64` (~75 MB). Para verificar que es de Linux: `file build/JuegoA.x86_64` dice "ELF 64-bit LSB executable, x86-64". Necesita las plantillas de Linux, que vienen con las de Windows (paso 6, arriba).

**En una computadora Linux:** `tar -xzf JuegoA_linux.tar.gz` y `./JuegoA.x86_64`. Si se copió el archivo suelto desde Windows, hay que darle permiso: `chmod +x JuegoA.x86_64`.

> ⚠️ Desde Windows no se puede abrir, así que probarlo en una computadora Linux real sigue pendiente. Si falla al abrir, lo primero que hay que mirar es la terminal: el ejecutable imprime ahí sus errores.

---

## 7. Android (`.apk`)

Godot exporta **el mismo proyecto** a Android; no hace falta portar nada (decisión D-021, spec §9.4).

### 7.1 Qué hace falta instalar

Lo más simple es instalar **Android Studio** (<https://developer.android.com/studio>), que trae las dos cosas que Godot necesita:

| Qué | Para qué | Dónde queda |
|---|---|---|
| **Android SDK** | Herramientas de Android (empaquetar, instalar en el celular). | `C:\Users\<usuario>\AppData\Local\Android\Sdk` |
| **Java 17 o superior** ("JBR") | Firmar el `.apk`. | `C:\Program Files\Android\Android Studio\jbr` |

> ⚠️ **Trampa conocida:** Windows puede tener un **Java 8** viejo instalado (por ejemplo, el de Oracle en `Program Files (x86)`). Godot 4 **no** funciona con Java 8. Hay que indicarle el de Android Studio.

### 7.2 Configurar el editor de Godot

Estas rutas se guardan en la **configuración del editor**, que es de cada computadora y **no** del proyecto. Por eso no están en git.

**Editor → Configuración del Editor → Exportar → Android:**

| Campo | Valor |
|---|---|
| **Ruta del SDK de Android** (*Android SDK Path*) | `C:\Users\<usuario>\AppData\Local\Android\Sdk` |
| **Ruta del SDK de Java** (*Java SDK Path*) | `C:\Program Files\Android\Android Studio\jbr` |
| **Keystore de depuración** (*Debug Keystore*) | Godot lo crea solo la primera vez. No hace falta tocarlo. |

> ⚠️ **Trampa conocida:** después de escribir una ruta, **pulsar Enter** o hacer clic en otro campo antes de cerrar la ventana. Si no, el valor puede no guardarse.
>
> 🔧 **Si aun así no se guarda** (nos pasó con la ruta de Java): **cerrar el editor de Godot** y editar a mano el archivo `%APPDATA%\Godot\editor_settings-4.7.tres`, en la línea
> `export/android/java_sdk_path = "C:/Program Files/Android/Android Studio/jbr"`.
> ⚠️ Con el editor **abierto** no sirve: el editor guarda su configuración cada tanto y pisa el cambio con el valor que tiene en memoria.

**✅ Comprobar** (con la terminal, estando el editor cerrado o después de configurar):
```bash
grep -n "java_sdk_path\|android_sdk_path" "$APPDATA/Godot/editor_settings-4.7.tres"
```
Las dos líneas tienen que tener una ruta, no `""`.

### 7.3 Exportar

La configuración está en `export_presets.cfg`, preset **"Android"**: paquete `com.juegoa.towerdefense`, solo celulares de 64 bits (arm64), sin Gradle. El proyecto ya tiene activada la compresión de texturas **ETC2/ASTC** (la que usan los celulares) y un ícono propio (`assets/icon.png`, generado con `tools/make_icon.gd`).

```bash
godot --headless --path . --export-debug "Android" build/JuegoA.apk
```

Se usa `--export-debug` porque la versión de **prueba** se firma sola con la clave de depuración. (Publicar en la Play Store requiere una clave propia y `--export-release`; eso no está hecho.)

### 7.4 Instalar en el celular

**Opción A — por cable (la más rápida):**
1. En el celular: *Ajustes → Acerca del teléfono* → tocar 7 veces **Número de compilación** (activa las "Opciones de desarrollador").
2. *Ajustes → Opciones de desarrollador* → activar **Depuración USB**.
3. Conectar el celular por USB y aceptar el aviso que aparece en él.
4. Instalar:
   ```bash
   "$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" install -r build/JuegoA.apk
   ```

**Opción B — copiando el archivo:** pasar `JuegoA.apk` al celular (cable, Drive, WhatsApp…), abrirlo y aceptar **"Permitir instalar apps de origen desconocido"**. Android lo pide porque no viene de la Play Store.

**Cómo se juega en el celular** (spec §9.4): tocar = clic; el botón **"atrás"** = `Esc` (abre el menú de pausa y **no** cierra el juego); el juego queda siempre en horizontal.

---

## Dónde guarda las cosas el juego

| Qué | Dónde |
|---|---|
| Progreso, récords y opciones del jugador | `%APPDATA%\Godot\app_userdata\JuegoA\save.json` |
| Lo mismo, pero del ejecutable de pruebas | `%APPDATA%\Godot\app_userdata\JuegoA\save_pruebas.json` |
| Registros (logs) de cada ejecución, los últimos 30 | `%APPDATA%\Godot\app_userdata\JuegoA\logs` |
| Configuración del editor (rutas de Android, etc.) | `%APPDATA%\Godot\editor_settings-4.7.tres` |
| Plantillas de exportación | `%APPDATA%\Godot\export_templates\4.7.2.stable` |
| Caché del proyecto (se regenera sola) | `JuegoA/.godot/` |

> 💡 **Empezar el progreso de cero:** borrar `save.json`. El `.exe` y el juego abierto desde el editor **comparten** ese archivo.

---

## Herramientas del proyecto

Se ejecutan desde la carpeta del proyecto. Más detalle dentro de cada archivo.

| Comando | Para qué |
|---|---|
| `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` | Correr todos los tests. |
| `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart level=1` | Bot que juega solo, para revisar el balance (spec §7.1). Estrategias: `smart`, `basic`, `naive`. |
| `godot --path . -s tools/perf_test.gd` | Prueba de rendimiento: 200 enemigos y 60 torres. Abre una ventana. |
| `godot --headless --path . -s tools/make_sounds.gd` | Volver a generar los sonidos (D-020). Con `-- shot_fire`, solo ese. |
| `godot --headless --path . -s tools/check_level.gd -- data/levels/level_06.json` | Revisar un nivel sin jugarlo (sin archivo: todos los de la campaña). Cómo hacer un nivel: `CONTENIDO.md`. |
| `godot --headless --path . -s tools/make_icon.gd` | Volver a generar el ícono del juego (`assets/icon.png`). |

> ⚠️ **Trampa conocida (para quien escriba herramientas nuevas):** los scripts que se ejecutan con `-s` se compilan **antes** que los autoloads. No pueden usar `GameFlow`, `SaveManager` ni `Audio` por su nombre, ni declarar variables de tipo `Game`. Hay que declarar la partida como `Node2D` (plan técnico §7).

---

## Problemas conocidos

| Síntoma | Causa | Qué hacer |
|---|---|---|
| `godot` no se reconoce como comando | La terminal se abrió antes de cambiar el `PATH`. | Abrir una terminal nueva. |
| *"Invalid wrapper executable name"* | Se renombró el `…_console.exe`. | Devolverle su nombre original y usar `godot.cmd` (paso 2). |
| Exportar a Android: *"Se requiere una ruta válida para el SDK de Java"* | Falta la ruta de Java en el editor, o no se confirmó con Enter. | Paso 7.2 (y el 🔧 si no se guarda). |
| Exportar a Android: *"La compresión de texturas ETC2/ASTC se requiere…"* | El proyecto no genera texturas para celulares. | Ya está resuelto en `project.godot` (`import_etc2_astc=true`). Si reaparece: *Configuración del proyecto → Renderizado → Texturas → Compresión de VRAM → Importar ETC2 ASTC*. |
| Al cerrar el juego, en la terminal: *"ObjectDB instances were leaked"* | La música sigue "reproduciéndose" en el servidor de audio durante el cierre. | Es inofensivo y el jugador no lo ve. Está anotado como pendiente. |
| Una herramienta (`tools/…`) da *"Identifier not found: GameFlow"* | Ver la trampa de la sección anterior. | Declarar la partida como `Node2D`. |
| Un dibujo nuevo (`assets/sprites/`) se ve borroso, chico o con bordes serruchados | Se importó sin la configuración del proyecto (tamaño ×1, sin mipmaps): pasa si se borró `[importer_defaults]` de `project.godot` o si el `.import` se copió de otro lado. | Seleccionarlo, y en el panel *Importar*: `Svg → Scale = 2`, `Mipmaps → Generate` activado, *Reimportar* (README, "Dibujos"). |
| Un dibujo que se dibuja con código sale como un **cuadrado blanco** | La textura se cargó dentro de `_draw()` en una variable local: Godot la libera antes de mostrarla. | Guardarla en una variable del script o en una constante con `preload()`. |
| El juego se cierra solo, se congela o hace algo raro | En la versión exportada los errores de GDScript **no se muestran**. | Anotar la hora y qué se estaba haciendo. Revisar el log de esa hora en la carpeta `logs` (ver "Dónde guarda las cosas el juego") y, si el programa se cerró de golpe, el *Visor de eventos* de Windows (*Registros de Windows → Aplicación*). |

---

## Versiones de referencia

Con estas versiones se desarrolló y probó el proyecto (septiembre de 2026):

| Programa | Versión |
|---|---|
| Godot | 4.7.2 estable, estándar (renderizador *Compatibility*) |
| GUT | 9.7.1 (incluido en el repositorio) |
| Git | 2.55 |
| Java para Android | OpenJDK 21 (el de Android Studio) |
| Android SDK | build-tools 34–37, plataformas 35–36 |
| Sistema | Windows 10 Pro |

## Arte renderizado de torres (M23)

Las torres conservan el juego 2D y usan PNG con ocho vistas. La fuente y las capturas están en art/redesign-m23; la guía está en specs/05-guia-de-arte.md §7. Para reproducir los derivados:

```powershell
godot --headless --path . -s tools/prepare_tower_sprites.gd
python tools/apply_rendered_art.py
godot --headless --path . --editor --import
```

Los PNG de mecanismos/bases miden 128×128, los atlas 512×256, los proyectiles 64×64. Activar mipmaps, pero no ampliar los PNG como si fueran SVG. El campo turret_atlas permite las vistas; dejarlo vacío conserva la textura giratoria anterior. Las fuentes de art/ no van en exportables. El ejecutable Windows de esta entrega es build/JuegoA_m23.exe. No se volvieron a probar Android ni Linux con M23.

Para comprobarlo, abrir una partida, construir las ocho torres comunes, mejorar dos veces y ver cómo apuntan. El mortero se prueba en un nivel que lo habilite o mediante la escena art/redesign-m23/capture_game.tscn. Revisar frío, fuego, explosión y rayo; comparar con en_juego.png, direcciones_m23.png y conjunto_m23.png. La fila preparada de efectos_en_juego.png fue invocada para comparar efectos, no representa cuatro disparos espontáneos. Nunca usar el guardado habitual al ejecutar las herramientas de captura: aislar APPDATA como en las pruebas de producción.

## Monstruos y menú M24

- Menú: logo `assets/ui/logo.png` (se regenera con `godot --headless --path . -s tools/prepare_logo.gd`) y tema de botones `assets/ui/menu_theme.tres`, solo para el menú. Probar con el mouse y con las flechas + Enter.
- Monstruos: `godot --headless --path . -s tools/prepare_monster_sprites.gd` regenera los PNG de `assets/sprites/enemies/rendered/` desde `art/redesign-m24/sources/` (esas fuentes no se tocan). Después, `godot --headless --import`.
- Capturas reales (con ventana y el guardado aislado): `$env:APPDATA="$env:TEMP\m24appdata"; godot --path . res://tools/capture_m24.tscn -- monstruos` (también `menu` y `wiki`); salen en `art/m24-integracion/`.
- Para probarlo jugando: el ejecutable de pruebas, nivel 1, oleada 1. Mirar el diablillo, la bestia y el ogro caminando hacia la izquierda: no se dan vuelta (a propósito, D-050).

## Fondos M26
Los siete temas, el camino y las rocas, árbol, arbusto y puerta usan los nuevos PNG renderizados. Se aplican en partida, menú y editor; rutas y casillas construibles conservan sus reglas. Recursos en `assets/tiles/rendered/` y `assets/sprites/map/rendered/`.

### Arte M27 en revisión
Propuestas de niveles2/3 de las nueve torres (ocho vistas por nivel) y cinco monstruos especiales en `art/redesign-m27/`. Incluye atlas, iconos, muestras en Godot, fuentes y guía de integración; todavía no cambia los recursos que usa la partida.

### M27 aplicado a la partida
Las nueve torres usan mecanismos nuevos en niveles 2 y 3. Guardián, Curandero, Chamán, Espejo y Jefe usan sus PNG renderizados estáticos. Se conservan balance, habilidades y nivel 1 de las torres. Capturas en `art/m27-integracion/`.

### Probar M29
Importar el proyecto y correr GUT como arriba. En Windows/Linux la ventana crece hacia1920×1080 y cabe en el área útil; en Opciones, Pantalla completa utiliza toda la resolución del monitor. El lienzo lógico sigue1280×720. En partida, revisar Volador/Blindado/Troll/Araña/Cría migrados; caminar y doblar con Normal/Rápido/Tanque; pausar y ralentizar; comprobar barras, quemadura y parpadeo. Mejorar las nueve torres y comprobar base fija, apuntado y retroceso con el encastre C. `art/redesign-m29/capture.tscn` reproduce capturas de producción y24 cuadros de movimiento con `godot --path . --resolution 1920x1080 art/redesign-m29/capture.tscn`. Windows de pruebas: `godot --headless --path . --export-release "Windows (pruebas)" build/JuegoA_m29.exe`. Linux/móvil requieren revisión en sus dispositivos.

### Probar M30
Mejorar las nueve torres y comparar reflejos en niveles2/3; apuntar, retroceder, pausar y aturdir. La base y su sombra permanecen fijas. Reproducir captura con `godot --path . --resolution 1920x1080 art/redesign-m30/capture.tscn`.

### Probar M31
Ejecutar `build/JuegoA_m31.exe` o extraer `build/JuegoA_m31_linux.zip`. Revisar los nueve monstruos nuevos: giro, pies, tamaño, ralentización y pausa; comprobar crías, auras, regeneración, hechizo y rebote. Muestra reproducible: `art/redesign-m31/capture.tscn`; `previews/motion.gif` presenta las cuatro direcciones con actores y datos de producción. Linux fue exportado, sin ejecución en este equipo Windows.

### Probar M32
Abrir `build/JuegoA_m32.exe`, pasar el puntero sobre los iconos de la barra, revisar cifras y ayuda de oleada completada. Abrir Pruebas [F1], activar Mostrar FPS y cerrar el panel: el monitor sigue visible. Esc abre la pausa renovada; P pausa directamente. Capturas en `art/redesign-m32/`. Linux exportado sin ejecutar; móvil sin probar.
