# M79 · Inventario de los assets de los niveles altos (T491)

**Qué es:** la tabla real de qué dibujo usa cada nivel del 8 al 15, con sus casillas, su archivo y su técnica, más una captura del motor real por nivel («antes»). Es solo lectura: no cambió ningún código, dato, arte ni spec. No opina sobre el arte.

**Base:** rama `feature/m79-mejora-assets-altos` (PR #89), donde vive la spec M79. Se verificó contra esa rama, no contra `main`.

## Cómo se contó

- **Casillas `X` (decoración del tema):** un script temporal (ya borrado, no va al repo) leyó cada `data/levels/level_NN.json` y, para cada `X` de `mapa`, llamó a `MapThemes.blocked_decor(tema, casilla)`: es la misma función que usa `scenes/levels/level_decor.gd` al pintar. Así el conteo es **exacto** (no una estimación de la grilla) y da el mismo dibujo que se ve en pantalla.
- **Casillas de leyenda:** se contó cada carácter de `mapa` que está en `leyenda`, con su `dibujo` (o `removible` / `extraccion`). La `estatua` se resolvió con `MapDrawings.statue_texture(casilla, tema)`, igual que en el motor.
- **Capturas:** `tools/capture_t475_postes.tscn` con ventana real (`DISPLAY=:0`), `1280x720`, `stars=0`, niveles 8 a 15. Se corrió `godot --headless --import` una vez (salió con código 0 en el primer intento; no hubo código 139). No se tocó `assets/`: `git status` quedó sin cambios fuera de esta carpeta.

## Tabla por nivel (8 a 15)

Cada fila: tema, dibujos de las casillas `X` (con su conteo), dibujos de la leyenda (con su conteo) y la captura.

| Nivel | Tema | Casillas `X` (dibujo: casillas) | Leyenda (dibujo: casillas) | Captura «antes» |
|---|---|---|---|---|
| 8 | ruinas | 0 | `simbolo_ruina` (piedra con la A): 2 · `escombro` (removible): 4 | `art/m79-inventario/antes-nivel-08-1280x720.png` |
| 9 | ruinas | 0 | `simbolo_ruina`: 2 · `escombro` (removible): 4 | `art/m79-inventario/antes-nivel-09-1280x720.png` |
| 10 | desierto | 137: `cactus.svg` 60 · `huesos.svg` (cabeza de ganado) 26 · `roca_roja.svg` 51 | `simbolo_ruina`: 3 · `columna`: 4 · `escombro`: 4 · `roca` (removible): 3 · `mina` (extracción): 1 | `antes-nivel-10-1280x720.png` |
| 11 | desierto | 125: `cactus.svg` 57 · `huesos.svg` 25 · `roca_roja.svg` 43 | `roca_marcada` (piedra con la A): 3 · `escombro`: 2 · `roca`: 3 · `mina`: 1 · agua: 2 | `antes-nivel-11-1280x720.png` |
| 12 | desierto | 156: `cactus.svg` 73 · `huesos.svg` 23 · `roca_roja.svg` 60 | `roca_marcada`: 3 · `escombro`: 2 · `roca`: 3 · `bosque_explotable`: 1 | `antes-nivel-12-1280x720.png` |
| 13 | nieve | 117: `pino.svg` 65 · `abeto.svg` 20 · `roca_nieve.svg` 32 | `roca_marcada`: 4 · hielo: 6 · `escombro`: 2 · `roca`: 3 · `mina`: 1 · `bosque_explotable`: 1 | `antes-nivel-13-1280x720.png` |
| 14 | ruinas | 117: `bloque.svg` 61 · `columna.svg` 31 · `estatua.svg` 25 | `simbolo_ruina`: 8 · `columna`: 5 · `campamento_vacio` (restos): 5 · `escombro`: 2 · `roca`: 3 · `mina`: 1 · `bosque_explotable`: 1 | `antes-nivel-14-1280x720.png` |
| 15 | pradera | 132: `bush.png` 20 · `rock_a.png` 46 · `rock_b.png` 39 · `tree.png` 27 | `roca_marcada`: 2 · `campamento_vacio`: 3 · central de energía (4 piezas, 1 casilla cada una) · cadena de abastecimiento (`supply_depot`, `supply_line_pole`, `supply_cart`): 1 cada una · `escombro`: 5 · `mina`: 1 · `bosque_explotable`: 2 | `antes-nivel-15-1280x720.png` |

Totales de interés: cabezas de ganado (`huesos.svg`) en 10, 11 y 12: **74** casillas. Pinos nevados (`pino.svg` + `abeto.svg`) en el 13: **85**; con la roca nevada, **117**. Piedra con la A: `roca_marcada` en 11, 12, 13 y 15 (**12** casillas), más `roca_marcada` en el 7 (1, fuera de rango); `simbolo_ruina` en 8, 9, 10 y 14 (**15** casillas en el rango).

## Técnica y archivo de cada dibujo

| Dibujo | Archivo | Técnica | Tamaño |
|---|---|---|---|
| `simbolo_ruina` (piedra con la A) | `assets/sprites/map/simbolo_ruina.svg` | SVG plano (M4/M5) | viewBox 64×64 |
| `roca_marcada` (piedra con la A) | `assets/sprites/map/roca_marcada.svg` | SVG plano | viewBox 64×64 |
| `huesos` (cabeza de ganado) | `assets/sprites/map/huesos.svg` *(retirado el 2026-10-26, T516)* | SVG plano | viewBox 64×64 |
| `pino` / `abeto` / `roca_nieve` | `assets/sprites/map/pino.svg`, `abeto.svg`, `roca_nieve.svg` *(retirados el 2026-10-26, T516)* | SVG plano | viewBox 64×64 |
| `cactus` / `roca_roja` | `assets/sprites/map/cactus.svg`, `roca_roja.svg` | SVG plano | viewBox 64×64 |
| `columna` / `bloque` / `estatua` (ruinas) | `assets/sprites/map/columna.svg`, `bloque.svg`, `estatua.svg` | SVG plano | viewBox 64×64 |
| `campamento_vacio` | `assets/sprites/map/campamento_vacio.svg` | SVG plano | 64×64 |
| `estatua` (legenda de 1, 3 y 5) | `assets/sprites/map/rendered/statue_*_moss.png` | PNG dimensional (T277) | 128×128 |
| `rock_a` / `rock_b` / `tree` / `bush` (tema pradera: casillas `X` del 15 y del 1) | `assets/sprites/map/rendered/*.png` | PNG dimensional (T277) | 128×128 |
| `roca` / `escombro` / `mina` / `bosque_explotable` (removibles y extracciones) | `assets/sprites/map/rendered/*_idle.png` | PNG dimensional (T277) | 128×128 |
| `central_1` a `central_4` | `assets/sprites/map/rendered/central_*.png` | PNG dimensional | 128×128 |
| `supply_depot` / `supply_line_pole` / `supply_cart` | `assets/sprites/map/supply_*.svg` | SVG plano | 64×64 |
| `poste_cintas` (poste de campaña, enemigo) | `assets/sprites/map/rendered/banner_post_enemy.png` | PNG dimensional (T437) | 128×128 |

Lo que se dibuja por código (no tiene archivo): `hielo`, `agua`, `lava`, `barro`.

## Qué confirma y qué corrige de la tabla «Qué hay hoy» de M79

**Se confirma todo.** Los conteos de la tabla de M79 coinciden con los de esta medición: `roca_marcada` en 7 (1), 11 (3), 12 (3), 13 (4), 15 (2); `simbolo_ruina` en 8 (2), 9 (2), 10 (3), 14 (8); pinos y abetos solo en el 13; `huesos.svg` solo en 10, 11 y 12; `X` en 10 (137), 11 (125), 12 (156), 13 (117), 14 (117) y 15 (132). La única diferencia es de precisión: M79 decía que la repartición entre dibujos era «la esperada»; ahora está medida con la misma función del motor (en el 13, por ejemplo, 65 pinos, 20 abetos y 32 rocas nevadas, algo distinto de la proporción nominal 3:1:2 de la lista).

**Sobre `simbolo_ruina` y `roca_marcada`:** la tabla de M79 dice que `simbolo_ruina.svg` es «igual al de la roca marcada». No se comparó el dibujo (es arte, fuera de esta tarea), solo el archivo y su uso.

## Discrepancia con `specs/10-universo.md` §6 (la roca marcada en 1 y 5)

- **`specs/10-universo.md` §6** (tabla de señales): la roca marcada (`roca_marcada`) está en «1 y 5; las ruinas del 8», y el símbolo en piedra de ruina (`simbolo_ruina`) en «8 a 10».
- **Los JSON** (`data/levels/level_01.json` y `level_05.json`): **no usan `roca_marcada` ni `simbolo_ruina`**. En el 1 hay una casilla `m` = `estatua`; en el 5, tres casillas `m` = `estatua` (una `statue_basic_moss` y dos `statue_sniper_moss`, según la casilla). En el motor eso se dibuja con las estatuas de musgo de T277 (PNG), no con una piedra con la A. `roca_marcada` aparece en JSON en 7, 11, 12, 13 y 15, y `simbolo_ruina` en 8, 9, 10 y 14 (el 14 no está en §6).
- **Conclusión:** vale lo que dicen los JSON, como anotó la spec. Las señales de §6 no coinciden con los JSON en otros puntos, todos de la misma tabla: `sendero` (§6: nivel 2) y `herramienta` (§6: nivel 3) **no aparecen en ningún JSON**; `poste_cintas` (§6: nivel 4) está en el **6**; el `hito` (opcional, 11 a 13) **no está** en los JSON. Corregir §6 o los JSON queda para Lucas: esta tarea no los toca.

## Diferencias con M79

- Ninguna en los conteos ni en los archivos. Las únicas diferencias son de precisión (ver arriba).
- M79 cita el nivel 8 y el 9 solo por la piedra con la A; coincide (no tienen otra decoración alta).

## Capturas de poste de campaña (8 y 9)

- Hoy **no hay poste de campaña en los niveles 8 y 9**: `data/ui/postes_campana.json` no tiene entradas para esos niveles y su nota dice que la casilla aprobada `(0, 4)` (el símbolo de ruina) quedó frenada hasta que Lucas indique otra. Por eso las capturas de 8 y 9 son «sin poste». Se corrió también con 3 estrellas y las capturas salen **idénticas** a las de 0 estrellas (el poste no depende de las estrellas).
- **La captura «con poste» en 8 y 9 no se hizo**: requeriría cambiar `data/ui/postes_campana.json` (fuera de alcance de esta tarea).
- En los niveles 10 a 15 sí hay poste, en casillas `X` (10: 1; 11 a 15: 2 cada una; 11 casillas en total). Esas capturas muestran el poste **encima** de la decoración del tema: la decoración que queda debajo de esas 11 casillas no se midió.

## Qué no se pudo medir

- **Rendimiento:** no se afirma nada (ni mejor ni peor).
- **Celular simulado:** las capturas son solo a 1280×720 de escritorio; no se capturó la versión de celular simulado ni se probó en teléfono real.
- **Lo que queda debajo de los postes** en 10 a 15 (11 casillas).
- **Verificación visual del dibujo** (si la A se lee bien, si la cabeza de ganado se distingue del cactus): eso es juicio visual, no inventario; se ve en las capturas, sin puntaje.
- **Lo de `--import`:** salió bien el primer intento; no hubo reescritura de SVG (`git status` limpio).
