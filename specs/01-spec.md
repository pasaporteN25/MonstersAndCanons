# 01 — Especificación del juego (el "QUÉ")

> **Qué es este documento:** describe **qué hace el juego**, como si se lo explicaras a alguien que va a jugarlo. **No** habla de código, escenas ni Godot; eso está en [`02-plan-tecnico.md`](02-plan-tecnico.md).
>
> **Cómo leer los requisitos:** cada regla tiene un código (`RF-12`, *Requisito Funcional 12*) para poder mencionarla desde las tareas y el código. Las reglas importantes traen un **criterio de aceptación** con el formato:
>
> - **Dado** (la situación inicial) → **Cuando** (lo que pasa) → **Entonces** (el resultado esperado).
>
> Así cualquiera puede comprobar si la regla está bien implementada.
>
> **Sobre los números:** todos los valores de balance (costos, vida, daño…) son **valores iniciales**. Se ajustarán jugando. Cambiarlos está bien, pero se cambia **también aquí** (constitución P3).

---

## 1. Visión

Un tower defense **2D visto desde arriba**, con partidas cortas (10–20 minutos por nivel), donde el jugador construye torres en una cuadrícula junto a un camino fijo para impedir que las oleadas de enemigos lleguen a la salida.

**Lo que hace divertido al juego** (si algo no aporta a esto, sobra):
1. **Decidir dónde construir:** las curvas del camino son lugares valiosos, porque una torre ahí alcanza más tramo de camino.
2. **Decidir en qué gastar:** ¿una torre nueva o mejorar la que ya tengo?
3. **Adaptarse a los enemigos:** cada tipo de enemigo exige una respuesta distinta (voladores, blindados, rápidos…).

**Plataforma:** PC (Windows), con mouse y teclado.

---

## 2. Hitos (qué se construye primero)

El juego completo es grande, así que se construye por **hitos**. Al terminar cada hito el juego es jugable de principio a fin.

| Hito | Nombre | Qué agrega | Resultado |
|---|---|---|---|
| **M0** | Preparación | Proyecto Godot vacío, carpetas, git, tests. | Se abre una ventana vacía. |
| **M1** | Núcleo jugable (MVP) | 1 mapa, 3 torres, 3 enemigos, 10 oleadas, ganar/perder. | **Ya es un juego.** |
| **M1.5** | Pulido visual | Efectos y animaciones con el estilo geométrico actual: torres que apuntan, impactos, explosiones, oro flotante, mapa más vistoso, avisos en pantalla. Adelantado por pedido de Lucas (D-016). | Un juego que da gusto mirar. |
| **M2** | Profundidad | Mejorar y vender torres, 4.ª torre, 3 enemigos nuevos (voladores, blindados, jefe), velocidad x2, pausa, modos de apuntado. | Un juego con decisiones interesantes. |
| **M3** | Juego completo | Menú principal, selección de nivel, 3 mapas, guardado de progreso, opciones, sonido. | El "juego mediano" terminado. |
| **M4** | Pulido *(opcional)* | Arte, animaciones, partículas, mapas 4 y 5, balance fino. | Un juego que da gusto mostrar. |
| **MA** | Android *(prueba)* | Exportar un `.apk` para celular con las adaptaciones mínimas al tacto (§9.4). Pedido por Lucas (D-021). | El juego se instala y se juega en un celular. |

La columna **Hito** de las tablas siguientes indica en qué momento se agrega cada cosa.

---

## 3. El mapa

- **RF-01** El mapa es una **cuadrícula** de **20 columnas × 9 filas** *(M13: los mapas pueden ser más grandes, hasta 26×12, RF-250)*; cada casilla mide 64×64 píxeles (el mapa ocupa 1280×576 y deja espacio arriba y abajo para la interfaz).
- **RF-02** Cada casilla es de uno de estos tipos:
  - **Camino:** por aquí caminan los enemigos terrestres. No se puede construir.
  - **Libre:** se puede construir una torre.
  - **Bloqueada:** decoración (roca, agua…). No se puede construir.
- **RF-03** Cada mapa tiene una o más **entradas** (donde aparecen los enemigos) y **una salida** (a donde intentan llegar).
- **RF-04** Los enemigos **terrestres** siguen el camino desde su entrada hasta la salida, sin desviarse.
- **RF-05** *(M2)* Los enemigos **voladores** ignoran el camino y vuelan **en línea recta** desde su entrada hasta la salida.
- **RF-06** *(M4)* **La salida se ve.** Si un camino termina **dentro** del mapa (no en un borde), en esa casilla se dibuja una **puerta**. Una entrada también puede estar en el borde de **arriba** o de **abajo**, no solo a los costados.

---

## 4. Partida: vidas, oro y oleadas

### 4.1 Vidas

- **RF-10** El jugador empieza cada nivel con **20 vidas**.
- **RF-11** Cuando un enemigo llega a la salida, desaparece y el jugador pierde tantas vidas como el valor **"Vidas que quita"** de ese enemigo (ver tabla de enemigos).
- **RF-12** Si las vidas llegan a **0**, el jugador **pierde** de inmediato (ver §8).

> **Criterio de aceptación RF-11**
> **Dado** que tengo 20 vidas → **Cuando** un Tanque (quita 2) llega a la salida → **Entonces** tengo 18 vidas y el Tanque ya no está en el mapa.

### 4.2 Oro

- **RF-20** El jugador empieza con el **oro inicial del nivel** (nivel 1: **150**).
- **RF-21** Matar un enemigo da el oro indicado en su columna **"Oro"**.
- **RF-22** Al **terminar una oleada**, el jugador recibe un bono de **20 + 5 × número de oleada** (oleada 1 → 25, oleada 10 → 70).
- **RF-23** Construir y mejorar cuesta oro. Si no alcanza el oro, no se puede hacer (el botón aparece desactivado/gris).
- **RF-24** El oro nunca puede ser negativo.

### 4.3 Oleadas

- **RF-30** Un nivel tiene un número fijo de oleadas (nivel 1: **10**).
- **RF-31** Cada oleada está formada por uno o más **grupos**. Un grupo es: *"N enemigos de tipo X, saliendo cada S segundos, empezando T segundos después del inicio de la oleada"*.
- **RF-32** Al empezar el nivel, **no** llega ninguna oleada hasta que el jugador pulsa **"Empezar oleada"**. Así puede construir con calma primero.
- **RF-33** Una oleada **termina** cuando ya salieron todos sus enemigos **y** no queda ninguno vivo en el mapa (muertos o llegados a la salida).
- **RF-34** Entre oleadas hay una **cuenta atrás de 15 segundos**; al llegar a 0 empieza la siguiente. El jugador puede pulsar **"Empezar oleada"** para no esperar.
- **RF-35** No se puede llamar a la siguiente oleada mientras la actual está en curso.
- **RF-36** **Dificultad creciente:** la vida de cada enemigo se multiplica según la oleada:
  `vida real = vida base × (1 + 0.40 × (número de oleada − 1))`
  Ejemplo: un Normal (30 de vida) tiene 30 en la oleada 1, 30 × 1.4 = **42** en la oleada 2 y 30 × 4.6 = **138** en la oleada 10 (se redondea hacia abajo). El aumento es fuerte a propósito: así las últimas oleadas presionan aunque el jugador haya juntado mucho oro (ver §7.1).

> **Criterio de aceptación RF-33 / RF-22**
> **Dado** que la oleada 3 está en curso → **Cuando** muere o escapa el último enemigo de la oleada → **Entonces** recibo 35 de oro, el contador muestra "Oleada 3/10 completada" y empieza la cuenta atrás de 15 s.

---

## 5. Torres

### 5.1 Construir

- **RF-40** El jugador elige una torre en la barra inferior (o con las teclas **1–9**; en M1–M4 eran 1–4 y hasta M18, 1–8). Aparece una **vista previa** de la torre que sigue al mouse, "pegada" a la cuadrícula, mostrando su **círculo de alcance**.
- **RF-41** La vista previa se ve **verde** si se puede construir en esa casilla y **roja** si no.
- **RF-42** Se puede construir en una casilla solo si: es **Libre**, **no tiene** otra torre y el jugador **tiene el oro**.
- **RF-43** **Clic izquierdo** construye (y se descuenta el oro). La vista previa **sigue activa** para poder construir otra igual. **Clic derecho** o **Esc** cancelan.
- **RF-44** Se puede construir **en cualquier momento**, también durante una oleada.

> **Criterio de aceptación RF-42**
> **Dado** que tengo 60 de oro → **Cuando** intento construir una Ametralladora (50) sobre el camino → **Entonces** no se construye, la vista previa está roja y sigo teniendo 60 de oro.

### 5.2 Disparar

- **RF-50** Cada torre dispara **automáticamente** al enemigo elegido dentro de su alcance, según su cadencia.
- **RF-51** Por defecto la torre apunta al enemigo **"Primero"**: el que está **más cerca de llegar a la salida**.
- **RF-52** Los proyectiles **siempre impactan**: persiguen a su objetivo. Si el objetivo muere antes de que llegue, el proyectil sigue hasta el último lugar donde estaba el objetivo; allí, si es de área, explota igual; si no, desaparece sin hacer daño.
- **RF-53** Las torres marcadas "No" en la columna **Aire** ignoran a los enemigos voladores (ni los apuntan ni les hacen daño de área).
- **RF-54** *(M2)* Al seleccionar una torre se puede cambiar su **modo de apuntado**:
  - **Primero** — el más cercano a la salida *(por defecto)*.
  - **Último** — el más lejos de la salida.
  - **Más fuerte** — el que tiene más vida actual.
  - **Más cercano** — el más cerca de la torre.
- **RF-55** Los proyectiles viajan a **10 casillas por segundo** (todas las torres). Es lo bastante rápido para que casi nunca lleguen tarde, y lo bastante lento para que se vean. *(M5: el rayo de la Eléctrica va a 20 y las púas de la Ráfaga a 6; ver §5.6.)*

### 5.3 Tabla de torres (nivel 1 de cada torre)

> *Alcance y radio en casillas. Cadencia en disparos por segundo. DPS = daño × cadencia (a un solo objetivo).*

| ID | Nombre | Costo | Daño | Cadencia | DPS | Alcance | Especial | Aire | Forma provisional | Hito |
|---|---|---|---|---|---|---|---|---|---|---|
| `basic` | **Ametralladora** | 50 | 5 | 2.0 | 10 | 3.0 | — | Sí | Cuadrado gris | M1 |
| `cannon` | **Cañón** | 100 | 20 | 0.6 | 12 | 3.0 | Daño en área, radio 1.0 | **No** | Cuadrado negro | M1 |
| `frost` | **Hielo** | 75 | 2 | 1.0 | 2 | 2.5 | Ralentiza 40 % durante 2 s | Sí | Cuadrado celeste | M1 |
| `sniper` | **Francotirador** | 150 | 40 | 0.4 | 16 | 6.0 | — | Sí | Cuadrado verde oscuro | M2 |

**Rol de cada torre** (para qué existe):
- **Ametralladora:** barata y confiable. Buena contra enemigos débiles y rápidos. Mala contra armadura (su daño es bajo, y la armadura resta mucho).
- **Cañón:** golpea a grupos. Brilla cuando los enemigos van juntos. No sirve contra voladores.
- **Hielo:** casi no hace daño, pero hace que los enemigos pasen más tiempo dentro del alcance de las **otras** torres.
- **Francotirador:** muchísimo alcance y daño por golpe. Ideal contra blindados y el jefe.

### 5.4 Ralentización

- **RF-60** Un enemigo ralentizado se mueve a `velocidad × (1 − ralentización)`. Con 40 %: a 60 % de su velocidad normal.
- **RF-61** Las ralentizaciones **no se suman**: si le llegan dos, se aplica **la más fuerte**. Cada nuevo golpe **reinicia** la duración.
- **RF-62** Un enemigo ralentizado se ve teñido de **azul**.

### 5.5 Mejorar y vender *(M2)*

- **RF-70** Al hacer clic en una torre construida se abre un **panel** con: nivel actual, estadísticas, botón **Mejorar** (con su costo), botón **Vender** (con el oro que devuelve) y el modo de apuntado.
- **RF-71** Cada torre tiene **3 niveles**. El nivel 1 es al construirla; se puede mejorar dos veces.
- **RF-72** **Vender** elimina la torre y devuelve el **70 %** de todo el oro invertido en ella (construcción + mejoras), redondeado hacia abajo.

> **Criterio de aceptación RF-72**
> **Dado** una Ametralladora construida (50) y mejorada a nivel 2 (60) → **Cuando** la vendo → **Entonces** recibo 77 de oro (70 % de 110) y la casilla vuelve a estar libre.

- **RF-73** **Seleccionar:** clic izquierdo sobre una torre la selecciona (se ve su círculo de alcance). Clic sobre otra casilla del mapa, clic derecho o `Esc` la deseleccionan. Elegir una torre para construir deselecciona la torre construida, y viceversa: nunca hay las dos cosas a la vez.
- **RF-74** **Dónde está el panel:** flota a la derecha, justo encima de la barra inferior, y **no** tapa los botones. Mientras está abierto, los clics sobre él no llegan al mapa.
- **RF-75** **El nivel se ve:** cada torre muestra remaches encastrados en una placa de la base con su nivel (1, 2 o 3; RF-350) y, al mejorarse, aparece el mismo anillo que al construirla (RF-130).
- **RF-76** **Tecla y oro:** `U` mejora y `S` vende la torre seleccionada. El botón **Mejorar** se ve gris si no alcanza el oro, y dice "Nivel máximo" en el nivel 3.

**Tabla de mejoras** (solo se indica lo que cambia respecto al nivel anterior):

| Torre | Nivel 2 | Nivel 3 |
|---|---|---|
| Ametralladora | Costo 60 · daño 8 · cadencia 2.5 | Costo 100 · daño 12 · cadencia 3.0 · alcance 3.5 |
| Cañón | Costo 110 · daño 32 · radio 1.2 | Costo 170 · daño 50 · radio 1.5 · alcance 3.5 |
| Hielo | Costo 80 · ralentiza 50 % · alcance 3.0 | Costo 120 · ralentiza 60 % durante 3 s · daño 4 |
| Francotirador | Costo 150 · daño 70 | Costo 225 · daño 120 · alcance 7.0 |

### 5.6 Torres nuevas *(M5, pedidas por Lucas)*

Cuatro torres nuevas, pensadas como **respuesta** a los enemigos nuevos (§6.1). **Principio (RF-164):** cada comportamiento es un **dato** de la torre o del enemigo, no un caso especial en el código. Por eso cualquier torre puede combinar varios (por ejemplo, un rayo que además quema), y crear contenido nuevo (o un mod, B-04) es escribir datos y hacer dibujos.

- **RF-160** **Quemadura:** si el golpe trae quemadura, el enemigo **se prende fuego**: recibe `X` de daño por segundo durante `Y` segundos, de a golpecitos cada 0,5 s. El fuego **ignora la armadura**. Las quemaduras **no se suman**: queda la más fuerte y cada golpe nuevo **reinicia** el tiempo (igual que la ralentización, RF-61). Un enemigo que se quema **no se regenera** (RF-165). Se ve con llamitas encima.
- **RF-161** **Varios objetivos:** la torre dispara **a la vez** a sus `N` mejores objetivos según su modo de apuntado (RF-54), un proyectil a cada uno. Si hay menos enemigos en alcance, dispara a los que haya.
- **RF-162** **Ráfaga en círculo:** si hay algún enemigo en alcance, la torre lanza `N` púas repartidas en círculo (todas las direcciones por igual). Cada púa va **en línea recta** hasta el borde del alcance; golpea al **primer enemigo que toca** (si puede golpearlo, RF-53) y desaparece. Si no toca a nadie, se pierde. Es la única torre cuyos tiros **pueden fallar**.
- **RF-163** **Rayo en cadena:** después de golpear a su objetivo, el rayo **salta** al enemigo más cercano que todavía no golpeó (a menos de `D` casillas del último), hasta `N` saltos. Cada salto hace el mismo daño (con armadura). Se ve un rayo en zigzag que une a todos los golpeados.
- **RF-164** **Todo son datos:** quemadura, varios objetivos, ráfaga, rayo en cadena, regeneración y crías (§6.1) son campos de los datos (`TowerLevelData` y `EnemyData`), apagados por defecto (valen 0). Se pueden combinar libremente. La guía `CONTENIDO.md` explica cada campo.

| ID | Nombre | Costo | Daño | Cadencia | Alcance | Especial | Aire | Proyectil |
|---|---|---|---|---|---|---|---|---|
| `fire` | **Incendiaria** | 90 | 5 | 1.0 | 2.5 | Quema 8 por segundo durante 3 s | Sí | Bola de fuego (10) |
| `multi` | **Múltiple** | 100 | 7 | 1.3 | 3.0 | Dispara a 2 enemigos a la vez | Sí | Dardo (10) |
| `burst` | **Ráfaga** | 110 | 10 | 0.8 | 2.0 | 8 púas en círculo | **No** | Púa (6) |
| `tesla` | **Eléctrica** | 130 | 13 | 0.75 | 2.5 | El rayo salta a 2 enemigos más (hasta 1,5 casillas) | Sí | Rayo (20) |

**Rol de cada torre:**
- **Incendiaria:** el fuego ignora la armadura y **corta la regeneración**: es la respuesta al Troll (§6.1).
- **Múltiple:** reparte los tiros: buena contra muchos enemigos débiles (crías de araña, Rápidos).
- **Ráfaga:** barre todo lo que tiene alrededor. Rinde más en una **curva** del camino, rodeada de enemigos. No sirve contra voladores, y sus púas pueden fallar.
- **Eléctrica:** golpea a varios enemigos juntos, también voladores. Cara y de alcance corto.

**Tabla de mejoras:**

| Torre | Nivel 2 | Nivel 3 |
|---|---|---|
| Incendiaria | Costo 90 · daño 7 · quema 12 por segundo | Costo 140 · daño 10 · quema 18 por segundo durante 4 s · alcance 3.0 |
| Múltiple | Costo 90 · daño 9 · a 3 enemigos | Costo 140 · daño 12 · a 4 enemigos · alcance 3.5 |
| Ráfaga | Costo 100 · daño 13 · 10 púas · cadencia 0.9 | Costo 150 · daño 17 · 12 púas · cadencia 1.0 · alcance 2.5 |
| Eléctrica | Costo 120 · daño 19 · salta a 3 · cadencia 0.85 | Costo 180 · daño 27 · salta a 4 · cadencia 0.95 · alcance 3.0 |

**Cómo se balancearon (T84):** con los primeros números (daño 3, 6, 8 y 12), el bot que usa las 8 torres jugaba **peor** que el que usa las 4 viejas (por ejemplo, en el nivel 1 ganaba con 1 vida en vez de 13): cada moneda rendía más en Ametralladoras. Se subió el daño y la cadencia de las cuatro hasta que el bot con las 8 torres quedó parejo con el de las 4 viejas (resultados en §7.4). El fuego de varias Incendiarias no se suma (RF-160), así que conviene tener una por tramo, no muchas juntas.

### 5.7 Torres de 2×2: el Mortero *(M19, pedido por Lucas, D-041, D-044, B-16 forma B)*

Hasta ahora toda torre ocupa **una** casilla. Esta etapa enseña al juego a manejar torres **más grandes** y estrena la primera: el **Mortero**, que se construye **directo** en un cuadrado de 2×2. Es la base para la fusión de cuatro torres (B-16 forma A, más adelante) y la respuesta a los enemigos más duros (Guardián, Tanque, jefe).

- **RF-290** **Tamaño como dato:** `TowerData` gana `footprint` (el **lado** de la torre en casillas: `1` = una casilla, `2` = cuadrado de 2×2). Vale `1` por defecto, así que las ocho torres de hoy **no cambian**. Sin casos especiales en el código (RF-164): cualquier torre futura puede declarar su tamaño.
- **RF-291** **Dónde se puede construir:** una torre de `footprint` 2 necesita que **sus cuatro casillas** sean Libres (RF-42), estén dentro del mapa y **no tengan** otra torre; además, el oro. Si **una sola** casilla falla, no se construye (y no se cobra).
- **RF-292** **Vista previa:** la vista previa de una torre grande **se centra en el mouse** y se "pega" a la cuadrícula (el centro queda en la esquina común de las cuatro casillas más cercanas al mouse). Las **cuatro** casillas se pintan **verdes** si se puede construir y **rojas** si no (RF-41); el dibujo y el círculo de alcance salen desde el centro del cuadrado. Una torre de una casilla se ve **igual que siempre**.
- **RF-293** **Ocupación y selección:** la torre ocupa sus cuatro casillas: un clic en **cualquiera** de ellas la selecciona (RF-73), y ninguna puede usarse para otra torre. La torre **apunta y mide su alcance desde el centro** del cuadrado.
- **RF-294** **Vender y mejorar:** funcionan **igual** que en las demás (RF-70 a RF-76, devuelve el 70 %, RF-72). Al vender, **las cuatro casillas** vuelven a estar libres.
- **RF-295** **Dibujo:** la torre grande se dibuja **el doble de grande** (2×2 casillas): la base del nivel (`base_1`/`base_2`/`base_3`, que son dibujos vectoriales y escalan sin perder nitidez), la sombra, la torreta, la placa/remaches de nivel, el aturdimiento (RF-280) y el anillo de construcción (RF-130) se **escalan** con el tamaño. El Chamán y el Espejo (RF-282, RF-284) la tratan como a cualquier torre: miden hasta su **centro**.
- **RF-296** **El Mortero** (`mortar`, tecla **9**): daño enorme en **área**, muy lento, de largo alcance y caro. Su función: **concentrar el daño en un solo golpe** para que la armadura importe poco (RF-80) y reventar a los grupos de enemigos duros. No le pega a los voladores.

  | Nivel | Costo | Daño | Cadencia | Alcance | Radio del área |
  |---|---|---|---|---|---|
  | 1 | 300 | 90 | 0,25 (un disparo cada 4 s) | 5,0 | 1,5 |
  | 2 | 250 | 140 | 0,25 | 5,0 | 1,8 |
  | 3 | 350 | 220 | 0,25 | 5,5 | 2,2 |

  Son **números de partida**: se afinan con el bot (T141). Comparado con el Cañón (100 de oro, 20 de daño cada 1,7 s, radio 1,0), el Mortero cuesta tres veces más **y ocupa cuatro casillas**: tiene que valer la pena por pegar fuerte y de lejos, no por ser más de lo mismo. Proyectil: una **bomba** lenta (velocidad 6 casillas por segundo, RF-55) que recorre un tramo largo sin fallar (RF-52).
- **RF-297** **La barra y las teclas:** con el Mortero hay **9 torres**: la barra inferior y las teclas pasan de 8 a **9** (tecla `9`, acción `build_9`). Los botones **entran** sin tapar "Próxima oleada" (RF-170 se actualiza). El límite de la barra sube a 9.
- **RF-298** **Aviso y Wiki:** al elegir el Mortero el HUD agrega *"Necesita 2×2 casillas libres"* (RF-171) y la Wiki lo anota en su ficha (**"Tamaño: 2×2 casillas"**, RF-231). `CONTENIDO.md` explica `footprint`. *(Lucas, 2026-09-30: el Mortero **no** está en todos los niveles, ver RF-300.)*
- **RF-300** **Torres reservadas** *(pedido por Lucas, 2026-09-30: "la torre de 4 dejarla por ahora solo para el nivel 10")*: `TowerData` gana `reserved` (`false` por defecto). Una torre reservada **no aparece en la barra** de un nivel salvo que su archivo la habilite con el campo opcional `"torres_extra": ["mortar"]`. Un id que no existe es un **error** que lista los que hay (RF-204); uno repetido cuenta una vez; el editor **conserva** el campo. La barra y las teclas de ese nivel son las comunes más las habilitadas. El Mortero es reservada y **solo el nivel 10 la habilitará**; hasta que exista, se puede probar con `tools/ejemplos/mapa_torres_apagadas.json`. Sigue apareciendo en la Wiki.
- **RF-299** **Dibujos:** una **torreta de mortero** nueva (tubo corto y ancho apuntando hacia adelante, sobre una placa) y una **bomba** como proyectil, según la guía de arte (RF-151). La base es la de siempre, agrandada; no hay dibujos de base nuevos.

> **Criterio de aceptación RF-300**
> **Dado** un nivel sin `"torres_extra"` → **Entonces** la barra tiene las **8** torres de siempre y la tecla 9 no hace nada. **Dado** uno con `"torres_extra": ["mortar"]` → **Entonces** hay **9** y la tecla 9 elige el Mortero.

> **Criterio de aceptación RF-291**
> **Dado** un Mortero y un mapa donde hay tres casillas libres juntas (la cuarta es camino) → **Cuando** intento construirlo ahí → **Entonces** no se construye, las cuatro casillas se ven rojas y sigo teniendo mi oro.
> **Dado** cuatro casillas libres juntas y 300 de oro → **Cuando** hago clic con la vista previa → **Entonces** se construye, ocupa las cuatro casillas, **un clic en cualquiera** la selecciona, y al venderla recibo el 70 % y las cuatro vuelven a estar libres.

### 5.8 Sinergias: combinar los ataques *(M20 y M21, pedido por Lucas, D-041, D-046, B-16 forma C)*

Hoy cada torre hace lo suyo sola. Las sinergias hacen que **combinar** torres rinda más que repetir la misma. **Lucas decidió (2026-09-30)** hacerlo en **dos etapas**: primero **reacciones por estado del enemigo** (A, M20) y después **pares de torres vecinas** (B1, M21), con combos **notables (+25 a 30 %)** y **8 casillas** de vecindad. Mismo principio de siempre (RF-164): todo son **datos**, apagados en 0.

#### Etapa A · Reacciones por estado *(M20, hecha)*

Un enemigo **ralentizado** o **quemado** (los estados que ya existen y ya se ven: tinte azul y llamitas, RF-62 y RF-160) recibe **más daño** de ciertas torres. No importa **dónde** estén las torres: premia tener Hielo e Incendiaria en el camino junto al resto.

- **RF-310** **Los datos** (en `TowerLevelData`, enteros, valen 0 = apagado, D-013): `bonus_vs_slowed_percent` (+% de daño a un enemigo ralentizado) y `bonus_vs_burning_percent` (+% a uno que se quema).
- **RF-311** **Cuándo cuenta:** el estado se mira **al impactar y antes de aplicar lo que trae ese mismo golpe** (un golpe de Hielo no se "ayuda" a sí mismo). Si el enemigo tiene **los dos** estados, **se suman** los dos porcentajes. El daño del golpe pasa a `daño × (100 + bonus) / 100`, **redondeado al entero más cercano**, y **recién después** resta la armadura (RF-80). Vale para todos los golpes: directos, de área, de cadena y de ráfaga. Un golpe que **rebota** en el Espejo no hace daño, así que no hay bonus (RF-284).
- **RF-312** **Quién aprovecha qué** (números de partida; el mismo en los tres niveles de la torre):

  | Torre | Contra | Bonus | Idea |
  |---|---|---|---|
  | Cañón | ralentizado | +25 % | el hielo lo deja quieto para la bomba |
  | Francotirador | ralentizado | +25 % | blanco fácil |
  | Mortero | ralentizado | +25 % | ídem (solo en los niveles que lo tienen, RF-300) |
  | Eléctrica | quemado | +30 % | el fuego lo vuelve conductor |

  Con eso, el Hielo y la Incendiaria pasan de "casi no hacen daño" a **amplificadores** del resto.
