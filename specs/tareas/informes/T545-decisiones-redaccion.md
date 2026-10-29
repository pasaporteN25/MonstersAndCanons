# T545 · Elegí la redacción de cada texto

**Cómo se usa.** Abrí este archivo y, en cada texto, hacé una de tres cosas:

1. Marcá una opción cambiando `[ ]` por `[x]`.
2. Escribí tu versión en la línea `**Mi redacción:**`. Si escribís algo ahí, manda sobre las opciones.
3. No toques nada: el texto actual se queda.

Podés dejar notas en `**Nota:**`. Cuando termines, pasame el archivo (o pegame el contenido) y una tarea aplica lo elegido a `data/`, a `specs/11-textos-lore.md` y a los tests. **Hasta entonces no se cambió ningún texto del juego.**

Los límites son de pantalla (líneas y caracteres); los marcados «orientativo» son sugerencias. El epílogo ya está resuelto por vos y no aparece acá. La versión con capturas y contadores sigue disponible en `art/t545-revision/opciones.html`.

**Hallazgos que motivan las opciones**

| Id | Prioridad | Qué pasa |
|---|---|---|
| H1 | Alta | El agua del oasis y el nivel 2 se contradicen |
| H2 | Alta | Victoria del 15 / hilo de independencia frente al epílogo nuevo |
| H3 | Alta | Epílogo: «la máquina» sin referente y partida en 3 líneas |
| H4 | Media | La imagen del final todavía es la de T233 (luminosa) |
| H5 | Media | Nivel 13: «hitos de piedra» vs rocas marcadas en el mapa |
| H6 | Media | Dos nombres por nivel y de estilo mezclado |
| H7 | Media | Nivel 14: lo «vacío» se anuncia tres veces |
| H8 | Media | Jefe en el juego, Soberano en el lore |
| H9 | Media | Dónde queda la Central / cuál es «el valle» |
| H10 | Baja | Voz: «informe» y «nosotros» mezclados |
| H11 | Baja | Nivel 11: «paso asegurado» vs «El punto de agua» |
| H12 | Baja | Repeticiones entre campos del mismo nivel |
| H13 | Baja | Entradas con relleno o referencias sueltas |
| H14 | Baja | Wiki repite la victoria / anticipa el epílogo |
| H15 | Baja | Créditos: solo lo comprobable |
| H16 | Baja | Intro: tiempos verbales y dato que choca con H1 |

---

## Niveles

### Nivel 1 · Pradera

#### Nivel 1 · nombre  `nivel_01.nombre`
*Fuente:* `data/levels/level_01.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo

**Actual:**
> Pradera


**Mi redacción:** 

**Nota:** 

#### Nivel 1 · lugar  `nivel_01.lugar`
*Fuente:* `data/levels/level_01.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> Campamento de aterrizaje


**Mi redacción:** 

**Nota:** 

#### Nivel 1 · entrada  `nivel_01.entrada`
*Fuente:* `data/levels/level_01.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H1

**Actual:**
> La nave quedó en el borde del oasis.
> Hay agua, pasto y un terreno firme donde armar el campamento.
> Antes de descargar, hay que defenderlo.


**Mi redacción:** 

**Nota:** 

#### Nivel 1 · victoria  `nivel_01.victoria`
*Fuente:* `data/levels/level_01.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Campamento asegurado. Las primeras torres quedaron en pie.
> La carga de la nave se baja esta noche.


**Mi redacción:** 

**Nota:** 

### Nivel 2 · Desfiladero

#### Nivel 2 · nombre  `nivel_02.nombre`
*Fuente:* `data/levels/level_02.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo

**Actual:**
> Desfiladero


**Mi redacción:** 

**Nota:** 

#### Nivel 2 · lugar  `nivel_02.lugar`
*Fuente:* `data/levels/level_02.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H1, H12

**Actual:**
> El paso del agua

- [ ] **A · Del arroyo** — H1, H12: ya no habla del agua como algo ausente; no repite «paso» de la victoria
  > El paso del arroyo
- [ ] **B · De la vertiente** — H1, H12: acompaña la opción B de entrada y victoria
  > El camino a la vertiente
- [ ] **C · De las cañerías** — H1, H12: acompaña la opción C; el problema no es el agua sino cómo llega
  > El tendido de cañerías

**Mi redacción:** 

**Nota:** 

#### Nivel 2 · entrada  `nivel_02.entrada`
*Fuente:* `data/levels/level_02.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H1

**Actual:**
> El agua dulce más cercana está al otro lado del desfiladero.
> Sin ese paso, el campamento no aguanta.
> Hay que sostenerlo antes de tender las cañerías.

- [ ] **A · A · El arroyo (recomendada por el informe)** — H1: el oasis tiene agua pero no alcanza; el arroyo explica el desfiladero y deja el nivel 4 como continuación
  > El agua del oasis no alcanza para toda una colonia.
  > El arroyo más cercano está al otro lado del desfiladero.
  > Hay que sostener el paso antes de tender las cañerías.
- [ ] **B · B · La vertiente** — H1: no usa «arroyo» (queda libre para el 4); el agua que falta es nueva y nadie la midió
  > El agua del oasis alcanza para los primeros días, no para una colonia.
  > Arriba del desfiladero hay una vertiente que nadie midió todavía.
  > Hay que sostener el paso antes de tender las cañerías.
- [ ] **C · C · Llevar el agua más lejos** — H1: no hay agua nueva; el campamento creció y el agua no llega a todos los frentes
  > El campamento ya es más grande que el borde del oasis.
  > Para que el agua llegue a todos los frentes hay que cruzar el desfiladero.
  > Hay que sostener el paso antes de tender las cañerías.

**Mi redacción:** 

**Nota:** 

#### Nivel 2 · victoria  `nivel_02.victoria`
*Fuente:* `data/levels/level_02.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H1, H12

**Actual:**
> Paso asegurado. El agua llega al campamento por primera vez.
> Faltan tres tramos de cañería.

- [ ] **A · A · Agua del arroyo (par de la entrada A)** — H1, H12: el agua que «llega por primera vez» es la del arroyo, no la del campamento
  > Paso asegurado. El agua del arroyo llega al campamento por primera vez.
  > Faltan tres tramos de cañería.
- [ ] **B · B · Vertiente a tiro de cañería (par de B)** — H1, H12: no promete agua todavía, promete que se puede traer
  > Paso asegurado. La vertiente quedó a tiro de cañería.
  > Faltan tres tramos para que el agua llegue al campamento.
