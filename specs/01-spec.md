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

- **RF-01** El mapa es una **cuadrícula** de **20 columnas × 9 filas**; cada casilla mide 64×64 píxeles (el mapa ocupa 1280×576 y deja espacio arriba y abajo para la interfaz).
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

- **RF-40** El jugador elige una torre en la barra inferior (o con las teclas **1–8**; en M1–M4 eran 1–4). Aparece una **vista previa** de la torre que sigue al mouse, "pegada" a la cuadrícula, mostrando su **círculo de alcance**.
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
- **RF-75** **El nivel se ve:** cada torre muestra puntitos con su nivel (1, 2 o 3) y, al mejorarse, aparece el mismo anillo que al construirla (RF-130).
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

---

## 6. Enemigos

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
| 7 | Cruce | 20 | 300 | **Dos entradas** en lados opuestos y **la salida en el centro** (§7.9). El nivel final. Primero hecho en archivo de texto (§7.8). | M8 |

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

- **RF-200** **El archivo del nivel** es JSON y tiene: `version` (hoy 1), `nombre`, `oro` (inicial), `vidas` (iniciales), `mapa` (9 filas de 20 letras), `oleadas` y, si hace falta, `aumento_vida` (el % de vida extra por oleada de ese nivel, §7.4; si no está, se usa el general). El identificador del nivel (`level_06`) es el nombre del archivo.
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
- **RF-204** **Validación con mensajes claros:** al leer un nivel se comprueba todo lo anterior: que el mapa sea de 20×9 y solo tenga letras conocidas; que haya salida y al menos una entrada; que cada entrada llegue a la salida sin empates; que haya pasto para construir; que el oro, las vidas, las cantidades y los tiempos tengan sentido; que los enemigos existan; que cada grupo use una entrada del mapa, y que no haya **claves mal escritas** (por ejemplo `"canitdad"`). Cada problema se explica en castellano y dice dónde está ("oleada 3, grupo 2: no existe el enemigo 'trol'"). Un nivel inválido **no se juega** y el error queda en el registro; el juego no se cierra.
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
- **RF-170** *(M5)* **Barra para 8 torres:** cada botón muestra el **dibujo** de la torre, su **costo** y, en una esquina, su **tecla**. El nombre no entra: aparece al pasar el mouse por encima y al elegirla (RF-171).
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

Dibujos simples para dejar de ver formas geométricas. Es un **primer intento "para rellenar"**: **no** decide la ambientación (§12; B-01, B-02 y B-03 siguen abiertos) y cada dibujo se puede cambiar sin tocar el código.

**Estilo:** caricatura con colores planos y borde oscuro. Las torres se ven **desde arriba** (así la torreta puede girar); los enemigos, **de costado**, como personajes (así se les ven la cara y las patas).

- **RF-150** **Torres:** cada torre se dibuja con una **base** que muestra su nivel y una **torreta** propia de cada tipo. La torreta es la parte que gira y apunta (RF-120, RF-121). Se mantienen los puntitos de nivel (RF-75).

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

- **RF-110** **Menú principal:** Jugar, Récords *(M6, RF-195)*, Opciones, Salir. Es la primera pantalla al abrir el juego. De fondo se ve el mapa del nivel 1, oscurecido.
- **RF-117** El progreso **solo** se guarda cuando se juega desde el menú. Abrir la partida directamente desde el editor (F6) o correr los tests no toca el guardado del jugador.
- **RF-111** **Selección de nivel:** muestra los niveles. Los bloqueados dicen "Bloqueado". Los completados muestran sus **estrellas** (RF-93) y la mejor cantidad de vidas conseguida. Arriba se ve el **total de estrellas** de la campaña ("Estrellas: 7 de 15").
- **RF-116** *(M9)* **La selección de nivel admite cualquier cantidad de niveles:** las tarjetas se acomodan en **filas de hasta 5**, centradas; se ven **2 filas** y, si hay más, el área **se desplaza** (rueda del mouse, arrastrar con el dedo o las flechas del teclado, que siguen a la tarjeta elegida). Con 5 niveles o menos hay una sola fila. Ningún nivel queda fuera de la pantalla, sin importar cuántos haya.
- **RF-112** Al principio solo está desbloqueado el nivel 1. **Ganar** el nivel N desbloquea el N+1.
- **RF-113** **Opciones:** volumen de música, volumen de efectos, pantalla completa sí/no, **números de daño sí/no** *(M4, RF-132)*.
- **RF-114** **Menú de pausa** (con `Esc` durante la partida): Continuar, Reintentar, Opciones, Salir al menú.
- **RF-115** El progreso (niveles desbloqueados, mejores resultados) y las opciones **se guardan automáticamente** y siguen ahí al cerrar y volver a abrir el juego.
- **RF-116** **Sonido básico:** disparo de cada torre, muerte de enemigo, enemigo llega a la salida, victoria, derrota, clic de botón. Una música de fondo.

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

