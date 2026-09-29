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
| Niveles | `data/levels/` + `scenes/levels/` | Un `.tres` (`LevelData`: oro, vidas, oleadas) y una escena con el mapa |
| Dibujos | `assets/sprites/` | SVG (o PNG). Ver "Reglas de los dibujos" |
| Sonidos | `assets/audio/` | `.wav`. Cada torre usa `shot_<id>.wav` |

Un `.tres` es un archivo de texto de Godot. Se edita cómodo en el editor (panel **Inspector**), aunque también se puede abrir con cualquier editor de texto.

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

Hoy los mapas se arman con código en `tools/make_levels.gd`, describiendo:
- **cada camino** por sus esquinas (casillas, de la entrada a la salida);
- las **casillas bloqueadas** (rocas, árboles);
- el **oro inicial** y las **oleadas** (cada grupo: enemigo, cantidad, cada cuántos segundos, desde qué segundo y por qué entrada).

Para agregar el nivel 7: copiar la función `_level_6()`, cambiarla y llamarla desde `_init()`. Después:

```bash
godot --headless --path . -s tools/make_levels.gd -- 7
```

Eso crea `scenes/levels/level_07.tscn` y `data/levels/level_07.tres`, y **arma la campaña sola** con todos los niveles que existan. Por último, elegir el aumento de vida por oleada con el bot (abajo) y anotarlo en la spec (§7.4).

> En el futuro (spec B-04) los mapas se van a poder escribir en un archivo de texto, "dibujados" con letras, sin tocar código.

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

- [ ] El `id` es igual al nombre del archivo.
- [ ] Tiene nombre, frase y dibujo(s).
- [ ] Si es una torre: 3 niveles, sonido `shot_<id>.wav` y está en **Tower Types**.
- [ ] Pasan los tests (`test_content.gd` revisa todo lo anterior solo).
- [ ] Si cambia el balance: el bot da resultados razonables, y la spec lo dice (constitución P3: la spec manda).
