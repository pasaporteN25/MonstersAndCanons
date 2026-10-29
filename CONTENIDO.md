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
| Modo de pruebas | `data/dev_config.tres` | El oro del botón "+1000 de oro" y las cinco velocidades del panel (`DevConfig`) |
| Dibujos | `assets/sprites/` | SVG (o PNG). Ver "Reglas de los dibujos" |
| Sonidos | `assets/audio/` | `.wav`. Cada torre usa `shot_<id>.wav` |

Los niveles son JSON, un formato de texto común que se edita a mano. Un `.tres` (enemigos y torres) es un archivo de texto de Godot. Se edita cómodo en el editor (panel **Inspector**), aunque también se puede abrir con cualquier editor de texto.

---

## Reglas de los dibujos

- **Tamaño:** los SVG usan 64×64 unidades (proyectiles, 32×32) y se importan al doble. Los PNG ya se entregan a 128×128 (proyectiles, 64×64): no llevan otra ampliación. Mipmaps activados. En M23 las torres usan atlas de 512×256, con ocho cuadros de 128×128 (guía de arte §7).
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
| `texture` | El dibujo. Los tres monstruos de M24 (Normal, Rápido, Tanque) usan PNG de 256×256 de una sola vista en `assets/sprites/enemies/rendered/`. | `troll.png` |
| `flip_when_walking_left` | Si el dibujo se refleja en espejo al caminar hacia la izquierda (por defecto sí). Apagarlo para un PNG con luz propia (la luz no cambia de lado); entonces el enemigo mira siempre hacia el mismo lado. | `false` |
| `size_tiles` | Radio, en casillas (máximo 0,5). | `0.32` |
| `shape` | Forma geométrica si no hay dibujo. | `CIRCLE` |
| **Comportamientos** | *(valen 0 = apagado)* | |
| `regen_percent_per_second` | % de su vida máxima que recupera por segundo; no mientras se quema (RF-165). | `4.0` |
| `death_spawn` / `death_spawn_count` | Qué enemigo suelta al morir por daño, y cuántos (RF-166). | `spiderling`, `4` |
| `aura_radius_tiles` | Hasta dónde llega su **aura**, en casillas (RF-270). 0 = sin aura. | `2.0` |
| `aura_armor_bonus` | Armadura extra que da a los demás enemigos dentro del radio (RF-271). No se suma con otras auras. | `2` |
| `stun_interval` / `stun_seconds` / `stun_range_tiles` | El **hechizo** que apaga torres (RF-281): cada cuántos segundos, cuánto aturde y a qué distancia. 0 = no lanza. | `8.0`, `3.0`, `4.0` |
| `reflect_range_tiles` / `reflect_stun_seconds` | El **rebote** (RF-283): a qué distancia rebota el tiro de una torre y cuánto la aturde. La quemadura no rebota. | `2.5`, `2.0` |
| `aura_heal_percent_per_second` | % de vida máxima por segundo que hace recuperar a los demás dentro del radio (RF-272); no mientras se queman. | `3.0` |
| `entrance` | Dato del piloto viejo T366/T368, pendiente de reemplazo por T461; no agregar ni extender para el M66 aprobado. | `BossEntranceData`

### Presentación de jefes (M66; T461)

**No hay campo de datos para extenderla.** El piloto viejo (`EnemyData.entrance`, `BossEntranceData`, `data/ui/entrada_jefes.json`, destello, cartel y los PNG `boss_burst`, `boss_crack` y `boss_card_frame`) se retiró en T461: no agregues `entrance` a ningún enemigo. Hoy la presentación sale para **todo enemigo peligroso** (`lives_damage` ≥ 5, RF-135): el Jefe y el Coloso. Su título, nombre y frase son los del propio enemigo (`display_name`, `description`) y los segundos (5 la primera vez, 3 después, 0,3 de protección) están en `BossPresentationRules`.