- **RF-180** **Cómo se activa:** solo existe en el **ejecutable de pruebas** (`JuegoA_pruebas.exe`, del preset de exportación "Windows (pruebas)") y al jugar desde el editor de Godot con el argumento `--pruebas`. El `JuegoA.exe` normal y el `.apk` **no lo tienen**: un jugador normal nunca lo ve.
- **RF-181** **Guardado aparte:** en modo pruebas se usa `save_pruebas.json`. El progreso, las estrellas, los récords y las opciones del guardado real no cambian.
- **RF-182** Siempre se ve un cartel **"MODO PRUEBAS"** en una esquina (en los menús y en la partida), para no confundirlo con el juego normal.
- **RF-183** **Todos los niveles** se pueden elegir, aunque estén bloqueados.
- **RF-184** **Panel de pruebas** en la partida (tecla `F1` o botón "Pruebas" arriba): +1000 de oro · vidas infinitas (sí/no) · saltar oleada · matar a todos los enemigos · ganar · perder · velocidad x4 · hacer aparecer un enemigo de cualquier tipo · mostrar los FPS. Los enemigos que se matan con el panel no dan oro ni puntos.

### 10.3 Editor de mapas *(M9, pedido por Lucas, D-033, B-04 escalón 2)*

Una herramienta de **administración** para crear y probar niveles sin escribir el JSON a mano. Por ahora **solo existe en el modo de pruebas** (§10.2); si más adelante pasa al juego normal, o si se unifica todo en una app con modo admin, se decide aparte (B-13).

- **RF-210** **Dónde está:** el menú principal tiene un botón **"Editor de mapas"** **solo en el modo de pruebas** (RF-180). El `JuegoA.exe` normal y el `.apk` no lo tienen. Usa el guardado aparte de RF-181 y **nunca toca** el progreso, los niveles oficiales (`data/levels/`) ni `campaign.json`.
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
| ¿Ambientación? (medieval, espacial, juguetes…) Afecta nombres de torres/enemigos y el arte. **Candidata fuerte: "Épocas" (§13, B-01).** Se decide junto con el lore (B-03) y el arte (B-02). | M4 |
| ¿Música: de dónde sale? (propia, gratuita con licencia CC0…) | M3 |

---

## 13. Backlog de ideas

Ideas **aprobadas como dirección**, pero **sin fecha**: no se programan hasta convertirse en un hito con sus propias reglas (RF) y tareas. Se anotan aquí para no perderlas ni mezclarlas con el trabajo actual.

### B-01 · Épocas: la guerra evoluciona con el tiempo
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

### B-02 · Diseño de assets (arte)
*Propuesta de Lucas, 2026-09-28. No lo hace Claude: queda para un diseñador o para más adelante.*

**Idea:** reemplazar las formas geométricas por arte dibujado: torres, enemigos, casillas del mapa, efectos, íconos y la interfaz.

**Estado (2026-09-28):** hay un **juego de dibujos provisionales** hecho por Claude (§9.6, D-023) para no seguir con formas geométricas. B-02 sigue abierto: es el arte **definitivo**, que depende de la ambientación. Para cambiar un dibujo, alcanza con reemplazar su archivo en `assets/sprites/` (D-023 explica cómo).

**Qué ya está preparado para que sea fácil:**
- Cada torre y cada enemigo se dibuja en **un solo lugar** (`_draw()` de `tower.gd` y `enemy.gd`), y los datos ya dicen su forma y color (`EnemyData.shape`, `TowerData.color`). Cambiar a imágenes es cambiar ese dibujo, no la lógica.
- Las casillas vienen de `assets/tiles/tiles.png` (64×64) y la decoración de `LevelDecor`.
- La resolución base es 1280×720 y las casillas miden 64×64 px: el arte se hace a esa escala (o al doble, 128×128, para pantallas grandes).

