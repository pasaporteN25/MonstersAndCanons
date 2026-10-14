# T251 · Conceptos de un grupo de enemigos nuevo (y si de verdad ayudaría a Asedio)

> **Estado: INFORME PARA QUE ELIJA LUCAS.** Escrito el 2026-10-09 por Claude (Sonnet 5.5), tarea **T251** (📜, previa a la spec). Acá **no hay `RF` ni `D`**: se escriben recién cuando Lucas elija (los números libres son **RF-485** y **D-094**, verificados con `git grep` en todas las ramas locales y de `origin`: lo más alto es RF-484 y D-093). **No se programó nada** y no se cambió ningún dato del juego.
>
> **Pedido de Lucas (2026-10-09):** en Asedio el bot no gana ninguno de los mapas 10 a 15 al 115 % de vida. En vez de mandar oleadas muy grandes, Lucas propone **enemigos nuevos basados en el lore**, por ejemplo **una tribu organizada de ladrones** o de enemigos parecidos a ladrones.

## 0. Resumen (para quien lea solo esto)

1. **Los datos dicen que ningún enemigo nuevo, por sí solo, hace ganable Asedio al 115 %.** El bot (`sin_recursos`) pierde los **6 de 6** mapas (10 a 15) en Asedio real. Aguanta entre **+0 % y +8 %** de vida según el mapa (el 13 y el 15 ni llegan a +3 %); el modo pide **+15 %** (§2.3). Un grupo nuevo cambia **de qué está hecha** la oleada, no cuánta vida hay que romper.
2. **Las «oleadas muy grandes» son grandes en cantidad, pero no en vida:** Normales, Rápidos, Voladores y Crías son solo el **10 a 15 %** de la vida total de los mapas 10 a 15; la masa está en Tanques, Guardianes, Soberanos y Trolls (§2.4). Reemplazar los chicos por una banda no libera el 15 % que pide el modo.
3. **El bot deja miles de oro sin gastar** (1000 a 3900 en 4 de los 6 mapas) **porque nunca mejora torres** (se comprobó en el código). Una persona sí las mejora. **Con solo gastar ese oro en mejoras, el bot gana Asedio al 115 % en 3 de los 6 mapas (10, 14 y 15)** (§2.5). Así que «el bot no gana» **no prueba** que Asedio sea injusto para una persona, ni que falten enemigos.
4. Se proponen **tres conceptos, todos sin código nuevo** (solo archivos `.tres`): **A · La Cuadrilla** (banda de criaturas independientes, respeta la biblia), **B · Los Correos** (un grupo de los Moradores: **hay que enmendar la biblia**) y **C · Las Luminarias** (otra banda independiente, que no se frena con Hielo). Ver §4.
5. **Recomendación (§7): no hacerlo en la V1 como arreglo de Asedio.** Si Lucas igual quiere un grupo nuevo, el mejor es **B · Los Correos** (un solo enemigo que dibujar, el que mejor responde a «pocos y que importen» y a una señal del juego que hoy no tiene desenlace), con **A** como plan B sin enmiendas. Para Asedio hay palancas más baratas que no necesitan enemigos (§7.2).
6. Hay **cinco preguntas** para Lucas al final (§8).

---

## 1. Lo que ya está decidido (no se discute acá)

- **Biblia (10 §4):** cuatro capas de habitantes. La capa 2, **criaturas independientes**, «no pertenecen a ninguna comunidad y no obedecen a nadie» (07 §2.3, canon). La capa 3, **comunidades organizadas** (Moradores), tiene tres oficios: **protegen** (Guardián), **curan** (Curandero) y **coordinan** (Chamán). El **Ladrón** es una criatura independiente y **nunca lleva el símbolo A**, para no confundirlo con el Chamán (los dos encapuchados). El **Espejo** es la otra independiente.
- **Texto aprobado por Lucas (`11-textos-lore.md`, artículo 5, «Las criaturas que van solas»):** *«El Ladrón, por ejemplo, **va solo**, con una capa gris y una bolsa… No obedecen a nadie, y nadie sabe cuántas hay.»* Esto importa para el concepto A (§4.1).
- **Tono (10 §8):** sin caricaturas, ni colonos héroes ni habitantes villanos; consecuencias, no sentencias; textos breves.
- **Regla de oro (RF-432, ficha de cada nivel, punto 8):** la contramedida de cualquier enemigo tiene que estar **entre las torres comunes**, para que `sin_recursos` (sin Disruptora, Mortero ni Mecánico) pueda ganar al menos 4 de 5.
- **Criterio del 07 (§9 y §13.8):** «Varias torres nuevas: intención de variar la lógica, no autorización para producir un catálogo **sin definir funciones**», y «Enemigos/grupos nuevos» figura como decisión pendiente. Lo aplico igual a los enemigos: **función y contramedida primero, arte después**. *(El pedido hablaba de un «punto 9»; no encontré una regla literal con ese número que diga «un enemigo nuevo solo después de definir función y contramedidas». Lo que existe es el criterio de §9 para torres y la decisión pendiente 8 de §13. Uso ese espíritu.)*
- **Asedio (RF-391, D-078, Q-37):** Lucas respondió «sí» a que tenga los 15 mapas (Q-37). RF-391 dice que son «los mapas de la campaña con sus mismas oleadas y monstruos con más vida» y que **«no es balance definitivo»**. Hoy tiene los mapas 1 a 9 (T235 no sumó el 10 a 15 y lo dejó como decisión de Lucas).
- **Qué puede hacer un modo (RF-388):** un `modo.json` con una lista de mapas, **que se buscan primero en la carpeta del modo** y, si no están, entre los niveles oficiales; y tres reglas: `oro_inicial_%`, `vidas` y `vida_monstruos_%` (**una sola para todo el modo**). Esto abre una puerta que usan §5 y §7.2: un modo puede traer **su propia copia** de un mapa, con otras oleadas, sin código.

