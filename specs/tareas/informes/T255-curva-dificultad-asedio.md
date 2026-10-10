# T255 · Curva de dificultad y nivelación de Asedio

> Investigación del 2026-10-10 para que decida Lucas. Referencia: D-078, RF-388 a RF-392 y T251 §7. No se cambiaron datos ni código del juego. Las modificaciones del bot son experimentos temporales dentro de tools/; este informe no aprueba una nueva regla de Asedio.

## 0. Resultado y decisión propuesta

**Se pueden conservar los quince mapas sin cambiar la campaña.** El 115 % uniforme gana sólo **3 de 15 mapas** con sin_recursos, y **6 de 15** con la regla de mejorar cuando el mapa está lleno. Un perfil de porcentajes por mapa, con las políticas explícitas de §5.3, gana **75 de 75 partidas**: cinco semillas en cada uno de los quince mapas. Todos sus porcentajes son mayores que 100 % y no necesita recursos, extracción ni demolición.

**Recomiendo ese perfil como punto de partida para G5 y la extensión de porcentajes por mapa**, conservando las referencias del bot y la campaña. No recomiendo seis copias de los mapas finales como solución general: no corrigen los picos del Asedio actual y agregan mantenimiento. Tampoco recomiendo publicar la tabla como «balance definitivo» sin jugarla: la progresión mejora por bloques, pero las vidas del bot no bajan de forma estricta entre cada par de mapas.

La prueba de varias semillas fue decisiva: **122 % en el mapa 14 parecía ganable con la semilla 1, pero sólo ganó 1 de 5**. Al 118 % ganó 5 de 5. La propuesta usa este último valor, no el aparente máximo de una sola partida.

## 1. Alcance y método

Se mide la campaña completa, del 1 al 15, y el equivalente de Asedio con 115 % de vida, conservando oro, vidas, torres, caminos, grupos y tiempos de aparición. El paquete oficial sigue teniendo nueve mapas: las mediciones del 10 al 15 son una extensión simulada, no niveles ya publicados en el modo.

Base del repositorio: 5931c7d8770747e4e50ae317e1874c6274c76a5e, rama feature/t253-curva-asedio. Motor: Godot 4.7.2.stable.official.ed1daf0bf, Linux, sin ventana y con paso fijo de 1/60 s. Se usan las semillas 1 a 5, emparejadas entre variantes. La referencia principal es sin_recursos, la estrategia de RF-432; no demuele, no extrae, no compra Disruptora ni recibe recursos ficticios. También se contrasta smart en los primeros mapas: cambiar el orden de compra puede cambiar la conclusión sin cambiar el mapa.

Las medidas son victorias sobre cinco, vidas finales, oleada de derrota y oro sobrante. Una derrota se informa como derrota aunque ocurra en la última oleada. Las vidas son un indicador de margen de esta estrategia, no una escala universal de dificultad: una fuga de un jefe provoca saltos, y torres y entradas distintas impiden comparar sólo la cantidad de enemigos.

**No se usó hp=1.15.** Ese argumento modifica únicamente seis tipos de enemigos. Se fijó enemy_health_percent en memoria, que es el mismo campo aplicado por ModePacks y consumido por WaveSpawner. El modo actual sólo cambia ese porcentaje: oro_inicial_% es 100 y no reemplaza las vidas ni las torres. Así se pueden estudiar sus quince mapas sin editar modo.json.

## 2. Regla mínima de mejoras del bot

Se repite el experimento de T251: primero se construye como siempre; cuando no queda ninguna casilla construible libre, se intenta una mejora por frame. Se elige la torre de menor nivel y, entre ellas, la de menor costo de mejora. El cobro y la mejora pasan por BuildController.try_upgrade; no se otorga oro ni daño gratuito. Se registran cantidad de mejoras, oro gastado y oleada de la primera mejora.

La implementación exacta del apéndice de T251 **no filtra primero las torres pagables**: si la candidata de menor nivel no alcanza, espera. Se mantiene esa regla para comparar con T251. No vende, no cambia objetivos, no repara, no usa recursos ni sabe anticipar amenazas. Si el mapa todavía tiene una casilla libre, no mejora aunque esa casilla sea mala. Por eso un fracaso con esta regla sigue sin demostrar imposibilidad para una persona.

### 2.1 Control: mejorar antes de llenar el mapa

