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

- **RF-40** El jugador elige una torre en la barra inferior (o con las teclas **1–4**). Aparece una **vista previa** de la torre que sigue al mouse, "pegada" a la cuadrícula, mostrando su **círculo de alcance**.
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
- **RF-55** Los proyectiles viajan a **10 casillas por segundo** (todas las torres). Es lo bastante rápido para que casi nunca lleguen tarde, y lo bastante lento para que se vean.

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

**Tabla de mejoras** (solo se indica lo que cambia respecto al nivel anterior):

| Torre | Nivel 2 | Nivel 3 |
|---|---|---|
| Ametralladora | Costo 60 · daño 8 · cadencia 2.5 | Costo 100 · daño 12 · cadencia 3.0 · alcance 3.5 |
| Cañón | Costo 110 · daño 32 · radio 1.2 | Costo 170 · daño 50 · radio 1.5 · alcance 3.5 |
| Hielo | Costo 80 · ralentiza 50 % · alcance 3.0 | Costo 120 · ralentiza 60 % durante 3 s · daño 4 |
| Francotirador | Costo 150 · daño 70 | Costo 225 · daño 120 · alcance 7.0 |

---

## 6. Enemigos

- **RF-80** Cuando un enemigo recibe daño, el daño real es:
  `daño real = máximo(1, daño del golpe − armadura del enemigo)`
  Es decir, la armadura resta, pero **siempre** se hace al menos 1 de daño.
- **RF-81** Cuando la vida llega a 0, el enemigo muere, desaparece y da su oro.
- **RF-82** Cada enemigo muestra una **barra de vida** encima, pero **solo** después de haber recibido daño (para no llenar la pantalla de barras).

> **Criterio de aceptación RF-80**
> **Dado** un Blindado (armadura 4) → **Cuando** le pega una Ametralladora (daño 5) → **Entonces** pierde 1 de vida. **Cuando** le pega un Francotirador (40) → **Entonces** pierde 36.

### Tabla de enemigos

> *Velocidad en casillas por segundo. "Vida" es la vida base (en la oleada 1); después aumenta según RF-36.*

| ID | Nombre | Vida | Velocidad | Armadura | Oro | Vidas que quita | Vuela | Especial | Forma provisional | Hito |
|---|---|---|---|---|---|---|---|---|---|---|
| `normal` | **Normal** | 30 | 1.5 | 0 | 5 | 1 | No | — | Círculo gris | M1 |
| `fast` | **Rápido** | 18 | 3.0 | 0 | 4 | 1 | No | — | Triángulo amarillo | M1 |
| `tank` | **Tanque** | 135 | 0.8 | 0 | 15 | 2 | No | — | Cuadrado marrón, grande | M1 |
| `flyer` | **Volador** | 25 | 2.0 | 0 | 8 | 1 | **Sí** | Vuela en línea recta (RF-05) | Rombo celeste | M2 |
| `armored` | **Blindado** | 45 | 1.2 | 4 | 12 | 1 | No | Armadura alta | Hexágono azul oscuro | M2 |
| `boss` | **Jefe** | 800 | 0.6 | 3 | 150 | 10 | No | Solo le afecta la **mitad** de cualquier ralentización | Círculo rojo, muy grande | M2 |

**Tamaño visual** (radio del dibujo y de la zona que detectan las torres, en casillas): Normal 0.25 · Rápido 0.2 · Tanque 0.35 · Volador 0.25 · Blindado 0.3 · Jefe 0.45. Todos caben dentro de una casilla del camino (radio máximo 0.5).

---

## 7. Niveles

| # | Nombre provisional | Oleadas | Oro inicial | Particularidad | Hito |
|---|---|---|---|---|---|
| 1 | Pradera | 10 | 150 | Un camino en forma de "S". Para aprender. | M1 |
| 2 | Desfiladero | 15 | 200 | Camino largo con muchas curvas cerradas. | M3 |
| 3 | Encrucijada | 20 | 250 | **Dos entradas** cuyos caminos se unen antes de la salida. | M3 |
| 4–5 | *(por definir)* | — | — | — | M4 (opcional) |

### Oleadas del nivel 1

> Formato: `cantidad × tipo (cada X s)`. Los grupos de una misma oleada separados por "+" empiezan a la vez, salvo que se indique "tras N s".

| Oleada | Enemigos |
|---|---|
| 1 | 8 × Normal (cada 1.0 s) |
| 2 | 12 × Normal (cada 0.8 s) |
| 3 | 10 × Rápido (cada 0.6 s) |
| 4 | 10 × Normal (cada 0.8 s) + 6 × Rápido (cada 0.6 s, tras 4 s) |
| 5 | 3 × Tanque (cada 2.0 s) + 10 × Normal (cada 0.7 s, tras 3 s) |
| 6 | 15 × Rápido (cada 0.4 s) |
| 7 | 6 × Tanque (cada 1.5 s) |
| 8 | 20 × Normal (cada 0.5 s) + 10 × Rápido (cada 0.5 s, tras 5 s) |
| 9 | 8 × Tanque (cada 1.5 s) + 15 × Rápido (cada 0.4 s, tras 6 s) |
| 10 | 10 × Tanque (cada 1.2 s) + 20 × Normal (cada 0.4 s, tras 4 s) + 20 × Rápido (cada 0.3 s, tras 10 s) |

### 7.1 Cómo se balanceó el nivel 1 (T25)

El objetivo: **se gana jugando con criterio, pero no sin pensar**. Se comprobó con un bot que juega solo (`tools/balance_sim.gd`, instrucciones dentro del archivo) con tres estrategias:

| Estrategia del bot | Resultado con los números actuales |
|---|---|
| Mezcla torres y las pone donde cubren más camino | Gana con 13 vidas |
| Solo Ametralladoras, bien puestas | Gana con 14 vidas |
| Solo Ametralladoras, en casillas al azar | Pierde en la oleada 8 |

Qué se cambió respecto al borrador y por qué:
- **Con los números originales se ganaba sin perder ni una vida, incluso poniendo torres al azar.** Se subió la vida base ×1,5 (Normal 20 → 30, Rápido 12 → 18, Tanque 90 → 135) y, sobre todo, el aumento por oleada (8 % → **40 %**), para que el final presione aunque el jugador haya acumulado oro.
- **El Cañón rendía casi un tercio que la Ametralladora por cada moneda**, así que no convenía nunca. Su daño subió de 12 a **20** (y sus mejoras en proporción).

Un bot no reemplaza a una persona: estos números se revisan jugando. Cada vez que se cambie el balance, se vuelve a correr el bot y se actualiza esta tabla.

> **Pendiente para M2 (T38):** Volador, Blindado y Jefe todavía tienen los valores del borrador; se balancean al agregarlos.

---

## 8. Ganar y perder

- **RF-90** **Victoria:** se completa la última oleada con al menos 1 vida. Aparece la pantalla **"¡Victoria!"** con las vidas restantes y los botones **Siguiente nivel** *(M3)*, **Reintentar** y **Menú** *(M3)*.
- **RF-91** **Derrota:** las vidas llegan a 0. El juego se detiene y aparece **"Derrota"** con la oleada alcanzada y los botones **Reintentar** y **Menú** *(M3)*.
- **RF-92** **Reintentar** reinicia el nivel desde cero (vidas, oro, oleadas y torres).

---

## 9. Controles e interfaz

### 9.1 HUD (lo que se ve durante la partida)

- **RF-100** Arriba: **oro**, **vidas** y **oleada actual / total** (por ejemplo "Oleada 3/10").
- **RF-101** Abajo: un **botón por torre**, con su forma, nombre y costo. Desactivado (gris) si no alcanza el oro.
- **RF-102** Botón **"Empezar oleada"** que muestra la cuenta atrás entre oleadas y se desactiva durante una oleada.
- **RF-103** *(M2)* Controles de velocidad: **Pausa**, **x1**, **x2**.

### 9.2 Teclado

| Tecla | Acción | Hito |
|---|---|---|
| `1`–`4` | Elegir torre para construir | M1 (1–3), M2 (4) |
| `Esc` | Cancelar construcción / cerrar panel / *(M3)* menú de pausa | M1 |
| `Espacio` | Empezar oleada (si se puede) | M1 |
| `P` | Pausar / reanudar | M2 |
| `F` | Alternar velocidad x1 / x2 | M2 |
| `U` | Mejorar torre seleccionada | M2 |
| `S` | Vender torre seleccionada | M2 |

- **RF-104** *(M2)* **Pausa** detiene todo (enemigos, torres, cuenta atrás), pero se puede seguir mirando el mapa y seleccionar torres. No se puede construir en pausa.

### 9.3 Efectos visuales *(M1.5)*

**Estilo:** se mantiene el **estilo geométrico** (formas y colores planos), pero con vida: movimiento, destellos y partículas. La ambientación sigue abierta (§12); todo lo de aquí sirve igual si más adelante las formas se cambian por dibujos.

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

---

## 10. Pantallas y progreso *(M3)*

- **RF-110** **Menú principal:** Jugar, Opciones, Salir.
- **RF-111** **Selección de nivel:** muestra los niveles. Los bloqueados aparecen con candado. Los completados muestran la mejor cantidad de vidas conseguida.
- **RF-112** Al principio solo está desbloqueado el nivel 1. **Ganar** el nivel N desbloquea el N+1.
- **RF-113** **Opciones:** volumen de música, volumen de efectos, pantalla completa sí/no.
- **RF-114** **Menú de pausa** (con `Esc` durante la partida): Continuar, Reintentar, Opciones, Salir al menú.
- **RF-115** El progreso (niveles desbloqueados, mejores resultados) y las opciones **se guardan automáticamente** y siguen ahí al cerrar y volver a abrir el juego.
- **RF-116** **Sonido básico:** disparo de cada torre, muerte de enemigo, enemigo llega a la salida, victoria, derrota, clic de botón. Una música de fondo.

> **Criterio de aceptación RF-115**
> **Dado** que gané el nivel 1 → **Cuando** cierro el juego y lo vuelvo a abrir → **Entonces** el nivel 2 aparece desbloqueado.

---

## 11. Qué **NO** incluye este juego

Se deja por escrito para no caer en la tentación (constitución P4). Si más adelante se quiere algo de esto, se agrega **primero aquí** como un hito nuevo.

- Multijugador.
- Héroes o unidades controlables.
- Habilidades activas del jugador (lluvia de meteoros, etc.).
- Modo infinito / endless.
- Versión para móvil o controles táctiles.
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
| ¿Ambientación? (medieval, espacial, juguetes…) Afecta nombres de torres/enemigos y el arte. | M4 |
| ¿Estrellas por nivel (1–3 según vidas restantes) en vez de "mejor cantidad de vidas"? | M3 |
| ¿Música: de dónde sale? (propia, gratuita con licencia CC0…) | M3 |
| ¿El aumento de vida por oleada (40 %) debería ser distinto en cada nivel? Con 15–20 oleadas, 40 % da enemigos 7–9 veces más fuertes al final. Quizás convenga mover ese valor de `BalanceConfig` a `LevelData`. | M3 (T43) |
