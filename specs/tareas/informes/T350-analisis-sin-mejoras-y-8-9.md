# T350 · Análisis: ¿hace falta mejorar y vender? y los niveles 8 y 9

> **Estado: ANÁLISIS HECHO, PROPUESTAS A LA ESPERA DE LUCAS.** Escrito el 2026-10-19 por Claude (Sonnet 5.5), tarea **T350**. **No se cambió ningún dato ni código del juego ni de balance.** No se agregó ninguna estrategia al bot: la que hacía falta ya existe (el bot **no mejora ni vende por omisión**; ver §1). Las propuestas de §5 **no se implementaron**: están en `specs/01-spec.md` §13 («Sugerencias de Claude»).
>
> **Pedido (Lucas, 2026-10-19):** un tester humano llegó al nivel 13 sin mejorar ni vender ninguna torre, y se sospecha desbalance en los niveles 8 y 9. Preguntas: (1) ¿qué dice eso de la mecánica de mejorar y vender?, (2) ¿se reproduce el problema de 8 y 9, también con el Mortero alcanzable?, (3) ¿qué podría hacer que el jugador descubra mejorar y vender además del tutorial?

## 0. Resumen (para quien lea solo esto)

1. **Se puede ganar la campaña entera sin mejorar ni vender, pero con márgenes que se achican.** El bot que solo construye (`mix` y, del 11 al 15, `sin_recursos`) gana **15 niveles de 15 en las 5 semillas**: del 1 al 9 con 9 a 20 vidas; el 10 con 7 a 11; del 11 al 15 con 6, 3 a 5, 5, 3 y 2 vidas. **Un humano que llegó al 13 sin mejorar es lo que el bot predice**, no una rareza.
2. **Mejorar es opcional por balance en los niveles 1 a 9, y por exceso de oro (más falta de explicación) del 10 al 15.**
   - **Niveles 1 a 9:** el mapa **nunca se llena** y el bot gasta el oro en torres nuevas en cada oleada (le quedan 80 a 370 de oro en mano). Una mejora rinde **menos daño por oro que una torre nueva** (la Ametralladora: 0,16 contra 0,20 de DPS por oro; el resto, de 1,2 a 3 veces más cara por DPS), así que **no hay incentivo de números para mejorar mientras queden casillas.** Las mejoras tempranas **suben** el margen en 4, 6 y 8 (por ejemplo 6: V9 → V20) y lo **bajan** en 1 y 2 (V20 → V10; V16 → V6).
   - **Niveles 10 a 15:** el mapa **se llena** (en la oleada 14 a 24 según el nivel) y desde ahí el oro **se acumula sin uso**: **3 838** (nivel 10), **2 237**, **3 743**, **1 878**, **5 522** y **5 437** (niveles 11 a 15) al terminar. Mejorar es la **única** forma de gastarlo, y con ella los márgenes pasan de V2–6 a V8–20 (nivel 14: V3 → V20; nivel 15: V2 → V9). **Ahí mejorar no es tentador porque nada lo anuncia:** no hay ninguna señal en pantalla de que sobra oro ni de que las torres se pueden mejorar.