- **RF-313** **Cómo se ve:** ~~un golpe con bonus muestra **"¡Combo!"** dorado sobre el número de daño (mismas reglas que los números, RF-132: se apaga con la opción y hay un tope en pantalla).~~ *(Reemplazado por RF-315: el "¡Combo!" dorado se amontonaba con el número y con el "+N" del oro, D-047.)* El panel de la torre dice **"+25 % de daño a ralentizados"** y la Wiki lo escribe en los efectos de la torre (RF-234).
- **RF-314** **Por qué no se rompe el balance:** los bonus **no** son para las torres que ya sobresalen contra armadura (Ametralladora, Hielo) ni para las que pegan de a poquito (Múltiple, Ráfaga). Las torres con bonus son las de **golpe grande y lento**, que son las que más necesitan que el enemigo se quede quieto o se prenda fuego.

> **Criterio de aceptación**
> **Dado** un Cañón de nivel 1 (20 de daño) y un enemigo sin armadura → **Cuando** le pega a uno **ralentizado** → **Entonces** hace **25**; a uno que **no** lo está, **20**.
> **Dado** una Eléctrica de nivel 1 (13 de daño) y un enemigo quemado → **Entonces** hace **17** (13 × 1,3 = 16,9). **Dado** un golpe de Hielo → **Entonces** no tiene bonus por el estado que él mismo pone.

#### Etapa A, segunda parte · Que el combo se lea y se descubra *(M20, pedido por Lucas, D-047)*

Una investigación con capturas y con el bot (D-047) mostró que el combo quedaba **flojo**, sobre todo porque **no se leía**: el "¡Combo!" se amontonaba con el número de daño y con el "+N" del oro (del **mismo dorado**), se apagaba con los números y nada avisaba **antes** que el Hielo y el Cañón se combinan. Esta parte arregla cómo se **ve**, cómo **suena** y cómo se **descubre**, **sin tocar el balance** (los porcentajes de RF-312 no cambian).

- **RF-315** **El número es el aviso:** un golpe con bonus **no** muestra un número blanco y un "¡Combo!" aparte. Muestra **su** número de daño (el real, después de la armadura) **más grande** (20 en vez de 15) y con un **"!"** ("25!"), del **color del estado** que lo provocó: **celeste** si fue por ralentizado y **naranja** si fue por quemado. Si el golpe aprovechó **los dos** estados (una torre con los dos bonus), manda el que dio **más** bonus; si empatan, el celeste. **Nunca dorado:** el dorado es el color del oro (RF-124).
  - Debajo, un **anillo** del mismo color alrededor del enemigo (no dorado, para no confundirse con la onda del Cañón, RF-122).
  - **La primera vez en la partida** que salta un combo de cada estado, además aparece un texto más grande: **"¡Combo de hielo!"** o **"¡Combo de fuego!"** (como el "¡Rebote!" del Espejo, RF-284). Las siguientes veces, no. Reintentar el nivel empieza otra partida.
  - **Sin amontonar:** si en los últimos **0,15 s** ya salió un número de combo a menos de **40 px**, este golpe muestra **solo su anillo** (pasa en los golpes de área sobre un grupo).
  - **Con los números de daño apagados** (RF-132) no hay número, pero **el anillo, el texto de la primera vez y el sonido siguen**: el combo no puede desaparecer entero.
  - Los números de combo tienen **su propio tope** en pantalla (12) y **no** compiten con los 40 números blancos.
- **RF-316** **Suena:** cada combo hace un **"tin"** corto y brillante (`combo.wav`, sintetizado como los demás sonidos), **como mucho uno cada 0,15 s** para que una tanda de combos no suene a ametralladora. Respeta el volumen de efectos (RF-113).
- **RF-317** **Se dice desde los dos lados:** hoy lo dice solo la torre que aprovecha ("+25 % de daño a ralentizados"). Ahora también **la torre que pone el estado**: el panel y la Wiki del **Hielo** dicen *"Combo: Cañón, Francotirador y Mortero +25 % a los que frena"* y los de la **Incendiaria**, *"Combo: Eléctrica +30 % a los que quema"*. El texto **se arma leyendo los datos** (las torres con `bonus_vs_slowed_percent` o `bonus_vs_burning_percent` mayor que 0, con el porcentaje de su nivel 1): si mañana otra torre gana un bonus, aparece sola (RF-164). En la **partida**, el panel nombra solo las torres que **ese nivel** tiene (RF-300); la **Wiki** nombra todas. Además, el texto de la **barra de construcción** (RF-171) suma una frase corta: *"Combo: +25 % a ralentizados."* en las que aprovechan y la línea de arriba en las que ponen el estado. El artículo "Efectos de las torres" de la Wiki explica los combos, sin repetir números.
- **RF-318** **Marca de "vulnerable":** un enemigo **ralentizado** muestra una **dianita celeste** al lado de la barra de vida (en la misma fila que los íconos de aura, RF-274) **si en el mapa hay alguna torre que aprovecha ese estado**; uno **quemado**, una **naranja** si hay alguna que aprovecha la quemadura. Así se ve **antes** del golpe que ese enemigo "está listo". Si se vende la última torre que lo aprovecha, la marca desaparece; un enemigo que no está ralentizado ni quemado no tiene marca.
- **Lo que queda para después (D-047):** si después de probar esto el combo **todavía no pesa**, la regla elegida es **una nueva**: el combo **frena en seco** al enemigo un instante (el "quiebre"), y **no** subir los porcentajes (el bot mostró que duplicarlos casi no cambia las partidas). Se especifica al tomarla. La vista previa de construcción **no** marca con quién combina una torre en esta etapa: en la A la ubicación no importa, y marcarlo confundiría con la B1 (vecinas), que sí lo hará.

> **Criterio de aceptación RF-315 y RF-316**
> **Dado** un Cañón de nivel 1 y un enemigo sin armadura **ralentizado** → **Cuando** le pega → **Entonces** aparece **"25!"** celeste, más grande que los números comunes, **sin** un "25" blanco aparte, con un anillo celeste, suena el "tin" y, por ser el primero de la partida, aparece **"¡Combo de hielo!"**. **Cuando** le pega de nuevo → **Entonces** sale el número y el anillo, pero ya no "¡Combo de hielo!".
> **Dado** una Eléctrica y un enemigo quemado → **Entonces** el número es **naranja** ("17!") y el texto de la primera vez es "¡Combo de fuego!".
> **Dado** los números de daño apagados → **Cuando** salta un combo → **Entonces** no hay número, pero sí el anillo, el sonido y (la primera vez) el texto.
> **Dado** un golpe de área que hace combo sobre dos enemigos pegados → **Entonces** sale **un** número de combo y **dos** anillos.

> **Criterio de aceptación RF-317 y RF-318**
> **Dado** el nivel 1 (sin Mortero) → **Cuando** selecciono un Hielo construido → **Entonces** el panel dice "Combo: Cañón y Francotirador +25 % a los que frena"; en la **Wiki**, la ficha del Hielo nombra también al Mortero. La Incendiaria dice "Combo: Eléctrica +30 % a los que quema"; la Ametralladora no dice nada de combos. **Cuando** elijo el Cañón en la barra → **Entonces** el texto termina con "Combo: +25 % a ralentizados."
> **Dado** un enemigo ralentizado y ninguna torre con bonus contra ralentizados en el mapa → **Entonces** no tiene marca. **Cuando** construyo un Cañón → **Entonces** tiene la dianita celeste. **Cuando** lo vendo → **Entonces** la marca desaparece.

#### Etapa B1 · Pares de torres vecinas *(M21, se especifica al tomarla)*

**Actualización de backlog (Lucas, 2026-10-03):** análisis de activación desde mejoras2/3 entregado en B-23/M36; recetas y resultados en `art/redesign-m36/B23-vecindad.md`. Selección e integración de recetas pendientes. La etapa A existente no cambia.

Lo ya decidido: son **vecinas** las torres que se tocan en las **8 casillas** de alrededor (una torre de 2×2 toca por todo su borde); los pares son **pocos y elegidos a mano** (propuesta: **Incendiaria + Eléctrica** → el rayo además quema; **Hielo + Múltiple** → los dardos ralentizan un poco; **Hielo + Cañón** → el área también ralentiza); se **ven** con una línea fina entre las vecinas, el panel dice la sinergia activa y la vista previa resalta con quién combina. Se escribe como §5.9 con sus RF cuando se tome.


- **RF-80** Cuando un enemigo recibe daño, el daño real es:
  `daño real = máximo(1, daño del golpe − armadura del enemigo)`
  Es decir, la armadura resta, pero **siempre** se hace al menos 1 de daño.
- **RF-81** Cuando la vida llega a 0, el enemigo muere, desaparece y da su oro.
- **RF-82** Cada enemigo muestra una **barra de vida** encima, pero **solo** después de haber recibido daño (para no llenar la pantalla de barras).

> **Criterio de aceptación RF-80**
> **Dado** un Blindado (armadura 3) → **Cuando** le pega una Ametralladora (daño 5) → **Entonces** pierde 2 de vida. **Cuando** le pega un Francotirador (40) → **Entonces** pierde 37.

### Tabla de enemigos

> *Velocidad en casillas por segundo. "Vida" es la vida base (en la oleada 1); después aumenta según RF-36.*

| ID | Nombre | Vida | Velocidad | Armadura | Oro | Vidas que quita | Vuela | Especial | Forma provisional | Hito |
|---|---|---|---|---|---|---|---|---|---|---|
| `normal` | **Normal** | 30 | 1.5 | 0 | 5 | 1 | No | — | Círculo gris | M1 |
| `fast` | **Rápido** | 18 | 3.0 | 0 | 4 | 1 | No | — | Triángulo amarillo | M1 |
| `tank` | **Tanque** | 135 | 0.8 | 0 | 15 | 2 | No | — | Cuadrado marrón, grande | M1 |
| `flyer` | **Volador** | 18 | 2.0 | 0 | 8 | 1 | **Sí** | Vuela en línea recta (RF-05) | Rombo violeta (no celeste: se confundiría con el Hielo y con los ralentizados) | M2 |
| `armored` | **Blindado** | 30 | 1.2 | 3 | 12 | 1 | No | Armadura alta | Hexágono azul oscuro | M2 |
| `boss` | **Jefe** | 300 | 0.6 | 3 | 150 | 10 | No | Solo le afecta la **mitad** de cualquier ralentización | Círculo rojo, muy grande | M2 |

**Tamaño visual** (radio del dibujo y de la zona que detectan las torres, en casillas): Normal 0.25 · Rápido 0.2 · Tanque 0.35 · Volador 0.25 · Blindado 0.3 · Jefe 0.45. Todos caben dentro de una casilla del camino (radio máximo 0.5).

### 6.1 Enemigos nuevos *(M5, pedidos por Lucas)*

- **RF-165** **Regeneración:** el enemigo recupera `X` % de su vida máxima por segundo, sin pasarse de su máximo. **Mientras se quema no se regenera** (RF-160). Cuando se cura se ve un "+N" verde (si los números de daño están encendidos, RF-132).
- **RF-166** **Crías:** si el enemigo tiene crías, **al morir por daño** aparecen `N` crías en su lugar, un poco escalonadas hacia atrás en el camino. Si llega a la salida, no suelta nada. Las crías tienen la vida de la oleada en curso (RF-36), dan su propio oro, cuentan para terminar la oleada (RF-33) y se presentan como cualquier enemigo nuevo (RF-134).
- **RF-167** Los enemigos nuevos siguen el estilo del Tanque (§9.6, RF-151): bestias de costado, nada infantiles.

| ID | Nombre | Vida | Velocidad | Armadura | Oro | Vidas que quita | Vuela | Especial | Tamaño |
|---|---|---|---|---|---|---|---|---|---|
| `troll` | **Troll** | 70 | 1.0 | 0 | 10 | 2 | No | Se regenera 4 % por segundo | 0.32 |
| `spider` | **Araña** | 60 | 1.2 | 0 | 6 | 2 | No | Al morir suelta 4 Crías | 0.33 |
| `spiderling` | **Cría** | 8 | 2.4 | 0 | 1 | 1 | No | — | 0.16 |

| Enemigo | Frase de presentación (RF-134) |
|---|---|
| Troll | Se cura solo con el tiempo. El fuego de la Incendiaria le corta la curación. |
| Araña | Al morir suelta 4 crías. La Múltiple, la Ráfaga y el Cañón las barren. |
| Cría | Frágil y rápida, pero salen de a muchas. |

**Colores:** Troll verde musgo, Araña verde azulado oscuro, Cría verde azulado claro (ninguno se confunde con los enemigos anteriores).

### 6.2 Enemigos con aura *(M17, pedido por Lucas, D-041, D-042, B-07)*

Dos enemigos que **no atacan**: hacen más fuertes a los que caminan cerca de ellos. Obligan a cambiar de táctica (matarlos primero, o pegarles de lejos) y son la primera vez que un enemigo **cambia a otro**. Como todo lo de RF-164, son **datos** del enemigo (valen 0 = apagado) y se pueden combinar.

- **RF-270** **Los datos del aura** (en `EnemyData`): `aura_radius_tiles` (hasta dónde llega, en casillas; 0 = sin aura), `aura_armor_bonus` (armadura extra que da) y `aura_heal_percent_per_second` (% de su vida máxima por segundo que hace recuperar). Un mismo enemigo puede dar las dos cosas.
- **RF-271** **Aura de armadura:** cada enemigo **que no sea el portador** y esté a menos de `aura_radius_tiles` de él (distancia entre centros, ground o aire) tiene **+`aura_armor_bonus` de armadura**. Vale para todo daño **de una torre** (RF-80: `daño − armadura`, mínimo 1). **No** afecta a la quemadura, que ignora la armadura (RF-160). Si le llegan varias auras de armadura, **vale la más fuerte** (no se suman, como la ralentización, RF-61).
- **RF-272** **Aura de cura:** el enemigo dentro del aura recupera `aura_heal_percent_per_second` % de su vida máxima por segundo, **además** de su propia regeneración (RF-165), sin pasarse de su máximo y **no mientras se quema** (RF-165). Varias auras de cura: **vale la más fuerte**.
- **RF-273** **Cuándo se aplica:** el portador "emite" cada **0,25 s** y cada emisión dura **0,35 s**. Por eso, si el portador **muere**, sale del alcance o llega a la salida, **el efecto desaparece en menos de medio segundo**. El portador **no se da el aura a sí mismo**. La pausa y la velocidad x2 lo afectan igual que al resto del mundo.
- **RF-274** **Cómo se ve:** alrededor del portador, un **anillo suave en el suelo** que llega justo hasta donde llega el aura (marfil dorado para armadura, verde amarillento para cura). Sobre cada enemigo afectado, un **ícono chico** (un escudo o una cruz) al lado de su barra de vida. Se leen aunque haya muchos enemigos y no tapan el dibujo.
- **RF-275** **Los dos enemigos:**

  | ID | Nombre | Vida | Velocidad | Armadura | Oro | Vidas que quita | Vuela | Aura | Tamaño |
  |---|---|---|---|---|---|---|---|---|---|
  | `guardian` | **Guardián** | 200 | 0.7 | 1 | 25 | 3 | No | Radio 2 casillas: **+2 de armadura** | 0.38 |
  | `healer` | **Curandero** | 60 | 1.1 | 0 | 10 | 1 | No | Radio 2,5 casillas: **cura 3 %** de la vida por segundo | 0.28 |

  Son **números de partida**: se ajustan con el bot cuando debuten en un nivel (D-041: el Guardián en el nivel 8, el Curandero en el 9).

  | Enemigo | Frase de presentación (RF-134) |
  |---|---|
  | Guardián | Da armadura a los enemigos que lo rodean. Conviene eliminarlo primero, o pegarle de lejos. |
  | Curandero | Cura a los enemigos que lo rodean. Conviene eliminarlo primero; el fuego frena la cura. |

- **RF-276** **Dibujos:** el **Guardián** es un gólem de piedra **marfil** con un escudo grande; el **Curandero** es una criatura chica y ágil con un bulbo que brilla, **verde amarillento**. Siguen la guía de arte (`specs/05-guia-de-arte.md`) y usan dos de los **tonos libres** (marfil y amarillo verdoso), así que no se confunden con ningún enemigo anterior.
- **RF-277** **En el resto del juego:** aparecen **solos** en la Wiki (con su aura escrita en los datos, RF-233), en el bestiario (RF-238) y en el panel de pruebas (RF-184). Mientras no debuten en un nivel, la Wiki dice que no aparecen en la campaña.

> **Criterio de aceptación**
> **Dado** un Guardián (aura +2) y un Normal a 1,5 casillas de él, con una torre que pega de a 5 → **Cuando** la torre le pega al Normal → **Entonces** el daño real es 3 (5 − 0 − 2) y se ve el escudo sobre el Normal; **si** el Guardián muere, **en menos de medio segundo** el Normal vuelve a recibir 5.
> **Dado** un Curandero (aura 3 %) y un Tanque herido dentro de su radio → **Entonces** el Tanque recupera vida cada segundo y se ve la cruz verde; **si** se quema, deja de curarse.

### 6.3 Torres aturdidas: el Chamán y el Espejo *(M18, pedido por Lucas, D-041, D-043, B-06, B-07)*

Hasta ahora los enemigos no le hacían nada a las torres. Estos dos sí: las **apagan** unos segundos. Es la primera regla que cambia **lo que hacen las torres**, y hace que **dónde** se las pone importe más.

- **RF-280** **Torre aturdida:** una torre aturdida **no dispara** hasta que se le pasa el tiempo. Sigue en su lugar y se puede **mejorar, vender y cambiar de apuntado** igual. Si le llega otro aturdimiento, **no se suma**: queda el que más dura. El tiempo corre con el del mundo (la pausa y el x2 lo afectan como al resto). Se ve **apagada** (sin brillo de mejora, con aro roto y descargas localizadas sobre el mecanismo (RF-351)) y su panel dice **"Aturdida (N s)"**.
- **RF-281** **Los datos del Chamán** (en `EnemyData`, valen 0 = apagado, RF-164): `stun_interval` (cada cuántos segundos lanza su hechizo), `stun_seconds` (cuánto aturde) y `stun_range_tiles` (a qué distancia llega).
- **RF-282** **El Chamán:** cada `stun_interval` segundos (el primero, un intervalo después de aparecer) **aturde la torre más cercana** que esté a menos de `stun_range_tiles` de él y no esté ya aturdida. Si no hay ninguna, **espera** hasta que aparezca una (no acumula hechizos). Se ve un **rayo magenta** en zigzag del Chamán a la torre. Alcance del hechizo **menor** que el del Francotirador: se lo puede matar antes de que llegue a lanzarlo.
- **RF-283** **Los datos del Espejo:** `reflect_range_tiles` (a qué distancia rebota) y `reflect_stun_seconds` (cuánto aturde a la torre que disparó).
- **RF-284** **El Espejo:** cuando un golpe de una torre lo alcanza y esa torre está a **menos de `reflect_range_tiles`** de él (medido al impactar), el golpe **rebota**: el Espejo **no recibe daño ni ralentización** de ese golpe y la torre queda aturdida `reflect_stun_seconds`. Vale para todos los golpes (área, cadena, ráfaga); si una descarga trae varios proyectiles, **todos rebotan** (ninguno se cuela mientras la torre ya está apagada), pero el aturdimiento **no se alarga** (queda el que más dura, RF-280). Las torres **más lejos** le pegan normal. **La quemadura no rebota**: se aplica igual (RF-160). Se ve un **destello** y el texto **"¡Rebote!"**.
- **RF-285** **Los dos enemigos:**

  | ID | Nombre | Vida | Velocidad | Armadura | Oro | Vidas que quita | Vuela | Habilidad | Tamaño |
  |---|---|---|---|---|---|---|---|---|---|
  | `shaman` | **Chamán** | 90 | 0.9 | 0 | 20 | 2 | No | Cada 8 s aturde 3 s a la torre más cercana (hasta 4 casillas) | 0.32 |
  | `mirror` | **Espejo** | 180 | 0.7 | 0 | 25 | 2 | No | Rebota los golpes de torres a menos de 2,5 casillas y las aturde 2 s | 0.36 |

  Son **números de partida**: se ajustan con el bot cuando debuten (D-041: los dos en el nivel 10).

  | Enemigo | Frase de presentación (RF-134) |
  |---|---|
  | Chamán | Cada tanto apaga la torre más cercana. Un Francotirador lo alcanza antes de que lance su hechizo. |
  | Espejo | Devuelve los tiros de las torres cercanas y las aturde. El fuego y las torres de largo alcance lo golpean sin problema. |

- **RF-286** **Dibujos:** el **Chamán** es un encapuchado **magenta** con un bastón que chispea; el **Espejo**, una tortuga de cristal **cian frío** con placas que reflejan. Siguen la guía de arte y usan los dos **tonos libres** que quedaban (rosa magenta y cian frío).
- **RF-287** **En el resto del juego:** aparecen solos en la Wiki (con su habilidad escrita, RF-233), en el bestiario y en el panel de pruebas. Mientras no debuten en un nivel, la Wiki dice que no aparecen en la campaña.

> **Criterio de aceptación**
> **Dado** un Chamán con una Ametralladora a 3 casillas → **Cuando** pasan 8 segundos → **Entonces** la torre deja de disparar 3 segundos, se ve el rayo magenta y su panel dice "Aturdida"; después vuelve a disparar sola.
> **Dado** un Espejo y dos torres con el mismo daño, una a 2 casillas y otra a 4 → **Cuando** las dos le disparan → **Entonces** el golpe de la cercana **rebota** (0 de daño, la torre queda aturdida 2 s) y el de la lejana le pega normal.

---

## 7. Niveles

| # | Nombre provisional | Oleadas | Oro inicial | Particularidad | Hito |
|---|---|---|---|---|---|
| 1 | Pradera | 10 | 150 | Un camino en forma de "S". Para aprender. | M1 |
| 2 | Desfiladero | 15 | 200 | Zigzag con 8 curvas cerradas (§7.2). | M3 |
| 3 | Encrucijada | 20 | 250 | **Dos entradas** cuyos caminos se unen antes de la salida (§7.3). | M3 |
| 4 | Espiral | 15 | 200 | El camino da vueltas hacia adentro; **la salida está en el centro** (§7.5). | M4 |
| 5 | Fortaleza | 20 | 300 | **Tres entradas**, una desde arriba (§7.6). | M4 |
| 6 | Nido | 15 | 250 | **Dos entradas** (una desde arriba) y los enemigos nuevos: Troll, Araña y Crías (§7.7). | M5 |
| 7 | Cruce | 20 | 300 | **Dos entradas** en lados opuestos y **la salida en el centro** (§7.9). Cierra el tramo introductorio6/7. Primero hecho en archivo de texto (§7.8). | M8 |
| 8 | Bastión | 18 | 300 | Una entrada, debut Guardián, robo y embestidas separados antes de combinarse; Mecánico disponible con colección. | M45 |
| 9 | Taller asediado | 20 | 320 | Dos entradas, debut Curandero junto al Guardián, presión combinada y posiciones expuestas reparables. | M45 |

### Oleadas del nivel 1

> Formato: `cantidad × tipo (cada X s)`. Los grupos de una misma oleada separados por "+" empiezan a la vez, salvo que se indique "tras N s".

| Oleada | Enemigos |
|---|---|
| 1 | 8 × Normal (cada 1.0 s) |
| 2 | 12 × Normal (cada 0.8 s) |
| 3 | 10 × Rápido (cada 0.6 s) |
| 4 | 10 × Normal (cada 0.8 s) + 4 × **Blindado** (cada 1.5 s, tras 4 s) ← *aparecen los Blindados* |
| 5 | 3 × Tanque (cada 2.0 s) + 8 × **Volador** (cada 0.8 s, tras 3 s) ← *aparecen los Voladores* |
| 6 | 15 × Rápido (cada 0.4 s) + 6 × Blindado (cada 1.0 s, tras 5 s) |
| 7 | 6 × Tanque (cada 1.5 s) + 10 × Volador (cada 0.6 s, tras 4 s) |
| 8 | 20 × Normal (cada 0.5 s) + 8 × Blindado (cada 1.0 s, tras 5 s) + 10 × Rápido (cada 0.5 s, tras 8 s) |
| 9 | 8 × Tanque (cada 1.5 s) + 12 × Volador (cada 0.5 s, tras 3 s) + 15 × Rápido (cada 0.4 s, tras 8 s) |
| 10 | 1 × **Jefe** + 10 × Tanque (cada 1.2 s, tras 3 s) + 20 × Normal (cada 0.4 s, tras 6 s) + 15 × Volador (cada 0.4 s, tras 10 s) ← *el Jefe* |

### 7.1 Cómo se balanceó el nivel 1 (T25, revisado en T38)

El objetivo: **se gana jugando con criterio, pero no sin pensar**. Se comprobó con un bot que juega solo (`tools/balance_sim.gd`, instrucciones dentro del archivo) con tres estrategias:

| Estrategia del bot | Resultado con los números actuales |
|---|---|
| Mezcla torres (incluido el Francotirador) y las pone donde cubren más camino, también el aéreo | Gana con 13 vidas |
| Solo Ametralladoras, bien puestas | Gana con 10 vidas |
| Solo Ametralladoras, en casillas al azar | Pierde en la oleada 7 |

Qué se cambió respecto al borrador y por qué:
- **Con los números originales se ganaba sin perder ni una vida, incluso poniendo torres al azar.** Se subió la vida base ×1,5 (Normal 20 → 30, Rápido 12 → 18, Tanque 90 → 135) y, sobre todo, el aumento por oleada (8 % → **40 %**), para que el final presione aunque el jugador haya acumulado oro.
- **El Cañón rendía casi un tercio que la Ametralladora por cada moneda**, así que no convenía nunca. Su daño subió de 12 a **20** (y sus mejoras en proporción).

- **T38 (M2):** los enemigos nuevos tenían valores del borrador, pensados antes del +40 % por oleada, y con ellos se perdía siempre (un Blindado de la oleada 4 tenía 99 de vida y la Ametralladora le hacía 1 de daño). Se bajaron a: **Volador 18** de vida, **Blindado 30 y armadura 3** (la Ametralladora le hace 2, no 1: sigue siendo mala opción, pero no inútil), **Jefe 300** (≈ 1380 en la oleada 10). Con estos números, mezclar torres rinde más que usar solo Ametralladoras: los enemigos nuevos cumplen su función de premiar la variedad.

Un bot no reemplaza a una persona: estos números se revisan jugando. Cada vez que se cambie el balance, se vuelve a correr el bot y se actualiza esta tabla.

### 7.2 Nivel 2 — Desfiladero *(M3)*

Un zigzag con **8 curvas cerradas**. Las franjas de pasto encerradas entre dos tramos de camino son los mejores lugares: una torre ahí alcanza los dos lados.

```
col: 01234567890123456789
f0   ····················
f1   ■■■■···■■■■■···■■■■■  → salida
f2   ···■···■···■···■····
f3   ···■···■···■···■····
f4   ·X·■···■···■···■·X··      ■ camino · X roca
f5   ···■···■···■···■····
f6   ···■···■···■···■····
f7   ···■■■■■···■■■■■··X·
f8   ····················
```

Los Voladores cruzan en línea recta por la fila 1.