Se probó también una segunda regla mínima: después de comprar, permite gastar sobrante en mejoras desde tres torres construidas, aunque haya casillas libres. El resto de la compra y la selección de mejoras es idéntico. Este control usa **una semilla por mapa** al 115 %; no sustituye la referencia de cinco semillas.

Mejora el mapa 4 de derrota a V20 y el 8 de derrota a V16, pero empeora el 3 de V6 a D9/20 y el 11 de D14/22 a D6/22. También pierde 14 y 15 antes que la regla de llenar el mapa. Gastar temprano puede quitar el oro que necesita ampliar cobertura. **Ninguna de las dos políticas domina en todos los mapas.** La tabla de §5.3 fija la política antes de las cinco partidas: temprana sólo para el mapa 4; al llenar el mapa para los demás; smart sólo para el 2.

## 3. Curvas medidas del 1 al 15

Se completaron **300 partidas de referencia**: 15 mapas × 5 semillas × 2 porcentajes × 2 variantes del bot. Vn significa victoria con n vidas; Dw/t, derrota en la oleada w de t. Los rangos incluyen las cinco semillas y la fracción informa victorias sobre partidas.

| Mapa | Campaña 100 %, sin mejoras | Asedio 115 %, sin mejoras | Campaña 100 %, mejoras al llenar | Asedio 115 %, mejoras al llenar |
|---|---|---|---|---|
| 1 · Pradera | 5/5 · V20 | 5/5 · V3 | 5/5 · V20 | 5/5 · V3 |
| 2 · Desfiladero | 0/5 · D15/15 | 0/5 · D12/15 | 0/5 · D15/15 | 0/5 · D12/15 |
| 3 · Encrucijada | 5/5 · V16 | 5/5 · V6 | 5/5 · V16 | 5/5 · V6 |
| 4 · Espiral | 5/5 · V10 | 0/5 · D15/15 | 5/5 · V10 | 0/5 · D15/15 |
| 5 · Fortaleza | 5/5 · V13 | 5/5 · V4 | 5/5 · V13 | 5/5 · V4 |
| 6 · Nido | 5/5 · V9 | 0/5 · D7/15 | 5/5 · V9 | 0/5 · D7/15 |
| 7 · Cruce | 5/5 · V16 | 0/5 · D19–20/20 | 5/5 · V16 | 0/5 · D19–20/20 |
| 8 · Bastión | 5/5 · V12–14 | 0/5 · D18/18 | 5/5 · V12–14 | 0/5 · D18/18 |
| 9 · Taller asediado | 5/5 · V11 | 0/5 · D13–16/20 | 5/5 · V11 | 0/5 · D13–16/20 |
| 10 · La mina vieja | 5/5 · V7–13 | 0/5 · D18/20 | 5/5 · V20 | 5/5 · V10 |
| 11 · Puesto seco | 5/5 · V6 | 0/5 · D14/22 | 5/5 · V8 | 0/5 · D14/22 |
| 12 · El cañadón | 5/5 · V3–5 | 0/5 · D20/24 | 5/5 · V16 | 0/5 · D20/24 |
| 13 · Paso alto | 5/5 · V6 | 0/5 · D20/24 | 5/5 · V9 | 0/5 · D20/24 |
| 14 · Los poblados vacíos | 5/5 · V3 | 0/5 · D23/26 | 5/5 · V19–20 | 5/5 · V12–14 |
| 15 · La Central | 5/5 · V2 | 0/5 · D30/30 | 5/5 · V9 | 5/5 · V5 |

La campaña da 70/75 victorias con este orden de compra; las cinco derrotas son el mapa 2. El Asedio uniforme pasa de **15/75 a 30/75** al agregar mejoras. Los mapas recuperados son **10, 14 y 15**; no cambia el resultado de los primeros nueve. Al 100 %, las mejoras aumentan especialmente el margen del cierre: 10 → V20, 12 → V16, 14 → V19–20 y 15 → V9. Esto cambia el instrumento, no la dificultad de la campaña ni sus datos.

**No hay una curva monotónica en el Asedio actual.** Empieza con V3, luego D12/15 y V6; el 6 cae a mitad del nivel y el 15 sin mejoras llega a la última oleada. Con mejoras, el 14 queda mucho más holgado que el 13. Añadir únicamente el tramo final conservaría estos saltos.