- [ ] **C · C · Las cañerías cruzan (par de C)** — H1, H12: cambia la fórmula «Paso asegurado» por una imagen concreta
  > Las cañerías cruzan el desfiladero. El paso quedó asegurado.
  > Faltan tres tramos para que el agua llegue a todos los frentes.

**Mi redacción:** 

**Nota:** 

### Nivel 3 · Encrucijada

#### Nivel 3 · nombre  `nivel_03.nombre`
*Fuente:* `data/levels/level_03.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Encrucijada

- [ ] **A · Por el cruce de dos caminos** — H6: se aleja de «Cruce» (7), casi sinónimo
  > Dos caminos

**Mi redacción:** 

**Nota:** 

#### Nivel 3 · lugar  `nivel_03.lugar`
*Fuente:* `data/levels/level_03.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> Las huertas


**Mi redacción:** 

**Nota:** 

#### Nivel 3 · entrada  `nivel_03.entrada`
*Fuente:* `data/levels/level_03.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H13

**Actual:**
> Al norte del campamento hay tierra buena para sembrar.
> Dos caminos se cruzan justo ahí, y por los dos llegan manadas.
> Sin huerta no hay cosecha.

- [ ] **A · Sin la línea 3** — H13: se quita la frase casi tautológica (el límite es «hasta» 3 líneas)
  > Al norte del campamento hay tierra buena para sembrar.
  > Dos caminos se cruzan justo ahí, y por los dos llegan manadas.
- [ ] **B · Línea 3 con consecuencia** — H13: dice qué se pierde en vez de repetir la idea
  > Al norte del campamento hay tierra buena para sembrar.
  > Dos caminos se cruzan justo ahí, y por los dos llegan manadas.
  > Sin huerta no hay con qué alimentar a la colonia.

**Mi redacción:** 

**Nota:** 

#### Nivel 3 · victoria  `nivel_03.victoria`
*Fuente:* `data/levels/level_03.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Huertas aseguradas. Se sembró el primer surco.
> Lo que crezca depende de que las torres aguanten.


**Mi redacción:** 

**Nota:** 

### Nivel 4 · Espiral

#### Nivel 4 · nombre  `nivel_04.nombre`
*Fuente:* `data/levels/level_04.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo

**Actual:**
> Espiral


**Mi redacción:** 

**Nota:** 

#### Nivel 4 · lugar  `nivel_04.lugar`
*Fuente:* `data/levels/level_04.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> El pozo


**Mi redacción:** 

**Nota:** 

#### Nivel 4 · entrada  `nivel_04.entrada`
*Fuente:* `data/levels/level_04.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H13, H1

**Actual:**
> El arroyo no alcanza para toda la colonia.
> Hay que cavar un pozo en el centro del valle.
> El camino hasta ahí da muchas vueltas: que les cueste llegar.

- [ ] **A · Con «las manadas»** — H13: «les» tenía el referente suelto; ahora son las manadas (vocabulario del canon)
  > El arroyo no alcanza para toda la colonia.
  > Hay que cavar un pozo en el centro del valle.
  > El camino hasta ahí da muchas vueltas: conviene que a las manadas les cueste llegar.
- [ ] **B · Sin «les»** — H13: lo mismo como hecho del terreno, sin destinatario
  > El arroyo no alcanza para toda la colonia.
  > Hay que cavar un pozo en el centro del valle.
  > El camino hasta ahí da muchas vueltas, y cada vuelta cuenta.

**Mi redacción:** 

**Nota:** 

#### Nivel 4 · victoria  `nivel_04.victoria`
*Fuente:* `data/levels/level_04.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Pozo terminado. Hay agua para toda la colonia.
> Se armó un turno de guardia para cuidarlo.


**Mi redacción:** 

**Nota:** 

### Nivel 5 · Fortaleza

#### Nivel 5 · nombre  `nivel_05.nombre`
*Fuente:* `data/levels/level_05.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Fortaleza

- [ ] **A · Igual que el lugar** — H6: nombre = lugar, sin dos palabras para lo mismo
  > Empalizada
- [ ] **B · Primer cerco** — H6: nombre de mapa que cuenta lo que pasa en el nivel
  > El primer cerco
- [ ] **C · Palabra del canon** — H6: usa «perímetro», vocabulario de la biblia
  > Perímetro

**Mi redacción:** 

**Nota:** 

#### Nivel 5 · lugar  `nivel_05.lugar`
*Fuente:* `data/levels/level_05.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> La empalizada


**Mi redacción:** 

**Nota:** 

#### Nivel 5 · entrada  `nivel_05.entrada`
*Fuente:* `data/levels/level_05.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres

**Actual:**
> El campamento ya es un pueblo y todavía no tiene cerco.
> Hoy se cierra el primer perímetro.
> Lo que quede afuera, queda afuera.


**Mi redacción:** 

**Nota:** 

#### Nivel 5 · victoria  `nivel_05.victoria`
*Fuente:* `data/levels/level_05.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H10

**Actual:**
> Empalizada cerrada. Es el primer perímetro de la colonia.
> Por primera vez, dormimos adentro.

- [ ] **A · Impersonal** — H10: sin primera persona del plural
  > Empalizada cerrada. Es el primer perímetro de la colonia.
  > Por primera vez, se duerme adentro.

**Mi redacción:** 

**Nota:** 

### Nivel 6 · Nido

#### Nivel 6 · nombre  `nivel_06.nombre`
*Fuente:* `data/levels/level_06.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Nido

- [ ] **A · Bosque** — H6: «Nido» no aparece en ningún texto del 6
  > Bosque
- [ ] **B · Linde del bosque** — H6: se ata a la entrada («donde termina el cerco») sin repetir el lugar «El lindero»
  > Linde del bosque
- [ ] **C · Madera** — H6: nombre por lo que se busca en el nivel
  > Madera

**Mi redacción:** 

**Nota:** 

#### Nivel 6 · lugar  `nivel_06.lugar`
*Fuente:* `data/levels/level_06.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> El lindero


**Mi redacción:** 

**Nota:** 

#### Nivel 6 · entrada  `nivel_06.entrada`
*Fuente:* `data/levels/level_06.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H10

**Actual:**
> El bosque empieza donde termina el cerco.
> Hay madera para varios años, y también criaturas que no habíamos visto.
> Del campamento empezaron a faltar cosas.

- [ ] **A · Impersonal** — H10: sin «habíamos visto»
  > El bosque empieza donde termina el cerco.
  > Hay madera para varios años, y también criaturas que nadie había visto.
  > Del campamento empezaron a faltar cosas.

**Mi redacción:** 

**Nota:** 

#### Nivel 6 · victoria  `nivel_06.victoria`
*Fuente:* `data/levels/level_06.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Lindero asegurado. Se taló el primer tramo.
> La madera alcanza para dos casas.