**Lista de piezas** (para cuando se encargue): 4 torres × 3 niveles, 6 enemigos (con su versión "golpeado" y "ralentizado"), casillas (pasto, camino con bordes, roca, puerta de salida), proyectiles e impactos, íconos de la interfaz, ícono del juego, fondo de los menús.

**Depende de:** la ambientación (§12) y, si se elige, de Épocas (B-01): cada época necesitaría su propio juego de piezas.

### B-03 · Lore (la historia del mundo)
*Propuesta de Lucas, 2026-09-28. No lo hace Claude: queda para más adelante.*

**Idea:** darle al juego un mundo y una historia: quiénes defienden, quiénes atacan y por qué, qué es cada nivel (Pradera, Desfiladero, Encrucijada, Espiral, Fortaleza) dentro de ese mundo, y quién es el Jefe.

**Cómo se mostraría** (a decidir): un texto corto al elegir cada nivel, una frase en la pantalla de victoria, nombres temáticos para torres y enemigos.

**Depende de / afecta a:** Épocas (B-01) sería una forma de lore ("la guerra a través del tiempo"); el lore también decide la ambientación y, por lo tanto, el arte (B-02). Conviene definir los tres juntos. Si se agregan textos de historia, hay que sacar "Historia, diálogos o cinemáticas" de la lista de §11 (en todo o en parte).

### B-04 · Crear mapas fácilmente y mods
*Propuesta de Lucas, 2026-09-29. Analizada por Claude. Decisión: D-024. **El escalón 1 se hizo en M7 (§7.8, D-031).** **Prioridad de Lucas (D-033): el editor de mapas (escalón 2) y los mapas de la comunidad (escalón 3, solo la parte de mapas); el editor entra primero en la versión de pruebas, como herramienta de administración.** Sin fecha.*

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

**Relación con otras ideas:** Épocas (B-01) podría armarse como un "paquete" con otras torres, enemigos y dibujos, usando el mismo sistema que los mods. El arte definitivo (B-02) también se beneficia: cambiar dibujos pasaría a ser cambiar archivos.

**Qué cambia en la spec si se hace:** un hito nuevo con sus reglas (RF) y tareas; si se hacen mods, una sección de seguridad (qué puede traer un mod y qué no).

### B-05 · Modos de juego
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

### B-08 · Mapas más ricos: terrenos, temas y tamaño
*Pregunta de Lucas, 2026-09-29 (a raíz de M7). Sin fecha.*

**Hoy:** un mapa dice solo tres cosas por casilla (pasto, camino, bloqueada) y **el dibujo de lo bloqueado lo elige el juego** al azar (roca, árbol, arbusto, RF-154). No se puede pedir "acá va un lago". El tamaño es fijo, 20×9 (RF-01).

**Ideas**, de la más chica a la más grande. Cada una es un campo nuevo y opcional del archivo del nivel, así los niveles que ya existen no cambian:

| Idea | Qué es | Tamaño |
|---|---|---|
| **Leyenda** | El nivel declara letras nuevas y qué son: `"leyenda": {"~": {"dibujo": "agua", "construible": false}}`. Los dibujos son archivos de `assets/sprites/map/` (y en un mod, imágenes propias). Se puede decidir el dibujo de cada casilla. | Chico |
| **Temas** | `"tema": "desierto"` cambia la paleta del pasto y del camino y el conjunto de decoración (nieve, lava, ruinas). | Chico |
| **Decoración a mano** | Una lista de objetos con su posición (un árbol grande en 3,4), sin necesidad de ocupar una casilla entera. | Chico |
| **Terrenos con efecto** | Pantano (los enemigos van más lentos), colina (las torres ganan alcance), terreno rico (construir cuesta menos). Cambian la estrategia y necesitan reglas (RF) y balance. | Mediano |
| **Tamaño variable** | Mapas más grandes que 20×9, con cámara que se desplaza o zoom. Cambia la interfaz, la construcción y los tests. | Grande |

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
