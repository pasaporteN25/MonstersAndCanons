# Propuesta de simplificación del panel de torre

**Entrega de diseño, para revisar con Lucas. No es una implementación ni una aprobación de cambios de requisitos.** Las seis alternativas están en `maquetas-codex.html`, rotuladas «Maqueta, no motor». Recomiendo **PC 1 + Celular 1**: una sola lectura con los valores actuales y futuros juntos, sin esconder datos de decisión detrás de scroll, hover o una segunda pantalla.

## Qué leí y qué pude comprobar

Leí las dos hojas de casos, las dos capturas de pantalla completa, los TSV solicitados, `tower_panel.tscn`, `tower_panel.gd`, `mobile_hud.gd` (incluida `show_selected_tower`), `tower_text.gd`, ambos JSON de interfaz y ambos recursos de tema. Contrasté los ejemplos con `data/towers/{tesla,frost,mechanical_standard,cannon,basic}.tres`. Leí la constitución, las instrucciones del repositorio, los RF solicitados, D-193 a D-197 y los dos archivos de tests. No hace falta consultar documentación externa para esta comparación del proyecto.

Los TSV confirman que el panel PC reserva 320 px para contenidos muy distintos y que Hielo n1 necesita 93 px donde tiene 60. El celular coloca un bloque de 127 px desde y = 626: termina en 753, fuera del lienzo de 720. No es un problema que se resuelva cambiando colores.

En el código, `_refresh_upgrade_preview` elimina frases por prefijo y lleva los cambios a un bloque separado. La prueba `test_panel_shows_each_upgrade_value_once_for_cannon_tesla_ice_and_disruptor` exige esa eliminación: hoy protege una presentación contraria al ejemplo de RF-677.1. Corregir el diseño requiere corregir esa expectativa, conservando la prueba de que cada cambio aparece una sola vez.

**Límite de verificación:** inspeccioné las imágenes actuales y las fuentes. Las medidas siguientes son tamaños de diseño especificados en CSS, no mediciones nuevas en Godot. No pude renderizar el HTML: Firefox rechazó arrancar por la restricción de su paquete snap y no hay un navegador conectado en la herramienta de revisión. No verifiqué tipografía real de Godot, desbordes con un navegador, teléfono físico ni ejecución de GUT. No se ejecutó el motor para evitar generar archivos fuera del directorio autorizado. El HTML usa Arial/sans-serif del sistema como aproximación, sin fuentes externas.

## Criterio común

1. **Primero identificar, después comparar, después actuar.** Nombre completo, tarjeta de nivel, estadísticas y efectos; luego Mejorar; venta separada. No hay descripción de Wiki ni rótulo de animación suelto.
2. **La flecha vive en la frase.** «El rayo salta a 2 → 3 enemigos más», no «saltos 2 → 3». Son enemigos adicionales al primer impacto: decir solamente «3 enemigos» cambiaría el significado de `chain_extra_targets`. «Ralentiza 40 → 50 % durante 2 s» conserva el tiempo que no cambia. La Disruptora debe decir «Pulso: apaga las auras durante 2,5 → 3 s», sin repetir daño, frecuencia ni radio.
3. **Coma y precisión uniformes.** `0,75 → 0,85/s`, `2,5`, `3`. El resalte `#bfe699` toca únicamente el después, también cuando no hay oro suficiente; no promete que se haya aplicado la mejora. No achicar solo la cadencia.
4. **Mostrar únicamente campos aplicables.** El Estandarte muestra alcance, apoyo y reparación; no daño cero, Voladores ni Apuntar. La Disruptora conserva daño, frecuencia y alcance, pero omite Apuntar. Esto exige enmendar el selector deshabilitado de RF-512 y precisar RF-70 para torres sin apuntado.
5. **Tres rectángulos bajos, sin estiramiento vertical.** PC: 16 × 10 px, separados 3 px; celular: 22 × 12 px, separados 3 px. Cada metal ocupa una posición fija. Lleno = alcanzado; contorno = pendiente. Se conserva «Nivel actual: N de 3» como tooltip y nombre accesible, sin duplicarlo como texto visible.
6. **El mismo hierro del resto del juego.** Fondo `#1b1c20`, borde `#855c2b`, título `#ffd673`, texto `#f0e8d9`; botones con borde de 2 px y 4 abajo, radio 6 y sombra suave. Hover con borde y texto `#ffb833`. Mejorar gana jerarquía por posición y negrita; Vender usa el mismo material y un peso menor, sin bloque rojo. El contorno de foco debe seguir visible.
7. **No confundir inversión con devolución.** «Recursos invertidos: 2» y «Devuelve 1 recurso» no son el mismo dato. Propongo sacar la inversión histórica de la lectura principal; el reembolso exacto queda visible en Vender y en su confirmación. Si se conserva el historial, va a información secundaria, sin duplicar el reembolso. Revisar RF-418 antes de implementarlo.
8. **Estados vivos nunca desaparecen.** Aturdimiento y desgaste van junto al nombre; apoyo y reparación recibidos, prestaciones actuales y cualquier otro modificador efectivo deben agregarse como líneas condicionales. No reemplazar la cadencia efectiva por una base sin explicarlo. Las dimensiones comparadas corresponden a las torres sanas de ejemplo; estados simultáneos necesitan crecimiento adicional y capturas específicas.

