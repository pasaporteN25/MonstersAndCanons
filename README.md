<img width="1774" height="887" alt="image" src="https://github.com/user-attachments/assets/06cc1aed-e7d0-40fa-96c0-1aeb75d8dfb4" />


[![Tests](https://github.com/pasaporteN25/TDv1/actions/workflows/tests.yml/badge.svg)](https://github.com/pasaporteN25/TDv1/actions/workflows/tests.yml)

Juego *tower defense* 2D hecho en **Godot 4** con **GDScript**, construido con **SDD (Spec-Driven Development)**.

> **Estado actual:** M1 a M45 ✅ (nuevo logo Monsters & Canons, botones del menú de hierro y bronce, Normal, Rápido y Tanque con arte renderizado de una sola vista; campaña jugable y completa de **15 niveles** (el último trae al jefe **Coloso**, que al caer se parte en tres Pedazos, y termina en un **epílogo** y los créditos), 11 torres (una de 2×2: el Mortero) con arte renderizado de ocho vistas más el apoyo Mecánico, tres familias visuales y combos por estado, modo de pruebas con editor de mapas, mapas de la comunidad, Wiki con bestiario, mapas de tamaño variable con zoom, siete temas de paisaje y leyenda, récords, niveles en archivos de texto y versión para Linux). Lucas probó la APK en su celular (informado el 2026-10-07). Tests automáticos en GitHub (D-030).
>
> **Versión de Godot:** 4.7.2 estable (renderizador *Compatibility*).
>
> **¿Primera vez en esta computadora?** Empezar por [ONBOARDING.md](ONBOARDING.md).

---

## ¿Qué es un tower defense? (resumen de 20 segundos)

Unos enemigos aparecen en un punto del mapa y caminan por un **camino** hacia la salida. El jugador coloca **torres** al costado del camino, y las torres disparan solas a los enemigos que pasan cerca. Si un enemigo llega a la salida, el jugador pierde **vidas**. Al matar enemigos se gana **oro**, y con el oro se compran más torres. Los enemigos llegan en **oleadas**, cada una más difícil que la anterior. Si sobrevives a todas las oleadas, ganas.

---

## Cómo están organizados los documentos

La carpeta `specs/` contiene todo lo que define el juego. **Se leen en orden:**

| Archivo | Qué contiene | Cuándo lo consultas |
|---|---|---|
| [`00-constitucion.md`](specs/00-constitucion.md) | Reglas del proyecto que **no se rompen nunca**. | Cuando dudas sobre *cómo* hacer algo en general. |
| [`01-spec.md`](specs/01-spec.md) | **Qué** hace el juego: reglas, torres, enemigos, pantallas. Sin hablar de código. | Cuando dudas sobre *qué* debería pasar en el juego. |
| [`02-plan-tecnico.md`](specs/02-plan-tecnico.md) | **Cómo** se construye en Godot: carpetas, escenas, scripts, datos. | Cuando vas a programar. |
| [`03-tareas.md`](specs/03-tareas.md) | La lista de pasos pequeños, en orden, para construirlo. | Todos los días: es la lista de "qué hago ahora". |
| [`04-decisiones.md`](specs/04-decisiones.md) | Registro de cada decisión importante: qué se eligió, qué alternativas había y por qué. | Cuando alguien (o tú en 3 meses) pregunta "¿por qué se hizo así?". |
| [`05-guia-de-arte.md`](specs/05-guia-de-arte.md) | SVG existentes, paletas, temas y tres familias de torres PNG con ocho vistas (§7). | Antes de producir arte nuevo. |
| [`06-monsters-canons-3d.md`](specs/06-monsters-canons-3d.md) | Concepto y plan de la segunda entrega en 3D, más el relevamiento de lo que le falta a la V1. | Antes de cerrar la V1 y al arrancar el proyecto 3D. |

Fuera de `specs/`: [`CONTENIDO.md`](CONTENIDO.md) explica **cómo agregar enemigos, torres y niveles** (con todos los campos de los datos), y [`ONBOARDING.md`](ONBOARDING.md), cómo preparar una computadora para trabajar.

---

## El ciclo de trabajo SDD (cómo se usa esto día a día)

Cada vez que quieras **agregar o cambiar algo** en el juego, sigue estos pasos **en este orden**:

```
1. SPEC      ¿Cambia lo que hace el juego?   → edita 01-spec.md
2. PLAN      ¿Cambia cómo se construye?      → edita 02-plan-tecnico.md
3. TAREAS    Divídelo en pasos pequeños      → agrega tareas en 03-tareas.md
4. CÓDIGO    Implementa UNA tarea a la vez
5. VERIFICA  Comprueba el "criterio de aceptación" de la tarea
6. MARCA     Marca la tarea como hecha [x]
```

**La regla de oro:** si el código y la spec dicen cosas distintas, **uno de los dos está mal**. O se arregla el código o se actualiza la spec, pero nunca se dejan en desacuerdo.

**Ejemplo real:** quieres agregar una torre de fuego.
1. En `01-spec.md` agregas la torre a la tabla de torres, con su costo, daño y qué hace de especial (quema).
2. En `02-plan-tecnico.md` explicas cómo se programa el "quemar" (por ejemplo, un efecto que hace daño cada segundo).
3. En `03-tareas.md` agregas: "T-xx: efecto de quemadura", "T-yy: torre de fuego".
4. Programas T-xx, lo pruebas, lo marcas. Después T-yy.

---

## Glosario

Palabras que aparecen en todos los documentos:

| Término | Significado |
|---|---|
| **Casilla** (*tile*) | Un cuadrado de la cuadrícula del mapa. Mide 64×64 píxeles. Todas las distancias del juego se miden en casillas. |
| **Camino** (*path*) | La ruta fija por donde caminan los enemigos terrestres. No se puede construir encima. |
| **Oleada** (*wave*) | Un grupo de enemigos que salen uno tras otro. Un nivel tiene varias oleadas. |
| **Alcance** (*range*) | Distancia (en casillas) hasta la que una torre puede disparar. |
| **Cadencia** (*fire rate*) | Cuántos disparos por segundo hace una torre. |
| **DPS** | Daño por segundo = daño × cadencia. Sirve para comparar torres. |
| **Daño en área** (*splash*) | Un disparo que daña a todos los enemigos dentro de un radio, no solo a uno. |
| **Armadura** | Número que se resta a cada golpe que recibe un enemigo. |
| **MVP** | *Minimum Viable Product*: la versión más pequeña que ya es un juego completo. |
| **Hito** (*milestone*) | Un grupo de tareas que, al terminarse, deja el juego en un estado jugable y con algo nuevo. |
| **Escena** (Godot) | Un "bloque" reutilizable del juego (una torre, un enemigo, el menú). Se guarda como archivo `.tscn`. |
| **Nodo** (Godot) | Cada pieza dentro de una escena (un sprite, un temporizador, un área de colisión…). |
| **Resource** (Godot) | Un archivo de datos (`.tres`) que se edita desde el editor de Godot. Aquí se guardan los números de balance. |
| **Señal** (Godot) | Un aviso que un nodo emite ("¡morí!") y que otros nodos pueden escuchar. |
| **Autoload** (Godot) | Un script que existe siempre, en todas las escenas (como un "global"). |

---

## Requisitos para trabajar

Todo lo que hay que instalar y configurar (Git, Godot, tests, exportar a Windows y a Android), paso a paso y con cómo comprobar cada paso, está en **[ONBOARDING.md](ONBOARDING.md)**.

---

## Cómo exportar el juego (`.exe` para Windows)

Requiere las plantillas de exportación de Godot 4.7.2 (en el editor: *Editor → Administrar plantillas de exportación → Descargar e instalar*; se hace una sola vez).

```bash
godot --headless --path . --export-release "Windows Desktop" build/MonstersCanons.exe
```

- El resultado es **un solo archivo** (`build/MonstersCanons.exe`, ~160 MB con las láminas de la intro: casi todo es el motor de Godot). Se puede copiar a cualquier carpeta o computadora con Windows y jugar sin instalar nada.
- La configuración está en `export_presets.cfg`: deja fuera `tests/`, `tools/`, `specs/` y GUT.
- La carpeta `build/` no se sube a git.
- El progreso se guarda en `%APPDATA%\Godot\app_userdata\JuegoA\save.json`.

### Versión para GNU/Linux

```bash
godot --headless --path . --export-release "Linux" build/MonstersCanons.x86_64
tar --mode=755 -czf build/MonstersCanons_linux.tar.gz -C build MonstersCanons.x86_64
```

- Es **un solo archivo** (`MonstersCanons.x86_64`, ~127 MB, para procesadores de 64 bits Intel/AMD) con los datos adentro, igual que el `.exe`. Usa las mismas plantillas de exportación de Godot 4.7.2 (las de Linux vienen con las de Windows).
- Un archivo copiado desde Windows **pierde el permiso de ejecución**. Por eso también se arma el `.tar.gz`, que lo conserva: en Linux, `tar -xzf MonstersCanons_linux.tar.gz` y `./MonstersCanons.x86_64`. Si se copió el archivo suelto: `chmod +x MonstersCanons.x86_64`.
- Necesita una computadora con escritorio (X11 o Wayland) y OpenGL. El progreso se guarda en `~/.local/share/godot/app_userdata/JuegoA/save.json`.
- **Todavía no se probó en una computadora Linux real**: los tests sí corren en Linux en cada push (GitHub, D-030), pero el ejecutable no se abrió.

### El modo de pruebas (desde Opciones)

Para probar todo sin ganar cada nivel (spec §10.2, D-028, D-077). Desde M48 **no hay un ejecutable aparte**: es el mismo `MonstersCanons.exe`, `MonstersCanons.x86_64` o `MonstersCanons.apk`.

- **Cómo se activa:** menú principal → **Opciones** → **Administración** → **Activar modo de pruebas** → **Sí, activar**. Para salir: Opciones → **Volver al juego normal**. Desde el menú de pausa no aparece, para no cambiar de guardado en medio de una partida.
- **Siempre arranca normal:** si se cierra el juego en modo de pruebas, la próxima vez abre con el progreso real.
- **Qué trae:**
  - Todos los niveles abiertos.
  - Al elegir nivel se puede **empezar en cualquier oleada**, con el oro que se habría juntado o el que se escriba.
  - En la partida, el **panel de pruebas** (`F1` o el botón "Pruebas"): +1000 de oro, vidas infinitas, saltar oleada, matar a todos, ganar, perder, **cinco velocidades (x0,25 a x4)**, hacer aparecer cualquier enemigo y ver los FPS.
  - Atajos: `F2` matar, `F3` saltar oleada, `F4` vidas infinitas, `F6` / `F7` velocidad.
  - Al terminar guarda un informe en `user://pruebas_stats.json`.
- Usa **otro guardado** (`save_pruebas.json`, en la misma carpeta): lo que hagas ahí no toca tu progreso, tus estrellas ni tus récords reales.
- Abajo al centro siempre dice "MODO PRUEBAS", para no confundirlo con el juego normal.
- **Editor de mapas:** el menú principal trae el botón "Editor de mapas" para todos en PC. En el celular solo aparece con el modo de pruebas activo, porque se maneja con mouse y teclado. Se dibuja el mapa con el mouse, se arman las oleadas, se prueba el nivel al instante y se guarda en `%APPDATA%\Godot\app_userdata\JuegoA\maps`. Ver [`CONTENIDO.md`](CONTENIDO.md).
- **Para arrancar directo en modo de pruebas** (desarrollo):
  - Desde el editor de Godot: *Proyecto → Configuración del proyecto → Editor → Run → Main Run Args* = `-- --pruebas`.
  - Desde un acceso directo: `MonstersCanons.exe -- --pruebas`.

## Licencia

*Monsters & Canons* es **software libre** y se regala: código, datos, dibujos y sonidos propios se distribuyen bajo la **GNU General Public License, versión 3 o posterior** (GPL-3.0-or-later). El texto completo está en [`LICENSE`](LICENSE) (D-077, RF-387).

- **Qué permite:** usarlo, copiarlo, compartirlo y modificarlo. Quien reparta una versión modificada tiene que hacerlo con la misma licencia y ofrecer su código fuente.
- **Ojo al publicar:** quien reparte ejecutables bajo la GPL tiene que ofrecer también el código fuente. Hoy el repositorio de GitHub es privado, así que antes de subir el juego a itch.io o a Play Store hay que hacerlo público o adjuntar el código.
- **Terceros:**
  - El motor **Godot** es MIT; su aviso de copyright tiene que acompañar a los ejecutables, y por eso está en la Wiki del juego (Guía → Licencias).
  - **GUT** (`addons/gut/`, MIT) solo se usa para los tests y no va dentro de los ejecutables.

## Paisajes de mapa

Un nivel puede elegir su **tema** (pradera, desierto, nieve, volcán, bosque, pantano o ruinas) y declarar una **leyenda** con letras nuevas (lago, hielo, lava, flores, cactus…). Hay un mapa de ejemplo por tema en `tools/ejemplos/`. Cómo se escriben: [`CONTENIDO.md`](CONTENIDO.md).

## Wiki

El botón **Wiki** del menú principal abre una enciclopedia: **Enemigos** (un bestiario: cada uno aparece como "???" hasta que lo ves en una partida; en la versión de pruebas se ve todo) y **Torres** (con sus números reales, la tabla de niveles y dónde aparece cada enemigo) una **Guía** con las reglas y **Lore** (la historia de Cántaro y la colonia: cada artículo se abre al ganar un nivel de la campaña). Un enemigo o una torre nuevos aparecen solos; los artículos de la guía son archivos de texto en `data/wiki/`. Cómo escribirlos: [`CONTENIDO.md`](CONTENIDO.md).

## Mapas de la comunidad

En **Jugar → "Mapas de la comunidad"** aparecen todos los archivos `.json` que haya en la carpeta de mapas (en Windows, `%APPDATA%\Godot\app_userdata\JuegoA\maps`; el botón "Abrir carpeta de mapas" la abre). Sirve para jugar mapas que te pasó otra persona o los que hacés con el editor de mapas. Cada mapa tiene su propio progreso y su top 5, y no toca la campaña. Cómo instalar, compartir y qué límites tienen: [`CONTENIDO.md`](CONTENIDO.md).

## Modos de juego

En **Jugar** hay una solapa por modo (M49):
- **Modos oficiales**, después de "Campaña". Hoy está **Asedio**: los 15 mapas de la campaña con monstruos más duros (vida de 101 % a 118 % según el mapa, 115 % de base). Cada mapa se abre al ganar el anterior.
- **Modos propios**, después de "Mapas de la comunidad". Todos sus mapas están abiertos.

Cada modo tiene su progreso, sus estrellas y su top 5. No toca la campaña, el Salón de la fama ni los avances.

Un modo propio se arma desde el editor con **"En un modo…"** (crea el modo o elige uno existente), o a mano con un `modo.json` en `%APPDATA%\Godot\app_userdata\JuegoA\modos\<nombre>`. El formato está en [`CONTENIDO.md`](CONTENIDO.md).

## Dibujos y arte del juego

Los dibujos del juego son archivos **SVG** en `assets/sprites/` (decisión D-023, spec §9.6). B-02 fue cerrado por Lucas el2026-10-03: las mejoras visuales específicas se registran por separado. Los SVG originales conviven con los atlas PNG y materiales incorporados en M23–M36; el arte actual no espera una renovación general.

| Carpeta | Qué hay | Cómo están dibujados |
|---|---|---|
| `towers/` | `base_1.svg`, `base_2.svg`, `base_3.svg` (una base por nivel de torre) y `turret_<torre>.svg` | Desde arriba. La torreta mira a la **derecha** y gira sobre el **centro** de la imagen. |
| `enemies/` | Un archivo por enemigo (`normal.svg`, `boss.svg`…) | De costado, mirando a la **derecha**. El juego los da vuelta cuando caminan hacia la izquierda. |
| `projectiles/` | Un proyectil por torre | Mirando a la derecha. Son de 32×32; el resto, de 64×64. |
| `map/` | Rocas, árbol, arbusto y la puerta de salida | Ocupan una casilla. |

**Para cambiar un dibujo:**

1. Abrir el `.svg` en **Inkscape** (gratis), Figma o Illustrator, editarlo y guardarlo con el **mismo nombre**. También sirve una imagen PNG de 128×128: en ese caso hay que elegirla en el Inspector, en el `.tres` de la torre o del enemigo (carpeta `data/`).
2. Abrir el proyecto en Godot: el editor vuelve a importar el archivo solo.
3. Los SVG **nuevos** se importan solos al doble y con *mipmaps* (`[importer_defaults]` en `project.godot`): no hay que tocar el panel Importar. Para agregar un enemigo o una torre nuevos, ver [`CONTENIDO.md`](CONTENIDO.md).

Si a una torre o a un enemigo le falta el dibujo, el juego usa la forma geométrica de antes (RF-156): nunca se rompe por un archivo que falta.

## Tests automáticos en GitHub

Cada vez que se sube algo a `main` (o se abre un *pull request*), GitHub corre **todos los tests solo** (decisión D-030, [`.github/workflows/tests.yml`](.github/workflows/tests.yml)):

1. Baja Godot 4.7.2 para Linux (la primera vez; después queda guardado).
2. Importa el proyecto desde cero, como una computadora nueva.
3. Revisa que compilen las herramientas de `tools/`.
4. Corre los tests de GUT.

**Cómo ver el resultado:** en GitHub, al lado de cada commit aparece ✅ (todo bien), ❌ (algo se rompió) o 🟡 (todavía corriendo). La pestaña **Actions** del repositorio muestra el detalle de cada corrida; si falla, el paso "Correr los tests" dice qué test y por qué. También se puede correr a mano: *Actions → Tests → Run workflow*. Si una corrida falla, GitHub avisa por mail.

## Herramientas

| Comando | Para qué |
|---|---|
| `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` | Correr todos los tests. |
| `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart level=1` | Bot que juega solo para revisar el balance (ver spec §7.1). |
| `godot --path . -s tools/perf_test.gd` | Prueba de rendimiento con 200 enemigos y 60 torres. |
| `godot --path . res://tools/perf_levels.tscn -- level=15 from=27` | Rendimiento en un nivel real (T236): defensa completa y las oleadas finales a velocidad 1, con FPS por oleada. Abre una ventana. |
| `godot --headless --path . -s tools/make_sounds.gd` | Volver a generar los sonidos (`-- shot_fire` = solo ese). |
| `godot --headless --path . -s tools/check_level.gd -- data/levels/level_06.json` | Revisar un nivel sin jugarlo: sus errores, o el mapa con el recorrido de cada entrada. Sin archivo, revisa todos los de la campaña. Cómo hacer un nivel: [`CONTENIDO.md`](CONTENIDO.md). |
| `godot --headless --path . -s tools/make_icon.gd` | Volver a generar el ícono del juego con los dibujos. |

## Fondos M26
Los siete temas, el camino y las rocas, árbol, arbusto y puerta usan los nuevos PNG renderizados. Se aplican en partida, menú y editor; rutas y casillas construibles conservan sus reglas. Recursos en `assets/tiles/rendered/` y `assets/sprites/map/rendered/`.

### Arte M27 en revisión
Propuestas de niveles2/3 de las nueve torres (ocho vistas por nivel) y cinco monstruos especiales en `art/redesign-m27/`. Incluye atlas, iconos, muestras en Godot, fuentes y guía de integración; todavía no cambia los recursos que usa la partida.

### M27 aplicado a la partida
Las nueve torres usan mecanismos nuevos en niveles 2 y 3. Guardián, Curandero, Chamán, Espejo y Jefe usan sus PNG renderizados estáticos. Se conservan balance, habilidades y nivel 1 de las torres. Capturas en `art/m27-integracion/`.

### Presentación M29
Los trece monstruos renderizados tienen un aumento visual del20% en partida. Diablillo, Bestia y Tanque usan pasos por distancia en cuatro direcciones; Volador, cuatro poses de aleteo. Los otros nueve conservan una pose sin deformaciones globales. Las nueve torres usan el encastre C con bases fijas y el cañón tiene24 vistas nuevas. Windows/Linux abren una ventana objetivo1920×1080, limitada al área útil del monitor, conservando el lienzo lógico1280×720; pantalla completa utiliza el monitor. Móvil conserva su presentación. Capturas y reproducción en `art/redesign-m29/README.md`.

### Reflejos M30
Las mejoras de las nueve torres tienen reflejos programáticos por nivel y familia; siguen pose/retroceso, se congelan en pausa y se apagan al aturdir. Sombras intactas. Captura: `art/redesign-m30/torres_full_hd.png`.

### Animaciones M31
Los trece enemigos ya tienen movimiento propio: doce ciclos de caminar con cuatro poses por dirección y el aleteo del Volador. Los nueve ciclos restantes están conectados a los recursos de partida, sin cambiar habilidades ni balance. Fuentes, empaquetador, manifest y muestra animada: `art/redesign-m31/`.

### Interfaz M32
HUD compacto con ayudas; barra, pausa y administración con estilo hierro/bronce. En Pruebas, Mostrar FPS activa un texto independiente sin fondo con FPS y ms/cuadro estimados.

### Submenús M33
Opciones, niveles/comunidad, Wiki, récords, final, iniciales/Salón y editor/diálogos comparten el tema local hierro-bronce. B-19 completado; controles y datos conservados.

### Android M34
Presets normal y pruebas con paquetes separados; APK arm64 de instalación local en `build/JuegoA_PR1_normal.apk` y `build/JuegoA_PR1_pruebas.apk`. Firma de depuración, contenido del PR#1. Android7+, sin prueba en dispositivo. **Reemplazado en T196:** hoy hay una sola APK (`build/JuegoA.apk`) y el modo de pruebas se activa en Opciones (D-077).

### Panel de torre M35
Información agrupada con hierro/bronce: daño, cadencia y alcance arriba; descripción, efectos y sinergias desplazables; apuntado, Mejorar y Vender siempre accesibles. Estado de aturdimiento separado y foco visible. Capturas en `art/redesign-m35/`.

### M36 · Efectos, niveles y audio
Torres con placa/remaches de nivel integrados en la base. Rebote con trayectoria visible; aturdimiento y recuperación localizados. Cura efectiva con pulso orgánico y aura de alcance separada; muertes con pose real desintegrada y fragmentos facetados. Música de menú/combate y mezcla con avisos separados y limitador. Ver muestras e investigaciones B-21/22/23 en `art/redesign-m36/README.md`.

### M37 · Primera etapa: avances y Estandarte
Una pieza tecnológica por nivel1–5, cinco distintas desbloquean el apoyo mecánico en niveles que lo permiten desde6. Rejugar recupera fuentes pendientes; completar la oleada confirma el drop y victoria/derrota lo guarda, abandonar no. Admin puede habilitar estandartes sin colección. Ladrón, Embestidor, reparación y niveles8–15 permanecen en etapas posteriores.

### M38
Avances tecnológicos integrados en la barra superior con icono/valor; estado de la partida en la ayuda del icono. Rama de este desarrollo: feature/avances-estandarte.

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

### M44 · Balance6/7 y cierre de reparación

T191 agrega un laboratorio con compra temprana/tardía del Mecánico, ubicación, mejoras, semillas global/spawner y presión de especiales. Evidencia y límites: [art/balance-m44/README.md](art/balance-m44/README.md). Corrige residuos de desgaste que dejaban la reparación encendida;949/949 pruebas. Los dos EXE y dos APK locales se regeneraron con la corrección. Niveles1–5 intactos; balance definitivo humano pendiente.

Resultado M44:38 corridas más repetición idéntica. En7, el perfil de apoyo tardío agrupado con mejoras conserva18–19 vidas frente a7–10 sin apoyo, en tres semillas. Se mantienen costos y frecuencia oficiales6/7; mayor frecuencia cambia también economía/compras y no prueba dificultad de forma aislada. El diseño8/9 y la prueba humana continúan aparte; B22 permanece abierto.

### M45 · Campaña8/9

Bastión (18 oleadas, una entrada) presenta Guardián y eleva robo/desgaste. Taller asediado (20 oleadas, dos entradas) introduce Curandero y combina auras con esos encuentros. Mecánico permitido con colección5/5. Los guardados que ya ganaron7 permiten abrir8 sin rejugar; las consultas no escriben progreso. Pruebas y evidencia en art/campaign-m45; balance humano pendiente. No se regeneraron APK/EXE por instrucción de Lucas.

Validación M45:954/954 pruebas y62/62 finales de contenido.24 corridas más repetición idéntica, encuentros oficiales que causan/reparan40 puntos y capturas revisadas.8 conserva margen;9 gana con defensa variada en tres semillas y exige priorizar auras/cobertura. Las políticas del bot pueden perder, y no sustituyen juego humano. Paquetes anteriores y niveles1–7 verificados por hash sin cambios.

### T193 · Estudio de vista B-21 v2

- Cuatro vistas de la misma partida: la actual, relieve en la misma cuadrícula, oblicua al 80 % y maqueta 3D. Cada una tiene fotos, medidas de casillas y clics, y rendimiento, y además se puede jugar entera con `godot --path . res://art/b21-vista/vista_lab.tscn -- jugar variante=C` (letras A a D).
- Recomendación: no cambiar la proyección. Si se quiere más profundidad, relieve horneado por etapas. Informe completo en `art/b21-vista/B21-vista-v2.md`. No cambia el juego; la decisión es de Lucas.

### T194 · Monsters & Canons 3D

- El 3D no se integra en esta versión: pasa a una segunda entrega, *Monsters & Canons 3D*, que arranca después de cerrar lo pendiente de la V1. Concepto, evidencia, plan y relevamiento de la V1 en `specs/06-monsters-canons-3d.md`.
- Prueba de cámara libre sobre la maqueta: `godot --path . res://art/b21-vista/vista_lab.tscn -- camara`. No cambia el juego.

### T197 · Modos de juego

- Solapa **Asedio** en Jugar: los 15 mapas de la campaña con monstruos más duros (dureza propia por mapa, T258) y progreso propio.
- Modos propios: desde el editor con "En un modo…", o con un `modo.json` (ver `CONTENIDO.md`).
- El bot de balance acepta `modo=asedio`, `mejoras=llenar|temprana` y `perfil=asedio` (T258).

### T225 · Nivel 10: La mina vieja

Cierra el bloque 2 con un mapa grande (24 × 11) del desierto, dos entradas y 20 oleadas con los enemigos de los niveles 6 a 9 (sin debuts). Tiene una **mina** de reserva finita (100 de oro, 2 recursos por oleada, 8 en total), seis removibles que pueden dar 1 recurso, la **pieza 3/3 de la Disruptora** y el Mortero. Es un mapa de **espacio limitado** (43 casillas libres): el bot sin recursos lo gana con 7 a 13 vidas y las estrategias de extracción y de demolición lo ganan con 17 y 18. La ficha completa está en `specs/01-spec.md` §7.12 (RF-453) y la evidencia, en `art/campaign-t225/README.md`.

### T253 · La Cuadrilla: el Ratero y el Cargador

Dos enemigos nuevos que **roban en banda**: el **Ratero** (chico y veloz, 2 de oro cada 2 s) y el **Cargador** (grande y lento, 4 de oro cada 2 s), cada uno en su propio reloj y sin bajar la caja de 10 de oro. Debutan en el **nivel 7** (oleada 8) y vuelven en el **10**, el **13** y el **14**, cuatro veces por nivel, sin auras ni jefe en esas oleadas. Todo con datos que ya existían; arte provisional (forma geométrica) hasta T257. Hay un artículo nuevo de Lore, **«La Cuadrilla»**, que se abre al ganar el 7. Spec: `specs/01-spec.md` M55 (RF-485 a RF-491), decisión D-094; medición en el Resultado de T253 (`specs/03-tareas.md`).

### T242 · La intro de láminas

Al tocar «Jugar» por primera vez (guardado sin la marca `"intro_seen": true`, fuera del modo de pruebas) se abre una **intro de siete láminas** con el texto abajo, un fundido y avance por toque, teclas o tiempo; «Omitir», `Esc` y el «atrás» de Android la terminan. Al terminar va al **nivel 1** (sin niveles ganados) o a la **selección** (con niveles ganados); se vuelve a ver desde **Wiki → Lore → «Ver la intro»**. Los datos están en `data/intro/intro.json` (`IntroData`, `IntroFlow`, `scenes/ui/intro_screen.gd`). Las láminas de `assets/intro/` son las **definitivas** de T241 (aprobadas el 2026-10-11; son WebP y pesan unos 4 MiB dentro del juego, D-150). Son `.webp` sin pérdida que Godot comprime a calidad 0,90 al importar (D-150). `tools/capture_intro.tscn` las captura con ventana y `tools/check_intro_pack.tscn` comprueba que cargan (ver T242 en `specs/03-tareas.md`). Ficha: `specs/01-spec.md` M57 (RF-497 a RF-501), D-096 y `specs/intro/guion.md`.

### T234 · Nivel 15: La Central, el Coloso y el epílogo

Cierra la campaña: un mapa de pradera de 26 × 12 con **tres entradas**, la **central de energía** (cuatro dibujos de 64 × 64 junto a la salida) y la cadena de abastecimiento, y **30 oleadas** sin el Soberano. El jefe es el **Coloso** (oleadas 26, 28 y 30), que al caer se parte en tres Pedazos; en la 30 viene con la escolta completa. Al ganar, la pantalla de victoria ofrece **«Epílogo»** (imagen, cuatro líneas, «Créditos» y «Niveles») en lugar de «Siguiente nivel», sin guardar nada nuevo. Ficha: `specs/01-spec.md` §7.17 (RF-480 a RF-484, RF-471 y RF-472); evidencia: `art/campaign-t234/README.md`.

### T232 · Nivel 14: Los poblados vacíos

Un mapa de ruinas de 26 × 12 con **dos entradas** que se unen (el 13 espejado), las **señales que culminan** (campamentos vacíos, el símbolo A por todas partes y columnas) y 26 oleadas con **todas las amenazas juntas**, sin enemigos nuevos: es el examen antes del final. El bot sin recursos lo gana con 3 vidas (el 13: 6). Ficha: `specs/01-spec.md` §7.16 (RF-479); evidencia: `art/campaign-t229/README.md`.

### T231 · Nivel 13: Paso alto

Un paso de nieve de 26 × 12 con **dos entradas** que se unen, una laguna de hielo, una mina y un bosque (uno por entrada) y 24 oleadas **sin enemigos nuevos**: lo nuevo es **la escolta** (Guardián + Curandero + Chamán que salen juntos, primero por una entrada y desde la oleada 14 por las dos). El bot sin recursos lo gana con 6 vidas. Ficha: `specs/01-spec.md` §7.15 (RF-478); evidencia: `art/campaign-t229/README.md`.

### T230 · Nivel 12: El cañadón

Un cañadón de 26 × 11 del desierto con **una entrada** y un zigzag entre paredes, un **bosque explotable** en lugar de la mina y 24 oleadas. **Debuta el Espejo** (devuelve los tiros de las torres cercanas y las aturde), solo, en la oleada 5; desde la 12 viaja con las auras y el Chamán. El bot sin recursos lo gana con 3 a 5 vidas (el 11: 6). Ficha: `specs/01-spec.md` §7.14 (RF-477); evidencia: `art/campaign-t229/README.md`.

### T229 · Nivel 11: Puesto seco

Abre el bloque 3 con un mapa grande (24 × 11) del desierto, **una entrada**, 22 oleadas, dos pozos, una mina y cinco removibles. **Ya no hay Ametralladora** (rotación de torres, RF-474), se ofrece la **Disruptora** (con su colección) y **debuta el Chamán**, solo, en la oleada 5. El bot sin recursos lo gana con 6 vidas (el nivel 10: 7 a 13); con la Disruptora el bot **pierde** (la tabla está para que Lucas decida). La ficha completa está en `specs/01-spec.md` §7.13 (RF-476) y la evidencia, en `art/campaign-t229/README.md`.

### T366 y T368 · La entrada de los jefes (M66, arte provisional)

Cuando llega el **Jefe del nivel 1** (oleada 10, jugado desde el menú, o con el modo de pruebas y F1), sale un **destello con una grieta** en la entrada del camino, en el instante en que nace, y, al irse el cartel de «Oleada N», un **cartel arriba del mapa** (720 × 120 como máximo) con su retrato, «¡Llega el Jefe!», su nombre y su frase: dura **1,6 s** y se saltea con un toque o clic. **No pausa la partida, no mueve la cámara y no cambia al Jefe**; un jefe **no lleva** la tarjeta «Nuevo enemigo» (T456): el cartel y la línea «¡Llega el Jefe!» alcanzan. Se prende y se apaga en **Opciones → «Entrada de los jefes»**.

Es **un dato del enemigo** (`EnemyData.entrance`, `BossEntranceData`: `levels`, `line`, `sound`): sumar otro jefe no necesita código (ver `CONTENIDO.md`). Los números están en `data/ui/entrada_jefes.json` (`BossEntranceConfig`); las reglas, en `BossEntranceRules` (`scripts/logic/`); el destello es `BossEntranceBurst` (`scenes/effects/`, atlas aprobado de T367), el cartel `BossEntranceCard` (`scenes/ui/`) y la cola con el cartel de oleada y la tarjeta vive en `Hud`. `godot --headless --path . -s tools/check_entrada_jefes.gd` revisa los datos; `res://tools/capture_boss_entrance.tscn` saca capturas; `tools/perf_test.gd -- entrada_jefe` mide con 200 enemigos. Spec: `specs/01-spec.md` M66 (RF-597 a RF-602), D-138 a D-140. El arte aprobado de T367 ya está integrado (M71): destello, grieta y marco 9-slice. No se probó en un celular real.

### T330 y T331 · El tutorial del nivel 1 (M63)

Al entrar al **nivel 1 desde el menú** (guardado sin la marca `"tutorial_done"` y con la opción prendida, fuera del modo de pruebas) aparece una **tarjeta** con un texto corto y un **recuadro con flecha** sobre el control o la casilla del paso: camino, oro, vidas, elegir y construir una torre, empezar la oleada, elegir la torre construida, «Mejorar», «Vender», velocidad y pausa. Los pasos de acción **esperan la acción real** del jugador; los de lectura, «Siguiente»; «Saltar tutorial» está siempre; la partida **no se pausa**. En el **modo celular** los pasos son otros (carrito, catálogo, fantasma, tilde y doble toque). Se activa, se apaga y se vuelve a ver en **Opciones** («Tutorial del nivel 1» y «Volver a verlo»).

Los pasos y los textos están en `data/tutorial/tutorial.json` (`TutorialData` los valida; los textos son **borrador** hasta el OK de Lucas). La lógica es `TutorialFlow` y `TutorialLayout` (`scripts/logic/`); la escena, `TutorialOverlay` (`scenes/ui/`) y `TutorialController` (`scenes/game/`). `godot --headless --path . -s tools/check_tutorial.gd` revisa el archivo y `res://tools/capture_tutorial.tscn` saca una captura por paso. Ficha: `specs/01-spec.md` M63 (RF-570 a RF-578), D-125 a D-128. **No se probó en un celular real.**

### T340 y T341 · Pantalla de carga general (M64)

Todo cambio de pantalla (nivel, menú, «Reintentar», «Siguiente nivel», modos, comunidad, editor…) muestra una **pantalla de carga** con el texto «Cargando…» y una barra, carga la escena en un hilo y **bloquea toda la entrada** (toque, mouse, teclas y «atrás» de Android) hasta que la pantalla nueva está lista. Esto corrige el defecto reportado en el celular: un toque de más durante la carga lanzaba el nivel que quedaba debajo del dedo. Mientras hay un cambio en curso, ninguna función de `GameFlow` que cambia de pantalla hace nada.

La pieza es `SceneTransition` (`scripts/logic/scene_transition.gd`), un **núcleo genérico sin referencias al juego** (se puede copiar a otro proyecto); `GameFlow` es la capa fina que la conecta (`GameFlow.transition`, `is_changing()`, `reload_current()`). Un borrador de skill para reutilizarla está en `docs/skills-borrador/godot-pantalla-de-carga/SKILL.md` (no está instalado en ningún lado). Tests: `tests/test_scene_transition.gd` y `tests/test_loading_flow.gd`. Ficha: `specs/01-spec.md` M64 (RF-580 a RF-589), D-130 a D-134. **No se probó en un celular real ni se midió el tiempo de carga allí.**
### T361 y T363 · Animación de mejora de torres (M65)

Al mejorar una torre (`BuildController.try_upgrade` → `tower_upgraded`), `Game._on_tower_upgraded` llama a `EffectsLayer.tower_upgraded`: un efecto (`UpgradeEffect`, un nodo con un `Tween`, **sin `_process`**) de 0,5 s al nivel 2 o de 0,7 s al máximo, teñido con `TowerVisual.upgrade_glow_color`, y hasta tres `FloatingText` (cabecera «¡Nivel N!» y dos renglones de hasta dos estadísticas) escalonados 0,12 s. **Es solo presentación**: no toca la torre, el oro ni el balance. Con la opción **«Animaciones de mejora»** apagada (`settings."upgrade_fx"`, prendida por omisión, clave aditiva) todo queda como antes: el anillo de construir y el sonido. Tope de 8 efectos vivos (el texto, 4) y una torre no acumula.

Los números viven en `data/ui/mejoras.json` (duraciones, escala, tamaños de letra, topes y la tabla de estadísticas: campo de `TowerLevelData`, etiqueta y formato). `UpgradeFxConfig` lo lee y avisa en castellano qué está mal; `tools/check_mejoras.gd` lo revisa. La lógica pura es `UpgradeDeltas` (`scripts/logic/`: deltas, formato `+0,5`, renglones y `place_block`, que corre el texto dentro del mapa y fuera de las zonas que da `MobileHud.forbidden_rects()` y la barra de abajo de PC). El efecto usa los atlas aprobados de T362 (M71), con ocho cuadros por variante, teñidos con el color de la torre y sin mipmaps. Los atlas de mejora y del destello se importan a media resolución con tamaño visual compensado (RF-643). Tests: `-gtest=res://tests/test_upgrade_deltas.gd` y `test_upgrade_fx.gd` (partida real en PC y en modo celular 1280 × 720). Capturas: `godot --path . res://tools/capture_upgrade.tscn -- /ruta/de/salida 1280x720`.
### T371 y T373 · «Novedades de esta versión» (M67)

Al abrir el menú principal sale **una pantalla con lo nuevo de la versión instalada** (`config/version`), **una sola vez por versión**: el guardado suma la clave `"news_version"` (texto, aditiva; sin ella, o si no es texto, se lee como vacía, así que todo guardado viejo ve la primera). **No sale** con la versión `beta`, mientras la entrada sea **borrador**, en el modo de pruebas, desde el editor de Godot ni con el archivo roto (el menú abre normal y la salida dice qué falla). Se marca **al abrirse**. En **Opciones → «Créditos y versión»** el botón **«Novedades de esta versión»** la vuelve a abrir (la de la versión o la más nueva del archivo; con el rótulo «Borrador» si lo es) sin tocar el guardado.

Los textos están en `data/novedades/novedades.json` (`NewsData` los valida; la 1.0.0 está cargada como **borrador** hasta el OK de Lucas). La lógica es `NewsData` y `NewsFlow` (`scripts/logic/`); la escena, `NewsScreen` (`scenes/ui/`), enganchada en `MainMenu` y `OptionsMenu`. `godot --headless --path . -s tools/check_novedades.gd` revisa el archivo y avisa si la versión de `project.godot` no tiene una entrada aprobada, y `res://tools/capture_news.tscn` saca capturas en PC y celular. Ficha: `specs/01-spec.md` M67 (RF-603 a RF-609), D-141 a D-144. T375 integra la cabecera y los siete medallones aprobados en `assets/ui/novedades/`: 48 px en PC y 64 px en celular, sin mipmaps. La cabecera conserva su proporción y los textos quedan debajo sobre el panel oscuro. Los ítems sin ícono conservan el rombo de bronce. La banda sobria y el medallón de mejora quedan disponibles para entradas futuras. **No se probó en un celular real.**

### T420 a T422 · Consejo en la pantalla de derrota (M70)

Al perder aparece un **consejo de torre**, en una o dos líneas debajo de «Llegaste a la oleada N de M». `LeakLog` registra los enemigos que llegaron a la salida y las vidas que quitaron. `DefeatAdvice` combina eso con la oleada final y las reglas de `data/consejos/consejos.json`, calculadas contra los datos reales del catálogo. Solo recomienda torres ofrecidas por el nivel; sin datos suficientes, no inventa consejo. Los textos siguen en **borrador**. No cambia el balance ni el guardado. Spec: M70, RF-630 a RF-639 (RF-634 retirado), D-171 a D-175.

**Medición con el bot:** [informe T422](specs/tareas/informes/T422-consejo-derrota.md). El ensayo de una torre no demostró utilidad del consejo (0/7 coincide con la mejor torre sola); no reemplaza las partidas humanas.

### M58 · Interfaz para el celular (spec; sin programar)

Lucas especificó (G7, 2026-10-16) un **modo de interfaz para el celular**: un **carrito** flotante que abre el catálogo de torres sobre el mapa, una **X** flotante para salir al menú (los dos se arrastran y se pegan al borde izquierdo o derecho, y la posición se guarda), la barra de arriba solo con oro, vidas, oleada, recursos, Pausa y x2, la barra de abajo convertida en **barra de la torre elegida**, colocar con **torre fantasma con tilde y cruz**, **zoom** con pinza (rueda y botón central en PC) y **tarjetas de nivel con Insignias** (PC y celular). **La PC queda igual** y un selector «Interfaz» en Opciones permite probar el modo celular sin celular. Está en `specs/01-spec.md` (M58, RF-502 a RF-515), `specs/04-decisiones.md` (D-097, D-098) y `specs/02-plan-tecnico.md`; las tareas son T270 a T277 de `specs/03-tareas.md`. **Todavía no está en el juego** y la spec espera el OK de Lucas. Las estatuas de los mapas pasan a ser estatuas de torres de piedra (regla en `specs/05-guia-de-arte.md` §9). **M60 (2026-10-19, RF-540 a RF-545, D-110 a D-113; solo celular salvo lo que se diga):** el catálogo es una sola lista con las torres del nivel (abre siempre en las torres); un **tercer botón flotante** (un pico) demuele y habilita, con su estado y su cruz en la barra de abajo; la partida se **pausa sola al pasar la app a segundo plano** (la PC no); y «Ver todo» aparece también cuando el mapa se corrió con el zoom mínimo (en PC, con el botón central, solo en ese caso).

### M61 · Menús del celular, mouse y toque a la vez, y versión (T310 a T315)

En el modo celular los menús tienen **distribución propia**: el menú principal en dos columnas, Opciones en dos columnas con el título y «Volver» a la vista, botones de 56 px y listas (niveles, Wiki, Créditos) que se **desplazan con un dedo con inercia**. La entrada se decide **por dispositivo**: en el modo celular un mouse real hace de dedo también en Android, y el clic que el sistema fabrica a partir de un toque se descarta. Opciones suma **«Créditos y versión»**: hoy dice **«Beta»**, y la versión se cambia solo en `config/version` de `project.godot`. La PC no cambia (salvo que Opciones se desplaza si no entra en la ventana). Spec: `specs/01-spec.md` M61 (RF-550 a RF-555); decisiones D-115 a D-117. **No se probó en un celular real.**

### T248 · Barra con pestañas y flecha al menú (M53)

En los niveles que usan infraestructura (los que tienen removibles, minas o demoledora; hoy del 6 al 10) la barra de abajo trae dos pestañas, **«Cañones»** e **«Infraestructura»**, y el panel suelto de arriba a la derecha desaparece. Los niveles 1 a 5 no cambian. Teclas nuevas: **`0`** elige la décima torre y **`Tab`** cambia de pestaña (las torres 1 a 9 siguen en `1` a `9`; la torre 11 no tiene tecla). En todos los niveles hay una flecha **«← Menú»** arriba a la izquierda que pide confirmación y avisa qué se pierde (piezas de colección recogidas y demolición en curso); al probar un mapa del editor dice «← Editor» y vuelve sin preguntar. Capturas reales en `art/m53-barra/`. Spec: M53 (RF-454 a RF-463), D-088.
