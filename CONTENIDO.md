# Cómo crear contenido (enemigos, torres y niveles)

> **Para quién es:** para cualquiera que quiera agregar algo al juego: nosotros, un colaborador o, más adelante, alguien que haga un mod (spec B-04).
>
> **La idea central (spec RF-164, decisión D-025):** todo lo que hace una torre o un enemigo es un **dato**. El código nunca pregunta "¿es el Troll?"; pregunta "¿este enemigo se regenera?". Por eso, para agregar contenido casi nunca hace falta programar: alcanza con **un dibujo y un archivo de datos**. Y los comportamientos se pueden **combinar** libremente (un rayo que además quema, un enemigo que se regenera y suelta crías…).

---

## Dónde está cada cosa

| Qué | Carpeta | Formato |
|---|---|---|
| Datos de enemigos | `data/enemies/` | Un `.tres` por enemigo (`EnemyData`) |
| Datos de torres | `data/towers/` | Un `.tres` por torre (`TowerData`, con sus 3 niveles adentro) |
| Niveles | `data/levels/` | Un `.json` por nivel: el mapa dibujado con letras y las oleadas (ver "Agregar un nivel") |
| Campaña | `data/campaign.json` | La lista de niveles, en orden |
| Artículos de la Wiki | `data/wiki/` | Un `.json` por artículo (ver "La Wiki") |
| Dibujos | `assets/sprites/` | SVG (o PNG). Ver "Reglas de los dibujos" |
| Sonidos | `assets/audio/` | `.wav`. Cada torre usa `shot_<id>.wav` |

Los niveles son JSON, un formato de texto común que se edita a mano. Un `.tres` (enemigos y torres) es un archivo de texto de Godot. Se edita cómodo en el editor (panel **Inspector**), aunque también se puede abrir con cualquier editor de texto.

---

## Reglas de los dibujos

- **Tamaño:** 64×64 unidades (los proyectiles, 32×32). Godot los importa **solos** al doble de tamaño y con *mipmaps* (lo dice `[importer_defaults]` en `project.godot`): no hay que tocar el panel Importar.
- **Enemigos:** de costado, **mirando a la derecha** (el juego los da vuelta). El cuerpo, centrado un poco más abajo del centro (en y = 34).
- **Torretas:** vistas desde arriba, **apuntando a la derecha**, girando sobre el **centro** de la imagen. La punta del cañón, cerca del borde derecho.
- **Proyectiles:** apuntando a la derecha.
- **Estilo:** colores planos con borde oscuro (`#2b2233`). Los enemigos son **bestias con aspecto amenazante**, como el Tanque: ojos chicos y rasgados, colmillos, garras. Nada de ojos grandes ni caras sonrientes.
- Sirve cualquier programa que guarde SVG: Inkscape (gratis), Figma, Illustrator. También un PNG de 128×128.

---

## Agregar un enemigo

1. **Dibujo:** guardarlo como `assets/sprites/enemies/<id>.svg` (por ejemplo `lich.svg`). El `<id>` va en minúsculas y sin espacios.
2. **Datos:** en el editor, panel *Sistema de archivos* → `data/enemies/` → clic derecho sobre un enemigo parecido → **Duplicar** → llamarlo `<id>.tres`.
3. **Completar** en el Inspector (tabla de abajo). Como mínimo: `id` (igual al nombre del archivo), `display_name`, `description`, los números y `texture` (arrastrar el SVG).
4. **Usarlo** en una oleada de algún nivel (ver "Agregar un nivel").
   *Aparece solo en la **Wiki** ("Enemigos"), con su dibujo, sus datos y los niveles donde sale: no hay que tocar nada más.*
5. **Probar:** correr los tests. `tests/test_content.gd` revisa **todos** los enemigos solo y avisa si falta algo ("enemigo 'lich': frase de presentación").

### Campos de `EnemyData`