**Contenido para decidir que conservan las seis alternativas**, de forma inmediata o con el despliegue que se señala: identidad, nivel actual, daño/frecuencia cuando aplican, alcance en casillas, todos los cambios de la mejora, efectos y restricciones, interacción con voladores cuando corresponde, combo con condición y beneficiarios, prioridad vigente cuando existe, costo, nivel de destino, motivo de indisponibilidad y devolución de venta. No se cambia el balance ni la selección de estadísticas de `UpgradeDeltas`/`mejoras.json`. La semántica de cada efecto se compone con los datos de torre; las etiquetas breves de la animación no alcanzan para redactarla.

## PC: tres estructuras

Todas flotan por encima de la barra inferior, con el borde derecho a x = 1270. El anclaje inferior de referencia es y = 580, como el panel actual: crecen hacia arriba. Esto mantiene libre el catálogo; el hueco hasta la barra inferior no se ocupa con otra acción. Los tamaños incluyen borde y relleno.

| Alternativa | Eléctrica n1 | Hielo n1 | Estandarte n1 | Costo |
|---|---:|---:|---:|---|
| PC 1 · Ficha de lectura | 340 × 308 | 340 × 332 | 340 × 316 | Medio |
| PC 2 · Franja de dos columnas | 700 × 220 | 700 × 244 | 700 × 244 | Medio |
| PC 3 · Resumen con despliegue | 320 × 260 / 420 | 320 × 260 / 448 | 320 × 260 / 420 | Alto |

En PC 3, el segundo alto es el estado abierto. Hielo y Estandarte de PC 2/3 son presupuestos de diseño; el HTML representa esos casos únicamente en PC 1.

### PC 1 · Ficha de lectura — recomendada

**Idea:** una ficha algo más ancha, sin scroll interno, que permite entender y mejorar la torre en una sola mirada.

- Arriba: nombre de 20 px, tarjeta de nivel y cerrar de 28 × 28. El nombre del Estandarte tiene dos líneas completas, sin elipsis.
- Estadísticas en tres columnas de **68 / 138 / 82 px**, con dos espacios de 12, dentro de 312 px útiles. Rótulos de 12 y todos los valores de 16 px. Así la cadencia recibe ancho, en vez de una letra más chica. En apoyo, la única métrica de alcance ocupa una fila.
- Efectos de 15 px, con las flechas dentro de las frases. Hielo conserva el combo en dos líneas deliberadas: «Combo: Cañón y Francotirador» / «+25 % de daño a los que frena». No abrevia beneficiarios ni condición para forzarlo a una sola línea.
- Mejorar ocupa 312 × 34. En el pie, separado por 16 px y una línea bronce, conviven Apuntar y Vender; Vender queda a la derecha con devolución y `[S]`. Ya no hay tres acciones grandes apiladas. Si no existe Apuntar, el pie contiene solo la venta, sin un botón apagado ni un hueco reservado.
- Se mueve fuera del cuerpo principal la inversión histórica. No se esconde ninguna estadística de decisión. Las torres comunes recuperan altura: la maqueta de Ametralladora sin oro usa 340 × 276, con «Faltan 25 de oro» a la vista además del costo de 60.