| Oleada | Enemigos |
|---|---|
| 1 | 10 × Normal (cada 0.8 s) |
| 2 | 12 × Rápido (cada 0.5 s) |
| 3 | 8 × Normal (cada 0.8 s) + 5 × Blindado (cada 1.2 s, tras 3 s) |
| 4 | 4 × Tanque (cada 1.8 s) + 8 × Volador (cada 0.7 s, tras 2 s) |
| 5 | 15 × Rápido (cada 0.4 s) + 6 × Blindado (cada 1.0 s, tras 4 s) |
| 6 | 20 × Normal (cada 0.5 s) |
| 7 | 8 × Volador (cada 0.5 s) + 6 × Tanque (cada 1.5 s, tras 3 s) |
| 8 | 10 × Blindado (cada 0.9 s) + 12 × Rápido (cada 0.4 s, tras 4 s) |
| 9 | 1 × **Jefe** + 12 × Normal (cada 0.6 s, tras 2 s) |
| 10 | 8 × Tanque (cada 1.2 s) + 14 × Volador (cada 0.5 s, tras 3 s) |
| 11 | 25 × Rápido (cada 0.3 s) + 8 × Blindado (cada 1.0 s, tras 5 s) |
| 12 | 12 × Tanque (cada 1.0 s) + 20 × Normal (cada 0.4 s, tras 4 s) |
| 13 | 16 × Volador (cada 0.4 s) + 12 × Blindado (cada 0.8 s, tras 3 s) |
| 14 | 2 × **Jefe** (cada 4.0 s) + 20 × Rápido (cada 0.3 s, tras 4 s) |
| 15 | 2 × **Jefe** (cada 3.0 s) + 12 × Tanque (cada 1.0 s, tras 2 s) + 16 × Volador (cada 0.4 s, tras 6 s) + 12 × Blindado (cada 0.8 s, tras 10 s) |

### 7.3 Nivel 3 — Encrucijada *(M3)*

**Dos entradas** (A arriba, B abajo) que se juntan en la columna 8 y siguen juntas hasta la salida. El jugador tiene que decidir: ¿defender cada entrada por separado, o concentrar todo después del cruce?

```
col: 01234567890123456789
f0   ····················
f1   ■■■■■■■■■····■■■■■··  ← entrada A
f2   ········■·X··■···■··
f3   ········■····■···■··
f4   ····X···■■■■■■···■··      (se juntan en la columna 8)
f5   ········■·········■··
f6   ········■··X···X·■··
f7   ■■■■■■■■■········■■■  ← entrada B · → salida
f8   ····················
```

En la tabla, **(A)** y **(B)** indican por qué entrada sale cada grupo.

| Oleada | Enemigos |
|---|---|
| 1 | 8 × Normal (A, cada 1.0 s) |
| 2 | 8 × Normal (B, cada 1.0 s) |
| 3 | 8 × Normal (A, cada 0.9 s) + 8 × Normal (B, cada 0.9 s) |
| 4 | 10 × Rápido (A, cada 0.6 s) + 10 × Rápido (B, cada 0.6 s, tras 2 s) |
| 5 | 5 × Blindado (A, cada 1.2 s) + 8 × Volador (B, cada 0.8 s, tras 2 s) |
| 6 | 4 × Tanque (B, cada 1.8 s) + 12 × Normal (A, cada 0.6 s, tras 2 s) |
| 7 | 12 × Volador (A, cada 0.6 s) + 12 × Rápido (B, cada 0.4 s, tras 3 s) |
| 8 | 8 × Blindado (B, cada 1.0 s) + 8 × Blindado (A, cada 1.0 s, tras 4 s) |
| 9 | 6 × Tanque (A, cada 1.5 s) + 6 × Tanque (B, cada 1.5 s, tras 3 s) |
| 10 | 1 × **Jefe** (A) + 15 × Normal (B, cada 0.5 s, tras 2 s) |
| 11 | 20 × Rápido (A, cada 0.3 s) + 10 × Volador (B, cada 0.5 s, tras 3 s) |
| 12 | 10 × Blindado (A, cada 0.9 s) + 10 × Tanque (B, cada 1.2 s, tras 2 s) |
| 13 | 16 × Volador (A, cada 0.4 s) + 16 × Volador (B, cada 0.4 s, tras 6 s) |
| 14 | 25 × Normal (A, cada 0.3 s) + 25 × Rápido (B, cada 0.3 s, tras 3 s) |
| 15 | 1 × **Jefe** (B) + 10 × Blindado (A, cada 0.8 s, tras 3 s) + 10 × Tanque (B, cada 1.0 s, tras 6 s) |
| 16 | 12 × Tanque (A, cada 1.0 s) + 20 × Volador (B, cada 0.4 s, tras 4 s) |
| 17 | 15 × Blindado (A, cada 0.7 s) + 15 × Blindado (B, cada 0.7 s, tras 5 s) |
| 18 | 2 × **Jefe** (A, cada 3.0 s) + 25 × Rápido (B, cada 0.25 s, tras 3 s) |
| 19 | 15 × Tanque (A, cada 0.8 s) + 15 × Tanque (B, cada 0.8 s, tras 4 s) + 20 × Volador (A, cada 0.4 s, tras 8 s) |
| 20 | 2 × **Jefe** (A, cada 2.0 s) + 2 × **Jefe** (B, cada 2.0 s, tras 4 s) + 20 × Blindado (A, cada 0.6 s, tras 8 s) + 20 × Volador (B, cada 0.35 s, tras 10 s) |

### 7.4 Aumento de vida por nivel *(M3, D-019)*

Con +40 % por oleada, un nivel de 15 o 20 oleadas terminaría con enemigos 7 a 9 veces más fuertes que al principio. Por eso **cada nivel puede tener su propio aumento** (`LevelData.health_scale_percent_per_wave`); si no define uno, usa el general de `BalanceConfig` (40 %).

| Nivel | Aumento por oleada | Bot que mezcla torres | Solo Ametralladoras | Torres al azar |
|---|---|---|---|---|
| 1 · Pradera | 40 % *(el general)* | Gana con 13 vidas | Gana con 10 vidas | Pierde en la oleada 7 |
| 2 · Desfiladero | **35 %** | Gana con 17 vidas | Pierde en la última oleada | Pierde en la oleada 7 |
| 3 · Encrucijada | **20 %** | Gana con 9 vidas | Pierde en la última oleada | Pierde en la oleada 9 |
| 4 · Espiral | **20 %** | Pierde en la última oleada | **Gana con 14 vidas** | Pierde en la oleada 10 |
| 5 · Fortaleza | **10 %** | Pierde en la última oleada | **Gana con 10 vidas** | Pierde en la oleada 5 |
| 6 · Nido *(M5)* | **30 %** | Gana con 6 vidas | — | Pierde en la oleada 5 |
| 7 · Cruce *(M8)* | **24 %** | Pierde en la oleada 18 | — | Pierde en la oleada 4 |

**Con las 8 torres (M5, bot "mix"):** nivel 1 gana con 19 vidas · 2 pierde en la última oleada · 3 gana con 16 · 4 gana con 9 · 5 gana con 16 · **6 gana con 10** · **7 gana con 7**. Queda parejo con los bots de siempre (a veces mejor, a veces peor): las torres nuevas suman opciones sin regalar los niveles. El nivel 6 es el más exigente: con 35 % ningún bot pasaba la oleada 7 (10 Trolls y 6 Arañas).

La curva de dificultad buscada: en el nivel 1 alcanza con una sola torre bien usada; **desde el nivel 2 hay que mezclar torres** para ganar; el nivel 3 es el más exigente. (Con 40 %, el nivel 3 se perdía siempre en la oleada 6.)

**Niveles 4 y 5:** con oleadas densas y muchos Voladores, el bot "que mezcla" rinde peor que el de "solo Ametralladoras", porque su orden de compra fijo gasta en Cañones que no les pegan a los Voladores. Una persona se adapta, así que para estos niveles se tomó **el mejor de los dos bots** como referencia de "alguien que piensa". Con +35 % (Espiral) y +20 % (Fortaleza) ningún bot ganaba.

### 7.5 Nivel 4 — Espiral *(M4)*

El camino da **vueltas hacia adentro** y termina en el **centro del mapa**, donde se dibuja la puerta de salida (RF-06). Es el camino más largo del juego (unas 75 casillas): los enemigos tardan mucho en llegar, así que las oleadas son **más densas**. Una torre en el medio alcanza varios tramos a la vez.

```
col: 01234567890123456789
f0   ····················
f1   ■■■■■■■■■■■■■■■■■■■·  ← entrada
f2   ··················■·
f3   ··■■■■■■■■■■■■■■■·■·
f4   ··■·············■·■·
f5   ··■··◆■■■■■■■■■■■·■·      ◆ salida (puerta)
f6   ··■···············■·
f7   ··■■■■■■■■■■■■■■■■■·
f8   ····················
```

Los Voladores van en línea recta desde la entrada hasta la puerta del centro.

| Oleada | Enemigos |
|---|---|
| 1 | 12 × Normal (cada 0.7 s) |
| 2 | 15 × Rápido (cada 0.4 s) |
| 3 | 10 × Normal (cada 0.6 s) + 6 × Blindado (cada 1.0 s, tras 3 s) |
| 4 | 5 × Tanque (cada 1.5 s) + 10 × Volador (cada 0.6 s, tras 2 s) |
| 5 | 20 × Rápido (cada 0.3 s) + 8 × Blindado (cada 0.8 s, tras 4 s) |
| 6 | 25 × Normal (cada 0.4 s) |
| 7 | 12 × Volador (cada 0.4 s) + 8 × Tanque (cada 1.2 s, tras 3 s) |
| 8 | 12 × Blindado (cada 0.7 s) + 15 × Rápido (cada 0.3 s, tras 4 s) |
| 9 | 1 × **Jefe** + 20 × Normal (cada 0.4 s, tras 2 s) |
| 10 | 10 × Tanque (cada 1.0 s) + 16 × Volador (cada 0.4 s, tras 3 s) |
| 11 | 30 × Rápido (cada 0.25 s) + 10 × Blindado (cada 0.8 s, tras 5 s) |
| 12 | 15 × Tanque (cada 0.8 s) + 25 × Normal (cada 0.35 s, tras 4 s) |
| 13 | 20 × Volador (cada 0.35 s) + 15 × Blindado (cada 0.6 s, tras 3 s) |
| 14 | 2 × **Jefe** (cada 3.0 s) + 25 × Rápido (cada 0.25 s, tras 4 s) |
| 15 | 3 × **Jefe** (cada 3.0 s) + 15 × Tanque (cada 0.8 s, tras 3 s) + 20 × Volador (cada 0.35 s, tras 6 s) + 15 × Blindado (cada 0.6 s, tras 10 s) |

### 7.6 Nivel 5 — Fortaleza *(M4)*

El nivel final. **Tres entradas**: A (izquierda arriba), B (izquierda abajo) y **C, desde el borde de arriba**. A y B se juntan en la columna 6; en la columna 13 se les suma C, y los tres siguen juntos hasta la salida, abajo a la derecha. El jugador tiene que repartir su defensa o apostar todo al tramo final compartido.

```
col: 01234567890123456789
f0   ·············■······  ← entrada C (desde arriba)
f1   ■■■■■■■······■······  ← entrada A
f2   ······■······■······
f3   ······■······■······
f4   ······■■■■■■■■······      (A y B se juntan en la col. 6; C, en la 13)
f5   ······■······■······
f6   ······■······■······
f7   ■■■■■■■······■■■■■■■  ← entrada B · → salida
f8   ····················
```

| Oleada | Enemigos |
|---|---|
| 1 | 8 × Normal (A, cada 1.0 s) |
| 2 | 8 × Normal (B, cada 1.0 s) |
| 3 | 8 × Normal (C, cada 1.0 s) |
| 4 | 8 × Rápido (A, cada 0.6 s) + 8 × Rápido (B, cada 0.6 s, tras 1 s) + 8 × Rápido (C, cada 0.6 s, tras 2 s) |
| 5 | 6 × Blindado (C, cada 1.0 s) + 10 × Normal (A, cada 0.6 s, tras 2 s) |
| 6 | 10 × Volador (B, cada 0.6 s) + 4 × Tanque (A, cada 1.5 s, tras 2 s) |
| 7 | 12 × Rápido (C, cada 0.4 s) + 12 × Rápido (A, cada 0.4 s, tras 2 s) + 12 × Rápido (B, cada 0.4 s, tras 4 s) |
| 8 | 8 × Blindado (A, cada 0.9 s) + 8 × Blindado (B, cada 0.9 s, tras 3 s) |
| 9 | 6 × Tanque (C, cada 1.4 s) + 12 × Volador (A, cada 0.5 s, tras 3 s) |
| 10 | 1 × **Jefe** (B) + 15 × Normal (C, cada 0.5 s, tras 2 s) + 15 × Normal (A, cada 0.5 s, tras 4 s) |
| 11 | 20 × Rápido (A, cada 0.3 s) + 10 × Blindado (C, cada 0.8 s, tras 3 s) |
| 12 | 16 × Volador (B, cada 0.4 s) + 16 × Volador (C, cada 0.4 s, tras 5 s) |
| 13 | 10 × Tanque (A, cada 1.1 s) + 10 × Tanque (B, cada 1.1 s, tras 3 s) |
| 14 | 25 × Normal (C, cada 0.3 s) + 25 × Rápido (A, cada 0.3 s, tras 3 s) + 12 × Blindado (B, cada 0.7 s, tras 6 s) |
| 15 | 1 × **Jefe** (A) + 1 × **Jefe** (C, tras 3 s) + 15 × Volador (B, cada 0.4 s, tras 5 s) |
| 16 | 15 × Blindado (A, cada 0.7 s) + 15 × Blindado (C, cada 0.7 s, tras 4 s) |
| 17 | 12 × Tanque (B, cada 0.9 s) + 20 × Volador (A, cada 0.35 s, tras 4 s) + 20 × Rápido (C, cada 0.3 s, tras 6 s) |
| 18 | 2 × **Jefe** (B, cada 3.0 s) + 30 × Rápido (A, cada 0.25 s, tras 3 s) |
| 19 | 15 × Tanque (A, cada 0.8 s) + 15 × Tanque (C, cada 0.8 s, tras 3 s) + 25 × Volador (B, cada 0.3 s, tras 6 s) |
| 20 | 2 × **Jefe** (A, cada 2.5 s) + 2 × **Jefe** (B, cada 2.5 s, tras 3 s) + 2 × **Jefe** (C, cada 2.5 s, tras 6 s) + 25 × Blindado (A, cada 0.5 s, tras 9 s) + 25 × Volador (C, cada 0.3 s, tras 11 s) |

### 7.7 Nivel 6 — Nido *(M5)*

El nivel de los enemigos nuevos. **Dos entradas:** A (izquierda) y **B, desde arriba**, que se une al camino de A en la columna 10. Después el camino baja en zigzag hasta la salida, a la derecha. Las curvas son buenos lugares para la Ráfaga.

```
col: 01234567890123456789
f0   ··········■·········  ← entrada B (desde arriba)
f1   ■■■■■■····■·······▲·  ← entrada A
f2   ·····■····■·········
f3   ···▲·■■■■■■■■■■■■■··      (B se une a A en la col. 10)
f4   ·················■··
f5   ··■■■■■■■■■■■■■■■■··
f6   ··■·········▲·······
f7   ··■■■■■■■■■■■■■■■■■■  → salida
f8   ·······▲············
```

| Oleada | Enemigos |
|---|---|
| 1 | 10 × Normal (A, cada 0.8 s) |
| 2 | 6 × **Troll** (A, cada 1.5 s) |
| 3 | 12 × Rápido (B, cada 0.4 s) + 8 × Normal (A, cada 0.8 s, tras 2 s) |
| 4 | 4 × **Araña** (A, cada 2.0 s) |
| 5 | 8 × Troll (B, cada 1.2 s) + 10 × Volador (A, cada 0.6 s, tras 3 s) |
| 6 | 6 × Araña (B, cada 1.5 s) + 8 × Blindado (A, cada 1.0 s, tras 2 s) |
| 7 | 10 × Troll (A, cada 1.0 s) + 6 × Araña (B, cada 1.5 s, tras 3 s) |
| 8 | 20 × Rápido (A, cada 0.3 s) + 10 × Volador (B, cada 0.5 s, tras 3 s) |
| 9 | 12 × Blindado (B, cada 0.8 s) + 8 × Troll (A, cada 1.0 s, tras 3 s) |
| 10 | 1 × **Jefe** (A) + 8 × Araña (B, cada 1.2 s, tras 3 s) |
| 11 | 12 × Troll (A, cada 0.8 s) + 12 × Troll (B, cada 0.8 s, tras 4 s) |
| 12 | 10 × Araña (A, cada 1.0 s) + 15 × Volador (B, cada 0.4 s, tras 4 s) |
| 13 | 15 × Tanque (B, cada 1.0 s) + 10 × Araña (A, cada 1.0 s, tras 4 s) |
| 14 | 2 × **Jefe** (A, cada 3.0 s) + 15 × Troll (B, cada 0.6 s, tras 3 s) |
| 15 | 2 × **Jefe** (A, cada 3.0 s) + 2 × **Jefe** (B, cada 3.0 s, tras 3 s) + 12 × Araña (A, cada 0.8 s, tras 6 s) + 15 × Troll (B, cada 0.6 s, tras 8 s) |

**Aumento de vida por oleada: 30 %** (ver §7.4).

### 7.8 Niveles en archivos de texto *(M7, B-04 escalón 1, D-031)*

Cada nivel es **un archivo de texto** en `data/levels/` (por ejemplo `level_06.json`) que se puede leer y cambiar con el Bloc de notas. El juego lo lee y arma el mapa solo: ya no hay escenas de mapa hechas a mano ni generadas por código.

- **RF-200** **El archivo del nivel** es JSON y tiene: `version` (hoy 1), `nombre`, `oro` (inicial), `vidas` (iniciales), `mapa` (9 filas de 20 letras; hasta 12 filas de 26, RF-250), `oleadas` y, si hace falta, `aumento_vida` (el % de vida extra por oleada de ese nivel, §7.4; si no está, se usa el general). El identificador del nivel (`level_06`) es el nombre del archivo.
- **RF-201** **Las letras del mapa:**

  | Letra | Casilla |
  |---|---|
  | `.` | Pasto: se construye (RF-02, libre). |
  | `#` | Camino. |
  | `X` | Bloqueada (el dibujo, roca, árbol o arbusto, sale solo, RF-154). |
  | `A`, `B`, `C`… | Entrada (es camino). `A` es la primera; no puede faltar una letra en el medio (no hay `C` sin `B`). |
  | `S` | La salida (es camino). Hay **una sola**. Si está en el borde, los enemigos salen del mapa por ahí; si está adentro, se dibuja la puerta (RF-06). |

- **RF-202** **El recorrido se calcula solo:** cada entrada va a la salida por el **camino más corto** sobre casillas de camino (`#` y letras). Si hay **dos recorridos igual de cortos**, el nivel es inválido: el juego no adivina, y avisa para que se cierre uno. Si la entrada está en el borde, los enemigos entran desde fuera del mapa (igual que antes). Los voladores van en línea recta de la entrada a la salida (RF-05).
- **RF-203** **Las oleadas** son una lista; cada oleada es una lista de grupos: `{"enemigo": "troll", "cantidad": 8, "cada": 1.2, "desde": 3.0, "entrada": "B"}`. `enemigo` es el nombre de un archivo de `data/enemies/`; `desde` (segundos desde que empieza la oleada) vale 0 y `entrada` vale `"A"` si no se escriben.
- **RF-204** **Validación con mensajes claros:** al leer un nivel se comprueba todo lo anterior: que el mapa mida entre 20×9 y 26×12 (RF-250) y solo tenga letras conocidas; que haya salida y al menos una entrada; que cada entrada llegue a la salida sin empates; que haya pasto para construir; que el oro, las vidas, las cantidades y los tiempos tengan sentido; que los enemigos existan; que cada grupo use una entrada del mapa, y que no haya **claves mal escritas** (por ejemplo `"canitdad"`). Cada problema se explica en castellano y dice dónde está ("oleada 3, grupo 2: no existe el enemigo 'trol'"). Un nivel inválido **no se juega** y el error queda en el registro; el juego no se cierra.
- **RF-205** **La campaña** es `data/campaign.json`: la lista de niveles en orden (`"niveles": ["level_01", …]`). Agregar un nivel es crear su archivo y sumarlo a esa lista.
- **RF-206** **Revisar un nivel sin jugarlo:** `tools/check_level.gd` lee un archivo y muestra sus errores o, si está bien, el mapa con el recorrido de cada entrada y su largo en casillas.
- **RF-207** *(M9)* **Aviso de atajo:** si hay casillas de camino que **ningún recorrido usa**, el nivel muestra un **aviso** (no un error: se juega igual) que dice cuántas son y dónde están (fila y columna). Casi siempre es que dos partes del camino quedaron en casillas vecinas y el enemigo **se salta el tramo del medio**, o que quedó un callejón sin salida o un camino de dos casillas de ancho. `check_level` marca esas casillas con `?` en el mapa.

**Ejemplo** (el nivel 6, con solo 2 de sus 15 oleadas: la 1 y la 3):

```json
{
  "version": 1,
  "nombre": "Nido",
  "oro": 250,
  "vidas": 20,
  "aumento_vida": 30,
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
  ],
  "oleadas": [
    [{"enemigo": "normal", "cantidad": 10, "cada": 0.8}],
    [{"enemigo": "fast", "cantidad": 12, "cada": 0.4, "entrada": "B"},
     {"enemigo": "normal", "cantidad": 8, "cada": 0.8, "desde": 2.0}]
  ]
}
```

> **Criterio de aceptación RF-200 a RF-205**
> **Dado** que los 6 niveles pasaron a archivos de texto → **Entonces** cada mapa tiene exactamente las mismas casillas, entradas, recorridos y oleadas que antes, y el bot de balance da los mismos resultados.
> **Dado** un nivel con un error (una entrada que no llega a la salida, un enemigo que no existe, una clave mal escrita) → **Entonces** el mensaje dice qué está mal y dónde, y el resto de la campaña sigue andando.



---

### 7.9 Nivel 7 — Cruce *(M8)*

El primer nivel hecho **directamente como archivo de texto** ([`level_07.json`](../data/levels/level_07.json), §7.8): sirvió para probar el formato nuevo con contenido real. **Dos entradas** en lados opuestos, A (izquierda, arriba) y B (derecha, abajo), y **la salida en el centro del mapa**, con su puerta (RF-06). Los dos recorridos dan una vuelta larga y terminan pegados a la salida, uno por cada lado. Los recorridos son más cortos que los de los niveles 4 a 6 (30 y 29 casillas), pero los dos terminan en el mismo lugar: una defensa en el centro cubre los dos frentes.

```
col: 01234567890123456789
f0   ····················
f1   A■■■■■■■■■■■■■■■■■··  ← entrada A
f2   ····▲···▲·····▲··■··
f3   ·▲····▲······■■■■■··
f4   ········■■S■·■······  ← la salida (S), en el centro
f5   ··■■■■■■■··■■■···▲··
f6   ··■·······▲····▲····
f7   ··■■■■■■■■■■■■■■■■■B  ← entrada B
f8   ·····▲······▲·······
```

(`■` es camino y `▲`, casilla bloqueada, como en los otros mapas; `A`, `B` y `S` son las entradas y la salida.)

Oro inicial **300**, 20 vidas, **20 oleadas**, con todos los enemigos (Normal, Rápido, Tanque, Volador, Blindado, Jefe, Troll y Araña): las oleadas 1 a 8 los presentan de a pares, y de la 9 en adelante se mezclan; la 20 trae 6 Jefes, Arañas y Trolls. La lista completa está en el archivo del nivel.

**Aumento de vida por oleada: 24 %** (ver §7.4). Con 15 % y con 20 % el bot que mezcla ganaba casi sin perder vidas (20 y 19); con 30 % perdía en la oleada 18 y con 45 %, en la 6: el salto entre 24 % y 30 % es muy brusco, así que conviene no subirlo sin revisar.

### 7.10 Mapas de tamaño variable *(M13, pedido por Lucas, D-037, B-08)*

Para poder hacer niveles más altos (9 y 10) con más lugar para construir y caminos más largos, un mapa puede ser **un poco más grande** que 20×9. No hay cámara que se desplaza: el juego **achica todo** (zoom) para que el mapa entre entero en pantalla, y la interfaz no cambia.

- **RF-250** **Tamaños posibles:** de **20×9** (el de siempre y el de todos los niveles actuales) hasta **26×12** casillas. Cada fila del `mapa` tiene que tener **el mismo largo** (entre 20 y 26 letras) y la cantidad de filas va de 9 a 12. La casilla sigue midiendo 64×64 en los números del juego: **alcance, velocidad y daño no cambian con el tamaño**.
- **RF-251** **Zoom automático:** el mapa se muestra con un zoom de `mínimo(1; 1280 ÷ (ancho × 64); 576 ÷ (alto × 64))`, **centrado** en el área que hay entre la barra de arriba y la de abajo. Con 20×9 el zoom es 1 (todo igual que hoy); con 26×12, 0,75. La barra de arriba, la de torres y los paneles **no se achican**: solo el mundo (mapa, torres, enemigos, disparos y efectos).
- **RF-252** **Todo funciona igual con zoom:** la casilla que se marca con el mouse o el dedo es la que está debajo del puntero; los alcances, los disparos y el daño dan lo mismo que sin zoom.
- **RF-253** **Validación:** un mapa con filas de distinto largo, de menos de 20×9 o de más de 26×12 es inválido y el mensaje dice qué tamaño tiene y cuáles se aceptan. Las entradas tienen que estar en el borde del mapa **real** (no de 20×9). Los topes de RF-223 suman estos.
- **RF-254** **El editor (§10.3) respeta el tamaño:** abrir, guardar y probar un mapa de otro tamaño no lo recorta ni lo corrige a 20×9, y el mapa se ve entero en el editor (con su propio zoom). El nivel nuevo sigue siendo de 20×9; **cambiar el tamaño desde el editor** todavía no se puede (queda para cuando se pida).
- **RF-255** **Por ahora solo se usa en los niveles 9 y 10** (Lucas, 2026-09-29): antes de tenerlos, el tamaño grande se prueba con un mapa de ejemplo y con los tests. Los niveles 1 a 7 no cambian.

> **Criterio de aceptación**
> **Dado** un mapa de 26×12 → **Cuando** lo juego → **Entonces** se ve entero, centrado entre las dos barras; hago clic en una casilla y la torre se construye **en esa casilla**; una torre con alcance 3 alcanza a los mismos enemigos que en un mapa de 20×9.

### 7.11 Leyenda y temas *(M15, pedido por Lucas, D-039, B-08)*

Hoy todos los mapas se ven igual (pradera) y lo bloqueado lo dibuja el juego al azar (RF-154). Con esto, un nivel puede tener **su propio paisaje** (un desierto, un mundo de nieve, un volcán) y **pedir qué va en cada casilla** ("acá hay un lago"). Son dos campos opcionales del archivo del nivel (§7.8): un nivel que no los tiene se ve **exactamente igual que hoy**.

- **RF-260** **Tema:** el campo opcional `"tema"` elige el paisaje de **todo** el mapa: `"pradera"` (el de siempre, es el que se usa si no está), `"desierto"`, `"nieve"`, `"volcan"`, `"bosque"`, `"pantano"` o `"ruinas"`. Cambia los **colores** del pasto y del camino, sus bordes, las piedritas y matas, y **qué se dibuja en las casillas bloqueadas** (`X`). Es **solo visual**: no cambia por dónde van los enemigos, qué se puede construir ni ningún número del juego.
- **RF-261** **Los siete temas** (los dibujos son nuevos y siguen las reglas de arte de RF-151: aspecto cuidado, nada infantil):

  | Tema | Suelo | Camino | Lo que sale en las casillas `X` |
  |---|---|---|---|
  | `pradera` | pasto verde (el actual) | tierra | rocas, árboles, arbustos (el actual) |
  | `desierto` | arena | tierra rojiza | cactus, rocas rojizas, huesos |
  | `nieve` | nieve | barro oscuro | pinos nevados, rocas con nieve |
  | `volcan` | roca oscura | ceniza | rocas negras, columnas de piedra, grietas con brasas |