**La referencia del mapa 2 requiere contexto.** En estas mediciones sin_recursos lo pierde en campaña en las cinco semillas, en la oleada 15/15; smart lo gana con 17 vidas. T236 ya había registrado esa diferencia y aclaraba que era anterior al cierre de la V1. No apareció un fallo nuevo del juego: este orden de compra del bot resulta malo para ese mapa. Al 115 %, ambas estrategias lo pierden en 12/15. No se propone bajar la dificultad de campaña para hacer ganar a sin_recursos.

**El problema no se limita a los mapas 10 a 15.** Asedio sin_recursos termina el mapa 1 con sólo 3 vidas, pierde el 2 y el 4 y cae en 7/15 en el 6. La regla de mejoras no corrige los mapas 1 a 4: no llega a intervenir. Estudiar sólo copias del tramo final dejaría intactos esos picos de apertura.

### 3.1 Qué pasa con el oro del tramo final

| Mapa | Oro al terminar al 115 %, sin mejoras | Mejoras al 115 % | Oro invertido en mejoras | Primera mejora | Oro final, con mejoras |
|---|---:|---:|---:|---|---:|
| 10 | 2053–2073 | 41 | 3660 | oleada 13 | 399–417 |
| 11 | 70–92 | 0 | 0 | — | 70–92 |
| 12 | 1039–1068 | 11–12 | 940–1030 | oleada 17 | 17–86 |
| 13 | 5–91 | 0 | 0 | — | 5–91 |
| 14 | 2855–2886 | 49 | 5420 | oleada 18 | 336–362 |
| 15 | 3881–3911 | 52 | 5200 | oleada 24 | 232–259 |

El mapa 15 gasta 5200 en 52 mejoras desde la oleada 24 y gana V5 en todas las semillas. Esa inversión puede superar el oro que sobraba en la derrota sin mejoras: al sobrevivir y matar más enemigos cobra más recompensas y bonos. En 11 y 13 esta regla no llega a hacer mejoras al 115 %. El 12 sí hace 11–12 mejoras desde la oleada 17, gasta 940–1030 de oro y aun así pierde en la 20: el sobrante de la referencia no queda intacto. Esto precisa la explicación de T251 §2.5, que atribuía su derrota a no llegar a mejorar. No es una prueba de que mejorar allí sea inútil: el control temprano cambia el gasto y el resultado, y una persona puede elegir otra prioridad.

## 4. Palancas medidas

### 4.1 Qué cambia al bajar el aumento por oleada

Antes de los redondeos enteros, la relación de vida frente a la campaña en la oleada w es:

    relación(w) = 1,15 × (100 + aumento_copia × (w − 1)) / (100 + aumento_campaña × (w − 1))

La copia sigue empezando al 115 %, pero esa ventaja baja con las oleadas. No equivale a un porcentaje fijo menor: éste reduce también la primera oleada. Una copia puede mantener una apertura exigente y aflojar el cierre; un porcentaje por mapa afloja toda la partida. En el juego se redondea hacia abajo primero el escalado de oleada y después el porcentaje del modo, por lo que estas relaciones son aproximaciones analíticas, no vidas exactas de cada enemigo.

| Mapa | Oleadas | Aumento de campaña | Menor aumento entero de la copia que conserva más vida teórica hasta el final | Relación de vida en la última oleada con ese mínimo |
|---|---:|---:|---:|---:|
| 10 | 20 | 30 % | 26 % | 101,96 % |
| 11 | 22 | 27 % | 23 % | 100,52 % |
| 12 | 24 | 27 % | 23 % | 100,33 % |
| 13 | 24 | 40 % | 35 % | 102,03 % |
| 14 | 26 | 30 % | 26 % | 101,47 % |
| 15 | 30 | 23 % | 20 % | 101,96 % |

Con un punto menos que esos mínimos, el cierre ya tiene menos vida teórica que la campaña. Incluso con el mínimo, algunos enemigos chicos pueden tener exactamente la misma vida por redondeo. Por ejemplo, copiar el mapa 13 con aumento 34 % no conserva una dificultad adicional en todo el nivel: termina al 99,44 % de la vida teórica de campaña.

### 4.2 Resultados de los barridos

**Barrido diagnóstico de porcentajes, con mejoras al llenar y semilla 1.** Las columnas de una partida no equivalen a una validación 4/5: sirven para seleccionar candidatos, no para declarar un máximo seguro.

