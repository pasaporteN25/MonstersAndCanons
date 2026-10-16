# T266 · Auditoría de la progresión de dificultad de la campaña (niveles 1 a 15)

> **Estado: AUDITORÍA HECHA, AJUSTES PROPUESTOS A LA ESPERA DE LUCAS (G7).** Escrito el 2026-10-16 por Claude (Opus 5.5), tarea **T266**, a pedido de Lucas (B-37). **No se cambió ningún dato ni código del juego:** las variantes se jugaron con el bot en una **copia del proyecto fuera del repositorio** (archivos de nivel cargados con `file=`). Este informe **no escribe RF ni D**: los requisitos que habría que tocar están listados en §8.
>
> **Pedido de Lucas (2026-10-16):** un tester dijo que los niveles **2 y 7** eran los más difíciles en una versión vieja de siete niveles. Eso es evidencia histórica, no una medición actual. Auditar los **15 niveles actuales de la campaña** (no Asedio): saltos entre vecinos y cuánto depende el resultado de la estrategia; separar causas (balance, explicación de la contramedida o dependencia de una estrategia); marcar descansos justificados y picos sin justificación; proponer ajustes con antes y después medidos en copias, sin ajustar para una sola estrategia; y listar las partidas humanas que Lucas tiene que jugar.

## 0. Resumen (para quien lea solo esto)

1. **El reporte del tester se reproduce hoy, con los datos actuales.** El nivel 2 no cambió nada jugable desde la versión de siete niveles; el 7 cambió (Ladrón, Embestidor, removibles, Cuadrilla) pero su problema es el mismo. Las dos dificultades **dependen de la composición de torres**, no de la vida general de los monstruos:
   - **Nivel 2:** gana **solo** quien concentra Cañón y Francotirador (`smart`, 5/5 con 17 vidas). Quien diversifica con las torres nuevas (`mix`) o usa solo Ametralladoras (`basic`) **pierde en la última oleada en las 5 semillas**, con y sin mejoras. La causa es **la oleada 15: dos Jefes de 1770 de vida con armadura 3**, cada uno quita 10 vidas si llega. **Es el Jefe más duro de los niveles 1 a 7** (el del 7 tiene 1668). Es un **pico temprano sin justificación**.
   - **Nivel 7:** gana quien tiene daño en área (`mix`, 5/5 con 12 vidas, una semilla con 5) y **pierde en la oleada 18 quien juega con las cuatro torres clásicas** (`smart`, 0/5, con y sin mejoras; igual que en la versión vieja). La causa son **los enjambres de Rápidos por las dos entradas** (oleadas 2, 11 y 18; la 11 coincide con la Cuadrilla). Bajar la vida general no lo arregla: con aumento 20 % `smart` sigue perdiendo en la 18. Es **dependencia de una contramedida** que el juego no anticipa en ese nivel.
2. **Propuesta para el 2 (A, recomendada):** en la oleada 15, **un Jefe en lugar de dos** y **sin el último grupo de 12 Blindados**; el resto igual (35 %). Resultado: `mix` pasa de 0/5 a **5/5 con 16 vidas**, `smart` queda en 17, las mejoras tempranas ganan con 6, y **solo Ametralladoras sigue perdiendo** (el diseño pide mezclar torres desde el 2, §7.4 de la spec). Alternativa más generosa (B): aumento 30 % + un Jefe → todas las estrategias razonables ganan (`mix` V20, `smart` V18, `basic` V10).
3. **Propuesta para el 7:** suavizar **solo los tres enjambres**: oleada 2 de 15+15 a **10+10** Rápidos, oleada 11 de 30 a **22** Rápidos, oleada 18 de 40 Rápidos + 25 Voladores a **30 + 20**. Resultado: `smart` pasa de 0/5 a **5/5 con 5–6 vidas**, `mix` queda en **12 en las 5 semillas** (desaparece la semilla con 5). El 7 sigue siendo exigente para quien no usa área; deja de ser un muro.
4. **Los otros 11 niveles no tienen picos sin justificación.** Hay dependencias de estrategia **ya conocidas y explicadas** (4 y 5: muchos Voladores, el Cañón no les pega; `smart` pierde, `basic` y `mix` ganan) y un **descanso pedagógico** en el **8** (debut del Guardián; `smart` gana con 20). Del 11 al 15 la escalera de la regla de oro es correcta (`sin_recursos` 6 → 3–5 → 5 → 3 → 2, el 15 el más difícil); lo que sí aparece es **la trampa ya conocida de la Disruptora** (T217, T229): el bot que la compra pierde el 11 y el 13 aun mejorando torres. Queda pendiente de Lucas (§4).
5. **Las mejoras importan desde el 4.** Mejorar temprano sube mucho el margen en 4, 6, 8, 9 y 10 (por ejemplo, 6: de 9 a 20 vidas), y en el 1 lo **baja** (de 20 a 10). El bot casi nunca llena el mapa en los niveles 1 a 9, así que «mejorar al llenar» no cambia nada ahí.
6. **Lo que no se probó:** **ninguna persona jugó**; el bot no lee la oleada siguiente ni cambia de plan. Las conclusiones de dependencia de estrategia son del bot y hay que confirmarlas con las partidas de §7.

## 1. Versión de referencia y método