| `bosque` | pasto oscuro con musgo y hojas caídas | tierra oscura con hojas | árboles densos, troncos caídos, helechos |
| `pantano` | barro verdoso con charcos | tierra húmeda con tablones | juncos, troncos secos, hongos grandes |
| `ruinas` | adoquines de piedra clara con pasto ralo | losas de piedra gastadas | columnas rotas, bloques caídos, estatuas |

- **RF-262** **Leyenda:** el campo opcional `"leyenda"` declara letras nuevas para el mapa. Cada una dice **qué se dibuja** y **si se puede construir**:
  `"leyenda": {"~": {"dibujo": "agua"}, ",": {"dibujo": "flores", "construible": true}}`
  La **letra** es un solo carácter, **no** puede ser `.` `#` `X` `S` ni una entrada (`A` a `H`) ni un espacio, una comilla o una barra. Hasta **10** letras por nivel. `construible` vale `false` si no se escribe.
- **RF-263** **Los dibujos** (una lista cerrada: el archivo elige un nombre, no trae imágenes propias):

  | Dibujo | Qué es | Tipo |
  |---|---|---|
  | `roca`, `arbol`, `arbusto` | los de siempre | objeto sobre el suelo |
  | `flores` | un parche de flores del color del tema | objeto (decoración) |
  | `agua` | un lago o un río, con reflejos | **suelo** (cubre toda la casilla y se une con los vecinos) |
  | `hielo` | hielo agrietado | suelo |
  | `lava` | lava con brillo | suelo |
  | `barro` | un charco de barro | suelo |
  | `cactus`, `pino`, `columna` | según el paisaje | objeto sobre el suelo |
  | `tronco`, `helecho`, `junco`, `hongo`, `estatua` | según el paisaje | objeto sobre el suelo |

  Un dibujo cualquiera se puede usar en cualquier tema (un lago en el desierto es un oasis). Uno que no existe es un **error** que lista los que sí.
- **RF-264** **Lo que significa para el juego:** una letra de la leyenda es, para el juego, **pasto** (si es `construible`) o **casilla bloqueada** (si no). **Nunca es camino**: no cambia entradas, salida ni recorridos, y los enemigos no la pisan (los voladores la cruzan igual que el resto del mapa, RF-05). Por eso los recorridos y todo el cálculo de §7.8 quedan iguales.
- **RF-265** **Validación (con mensajes claros, RF-204):** una letra usada en el mapa que no está declarada dice "letra desconocida" y recuerda que existe la leyenda; una declarada pero que no se usa da un **aviso** (RF-207); un tema o dibujo desconocido, una letra prohibida o repetida y más de 10 letras son **errores**. Los topes de RF-223 suman: 10 letras.
- **RF-266** **Editor (§10.3), etapa siguiente (M16, Lucas: "en otra etapa"):** el panel de **Ajustes** tendrá un selector de **tema**; la barra de herramientas sumará un botón por cada letra de la leyenda (para pintarla) y un botón para **agregar una letra** eligiendo el dibujo y si es construible. **En M15 el editor solo tiene que conservar** el tema y la leyenda de un nivel al abrirlo y guardarlo (para no perderlos); se escriben a mano en el archivo.
- **RF-267** **Compatibilidad:** los 7 niveles oficiales no cambian (se ven igual). Un mapa de la comunidad con tema o leyenda funciona en cualquier versión del juego que tenga esta función; en una versión anterior el campo se rechaza por desconocido (RF-204), como cualquier otra clave. **Sigue siendo solo datos:** ningún archivo puede traer imágenes ni código (RF-223).
- **Lo que NO incluye** (queda en B-08): terrenos con efecto (pantano, colina), un camino dibujado distinto (puente), decoración puesta a mano por posición, imágenes propias de un mod, un tema para parte del mapa.

> **Criterio de aceptación**
> **Dado** un nivel con `"tema": "nieve"` y una leyenda `"~": {"dibujo": "hielo"}` con una laguna de `~` al lado del camino → **Cuando** lo juego → **Entonces** el mapa se ve nevado, la laguna se ve como hielo, no puedo construir sobre ella y los enemigos siguen el mismo camino de siempre.
> **Dado** un nivel sin `tema` ni `leyenda` → **Entonces** se ve **exactamente** igual que antes de M15.

---

## 8. Ganar y perder

- **RF-90** **Victoria:** se completa la última oleada con al menos 1 vida. Aparece la pantalla **"¡Victoria!"** con las vidas restantes y los botones **Siguiente nivel** *(M3, si hay uno)*, **Reintentar** y **Niveles** *(M3: vuelve a la selección de nivel)*.
- **RF-91** **Derrota:** las vidas llegan a 0. El juego se detiene y aparece **"Derrota"** con la oleada alcanzada y los botones **Reintentar** y **Niveles** *(M3)*.
- **RF-92** **Reintentar** reinicia el nivel desde cero (vidas, oro, oleadas y torres).
- **RF-93** *(M4)* **Estrellas:** ganar un nivel da de 1 a 3 estrellas según las vidas que quedan, en porcentaje de las vidas iniciales: **3 estrellas** con el 90 % o más (18 de 20), **2 estrellas** con el 50 % o más (10 de 20), **1 estrella** si se ganó con menos. Los porcentajes están en `balance.tres`. Se muestran en la pantalla de victoria y en la selección de nivel (RF-111). No se guardan aparte: se calculan con la mejor cantidad de vidas, que ya se guarda (RF-115).

---

## 9. Controles e interfaz

### 9.1 HUD (lo que se ve durante la partida)

- **RF-100** Arriba: **oro**, **vidas**, **oleada actual / total** (por ejemplo "Oleada 3/10") y *(M6)* **puntos** (RF-190).
- **RF-101** Abajo: un **botón por torre**, con su forma, nombre y costo. Desactivado (gris) si no alcanza el oro. *(M5: ver RF-170.)*
- **RF-170** *(M5; en M19 pasa a **9 torres**, RF-297)* **Barra para 8 torres:** cada botón muestra el **dibujo** de la torre, su **costo** y, en una esquina, su **tecla**. El nombre no entra: aparece al pasar el mouse por encima y al elegirla (RF-171).
- **RF-171** *(M5)* Al elegir una torre para construir, encima de la barra se ve su **nombre, costo y una frase** que dice para qué sirve (`TowerData.description`).

  | Torre | Frase |
  |---|---|
  | Ametralladora | Barata y rápida. Buena contra enemigos débiles; mala contra la armadura. |
  | Cañón | Daño en área contra grupos. No le pega a los voladores. |
  | Hielo | Casi no hace daño, pero frena a los enemigos para que las demás torres les peguen más. |
  | Francotirador | Muchísimo alcance y daño por tiro. Ideal contra blindados y el Jefe. |
  | Incendiaria | Prende fuego a los enemigos: el fuego ignora la armadura y no los deja curarse. |
  | Múltiple | Dispara a varios enemigos a la vez. Buena contra enjambres. |
  | Ráfaga | Lanza púas en círculo; rinde más en una curva. No le pega a los voladores. |
  | Eléctrica | El rayo salta de un enemigo a otro. Cara y de corto alcance. |
- **RF-102** Botón **"Empezar oleada"** que muestra la cuenta atrás entre oleadas y se desactiva durante una oleada.
- **RF-103** *(M2)* Controles de velocidad: **Pausa**, **x1**, **x2**.

### 9.2 Teclado

| Tecla | Acción | Hito |
|---|---|---|
| `1`–`8` | Elegir torre para construir | M1 (1–3), M2 (4), M5 (5–8) |
| `Esc` | Cancelar construcción / cerrar panel / *(M3)* menú de pausa | M1 |
| `Espacio` | Empezar oleada (si se puede) | M1 |
| `P` | Pausar / reanudar | M2 |
| `F` | Alternar velocidad x1 / x2 | M2 |
| `U` | Mejorar torre seleccionada | M2 |
| `S` | Vender torre seleccionada | M2 |

- **RF-104** *(M2)* **Pausa** detiene todo (enemigos, torres, cuenta atrás), pero se puede seguir mirando el mapa y seleccionar torres. No se puede construir en pausa, pero **sí mejorar y vender** (así se puede pensar con calma). Mientras está en pausa se ve el cartel **"PAUSA"** en el centro.
- **RF-105** *(M2)* **Velocidad x2:** todo el juego va al doble (enemigos, disparos, oleadas, cuenta atrás, efectos). Al reintentar o salir, la velocidad vuelve a x1 y la pausa se quita.

### 9.3 Efectos visuales *(M1.5)*

**Estilo:** se mantiene el **estilo geométrico** (formas y colores planos), pero con vida: movimiento, destellos y partículas. La ambientación sigue abierta (§12); todo lo de aquí sirve igual si más adelante las formas se cambian por dibujos. *(En M4 las formas se cambiaron por dibujos provisionales: ver §9.6.)*

**Regla general:** los efectos son **solo visuales**. No cambian ninguna regla del juego (daño, tiempos, oro) y nunca bloquean clics.

| Regla | Qué se ve | Duración aprox. |
|---|---|---|
| **RF-120** Torres que apuntan | Cada torre tiene un **cañón** que gira hacia su objetivo. Sin objetivo, se queda quieto. | continuo |
| **RF-121** Disparo | Al disparar, el cañón **retrocede** un poco y aparece un **destello** en su punta. | 0.1 s |
| **RF-122** Impacto | **Ametralladora:** chispa pequeña. **Cañón:** onda circular que crece hasta su radio de área (así el jugador *ve* el área). **Hielo:** destello celeste. | 0.1–0.3 s |
| **RF-123** Golpe | El enemigo golpeado **parpadea en blanco**. | 0.08 s |
| **RF-124** Muerte | **Estallido de partículas** del color del enemigo y un **"+5"** dorado que sube y se desvanece (el oro ganado). | 0.8 s |
| **RF-125** Movimiento | Los enemigos se **bambolean** levemente al avanzar. Triángulos y rombos **apuntan** hacia donde caminan. | continuo |
| **RF-126** Mapa | El pasto con **variaciones de tono** y pequeños detalles; el camino con **bordes**; **sombras** suaves bajo torres y enemigos. | — |
| **RF-127** Aviso de oleada | Al empezar una oleada, un cartel **"Oleada 3"** aparece en el centro y se desvanece. | 1.5 s |
| **RF-128** Perder vidas | El número de vidas **parpadea en rojo** y la pantalla **se sacude** levemente (máximo 4 px). | 0.25 s |
| **RF-129** Cambios de oro | El número de oro hace un pequeño **"pop"** (crece y vuelve). | 0.15 s |
| **RF-130** Construir | La torre nueva **aparece creciendo** desde el centro, con un anillo que se expande. | 0.2 s |

- **RF-131** Con todos los efectos activos, el juego sigue cumpliendo la constitución P7 (60 FPS con 200 enemigos y 60 torres).
- **RF-132** *(M4)* **Números de daño:** al recibir un golpe, sube desde el enemigo un número chico con el **daño real** (después de la armadura, RF-80). Si la armadura le quitó la mitad o más del golpe, el número se ve **gris**: así se aprende que esa torre no conviene contra ese enemigo. Se desvanece en 0,6 s. Nunca hay más de **40** números a la vez (los que sobran no se muestran). Se pueden **apagar** en las opciones (RF-113).

### 9.5 Avisos de enemigos *(M4, pedido por Lucas)*

Para que el jugador sepa **antes** qué viene y qué hace cada enemigo. (Motivo: en una partida real, el Jefe quitó 10 vidas sin que el juego avisara que era peligroso.)

- **RF-133** **Próxima oleada:** en la barra inferior, entre los botones de torres y "Empezar oleada", se ven los enemigos de la **próxima** oleada: el dibujo de cada tipo y, debajo, cuántos son (por ejemplo, "×10"). Entran hasta 4 tipos en una fila (el máximo que trae una oleada). Se actualiza al empezar cada oleada. En la última oleada ya no hay "próxima" y el espacio queda vacío.
- **RF-134** **Presentación de enemigos:** la **primera vez en todo el juego** que aparece un tipo de enemigo, se muestra arriba una tarjeta con su forma, su nombre y una frase sobre qué hace, durante 6 segundos. No bloquea clics. Los enemigos ya presentados se recuerdan en el guardado (solo jugando desde el menú, RF-117). Las frases están en los datos de cada enemigo (`EnemyData.description`).
- **RF-135** **Cartel del Jefe:** si la oleada que empieza trae algún enemigo **peligroso** (que quita 5 vidas o más, RF-11), el cartel de oleada (RF-127) agrega "**¡Llega el Jefe!**" (con el nombre del enemigo) en rojo.
- **RF-136** **Marca de peligro:** los enemigos peligrosos llevan una **corona dorada** dibujada encima.

| Enemigo | Frase de presentación |
|---|---|
| Normal | Camina por el camino. Si llega a la salida, quita 1 vida. |
| Rápido | Muy veloz pero frágil. Las Ametralladoras lo frenan bien. |
| Tanque | Lento y con mucha vida. Si llega, quita 2 vidas. |
| Volador | Vuela en línea recta hacia la salida. ¡El Cañón no le pega! |
| Blindado | Su armadura le quita 3 a cada golpe: la Ametralladora casi no le hace nada. Usa Cañón o Francotirador. |
| Jefe | Mucha vida y armadura; el Hielo lo frena a medias. ¡Si llega, quita 10 vidas! |

### 9.4 Android *(hito MA, D-021)*

Adaptaciones **mínimas** para que el juego funcione en un celular. No es un rediseño para pantallas táctiles.

- **RF-140** Se exporta un `.apk` que se instala en un celular Android (versión de prueba, firmada con la clave de depuración).
- **RF-141** El juego se ve siempre **en horizontal** (girando el celular hacia cualquiera de los dos lados).
- **RF-142** El **botón "atrás"** de Android hace lo mismo que `Esc`: en la partida cancela la construcción o la selección, o abre y cierra el menú de pausa; en las opciones las cierra; en la selección de nivel vuelve al menú principal. **Nunca cierra el juego de golpe** (para salir está el botón "Salir" del menú principal).
- **RF-143** **Tocar** equivale a un clic izquierdo: tocar un botón lo pulsa; con una torre elegida, tocar una casilla construye; tocar una torre la selecciona. Como no hay "pasar el mouse por encima", la vista previa aparece donde se tocó. Para dejar de construir se toca otra vez el botón de la torre elegida.

### 9.6 Arte provisional *(M4, pedido por Lucas, D-023)*

Dibujos simples para dejar de ver formas geométricas. Es un **primer intento "para rellenar"**: **no** decide la ambientación (§12; B-01 y B-03 siguen abiertos; B-02 cerrado el2026-10-03) y cada dibujo se puede cambiar sin tocar el código.

**Estilo:** caricatura con colores planos y borde oscuro. Las torres se ven **desde arriba** (así la torreta puede girar); los enemigos, **de costado**, como personajes (así se les ven la cara y las patas).

- **RF-150** **Torres:** cada torre se dibuja con una **base** que muestra su nivel y una **torreta** propia de cada tipo. La torreta es la parte que gira y apunta (RF-120, RF-121). Se mantienen la placa/remaches de nivel (RF-75).

  | Nivel | Base | | Torre | Torreta |
  |---|---|---|---|---|
  | 1 | Plataforma de madera | | Ametralladora | Dos cañones finos |
  | 2 | Plataforma de piedra | | Cañón | Un cañón grueso |
  | 3 | Piedra con borde y remaches dorados | | Hielo | Cristal celeste con aletas |
  | | | | Francotirador | Cañón largo con mira, camuflado |

- **RF-151** **Enemigos:** cada tipo es una **bestia** del **mismo color** que tenía su forma, porque el jugador ya los reconoce por el color. El estilo es el del Tanque, que Lucas eligió como referencia: aspecto amenazante (ojos chicos y rasgados, colmillos, garras, púas), nada infantil. Normal = bestia gris parecida a un lobo; Rápido = lagarto corredor amarillo; Tanque = bestia marrón con placas y colmillo; Volador = dragón alado violeta (wyvern), de costado como los demás; Blindado = escarabajo con caparazón de metal azul y cuerno; Jefe = bestia roja enorme con cuernos y púas de hueso. **Miran hacia donde caminan:** se dan vuelta al ir hacia la izquierda, y al subir o bajar siguen mirando hacia donde miraban. Se mantienen la sombra, el bamboleo (RF-125), el parpadeo al recibir un golpe (RF-123), la barra de vida (RF-82) y la corona del Jefe (RF-136).
- **RF-152** **Ralentizado** (reemplaza el dibujo de RF-62): el enemigo se tiñe de **celeste** y aparece una **mancha de escarcha** en el piso, debajo de él.
- **RF-153** **Proyectiles:** cada torre dispara su propio proyectil, que **apunta hacia donde viaja**: bala con estela (Ametralladora), bala de cañón (Cañón), cristal de hielo (Hielo) y estela larga (Francotirador).
- **RF-154** **Mapa:** cada casilla bloqueada muestra una roca grande, un grupo de piedras, un árbol o un arbusto. Cuál muestra depende de la casilla, así que el mapa siempre se ve igual. La salida es una **puerta de piedra con antorchas** (RF-06). El pasto y el camino no cambian.
- **RF-155** **Interfaz:** los botones de torres muestran su **torreta**, y los íconos de enemigos (próxima oleada y presentación, RF-133 y RF-134) muestran su **dibujo**.
- **RF-156** **Reemplazable:** cada dibujo es un archivo en `assets/sprites/`, y los datos de cada torre y cada enemigo dicen qué archivo usan. Si a un dato le falta el dibujo, se usa la **forma geométrica** de antes: así nada se rompe si falta un archivo.
- **RF-157** Con los dibujos, el juego sigue cumpliendo P7 (60 FPS con 200 enemigos y 60 torres).
- **RF-158** *(M5)* **Efectos de lo nuevo:** el enemigo que se quema lleva **llamitas** encima; el que se regenera muestra "+N" verdes (RF-165); el rayo en cadena se ve como un **zigzag** amarillo entre los enemigos golpeados; las púas de la Ráfaga salen en círculo. Las torres y enemigos nuevos tienen sus dibujos, con el mismo estilo que el resto.
- **RF-159** *(M5)* **Ícono del juego:** hecho con los dibujos (una torre frente a una bestia), el mismo en la ventana, en el `.exe` y en el celular.

---

## 10. Pantallas y progreso *(M3)*

- **RF-110** **Menú principal:** Jugar, Récords *(M6, RF-195)*, Wiki *(M11, RF-230)*, Opciones, Salir. Es la primera pantalla al abrir el juego. De fondo se ve el mapa del nivel 1, oscurecido.
- **RF-117** El progreso **solo** se guarda cuando se juega desde el menú. Abrir la partida directamente desde el editor (F6) o correr los tests no toca el guardado del jugador.
- **RF-111** **Selección de nivel:** muestra los niveles. Los bloqueados dicen "Bloqueado". Los completados muestran sus **estrellas** (RF-93) y la mejor cantidad de vidas conseguida. Arriba se ve el **total de estrellas** de la campaña ("Estrellas: 7 de 15").
- **RF-116** *(M9)* **La selección de nivel admite cualquier cantidad de niveles:** las tarjetas se acomodan en **filas de hasta 5**, centradas; se ven **2 filas** y, si hay más, el área **se desplaza** (rueda del mouse, arrastrar con el dedo o las flechas del teclado, que siguen a la tarjeta elegida). Con 5 niveles o menos hay una sola fila. Ningún nivel queda fuera de la pantalla, sin importar cuántos haya.
- **RF-112** Al principio solo está desbloqueado el nivel 1. **Ganar** el nivel N desbloquea el N+1.
- **RF-113** **Opciones:** volumen de música, volumen de efectos, pantalla completa sí/no, **números de daño sí/no** *(M4, RF-132)*.
- **RF-114** **Menú de pausa** (con `Esc` durante la partida): Continuar, Reintentar, Opciones, Salir al menú.
- **RF-115** El progreso (niveles desbloqueados, mejores resultados) y las opciones **se guardan automáticamente** y siguen ahí al cerrar y volver a abrir el juego.
- **RF-116** **Sonido básico:** disparo de cada torre, muerte de enemigo, enemigo llega a la salida, victoria, derrota, clic de botón. Música de menú y combate, con transiciones y mezcla (RF-354).

> **Criterio de aceptación RF-115**
> **Dado** que gané el nivel 1 → **Cuando** cierro el juego y lo vuelvo a abrir → **Entonces** el nivel 2 aparece desbloqueado.

### 10.1 Puntos y récords *(M6, pedido por Lucas)*

Récords "a la antigua", como en los arcades: iniciales y un top 5.

- **RF-190** **Puntos:** cada enemigo muerto da **su oro × 10** (las crías también). Si se gana, cada vida que queda suma **100**. Los puntos se ven arriba, junto al oro ("Puntos: 1230"). Los dos números (10 y 100) están en `balance.tres`.
- **RF-191** **Récords de cada nivel:** cada nivel tiene su **top 5**, con **3 letras** (A–Z) y los puntos. Al terminar una partida desde la campaña, **ganada o perdida**, si los puntos entran en el top 5 se piden las 3 letras. A igual puntaje queda arriba el que llegó primero. Con 0 puntos no se entra.
- **RF-192** **Cómo se escriben las letras (estilo arcade):** una casilla por letra. **▲/▼** (o las flechas del teclado) cambian la letra; **◄/►** pasan de casilla; también se puede escribir directo con el teclado. **Listo** (o Enter) confirma. Empieza con las últimas letras usadas (la primera vez, "AAA"). Funciona igual con el mouse y tocando la pantalla.
- **RF-193** Después de anotarse (o si no entró), la pantalla final muestra el **top 5 del nivel**, con la entrada nueva resaltada.
- **RF-194** **Salón de la fama** ("el ranking de los rankings"): es para quien **ganó todos los niveles**. Su puntaje es la **suma del mejor puntaje en victoria de cada nivel** de esta partida guardada. Cada vez que ese total **sube** (al ganar el último nivel que faltaba, o al mejorar el récord propio de un nivel) y entra en el top 5 del Salón, se piden **5 letras**. Tiene estética propia: dorado, con marco y trofeo.
- **RF-195** **Pantalla "Récords"** en el menú principal: el top 5 de cada nivel (se cambia de nivel con ◄/►) y el Salón de la fama.
- **RF-196** Los récords se guardan con el progreso (RF-115) y, como el progreso, **solo** jugando desde el menú (RF-117). En el modo de pruebas van a un guardado aparte (RF-181).

> **Criterio de aceptación RF-191**
> **Dado** que el top 5 del nivel 1 tiene 5 entradas y la última tiene 800 puntos → **Cuando** termino el nivel 1 con 900 puntos → **Entonces** se me piden 3 letras, entro cuarto (o más arriba) y la entrada de 800 desaparece.

### 10.2 Modo de pruebas *(M6, pedido por Lucas, D-028)*

Para probar todo sin tener que ganar cada nivel, y sin ensuciar el progreso ni los récords reales.

- **RF-180** **Cómo se activa** *(cambiado en M48, D-077)*: desde **Opciones** en el menú principal (RF-383, RF-384), en el mismo ejecutable o APK de siempre, o al iniciar con el argumento `--pruebas` (RF-385). Hasta M48 solo existía en un ejecutable aparte, `JuegoA_pruebas.exe` (D-028).
- **RF-181** **Guardado aparte:** en modo pruebas se usa `save_pruebas.json`. El progreso, las estrellas, los récords y las opciones del guardado real no cambian.
- **RF-182** Siempre se ve un cartel **"MODO PRUEBAS"** en una esquina (en los menús y en la partida), para no confundirlo con el juego normal.
- **RF-183** **Todos los niveles** se pueden elegir, aunque estén bloqueados.
- **RF-184** **Panel de pruebas** en la partida (tecla `F1` o botón "Pruebas" arriba): +1000 de oro · vidas infinitas (sí/no) · saltar oleada · matar a todos los enemigos · ganar · perder · velocidad x4 · hacer aparecer un enemigo de cualquier tipo · mostrar los FPS. Los enemigos que se matan con el panel no dan oro ni puntos.

#### Probar oleadas finales y combos sin jugar el nivel entero *(M22, pedido por Lucas, D-048)*

**Estado: hecha (2026-10-01, T149 a T155), aprobada por Lucas.** Hoy, para ver la oleada 18 hay que jugar las 17 anteriores, y para mirar el aviso de combo (RF-315 a RF-318) solo hay una velocidad rápida (x4), que lo vuelve ilegible. Esta parte hace que el modo de pruebas sirva para eso. **Solo existe en el modo de pruebas** (RF-180): el juego normal no cambia.

- **RF-319** **Empezar en la oleada N:** en la selección de nivel (campaña y mapas de la comunidad), el modo de pruebas muestra una franja **"Pruebas"** con **Oleada inicial** (un número, desde 1) y **Oro inicial** (**Automático** o un valor a mano). Al elegir un nivel, la partida arranca **lista para empezar la oleada N** (la oleada y la vida de los enemigos son las que corresponden a la N, RF-36, y el HUD muestra la N como "próxima"). Si N es mayor que las oleadas del nivel, se usa la última. Con N = 1 todo es **igual que hoy**. La partida empieza **sin torres**: el oro sirve para construirlas.
- **RF-320** **Oro automático:** es lo que habría juntado quien juega las oleadas saltadas sin perder ningún enemigo: **el oro inicial del nivel** + **lo que dan todos los enemigos de cada oleada saltada** (incluidas las crías que suelta al morir, RF-166) + **el bono de cada oleada saltada** (RF-22). Se calcula **leyendo los datos** (el nivel, las oleadas, los enemigos y `balance.tres`): **no hay números nuevos en el código** (P2). Las **vidas** son las del nivel. Con un valor a mano, se usa ese (puede ser 0).
- **RF-321** **No ensucia el progreso:** una partida que empezó en la oleada 2 o más **no guarda** victoria, estrellas, récords ni desbloqueos (como cuando se prueba un nivel desde el editor, RF-217), porque no es una partida entera. Con la oleada 1 se guarda como hasta ahora (en el guardado aparte, RF-181). **Reintentar** vuelve a empezar en la **misma** oleada y con el **mismo** oro; "Siguiente nivel" y volver a la selección vuelven a la oleada 1.
- **RF-322** **Velocidades:** el panel de pruebas ofrece **x0,25 · x0,5 · x1 · x2 · x4** (cinco botones, el activo resaltado) en vez del interruptor "Velocidad x4". La velocidad se ve en el **cartel "MODO PRUEBAS"** (por ejemplo "MODO PRUEBAS · F1: panel · x0,5"; con x1 el cartel queda como hoy) y en el botón de velocidad del HUD (que hoy redondea y mostraría "x0"). **Al reintentar, terminar la partida o salir, la velocidad vuelve a x1** y el cartel también (RF-105). La tecla `F` sigue alternando x1 y x2; desde cualquier otra velocidad vuelve a x1.
- **RF-323** **Atajos de teclado** (solo en la partida y solo en el modo de pruebas, con el panel abierto o cerrado, y no con el menú de pausa abierto): **`F2`** matar a todos · **`F3`** saltar oleada · **`F4`** vidas infinitas (sí/no) · **`F6`** velocidad más lenta · **`F7`** velocidad más rápida (se saltea `F5`: Godot la usa en los cuadros de archivos). Se escriben en el panel junto a cada botón ("Matar a todos [F2]"). **No chocan** con ninguna acción del juego: las teclas `1`–`9` (torres), `Esc`, `Espacio`, `P`, `F`, `U`, `S` ni con `F1` (panel) ni con ninguna acción `ui_*` de Godot. Son acciones del `InputMap` creadas por el modo de pruebas al arrancar, así el juego normal ni las tiene. Las teclas **no se reasignan** (el juego no tiene pantalla de controles).
- **RF-324** **Los números viven en datos (P2):** las velocidades y el oro del botón "+1000 de oro" pasan de constantes del código a `data/dev_config.tres`.