| Mapa | 101 % | 103 % | 105 % | 108 % | 110 % | 115 %, cinco semillas |
|---|---|---|---|---|---|
| 11 | 1/1 · V6 | 1/1 · V5 | 1/1 · V3 | 0/1 · D20/22 | 0/1 · D14/22 | 0/5 · D14/22 |
| 12 | 1/1 · V14 | 1/1 · V12 | 1/1 · V10 | 1/1 · V8 | 1/1 · V6 | 0/5 · D20/24 |
| 13 | 1/1 · V8 | 1/1 · V4 | 1/1 · V3 | 1/1 · V1 | 0/1 · D20/24 | 0/5 · D20/24 |

**Copias simuladas en memoria, sin crear mapas del juego.** Se conserva 115 % y sólo se cambia aumento_vida; mismas torres, oro, grupos, caminos y tiempos. Se enfocó la medición en los tres mapas que la regla de mejoras no recupera, 11 a 13. Para 10, 14 y 15, la referencia al 115 % ya gana 5/5, por lo que no hace falta reducir su aumento para demostrar que se pueden conservar.

| Mapa | Aumento de campaña | Copias al 115 %: aumento → resultado de una semilla |
|---|---:|---|
| 11 | 27 % | 23 % → 1/1 · V7 · 24 % → 1/1 · V1 · 25 % → 0/1 · D14/22 |
| 12 | 27 % | 23 % → 1/1 · V12 · 24 % → 1/1 · V10 · 25 % → 1/1 · V8 |
| 13 | 40 % | 34 % → 1/1 · V10 · 35 % → 1/1 · V5 · 36 % → 1/1 · V5 |

Se ensayaron además aumentos 34, 35 y 36 % en 11 y 12 como controles más duros: los seis casos pierden en la oleada 10. La copia del 13 con 34 % gana, pero termina con menos vida teórica que campaña y se descarta como ejemplo de «más vida en todo el nivel». Las copias 35 y 36 % conservan esa propiedad y dan V5 en la semilla 1; **no se verificaron con cinco semillas**. La del 11 con 24 % gana con una sola vida: demasiado cerca del borde para recomendarla sin otra prueba.

**El 14 demuestra por qué hay que validar.** Con una semilla, 118, 120 y 122 % dan V8, V8 y V7. Al repetir 122 % con cinco semillas, gana sólo la 1; las otras cuatro pierden en 23/26. Se repitió la semilla 2 sola y volvió a perder en 23/26, descartando que fuera sólo un efecto de correr la cola. Al 118 %, la verificación final gana 5/5 con V8–9.

Los resultados no siempre ordenan igual que los porcentajes: por ejemplo, el mapa 6 pasa de V9 al 100 % a V11 al 101 % con esta estrategia. La compra depende del momento de las muertes y del oro; el combate y las fugas son discretos. Una fuga de un jefe produce un salto grande. No se debe interpolar vidas linealmente ni identificar el porcentaje más alto observado con una dificultad universal.

## 5. Recomendación y requisitos que cambiarían

### 5.1 Costo y alcance de las tres palancas

| Palanca | Qué resuelve | Qué queda pendiente | Costo de implementación posterior |
|---|---|---|---|
| Bot que mejora | Gasta el oro acumulado cuando faltan casillas; permite separar limitaciones del bot de la defensa | No modifica Asedio para quien juega; no ayuda antes de llenar el mapa; no ordena por sí sola la curva | Herramienta en tools/, con opción explícita para conservar la referencia vieja |
| Copias de los mapas 10 a 15 con menor aumento | Conserva 115 % en la apertura y reduce la presión de las oleadas finales, sin código nuevo | No corrige la apertura de los mapas 1 a 9; puede acabar por debajo de campaña; las copias se desactualizan cuando cambia el original | Archivos JSON del modo y validadores existentes; cambio explícito de RF-391 |
| Porcentaje de vida por mapa | Permite calibrar las aperturas y los cierres de los quince mapas conservando las oleadas oficiales | No garantiza una curva ordenada sólo porque los porcentajes estén ordenados; exige barrer, verificar márgenes y probar a mano | Extensión pequeña pero real del formato, validación y aplicación de ModePacks; no existe hoy |

RF-388 permite buscar una copia en la carpeta del modo; no hace falta implementar esa búsqueda. En cambio, LevelFile no acepta vida_monstruos_% en el JSON de nivel y ModePacks aplica un porcentaje global: escribir ese campo en una copia o convertir las entradas de mapas en objetos sin cambiar el lector produciría un paquete inválido. La opción de porcentajes por mapa necesita una spec y código posteriores.