| Campo | Qué es | Ejemplo |
|---|---|---|
| `id` | Nombre interno; **igual al nombre del archivo**. | `troll` |
| `display_name` | Nombre que ve el jugador. | `Troll` |
| `description` | Frase de la tarjeta "Nuevo enemigo" (RF-134). | `Se cura solo con el tiempo…` |
| `max_health` | Vida en la oleada 1 (después sube, RF-36). | `70` |
| `speed_tiles` | Casillas por segundo. | `1.0` |
| `armor` | Se resta a cada golpe (RF-80). | `3` |
| `reward` | Oro al morir. | `10` |
| `lives_damage` | Vidas que quita si llega a la salida. 5 o más = "peligroso": corona y cartel (RF-135, RF-136). | `2` |
| `is_flying` | Vuela en línea recta; el Cañón y la Ráfaga no le pegan (RF-53). | `false` |
| `slow_resistance` | Parte de la ralentización que ignora (0,5 = la mitad). | `0.0` |
| `color` | Color del estallido al morir. | verde |
| `texture` | El dibujo. | `troll.svg` |
| `size_tiles` | Radio, en casillas (máximo 0,5). | `0.32` |
| `shape` | Forma geométrica si no hay dibujo. | `CIRCLE` |
| **Comportamientos** | *(valen 0 = apagado)* | |
| `regen_percent_per_second` | % de su vida máxima que recupera por segundo; no mientras se quema (RF-165). | `4.0` |
| `death_spawn` / `death_spawn_count` | Qué enemigo suelta al morir por daño, y cuántos (RF-166). | `spiderling`, `4` |

---

## Agregar una torre

1. **Dibujos:** `assets/sprites/towers/turret_<id>.svg` (la torreta) y `assets/sprites/projectiles/<id>.svg`. Las **bases** (madera, piedra, piedra con oro) son las mismas para todas.
2. **Sonido** *(opcional)*: `assets/audio/shot_<id>.wav`. Se puede generar uno agregando una línea en `tools/make_sounds.gd` y corriendo `godot --headless --path . -s tools/make_sounds.gd -- shot_<id>` (así no se tocan los otros sonidos).
3. **Datos:** duplicar una torre parecida de `data/towers/` y completar (tabla de abajo). Cada torre tiene **3 niveles** (`levels`): el nivel 1 es al construirla; en los niveles 2 y 3, `cost` es lo que cuesta mejorarla.
4. **Sumarla al juego:** abrir `scenes/game/game.tscn`, seleccionar el nodo **Game** y agregarla al final de **Tower Types**. Entran **hasta 8** (teclas 1 a 8, RF-170). Si te olvidás, un test te avisa.
5. **Probar:** tests y el bot de balance (más abajo).
   *Aparece sola en la **Wiki** ("Torres"), con su tabla de niveles y sus efectos.*

### Campos de `TowerData`

| Campo | Qué es |
|---|---|
| `id`, `display_name` | Como en los enemigos. |
| `description` | Frase que se ve al elegirla para construir (RF-171). |
| `can_hit_air` | Si le pega a los voladores. |
| `projectile_speed_tiles` | Velocidad de sus proyectiles (casi todas: 10). |
| `color` | Color de sus efectos (anillo al construir). |
| `turret_texture`, `projectile_texture` | Los dibujos. |
| `levels` | Los 3 niveles (`TowerLevelData`, tabla de abajo). |

### Campos de cada nivel (`TowerLevelData`)