> **Criterio de aceptación RF-319 a RF-321**
> **Dado** el nivel 1 (oro inicial 100 y 10 oleadas) en el modo de pruebas, **cuando** elijo oleada inicial 6 con oro automático, **entonces** la partida arranca con el oro del nivel + las recompensas de los enemigos de las oleadas 1 a 5 + los bonos de esas cinco oleadas (el número exacto sale de los datos y lo comprueba un test), el HUD dice que la próxima es la 6, y al empezarla salen los enemigos de la 6 con la vida de la 6.
> **Dado** una oleada inicial mayor que el total (por ejemplo 99), **entonces** se usa la última. **Dado** oleada 1, **entonces** el oro es el del nivel, como hoy. **Dado** un oro a mano de 0, **entonces** arranca con 0.
> **Dado** una partida empezada en la oleada 6, **cuando** gano, **entonces** no se guarda nada en el progreso ni en los récords; **y cuando** reintento, **entonces** vuelve a la oleada 6 con el mismo oro.

> **Criterio de aceptación RF-322 a RF-324**
> **Dado** una partida en el modo de pruebas, **cuando** elijo x0,5, **entonces** `Engine.time_scale` vale 0,5, el cartel y el botón del HUD dicen "x0,5"; **y cuando** salgo de la partida, **entonces** la velocidad es 1 y el cartel ya no dice nada de velocidad.
> **Dado** el `InputMap` con las acciones del juego y las del modo de pruebas, **entonces** ninguna tecla de una acción de pruebas es igual a la de otra acción (un test lo recorre), ninguna es `1`–`9`, y cada acción de pruebas hace lo mismo que su botón del panel.

- **RF-325** **Estadísticas de la partida de pruebas** *(Lucas dijo que sí, 2026-10-01)*: al terminar la partida (ganada o perdida) o al salir de ella, el modo de pruebas escribe `user://pruebas_stats.json` con **los mismos datos que el informe del bot** (`tools/balance_sim.gd`: oleada, vidas, oro, torres, resultado), con los nombres en inglés como el resto del código: `level`, `start_wave`, `wave`, `total_waves`, `lives`, `gold`, `towers`, `result` (`"won"`, `"lost"` o `"left"` si se salió antes) y `waves`, una lista con una fila por oleada terminada (`wave`, `lives`, `gold`, `towers`), más `seconds` (tiempo de juego, sin contar la pausa) y `started_at`. Cada partida **reemplaza** el archivo (no se acumulan). Solo en el modo de pruebas, y nunca toca el guardado de pruebas ni el real.

> **Criterio de aceptación RF-325**
> **Dado** una partida de pruebas que terminé en la oleada 3 con 17 vidas y 40 de oro, **cuando** termina, **entonces** `pruebas_stats.json` dice `result` `"won"` o `"lost"`, `wave` 3, `lives` 17, `gold` 40 y una fila por cada oleada terminada. **Dado** que salgo antes del final, **entonces** `result` es `"left"`. **Dado** el juego normal, **entonces** no se escribe nada.

### 10.3 Editor de mapas *(M9, pedido por Lucas, D-033, B-04 escalón 2)*

Una herramienta para crear y probar niveles sin escribir el JSON a mano. Nació como herramienta de administración solo del modo de pruebas (§10.2); desde M14 **está en el juego normal** (D-038): cualquiera puede hacer un mapa y jugarlo o compartirlo (§10.4). Lo que sigue siendo solo del modo de pruebas es el panel de pruebas y jugar cualquier nivel de la campaña (§10.2).

- **RF-210** **Dónde está:** el menú principal tiene un botón **"Editor de mapas"** en el `JuegoA.exe` normal y en Linux *(M14, D-038; Lucas confirmó el 2026-10-07 que sigue siendo para todos)*. **En el celular no se ofrece** (se maneja con mouse y teclado), salvo en el modo de pruebas. **Nunca toca** el progreso, los niveles oficiales (`data/levels/`) ni `campaign.json`: guarda solo en `user://maps/` (RF-216), y en el modo de pruebas usa además su guardado aparte (RF-181).
- **RF-211** **La pantalla:** arriba, una barra con **Nuevo · Abrir · Guardar · Probar · Salir**; en el centro, el mapa de 20×9 casillas con el mismo tamaño y lugar que en la partida (así se ve como va a quedar); abajo, las herramientas y una línea de mensajes. Los ajustes del nivel (RF-214) y las oleadas (RF-215) se abren en paneles encima del mapa.
- **RF-212** **Pintar el mapa:** se elige una herramienta y se hace clic, o se arrastra, sobre el mapa.

  | Herramienta | Tecla | Qué hace |
  |---|---|---|
  | Pasto | `1` | Casilla libre (se construye). También borra. |
  | Camino | `2` | Casilla de camino. |
  | Bloqueada | `3` | Casilla bloqueada (`X`). |
  | Entrada | `4` | Pone la **próxima letra libre** (`A`, `B`…, hasta 8) en esa casilla. |
  | Salida | `5` | Pone la salida (`S`); como hay una sola, **se mueve** si ya estaba. |

  Con el **botón derecho** se borra (pasto). Pintar encima de una entrada **la quita** y las letras que venían después **bajan un lugar** (las oleadas que usaban esas entradas se acomodan solas: las de la entrada quitada pasan a la `A`). **`Ctrl+Z`** deshace y **`Ctrl+Y`** rehace, hasta 50 pasos.
- **RF-213** **Se revisa solo, mientras se edita:** después de cada cambio se aplican las mismas reglas de §7.8. Si el mapa es válido, se dibuja el **recorrido de cada entrada** (un color por entrada) y se marcan las casillas que nadie pisa (RF-207). Si no lo es, la línea de mensajes dice qué falta o qué está mal, con los mismos textos de `check_level`. El editor **deja guardar un borrador con errores** (para seguir después), pero no probarlo.
- **RF-214** **Ajustes del nivel:** nombre, oro inicial, vidas, y aumento de vida por oleada (`0` = usar el general, §7.4).
- **RF-215** **Oleadas:** agregar, quitar y duplicar oleadas; cada oleada tiene grupos con **enemigo** (todos los de `data/enemies/`), **cantidad**, **cada** (segundos), **desde** (segundos) y **entrada** (solo las que tiene el mapa). Se ve el **total de enemigos** de la oleada. Un panel de oleadas nuevo empieza con un grupo de 10 Normales.
- **RF-216** **Guardar y abrir:** los mapas se guardan en `user://maps/<archivo>.json` con el formato de §7.8 (y ordenado como los niveles oficiales, para que se lea bien y se vea qué cambió en git). El nombre de archivo solo admite minúsculas, números y `_`. **"Abrir"** lista los **mapas propios** y los **niveles oficiales**; un nivel oficial se abre como **plantilla**: al guardarlo se pide otro nombre y **nunca se pisa** el oficial. Un mapa guardado se puede revisar con `tools/check_level.gd`, y para volverlo **oficial** se copia a `data/levels/` en el repositorio y se suma a `campaign.json`.
- **RF-217** **Probar:** el nivel del editor se juega ahí mismo, con las reglas de siempre (torres, oro, oleadas), pero **sin guardar** progreso, estrellas ni récords. Al terminar (o al salir desde la pausa) se vuelve al editor con el borrador intacto, tal como se dejó. **No se puede probar un nivel con errores.**
- **RF-218** **Nunca pierde trabajo sin avisar:** si hay cambios sin guardar, **Nuevo**, **Abrir** y **Salir** piden confirmación.

> **Criterio de aceptación**
> **Dado** el editor abierto en modo de pruebas → **Cuando** dibujo un camino de una entrada `A` a la salida `S`, dejo la oleada de ejemplo, guardo con el nombre `prueba_1` y apreto **Probar** → **Entonces** se juega ese mapa, y al terminar vuelvo al editor con el mismo mapa.
> **Dado** un mapa guardado por el editor → **Cuando** lo reviso con `tools/check_level.gd` → **Entonces** da el mismo resultado que el editor (sin errores, o los mismos errores).

### 10.4 Mapas de la comunidad *(M10, pedido por Lucas, D-033, D-034, B-04 escalón 3)*

Cualquiera puede sumar mapas al juego **copiando un archivo**: los mapas hechos con el editor (§10.3) o recibidos de otra persona aparecen en el menú, en cualquier versión del juego y sin tocar nada más. Son **solo datos** (JSON, §7.8): un mapa de la comunidad nunca puede traer código.

- **RF-220** **Dónde van:** todo archivo `.json` de la carpeta **`user://maps/`** es un **mapa de la comunidad**. En Windows es `%APPDATA%\Godot\app_userdata\JuegoA\maps` y en Linux, `~/.local/share/godot/app_userdata/JuegoA/maps/`. Es **la misma carpeta donde guarda el editor**: un mapa hecho con el editor aparece solo. Vale en todas las versiones que tengan esa carpeta a mano (Windows y Linux; en el celular la carpeta no se ve, así que allí la lista simplemente queda vacía).
- **RF-221** **La pantalla:** la selección de nivel tiene dos solapas, **Campaña** y **Mapas de la comunidad (N)**. La segunda muestra una tarjeta por archivo, en orden alfabético y **todos abiertos** (no hay desbloqueo). Cada tarjeta muestra el nombre del mapa, sus oleadas, su mejor resultado y sus estrellas. Si no hay ninguno, explica **dónde** ponerlos. Un botón **"Abrir carpeta"** (en PC) abre la carpeta y la crea si todavía no existe.
- **RF-222** **Mismas reglas que los niveles:** cada archivo se lee con las reglas de §7.8. Uno **con errores** aparece como tarjeta **deshabilitada** que dice "Con errores" y, al pasar el mouse, su primer error; no impide que se vean ni se jueguen los demás. Un archivo con un **nombre no válido** (solo minúsculas, números y `_`, RF-216) o **demasiado grande** (más de 200 KB) se muestra igual, deshabilitado y con el motivo.
- **RF-223** **Límites, para que un archivo ajeno no cuelgue el juego:** hasta **100 oleadas**, **20 grupos** por oleada, cantidad de hasta **999**, `cada` de hasta **60 s**, `desde` de hasta **600 s**, oro de hasta **99999**, vidas de hasta **999**, `aumento_vida` de hasta **300** y nombre de hasta **30 letras**. Valen para **todos** los niveles (los oficiales los cumplen) y el editor no deja pasarse de esos números.
- **RF-224** **Progreso aparte:** cada mapa de la comunidad tiene su propio progreso, con el id `comunidad_<archivo>`: mejor cantidad de vidas, estrellas (RF-93), mejor puntaje y **top 5 de récords** con 3 letras (RF-191 a RF-193). **No** cuentan para el desbloqueo de la campaña, ni para el total de estrellas, ni para el Salón de la fama (RF-194). Se guardan en el guardado de esa versión (RF-181: el modo de pruebas tiene el suyo).
- **RF-225** **Al terminar** un mapa de la comunidad, el botón "Niveles" vuelve a la **solapa de la comunidad**, y no hay "Siguiente nivel".
- **RF-226** **Se buscan cada vez que se abre la pantalla:** un mapa copiado mientras el juego está abierto aparece al volver a la selección de nivel, sin reiniciar.

> **Criterio de aceptación**
> **Dado** un mapa guardado con el editor (`mi_mapa.json`) → **Cuando** abro la selección de nivel en cualquier versión del juego y voy a "Mapas de la comunidad" → **Entonces** veo una tarjeta "mi_mapa", la juego, y mi mejor resultado queda anotado **solo** en ese mapa.
> **Dado** un archivo con un enemigo que no existe → **Entonces** se ve una tarjeta deshabilitada "Con errores" con el motivo, y los demás mapas se pueden jugar igual.

### 10.5 Wiki *(M11, pedido por Lucas, D-035)*

Una enciclopedia dentro del juego: dice cómo es cada enemigo y cada torre, y explica las reglas. Está pensada para **crecer sin tocar el código de la pantalla**: la pantalla no sabe qué es un enemigo ni una torre, solo dibuja **categorías** que contienen **entradas** hechas de **bloques** (títulos, textos y tablas).

- **RF-230** **Dónde está:** botón **"Wiki"** en el menú principal, entre "Récords" y "Opciones", en todas las versiones (también en el celular). `Esc` o "Volver" regresan al menú.
- **RF-231** **La pantalla:** arriba, una solapa por **categoría**; a la izquierda, la lista de **entradas** de la categoría elegida (dibujo y nombre); a la derecha, el **detalle** de la entrada elegida. Se elige con el mouse, con el dedo o con el teclado (**▲/▼** entre entradas, **◄/►** entre categorías). Las listas y el detalle **se desplazan** si no entran: no importa cuántas entradas ni cuánto texto haya.
- **RF-232** **Categorías iniciales:** **Enemigos**, **Torres** y **Guía** (artículos que explican las reglas). Si una categoría no tiene entradas no se muestra.
- **RF-233** **Enemigos:** una entrada por cada archivo de `data/enemies/`, **sin lista aparte**: agregar un enemigo al juego lo agrega solo a la wiki. Muestra su dibujo, su descripción (la de RF-134) y sus datos: vida en la primera oleada, velocidad, armadura, oro que da, vidas que quita, si vuela, resistencia a la ralentización, regeneración y qué suelta al morir. Además dice **en qué niveles de la campaña aparece** y **qué enemigo lo suelta** (las Crías, la Araña). Van ordenados del más débil al más fuerte (por vida).
- **RF-234** **Torres:** una entrada por cada archivo de `data/towers/`, también automática. Muestra su dibujo (base y torreta), la frase de RF-171, si golpea voladores y **una tabla con los 3 niveles** (costo de construir o mejorar, daño, cadencia, alcance) más los **efectos** de cada nivel (área, quemadura, ralentización, rayo que salta, púas, varios objetivos). Van ordenadas de la más barata a la más cara.
- **RF-235** **Guía:** artículos escritos a mano en **archivos de texto** `data/wiki/*.json` (uno por artículo: título, orden y bloques), para que se puedan escribir o corregir sin programar. Iniciales: cómo se juega, torres (construir, mejorar, vender, apuntado), enemigos (voladores, peligrosos, jefe), armadura y daño, efectos (ralentización, quemadura), puntos y estrellas. Los artículos **no repiten números que ya viven en los datos** (constitución P2): explican la regla y mandan a la entrada correspondiente.
- **RF-236** **Nada se rompe por una entrada mala:** un artículo con errores no se muestra y no impide ver el resto (los tests, en cambio, **fallan** si algún artículo oficial tiene errores, para no publicarlo así).
- **RF-237** **Los números salen de los datos**, no de textos escritos a mano: si se rebalancea un enemigo o una torre, la wiki cambia sola.
- **RF-238** **Bestiario que se va llenando** *(D-036, pedido por Lucas)*: un enemigo **aparece en la wiki cuando el jugador lo vio por primera vez en una partida** (el mismo momento en que el juego lo presenta, RF-134, y que el guardado ya recuerda). Mientras no se vio, su entrada existe pero está **cerrada** (RF-239). Las **torres y la Guía se ven siempre**: las torres se pueden construir desde el principio y la Guía explica las reglas.
- **RF-239** **Entrada cerrada:** en la lista se ve como **"???"** con su dibujo en **silueta negra** (así el jugador sabe que falta uno, pero no cómo es); al abrirla solo dice que todavía no se cruzó con ese enemigo y que aparece en la partida cuando lo enfrente. **No muestra** su nombre, sus datos, su descripción ni los niveles donde sale. La solapa dice cuántos lleva ("Enemigos 5/9") mientras falte alguno. La lista mantiene el mismo orden, así que las posiciones no se mueven cuando se abre uno.
- **RF-240** **Modo de pruebas:** con el modo de pruebas activo (§10.2) la wiki muestra **todo abierto**, porque es una herramienta de administración y usa su propio guardado (RF-181).

> **Criterio de aceptación**
> **Dado** un enemigo nuevo agregado a `data/enemies/` → **Cuando** abro la Wiki → **Entonces** aparece en "Enemigos" con sus datos, sin haber tocado ningún otro archivo.
> **Dado** un artículo nuevo `data/wiki/mi_articulo.json` → **Entonces** aparece en "Guía".

---

## 11. Qué **NO** incluye este juego

Se deja por escrito para no caer en la tentación (constitución P4). Si más adelante se quiere algo de esto, se agrega **primero aquí** como un hito nuevo.

- Multijugador.
- Héroes o unidades controlables.
- Habilidades activas del jugador (lluvia de meteoros, etc.).
- Modo infinito / endless.
- ~~Versión para móvil~~ → pasó al hito **MA** (§9.4, D-021), **solo** con adaptaciones mínimas. Sigue fuera: controles táctiles propios (arrastrar para construir, gestos, zoom) y una interfaz pensada para pantallas chicas.
- Llamar oleadas antes de tiempo con bonus de oro.
- Meta-progresión (mejoras permanentes entre partidas, tienda).
- Historia, diálogos o cinemáticas.
- Logros.
- Construir laberintos (los enemigos nunca cambian de camino).

---

## 12. Preguntas abiertas

Cosas que **no** hace falta decidir ahora; se deciden antes del hito indicado.

| Pregunta | Decidir antes de |
|---|---|
| ¿Nombre definitivo del juego? | M3 |
| ¿Ambientación? (medieval, espacial, juguetes…) Afecta nombres de torres/enemigos y el arte. **"Épocas" (B-01) pasó a Monsters & Canons 3D / M&C 2 (D-076).** Se decide junto con el lore (B-03); B-02 está cerrado y el arte futuro se encarga como trabajo específico. | M4 |
| ¿Música: de dónde sale? (propia, gratuita con licencia CC0…) | M3 |

---

## 13. Backlog de ideas

Ideas **aprobadas como dirección**, pero **sin fecha**: no se programan hasta convertirse en un hito con sus propias reglas (RF) y tareas. Se anotan aquí para no perderlas ni mezclarlas con el trabajo actual.

### B-01 · Épocas: la guerra evoluciona con el tiempo
**Trasladado por Lucas, 2026-10-07 (D-076):** Épocas no se hace en la V1; pasa al backlog de *Monsters & Canons 3D* o de *M&C 2* ([`06-monsters-canons-3d.md`](06-monsters-canons-3d.md) §15). La documentación de Épocas que menciona B-03 viaja con ella. El texto siguiente queda como registro.
*Propuesta de Lucas, 2026-09-28.*

**Idea:** las armas mejoran a través de las épocas (por ejemplo: medieval → pólvora → industrial → moderna → futurista), y los enemigos y sus defensas también. El jugador *ve* el progreso: sus arqueros se vuelven mosqueteros, después ametralladoras, después láseres.

**Por qué encaja:**
- Da la **ambientación** que faltaba (§12) y un hilo de "historia" sin necesidad de diálogos.
- Encaja con la arquitectura: torres y enemigos son "una escena + datos" (D-006), así que una época nueva es sobre todo **datos y dibujos nuevos**, no código nuevo.
- La armadura (RF-80) y los voladores (RF-05) ya permiten que los enemigos "evolucionen sus defensas": más armadura en épocas posteriores, aviones en la época moderna, etc.

**Variantes a decidir** (de menor a mayor complejidad):

| Variante | Cómo funciona |
|---|---|
| **A. Una época por nivel** | Cada mapa de la campaña es una época; las torres y enemigos disponibles cambian de un nivel a otro. |
| **B. Las mejoras son épocas** | Mejorar una torre (RF-71) la hace avanzar de época: se ve y se llama distinta. |
| **C. Avanzar de época en la partida** | El jugador paga para que toda su defensa avance de época a mitad de partida; los enemigos también avanzan con las oleadas. Mecánica nueva. |

**Antes de convertirla en hito hay que:**
1. Elegir la variante (o combinación).
2. Definir la lista de épocas y, para cada una, sus torres y enemigos.
3. Sacar "Historia" y "Meta-progresión" de la lista de §11 si la variante los necesita.
4. ~~Decidir si reemplaza la campaña normal o es un **modo aparte**.~~ **Decidido por Lucas (2026-09-29): es un modo aparte** (ver B-05), con dibujos de **imperios reales**.

**Cuándo:** sin fecha. Lucas prefiere no elegir variante por ahora (2026-09-28). Si se retoma, el lugar natural es M4 (arte), porque ahí se elige la ambientación.

### B-02 · ~~Diseño de assets (arte)~~
**Cerrado por Lucas, 2026-10-03 (D-063).** El juego ya tiene arte de torres, enemigos, mapas, interfaz y efectos, renovado en M23–M36. Se elimina el objetivo indefinido de «arte definitivo». Los detalles visuales concretos que surjan se registrarán y resolverán por separado, siguiendo la guía de arte; no mantienen abierta esta entrada ni requieren rehacer todo.

### B-03 · Lore y cierre de la V1
**Actualizado por Lucas, 2026-10-07. Dirección acordada; implementación pendiente.** La expedición coloniza un planeta desde un oasis, asegura posiciones y enfrenta bestias, criaturas independientes y comunidades organizadas. Campaña de **15 niveles**, en bloques **1–5 / 6–10 / 11–15**; final con asentamiento permanente, central de energía y abastecimiento, sin conquistar todo el planeta. El desenlace deja una sensación ambigua y la elección de bando queda fuera de V1.

**Registro completo de decisiones y plan:** [07-lore-y-cierre-v1.md](07-lore-y-cierre-v1.md). Incluye señales narrativas, biomas/mapas, demolición directa y demoledora global, recursos locales, extracción finita por oleadas, hallazgos científicos permanentes con colecciones por tecnología, Disruptora y Lanzamisiles candidato, rotación, assets, economía, criterios de entrega y preguntas pendientes. Los mapas con torres de recursos deben poder ganarse sin recolectar ni gastar recursos. **La intro ilustrada se agrega al final, después del juego funcional.** Registro de diseño; no afirma funciones implementadas ni cierra B-03.

**Relación con el backlog:** B-10 conserva niveles y campaña; B-22 conserva contenido/desbloqueos; las mecánicas nuevas requieren requisitos y tareas antes de implementarse. Textos breves, victoria, nombres y Lore en la Wiki siguen como opciones de presentación; revisar §11 antes de incorporar historia al juego. No se reabre B-02 como renovación general del arte.

**Épocas y registro histórico:** D-063 trasladó desde B-15 su futura documentación. D-076 traslada Épocas y esa documentación a otra entrega (B-01 y 06-monsters-canons-3d.md); no forma parte de este cierre de V1.

### B-04 · Crear mapas fácilmente y mods
*Propuesta de Lucas, 2026-09-29. Analizada por Claude. Decisión: D-024. **El escalón 1 se hizo en M7 (§7.8, D-031). El escalón 2, el editor, se hizo en M9 (§10.3) solo en la versión de pruebas.** **Prioridad de Lucas (D-033): el editor de mapas (escalón 2) y los mapas de la comunidad (escalón 3, solo la parte de mapas).** **La parte de mapas del escalón 3 se hizo en M10 (§10.4, D-034).** Lo que falta: enemigos, torres y dibujos propios (paquetes de mods completos) y decidir si el editor pasa al juego normal (B-13). Sin fecha.*

> **Lo que se decidió el 2026-09-29 sobre el editor y la comunidad (D-033):**
> - **El editor va primero en `JuegoA_pruebas.exe`**, como herramienta de administración (igual que el panel de pruebas, §10.2). Después se decide si pasa al juego normal, o si conviene **una sola app con un modo admin** (B-13).
> - **Dónde guarda:** un `.exe` exportado no puede escribir dentro de sí mismo (`res://` es de solo lectura), así que el editor guarda en `user://maps/`. Para volver un mapa **oficial** hay que copiar el archivo a `data/levels/` en el repositorio y sumarlo a `campaign.json`.
> - **Requisito previo, la pantalla de selección de nivel:** hoy tiene una sola fila de tarjetas de ancho fijo (se angostó al pasar a 6 y otra vez a 7 niveles, y con 8 ya no entra). Con mapas de la comunidad la cantidad de niveles no tiene tope, así que primero hay que pasarla a una grilla que se acomoda y se desplaza (también sirve en el celular).
> - **Lo que ya está hecho y sirve de base:** leer el mapa de letras, calcular los recorridos, validar con mensajes claros (`MapGrid`, `LevelFile`) y revisar un archivo sin jugarlo (`check_level`).

**Idea:** que crear un mapa nuevo sea fácil (sin tocar código ni el editor de Godot) y, más adelante, que otras personas puedan agregar contenido al juego: mapas, oleadas, enemigos, torres y dibujos. A eso se le llama **mods** (modificaciones hechas por jugadores).

**Qué ya tenemos a favor:**
- **Los datos ya están separados del código** (constitución P2): torres, enemigos, oleadas y niveles viven en archivos `.tres`, y los dibujos se eligen en esos datos (RF-156).
- **Un mapa es poca información:** el tamaño (20×9 casillas), qué es cada casilla (pasto, camino o bloqueada), por dónde pasa cada camino y las oleadas. `tools/make_levels.gd` ya arma los niveles 4, 5 y 6 a partir de eso: el "formato de mapa" existe, pero está escrito dentro del código. *(Así era antes de M7; desde M7 los niveles son archivos de texto, §7.8.)*
- **El nivel se puede armar al vuelo:** `Level` solo necesita las casillas (un `TileMapLayer`) y los caminos (`Path2D`); no importa si vienen de una escena o se crean al cargar un archivo.
- **El bot de balance** (`balance_sim.gd`) puede jugar cualquier nivel: serviría para avisar si un mapa nuevo es imposible o demasiado fácil.

**Tres escalones.** Cada uno sirve por sí solo y prepara el siguiente:

| Escalón | Qué es | Para quién | Tamaño aproximado |
|---|---|---|---|
| **1. Mapas en archivos de texto** | Un archivo por nivel con el mapa "dibujado" con letras y la lista de oleadas. El juego lo lee y arma el nivel solo. | Nosotros (hacer niveles nuevos sin tocar escenas) y cualquiera con un editor de texto. | 3–4 tareas |
| **2. Editor dentro del juego** | Pantalla "Crear mapa": pintar casillas con el mouse, marcar entradas y salida, armar las oleadas eligiendo enemigos, **probar al instante** y guardar. | Jugadores. | 5–7 tareas |
| **3. Mods de datos** | Una carpeta `mods/` donde cada mod trae mapas y, si quiere, enemigos y torres nuevos (sus números) y sus dibujos. El menú muestra los mapas instalados. | La comunidad. | 4–6 tareas |

**Cómo se vería un mapa en texto** (escalón 1; formato JSON, que Godot lee sin agregados):

```json
{
  "version": 1,
  "nombre": "Pradera",
  "oro": 150, "vidas": 20,
  "mapa": [
    "....................",
    "A################...",
    "................#...",
    "...X#############...",
    "....#...............",
    "....###############S",
    "...................."
  ],
  "oleadas": [
    [{"enemigo": "normal", "cantidad": 8, "cada": 1.0}],
    [{"enemigo": "normal", "cantidad": 10, "cada": 0.8},
     {"enemigo": "armored", "cantidad": 4, "cada": 1.5, "desde": 3.0}]
  ]
}
```

(Ejemplo recortado: un mapa real tiene 9 filas de 20 casillas.) `.` = pasto (se construye), `#` = camino, `X` = bloqueada, `A`/`B`/`C` = entradas, `S` = salida. El recorrido de cada camino se calcula solo: es el camino más corto por las casillas `#` desde cada entrada hasta la salida. Los voladores van en línea recta, como ahora.