**Costo de la elección:** simplifica la lectura, pero no promete menos superficie en todos los casos. Eléctrica ocupa 104.720 px², frente a 86.400 actuales: un 21 % más. Hielo ocupa 112.880 px², a cambio de tener todo visible. Antes de implementar, capturar sobre mapas densos: liberar el scroll tiene un costo real de mapa. La reducción está en recorridos, repeticiones y peso de acciones; no en comprimir el texto.

**Decisión conservada:** todo el contenido común está visible, incluidos los tres cambios de Eléctrica y los tres de Estandarte. Cañón n3 conserva daño 50, 0,6/s, alcance 3,5, radio 1,5, +25 % a ralentizados, Voladores: no, venta 266 y Nivel máximo, sin flechas.

**Enmiendas:** RF-677 y RF-686 para reemplazar la exigencia de 270 px; RF-650 para dimensiones adaptadas al contenido; precisar RF-70 y revisar RF-418 por campos aplicables e inversión histórica. RF-616 ya está enmendado por RF-677: no restaurar el bloque. D-193 necesita actualizar el riesgo aceptado y la solución tipográfica, manteniendo el principio de cada dato una vez. D-194 a D-197 no cambian.

**Pruebas afectadas:** U1/U2/U3 y L1/L2 del mapa de tests de abajo. Se conservan las aserciones funcionales de hover y atajos de otras suites; el nuevo pie no puede cambiar U/S ni interceptar el hover de Mejorar.

### PC 2 · Franja de dos columnas

**Idea:** cambiar altura por ancho: comparar a la izquierda y entender el efecto a la derecha.

- Caja de 700 px; cuerpo con columna de 330, separación de 24 y columna de 318 px. Encabezado común. Estadísticas y Apuntar a la izquierda; efectos, combo y Voladores a la derecha. Abajo Mejorar y Vender, con 50 px de separación horizontal.
- No se esconde información de decisión. Se mueve la venta al extremo derecho de la fila de acciones, y la inversión histórica sale de la lectura principal como en PC 1. Apoyo usa la columna izquierda para alcance y la derecha para apoyo/reparación; Apuntar desaparece.
- En el anclaje propuesto ocupa x = 570–1270. Su menor alto deja ver más por encima del HUD, pero tapa mucho ancho del camino: Eléctrica ocupa 154.000 px², un 78 % más que el panel actual. Es una alternativa para priorizar lectura horizontal, no una ganancia de mapa.

**Decisión conservada:** todo visible simultáneamente. La proximidad horizontal ayuda a relacionar números y efectos; hay más recorrido de ojos entre las columnas.

**Enmiendas:** las de PC 1; precisar RF-74 por la franja ancha sobre el mapa y revisar su encaje con el resto del HUD. D-193 debe recoger la nueva composición, sin cambiar la regla de flechas. No cambia D-194 a D-197.

**Costo medio:** dos columnas y cálculo de alto por la más larga; no requiere estados de navegación nuevos. **Pruebas:** U1/U2/U3 y L1/L2. L1 debe medir también ambos extremos horizontales y la fila de acciones, no solo el borde inferior de Vender.

### PC 3 · Resumen con despliegue

**Idea:** dejar a la vista la mejora y el efecto principal; abrir el resto únicamente cuando se necesita comparar o cambiar otra acción.