## 2. Qué dicen los datos (medido en esta rama, 2026-10-09)

Todo con el bot de `tools/balance_sim.gd`, estrategia `sin_recursos` (la de la regla de oro), **semilla 1** (las semillas dan siempre lo mismo en estos mapas, según T229 a T234), sobre `feature/integracion-v1` sin cambios. La partida «a 100 %» reproduce exactamente las vidas que anotaron T229 a T234 (10: 9 · 11: 6 · 12: 5 · 13: 6 · 14: 3 · 15: 2).

### 2.1 Qué pide el 115 % en «puntos de aumento por oleada»

La vida de un enemigo en la oleada *w* es `base × (1 + aumento × (w − 1))` (RF-36); Asedio multiplica eso por 1,15. Para compararlo con las tablas de T229 a T234, que se afinaron moviendo el `aumento_vida`, lo traduzco: **¿a qué `aumento_vida` equivale el 115 % en la última oleada?**

| Mapa | Oleadas | `aumento_vida` hoy | Equivalente con 115 % | Puntos de más | Lo que se sabía por T229–T234 |
|---|---|---|---|---|---|
| 10 · La mina vieja | 20 | 30 % | 35,3 % | +5,3 | `sin_recursos` termina con 9 vidas |
| 11 · Puesto seco | 22 | 27 % | 31,8 % | +4,8 | con 28 % gana con 1 vida: «margen de 1 punto» |
| 12 · El cañadón | 24 | 27 % | 31,7 % | +4,7 | «precipicios»: un Soberano que escapa cuesta 10 vidas de golpe |
| 13 · Paso alto | 24 | 40 % | 46,7 % | +6,7 | con 41 % y 42 % gana con 1 vida; con 44 % pierde |
| 14 · Los poblados vacíos | 26 | 30 % | 35,1 % | +5,1 | con 30 % gana con 3 vidas; con 33 % pierde |
| 15 · La Central | 30 | 23 % | 27,0 % | +4,0 | con 23 % gana con 2; con 24 % pierde |

**Lectura:** los mapas 11 a 15 se dejaron, a propósito, al borde (margen de 1 punto de aumento: T229 a T234 lo anotan en cada Resultado). El 115 % les pide **de 4 a 7 puntos más**. No es que Asedio sea «un poco más difícil»: es **de 4 a 7 veces el margen** que dejó cada nivel.

### 2.2 El bot en Asedio real (modo `asedio` con los mapas 10 a 15 sumados, solo para medir; el archivo quedó como estaba)

| Mapa | Resultado | Oleada | Oro sobrante al perder |
|---|---|---|---|
| 10 | derrota | 18/20 | **2054** |
| 11 | derrota | 14/22 | 70 |
| 12 | derrota | 20/24 | **1039** |
| 13 | derrota | 20/24 | 67 |
| 14 | derrota | 23/26 | **2859** |
| 15 | derrota | **30/30** (en la última) | **3881** |

**0 de 6**, igual que midió T235 con `mix` (T235 anotó 11/24 en el 12; acá con `sin_recursos` llega a la 20: el bot depende de su estrategia).

### 2.3 Hasta qué porcentaje gana el bot (barrido, misma estrategia)