**Versión auditada:** commit `93f780ac7b79980352f893665abb9d8543b59d88` (rama `feature/t266-auditoria-dificultad`, 2026-10-16). Godot 4.7.2.stable.official.ed1daf0bf, Linux, sin ventana, `--fixed-fps 60`. Las baterías corrieron con `nice -n 19` y **a lo sumo 4 procesos** a la vez, porque otra tarea medía FPS. Ningún registro tuvo `SCRIPT ERROR`.

**Versión histórica del tester:** la campaña tuvo siete niveles entre el commit `1bfd5e1` (2026-09-29, T97/T98, nivel 7 «Cruce») y `254155c` (2026-10-04, T192, niveles 8 y 9). En ese tramo:

- **Nivel 2:** las oleadas, el oro (200), las vidas (20) y el aumento (35 %) son **idénticos** a los de hoy. Lo único que cambió después es decorado (T222: rocas `X` por columna y agua, que siguen sin ser construibles) y textos (T228).
- **Nivel 7:** el viejo se jugó con el bot actual (`git show 1bfd5e1:data/levels/level_07.json`, cargado con `file=` en la copia). Hoy tiene además Ladrón, Embestidor, removibles con drop (T223) y la Cuadrilla (T253).
- **Torres y enemigos:** entre esa versión y hoy los `.tres` de torres y enemigos comunes solo cambiaron **arte** (texturas, atlas), no vida, daño, alcance ni costos (revisado con `git diff 1bfd5e1 HEAD`).

**Estrategias del bot** (`tools/balance_sim.gd`, sin modificarlo):

| Estrategia | Qué representa | Dónde se jugó |
|---|---|---|
| `mix` | Mezcla las 8 torres comunes en orden fijo (Ametralladoras, Eléctrica, Cañón, Incendiaria, Múltiple, Francotirador, Ráfaga, Hielo) y las pone donde cubren más camino. Es la referencia de la regla de oro en 1 a 10 (en esos mapas es idéntica a `sin_recursos`). | 1 a 15 |
| `smart` | Solo las 4 torres clásicas (Ametralladora, Cañón, Hielo, Francotirador): alguien que no usa las torres nuevas. | 1 a 10 (del 11 al 15 no hay Ametralladora) |
| `basic` | Solo Ametralladoras bien puestas: alguien que no mezcla. | 1 a 5 |
| `naive` | Solo Ametralladoras en casillas al azar: piso, no una persona razonable. | 1 a 10 |
| `demoler` | Como `mix`, pero gasta oro en demoler removibles que abren casillas mejores. | 7 a 10 |
| `extraer_temprano` | Habilita extracción desde la oleada 1 y construye con recursos. | 10 |
| `sin_recursos` | La de la regla de oro (RF-432): no demuele, no extrae, no compra la Disruptora. | 11 a 15 |

**Mejoras de torres** (T258): sin mejoras (`none`), `llenar` (mejora cuando no queda casilla libre) y `temprana` (mejora desde 3 torres, aunque queden casillas). **Semillas 1 a 5** en todo. «V*n*» es victoria con *n* vidas y «D*w*» derrota en la oleada *w*. Si las cinco semillas dan lo mismo se escribe una sola vez.

**Una advertencia que vale para todo el informe:** en estos mapas el bot juega casi igual con cada semilla (la semilla solo cambia el azar de los grupos, los drops y el temblor), así que «5 de 5» es en la práctica **una medida repetida**, no cinco independientes. Y el final de casi todos los niveles es un **precipicio**: un Jefe que pasa quita 10 vidas. Por eso V10 o V12 suelen significar «se escapó un Jefe» y las vidas sirven como **margen**, no como medida fina.

**Volumen:** 425 partidas de base (15 niveles), 261 de variantes en copias y 25 de control de Asedio (§5.3), además de 10 de la propuesta del 7 con otras estrategias.

## 2. Lo que dicen los datos de cada nivel (sin jugar)

Vida calculada como lo hace el juego (`vida base × (100 + aumento × (oleada − 1)) / 100`, sin armadura). «Jefe más duro» es la vida de un Jefe (o del Coloso en el 15) en su oleada más exigente, y cuántos vienen.

| Nivel | Oro | Oleadas | Aumento | Vida en la última oleada | Vida total del nivel | Jefe más duro |
|---|---|---|---|---|---|---|
| 1 · Pradera | 150 | 10 | 40 % | 11 580 | 30 100 | 1380 × 1 (o10) |
| **2 · Desfiladero** | 200 | 15 | **35 %** | **16 912** | 57 500 | **1770 × 2 (o15)** |
| 3 · Encrucijada | 250 | 20 | 20 % | 10 360 | 80 000 | 1440 × 4 (o20) |
| 4 · Espiral | 200 | 15 | 20 % | 14 185 | 48 600 | 1140 × 3 (o15) |
| 5 · Fortaleza | 300 | 20 | 10 % | 8 695 | 55 800 | 870 × 6 (o20) |
| 6 · Nido | 250 | 15 | 30 % | 15 444 | 62 100 | 1560 × 4 (o15) |
| **7 · Cruce** | 300 | 20 | 24 % | 19 839 | **109 900** | 1668 × 6 (o20) |
| 8 · Bastión | 300 | 18 | 32 % | 23 164 | 107 000 | 1932 × 3 (o18) |
| 9 · Taller asediado | 320 | 20 | 40 % | 27 692 | 164 500 | 2580 × 3 (o20) |
| 10 · La mina vieja | 360 | 20 | 30 % | 19 966 | 129 200 | 2010 × 3 (o20) |
| 11 · Puesto seco | 420 | 22 | 27 % | 17 805 | 123 500 | 2001 × 3 (o22) |
| 12 · El cañadón | 440 | 24 | 27 % | 13 330 | 155 800 | 2163 × 1 (o24) |
| 13 · Paso alto | 460 | 24 | 40 % | 18 870 | 224 300 | 3060 × 1 (o24) |
| 14 · Los poblados vacíos | 480 | 26 | 30 % | 25 075 | 243 600 | 2550 × 2 (o26) |
| 15 · La Central | 520 | 30 | 23 % | 42 958 | 271 300 | Coloso 4602 × 3 (o30) |