**Mi redacción:** 

**Nota:** 

### Nivel 7 · Cruce

#### Nivel 7 · nombre  `nivel_07.nombre`
*Fuente:* `data/levels/level_07.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Cruce

- [ ] **A · Aserradero** — H6: se distancia de «Encrucijada» (3) y coincide con el lugar
  > Aserradero
- [ ] **B · Cruce de caminos** — H6: queda claro que no es la encrucijada del 3
  > Cruce de caminos
- [ ] **C · Corte de madera** — H6: nombre por la actividad
  > Corte de madera

**Mi redacción:** 

**Nota:** 

#### Nivel 7 · lugar  `nivel_07.lugar`
*Fuente:* `data/levels/level_07.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> El aserradero


**Mi redacción:** 

**Nota:** 

#### Nivel 7 · entrada  `nivel_07.entrada`
*Fuente:* `data/levels/level_07.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres

**Actual:**
> El mejor sitio para cortar madera es un cruce de caminos.
> Se arma un aserradero, y para eso hay que despejar el terreno.
> Todo lo que estorbe se retira.


**Mi redacción:** 

**Nota:** 

#### Nivel 7 · victoria  `nivel_07.victoria`
*Fuente:* `data/levels/level_07.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H2

**Actual:**
> Aserradero en marcha. La colonia ya tiene madera propia.
> La primera carga sale mañana hacia el campamento.

- [ ] **A · Sin independencia** — H2: no usa «propia»; el hilo de independencia queda para el 9 y el 15
  > Aserradero en marcha. Hay madera para empezar a construir en serio.
  > La primera carga sale mañana hacia el campamento.
- [ ] **B · Solo el hecho** — H2: no promete nada; ya se cortó, no se cuenta
  > Aserradero en marcha. Los primeros troncos ya están en el patio.
  > La primera carga sale mañana hacia el campamento.
- [ ] **C · Con costo** — H2: el logro trae su sombra; encaja con «Todo lo que estorbe se retira»
  > Aserradero en marcha. El terreno quedó despejado de punta a punta.
  > La primera carga sale mañana hacia el campamento.

**Mi redacción:** 

**Nota:** 

### Nivel 8 · Bastión

#### Nivel 8 · nombre  `nivel_08.nombre`
*Fuente:* `data/levels/level_08.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Bastión

- [ ] **A · La loma** — H6: nombre geográfico, sin «bastión» ni «ruinas»
  > La loma
- [ ] **B · Muros viejos** — H6: toma la imagen de la entrada («piedra vieja»)
  > Muros viejos
- [ ] **C · Piedra vieja** — H6: palabra exacta de la entrada; evita «ruinas» antes de la revelación
  > Piedra vieja

**Mi redacción:** 

**Nota:** 

#### Nivel 8 · lugar  `nivel_08.lugar`
*Fuente:* `data/levels/level_08.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H6

**Actual:**
> El bastión sobre ruinas

- [ ] **A · La loma** — H6: no repite el nombre ni adelanta «ruinas»
  > La loma
- [ ] **B · El bastión** — H6: lugar breve, sin «ruinas»
  > El bastión
- [ ] **C · Los muros viejos** — H6: usa «viejos» como la entrada
  > Los muros viejos

**Mi redacción:** 

**Nota:** 

#### Nivel 8 · entrada  `nivel_08.entrada`
*Fuente:* `data/levels/level_08.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H10

**Actual:**
> Sobre la loma hay muros de piedra vieja, a medio enterrar.
> Las rocas tienen la misma marca que las del campamento.
> Alguien la puso antes que nosotros.

- [ ] **A · Impersonal** — H10: sin «nosotros»
  > Sobre la loma hay muros de piedra vieja, a medio enterrar.
  > Las rocas tienen la misma marca que las del campamento.
  > Alguien la puso antes que la colonia.

**Mi redacción:** 

**Nota:** 

#### Nivel 8 · victoria  `nivel_08.victoria`
*Fuente:* `data/levels/level_08.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H10

**Actual:**
> Bastión asegurado. La colonia tiene una posición alta sobre la loma.
> Los muros son de otros; los usamos igual.

- [ ] **A · Impersonal** — H10: sin «los usamos»
  > Bastión asegurado. La colonia tiene una posición alta sobre la loma.
  > Los muros son de otros; se usan igual.

**Mi redacción:** 

**Nota:** 

### Nivel 9 · Taller asediado

#### Nivel 9 · nombre  `nivel_09.nombre`
*Fuente:* `data/levels/level_09.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Taller asediado

- [ ] **A · Taller en ruinas** — H6: ya no choca con el modo «Asedio»
  > Taller en ruinas
- [ ] **B · El galpón** — H6: toma la palabra de la entrada
  > El galpón
- [ ] **C · Taller** — H6: igual al lugar; nada que choque
  > Taller

**Mi redacción:** 

**Nota:** 

#### Nivel 9 · lugar  `nivel_09.lugar`
*Fuente:* `data/levels/level_09.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> El taller


**Mi redacción:** 

**Nota:** 

#### Nivel 9 · entrada  `nivel_09.entrada`
*Fuente:* `data/levels/level_09.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H13

**Actual:**
> Entre las ruinas hay un galpón que puede servir de taller.
> Los que lo rodean no parecen animales: algunos curan a los suyos.
> Hoy se prueba el primer mortero de la colonia.

- [ ] **A · Sin nombrar la torre** — H13: «el primer mortero» es mecánica y estaba A REVISAR TRAS G4
  > Entre las ruinas hay un galpón que puede servir de taller.
  > Los que lo rodean no parecen animales: algunos curan a los suyos.
  > Hoy se prueba la primera pieza que sale de la forja.
- [ ] **B · Defender antes del horno** — H13: línea 3 como hecho del mundo; no repite el horno de la victoria
  > Entre las ruinas hay un galpón que puede servir de taller.
  > Los que lo rodean no parecen animales: algunos curan a los suyos.
  > Hay que defenderlo antes de encender el horno.

**Mi redacción:** 

**Nota:** 

#### Nivel 9 · victoria  `nivel_09.victoria`
*Fuente:* `data/levels/level_09.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Taller asegurado. El horno se encendió por primera vez fuera del oasis.
> La forja ya no depende de lo que trajo la nave.


**Mi redacción:** 

**Nota:** 

### Nivel 10 · La mina vieja

