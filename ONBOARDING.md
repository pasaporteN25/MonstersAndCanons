# Onboarding — cómo preparar una computadora para trabajar en Monsters & Canons (TDv1)

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
| 6 | [Exportar para Windows](#6-exportar-para-windows-exe) | Para exportar | se crea `build/MonstersCanons.exe` |
| 7 | [Preparar Android](#7-android-apk) | Solo para el celular | se crea `build/MonstersCanons.apk` |

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

**✅ Comprobar:** pulsar **F5**. Tiene que abrirse el **menú principal** (logo «Monsters & Canons» con el mapa de fondo).

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
godot --headless --path . --export-release "Windows Desktop" build/MonstersCanons.exe
```

**✅ Comprobar:** se crea `build/MonstersCanons.exe` (~110 MB, casi todo es el motor). Copiarlo a otra carpeta y abrirlo: tiene que funcionar sin Godot.

> ℹ️ La carpeta `build/` no se sube a git.

### 6.1 El modo de pruebas (desde Opciones)

Para probar todos los niveles y el contenido sin ganar cada nivel (spec §10.2). Desde M48 (D-077) **no hay un ejecutable aparte**: se activa en el mismo `MonstersCanons.exe` (o la APK), desde **Opciones → Administración → Activar modo de pruebas → Sí, activar**.

**✅ Comprobar:**
- Al confirmar, el menú se vuelve a armar y abajo al centro dice "MODO PRUEBAS · F1: panel". Todos los niveles se pueden elegir y en la partida `F1` abre el panel de pruebas. En el log aparece "Modo de pruebas activado".
- Usa su propio guardado (`save_pruebas.json`), así que no toca el progreso ni los récords reales.
- Opciones ahora dice **"Volver al juego normal"**, y desde el menú de pausa la sección no aparece.
- Si cerrás el juego en modo de pruebas, la próxima vez arranca normal.

Para arrancar directo en modo de pruebas, por ejemplo con un acceso directo para desarrollo: `MonstersCanons.exe -- --pruebas`.

El botón **"Editor de mapas"** (spec §10.3) está **para todos en PC** (desde M14, D-038; en el celular solo con el modo de pruebas activo): se dibujan niveles con el mouse, se prueban al instante y se guardan en `%APPDATA%\Godot\app_userdata\JuegoA\maps`. Comprobá que abrirlo no cambia el progreso. Cómo se usa y cómo volver oficial un mapa: [`CONTENIDO.md`](CONTENIDO.md).

### 6.1.0 La Wiki (en todas las versiones)

Menú principal → **Wiki**. Comprobá que hay cinco solapas (Enemigos, Torres, Colecciones, Guía, Lore), que cada enemigo y cada torre tienen su dibujo y sus números, y que se puede recorrer con el mouse y con el teclado (▲/▼ entre entradas, ◄/► entre solapas, Esc para volver). Los enemigos que todavía no viste en una partida salen como "???" (con el contador "Enemigos 4/9"): en el `.exe` normal empiezan cerrados y se abren al cruzártelos; en el de pruebas se ve todo. Un enemigo o una torre nuevos deberían aparecer sin tocar nada más; los artículos de la Guía están en `data/wiki/*.json` ([`CONTENIDO.md`](CONTENIDO.md)).

### 6.1.001 Textos de los niveles y Lore (M52, T228; en todas las versiones)

Con el `.exe` normal (no el modo de pruebas, que no muestra textos): **Niveles** → los desbloqueados traen su **lugar** en letra chica bajo el nombre (los bloqueados, no). Entrá a uno: aparece un **cartel** con el nombre, el lugar y 3 líneas, y la partida **espera** (la cuenta atrás no corre) hasta que tocás la pantalla, o apretás `Espacio`, `Enter` o `Esc` (`Esc` **no** abre la pausa). «Reintentar» **no** vuelve a mostrarlo; «Siguiente nivel» y elegir el nivel otra vez, sí. Al ganar, la pantalla de victoria trae 2 líneas bajo las estrellas. En **Wiki → Lore** los artículos se abren al ganar el nivel que dicen (cerrados: «???» y «Se abre al ganar el nivel N.»). **Sin probar en un celular real:** el cartel entra en 1280 × 720 y se comprobó por medidas, pero el tamaño táctil de «Empezar» y que no tape el botón de pausa hay que mirarlo con el dedo.

### 6.1.05 Mapas más grandes (zoom)

Copiá `tools/ejemplos/mapa_grande.json` a la carpeta de mapas de la comunidad (ver más abajo) y jugalo desde **Jugar → Mapas de la comunidad**. Tiene que verse **entero**, centrado entre las dos barras, con las torres y los enemigos algo más chicos que en los otros niveles y la interfaz igual. Construí una torre haciendo clic en una casilla: tiene que aparecer **justo en esa casilla**. Con el ratón y, en el celular, con el dedo. Abrilo también en el editor de mapas: se ve entero y se puede pintar sin errores de puntería.

### 6.1.06 Temas y leyenda

Copiá los siete `tools/ejemplos/tema_*.json` a la carpeta de mapas de la comunidad y jugá cada uno. Se tiene que ver: el **paisaje** propio de cada tema, el **camino bien distinto del suelo**, los enemigos claros sobre cualquier suelo, un **lago / oasis / laguna helada / río de lava / barro** que **no se puede construir**, las **flores** (que sí) y la decoración del tema. Los enemigos siguen el **mismo camino** que en el nivel 4 (son ese nivel con parches). Abrilos también en el editor: se ven igual y se guardan sin perder el tema.

### 6.1.07 Guardián y Curandero (modo de pruebas)

Con el modo de pruebas activo (Opciones), abrí una partida, `F1` (panel de pruebas) y hacé aparecer un **Guardián**, un **Curandero** y varios enemigos comunes. Tiene que verse: el **anillo** de cada uno en el suelo (marfil dorado el Guardián, verde el Curandero); un **escudo** sobre los enemigos que están dentro del anillo del Guardián y una **cruz verde** sobre los del Curandero; el **número de daño gris** cuando la armadura se come el golpe; y que al **matar al portador** el escudo o la cruz desaparecen en menos de un segundo. Con una Incendiaria, el enemigo que se quema no recupera vida aunque esté dentro del anillo verde.

### 6.1.10 Combos por estado

En el nivel 1 poné un **Hielo** y, un poco más adelante en el camino, un **Cañón**. Qué tiene que pasar (RF-315 a RF-318):

- **Antes del golpe:** un enemigo ralentizado (tinte **celeste** y escarcha en el piso) muestra una **dianita celeste** al lado de su barra de vida, porque hay un Cañón en el mapa. Si vendés el Cañón, la dianita desaparece.
- **El golpe:** cuando el Cañón le pega, el número de daño sale **"25!"**, **celeste y más grande** (en vez del "20" blanco), con un **anillo celeste** y un **"tin"**. El primer combo de la partida dice además **"¡Combo de hielo!"**; los siguientes, no.
- **Con fuego:** con una **Incendiaria** y una **Eléctrica**, el enemigo en llamas muestra una dianita **naranja**, el número sale **naranja** ("17!") y la primera vez dice "¡Combo de fuego!".
- **Los textos:** seleccioná el Hielo: el panel dice "Combo: Cañón y Francotirador +25 % a los que frena" (en el nivel 1 no hay Mortero). Elegí el Cañón en la barra: la frase de abajo termina con "Combo: +25 % a ralentizados.". En la Wiki, la ficha del Hielo tiene un apartado "Combos" y el artículo "Efectos de las torres" los explica.
- **Números apagados** (Opciones): no hay número, pero el anillo, el "tin" y el texto de la primera vez siguen.

Qué mirar con ojo crítico: si el "tin" se vuelve molesto en una oleada cargada, y si el combo **pesa** lo suficiente. Si falta peso, lo decidido es una regla nueva (el combo frena en seco al enemigo un instante, D-047), no subir los porcentajes.

### 6.1.09 El Mortero (2×2)

El Mortero es una torre **reservada** (debuta en el nivel 9, T224, y sigue en el 10, T225) y **cuesta 300 de oro + 3 recursos** (T209): para probarla, abrí el mapa `tools/ejemplos/mapa_recursos.json` (copialo a la carpeta de mapas de la comunidad). Arriba aparece el contador de recursos (con ícono verde); demolé la roca y el árbol del mapa (30 de oro cada uno, 3 s; los dos entregan 1 recurso) y la roca de la derecha para llegar a 3. En la barra, el Mortero dice **"300 + 3"** y está gris (con el motivo al pasar el mouse) hasta tener los 3 recursos. Elegí el **Mortero** (tecla **4** en ese mapa) y pasá el mouse por el mapa: el cuadrado de **2×2** queda centrado en el mouse y se ve **verde** donde entra y **rojo** si una de las cuatro casillas es camino, roca u otra torre. Construilo: ocupa las cuatro casillas, un clic en cualquiera lo selecciona, dispara una bomba cada 4 segundos con daño de área, y al **venderlo** devuelve el 70 % del oro y de los recursos (210 y 2) y libera las cuatro casillas. En el mismo mapa, elegí el **Francotirador**: la ayuda de abajo muestra dos botones chicos, "150 de oro" (elegido de entrada) y "120 de oro + 1 recurso" (apagado hasta tener un recurso); con el segundo, la venta devuelve 0 recursos. En cualquier mapa sin removibles (por ejemplo el nivel 1) no hay contador y la segunda opción dice que el mapa no tiene recursos. La barra de abajo debe mostrar las 9 torres sin tapar "Próxima oleada".

### 6.1.08 Chamán y Espejo (modo de pruebas)

Con el modo de pruebas activo (Opciones), `F1`, hacé aparecer un **Chamán** cerca de varias torres y esperá unos 8 segundos: tiene que salir un **rayo magenta** hacia la torre más cercana, que se ve **apagada** (oscura, con chispas) y **no dispara** unos 3 segundos; si la seleccionás, el panel dice **"Aturdida (N s)"** con la cuenta atrás. Después, un **Espejo** al lado de una torre pegada al camino: el primer disparo tiene que mostrar **"¡Rebote!"**, el Espejo no pierde vida y la torre queda apagada 2 segundos; una torre lejos (por ejemplo un Francotirador) le pega normal. Con una Incendiaria pegada, el Espejo se quema igual.


### 6.1.11 Probar oleadas finales y mirar un combo (modo de pruebas)

Con el modo de pruebas activo (Opciones), **Jugar**: arriba de las tarjetas hay una franja **"Pruebas"**. Poné **Oleada inicial** en 10 (por ejemplo) y dejá el oro en **Automático**, y elegí el **Nivel 1**.

**✅ Comprobar:**
- La partida arranca sin torres, con bastante más oro que el normal (lo que se habría juntado en las oleadas 1 a 9), el HUD dice **"Próxima: oleada 10/10"** y al apretar *Empezar oleada* salen los enemigos de la última. Con **Oro inicial** a mano (sacá la tilde de "Automático") arranca con el número que escribas, también con 0. Un número mayor al total usa la última oleada.
- Ganar o perder esa partida **no** cambia estrellas, récords ni niveles desbloqueados (mirá la pantalla de selección al volver). **Reintentar** vuelve a la oleada 10 con el mismo oro.
- `F1` abre el panel: la fila **Velocidad** tiene **x0,25 · x0,5 · x1 · x2 · x4**. Elegí x0,25 con un Hielo y un Cañón en el camino: el aviso de combo (número celeste con "!") se lee con calma. El cartel de abajo dice "MODO PRUEBAS · F1: panel · x0,25", el botón de arriba dice "x0,25 [F]", y al salir de la partida vuelve a x1.
- **Atajos** (con el panel abierto o cerrado): `F2` mata a todos, `F3` salta la oleada, `F4` prende y apaga las vidas infinitas, `F6` y `F7` bajan y suben la velocidad un paso. Las teclas `1`–`9` siguen construyendo torres.
- Al terminar (o al salir) se escribe `%APPDATA%\Godot\app_userdata\JuegoA\pruebas_stats.json` con la oleada, las vidas, el oro y las torres de cada oleada terminada y el resultado (`won`, `lost` o `left`).

### 6.1.1 Mapas de la comunidad (en todas las versiones)

Los `.json` de `%APPDATA%\Godot\app_userdata\JuegoA\maps` (la misma carpeta donde guarda el editor) aparecen en **Jugar → Mapas de la comunidad**, en el `.exe` normal y en el de pruebas. Para comprobarlo: guardar un mapa desde el editor (en cualquiera de los dos `.exe`) y buscarlo en la solapa. Cada versión tiene su propio guardado, así que el progreso en esos mapas no se comparte entre el `.exe` normal y el de pruebas. Detalles en [`CONTENIDO.md`](CONTENIDO.md).

### 6.1.2 Probar el modo celular sin celular (M58; cuando T271 esté hecha)

La spec M58 (RF-502) agrega en **Opciones** un selector **«Interfaz»**: *Automática* (celular si el aparato lo es, PC si no), *Celular* y *PC*. Para ver el modo celular en una computadora: **Opciones → Interfaz → Celular**, y abrir una partida (no cambia una que ya está en curso). El mouse hace de dedo: un clic es un toque y arrastrar es un arrastre de un dedo. **La pinza con dos dedos no se puede probar así** (el zoom se prueba con la rueda y el botón central); para eso y para medir milímetros hace falta el celular, con el kit de `specs/tareas/informes/T262-analisis-mobile.md` §6. **Hasta que T271 esté hecha, este paso no existe.** La posición de los botones flotantes queda en `save.json` (clave `ui_prefs`): para volver a los lugares de fábrica, borrar esa clave o el archivo (ver «Dónde guarda las cosas el juego»).

### 6.1.3 Menús del celular, mouse en Android y versión (M61)

- **Ver los menús del celular en la computadora:** **Opciones → Interfaz → Celular** y volver al menú principal (se ve en dos columnas). Para **capturas reales** de cada pantalla y un informe de qué botón queda fuera de la ventana o mide menos de 56 px: `godot --path . res://tools/capture_menus.tscn -- /carpeta/de/salida 1280x720 mobile` (o `pc`; hace falta ventana, no sirve `--headless`). En un celular apaisado 16:9 o 20:9 el juego dibuja siempre 1280 × 720 (en el 20:9 sobran franjas a los costados), así que 1280 × 720 es la medida que vale.
- **Desplazar listas con el dedo:** en el celular, las listas de niveles, la Wiki, Opciones y Créditos se mueven arrastrando un dedo (aunque empiece sobre una tarjeta), con inercia. En la computadora con el modo celular forzado el mouse **no** arrastra listas: usar la rueda o la barra (un clic en la barra de la derecha).
- **Mouse en Android** (DeX, Chromebook, teclado y mouse): en el modo celular un clic real hace de dedo (mapa, carrito, X, tilde, cruz); el clic que Android fabrica a partir de un toque se descarta. Ya no hace falta «Interfaz: PC». **Nunca se probó en un aparato real: si en DeX algo no responde o se duplica, anotar qué dispositivo era y ajustar `puntero_duplicado_ms` y `puntero_duplicado_px` en `data/ui/mobile_ui.json`.**
- **La versión** (Opciones → «Créditos y versión» muestra «Beta») se cambia **solo** en `project.godot`, `config/version`. Al exportar un `.exe` hay que mirar que Windows tenga su `file_version` y `product_version` numéricos (hoy `0.0.0.0`, en `export_presets.cfg`); el APK toma la versión del proyecto (su `version/name` está vacío). **Todavía no se exportó nada con este cambio.**

### 6.2 La versión para GNU/Linux

```bash
godot --headless --path . --export-release "Linux" build/MonstersCanons.x86_64
tar --mode=755 -czf build/MonstersCanons_linux.tar.gz -C build MonstersCanons.x86_64
```

**✅ Comprobar:** se crea `build/MonstersCanons.x86_64` (~75 MB). Para verificar que es de Linux: `file build/MonstersCanons.x86_64` dice "ELF 64-bit LSB executable, x86-64". Necesita las plantillas de Linux, que vienen con las de Windows (paso 6, arriba).

**En una computadora Linux:** `tar -xzf MonstersCanons_linux.tar.gz` y `./MonstersCanons.x86_64`. Si se copió el archivo suelto desde Windows, hay que darle permiso: `chmod +x MonstersCanons.x86_64`.

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
godot --headless --path . --export-debug "Android" build/MonstersCanons.apk
```

Se usa `--export-debug` porque la versión de **prueba** se firma sola con la clave de depuración. (Publicar en la Play Store requiere una clave propia y `--export-release`; eso no está hecho.) Mientras no esté el SDK de Android (T237), la APK `MonstersCanons.apk` no se genera en la máquina Linux.

### 7.4 Instalar en el celular

**Opción A — por cable (la más rápida):**
1. En el celular: *Ajustes → Acerca del teléfono* → tocar 7 veces **Número de compilación** (activa las "Opciones de desarrollador").
2. *Ajustes → Opciones de desarrollador* → activar **Depuración USB**.
3. Conectar el celular por USB y aceptar el aviso que aparece en él.
4. Instalar:
   ```bash
   "$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" install -r build/MonstersCanons.apk
   ```

**Opción B — copiando el archivo:** pasar `MonstersCanons.apk` al celular (cable, Drive, WhatsApp…), abrirlo y aceptar **"Permitir instalar apps de origen desconocido"**. Android lo pide porque no viene de la Play Store.

**Cómo se juega en el celular** (spec §9.4): tocar = clic; el botón **"atrás"** = `Esc` (abre el menú de pausa y **no** cierra el juego); el juego queda siempre en horizontal.

---

## Dónde guarda las cosas el juego

| Qué | Dónde |
|---|---|
| Progreso, récords y opciones del jugador | `%APPDATA%\Godot\app_userdata\JuegoA\save.json` |
| Lo mismo, pero del modo de pruebas | `%APPDATA%\Godot\app_userdata\JuegoA\save_pruebas.json` |
| Registros (logs) de cada ejecución, los últimos 30 | `%APPDATA%\Godot\app_userdata\JuegoA\logs` |
| Configuración del editor (rutas de Android, etc.) | `%APPDATA%\Godot\editor_settings-4.7.tres` |
| Plantillas de exportación | `%APPDATA%\Godot\export_templates\4.7.2.stable` |
| Caché del proyecto (se regenera sola) | `JuegoA/.godot/` |

> 📱 **M58 (cuando esté programada):** `save.json` suma `settings.ui_mode` (la opción «Interfaz») y la clave `ui_prefs` (lado y altura de los botones flotantes, por dispositivo). Son aditivas: `SAVE_VERSION` no cambia y, si faltan o están rotas, el juego usa los valores por omisión.

> 💡 **Empezar el progreso de cero:** borrar `save.json`. El `.exe` y el juego abierto desde el editor **comparten** ese archivo.

---

## Herramientas del proyecto

Se ejecutan desde la carpeta del proyecto. Más detalle dentro de cada archivo.

| Comando | Para qué |
|---|---|
| `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` | Correr todos los tests. |
| `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart level=1` | Bot que juega solo, para revisar el balance (spec §7.1). Estrategias: `smart`, `mix`, `heavy`, `basic`, `naive` y, de M50, `sin_recursos`, `demoler`, `demoledora`, `pieza` (T245), `extraer_temprano`, `extraer_tarde`; con `seeds=N` y `levels=A-B` juega muchas partidas y da una tabla. `check_rule=1` comprueba la regla de oro. |
| `godot --path . -s tools/perf_test.gd` | Prueba de rendimiento: 200 enemigos y 60 torres. Abre una ventana. |
| `godot --path . res://tools/perf_levels.tscn -- level=15 from=27` | Rendimiento en un nivel real (T236): `level` es el mapa, `from` cuántas oleadas se dan por jugadas antes de medir; opciones `to`, `towers`, `seconds`, `vsync=1`. Imprime los FPS de cada oleada. Abre una ventana. |
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
- Para probarlo jugando: el modo de pruebas, nivel 1, oleada 1. Mirar el diablillo, la bestia y el ogro caminando hacia la izquierda: no se dan vuelta (a propósito, D-050).

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

### Probar M33
Abrir `build/JuegoA_m33.exe`; revisar Opciones desde menú y pausa (sonido/visualización), niveles/comunidad, Wiki, récords, final e iniciales. Probar editor/Ajustes/Oleadas/diálogos en modo pruebas. Capturas en `art/redesign-m33/`; ejecutar `capture.tscn` reproduce las siete pantallas. Windows exportado y arranque verificado; Linux exportado sin ejecutar, móvil sin probar.

### APK del PR#1 · M34
> **Reemplazado en T196 (D-077):** hoy hay una sola APK (`build/JuegoA.apk`, paquete `com.juegoa.towerdefense`) y el modo de pruebas se activa desde Opciones. Lo que sigue es el registro de M34.

- Normal: `build/JuegoA_PR1_normal.apk`, paquete `com.juegoa.towerdefense`.
- Pruebas: `build/JuegoA_PR1_pruebas.apk`, paquete `com.juegoa.towerdefense.pruebas`, feature `pruebas`.
Ambas pueden instalarse juntas, Android7 o superior en arm64. Están firmadas con clave de depuración para instalación directa, no para Play Store; «normal» describe las reglas del juego, aunque la exportación técnica es debug. Exportar con `--export-debug "Android"` y `--export-debug "Android (pruebas)"`. Si una versión instalada usa otra firma, Android rechazará actualizarla; no desinstalar sin resguardar el progreso. No se probaron en dispositivo físico. SHA256 y verificación: `build/m34/`.
iOS usa IPA, no APK. La exportación exige un Mac con Xcode y los datos de firma de Apple; este Windows no genera una app iOS instalable. Fuente: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html

### Prueba manual M35 · Panel de torre
Seleccionar torres de niveles1–3, revisar daño/cadencia/alcance, descripción y voladores. Cambiar prioridad, mejorar con U, vender con S; comprobar falta de oro y nivel máximo. Aturdir una torre: aparece cuenta atrás independiente del título. En Hielo, recorrer el detalle hasta ver sinergias y capacidad aérea. Con texto largo, desplazar el detalle y recorrer botones con Tab: ninguna acción sale del panel ni tapa la barra de construcción. Revisar también ventana1280×720 y tamaños escalados.

### M36 · Comprobar niveles, efectos y sonido
Revisar las nueve torres niveles1–3 y Mortero2×2, también aturdidas: contar remaches sin depender del brillo. Probar Espejo/Chamán, origen del efecto y recuperación. Curandero con heridos/vida completa/fuego y Troll regenerando: distinguir radio del aura de cura efectiva. Matar las trece especies, pausar y usar x2 durante efectos; verificar crías/oro/salida. Escuchar menú y combate, luego impactos/rebote/hechizo/cura con muchas torres; Opciones al0/50/100%. Muestras y laboratorio en art/redesign-m36; requieren APPDATA aislado. No implica prueba física Android/Linux ni aprobación auditiva humana.

### M37 · Comprobar avances y apoyo
Usar guardado aislado. Verificar que fuente repetida no suma, enemigo portador que escapa no entrega, derrota antes/después del cierre de oleada difiere y abandonar no guarda. En6/7, colección incompleta bloquea mecánico;5/5 permite construirlo. F1→Habilitar estandartes ofrece apoyo sin colección también fuera de esos niveles solo en admin. Dos auras no apilan; aturdir/vender/mejorar modifica el apoyo. Reparación todavía pendiente.

### M38
Comprobar contador0/5 en la barra superior, pickup1/5 y ayuda pendiente/confirmada; sin cartel fijo sobre el mapa. Normal/admin/comunidad tienen contador y ayudas de foco.

### M39 · Ladrón
Encuentros opcionales en6/7: roba3 de oro cada2s, piso10, hasta morir o escapar. Pausa/velocidad respetadas. Pruebas permite invocarlo sin progresión; Wiki explica la habilidad. Arte y balance iniciales revisables.

### M40 · Embestidor y desgaste
Ensayos6/7. Carga al final de rectas; solo alcanza una torre próxima a ese extremo. Desgaste20% por impacto, tope50%, reduce cadencia y apoyo sin destruir. Hielo fuerte interrumpe carga; mejora conserva desgaste. Panel y marcas distinguen daño y aturdimiento. Reparación continúa en M41.

### M41 · Mecánico reparador
El Mecánico recupera2/3/4 puntos de desgaste por segundo dentro de su radio; solo el más fuerte y sin autorreparación. No cura aturdimiento. Daño reduce sus prestaciones; otra estatua puede repararlo. Colección5 avances+permiso del nivel y habilitación de Pruebas se conservan. Ensayos6/7;1–5 conservan datos de oleadas y balance.

Verificación M41: 943 pruebas GUT verdes; 103 FPS con 200 enemigos/60 torres y desgaste activo. Exportaciones Windows normal/pruebas y Linux; arranque Windows código 0. Capturas y 12 simulaciones en art/mechanics-m41. Balance inicial: compra temprana del Mecánico perjudica al bot en nivel 6; en nivel 7 ambas variantes ganan. Ajuste fino y arte final pendientes.

### M42 · Selección de enemigos en Pruebas
Rueda sobre el selector: anterior/siguiente, sin abrir ni invocar. Clic mantiene la lista completa, ahora con altura limitada y scroll, fondo opaco y sin sombra recortada. B-31 registra rediseños pendientes de Mecánico, Embestidor, Ladrón y Curandero; se evaluará reutilizar la silueta del Curandero como base del Embestidor.

### M43 · Rediseños B31 integrados
Embestidor acorazado con frente de impacto; Curandero erguido con semilla medicinal; Ladrón encapuchado con bolsa; Mecánico renderizado en hierro/bronce sobre bases existentes. Los tres enemigos tienen ciclos 4×4, por distancia. No cambia balance. Vista animada y capturas: `art/redesign-m43/preview.html`; prompts/fuentes allí. Pruebas: habilitar estandartes, invocar los enemigos y observar giros/carga/pausa; revisar Wiki. Aprobado visualmente por Lucas el 2026-10-04.

### T190 · Entrega visual aprobada
B31 cerrado por aprobación de Lucas (2026-10-04). Exportados `build/JuegoA.exe`, `build/JuegoA_pruebas.exe`, `build/JuegoA.apk` y `build/JuegoA_pruebas.apk`. Windows release: ambos arrancan con código0, solo pruebas activa DevMode. APK debug arm64, Android7+, paquetes normal/pruebas separados, misma firma anterior verificada v2/v3 y recursos M43 presentes. SHA256 y registros en `build/t190/manifest.json`; no se ejecutaron en celular físico. Siguiente: balance/estrategias6/7, luego diseñar8/9.

### T191 · Verificar balance y reparación

Ver art/balance-m44/README.md para perfiles, semillas, ejecución y límites. Runner usa APPDATA por proceso y física60Hz; no ejecutar fases de escritura simultáneas. La suite incluye pasos0,1s y cierre exacto de desgaste/tasa. Los paquetes build/JuegoA{,_pruebas}.{exe,apk} incluyen esta corrección; firmas y paquetes Android conservados. No hay QA física Android ni balance humano definitivo.

### T192 · Probar campaña8/9 desde el proyecto

Abrir el editor o ejecutar Godot desde el proyecto: los EXE/APK anteriores no incluyen esta etapa y no se regeneraron. Ganar7 habilita8 incluso en un guardado antiguo; ganar8 habilita9. Admin permite elegir ambos niveles y habilitar Mecánico sin avances. En modo normal construirlo exige5/5 y permiso del nivel. Verificar presentación Guardián8/Curandero9, encuentros opcionales de Ladrón y carga al extremo de rectas con torres cercanas; probar apoyo en grupo y reparación después de impacto. Capturas/bots y criterios en art/campaign-m45/README.md; no confundir capturas controladas con sesión humana de balance.

### T225 · Probar el nivel 10 (La mina vieja)

Con el proyecto abierto (o `godot --path .`): ganar el nivel 9 abre el 10 (o, con el modo de pruebas activo, elegirlo en **Niveles**). **✅ Comprobar:** el mapa es **más grande** que los otros y se ve entero (zoom), con arena, cactus y huesos; arriba aparece el contador de recursos. Tocá la **mina** (bloque oscuro arriba, al centro): el panel dice *Habilitar extracción · 100 de oro*, *2 recursos por oleada completada* y *Reserva 8*; al habilitarla y completar una oleada, el contador suma 2 con un aviso "+2" sobre la mina. Tocá el escombro del centro de la banda de abajo: *Pieza de la Disruptora: pendiente*; demolerlo (90 de oro, 10 s) y completar la oleada confirma la pieza (la barra muestra la colección **3/3** si ya tenías las del 8 y el 9). Con 3 recursos y 300 de oro, el **Mortero** (tecla 9) se construye en uno de los cuatro bloques libres de 2×2. Se puede ganar sin tocar nada de esto.

Para medir: `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=10 seeds=5` y `... -- x check_rule=1 levels=10`. Captura y exposición: `godot --path . --resolution 1920x1080 art/campaign-t225/capture.tscn` (necesita pantalla) y `godot --headless --path . art/campaign-t225/exposure.tscn`. Detalle en `art/campaign-t225/README.md`.

### T253 · Probar La Cuadrilla (el Ratero y el Cargador en los niveles 7, 10, 13 y 14)

Entrar al **nivel 7** (con el modo de pruebas se puede elegir en **Niveles**) y llegar a la **oleada 8**. **✅ Comprobar:** salen **dos tarjetas seguidas**, «Ratero» y «Cargador» (6 s cada una), con una **forma de color** en lugar de dibujo (rombo ocre y hexágono marrón); los Rateros corren **en tanda** por la entrada A y detrás viene **un Cargador lento**; la **caja de oro baja** de a poco mientras siguen vivos (cada uno roba por su cuenta) y **nunca por debajo de 10**; aparece el aviso ámbar del robo. En **Wiki → Enemigos** se abren las dos entradas con la línea **«Robo»** y «Dónde aparece» con los niveles 7, 10, 13 y 14 (sin ilustración, hasta T257). **Ganar el 7 abre «La Cuadrilla» en Wiki → Lore**, entre «Las criaturas que van solas» y «Las ruinas»; el artículo de las criaturas no cambia. Las mismas bandas vuelven en las oleadas 8, 12, 14 y 16 del **10**, y 10, 13, 15 y 18 del **13** y del **14**.

Para medir: `... -s tools/balance_sim.gd -- sin_recursos level=7 seeds=5` (repetir con `level=10`, `13` y `14`; la tabla final trae la columna **«oro robado»**) y `... -- x check_rule=1 levels=7-14`. En **Asedio**, `... -- sin_recursos modo=asedio level=7 seeds=3`: con la Cuadrilla el bot lo pierde en la oleada 11 de 20.

### T242 · Probar la intro

Con un guardado nuevo (o sin la marca `"intro_seen"` en `save.json`), tocar **Jugar** en el menú principal. **✅ Comprobar:** se abre la intro en la lámina 1, con el texto de dos líneas en la franja de abajo y el botón **«Omitir»** arriba a la derecha; avanza sola (7 s la primera) o con un clic, `Espacio`, `Enter` o `→`, con un fundido corto; en la séptima, un toque o el tiempo terminan y se abre **el nivel 1 con su cartel de entrada** (si el guardado ya tenía niveles ganados, la selección de niveles). `Esc` o «Omitir» terminan en cualquier lámina, y el clic que termina **no construye nada** en la pantalla de después. Al volver a tocar «Jugar» ya no aparece. **Para verla de nuevo:** **Wiki → solapa Lore → «Ver la intro»** (vuelve a la Wiki y no toca el guardado), o borrar `"intro_seen"` de `save.json` (la carpeta de datos de usuario del juego; en esta máquina Linux es `~/.local/share/JuegoA/`). En el modo de pruebas «Jugar» no la abre sola. **Las láminas son las definitivas** (T241, aprobadas el 2026-10-11): el texto tiene que verse entero sobre la parte oscura de abajo, sin cortarse. Para probar un archivo roto: renombrar `data/intro/intro.json` y tocar «Jugar»: va a la selección de niveles y avisa en la salida.

Tests: `-gtest=res://tests/test_intro_data.gd`, `test_intro_flow.gd` y `test_intro_screen.gd`. **No correr `tools/make_intro_placeholders.py`: pisaría las láminas definitivas con las provisorias.** Para ver cómo entra el texto en una ventana real: `godot --path . res://tools/capture_intro.tscn -- <carpeta fuera del repo> 1280x720` (guarda un PNG por lámina y dos de peor caso); para comprobar que cargan: `godot --headless --path . res://tools/check_intro_pack.tscn`.

### T234 · Probar el nivel 15 (La Central, el Coloso y el epílogo)

Ganar el nivel 14 abre el 15 (o, con el modo de pruebas, elegirlo en **Niveles**). **✅ Comprobar:** al entrar, el **cartel** con «Energía y abastecimiento» y las tres líneas de entrada (la partida espera; un clic lo cierra); mapa **de pradera** de 26 × 12 con **tres entradas a la izquierda** que se juntan y siguen juntas hasta la salida de la derecha; **al lado de la salida, la central** (un edificio de piedra de cuatro cuadros) y, por el borde, un depósito, un poste y una vagoneta; **dos o tres campamentos vacíos**; en «Infraestructura» una mina y dos bosques. En la **oleada 26** sale la tarjeta «Nuevo enemigo: Coloso»: lento, grande, con la corona de «Peligroso». **Al caer se parte en tres Pedazos** chicos y rápidos que siguen camino (la Wiki los abre cuando los ves). En la **28** salen dos Colosos y en la **30**, tres, con la escolta completa por dos entradas. Al ganar: la pantalla de victoria muestra el texto «Central encendida…», los récords de siempre y el botón **«Epílogo»** (no «Siguiente nivel»); el epílogo muestra la imagen con cuatro líneas y los botones «Créditos» y «Niveles»; `Esc` o un toque sobre la imagen vuelven a la victoria; «Créditos» tiene «Volver». En **Wiki → Lore** se abre «La Central».

Para medir: `... -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=15 seeds=5` y `... -- x check_rule=1 levels=15` (cada partida tarda unos 3 minutos; conviene correr una semilla por proceso). Partida real con clics del mouse y capturas del cartel, el Coloso, el epílogo y los créditos (necesita pantalla y mueve el puntero): `godot --path . --resolution 1280x720 art/campaign-t234/play.tscn -- speed=6 out=art/campaign-t234`.

### T232 · Probar el nivel 14 (Los poblados vacíos)

Ganar el nivel 13 abre el 14 (o, con el modo de pruebas, elegirlo en **Niveles**). **✅ Comprobar:** mapa **de ruinas** (adoquines grises, columnas rotas, estatuas) de 26 × 12 con **dos entradas a la derecha** que se juntan en el medio-derecha y siguen juntas hasta la salida de la izquierda; **cinco campamentos vacíos** (tiendas oscuras con restos de fuego), **muchas rocas con una A** y cinco removibles; en «Infraestructura» una mina (arriba) y un bosque (abajo). **Sin enemigos nuevos:** la escolta (Guardián + Curandero + Chamán) llega con el Espejo y Voladores desde la oleada 12, por una o por las dos entradas. **La sensación a mirar:** que los poblados se vean abandonados hace poco, mientras la defensa sigue siendo necesaria.

Para medir: `... -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=14 seeds=5` y `... -- x check_rule=1 levels=14`. Partida real (necesita pantalla y mueve el puntero): `godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=14 until=10 speed=5 out=art/campaign-t229`.

### T231 · Probar el nivel 13 (Paso alto)

Ganar el nivel 12 abre el 13 (o, con el modo de pruebas, elegirlo en **Niveles**). **✅ Comprobar:** mapa **de nieve** de 26 × 12 con **dos entradas** (arriba y abajo a la izquierda) que se juntan a la izquierda del medio y siguen juntas hasta la salida, a la derecha; una **laguna de hielo** celeste en el medio donde no se puede construir; **la barra tiene 8 torres** (sin Ametralladora ni Lanzamisiles). En la **pestaña «Infraestructura»** hay **dos fuentes**: la mina (arriba) y el bosque (abajo), cada una *Habilitar · 100 de oro*. En la **oleada 9** llegan juntos un Guardián, un Curandero y un Chamán por **una** entrada (la tarjeta «Nuevo enemigo» sale por cada uno si es tu primera vez); desde la **14**, por las dos entradas a la vez. Con la Disruptora, se la pone donde se juntan los caminos.

Para medir: `... -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=13 seeds=5` y `... -- x check_rule=1 levels=13`. Partida real (necesita pantalla y mueve el puntero): `godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=13 until=10 speed=5 out=art/campaign-t229`.

### T230 · Probar el nivel 12 (El cañadón)

Ganar el nivel 11 abre el 12 (o, con el modo de pruebas, elegirlo en **Niveles**). **✅ Comprobar:** mapa **de 26 × 11** con paredes de roca y un camino que baja y sube cinco veces; **un solo lugar por donde entran** (arriba a la izquierda); tres rocas con una A cerca de la entrada; **sin Ametralladora**. En la **oleada 5** sale la tarjeta «Nuevo enemigo: Espejo»: cuando una torre a **menos de 2,5 casillas** le dispara, aparece «¡Rebote!» y la torre queda **aturdida 2 s**; un Francotirador (alcance 6) o el Mortero le pegan sin problema. En la **pestaña «Infraestructura»**, el **bosque** (cuadro verde con árboles) dice *Habilitar · 100 de oro*, *2 recursos por oleada*, *reserva 8*. Se puede ganar sin usarlo.

Para medir: `... -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=12 seeds=5` y `... -- x check_rule=1 levels=12`. Partida real (necesita pantalla y mueve el puntero): `godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=12 until=7 speed=5 out=art/campaign-t229`.

### T229 · Probar el nivel 11 (Puesto seco)

Con el proyecto abierto (o `godot --path .`): ganar el nivel 10 abre el 11 (o, con el modo de pruebas, elegirlo en **Niveles**). **✅ Comprobar:** el mapa es **grande** y del desierto, con **una sola entrada** (arriba a la izquierda) y la salida abajo a la derecha, **dos pozos azules** y tres rocas con una A; la barra **no tiene la Ametralladora** (8 botones; 10 con las colecciones completas, y entonces la Disruptora y el Mecánico aparecen); en la **tarjeta del nivel** la Disruptora aparece como «Nueva» (la tarjeta avisa lo que ofrece el nivel, aunque todavía falte la colección). En la **oleada 5** sale una tarjeta «Nuevo enemigo: Chamán» y, unos segundos después, un rayo magenta **apaga la torre más cercana** (3 s): un Francotirador lo mata antes. El Guardián y el Curandero llegan juntos en la 8. Se puede ganar sin la mina ni los removibles.

Para medir: `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos,demoler,extraer_temprano,extraer_tarde level=11 seeds=5`, `... -- x check_rule=1 levels=11` y, para la Disruptora, `... -- mix level=11 seeds=5 disruptor=0` contra `disruptor=1`. Partida de verificación con la escena real (necesita pantalla y **mueve el puntero**): `godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=11 until=7 speed=6 out=art/campaign-t229`. Detalle en `art/campaign-t229/README.md`.

### T197 · Comprobar los modos de juego

Abrí el juego (o el proyecto con F5) y entrá a **Jugar**.

**✅ Comprobar:**
- Después de "Campaña" aparece la solapa **Asedio**. Tiene **15 mapas** (T258): el primero abierto y los demás "Bloqueado". Con el modo de pruebas (Opciones) se abren todos para mirar del 10 al 15 sin ganar los anteriores.
- Jugar el Mapa 1 de Asedio arranca la Pradera con los monstruos más duros. Al ganar, se abre el Mapa 2 de Asedio, pero la campaña no cambia.
- En el **Editor de mapas**, **"En un modo…"** → **+ Nuevo modo…** → un nombre → un nombre de archivo. Al volver a **Jugar**, aparece una solapa con ese modo después de "Mapas de la comunidad", con el mapa abierto y el botón "Abrir carpeta del modo".
- "Guardar" después de eso sigue guardando en el modo, y "Abrir" lista el mapa bajo "— Modo … —".
- **Cada mapa de Asedio tiene su propia vida de monstruos** (de 101 % a 118 %; el 4 y el 15 en 115 %; los números están en `data/modos/asedio/modo.json`, clave `vida_monstruos_por_mapa_%`). Para verla: `... -s tools/balance_sim.gd -- sin_recursos modo=asedio level=10 mejoras=llenar` imprime «Modo: Asedio · … vida de los monstruos 118 %» y la línea «Variante». Jugando, el mapa 10 tiene que sentirse más duro que el 11 (118 % contra 101 %), aunque el 11 sea un nivel más difícil de por sí.
- Para balancear: `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix modo=asedio level=1`.
- **Perfil de Asedio (T258):** `... -s tools/balance_sim.gd -- x perfil=asedio` juega los 15 mapas con 5 semillas y la política de cada mapa (`tools/asedio_politicas.json`; tarda cerca de una hora, se puede partir con `levels=1-5`, `6-10` y `11-15` en tres terminales). Imprime la tabla, el promedio de vidas por bloque y termina con código 1 si algún mapa no gana las 5 con 3 vidas o más o si los bloques suben. `mejoras=llenar` y `mejoras=temprana` mejoran torres como lo haría quien juega (con el oro).
- **Varias semillas y varios mapas (T204):** `... -s tools/balance_sim.gd -- mix levels=6-9 seeds=5 report=user://balance.json`. `seed=N` fija una semilla, `seeds=N` juega las semillas 1 a N, `levels=A-B` juega los mapas A a B y se pueden pedir varias estrategias (`mix,smart`). La misma semilla da siempre el mismo resultado. Al final imprime una tabla (mapa, estrategia, semilla, resultado, vidas, oleada y oro sobrante) y, con `report=`, la guarda en JSON (`user://` es `~/.local/share/godot/app_userdata/<proyecto>/`).
- **Estrategias de infraestructura y regla de oro (T214):** `... -s tools/balance_sim.gd -- sin_recursos,demoler,demoledora,extraer_temprano,extraer_tarde seeds=3 file=tools/ejemplos/mapa_extraccion.json`. Las cinco usan el orden de compra de `mix` y solo las torres que ofrece el mapa. `sin_recursos` no toca la infraestructura; `demoler` demuele de a uno los removibles cuya casilla alcanzaría más camino que la mejor casilla libre que queda; `demoledora` compra la máquina cuando quedan 4 o más removibles que valen la pena; `pieza` (T245) juega como `sin_recursos` pero, pasadas las 2 primeras torres, junta oro y demuele solo la ruina con la pieza de colección; `extraer_temprano` habilita los puntos de extracción desde la oleada 1 y `extraer_tarde` a mitad del nivel, y las dos construyen torres con recursos apenas alcanzan (la primera del mapa que alcance, con la segunda forma de pago si la tiene). Para juntar oro, el bot deja de comprar torres (después de las 2 primeras) hasta pagar lo que quiere. La tabla suma cinco columnas: oleada de la compra de la máquina, recursos obtenidos y sobrantes, oro invertido en infraestructura y oleada de la primera torre con recursos. El drop de los removibles usa la misma semilla (`GameFlow.forced_seed`).
- **`check_rule=1` (RF-432):** juega `sin_recursos` con 5 semillas en cada mapa con recursos y **termina con código 1** si algún mapa gana menos de 4. Sin `level`, `levels`, `file` ni `modo` mira toda la campaña y se salta los mapas sin recursos; con alguno de ellos comprueba ese mapa siempre. Ejemplo: `... -s tools/balance_sim.gd -- x check_rule=1 file=tools/ejemplos/mapa_extraccion.json` (código 0); con `hp=20` el mismo mapa da código 1. Lo corre cada tarea de nivel con recursos y la regresión final (T236).

Con más de dos modos propios, las solapas ya no entran en la fila (limitación conocida de esta primera prueba).

### T248 · Probar la barra con pestañas y la flecha al menú (M53)

Con el proyecto abierto (o `godot --path .`). **✅ Comprobar:**

- **Nivel 1 (o cualquiera del 1 al 5):** la barra de abajo es la de siempre (sin pestañas) y arriba a la izquierda hay una flecha **«← Menú»**, con los contadores a su derecha. `Tab` y `0` no hacen nada.
- **Nivel 7 («El aserradero», con demoledora):** a la izquierda de la barra hay dos pestañas, «Cañones» (activa) e «Infraestructura». Tocá **Infraestructura** (o apretá `Tab`): se ven tres tarjetas, *Trabajo en curso*, *Demoledora · 180 de oro* con su botón **Comprar**, y *Recursos*. Comprá la demoledora: dice «Demoledora activa» y «Cada demolición cuesta el 10 % y tarda el 80 %». Volvé a «Cañones», tocá un árbol del mapa (la pestaña **no** cambia, se abre su panel a la derecha) y **Demoler**: el título de la otra pestaña pasa a «Infraestructura · 3 s» y baja; en la pestaña se ve la barra de avance y **Cancelar** (devuelve todo el oro). Elegí una torre y apretá `Tab`: la construcción se cancela. Desde «Infraestructura», apretá `3`: vuelve a «Cañones» con la tercera elegida. En el **nivel 6** no hay tarjeta de demoledora (su archivo no la trae).
- **Nivel 10 («La mina vieja»):** «Infraestructura» muestra la **Mina** con su botón *Habilitar · 100 de oro* (y, ya habilitada, «Activa · reserva 8/8 · +2 por oleada»). Con el modo de pruebas y **Habilitar todas las colecciones** hay 11 torres: los botones se achican a 57 px, se lee el costo y la insignia verde del recurso, ninguno toca «Próxima oleada», y `0` elige la décima. El mapa se ve igual (con zoom) con o sin pestañas.
- **La flecha:** tocala. Aparece «¿Volver al menú principal?» con la partida en pausa y el foco en «Seguir jugando» (`Esc` hace lo mismo). Si recogiste una pieza de colección o hay una demolición en curso, el texto lo avisa. «Seguir jugando» deja todo como estaba (en pausa si ya lo estaba); «Salir al menú» vuelve al menú principal y **no guarda** la pieza. Al probar un mapa desde el editor, la flecha dice «← Editor» y vuelve sin preguntar. Con la partida terminada la flecha no se ve.
- **Con toques:** todo lo anterior se hace sin teclado. **No se probó en un celular real.**

Capturas y mediciones en `art/m53-barra/` (`README.md`).