**Lecturas:**

- **El 2 tiene la última oleada más pesada de los niveles 1 a 6** (16 912, 1,46 veces la del 1) **con el segundo oro más bajo** (200) y **el Jefe individual más duro hasta el 8.** Además, su última oleada pesa **3,2 veces la anterior** (5,3 mil → 16,9 mil); en el 1 la relación es 1,8. Es un escalón al final, no una subida pareja.
- **El 7 casi duplica la vida total del 6** (62 mil → 110 mil) con solo 50 de oro más, y la reparte en **dos entradas opuestas**. Pero la vida no explica el resultado (ver §3.2): lo que decide son los enjambres.
- Del 8 en adelante la vida sube con el oro y el tamaño de los mapas; el 15 es, como corresponde, el más pesado.

## 3. Resultados de la campaña, niveles 1 a 10

| Nivel | `mix` | `mix` + mejoras al llenar | `mix` + mejoras tempranas | `smart` | `smart` + mejoras al llenar | `basic` | `naive` | `demoler` | `extraer_temprano` |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 5/5 · V20 | 5/5 · V20 | 5/5 · V10 | 5/5 · V14 | 5/5 · V14 | 5/5 · V10 | 0/5 · D10 D6 D7 D8 D10 | — | — |
| **2** | **0/5 · D15** | **0/5 · D15** | **0/5 · D15** | 5/5 · V17 | 5/5 · V17 | **0/5 · D15** | 0/5 · D9 D9 D12 D7 D4 | — | — |
| 3 | 5/5 · V16 | 5/5 · V16 | 5/5 · V17 | 5/5 · V8 | 5/5 · V8 | 0/5 · D20 | 0/5 · D9 D9 D15 D9 D9 | — | — |
| 4 | 5/5 · V10 | 5/5 · V10 | 5/5 · V20 | 0/5 · D15 | 0/5 · D15 | 5/5 · V16 | 0/5 · D7 D10 D10 D10 D15 | — | — |
| 5 | 5/5 · V13 | 5/5 · V13 | 5/5 · V15 | 0/5 · D20 | 0/5 · D20 | 5/5 · V10 | 1/5 · D9 D10 D15 V3 D5 | — | — |
| 6 | 5/5 · V9 | 5/5 · V9 | 5/5 · V20 | 5/5 · V7 | 5/5 · V7 | — | 0/5 · D5 D5 D5 D5 D7 | — | — |
| **7** | 5/5 · V5 V12 V12 V12 V12 | 5/5 · V5 V12 V12 V12 V12 | 5/5 · V10 V11 V11 V11 V11 | **0/5 · D18** | **0/5 · D18** | — | 0/5 · D4 D10 D10 D3 D2 | 5/5 · V11 | — |
| 8 | 5/5 · V14 V14 V14 V12 V14 | 5/5 · V14 V14 V14 V12 V14 | 5/5 · V20 | 5/5 · V20 | 5/5 · V20 | — | 0/5 · D7 D7 D7 D12 D7 | 5/5 · V14 V16 V14 V14 V16 | — |
| 9 | 5/5 · V11 | 5/5 · V11 | 5/5 · V14 | 5/5 · V6 V4 V4 V5 V4 | 5/5 · V6 V4 V4 V5 V4 | — | 0/5 · D5 D5 D4 D3 D3 | **2/5 · V4 D16 D16 V1 D16** | — |
| 10 | 5/5 · V7 V11 V7 V9 V11 | 5/5 · V20 | 5/5 · V20 | 5/5 · V8 V9 V9 V8 V9 | 5/5 · V18 | — | 0/5 · D13 | 5/5 · V18 | 5/5 · V17 |

### 3.1 Saltos entre vecinos y su causa

Se lee la tabla de a pares. «Pico» es cuando un nivel es claramente más difícil que el anterior **y** el siguiente para alguna estrategia razonable (no `naive`).