#### Nivel 10 · nombre  `nivel_10.nombre`
*Fuente:* `data/levels/level_10.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> La mina vieja

- [ ] **A · La mina** — H6: sin «vieja» (nombre provisorio de la biblia)
  > La mina
- [ ] **B · Mina vieja** — H6: estilo sin artículo
  > Mina vieja
- [ ] **C · Las galerías** — H6: toma la imagen de la entrada
  > Las galerías

**Mi redacción:** 

**Nota:** 

#### Nivel 10 · lugar  `nivel_10.lugar`
*Fuente:* `data/levels/level_10.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H12

**Actual:**
> Primer puesto de abastecimiento

- [ ] **A · La boca de la mina** — H12: ya no se repite tal cual en la victoria
  > La boca de la mina
- [ ] **B · El primer puesto** — H12: corto; deja «abastecimiento» a la victoria
  > El primer puesto
- [ ] **C · Puesto de abastecimiento** — H12: sin «primer» (que dice la victoria)
  > Puesto de abastecimiento

**Mi redacción:** 

**Nota:** 

#### Nivel 10 · entrada  `nivel_10.entrada`
*Fuente:* `data/levels/level_10.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H10

**Actual:**
> Las galerías ya estaban cavadas cuando llegamos.
> Si se las retoma, la colonia tiene mineral a pocos días del campamento.
> Hay que sostener la boca de la mina.

- [ ] **A · Impersonal** — H10: sin «cuando llegamos»
  > Las galerías ya estaban cavadas cuando llegó la Compañía.
  > Si se las retoma, la colonia tiene mineral a pocos días del campamento.
  > Hay que sostener la boca de la mina.

**Mi redacción:** 

**Nota:** 

#### Nivel 10 · victoria  `nivel_10.victoria`
*Fuente:* `data/levels/level_10.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H12, H10

**Actual:**
> Mina asegurada. Es el primer puesto de abastecimiento de la colonia.
> Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.

- [ ] **A · Primer mineral** — H12: no repite el lugar; el hito es el mineral
  > Mina asegurada. De acá sale el primer mineral de la colonia.
  > Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.
- [ ] **B · Impersonal** — H12, H10: sin «cavamos nosotros»; conserva la mejor línea
  > Mina asegurada. Es el primer puesto de abastecimiento de la colonia.
  > Las galerías no las cavó la colonia, y nadie vino a reclamarlas.

**Mi redacción:** 

**Nota:** 

### Nivel 11 · Puesto seco

#### Nivel 11 · nombre  `nivel_11.nombre`
*Fuente:* `data/levels/level_11.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Puesto seco

- [ ] **A · Los pozos** — H6, H11: nombre por lo que se asegura
  > Los pozos
- [ ] **B · Camino seco** — H6: estilo sin artículo, descriptivo
  > Camino seco
- [ ] **C · Puesto** — H6: mínimo
  > Puesto

**Mi redacción:** 

**Nota:** 

#### Nivel 11 · lugar  `nivel_11.lugar`
*Fuente:* `data/levels/level_11.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H11

**Actual:**
> El punto de agua

- [ ] **A · Los dos pozos** — H11: más concreto; acerca el lugar a la victoria
  > Los dos pozos
- [ ] **B · El camino seco** — H11: coincide con la entrada
  > El camino seco

**Mi redacción:** 

**Nota:** 

#### Nivel 11 · entrada  `nivel_11.entrada`
*Fuente:* `data/levels/level_11.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres

**Actual:**
> Pasada la mina, el camino se vuelve seco.
> Los dos pozos que hay ya tenían huellas alrededor.
> Desde hoy, algunas torres se apagan sin que nadie las toque.


**Mi redacción:** 

**Nota:** 

#### Nivel 11 · victoria  `nivel_11.victoria`
*Fuente:* `data/levels/level_11.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H11

**Actual:**
> Informe del puesto seco: paso asegurado.
> Dos pozos quedaron dentro del perímetro.

- [ ] **A · Punto de agua asegurado** — H11: el informe habla del lugar, no de un paso (cambia la frase de la biblia)
  > Informe del puesto seco: punto de agua asegurado.
  > Dos pozos quedaron dentro del perímetro.
- [ ] **B · Pozos asegurados** — H11: nombra lo asegurado
  > Informe del puesto seco: pozos asegurados.
  > Quedaron dentro del perímetro.
- [ ] **C · Perímetro cerrado** — H11: usa «perímetro», vocabulario del canon
  > Informe del puesto seco: perímetro cerrado.
  > Dos pozos quedaron adentro.

**Mi redacción:** 

**Nota:** 

### Nivel 12 · El cañadón

#### Nivel 12 · nombre  `nivel_12.nombre`
*Fuente:* `data/levels/level_12.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> El cañadón

- [ ] **A · Cañadón** — H6: estilo sin artículo
  > Cañadón
- [ ] **B · Paredes altas** — H6: imagen de la entrada
  > Paredes altas
- [ ] **C · El eco** — H6: toma la mecánica del nivel como hecho del paisaje
  > El eco

**Mi redacción:** 

**Nota:** 

#### Nivel 12 · lugar  `nivel_12.lugar`
*Fuente:* `data/levels/level_12.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H12

**Actual:**
> El paso hacia el norte

- [ ] **A · Las paredes altas** — H12: no repite «el paso hacia el norte» de la entrada
  > Las paredes altas
- [ ] **B · La boca del cañadón** — H12: lugar concreto
  > La boca del cañadón

**Mi redacción:** 

**Nota:** 

#### Nivel 12 · entrada  `nivel_12.entrada`
*Fuente:* `data/levels/level_12.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H12, H13

**Actual:**
> El único paso hacia el norte es un cañadón de paredes altas.
> Los tiros vuelven contra las torres, como si las paredes los devolvieran.
> Cruzarlo es la única forma de llegar al resto de la región.

- [ ] **A · Solo cambia la línea 3** — H13: «único» ya no se repite
  > El único paso hacia el norte es un cañadón de paredes altas.
  > Los tiros vuelven contra las torres, como si las paredes los devolvieran.
  > Cruzarlo es llegar al resto de la región.
- [ ] **B · Cambia la línea 1** — H12, H13: el lugar ya dijo «el paso»; acá queda el paisaje
  > El camino al norte se estrecha en un cañadón de paredes altas.
  > Los tiros vuelven contra las torres, como si las paredes los devolvieran.
  > Cruzarlo es la única forma de llegar al resto de la región.

**Mi redacción:** 

**Nota:** 

#### Nivel 12 · victoria  `nivel_12.victoria`
*Fuente:* `data/levels/level_12.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Cañadón asegurado. El paso al norte quedó abierto.
> En las paredes quedaron las marcas de los tiros que volvieron.


