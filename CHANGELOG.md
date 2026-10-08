# Novedades del juego

Lo que cambió para quien juega, de lo más nuevo a lo más viejo. El detalle técnico está en `specs/03-tareas.md` y las razones, en `specs/04-decisiones.md`.

## Editor: removibles, minas, demoledora y torres del mapa *(T212, 2026-10-08)*

- El **editor de mapas** suma cinco pinceles: **Árbol**, **Roca**, **Escombro**, **Mina** y **Bosque** (teclas `6` a `0`). Se pintan como el pasto o el camino y el editor arma solo la leyenda del archivo. Si la leyenda ya tiene sus 10 letras, avisa abajo en lugar de pintar.
- Un botón nuevo, **Objetos**, deja cambiar el costo, el tiempo, los recursos y la probabilidad de un removible (o la producción y la reserva de una mina) para todas las casillas de ese tipo, viendo siempre el valor de la clase.
- **Ajustes** suma *Demoledora disponible* y *Torres del mapa* (casillas para elegir cuáles ofrece el nivel; "Usar las de siempre" las deja como antes). **Probar** funciona con todo esto.
- La **pieza de colección** de una ruina solo se puede elegir al editar un nivel de la campaña; en los mapas de la comunidad y de los modos el campo está deshabilitado y explica por qué (si el archivo ya tenía una, se conserva).

## Niveles 6 y 7 en el bosque *(T223, 2026-10-08)*

- **Nido («El lindero»)** y **Cruce («El aserradero»)** pasan al **bosque**, con árboles y rocas que se pueden **demoler** pagando oro y esperando (un clic sobre el objeto). Despejarlos libera casillas buenas entre las rectas del camino. En el Nido son 3 y **no dan recursos**; se gana sin demoler.
- En el Cruce hay 6 removibles, la **demoledora** se puede comprar desde el botón *Infraestructura* y cada removible **puede entregar 1 recurso** (50 % de probabilidad). Con un recurso, el Francotirador cuesta 120 de oro en vez de 150; nunca es obligatorio. Se suman señales nuevas (un poste con cintas y una roca con una marca tallada).
- El camino y las oleadas no cambian.

## Demoledora global *(T208, 2026-10-08)*

- En los niveles que la habilitan, el botón **Infraestructura** permite comprar una demoledora por 180 de oro, una sola vez. Cada demolición posterior cuesta el 10 % del precio original (mínimo 5) y tarda el 80 % del tiempo; el panel de cada objeto muestra el ahorro antes de comprarla. Las demoliciones ya iniciadas conservan su costo y duración, y al reiniciar se pierde la compra.
## Minas y bosques que se pueden explotar *(T210, 2026-10-08)*

- Un clic en una **mina** o un **bosque explotable** abre su panel: *"Habilitar extracción (100 de oro)"*, *"Produce 2 recursos por oleada"* y *"Reserva 8/8"*. Habilitar cobra el oro al instante; no se cancela ni se devuelve. Se pueden habilitar todos los puntos que alcance el oro.
- Un punto activo entrega sus recursos **cada vez que se completa una oleada** (también la que estaba en curso al habilitarlo) y aparece un "+2 recursos" sobre él. **No produce por esperar** ni cuando el modo de pruebas salta de oleada. Una mina con la reserva de 8 entrega 2, 2, 2 y 2, y queda **agotada**.
- En el mapa se ve el estado (velo gris y marco ámbar sin habilitar, marco verde activa, velo oscuro agotada) y la reserva como **segmentos que se vacían**. El dibujo es provisional: el arte final llega más adelante.

## Recursos y torres que cuestan recursos *(T209, 2026-10-08)*

- En un mapa que tenga **recursos** (removibles que pueden entregarlos o minas), la barra de arriba muestra un **contador de recursos** con un ícono provisional. Los recursos son solo de esa partida: empiezan en 0, no se guardan y los que sobran se pierden. Al terminar una demolición, el recurso (si salió) entra una sola vez.
- El **Mortero** ahora cuesta **300 de oro + 3 recursos**: la barra muestra "300 + 3" y lo deshabilita diciendo qué falta. Al venderlo se devuelve el 70 % del oro y de los recursos, redondeado hacia abajo (210 y 2). Mejorarlo sigue costando solo oro. Los niveles 1 a 8 no lo ofrecen, así que no cambian.
- El **Francotirador** se puede comprar de dos formas en la misma partida: **150 de oro** (como siempre) o **120 de oro + 1 recurso**. Al elegirlo aparecen dos botones chicos de pago (arranca "solo oro"); el segundo se apaga si faltan recursos o el mapa no tiene. Con 1 recurso, la venta no devuelve ninguno.
- El panel de la torre y la Wiki muestran los costos en recursos. El validador (`check_level`) avisa si un mapa ofrece una torre que cuesta recursos y no tiene cómo conseguirlos.
## Colecciones por tecnología y piezas en ruinas *(T211, 2026-10-08)*