**Fondo del Coloso (T548).** `data/ui/boss_presentation.json` dice qué jefe tiene fondo propio (`jefes.<id>.fondo`, ruta `res://`; hoy solo `colossus`, el PNG `assets/backgrounds/boss/colossus.png`, 1672×941, la muestra 02 aprobada por Lucas el 2026-10-28) y cómo se oscurece la franja de texto (`degradado.color`, `degradado.alto` en fracción de la ventana y `degradado.opacidad`; en 0 se apaga). `Game` le pasa ese fondo a `BossPresentation.setup()`; un jefe sin entrada (el Jefe) o con una ruta que no existe usa el fondo liso. El fondo se escala sin deformar (se recorta). La ilustración quieta del Coloso (T367) sigue pendiente: hasta entonces usa el retrato del enemigo, y el Jefe sigue con la composición provisional. El jefe presentado no lleva tarjeta «Nuevo enemigo» (PR #59). Ver [M66](specs/01-spec.md), [T461](specs/03-tareas.md) y la [ficha de muestras T367](specs/tareas/T367-arte-entrada-jefes.md).

---

## Agregar una torre

1. **Dibujos:** `assets/sprites/towers/turret_<id>.svg` (la torreta) y `assets/sprites/projectiles/<id>.svg`. Las **bases** (madera, piedra, piedra con oro) son las mismas para todas.
2. **Sonido** *(opcional)*: `assets/audio/shot_<id>.wav`. Se puede generar uno agregando una línea en `tools/make_sounds.gd` y corriendo `godot --headless --path . -s tools/make_sounds.gd -- shot_<id>` (así no se tocan los otros sonidos).
3. **Datos:** duplicar una torre parecida de `data/towers/` y completar (tabla de abajo). Cada torre tiene **3 niveles** (`levels`): el nivel 1 es al construirla; en los niveles 2 y 3, `cost` es lo que cuesta mejorarla.
4. **Sumarla al juego:** abrir `scenes/game/game.tscn`, seleccionar el nodo **Game** y agregarla al final de **Tower Types**. Entran **hasta 11** *(M53)*: las teclas son `1` a `9` y `0` (la décima); de la torre 11 en adelante no hay tecla y se elige con el mouse. Los botones de la barra se achican solos (de 76 a 57 px) cuando hay más de 9; en un nivel con removibles, minas o demoledora la barra además lleva dos pestañas (RF-170, RF-297, RF-454 a RF-456). Si te olvidás, un test te avisa.
5. **Probar:** tests y el bot de balance (más abajo).
   *Aparece sola en la **Wiki** ("Torres"), con su tabla de niveles y sus efectos.*

### Campos de `TowerData`

| Campo | Qué es |
|---|---|
| `id`, `display_name` | Como en los enemigos. |
| `description` | Frase que se ve al elegirla para construir (RF-171). |
| `can_hit_air` | Si le pega a los voladores. |
| `bonus_vs_slowed_percent` / `bonus_vs_burning_percent` | **Sinergia por estado** (RF-310): % de daño extra contra un enemigo ralentizado o que se quema. Se mira al impactar, se suman si tiene los dos y se calcula antes de la armadura. 0 = nada. Va en cada **nivel** de la torre. Con solo poner el dato, el juego ya lo muestra todo (RF-315 a RF-318): el número del combo, el panel y la Wiki de la torre que pone el estado ("Combo: … +25 % a los que frena", con el porcentaje del nivel 1), la frase de la barra y la dianita de "vulnerable". | `25`, `0` |
| `reserved` | `true` = la torre **no** está en la barra salvo que el nivel la habilite con `"torres_extra"` (RF-300). Hoy: el Mortero. | `true` |
| `resource_cost` | **Recursos** que cuesta construirla además del oro (RF-418). `0` (por omisión) = solo oro. Mejorar no cuesta recursos; vender devuelve el mismo % que el oro, redondeado hacia abajo. Aparece sola en la barra ("300 + 3"), el panel y la Wiki. Hoy: el Mortero. | `3` |
| `alt_gold_cost` y `alt_resource_cost` | **Segunda forma de pago** (RF-419): oro más recursos. Con `alt_resource_cost` mayor que 0, la ayuda de construcción ofrece dos botones ("150 de oro" y "120 de oro + 1 recurso"). `alt_gold_cost` tiene que ser menor que el costo de oro del nivel 1 y no se puede combinar con `resource_cost`. Hoy: el Francotirador. | `120` y `1` |
| `footprint` | **Lado** de la torre en casillas (RF-290). `1` = una casilla (la común), `2` = cuadrado de 2×2 como el Mortero. Necesita todas sus casillas libres; usa los mismos dibujos de base agrandados. | `2` |
| `projectile_speed_tiles` | Velocidad de sus proyectiles (casi todas: 10). |
| `color` | Color de sus efectos (anillo al construir). |
| `turret_texture`, `projectile_texture` | Los dibujos. |
| `turret_atlas` | Opcional: PNG de cuatro columnas × dos filas, ocho vistas en orden E, SE, S, SO, O, NO, N, NE. Mantiene luz y perspectiva al apuntar. Sin atlas, gira `turret_texture` como antes. |
| `levels` | Los 3 niveles (`TowerLevelData`, tabla de abajo). |

### Campos de cada nivel (`TowerLevelData`)

| Campo | Qué es |
|---|---|
| `cost` | Oro para construir (nivel 1) o para mejorar (niveles 2 y 3). |
| `damage`, `fire_rate`, `range_tiles` | Daño por golpe, disparos por segundo, alcance en casillas. |
| `base_texture` | Base fija de ese nivel: producción M23 en `assets/sprites/towers/rendered/base_1.png` a `base_3.png`. Los SVG anteriores siguen siendo válidos para datos sin atlas. |
| **Comportamientos** | *(valen 0 = apagado; se pueden combinar)* |
| `splash_radius_tiles` | Daño en área alrededor del impacto (Cañón). |
| `slow_amount`, `slow_duration` | Ralentiza (Hielo). 0,4 = 40 % más lento. |
| `burn_damage_per_second`, `burn_duration` | Quema: daño por segundo que ignora la armadura y corta la regeneración (Incendiaria, RF-160). |
| `extra_targets` | Dispara a tantos enemigos **más** a la vez (Múltiple, RF-161). |
| `burst_count` | Lanza tantas púas en círculo, en línea recta (Ráfaga, RF-162). |
| `chain_extra_targets`, `chain_range_tiles` | El golpe salta a tantos enemigos más, hasta esa distancia (Eléctrica, RF-163). |
| `suppress_seconds` | **Torre de pulso** (Disruptora, RF-439): segundos que un enemigo con aura alcanzado por el pulso deja de emitirla. Con esto mayor que 0 la torre no dispara: `fire_rate` son pulsos por segundo, `range_tiles` el radio del pulso y `damage` el golpe a cada alcanzado (menos al Espejo). No se combina con púas, rayos, área, ralentización ni quemadura. La Disruptora necesita su colección `disruptor` y cuesta recursos (`resource_cost`); un nivel la ofrece nombrándola en `"torres"`. |

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
| `textos` | *(M52, RF-464, T228)* Los textos breves del nivel: `"lugar"` (1 línea, 32 caracteres; sale en la tarjeta), `"entrada"` (hasta 3 líneas y 240 caracteres; un cartel al empezar), `"victoria"` (hasta 2 líneas y 160 caracteres; sale en la pantalla de victoria) y `"epilogo"` (3 a 5 líneas, solo para el último nivel de la campaña). Las líneas se separan con `\n` y ninguna pasa de 90 caracteres. Ejemplo: `"textos": {"lugar": "El paso del agua", "victoria": "Paso asegurado."}`. Un mapa de la comunidad o de un modo propio los muestra **solo si el archivo los trae**; los modos oficiales (Asedio), el modo de pruebas y probar desde el editor **no los muestran nunca**. El `"lugar"` sale en la tarjeta (solo si el nivel está desbloqueado), la `"entrada"` en un cartel que pausa la partida hasta que se toca la pantalla (o `Espacio`, `Enter`, `Esc`) y no vuelve al «Reintentar», y la `"victoria"` bajo las estrellas. Una clave de más, un texto vacío o pasarse de líneas o de caracteres es un error que dice cuánto tiene y cuánto es el máximo (los saltos de línea cuentan como caracteres). El editor de mapas **conserva** el campo al abrir y guardar, pero no lo edita: se escribe a mano en el archivo. Los textos oficiales están en `specs/11-textos-lore.md` (un test comprueba que los niveles traen exactamente esos). | No |
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

En el menú principal, en el **`MonstersCanons.exe` normal y en el de pruebas** (no en el celular), está el botón **"Editor de mapas"**. Es lo mismo que escribir el JSON, pero se dibuja con el mouse:

| Qué | Cómo |
|---|---|
| **Pintar** | Elegir una herramienta abajo (o las teclas `1` a `5`): Pasto, Camino, Bloqueada, Entrada, Salida. Clic o arrastrar. **Clic derecho borra.** |
| **Objetos** *(M50, T212)* | Cinco pinceles más (teclas `6`, `7`, `8`, `9` y `0`): **Árbol** y **Roca** removibles, **Escombro**, **Mina** y **Bosque**. Cada uno crea (o reusa) por debajo la letra de la leyenda con esa clase, así que no hay que tocar el JSON. Si la leyenda ya tiene sus **12 letras** (eran 10 hasta T234, D-093), el pincel no pinta y avisa abajo. Borrar la última casilla de un objeto saca su letra de la leyenda. |
| **Valores de los objetos** | Botón **Objetos**: se elige una letra y se cambian `costo`, `tiempo`, `recursos` y `probabilidad` (o `produccion` y `reserva`) para **todas** las casillas con esa letra. Cada dato muestra el valor de la clase; escribir ese mismo número borra la sobrescritura. Si querés valores distintos en dos árboles, pintá uno, cambiale los valores y pintá el otro con el pincel: como la primera letra ya no es "común", el pincel crea otra. |
| **Pieza de un escombro** | En el panel **Objetos**, un escombro tiene el campo *Pieza de colección* (`hallazgo`). **Solo se puede editar en un nivel de la campaña**, es decir, uno oficial abierto como plantilla y todavía sin guardar. En un mapa de la comunidad o de un modo el campo aparece deshabilitado ("Las piezas de colección solo se consiguen en la campaña"), pero un hallazgo que el archivo ya traía se **conserva** al guardar. |
| **Entradas** | La herramienta Entrada pone la próxima letra libre (`A`, `B`…). Pintar encima de una entrada la quita y las letras siguientes bajan un lugar (las oleadas se acomodan solas). |
| **Salida** | Hay una sola: si ya estaba, se mueve. |
| **Ver si está bien** | Abajo, un mensaje dice si el nivel es válido (con el largo de cada recorrido) o qué está mal y dónde. Sobre el mapa se dibuja el recorrido de cada entrada y las casillas que nadie pisa. |
| **Ajustes y oleadas** | Botones **Ajustes** (nombre, oro, vidas, vida extra por oleada, **Demoledora disponible** y **Torres del mapa**) y **Oleadas** (agregar, copiar y quitar oleadas; en cada una, los grupos de enemigos). En *Torres del mapa* se marcan las torres que ofrece el nivel (`"torres"`); sin tocarlas se ofrecen las de siempre, y **"Usar las de siempre"** borra la lista. Tiene que quedar al menos una marcada. |
| **Deshacer** | `Ctrl+Z` y `Ctrl+Y` (hasta 50 pasos). |
| **Probar** | Juega ese nivel en el momento, sin guardar progreso ni récords. Al terminar (o con "Volver al editor" en la pausa) se vuelve al editor con todo como estaba. No se puede probar un nivel con errores. |
| **Guardar / Abrir** | `Ctrl+S`. Guarda en `user://maps/<nombre>.json` (en Windows: `%APPDATA%\Godot\app_userdata\JuegoA\maps`). "Abrir" lista tus mapas y los niveles oficiales (que se abren como **plantilla**: al guardar pide otro nombre y **nunca pisa el oficial**). |

**Para volver oficial un mapa hecho con el editor:**
1. Copiar el archivo de `maps/` a `data/levels/level_08.json` (o el número que siga: el nombre del archivo es el id del nivel).
2. Revisarlo: `godot --headless --path . -s tools/check_level.gd -- data/levels/level_08.json`.
3. Sumarlo al final de `"niveles"` en `data/campaign.json`.
4. Balancearlo con el bot (sección de abajo) y anotarlo en la spec (una sección como §7.9 y el aumento de vida en §7.4). Los tests revisan solos que los niveles oficiales no tengan errores ni avisos.

---

## Paisaje del mapa: tema y leyenda

Dos campos **opcionales** del nivel (sin ellos, el nivel se ve como siempre). Hay un ejemplo por tema en `tools/ejemplos/tema_*.json`.

```json
"tema": "nieve",
"leyenda": {
  "~": {"dibujo": "hielo"},
  "p": {"dibujo": "pino"},
  ",": {"dibujo": "flores", "construible": true}
},
```

- **`tema`** cambia los colores y la decoración de todo el mapa: `pradera` (el de siempre), `desierto`, `nieve`, `volcan`, `bosque`, `pantano` o `ruinas`. Es solo visual.
- **`torres_extra`** (opcional) habilita torres **reservadas** en este nivel, por ejemplo `"torres_extra": ["mortar"]` (RF-300). Un nombre que no existe es un error.
- **`torres`** (opcional, RF-393) dice **qué torres ofrece** el nivel, por ejemplo `"torres": ["frost", "cannon", "tesla"]`. Sin el campo, el nivel ofrece las 8 comunes más las de `torres_extra`, como siempre. Con el campo, la barra y las teclas muestran **solo esas**, siempre en el orden de la barra (Ametralladora, Cañón, Hielo, Francotirador, Incendiaria, Ráfaga múltiple, Ráfaga, Tesla, Mortero), no en el orden en que las escribas. Se pueden nombrar torres reservadas (equivale a habilitarlas). Un nombre que no existe es un error que lista los que hay; uno repetido cuenta una vez; la lista no puede estar vacía. Una torre que pide una colección sigue pidiéndola. Si un modo (`modo.json`) también limita las torres, vale lo que tengan **en común**; si no tienen nada en común, el mapa de ese modo da error. La tarjeta del nivel muestra las torres que ofrece y marca **"Nueva"** donde debuta cada una. Ejemplo: `tools/ejemplos/mapa_torres_por_mapa.json`.
- **`leyenda`** declara letras nuevas (hasta 10) para usar en el `"mapa"`. Cada una dice un **`dibujo`** y, si se puede construir encima, `"construible": true` (si no se escribe, no se puede). La letra es **una sola** y no puede ser `. # X S` ni una entrada (`A` a `H`).
- **Nunca son camino:** una letra de la leyenda es pasto (si es construible) o casilla bloqueada. Los recorridos de los enemigos no cambian.
- **Los dibujos** son una lista cerrada:

| Dibujo | Tipo | |
|---|---|---|
| `roca`, `arbol`, `arbusto`, `flores` | objeto | los de la pradera; las flores son decoración |
| `cactus`, `pino`, `columna`, `tronco`, `helecho`, `junco`, `hongo`, `estatua` | objeto | uno o dos por paisaje |
| `escombro`, `mina`, `bosque_explotable` | objeto | removibles y puntos de extracción de M50 |
| `agua`, `hielo`, `lava`, `barro` | suelo | cubren toda la casilla y se unen entre sí; tienen un borde donde terminan |

*(T516, 2026-10-26: `pino` se dibuja con el PNG renderizado `pine_snow.png` (T497); los SVG viejos `pino.svg`, `abeto.svg`, `roca_nieve.svg` y `huesos.svg` se retiraron y ya no existen. Los nombres de dibujo de la leyenda no cambian.)*

- **Objetos que se pueden retirar y minas** *(M50, RF-398 a RF-403; formato, validación, dibujo y `check_level` en T206; **demolición directa en T207** (clic, panel, cobro, trabajo con reloj de partida, cancelar); recursos, extracción y piezas, en T209 a T211; demoledora global en T208)*. Una letra de la leyenda puede llevar **`removible`** (un objeto que se retira pagando oro y esperando) **o** **`extraccion`** (una mina o un bosque que produce recursos), nunca los dos. Ejemplo:
- **Objetos que se pueden retirar y minas** *(M50, RF-398 a RF-403; formato, validación, dibujo y `check_level` en T206; **demolición directa en T207** (clic, panel, cobro, trabajo con reloj de partida, cancelar); recursos en T209; **extracción finita en T210** (habilitar con oro, producir al completar oleadas hasta agotar la reserva); demoledora y piezas, en T208 y T211)*. Una letra de la leyenda puede llevar **`removible`** (un objeto que se retira pagando oro y esperando) **o** **`extraccion`** (una mina o un bosque que produce recursos), nunca los dos. Ejemplo:

```json
"leyenda": {
  "t": {"removible": {"clase": "arbol"}},
  "r": {"removible": {"clase": "roca", "costo": 50, "probabilidad": 0}},
  "u": {"removible": {"clase": "escombro", "hallazgo": "technology"}},
  "m": {"extraccion": {"clase": "mina", "reserva": 6}}
}
```

  - **`clase`** es obligatoria: `arbol`, `roca` o `escombro` (removibles), `mina` o `bosque_explotable` (extracción). Los números de cada clase están en `data/obstaculos.json`, que se puede editar sin programar.
  - **Se pueden cambiar por letra**, solo para ese mapa: `costo` (oro), `tiempo` (segundos), `recursos` (cuántos entrega) y `probabilidad` (de 0 a 100, la chance de que los entregue) en un removible; `costo`, `produccion` y `reserva` en una extracción. Lo que no se escribe sale de la clase. Con `"probabilidad": 0` el objeto solo abre la casilla.
  - **`hallazgo`** (solo en un `escombro`) identifica una colección de `data/progression.json`, por ejemplo `"technology"`. Solo se recoge jugando la **campaña**, y un nivel solo puede tener una pieza por colección. La pieza solo cuenta si el id del nivel está en `sources` de esa colección en `data/progression.json`; si no, la ruina es común.
  - **Colecciones (`data/progression.json`, T211):** un diccionario `{id: {"required": N, "sources": [niveles], "origen": "portador" | "hallazgo", "nombre": "…", "icono": "res://…"}}`. `origen`, `nombre` e `icono` son opcionales (`portador` por omisión; sin `icono` se usa el disco plateado). `required` tiene que ser igual a la cantidad de `sources`: un test lo comprueba. Hoy: `technology` (5, portadores, niveles 1 a 5) y `disruptor` (3, hallazgo, niveles 8 a 10). La torre que una colección desbloquea es el `required_collection` de su `.tres`.
  - **`dibujo`** se puede omitir: es el de la clase. Si se escribe, tiene que ser el mismo.
  - Un removible **intacto** es una casilla bloqueada y **ya despejado** es pasto construible. **Nunca es camino**: los recorridos no cambian. Cuentan para el tope de letras (12; eran 10 hasta T234).
  - **`"demoledora": true`** (opcional, en el nivel, no en la leyenda) declara que el nivel habilita la demoledora. La pestaña **Infraestructura** de la barra de abajo (M53, RF-457) permite comprarla una vez por 180 de oro; después cada demolición cuesta el 10 % (mínimo 5) y tarda el 80 % del tiempo de clase. El editor lo conserva y lo edita (casilla *Demoladora disponible* en Ajustes). El ejemplo jugable `tools/ejemplos/mapa_demoledora.json` tiene cinco removibles, cuatro rocas para comprobar la amortización, y una mina. Para probar el bot de balance con infraestructura hay un mapa más largo, `tools/ejemplos/mapa_extraccion.json` (30 removibles pegados al camino, una mina, un bosque explotable, demoledora y el Mortero y el Francotirador, 6 oleadas).
  - **Errores comunes:** `removible` y `extraccion` en la misma letra; `construible: true` en un removible; una `clase` que no existe (el mensaje lista las que hay); `hallazgo` fuera de un `escombro`; dos `hallazgo` de la misma colección en un mismo nivel. **Avisos:** `demoledora` en un mapa sin removibles, y una torre que cuesta recursos en un mapa sin forma de conseguirlos.
  - Los dibujos `escombro`, `mina` y `bosque_explotable` se suman a la lista cerrada de arriba.
  - **Arte aprobado T277:** los PNG de `assets/sprites/map/rendered/` se precargan en `MapDrawings`: mina y bosque tienen estados inicial, activo y agotado; escombros, intacto y en trabajo. `LevelDecor` sigue las señales de `ObstacleField`; sin campo (editor), muestra el estado inicial. La marca de demolición, los velos y la reserva siguen superpuestos. No se agregan ids de leyenda para los estados.
  - **Estatuas de torres T277 (RF-515):** `estatua` sigue siendo decoración de una casilla: sin selección, panel ni alcance. Las variantes Cañón, Francotirador y Ametralladora se eligen con `posmod(x + 7*y, 3)`; musgo por omisión y escarcha si el tema es `nieve`. Los niveles 1, 3 y 5 conservan sus cinco posiciones; el 13 no trae estatuas y no se agregaron. La decoración automática de casillas bloqueadas no cambia.
  - **Central T277:** `central_1` a `central_4` consumen cuatro PNG de 128×128 (NO/NE/SO/SE), derivados de un mismo máster de 256×256 aprobado en T267b. Conserva las cuatro casillas del nivel 15. Fuentes y prompts en `art/t267b/`; capturas de integración en `art/t277-integracion/`.
  - **Mapa con recursos:** tiene recursos si algún removible puede entregarlos (`probabilidad` y `recursos` mayores que 0) o si tiene una mina o un bosque. Solo entonces el HUD muestra el contador. **Todo mapa de la campaña con recursos tiene que poderse ganar sin usarlos** (el bot lo comprueba con la estrategia `sin_recursos`).
- **Errores comunes:** una letra usada en el mapa que no está en la leyenda ("Letra desconocida"), un nombre de dibujo o de tema mal escrito (el mensaje lista los que existen) y una letra de la leyenda que no se usa (solo un aviso).
- **Un dibujo nuevo** (para el catálogo) es un SVG de 64×64 en `assets/sprites/map/` que sigue `specs/05-guia-de-arte.md`, y un nombre nuevo en `scripts/logic/map_drawings.gd`. Un tema nuevo es una paleta y una lista de decoración en `scripts/logic/map_themes.gd`.
- El editor de mapas **conserva** el tema y la leyenda al abrir y guardar. Desde M50 (T212) también **edita** los removibles y la extracción de la leyenda, `"demoledora"` y `"torres"` (ver la tabla del editor, más arriba). Lo que sigue siendo a mano: el tema y las letras de decoración. Al guardar, los números de la leyenda quedan como decimales (`50.0`): es lo mismo que `50` para el juego.

---

## Mapas de la comunidad: instalar y compartir

Cualquier persona puede sumar mapas al juego **copiando un archivo**, en cualquier versión (Windows o Linux; en el celular no). No hace falta el editor ni programar (spec §10.4).

**Instalar un mapa:** copiar el archivo `.json` a la carpeta de mapas:

| Sistema | Carpeta |
|---|---|
| Windows | `%APPDATA%\Godot\app_userdata\JuegoA\maps` |
| Linux | `~/.local/share/godot/app_userdata/JuegoA/maps/` |

Lo más fácil: en el juego, **Jugar → solapa "Mapas de la comunidad" → "Abrir carpeta de mapas"** (la crea si no existe). Al volver a la selección de nivel, el mapa aparece solo, sin reiniciar el juego.

**Compartir un mapa:** se manda el archivo (por Discord, mail, itch.io…). Los mapas hechos con el editor se guardan en esa misma carpeta, así que ya están ahí.

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

La **Wiki** (menú principal) tiene cinco categorías (Enemigos, Torres, Colecciones, Guía y Lore):

| Categoría | De dónde sale | Qué hay que hacer |
|---|---|---|
| **Enemigos** | Un `.tres` de `data/enemies/` | Nada: se agrega sola, ordenada de más débil a más fuerte. Los números salen del `.tres` y "dónde aparece" sale de la campaña. Es un **bestiario**: cada enemigo aparece "???" (en silueta) hasta que el jugador lo ve en una partida; el enemigo nuevo queda cerrado para todos hasta que se lo cruzan. |
| **Torres** | Un `.tres` de `data/towers/` | Nada: se agrega sola, de la más barata a la más cara. |
| **Guía** | Un `.json` de `data/wiki/` | Escribir el artículo (abajo). |
| **Lore** | Un `.json` de `data/wiki/lore/` | Escribir el artículo con su `"desbloqueo"` (al final de esta sección). |

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
- **Lore** *(M52, RF-469 y RF-470, T228)*: la categoría después de la Guía, con artículos en `data/wiki/lore/` (subcarpeta: la Guía no los ve). Tienen el mismo formato que los de la Guía **más la clave obligatoria `"desbloqueo"`**: el id de un nivel **que figure en `data/campaign.json`** (por ejemplo `"level_08"`); el artículo se abre cuando el jugador gana ese nivel (sale del guardado, no hay campo nuevo). Antes se ve como «???» con *«Se abre al ganar el nivel N.»* (el número, nunca el nombre ni nada del contenido) y la solapa cuenta «Lore 3/7». En el modo de pruebas está todo abierto. Un artículo sin `"desbloqueo"`, o con uno que no está en la campaña, no se muestra y hace fallar `tests/test_lore_wiki.gd`. Los 10 artículos oficiales son los de `specs/11-textos-lore.md` §4; **los de los niveles 11, 14 y 15 no se ven hasta que esos niveles entren en la campaña** (T229 a T234), y entonces aparecen solos.

---

## Revisar el balance con el bot

El bot juega solo, a toda velocidad, e imprime cómo termina:

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=6
```

- Estrategias: `smart` (las 4 torres de siempre), `mix` (las 8 torres), `heavy` (como `mix` más Morteros, M19), `basic` (solo Ametralladoras) y `naive` (torres al azar).
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

## Fondos M26
Los siete temas, el camino y las rocas, árbol, arbusto y puerta usan los nuevos PNG renderizados. Se aplican en partida, menú y editor; rutas y casillas construibles conservan sus reglas. Recursos en `assets/tiles/rendered/` y `assets/sprites/map/rendered/`.

### Arte M27 en revisión
Propuestas de niveles2/3 de las nueve torres (ocho vistas por nivel) y cinco monstruos especiales en `art/redesign-m27/`. Incluye atlas, iconos, muestras en Godot, fuentes y guía de integración; todavía no cambia los recursos que usa la partida.

### M27 aplicado a la partida
Las nueve torres usan mecanismos nuevos en niveles 2 y 3. Guardián, Curandero, Chamán, Espejo y Jefe usan sus PNG renderizados estáticos. Se conservan balance, habilidades y nivel 1 de las torres. Capturas en `art/m27-integracion/`.

### Recursos visuales M29
Los13 `data/enemies/*.tres` apuntan a `assets/sprites/enemies/rendered/`. `visual_scale=1.2` cambia solo el cuerpo, sin alterar `size_tiles` (selección/colisión). `walk_atlas` opcional:1024×1024, cuatro pasos por fila, filas derecha/abajo/izquierda/arriba; `walk_stride_tiles` es la distancia de un ciclo. `walk_art_scale` compensa el encuadre distinto del atlas frente a la pose fija (1.066 normal,1.335 rápido,1.19 tanque), siempre con pies en la fila191. `flight_atlas`:512×512, cuatro cuadros256 en2×2; `flight_frame_seconds=0.16`. Sin atlas se usa la pose fija. No reflejar dibujos con luz propia.
Las bases compartidas de niveles1/2/3 y los24 cuadros del cañón adoptan C. `TowerVisual.MOUNT_OFFSET` define el encastre, compartido por partida, disparo e iconos compuestos. Los atlas conservan512×256 y cuadros128. Las otras ocho torres conservan sus mecanismos aprobados y usan el nuevo asiento/contacto.

### Reflejos por nivel
`assets/shaders/tower_upgrade_glow.gdshader` añade luz sobre píxeles claros del mecanismo, conservando el alfa. `TowerVisual.upgrade_glow_strength` define intensidad visual:0/0.5/1 para niveles1/2/3; `upgrade_glow_color` define la familia. Tower reutiliza AtlasTexture y material propios, con tiempo físico; no cambia datos de balance ni sombras.

### Ciclos restantes M31
Blindado, Troll, Araña, Cría, Guardián, Curandero, Chamán, Espejo y Jefe: nueve atlas1024×1024, cuatro filas Este/Sur/Oeste/Norte y cuatro fases por fila. Cuadros256×256 y apoyo191, calibración uniforme por especie. Se conservan los PNG estáticos para la Wiki. Caminata integrada; no se agregan ciclos de ataque ni muerte.

### Monitor M32
Solo métricas locales: FPS de Engine y ms/cuadro estimados como1000/FPS; actualización cada500ms con reloj real, independiente de velocidad de juego. No equivale a medir tiempo de CPU/GPU ni envía datos.

### Tema de interfaz M33
`assets/ui/menu_theme.tres` reúne botones, deslizadores, casillas, desplegables y entradas. Iconos SVG propios en `assets/ui/`; paneles en `game_panel_style.tres`. Se aplica por pantalla, sin tema global.

### Variantes Android M34
Preset Android sin feature especial; Android (pruebas) incluye `pruebas`. Identificadores separados y versión1.1-pr1/code2; las exportaciones incluyen recursos actuales y excluyen tests/tools/specs/art/GUT.

### M36 · Efectos y audio
Los efectos de muerte reutilizan automáticamente textura, cuadro y escala del enemigo actual; no necesitan un asset de muerte por especie. Residuo y fragmentos son visuales y no alteran recompensa/crías. El audio se regenera con tools/make_sounds.gd; music_menu/music_combat usan bucle en importación. Material y límites de efectos se documentan en plan/spec; los candidatos de B-22 y recetas B-23 son propuestas y todavía no forman parte del formato de contenido.

### M37 · Avances y apoyo
data/progression.json define colecciones/fuentes/cantidad requerida; solo fuentes oficiales permiten drops. TowerData puede exigir una colección y ser support_only; TowerLevelData declara support_rate_percent. El mecánico se habilita con torres_extra en6–9 más colección5/5; admin lo habilita sin modificar el progreso. Ladrón/desgaste/reparación están implementados; niveles8/9 integrados en M45. Niveles10–15 continúan pendientes.

### M39 · Encuentros opcionales y drenaje
Un grupo de oleada puede declarar `"probabilidad":0.35`; ausencia equivale a1. El sorteo ocurre una vez por oleada/grupo. `EnemyData.optional_wave_limit` limita el total sorteado de ese tipo. `gold_drain_amount`, `gold_drain_interval` y `gold_drain_floor` habilitan drenaje combinable; cero lo apaga. Ladrón:3/2s/piso10, una aparición opcional por oleada. Sus cifras se modifican en data/enemies/thief.tres; introducción6/7 y mayor presión8/9,1–5 intactos.


### M40 · Carga y desgaste
EnemyData: `charge_distance_tiles`, `charge_multiplier`, `charge_slow_tolerance`, `charge_impact_radius_tiles`, `charge_wear_percent` (cero apaga). Embestidor: preparación3 casillas, velocidad×1.8, slow hasta20%, impacto20% a una torre a≤1.25 casillas del extremo; `data/balance.tres` limita desgaste a50%. No se destruyen torres. La Bestia B de M24 se reutiliza como diseño inicial. Nivel6: oleada10; nivel7:9/14/18.1–5 sin nuevos enemigos.


### M41 · Reparación
`TowerLevelData.support_repair_per_second` expresa puntos porcentuales de desgaste por segundo,0 desactiva. Mecánico2/3/4, costos y rangos intactos. Mayor tasa activa por radio, sin apilar ni autorreparar; otras fuentes sí pueden reparar estandartes. Desgaste de la fuente reduce tasa y bonus proporcionalmente. Pausa/velocidad afectan reloj; stun del reparador lo apaga, stun del receptor no impide recuperar desgaste ni se acorta.


### M42 · Catálogo y arte pendiente
El selector de Pruebas sigue leyendo todos los EnemyData. La lista larga se desplaza dentro del popup y la rueda sobre el selector cerrado cambia el elegido. No hay nuevos ids ni cambios de balance. Los rediseños concretos quedan en B-31; todavía no se reasignan recursos Curandero/Embestidor.

### M43 · B31
PNG versionados *_m43 y ciclos 1024×1024 de Embestidor/Curandero/Ladrón; estáticas256×256 en Wiki. Mecánico128×128 con casco/engranaje y bases compartidas. Sources, prompts, pack.gd, manifest, captura y preview animada en art/redesign-m43. Los originales anteriores quedan conservados para comparación; no cambian ids ni estadísticas.

### T190 · Arte aprobado y paquetes
Lucas aprobó los cuatro diseños M43, B31 cerrado. Dos EXE y dos APK normal/pruebas disponibles en build; los paquetes incluyen las nuevas estáticas y ciclos. No modifica comportamiento ni balance. Validación APK estática, sin prueba física móvil.

### T191 · Laboratorio6/7

Perfiles de compra/ubicación/mejoras y variantes de frecuencia viven en art/balance-m44, modifican recursos solo en memoria y no son presets de campaña. Exposure.json registra celdas realmente amenazadas al final de rectas y reparación20→0 en10/6,7/5s. El cierre de reparación elimina residuos de coma flotante; no cambia tasas ni costos. Consultar README del laboratorio antes de usar sus resultados para diseñar8/9.

### M45 · Niveles8/9

Campaña ampliada con level_08 (Bastión) y level_09 (Taller asediado). JSON en formato canónico del editor; torres_extra permite Mecánico, sin nuevas fuentes de colección. Guardián debuta en8/oleada4 y Curandero en9/oleada5; robos opcionales comienzan6 y embestidas8, con combinaciones posteriores. Carga/auras/desgaste/reparación reutilizan recursos existentes y no cambian sus estadísticas. Datos y recorridos1–7 intactos. Detalle, bots/capturas y límites en art/campaign-m45/README.md.

**M61 (T282):** en `level_09.json`, la letra `e` de los tres escombros comunes está al 100 % y garantiza 1 recurso por escombro; la ruina `u` con la pieza no da recursos la primera vez (RF-428). La estrategia específica juntó los 3 recursos, pero perdió en la oleada 3 con 0 vidas y 136 de oro, sin comprar el Mortero; pasó en las 5 semillas. No se cambiaron los costos; falta la partida humana de T283.

### T225 · Nivel 10 (La mina vieja)

`data/levels/level_10.json`, último de `data/campaign.json`. Es el **único nivel oficial de mapa grande** (24 × 11, RF-250) y de tema `desierto`, con las ruinas de los niveles 8 y 9 contadas por la leyenda (`p` columna, `s` señal con la marca G2 de los Moradores, `u` y `e` escombros). Su leyenda usa 6 de las 12 letras: `u` escombro con `hallazgo: disruptor` (la pieza 3/3), `e` escombro común (1 recurso al 50 %), `r` roca removible (1 recurso al 50 %), `m` mina (clase `mina`, sin sobrescribir: 100 de oro, 2 por oleada, reserva 8), `s` y `p` decoración. Para cambiar la dificultad sin tocar el mapa se mueve `aumento_vida` (30) y, con cuidado, las cantidades de las oleadas: con 33 `sin_recursos` ya pierde 2 de 5, así que **después de cualquier cambio** hay que correr `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1 levels=10` (regla de oro, RF-432). Es un mapa de **espacio limitado** (43 casillas libres, ver §7.12 de la spec): agregar casillas libres lo vuelve más fácil para todos los bots. La exposición del Embestidor y la captura están en `art/campaign-t225/`.

### M58 · Interfaz para el celular (spec escrita; todavía no está en el juego)

El modo celular (RF-502 a RF-515, D-097) **no agrega enemigos, torres ni niveles**, pero tiene un archivo de números ajustables en **`data/ui/mobile_ui.json`**. Ahí van el alto de los botones de la barra (56 px), el de la barra de arriba (64 px), el tamaño mínimo de los botones flotantes (64 px o 6 mm), cuánto debe moverse un dedo para dejar de ser un toque (2 mm), los segundos de «Vender» armado (3 s), la espera mínima entre los dos toques de «Vender» (0,4 s), el bloqueo de «Mejorar» (0,35 s), la opacidad con fantasma (45 %) y la casilla máxima del zoom (64 px, tope 1,0 según D-205). Un archivo dañado usa los valores por omisión.

- **Lo que cada jugador elige** no es contenido: se guarda en su `save.json`. La opción **«Interfaz»** (Automática / Celular / PC) está en `settings` como `ui_mode`, y la **posición de los botones flotantes** en la clave nueva `ui_prefs` (`cart_side`, `cart_y`, `exit_side`, `exit_y`). Sin ellas el juego usa los valores por omisión.
- **Las tarjetas de nivel con Insignias** (RF-514) muestran **las torres que ya ofrece cada nivel**: no hay nada para agregar a mano.
- **Las estatuas de los mapas** serán estatuas de torres de piedra (RF-515, D-098, `specs/05-guia-de-arte.md` §9). Hasta que T277 las dibuje, los niveles 1, 3 y 5 siguen con la estatua de hoy.

### M61 · Menús del celular y entrada por dispositivo (RF-550 a RF-555, D-115 a D-117)

No agrega enemigos, torres ni niveles. **Sí suma números que se ajustan sin programar**, en `data/ui/mobile_ui.json` (los mismos que ya usa el modo celular; si falta uno, el juego usa su valor por omisión):

- **Menús táctiles:** `boton_alto_px` (56: alto mínimo de todo botón de menú en el celular), `menu_deslizador_alto_px` (44: alto de los deslizadores de volumen), `scroll_umbral_px` (12: cuánto puede moverse el dedo y seguir siendo un toque), `scroll_friccion` (4,0: cuánto frena la inercia; más alto = frena antes), `scroll_velocidad_min_px` (30: debajo de esta velocidad la inercia se corta) y `scroll_barra_px` (22: ancho de la barra de desplazamiento).
- **Mouse y toque a la vez:** `puntero_duplicado_ms` (500) y `puntero_duplicado_px` (32): un clic que cae dentro de ese tiempo y esa distancia de un toque se toma por duplicado y se descarta.
- **La versión del juego** (RF-554) **no** está en ese archivo: es `config/version` en `project.godot` (hoy `"beta"`). Se cambia **solo ahí**.

### T243 · El Coloso, jefe supremo del nivel 15 (diseño aprobado; todavía no está en el juego)

El jefe del último nivel es un ejemplo de **un enemigo que se parte con solo datos**, igual que la Araña y sus Crías: **dos archivos en `data/enemies/`**, sin tocar el código (RF-481 a RF-484, D-092).

- `colossus.tres` (**Coloso**): vida 600, velocidad 0.5, armadura 5, resiste la mitad de la ralentización, quita 12 vidas y da 200 de oro. Su `death_spawn` es `colossus_shard` y su `death_spawn_count`, 3.
- `colossus_shard.tres` (**Pedazo**): vida 180, velocidad 1.0, sin armadura, quita 4 vidas y da 30 de oro. No suelta nada.
- **El Pedazo no se pone en ninguna oleada:** solo lo suelta el Coloso, como la Cría. Los grupos de `level_15.json` nombran únicamente a `colossus`.
- **Los números son los de RF-481 y T234 no los cambió:** midió con el bot que ningún Pedazo ni Coloso llega a la salida con la defensa que arma (ver el Resultado de T234); el balance del nivel se mueve con `aumento_vida` y con las cantidades de las oleadas 26, 28 y 30 de `level_15.json`, no con estos dos archivos. Aparecen solos en la Wiki ("Enemigos") y el texto de lore del Coloso está en el artículo «La Central» (`specs/11-textos-lore.md`).
- **Para hacer un enemigo parecido** (uno que se parte al caer): duplicar `spider.tres`, cambiar `death_spawn` por el enemigo-hijo y `death_spawn_count` por la cantidad, y cuidar que **las vidas del hijo × la cantidad** no superen las del padre si no querés que matarlo salga más caro que dejarlo pasar (acá: 4 × 3 = 12).
### T253 · La Cuadrilla: el Ratero y el Cargador (niveles 7, 10, 13 y 14)

Una banda de criaturas independientes que roban en grupo, hecha **solo con datos que ya existían** (RF-485 a RF-491, D-094): dos archivos de `data/enemies/`, cuatro apariciones en cuatro niveles y un artículo de la Wiki. No hay campo ni sistema nuevo: el robo es el mismo del Ladrón (`gold_drain_*`).

- `ratero.tres` (**Ratero**): vida 14, velocidad 2.2, sin armadura, da 5 de oro y quita 1 vida. Roba **2 de oro cada 2 s, sin bajar de 10**. Tamaño 0.20.
- `cargador.tres` (**Cargador**): vida 110, velocidad 0.9, armadura 1, da 30 de oro y quita 2 vidas. Roba **4 de oro cada 2 s, sin bajar de 10**. Tamaño 0.33.
- **`optional_wave_limit` queda en 0** (no tienen el tope «uno por oleada» del Ladrón): en un grupo de 8 Rateros salen los 8. Cada uno roba **en su propio reloj**.
- **Dónde salen:** en `level_07.json` (oleadas 8, 11, 13 y 16) y `level_10.json` (8, 12, 14 y 16), `level_13.json` (10, 13, 15 y 18) y `level_14.json` (10, 13, 15 y 18), siempre como **dos grupos al final de la oleada**: `ratero` con `"cada": 0.4` y `cargador` con `"cada": 3.0`, sin `desde`, sin `probabilidad` y por la entrada por omisión (la A). Son 6 + 1, 8 + 1, 8 + 1 y 10 + 2. **Para moverlos** basta cambiar `cantidad` o pasar los dos grupos a otra oleada; la regla es **no ponerlos en una oleada con Guardián, Curandero, Chamán, Espejo ni jefe** (no se midió) y **no en el nivel 6, el 8, el 9, el 11, el 12 ni el 15** (RF-487).
- **Para ajustar un nivel con ellos** (RF-488): primero la cantidad o la oleada de la Cuadrilla, después sacar relleno de esa oleada y recién último el `aumento_vida`. El bot (`sin_recursos`, 5 semillas) tiene que ganar al menos 4 con 3 vidas o más, el 14 con 3 o más y el 15 con 2; la tabla del bot ahora trae también la columna **«oro robado»**.
- **Arte provisional:** los dos **no tienen `texture` ni `walk_atlas`**, así que se dibujan como forma geométrica (Ratero: rombo ocre; Cargador: hexágono marrón, RF-156). La tarjeta y la barra de próxima oleada los muestran con esa forma; la Wiki los lista **sin ilustración** hasta que T257 los dibuje. Al agregarles dibujo hay que sacarlos de la lista `PROVISIONAL_ART` de `tests/test_content.gd`, `test_wiki.gd` y `test_bestiary.gd`.
- **Wiki:** las dos entradas de Enemigos salen solas de los datos (línea «Robo» y «Dónde aparece: niveles 7, 10, 13 y 14»). El artículo de Lore **«La Cuadrilla»** es `data/wiki/lore/la_cuadrilla.json` (`orden` 6, se abre al ganar el nivel 7, texto de `specs/11-textos-lore.md` §4.11); los artículos de las ruinas en adelante pasaron a `orden` 7 a 11.
- **Asedio:** con los 15 mapas, los niveles 7, 10, 13 y 14 de Asedio heredan las oleadas y, con ellas, **la Cuadrilla**. Lucas decidió que el 7 la hereda; T258 bajó su porcentaje de vida a 101 %, el mínimo permitido, y aun así una semilla del bot termina con 1 vida: queda para que Lucas decida (ver el Resultado de T258 en `specs/03-tareas.md`). Para quitársela a un mapa alcanzaría con una copia en `data/modos/asedio/` sin esos grupos (y sacar su entrada de la tabla si ya no hace falta).

### T229 · Nivel 11 (Puesto seco)

`data/levels/level_11.json`, último de `data/campaign.json`. Mapa de **24 × 11**, tema `desierto`, **una entrada** (A, arriba a la izquierda) y la salida abajo a la derecha. Su leyenda usa 5 de las 12 letras: `e` escombro común y `r` roca removible (1 recurso al 50 %), `m` mina (clase `mina`, sin sobrescribir), `w` agua (los pozos: no se construyen) y `h` `roca_marcada` (el `hito` de la biblia, hasta que llegue su dibujo). Es el primero con el campo `"torres"` del bloque 3 (RF-474: las torres de la campaña **menos la Ametralladora**; la Disruptora y el Mecánico aparecen solo con su colección) y con `"demoledora": false`. Para cambiar la dificultad sin tocar el mapa se mueve `aumento_vida` (27): con 28 `sin_recursos` gana con solo 1 vida, así que **después de cualquier cambio** hay que correr `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1 levels=11` (regla de oro, RF-432) y mirar que las oleadas 1 a 3 no pierdan vidas. La oleada 14 (Guardianes, Curanderos, Trolls y un Chamán) es un precipicio de dificultad. **El bot sin Ametralladora** abre con `NO_BASIC_ORDER` (Cañón y Hielo; `tools/balance_sim.gd`). La partida de verificación con la escena real y las tablas del bot están en `art/campaign-t229/`.

### T230 · Nivel 12 (Cañadón)

`data/levels/level_12.json`, de **26 × 11** y tema `desierto`, con **una entrada** y cinco patas verticales (un zigzag de 76 casillas). Su leyenda usa 4 letras: `e` escombro y `r` roca removibles (1 recurso al 50 %), `b` **bosque explotable** (clase `bosque_explotable`, sin sobrescribir: 100 de oro, 2 por oleada, reserva 8) y `h` `roca_marcada` (el `hito`). `"torres"` de RF-474 y `"demoledora": false`. Es de **espacio limitado** (45 casillas libres, 4 bloques de 2×2): agregar casillas libres lo vuelve más fácil. Para cambiar la dificultad se mueve `aumento_vida` (27) y, con cuidado, las oleadas 14, 20, 22, 23 y 24, que tienen **precipicios** (el Soberano que se escapa cuesta 10 vidas de golpe); **después de cualquier cambio**: `godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x check_rule=1 levels=12`.

### T231 · Nivel 13 (Paso alto)

`data/levels/level_13.json`, de **26 × 12**, tema `nieve` y **dos entradas** (A y B) que se unen en la casilla (2,6): los dos recorridos comparten un tronco hasta la salida. Su leyenda usa 6 de las 12 letras: `e` y `r` removibles (1 recurso al 50 %), `m` mina y `b` bosque explotable (una fuente por entrada), `i` **hielo** (la laguna: no se construye) y `h` `roca_marcada` (el `hito`). `"torres"` de RF-474 (sin Ametralladora ni Lanzamisiles) y `"demoledora": false`. **La escolta** se escribe con tres grupos del mismo `desde` y la misma `entrada` (`guardian`, `healer`, `shaman`), p. ej. `{"enemigo": "guardian", "cantidad": 2, "cada": 3.0, "entrada": "B"}` más los otros dos con el mismo `desde`. Para cambiar la dificultad se mueve `aumento_vida` (40; con 41 el bot gana con 1 vida y con 42 pierde) y, con cuidado, las oleadas 14, 22 y 23, que son **precipicios**. **Después de cualquier cambio:** `... -s tools/balance_sim.gd -- x check_rule=1 levels=13`.

### T420 · Los consejos de la pantalla de derrota (`data/consejos/consejos.json`)

El consejo que sale al perder se retoca con un archivo, sin programar: `{"version": 1, "borrador": true, "ajustes": {…}, "criterios": {…}, "reglas": [ … ]}`.

| Parte | Qué es |
|---|---|
| `"ajustes"` | `peso_oleada` (cuánto pesan los enemigos de la oleada final frente a los que ya se colaron; hoy 0,25), `participacion_minima_pct` (qué parte del peso total tiene que explicar una regla; hoy 30), `vidas_minimas` (menos que esto, no hay consejo; hoy 3), `max_torres` (cuántos nombres de torre; hoy 2) y `max_caracteres` (largo máximo de una frase ya armada, para que entre en 2 líneas; hoy 90). |
| `"criterios"` | Qué torres cuentan como «de golpe alto», «que golpean el aire», «de fuego»… Cada criterio mira los **números del nivel 1 de la torre**: `golpea_aire`, `danio_min`, `quema_min`, `area_min`, `ralentiza_min`, `alcance_min` (números) y `multi`, `pulso` (sí/no). Si cambia el daño de una torre, el criterio la incluye o la saca solo. |
| `"reglas"` | Una por comportamiento de enemigo, **de lo más específico a lo más general** (a igual peso gana la primera). `"enemigo"`: `vuela`, `en_tierra` (no vuela), `aturde`, `rebota`, `roba_oro`, `embiste`, `suelta_crias` (siempre `true`) o `armadura_min`, `resiste_ralentizar_min`, `regenera_min`, `cura_min`, `aura_armadura_min`, `velocidad_min`, `vida_min` (números mayores que 0). `"torres"`: la lista de criterios que sirven, en orden de preferencia. `"texto"`: la frase, con `{torres}` donde van los nombres. |

- **Una regla solo sale si el nivel ofrece una torre que la cumple**: nunca nombra torres que no están. Si no, pasa a la siguiente regla con peso.
- **Un enemigo nuevo entra solo** si cumple una condición (por ejemplo, `armor = 4` entra en la regla de armadura). Un tipo de enemigo sin regla (el Normal, el Tanque flaco) simplemente no genera consejo.
- **Textos cortos:** una frase ya armada, con los nombres más largos, tiene que entrar en **2 líneas** (90 caracteres). No repitas números de otros datos.
- **Revisalo** con `godot --headless --path . -s tools/check_consejos.gd`: dice en castellano qué arreglar y además comprueba que cada regla aplique a algún enemigo y a alguna torre **reales**. Un archivo con errores **no se usa** (la derrota se muestra sin consejo).
- Los textos son **borrador** (`"borrador": true`) hasta que Lucas los apruebe.

### T330 · El tutorial del nivel 1 (`data/tutorial/tutorial.json`)

El tutorial se retoca con un archivo, sin programar: `{"version": 1, "borrador": true, "nivel": "level_01", "interfaz": {…}, "pc": [{"paso": "welcome", "texto": "…"}, …], "celular": [ … ]}`.

| Clave | Qué es | Límite |
|---|---|---|
| `"borrador"` | `true` mientras Lucas no aprobó los textos (solo avisa; se ve igual en el juego). Al aprobarlos, `false`. | Booleano, obligatorio. |
| `"nivel"` | El nivel donde se muestra. Hoy `level_01`. | Texto. |
| `"interfaz"` | Los rótulos de la tarjeta: `titulo`, `paso` (con **dos `%d`**: el número y el total), `siguiente`, `saltar` y `terminar`. | Hasta **40** caracteres cada uno. |
| `"pc"` y `"celular"` | Los pasos, **en orden**, de cada modo. | Ver abajo. |
| `"paso"` | Cuál de los pasos que sabe hacer el juego: `welcome`, `path`, `gold`, `lives`, `pick_tower`, `place_tower`, `open_cart`, `pick_card`, `confirm_tower`, `start_wave`, `select_tower`, `upgrade`, `sell`, `speed`, `pause`, `resume`, `done`. | `pick_tower` y `place_tower` **solo en PC**; `open_cart`, `pick_card` y `confirm_tower` **solo en el celular**; sin repetir. |
| `"texto"` | Lo que dice la tarjeta. | **1 o 2 líneas** (`\n`), **80 caracteres por línea**, **160** en total. |

- **Qué hace cada paso** (qué señala y qué espera) **es del juego**; el texto, el orden y cuáles se usan son tuyos. **Obligatorios:** `path`, `gold`, `lives`, `start_wave`, `upgrade`, `sell`, `speed`, `pause` y los de elegir y construir de cada modo. **Opcionales:** `welcome`, `select_tower`, `resume` y `done`. `pick_tower` va antes que `place_tower`; `open_cart`, `pick_card` y `confirm_tower` en ese orden; si hay `pause`, tiene que haber `resume` después; `done`, si está, al final.
- **No repitas números de otros datos** (costos, tiempos): explicá la regla y listo.
- **Revisalo** con `godot --headless --path . -s tools/check_tutorial.gd` (dice en castellano qué arreglar). Un archivo con errores **no se muestra** (el error sale en la salida) y el nivel 1 se juega sin tutorial.
- **Dónde se ve:** solo en el nivel 1 jugado desde el menú, una vez (se completa o se salta). Se apaga y se vuelve a ver en **Opciones**.

### M65 · La animación de mejora de torres (`data/ui/mejoras.json`)

El arte aprobado está integrado (M71): `assets/sprites/effects/mejora/upgrade_l2.png` y `upgrade_l3.png`, atlas de 4 × 2 cuadros de 192 px. Para los jefes, `assets/sprites/effects/jefe/` contiene el destello (4 × 2 cuadros de 256 px), la grieta (192 × 96) y el marco 9-slice (192 × 128, márgenes de 32). Los cinco PNG se importan sin mipmaps. RF-643 limita la importación de los atlas de mejora a 384 × 192 y del destello a 512 × 256; el código compensa con escala 2, sin cambiar tamaño visual ni pies. Los originales y los ocho cuadros permanecen intactos. Peso de los cinco PNG: 151.135 bytes (27.924 + 53.552 + 54.987 + 10.924 + 3.748); el límite de importación reduce 75 % los texels de los tres atlas, no el peso de sus originales.

Lo que aparece al mejorar una torre se retoca con un archivo, sin programar. **No hay que escribir ningún número de torre**: el texto («+3 daño · +0,5 disp/s») se calcula restando los niveles de `data/towers/<id>.tres`, así que si cambiás el daño de un `.tres`, el texto cambia solo.

| Clave | Qué es |
|---|---|
| `"variantes"` | `refuerzo` (nivel 2) y `maestria` (nivel 3): `duracion_s` (mayor que 0), `cuadros` (para el arte definitivo) y `escala` (tamaño del efecto). |
| `"aclarado_blanco"` | Cuánto se aclara el color de la torre para el texto (0 a 1; 0,4 = 40 % de blanco). |
| `"fuente_base_px"`, `"fuente_min_px"`, `"fuente_max_px"` | Tamaño del texto: se compensa con el zoom del mapa para medir entre el mínimo y el máximo **en pantalla** (20 a 30 px). |
| `"texto_duracion_s"`, `"texto_sube_px"`, `"escalonado_s"` | Cuánto dura el texto, cuánto sube y el retraso entre renglones. |
| `"max_estadisticas"`, `"max_por_renglon"` | Hasta 4 estadísticas, de a 2 por renglón. Si lo ves cargado, bajá el máximo. |
| `"tope_efectos"`, `"tope_textos"` | Cuántos efectos (8) y textos (4) pueden estar vivos a la vez. |
| `"estadisticas"` | La tabla, **en orden de prioridad**: `campo` (un campo de `TowerLevelData`), `etiqueta` (lo que se lee), `formato` (`entero`, `decimal` o `porcentaje`) y, opcional, `escala` (100 para `slow_amount`, que se guarda como fracción). |

- **Solo se muestra lo que cambió** entre niveles (con tolerancia de 0,005). El costo, las texturas, `bonus_vs_*` y `chain_range_tiles` no están en la tabla: si algún día cambian y querés mostrarlos, sumá una línea.
- **Si agregás un campo nuevo** a `TowerLevelData` que cambia entre niveles, sumalo a la tabla: un test (`test_upgrade_deltas.gd`) avisa si falta.
- **La misma tabla arma el «antes → después»** (M68, RF-616 a RF-618): el panel de la torre en la PC (filas «Daño 5 → 8», «Alcance 3 → 3,5» y frases de efecto como «El rayo salta a 2 → 3 enemigos más») *(M75 y T512/D-214, hecho en T513: el bloque «Al nivel N:» ya no existe; las filas salen de esta tabla —daño, disparos por segundo y alcance— y la frase de cada efecto la arma `TowerText.effect_phrases` con las plantillas de siempre, no con las etiquetas de esta tabla)* y la barra de abajo del celular (la parte de abajo del botón «Mejorar», «daño 13 → 19 · disp/s 0,75 → 0,85»; *T514, RF-722: ya no hay renglón «Al mejorar:»*) muestran las estadísticas de esta tabla, en este orden y con este tope (`max_estadisticas` en la PC; `mejorar_cambio_max`, 2, en `data/ui/mobile_ui.json` para el celular). No hay un archivo aparte.
- **Revisalo** con `godot --headless --path . -s tools/check_mejoras.gd`. Con un error, el juego usa el valor por omisión de ese campo y sigue andando.
- **Se apaga** en Opciones → «Animaciones de mejora».

### T242 · La intro (`data/intro/intro.json`)

Las láminas son archivos **`.webp`** (sin pérdida, 1920 × 1080) en `assets/intro/`; Godot los comprime a calidad 0,90 al importar (D-150). La intro se arma con un archivo, sin programar: `{"version": 1, "fundido_s": 0.6, "laminas": [{"imagen": "res://assets/intro/01_la_nave.webp", "texto": "Línea 1\nLínea 2", "segundos": 7}, …]}`.

| Clave | Qué es | Límite |
|---|---|---|
| `"version"` | Versión del formato | Hoy **1** |
| `"fundido_s"` | Segundos del fundido entre láminas | De **0 a 2**; opcional (0,6) |
| `"laminas"` | Las láminas, en orden | De **5 a 8** |
| `"imagen"` | El PNG de la lámina | Ruta `res://` que existe; **1920 × 1080**, sin texto dibujado; el 22 % de abajo queda tranquilo (ahí va la franja) |
| `"texto"` | Lo que se lee abajo | **1 o 2 líneas** (`\n`), **90 caracteres por línea**, **160 en total** |
| `"segundos"` | Cuánto se queda sola la lámina | Entero de **4 a 12**; para poder leerla, al menos `2 + caracteres / 20` redondeado hacia arriba y nunca menos de 5 (lo revisa un test) |

Los textos oficiales son **los de `specs/intro/guion.md`**: si hay que corregir uno, se corrige primero ahí. Un archivo con errores no se muestra (el error sale en la salida) y «Jugar» sigue yendo a la selección de niveles. Para cambiar una lámina alcanza con reemplazar el PNG con el mismo nombre. **Hoy las siete son provisorias** (color liso con el número); las definitivas son de T241.

### T234 · Nivel 15 (Central) y el final

`data/levels/level_15.json`, de **26 × 12**, tema `pradera` y **tres entradas** a la izquierda (A arriba, C en el medio y B abajo) que se unen al principio de un tronco común y siguen juntas hasta la salida de la derecha (recorridos de 65, 76 y 70). Su leyenda usa las **12 letras** que permite `LevelFile.MAX_LEGEND` (D-093): `1`, `2`, `3` y `4` son los cuatro cuartos de la central (`central_1` a `central_4`, de arriba a la izquierda a abajo a la derecha), `d`, `p` y `v` las piezas de la cadena de abastecimiento (`supply_depot`, `supply_line_pole`, `supply_cart`; desde T549 son una nave exploradora destruida, un taller en ruinas y una pila de lingotes, en PNG de `assets/sprites/map/rendered/t527/`; `supply_conveyor` ya no existe), `m` mina y `b` bosque explotable (dos), `e` escombro removible (5, 1 recurso al 50 %), `c` `campamento_vacio` (3) y `s` `roca_marcada` (2). **La central** son cuatro casillas contiguas **al lado de la salida** (no la salida): para moverla basta cambiar esas cuatro letras de lugar, siempre en ese orden. `"torres"` de RF-474 y `"demoledora": false`. **No lleva al Soberano** (`boss`): el jefe es `colossus`, que se nombra en las oleadas 26, 28 y 30 (uno, dos y tres); la escolta completa (Guardián + Curandero + Chamán con el mismo `desde` y la misma `entrada`) acompaña al Coloso solo en la 30, por B y por C. La oleada 25 es un respiro a propósito. `aumento_vida` es 23: con 22 el bot sin recursos termina con 3 vidas y con 24 pierde; **después de cualquier cambio** `... -s tools/balance_sim.gd -- x check_rule=1 levels=15`.

**El epílogo y los créditos** no se arman con código: el texto del epílogo es el campo `"epilogo"` del nivel 15 (de 3 a 5 líneas, RF-464) y los créditos están en `data/creditos.json` (`{"version": 1, "lineas": ["…", …]}`, hasta 40 líneas de 90 caracteres). Hay **dos imágenes** (16:9, 1920×1080; si no entran se recortan): `assets/sprites/story/epilogue.png` (luminosa) si los 15 niveles tienen 3 estrellas, y `assets/sprites/story/epilogue_dark.png` (tormenta lejana) en cualquier otro caso (RF-729); se elige al abrir el epílogo y no se guarda. Si falta una, se ve un fondo liso. El botón «Epílogo» aparece solo en el último nivel de la campaña, jugado desde la campaña, y solo si ese nivel trae `"epilogo"`.

### T232 · Nivel 14 (Poblados)

`data/levels/level_14.json`, de **26 × 12**, tema `ruinas` y **dos entradas** a la derecha (A arriba y B abajo) que se unen en (23,6) y siguen juntas hasta la salida de la izquierda: es el trazado del nivel 13 **espejado**. Su leyenda usa 7 de las 12 letras: `e` y `r` removibles (las casas, 1 recurso al 50 %), `m` mina y `b` bosque explotable, `c` **`campamento_vacio`** (5), `s` **`simbolo_ruina`** (8) y `p` `columna` (5): las señales que culminan; las que cuentan son las cuatro o más de `campamento_vacio` y las seis o más de `simbolo_ruina` (RF-479). `"torres"` de RF-474 y `"demoledora": false`. Trae los 14 enemigos y las escoltas con el Espejo y Voladores. `aumento_vida` es 30: con 29 el bot gana con 11 vidas y con 33 pierde; **después de cualquier cambio** `... -s tools/balance_sim.gd -- x check_rule=1 levels=14`.

### M49 · Modos de juego (RF-388 a RF-392)

Un **modo** es un grupo de mapas con reglas propias. Aparece como una solapa en **Jugar** (la fila se desplaza si no entran todas): los oficiales después de "Campaña" y los propios después de "Mapas de la comunidad". **Récords** muestra el top 5 de cada modo por separado. No hace falta programar: es una carpeta con un archivo `modo.json`.

**Dónde va cada uno:**
- **Oficiales:** `data/modos/<id>/modo.json`, en el repositorio. Hoy existe **Asedio** (`data/modos/asedio/`, con los 15 mapas).
- **Propios:** `user://modos/<id>/modo.json`; en Windows, `%APPDATA%\Godot\app_userdata\JuegoA\modos\`. El editor de mapas los crea solo con **"En un modo…"**.
- El `<id>` es el nombre de la carpeta: minúsculas, números y `_`. Un modo propio no puede llamarse igual que uno oficial.

**Ejemplo** (`modo.json`):

```json
{
	"version": 1,
	"nombre": "Mis desafíos",
	"descripcion": "Tres mapas con pocas vidas.",
	"mapas": ["mi_mapa", "level_03", "level_05"],
	"torres": ["basic", "cannon", "frost"],
	"reglas": {"oro_inicial_%": 100, "vidas": 5, "vida_monstruos_%": 120}
}
```

**Las claves:**

| Clave | Obligatoria | Qué hace |
|---|---|---|
| `version` | Sí | Siempre `1`. |
| `nombre` | Sí | Lo que dice la solapa (hasta 30 letras). |
| `descripcion` | No | Se ve al pasar el mouse por la solapa (hasta 200 letras). |
| `mapas` | Sí | Los mapas en orden, sin `.json`. Cada uno se busca primero en la carpeta del modo y, si no está, entre los niveles oficiales (`data/levels/`). Así se pueden reusar mapas de la campaña sin copiarlos. Hasta 50; ninguno puede llamarse `modo`. |
| `torres` | No | Las torres que se pueden construir (ids de `data/towers/`). Sin esta clave, las de siempre. |
| `reglas` | No | `oro_inicial_%` (10 a 1000, sobre el oro del mapa), `vidas` (1 a 999, reemplaza las del mapa), `vida_monstruos_%` (10 a 1000, sobre la vida de cada monstruo) y `vida_monstruos_por_mapa_%` (M56, T258: un objeto `{"level_01": 105}` con el porcentaje propio de cada mapa; ver abajo). Sin reglas, el mapa se juega tal cual. |

**Vida de los monstruos por mapa** *(M56, RF-492, T258)*: dentro de `reglas`, `"vida_monstruos_por_mapa_%"` es un objeto con el id de un mapa y su porcentaje. Ejemplo: `"reglas": {"vida_monstruos_%": 115, "vida_monstruos_por_mapa_%": {"level_01": 105, "level_02": 108}}`. Cada mapa toma **su** porcentaje; el que no está en la tabla toma el `vida_monstruos_%` global y, si tampoco hay global, 100. Cada clave tiene que ser un mapa de `"mapas"` (un id que no está es un **error** que lista los del modo) y cada valor un **entero de 10 a 1000**. `{ }` vacío es válido y no cambia nada. No toca el oro, las vidas ni las torres. Una **versión anterior del juego rechaza** un modo con esta clave («clave desconocida»). El editor de mapas la **conserva** al guardar un mapa en el modo, pero no la edita: se escribe a mano.

**Progreso y desbloqueo:**
- Cada mapa de un modo guarda vidas, estrellas, puntaje y su top 5 aparte, con el id `modo_<modo>_<mapa>`.
- No cuenta para la campaña, el total de estrellas de la campaña, el Salón de la fama ni los avances.
- En un modo oficial, cada mapa se abre al ganar el anterior; en los propios, todos están abiertos. El modo de pruebas abre todo.

**Si algo está mal**, el juego no se corta: un `modo.json` roto muestra una sola tarjeta "Con errores" con el motivo, y un mapa que falta o tiene errores queda como tarjeta deshabilitada, mientras los demás se juegan igual.

**Balancear un modo oficial con el bot:**

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix modo=asedio level=2
```

Las opciones del bot para modos (T258): `mejoras=llenar` (cuando ya no queda casilla libre, mejora la torre de menor nivel y menor costo, una por frame, pagando como el jugador), `mejoras=temprana` (lo mismo desde las 3 torres) y `perfil=asedio` (los 15 mapas del modo con 5 semillas y la política fija de cada mapa de `tools/asedio_politicas.json`; imprime la tabla y el promedio de vidas por bloque y termina con código 1 si algún mapa no gana las 5 con 3 vidas o más o si los bloques suben). Cada partida imprime la variante que usó.

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- x perfil=asedio
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos modo=asedio levels=1-15 seeds=5 mejoras=llenar
```

**Asedio:** usa **los 15 mapas** de la campaña con el mismo oro, `vida_monstruos_%` 115 como regla global y una tabla `vida_monstruos_por_mapa_%` de 13 excepciones (de 101 % a 118 %; el 4 y el 15 toman el 115 % global). No hay ninguna copia de mapa en `data/modos/asedio/`: para cambiar la dureza de un mapa se cambia **su número en la tabla** de `data/modos/asedio/modo.json`. Los valores son **iniciales**: salen del bot (T255, y T258 para los mapas con la Cuadrilla) y se ajustan cuando Lucas juegue. Con 150 % y 80 % de oro, el bot perdía en la oleada 4.


## Editar los textos de la intro *(M62, RF-561 a RF-563)*

Los textos, los segundos de cada lámina y el fundido de la intro viven en `data/intro/intro.json`, pero **no hace falta tocar ese archivo**: se editan en un documento más cómodo, **`specs/intro/intro-editable.md`** (una sección por lámina, con el texto, los segundos, la imagen y un lugar para tus notas).

1. **Editá** el documento: el texto va debajo de `Texto:`, **cada línea con `> ` adelante**; los segundos van en `- Segundos:`; las notas, debajo de `Notas:` (no se cargan al juego).
2. **Probá sin guardar nada:** `godot --headless --path . -s tools/intro_doc.gd -- import --dry`. Muestra los cambios (`CAMBIA: lámina 5, texto: …`), los avisos y los errores.
3. **Pasalo al juego:** el mismo comando sin `--dry`. **Si hay un error, no cambia nada** y dice cuál es, con el número de línea o de lámina (por ejemplo «la lámina 3 tiene 3 líneas y el máximo es 2»).
4. **Volver a empezar** desde lo que carga el juego: `... -- export` (reescribe el documento y **conserva las notas**).

**Reglas** (las mismas que revisa el juego, RF-497): de 5 a 8 láminas; texto de 1 o 2 líneas, hasta 90 caracteres por línea y 160 en total; segundos enteros de 4 a 12; fundido de 0 a 2; la imagen tiene que existir. Un **aviso** (no un error) te dice si una lámina dura menos de lo que pide su texto para leerse (`2 s + caracteres / 20`).

**Dos cosas que conviene saber:**
- Los textos oficiales **también** están en `specs/intro/guion.md`, y un test (`tests/test_intro_data.gd`) los compara con `intro.json`. Si cambiás un texto con esta herramienta, **el test va a avisar** hasta que el guion diga lo mismo: pedile a Claude que lo actualice o corregilo vos.
- La herramienta **no crea imágenes**: el campo `Imagen` solo puede apuntar a un archivo que ya exista (por ejemplo, para reordenar láminas). Cambiar qué imagen va con qué texto cambia cómo se ve el juego: conviene hablarlo antes.

Si el documento y el JSON se desfasan (alguien editó uno solo), `tests/test_intro_doc.gd` lo avisa.


## Cómo agregar las novedades de una versión *(M67, RF-605 y RF-609)*

La pantalla «Novedades de esta versión» (se abre sola una vez por versión y se vuelve a ver en **Opciones → «Créditos y versión»**) lee **`data/novedades/novedades.json`**. Para sacar una versión nueva (por ejemplo, la 1.1.0) **no hace falta tocar código**:

1. **Subí la versión** en `project.godot` (`config/version`), y a mano `file_version` y `product_version` de Windows y `version/code` de Android (`export_presets.cfg`).
2. **Agregá al principio de `versiones`** una entrada con `"tipo": "mejoras"`, tus novedades y `"borrador": false`. `CHANGELOG.md` sigue siendo la fuente para armarla, pero **el juego no lo lee**. Dejá las entradas viejas: Opciones las usa como historial.
3. **Revisalo:** `godot --headless --path . -s tools/check_novedades.gd`. Da errores en castellano (con la versión y la novedad) y un **aviso** si la versión de `project.godot` es un número y no tiene entrada aprobada.

**La forma del archivo.** `version` (el formato, hoy 1), `interfaz` (los rótulos fijos: `entendido`, `titulo_novedades`, `titulo_mejoras`, `borrador`, `sin_novedades`) y `versiones`. Cada versión: `id` (**igual** que `config/version`), `tipo` (`"presentacion"` para la 1.0.0, `"mejoras"` para las siguientes), `borrador` (`true` hasta que el texto esté aprobado: **un borrador no sale solo**, pero se puede revisar desde Opciones), `titulo` (hasta 40 caracteres), `subtitulo` (opcional, hasta 80), `cabecera` (opcional, una imagen `res://` que exista) y `novedades`: **de 1 a 8**, cada una con `titulo` (hasta 40), `texto` (hasta 140 caracteres y 2 líneas) e `icono` (opcional, una imagen `res://` que exista).

**Reglas que conviene saber.** Las de tipo «mejoras» muestran arriba «Mejoras de esta versión» y no salen solas a un guardado nuevo (quien instala por primera vez no necesita saber qué cambió). **No sale** con `config/version` en `beta`, en el modo de pruebas ni desde el editor de Godot. **No escribas cifras** que puedan quedar viejas (cantidad de torres, de enemigos…): si hace falta una, `tests/test_news_content.gd` la compara con el juego. Un archivo con errores **no muestra nada** y el juego abre normal.


**Arte de Novedades (T375):** en `assets/ui/novedades/` están `news_header_1_0.png` (presentación, 4:1), `news_header_plain.png` (mejoras, 8:1) y los medallones `news_icon_<nombre>.png`, con nombres `map`, `tower`, `monster`, `siege`, `editor`, `mobile`, `book` y `upgrade`. Poné la ruta `res://` en `cabecera` o `icono` para usarlos. La cabecera se ajusta al ancho interior del panel sin recorte; el texto queda debajo. Los íconos miden 48 px en PC y 64 px en celular. Si omitís `icono`, queda un rombo de bronce; si omitís `cabecera`, no se reserva espacio. Importar sin mipmaps. La 1.0.0 sigue en borrador hasta aprobar los textos.

## Presentación de jefes (M66, T461)

La presentación pausa la campaña normal, dura 5 s la primera vez que el guardado ve a ese jefe y 3 s después, y no sale en Asedio ni en modo de pruebas. La opción conserva su clave (`boss_entrance`) y se llama «Presentación de los jefes»; en el menú sigue en la fila donde estaba (debajo de «Tutorial»): el agrupado «Partida y ayudas» todavía no existe en el código. La animación es por código sobre una ilustración quieta; el arte propio del Jefe y la ilustración del Coloso no están aprobados (T367); el fondo del Coloso entró en T548. El piloto viejo y sus assets se retiraron. Ver [M66](specs/01-spec.md), [T461](specs/03-tareas.md) y la [ficha de arte T367](specs/tareas/T367-arte-entrada-jefes.md).
## M76 · Mapa y postes de conquista (T459; spec, sin implementar)

El planeta será la vista inicial de campaña en PC/celular con migración de una vez y tarjetas alternativas. La geografía en serrucho oeste→este (atlas de T485, ruta B, aprobada por Lucas el 2026-10-25) ya está integrada por T471: `CampaignMap` (`REGION_POINTS`, `LANDER`, `ROUTE_CONTROLS`, `LAND_COORDS`) y `assets/ui/campaign_map_background.svg` salen de la misma fuente con `python3 -I art/t471-geografia/build_background.py`; no se retocan a mano por separado. Las insignias de conquista y la vista celular nueva (T469) siguen pendientes; el descubrimiento por zonas (T486 a T488) está implementado en `main` (estado actualizado 2026-10-26, T517). No modifica geografía jugable. Asedio N se habilitará con campaña N ganada, manteniendo accesos anteriores y guardados de pruebas separados (T472).

El círculo del número llevará fondo rebelde, partido con 1–2 estrellas o del jugador con 3. La receta del editor es solo estética. Se proponen 20 postes (1 por nivel 1–10, 2 por 11–15), rebeldes hasta 2 estrellas y del jugador con 3; reemplaza la regla anterior del 6. Las posiciones de T475 son candidatas sobre casillas permanentemente no construibles (incluidos los niveles 8 y 9, donde Lucas eligió el 2026-10-28 la casilla `(18, 1)`, que pasó de libre a `X` en su mapa) y requieren **OK de Lucas por cada uno de los 15 mapas** antes de integrar. No cambiar leyenda, casillas construibles, removibles ni recursos para hacerles lugar (única excepción aprobada: la `X` en `(18, 1)` de los niveles 8 y 9). M74 mantiene su editor desktop; no se habilita editor móvil por inferencia.


## «Ver todo», panel de mejora, alcance y Opciones (M75, T458; implementado en main)

**Estado (2026-10-26, T517):** M75 está implementado en `main` por T464, T466 a T468, T481, T513 y T514. Los pasos para comprobarlo están en [ONBOARDING.md](ONBOARDING.md). Esta actualización reemplaza el estado pendiente de T458; no cambia reglas de juego ni datos de balance.

- **Alcance de las torres.** La opción «Círculo de alcance» ofrece Oculto (por omisión), Sutil y Completo, en PC y celular. Los valores de dibujo se ajustan en `data/ui/alcance.json`; la preferencia se guarda en `settings.range_display`.
- **Panel de torre.** En PC, el panel muestra cada cambio una vez con «antes → después», dentro de la frase del efecto, sin bloque separado de mejora. En celular, CEL-B muestra el cambio que se compra dentro del botón «Mejorar». Las estadísticas salen de `data/ui/mejoras.json` y los decimales usan coma.
- **«Ver todo».** En PC no aparece un botón al acercar: se usa la tecla configurada. En celular aparece el botón con lupa al acercar; el aviso de una vez por guardado se activa solo ante zoom creciente. Los textos aprobados están en RF-676.
- **Opciones.** Las categorías son solapas superiores; en celular no aparece «Controles». Cambiar de categoría no modifica las preferencias.
- **Límite de verificación:** el ajuste CEL-B conserva una separación calculada de 35 mm y usa texto de 16 a 20 px; esto se midió en celular simulado, no en un teléfono real.

Ver [M75](specs/01-spec.md), [T464 a T468, T481 y T513/T514](specs/03-tareas.md).
## M77 · Fondos de franjas y de carga (T460; spec aprobada)

T478 integra los siete fondos aprobados del PR #66, asociados al tema del nivel en `data/ui/presentation_backgrounds.json`. Rellenan las franjas externas y los márgenes internos sin crear casillas ni cambiar leyenda/camino; quedan fijos respecto al zoom y se recortan en ejecución. El respaldo exterior es liso si el tema o el recurso no está disponible. El máximo de zoom es 1,0. **T532:** el brillo y la saturación de las franjas externas (no del viewport jugable) se ajustan en el bloque `franjas` del mismo JSON (`brillo` 0,55 y `saturacion` 0,6; 1,0 = sin cambio; se limitan entre 0 y 1).

La carga podrá reutilizar las láminas oficiales de intro, una por cambio y sin repetición consecutiva, con recorte en ejecución y sin texto narrativo. **No se implementa hasta agregar al informe T454 una medición del costo en celular real y obtener aprobación de Lucas con esos datos**. Si se aprueba, GameFlow inyectará la imagen al núcleo genérico; no se copian siete láminas a otro directorio ni se modifica su importación/resolución por inferencia. Color/barra siguen de respaldo y una imagen tardía no demora la escena. Ver RF-699–707 y fichas T476–479.

## Idioma e inventario de textos *(T533, RF-727; base interna, sin cambios visibles)*

- Los catálogos de idioma viven en `data/i18n/es.json` y `data/i18n/en.json`: una lista de `{"clave": "...", "texto": "..."}`. Las claves son en inglés y con puntos (`options.language.label`); los valores usan marcadores `{nombre}` (iguales en los dos idiomas) y los plurales se escriben como `clave.one` y `clave.other`.
- **T534 (en curso, tercera tanda):** ya leen el catálogo el menú principal, Herramientas, Opciones, la pausa, la salida, Récords, el HUD (PC y celular), el panel de torre, resultados y consejos, tutorial, selector de niveles, novedades, Wiki (fichas y Guía), los nombres y descripciones de torres y enemigos, el editor de mapas y de banderines, los mensajes de validación de mapas, modos y textos de nivel y el panel del modo de pruebas. Sigue en español el Lore (se traduce después de T545, D-222) y los mensajes de validación de los **datos de desarrollo** (tutorial, intro, consejos, novedades, Wiki, créditos y configuraciones), que solo salen por consola.
- **Cómo se traduce un dato sin tocarlo:** el archivo de `data/` (por ejemplo `data/towers/basic.tres`) conserva el español; el inglés va en `data/i18n/en.json` con la clave `tower.<id>.name` / `tower.<id>.description` (enemigos: `enemy.<id>.…`; modos: `mode.<id>.name`; consejos: `advice.<id>.text`; artículos de la Guía: `wiki.<archivo>.title`, `.subtitle`, `.b<n>`; tutorial: `tutorial.<pc|celular>_<paso>.text`; novedades: `news.v<versión>.…`) y el mismo par en `es.json` con el texto en español. Una torre o enemigo nuevo necesita sus claves en los dos catálogos (`tests/test_localization_en.gd` lo comprueba). El selector de idioma sigue oculto. Un mensaje nuevo de validación de mapas o modos (`LevelFile`, `MapGrid`, `ModePacks`…) también va en **los dos** catálogos: se escribe con `Localization.t_fmt(&"lvlfile.clave", {"n": 3})`, con el español idéntico al que querías y los marcadores `{nombre}`; las claves de JSON que cite el mensaje (`"cantidad"`) se dejan en español. Si agregás un texto a una pantalla ya migrada, ponelo en **los dos** catálogos con la misma clave (`tests/test_localization_en.gd` falla si falta alguno o si el inglés tiene tildes o «¿»).
- Los nombres propios «Cántaro» y «Compañía Meridiana», «Monsters & Canons», las iniciales de los récords y el formato de números y versión no se traducen.
- Para ver todos los textos visibles del juego agrupados por pantalla: `python3 tools/localization_inventory.py` (escribe `specs/tareas/informes/T533-inventario-textos.md`).