- Cerrada: nombre, nivel, métricas con todas sus flechas, efecto principal con su cambio, Mejorar y «Más datos y acciones». El estado de la torre permanece visible.
- Abierta: añade bonus/combo, Voladores, reglas de apoyo, Apuntar y Vender con devolución. No repite el efecto principal. En Estandarte, apoyo y reparación con sus cambios deben quedar en el resumen; las restricciones pasan al despliegue.
- Abrir/cerrar es una acción de interfaz sin costo ni pausa. Al elegir otra torre, vuelve cerrada. `[S]` sigue funcionando aun cerrada: **no** se transforma en abrir detalles ni se añade una confirmación PC nueva. Ese atajo hace a la opción menos predecible para quien ve Vender oculto.
- Crece hacia arriba y no usa scroll para estos ejemplos. Una combinación de estados que no entre requiere otra especificación de crecimiento, no un recorte silencioso.

**Decisión conservada:** costo, destino y todas las mejoras visibles sin abrir; daño condicionado, voladores, combo, prioridad y devolución requieren un clic adicional. Es información recuperable dentro del panel, pero no tiene la misma disponibilidad que en PC 1/2. Por eso no la recomiendo.

**Enmiendas:** RF-70, RF-650, RF-677 y D-193 para aprobar la divulgación progresiva; RF-74/RF-686 para alto y ancho; revisar RF-418 como en PC 1. RF-76 conserva los atajos y Nivel máximo. Sin cambios a D-194 a D-197.

**Costo alto:** añade estado de despliegue, foco y apertura por teclado, reinicio al cambiar de selección y verificación del crecimiento. **Pruebas:** U1/U2/U3 y L1/L2, con recorridos de panel cerrado y abierto. L1 ya no puede exigir Vender dentro del rectángulo visible mientras su sección está cerrada; sí debe exigirlo al abrirla.

## Celular: tres estructuras, solo apaisado

Base de comparación: 1280 × 720. Texto de contenido y acciones de **20 px como mínimo**, valores de 22 y nombre de 24; no convertir esto en una afirmación de sp reales. El tamaño físico y el área segura necesitan teléfono real. Ninguna maqueta se escala con `transform` ni con zoom para entrar en el HTML.

| Alternativa | Eléctrica n1 | Hielo n1 | Estandarte n1 | Costo |
|---|---:|---:|---:|---|
| Celular 1 · Banda en dos pisos | 1280 × 280 | 1280 × 280 | 1280 × 280 | Medio |
| Celular 2 · Barra con efectos desplegables | 1280 × 176 / 350 | 1280 × 176 / 376 | 1280 × 176 / 376 | Alto |
| Celular 3 · Inspector separado | 1280 × 360 | 1280 × 386 | 1280 × 386 | Alto |

Celular 2 indica cerrada/abierta. Celular 3 indica la envolvente máxima; no toda esa superficie lleva fondo. Hielo y Estandarte de Celular 2/3 son presupuestos, no casos renderizados en el HTML.

**Acciones comunes:** Mejorar en x = 16–236, 220 × 84 px; Apuntar en x = 260–476, 216 × 56; Vender en x = 1088–1264, 176 × 84. La distancia libre horizontal entre Mejorar y Vender es **852 px**, superior a los ~372 px de referencia para 35 mm. Se mantiene una separación espacial aun cuando haya Apuntar entre ellos. No equiparar esos px con mm en cualquier dispositivo: comprobar la conversión real. Cerrar mide 56 × 56 y nunca comparte blanco táctil con otra acción.

### Celular 1 · Banda en dos pisos — recomendada

**Idea:** dar a la información su propio piso y a los dedos el suyo, sin hacerlos competir por ancho.