- Ahora hay **dos colecciones**: los avances tecnológicos de siempre (niveles 1 a 5, sin cambios) y una nueva, la de la **Disruptora**, con 3 piezas que se encuentran en **ruinas** (escombros con hallazgo) de los niveles 8, 9 y 10. Los niveles actuales todavía no tienen ruinas con hallazgo: la colección empieza vacía y se llena cuando lleguen esos mapas.
- Al terminar de demoler una ruina, la pieza queda **pendiente**; se **confirma** al completar la oleada en curso (o la siguiente, si demoliste antes de empezar). Una derrota antes de confirmar, abandonar o reintentar la pierde; una pieza confirmada se guarda aunque después pierdas. El panel de la ruina dice **"pendiente"** o **"ya recuperada"** antes de demoler.
- Las piezas **solo se consiguen en la campaña**: en los modos, la comunidad, el editor y el modo de pruebas la ruina se puede demoler, pero el panel avisa "Aquí no se recogen piezas" y no se guarda nada.
- La barra superior muestra la colección del nivel que jugás, y la Wiki tiene una solapa nueva, **Colecciones**, con el progreso de cada una y qué torre desbloquea. Los guardados viejos cargan igual.

## Demolición directa de obstáculos *(T207, 2026-10-08)*

- En un mapa que tenga **removibles** (árboles, rocas o escombros marcados con una estaca ámbar), un clic abre un panel con el costo, el tiempo y la recompensa. **Demoler** cobra el oro y empieza un trabajo que avanza con el reloj de la partida (se frena en pausa y va más rápido a ×2). Se puede **cancelar** y se devuelve todo el oro. Al terminar la casilla queda libre para construir.
- Una sola demolición a la vez. Los 9 niveles actuales no tienen removibles: no cambian. Los recursos y las piezas todavía no se entregan (llegan en tareas siguientes).

## Torres por mapa y aviso en la selección *(T203, 2026-10-08)*

- Un nivel puede decir qué torres ofrece (`"torres"` en su archivo): la barra muestra solo esas. Sin el campo, todo sigue igual; los 9 niveles actuales no cambian.
- Las tarjetas de la campaña muestran las torres de cada nivel y marcan con un punto naranja (y "Nueva" al pasar el mouse) la que debuta ahí. La Wiki sigue mostrando todas.
## Señales y oasis en los niveles 1 a 5 *(T222, 2026-10-08)*

- Los cinco primeros mapas suman unas rocas talladas, charcos de agua y flores donde antes había casillas bloqueadas. Es solo decoración: el camino, dónde se puede construir, las oleadas, el oro y las vidas son los mismos de siempre.

## Android normal y pruebas *(M34, 2026-10-02)*

- Dos APK con los últimos diseños e interfaces del PR#1, con paquetes separados para instalarlas juntas. La variante de pruebas conserva su panel de administración; la normal no lo habilita.
- Android7 o superior, arm64; firmadas para instalación local. Instalación y partida en dispositivo todavía no verificadas.

## Submenús coherentes *(M33, 2026-10-02)*

- Opciones separa sonido y visualización, con deslizadores y casillas de hierro/bronce.
- Selección de niveles y mapas de la comunidad, Wiki, récords, pantalla final, iniciales/Salón de la Fama y editor/diálogos adoptan el estilo del menú. Se conservan controles, guardados y navegación.
- Backlog B-19 completado; B-17/B-18 también señalados como terminados.

## HUD compacto y monitor local *(M32, 2026-10-02)*

- Barra superior con iconos y cifras; ayudas al pasar el puntero y al enfocar con teclado. Oleada completada con marca y detalle del bonus en su ayuda.
- Barra, menú de pausa y controles de pruebas adoptan hierro/bronce; el panel agrupa recursos, partida y simulación.
- Mostrar FPS deja un monitor sin fondo sobre la partida, visible al cerrar Pruebas. Incluye ms/cuadro estimados y refresca dos veces por segundo; solo información local.

## Ciclos completos de monstruos *(M31, 2026-10-02)*