**Mi redacción:** 

**Nota:** 

### Nivel 13 · Paso alto

#### Nivel 13 · nombre  `nivel_13.nombre`
*Fuente:* `data/levels/level_13.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Paso alto

- [ ] **A · El paso alto** — H6: estilo con artículo, como 11 a 15 hoy
  > El paso alto
- [ ] **B · Rocas marcadas** — H5, H6: nombre por lo que el mapa dibuja
  > Rocas marcadas
- [ ] **C · El límite** — H6: nombre por la idea de la entrada
  > El límite

**Mi redacción:** 

**Nota:** 

#### Nivel 13 · lugar  `nivel_13.lugar`
*Fuente:* `data/levels/level_13.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres

**Actual:**
> El camino al resto de la región


**Mi redacción:** 

**Nota:** 

#### Nivel 13 · entrada  `nivel_13.entrada`
*Fuente:* `data/levels/level_13.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H5, H10

**Actual:**
> En el paso alto el camino se parte en dos.
> Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apaga torres.
> Hay hitos de piedra en el camino. Marcan un límite, y ya lo pasamos.

- [ ] **A · A · Rocas marcadas (informe)** — H5: el texto coincide con lo que el mapa dibuja (roca_marcada)
  > En el paso alto el camino se parte en dos.
  > Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apaga torres.
  > Hay rocas marcadas en el camino. Marcan un límite, y ya lo pasamos.
- [ ] **B · B · La marca de siempre** — H5: une con la revelación del 8 («la misma marca»)
  > En el paso alto el camino se parte en dos.
  > Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apaga torres.
  > Hay rocas con la marca de siempre. Marcan un límite, y ya lo pasamos.
- [ ] **C · C · Escolta más corta** — H5, H10: rocas marcadas, línea 2 sin enumerar la mecánica y sin «nosotros»
  > En el paso alto el camino se parte en dos.
  > Ya no llegan de a uno: cada grupo trae quien lo cuide y quien apague torres.
  > Hay rocas marcadas en el camino. Marcan un límite, y el límite ya quedó atrás.

**Mi redacción:** 

**Nota:** 

#### Nivel 13 · victoria  `nivel_13.victoria`
*Fuente:* `data/levels/level_13.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H5, H9

**Actual:**
> Paso alto asegurado. La región queda comunicada con el valle.
> Los hitos quedaron del lado de adentro.

- [ ] **A · A · Rocas y campamento** — H5, H9: «rocas marcadas» y comunicada con el campamento (no «el valle»)
  > Paso alto asegurado. La región queda comunicada con el campamento.
  > Las rocas marcadas quedaron del lado de adentro.
- [ ] **B · B · Camino abierto** — H5, H9: sin «valle»; la marca queda en plural corto
  > Paso alto asegurado. El camino al resto de la región está abierto.
  > Las marcas quedaron del lado de adentro.
- [ ] **C · C · Ir y volver** — H5, H9: dice qué cambia para la colonia
  > Paso alto asegurado. Ya se puede ir y volver del campamento al resto de la región.
  > Las rocas marcadas quedaron del lado de adentro.

**Mi redacción:** 

**Nota:** 

### Nivel 14 · Los poblados vacíos

#### Nivel 14 · nombre  `nivel_14.nombre`
*Fuente:* `data/levels/level_14.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6, H7

**Actual:**
> Los poblados vacíos

- [ ] **A · Los poblados** — H7, H6: sin «vacíos» en el nombre (opción B del informe)
  > Los poblados
- [ ] **B · Poblados** — H7, H6: sin artículo
  > Poblados
- [ ] **C · El valle bajo** — H7: nombre geográfico (el artículo de la Wiki dice «valle bajo»)
  > El valle bajo

**Mi redacción:** 

**Nota:** 

#### Nivel 14 · lugar  `nivel_14.lugar`
*Fuente:* `data/levels/level_14.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H6, H7

**Actual:**
> Asentamientos de los Moradores

- [ ] **A · Poblados de los Moradores** — H6: usa «poblados» como el resto
  > Poblados de los Moradores
- [ ] **B · Lo que dejaron los Moradores** — H7: no dice «vacíos» pero lo insinúa
  > Lo que dejaron los Moradores
- [ ] **C · Los caminos pisados** — H7: lo que se ve, sin nombrar a nadie
  > Los caminos pisados

**Mi redacción:** 

**Nota:** 

#### Nivel 14 · entrada  `nivel_14.entrada`
*Fuente:* `data/levels/level_14.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H7

**Actual:**
> Los poblados están a la vista, pero no sale humo de ninguno.
> Los Moradores se llevaron lo que pudieron.
> Aun así, algo todavía defiende el lugar.

- [ ] **A · A · Fogones armados (informe)** — H7: el descubrimiento de que están vacíos queda en la victoria
  > Los poblados están a la vista, pero no sale humo de ninguno.
  > Los fogones están armados y no se ve a nadie.
  > Aun así, algo todavía defiende el lugar.
- [ ] **B · B · Solo lo que se ve** — H7: no anuncia que se fueron; la mecánica entra en la línea 2
  > Los poblados están a la vista.
  > No sale humo de ninguno, pero algo sigue defendiendo el lugar.
  > Hay que cruzarlos de punta a punta.
- [ ] **C · C · Caminos pisados** — H7: la señal es el rastro, no la ausencia
  > Más allá hay poblados de piedra y paja.
  > Los caminos que los unen están bien pisados.
  > Algo todavía los defiende.

**Mi redacción:** 

**Nota:** 

#### Nivel 14 · victoria  `nivel_14.victoria`
*Fuente:* `data/levels/level_14.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H7

**Actual:**
> Los poblados están vacíos.
> Las brasas todavía están tibias.

- [ ] **A · No quedó nadie** — H7: golpe más seco
  > No quedó nadie.
  > Las brasas todavía están tibias.
- [ ] **B · Fogones tibios** — H7, H14: la imagen cambia de «brasas» a «fogones» (la Wiki puede conservar «brasas»)
  > Los poblados están vacíos.
  > Los fogones todavía están tibios.

**Mi redacción:** 

**Nota:** 

### Nivel 15 · La Central

#### Nivel 15 · nombre  `nivel_15.nombre`
*Fuente:* `data/levels/level_15.json` · *Límite:* hasta 1 línea(s), 24 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> La Central

- [ ] **A · Central** — H6: estilo sin artículo
  > Central
- [ ] **B · El último valle** — H6, H9: nombre geográfico que fija dónde queda
  > El último valle
- [ ] **C · La línea** — H6: por lo que une la central con la mina
  > La línea