| Paso | Qué pasa | Causa | Veredicto |
|---|---|---|---|
| 1 → 2 | `mix` y `basic` pasan de ganar (V20, V10) a **perder en la última oleada**; `smart` mejora (V14 → V17). | **Balance + dependencia de estrategia.** El resultado se decide en la oleada 15 por si pasan los dos Jefes (1770 de vida, armadura 3: a la Ametralladora le entran 2 de sus 5 de daño y Múltiple y Ráfaga pierden casi la mitad). Solo con Cañón y Francotirador concentrados se los frena. | **Pico temprano sin justificación** (§5.1). |
| 2 → 3 | Para `mix` el 3 es mucho más fácil (V16); para `smart` más difícil (V17 → V8). `basic` sigue perdiendo. | El 3 tiene 20 oleadas, menos aumento (20 %) y dos entradas: premia cubrir dos caminos, no romper armadura. | Normal si se corrige el 2. Hoy el 3 es un **descanso involuntario** para quien diversifica. |
| 3 → 4 → 5 | `smart` **pierde** el 4 y el 5; `basic` los gana (V16, V10); `mix` gana (V10, V13). | **Dependencia de estrategia ya conocida** (spec §7.4): muchos Voladores; el Cañón no les pega y `smart` gasta en Cañones. | **Justificado y explicado:** la descripción del Cañón dice «No le pega a los voladores» y la barra muestra la próxima oleada (RF-133). |
| 5 → 6 | Todas bajan (`mix` V13 → V9, `smart` V7 gana). | Debut de Troll, Araña y Crías con dos entradas, 30 %. Las mejoras tempranas lo vuelven holgado (V20). | Subida razonable: es el inicio del segundo bloque. |
| **6 → 7** | `mix` sube (V9 → V12, con una semilla en V5); `smart` **pierde en la 18 en las 5 semillas**. | **Dependencia de contramedida:** enjambres de Rápidos por las dos entradas (oleadas 2, 11 y 18) más la Cuadrilla en la 11. Bajar el aumento a 20 % no lo arregla (§5.2). | **Pico sin justificación para quien no usa daño en área**; el juego no lo anticipa en ese nivel. |
| 7 → 8 | Todas mejoran (`smart` V20, `mix` V14). | Debut del Guardián (una entrada, separa robo y embestidas antes de combinarlos, spec §7). | **Descanso pedagógico justificado** al presentar una mecánica nueva. |
| 8 → 9 | Todas bajan (`mix` V11, `smart` V4–6); **`demoler` pierde 3 de 5**. | 40 % de aumento, Curandero junto al Guardián y dos entradas. Demoler gasta oro que falta en las oleadas 15–16. | Subida razonable; la de `demoler` es una **trampa de recursos** (ver §3.3). |
| 9 → 10 | `mix` sin mejoras baja algo (V7–11) pero con mejoras sube a V20; `extraer` y `demoler` ganan con 17–18. | Mapa grande con pocas casillas: se llena y las mejoras entran en juego. | Razonable; el 10 premia mejorar y usar recursos, que es lo que enseña. |

### 3.2 Cuánto pesa cada palanca

- **Composición:** es la palanca que más pesa en 1 a 7. Ninguna estrategia del bot gana todos los niveles del 1 al 7: `mix` pierde el 2, `smart` pierde el 4, el 5 y el 7, `basic` pierde el 2 y el 3. Que una persona tenga que **cambiar de composición según el mapa** es deseable; que lo tenga que adivinar en un nivel temprano, no.
- **Ubicación:** `naive` (mismas Ametralladoras, al azar) pierde **casi todo** (gana 1 de 50 partidas), incluso el 1, mientras `basic` (bien puestas) gana 1, 4 y 5. La ubicación es tan importante como la composición; el juego ya la enseña en el 1 y en la Wiki.
- **Mejoras:** con «mejorar al llenar» el bot casi nunca mejora en 1 a 9 (no llena el mapa), así que esas columnas repiten la base. Con mejoras **tempranas** el margen sube mucho en 4 (V10 → V20), 6 (V9 → V20), 8 (V14 → V20), 9 (V11 → V14) y 10 (→ V20), y **baja** en el 1 (V20 → V10) y algo en el 7: gastar en mejoras antes de cubrir el camino puede dejar pasar un Jefe. En el 2 no cambia nada: la armadura del Jefe se come la mejora de las torres de daño chico.
- **Recursos (7 a 10):** demoler ayuda en el 8 y el 10 y es neutro en el 7, pero en el 9 hace perder 3 de 5. Extraer en el 10 gana con 17. La regla de oro (RF-432) se cumple: `mix`/`sin_recursos` gana 5 de 5 en todos los niveles con recursos del 7 al 10.

### 3.3 La trampa de demoler en el 9

`demoler` pierde el 9 en la oleada 16 en tres semillas (V4 y V1 en las otras dos), mientras `mix` sin demoler gana con 11. El bot demuele de a uno «lo que abra casillas mejores» sin mirar cuánto oro le queda, así que es un caso extremo; pero muestra que en el 9 **gastar en infraestructura antes de tener la defensa armada se paga caro**. No es un pico (la estrategia de referencia gana con margen) y no se propone cambiarlo; se anota para la partida humana del 9 si Lucas la quiere hacer. Coincide con la sugerencia «Que demoler valga la pena en los niveles 6 a 9» (T245, `01-spec.md` §13), que ya había medido 3 derrotas de 5 en el 9.

## 4. Resultados de la campaña, niveles 11 a 15

