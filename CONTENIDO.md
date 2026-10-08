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
| `texture` | El dibujo. Los tres monstruos de M24 (Normal, Rápido, Tanque) usan PNG de 256×256 de una sola vista en `assets/sprites/enemies/rendered/`. | `troll.svg` |
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

---

## Agregar una torre

1. **Dibujos:** `assets/sprites/towers/turret_<id>.svg` (la torreta) y `assets/sprites/projectiles/<id>.svg`. Las **bases** (madera, piedra, piedra con oro) son las mismas para todas.
2. **Sonido** *(opcional)*: `assets/audio/shot_<id>.wav`. Se puede generar uno agregando una línea en `tools/make_sounds.gd` y corriendo `godot --headless --path . -s tools/make_sounds.gd -- shot_<id>` (así no se tocan los otros sonidos).
3. **Datos:** duplicar una torre parecida de `data/towers/` y completar (tabla de abajo). Cada torre tiene **3 niveles** (`levels`): el nivel 1 es al construirla; en los niveles 2 y 3, `cost` es lo que cuesta mejorarla.
4. **Sumarla al juego:** abrir `scenes/game/game.tscn`, seleccionar el nodo **Game** y agregarla al final de **Tower Types**. Entran **hasta 9** (teclas 1 a 9, RF-170 y RF-297). Si te olvidás, un test te avisa.
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

En el menú principal, en el **`JuegoA.exe` normal y en el de pruebas** (no en el celular), está el botón **"Editor de mapas"**. Es lo mismo que escribir el JSON, pero se dibuja con el mouse:

| Qué | Cómo |
|---|---|
| **Pintar** | Elegir una herramienta abajo (o las teclas `1` a `5`): Pasto, Camino, Bloqueada, Entrada, Salida. Clic o arrastrar. **Clic derecho borra.** |
| **Entradas** | La herramienta Entrada pone la próxima letra libre (`A`, `B`…). Pintar encima de una entrada la quita y las letras siguientes bajan un lugar (las oleadas se acomodan solas). |
| **Salida** | Hay una sola: si ya estaba, se mueve. |
| **Ver si está bien** | Abajo, un mensaje dice si el nivel es válido (con el largo de cada recorrido) o qué está mal y dónde. Sobre el mapa se dibuja el recorrido de cada entrada y las casillas que nadie pisa. |
| **Ajustes y oleadas** | Botones **Ajustes** (nombre, oro, vidas, vida extra por oleada) y **Oleadas** (agregar, copiar y quitar oleadas; en cada una, los grupos de enemigos). |
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
  - Un removible **intacto** es una casilla bloqueada y **ya despejado** es pasto construible. **Nunca es camino**: los recorridos no cambian. Cuentan para el tope de 10 letras.
  - **`"demoledora": true`** (opcional, en el nivel, no en la leyenda) declara que el nivel habilita la demoledora. El botón **Infraestructura** permite comprarla una vez por 180 de oro; después cada demolición cuesta el 10 % (mínimo 5) y tarda el 80 % del tiempo de clase. El editor conserva este campo. El ejemplo jugable `tools/ejemplos/mapa_demoledora.json` tiene cinco removibles, cuatro rocas para comprobar la amortización, y una mina.
  - **Errores comunes:** `removible` y `extraccion` en la misma letra; `construible: true` en un removible; una `clase` que no existe (el mensaje lista las que hay); `hallazgo` fuera de un `escombro`; dos `hallazgo` de la misma colección en un mismo nivel. **Avisos:** `demoledora` en un mapa sin removibles, y una torre que cuesta recursos en un mapa sin forma de conseguirlos.
  - Los dibujos `escombro`, `mina` y `bosque_explotable` se suman a la lista cerrada de arriba.
  - **Mapa con recursos:** tiene recursos si algún removible puede entregarlos (`probabilidad` y `recursos` mayores que 0) o si tiene una mina o un bosque. Solo entonces el HUD muestra el contador. **Todo mapa de la campaña con recursos tiene que poderse ganar sin usarlos** (el bot lo comprueba con la estrategia `sin_recursos`).
- **Errores comunes:** una letra usada en el mapa que no está en la leyenda ("Letra desconocida"), un nombre de dibujo o de tema mal escrito (el mensaje lista los que existen) y una letra de la leyenda que no se usa (solo un aviso).
- **Un dibujo nuevo** (para el catálogo) es un SVG de 64×64 en `assets/sprites/map/` que sigue `specs/05-guia-de-arte.md`, y un nombre nuevo en `scripts/logic/map_drawings.gd`. Un tema nuevo es una paleta y una lista de decoración en `scripts/logic/map_themes.gd`.
- El editor de mapas **conserva** el tema, la leyenda y `demoledora` al abrir y guardar, pero **todavía no los edita**: se escriben a mano en el archivo.

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

### M49 · Modos de juego (RF-388 a RF-392)

Un **modo** es un grupo de mapas con reglas propias. Aparece como una solapa en **Jugar**: los oficiales después de "Campaña" y los propios después de "Mapas de la comunidad". No hace falta programar: es una carpeta con un archivo `modo.json`.

**Dónde va cada uno:**
- **Oficiales:** `data/modos/<id>/modo.json`, en el repositorio. Hoy existe **Asedio** (`data/modos/asedio/`).
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
| `reglas` | No | `oro_inicial_%` (10 a 1000, sobre el oro del mapa), `vidas` (1 a 999, reemplaza las del mapa) y `vida_monstruos_%` (10 a 1000, sobre la vida de cada monstruo). Sin reglas, el mapa se juega tal cual. |

**Progreso y desbloqueo:**
- Cada mapa de un modo guarda vidas, estrellas, puntaje y su top 5 aparte, con el id `modo_<modo>_<mapa>`.
- No cuenta para la campaña, el total de estrellas de la campaña, el Salón de la fama ni los avances.
- En un modo oficial, cada mapa se abre al ganar el anterior; en los propios, todos están abiertos. El modo de pruebas abre todo.

**Si algo está mal**, el juego no se corta: un `modo.json` roto muestra una sola tarjeta "Con errores" con el motivo, y un mapa que falta o tiene errores queda como tarjeta deshabilitada, mientras los demás se juegan igual.

**Balancear un modo oficial con el bot:**

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix modo=asedio level=2
```

**Asedio:** usa los mapas 1 a 9 de la campaña con `vida_monstruos_%` 115 y el mismo oro. El valor salió del bot: con 150 % y 80 % de oro, el bot perdía en la oleada 4.