**Mi redacción:** 

**Nota:** 

#### Nivel 15 · lugar  `nivel_15.lugar`
*Fuente:* `data/levels/level_15.json → textos.lugar` · *Límite:* hasta 1 línea(s), 32 caracteres · *Hallazgos:* H12

**Actual:**
> Energía y abastecimiento

- [ ] **A · La central** — H12: no repite «abastecimiento» de la victoria
  > La central
- [ ] **B · La central y la línea** — H12: dice qué hay, sin repetir
  > La central y la línea

**Mi redacción:** 

**Nota:** 

#### Nivel 15 · entrada  `nivel_15.entrada`
*Fuente:* `data/levels/level_15.json → textos.entrada` · *Límite:* hasta 3 línea(s), 240 caracteres · *Hallazgos:* H2, H9, H10

**Actual:**
> Falta cerrar el valle: la central de energía y la línea que la une con la mina.
> Si se sostiene, la colonia queda asentada en esta región.
> Hoy llega lo más grande que vimos hasta ahora, y no viene solo.

- [ ] **A · A · Último valle (informe)** — H9: fija «el último valle» (el extremo del mapa)
  > Falta cerrar el último valle: la central de energía y la línea que la une con la mina.
  > Si se sostiene, la colonia queda asentada en esta región.
  > Hoy llega lo más grande que vimos hasta ahora, y no viene solo.
- [ ] **B · B · Más corta** — H9, H10: sin «valle», más corta (hoy ocupa 5 renglones en pantalla) y sin «vimos»
  > Falta la central de energía y la línea que la une con la mina.
  > Si se sostiene, la colonia queda asentada en esta región.
  > Hoy llega lo más grande que se vio hasta ahora, y no viene solo.
- [ ] **C · C · Con duda** — H2, H9: «asentada» se vuelve condicional; prepara el epílogo
  > Falta cerrar el último valle: la central de energía y la línea hasta la mina.
  > Si se sostiene, la colonia puede quedarse en esta región.
  > Hoy llega lo más grande que vimos, y no viene solo.

**Mi redacción:** 

**Nota:** 

#### Nivel 15 · victoria  `nivel_15.victoria`
*Fuente:* `data/levels/level_15.json → textos.victoria` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H2, H9, H12

**Actual:**
> Central encendida. La línea de abastecimiento está completa.
> La colonia tiene luz propia.

- [ ] **A · A · La luz se ve (informe B)** — H2: menos triunfal; mira hacia afuera
  > Central encendida. La línea de abastecimiento está completa.
  > La luz se ve desde los poblados vacíos.
- [ ] **B · B · Ya no depende de la nave (informe C)** — H2: sin «propia»; cierra el hilo del 9
  > Central encendida. La línea de abastecimiento está completa.
  > La colonia ya no depende de la nave.
- [ ] **C · C · Con costo** — H2: el logro trae una pregunta, en voz de informe; prepara el epílogo
  > Central encendida. La línea de abastecimiento está completa.
  > Nadie escribió cuánto cuesta mantenerla.

**Mi redacción:** 

**Nota:** 

### Selector de campaña

#### Selector de campaña (vista de mapa)  `selector`
*Fuente:* `scenes/ui/level_select.gd, campaign_map_view.gd` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H6

**Actual:**
> Título «Elegir nivel»; en el mapa, «15 · La Central» bajo la insignia del nivel elegido y, en la franja de abajo, «Disponible · sin victorias todavía».


**Mi redacción:** 

**Nota:** 

---

## Epílogo, imagen y créditos

### Epílogo

#### Epílogo (nivel 15)  `epilogo`
*Fuente:* `data/levels/level_15.json → textos.epilogo` · *Límite:* hasta 5 línea(s), 400 caracteres · *Hallazgos:* H2, H3

**Actual:**
> La máquina sigue avanzando,
> pero ¿por cuánto tiempo más?
> ¿A qué costo?


**Mi redacción:** 

**Nota:** 

#### Imagen del epílogo  `epilogo.imagen`
*Fuente:* `assets/sprites/story/epilogue.png` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H4

**Actual:**
> La colonia iluminada con una central de vapor en primer plano y una mina arriba a la izquierda; al fondo a la derecha un río y varias fogatas pequeñas que se alejan por el valle. Atardecer cálido adelante, horizonte frío atrás.


**Mi redacción:** 

**Nota:** 

### Créditos

#### Créditos  `creditos`
*Fuente:* `data/creditos.json → lineas` · *Límite:* hasta 4 línea(s), 400 caracteres · *Hallazgos:* H15

**Actual:**
> Monsters & Canons
> Un juego de Lucas
> Hecho con Godot Engine
> Software libre bajo la licencia GPL-3.0-or-later (los detalles, en Wiki → Licencias)

- [ ] **A · Licencia más corta** — H15: la línea 4 deja de ocupar dos renglones en pantalla
  > Monsters & Canons
  > Un juego de Lucas
  > Hecho con Godot Engine
  > Software libre (GPL-3.0-or-later). Detalles en Wiki → Licencias
- [ ] **B · Cierre amable, sin licencia** — H15: cierra con una frase en vez de la licencia. Ojo: la licencia sigue en Wiki → Licencias, pero hay que confirmar que RF-472 no la exija en la pantalla de créditos
  > Monsters & Canons
  > Un juego de Lucas
  > Hecho con Godot Engine
  > Gracias por jugar

**Mi redacción:** 

**Nota:** 

---

## Intro de láminas

### Lámina 1

#### Lámina 1 · la nave  `intro.lamina_1`
*Fuente:* `data/intro/intro.json → laminas[0].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> La Compañía Meridiana mandó una sola nave.
> No lleva soldados: lleva gente de oficio.


**Mi redacción:** 

**Nota:** 

### Lámina 2

#### Lámina 2 · la bodega  `intro.lamina_2`
*Fuente:* `data/intro/intro.json → laminas[1].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio.
> Hay semillas, planos y piezas para empezar de cero.


**Mi redacción:** 

**Nota:** 

### Lámina 3

#### Lámina 3 · los turnos  `intro.lamina_3`
*Fuente:* `data/intro/intro.json → laminas[2].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo.
> Era un viaje de ida.

- [ ] **A · Una sola frase de viaje** — Ritmo: junta la primera y la segunda oración y deja «ida» como golpe
  > Fueron años de viaje, durmiendo por turnos y arreglando a bordo lo que se rompía.
  > Era un viaje de ida.

**Mi redacción:** 

**Nota:** 

### Lámina 4

#### Lámina 4 · la ventana  `intro.lamina_4`
*Fuente:* `data/intro/intro.json → laminas[3].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H1, H16

