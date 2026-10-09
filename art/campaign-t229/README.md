# T229 a T232 · Niveles 11 a 14 (bloque 3)

Evidencia de los niveles 11 («Puesto seco»), 12, 13 y 14 (`data/levels/level_11.json` a `level_14.json`, spec §7.13 a §7.16, RF-476 a RF-479). Lo de acá **no es una partida humana**: son corridas del bot de balance (T214) y una partida de verificación con la escena real. Balance humano: pendiente (G4, T226).

## Archivos

| Archivo | Qué es |
|---|---|
| `play.gd` / `play.tscn` | **Partida de verificación en una ventana real**: compra torres con el puntero del sistema y clics de mouse (sin el modo de pruebas), empieza las oleadas con el botón «Empezar oleada», y mira lo que ve quien juega (tarjetas de «Nuevo enemigo», el rayo del Chamán, el rebote del Espejo, vidas y oro). Saca capturas y deja `play_level_N.json`. |
| `level_N_apertura.png`, `level_N_aturdida.png` (11) / `level_N_rebote.png` (12), `level_N_final.png` | Capturas de 1777 × 1000 (el tamaño que le dio el gestor de ventanas a `--resolution 1280x720`), reducidas a 256 colores para el repositorio. |
| `play_level_N.json` | Lo que registró la partida de verificación. |

```bash
godot --path . --resolution 1280x720 art/campaign-t229/play.tscn -- level=11 until=7 speed=6 out=art/campaign-t229
```

Necesita pantalla. **Mueve el puntero real del sistema** (`Input.warp_mouse`): en una ventana real, los movimientos de mouse sintéticos que entran por `Input.parse_input_event` **no** cambian la posición que lee el juego (`get_global_mouse_position`), y por eso los tests de clics reales (`test_real_scene_clicks.gd`) solo valen en `--headless`. El apretar y soltar del clic sí entra como evento. `speed=6` acelera el reloj del motor (la partida no es en tiempo real).

## Nivel 11 · Puesto seco

Mapa de **24 × 11**, tema `desierto`, **una entrada**: A arriba a la izquierda, salida S abajo a la derecha (los voladores cruzan en diagonal), camino de **76 casillas** en una serpentina de tres rectas largas (filas 0, 5 y 10). **52 casillas libres** y cuatro bloques libres de 2×2 para el Mortero: (3,1), (13,2), (6,7) y (13,7). Dos pozos de agua en (6,3) y (16,7), tres rocas marcadas (`roca_marcada`, hasta que llegue el dibujo del `hito`) en (1,2), (21,2) y (2,8), una mina en (11,2) y **cinco removibles** (rocas en (6,1), (12,6), (19,9); escombros en (16,2), (7,9)), todos con 1 recurso al 50 %. Las cuatro esquinas del Embestidor tienen una casilla libre pegada y otra para el apoyo. **22 oleadas**, 420 de oro, 20 vidas, **aumento de vida 27 %** (la ficha traía 28: con 28 `sin_recursos` gana con 1 vida de margen).

**Las oleadas:** 1 a 4 los enemigos de siempre, livianos; **oleada 5: el Chamán debuta solo** (1 Chamán y 5 Trolls, sin Guardián, Curandero ni Espejo); **oleada 8: el Guardián y el Curandero entran juntos** (la Disruptora tiene a quién apagarle el aura); **oleada 12: el Chamán se junta con ellos**; el Soberano en las oleadas 11, 17, 21 y 22. Sin otros debuts.

### Bot, 5 semillas (vidas al terminar; todas ganaron las 22 oleadas)

| Estrategia | Sem. 1 | Sem. 2 | Sem. 3 | Sem. 4 | Sem. 5 |
|---|---|---|---|---|---|
| `sin_recursos` | 6 | 6 | 6 | 6 | 6 |
| `demoler` | 8 | 8 | 8 | 8 | 8 |
| `demoledora` (el nivel no la habilita: igual que `demoler`) | 8 | 8 | 8 | 8 | 8 |
| `extraer_temprano` | 17 | 17 | 17 | 17 | 17 |
| `extraer_tarde` | 18 | 16 | 16 | 16 | 16 |

(El nivel 10: `sin_recursos` 9, 9, 13, 7, 9.) **Regla de oro:** `check_rule=1 levels=11` → 5 de 5, «SE CUMPLE». Las oleadas 1 a 3 no pierden vidas en 5 de 5.

### Con y sin Disruptora (decisión de T217: la tabla es para que decida Lucas)

La estrategia `mix` (la única que compra la Disruptora; simula la colección completa y le da 4 recursos). Se la compara contra `mix` con `disruptor=0`.

| `mix` | Sem. 1 | Sem. 2 | Sem. 3 | Sem. 4 | Sem. 5 |
|---|---|---|---|---|---|
| sin Disruptora (`disruptor=0`) | gana, 6 | gana, 6 | gana, 6 | gana, 6 | gana, 6 |
| con Disruptora (`disruptor=1`) | pierde en la 20 | pierde en la 14 | pierde en la 14 | pierde en la 14 | pierde en la 14 |

**Con el bot la Disruptora empeora el nivel** (igual que en T217): `mix` sin ella gana 5 de 5 con 6 vidas y con ella pierde 5 de 5, casi siempre en la oleada 14 (la de tres Guardianes, tres Curanderos y 18 Trolls con un Chamán). El bot compra hasta 2 Disruptoras después de 3 torres comunes (130 de oro cada una, 260 en total, el precio de 2,6 Cañones) y la torre hace 5 de daño: el oro que se va ahí falta en la defensa. **No se tocó nada de la torre** (costo, supresión ni cadencia: decide Lucas). Lo que esta tabla **no** dice: el bot no apunta ni elige dónde ponerla como una persona, ni mejora la torre; la compra por una regla fija.

### Partida real (ventana de 1777 × 1000, torres con clics, `speed=6`, oleadas 1 a 7)

`play_level_11.json`: 13 torres, 17 vidas. Se vio: la tarjeta **«Nuevo enemigo: Chamán»** en la oleada 5, una torre **aturdida 3,0 s** (RF-285) con el rayo magenta del Chamán a un Cañón, las tarjetas de los enemigos nuevos del guardado vacío, y los clics de la compra (botón de la torre y casilla) sin ningún fallo.