### 5.2 Requisitos y documentos afectados

Estos son cambios propuestos, **no modificaciones hechas por T255**:

- **RF-391:** reemplazar el alcance 1 a 9 por 1 a 15 y el 115 % uniforme por la política que elija Lucas. Definir cómo se comprueba el margen de cada mapa y la progresión entre bloques; conservar la campaña. Si se eligen copias, permitir explícitamente distinto aumento de vida por oleada y aclarar que grupos, cantidades, entradas y tiempos se conservan.
- **RF-388, sólo si se eligen porcentajes por mapa:** agregar una tabla opcional de porcentajes por id de mapa al paquete, con precedencia sobre la regla global. Mantener válidos los paquetes actuales. Validar enteros dentro del rango ya admitido, ids presentes en la lista y errores de forma; no aceptar silenciosamente una entrada desconocida.
- **RF-389 y RF-390:** sus reglas de selección y progreso ya sirven para quince mapas. No necesitan una mecánica nueva; hay que comprobar listado, desbloqueo secuencial, estrellas e independencia de campaña al ampliar Asedio.
- **RF-392:** conservar lectura y guardado de los modos existentes. Si un modo propio usa la tabla nueva, documentar y probar que guardar sus mapas no borre esos metadatos; una interfaz nueva para editarlos sería un alcance adicional que Lucas debe decidir.
- **RF-432 y RF-475:** conservar la referencia sin_recursos histórica de campaña. Si las mejoras pasan a integrar una medición normativa, registrar cuál es la variante y su criterio; no sustituir silenciosamente las tablas viejas ni concluir que el juego se volvió más fácil por cambiar el instrumento. La regla de oro no autoriza a exigir Disruptora, Mortero ni extracción en Asedio.
- **D-078:** enlazar una decisión nueva que revise el esquema y la calibración del modo, conservando el historial de la decisión original. Los números RF y D nuevos se asignan recién en la tarea de spec, buscando los siguientes libres; este informe no los reserva.

La implementación elegida requiere actualizar la sección de modos de specs/01-spec.md, specs/02-plan-tecnico.md, specs/03-tareas.md y specs/04-decisiones.md; los alcances y valores repetidos en README.md, ONBOARDING.md, CONTENIDO.md y CHANGELOG.md; y cualquier ficha que todavía describa Asedio con nueve mapas o porcentaje uniforme. Los textos de lore de la campaña no cambian: RF-468 ya excluye sus entradas y victorias de los modos.

### 5.3 Perfil concreto para probar antes de publicar

**Conservar los quince mapas, mantener la campaña y agregar porcentajes por mapa.** Mantener 115 % como regla global y aplicar las excepciones de esta tabla. No crear las seis copias: el perfil conserva todos los caminos, oleadas, recursos y aumentos originales. Usar las dos políticas del bot como opciones explícitas; no reemplazar silenciosamente la referencia histórica de RF-432.

El perfil ganó **75/75 observaciones**, cinco por mapa. Son **70 partidas nuevas** y las cinco ya medidas del 15 al 115 % con mejoras al llenar. En el mapa 2 se usa smart por el problema de orden de compra registrado en T236. En el 4 se conserva 115 % y se usa la política temprana: ganó las cinco con 20 vidas; bajar a 101–103 % sólo porque la política tardía deja cinco vidas sería calibrar una limitación del bot. Son políticas fijadas por mapa, no elegidas por semilla ni una regla nueva que se le imponga al jugador.

| Mapa | Vida propuesta | Estrategia y mejoras del bot de referencia | Resultado, semillas 1–5 |
|---|---:|---|---|
| 1 · Pradera | 105 % | sin_recursos · al llenar | 5/5 · V20 |
| 2 · Desfiladero | 105 % | smart · al llenar | 5/5 · V13 |
| 3 · Encrucijada | 105 % | sin_recursos · al llenar | 5/5 · V15 |
| 4 · Espiral | 115 % | sin_recursos · tempranas desde tres torres | 5/5 · V20 |
| 5 · Fortaleza | 108 % | sin_recursos · al llenar | 5/5 · V12 |
| 6 · Nido | 101 % | sin_recursos · al llenar | 5/5 · V11 |
| 7 · Cruce | 103 % | sin_recursos · al llenar | 5/5 · V15–16 |
| 8 · Bastión | 101 % | sin_recursos · al llenar | 5/5 · V12–16 |
| 9 · Taller asediado | 101 % | sin_recursos · al llenar | 5/5 · V8–9 |
| 10 · La mina vieja | 118 % | sin_recursos · al llenar | 5/5 · V8–10 |
| 11 · Puesto seco | 101 % | sin_recursos · al llenar | 5/5 · V6 |
| 12 · El cañadón | 110 % | sin_recursos · al llenar | 5/5 · V6–8 |
| 13 · Paso alto | 101 % | sin_recursos · al llenar | 5/5 · V8 |
| 14 · Los poblados vacíos | 118 % | sin_recursos · al llenar | 5/5 · V8–9 |
| 15 · La Central | 115 % | sin_recursos · al llenar | 5/5 · V5 |