Del 11 al 15 no hay Ametralladora (RF-474), así que se juegan `mix` (que compra la Disruptora: el bot simula la colección completa y le da 4 recursos, RF-452) y `sin_recursos` (la de la regla de oro: igual que `mix` pero sin Disruptora, sin demoler ni extraer).

| Nivel | `sin_recursos` | `mix` (con Disruptora) | `mix` + mejoras al llenar |
|---|---|---|---|
| 11 · Puesto seco | 5/5 · V6 | **0/5 · D20 D14 D14 D14 D14** | **0/5 · D20 D14 D14 D14 D14** |
| 12 · El cañadón | 5/5 · V5 V3 V3 V5 V3 | 5/5 · V4 V1 V1 V1 V1 | 5/5 · V16 V13 V13 V13 V13 |
| 13 · Paso alto | 5/5 · V5 | **0/5 · D14** | **0/5 · D14** |
| 14 · Los poblados vacíos | 5/5 · V3 | **0/5 · D26** | 5/5 · V12 V10 V10 V10 V12 |
| 15 · La Central | 5/5 · V2 | **0/5 · D28 D30 D30 D30 D30** | 5/5 · V3 |

**Lecturas:**

- **La escalera de la regla de oro está bien.** `sin_recursos` termina con 6 → 3–5 → 5 → 3 → 2: baja casi siempre y **el 15 es el más difícil**, como pide RF-475. El 12 queda un poco por debajo del 13 (3 contra 5 en tres semillas); es el debut del Espejo y la diferencia es de una o dos fugas, así que **no es un pico** que haya que corregir.
- **Los márgenes del 14 y el 15 son finos** (3 y 2 vidas), como ya se sabía (T232, T234 y el riesgo del plan 12, §6). Cualquier cambio en esos niveles se remide con las 5 semillas.
- **Comprar la Disruptora como la compra el bot empeora mucho:** sin mejoras, `mix` pierde 11, 13, 14 y 15; con mejoras sigue perdiendo 11 y 13. **No es un hallazgo nuevo:** T217 y T229 ya midieron que «con el bot la Disruptora empeora» (gasta 260 de oro en dos Disruptoras en lugar de torres de daño) y quedó **para que Lucas decida** (RF-475, punto 8, «A REVISAR TRAS G4»). Este informe solo agrega que el efecto se repite en los cinco niveles finales y con la Cuadrilla ya cargada. Es una **dependencia de estrategia con una trampa**: una persona que se entusiasma con la torre de colección del final puede trabarse en el 11. **No se propone tocarlo acá** porque es una decisión pendiente de balance de la Disruptora, no de la curva; se lista en §8.
- **Las mejoras deciden el 12 y el 14:** con «mejorar al llenar», `mix` pasa de V1–4 a V13–16 en el 12 y de perder a V10–12 en el 14. En estos mapas grandes el bot sí llena el mapa, así que esta columna sí mide algo.

## 5. Ajustes propuestos, medidos en copias

Todas las variantes se jugaron con `file=tools/t266/<variante>.json` en la copia, con 5 semillas. El control `l02_base` (el archivo actual cargado por `file=`) reproduce la base (`mix` D15), así que cargar por archivo no cambia el resultado.

### 5.1 Nivel 2

| Variante | Qué cambia | `mix` | `mix` + llenar | `mix` + tempranas | `smart` | `smart` + llenar | `basic` | `naive` |
|---|---|---|---|---|---|---|---|---|
| **Hoy** | — | 0/5 · D15 | 0/5 · D15 | 0/5 · D15 | 5/5 · V17 | 5/5 · V17 | 0/5 · D15 | 0/5 · D9 D9 D12 D7 D4 |
| a32 | Aumento 35 → 32 % | 5/5 · V10 | 5/5 · V10 | 0/5 · D15 | 5/5 · V18 | — | 0/5 · D15 | 0/5 · D12 D12 D12 D8 D5 |
| a30 | Aumento 35 → 30 % | 5/5 · V10 | 5/5 · V10 | 5/5 · V2 | 5/5 · V18 | 5/5 · V18 | 0/5 · D15 | 0/5 · D12 D12 D12 D9 D6 |
| a28 | Aumento 35 → 28 % | 5/5 · V10 | — | — | 5/5 · V20 | — | — | — |
| jefe1 | Oleada 15 con 1 Jefe | 5/5 · V6 | — | — | 5/5 · V17 | — | — | — |
| **A · final suave** | Oleada 15: **1 Jefe** y **sin los 12 Blindados** del final | **5/5 · V16** | **5/5 · V16** | **5/5 · V6** | **5/5 · V17** | **5/5 · V17** | 0/5 · D15 | 0/5 · D9 D9 D12 D7 D4 |
| **B · a30 + 1 Jefe** | Aumento 30 % y oleada 15 con 1 Jefe | **5/5 · V20** | **5/5 · V20** | **5/5 · V12** | **5/5 · V18** | — | **5/5 · V10** | 0/5 · D12 D12 D12 D9 D6 |

**Lecturas:**

