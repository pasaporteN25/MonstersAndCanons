# JuegoA — Tower Defense

[![Tests](https://github.com/pasaporteN25/TDv1/actions/workflows/tests.yml/badge.svg)](https://github.com/pasaporteN25/TDv1/actions/workflows/tests.yml)

Juego *tower defense* 2D hecho en **Godot 4** con **GDScript**, construido con **SDD (Spec-Driven Development)**.

> **Estado actual:** M1 a M20 ✅ (juego completo, 7 niveles, 9 torres (una de 2×2), modo de pruebas con editor de mapas, mapas de la comunidad, Wiki con bestiario, mapas de tamaño variable con zoom, siete temas de paisaje y leyenda, récords, niveles en archivos de texto y versión para Linux) y versión Android probada en un celular. Tests automáticos en GitHub (D-030).
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
| [`05-guia-de-arte.md`](specs/05-guia-de-arte.md) | Cómo se dibuja todo: técnica del SVG, paleta de cada enemigo y reglas para los temas del mapa. | Antes de dibujar cualquier cosa nueva. |

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
godot --headless --path . --export-release "Windows Desktop" build/JuegoA.exe
```

- El resultado es **un solo archivo** (`build/JuegoA.exe`, ~110 MB: casi todo es el motor de Godot). Se puede copiar a cualquier carpeta o computadora con Windows y jugar sin instalar nada.
- La configuración está en `export_presets.cfg`: deja fuera `tests/`, `tools/`, `specs/` y GUT.
- La carpeta `build/` no se sube a git.
- El progreso se guarda en `%APPDATA%\Godot\app_userdata\JuegoA\save.json`.

### Versión para GNU/Linux

```bash
godot --headless --path . --export-release "Linux" build/JuegoA.x86_64
tar --mode=755 -czf build/JuegoA_linux.tar.gz -C build JuegoA.x86_64
```

- Es **un solo archivo** (`JuegoA.x86_64`, ~75 MB, para procesadores de 64 bits Intel/AMD) con los datos adentro, igual que el `.exe`. Usa las mismas plantillas de exportación de Godot 4.7.2 (las de Linux vienen con las de Windows).
- Un archivo copiado desde Windows **pierde el permiso de ejecución**. Por eso también se arma el `.tar.gz`, que lo conserva: en Linux, `tar -xzf JuegoA_linux.tar.gz` y `./JuegoA.x86_64`. Si se copió el archivo suelto: `chmod +x JuegoA.x86_64`.
- Necesita una computadora con escritorio (X11 o Wayland) y OpenGL. El progreso se guarda en `~/.local/share/godot/app_userdata/JuegoA/save.json`.
- **Todavía no se probó en una computadora Linux real**: los tests sí corren en Linux en cada push (GitHub, D-030), pero el ejecutable no se abrió.

### El ejecutable de pruebas (`JuegoA_pruebas.exe`)

Para probar todo sin ganar cada nivel (spec §10.2, D-028):

```bash
godot --headless --path . --export-release "Windows (pruebas)" build/JuegoA_pruebas.exe
```

- Trae el **modo de pruebas**: todos los niveles abiertos y, en la partida, el **panel de pruebas** (`F1` o el botón "Pruebas"): +1000 de oro, vidas infinitas, saltar oleada, matar a todos, ganar, perder, velocidad x4, hacer aparecer cualquier enemigo y ver los FPS.
- Usa **otro guardado** (`save_pruebas.json`, en la misma carpeta): lo que hagas ahí no toca tu progreso, tus estrellas ni tus récords reales.
- **Editor de mapas:** el menú principal trae el botón "Editor de mapas" (en el juego normal y en el de pruebas, no en el celular). Se dibuja el mapa con el mouse, se arman las oleadas, se prueba el nivel al instante y se guarda en `%APPDATA%\Godot\app_userdata\JuegoA\maps`. Ver [`CONTENIDO.md`](CONTENIDO.md).
- Abajo al centro siempre dice "MODO PRUEBAS", para no confundirlo con el juego normal.
- El `JuegoA.exe` normal y el `.apk` **no** lo tienen.
- Desde el editor de Godot: *Proyecto → Configuración del proyecto → Editor → Run → Main Run Args* = `-- --pruebas`.

## Paisajes de mapa

Un nivel puede elegir su **tema** (pradera, desierto, nieve, volcán, bosque, pantano o ruinas) y declarar una **leyenda** con letras nuevas (lago, hielo, lava, flores, cactus…). Hay un mapa de ejemplo por tema en `tools/ejemplos/`. Cómo se escriben: [`CONTENIDO.md`](CONTENIDO.md).

## Wiki

El botón **Wiki** del menú principal abre una enciclopedia: **Enemigos** (un bestiario: cada uno aparece como "???" hasta que lo ves en una partida; en la versión de pruebas se ve todo) y **Torres** (con sus números reales, la tabla de niveles y dónde aparece cada enemigo) y una **Guía** con las reglas. Un enemigo o una torre nuevos aparecen solos; los artículos de la guía son archivos de texto en `data/wiki/`. Cómo escribirlos: [`CONTENIDO.md`](CONTENIDO.md).

## Mapas de la comunidad

En **Jugar → "Mapas de la comunidad"** aparecen todos los archivos `.json` que haya en la carpeta de mapas (en Windows, `%APPDATA%\Godot\app_userdata\JuegoA\maps`; el botón "Abrir carpeta de mapas" la abre). Sirve para jugar mapas que te pasó otra persona o los que hacés con el editor de la versión de pruebas. Cada mapa tiene su propio progreso y su top 5, y no toca la campaña. Cómo instalar, compartir y qué límites tienen: [`CONTENIDO.md`](CONTENIDO.md).

## Dibujos (arte provisional)

Los dibujos del juego son archivos **SVG** en `assets/sprites/` (decisión D-023, spec §9.6). Son **provisionales**: el arte definitivo sigue en el backlog (B-02), porque depende de la ambientación.

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
| `godot --headless --path . -s tools/make_sounds.gd` | Volver a generar los sonidos (`-- shot_fire` = solo ese). |
| `godot --headless --path . -s tools/check_level.gd -- data/levels/level_06.json` | Revisar un nivel sin jugarlo: sus errores, o el mapa con el recorrido de cada entrada. Sin archivo, revisa todos los de la campaña. Cómo hacer un nivel: [`CONTENIDO.md`](CONTENIDO.md). |
| `godot --headless --path . -s tools/make_icon.gd` | Volver a generar el ícono del juego con los dibujos. |