**Actual:**
> El reconocimiento vio agua en un solo lugar de todo el planeta.
> Hacia ahí apuntó la nave.

- [ ] **A · Un valle con agua** — H1, H16: «un solo valle», no «un solo lugar de todo el planeta»; compatible con arroyo o vertiente en el nivel 2
  > El reconocimiento encontró un solo valle con agua para asentarse.
  > Hacia ahí apuntó la nave.
- [ ] **B · Tierra seca y un valle** — H1, H16: dice lo que se vio sin afirmar que no hay más agua en el planeta
  > El reconocimiento vio mucha tierra seca y, en medio, un valle con agua.
  > Hacia ahí apuntó la nave.
- [ ] **C · Agua, y poco más** — H1, H16: tono de bitácora; deja lugar a que haya más agua en otro lado
  > El reconocimiento mostró agua en un solo valle, y poco más.
  > Hacia ahí apuntó la nave.

**Mi redacción:** 

**Nota:** 

### Lámina 5

#### Lámina 5 · el descenso  `intro.lamina_5`
*Fuente:* `data/intro/intro.json → laminas[4].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres

**Actual:**
> La bajada fue brusca. El casco crujió entero, pero aguantó.


**Mi redacción:** 

**Nota:** 

### Lámina 6

#### Lámina 6 · los motores apagados  `intro.lamina_6`
*Fuente:* `data/intro/intro.json → laminas[5].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H16

**Actual:**
> Los motores se apagaron al tocar tierra.
> La nave ya no va a despegar.

- [ ] **A · Todo en presente** — H16: presente en las dos líneas, como las láminas 1 y 7
  > Los motores se apagan al tocar tierra.
  > La nave ya no va a despegar.
- [ ] **B · Todo en pasado** — H16: pasado, como las láminas 3 a 5
  > Los motores se apagaron al tocar tierra.
  > La nave no iba a despegar de nuevo.

**Mi redacción:** 

**Nota:** 

### Lámina 7

#### Lámina 7 · el oasis  `intro.lamina_7`
*Fuente:* `data/intro/intro.json → laminas[6].texto (fuente: specs/intro/guion.md)` · *Límite:* hasta 2 línea(s), 160 caracteres · *Hallazgos:* H10, H16

**Actual:**
> Un valle chico, con agua y pasto, en medio de la nada.
> Acá nos quedamos.

- [ ] **A · Se queda la Compañía** — H10: sin «nosotros»
  > Un valle chico, con agua y pasto, en medio de la nada.
  > Acá se queda la Compañía.
- [ ] **B · Acá empieza la colonia** — H10, H16: cierre más de comienzo que de encierro
  > Un valle chico, con agua y pasto, en medio de la nada.
  > Acá empieza la colonia.

**Mi redacción:** 

**Nota:** 

---

## Wiki · Lore

### El oasis

#### Wiki · El oasis  `lore.el_oasis`
*Fuente:* `data/wiki/lore/el_oasis.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H1

**Actual:**
> El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista que encontró el reconocimiento, y por eso la nave bajó acá.
> 
> Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sembrar) hay que ir a buscarlo más lejos.
> 
> Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.

- [ ] **A · El sitio con más agua** — H1: «más agua» en vez de «único con agua»; deja lugar al arroyo del nivel 2
  > El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el sitio con más agua a la vista que encontró el reconocimiento, y por eso la nave bajó acá.
  > 
  > Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sembrar) hay que ir a buscarlo más lejos.
  > 
  > Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.
- [ ] **B · Agua que no alcanza** — H1: dice en voz de informe que el oasis es chico para una colonia (liga con la opción A del nivel 2)
  > El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el sitio con agua más a mano que encontró el reconocimiento, y por eso la nave bajó acá. Alcanza para empezar, no para quedarse.
  > 
  > Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sembrar) hay que ir a buscarlo más lejos.
  > 
  > Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.
- [ ] **C · Sin hablar de cuánta agua** — H1: solo dice dónde bajó la nave (liga con cualquier nivel 2)
  > El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Fue el sitio que eligió el reconocimiento, y por eso la nave bajó acá.
  > 
  > Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sembrar) hay que ir a buscarlo más lejos.
  > 
  > Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.

**Mi redacción:** 

**Nota:** 

### Cántaro

#### Wiki · Cántaro  `lore.planeta_cantaro`
*Fuente:* `data/wiki/lore/planeta_cantaro.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> Los colonos le pusieron Cántaro al planeta, por el oasis: un poco de agua guardada en una tierra seca.
> 
> Lo que se conoce es un solo rincón: el oasis y lo que lo rodea. Más allá, todavía no se llegó.
> 
> Cada tramo que se asegura se agrega al mapa de la Compañía. El mapa tiene más blanco que dibujo.


**Mi redacción:** 

**Nota:** 

### La Compañía Meridiana

#### Wiki · La Compañía Meridiana  `lore.la_compania`
*Fuente:* `data/wiki/lore/la_compania.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> La Compañía Meridiana armó la expedición. No es un ejército: es gente de oficio (ingenieros, herreros, carpinteros, agricultores) con herramientas, semillas y planos.
> 
> La nave no puede volver a despegar. Se la va desarmando de a poco para hacer casas, cañerías y torres, y lo que se rompe se arregla con lo que hay.
> 
> Por eso las torres son de hierro, bronce y cristal: se pueden reparar en el lugar. Entre la carga venían también planos y piezas de repuesto, que se van recuperando de entre los restos del aterrizaje.


**Mi redacción:** 

**Nota:** 

### El Soberano

#### Wiki · El Soberano  `lore.el_soberano`
*Fuente:* `data/wiki/lore/el_soberano.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H8

**Actual:**
> Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le dicen Soberano.
> 
> No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.

- [ ] **A · A · Aclarar en el parte** — H8: el artículo suma la relación Jefe / Soberano sin tocar el juego
  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le dicen Soberano; en los partes del campamento se lo anota como el Jefe de la oleada.
  > 
  > No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.
- [ ] **B · B · Pasar el artículo a «Jefe»** — H8: el artículo habla como el juego; «Soberano» queda como apodo
  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. El campamento lo llama el Jefe; algunos colonos, entre ellos, dicen Soberano.
  > 
  > No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.
- [ ] **C · C · Cambiar el juego a «Soberano»** — H8: el artículo queda tal cual y el juego pasa a decir «Soberano» (contradice Q-2 de T202). Lo aplica otra tarea
  > Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le dicen Soberano.
  > 
  > No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.

**Mi redacción:** 

**Nota:** 

### Las criaturas que van solas