- **Bajar solo el aumento no alcanza.** Entre 28 y 32 %, `mix` gana siempre con **exactamente 10**: se le sigue escapando un Jefe. Con mejoras tempranas queda en 2 vidas (30 %) o pierde (32 %). Es un ajuste para el bot `mix`, no para el nivel.
- **Sacar un Jefe solo tampoco** (V6): el último grupo de Blindados llega cuando las torres todavía pelean con el Jefe.
- **La variante A ataca la causa** (el escalón de la oleada 15) y deja todo lo demás igual: 35 %, oro, oleadas 1 a 14. `mix` y `smart` quedan **parejos** (16 y 17) y **solo Ametralladoras sigue perdiendo**, que es lo que pide la spec para el 2 («desde el nivel 2 hay que mezclar torres», §7.4). Con A, la curva para `mix` queda 1 (V20) → 2 (V16) → 3 (V16) y para `smart` 14 → 17 → 8.
- **La variante B es más generosa:** gana incluso solo con Ametralladoras (V10) y deja el 2 tan fácil como el 1 para `mix`. Conviene si las partidas humanas con A todavía se sienten como un muro.
- **No se propone tocar el oro inicial:** el 2 ya da 200 y el problema no aparece hasta la última oleada; más oro ayuda sobre todo a quien ya ganaba.

**Recomendación: A.** Si Lucas, jugando A, todavía pierde o gana «de casualidad» en la 15, pasar a B.

### 5.2 Nivel 7

| Variante | Qué cambia | `mix` | `mix` + llenar | `mix` + tempranas | `smart` | `smart` + llenar | `demoler` | `naive` |
|---|---|---|---|---|---|---|---|---|
| Versión vieja (tester) | Archivo de `1bfd5e1` | 5/5 · V16 | — | — | **0/5 · D18** | — | — | — |
| **Hoy** | — | 5/5 · V5 V12 V12 V12 V12 | 5/5 · V5 V12 V12 V12 V12 | 5/5 · V10 V11 V11 V11 V11 | **0/5 · D18** | **0/5 · D18** | 5/5 · V11 | 0/5 · D4 D10 D10 D3 D2 |
| a20 | Aumento 24 → 20 % | 5/5 · V17 | — | 5/5 · V14 V13 V13 V13 V13 | 0/5 · D18 | 0/5 · D18 | — | 0/5 · D4 D14 D11 D3 D2 |
| o11 | Oleada 11: 30 → 22 Rápidos | 5/5 · V5 V12 V12 V11 V12 | — | 5/5 · V8 V11 V11 V11 V11 | 0/5 · D18 | 0/5 · D18 | — | 0/5 · D4 D10 D10 D3 D2 |
| o2 + o11 | Además, oleada 2: 15 + 15 → 10 + 10 Rápidos | 5/5 · V12 | — | 5/5 · V11 | 2/5 · V1 D18 D18 V1 D18 | 2/5 · V1 D18 D18 V1 D18 | — | 0/5 · D4 D8 D8 D3 D3 |
| **Propuesta · o2 + o11 + o18** | Además, oleada 18: 40 Rápidos + 25 Voladores → **30 + 20** | **5/5 · V12** | **5/5 · V12** | **5/5 · V9 V11 V11 V9 V11** | **5/5 · V6 V5 V5 V6 V5** | **5/5 · V6 V5 V5 V6 V5** | **5/5 · V13** | 0/5 · D4 D8 D8 D3 D3 |

**Lecturas:**

- **El pico del 7 no es de vida:** con 20 % de aumento `mix` sube a 17 pero `smart` sigue perdiendo en la 18, igual que hoy y que en la versión vieja.
- **Es de enjambres.** En una partida de `smart` (semilla 1) las vidas se van en la oleada 2 (−8: 15 Rápidos por cada entrada con apenas 300 de oro), la 7 (−6), la 11 (−5, 30 Rápidos con la Cuadrilla) y la 18 (la derrota: 40 Rápidos y 25 Voladores). `mix`, que tiene Múltiple, Ráfaga y Eléctrica, pierde casi todo en la 11 (−11 en la semilla 1).
- **Hay que tocar las tres oleadas:** con solo la 11, nada cambia; con 2 y 11, `smart` gana 2 de 5 con 1 vida; con las tres gana 5 de 5 con 5–6. **No es un ajuste para una sola estrategia:** `mix` también mejora (desaparece la semilla con V5) y las mejoras tempranas siguen ganando con 9–11.
- **La Cuadrilla no se toca** (oleadas 8, 11, 13 y 16, RF-487): solo baja la cantidad de Rápidos que la acompañan en la 11.
- **El 7 sigue siendo exigente** para quien juega con las cuatro torres clásicas (5–6 vidas, el menor margen de 6 a 8), lo que está bien para el cierre del primer tramo con dos entradas.

**Explicación de la contramedida (complementa el ajuste, no lo reemplaza):** el juego no le dice a quien llega al 7 que las oleadas de Rápidos por las dos entradas piden torres de área. La presentación de enemigos (RF-134) solo aparece la primera vez que se ve un tipo, y el Rápido se ve en el 1. **Sugerencia (consultar):** una línea de consejo en el cartel de entrada del 2 («Los Jefes y los Blindados tienen armadura: Cañón y Francotirador») y del 7 («Enjambres por las dos entradas: Múltiple, Ráfaga o Eléctrica»). Los textos de entrada son lore (`specs/11-textos-lore.md`), así que esto sería un requisito nuevo; quedó anotado en `01-spec.md` §13, «Sugerencias de Claude», y en §8.