- Blindado, Troll, Araña, Cría, Guardián, Curandero, Chamán, Espejo y Jefe ahora caminan con cuatro poses en cuatro direcciones: 144 poses nuevas. Con los ciclos anteriores, los trece enemigos tienen movimiento propio.
- Los pasos acompañan la distancia y la ralentización, se congelan al pausar y conservan tamaño y apoyo. Habilidades, balance y sombras permanecen intactos.

## Reflejos de mejoras *(M30, 2026-10-02)*

- Las nueve torres ahora suman reflejos programáticos sobre metal/cristal: nivel1 conserva su acabado, nivel2 destaca las piezas claras y nivel3 intensifica el brillo. Bronce para armas metálicas, azul para Hielo/Múltiple, violeta para Eléctrica y naranja para Incendiaria.
- El reflejo acompaña las ocho vistas, el retroceso y el encastre; pausa congela el pulso y el aturdimiento lo apaga. Las sombras quedan intactas.
- Pendientes de ciclos propios: Blindado, Troll, Araña, Cría, Guardián, Curandero, Chamán, Espejo y Jefe. Solo Normal/Rápido/Tanque caminan y Volador aletea; los otros nueve usan pose fija.

## Monstruos más legibles, montaje C y escritorio Full HD *(M29, 2026-10-02)*

- Los trece enemigos usan sus diseños renderizados: se suman Volador, Blindado, Troll, Araña y Cría que seguían con SVG. En partida el cuerpo crece un20% sin cambiar vida, alcance, selección, colisión ni habilidades.
- Diablillo, Bestia y Tanque caminan con cuatro poses en cuatro direcciones, sincronizadas con la distancia recorrida. El volador aletea con cuatro poses. Al ralentizar se frenan los pasos y al pausar se detiene la animación. Los otros nueve tienen pose fija, sin aplastamiento global; sus ciclos propios quedan para otra tanda.
- Las nueve torres encastran sobre bases reforzadas siguiendo el montaje C. El Cañón recibe24 vistas nuevas (ocho por nivel), conservando bronce, hierro y madera. La base queda quieta al apuntar; mecanismo, retroceso y boca de disparo comparten el nuevo asiento. HUD y Wiki usan iconos coherentes con el encastre.
- Windows/Linux apuntan a1920×1080 con ajuste al área útil en pantallas menores. En pantalla completa se usa la resolución del monitor. El mapa conserva su lienzo lógico1280×720 y se escala junto con la interfaz; celular conserva su presentación.
- Fuentes, prompts y capturas reales en `art/redesign-m29/`. Linux y celular no se ejecutaron en esta tanda; la revisión visual y el ejecutable corresponden a Windows. Descripción del PR a cargo de Lucas.

## Monsters & Canons: logo, menú y primeros monstruos *(M24, 2026-10-02)*

- El menú principal muestra el logo **Monsters & Canons** y sus botones tienen un acabado de hierro oscuro con borde de bronce, relieve discreto y resplandor ámbar al pasar el mouse o con el teclado.
- **Normal** (diablillo rojo), **Rápido** (bestia turquesa) y **Tanque** (ogro de piedra) tienen arte nuevo en la partida, la Wiki, "Próxima oleada" y el aviso de enemigo nuevo. Vida, velocidad, recompensa, tamaño y habilidades son los mismos.
- Por ahora son imágenes fijas: miran siempre hacia el mismo lado y se mueven solo con el bamboleo de caminar (para que la luz no cambie de lado). Las evoluciones de las torres todavía no se integraron: falta arte de ocho vistas.

## Torres con volumen y tres familias visuales *(M23, 2026-10-02)*

- Cañón y mortero de hierro, bronce y madera; cinco torretas industriales; hielo y electricidad con cristal y metal claro.
- Nueve torres con ocho vistas para apuntar, tres bases según el nivel y nueve proyectiles nuevos. La luz se mantiene fija al cambiar de dirección.
- Llama renderizada, fragmentos de hielo, explosión y chispas violetas. Los efectos desaparecen al terminar y mantienen los anillos que indican el área.
- HUD y Wiki usan el nuevo arte. Los cuatro emblemas del HUD ya aceptados quedan incluidos en el repositorio.
- Conserva reglas y balance. 859 tests en verde y ejecutable Windows de pruebas verificado al arrancar. Enemigos, suelo y decoración quedan para su siguiente revisión artística.