**Cómo avanza la referencia por bloques.** Promedio de vidas de cinco mapas por semilla, luego promedio de las cinco semillas:

| Bloque | Promedio de vidas | Rango del promedio entre semillas |
|---|---:|---:|
| 1–5 | 16,00 | 16,00–16,00 |
| 6–10 | 11,72 | 11,00–12,20 |
| 11–15 | 6,84 | 6,60–7,20 |

La apertura deja más margen, el tramo medio baja y el cierre vuelve a bajar. **No es una curva estricta mapa por mapa:** el 4 recompensa mejorar temprano, el 7 deja más vidas que el 6 y el 8 tiene variación. Esta tabla demuestra que no hace falta sacar niveles para que una referencia razonable complete el modo y que se puede graduar por bloques; **no demuestra todavía que Lucas sienta la progresión correcta**. Tampoco los porcentajes deben subir en orden: multiplican bases distintas.

Propongo llevar este perfil a G5 y probar especialmente 1–4, 6–9 y 13–15. Si el salto que siente Lucas es distinto del que muestran las vidas, se ajusta el porcentaje del mapa correspondiente y se repiten sus semillas, conservando ambos diagnósticos del bot. Publicar sólo después de esa comprobación; el criterio «no es balance definitivo» de RF-391 sigue vigente durante la prueba.

**Alternativa si Lucas prefiere evitar extender el formato:** copias sólo de los mapas cuyo cierre no alcance, con los mínimos de §4.1 y validación de cinco semillas. Es compatible con la búsqueda actual de RF-388 y mantiene apertura al 115 %, pero no resuelve por sí sola los picos 1–9 y no conviene copiar por rutina los seis finales. Si se elige, habría que revisar también esas aperturas y sincronizar las copias con futuras correcciones de campaña.

## 6. Verificación y límites

La suite completa de GUT pasó: **1524/1524 tests, 17359 asserts, 112 scripts**, sin SCRIPT ERROR, Parse Error ni Unexpected Errors. Se importaron los recursos antes de las mediciones. Una primera corrida iniciada antes de terminar la importación imprimió errores de recursos de audio: se interrumpió, se descartó y se repitió después de importar; no integra las tablas.

**Comprobado:** las 300 partidas de referencia; el perfil de 75 observaciones; el modo oficial real 1–9 con semilla 1, que reproduce vidas y oleadas de la inyección del 115 %; el caso 14/122 %/semilla 2 repetido fuera de la cola, también derrota; y cero SCRIPT ERROR o Parse Error en las corridas retenidas. Los avisos de ObjectDB y recursos todavía en uso al salir de algunas herramientas aparecen también en la línea de base de T236; no se interpretaron como victorias ni se ocultaron.

Un primer intento del cargador auxiliar del perfil tuvo un Parse Error de indentación antes de iniciar partidas; se corrigió y se descartó esa ejecución. Los casos de las tablas provienen de las corridas corregidas, no de ese intento.

No se jugó manualmente, no se exportó un ejecutable y no se probó Android. Las semillas exploran los sorteos existentes; cinco resultados iguales no equivalen a cinco estrategias independientes. Ningún valor propuesto se cargó en data/ y ninguna modificación experimental queda activa en el bot del proyecto.

## 7. Reproducción