- Anclada abajo: y = 440–720. Encabezado de 56 px con nombre, tarjeta y cerrar. Cuerpo desde y local 72, con 550 px para métricas y 668 para efectos (separación 30). Para Estandarte: 270 para alcance y 948 para apoyo y reparación. Los efectos completos preceden a las acciones.
- Piso de acciones de 84 px, desde y local 182 hasta 266, con margen inferior de 12. Hielo usa hasta cuatro líneas de efectos: frenado, dos de combo y Voladores. Se reserva altura para que ninguna empuje los botones. No hay scroll ni «Al mejorar» duplicado: cada flecha está en su métrica o su frase.
- La venta presenta la devolución desde el primer estado; no obliga a tocar para descubrirla. Apoyo prescinde de Apuntar y no hereda cifras de ataque. Todos los ejemplos sanos comparten el alto para evitar saltos de las acciones al pasar de una torre a otra.

**Qué se esconde/mueve:** solo descripción e inversión histórica; efectos, combo y Voladores pasan de la Wiki a la banda. Se elimina la repetición «Nivel 1 de 3 ●○○». No se abre otro panel para decidir.

**Decisión conservada:** todo el contenido común de forma simultánea. Estandarte además informa que se aplica el mayor apoyo y la mayor reparación y que no se repara a sí mismo; mejorar no implica acumular bonificaciones.

**Costo de mapa explícito:** reservar 280 px, en vez de 96, reduce el espacio entre barra superior de 64 y banda inferior de 560 a **376 px**: 184 menos, un 33 % menos de altura disponible. Se propone recalcular el encuadre como parte del HUD; no afirmar «0 % de mapa tapado» sin esa reserva y su prueba. Con cámara sin reajuste, esa diferencia sí tapa mapa. Si Lucas prioriza conservar más altura, elegir Celular 2 y aceptar el despliegue.

**Enmiendas:** RF-512 (alto, contenido, nivel sin repetición y omisión de Apuntar), RF-617 (flechas completas en su lugar, sin renglón separado ni límite de dos estadísticas), RF-677 para extender claramente el criterio al celular, RF-681.1 por su referencia literal a «Al mejorar». Precisar RF-618: conservar tabla y cálculo, presentar todos los cambios sin el tope móvil de dos. D-193 debe dejar de exceptuar al celular; D-195 solo cambia la referencia al texto, conserva el flujo. RF-503 se cumple por la intención tipográfica, pendiente medición de sp. RF-550 no se reduce. D-194, D-196 y D-197 quedan iguales. Revisar RF-418 por el historial.

**Costo medio:** reemplazar la única etiqueta por contenedores de contenido y acciones; compartir el formateo y las frases con PC; recalcular reserva de cámara. **Pruebas:** U4 del mapa; los tests de PC no deberían cambiar por implementar solo esta opción. L1/L2 no cubren el HUD móvil: hacen falta casos nuevos, no declarar cobertura que no existe.

### Celular 2 · Barra con efectos desplegables

**Idea:** mantener una barra baja para operar y abrir efectos cuando importa la sinergia.

- Cerrada: y = 544–720, 176 px. Arriba nombre, nivel y métricas con cambios; botón «Ver efectos» de al menos 56 de alto. Abajo acciones con las mismas posiciones comunes y cerrar junto a Apuntar. En apoyo se muestran alcance, apoyo y reparación en el resumen: no esconder los cambios de su mejora.
- Abierta: crece hacia arriba hasta 350 px para Eléctrica y 376 para Hielo/Estandarte. Añade frases completas, Voladores, bonus y combo; las métricas no se duplican. Mantiene las acciones fijas abajo. Cambiar selección cierra los efectos y cancela cualquier mejora armada.
- En Eléctrica cerrada el cambio del rayo está dentro de «Ver efectos»: el usuario tiene que abrirlo para comprender toda la mejora. Para que no confirme sin verlo, el **primer toque de Mejorar abre también los efectos**, además de armar el alcance; el segundo sigue confirmando. Abrir «Ver efectos» por sí solo no arma ni compra. Esto exige diseño y tests propios; no está simulado en el HTML, donde solo funciona el despliegue nativo.