3. **Vender no tiene ningún incentivo y el bot no lo usa** (no hay estrategia de venta, y no se agregó una: no estaba pedido y la conclusión no cambia). Los mapas tienen decenas de casillas libres (T245: ~115 en el 6 al 9), así que reubicar torres nunca hace falta. **Vender es opcional por diseño** y solo cobra sentido cuando el mapa está lleno (del 10 en adelante).
4. **El tutorial no alcanza para enseñarlo:** los pasos `upgrade` y `sell` son de **lectura** (el jugador no tiene que hacerlos, `tutorial_data.gd` los marca `EVENT_NONE`; RF-577 lo fija a propósito), solo salen en el nivel 1 (donde mejorar temprano **empeora** el margen, V20 → V10), se pueden saltar y los textos siguen en **borrador**. Quien lo saltó o lo leyó rápido no vuelve a ver mejorar ni vender nunca más.
5. **Nivel 8: el desbalance sospechado NO se reproduce.** `mix` gana 5/5 con V12–14, `smart` gana 5/5 con **V20** y las mejoras tempranas dan V20. El único tramo duro es la última oleada (la 18: 3 Guardianes, 3 Jefes, 14 Arañas y 18 Trols; 23 184 de vida), que le saca 6 vidas a `mix` y nada a `smart`. Es un descanso, como dijo T266.
6. **Nivel 9: sí se reproduce, pero solo para quien juega con las cuatro torres clásicas.** `smart` gana 5/5 pero con **V4–6** (en una sola oleada, la 16, pierde 11 vidas); `demoler` gana **2/5**; `naive` pierde 0/5. `mix` gana con V11 y las mejoras tempranas lo llevan a V14. Es la misma dependencia de la torre de área y la misma falta de mejoras que en el resto: **no es un muro, es un nivel que castiga más a quien no mezcla ni mejora.**
7. **El Mortero en el 9 (PR #11).** La rama `feature/copia-guardado-y-mortero` **solo trae la spec (RF-523 a RF-525) y la copia del guardado: no toca `data/` ni `tools/`**, así que el balance con ella mergeada es **idéntico** al de la rama de integración (el merge solo choca en la línea `config/version` de `project.godot`). El cambio real (escombros al 100 %) vive en `feature/impl-mortero-nivel9` (T282, `54b7fd4`), que sí se midió: **el Mortero se compra en la oleada 8 en 5 de 5 partidas y se gana con V13–17 si el bot también mejora**; **sin mejoras, la estrategia `mortero` pierde 5 de 5 en la oleada 3** (junta oro y deja de construir; es una limitación del bot, no una conclusión sobre personas).
8. **Lo que no se probó:** **ninguna persona jugó**. El bot no es un humano: coloca torres en el mejor lugar, nunca se equivoca y no tiene dudas. Un humano llena el mapa más tarde y puede acumular menos oro ocioso; o más, si se confunde. Todo lo de «descubrir» (§5) es hipótesis para validar con partidas reales.

## 1. Versión de referencia y método

**Versión medida:** `60fba1158ef2cca519ba186a305bb1b87b715c86` (rama `feature/integracion-mobile`, «Integración M60–M63»), Godot 4.7.2.stable.official.ed1daf0bf, Linux, sin ventana, `--fixed-fps 60`. Informe y notas en la rama `feature/t350-analisis-sin-mejoras`. Ningún registro de las baterías tuvo `SCRIPT ERROR`.

**El bot de balance (`tools/balance_sim.gd`) no mejora ni vende por omisión** (encabezado, «Mejoras de torres»: «Por omisión el bot no mejora nada»). Entonces la estrategia «solo construye» **es** la estrategia ya existente sin la opción `mejoras=`. No hizo falta agregar nada a `tools/`:

| Etiqueta del informe | Cómo se corrió | Qué representa |
|---|---|---|
| **Solo construye** | `mix` (niveles 1 a 10) y `sin_recursos` (11 a 15), sin `mejoras=` | Nunca mejora ni vende. Del 1 al 10 `sin_recursos` es idéntico a `mix`. |
| **Solo construye (`mix` con Disruptora)** | `mix` en el 11 a 15 | Compra la Disruptora cuando hay emisores de aura: la trampa conocida de T217/T229. Se informa aparte. |
| **Mejora al llenar** | `mejoras=llenar` | Mejora **solo** cuando ya no queda casilla libre (T255 §2). |
| **Mejora temprana** | `mejoras=temprana` | Mejora desde 3 torres, aunque queden casillas. |
| **`smart`** | 4 torres clásicas | Alguien que no usa las torres nuevas (solo 1 a 10). |
| **`demoler`, `extraer_temprano`, `naive`** | Solo en los niveles 8 y 9 | Ver T266 §1. |
| **`mortero`** | Solo en la rama `impl-mortero-nivel9` | Demuele los 3 escombros comunes y compra el Mortero (T282). |

**Semillas 1 a 5** (el mismo «5 de 5» que T266: en estos mapas el bot juega casi igual con cada semilla; son una medida repetida más que cinco independientes). «V*n*» es victoria con *n* vidas y «D*w*» derrota en la oleada *w*. **Oro sobrante** = oro sin gastar al terminar. Las vidas del bot son **margen**, no una escala fina: un Jefe que pasa quita 10.

**Volumen:** 549 partidas: 225 de la tabla base (15 niveles × 5 semillas × 3 reglas de mejoras), 150 de `smart` (1 a 10 × 3 reglas), 60 de `sin_recursos` en 11 a 15 × 3 reglas, 40 de `demoler`/`extraer_temprano`/`naive` en 8 y 9, 20 de una copia del nivel 9 con RF-523 (archivo con `file=`, fuera del repositorio), 30 en la rama del Mortero (un árbol de trabajo aparte, sin pushear, ya borrado) y 24 corridas de una semilla que imprimen oleada por oleada (para el oro y las vidas por oleada). Se corrieron hasta 30 procesos a la vez; el resultado no depende del reloj (`--fixed-fps`).

**Una trampa de método para quien repita esto:** la fila `mix` del 11 al 15 **no** es la regla de oro; la Disruptora hace perder el 11, 13, 14 y 15 aun sin mejorar (T266 §4). Por eso la referencia «solo construye» del 11 en adelante es `sin_recursos`.

## 2. Pregunta 1 · Niveles ganables sin mejorar ni vender

### 2.1 Tabla por nivel (5 semillas)

| Nivel | Solo construye | Oro sobrante al final | Mejora al llenar | Mejora temprana | `smart` solo construye | `smart` + mejora temprana |
|---|---|---|---|---|---|---|
| 1 · Pradera | 5/5 · V20 | 241 | 5/5 · V20 | 5/5 · V10 | 5/5 · V14 | 5/5 · V5 |
| 2 · Desfiladero | 5/5 · V16 | 324 | 5/5 · V16 | 5/5 · **V6** | 5/5 · V17 | 5/5 · V18 |
| 3 · Encrucijada | 5/5 · V16 | 310 | 5/5 · V16 | 5/5 · V17 | 5/5 · V8 | 5/5 · V15 |
| 4 · Espiral | 5/5 · V10 | 316 | 5/5 · V10 | 5/5 · V20 | **0/5 · D15** | 5/5 · V20 |
| 5 · Fortaleza | 5/5 · V13 | 283 | 5/5 · V13 | 5/5 · V15 | **0/5 · D20** | 5/5 · V18 |
| 6 · Nido | 5/5 · V9 | 267 | 5/5 · V9 | 5/5 · V20 | 5/5 · V7 | 5/5 · V16 |
| 7 · Cruce | 5/5 · V12 | 289 | 5/5 · V12 | 5/5 · V9–11 | 5/5 · **V5–6** | 5/5 · V17 |
| 8 · Bastión | 5/5 · V12–14 | 320 | 5/5 · V12–14 | 5/5 · V20 | 5/5 · V20 | 5/5 · V20 |
| 9 · Taller asediado | 5/5 · V11 | 343 | 5/5 · V11 | 5/5 · V14 | 5/5 · **V4–6** | 5/5 · V5–13 |
| 10 · La mina vieja | 5/5 · V7–11 | **3 838** | 5/5 · **V20** | 5/5 · V20 | 5/5 · V8–9 (oro 4 078) | 5/5 · V18 |
| 11 · Puesto seco | 5/5 · V6 | **2 237** | 5/5 · V8 | **0/5** · D7 D14 | — | — |
| 12 · El cañadón | 5/5 · V3–5 | **3 743** | 5/5 · V16 | **1/5** · D14 | — | — |
| 13 · Paso alto | 5/5 · V5 | **1 878** | 5/5 · V8–10 | **0/5** · D14 D18 | — | — |
| 14 · Los poblados vacíos | 5/5 · V3 | **5 522** | 5/5 · **V20** | 5/5 · V9–11 | — | — |
| 15 · La Central | 5/5 · V2 | **5 437** | 5/5 · V9 | **0/5** · D26 | — | — |

Notas de lectura:

- **11 a 15, «solo construye» = `sin_recursos`.** Con `mix` (con Disruptora) el 11, 13, 14 y 15 dan **0/5** (D14/D20, D14, D26 con **4 598** de oro sin gastar, D28/D30) y solo el 12 gana (V1–4). La trampa de la Disruptora es de T229, no de esta tarea.
- **«Mejora temprana» en 11, 12, 13 y 15 pierde** porque gasta el oro que necesitaba para ampliar cobertura (la advertencia de T255 §2.1: ninguna regla domina). No quiere decir que mejorar sea malo: quiere decir que el bot mejora mal. «Al llenar» (que espera a que no haya casillas) gana en los 15 niveles.
- **En el 1 y el 2 mejorar temprano baja el margen** (V20 → V10 y V16 → V6): el oro que se va a mejorar se le saca a la cobertura. Es lo que hay que tener en cuenta antes de pedir que el tutorial del nivel 1 obligue a mejorar.
- **Las semillas casi no mueven nada** (las vidas son iguales en las 5 salvo en el 8, el 10 y el 12); el desvío del nivel 10 (V7–11) viene del azar de los grupos y del temblor de pantalla.

### 2.2 Cuándo se llena el mapa y cuánto oro se acumula (una semilla, oleada por oleada)

«Última compra» es la última oleada en que subió la cantidad de torres (después ya no hay casillas buenas); «oro ≥ 500» es la primera oleada que terminó con 500 o más en mano. Nivel con `mix` (1 a 10) y `sin_recursos` (11 a 15), semilla 1, sin mejoras.

| Nivel | Oleadas | Torres al final | Última compra | Oro ≥ 500 desde | Oro máximo | Dónde se pierden vidas (oleada: vidas) |
|---|---|---|---|---|---|---|
| 1 | 10 | 23 | o10 | nunca | 241 | — |
| 2 | 15 | 40 | o15 | nunca | 324 | o12: −4 |
| 3 | 20 | 71 | o20 | nunca | 310 | o7: −4 |
| 4 | 15 | 51 | o15 | nunca | 316 | o13: −2, o15: −8 |
| 5 | 20 | 81 | o20 | nunca | 351 | o4: −1, o20: −6 |
| 6 | 15 | 46 | o14 | nunca | 282 | o5: −4, o8: −2, o12: −5 |
| 7 | 20 | 82 | o20 | nunca | 288 | o7: −3, o11: −5 |
| 8 | 18 | 67 | o18 | nunca | 367 | **o18: −6** |
| 9 | 20 | 86 | o20 | nunca | 351 | o13: −2, **o16: −7** |
| **10** | 20 | 43 | **o14** | **o15** | **3 790** | o16: −3, **o18: −10** |
| **11** | 22 | 52 | o20 | o21 | 2 222 | o14: −12, o20: −2 |
| **12** | 24 | 45 | o18 | o18 | 3 737 | o14: −4, o20: −2, o22: −3, o23: −6 |
| **13** | 24 | 59 | o22 | o22 | 1 807 | cinco oleadas con pérdidas (o4, o13, o14, o18, o23) |
| **14** | 26 | 51 | o19 | o19 | 5 516 | o19: −2, o22: −4, o23: −2, o24: −3, o26: −6 |
| **15** | 30 | 72 | o24 | o25 | 5 426 | o7: −4, o19: −7, o27: −3, o28: −1, o30: −3 |

**Lectura:** hasta el 9 el bot **compra torres hasta el último momento** y el oro nunca pasa de 370. Del 10 en adelante hay un **corte**: el mapa se llena entre 4 y 8 oleadas antes del final y el oro sube sin freno (más de 3 000 en cuatro niveles). Esos son los niveles donde mejorar pasa de «opcional» a «lo único que queda para gastar oro».

### 2.3 Por qué mejorar no es tentador hasta que el mapa se llena

DPS de los datos actuales (daño × cadencia, sin armadura) y lo que rinde cada oro:

| Torre | Costo nueva | Mejora 1 / 2 | DPS por oro de una torre nueva | DPS por oro de la mejora 1 / 2 | Resultado |
|---|---|---|---|---|---|
| Ametralladora | 50 | 60 / 100 | 0,200 | 0,167 / 0,160 | casi iguala |
| Francotirador | 150 | 150 / 225 | 0,107 | 0,080 / 0,089 | algo peor |
| Cañón | 100 | 110 / 170 | 0,120 | 0,065 / 0,064 | la mitad |
| Mortero | 300 | 250 / 350 | 0,075 | 0,050 / 0,057 | algo peor |
| Eléctrica | 130 | 120 / 180 | 0,075 | 0,053 / 0,053 | peor |
| Ráfaga | 110 | 100 / 150 | 0,073 | 0,037 / 0,035 | la mitad |
| Múltiple | 100 | 90 / 140 | 0,091 | 0,029 / 0,028 | un tercio |
| Incendiaria | 90 | 90 / 140 | 0,056 | 0,022 / 0,021 | un tercio |
| Hielo | 75 | 80 / 120 | 0,027 | 0,000 / 0,017 | casi nada de daño |

Mientras haya casillas buenas, **construir otra torre da más daño por oro que mejorar una** (con una salvedad: la mejora sí sube el **daño por golpe**, que contra armadura vale mucho más: la Ametralladora pasa de 5 a 12 por golpe, y contra armadura 3 de 2 a 9, o sea ×4,5; por eso las mejoras tempranas suben tanto el 4, 6 y 8). Cuando no queda lugar, la mejora es la única forma de seguir sumando daño. Esto es **balance coherente**, no un error; el problema es que el jugador no se entera.

### 2.4 Diagnóstico: ¿por qué mejorar es opcional?

| Causa | ¿Aplica? | Evidencia |
|---|---|---|
| **Opcional por balance** | **Sí, en 1 a 9** | Todas las estrategias que solo construyen ganan 1 a 9 con 9 a 20 vidas; mejorar temprano a veces ayuda (4, 6, 8) y a veces perjudica (1, 2). |
| **Exceso de oro** | **Sí, en 10 a 15** | 1 878 a 5 522 de oro ocioso; el mapa se llena entre las oleadas 14 y 24. Sin mejorar los márgenes son V2–11; con mejorar al llenar, V8–20. |
| **Falta de incentivo o explicación** | **Sí, en todos** | Solo hay tutorial de lectura en el nivel 1 (`upgrade` y `sell` son pasos EVENT_NONE, RF-577 prohíbe que el tutorial mejore por el jugador); el panel de la torre solo aparece al elegirla; ninguna señal avisa de oro ocioso ni de torres mejorables; la pantalla de derrota no dice nada. |

Que un tester llegue al 13 sin mejorar es lo que el bot predice: el juego **no empuja** a descubrirlo y solo lo castiga recién cuando el margen ya es de 2 a 6 vidas.

## 3. Pregunta 2 · Niveles 8 y 9

### 3.1 Datos del nivel (cálculo con el aumento de vida, sin armadura)

| | 8 · Bastión | 9 · Taller asediado |
|---|---|---|
| Oro / vidas / aumento | 300 / 20 / 32 % | 320 / 20 / 40 % |
| Oleadas | 18 | 20 |
| Vida total | 107 000 | 164 500 |
| Oleada más pesada | **18**: 23 184 (3 Guardianes, 3 Jefes, 14 Arañas, 18 Trols); la 16: 20 938 | **20**: 27 692; la 15: 19 602 (3 Jefes, 14 Tanques, 3 Curanderos) |
| Torres extra | Estándar mecánica | Estándar mecánica y Mortero |

### 3.2 Resultados por estrategia y semilla (rama de integración, `60fba11`)

| Estrategia | Nivel 8 | Nivel 9 |
|---|---|---|
| `mix` (solo construye) | 5/5 · V14 V14 V14 V12 V14 | 5/5 · V11 |
| `mix` + mejora al llenar | igual que `mix` (el mapa no se llena) | igual |
| `mix` + mejora temprana | 5/5 · **V20** | 5/5 · V14 |
| `smart` (clásicas) | 5/5 · **V20** | 5/5 · **V6 V4 V4 V5 V4** |
| `smart` + mejora temprana | 5/5 · V20 | 5/5 · V5–13 |
| `demoler` | 5/5 · V14–16 | **2/5** · V4 D16 D16 V1 D16 |
| `demoler` + mejora temprana | 5/5 · V20 | 5/5 · V10–11 |
| `extraer_temprano` | 5/5 · V12–14 | 5/5 · V11 (no compra nada con recursos) |
| `naive` (piso) | 0/5 · D7 D12 | 0/5 · D3 D4 D5 |

Sin cambios respecto de T266: **mismos números** que su tabla del §3 (8: V14 V14 V14 V12 V14 y `smart` V20; 9: V11 y `smart` V6 V4 V4 V5 V4; `demoler` 2/5), así que el bot reproduce hoy lo que midió hace tres días.

### 3.3 Picos (oleada por oleada, semilla 1)

| Estrategia | Nivel 8 | Nivel 9 |
|---|---|---|
| `mix` | sin pérdidas hasta la **o18: −6** (V14) | o13: −2; **o16: −7** (V11) |
| `smart` | **ninguna pérdida** (V20) | o4, o8, o12: −1 cada una; **o16: −11** (V6) |
| `mix` + temprana | ninguna (V20) | o9: −4, o16: −2 (V14) |
| `smart` + temprana | — | o9: −1, o16: −6 (V13) |

- **Nivel 9, oleada 16:** 36 Rápidos y 24 Voladores (7 560 de vida; **no** es una de las oleadas pesadas: la 15 pesa 19 602 y pasa sin pérdidas). Es un **enjambre rápido y volador** sin escudo de Guardián ni de Jefe: lo detiene el daño en área y el alcance, no la vida. `smart` (sin torres de área nuevas) pierde 11 vidas ahí; `mix`, 7. Con mejoras tempranas pierde 2.
- **Nivel 9, oleada 13:** 3 Guardianes, 3 Curanderos y 18 Trols (11 832): −2 con `mix`, nada con `smart` ni con mejoras.
- **Nivel 8, oleada 18** (final): −6 con `mix`; nada con `smart` ni con mejoras tempranas.

### 3.4 ¿Se reproduce el desbalance sospechado?

| Nivel | ¿Se reproduce? | Por qué |
|---|---|---|
| **8** | **No.** | Es el nivel **más holgado** del tramo 6–10 para `smart` (V20) y para `mix` con mejoras (V20). Su único tramo duro es la oleada final. Confirma el «descanso pedagógico» de T266 §4. |
| **9** | **Sí, moderado, y solo con dependencia de estrategia.** | `smart` termina con V4–6 (el margen más bajo de 1 a 10, junto con el 7: V5–6), `demoler` pierde 3 de 5 y `naive` pierde en la oleada 3 a 5. `mix` gana con V11 y mejorar lo sube a V14: **el nivel es ganable por cualquiera que mezcle torres o mejore, y se vuelve justo para quien hace ninguna de las dos cosas.** No hay un pico escondido de vida: hay dos oleadas (13 y 16) que piden torres de área. |

**Contramedidas necesarias en el 9** (de lo medido): torres de área o de mucho alcance para el enjambre de la 16 (la diferencia entre `smart` V6 y `mix` V11 es exactamente eso), y mejoras antes de la 16 (V11 → V14). Ni el 8 ni el 9 necesitan tocar números por lo que muestra el bot; si un humano se traba, es por la contramedida que no se anticipa (la sugerencia de consejo en el cartel de entrada de T266, §13).

### 3.5 Con el Mortero alcanzable (PR #11)

**Lo que trae `origin/feature/copia-guardado-y-mortero`** (`706b706`, el PR #11): 12 archivos, **ninguno** en `data/`, `tools/` ni `scripts/logic/`; sólo la copia del guardado (`save_manager.gd`, un test), `project.godot` (`config/version="1.0.0"`, que **choca** con el `beta` de T315 al mergear) y documentos (la spec RF-523 a RF-525, D-102/D-103). Por lo tanto **mergearla no cambia ningún número de balance**: las mediciones de §3.2 valen tal cual. No se pudo montar la copia mergeada como árbol de trabajo (el entorno no deja correr `git merge` fuera de mi árbol), pero se comprobó con `git diff --stat` y `git merge-tree` y con la copia del nivel 9 con RF-523 (abajo).

**El cambio de datos** (los escombros del 9 al 100 %) está en `origin/feature/impl-mortero-nivel9` (T282, `54b7fd4`), que **incluye** el PR #11. Se midió en un árbol de trabajo temporal (ya borrado, sin pushear), nivel 9, 5 semillas:

| Estrategia | Resultado | Notas |
|---|---|---|
| `mix` | 5/5 · V11 | Igual que antes. |
| `smart` | 5/5 · V4–6 | Igual que antes. |
| `demoler` | **2/5** · V1–4 | Igual: demuele pero no compra el Mortero. |
| `mortero` (demuele los 3 escombros y compra) | **0/5 · D3** | Junta oro (270 de demolición + 300 del Mortero) y deja de construir: cae en la **oleada 3**, las 5 semillas. |
| `mortero` + mejora temprana | **5/5 · V13–17** | Compra el Mortero en la **oleada 8** en las 5; gasta 270 de oro en demoler; termina con los 3 recursos usados. |
| `mix` + mejora temprana | 5/5 · V14 | Referencia. |

Con una copia del nivel 9 con RF-523 sobre la rama de integración (archivo con `file=`, no versionado), `demoler` junta **2 a 3 recursos** (antes 1 a 2) pero **ninguna estrategia vieja compra el Mortero** y los resultados son los mismos (`demoler` 2/5 V1–4, `demoler` + temprana 5/5 V10–11, `extraer_temprano` 5/5 V11).

**Lectura:** el Mortero **es alcanzable** para un bot que mejora (V13–17, mejor que `mix` con mejoras, V14), pero **no** para uno que sólo construye, porque ahorrar 570 de oro sin torres hunde las primeras oleadas. Dicho de otro modo: **el camino al Mortero depende de saber gestionar el oro** y, para el jugador que no mejora, del mismo descubrimiento. Esto **no es** una conclusión sobre personas (el bot ahorra a la brava y no escalona): lo valida la partida de Lucas en T283.

## 4. Qué dice todo esto de «mejorar y vender»

1. **Mejorar** funciona como mecánica de **sumidero de oro y de daño por golpe**: se vuelve necesario cuando el mapa se llena (10 a 15) o cuando hay armadura (4, 6, 8, 9). En los otros casos construir más rinde igual o más.
2. **Vender** no tiene ningún papel en los 15 niveles tal como están: ni el bot ni el balance lo piden. Sólo cobra sentido para **reubicar con el mapa lleno** (devuelve el 70 %).
3. **El juego no tiene un camino de descubrimiento por fuera del tutorial.** La información está (panel con «Mejorar (costo)» y «Vender», teclas `U` y `S`, tooltip «Faltan N de oro»), pero hay que elegir una torre para verla.
4. **Lo que se puede afirmar con el bot y lo que no.** Afirmable: hay márgenes para ganar sin mejorar; el oro ocioso aparece a partir del 10; las mejoras ayudan mucho a partir del 10. **No afirmable:** que un humano se aburra, se trabe o no pueda ganar sin mejorar en el 13 a 15 (ahí el bot gana con V2–5: **al borde**); ni cuántos testers más pasan por lo mismo.

## 5. Pregunta 3 · Propuestas (sin implementar), de más a menos impacto por costo

Ninguna toca números de balance salvo la 7, y esa está marcada. Van también a `specs/01-spec.md` §13.

| # | Propuesta | Qué resuelve | Costo | Riesgo |
|---|---|---|---|---|
| 1 | **Consejo en la pantalla de derrota** según lo que pasó: si perdió con oro sin gastar o sin mejoras, una línea (*«Terminaste con 1.240 de oro sin gastar y ninguna torre mejorada. Elegí una torre y tocá Mejorar.»*). | Llega justo cuando el jugador busca por qué perdió; usa datos que la sesión ya tiene (oro, mejoras hechas). | **Bajo** (texto + 2 contadores; `end_screen.gd` y datos de textos) | Casi ninguno; sólo texto. |
| 2 | **Aviso de «te sobra oro» en partida**, una vez por nivel y con «no volver a mostrar»: al terminar una oleada con oro por encima de un umbral (dato; sugerido 500) y **ninguna casilla libre** o **ninguna compra posible**, un cartel no bloqueante: *«Te sobra oro. Elegí una torre y mejorala (U) o vendé una que cubra poco (S): devuelve el 70 %.»* | Es exactamente el caso del 10 al 15 (oro ocioso 1 878 a 5 522). También enseña vender. | **Bajo a medio** (una condición en `game.gd`/`session`, un `Label` y la preferencia) | Ruido si el umbral es bajo; por eso un dato y una sola vez. |
| 3 | **Marca visual en las torres mejorables** cuando el aviso 2 está activo (una flecha ▲ pequeña sobre las que se pueden pagar ahora), o al elegir cualquier torre con oro de sobra. | Hace visible la acción en el celular, donde no hay hover. | **Medio** (dibujo en la torre, cuidado con 80 torres) | Carga visual y de rendimiento (T193). |
| 4 | **Mostrar el antes → después en el botón** («Mejorar → N2 · daño 5 → 8 · 60 oro»; hoy: «Mejorar → N2 / 60 de oro»). | Explica el valor de mejorar y que sube el daño por golpe, que es lo que importa contra armadura. | **Bajo** (texto armado desde los datos de la torre, como `tower_text.gd`) | Más texto en el botón del celular: revisar ancho (RF-503). |
| 5 | **Hitos de «primera vez»**: un cartelito único al hacer la **primera mejora** y la **primera venta** del guardado (*«¡Primera mejora! Tu torre pega más fuerte.»*) y, opcionalmente, una insignia en el Salón de la fama. | Refuerza el descubrimiento y da una razón visible. | **Medio** (clave nueva y aditiva en el guardado, como `tutorial_done`) | Mínimo; sólo guardado aditivo. |
| 6 | **Un segundo tutorial corto en el nivel 4** (donde mejorar sube el margen de V10 a V20): *«Esta torre está pegando poco contra los Blindados. Mejorala.»* con la acción real. | Enseña en el nivel donde mejorar **sí** gana partidas, no en el 1 donde las perjudica. | **Medio** (nueva instancia del tutorial, RF-577 hoy lo limita al 1) | Toca la spec M63; hay que decidir si se fuerza o se sugiere. |
| 7 | **Un incentivo de balance**: que alguna oleada de los niveles 3 a 5 sea más fácil con una torre mejorada que con otra nueva (por ejemplo, más armadura en una oleada). | Da una razón de números para mejorar antes del 10. | **Alto** (toca datos de niveles y obliga a re-medir todo) | **Alto**: puede romper la regla de oro y los niveles ya medidos (T279). **No recomendada** sin partidas humanas que lo justifiquen. |
| 8 | **No hacer nada de balance**, medir con 3 a 5 testers si el 1 a 4 los lleva a mejorar solos. | Evita arreglar a ciegas. | Ninguno | El problema real puede ser sólo del 10 en adelante. |

**Recomendación:** 1, 2 y 4 son baratas, no cambian balance ni guardado, y cubren el caso medido (oro ocioso del 10 al 15) y el caso del tester (llegar al 13 sin saber). Las medidas 3, 5 y 6 se dejan para después de ver si alcanzan. La 7 no.

## 6. Qué no se probó

- **Ninguna persona jugó.** El bot coloca torres siempre en el punto de mayor cobertura, no se confunde, no se cansa y no deja huecos; un humano llena el mapa más tarde, gasta peor y puede tener menos oro ocioso (o más). **Los 1 878 a 5 522 de oro del 10 al 15 son el techo del bot, no una predicción.**
- **No se midió venta:** el bot no vende, no se agregó una estrategia de venta y no se probó si vender mejora algo.
- **No se probó ninguna de las propuestas de §5**, ni si el aviso o la marca bastan para que el jugador descubra mejorar.
- **Mejorar en el 11 al 15 con la regla `temprana` pierde** en el bot por cómo reparte el oro; no significa que mejorar sea contraproducente para una persona.
- **Una sola semilla para las trazas** de §2.2 y §3.3 (las demás partidas dan las mismas vidas).
- **El Mortero con una persona:** el bot que ahorra para el Mortero pierde en la oleada 3 (sin mejoras) o gana con V13–17 (con ellas); la partida de Lucas (T283) es la validación.
- **El merge del PR #11 no se montó como árbol:** se concluyó desde el diff (sólo spec, guardado y `project.godot`) y se midió en la rama que sí contiene el cambio de datos.
- **El tutorial** se leyó de `data/tutorial/tutorial.json`, `tutorial_data.gd` y la spec (RF-570 a RF-578); no se jugó a mano.
- **El nivel de oro ocioso mide al terminar** (no cuánto del oro se podía haber usado antes); la fila «Oro ≥ 500 desde» da la oleada en que empieza.
- No se generó APK ni EXE; no se ejecutó la suite de GUT (no se tocó código).

## Apéndice · Archivos de la corrida

Las salidas crudas (`*.json`, `*.log`) quedaron en la carpeta de trabajo de la sesión, **fuera del repositorio**. Se reproducen con:

```bash
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix levels=1-10 seeds=5
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix levels=1-10 seeds=5 mejoras=llenar
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos levels=11-15 seeds=5 mejoras=llenar
godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=9 seed=1        # oleada por oleada
```