#### Wiki · Las criaturas que van solas  `lore.criaturas_solas`
*Fuente:* `data/wiki/lore/criaturas_solas.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> En el bosque hay seres que no andan con ninguna manada. El Ladrón, por ejemplo, va solo, con una capa gris y una bolsa, y se lleva lo que brilla del campamento: monedas, herramientas, un botón.
> 
> Los informes las llaman criaturas, para distinguirlas de los animales. No obedecen a nadie, y nadie sabe cuántas hay.


**Mi redacción:** 

**Nota:** 

### La Cuadrilla

#### Wiki · La Cuadrilla  `lore.la_cuadrilla`
*Fuente:* `data/wiki/lore/la_cuadrilla.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> Cerca del aserradero se vieron criaturas chicas y rápidas que se llevan lo que brilla, igual que el Ladrón. A diferencia de él, no andan solas: llegan juntas, y los colonos las llaman Rateros.
> 
> Con ellas viene siempre una más grande y lenta, con una bolsa más grande que ella misma donde parece juntarse lo de todas. La llaman el Cargador, y a todas juntas, la cuadrilla, por cómo llegan.
> 
> Nadie vio que alguna mande ni que alguna obedezca. Parece que van juntas porque buscan lo mismo.


**Mi redacción:** 

**Nota:** 

### Las ruinas

#### Wiki · Las ruinas  `lore.las_ruinas`
*Fuente:* `data/wiki/lore/las_ruinas.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> Sobre la loma del bastión hay muros de piedra y metal, a medio enterrar. Los colonos los llaman «las ruinas» y los tratan como un yacimiento: se despeja, se anota y se recupera lo que sirve.
> 
> Todas llevan la misma marca que las rocas del oasis. Nadie sabe qué quiere decir: puede ser «esto es nuestro», «hasta acá» o un recuerdo.
> 
> El informe de la Compañía dice que las dejó una gente que ya no está. No dice cómo lo sabe.


**Mi redacción:** 

**Nota:** 

### Los Moradores

#### Wiki · Los Moradores  `lore.los_moradores`
*Fuente:* `data/wiki/lore/los_moradores.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo

**Actual:**
> Así llama la Compañía a las comunidades que viven en Cántaro. Es un nombre de informe: cómo se llaman ellos a sí mismos no figura en ningún registro.
> 
> Hasta ahora se vieron dos oficios: los que protegen, de piedra y escudo dorado, y los que curan, con una semilla en el pecho. No está claro si son un solo pueblo o varios que se juntaron.
> 
> Tampoco está claro si guían a los animales de las manadas o si solo cuidan sus propios caminos.


**Mi redacción:** 

**Nota:** 

### Los pozos

#### Wiki · Los pozos  `lore.los_pozos`
*Fuente:* `data/wiki/lore/los_pozos.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H10

**Actual:**
> En el camino seco hay pocos pozos, y todos tienen huellas alrededor. Dos quedaron dentro del perímetro del puesto.
> 
> El mismo día en que se aseguró el paso empezaron los fallos: torres que se apagan sin motivo. Las observaciones coinciden en un encapuchado con un bastón que chispea, que se acerca a las torres y no a los colonos.
> 
> No ataca a las personas. Ataca lo que construimos.

- [ ] **A · Sin «construimos»** — H10: tercera persona, como el resto de la Wiki
  > En el camino seco hay pocos pozos, y todos tienen huellas alrededor. Dos quedaron dentro del perímetro del puesto.
  > 
  > El mismo día en que se aseguró el paso empezaron los fallos: torres que se apagan sin motivo. Las observaciones coinciden en un encapuchado con un bastón que chispea, que se acerca a las torres y no a los colonos.
  > 
  > No ataca a las personas. Ataca lo que construye la colonia.

**Mi redacción:** 

**Nota:** 

### Los poblados vacíos

#### Wiki · Los poblados vacíos  `lore.poblados_vacios`
*Fuente:* `data/wiki/lore/poblados_vacios.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H14

**Actual:**
> Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.
> 
> No hay nadie. Las brasas están tibias, así que se fueron hace poco, y se llevaron lo que podían cargar.
> 
> La Compañía registra los poblados como «posiciones desocupadas».

- [ ] **A · Sin las brasas** — H14: no repite «brasas tibias» de la victoria del 14
  > Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.
  > 
  > No hay nadie. Se fueron hace poco y se llevaron lo que podían cargar.
  > 
  > La Compañía registra los poblados como «posiciones desocupadas».
- [ ] **B · Sin «posiciones desocupadas»** — H14: saca la línea que la spec ya marcaba como la que podía sobrar
  > Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.
  > 
  > No hay nadie. Las brasas están tibias, así que se fueron hace poco, y se llevaron lo que podían cargar.
- [ ] **C · Las dos cosas** — H14: más corto: solo lo que queda en pie y que se fueron
  > Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.
  > 
  > No hay nadie. Se fueron hace poco y se llevaron lo que podían cargar.

**Mi redacción:** 

**Nota:** 

### La Central

#### Wiki · La Central  `lore.la_central`
*Fuente:* `data/wiki/lore/la_central.json` · *Límite:* hasta 0 línea(s), 0 caracteres, orientativo · *Hallazgos:* H3, H9, H14

**Actual:**
> La central quedó en el valle donde aterrizó la nave. Produce la energía que necesita la colonia y alimenta la línea que la une con la mina.
> 
> Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.
> 
> Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.
> 
> El informe termina ahí. No dice qué se hará con lo que falta.

- [ ] **A · A · Último valle** — H9, H14: fija dónde queda y saca el párrafo 4, que anticipa el epílogo
  > La central quedó en el último valle, el del este. Produce la energía que necesita la colonia y alimenta la línea que la une con la mina.
  > 
  > Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.
  > 
  > Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.
- [ ] **B · B · «La máquina» tiene referente** — H3, H9, H14: los colonos llaman «la máquina» a la central, y el epílogo apunta a algo. Riesgo: puede leerse como la colonia entera
  > La central quedó en el último valle, el del este. Los colonos le dicen «la máquina»: produce la energía que necesita la colonia y alimenta la línea que la une con la mina.
  > 
  > Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.
  > 
  > Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.
  > 
  > El informe termina ahí. No dice qué se hará con lo que falta.
- [ ] **C · C · Solo sacar el párrafo 4** — H14: el artículo no repite la pregunta del epílogo; el resto igual
  > La central quedó en el valle donde aterrizó la nave. Produce la energía que necesita la colonia y alimenta la línea que la une con la mina.
  > 
  > Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.
  > 
  > Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.

**Mi redacción:** 

**Nota:** 