**Qué se esconde/mueve:** efectos, bonus, Voladores y combo pasan a un despliegue local en lugar de la Wiki. No se borran, pero exigen una interacción. Costo, devolución y motivo de bloqueo siempre visibles.

**Decisión conservada:** toda antes de confirmar, pero no toda desde la selección. La barra cerrada reserva 80 px más que la actual; deja 480 px de altura entre HUD superior e inferior. Es el compromiso con mejor conservación del mapa.

**Enmiendas:** RF-512, RF-617, RF-677 y D-193 para aprobar el resumen/despliegue y el nivel; RF-681 y D-195 para abrir efectos al armar sin agregar un tercer toque; RF-618 para no perder los cambios fuera del límite móvil actual; revisar RF-418. RF-550 se conserva. Sin cambio a D-194/D-196/D-197.

**Costo alto:** despliegue con cámara, foco, estado armado y cambio de selección coordinados. **Pruebas:** U4; nuevas pruebas de apertura automática, contenido completo antes de confirmar, cierre y cancelación. L1/L2 siguen siendo de PC y no cubren estos casos.

### Celular 3 · Inspector separado de las acciones

**Idea:** conservar un zócalo de acciones de 96 px y colocar una ficha de lectura independiente arriba, a la izquierda.

- La barra sigue en y = 624–720 con las acciones comunes. Una ficha de 600 × 252 aparece en x = 0, y = 360, dejando 12 px antes de la barra. Hielo/Estandarte usan ficha de 600 × 278 desde y = 334. La envolvente va desde esa ficha al borde inferior: 1280 × 360/386.
- Ficha con nombre, nivel, cerrar, métricas, efectos, combo y Voladores aplicables; no se esconde información de decisión. Apoyo mantiene alcance y su función. Acciones a los extremos, sin Vender pegado a Mejorar.
- La cámara conserva su reserva de 96 px, pero la ficha tapa parte del mapa: Eléctrica superpone **151.200 px²** de ficha al área de juego, aproximadamente 21 % del lienzo completo. No llamarlo «0 %» por conservar el zócalo. No se agrega auto-pausa ni arrastre: serían mecánicas nuevas.

**Qué se esconde/mueve:** se mueve la lectura fuera de la barra; únicamente descripción e inversión histórica quedan fuera. El mapa sigue visible en la zona superior derecha, pero el pulgar puede tapar la ficha según el agarre.

**Decisión conservada:** toda visible; información y acción quedan más separadas que en Celular 1. Elegir otra torre no reposiciona la ficha junto al dedo: se mantiene estable para evitar saltos de lectura.

**Enmiendas:** RF-512 para la separación entre ficha y barra, admitir superposición y omitir Apuntar en apoyo/pulso; RF-617/RF-618/RF-677, D-193 y referencia textual de RF-681/D-195 como en Celular 1; revisar RF-418. Mantener RF-550 y las reglas de alcance de D-194/D-196. D-197 no cambia.

**Costo alto:** dos superficies de HUD con áreas de input, orden de dibujo y pruebas de mapa/selección. **Pruebas:** U4 y nuevos tests móviles de ambos rectángulos, blancos táctiles y ausencia de clic al mapa detrás de controles. L1/L2 no prueban el celular.

## Estados e interacción que no se negocian