| Campo | Qué es |
|---|---|
| `cost` | Oro para construir (nivel 1) o para mejorar (niveles 2 y 3). |
| `damage`, `fire_rate`, `range_tiles` | Daño por golpe, disparos por segundo, alcance en casillas. |
| `base_texture` | La base de ese nivel (`base_1.svg`, `base_2.svg`, `base_3.svg`). |
| **Comportamientos** | *(valen 0 = apagado; se pueden combinar)* |
| `splash_radius_tiles` | Daño en área alrededor del impacto (Cañón). |
| `slow_amount`, `slow_duration` | Ralentiza (Hielo). 0,4 = 40 % más lento. |
| `burn_damage_per_second`, `burn_duration` | Quema: daño por segundo que ignora la armadura y corta la regeneración (Incendiaria, RF-160). |
| `extra_targets` | Dispara a tantos enemigos **más** a la vez (Múltiple, RF-161). |
| `burst_count` | Lanza tantas púas en círculo, en línea recta (Ráfaga, RF-162). |
| `chain_extra_targets`, `chain_range_tiles` | El golpe salta a tantos enemigos más, hasta esa distancia (Eléctrica, RF-163). |

**Ejemplos de combinaciones** (sin programar nada): un Cañón que además quema (`splash_radius_tiles` + `burn_damage_per_second`); una Múltiple que frena (`extra_targets` + `slow_amount`); un rayo que quema (`chain_extra_targets` + `burn_damage_per_second`).

---

## Agregar un nivel

Un nivel es **un archivo de texto** en `data/levels/` (spec §7.8). Se abre con el Bloc de notas, VS Code o cualquier editor. No hace falta Godot ni programar.

### Paso a paso (por ejemplo, el nivel 7)

1. **Copiar** un nivel parecido: `data/levels/level_06.json` → `data/levels/level_07.json`. El nombre del archivo es el **id** del nivel (así se guardan su progreso y sus récords): no cambiarlo después.
2. **Dibujar el mapa** en `"mapa"`: normalmente 9 filas de 20 letras cada una. Puede ser más grande, **hasta 12 filas de 26 letras** (todas las filas del mismo largo): el juego lo achica solo para que entre entero (zoom, sin cambiar el alcance ni el daño de nada). Hay un mapa de ejemplo en `tools/ejemplos/mapa_grande.json`: copialo a la carpeta de mapas de la comunidad para verlo, o abrilo con `check_level`. El editor lo abre, lo muestra entero y lo guarda sin recortarlo, pero **todavía no permite cambiar el tamaño**.
3. **Escribir las oleadas** en `"oleadas"`.
4. **Revisarlo** sin abrir el juego:
   ```bash
   godot --headless --path . -s tools/check_level.gd -- data/levels/level_07.json
   ```
   Si algo está mal, dice qué y dónde (fila y columna, oleada y grupo). Si está bien, muestra el mapa con el recorrido de cada entrada.
5. **Sumarlo a la campaña:** agregar `"level_07"` al final de la lista `"niveles"` de `data/campaign.json`.
6. **Balancearlo** con el bot (sección de abajo) y anotarlo en la spec (una sección como §7.7 y el aumento de vida en §7.4).

### El mapa

```
"mapa": [
  "..........B.........",
  "A#####....#.......X.",
  ".....#....#.........",
  "...X.#############..",
  ".................#..",
  "..################..",
  "..#.........X.......",
  "..#################S",
  ".......X............"
]
```

| Letra | Qué es |
|---|---|
| `.` | Pasto: ahí se construyen torres. |
| `#` | Camino. |
| `X` | Bloqueada: el juego dibuja solo una roca, un árbol o un arbusto. |
| `A`, `B`, `C`… | Entradas (son camino). `A` es la primera; no se puede saltear una letra. Hasta 8 (`A` a `H`). |
| `S` | La salida (una sola). En el borde, los enemigos salen del mapa; adentro, se dibuja una puerta. |

**Cómo caminan los enemigos:** cada entrada va a la salida por el **camino más corto** sobre las casillas de camino. Por eso:
- los caminos se pueden **unir** (como la `B` del ejemplo, que baja y se suma al camino de la `A`);
- no puede haber **dos recorridos igual de cortos** (por ejemplo, un camino de dos casillas de ancho o un anillo): el juego no adivina y avisa dónde se separan. Se arregla cerrando uno con `X` o con pasto.