Se creó tools/_t253_balance.gd como copia temporal del bot, con el parche de abajo. Los comandos se muestran sin acentos graves. Ejemplos reales de las mediciones y equivalentes por caso del barrido:

    godot --headless --import
    godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
    godot --headless --path . --fixed-fps 60 -s tools/balance_sim.gd -- sin_recursos levels=1-15 seeds=5 report=/tmp/t253-results/campaign-base.json
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos levels=1-15 seeds=5 mp=115 report=/tmp/t253-results/siege-base.json
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos levels=1-15 seeds=5 mp=100 upg=1 report=/tmp/t253-results/campaign-upg.json
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos levels=1-15 seeds=5 mp=115 upg=1 report=/tmp/t253-results/siege-upg.json
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos modo=asedio levels=1-9 seed=1 report=/tmp/t253-results/native-siege.json
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos level=11 seed=1 mp=103 upg=1
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos level=11 seed=1 mp=115 upg=1 levelscale=23

Los barridos recorren los valores de las tablas, cambiando sólo mp y/o levelscale. La variante tools/_t253_scan.gd automatizó esas combinaciones con una cola y una copia de LevelData por partida, para no arrastrar un aumento modificado al siguiente caso. Los cuatro lotes iniciales se detuvieron después de completar las cinco semillas de los primeros nueve mapas: esas filas se recuperaron de los resultados completos del log. Para el tramo final se separaron lotes por mapa y condición, con JSON del bot; no se cuentan partidas interrumpidas ni filas duplicadas. La variante tools/_t253_fast.gd añadió dos cachés de la herramienta: casillas libres hasta que cambia built, y revisión de mejoras hasta que cambia built o el oro. Son válidas en las estrategias sin demolición usadas acá; no se proponen para las estrategias de infraestructura que modifican casillas. También se suprimió el bucle de renderizado en esos lotes con --disable-render-loop, conservando física y proceso a 60 Hz. La copia sin estas optimizaciones permite repetir cada caso; el bot permanente conserva su comportamiento original.

Para repetir el control temprano, copiar el script temporal y sustituir únicamente la condición de entrada de _upgrade_surplus: en lugar de esperar a que _free_cells quede vacío, retornar mientras built sea menor que 3. El resultado de cada mapa del control al 115 % y semilla 1 fue:

| Mapa | Control temprano |
|---|---|
| 1 | 1/1 · V10 |
| 2 | 0/1 · D15/15 |
| 3 | 0/1 · D9/20 |
| 4 | 1/1 · V20 |
| 5 | 1/1 · V14 |
| 6 | 0/1 · D15/15 |
| 7 | 0/1 · D18/20 |
| 8 | 1/1 · V16 |
| 9 | 0/1 · D16/20 |
| 10 | 1/1 · V16 |
| 11 | 0/1 · D6/22 |
| 12 | 0/1 · D7/24 |
| 13 | 0/1 · D14/24 |
| 14 | 0/1 · D18/26 |
| 15 | 0/1 · D25/30 |

Con smart, el control temprano del 2 también perdió en 15/15. Para reproducir el perfil de §5.3, correr cada mapa con su porcentaje, seeds=5 y la política indicada. Ejemplos adicionales:

    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- smart level=2 seeds=5 mp=105 upg=1
    godot --headless --path . --fixed-fps 60 -s tools/_t253_active.gd -- sin_recursos level=4 seeds=5 mp=115 upg=1
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos level=13 seeds=5 mp=101 upg=1
    godot --headless --path . --fixed-fps 60 -s tools/_t253_balance.gd -- sin_recursos level=14 seeds=5 mp=118 upg=1

### 7.1 Parche temporal de la regla e instrumentación