**Decisiones a tomar cuando se retome** (con la recomendación de Claude):
1. **Formato:** JSON *(recomendado: se escribe a mano y Godot lo lee sin agregados)* o `.tres` (lo que usamos hoy: cómodo desde el editor de Godot, incómodo a mano y peligroso para mods, porque un `.tres` puede traer código).
2. **¿Mods solo con datos o también con código?** *Recomendado: solo datos* (JSON + imágenes). Godot puede cargar paquetes `.pck` con scripts, pero un mod con código puede hacer cualquier cosa en la computadora de quien lo instala, y además se rompe con cada cambio nuestro.
3. **¿Dónde se guardan?** En `user://maps/` y `user://mods/`, junto a `save.json`. En Android esa carpeta no se ve desde el celular, así que el editor y los mods serían sobre todo para PC.
4. **Progreso de los mapas propios:** separado del de la campaña (como RF-117), guardado por el nombre del mapa.
5. **Validación:** al cargar o guardar un mapa se comprueba que cada entrada llegue a la salida, que haya casillas para construir, que los números estén en rangos razonables y que los enemigos existan. Si algo falla, se muestra un mensaje claro y el juego sigue funcionando.
6. **Compartir:** copiando el archivo (Discord, itch.io). Steam Workshop queda fuera.

**Riesgos y costos:**
- **Balance:** un mapa de la comunidad puede ser imposible. Solo importa en los mapas oficiales; el bot puede dar una estimación ("el bot lo gana con 12 vidas").
- **Compatibilidad:** si cambiamos el formato, los mapas viejos dejan de andar. Por eso el archivo lleva `"version"`, igual que `save.json`.
- **Dibujos de mods:** se cargan mientras el juego corre, así que no pasan por el importador de Godot. El juego tiene que aplicarles él mismo el tamaño doble y los mipmaps (D-023).
- **El editor es lo más grande**, y en celular sería incómodo (spec §11: sin controles táctiles propios).

**Recomendación:** empezar por el **escalón 1** cuando haga falta hacer más niveles. Se paga solo: los niveles 1 a 5 se pueden pasar a ese formato (y un test compararía que se juegan igual que antes), y es la base del editor y de los mods.

**Relación con otras ideas:** Épocas (B-01) podría armarse como un "paquete" con otras torres, enemigos y dibujos, usando el mismo sistema que los mods. Los assets propios de un mod también se benefician: sus dibujos forman parte del paquete; B-02 está cerrado.

**Qué cambia en la spec si se hace:** un hito nuevo con sus reglas (RF) y tareas; si se hacen mods, una sección de seguridad (qué puede traer un mod y qué no).

### B-05 · Modos de juego
**Actualización de Lucas, 2026-10-07 (D-076):** el modo de historia con imperios reales (Épocas) pasa al otro juego. En la V1, Lucas propone una **prueba chica de modos, unificada con el gestor de mapas**. **Especificada en M49 (RF-388 a RF-392, D-078) con el OK de Lucas y hecha en T197: modo oficial Asedio, modos propios y "En un modo…" en el editor.**
*Propuesta de Lucas, 2026-09-29. Sin fecha: Lucas pidió solo anotarlo.*

**Idea:** el juego tiene **modos**, cada uno con sus propias torres, enemigos, niveles y dibujos. El juego actual sería el modo **"Torres y Bestias"**. Otro modo sería el de **historia** (Épocas, B-01), con dibujos de **imperios reales** (por ejemplo, legiones romanas, jinetes mongoles, samuráis) y armas que avanzan con las épocas.

**Cómo encaja con lo que hay:**
- Un modo es, sobre todo, un **paquete de datos y dibujos**: la lista de torres, la campaña (niveles y oleadas), los enemigos y sus dibujos. Desde M5 cada comportamiento es un dato (RF-164), así que un modo nuevo casi no necesita código.
- Es la misma idea que los **mods** (B-04): un modo oficial sería un "mod hecho por nosotros". Conviene diseñar los dos juntos (mismo formato de paquete).
- Pantalla para elegir modo: recién hace falta cuando exista un segundo modo.
- Guardado: el progreso y las estrellas se guardan por modo (los ids de nivel no se pueden repetir entre modos).

**Qué hay que cuidar con imperios reales:**
- Representarlos con **respeto**: sin caricaturas ni estereotipos, sobre todo de pueblos que existen hoy.
- Decidir cuánta **precisión histórica** se quiere (uniformes, armas, épocas) y usar referencias reales.
- Qué pasa con el estilo: el de "Torres y Bestias" (caricatura con borde oscuro) puede servir, pero un modo de historia podría pedir otro.

**Antes de convertirlo en hito:** elegir la variante de Épocas (B-01), la lista de imperios y épocas, y el formato de paquete (B-04).

### B-06 · Enemigo espejo
*Idea de Lucas, 2026-09-29. Sin fecha.*

**Idea:** un enemigo con caparazón de espejo. Si le dispara una torre que está **cerca** (rango corto), el tiro **rebota**: el enemigo no recibe daño y **esa torre queda aturdida** unos segundos, sin disparar. Las torres lejanas le pegan normal.

**Para qué:** castigar a las torres de corto alcance pegadas al camino, sobre todo a la **Eléctrica** (§5.6), y premiar al Francotirador.

**Qué necesitaría:** una regla nueva, "torre aturdida" (hoy las torres no tienen estados), y un efecto que se vea (chispas o estrellitas sobre la torre). Siguiendo RF-164, serían dos datos del enemigo: `reflect_range_tiles` y `reflect_stun_seconds`.

### B-07 · Enemigos que atacan o se defienden
**Actualización Lucas, 2026-10-03 (M37/D-064):** Estandarte, Ladrón periódico, Embestidor al extremo de rectas y desgaste/reparación se desarrollan por etapas al final de esta spec. Las propuestas históricas siguientes no sustituyen esas reglas nuevas. Guardián/Curandero/Chamán/Espejo ya implementados; Excavador continúa candidato.
*Pregunta de Lucas, 2026-09-29. Sin fecha: son ideas para elegir más adelante.*

**Hoy:** los enemigos **no atacan ni se defienden activamente**. Sus defensas son pasivas: armadura (RF-80), resistencia a la ralentización (el Jefe), regeneración (Troll) y soltar crías (Araña).

**Ideas**, de la más simple a la más grande (todas como datos, RF-164):

| Idea | Qué hace | Contra qué | Tamaño |
|---|---|---|---|
| **Guardián (aura de escudo)** | Los enemigos que caminan cerca de él tienen +2 de armadura. | Obliga a matarlo primero (modo de apuntado "Más fuerte" o el Francotirador). | Chico |
| **Curandero (aura de cura)** | Cura un poco por segundo a los que tiene alrededor. | Igual que el Guardián; el fuego le corta la cura. | Chico |
| **Enemigo espejo** (B-06) | Si le dispara una torre cercana, el tiro rebota y la torre queda aturdida. | Castiga a la Eléctrica y a las torres pegadas al camino. | Mediano |
| **Chamán (aturdir torres)** | Cada tanto lanza un rayo que **apaga** la torre más cercana por unos segundos. | Obliga a repartir torres; se ve una chispa sobre la torre apagada. | Mediano |
| **Excavador** | Se entierra unos segundos: mientras tanto, las torres no lo ven. | Premia las torres de área y el daño que queda (quemadura). | Mediano |
| **Ladrón** | Si llega a la salida, en vez de vidas se lleva oro. | Cambia la presión: menos vidas perdidas, menos oro. | Chico |
| **Torres con vida** | Algunos enemigos **atacan a las torres** y las pueden romper; habría que repararlas. | Cambia mucho el juego: interfaz nueva (vida de la torre, reparar), balance de todo. | Grande |

**Recomendación de Claude:** empezar por el **Guardián** y el **Chamán**. El Guardián es una aura (un dato y una búsqueda de enemigos cercanos, como la del rayo en cadena). El Chamán necesita una regla nueva, "torre aturdida", que también usaría el enemigo espejo (B-06). "Torres con vida" conviene dejarla para un modo aparte (B-05), porque cambia la base del juego.

### B-07 · Diseño ampliado de los enemigos con habilidades *(Lucas, 2026-09-29: "me gustaron, desarrollalos"; **Guardián y Curandero hechos en M17** (RF-270 a RF-277) y **Chamán y Espejo en M18** (RF-280 a RF-287); Ladrón hecho en M39, Excavador sin fecha)*

Los cuatro enemigos que gustaron, con lo necesario para convertirlos en spec cuando se tomen. Todos siguen RF-164: son **datos** del enemigo, apagados por defecto (valen 0), y se pueden combinar. Los colores son los libres de la guía de arte (`specs/05-guia-de-arte.md`).

| | **Guardián** | **Curandero** | **Chamán** | **Espejo** |
|---|---|---|---|---|
| **Aspecto** | Gólem de piedra marfil con un escudo grande; lento y macizo | Criatura chica y ágil con un bulbo o cristal que brilla, verde amarillento (no el verde del Troll) | Encapuchado magenta con un bastón que chispea | Tortuga de cristal cian, con placas que reflejan la luz |
| **Qué hace** | Aura de **armadura**: los enemigos cerca de él ganan +armadura | Aura de **cura**: los enemigos cerca de él recuperan vida | Cada tanto **apaga** la torre más cercana unos segundos | Si le dispara una torre **cercana**, el tiro rebota y esa torre queda aturdida |
| **Datos nuevos** | `aura_radius_tiles`, `aura_armor_bonus` | `aura_radius_tiles`, `aura_heal_percent_per_second` | `stun_interval`, `stun_seconds`, `stun_range_tiles` | `reflect_range_tiles`, `reflect_stun_seconds` |
| **Números de partida** (a balancear con el bot) | vida ≈ 2× el Tanque, velocidad baja, radio 2 casillas, +2 de armadura | vida ≈ el Troll, velocidad media, radio 2,5 casillas, 3 % de vida por segundo | vida media, velocidad media, cada 8 s, 3 s de apagón, alcance 4 casillas | vida alta, velocidad baja, rebota a menos de 3 casillas, 2 s de aturdimiento |
| **Cómo se le gana** | Matarlo primero (modo "Más fuerte", Francotirador) o pegarle desde lejos; el **fuego** no es frenado por el +armadura | Matarlo primero; el fuego le corta la cura (igual que al Troll, RF-165); el daño en área lo alcanza | Matarlo de lejos (Francotirador tiene más alcance que su hechizo) o tener torres de sobra | Torres de **largo alcance**, la quemadura (no rebota) y la ralentización |
| **Castiga a** | Las torres de golpe chico (Ametralladora, Múltiple, Ráfaga): con +2 de armadura casi no hacen daño | Los grupos que se plantan lejos de las torres de área | Las defensas que dependen de **una** torre fuerte | A la Eléctrica y a las torres pegadas al camino |

**Reglas comunes de las auras** (Guardián y Curandero): afectan **solo a los demás** enemigos dentro del radio, no a sí mismos; **no se suman** (vale la más fuerte, como la ralentización, RF-61); se ven como un **anillo suave** en el suelo alrededor del portador y un detalle sobre el afectado (un destello de escudo, una cruz verde); el portador **muere como cualquier otro** (no es inmune). Cuestan poco de calcular: una búsqueda de enemigos cercanos cada 0,25 s, igual que el rayo en cadena (RF-163).

**Regla común de "torre aturdida"** (Chamán y Espejo): una torre aturdida **no dispara** hasta que pasa el tiempo; se ve con **chispas** encima y el panel de la torre dice "Aturdida (2 s)". Se puede mejorar y vender igual. Es una regla nueva de las torres (hoy no tienen estados), que hay que agregar una sola vez para los dos enemigos.

**En qué orden y por qué:**
1. **Guardián + Curandero** (una etapa): comparten la mecánica de aura y no piden reglas nuevas en las torres. Empezar por el Guardián, que es el que obliga a cambiar de táctica.
2. **Chamán + Espejo** (una etapa): comparten "torre aturdida"; el Espejo además necesita que un proyectil sepa **qué torre lo disparó**.
3. **Cómo se presentan en los niveles** (spec §7.4): cada uno **entra solo** en un nivel (nivel 8: Guardián con muchos comunes; nivel 9: Curandero junto al Guardián; nivel 10: Chamán y Espejo), con la frase de presentación de RF-134, y en la Wiki aparecen solos (los datos nuevos se muestran como los demás).
4. **Cada uno se balancea con el bot** sobre el nivel donde debuta, y el bot tiene que aprender la respuesta (por ejemplo, poner el Francotirador). Si el bot no la encuentra, el enemigo es injusto.

**Actualización M39–M41:** Ladrón periódico y Embestidor/desgaste/reparación ya implementados para pruebas 6/7. Excavador continúa candidato sin selección. El diseño histórico de robo al escapar queda reemplazado por RF-363–365.

### B-08 · Mapas más ricos: terrenos, temas y tamaño
*Pregunta de Lucas, 2026-09-29 (a raíz de M7). Sin fecha.*

**Hoy:** un mapa dice solo tres cosas por casilla (pasto, camino, bloqueada) y **el dibujo de lo bloqueado lo elige el juego** al azar (roca, árbol, arbusto, RF-154). No se puede pedir "acá va un lago". El tamaño es fijo, 20×9 (RF-01).

**Ideas**, de la más chica a la más grande. Cada una es un campo nuevo y opcional del archivo del nivel, así los niveles que ya existen no cambian:

| Idea | Qué es | Tamaño |
|---|---|---|
| **Leyenda** *(propuesta en M15, §7.11)* | El nivel declara letras nuevas y qué son: `"leyenda": {"~": {"dibujo": "agua", "construible": false}}`. Los dibujos son archivos de `assets/sprites/map/` (y en un mod, imágenes propias). Se puede decidir el dibujo de cada casilla. | Chico |
| **Temas** *(propuesta en M15, §7.11)* | `"tema": "desierto"` cambia la paleta del pasto y del camino y el conjunto de decoración (nieve, lava, ruinas). | Chico |
| **Decoración a mano** | Una lista de objetos con su posición (un árbol grande en 3,4), sin necesidad de ocupar una casilla entera. | Chico |
| **Terrenos con efecto** | Pantano (los enemigos van más lentos), colina (las torres ganan alcance), terreno rico (construir cuesta menos). Cambian la estrategia y necesitan reglas (RF) y balance. | Mediano |
| **Tamaño variable** | Mapas más grandes que 20×9, con cámara que se desplaza o zoom. Cambia la interfaz, la construcción y los tests. **Hecho con zoom en M13 (RF-250 a RF-255, D-037): hasta 26×12.** | Grande |

**Recomendación de Claude:** empezar por **leyenda + temas**, que son lo que más ayuda al editor (B-04) y a los mods, y dejar el tamaño variable para el final.

### B-09 · Rutas explícitas y cruces de caminos
*Pregunta de Lucas, 2026-09-29. Sin fecha.*

**Hoy (§7.8):** el recorrido de cada entrada se **calcula** como el camino más corto por las casillas de camino. Eso permite **unirse** (empalmes en "T": niveles 3, 5 y 6) pero no permite:
- **Cruzarse:** dos caminos que se atraviesan en "+" y cada uno sigue derecho. En la casilla del cruce los dos enemigos "eligen" el mismo tramo de salida, así que uno se desviaría. Ningún nivel actual lo necesita.
- **Correr pegados sin tocarse:** dos tramos en casillas vecinas quedan **conectados**, y el enemigo puede tomar el atajo **sin que haya error** (si el atajo es el único más corto). `check_level` lo deja a la vista con el recorrido marcado, pero no lo avisa.

**Ideas:**
1. **Casilla de puente/cruce** (una letra, por ejemplo `+`): el enemigo la atraviesa **siguiendo derecho**, sin elegir. Resuelve los cruces con solo agregar una letra (el cálculo del camino tendría que recordar la dirección en que se llega).
2. **Rutas explícitas (opcional):** un campo `"caminos"` con las esquinas de cada entrada, como se hacía antes de M7. Si está, **reemplaza el cálculo**. Sirve para cualquier forma, incluidas salidas separadas por entrada (RF-03 hoy pide una sola).
3. **Aviso de atajo en `check_level`:** avisar cuando el enemigo se salta un tramo dibujado. **Hecho en M9 (RF-207, T100):** el aviso detecta las casillas de camino que ningún recorrido usa, que es justo lo que deja un atajo.

**Recomendación de Claude:** hacer el **aviso de atajo (3)** apenas se pueda, porque es barato, y el **puente (1)** cuando el editor o un nivel lo pidan.

### B-10 · Más niveles y niveles difíciles
**Dirección de cierre acordada, 2026-10-07:** campaña de 15 niveles y tres bloques; fichas, biomas y rotación por definir junto con el lore. Plan completo en [07-lore-y-cierre-v1.md](07-lore-y-cierre-v1.md) §§3/11/12. No marca como hechos los niveles pendientes.
**Producción parcial M45/T192:** niveles8/9 integrados con debuts de auras y encuentros de robo/desgaste; balance automatizado inicial. Los niveles "difíciles" (mismo mapa, otras exigencias) quedan cubiertos por el modo Asedio (M49, T197). Niveles10–14 y cierre15 siguen pendientes, además de validación humana8/9.
**Actualización de Lucas, 2026-10-03:** campaña base objetivo15 niveles: básico1–5, introducción/pruebas6–7, mayor presencia de nuevas mecánicas8–9, avanzado10–14 y definitivo15. Actualmente `campaign.json` incluye niveles1–9 (M45). Niveles10–15 requieren diseño y balance; no están implementados. Las amenazas nuevas no afectan1–5; esas primeras pantallas solo reciben avances de colección.
*Idea de Lucas (a partir de las propuestas de Claude), 2026-09-29. Sin fecha.*

- **Niveles 8, 9, 10…:** con el formato de M7 son un archivo de texto y una línea en `campaign.json`. Cada uno se balancea con el bot (spec §7.4).
- **Niveles "difíciles":** el mismo mapa con otras oleadas y más vida por oleada, como archivo aparte (`level_03_dificil.json`), con su propio récord. Reusan el mapa: un modo de dificultad sin diseñar mapas nuevos.
- **Requisito:** la selección de nivel escalable (ver B-04).

### B-11 · Compartir un mapa como texto
*Idea de Lucas (a partir de las propuestas de Claude), 2026-09-29. Sin fecha.*

**Idea:** en el editor, un botón **"Copiar código"** deja el nivel en el portapapeles, y otro **"Pegar código"** lo carga: se comparte por Discord o WhatsApp sin mandar archivos. El código es el mismo JSON de §7.8, quizás comprimido (más corto y sin comillas que se rompen al pegar). Aplica la misma validación de RF-204 al pegar: un código de un desconocido **nunca puede traer código ejecutable**, solo datos.

### B-12 · Mapas al azar y modo desafío
*Idea de Lucas (a partir de las propuestas de Claude), 2026-09-29. Sin fecha.*

**Idea:** un generador arma un mapa válido (camino, entradas, salida, bloques) y **el bot de balance lo juega** para comprobar que se puede ganar y que no es regalado, antes de ofrecérselo al jugador. Puede ser un **desafío diario** con una semilla igual para todos (la misma fecha, el mismo mapa), y un récord propio. Las oleadas también se pueden generar con una fórmula de dificultad. **Cuidar:** el bot tarda minutos por partida, así que la comprobación tendría que hacerse **antes** (mapas ya verificados) o con una versión rápida.

### B-13 · Una sola app con modo administrador
**Hecho en M48 (T196, RF-383 a RF-387, D-077), pedido por Lucas el 2026-10-07:** como el juego se regala, el modo de pruebas se activa desde Opciones y hay un solo ejecutable o APK por plataforma.
*Idea de Lucas, 2026-09-29. Sin fecha.*

**Hoy (D-028):** el modo de pruebas es un ejecutable aparte, sin ninguna clave: una contraseña dentro de un juego de un solo jugador no protege nada (el guardado es un archivo de texto editable). **Si se quiere una sola app**, el modo admin se activaría por algo que **el jugador normal no toca**, por ejemplo un argumento (`JuegoA.exe --admin`, un atajo del escritorio) o un archivo de configuración al lado del `.exe`. La regla de D-028 sigue valiendo: el modo admin **usa otro guardado** para no ensuciar el progreso ni los récords reales. **Decidir después** de ver el editor funcionando (B-04).

### B-14 · Tipos de daño (físico y elemental) y armadura más flexible
*Idea de Lucas, 2026-09-29 (a raíz de la fórmula de daño de League of Legends). Sin fecha.*

**Hoy (RF-80):** `daño real = máximo(1, daño − armadura)`. La resta fija es deliberada: la armadura castiga a las torres que pegan muchas veces con poco daño (Ametralladora, Múltiple, Ráfaga) y casi no afecta a las pesadas (Cañón, Francotirador), así cada torre tiene un papel. Con armadura 3, la Ametralladora pierde el 60 % del golpe y el Francotirador el 8 %. Un porcentaje fijo (`daño × 100 / (100 + armadura)`, como en League of Legends, Dota 2 o Warcraft 3) afectaría a todas por igual y se perdería esa diferencia.

**Idea:** en vez de cambiar la fórmula, sumar **dos tipos de daño**, cada uno con su defensa (la idea que sí sirve de ese video):
- **Físico** (Ametralladora, Cañón, Francotirador, Ráfaga, Múltiple): lo reduce la **armadura** (resta fija, como hoy).
- **Elemental** (Incendiaria, Hielo, Eléctrica): lo reduce una **resistencia mágica** (`resistencia_elemental`), que podría ser un porcentaje.
- Cada enemigo tendría sus dos defensas: el Blindado, mucha armadura y poca resistencia; un enemigo "de piedra", al revés. Sigue RF-164: son campos con valor 0 que se combinan (`damage_type` en la torre; `armor` y `elemental_resistance` en el enemigo).

**Punto débil de hoy que se puede arreglar aparte:** el piso de 1 es un precipicio (si un enemigo tuviera armadura 10, las torres de golpe chico pegarían siempre 1). Una salida chica es un **piso proporcional**: `máximo(golpe × 20 %, golpe − armadura)`.

**Antes de hacerlo:** cambiar la fórmula obliga a **volver a balancear los 7 niveles** con el bot. Se puede comparar las dos fórmulas con el bot en una copia aparte, sin tocar el proyecto. **Qué cambia en la spec:** RF-80, la tabla de torres (columna "tipo de daño") y la de enemigos.

### B-15 · ~~Ampliación general de la Wiki~~
**Retirado y dividido por Lucas, 2026-10-03 (D-063).** Lore y Épocas pasan a B-03; la documentación de mods y comunidad se separa en B-29 y B-30. Se retira del pendiente el bestiario ya implementado en M12. Se descartan buscador, enlaces entre entradas, categoría Niveles e imágenes adicionales en artículos: no se necesitan. El bestiario, los dibujos y la navegación existentes se conservan.

### Sugerencias de Claude *(consultar antes de implementar)*
*Regla de Lucas, 2026-09-29: las ideas que Claude propone por su cuenta se anotan acá y no se implementan hasta que Lucas las apruebe.*

- **Bot de balance repetible** *(2026-10-01, D-047)*: el temblor de pantalla (RF-128) usa `randf` sin semilla fija y, con varias copias del bot corriendo a la vez, cambia por redondeo qué enemigo está dentro del alcance; en el nivel 7 el mismo caso daba derrota en la oleada 11 o en la 18. Arreglo de una línea en `tools/balance_sim.gd` (`seed(12345)` en `_initialize`, o anular el temblor en el bot). Sumar también la opción `seed=N` de la investigación del combo (elegir entre casillas casi tan buenas como la mejor) para medir con varias corridas por caso. No cambia el juego.
- **Dibujo más liviano de torres y monstruos** *(2026-10-06, hallazgo del estudio B-21 v2, T193)*: con la carga de P7 (200 monstruos, 60 torres) unos 9 de los ~11 ms de cada cuadro se van en dibujar torres y monstruos en 2D (cada uno se redibuja entero con `_draw` en cada cuadro); con ellos ocultos el juego corre a ~520 FPS en lugar de ~92 (medido en `art/b21-vista/rendimiento.txt`). En PC sobra margen, pero en celular puede ser lo primero que conviene aligerar: por ejemplo, el cuerpo con `Sprite2D` y solo barras/íconos con dibujo propio, o redibujar solo lo que cambia. Medir primero en un Android real (P4: no optimizar sin medir).
- **"¿Qué es esto?" desde la partida:** al tocar un enemigo o una torre durante la partida, un botón que abre su entrada de la wiki (con `show_target`) y al volver retoma la partida en pausa. Ojo con la pausa, con el celular (el toque ya selecciona torres) y con no dejar espiar enemigos que todavía están cerrados en el bestiario.
- ~~**Guía de arte del juego:** a partir del rediseño de los nueve enemigos (T127) se ve un estilo propio: contorno oscuro grueso, formas angulosas con facetas, un brillo por dibujo, mirando a la derecha, un color por especie. Escribirlo en un documento corto (`specs/05-guia-de-arte.md`: paleta por enemigo y por tema, grosor del contorno, cómo se hace una faceta, qué se evita) ayudaría a que los ~25 dibujos de M15 y los enemigos nuevos salgan iguales. Idea inspirada en el rol de "director de arte" del repositorio Claude Code Game Studios.~~ **Hecho (T129, D-040): [`specs/05-guia-de-arte.md`](05-guia-de-arte.md).**
- ~~**Reglas por carpeta para Claude** (`.claude/rules/`): por ejemplo "en `scripts/` y `scenes/` se sangra con tabuladores", "los números de balance van en `data/`, no en el código" y "un dibujo nuevo sigue `specs/05-guia-de-arte.md`". Hoy esas reglas están en la constitución y en mi cabeza; ponerlas por carpeta evitaría errores repetidos (por ejemplo, editar con espacios un archivo de tabuladores).~~ **Hecho (T129, D-040): [`.claude/rules/`](../.claude/rules/).**
- **Parte útil del repositorio Claude Code Game Studios** (Lucas: "no hace falta `validate-commit`"; del resto, ver D-040):
  - **Informe de prueba** (su `playtest-report`): una plantilla corta para anotar lo que se siente al probar el juego (¿se entendió?, ¿dónde te trabaste?, ¿qué te aburrió?) y guardarla en `specs/pruebas/`. Hoy las impresiones de Lucas quedan en la charla.
  - **Auditoría de recursos** (su `asset-audit`): un test que revise que **todos** los dibujos y sonidos existen, miden lo que dice la guía y que ningún dato apunta a un archivo que falta.
  - **Notas de versión** (su `changelog`/`patch-notes`): un `CHANGELOG.md` para quien juegue, con lo nuevo de cada versión, cuando se empiece a compartir el juego.
  - **Deuda técnica** (su `tech-debt`): un registro de las cosas flojas que fuimos anotando (el editor solo con mouse, Linux sin probar, el celular sin probar el zoom…).

### B-16 · Torres especiales y torres que se fusionan *(idea de Lucas, 2026-09-29: "combinar torres para hacer unas de 4 casillas contra los bichos más fuertes"; sin fecha)*

**Idea de Lucas:** juntar torres para hacer una más grande, de 4 casillas (2×2), que sirva contra los enemigos más fuertes.

**Por qué encaja bien con lo que ya hay:** la armadura resta un número fijo **a cada golpe** (RF-80). (Números de ejemplo.) Cuatro Ametralladoras que pegan de a 5 contra armadura 3 hacen 4 × 2 = 8 por ronda; **una** torre que pega de a 20 hace 17. Concentrar el daño en un solo golpe es justo lo que vence a la armadura, y así ya funcionan el Cañón y el Francotirador. Una fusión sería la forma de que **toda** torre tenga un "modo pesado". Además, en los mapas grandes (§7.10) hay lugar de sobra.