| Situación | Presentación y comportamiento en las seis propuestas |
|---|---|
| PC con oro | Un clic en Mejorar o U mejora; S vende como hoy. El hover de Mejorar conserva RF-680, aun con alcance sin cambio. Salir del hover retira la ampliación. |
| Ametralladora n1 sin oro | Daño 5 → 8; cadencia 2 → 2,5/s; alcance 3; Voladores: sí; precio 60; «Faltan 25 de oro» visible; venta +35. Botón apagado, sin armar ni mostrar alcance. Se habilita cuando llega el oro. |
| Nivel máximo | «Nivel máximo» deshabilitado y sin flechas en ninguna sección, incluso al desplegar. Mantener venta y apuntado aplicable. No eliminar efectos vigentes. |
| Primer toque móvil | «Confirmar → N2» conserva el precio y el mismo blanco táctil. No se cobra ni se sube. Se muestra el alcance según RF-680/681. La maqueta recomendada incluye este estado. |
| Segundo toque móvil | Cobra y mejora exactamente una vez, instantáneamente; bloqueo de 0,35 s y estado «¡Nivel N!» como hoy. Ningún rediseño introduce demora de juego. |
| Cancelación móvil | Mapa, soltar/cambiar torre, cambiar estado de barra, Vender, Apuntar, pausa o falta de oro cancelan el armado y retiran el alcance. En Celular 2, cerrar efectos también cancela para no confirmar información que se acaba de ocultar. |
| Venta móvil | Se mantiene la confirmación existente, su temporización y el reembolso de oro/recursos completo. Primer toque en Vender cancela la mejora armada. No reutilizar el botón de Mejorar para confirmar la venta ni acercar sus blancos. |
| Recursos | Mostrar en Vender el oro y los recursos que realmente devuelve la sesión, no inferirlos del nivel. Si el texto no entra, permitir otra línea/aumentar ancho manteniendo la distancia mínima; no truncar el reembolso. Los cinco ejemplos usan los importes pedidos por Lucas. |
| Opción de alcance y animación | Se conservan Oculto/Sutil/Completo, fantasma completo, ampliación y efecto cosmético, incluido Estandarte. No cambian guardados ni Opciones; RF-678/679/682–685 y D-194/196/197 no necesitan enmiendas funcionales. |

## Mapa concreto de pruebas afectadas

Estos identificadores abreviados se usan arriba para evitar repetir nombres muy largos. Es un análisis de impacto, **no una modificación ni una ejecución de tests**.

### `tests/test_upgrade_preview.gd`

- **U1 — `test_pc_panel_shows_the_preview_and_hides_it_at_max_level`:** dejar de buscar obligatoriamente un `Label UpgradePreview` aunque esté invisible. Verificar ausencia del bloque separado y presencia del cambio en la métrica/frase. Mantener valores, costo, nivel destino y ocultamiento de flechas al máximo. Si el botón pasa a «Mejorar a nivel 2 · 60 de oro [U]», actualizar su comparación literal. La tarjeta puede conservar su tooltip exacto aunque cambie de composición.
- **U2 — `test_panel_shows_each_upgrade_value_once_for_cannon_tesla_ice_and_disruptor`:** invertir la expectativa que prohíbe el prefijo de efecto en `%Stats`; exigir la frase con significado y cambio una sola vez allí. Dejar de exigir `change["texto"]` de animación en `preview.text`. Para Hielo, «durante 2 s» reemplaza la aserción literal «Duración del frenado: 2 s»; mismo criterio para quemadura de 3 s. Seguir verificando todos los campos y coma decimal. Incluir Estandarte y sus dos efectos, y ambos estados de PC 3.
- **U3 — `test_panel_at_level_three_has_no_arrows_and_no_decimal_point`:** mantener sus invariantes. Ajustar cómo recolecta el texto si cambian nodos; en PC 3 abrir detalles para cubrir también lo que no es visible al inicio. Conservar la comprobación de `TowerText.effects` para radio 1,5 y el literal «Nivel máximo».
- **U4 — `test_mobile_status_line_shows_the_preview`:** deja de alcanzar buscar «Al mejorar:» en una única etiqueta `StatusText`. Para Celular 1/3 comprobar métricas y frases en sus lugares, todos los cambios sin tope de dos, falta de punto decimal y ausencia de flechas al máximo. Para Celular 2 comprobar resumen, despliegue y apertura con el primer toque, sin cobro. Esta prueba sola no valida los dos toques.