## Modo de pruebas: oleadas finales, velocidades y atajos *(M22)*
- **Empezar en la oleada N:** en la selección de nivel del ejecutable de pruebas, una franja **"Pruebas"** deja elegir la **oleada inicial** y el **oro inicial** (automático, que es lo que se habría juntado, o a mano). Esa partida empieza sin torres y **no guarda** progreso ni récords.
- **Cinco velocidades:** x0,25 · x0,5 · x1 · x2 · x4, que se ven en el cartel "MODO PRUEBAS" y vuelven a x1 al salir. Sirve para mirar con calma el aviso de combo.
- **Atajos:** `F2` matar a todos, `F3` saltar oleada, `F4` vidas infinitas, `F6` y `F7` velocidad más lenta y más rápida (no chocan con las teclas del juego).
- **Informe:** al terminar o salir de una partida de pruebas, escribe `user://pruebas_stats.json` con la oleada, vidas, oro y torres de cada oleada (los mismos datos que el bot de balance).

## Sinergias: combinar ataques *(M20)*
- Un enemigo **ralentizado** por el Hielo recibe **+25 %** de daño del **Cañón**, el **Francotirador** y el **Mortero**; uno **quemado** por la Incendiaria recibe **+30 %** de la **Eléctrica**.
- **El combo se nota:** el número de daño del golpe sale **más grande y con "!"**, **celeste** si fue por el hielo y **naranja** si fue por el fuego, con un anillo del mismo color y un **"tin"** propio. El primer combo de cada tipo en la partida dice **"¡Combo de hielo!"** o **"¡Combo de fuego!"**. Ya no se amontona con los otros números ni se confunde con el oro, y no desaparece aunque apagues los números de daño.
- **El combo se descubre:** el **Hielo** y la **Incendiaria** dicen en su panel y en la Wiki con qué torres combinan; la barra de construcción lo nombra; y un enemigo que está listo para un combo muestra una **dianita** al lado de su barra de vida.
- Es la primera mitad; después vendrán los pares de torres vecinas.

## Torres grandes: el Mortero *(M19)*
- Primera torre de **2×2 casillas**: el **Mortero** (tecla **9**), una bomba lenta de gran daño en área y largo alcance, pensada contra blindados y jefes. Se construye en un cuadrado de cuatro casillas libres; la vista previa se centra en el mouse y se pinta verde o roja.
- Por ahora el Mortero es una torre **reservada**: solo aparece en los niveles que la habilitan (el 10, cuando exista); los demás siguen con las 8 de siempre.

## Torres apagadas: Chamán y Espejo *(M18)*
- El **Chamán** apaga la torre más cercana unos segundos con un rayo magenta; el **Espejo** devuelve los tiros de las torres cercanas y las aturde.
- Las **torres aturdidas** se ven apagadas y su panel dice cuánto falta. Todavía no aparecen en los niveles (debutan en el 10).

## Enemigos con aura: Guardián y Curandero *(M17)*
- El **Guardián** da armadura a los enemigos que lo rodean; el **Curandero** los cura. Los dos muestran un **anillo** en el suelo y ponen un escudo o una cruz sobre los que ayudan.
- Todavía no aparecen en los niveles (debutan en el 8 y el 9); se pueden ver en la Wiki y en la versión de pruebas.

## Paisajes de mapa *(M15)*
- Un nivel puede tener su **tema**: pradera, desierto, nieve, volcán, bosque, pantano o ruinas.
- Los mapas pueden pedir **lagos, hielo, lava, barro, flores y decoración** con una leyenda.
- **16 dibujos nuevos** para el mapa.

## Los enemigos, redibujados
- Los nueve enemigos tienen un dibujo nuevo, con más volumen y una silueta propia (T127).

## El editor de mapas, para todos *(M14)*
- El botón "Editor de mapas" está en el juego normal (no en el celular).

## Mapas más grandes *(M13)*
- Un mapa puede medir hasta **26×12** casillas; el juego lo achica solo para que entre.

## Wiki y bestiario *(M11, M12)*
- Nueva pantalla **Wiki** en el menú: enemigos, torres y una guía de reglas.
- Los enemigos aparecen como **"???"** hasta que los ves por primera vez en una partida.

## Mapas de la comunidad *(M10)*
- Cualquier mapa que pongas en la carpeta de mapas aparece en **Jugar → Mapas de la comunidad**, con su propio récord.

## Editor de mapas *(M9)*
- Se crean, prueban y guardan niveles con el mouse (por ahora, solo en la versión de pruebas).
- La selección de nivel acepta cualquier cantidad de niveles.