**Cuatro formas de hacerlo**, de la más grande a la más chica:

| | Qué es | Trabajo | Comentario |
|---|---|---|---|
| **A · Fusión** | 4 torres **iguales, de nivel 3, en cuadrado** se fusionan (botón "Fusionar") en una torre 2×2 con más daño por golpe, más alcance y un efecto extra, de datos propios | Grande | Es lo que pidió Lucas. Exige torres de **más de una casilla** en el juego (ocupación, vista previa, vender, mejorar) y un arte de fusión |
| **B · Torre grande construible** | Una torre nueva que **se construye directamente en 2×2** (por ejemplo un **Mortero**: daño enorme en área, lento, de gran alcance) | Mediano | Es el paso previo de A: prueba el "2×2" con **una** sola torre y **una** pieza de arte |
| **C · Sinergia por vecinos** | Dos torres **pegadas** se potencian (Hielo junto al Cañón: el Cañón pega más a lo ralentizado; Incendiaria + Eléctrica: el rayo quema) | Mediano | Sin torres nuevas ni arte, pero hay que **mostrar** los vínculos y balancear pares |
| **D · Recetas** | Dos torres **distintas** adyacentes se fusionan en una híbrida | Grande | Con 8 torres son 28 pares: demasiado, salvo pocas recetas elegidas a mano |

**Orden acordado (Lucas, 2026-09-30, D-041): B, después C, y la A (fusión) para más adelante. La B (el Mortero 2×2) se especifica en §5.7 y está hecha en M19 (RF-290 a RF-299).** *Recomendación original de Claude: ir por **B y después A**.* Con B se resuelve lo difícil (que una torre ocupe 4 casillas) con un solo dibujo y un solo balance. Con A, las fusiones pueden salir **de los datos** (cada torre declara su versión fusionada con multiplicadores) y **reusar el mismo dibujo agrandado** con un marco dorado, sin ocho dibujos nuevos.

**Reglas a decidir cuando se tome:**
- ¿La fusión **se puede deshacer**? (Propuesta: no; se puede **vender** y devuelve una parte, RF-72.)
- ¿Cuánto **cuesta**? Ya se pagaron las 4 torres; una fusión debe **valer la pena**, pero no ser obligatoria (propuesta: costo extra parecido al de una torre de nivel 3).
- La torre fusionada **apunta desde el centro** del cuadrado y el alcance se mide desde ahí.
- En el **bot de balance**, una estrategia nueva que fusione.
- En **mapas chicos** (20×9) el espacio sí importa: 4 casillas de pasto juntas cerca del camino.

**Torres de apoyo (idea de Claude, relacionada):** como los enemigos tendrán auras (arriba), las torres pueden tenerlas también: un **Estandarte** que sube la cadencia o el alcance de las torres cercanas. Usa **la misma mecánica de aura**, así que conviene diseñarlas juntas.

### Actualización de prioridades · Lucas, 2026-10-02

**Registro inicial; Lucas autorizó B-17/B-18 en M32 y B-19 en M33.** B-20 y B-24 a B-27 completados en M36; análisis B-21/B-22/B-23 entregados con opciones de producción por decidir. B-17 a B-23 tenían **prioridad media**, sin fecha. Primero mejorar la experiencia y la presentación actuales; ampliar la campaña hasta el nivel10 (B-10) queda con **prioridad baja**. Las investigaciones entregan opciones y muestras para decidir antes de producción. Las capturas compartidas muestran el HUD/panel de pruebas y los indicadores amarillos de niveles de torre; sirven de referencia visual.

### B-17 · ~~HUD compacto, pausa y controles de administración~~
**Prioridad media · Implementado en M32 (T175, RF-345).** Quitar palabras redundantes junto a los iconos de oro, vidas, puntos y oleada: conservar icono y valor (incluido actual/total de oleada). Al pasar el puntero sobre cada icono, mostrar una ayuda pequeña con su significado; contemplar foco por teclado y una alternativa táctil. Rediseñar el fondo de la barra superior, el menú de pausa y los controles de pruebas/admin con la estética actual de Monsters & Canons, mejorando agrupación, jerarquía y orden. Conservar acciones y atajos. **Entrega futura:** muestras del HUD, pausa y panel reorganizado, legibles en los tamaños de ventana soportados, antes de integrar.

### B-18 · ~~FPS y métricas visibles durante la partida~~
**Prioridad media · Implementado en M32 (T175, RF-346).** FPS y ms/cuadro estimados; otras métricas no se añadieron. Cuando se active Mostrar FPS, dibujarlos sobre la partida, sin fondo y fuera del panel de pruebas, para que sigan visibles con el panel cerrado. Evaluar si conviene añadir tiempo por cuadro en ms, enemigos/proyectiles activos u otra métrica útil; elegir pocas, con bajo costo y buen contraste sin tapar controles. Es un monitor local de rendimiento (telemetría local); no implica envío ni recopilación remota. **Entrega futura:** propuesta de métricas, ubicación, frecuencia de actualización y muestra; comparar costo con el monitor apagado/encendido.

### B-19 · ~~Renovar Opciones y los submenús~~
**Completado en M33 (T176, RF-347), prioridad media.** Opciones separa sonido/visualización con deslizadores y casillas del tema. Selección de campaña/comunidad, Wiki, récords, final, iniciales/Salón de la Fama y editor/diálogos comparten hierro-bronce. Paneles y foco coherentes; funciones/guardados conservados. Capturas en `art/redesign-m33/`,891/891 GUT; revisión visual Full HD, sin ejecución móvil/Linux.

### B-20 · ~~Integrar mejor las marcas del nivel de torre~~
**Completado en M36 (T181, Lucas, 2026-10-03).** Capturas y detalles en `art/redesign-m36/`; reglas de combate conservadas. El texto siguiente registra el pedido original.
**Pedido original:** revisar los puntos amarillos flotantes de RF-75, que hoy indican niveles1/2/3. Comparar puntos más sutiles incorporados a la base (remaches, luces o detalles) con mayor contraste/intensidad del brillo ya implementado en M30. No es obligatorio eliminarlos: el nivel debe seguir siendo reconocible a escala de partida, también cuando el brillo se apaga por aturdimiento. Evitar confundirlos con selección u otros efectos. **Entrega futura:** comparación de los tres niveles, al menos sobre el Cañón, y revisión del criterio para las demás torres; sombras fuera de alcance salvo pedido posterior.

### B-21 · Investigar una vista general con más sensación de 3D
**Resuelto por Lucas, 2026-10-07 (D-075):** la maqueta 3D es la que más le gustó, pero exige adaptar los dibujos y repensar el espacio, así que el 3D **no se integra en la V1**: pasa a la segunda entrega, *Monsters & Canons 3D* (B-32, [`06-monsters-canons-3d.md`](06-monsters-canons-3d.md)). En la V1 solo queda, como opcional, la etapa 1 del relieve (orden por profundidad con capa superior para barras).
**Análisis v2 entregado en M46 (T193, RF-382, D-074; Lucas lo pidió el 2026-10-06).** Entrega en [`B21-vista-v2.md`](../art/b21-vista/B21-vista-v2.md): cuatro vistas de la misma partida real (actual, relieve en la misma cuadrícula, oblicua al 80 % y maqueta 3D), jugables, con medidas de casillas/clics y rendimiento. Recomendación: no cambiar la proyección; si se quiere más profundidad, relieve en la misma cuadrícula (B) horneado y por etapas; oblicua (C) como alternativa con PR *breaking change*; 3D real (D) descartada para este juego; dejarlo como está (A) también es válido. No se integró nada.
**Antes: análisis preliminar entregado en M36 (T181).** Entrega en [`B21-profundidad.md`](../art/redesign-m36/B21-profundidad.md). Faltan decisiones de Lucas y profundizar/validar la opción elegida antes de producción; no se integró esa mecánica. El estudio rápido no constituye un diseño definitivo. El texto siguiente registra el alcance original.
**Pedido original de investigación:** Mejorar la profundidad de toda la escena, además de los sprites. Comparar alternativas: relieve y bordes del terreno con iluminación coherente; perspectiva oblicua/isométrica simulada en2D; escena2.5D con suelo3D y sprites. Evaluar orden de dibujo/oclusiones, alineación de bases y caminos, selección/construcción, cámara, interfaz, rendimiento, escritorio y móvil, y compatibilidad de mapas/guardados. No se adopta ninguna opción todavía.
**Entrega futura:** muestras comparables del mismo mapa y una evaluación de alcance/costos/riesgos. Tratar el cambio de vista como potencial **breaking change**: preparar un PR de revisión identificado como tal, avisar a Lucas con el enlace y esperar su aprobación explícita **antes de mergear**. Una muestra no autoriza migrar toda la producción ni fusionar el PR.

### B-22 · Analizar contenido nuevo y desbloqueos en niveles superiores
**Dirección acordada, 2026-10-07:** recursos locales opcionales, hallazgos científicos por tecnología, Disruptora aprobada como dirección y Lanzamisiles candidato. Asedio de largo alcance descartado por redundancia con Francotirador. Reglas, economía y preguntas en [07-lore-y-cierre-v1.md](07-lore-y-cierre-v1.md) §§4–9; no cierra B-22.
**Producción M45/T192:** campaña8/9 con Guardián/Curandero y mayor presión de sistemas existentes; estadísticas globales y1–7 intactos, balance humano pendiente. B22 continúa abierto para tramo avanzado y otros candidatos.

**Primera producción parcial M37/T183:** colección y apoyo mecánico implementados como etapa funcional; diseño visual y balance iniciales. Disponibilidad por nivel aprobada, con colección adicional para estandartes. Ladrón, Embestidor/desgaste y reparación implementados en T184–T186 con pruebas6/7; Ballesta/Alquimista/Excavador aún candidatos. B-22 no está cerrado.
**Abierto: análisis preliminar entregado en M36 (T181).** Entrega en [`B22-contenido.md`](../art/redesign-m36/B22-contenido.md). Faltan decisiones de Lucas y profundizar/validar la opción elegida antes de producción; no se integró esa mecánica. El estudio rápido no constituye un diseño definitivo. El texto siguiente registra el alcance original.
**Pedido original de análisis; producción pendiente de selección:** Proponer2–3 candidatos de torretas y2–3 de monstruos (confirmar la selección final), con papel táctico distinto, estética, contramedida, costo de implementación y nivel de aparición/desbloqueo. Mantener la temática de monstruos. Considerar Excavador/Ladrón del B-07 y las variantes B de Bestia/Tanque que Lucas reservó para futuro, evitando duplicar funciones existentes. Comparar habilitación por nivel con desbloqueo persistente; contemplar Wiki, presentación, progreso y balance. El Mortero ya tiene disponibilidad reservada para el nivel10 (RF-300); no tratarlo como contenido nuevo. **Entrega futura:** tabla comparativa y recomendación, sin depender de completar ahora los niveles8–10.

### B-23 · Combinar ataques de torres vecinas desde mejoras2/3
**Abierto: análisis preliminar entregado en M36 (T181).** Entrega en [`B23-vecindad.md`](../art/redesign-m36/B23-vecindad.md). Faltan decisiones de Lucas y profundizar/validar la opción elegida antes de producción; no se integró esa mecánica. El estudio rápido no constituye un diseño definitivo. El texto siguiente registra el alcance original.
**Pedido original de análisis:** Extiende la propuesta B1 de §5.8 y B-16.C, todavía sin implementar. Investigar combinaciones de ataques entre torres cercanas, habilitadas recién desde nivel de **mejora de torre2 o3** (distinto del número de nivel de campaña). Decidir si ambas torres deben alcanzar el mínimo, qué pares califican y si el efecto combinado reemplaza o suma al ataque normal. Comparar requisito2 frente a3, legibilidad de vínculos/vista previa y respuesta al mejorar, vender o aturdir una vecina; medir balance y rendimiento. Conservar separadas las reacciones por estado existentes de M20, que ya funcionan sin vecindad. **Entrega futura:** pocas recetas propuestas, reglas de activación y prueba de balance; sin cambiar las reglas actuales hasta aprobación.

### Ampliación del backlog · Lucas, 2026-10-02
B-24 a B-27: **completados en M36 (T181), autorizados por Lucas el2026-10-03**. B-28 completado en M35 (T180, RF-349), autorizado por Lucas el2026-10-03. Complementan la renovación visual actual; B-19 sigue completo para los submenús y B-28 cubre el panel de torre en partida que no formó parte de esa tarea.

### B-24 · ~~Renovar los assets de muerte de enemigos~~
**Completado en M36 (T181, Lucas, 2026-10-03).** Capturas y detalles en `art/redesign-m36/`; reglas de combate conservadas. El texto siguiente registra el pedido original.
Volver a generar los efectos/poses de muerte, que quedaron desactualizados frente a los monstruos renderizados y sus ciclos M31. Relevar lo existente y definir si conviene un efecto común con variantes o ciclos propios por criatura; conservar identidad, escala, apoyo y claridad cuando mueren varios juntos. **Entrega futura:** muestras de muertes en combate y cobertura del bestiario. No alterar momento de muerte, recompensa, salida de crías ni desaparición lógica; respetar pausa/velocidad y límites de efectos simultáneos.

### B-25 · ~~Rediseñar rebote y aturdimiento del Espejo~~
**Completado en M36 (T181, Lucas, 2026-10-03).** Capturas y detalles en `art/redesign-m36/`; reglas de combate conservadas. El texto siguiente registra el pedido original.
Renovar el efecto que Lucas describe como «letargo»: corresponde al **aturdimiento de la torre** después de que el Espejo rebota un ataque (RF-280/RF-284), no a la ralentización del enemigo. Revisar destello de rebote, aviso y efecto sobre la torre apagada para que se entienda origen, estado y recuperación, con la estética actual. Evaluar coherencia con el aturdimiento del Chamán, que comparte el estado. **Entrega futura:** comparación visual en partida, sin modificar alcance, duración ni reglas del rebote.

### B-26 · ~~Rediseñar la curación del Curandero~~
**Completado en M36 (T181, Lucas, 2026-10-03).** Capturas y detalles en `art/redesign-m36/`; reglas de combate conservadas. El texto siguiente registra el pedido original.
Mejorar aura e indicación de curación sobre los enemigos afectados: un efecto orgánico y coherente con el monstruo, visible sin tapar cuerpos, barras o caminos. Distinguir alcance del aura y curación efectiva; evaluar coherencia con la regeneración del Troll. **Entrega futura:** muestra con varios enemigos, pausa y fuego que impide la cura. Conservar porcentajes, radio y reglas actuales, con costo de dibujo acotado.

### B-27 · ~~Mejorar música y efectos de sonido~~
**Completado en M36 (T181, Lucas, 2026-10-03).** Capturas y detalles en `art/redesign-m36/`; reglas de combate conservadas. El texto siguiente registra el pedido original.
Relevar música y efectos actuales; mejorar o rediseñar su calidad y coherencia con Monsters & Canons. Evaluar música de menú/partida y señales de disparos, impactos, muerte, mejora, rebote, curación, combos, victoria/derrota e interfaz; priorizar según el relevamiento. Evitar fatiga y saturación con muchos ataques, equilibrar volúmenes y conservar controles de Opciones. **Entrega futura:** muestras de audio y propuesta de mezcla/variantes antes de reemplazar archivos; registrar procedencia/licencia de los recursos elegidos. No generar ni integrar audio en esta tarea de registro.

### B-28 · ~~Renovar el panel de información y mejoras de torre~~
Rediseñar el panel en partida de la captura de Lucas (Ráfaga · Nivel2): título/nivel, daño, cadencia, alcance, descripción, capacidad contra voladores, selector de apuntado, Mejorar y Vender. Aplicar hierro/bronce y mejor jerarquía/agrupación, fondo legible y compacto, sin tapar más partida. Mantener precios, devolución, atajos U/S, estados sin oro/nivel máximo/aturdida y datos de sinergias. **Entrega futura:** muestras con torres de niveles1–3 y textos cortos/largos; verificar foco, controles y tamaños soportados. Relacionado con B-20 (marcas visuales del nivel), pero independiente de cambiar los assets de torre.

### B-29 · Wiki de mods
**Separado de B-15 por Lucas, 2026-10-03 (D-063). Sin fecha.** Cuando existan paquetes de mods completos (B-04), mostrar en la Wiki sus torres y enemigos, identificando el paquete de origen. Definir carga y actualización de entradas, compatibilidad y descubrimiento del bestiario. Esta entrada documenta contenido instalado; no duplica el sistema de instalación, validación ni formato de mods de B-04.

### B-30 · Wiki de mapas de la comunidad
**Separado de B-15 por Lucas, 2026-10-03 (D-063). Sin fecha.** Evaluar una categoría dedicada a mapas comunitarios instalados, con información útil que no repita la selección de mapas. La carga y validación de mapas ya existen desde M10 (§10.4, B-04); esta entrada no implica crear un servicio online, publicación ni otro editor. Definir primero qué información agrega y cómo se mantiene al importar o quitar mapas.

### Estado depurado del backlog · Lucas, 2026-10-03
B-02 cerrado; B-15 retirado/dividido. B-17 a B-20 y B-24 a B-28 implementados. B-21/B-22/B-23 siguen abiertos: informes preliminares entregados, sin decisión ni validación definitiva de producción. B-21 quedó resuelto (D-075): el 3D pasa a *Monsters & Canons 3D* (B-32).

### B-31 · Rediseño visual de Mecánico, Embestidor, Ladrón y Curandero
**Pedido de Lucas, 2026-10-04. Producción integrada en T189 (M43), aprobada visualmente por Lucas el 2026-10-04. B-31 cerrado.**
- Mecánico: reemplazar la estatua vectorial inicial por un diseño con volumen, materiales y calidad acordes a los cañones; actualmente parece de otro juego. Mantener identidad de ingeniería, apoyo y reparación.
- Embestidor: rediseñar silueta y crear sprites/poses que transmitan fuerza e impulso frontal; abandonar la apariencia actual de dinosaurio rápido. Evaluar el Curandero actual como referencia/base del Embestidor, comparando ambos a escala real antes de reasignar sprites.
- Curandero: si se reutiliza su aspecto para Embestidor, crear un nuevo monstruo que comunique curación con anatomía, objeto o gesto propio, además del aura; conservar rol/habilidad. La reasignación es una propuesta a evaluar, no un intercambio ya aplicado.
- Ladrón: crear un asset de la calidad del resto del bestiario, con bolsa/robo reconocibles y sprites coherentes con caminar/estados; reemplazar el vector inicial.
**Aceptación:** revisar siluetas juntas en mapa y Wiki, materiales/luz/escala/estados, poses direccionales y movimiento; distinguir carga, robo y cura sin depender del texto. Mantener mecánicas y datos de balance. B-02 permanece cerrado: este es un pendiente concreto nuevo, ligado a B-07/B-22.

### B-32 · Monsters & Canons 3D (segunda entrega)
**Idea de Lucas, 2026-10-07 (D-075). Proyecto aparte; arranca después de cerrar lo pendiente de la V1.** Llevar el juego al 3D conservando lo de la V1 (monstruos, torres, habilidades, sistemas, Wiki, modo de pruebas y forma de trabajar), con PC como desarrollo principal y celular como segundo desarrollo cuidado, y cámara no fija. Sirve de campo de pruebas para aprender 3D antes de una eventual *Monsters & Canons 2*, que no se planifica. El lore de la V1 (B-03) es la base de la saga. Concepto, evidencia, relevamiento de lo pendiente en la V1 y plan por hitos en [`06-monsters-canons-3d.md`](06-monsters-canons-3d.md). No agrega requisitos a la V1: lo que el documento propone hacer antes en la V1 (por ejemplo, la colina de B-08 o los puentes de B-09) se decide ítem por ítem.

Otros pendientes: prueba chica de modos (B-05; Épocas pasó a M&C 3D/M&C 2, D-076), lore (B-03), mods completos (resto de B-04), Excavador y eventual vida/destrucción/economía de torres (resto de B-07, candidatos relacionados con B-22; Ladrón y Embestidor/desgaste/reparación implementados en M39–M41), decoración manual/terrenos con efectos y temas/leyenda en el editor (resto de B-08, T128), cruces/rutas explícitas (resto de B-09), campaña/dificultades (B-10, prioridad baja), compartir mapas como texto (B-11), mapas al azar/desafíos (B-12), app única con admin (B-13), daño elemental/armadura (B-14), fusiones (resto de B-16; vecindad se sigue en B-23), Wiki de mods (B-29) y de comunidad (B-30). B-06 ya está implementado en M18; leyenda/temas del formato y tamaño variable de B-08 están implementados en M15/M13; aviso de atajos B-09 está hecho en M9. No contarlos nuevamente como pendientes. Las sugerencias no autorizadas permanecen separadas y no son tareas comprometidas.

## 14. Arte de torres con volumen (M23, pedido por Lucas, 2026-10-02)

- **RF-326** Las nueve torres usan la dirección artística elegida: cañón y mortero de hierro, bronce y madera (A); básica, francotirador, fuego, múltiple y ráfaga industriales (B); hielo y Tesla arcanas (C). Comparten perspectiva elevada, luz desde arriba a la izquierda y proporciones legibles a 64 px y 34 px.
  **Aceptación:** dado el grupo completo, cuando se ve en el mapa, HUD y Wiki, entonces cada mecanismo se reconoce y conserva el material y volumen de las muestras aprobadas.
- **RF-327** Al apuntar, la torreta conserva la vertical y la iluminación del mundo. Usa ocho vistas direccionales; la base permanece fija. Retroceso, pausa, mejoras y destello siguen funcionando. Sin atlas, conserva la compatibilidad con dibujos de una sola vista y formas geométricas.
  **Aceptación:** dada una torre con atlas, cuando apunta en las ocho direcciones y cruza el límite entre 0 y 360 grados, entonces usa el cuadro correcto sin girar su luz; sin atlas, el dibujo anterior funciona.
- **RF-328** Las bases muestran tres niveles de construcción con piedra, metal y detalles dorados. Los proyectiles y efectos de impacto acompañan las tres familias y mantienen la lectura de fuego, frío, electricidad y explosión.
  **Aceptación:** dada una partida con las nueve torres, cuando construyen, mejoran y disparan, entonces los dibujos importan, quedan centrados y los efectos se liberan al terminar; daño, precios, alcance y tiempos de balance no cambian.

Los PNG con transparencia se permiten para conservar la calidad de las muestras 3D; los SVG siguen siendo válidos para arte existente y mods. Enemigos, terreno y decoración requieren una revisión posterior específica; esta entrega cubre torres, bases, disparos y sus efectos.

## 15. Monstruos y menú con el nuevo arte (M24, pedido por Lucas, 2026-10-02)

Lucas eligió entre las propuestas de la tanda 1 (`art/redesign-m24/`): **Normal = diablillo rojo** (`normal_B`), **Rápido = bestia turquesa** (`fast_A`), **Tanque = ogro de piedra y piel verde** (`tank_A`) y el logo **Monsters & Canons** (`logo_corrected`). `normal_A` se descarta; `fast_B` y `tank_B` quedan como conceptos para enemigos futuros y **no** se integran. No cambia ningún número de balance, habilidad, ruta ni colisión.

- **RF-329** Normal, Rápido y Tanque usan las copias de producción de los monstruos aprobados, con su transparencia, a la misma escala visual que sus dibujos anteriores y con los pies apoyados siempre a la misma altura del lienzo (sobre la sombra del suelo). Se ven igual en la partida, la Wiki, "Próxima oleada" y la presentación de enemigos. Sus IDs, vida, velocidad, armadura, recompensa y tamaño (`size_tiles`, que fija colisiones y selección) no cambian.
  **Aceptación:** dado un Normal, un Rápido y un Tanque, cuando caminan, reciben un golpe, se ralentizan o se queman, entonces se ve el monstruo nuevo con el parpadeo blanco en su silueta, el tinte celeste y la mancha de escarcha, las llamitas, la barra de vida y (el Tanque) la corona en su lugar de siempre; y los datos de los tres, salvo el dibujo, son los mismos que antes.
- **RF-330** Los PNG de esta tanda son **conceptos estáticos de una sola vista** (la luz viene de arriba a la izquierda): no son atlas y no tienen cuadros de animación. Por eso estos enemigos **no se dan vuelta en espejo** al caminar hacia la izquierda (un espejo pasaría la luz a la derecha): mantienen siempre la misma vista y conservan el bamboleo de caminar (estirarse y aplastarse). Un dato nuevo `flip_when_walking_left` (por defecto sí) lo decide por enemigo: los tres de esta tanda lo apagan; los demás enemigos siguen como antes.
  **Aceptación:** dado un enemigo de esta tanda, cuando camina hacia la izquierda, entonces su dibujo no se refleja; dado un enemigo con `flip_when_walking_left` encendido, se refleja como hasta ahora.
- **RF-331** El menú principal muestra el logo **Monsters & Canons** en lugar de "JuegoA" y "Tower Defense". El logo conserva su proporción, se achica si la ventana es baja para que todos los botones sigan a la vista, y no tapa los controles.
  **Aceptación:** dada la ventana del juego (1280×720 lógicos, que `canvas_items` escala a cualquier tamaño), cuando se abre el menú, entonces se ve el logo entero y los seis botones (cinco si no hay editor) sin recortes ni superposiciones.
- **RF-332** Los botones del menú principal tienen un acabado de **hierro oscuro con borde de bronce y relieve discreto**, y un **acento ámbar** al pasar el mouse o recibir el foco del teclado. Los textos siguen legibles (contraste suficiente), se navega con las flechas y Enter, y los botones se adaptan al ancho disponible.
  **Aceptación:** dado el menú, cuando el mouse pasa sobre un botón o el teclado lo enfoca, entonces el botón se ve distinto de los demás (borde y texto ámbar); el texto de todos los botones tiene un contraste mínimo de 4,5:1 contra su fondo.
- **RF-333** Las **evoluciones** de torres de `upgrades_comparison.png` (Cañón e Hielo en tres niveles) son referencias de **una sola dirección**: **no se integran** todavía, porque las torres apuntan con ocho vistas (RF-327) y esas hojas no las tienen. El nivel 1 conserva el atlas aprobado en M23. Queda documentado el formato que necesita la siguiente entrega artística (plan §6.20, `art/FORMATO_PROXIMA_ENTREGA_M24.md`).
  **Aceptación:** dado el juego tras esta tanda, entonces las nueve torres siguen usando sus atlas de M23, sin cambios.

- **RF-334** Los siete temas usan los suelos preparados de M26, el camino común y las rocas, árbol, arbusto y puerta nuevos.
  **Aceptación:** dado un mapa en partida, menú o editor, cuando se dibuja, entonces aparecen los nuevos materiales; rutas, casillas construibles, leyendas y selección determinista de objetos conservan su comportamiento.

### M27 · Evoluciones y monstruos especiales
- **RF-335** Las evoluciones conservan los mecanismos de nivel 1 y diferencian niveles 2 y 3 con refuerzos, materiales y brillos localizados.
  **Aceptación:** dados los nueve tipos de torre, cuando se revisa la entrega, entonces cada nivel tiene ocho vistas en el orden de M23, icono hacia arriba y margen transparente; el nivel 1 y el balance permanecen intactos.
- **RF-336** Guardián, Curandero, Chamán, Espejo y Jefe reciben conceptos renderizados dentro de la temática de monstruos y con siluetas propias de su función.
  **Aceptación:** dados los cinco diseños, cuando se presentan a escala de juego, entonces sus cuerpos son legibles, tienen transparencia real y la misma luz que los monstruos aprobados; no se cambia ninguna habilidad.

