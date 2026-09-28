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

---

## 7. Niveles

| # | Nombre provisional | Oleadas | Oro inicial | Particularidad | Hito |
|---|---|---|---|---|---|
| 1 | Pradera | 10 | 150 | Un camino en forma de "S". Para aprender. | M1 |
| 2 | Desfiladero | 15 | 200 | Zigzag con 8 curvas cerradas (§7.2). | M3 |
| 3 | Encrucijada | 20 | 250 | **Dos entradas** cuyos caminos se unen antes de la salida (§7.3). | M3 |
| 4 | Espiral | 15 | 200 | El camino da vueltas hacia adentro; **la salida está en el centro** (§7.5). | M4 |
| 5 | Fortaleza | 20 | 300 | **Tres entradas**, una desde arriba (§7.6). El nivel final. | M4 |

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


---

## 8. Ganar y perder

- **RF-90** **Victoria:** se completa la última oleada con al menos 1 vida. Aparece la pantalla **"¡Victoria!"** con las vidas restantes y los botones **Siguiente nivel** *(M3, si hay uno)*, **Reintentar** y **Niveles** *(M3: vuelve a la selección de nivel)*.
- **RF-91** **Derrota:** las vidas llegan a 0. El juego se detiene y aparece **"Derrota"** con la oleada alcanzada y los botones **Reintentar** y **Niveles** *(M3)*.
- **RF-92** **Reintentar** reinicia el nivel desde cero (vidas, oro, oleadas y torres).
- **RF-93** *(M4)* **Estrellas:** ganar un nivel da de 1 a 3 estrellas según las vidas que quedan, en porcentaje de las vidas iniciales: **3 estrellas** con el 90 % o más (18 de 20), **2 estrellas** con el 50 % o más (10 de 20), **1 estrella** si se ganó con menos. Los porcentajes están en `balance.tres`. Se muestran en la pantalla de victoria y en la selección de nivel (RF-111). No se guardan aparte: se calculan con la mejor cantidad de vidas, que ya se guarda (RF-115).

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

- **RF-133** **Próxima oleada:** en la barra inferior, entre los botones de torres y "Empezar oleada", se ven los enemigos de la **próxima** oleada: la forma de cada tipo y cuántos son (por ejemplo, "×10"). Se actualiza al empezar cada oleada. En la última oleada ya no hay "próxima" y el espacio queda vacío.
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

- **RF-151** **Enemigos:** cada tipo es un monstruito del **mismo color** que tenía su forma, porque el jugador ya los reconoce por el color. Normal = bichito gris; Rápido = gota amarilla con cresta; Tanque = bestia marrón con colmillo; Volador = murciélago violeta; Blindado = bicho azul con casco y visera; Jefe = demonio rojo con cuernos. **Miran hacia donde caminan:** se dan vuelta al ir hacia la izquierda, y al subir o bajar siguen mirando hacia donde miraban. Se mantienen la sombra, el bamboleo (RF-125), el parpadeo al recibir un golpe (RF-123), la barra de vida (RF-82) y la corona del Jefe (RF-136).
- **RF-152** **Ralentizado** (reemplaza el dibujo de RF-62): el enemigo se tiñe de **celeste** y aparece una **mancha de escarcha** en el piso, debajo de él.
- **RF-153** **Proyectiles:** cada torre dispara su propio proyectil, que **apunta hacia donde viaja**: bala con estela (Ametralladora), bala de cañón (Cañón), cristal de hielo (Hielo) y estela larga (Francotirador).
- **RF-154** **Mapa:** cada casilla bloqueada muestra una roca grande, un grupo de piedras, un árbol o un arbusto. Cuál muestra depende de la casilla, así que el mapa siempre se ve igual. La salida es una **puerta de piedra con antorchas** (RF-06). El pasto y el camino no cambian.
- **RF-155** **Interfaz:** los botones de torres muestran su **torreta**, y los íconos de enemigos (próxima oleada y presentación, RF-133 y RF-134) muestran su **dibujo**.
- **RF-156** **Reemplazable:** cada dibujo es un archivo en `assets/sprites/`, y los datos de cada torre y cada enemigo dicen qué archivo usan. Si a un dato le falta el dibujo, se usa la **forma geométrica** de antes: así nada se rompe si falta un archivo.
- **RF-157** Con los dibujos, el juego sigue cumpliendo P7 (60 FPS con 200 enemigos y 60 torres).

---

## 10. Pantallas y progreso *(M3)*

- **RF-110** **Menú principal:** Jugar, Opciones, Salir. Es la primera pantalla al abrir el juego. De fondo se ve el mapa del nivel 1, oscurecido.
- **RF-117** El progreso **solo** se guarda cuando se juega desde el menú. Abrir la partida directamente desde el editor (F6) o correr los tests no toca el guardado del jugador.
- **RF-111** **Selección de nivel:** muestra los niveles. Los bloqueados dicen "Bloqueado". Los completados muestran sus **estrellas** (RF-93) y la mejor cantidad de vidas conseguida. Arriba se ve el **total de estrellas** de la campaña ("Estrellas: 7 de 15").
- **RF-112** Al principio solo está desbloqueado el nivel 1. **Ganar** el nivel N desbloquea el N+1.
- **RF-113** **Opciones:** volumen de música, volumen de efectos, pantalla completa sí/no, **números de daño sí/no** *(M4, RF-132)*.
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
4. Decidir si reemplaza la campaña normal o es un **modo aparte**.

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