## Nivel 7 y Linux *(M8)*
- **Nivel 7 "Cruce"**, y una versión del juego para **Linux**.

## Niveles en archivos de texto *(M7)*
- Los niveles son archivos que se pueden leer y cambiar sin programar.

## Récords y modo de pruebas *(M6)*
- **Puntos**, top 5 por nivel con tres letras y **Salón de la fama** para quien gana todos los niveles.
- Un ejecutable de pruebas para probar el juego sin ensuciar el progreso.

## Contenido nuevo *(M5)*
- **4 torres nuevas** (Incendiaria, Múltiple, Ráfaga, Eléctrica) y **la Araña y el Troll** como enemigos con habilidades.
- Nivel 6 "Nido".

## Pulido *(M4)*
- Dibujos para todo, **estrellas** por nivel, avisos de enemigos peligrosos, **números de daño** y niveles 4 y 5.

## Android *(hito MA)*
- Una versión para **celular** (APK), con controles táctiles.

## Los primeros niveles *(M1 a M3)*
- El juego base: **3 niveles**, 4 torres, menú, opciones, pausa, sonido y guardado del progreso.

## Fondos M26
Los siete temas, el camino y las rocas, árbol, arbusto y puerta usan los nuevos PNG renderizados. Se aplican en partida, menú y editor; rutas y casillas construibles conservan sus reglas. Recursos en `assets/tiles/rendered/` y `assets/sprites/map/rendered/`.

### Arte M27 en revisión
Propuestas de niveles2/3 de las nueve torres (ocho vistas por nivel) y cinco monstruos especiales en `art/redesign-m27/`. Incluye atlas, iconos, muestras en Godot, fuentes y guía de integración; todavía no cambia los recursos que usa la partida.

### M27 aplicado a la partida
Las nueve torres usan mecanismos nuevos en niveles 2 y 3. Guardián, Curandero, Chamán, Espejo y Jefe usan sus PNG renderizados estáticos. Se conservan balance, habilidades y nivel 1 de las torres. Capturas en `art/m27-integracion/`.

## Muestras de legibilidad y presentación *(M28, pendientes de aprobación)*

Comparaciones del arte pendiente de Volador, Blindado, Troll, Araña y Cría; cuerpos+20%/+35%; ciclos de caminar y aleteo exploratorio; presentación1920×1080 para escritorio; ajustes de contacto entre torreta/base y dos conceptos integrados de Cañón. Fuentes, GIF y capturas en `art/redesign-m28/`. Estas propuestas **todavía no cambian la partida**, su resolución, balance ni colisiones. La descripción del PR queda a cargo de Lucas.

### M35 · Panel de torre
- Panel de información y mejoras con estilo hierro/bronce, métricas agrupadas y detalle desplazable. Los botones quedan visibles incluso con textos largos; aturdimiento y foco de teclado se distinguen.

### M36 · Mejoras B-20 a B-27
- Marcas de nivel integradas en la base; rebote, aturdimiento, recuperación y curación más legibles.
- Muertes conservan brevemente la pose del monstruo y se desintegran sin demorar recompensa ni crías.
- Música propia de menú/combate, efectos suaves y avisos protegidos de los disparos; limitador de mezcla.
- Estudios de profundidad, contenido/desbloqueos y combos vecinales entregados; esas mecánicas no se activaron en el juego.

### Backlog depurado · T182 (2026-10-03)
B-02 cerrado; B-15 retirado/dividido. Lore y documentación de Épocas en B-03; Wiki de mods y comunidad en B-29/B-30. B-21/22/23 siguen abiertos con estudios preliminares. Sin cambios en el juego.

### M37 · Avances y Estandarte mecánico
Colección de cinco piezas tecnológicas, una por cada nivel1–5, y apoyo de cadencia disponible desde6 con colección completa y permiso del nivel. Habilitación manual en pruebas. Próximas etapas: robo periódico, embestida/desgaste y reparación; campaña base objetivo15 niveles, todavía no construida.

### M38 · Avances en el HUD
La colección ahora aparece en la barra superior como icono y cantidad/objetivo; pendiente/confirmado se explica en la ayuda.

### M39 · Ladrón
Encuentros opcionales en6/7: roba3 de oro cada2s, piso10, hasta morir o escapar. Pausa/velocidad respetadas. Pruebas permite invocarlo sin progresión; Wiki explica la habilidad. Arte y balance iniciales revisables.