### 5.3 Efecto en el resto de la campaña y en Asedio

- **Campaña:** los cambios son solo de datos de `level_02.json` y `level_07.json`; ningún otro nivel cambia. La regla de oro (RF-432) en el 7 se sigue cumpliendo (`mix`/`sin_recursos` 5 de 5).
- **Asedio reusa los mapas 2 y 7** con las mismas oleadas (RF-391) y un porcentaje de vida por mapa (`data/modos/asedio/modo.json`: 105 % en el 2 y 101 % en el 7, T258). Cambiar la campaña **también afloja esos dos mapas de Asedio**. Medido con la política fija de cada mapa (T258):

| Mapa de Asedio | Política (T258) | Hoy | Con la propuesta | Con la alternativa B del 2 |
|---|---|---|---|---|
| 2 (105 %) | `smart`, mejoras al llenar | 5/5 · V13 | A: 5/5 · V13 | 5/5 · V18 |
| 7 (101 %) | `sin_recursos`, mejoras al llenar | 5/5 · V1 V10 V10 V10 V10 | 5/5 · V6 | — |

- **El mapa 2 de Asedio no cambia con A** (la política de ese mapa es `smart`, que ya ganaba con 17 en la campaña y sigue igual). Con B sube de 13 a 18 vidas: si Lucas elige B, Asedio 2 queda más fácil que hoy y habría que remedir su porcentaje.
- **El mapa 7 de Asedio queda más parejo, no más fácil:** desaparece la semilla que ganaba con 1 vida, pero las otras bajan de 10 a 6. Una explicación posible (no verificada) es que con menos Rápidos el bot cobra menos oro y llega a las oleadas finales con menos torres. Gana 5 de 5 igual; conviene remedirlo en la tarea que especifique el ajuste.

## 6. Picos y descansos: la lista

| Nivel | Tipo | Para quién | Causa | Propuesta |
|---|---|---|---|---|
| **2** | **Pico temprano sin justificación** | `mix`, `basic` (y cualquiera que no concentre Cañón y Francotirador) | Balance de la oleada 15 (dos Jefes de 1770 + Blindados) y dependencia de composición | **A** (§5.1); B si hace falta |
| 3 | Descanso involuntario para `mix` | `mix` | Se vuelve fácil sobre todo porque el 2 es un muro para esa estrategia | Ninguna; se normaliza con A |
| 4 y 5 | Dependencia de estrategia **justificada y explicada** | `smart` pierde | Muchos Voladores; el Cañón no les pega (dicho en su descripción y en la próxima oleada) | Ninguna |
| **7** | **Pico sin justificación** | `smart` (las 4 torres clásicas) | Enjambres por dos entradas (oleadas 2, 11 y 18) sin aviso de contramedida | o2 + o11 + o18 (§5.2) y consejo de entrada (§8) |
| 8 | **Descanso pedagógico justificado** | todas | Debut del Guardián | Ninguna |
| 9 | Subida razonable; trampa de demoler | `demoler` | Gastar en infraestructura antes de defender | Ninguna; anotar |
| 11 a 15 | Escalera correcta (6 → 3–5 → 5 → 3 → 2); el 12 apenas por debajo del 13 | `sin_recursos` | Debut del Espejo en el 12; márgenes finos en 14 y 15 | Ninguna |
| 11 y 13 | Dependencia de estrategia **con trampa** (ya conocida) | quien compra la Disruptora temprano | El bot gasta en Disruptoras en lugar de daño (T217, T229) | Pendiente de Lucas (RF-475, punto 8); fuera de esta auditoría |

## 7. Partidas humanas para validar (G8)

El bot no es una persona: no mira la próxima oleada, no cambia de plan y no vende. **Lucas tiene que jugar** las partidas siguientes, en una build con los ajustes que apruebe, **con un guardado nuevo** (campaña desde cero, para ver las presentaciones de enemigos como las ve un tester). Anotar en cada una: si ganó, vidas, en qué oleada perdió vidas y si en algún momento sintió que «no había forma».

| # | Partida | Cómo jugarla | Qué confirmar |
|---|---|---|---|
| 1 | **1 → 2 → 3** seguidos, jugando «natural» | Sin plan previo, como un tester nuevo; usar las torres que parezcan buenas. | Que el 2 sea más difícil que el 1 pero **no un muro**, y que el 3 no se sienta más fácil que el 2. |
| 2 | **2** con torres variadas | Mezclar Eléctrica, Múltiple, Incendiaria y alguna Ametralladora; poco Cañón y Francotirador. | Que con A se gane sin depender del Cañón (en el bot, `mix` V16). |
| 3 | **2** solo con Ametralladoras | Todas Ametralladoras, bien puestas. | Que **se pierda** (es lo buscado) y que al perder se entienda por qué (el Jefe y la armadura). |
| 4 | **6 → 7 → 8** seguidos, jugando «natural» | Como la 1. | Que el 7 sea el más exigente de los tres pero no un muro, y que el 8 se sienta como respiro al presentar el Guardián. |
| 5 | **7** con las cuatro torres clásicas | Solo Ametralladora, Cañón, Hielo y Francotirador. | Que con el ajuste se gane con poco margen (en el bot, `smart` V5–6) y que hoy se pierda en la 18 (control). |
| 6 | **7** mejorando temprano | Pocas torres y mejorarlas pronto. | Que siga ganándose (bot: V9–11). |
| 7 *(opcional)* | **9** demoliendo mucho | Demoler todo lo que se pueda antes de la oleada 10. | Si la «trampa de demoler» de §3.3 también le pasa a una persona. |