- **RF-337** La partida usa los atlas M27 al mejorar las nueve torres a niveles 2/3 y los cinco especiales aprobados.
  **Aceptación:** dada una mejora, el mecanismo cambia al atlas del nivel conservando ocho direcciones y retroceso; sin atlas de nivel se usa el original. Los cinco especiales conservan habilidades, tamaño y efectos y no se reflejan en espejo.

### M28 · Muestras de legibilidad y presentación
- **RF-338** Antes de cambiar producción se comparan pendientes de migración, tamaños visuales, movimiento y encastre de torretas; Windows/Linux cuentan con una muestra a1920×1080.
  **Aceptación:** dadas las muestras, Lucas puede comparar el estado actual y las alternativas con PNG/GIF y criterios explícitos; no se modifican escenas, datos o resolución de producción hasta su aprobación.

### M29 · Integración aprobada de las muestras M28
- **RF-339** Los trece enemigos usan los diseños renderizados aprobados y un aumento visual del 20 %, independiente de su radio lógico. Los tres ciclos M25 caminan en cuatro direcciones por distancia recorrida; el volador usa cuatro poses de aleteo. Los otros nueve conservan su pose sin aplastamiento global.
  **Aceptación:** dado un enemigo ralentizado, el paso acompaña su desplazamiento; al pausar no avanzan las poses. Vida, velocidad, selección, colisión y habilidades conservan sus cifras. Los pies de los terrestres conservan la línea de apoyo y la barra de vida queda sobre el cuerpo.
- **RF-340** Las nueve torres adoptan el encastre C: asiento reforzado, contacto con la base fija y mecanismo móvil; el cañón cuenta con ocho vistas por nivel del montaje nuevo.
  **Aceptación:** al apuntar y retroceder, la base queda fija y los tres niveles conservan su identidad, huella y reglas. El icono de construcción utiliza el mismo encastre que la partida.
- **RF-341** Windows y Linux usan una ventana inicial Full HD (1920×1080), con lienzo lógico 1280×720 y ajuste a pantallas menores. Celular conserva el tamaño y orientación existentes.
  **Aceptación:** dado un escritorio Full HD, el mapa y la interfaz se escalan juntos sin casillas nuevas ni recortes; una pantalla menor recibe una ventana que cabe en el área disponible.

### M30 · Lectura programática de mejoras
- **RF-342** Las nueve torres distinguen sus mejoras con reflejos aditivos localizados: nivel1 sin capa extra, nivel2 moderado y nivel3 más intenso. Conservan atlas, luz, dirección, retroceso y encastre. Una torre aturdida apaga el reflejo.
  **Aceptación:** dadas las torres de tres niveles, cuando apuntan o retroceden, entonces el reflejo sigue solo el mecanismo, respeta el alfa y permite distinguir la mejora en partida. Pausa congela su pulso; sombras y reglas permanecen intactas.
- **RF-343** Se registra el estado de animaciones: Normal/Rápido/Tanque tienen ciclos de caminar y Volador aleteo; Blindado/Troll/Araña/Cría/Guardián/Curandero/Chamán/Espejo/Jefe requieren ciclos propios. No se simulan esos ciclos deformando una pose estática.

### M31 · Ciclos completos de monstruos
- **RF-344** Blindado, Troll, Araña, Cría, Guardián, Curandero, Chamán, Espejo y Jefe reciben ciclos propios de cuatro poses en cuatro direcciones, conservando sus diseños aprobados y la luz fija.
  **Aceptación:** dadas las nueve criaturas en partida, cuando caminan o doblan, entonces se selecciona su pose direccional por distancia; pies anclados, cuerpo legible con el20% aprobado, sin reflejar luz o deformar el sprite globalmente. Ralentización y pausa detienen/reducen los pasos; regeneración, crías, auras, hechizo, rebote y resistencia del Jefe conservan sus cifras.

### M32 · HUD y monitor local (B-17/B-18 aprobados por Lucas)
- **RF-345** HUD con iconos y valores sin etiquetas redundantes; significado en ayuda pequeña al pasar el puntero o enfocar. Barra, pausa y pruebas usan hierro/bronce del menú y controles agrupados. Dado el HUD, cuando cambia un valor o se completa una oleada, entonces conserva cifras/estado y muestra el bonus en la ayuda de oleada.
- **RF-346** Mostrar FPS activa un texto sobre la partida sin fondo, independiente del panel, con FPS y ms por cuadro estimados a partir de FPS. Dado el monitor activo, cuando se cierra Pruebas, entonces sigue visible; apagado no actualiza, encendido refresca como máximo dos veces por segundo. Solo métricas locales.

### M33 · Submenús renovados
- **RF-347** Opciones, selección de niveles, Wiki, récords, final, iniciales/Salón de la Fama y editor/diálogos adoptan el tema hierro-bronce sin alterar funciones. Dado un submenú, cuando se abre desde menú o partida, entonces conserva navegación y controles legibles, foco visible y paneles coherentes. Opciones separa sonido y visualización y usa deslizadores/casillas del tema.

### M35 · Panel de torre renovado (B-28, Lucas, 2026-10-03)
- **RF-349** El panel seleccionado usa hierro/bronce, título y nivel, tres cifras agrupadas (daño, cadencia, alcance), descripción, efectos/sinergias y capacidad contra voladores. El contenido largo se desplaza dentro del panel; apuntado, Mejorar y Vender permanecen visibles. Conserva ancho de270 píxeles lógicos, límite inferior sobre la barra de construcción y atajos U/S.
  **Aceptación:** Dada una torre de nivel1–3 con texto corto o largo, cuando se selecciona, mejora, cambia el oro o se aturde, entonces los datos/precios/devolución siguen correctos, el estado es legible, el panel no invade la barra inferior y sus botones tienen foco visible. Sin oro y en nivel máximo se desactiva Mejorar; vender y apuntar conservan sus señales y reglas.

### M36 · Cierre de B-20 a B-27 (Lucas, 2026-10-03)
- **RF-350** Niveles de torre indicados por remaches ámbar encastrados en una placa de la base, legibles sin brillo animado, también aturdida. Dada cualquier torre nivel1–3, cuando apunta/mejora/se aturde, entonces se cuenta su nivel sin confundirlo con selección, conservando sombras y atlas.
- **RF-351** Rebote del Espejo muestra una trayectoria cristalina desde el enemigo hasta la torre y un destello facetado; torre aturdida tiene aro roto/descargas localizadas, sin oscurecer el cuadrado vacío del sprite. Dado Espejo/Chamán, cuando aturden y termina el estado, entonces origen, estado y recuperación se reconocen y sus duraciones/alcances no cambian.
- **RF-352** Aura de Curandero usa límite verde suave y brotes/luz sobre receptores solo mientras pueden curarse. Dado un receptor herido, cuando recibe cura efectiva se muestra un pulso; a vida completa o quemado no se indica cura activa. Regeneración del Troll comparte el pulso, no el aura. Radio, porcentajes y bloqueo por fuego intactos.
- **RF-353** Muertes usan la pose renderizada actual como residuo breve desintegrado y fragmentos facetados propios del color del enemigo. Dado cualquier especie, cuando muere entonces desaparece lógicamente y recompensa/crías ocurren como antes; residuo solo visual, sin colisión, respeta pausa/velocidad, se libera y tiene tope. Escapar o desaparecer por administración no produce muerte.
- **RF-354** Música de menú y combate diferenciadas, síntesis original reproducible y efectos suavizados sin recorte digital. Disparo/impacto/rebote/hechizo/cura tienen señales propias; límites de voces/repetición y mezcla atenúan disparos para conservar avisos. Dado un cambio de pantalla, entonces se elige la música correspondiente sin reiniciar la misma pista; opciones de buses permanecen y se documenta procedencia.
- **RF-355** Investigación B-21 entrega tres muestras del mismo mapa (relieve2D, oblicua2D y suelo3D/sprites) con costos/riesgos y recomendación. Ningún prototipo modifica producción, mapas ni guardados; migración exige PR separado y aprobación de merge.
- **RF-356** Análisis B-22 entrega2–3 torres y2–3 monstruos candidatos con función, contramedida, arte, costo y aparición/desbloqueo, comparando desbloqueo persistente y por nivel. No integra nuevos datos de producción.
- **RF-357** Análisis B-23 entrega pocas recetas de vecindad, reglas de mejora2/3, venta/aturdimiento y ensayo reproducible de balance/costo. Conserva las reacciones M20 actuales; no activa recetas nuevas en producción.

### M37 · Avances y Estandarte, primera etapa de B-07/B-22
Lucas, 2026-10-03. Disponibilidad por nivel, con colección persistente como condición adicional para estandartes. Primera entrega: avances y apoyo de cadencia; ampliada con Ladrón, Embestidor/desgaste y reparación en M39–M41.
- **RF-358** Colección genérica por id, con fuentes únicas: un avance plateado por cada nivel oficial1–5, total5. Dado un nivel con avance pendiente, al comenzar se elige al azar un enemigo original de sus oleadas como portador; cuando muere entrega el avance automáticamente. Si escapa, se puede rejugar el nivel. Crías/admin/comunidad/editor no generan avances; niveles sin fuente no generan drops. No altera oro, daño, oleadas ni balance1–5.
- **RF-359** El avance recogido queda pendiente hasta completar su oleada. Dada una derrota posterior o victoria, se conserva; derrota durante esa oleada no lo conserva. Abandonar/reintentar/cerrar antes del resultado descarta los avances de esa partida, incluso si la oleada terminó. El guardado es aditivo y compatible con versión1; no se conceden avances retrospectivos por victorias viejas.
- **RF-360** Estandarte mecánico reservado disponible desde nivel6 cuando el nivel lo permita y existan5 avances distintos. Dada una colección incompleta no puede construirse; con5 y sin disponibilidad tampoco. Niveles1–5 no lo permiten. Admin tiene habilitación explícita de estandartes sin reunir avances, aplicable al nivel actual y sin escribir colección/progreso normal.
- **RF-361** Torre de apoyo sin disparos: radio2/2,5/3 y cadencia extra10/15/20%, costos120/100/160 como valores iniciales en datos. Dadas varias auras solo vale la mayor; no potencia a sí misma ni a otras torres de apoyo; venta, mejora y aturdimiento actualizan el efecto. Pausa/velocidad respetadas. UI/Wiki distinguen apoyo de daño, alcance del aura y condición de colección. Icono de avance genérico plateado y estatua de engranaje/casco, diseño inicial revisable por Lucas.

### Etapas siguientes de B-07/B-22 · dirección aprobada, producción pendiente
**Campaña base objetivo:15 niveles**, no15 niveles ya implementados. Básico1–5, introducción y pruebas6–7 (énfasis7), mayor presencia8–9, combinación avanzada10–14 por diseñar, cierre definitivo15. Los nuevos ataques/desgaste/robo no se introducen en1–5. El drop de avance allí es una recompensa sin dificultad adicional. Los niveles oficiales actuales siguen siendo1–7.
1. **Ladrón:** aparición aleatoria acotada en oleadas autorizadas avanzadas, robo periódico de oro mientras está vivo/en pantalla; monto/intervalo por datos (semilla3 cada2s), piso10. Si vuelve a entrar oro, el robo continúa; muerte/salida lo corta, pausa congela el reloj. No roba al escapar además del efecto periódico. Definir balance y máximo de ladrones por oleada antes de activarlo.
2. **Embestidor:** carga al recorrer una recta; solo embiste torres cercanas al camino en el extremo final de esa recta. No afecta torres alejadas ni cualquiera a mitad del tramo. Hielo/daño antes de la carga son respuestas. Desgaste reparable reduce funcionamiento, no destruye torres. Definir geometría, límites, cadencia de impactos y señalización con prototipo6/7 antes de8/9.
3. **Reparación:** segunda etapa del Estandarte mecánico, sobre un sistema genérico de estados/desgaste para futuras torres de apoyo; aún no implementada. Registrar como alternativa futura vida/destrucción/reconstrucción de torres, reparación paga, nueva economía/interfaz y rebalanceo completo. No activar esa alternativa en esta etapa.
Excavador/Ballesta/Alquimista siguen candidatos sin selección. B-21/B-23 no se cierran con esta etapa; B-22 sigue abierto para siguientes piezas y balance avanzado.

### M38 · Avances en la barra superior
- **RF-362** Dada cualquier partida, cuando cambia la colección, entonces la barra superior muestra icono plateado + cantidad/objetivo, con el mismo tamaño/formato de las otras estadísticas. El icono ofrece ayuda por puntero/foco con estado pendiente/confirmado; se retira el aviso fijo sobre el mapa. Recogida, confirmación y guardado conservan RF-358/359. Admin/comunidad muestran la colección pero no generan avances.

### M39 · Ladrón periódico (B-07/B-22)
- **RF-363** Dado un enemigo con drenaje configurado, mientras permanece vivo en el camino solicita oro cada intervalo de tiempo de juego. El Ladrón roba3 cada2s, sin bajar de10; con menos oro no crea ni quita monedas. Un ingreso posterior vuelve a ser robable en el próximo intervalo. Morir, desaparecer, escapar o terminar la partida corta el drenaje; pausa congela y velocidad acelera el reloj. No hay robo adicional al escapar. Valores y habilidad combinables viven en EnemyData.
- **RF-364** Los grupos aceptan probabilidad opcional0–1 (por defecto1), sorteada una vez al iniciar la oleada. Dado un grupo omitido, no mantiene la oleada abierta. Ladrón: máximo uno por oleada sorteada, incluso con grupos duplicados; nivel6 oleada9 al25%, nivel7 oleadas7/12/17 al35%. Niveles1–5 intactos. El editor conserva y permite editar la probabilidad; Wiki, intro y pruebas administrativas descubren el nuevo dato. Son semillas de balance, no ajuste definitivo.
- **RF-365** Cuando se roba oro efectivo, la barra actualiza y aparece un aviso ámbar en el Ladrón; no anuncia robos cuando se alcanzó el piso. Arte inicial revisable: pequeño monstruo encapuchado con bolsa; no se considera arte final aprobado.


### M40 · Embestidor y desgaste reparable
- **RF-366** Dado un Embestidor que recorre3 casillas seguidas sin ralentización fuerte en una recta, entonces acelera×1.8 hasta el giro/salida. Al cruzar el extremo de esa recta puede golpear una sola torre cuyo centro esté a1.25 casillas o menos del extremo. Rectas cortas, torres lejanas o situadas en el medio de la recta no reciben impacto. Cada extremo se evalúa una vez; no hay ataques periódicos alrededor del enemigo. Ralentización mayor al20% interrumpe la preparación e impide la carga mientras dure. El reloj/distancia respetan pausa y velocidad.
- **RF-367** Un impacto añade20 puntos porcentuales de desgaste, con tope global50; cadencia efectiva = cadencia con apoyo×(1−desgaste/100). No destruye ni elimina torres; stun sigue siendo otro estado. Mejorar no borra desgaste, vender conserva devolución normal. Los apoyos desgastados también reducen sus prestaciones proporcionalmente. Sin impactos previos no cambia nada. El panel distingue desgaste/aturdimiento, muestra cadencia efectiva y una marca ámbar sobre la base indica daño reparable.
- **RF-368** Embestidor se ensaya en nivel6 oleada10 y nivel7 oleadas9/14/18, uno por grupo, sin modificar1–5. Disponibilidad por nivel: ningún desbloqueo persistente de enemigos. Diseño inicial basado en Bestia B reservada por Lucas, sin nuevos atlas aprobados; carga/impacto tienen avisos programáticos. Balance avanzado8/9 y10–15 pendiente de esos niveles.


### M41 · Reparación del Mecánico y validación conjunta
- **RF-369** Dada una torre desgastada dentro del alcance de un Mecánico activo, recupera2/3/4 puntos porcentuales por segundo según nivel del Mecánico, gratis y sin superar estado sano. Solo aplica la tasa más fuerte, no suma Mecánicos. Aturdir/vender el reparador corta su efecto; pausa congela y velocidad acelera reparación. El reparador no se repara a sí mismo, pero otro puede repararlo. Su desgaste reduce tanto bonus de cadencia como tasa reparadora. Reparar no acorta stun; mejorar conserva desgaste. Torres sin desgaste no reciben cura ni avisos falsos.
- **RF-370** Panel/Wiki/ayuda de construcción explican apoyo y reparación desde datos, cadencia efectiva incluye desgaste y apoyo. Una marca ámbar de desgaste disminuye hasta desaparecer; mientras recibe reparación aparece un pequeño indicador cian junto a la base, distinto de la curación verde de enemigos. Los tres niveles del Mecánico mantienen costos120/100/160 y rangos2/2.5/3; pruebas administrativas habilitan sin colección. Verificar integración6/7, estabilidad de1–5, pruebas completas y exportación Windows/Linux. Balance y arte se declaran iniciales, no definitivos.


### M42 · Selector de enemigos en Pruebas
- **RF-371** Dada la lista de enemigos de Pruebas, cuando se abre por clic, entonces el desplegable tiene altura limitada y desplazamiento interno, fondo opaco y resaltado sin sombra recortada; permanece dentro de la ventana. Todos los enemigos siguen accesibles, incluyendo al aumentar el catálogo.
- **RF-372** Dado el puntero sobre el selector cerrado, cuando gira la rueda arriba/abajo, entonces elige anterior/siguiente sin abrir ni invocar; se detiene en primer/último elemento. Clic conserva lista completa y selección normal; Aparecer usa el elegido. La rueda fuera del selector no modifica la selección.


### M43 · Producción visual B-31
- **RF-373** Dado Embestidor, cuando camina o carga, entonces usa sprites con cuatro direcciones y cuatro fases, cabeza reforzada baja y cuerpo robusto inspirado en el Curandero anterior, sin bulbo de cura. El ciclo sigue distancia recorrida y la carga existente acelera su paso.
- **RF-374** Dado Curandero, cuando se ve en mapa y Wiki, entonces se distingue por silueta erguida y herramienta/semilla medicinal; mantiene cura, aura y balance. Tiene cuatro direcciones por cuatro fases, sin reflejar la luz.
- **RF-375** Dado Ladrón y Mecánico, cuando se ven junto al bestiario/cañones, entonces usan PNG renderizados con materiales y luz compatibles: bolsa/robo en Ladrón y casco/engranaje en estatua fija de Mecánico. No cambian lógica, economía ni bases.
- **RF-376** Dados los nuevos assets, cuando se importan, entonces tienen alfa real, márgenes y anclajes estables, poses completas y capturas a escala de juego/Wiki. Se conservan fuentes y prompts reproducibles. Lucas aprobó visualmente los cuatro diseños el 2026-10-04; B31 cerrado.


### M44 · Cierre de reparación
- **RF-377** Dada una torre reparada en pasos pequeños, cuando el desgaste restante llega al cero aproximado de coma flotante, entonces se fija desgaste0, se limpia tasa/indicador de reparación y termina el efecto. No queda un residuo positivo invisible; la última variación conserva señal y no cambia tasas/costos.

### M45 · Campaña8/9
- **RF-378** Dada la campaña completada hasta7, cuando se continúa, entonces se puede jugar8 y9 en orden.8 presenta Guardián y9 Curandero junto al Guardián según D041, sin alterar niveles1–7 ni estadísticas globales.
- **RF-379** Dados los mapas8/9, cuando aparece un Embestidor, entonces existen extremos de rectas de al menos tres casillas con posiciones construibles a distancia de impacto y una posición distinta para apoyo dentro de radio. Los encuentros iniciales de Ladrón/Embestidor son separados; aparecen después de una preparación ofensiva y se combinan más tarde. Cada grupo opcional del Ladrón tiene cantidad1/probabilidad y el Mecánico requiere colección5 más permiso del nivel; no se agregan avances fuera de1–5.
- **RF-380** Dados8/9, cuando se valida su primera versión, entonces carga/recorridos/campaña/progresión y composición se prueban, se comparan bots reproducibles con/sin mejoras/apoyo en varias semillas y se conserva evidencia de exposición y sesiones. Balance humano pendiente se informa explícitamente. No generar EXE/APK en esta etapa por instrucción de Lucas.

- **RF-381** Dado un guardado de campaña anterior que completó el antiguo último nivel, cuando se amplía la campaña, entonces la selección permite jugar el siguiente por victoria previa aunque no exista su entrada unlocked en el guardado. No saltea el nivel siguiente sin victoria, no modifica récords ni reescribe el archivo al consultar.

### M46 · Estudio de vista B-21 v2 (Lucas, 2026-10-06)
Lucas pidió revisar de nuevo B-21 con análisis y pruebas, considerando también no aplicarlo. Es una investigación: no cambia el juego.
- **RF-382** Dada la investigación B-21 v2, cuando Lucas la revisa, entonces encuentra cuatro presentaciones de **la misma partida real** (actual; relieve en la misma cuadrícula; oblicua con el suelo al 80 %; maqueta 3D con los dibujos actuales), cada una con captura completa, recorte de detalle de la misma zona y un modo jugable del nivel 1; medidas de tamaño de casilla, superficie del mapa y clics de ida y vuelta en todas las casillas construibles; rendimiento con la carga de P7 en tres rondas; costos, riesgos, límites honestos y una recomendación que incluye no cambiar la vista. Ningún prototipo modifica producción, mapas ni guardados; adoptar una opción requiere decisión de Lucas, y cambiar la proyección, un PR separado marcado como *breaking change*.

### M48 · Modo de pruebas en Opciones, una sola app y licencia (Lucas, 2026-10-07)
Como el juego se va a regalar, no tiene sentido un ejecutable aparte para el modo de pruebas (B-13). Lucas también pidió una licencia libre del tipo GNU 3.0. Reemplaza el "ejecutable aparte" de D-028; el guardado aparte (RF-181) sigue igual.

- **RF-383** **Activar desde Opciones.**
  - **Dado** el menú principal, **cuando** se abre Opciones, **entonces** se ve una sección "Administración" con el botón "Activar modo de pruebas".
  - **Cuando** se lo toca, aparece una confirmación en el mismo panel. Explica que el modo usa un guardado aparte, que abre todos los niveles y herramientas, y que lo que se haga ahí no cuenta para el progreso ni los récords reales. Aceptar activa el modo (guardado aparte, cartel, atajos: RF-181 a RF-184) y rearma el menú principal. Cancelar no cambia nada.
  - Desde el menú de pausa la sección **no aparece**: nunca se cambia de guardado en medio de una partida.
- **RF-384** **Volver al juego normal.**
  - **Dado** el modo de pruebas activo, **cuando** se abre Opciones desde el menú principal, **entonces** el botón dice "Volver al juego normal". Tocarlo vuelve al guardado real sin confirmación y rearma el menú.
  - Mientras el modo de pruebas está activo, el guardado real no se modifica.
- **RF-385** **Siempre arranca normal.**
  - **Dado** cualquier ejecutable o APK, **cuando** se abre el juego, **entonces** arranca en modo normal, aunque se haya cerrado en modo de pruebas. Así nadie cree que perdió su progreso.
  - Excepción para desarrollo: con el argumento `--pruebas` al iniciar, desde el editor de Godot o desde un acceso directo con `-- --pruebas`, arranca ya activado.
- **RF-386** **Una sola exportación por plataforma.**
  - Quedan `JuegoA.exe` (Windows), `JuegoA.x86_64` (Linux) y `JuegoA.apk` (Android).
  - Desaparecen los presets "Windows (pruebas)" y "Android (pruebas)" y la característica de exportación `pruebas`.
  - **Dado** un celular con la APK de pruebas anterior instalada, esa app queda aparte hasta desinstalarla a mano.
- **RF-387** **Licencia libre.**
  - El juego (código, datos, dibujos y sonidos propios) se distribuye gratis bajo la **GNU General Public License, versión 3 o posterior** (GPL-3.0-or-later). El texto oficial completo va en `LICENSE`, en la raíz, y el README tiene una sección "Licencia".
  - **Dada** la Wiki, **cuando** se abre la guía, **entonces** hay un artículo "Licencias" que nombra la licencia del juego y la del motor Godot (MIT, con su aviso de copyright, que tiene que acompañar a los ejecutables). También aclara que GUT, la herramienta de tests (MIT), no va dentro de los ejecutables.

### M49 · Prueba de modos unificada con el gestor de mapas (Lucas, 2026-10-07)
**Estado: hecha en T197 (2026-10-07).** Es la prueba chica de modos de B-05 (D-078). Un modo es un paquete de datos, igual que un mapa de la comunidad pero con varios mapas y reglas. Épocas pasó al otro juego (D-076).

- **RF-388** **Paquete de modo.**
  - Es una carpeta con un `modo.json` y sus mapas JSON (formato §7.8). El `modo.json` lleva versión, nombre, descripción y la lista ordenada de mapas, y como opcionales las torres disponibles y las reglas `oro_inicial_%`, `vidas` y `vida_monstruos_%`.
  - Cada mapa de la lista se busca primero en la carpeta del modo y, si no está, entre los niveles oficiales (`data/levels/`). Así un modo puede reusar mapas de la campaña sin copiarlos *(aclarado en T197)*.
  - Los modos oficiales viven en `res://data/modos/<id>/` y los propios en `user://modos/<id>/`. Un modo propio con el mismo nombre de carpeta que uno oficial se muestra con error, para que sus récords no se mezclen.
  - **Solo datos:** un modo nunca trae código (como RF-204).
  - **Dado** un paquete roto, **cuando** se listan los modos, **entonces** aparece con su motivo y los demás se ven igual (como RF-222).
- **RF-389** **Selección de nivel con modos.**
  - Arriba hay un selector de modo:
    - **Campaña:** la de siempre, sin mover archivos.
    - **Los modos oficiales.**
    - **Comunidad:** los mapas sueltos de `user://maps/`, como hoy.
    - **Los modos propios.**
  - **Cuando** se elige un modo, **entonces** se ven sus mapas en orden, con sus estrellas.
- **RF-390** **Progreso por modo.**
  - Cada mapa de un modo guarda vidas, estrellas, puntaje y top 5 con el id `modo_<modo>_<mapa>`.
  - No cuenta para la campaña, el total de estrellas de la campaña, el Salón de la fama ni la colección de avances.
  - En un modo oficial el primer mapa está abierto y cada uno se habilita al ganar el anterior del mismo modo. En los modos propios, todos están abiertos. El modo de pruebas abre todo (RF-183).
- **RF-391** **Modo oficial de prueba "Asedio".**
  - Son los mapas 1 a 9 de la campaña con sus mismas oleadas y monstruos con más vida. Valor en datos: **vida 115 %**, con el mismo oro, ajustable. *(Ajustado en T197 con el bot: la propuesta inicial de vida 150 % y oro 80 % hacía perder al bot en la oleada 4 de los mapas 1 a 3, y hasta 125 % con el mismo oro perdía temprano. Con 115 % gana el mapa 1 con 3 vidas y el 3 con 6, contra 20 y 18 en la campaña.)*
  - Cubre también los "niveles difíciles" de B-10.
  - **Dado** el bot de balance, **cuando** juega los primeros mapas de Asedio, **entonces** se informa si se pueden ganar. No es balance definitivo.
- **RF-392** **El editor guarda en modos.**
  - "Guardar" sigue como hoy: mapa suelto (Comunidad) o el modo donde ya está el mapa.
  - Nueva acción **"Guardar en un modo…"**: se elige un modo propio existente o uno nuevo (con su nombre) y el nombre del archivo *(aclarado en T197)*.
  - Crear un modo desde el editor arma la carpeta y su `modo.json`; cada mapa nuevo se agrega al final de la lista. Después, "Guardar" sigue guardando en ese modo.
  - Abrir un mapa en el editor lista también los de los modos propios.
  - Nunca toca `data/` ni `campaign.json` (RF-210).
