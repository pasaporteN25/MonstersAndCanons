# T449 · Selector y modos: Campaña contra Asedio, mapa como vista inicial, geografía e interacción (B-52)

- **Frente:** A de la matriz del 2026-10-23 · **Backlog:** B-52 (PR #49) · **Base:** `origin/main` = `250e724`.
- **Tipo:** análisis. **No se tocó** código, `data/`, balance, canon, mapa, arte aprobado ni `specs/01` a `04`. Toda D o RF que aparece acá es **texto propuesto, PENDIENTE DE LUCAS**.
- **Números:** los RF, D y T de este informe son **provisionales**. Mientras se escribía este informe, otros agentes tomaron T450 a T452 en ramas paralelas, y también pueden estar usando D-187 y siguientes. Los números definitivos los fija la tarea 📜 que registre M75. Acá las D se llaman **D-A1 a D-A4** y las tareas **A-1 a A-9**.

## 0. Qué se verificó y qué no

| Verificado | Cómo |
|---|---|
| El aterrizaje (`LANDER`) cae **fuera** de la tierra | Script de punto en polígono, en el scratchpad (no en el repo). Lee las constantes directamente de `scripts/logic/campaign_map.gd` (§4.1). |
| La geografía propuesta (§4.3) cumple sus reglas | El mismo script, sobre las coordenadas propuestas: todos los puntos en tierra y en su bioma, los marcadores sin tocar el mar, la ruta sin cruzar el agua y sin tramos que se crucen. |
| Las líneas de código citadas | Leídas en `250e724`. |
| Que los guardados no distinguen «elegí tarjetas» de «nunca elegí» (§3.3) | Lectura de `save_manager.gd:16-24`, `:64`, `:106-115` y `:452-458`. |

**No se hizo:**
- No se corrió Godot ni GUT, porque no cambió código.
- No hay capturas nuevas ni maquetas: no se pidieron.
- No se midió la dificultad de Asedio. Los números salen de RF-494, T255, T258 y T279.
- No se probó en un celular.
- El script calcula en el plano del modelo (unidades de `campaign_map.gd`). No miré el render real del motor.

---

## 1. Campaña contra Asedio, con los datos del repo

### 1.1 Tabla comparativa

| Aspecto | Campaña | Asedio | Fuente |
|---|---|---|---|
| **Mapas** | `level_01` a `level_15` | **Los mismos 15**, en el mismo orden y sin copias. Mismas oleadas, caminos, enemigos, oro, vidas y torres. | `data/modos/asedio/modo.json`, RF-493 |
| **Vida de los monstruos** | 100 % | **115 % global**, pero solo lo usan el 4 y el 15. Los otros 13 tienen su propio porcentaje: 101 % en el 6, 7, 8, 9, 11 y 13; 105 % en el 1, 2 y 3; 108 % en el 5; 110 % en el 12; 118 % en el 10 y el 14. Todos son mayores que 100. | `modo.json`, RF-492, RF-494, D-095 |
| **Oro y vidas** | Los del nivel | Los mismos (`oro_inicial_%` = 100) | `modo.json` |
| **Dificultad medida** | Referencia del bot (RF-432) | El bot gana 5 de 5 en cada mapa con margen. Asedio 7 quedó en 101 %: T279 lo remidió con **5/5 y 6 vidas**, pero RF-494 todavía dice «NO cumple» (T444, hallazgo 2). **Ninguna persona jugó Asedio**: los valores son «iniciales» hasta G5. | RF-494, RF-495, `03-tareas.md:90` |
| **Desbloqueo** | Ganar el nivel anterior | Ganar el mapa anterior **de Asedio**. Ganar en la campaña no abre nada en Asedio, ni al revés. | `game_flow.gd:211-229`, `mode_packs.gd:129-136`, RF-390 |
| **Progreso** | Ids `level_NN` | Ids propios `modo_asedio_level_NN` (`ModePacks.level_id`, `mode_packs.gd:108-109`) | RF-390 |
| **Estrellas** | Salen de las mejores vidas (`level_stars`, `game_flow.gd:102-106`). Suman al total «Estrellas: x de 45». | Misma fórmula (`map_stars` → `community_stars`, `:149-158`) y su propio total de 45. **No suman a la campaña.** | RF-93, RF-390 |
| **Récords (top 5)** | Se guardan y se ven en Récords | Se guardan con el id del modo, pero **la pantalla de Récords no los muestra**: solo recorre la campaña (`records_screen.gd:39-43`). Es pendiente de T235. | RF-390, T235 paso 3 |
| **Salón de la fama** | Sí | No | RF-390 |
| **Textos (entrada, victoria, lugar)** | Sí | **No**: los modos oficiales nunca los muestran (`game.gd:613-617`) | RF-468 |
| **Piezas de colección y avances** | Sí | No: el hallazgo se ve y se puede demoler, pero no se recoge | RF-429, Q-31 |
| **Entrada de jefes (M66)** | Sí | No (`game.gd:950-956`) | RF-597 a RF-602 |
| **Poste del 6 conquistado** | Cambia al ganar el 6 | Siempre muestra el poste enemigo: solo se consulta el guardado de la campaña (`game.gd:110-112`) | RF-656, RF-657 |
| **Propósito declarado** | La historia de la colonia (07, 10, 11) | «Los 15 mapas de la campaña con monstruos más duros» (descripción de `modo.json`; novedades: «un modo aparte… con estrellas y récords propios»). **No tiene papel en el canon**: `10-universo.md` no lo menciona. | `modo.json`, `novedades.json:34-35` |

### 1.2 Qué ve el jugador en cada solapa (desktop, 1280×720)

**La pantalla** es la misma escena para todo (`level_select.tscn`): título «Elegir nivel», una fila de solapas `Campaña | Asedio | Mapas de la comunidad (N) | [modos propios]` y el total de estrellas a la derecha. Asedio entra como «modo oficial, después de Campaña» (`level_select.gd:204-224`).

**Solapa Campaña:**
- 15 tarjetas compactas de 200×146 en tres filas, sin scroll (RF-646).
- Cada tarjeta tiene:
  - el fondo del tema del nivel (T426);
  - «Nivel N», el nombre y el lugar;
  - los íconos de torres, con la marca de «Nueva»;
  - el estado: «¡Jugar!», «Mejor: N vidas» o «Bloqueado»;
  - las estrellas;
  - un tooltip con el lugar, las torres y el avance (`:389-406`).
- Abajo está el interruptor **Vista: Tarjetas / Mapa** (`:125-129`). Hoy arranca en **Tarjetas**.

**Solapa Asedio:**
- 15 botones de texto plano de 200×214, en dos filas visibles y con scroll.
- El texto es `Mapa N\n<nombre>\nN oleadas\n<estado>`, más las estrellas (`:263-275`).
- No tiene lugar, torres, fondo temático ni interruptor de vista.
- **La única explicación del modo es el tooltip de la solapa** (`:211`): solo aparece al dejar el mouse encima.

**En la partida de Asedio:**
- Todo se ve igual que en la campaña, pero **sin** el cartel de entrada, el texto de victoria, los hallazgos ni la entrada de jefes.
- **El porcentaje de vida no se muestra en ningún lado**: `enemy_health_percent` solo lo usa el spawner (`game.gd:128`).

**En el celular:** las dos solapas usan tarjetas grandes. La de Campaña lleva la placa de torres; la de Asedio, el mismo texto plano.

### 1.3 Por qué parecen lo mismo

1. **Mismo contenido visible.** Mismos 15 nombres, en el mismo orden, con el mismo «gana el anterior para abrir el siguiente», las mismas estrellas de 0 a 3 por vidas y el mismo «Mejor: N vidas».
2. **La diferencia no se ve.**
   - Lo único que cambia en la partida es entre +1 % y +18 % de vida en los monstruos. En 8 de los 15 mapas es +1 % a +5 %.
   - No hay un número en pantalla, ni un ícono, ni una palabra.
   - Lo que **falta** en Asedio (textos, hallazgos, jefes) se nota como ausencia, no como identidad.
3. **Misma jerarquía.** Asedio es una solapa hermana de Campaña, a la misma altura y con el mismo estilo, sin encabezado ni subtítulo. Para quien juega, «Asedio» es otra lista de los mismos niveles.
4. **La tarjeta de Asedio es una versión pobre de la de Campaña.** Parece la misma lista sin terminar, no otro modo.
5. **No hay propósito narrativo ni de progresión.** Asedio no se abre al terminar nada ni lo anuncia la campaña, y el canon no le da un papel. Además, sus récords no se pueden ver: la recompensa que promete («récords propios») no aparece.

---

## 2. Tres maneras de explicarlos o reorganizarlos (sin fusionarlos)

Las tres conservan el progreso separado, los ids `modo_asedio_*`, los porcentajes de RF-494 y la campaña tal cual.

### Alternativa A · Explicar dentro de la solapa (lo mínimo)
**Qué incluye:**
- **Un encabezado fijo** en la solapa Asedio, encima de las tarjetas, de 1 o 2 renglones. Por ejemplo: «**Asedio** · los 15 mapas de la campaña con monstruos más resistentes. Sin textos ni hallazgos: estrellas y récords aparte».
- **Una insignia «+N % vida»** en cada tarjeta, calculada desde `LevelData.enemy_health_percent`, no escrita a mano.
- **La misma tarjeta rica que la campaña** (nombre, lugar o tema, torres), con una **identidad propia**: marco o acento de otro color y un ícono de asedio (ya existe `news_icon_siege.png`).
- **En la partida**, el porcentaje en la línea de estado del HUD o en la pausa: «Asedio · vida +8 %».

| Ventajas | Riesgos |
|---|---|
| Barata. No cambia reglas, progreso ni la estructura de solapas. Ataca las causas 2 y 4. | No resuelve la causa 3 (misma jerarquía). La insignia de +1 % puede leerse como «es lo mismo» y reforzar la confusión: conviene decir «más resistentes» y dar el número como detalle. Toca `level_select.gd`, que también editan las tareas del mapa (§6): hay que hacerlas en serie. |

### Alternativa B · Reordenar la jerarquía: Campaña arriba, «Desafíos» como grupo
**Qué incluye:**
- La fila queda `Campaña | Desafíos ▾ | Comunidad`. Dentro de «Desafíos» van **Asedio y los modos propios**, como sub-solapas desplazables o como un selector.
- Cada modo tiene su encabezado, como en A.
- La pantalla de Récords suma un selector «Campaña / Asedio / …», con un top 5 por mapa del modo.

| Ventajas | Riesgos |
|---|---|
| Ataca la causa 3: Asedio deja de ser «otra campaña» y pasa a ser un desafío. **Absorbe las dos partes que le quedan a T235**: las solapas que no entran con más de dos modos propios y los récords de los modos. | Cambia RF-389 (el orden de las solapas: hoy los oficiales van después de Campaña y los propios después de Comunidad), así que necesita un RF nuevo. `GameFlow.select_page` guarda `&"mode:<id>"` y hay que mantener que «Niveles» vuelva a la misma solapa (RF-225). Mobile: un desplegable en táctil necesita 56 px (RF-550). |

### Alternativa C · Asedio como contenido posterior
**Qué incluye:**
- La solapa se ve desde el principio, con su explicación, pero **el mapa N de Asedio se abre al ganar el N de la campaña** (o toda la solapa, al ganar el 5).
- El encabezado lo dice: «Volvé a un lugar ya asegurado con monstruos más duros».

| Ventajas | Riesgos |
|---|---|
| Le da a Asedio un lugar en la progresión (causa 5) y explica por qué son los mismos mapas: son **los que ya ganaste**. | **Cambia la regla de desbloqueo de RF-390.** Hace falta migrar: todo mapa de Asedio que ya estaba abierto o ganado en un guardado tiene que seguir abierto (nunca cerrar lo que se abrió). Cambia la prueba de G5 (T238), que hoy pide Asedio desde el principio. Tiene que coexistir con el modo de pruebas (RF-183, abre todo). Darle un marco narrativo («contraataque») tocaría el canon y el tono de §8, que dicen que los Moradores no son monstruos de horda. **No lo propongo para la V1** sin el OK de Lucas sobre el canon. |

### Recomendación
- **A + B**, en ese orden.
  - **A** es la explicación que falta y no depende de nada.
  - **B** se hace junto con lo que le queda a T235, que de todos modos necesita un RF nuevo y la respuesta de Lucas sobre si entra en la 1.0 (`03-tareas.md:57`). Conviene que **B reemplace a T235**: se cierra T235 como «absorbida por A-8», con la parte de los 15 mapas ya hecha por T258.
- **C** queda como opción para después de G5, si Lucas quiere que Asedio sea «la vuelta de tuerca» de la campaña.
- **Descarté** usar el mapa planetario para Asedio: dibujaría las mismas 15 regiones y **aumentaría** el parecido.

**D-A1 · Cómo se presenta Asedio (PENDIENTE DE LUCAS)**
- **Qué:**
  - Asedio sigue siendo un modo aparte, con su progreso, ids y porcentajes.
  - La solapa explica qué es con un encabezado.
  - Cada tarjeta muestra el aumento de vida de su mapa.
  - Los modos (oficiales y propios) se agrupan en «Desafíos».
  - Récords muestra el top 5 de los modos.
- **Por qué:** hoy no se distingue de la campaña (§1.3) y sus récords no se ven.
- **Alternativas:** solo A; A + B (**recomendada**); C, desbloqueo atado a la campaña (diferida); mapa planetario para Asedio (descartada).
- **Qué cambia:** RF-389 (orden y agrupación de solapas), RF-195 (Récords) y T235, que queda absorbida.

---

## 3. Rediseño del selector: el mapa como vista inicial

### 3.1 Qué hay hoy
- `selector_style` vale 0 (tarjetas) por omisión (`save_manager.gd:23`), y `CampaignMap.style_from` lleva todo lo que no sea 1 a tarjetas (`campaign_map.gd:34-37`).
- RF-645 dice textualmente: «**guardados anteriores abren con tarjetas**». D-178 descarta «reemplazar el selector actual».
- B-52 pide lo contrario como vista inicial, así que **hace falta una D nueva que revise D-178**. No alcanza con cambiar un número.

### 3.2 Propuesta de decisión

**D-A2 · El mapa planetario es la vista inicial de la campaña en desktop; las tarjetas quedan como alternativa (PENDIENTE DE LUCAS). Revisa D-178.**
- **Qué:**
  - En desktop, la solapa Campaña abre en el mapa salvo que la persona haya elegido «Tarjetas».
  - El interruptor «Vista: Mapa / Tarjetas» sigue visible. **Mapa va primero.**
  - La preferencia sigue en `settings`, sin tocar el progreso ni `SAVE_VERSION`.
  - Mobile sigue con tarjetas (RF-653).
- **Por qué:** Lucas pidió el mapa como presentación principal (B-52). El mapa comunica el avance de la colonia. Las tarjetas siguen siendo la vista densa para revisar torres y récords.
- **Alternativas:**
  - (a) Mapa por omisión con una migración que respete a quien eligió tarjetas a propósito (**recomendada**, §3.3 M1).
  - (b) Mapa solo para guardados nuevos (§3.3 M2).
  - (c) Dejar tarjetas y ofrecer el mapa con un aviso único (§3.3 M3).
  - (d) Quitar las tarjetas (descartada: contradice «tarjetas como alternativa» y deja sin la vista densa).
- **Qué cambia:**
  - RF-645, que se enmienda en la frase «guardados anteriores abren con tarjetas».
  - D-178, que pasa a «revisada por D-A2» y conserva su historial.
  - `save_manager.gd` (el valor por omisión y una clave nueva) y `campaign_map.gd` (`style_from`).
  - `test_campaign_map.gd` y `test_old_saves.gd`.
  - CHANGELOG, README y ONBOARDING.
- **Depende de:** que la geografía nueva (§4) esté aprobada e integrada. **Poner el mapa como vista inicial con el aterrizaje en el mar sería mostrar primero el defecto.**

### 3.3 Migración de guardados: hallazgo y opciones

**Hallazgo.**
- `load_save()` arranca con `_settings = DEFAULT_SETTINGS.duplicate()` (`save_manager.gd:64`) y `save()` escribe `_settings` entero (`:112`).
- Entonces **todo guardado escrito desde T428 (2026-10-21) ya tiene `"selector_style": 0` en el archivo**, aunque la persona nunca haya tocado el interruptor.
- Por eso **no se puede distinguir** «elegí tarjetas» de «nunca elegí» con la clave actual. Cambiar solo el valor por omisión a 1 no alcanza: esos guardados siguen leyendo un 0 explícito.

| Opción | Cómo | A quién afecta | Riesgo |
|---|---|---|---|
| **M1 (recomendada)** | Clave aditiva nueva en `settings`: `selector_style_chosen` (booleana, por omisión `false`). `set_style` la pone en `true`. Al leer, si es `false`, vale la vista nueva por omisión (mapa), **sin importar** el `selector_style` guardado. | Todos los guardados existentes en desktop pasan al mapa **una vez**. Quien después elija tarjetas queda en tarjetas para siempre. | Quien eligió «Tarjetas» a propósito entre el 2026-10-21 y la integración vuelve a ver el mapa una vez. Hoy son solo Lucas y quien probó la beta (`config/version="beta"`, sin release pública). Se avisa en el CHANGELOG. |
| **M2** | La misma clave nueva, pero un guardado **existente** sin la clave conserva lo que tenga, que es tarjetas. Solo un guardado **nuevo** (sin archivo) arranca en el mapa. | Solo jugadores nuevos. | Cumple al pie de la letra «guardados anteriores abren con tarjetas», pero Lucas y los testers de G5 no verían la vista inicial nueva sin cambiarla a mano. |
| **M3** | Sin cambiar el valor por omisión: un aviso único en la solapa («Nuevo: vista de mapa») con un botón. | Nadie cambia solo. | Una pantalla más que mantener. No cumple «mapa como vista inicial». |

**Lo que cumplen las tres:**
- `SAVE_VERSION` sigue en 1.
- La clave es aditiva: un guardado sin ella carga.
- Un valor dañado o que no es booleano vale `false`, como RF-498 y RF-575.
- El progreso no se toca.
- `test_old_saves.gd` suma tres casos: guardado anterior a T428 (sin `selector_style`), guardado de T428 (con 0) y guardado con `selector_style_chosen: true` y 0.

**RF propuesto (texto, PENDIENTE DE LUCAS) · RF-A1 · Vista inicial del selector desktop** *(enmienda RF-645)*
- La solapa Campaña abre en el mapa planetario salvo que la persona haya elegido tarjetas con el interruptor.
- La elección se recuerda con una clave aditiva y sin `SAVE_VERSION`.
- **Dado** un guardado anterior sin elección explícita → **Cuando** se abre el selector en desktop → **Entonces** se ve el mapa con el progreso intacto.
- **Dado** que se eligió «Tarjetas» → **Cuando** se vuelve al selector → **Entonces** se ven tarjetas.
- En el celular no cambia nada.

---

## 4. Geografía

### 4.1 Verificación del aterrizaje (script en el scratchpad)

- **Script:** `/tmp/claude-1000/-home-newman-orca-workspaces-TDv1-krill/c1c12662-57ce-4f35-a99a-0df217184a26/scratchpad/t449/geo_check.py`. **No está en el repo.**
- **Qué hace:** lee `LANDER`, `REGION_POINTS` y `LAND_COORDS` de `scripts/logic/campaign_map.gd` con expresiones regulares y aplica el criterio par-impar de punto en polígono, el mismo que `Geometry2D.is_point_in_polygon`.
- **Cómo se corre:** `python3 -I geo_check.py <ruta a campaign_map.gd>`.

| Punto | Coordenada | ¿En tierra? | Distancia a la costa (unidades del mapa) |
|---|---|---|---|
| **LANDER** (`:16`) | (181, 465) | **No** | **78,4** mar adentro, al sur. El tramo de costa más cercano es (196,388)–(166,359). |
| R01 | (251, 397) | Sí, pero **sobre la línea de costa** | **0,0**: cae prácticamente sobre el tramo (233,383)–(265,408) |
| R14 | (597, 455) | Sí | 25,2 |
| R02 a R13 y R15 | — | Sí | 36,7 a 135,4 |

Lectura:
1. **El aterrizaje está en el mar**, a unos 78 de la costa. Eso equivale a unos 63 px de vista (escala `380/472 ≈ 0,805`, `campaign_map_view.gd:33`).
2. El marcador de región mide 44 px de vista (`REGION_SIZE`), un radio de unas 27,3 unidades. Con eso:
   - **la región 1 queda medio en el agua**, porque su centro está sobre la costa;
   - **la región 14 asoma** unas 2 unidades sobre el mar.
3. **El recorrido es un anillo:**
   - del 1 al 9 va al este por el norte (x de 251 a 1058);
   - el 10 baja en el extremo este;
   - del 11 al 15 vuelve al oeste por el sur (x de 956 a 498);
   - **el 15 termina a unos 250 del 1.**
4. Eso choca con la regla 1 de `10-universo.md:90-91` («se pasa del oasis al bosque, del bosque a las ruinas y de ahí al desierto por caminos reales, no por saltos»). Además, el fondo no dibuja ningún bioma: todo es la misma tierra verde (`assets/ui/campaign_map_background.svg`).

**Una ambigüedad del canon, para que Lucas la resuelva.**
- La tabla de `10-universo.md:80` pone en el mismo tema «Niveles 1–5 **y el valle del 15**», y `data/levels/level_15.json` usa el tema `pradera`. Una lectura posible es que el 15 vuelve cerca del oasis, y eso justificaría el anillo.
- La otra lectura es que el 15 es **otro valle fértil, más allá del paso**, que comparte el tema pradera. La sostienen:
  - el bloque 3 («consolidar la región», `10-universo.md:300-306`);
  - el 13 como «el paso que comunica con el resto de la región»;
  - el 14 con los poblados de los Moradores.
- La propuesta de abajo toma **la segunda lectura**, como pide B-52 («sin anillo»).

### 4.2 Ruta por biomas (del canon y de los datos de cada nivel)

| Nivel | Tema en `data/levels` | Lugar (`textos`) | Bioma en la ruta |
|---|---|---|---|
| 1–5 | pradera | Campamento de aterrizaje · El paso del agua · Las huertas · El pozo · La empalizada | **Oasis** |
| 6–7 | bosque | El lindero · El aserradero | **Bosque** |
| 8–9 | ruinas | El bastión sobre ruinas · El taller | **Ruinas (coloniales)** |
| 10–12 | desierto | Primer puesto de abastecimiento · El punto de agua · El paso hacia el norte | **Desierto**, terminando al norte |
| 13 | nieve | El camino al resto de la región | **Sierra nevada**: el paso alto, que corta el continente |
| 14 | ruinas | Asentamientos de los Moradores | **Poblados vacíos**, del otro lado del paso |
| 15 | pradera | Energía y abastecimiento | **Valle de La Central**, en el extremo este |

La ruta va **de oeste a este sin volver**: oasis, bosque, ruinas, desierto, sierra, poblados y valle. Los únicos ida y vuelta son norte-sur, dentro de cada bioma. La sierra entre el 12 y el 14 parte el mapa en «lo que la colonia ya conoce» y «la tierra de los Moradores», que es lo que cuenta el bloque 3.

### 4.3 Coordenadas propuestas (SOLO PROPUESTA, no se tocó `campaign_map.gd`)

- **Plano:** el mismo sistema de unidades que hoy, pero con el mar más ancho. `SEA_ORIGIN = (20, 90)` y `SEA_SIZE = (2400, 472)`. El alto no cambia, así que la escala sigue en 0,805 y los marcadores conservan su tamaño. El ancho del mapa en vista pasa de 998 a **1932 px**, contra los 1090 px del área: hay unos 842 px de desplazamiento lateral, 1,8 pantallas.
- **Validación:** el script `/tmp/claude-1000/-home-newman-orca-workspaces-TDv1-krill/c1c12662-57ce-4f35-a99a-0df217184a26/scratchpad/t449/propuesta.py` verifica, sobre estas coordenadas:
  - cada punto está en tierra y en el bioma que le corresponde;
  - ningún marcador toca el mar (al menos 31 unidades de la costa);
  - ningún marcador cruza la frontera de su bioma (margen de al menos 27);
  - ningún tramo de la ruta cruza el agua (50 muestras por tramo, cada una a más de 8 de la costa);
  - no hay tramos que se crucen;
  - la separación mínima entre marcadores es al menos 2r + 10.

  **Resultado: OK.** La separación mínima es 90,6 (entre el aterrizaje y la región 1), la costa más cercana a un marcador está a 71,9 (región 2) y el margen de frontera más chico es 37,0 (región 5).

```gdscript
# PROPUESTA T449 — no integrar sin la muestra de arte aprobada (A-2) ni el OK de Lucas.
const SEA_ORIGIN := Vector2(20, 90)
const SEA_SIZE := Vector2(2400, 472)
const LANDER := Vector2(150, 330)          # en el oasis, a 76,6 de la costa oeste
const REGION_POINTS: Array[Vector2] = [
	Vector2(240, 320), Vector2(320, 215), Vector2(380, 400), Vector2(470, 290), Vector2(575, 390),   # oasis 1–5
	Vector2(680, 300), Vector2(840, 220),                                                            # bosque 6–7
	Vector2(1040, 330), Vector2(1160, 240),                                                          # ruinas 8–9
	Vector2(1290, 400), Vector2(1440, 300), Vector2(1600, 210),                                      # desierto 10–12
	Vector2(1800, 200),                                                                              # sierra 13
	Vector2(1990, 330),                                                                              # poblados 14
	Vector2(2200, 380),                                                                              # valle 15
]
const LAND_COORDS: Array[float] = [
	70, 330, 85, 260, 130, 205, 190, 170, 260, 150, 340, 140, 420, 128, 500, 140, 580, 125, 660, 145, 740, 132,
	820, 150, 900, 135, 980, 150, 1060, 140, 1140, 160, 1220, 145, 1300, 165, 1380, 150, 1460, 170, 1540, 150,
	1620, 130, 1700, 115, 1780, 110, 1860, 120, 1940, 140, 2020, 150, 2100, 165, 2180, 160, 2260, 185, 2330, 220,
	2380, 280, 2390, 350, 2370, 420, 2320, 480, 2240, 515, 2160, 530, 2080, 520, 2000, 540, 1920, 525, 1840, 540,
	1760, 520, 1680, 535, 1600, 515, 1520, 530, 1440, 510, 1360, 525, 1280, 505, 1200, 520, 1120, 500, 1040, 515,
	960, 495, 880, 510, 800, 490, 720, 505, 640, 485, 560, 500, 480, 480, 400, 495, 320, 470, 250, 480, 180, 455,
	120, 420, 85, 380,
]
## Fronteras de bioma, de norte a sur (x en función de y). Entre una y la siguiente hay un bioma:
## oasis | bosque | ruinas | desierto | sierra | poblados | valle.
const BIOME_BORDERS: Array = [
	[Vector2(600, 100), Vector2(640, 250), Vector2(610, 400), Vector2(650, 560)],
	[Vector2(960, 100), Vector2(1000, 250), Vector2(970, 400), Vector2(1010, 560)],
	[Vector2(1230, 100), Vector2(1210, 250), Vector2(1250, 400), Vector2(1220, 560)],
	[Vector2(1710, 100), Vector2(1690, 250), Vector2(1730, 400), Vector2(1700, 560)],
	[Vector2(1900, 100), Vector2(1880, 250), Vector2(1910, 400), Vector2(1890, 560)],
	[Vector2(2100, 100), Vector2(2080, 250), Vector2(2120, 400), Vector2(2090, 560)],
]
```

**Cómo se lee:**
- Las fronteras son el **esqueleto**: el arte (A-2) las dibuja orgánicas, con lenguas de bosque que entran al oasis, dunas y una sierra con forma de cordillera. Los anchos de banda ya son distintos entre sí (oasis unos 530, bosque unos 360, desierto unos 480, sierra unos 190).
- Si el arte mueve un punto, se vuelve a correr el script, o el test de A-3, que lo porta a GUT.
- **La costa propuesta es una masa sola, larga y con entrantes.** Si Lucas prefiere que el oasis sea una península o que la sierra llegue al mar, se ajusta en A-2 sin cambiar la ruta.

**D-A3 · Geografía del atlas: aterrizaje en tierra y ruta lineal por biomas (PENDIENTE DE LUCAS)**
- **Qué:**
  - el aterrizaje cae sobre tierra, en el oasis;
  - las 15 regiones siguen la secuencia de biomas de §4.2, de oeste a este, sin cerrar un anillo;
  - el fondo dibuja los biomas como zonas orgánicas;
  - el mapa es más ancho que el área y se desplaza en horizontal.
- **Por qué:** el aterrizaje está en el mar (§4.1), la región 1 está sobre la costa y el anillo contradice la regla 1 de `10-universo.md`.
- **Alternativas:**
  - (a) corregir solo el aterrizaje y dejar el anillo: barata, pero no cumple B-52;
  - (b) ruta lineal en el mismo ancho de 1240, sin scroll: entra, pero comprime cada bioma a unas 170 unidades y obliga a achicar los marcadores por debajo de 44 px;
  - (c) ruta lineal con scroll lateral (**recomendada**);
  - (d) 15 al lado del oasis, como un anillo justificado (depende de la lectura del canon de §4.1).
- **Qué cambia:**
  - **Rehace la muestra aprobada en T427** (RF-652: arte nuevo con aprobación de Lucas);
  - las constantes de `campaign_map.gd` y `assets/ui/campaign_map_background.svg`;
  - D-179 conserva «el aterrizaje es el origen visual fijo», con otra coordenada;
  - RF-647 sigue: no es geografía jugable.

### 4.4 Desplazamiento lateral

**Hoy:**
- La vista mide 1090×458 fija (`campaign_map_view.gd:11`).
- El panel inferior (`:148-173`), la leyenda (`:238-250`), la rosa de los vientos y el título se dibujan **en el mismo lienzo** que el mapa.
- `level_select.gd:161-163` apaga el scroll.

**Propuesta:**
1. **Separar en dos capas.**
   - Un `MapCanvas` desplazable de unos 1932×380, con el fondo, la ruta, el aterrizaje y las regiones.
   - Encima, una capa fija con el título, la leyenda y la rosa de los vientos, y debajo el `InfoPanel` con «Jugar».
   - La leyenda tiene que quedar fija: si se desplazara con el mapa, taparía regiones distintas según la posición.
2. **Mecánica.** Un `ScrollContainer` solo horizontal alrededor del `MapCanvas`, con `follow_focus = true`. Así, mover el foco con las flechas lleva la región a la vista.
   - La rueda del mouse tiene que mover en horizontal. Sin la barra vertical, **hay que verificar** si Godot 4.7 lo hace solo o si hace falta traducir `WHEEL_UP/DOWN` a `scroll_horizontal`. No lo probé.
   - Arrastrar con el botón izquierdo sobre el mar es una opción, pero choca con «clic selecciona». Sugiero arrastrar solo con el botón del medio o con la barra.
3. **Posición inicial:** centrada en `default_selection` (`campaign_map.gd:58-65`), no en x = 0. Quien va por el 12 no tiene que desplazarse para encontrarlo.
4. **Ayudas de orientación:**
   - flechas o degradés en los bordes cuando hay mapa fuera de la vista;
   - opcional: un minimapa de 15 puntos en el panel. Es una sugerencia, no la pidió nadie: va a §13 si interesa.

---

## 5. Interacción: tocar selecciona y solo «Jugar» inicia

### 5.1 Qué hace hoy

| Dónde | Acción | Resultado | Código |
|---|---|---|---|
| Mapa | Clic en una región | **Selecciona e inicia** | `campaign_map_view.gd:122-125` (`select` y `_request` seguidos) |
| Mapa | Foco (flechas, Tab) | Solo selecciona | `:59` (`focus_entered` → `select`), `:95-108` |
| Mapa | Enter o Espacio sobre la región enfocada | Inicia: el `Button` emite `pressed` con `ui_accept` | El test `test_keyboard_accept_on_focused_region_opens_it` |
| Mapa | «Jugar» | Inicia la seleccionada; si está bloqueada, nada | `:112-113`, `:168-172` |
| Tarjetas de campaña | Clic | **Inicia** | `level_select.gd:404` |
| Tarjetas de Asedio | Clic | **Inicia** | `level_select.gd:273` |
| Tarjetas de comunidad | Clic | **Inicia** | `level_select.gd:582` |

Los tests que fijan el comportamiento actual y habría que cambiar: `test_click_on_available_region_opens_that_level_once` y `test_keyboard_accept_on_focused_region_opens_it`, en `tests/test_campaign_map.gd:256-321`.

### 5.2 Propuesta de decisión

**D-A4 · En el mapa, tocar una región la selecciona; la partida empieza con «Jugar» (PENDIENTE DE LUCAS)**
- **Qué:**
  - Clic en una región: la selecciona y actualiza la ficha. **No inicia.**
  - Clic en una bloqueada: la selecciona y muestra «Bloqueada · ganá el nivel anterior». «Jugar» queda deshabilitado, como hoy.
  - «Jugar» inicia la seleccionada.
  - **Enter o Espacio sobre la región enfocada equivalen a «Jugar»**: con teclado, el foco ya es la selección y confirmar es el paso explícito.
  - **Doble clic: no inicia** en la primera versión (ver alternativas).
- **Alternativas:**
  - **Alcance:**
    - (i) solo el mapa (**recomendada**);
    - (ii) el mapa y las tarjetas de campaña de desktop: cada tarjeta selecciona y aparece una ficha con «Jugar». Pero RF-646 pide 15 tarjetas sin scroll y las tres filas ya ocupan 458 px de alto (3 × 146 + 2 × 10): la ficha obliga a achicar las tarjetas o a sacar el pie;
    - (iii) todo el selector desktop, con Asedio, comunidad y modos.
    Lo recomendado es (i) ahora y (ii) solo si Lucas quiere coherencia entre las vistas, en otra tarea.
  - **Doble clic:**
    - (a) no inicia (**recomendada**: respeta «solo Jugar inicia» y evita arrancar al explorar);
    - (b) inicia (convención de escritorio, más rápida).
  - **Segundo clic sobre la ya seleccionada:** (a) no inicia (**recomendada**); (b) inicia, al estilo de «tocar dos veces» en el celular, con riesgo de arrancar sin querer.
  - **Enter:** (a) inicia (**recomendada**); (b) mueve el foco a «Jugar» y hay que apretar Enter otra vez (más estricto y más lento).
- **Qué cambia:** RF-648 (se enmienda: «abrir solo un nivel habilitado» pasa a ser con «Jugar» o con Enter), `campaign_map_view.gd`, `campaign_region.gd` y los dos tests citados.

**Cómo se implementa sin ambigüedad.** Para decidir qué hace «pressed», hay que saber de dónde vino:
- **Mouse:** en `CampaignRegion._gui_input`, el clic izquierdo llama a `select` y consume el evento (`accept_event`), así no llega a emitirse `pressed`. Si D-A4 elige el doble clic (b), `double_click` llama a `request`.
- **Teclado:** `pressed` solo llega por `ui_accept` y llama a `request_selected`.

Alternativa más simple: `action_mode = ACTION_MODE_BUTTON_PRESS` combinado con una marca «vino del mouse». Hay que medirlo con un test de input real (`push_input`), como los que ya existen.

### 5.3 Foco y teclado

**Hoy:**
- Izquierda y derecha siguen el orden de la ruta (`:62-66`).
- Esc vuelve al menú (`level_select.gd:102-105`).
- El foco arranca en la región seleccionada (`:93-94`).

**Agregar:**
- `focus_neighbor_bottom` de cada región → `PlayButton`, y `focus_neighbor_top` de `PlayButton` → la región seleccionada. Así el «bajo y confirmo» funciona con flechas, sin Tab.
- `follow_focus` del scroll (§4.4), para que la región enfocada siempre se vea.
- **Arriba y abajo entre regiones** no tienen sentido en una ruta lineal: se dejan para el botón «Jugar» y la fila de solapas.
- El anillo de foco no depende del color: ya tiene borde (`campaign_region.gd:39`).

### 5.4 Resoluciones
- El viewport es fijo en 1280×720 con `canvas_items` y `aspect` en `keep` (`project.godot:35-37`). En 1920×1080 se escala todo igual, y la vista sigue midiendo 1090 px lógicos.
- **Dependencia con el frente B:** si B pasa a `aspect=expand`, el área del mapa puede ganar ancho. El scroll lo absorbe sin cambios, pero hay que volver a capturar.
- **RF-654:** cada tarea de código captura 1280×720 y 1920×1080, con el scroll en tres posiciones: inicio, medio y final.

### 5.5 Mobile (RF-653)
- **Recomendación:** en la V1, el mapa **no** llega al celular. RF-653 y D-178 lo dejan afuera, y estas razones lo confirman:
  - los marcadores de 44 px quedan por debajo de los 56 px táctiles (RF-550);
  - el arrastre para desplazar choca con tocar para seleccionar;
  - G5 no lo probaría en un dispositivo.
- **Si Lucas lo quiere en el celular:** hace falta un RF propio con marcadores de 56 px, arrastre con umbral (como `MenuTouch`) y una prueba en un dispositivo real. Va al backlog.
- **«Tocar selecciona» tampoco se lleva a las tarjetas del celular**, porque RF-653 prohíbe cambios móviles por inferencia.
- **La clave `selector_style_chosen` no cambia nada en el celular:** ya hoy el estilo se ignora ahí (`level_select.gd:114`, `:126`).

---

## 6. Tareas propuestas

Los números son provisionales: los asigna la tarea 📜 que registre M75. Hay tres compuertas:
- 🚦 **Lucas** aprueba las decisiones D-A1 a D-A4.
- 🎨 **Arte:** pasa por Codex y la aprueba Lucas.
- **Orden:** como máximo **dos tareas de código a la vez**, y las que tocan `level_select.gd` o `campaign_map_view.gd` van en serie.

| # | Tarea | Quién | Depende de | Archivos | Hecho cuando |
|---|---|---|---|---|---|
| **A-1** 📜 | Registrar M75 (desde B-52): RF-A1, la enmienda de RF-645, RF-647, RF-648 y RF-389; D-A1 a D-A4, con D-178 revisada; fichas de A-2 a A-9 | Claude (Sonnet) | 🚦 Lucas sobre §7 | `specs/01`, `02`, `03`, `04`, `specs/tareas/` | RF y D con «Dado / Cuando / Entonces», números fijados sin chocar con otros frentes, Lucas da el OK. |
| **A-2** 🎨 | **Arte nuevo del atlas** (rehace la muestra aprobada en T427): fondo de unos 2400×472 con costa, siete biomas orgánicos, sierra, río y aterrizaje en tierra según §4.3. Captura a 1280×720 en tres posiciones de scroll. Procedencia y peso. | **Codex** | A-1 (D-A3) | `art/t4xx-atlas-biomas/mapa.svg`, capturas y `README.md`. Después del OK: `assets/ui/campaign_map_background.svg` | Lucas aprueba (RF-652). El SVG editable pesa poco (el actual pesa unos 4 KB); el script de §4.3 o el test de A-3 dan OK con las coordenadas que use el arte. |
| **A-3** | **Modelo geográfico:** las constantes nuevas de `CampaignMap` (`SEA_SIZE`, `LANDER`, `REGION_POINTS`, `LAND_COORDS`, `BIOME_BORDERS`) y un test que porte el script: aterrizaje y regiones en tierra, distancia a la costa al menos r + 4, bioma correcto, tramos sin mar y sin cruces | Claude (Sonnet) | A-2 aprobada | `scripts/logic/campaign_map.gd`, `tests/test_campaign_map.gd` | Test nuevo en verde y GUT completo sin `SCRIPT ERROR`. |
| **A-4** | **Scroll lateral:** separar `MapCanvas` desplazable de la capa fija (título, leyenda, rosa, `InfoPanel`); `follow_focus`; posición inicial en la selección; rueda horizontal; indicadores de borde | Claude (Sonnet) | A-3 | `scenes/ui/campaign_map_view.gd`, `scenes/ui/level_select.gd` (`:158-163`), tests | Con un progreso en el 12, el 12 se ve al abrir; las flechas recorren las 15 y cada una entra en la vista; la leyenda no se mueve; capturas en 1280×720 y 1920×1080 (RF-654). |
| **A-5** | **Tocar selecciona** (D-A4): clic → `select`; Enter/Espacio → `request`; doble clic según la decisión; vecinos de foco con «Jugar» | Claude (Sonnet) | A-1. Puede ir antes que A-2, con el mapa actual. | `scenes/ui/campaign_map_view.gd`, `scenes/ui/campaign_region.gd`, `tests/test_campaign_map.gd` | El clic no abre (el test invierte el de `:256`); Enter abre una sola vez; una bloqueada nunca abre; abajo desde una región lleva a «Jugar». |
| **A-6** | **Mapa por omisión con migración** (D-A2, M1): clave aditiva `selector_style_chosen` y nuevo `style_from` | Claude (Sonnet) | **A-3 y A-4 integradas** (no se muestra primero el mapa defectuoso) | `scripts/autoload/save_manager.gd`, `scripts/logic/campaign_map.gd`, `scenes/ui/level_select.gd` (`set_style`), `tests/test_old_saves.gd`, `tests/test_campaign_map.gd` | Los tres casos de §3.3 en verde; mobile sigue con tarjetas; `SAVE_VERSION` sigue en 1. |
| **A-7** | **Explicar Asedio** (D-A1, parte A): encabezado de la solapa, insignia «+N % vida» calculada, tarjeta con identidad propia, estado en el HUD o la pausa | Claude (Sonnet). Si hace falta un ícono nuevo, la parte de arte va a Codex 🎨. | A-1 | `scenes/ui/level_select.gd` (`_show_mode`, `_make_mode_card`), `scenes/game/hud.gd` o `pause_menu.gd`, `tests/test_mode_select.gd`. Texto en `data/modos/asedio/modo.json` solo si cambia la descripción. | Las 15 tarjetas muestran el porcentaje que lee `ModePacks` (el test compara con RF-494); el encabezado se ve sin hover; la campaña no cambia. |
| **A-8** | **Desafíos y récords de modos** (D-A1, parte B; absorbe T235 paso 3): grupo «Desafíos» con sub-solapas desplazables; Récords con un selector de modo | Claude (Sonnet) | A-7 | `scenes/ui/level_select.gd` y `.tscn`, `scenes/ui/records_screen.gd` y `.tscn`, `scripts/autoload/game_flow.gd` (`select_page`), tests de selección y de récords | Con cinco modos propios, todas las solapas son alcanzables; «Niveles» vuelve a la misma sub-solapa (RF-225); Récords muestra el top 5 de `modo_asedio_level_NN`; T235 cerrada como absorbida. |
| **A-9** | **Cierre:** capturas finales, CHANGELOG, README, ONBOARDING (cómo probar), CONTENIDO si cambia el formato | Claude (Sonnet) | A-4 a A-8 | Documentos y `art/t4xx-capturas/` | Documentos coherentes en todos los lugares (regla de CLAUDE.md) y GUT completo en verde. |

**Qué es arte y qué no:**
- **Solo A-2 es arte** (y A-7 si se pide un ícono nuevo). Pasa por **Codex** con la compuerta 🎨, y **rehace la muestra que Lucas aprobó en T427**: no se toca `art/t427-mapa-propuesta/` (queda como historia) ni `assets/ui/campaign_map_background.svg` hasta que Lucas apruebe.
- Los estados de cada región se siguen dibujando en la interfaz (RF-652), no en la imagen.

**Orden sugerido:**
1. A-1.
2. A-2 en paralelo con A-5 y A-7. A-5 toca la vista del mapa y A-7 `level_select.gd`: no comparten archivos.
3. A-3, después A-4 y después A-6.
4. A-8, después de A-7, porque comparten `level_select.gd`.
5. A-9.

**Choques con otros frentes** (matriz §5):
- `save_manager.gd` y `test_old_saves.gd` los tocan también C y E. Las claves son aditivas y distintas, pero cada rama tiene que sincronizarse antes de su PR.
- Si A-7 pone el estado en la pausa, `pause_menu.gd` también lo toca E.

---

## 7. Decisiones para Lucas

| # | Pregunta | Opciones | Recomendación de Claude |
|---|---|---|---|
| **L-1** | ¿Cómo se diferencian Campaña y Asedio? (D-A1) | A explicar · A + B con Desafíos y récords · C desbloqueo atado a la campaña | **A + B.** C queda para después de G5. |
| **L-2** | ¿T235 (solapas y récords de los modos) entra en la 1.0 y se absorbe en A-8? | Sí / no / después | **Sí**, absorbida en A-8. |
| **L-3** | ¿El mapa pasa a ser la vista inicial de la campaña en desktop? (D-A2, revisa D-178 y RF-645) | Sí / no | **Sí**, pero **recién cuando la geografía nueva esté integrada.** |
| **L-4** | Migración de guardados | M1 todos pasan al mapa una vez · M2 solo los guardados nuevos · M3 aviso | **M1.** Hoy no se puede distinguir quién eligió tarjetas, y la beta no tiene jugadores públicos. |
| **L-5** | El valle del 15: ¿vuelve cerca del oasis o queda más allá del paso? (§4.1) | Más allá del paso (lineal) / al lado del oasis (anillo) | **Más allá del paso.** |
| **L-6** | La geografía nueva (D-A3) | (a) solo mover el aterrizaje · (b) lineal sin scroll · (c) lineal con scroll lateral · (d) anillo justificado | **(c)**, con las coordenadas de §4.3 como punto de partida para Codex. |
| **L-7** | ¿Se rehace la muestra aprobada en T427? | Sí, con la compuerta 🎨 / no | **Sí.** Sin eso no hay aterrizaje en tierra ni biomas. |
| **L-8** | Alcance de «tocar selecciona» (D-A4) | (i) solo el mapa · (ii) también las tarjetas de campaña · (iii) todo el selector | **(i).** (ii) choca con RF-646. |
| **L-9** | ¿Enter sobre la región enfocada inicia? | Sí / no (solo «Jugar») | **Sí.** |
| **L-10** | ¿El doble clic inicia? ¿Y el segundo clic sobre la ya seleccionada? | Sí / no | **No a los dos.** |
| **L-11** | ¿El mapa llega al celular? | No en la V1 / sí, con un RF propio | **No en la V1.** |
| **L-12** | ¿Asedio 7 al 101 % ya cumple? (T444, hallazgo 2) | Confirmar el remedido de T279 / mantener «no cumple» | Confirmarlo en G5. **No es de este frente:** lo anoto porque cambia la tabla que mostraría A-7. |

## Decisiones de Lucas (2026-10-23)

> Registradas por Claude a partir de las respuestas de Lucas en la sesión. **Todavía no son D ni RF** y nada está implementado; los números de D/RF los fija la tarea de spec. Lo que dice «a aclarar» queda abierto.

1. **Campaña vs Asedio (L-1):** **Asedio se desbloquea mapa por mapa** al ganar el mismo nivel en campaña (Asedio 3 al ganar el nivel 3, etc.). **Cambia el acceso actual** (hoy Asedio está abierto desde el principio). Los **guardados que ya jugaron Asedio conservan el acceso** y sus récords. A aclarar en la spec: modo de pruebas, y el orden de la prueba G5 (L-12 queda como confirmación en G5).
2. **Vista inicial (L-3):** el **mapa planetario es la vista inicial ya**, con las tarjetas como alternativa, y se actualiza cuando esté la geografía nueva. **Vale también para el celular**, lo que **enmienda RF-653** («el selector celular queda igual») y exige definir gestos táctiles (tocar, arrastrar, desplazar); el mapa nunca se probó en un celular real.
3. **Migración (L-4):** **todos los guardados pasan al mapa una vez** (hace falta una clave nueva).
4. **Geografía (L-5/L-6):** camino **en serrucho de oeste a este**, aterrizaje **en tierra**, y scroll lateral **solo si hace falta**. Las zonas no conquistadas se ven **más grises**; la forma de cada zona **no es geométrica** sino orgánica, como los límites de un mapa.
5. **Arte (L-7):** Codex hace una muestra que **rehace la de T427**, y **nada se integra sin la aprobación de Lucas**.
6. **Tocar selecciona (L-8):** **solo el mapa**; las tarjetas siguen iniciando con un clic (RF-646). **Enter** sobre la región enfocada **inicia** (L-9); el **doble clic no** (L-10).
7. **T235 (L-2):** **se absorbe** en el trabajo del selector.
8. **Estandarte de conquista en el selector:** además de las 3 estrellas, el **banderín del jugador** se muestra en la **tarjeta** y en el **mapa**, como fondo del círculo que contiene el número del nivel. Una zona **no tomada por completo** muestra un fondo **mitad escudo rebelde, mitad el nuestro**.
9. **Limpieza visual del mapa:** se **quitan las aclaraciones «tomada / rebeldes / bloqueada»** (se sobreentienden) y a los números de nivel se les **saca el cero** a la izquierda (01 → 1); **a aclarar** en qué pantallas.
10. **Banderines en el nivel:** la idea es un **poste con banderín** en los mapas, con la receta del editor, cuando se logran las 3 estrellas. **Hoy solo el nivel 6 tiene poste** (`level_06.json`; RF-656 lo hace cambiar con cualquier victoria, no con 3 estrellas). Lucas pidió sumar postes en los niveles 2 y 3 y en los últimos cinco, sin hacerlo en todos; cambiar mapas **requiere spec y su OK a cada uno**.
11. **L-11:** el mapa **sí llega al celular** (ver punto 2). **L-12:** Asedio 7 al 101 % se confirma en G5.