Copiar tools/balance_sim.gd de la revisión indicada en §1 a tools/_t253_balance.gd y aplicar este diff con git apply -p0. En esta transcripción los tabuladores se representan mediante la secuencia literal \t: convertirla en un tabulador real al guardar el parche. No reemplazar el bot permanente. Después de medir se eliminaron las copias temporales de tools/.

    --- tools/_t253_balance.gd
    +++ tools/_t253_balance.gd
    @@ -61,6 +61,7 @@
     #
     # --fixed-fps 60 hace que cada frame cuente como 1/60 s sin esperar al reloj real,
     # así una partida de ~10 minutos se simula en segundos.
    +# T255: copia temporal para medir; no modifica archivos del juego.
     extends SceneTree

     ## Orden de compra de "smart" (índices de Game.tower_types): primero Ametralladoras
    @@ -105,6 +106,11 @@
     ## levelscale=N: prueba otro % de vida por oleada para el nivel elegido (D-019). -1 = no tocar.
     var level_scale_override: int = -1
     var starting_gold_override: int = -1
    +var health_percent_override: int = -1
    +var upgrades_enabled: bool = false
    +var upgrade_count: int = 0
    +var upgrade_gold: int = 0
    +var first_upgrade_wave: int = -1
     ## T204: mapas y semillas a jugar, y la cola de partidas pendientes.
     var level_numbers: Array[int] = []
     var seed_list: Array[int] = [BalanceArgs.DEFAULT_SEED]
    @@ -171,6 +177,9 @@
     \tstrategy = _current["strategy"]
     \tlevel_number = _current["level"]
     \tbuilt = 0
    +\tupgrade_count = 0
    +\tupgrade_gold = 0
    +\tfirst_upgrade_wave = -1
     \tdisruptors_built = 0
     \t_disruptor_prepared = false
     \tlast_reported_wave = 0
    @@ -222,6 +231,8 @@
     \t\tgame.level_data.starting_gold = starting_gold_override
     \tif level_scale_override >= 0:
     \t\tgame.level_data.health_scale_percent_per_wave = level_scale_override
    +\tif health_percent_override > 0:
    +\t\tgame.level_data.enemy_health_percent = health_percent_override
     \troot.add_child(game)
     \t_seed_spawner()
     \tprint("Nivel: %s · estrategia: %s · semilla: %d · vida del Normal: %d" % [
    @@ -239,6 +250,12 @@
     ##   <enemigo>.<campo>=valor  cambia un enemigo (ej: tank.max_health=120)
     func _apply_override(arg: String) -> void:
     \tvar parts: PackedStringArray = arg.split("=")
    +\tif parts[0] == "mp":
    +\t\thealth_percent_override = parts[1].to_int()
    +\t\treturn
    +\tif parts[0] == "upg":
    +\t\tupgrades_enabled = parts[1] == "1"
    +\t\treturn
     \tif parts[0] == "file":
     \t\tlevel_file = parts[1] if parts[1].begins_with("res://") else "res://" + parts[1]
     \t\treturn
    @@ -347,6 +364,9 @@
     \t\t\t"level": _current["level"], "strategy": strategy, "seed": _current["seed"],
     \t\t\t"won": won, "lives": session.lives, "wave": session.wave,
     \t\t\t"total_waves": session.total_waves, "gold": session.gold,
    +\t\t\t"built": built, "upgrades": upgrade_count, "upgrade_gold": upgrade_gold,
    +\t\t\t"first_upgrade_wave": first_upgrade_wave, "health_percent": game.level_data.enemy_health_percent,
    +\t\t\t"health_scale": game.level_data.health_scale_percent_per_wave,
     \t\t\t"machine_wave": _machine_wave, "resources_gained": _res_gained, "resources_left": session.resources,
     \t\t\t"infra_gold": _infra_gold, "first_resource_tower_wave": _first_resource_tower_wave})
     \t\troot.remove_child(game)
    @@ -359,6 +379,7 @@
     \t\t\t_finish_rule_check()
     \t\treturn true
     \t_buy_towers()
    +\t_upgrade_surplus()
     \tif session.can_start_wave():
     \t\tgame.start_next_wave()  # sin esperar la cuenta atrás
     \treturn false
    @@ -768,3 +789,26 @@
     \t\tcode = 0 if level_numbers.is_empty() else 1
     \tprint("REGLA DE ORO: %s" % ("SE CUMPLE" if code == 0 else "NO SE CUMPLE"))
     \tquit(code)
    +
    +
    +## T255: una mejora por frame cuando ya no quedan casillas libres.
    +## Prioriza menor nivel y luego menor costo; usa el cobro normal del juego.
    +func _upgrade_surplus() -> void:
    +\tif not upgrades_enabled or not _free_cells().is_empty():
    +\t\treturn
    +\tvar best: Node = null
    +\tvar best_key: int = 1 << 30
    +\tfor tower: Node in game.get_tree().get_nodes_in_group(&"towers"):
    +\t\tif not tower.can_upgrade():
    +\t\t\tcontinue
    +\t\tvar key: int = int(tower.level_index) * 100000 + int(tower.next_level_stats().cost)
    +\t\tif key < best_key:
    +\t\t\tbest_key = key
    +\t\t\tbest = tower
    +\tif best != null:
    +\t\tvar cost: int = best.next_level_stats().cost
    +\t\tif game.build_controller.try_upgrade(best):
    +\t\t\tupgrade_count += 1
    +\t\t\tupgrade_gold += cost
    +\t\t\tif first_upgrade_wave < 0:
    +\t\t\t\tfirst_upgrade_wave = game.session.wave