**Se conservan sin cambiar su contrato** los tests puros `test_values_are_formatted_without_sign_and_with_comma`, `test_before_after_text_and_values`, `test_before_after_lists_the_same_stats_as_the_effect_in_the_same_order`, `test_scale_is_applied_to_both_sides`, `test_no_change_or_null_gives_nothing_and_the_cap_is_respected`, `test_preview_is_empty_at_the_last_level_and_for_bad_indexes` y `test_every_tower_shows_at_least_one_change_per_upgrade`. El límite configurable de la función pura no obliga a esconder cambios en el nuevo HUD. No tocar cálculo, orden de datos ni redondeo para adaptar las maquetas.

### `tests/test_tower_panel_layout.gd`

- **L1 — `test_description_is_removed_actions_fit_and_scroll_resets_on_selection`:** sustituir ancho literal 270 y límite de alto genérico por los presupuestos de la alternativa elegida. Conservar que no vuelve la descripción, las acciones caben, la venta admite foco y el estado sin oro es correcto. La cadencia más larga debe entrar con la misma fuente de 16 px que los otros valores, midiendo su ancho real en Godot. No exigir el tipo concreto `HBoxContainer` con tres `ColorRect` ni sus colores oscurecidos si cambia la tarjeta; probar tres posiciones bronce/plata/oro, llenado por nivel y contraste de pendientes. Si se elimina `Details: ScrollContainer`, reemplazar acceso/reset por ausencia de scroll necesario y contenido completo. PC 3 agrega apertura/cierre, reinicio al cambiar torre y recorrido de foco.
- **L2 — `test_panel_passes_map_clicks_through_passive_regions_but_keeps_buttons_interactive`:** conservar el contrato de input actual para superficies pasivas y botones, actualizando rutas y eliminando la aserción de un `ScrollContainer` inexistente. PC 3 agrega un control de despliegue que debe detener el clic; desplegar no debe seleccionar el mapa. Hay una tensión previa con RF-74, que dice que los clics del panel no llegan al mapa: antes de implementar, precisar si solo las regiones pasivas siguen atravesándolo, como exige este test actual; no cambiarlo por accidente como efecto del contenedor nuevo.

**Cobertura nueva necesaria al implementar:** los tres casos sanos más Ametralladora sin oro y Cañón n3; 13 casos actuales; estados simultáneos (aturdimiento/desgaste/apoyo/reparación), recursos devueltos y nombres largos; bordes y superposiciones a 1280 × 720 y 1920 × 1080. En móvil medir cada botón ≥ 56 px, Mejorar ≥ 84, separación real entre Mejorar y Vender, texto completo dentro de pantalla, decimales y nivel sin repetición; verificar armado/cancelaciones/confirmación y bloqueo sin doble cobro. PC: hover activo, salida, panel oculto y botones deshabilitados. Suite completa y captura real posterior, como RF-686; el HTML no sustituye eso.

## Recomendación final

**PC 1 + Celular 1** comparten el mismo orden mental y la misma redacción: qué torre es, qué hace, qué cambia y cuánto cuesta. La mejora deja de competir con tres bloques de acción y los efectos recuperan su significado. Hielo y Estandarte se entienden sin scroll ni una visita a la Wiki. El HTML incluye ambos junto a Eléctrica en estas opciones, y los casos límite PC de falta de oro y nivel máximo.

El costo que Lucas tiene que aceptar es concreto: PC pasa a 340 px de ancho; móvil reserva 280 px de alto. Si esa pérdida de mapa pesa más que la lectura completa, la segunda opción es **Celular 2**, con un paso adicional para explorar los efectos y apertura automática antes de confirmar. No recomiendo compensar ese costo achicando letras ni recortando valores: reproduciría el problema actual.

Antes de programar: elegir la estructura, aprobar sus enmiendas y renderizar estas medidas con la fuente del juego. Esta entrega no toca el tablero ni la spec, no crea un commit y no incorpora código de juego.

**Chequeo estático de la entrega:** HTML con etiquetas balanceadas, idioma `es-AR`, once secciones de comparación y casos adicionales, seis alternativas principales, sin scripts ni recursos externos, paleta indicada y ejemplos de coma decimal presentes. No equivale a una revisión visual renderizada.