Mismo bot y misma semilla, mapas 10 a 15 con la vida de los monstruos al 100, 103, 105, 108, 110 y 115 % (el porcentaje del modo, aplicado igual que Asedio, RF-388). «V*n*» = victoria con *n* vidas; «D *w*/*t*» = derrota en la oleada *w* de *t*.

| Mapa | 100 % | 103 % | 105 % | 108 % | 110 % | 115 % | Hasta dónde gana |
|---|---|---|---|---|---|---|---|
| 10 | V9 | V7 | V4 | V1 | D 18/20 | D 18/20 | **108 %** |
| 11 | V6 | V1 | V3 | D 20/22 | D 14/22 | D 14/22 | **105 %** |
| 12 | V5 | V1 | D 22/24 | D 22/24 | D 22/24 | D 20/24 | **103 %** |
| 13 | V6 | D 22/24 | D 22/24 | D 22/24 | D 20/24 | D 20/24 | **menos de 103 %** |
| 14 | V3 | V4 | D 26/26 | D 26/26 | D 26/26 | D 23/26 | **103 %** |
| 15 | V2 | D 30/30 | D 30/30 | D 30/30 | D 28/30 | D 30/30 | **menos de 103 %** |

**Lectura:** el bot aguanta entre **+0 % y +8 %** de vida según el mapa (el 10 es el más holgado, el 13 y el 15 no llegan a +3 %); Asedio pide **+15 %**. Para que el bot ganara habría que bajar el porcentaje a **100 o 103 %** en la mayoría de estos mapas, o sea a «casi la campaña normal». (Las vidas no bajan siempre en orden —por ejemplo el 14 termina con 4 vidas a 103 % y con 3 a 100 %—: es ruido de una sola semilla, y por eso doy el límite como «hasta dónde gana» y no como una curva.)

### 2.4 Dónde está la vida: las «oleadas grandes» no son las pesadas

Sumé, para cada mapa, la vida total (ya escalada por oleada) de **todas las oleadas** y la repartí por tipo de enemigo:

| Mapa | Vida total | Relleno (Normal + Rápido + Volador + Cría) | Tanque | Soberano | Troll | Guardián | Coloso + Pedazos | Ladrón |
|---|---|---|---|---|---|---|---|---|
| 10 | 130 490 | **14 %** | 15 % | 17 % | 15 % | 16 % | — | 0,23 % |
| 11 | 129 009 | **13 %** | 17 % | 18 % | 14 % | 15 % | — | 0,19 % |
| 12 | 160 522 | **11 %** | 26 % | 12 % | 12 % | 14 % | — | 0,15 % |
| 13 | 223 800 | **10 %** | 23 % | 12 % | 12 % | 17 % | — | 0,10 % |
| 14 | 243 045 | **13 %** | 23 % | 13 % | 9 % | 17 % | — | 0,17 % |
| 15 | 301 543 | **15 %** | 29 % | — | 8 % | 12 % | 17 % | 0,08 % |

(En unidades sí son muchas: el 14 manda **166 Voladores** y el 15 manda **220**, y 162 Rápidos; pero un Volador es 18 de vida contra los 135 de un Tanque.) **Consecuencia:** aunque una banda nueva reemplazara *todo* el relleno, se liberaría el 10 al 15 % de la vida, que es justo lo que pide el 115 % de *más*. Para que un grupo nuevo alivie algo hay que usarlo **en lugar de Tanques, Guardianes y Soberanos**, o sea rehacer las oleadas, no agregarle una banda.

### 2.5 El bot no mejora las torres

- En `tools/balance_sim.gd` **no hay ninguna llamada a mejorar ni a vender** (`grep -i "upgrade\|vend\|sell"` da solo comentarios): el bot compra torres de nivel 1 hasta llenar el mapa y **ahí se queda mirando el oro**. T235 ya lo dijo: «el bot no sabe gastarlo mejor».
- Las torres tienen 3 niveles. Ejemplo del Francotirador: construirlo cuesta 150 (40 de daño); la mejora a nivel 2 cuesta **150** (70 de daño, +75 %) y la de nivel 3, **225** (120, +71 %). Con 2000 a 3900 de oro sobrante, una persona convierte las casillas llenas en torres de nivel 2 o 3: **mucho más daño por casilla**, que es justo lo que falta cuando el mapa está lleno.

**Experimento (copia temporal del bot, fuera del repositorio; el código está en el Apéndice):** cuando no quedan casillas libres, el bot gasta el oro en mejorar la torre de menor nivel que pueda pagar (sin ninguna otra inteligencia). Mismas partidas, `sin_recursos`, semilla 1:

| Mapa | 115 % sin mejoras | **115 % con mejoras** | 125 % con mejoras | 135 % con mejoras |
|---|---|---|---|---|
| 10 | D 18/20 | **V10** | D 18/20 | D 13/20 |
| 11 | D 14/22 | D 14/22 | D 14/22 | D 10/22 |
| 12 | D 20/24 | D 20/24 | D 11/24 | D 10/24 |
| 13 | D 20/24 | D 20/24 | D 14/24 | D 13/24 |
| 14 | D 23/26 | **V14** | D 22/26 | D 16/26 |
| 15 | D 30/30 | **V5** | D 30/30 | D 27/30 |

**Con solo gastar el oro sobrante, Asedio al 115 % pasa a ser ganable por el bot en 3 de los 6 mapas (10, 14 y 15)**, justo los que tenían más oro sin usar. Los mapas 11 y 13 no cambian (no tenían oro: sobraban 70 y 67). El 12 tampoco, aunque sobraba oro (1039): la derrota es en la oleada 20, antes de que el mapa se llene y se junte oro; no se investigó por qué. A 125 % y 135 % siguen perdiendo todos: **el 115 % no es imposible, pero está cerca del límite** incluso con mejoras. **Esto no es una prueba de nada sobre personas ni cambia el balance de la campaña**: es la medida de que el instrumento tiene un límite propio.

### 2.6 Qué dicen los datos, todos juntos

1. El 115 % pide mucho más margen del que dejó cada nivel (§2.1), y el bot lo pierde en los 6 mapas (§2.2).
2. En **4 de los 6 mapas el bot muere con el mapa lleno y miles de oro sin usar**: el límite ahí es **el espacio y la falta de mejoras del bot**, no la plata (y en 3 de ellos, gastarlo en mejoras alcanza para ganar al 115 %). En los otros dos (11 y 13) sí se queda sin oro (sobran 70 y 67) y las mejoras no cambian nada.
3. Una tabla del bot **no es una prueba para una persona** (lo dicen T225, T229 y T235), y esta tampoco.

---

## 3. Con qué se compara (datos de hoy, `data/enemies/*.tres`)

Lo que **ya hace** cada enemigo (campos de `EnemyData`). Un concepto nuevo tiene que hacer algo que **no esté en esta tabla**:

| Enemigo | Capa | Función (qué obliga a hacer al jugador) | Campos |
|---|---|---|---|
| Normal | bestia | relleno, ritmo | — |
| Rápido | bestia | llegar antes que la defensa se acomode | `speed` 3,0 |
| Tanque | bestia | aguantar | `max_health` 135 |
| Blindado | bestia | anular golpes chicos | `armor` 3 |
| Volador | bestia | ignorar el camino | `is_flying` |
| Troll | bestia | curarse solo (el fuego lo corta) | `regen_percent_per_second` |
| Araña / Cría | bestia | enjambre al morir | `death_spawn` |
| Embestidor | bestia | desgastar una torre en el giro | `charge_*` |
| **Ladrón** | **independiente** | **robar oro mientras esté en pantalla** (1 por oleada, 25–55 %) | `gold_drain_*`, `optional_wave_limit` |
| **Espejo** | **independiente** | devolver los tiros y aturdir | `reflect_*` |
| Guardián | Morador | dar armadura a los de al lado | `aura_armor_bonus` |
| Curandero | Morador | curar a los de al lado | `aura_heal_percent_per_second` |
| Chamán | Morador | aturdir **una** torre cada 8 s | `stun_*` |
| Soberano | bestia (jefe) | vida, armadura, resiste la mitad del Hielo | `slow_resistance` 0,5 |
| Coloso / Pedazo | ambiguo | castigar al que juega con una sola idea (se parte en 3) | `death_spawn` |

**Huecos que se pueden cubrir sin código** (con campos que ya existen): (1) **que cada fuga duela mucho con poca vida** (`lives_damage` hoy va de 1 a 4, salvo los jefes); (2) **ser inmune al Hielo** (`slow_resistance` acepta hasta 1,0; hoy el máximo es 0,5); (3) **robo en cantidad** (`gold_drain_*` sin el límite de uno por oleada, que solo aplica si el grupo es opcional). Los tres conceptos salen de ahí. Lo que **sí** pediría código y se descartó: una aura de velocidad («Arrieros»), el aturdimiento de varias torres a la vez («Vocero», ya descartado en T243), detenerse a cavar («Zapadores») y el sigilo.

---

## 4. Los tres conceptos

Los nombres son **de informe** (los puede cambiar Lucas). Los números son **iniciales y tentativos**: no se midieron con el bot en un mapa con el grupo puesto (la tarea no programa). Para tener una referencia, a la oleada 20 de un mapa con 30 % la vida se multiplica por 6,7.

### 4.1 A · «La Cuadrilla» — una banda de ladrones sin jefe *(la idea de Lucas, adaptada a la biblia)*

**Qué es y a qué capa pertenece.** Criaturas **independientes** (capa 2) parecidas al Ladrón, pero de **otra especie**: los **Rateros** (chicos, rápidos, andan juntos) y el **Cargador** (grande, lento, lleva la bolsa de todos). Los colonos las llaman «cuadrilla» porque aparecen juntas, pero **no hay jefe, ni mando, ni símbolo A**: se juntan por lo mismo que cada una busca (lo que brilla). Eso respeta «no obedecen a nadie» (07 §2.3).

- **Por qué NO una «tribu organizada».** Una tribu que se organiza es, por definición, de la capa 3 (Moradores). Si fuera de la capa 3, un grupo de Moradores que **roba** convertiría a los habitantes en ladrones, que es lo que 10 §8 pide evitar («ni habitantes villanos»). Con una banda independiente la ambigüedad moral del juego queda intacta.
- **Por qué otra especie y no «más Ladrones».** El artículo aprobado de la Wiki dice que el Ladrón **«va solo»**. Si aparecieran muchos Ladrones juntos, ese texto dejaría de ser cierto y habría que corregir un texto que Lucas ya aprobó. Con una especie nueva, el Ladrón sigue solo y el texto no cambia («Los Rateros, en cambio, andan en cuadrilla»).
- **Regla de arte que heredan:** nunca llevan el símbolo A (extiende la regla del Ladrón). Se distinguen de él por tamaño y color (el Ladrón es gris violeta con capa y bolsa; el Ratero es más chico y sin capa; el Cargador es ancho, con la bolsa más grande que el cuerpo).

**Función propia.** Hoy el robo es un **hecho aislado** (un Ladrón, máximo uno por oleada, con 25 a 55 % de probabilidad, que aporta 0,1 a 0,2 % de la vida total del nivel). La Cuadrilla lo convierte en **presión económica simultánea**: varios drenajes a la vez, y un objetivo que **conviene matar primero** (el Cargador, porque cada segundo vivo cuesta oro). Es la función **menos nueva** de las tres: escala la del Ladrón, y lo digo con franqueza (calificación: media-baja). Lo que sí cambia es la jugada: ya no alcanza con «dejar que las torres peguen al primero».

**Contramedida entre las torres comunes.** Daño rápido y de área contra los Rateros (**Múltiple, Ráfaga, Eléctrica, Cañón**); **Hielo** (no resisten); **Francotirador o Cañón** contra el Cargador (armadura 1). Ninguna es de recursos: `sin_recursos` puede.

**Campos de `EnemyData` que usa.** Todos existentes: `max_health`, `speed_tiles`, `armor`, `reward`, `lives_damage`, `gold_drain_amount`, `gold_drain_interval`, `gold_drain_floor`, `size_tiles`, `texture`, `walk_atlas`. **Código nuevo: ninguno.** (La Wiki ya escribe sola la línea «Robo», `wiki.gd:106`.)

| ID | Vida | Velocidad | Armadura | Oro | Vidas | Robo | Tamaño |
|---|---|---|---|---|---|---|---|
| `ratero` | 14 | 2,2 | 0 | 5 | 1 | 2 de oro cada 2 s, piso 10 | 0,20 |
| `cargador` | 110 | 0,9 | 1 | 30 | 2 | 4 de oro cada 2 s, piso 10 | 0,33 |

Con `optional_wave_limit = 0` (el límite de uno por oleada solo vale para grupos con probabilidad, `wave_spawner.gd:61`). Ejemplo de una oleada: 8 Rateros + 1 Cargador. Si ninguno muere, el Cargador solo roba ~2 de oro por segundo; los 8 Rateros, ~8 por segundo (cada uno 1 por segundo). **Una cuadrilla entera sin matar en un camino de 70 casillas cuesta del orden de 200 a 400 de oro por oleada.**

**Cómo se usaría.** Debutaría en el 11 o el 12 (donde el oro sí es justo: el bot termina con 70 y 67 en el 11 y el 13) o solo en Asedio. En los mapas 10, 12, 14 y 15 el robo **no muerde al bot** (termina con 1000 a 3900 de oro). Aparece en la Wiki en la sección de criaturas.

**Tono (ejemplo, no es el texto final):** *«Los Rateros no van solos, como el Ladrón. Tampoco obedecen a nadie: van juntos porque buscan lo mismo.»*

**Qué puede salir mal.** (1) Es **el más parecido a algo existente**; el que más riesgo tiene de sentirse «más Ladrón». (2) El robo no mata: si el jugador está sobrado de oro (como el bot), **no tiene dientes**. (3) Con muchos Rateros chicos y rápidos hay riesgo de «tiempo de espera» sin tensión.

### 4.2 B · «Los Correos» — los que avisan *(un grupo de los Moradores; hay que enmendar la biblia)*

**Qué es y a qué capa pertenece.** Un grupo de la capa 3, **Moradores**: corredores livianos que llevan **avisos** entre los poblados. La biblia ya dejó la pista: el **poste con cintas** del nivel 4 «es una señal para otros: avisa algo» (10 §6). Los Correos son *quienes llevan ese aviso*. No tienen arma ni escudo: corren.

- **Qué hay que enmendar en la biblia (y lo digo claro).** 10 §4.3 dice que las comunidades tienen **tres oficios** (protegen, curan, coordinan) y 10 §4.3 (P-1) los lee como una **alianza de tres pueblos**. Esto agrega un **cuarto oficio: «avisan»**. Cambios: una línea en §4.3 («Los tres oficios» pasa a cuatro), la frase de P-1 («alianza de tres pueblos» → «de cuatro») y una línea en `07` §2.4. **No toca el canon fijo** de §9 («cuatro capas», símbolo A, desenlace ambiguo). Pero es una enmienda a un documento que Lucas aprobó en G2, así que **tiene que aprobarla él**.
- **Lleva el símbolo A** (es de los Moradores). Se distingue del Chamán (el otro encapuchado con A) por la silueta: **sin capucha, de pie, con la cinta al viento**.
- **Encaja con el tono:** no es un villano ni hace daño por maldad; lleva un aviso. Que su fuga cueste vidas es una consecuencia mecánica (el aviso llegó), no un juicio.

**Función propia.** **«Pocos, y cada uno importa»**: poca vida y mucha velocidad, pero **cada uno que llega quita 3 vidas** (el Rápido quita 1; hoy ningún enemigo común pasa de 2 con velocidad). Cambia el **presupuesto de vida por presupuesto de fugas**: obliga a **cubrir el camino entero**, no solo a tener daño bruto. Ningún enemigo actual hace eso (el Rápido es relleno; el Embestidor y el Soberano son lentos). Calificación: **media-alta**.

**Contramedida entre las torres comunes.** **Hielo** (no resisten: frena a los que van a 2,6), **Eléctrica, Múltiple y Ráfaga** (muchos golpes baratos, no tienen armadura), **Francotirador** (alcance 6 para el primer golpe) y **tener cobertura repetida** a lo largo del camino. Todo común.

**Campos de `EnemyData` que usa.** `max_health`, `speed_tiles`, `reward`, `lives_damage`, `size_tiles`, `texture`, `walk_atlas`. **Código nuevo: ninguno.** (Un efecto de «alarma», que el aviso llegado apure a la oleada siguiente, sí sería código y **no se propone**.)

| ID | Vida | Velocidad | Armadura | Oro | Vidas | Tamaño |
|---|---|---|---|---|---|---|
| `correo` | 24 | 2,6 | 0 | 14 | 3 | 0,22 |

Un solo enemigo; el «grupo» son varios Correos juntos. Ejemplo: 4 a 6 por oleada, a veces con una escolta existente. A la oleada 20 de un mapa con 30 %: 24 × 6,7 ≈ 160 de vida, a 2,6 casillas por segundo; se escapa 3 vidas por cada uno.

**Cómo se usaría.** Debutaría en el 13 o el 14 (donde el lore dice «ataques coordinados» y «se fueron»): son *los que dan el aviso de retirarse*, y en el 14 los poblados están vacíos. En Asedio puede reemplazar parte del relleno por menos unidades que importen más.

**Tono (ejemplo):** *«Los colonos los llaman Correos. Corren por el camino con una cinta atada al brazo. Cuando llegan, otros se mueven.»* (muestra una consecuencia y no concluye.)

**Qué puede salir mal.** (1) **3 vidas por fuga con 20 vidas** es muy castigador si el jugador no tiene cobertura: dos fugas y media pierden el 40 %; hay que medirlo con el bot (el Pedazo del Coloso quita 4 y el bot nunca dejó pasar ninguno, T234). (2) Se parece al Rápido en velocidad: la diferencia es la **fuga letal**, y hay que dibujarlo para que se lea distinto. (3) Requiere la enmienda a la biblia.

### 4.3 C · «Las Luminarias» — las que el Hielo no frena *(otra banda independiente, «mágica»)*

**Qué es y a qué capa pertenece.** Criaturas **independientes** (capa 2, la de «seres especiales o mágicos», 07 §2.3): pequeñas luces frías que **se acercan a la energía**. Por eso aparecen cerca de la **mina** (10), de los **pozos** y, sobre todo, de **La Central** (14 y 15, «energía y abastecimiento»). Hacen eco de dos pistas de la biblia: el Ladrón «busca lo que brilla» y el Espejo es de cristal. **No llevan A, no obedecen a nadie.**

**Función propia.** **El Hielo no sirve contra ellas** (`slow_resistance = 1,0`). Ningún enemigo actual es inmune a la ralentización (el Soberano y el Coloso la resisten **a medias**, 0,5). Es la única función que **ataca una torre entera** en vez de a una casilla: el Hielo, que está en la apertura obligatoria de los mapas 11 a 15 (RF-474). Calificación: **alta** en novedad.

**Contramedida entre las torres comunes.** **Daño por cobertura**: más torres a lo largo del camino y área (**Cañón, Eléctrica, Múltiple, Ráfaga**); la **Incendiaria** las quema (la quemadura no depende de la ralentización). El Francotirador pega el primer golpe a distancia. Todo común.

**Campos de `EnemyData` que usa.** `slow_resistance` (ya existe, rango 0 a 1), `max_health`, `speed_tiles`, `reward`, `lives_damage`, `size_tiles`, `texture`, `walk_atlas`. **Código nuevo: ninguno.** Falta comprobar que la Wiki y el panel escriben bien «No se frena» con 1,0 (hoy el texto de la resistencia probablemente dice «la mitad»): sería un ajuste menor de texto, no de reglas.

| ID | Vida | Velocidad | Armadura | Oro | Vidas | Resistencia al Hielo | Tamaño |
|---|---|---|---|---|---|---|---|
| `luminaria` | 22 | 1,6 | 0 | 7 | 1 | 1,0 | 0,20 |
| `farol` | 100 | 1,1 | 0 | 24 | 2 | 1,0 | 0,30 |

**Cómo se usaría.** Debutaría en el 10 o el 14. **No más de un tercio de cada oleada**, porque el Hielo es parte de la apertura que el juego ofrece (RF-474): si todo fuera inmune, la apertura quedaría castigada.

**Tono (ejemplo):** *«Cerca de la central hay luces que no se detienen con el frío. Los informes las llaman Luminarias. Se acercan a la corriente y no se sabe qué buscan.»*

**Qué puede salir mal.** (1) **Es la que más empeora el balance**: es una amenaza *extra* para la torre más usada del bot. (2) El **arte**: «criatura de luz» con alfa real y sin sombra dibujada (guía de arte) es más difícil de leer a 34 px que un cuerpo sólido. (3) Dos enemigos dibujar. (4) Si el Hielo ya está en 4 de las 5 estrategias del bot, puede romper la regla de oro (hay que medirlo).

### 4.4 Lo que no se propone (y por qué)

- **Una «tribu de ladrones» de los Moradores.** Es la lectura más literal del pedido, y **no la recomiendo**: choca con 10 §8 (habitantes villanos) y con la regla de que el Ladrón es una criatura independiente. Si Lucas la quiere igual, es un concepto A con otra piel: **mismos números**, y exige la misma enmienda que B (un oficio nuevo, «los que recuperan»). Habría que cuidar que los textos hablen de *recuperar* y no de *robar* (la colonia está sacando algo a alguien).
- **Aura de velocidad («Arrieros»), aturdir varias torres («Voceros»), detenerse a cavar («Zapadores»), sigilo.** Funciones más nuevas, pero **piden código** (campo nuevo en `EnemyData`, cambios en `enemy.gd`, tests y spec). El Vocero ya lo evaluó y descartó T243.
- **Un señuelo** (enemigo inofensivo que atrae los tiros): las torres tienen modo de puntería elegible por el jugador (`TargetMode`), así que el efecto sería chico.

---

## 5. ¿De verdad ayudaría a que Asedio al 115 % sea ganable?

**Respuesta honesta: no, ninguno de los tres por sí solo. Cambian la composición, no el presupuesto de vida.**

| | Qué cambia | ¿Libera el +15 % de vida? | ¿Con qué datos? |
|---|---|---|---|
| **A · Cuadrilla** | Suma presión de **oro**. | **No.** Y **empeora** los mapas 11 y 13, donde el oro es lo justo (sobran 70 y 67). En 10, 12, 14 y 15 no tiene dientes: el bot termina con 1000 a 3900 de oro. | §2.2 y §2.5 |
| **B · Correos** | Cambia vida por **fugas**. | **Parcial, y solo si se rehacen las oleadas.** Los Correos pesan poco (24 de vida); para ahorrar vida hay que sacar Tanques o Guardianes. El relleno es el 10 al 15 % de la vida (§2.4). Puede hacer las oleadas **más chicas**; que el bot las gane no está probado. | §2.4 |
| **C · Luminarias** | Suma una **amenaza extra** a la torre más usada. | **No: lo empeora.** El bot abre con Cañón + Hielo (T229). | §2.1 y T229 |

- **El único camino para que un grupo nuevo «ayude» es reemplazar vida pesada por mecánica barata** (sacar un Tanque y poner Correos). Eso es rehacer oleadas con el bot, como se hizo en T229 a T234 —con varias vueltas por mapa y «precipicios»—, y hay que decirlo: los mapas 11 a 15 se ajustaron con ese método y quedaron a 1 punto del borde.
- **Falta la prueba directa.** No se armó ninguna oleada con el grupo: sería una prueba nueva por concepto y por mapa, que corresponde a la tarea de balance (si Lucas elige). **La primera medida sería prototipar con la forma provisional** (RF-156: sin dibujo, el juego usa figuras de colores) y **el bot, antes de pagarle arte a Codex.**
- **Una consecuencia que conviene tener presente:** si el grupo vive **solo en Asedio** (mapas propios del modo), **no se ven los textos** (RF-468: Asedio no muestra textos de nivel), así que **el lore no se cuenta** en esa ruta, solo en la Wiki y en la tarjeta de presentación (RF-134). Para que cuente historia hay que debutarlo en un nivel de la campaña, y eso toca niveles que se ajustaron al milímetro, **justo antes de que Lucas los juegue (G5)**.

## 6. Costo estimado de cada concepto

«Tamaño» es una estimación de trabajo relativa (chico/mediano/grande), **no horas medidas**. Tomo como referencia T243 + T244 + parte de T234 para el Coloso (dos enemigos con ciclo de caminata): **cada enemigo con ciclo de caminata es un trabajo de arte mediano**.

| | A · Cuadrilla | B · Correos | C · Luminarias |
|---|---|---|---|
| **Enemigos** | 2 (`ratero`, `cargador`) | 1 (`correo`) | 2 (`luminaria`, `farol`) |
| **Spec 📜** (RF-485 en adelante, D-094, plan, §7 de la spec) | 1 tarea chica (3 RF: enemigos, contramedidas y uso; 1 D) | 1 tarea chica **+ enmienda de la biblia (aprobación de Lucas)** | 1 tarea chica |
| **Arte (Codex)** | 2 × (PNG de 256 + atlas de 16 poses + hojas de contacto): **mediano** | 1 × lo mismo: **chico-mediano** | 2 × lo mismo, **con efecto de luz**: **mediano-grande** |
| **Datos** | 2 `.tres` + oleadas | 1 `.tres` + oleadas | 2 `.tres` + oleadas |
| **Balance con el bot** | Mapas donde entra (11/12 o Asedio): **varias vueltas por mapa** | Ídem (13/14 o Asedio) | Ídem, **más riesgo de romper la regla de oro** |
| **Wiki** | Automática (+ un párrafo en el artículo 5 de Lore, **texto nuevo que debe aprobar Lucas** en `11-textos-lore.md`) | Automática (+ párrafo en un artículo de Lore) | Automática + ajustar el texto de la resistencia (1,0) |
| **Tests** | Agregar los ids a `test_enemy_visual.gd` (6 listas, ver el caso del Coloso) y un `test_cuadrilla.gd` de ~10 pruebas | Ídem, ~8 pruebas | Ídem, ~10 pruebas (incluye la resistencia 1,0) |
| **Documentos** | `CONTENIDO.md`, `README.md`, `ONBOARDING.md`, `CHANGELOG.md`, guía de arte (colores nuevos) | Ídem + `10-universo.md` §4.3 y P-1, `07` §2.4 | Ídem |
| **Código** | **Ninguno** | **Ninguno** | **Ninguno** |
| **Tamaño total** | **Mediano** (4 a 5 tareas) | **Mediano-chico** (4 tareas) + decisión de biblia | **Mediano-grande** (5 tareas) |

**Tareas típicas** (como las del Coloso): 📜 spec → 🎨 concepto y arte (Codex, con OK de Lucas) → datos + tests → balance con el bot → documentos. Todo lo que dice «varias vueltas» ya se vio en T229 a T234: cada mapa tuvo precipicios y se afinó cambiando composición.

## 7. Comparación y recomendación

| | A · Cuadrilla | B · Correos | C · Luminarias |
|---|---|---|---|
| **Respeta la biblia sin enmiendas** | **Sí** | No (cuarto oficio) | **Sí** |
| **Toca un texto ya aprobado** | No (si es otra especie) | No | No |
| **Función propia (no repite)** | Media-baja (escala al Ladrón) | **Media-alta** | **Alta** |
| **Contramedida en torres comunes** | Sí | Sí | Sí |
| **Código nuevo** | No | No | No |
| **Enemigos a dibujar** | 2 | **1** | 2 (con luz) |
| **Ayuda a Asedio al 115 %** | **No** (y empeora 11 y 13) | Parcial, rehaciendo oleadas | **No** (lo empeora) |
| **Riesgo de balance** | Bajo | **Medio** (3 vidas por fuga) | **Alto** (Hielo) |
| **Responde a «pocas unidades que importen»** | No | **Sí** | Parcial |
| **Se parece a la idea de Lucas** | **La más cercana** | Media | Lejana |

### 7.1 Recomendación

**No hacerlo en la V1 como arreglo de Asedio.** Razones, con los datos de §2:

1. **No resuelve el problema que lo motivó.** Asedio al 115 % pide de 4 a 7 puntos más de los que dejó cada nivel; el relleno es el 10 al 15 % de la vida; ningún concepto libera ese 15 % sin rehacer oleadas.
2. **El bot es un juez parcial** (no mejora torres y deja miles de oro sin gastar; con una regla mínima de mejoras gana 3 de los 6 mapas al 115 %, §2.5). Gastar arte y balance para que *el bot* gane es invertir en el instrumento, no en el juego.
3. **El tiempo.** Quedan T236 a T239 (regresión, marca, G5 de Lucas, publicación). Un enemigo nuevo en la campaña obliga a volver a ajustar mapas que están **al borde**, justo antes de que Lucas los juegue. Y el criterio de «primera entrega completa» (07 §12) **no menciona** Asedio ni enemigos nuevos.
4. **Si vive solo en Asedio, pierde el lore** que lo justifica (RF-468).

**Si Lucas igual quiere un grupo nuevo (para la V1 o para la entrega siguiente): B · Los Correos.** Es el que menos arte pide (un enemigo), el que más se acerca a «en vez de oleadas grandes, pocos que importen», el que cubre un hueco real de funciones y el que le da **desenlace a una señal que hoy no lo tiene** (el poste con cintas). Su costo es la enmienda de la biblia, que es chica pero es de Lucas. **Plan B sin enmiendas: A · La Cuadrilla**, con la advertencia de que es la idea más cercana a lo que pidió pero la que menos cambia la jugada.

### 7.2 Para Asedio hay palancas más baratas que no necesitan enemigos

(Son opciones para que decida Lucas; **no se implementó ninguna**. Las primeras tres son las de T235 con lo medido acá.)

- **(a) Dejar Asedio en 9 mapas.** Cero costo. Es lo que hay hoy; cumple RF-391 («prueba chica de modos»).
- **(b) Sumar solo los mapas que el bot gana al 115 %.** Hoy **ninguno** (§2.2); **con el bot que mejora torres, el 10, el 14 y el 15** (§2.5).
- **(c) Bajar el porcentaje del modo** o darle uno **por mapa** (hoy es uno solo para todo el modo; sería un cambio de RF-388/391, 📜). Según §2.3, para que el bot gane los seis haría falta **100 a 103 %**, o sea casi la campaña normal: el modo dejaría de ser «más duro».
- **(d) Que Asedio traiga su propia copia de los mapas 10 a 15** con `aumento_vida` más bajo (RF-388 ya busca primero en la carpeta del modo): es solo datos, pero RF-391 dice «mismas oleadas», así que también sería un cambio de RF.
- **(e) Enseñarle al bot a mejorar torres** (una mejora de `tools/balance_sim.gd`, no del juego) y volver a medir: la prueba de §2.5, hecha con una regla mínima, ya lo muestra. **Ojo:** las tablas de T229 a T234 se ajustaron contra el bot *sin* mejoras; con mejoras, todos los niveles se volverían más fáciles para el bot y habría que revisar la referencia. Lo anoté en las Sugerencias de Claude (§13 de la spec), **sin implementarlo**.

## 8. Preguntas para Lucas

1. **¿Hacemos un grupo de enemigos nuevo en la V1, o lo dejamos como semilla para la entrega siguiente?** (Mi recomendación: no en la V1.)
2. **Si se hace: ¿A (Cuadrilla), B (Correos) o C (Luminarias)?** (Si es B, necesito tu OK para agregar a la biblia un **cuarto oficio de los Moradores**, «los que avisan». Si es A, ¿te sirve que sean **Rateros**, otra especie, para que «el Ladrón va solo» siga valiendo?)
3. **¿Dónde?** ¿Solo en Asedio (con mapas propios del modo; cambia RF-391 y los textos no se ven) o también en un nivel de la campaña (hay que reajustar con el bot los niveles 11 a 14 antes de G5)?
4. **¿Qué hacemos con Asedio 10 a 15?** (a) dejarlo en 9, (b) sumar solo los que el bot gana, (c) bajar el porcentaje en esos mapas, (d) copias propias del modo, o (e) enseñarle al bot a mejorar torres y volver a medir.
5. **¿Querés que el grupo sea una «tribu» de los Moradores igual** (aunque yo lo desaconsejo: se parece a un villano) **o preferís que mantengamos a los ladrones como criaturas independientes?**

## 9. Qué se comprobó y qué no

**Se comprobó:**
- Todos los datos de enemigos (`data/enemies/*.tres`), los campos de `EnemyData` y que `slow_resistance` acepta hasta 1,0 (`@export_range(0.0, 1.0)`), que `optional_wave_limit` solo se aplica a grupos con probabilidad (`wave_spawner.gd:61`) y que el drenaje de oro lo procesa `enemy.gd`/`game.gd` sin límite de enemigos.
- Los números de vida por oleada, la equivalencia del 115 % (§2.1) y el reparto de la vida por tipo (§2.4) se calcularon de `data/levels/level_10.json` a `level_15.json` y `data/enemies/*.tres` con un script suelto (no queda en el repositorio).
- Las partidas del bot de §2.2, §2.3 y §2.5 se corrieron de verdad en esta máquina (Godot 4.7.2, `--headless --fixed-fps 60`); la línea de base a 100 % reproduce las vidas anotadas por T229 a T234.
- El bot no llama a mejorar ni a vender (`grep` en `tools/balance_sim.gd`).
- Los números libres RF-485 y D-094, y que T251 no existía en ninguna rama.

**No se comprobó:**
- **Ningún concepto se probó con el bot en un mapa con el grupo puesto.** Los números de vida, velocidad y cantidad son **iniciales y tentativos**; no hay oleadas escritas con ellos.
- **Una sola semilla** (la 1) en el barrido y en el experimento de mejoras; T229 a T234 observaron que en estos mapas las semillas dan siempre lo mismo, pero no se volvió a comprobar acá con 5.
- **El bot juzga a una máquina, no a una persona:** nadie jugó Asedio 10 a 15 a mano.
- **No se miró el arte** de ningún enemigo; las descripciones de silueta y colores son propuestas, no dibujos.
- **No se comprobó** cómo escribe la Wiki la resistencia 1,0 (concepto C) ni qué muestra la Wiki de un enemigo que solo aparece en Asedio (la línea «Nivel…» se deduce de la campaña).
- **Los tonos de ejemplo** de cada concepto son ilustraciones, no textos para cargar (los textos van en `11-textos-lore.md` y los aprueba Lucas).
- El nombre «punto 9» del pedido no se encontró literal (ver §1).

## Apéndice · el experimento de §2.5 (para repetirlo)

No se versiona. Es una copia de `tools/balance_sim.gd` guardada como `tools/_exp_bot.gd` con tres cambios (se borró al terminar):

1. Dos variables nuevas, `mp_override` y `upg_enabled`, y dos argumentos en `_apply_override`: `mp=N` (fija `enemy_health_percent` del nivel, igual que el modo; se usa con los mapas de la campaña sin tocar `modo.json`) y `upg=1` (enciende las mejoras).
2. En `_start_next_run`, después de elegir el nivel: `if mp_override > 0: game.level_data.enemy_health_percent = mp_override`.
3. En `_process`, después de `_buy_towers()`, una llamada a:

```gdscript
func _upgrade_surplus() -> void:
	if not upg_enabled:
		return
	if not _free_cells().is_empty():
		return
	var best: Node = null
	var best_key: int = 1 << 30
	for tower: Node in game.get_tree().get_nodes_in_group(&"towers"):
		if not tower.can_upgrade():
			continue
		var key: int = int(tower.level_index) * 100000 + int(tower.next_level_stats().cost)
		if key < best_key:
			best_key = key
			best = tower
	if best != null:
		game.build_controller.try_upgrade(best)
```

(Se usa el grupo `&"towers"` y `Node` sin tipo porque el bot se compila antes que los autoloads: nombrar `Tower` rompe la carga.) Comando: `godot --headless --path . --fixed-fps 60 -s tools/_exp_bot.gd -- sin_recursos level=14 seeds=1 mp=115 upg=1`.

**Un primer barrido descartado.** Antes usé el argumento `hp=` del bot para escalar la vida; resultó que **solo escala 6 tipos de enemigo** (Normal, Rápido, Tanque, Volador, Blindado y Soberano; no el Troll, el Guardián, el Curandero, etc.), así que **no equivale al modo** (con `hp=1.15` el bot ganaba los mapas 10 y 11, que en Asedio real pierde). Ese barrido se descartó y no se usó en ningún número de arriba; lo dejo anotado para que nadie lo repita.