### M40 · Embestidor y desgaste
Ensayos6/7. Carga al final de rectas; solo alcanza una torre próxima a ese extremo. Desgaste20% por impacto, tope50%, reduce cadencia y apoyo sin destruir. Hielo fuerte interrumpe carga; mejora conserva desgaste. Panel y marcas distinguen daño y aturdimiento. Reparación continúa en M41.

### M41 · Mecánico reparador
El Mecánico recupera2/3/4 puntos de desgaste por segundo dentro de su radio; solo el más fuerte y sin autorreparación. No cura aturdimiento. Daño reduce sus prestaciones; otra estatua puede repararlo. Colección5 avances+permiso del nivel y habilitación de Pruebas se conservan. Ensayos6/7;1–5 conservan datos de oleadas y balance.

Verificación M41: 943 pruebas GUT verdes; 103 FPS con 200 enemigos/60 torres y desgaste activo. Exportaciones Windows normal/pruebas y Linux; arranque Windows código 0. Capturas y 12 simulaciones en art/mechanics-m41. Balance inicial: compra temprana del Mecánico perjudica al bot en nivel 6; en nivel 7 ambas variantes ganan. Ajuste fino y arte final pendientes.

### M42 · Selección de enemigos en Pruebas
Rueda sobre el selector: anterior/siguiente, sin abrir ni invocar. Clic mantiene la lista completa, ahora con altura limitada y scroll, fondo opaco y sin sombra recortada. B-31 registra rediseños pendientes de Mecánico, Embestidor, Ladrón y Curandero; se evaluará reutilizar la silueta del Curandero como base del Embestidor.

### M43 · Rediseños B31 integrados
Embestidor acorazado con frente de impacto; Curandero erguido con semilla medicinal; Ladrón encapuchado con bolsa; Mecánico renderizado en hierro/bronce sobre bases existentes. Los tres enemigos tienen ciclos 4×4, por distancia. No cambia balance. Vista animada y capturas: `art/redesign-m43/preview.html`; prompts/fuentes allí. Pruebas: habilitar estandartes, invocar los enemigos y observar giros/carga/pausa; revisar Wiki. Aprobado visualmente por Lucas el 2026-10-04.

### T190 · Entrega visual aprobada
B31 cerrado por aprobación de Lucas (2026-10-04). Exportados `build/JuegoA.exe`, `build/JuegoA_pruebas.exe`, `build/JuegoA.apk` y `build/JuegoA_pruebas.apk`. Windows release: ambos arrancan con código0, solo pruebas activa DevMode. APK debug arm64, Android7+, paquetes normal/pruebas separados, misma firma anterior verificada v2/v3 y recursos M43 presentes. SHA256 y registros en `build/t190/manifest.json`; no se ejecutaron en celular físico. Siguiente: balance/estrategias6/7, luego diseñar8/9.

### T191 · Reparación y estudio6/7

- La reparación termina correctamente aunque quede un residuo mínimo de desgaste; el indicador se apaga.
- Laboratorio de compra/ubicación/mejoras del Mecánico y frecuencia de Ladrón/Embestidor sobre6/7; resultados y límites en art/balance-m44.
- EXE y APK normales/de pruebas regenerados con la corrección. No cambia balance1–5.

### T192 · Bastión y Taller asediado

- Campaña con9 niveles: Guardián en8, Curandero en9, más encuentros de robo/desgaste y apoyo Mecánico disponible.
- Un guardado que completó el antiguo último nivel permite acceder al siguiente agregado sin repetirlo.
- Niveles1–7 y estadísticas globales conservados. EXE/APK sin regenerar; primera versión de balance con validación humana pendiente.

### T196 · Modo de pruebas en Opciones y licencia libre

- El modo de pruebas ahora está en **Opciones → Activar modo de pruebas**, con confirmación, y se apaga con **Volver al juego normal**. Usa su propio guardado: no toca tu progreso ni tus récords. El juego siempre arranca en modo normal.
- Un solo ejecutable o APK por plataforma: ya no hay una versión "de pruebas" aparte.
- El juego es software libre, bajo la GPL versión 3 o posterior. Detalles en la Wiki: Guía → Licencias.

### T197 · Modos de juego

- Nueva solapa **Asedio** en Jugar: los nueve mapas de la campaña con monstruos más duros. Cada mapa se abre al ganar el anterior y tiene sus propias estrellas y récords, sin tocar la campaña.
- Podés armar tus propios modos: en el editor de mapas, **"En un modo…"** crea un modo (o elige uno) y guarda el mapa adentro. Cada modo aparece como una solapa más en Jugar.