Los voladores ignoran el camino: van en línea recta de su entrada a la salida.

### Los demás campos

| Clave | Qué es | ¿Obligatoria? |
|---|---|---|
| `version` | El formato del archivo. Hoy, `1`. | Sí |
| `nombre` | El nombre que ve el jugador ("Nido"). | Sí |
| `oro` | Oro al empezar. | Sí |
| `vidas` | Vidas al empezar (los niveles oficiales usan 20). | Sí |
| `aumento_vida` | % de vida extra de los enemigos en cada oleada (spec §7.4). Si no está, se usa el general de `balance.tres`. | No |
| `oleadas` | La lista de oleadas (abajo). | Sí |

### Las oleadas

Cada oleada es una lista de **grupos**; los grupos de una oleada arrancan juntos, salvo que digan `desde`.

```
"oleadas": [
  [{"enemigo": "normal", "cantidad": 10, "cada": 0.8}],
  [{"enemigo": "fast", "cantidad": 12, "cada": 0.4, "entrada": "B"},
   {"enemigo": "troll", "cantidad": 8, "cada": 1.2, "desde": 2.0}]
]
```

| Clave | Qué es | ¿Obligatoria? |
|---|---|---|
| `enemigo` | El nombre de un archivo de `data/enemies/` (sin `.tres`): `normal`, `fast`, `tank`, `flyer`, `armored`, `boss`, `troll`, `spider`… | Sí |
| `cantidad` | Cuántos salen. | Sí |
| `cada` | Segundos entre uno y el siguiente. | Si `cantidad` es más de 1 |
| `desde` | Segundos desde que empieza la oleada hasta que sale el primero. | No (vale 0) |
| `entrada` | Por qué entrada salen: `"A"`, `"B"`… | No (vale `"A"`) |

### Errores comunes

El juego avisa todos estos (y un nivel con errores no se juega, pero el resto de la campaña sigue andando):
- **Una coma de más o de menos**, o una comilla sin cerrar: "no es un JSON válido (línea 12…)". En JSON, el último elemento de una lista o de un `{ }` **no** lleva coma.
- **Una clave mal escrita** (`"canitdad"`): el juego no la ignora, avisa.
- **Un enemigo que no existe** (`"trol"`), o una entrada que el mapa no tiene (`"C"` en un mapa con `A` y `B`).
- **Una fila con 19 o 21 letras.**
- **Casillas de camino que nadie pisa** (un aviso, no un error): casi siempre dos partes del camino quedaron en casillas vecinas y el enemigo se salta el tramo del medio. `check_level` las marca con `?`.

### Hacerlo con el editor, sin escribir el archivo a mano

En el **ejecutable de pruebas** (`JuegoA_pruebas.exe`) el menú principal tiene el botón **"Editor de mapas"**. Es lo mismo que escribir el JSON, pero se dibuja con el mouse:

| Qué | Cómo |
|---|---|
| **Pintar** | Elegir una herramienta abajo (o las teclas `1` a `5`): Pasto, Camino, Bloqueada, Entrada, Salida. Clic o arrastrar. **Clic derecho borra.** |
| **Entradas** | La herramienta Entrada pone la próxima letra libre (`A`, `B`…). Pintar encima de una entrada la quita y las letras siguientes bajan un lugar (las oleadas se acomodan solas). |
| **Salida** | Hay una sola: si ya estaba, se mueve. |
| **Ver si está bien** | Abajo, un mensaje dice si el nivel es válido (con el largo de cada recorrido) o qué está mal y dónde. Sobre el mapa se dibuja el recorrido de cada entrada y las casillas que nadie pisa. |
| **Ajustes y oleadas** | Botones **Ajustes** (nombre, oro, vidas, vida extra por oleada) y **Oleadas** (agregar, copiar y quitar oleadas; en cada una, los grupos de enemigos). |
| **Deshacer** | `Ctrl+Z` y `Ctrl+Y` (hasta 50 pasos). |
| **Probar** | Juega ese nivel en el momento, sin guardar progreso ni récords. Al terminar (o con "Volver al editor" en la pausa) se vuelve al editor con todo como estaba. No se puede probar un nivel con errores. |
| **Guardar / Abrir** | `Ctrl+S`. Guarda en `user://maps/<nombre>.json` (en Windows: `%APPDATA%\Godot\app_userdata\JuegoA\maps\`). "Abrir" lista tus mapas y los niveles oficiales (que se abren como **plantilla**: al guardar pide otro nombre y **nunca pisa el oficial**). |

**Para volver oficial un mapa hecho con el editor:**
1. Copiar el archivo de `maps/` a `data/levels/level_08.json` (o el número que siga: el nombre del archivo es el id del nivel).
2. Revisarlo: `godot --headless --path . -s tools/check_level.gd -- data/levels/level_08.json`.
3. Sumarlo al final de `"niveles"` en `data/campaign.json`.
4. Balancearlo con el bot (sección de abajo) y anotarlo en la spec (una sección como §7.9 y el aumento de vida en §7.4). Los tests revisan solos que los niveles oficiales no tengan errores ni avisos.

---

## Mapas de la comunidad: instalar y compartir

Cualquier persona puede sumar mapas al juego **copiando un archivo**, en cualquier versión (Windows o Linux; en el celular no). No hace falta el editor ni programar (spec §10.4).

**Instalar un mapa:** copiar el archivo `.json` a la carpeta de mapas:

| Sistema | Carpeta |
|---|---|
| Windows | `%APPDATA%\Godot\app_userdata\JuegoA\maps\` |
| Linux | `~/.local/share/godot/app_userdata/JuegoA/maps/` |

Lo más fácil: en el juego, **Jugar → solapa "Mapas de la comunidad" → "Abrir carpeta de mapas"** (la crea si no existe). Al volver a la selección de nivel, el mapa aparece solo, sin reiniciar el juego.

**Compartir un mapa:** se manda el archivo (por Discord, mail, itch.io…). Los mapas hechos con el editor (versión de pruebas) se guardan en esa misma carpeta, así que ya están ahí.

**Cómo se ve y cómo se juega:**
- Cada archivo es una tarjeta con el nombre del mapa, las oleadas, las estrellas y "Mejor: N vidas". Están **todos abiertos**.
- Tienen su **propio progreso y su propio top 5**: no desbloquean niveles, no suman a las estrellas de la campaña y **no cuentan para el Salón de la fama** (si contaran, alguien podría regalarse el ranking con un mapa fácil hecho a medida).
- Al terminar, "Niveles" vuelve a la solapa de la comunidad.

**Si una tarjeta sale en rojo ("Con errores")**, el archivo no se puede jugar. Pasá el mouse por arriba para ver el motivo, o revisalo con `tools/check_level.gd` (dice fila y columna). Los motivos más comunes:

| Motivo | Cómo se arregla |
|---|---|
| "Nombre de archivo no válido" | El nombre solo puede tener minúsculas, números y `_` (hasta 40 letras): `mi_mapa_2.json`, no `Mi Mapa.json`. |
| "No existe el enemigo …" | Tiene que ser uno de `data/enemies/` (`normal`, `fast`, `troll`…). |
| "El archivo es demasiado grande" | Un mapa real pesa 2 o 3 KB; el máximo es 200 KB. |
| Un número pasado del límite | Ver la tabla de abajo. |

**Límites** (valen para todos los niveles y el editor no deja pasarse), para que un archivo ajeno no cuelgue el juego:

| Qué | Máximo |
|---|---|
| Oleadas | 100 |
| Grupos por oleada | 20 |
| Cantidad de un grupo | 999 |
| `cada` (segundos) | 60 |
| `desde` (segundos) | 600 |
| Oro inicial | 99999 |
| Vidas | 999 |
| `aumento_vida` | 300 |
| Nombre del nivel | 30 letras |

**Seguridad:** un mapa es **solo datos** (texto JSON): no puede traer código. Aun así, como con cualquier archivo que baja de internet, conviene abrirlo en un editor de texto antes de instalarlo si no se confía en quien lo mandó.

---

## La Wiki: qué se agrega solo y cómo escribir un artículo

La **Wiki** (menú principal) tiene tres categorías:

| Categoría | De dónde sale | Qué hay que hacer |
|---|---|---|
| **Enemigos** | Un `.tres` de `data/enemies/` | Nada: se agrega sola, ordenada de más débil a más fuerte. Los números salen del `.tres` y "dónde aparece" sale de la campaña. Es un **bestiario**: cada enemigo aparece "???" (en silueta) hasta que el jugador lo ve en una partida; el enemigo nuevo queda cerrado para todos hasta que se lo cruzan. |
| **Torres** | Un `.tres` de `data/towers/` | Nada: se agrega sola, de la más barata a la más cara. |
| **Guía** | Un `.json` de `data/wiki/` | Escribir el artículo (abajo). |

Un artículo es un archivo de texto (el nombre del archivo es su id: minúsculas, números y `_`):

```json
{
  "version": 1,
  "titulo": "Mi artículo",
  "subtitulo": "Una línea que lo resume (opcional)",
  "orden": 8,
  "bloques": [
    { "tipo": "titulo", "texto": "Un subtítulo" },
    { "tipo": "texto", "texto": "Un párrafo. Se parte solo en renglones." },
    { "tipo": "datos", "filas": [["Nombre", "valor"], ["Otro", "otro valor"]] },
    { "tipo": "tabla", "filas": [["Columna A", "Columna B"], ["1", "2"]] }
  ]
}
```

- `orden` (opcional) decide dónde va en la lista; a igual número, por nombre de archivo.
- En `datos` cada fila tiene **2** textos; en `tabla`, la primera fila es el encabezado y todas tienen la misma cantidad de columnas.
- **No copies números que ya viven en los datos** (vida, daño, costos, porcentajes): explicá la regla y mandá a la entrada del enemigo o la torre. Si se rebalancea, el artículo quedaría mintiendo.
- Si te equivocás, el artículo simplemente no aparece; `tests/test_wiki_articles.gd` falla y dice **qué archivo y qué error**.
- Para una categoría nueva (Niveles, Lore…) hay que sumar una función en `scripts/logic/wiki.gd`; la pantalla no cambia (plan técnico §6.10).

---

## Revisar el balance con el bot

El bot juega solo, a toda velocidad, e imprime cómo termina:

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=6
```

- Estrategias: `smart` (las 4 torres de siempre), `mix` (las 8 torres), `basic` (solo Ametralladoras) y `naive` (torres al azar).
- `levelscale=30` prueba otro aumento de vida por oleada sin tocar los archivos.
- `<torre>.<campo>=valor` prueba otro número del nivel 1 de una torre (por ejemplo `fire.damage=6`).

Una buena señal: los bots que piensan ganan con algunas vidas de sobra y el que pone torres al azar pierde.

---

## Lista rápida antes de subir contenido nuevo

- [ ] El `id` es igual al nombre del archivo (en los niveles, el id **es** el nombre del archivo).
- [ ] Si es un nivel: `check_level` no da errores y está en `data/campaign.json`.
- [ ] Tiene nombre, frase y dibujo(s).
- [ ] Si es una torre: 3 niveles, sonido `shot_<id>.wav` y está en **Tower Types**.
- [ ] Se ve bien en la **Wiki** (enemigos y torres se agregan solos: abrirla y mirar la entrada nueva).
- [ ] Pasan los tests (`test_content.gd` revisa todo lo anterior solo).
- [ ] Si cambia el balance: el bot da resultados razonables, y la spec lo dice (constitución P3: la spec manda).