Si alguna de estas partidas contradice al bot, **manda la partida humana** y se reabre la propuesta antes de reenviar al tester.

## 8. Requisitos que habría que cambiar (no se escriben acá)

Si Lucas aprueba los ajustes, la tarea 📜 que los especifique (M59 en `specs/12-plan-t262-t268.md`) tendría que tocar:

1. **`01-spec.md` §7.2 (nivel 2):** la fila de la oleada 15 de la tabla de oleadas (hoy «2 × Jefe … + 12 × Blindado (cada 0.8 s, tras 10 s)»).
2. **`01-spec.md` §7.4:** la fila del nivel 2 de la tabla de aumento y resultados del bot, y el párrafo «Con las 8 torres (M5, bot "mix")… 2 pierde en la última oleada».
3. **`01-spec.md` §7.9 (nivel 7):** las filas de las oleadas 2, 11 y 18 de su tabla.
4. **RF-487** (Cuadrilla): no cambia ninguna aparición, pero conviene anotar que la oleada 11 del 7 lleva 22 Rápidos en lugar de 30.
5. **Asedio (RF-495 y la tabla de porcentajes de T258):** remedir los mapas 2 y 7 con su política y, si quedan más fáciles que sus vecinos, subir su porcentaje (§5.3).
6. **Requisito nuevo, si Lucas lo quiere:** un consejo de contramedida en el cartel de entrada de algunos niveles (2 y 7 como mínimo). Es una sugerencia de Claude, no algo pedido: quedó anotada en `01-spec.md` §13 («Sugerencias de Claude, consultar antes de implementar») y no se implementa sin su OK.
7. **Disruptora (fuera de esta auditoría, ya pendiente):** RF-452 y RF-475, punto 8. Si Lucas decide tocar su costo, su supresión o la regla de compra del bot, remedir 11 a 15 con `mix`.
8. **Documentos de jugador:** `CHANGELOG.md` («el nivel 2 y el 7 se ajustaron»), y donde `README.md`, `ONBOARDING.md` o `CONTENIDO.md` citen resultados del bot de esos niveles.

## 9. Lo que no se probó

- **Ninguna persona jugó.** Todo es del bot, que no reacciona a la próxima oleada ni cambia de estrategia a mitad de partida.
- **Una sola variante combinada por nivel en el 7** (la que se propone); no se buscó la mínima cantidad de Rápidos que alcanza.
- **`basic` solo en 1 a 5, `smart` solo en 1 a 10, `demoler` solo en 7 a 10, `extraer_temprano` solo en el 10.** Del 11 al 15 no hay Ametralladora, así que `smart` y `basic` no se pueden jugar ahí.
- **`heavy`** (Mortero en todos los mapas) no se jugó: los niveles 1 a 8 no ofrecen el Mortero y no representa una opción real.
- **El modo Asedio** solo se miró como efecto colateral en los mapas 2 y 7 (§5.3); su curva completa es T255/T258.
- **Rendimiento:** las baterías compartieron la máquina con la medición de FPS de otra tarea; eso no cambia resultados (el paso es fijo) pero sí los tiempos.

## Apéndice · Cómo reproducir

Base (desde la carpeta del proyecto, una partida por proceso):

```bash
nice -n 19 godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix level=2 seed=1 report=/ruta/L2_mix_none_s1.json
nice -n 19 godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- smart level=7 seed=3 mejoras=llenar report=...
```

Variantes: copiar el proyecto fuera del repositorio, crear el archivo de nivel modificado (por ejemplo `tools/t266/l02_final_suave.json`) y jugarlo con `file=`:

```bash
nice -n 19 godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- mix file=tools/t266/l02_final_suave.json level=2 seed=1
```

Las variantes, en detalle (cambios sobre el archivo actual):

| Archivo | Cambio |
|---|---|
| `l02_a28`, `l02_a30`, `l02_a32` | `"aumento_vida": 28`, `30` o `32` |
| `l02_jefe1` | Oleada 15: `{"enemigo": "boss", "cantidad": 1, "cada": 3.0}` |
| `l02_final_suave` (A) | Oleada 15: Jefe `cantidad` 1 y se quita el grupo `{"enemigo": "armored", "cantidad": 12, "cada": 0.8, "desde": 10.0}` |
| `l02_a30_jefe1` (B) | `"aumento_vida": 30` y oleada 15 con 1 Jefe |
| `l07_viejo` | `git show 1bfd5e1:data/levels/level_07.json` |
| `l07_a20` | `"aumento_vida": 20` |
| `l07_o11` | Oleada 11: `fast` (entrada A) `cantidad` 30 → 22 |
| `l07_o2_o11` | Además, oleada 2: los dos grupos `fast` 15 → 10 |
| `l07_o2_o11_o18` (propuesta) | Además, oleada 18: `fast` 40 → 30 y `flyer` (entrada B) 25 → 20 |
