# Novedades del juego

## Mapa planetario como inicio *(T470, 2026-10-24)*

La campaña abre en el mapa planetario tanto en PC como en celular. En el mapa, un clic o toque selecciona el nivel; **Jugar** o **Enter** lo inicia, y el doble clic no lo saltea. El pie con la selección y el botón queda fijo mientras desplazás el mapa si no entra entero. Las tarjetas siguen iniciando con un clic. Los guardados existentes pasan al mapa una vez, al guardar; después se respeta el estilo que elijas. No se probaron teléfonos reales.

## «Ver todo»: tecla en PC y aviso de cámara *(T464, 2026-10-24)*

En PC, «Ver todo» queda solo en la tecla configurable (V por omisión), sin botón flotante. En celular, el botón sigue apareciendo al acercar el mapa; desplazarlo sin zoom no lo muestra. La primera vez que acercás el mapa aparece por tres segundos un aviso con la tecla o el botón para volver al encuadre completo; desplazarlo sin zoom no muestra el aviso (aclaración de Lucas, 2026-10-23). Se recuerda en el guardado y no interrumpe el tutorial. La lupa está en muestra para aprobación y todavía no se integró: hasta entonces el botón conserva el texto «Ver todo».

Lo que cambió para quien juega, de lo más nuevo a lo más viejo. El detalle técnico está en `specs/03-tareas.md` y las razones, en `specs/04-decisiones.md`.

## Editor de banderines para el nivel 6 *(T443, 2026-10-23)*

Desde **Herramientas → Editor de banderines** se puede elegir una de cuatro paletas y cuatro emblemas. La vista grande y la de 34 px se actualizan al editar; «Aplicar» guarda el diseño por separado del progreso, y «Cancelar» o Escape descartan los cambios. «Restaurar» selecciona el diseño inicial, que se guarda solo al aplicar. El poste del jugador en el nivel 6 usa la elección al volver a entrar después de ganar; el banderín enemigo y los otros modos siguen con sus recursos fijos.

## Herramientas para los editores *(T441, 2026-10-22)*

El acceso «Editor de mapas» del menú ahora se llama **Herramientas**. Ahí podés abrir el editor de mapas y el editor de banderines. Al salir del editor de mapas volvés al hub, y «Probar» sigue regresando al borrador.

## Banderines de conquista y decoración del bosque *(T437, 2026-10-21)*

Se rehacen el tronco y el helecho con el acabado dimensional de la decoración actual. En el nivel 6, el poste muestra banderines enemigos hasta que el nivel tenga una victoria guardada; al volver a entrar después de ganarlo, muestra los del jugador. No depende de las estrellas y no cambia el progreso. T443 agrega el catálogo de paletas y emblemas al banderín del jugador.
## La entrada al nivel en PC, con el paisaje del nivel *(T429, 2026-10-21)*

En PC, el cartel que aparece al entrar a un nivel ya no tiene el botón «Empezar»: dice **«Hacé clic en cualquier lugar, o apretá cualquier tecla, para empezar.»** y sigue arrancando una sola vez, sin tocar la pausa ni la cuenta atrás. Detrás del texto se ve, tenue, el suelo del paisaje de ese nivel (pradera, desierto, nieve, etc.). El celular no cambia: conserva el botón y su texto.

## Mapa planetario como segunda vista de la campaña en PC *(T428, 2026-10-21)*

En PC, abajo del selector de campaña hay un interruptor **Vista: Tarjetas / Mapa**. El mapa dibuja Cántaro con el aterrizaje y las 15 zonas, con el estilo de la muestra que aprobó Lucas. Cada zona muestra su estado: **bloqueada** (candado), **disponible**, **presencia rebelde** (bandera, victoria con 1 o 2 estrellas) y **zona tomada** (tilde, 3 estrellas); no dependen solo del color. Se recorre con el mouse o con las flechas, y Enter o «Jugar» abren el nivel; una zona bloqueada se puede mirar pero no abrir. Lo elegido se recuerda en Opciones del guardado; los guardados viejos abren con tarjetas. Cambiar de vista no toca el progreso, los desbloqueos ni las estrellas, y el celular no cambia.

## Quince niveles a la vista en desktop *(T426, 2026-10-21)*

El selector de campaña ahora muestra los **15 niveles en tres filas**, sin desplazamiento, en PC. Se quitó el conteo de oleadas y las torres disponibles aparecen integradas en la tarjeta, sin cajas individuales. Los nombres, estados, desbloqueos, récords, estrellas y teclas se conservan; mobile mantiene su presentación anterior. Cada tarjeta de PC tiene un fondo temático muy tenue: el suelo del paisaje real de ese nivel (pradera, desierto, nieve, etc.), con un velo oscuro encima para que el nombre, las estrellas y las torres se sigan leyendo; es el mismo lenguaje que la entrada al nivel. Las tarjetas de mobile, de la comunidad y de los modos no cambian.

## Consejo en la derrota
- Podés apagar «Consejos en la derrota» desde Opciones, tanto en el menú principal como durante una partida. Se guarda la preferencia y, por omisión, los consejos siguen prendidos.

## Panel de torres más despejado en PC
- El panel muestra el daño actual junto al que dará la mejora y dice a qué nivel sube. La card de tres colores identifica el nivel actual; se sacó la descripción repetida.
- El fondo es más transparente y las áreas sin botones dejan pasar clics al mapa. Si una torre queda debajo de un botón, podés ocultar el panel con «×», elegirla y el panel vuelve a aparecer.

## Pausa que bloquea el carrito, «Ver todo» con tecla y «Mejorar» con antes → después *(T401 a T404, 2026-10-20)*

- **Celular: en pausa no se construye.** Con la partida en pausa (el botón, el menú de pausa, el cartel de entrada o la app en segundo plano) el **carrito** y el botón de **demolición** se ven apagados y no hacen nada; si el catálogo estaba abierto, se cierra. La barra de abajo dice «En pausa: seguí la partida para construir». Al seguir, todo vuelve. Mejorar y vender no cambian.
- **PC: «Ver todo» con tecla.** Apretá **V** para volver a ver todo el mapa (también con la partida en pausa). El botón «Ver todo» ahora aparece también cuando acercaste con la rueda, no solo cuando corriste el mapa. Podés cambiar la tecla en **Opciones → «Tecla de «Ver todo»»** (tocás el botón y apretás la tecla que quieras; **Esc** cancela y **Restaurar** vuelve a la V). Si la tecla ya la usa otra cosa (las torres, la pausa, Tab, Espacio…), el juego avisa y no la cambia. Se guarda con tus preferencias; un guardado viejo sigue sirviendo.
- **«Mejorar» te muestra qué comprás.** En la PC, el panel de la torre elegida dice, encima del botón, **«Al nivel 2: daño 5 → 8 · alcance 3 → 3,5»**; en el celular, la barra de abajo trae un renglón **«Al mejorar: …»**. En el nivel máximo no aparece. Son las mismas estadísticas que muestra la animación al mejorar.
- **Documentos:** se sacó de la spec la franja de borde de 56 px de los botones flotantes (no se usaba) y el README cuenta **11 torres**.
- **Qué no se probó:** nada de esto se miró en un celular real ni con un teclado distinto del de desarrollo.

## Arte de «Novedades de esta versión» *(T375, 2026-10-20)*

La presentación de la 1.0.0 tiene ahora una cabecera del campamento y siete medallones de hierro y bronce, con el arte aprobado por Lucas. La imagen se ve completa y los textos quedan debajo, sobre el panel oscuro. Los íconos miden 48 px en PC y 64 px en celular; las novedades sin imagen siguen usando el rombo de bronce. La lista se desplaza y «Entendido» queda a la vista. Los textos siguen en **borrador**, disponibles desde Opciones; este cambio no publica la 1.0.0.

## La intro pesa mucho menos *(T390, 2026-10-20)*

Las siete láminas de la intro se guardan ahora como WebP con una compresión leve (calidad 0,90): **ocupan unos 4 MiB en vez de casi 18** dentro del juego, y en pantalla se ven igual (no se notan diferencias a simple vista). El juego queda más liviano de instalar y de abrir en el celular.

## Pantalla de carga y toques bloqueados al cambiar de pantalla *(T340, 2026-10-19)*

Al elegir un nivel, volver al menú, reintentar o pasar al siguiente nivel, el juego muestra ahora una **pantalla de carga** («Cargando…» con una barra que se mueve) y **no hace caso a nada** (toques, clics, teclas ni el botón «atrás») hasta que la pantalla nueva está lista. Antes, si tocabas de más mientras el nivel cargaba en el celular, se podía lanzar **otro nivel** (el que quedaba debajo del dedo en la selección). Ahora entra solo el que elegiste. La pantalla de carga se ve como mínimo 0,4 segundos, así que en equipos rápidos es un destello corto y no un parpadeo.
## Animación al mejorar una torre *(T363, 2026-10-19)*

Al mejorar una torre sale ahora un **efecto breve sobre ella**, distinto según el nivel: un anillo de luz con chispas al **nivel 2** (medio segundo) y uno más grande, con doble anillo, destello en cruz y chispas en abanico, al **nivel máximo** (0,7 s). Se tiñe con el color de la torre. Junto con el efecto sube un **texto con lo que sumó la mejora**, leído de los datos reales de la torre y solo lo que cambió: por ejemplo, la Ametralladora al nivel 2 dice «¡Nivel 2!» y «+3 daño · +0,5 disp/s»; la Tesla al máximo, «¡Nivel máximo!», «+8 daño · +0,1 disp/s» y «+1 saltos · +0,5 alcance».

El texto no tapa la barra de abajo, la tilde, la cruz ni los botones flotantes del celular, se corre hacia adentro del mapa si la torre está en un borde y se agranda para leerse con el zoom. Se apaga en **Opciones → «Animaciones de mejora»** (debajo de «Mostrar números de daño»): apagada, queda el anillo y el sonido de siempre. El dibujo usa ahora los atlas aprobados de refuerzo y maestría (M71) y el juego no cambia en nada: costos, niveles y balance son los de antes.
## Presentación de los jefes: pantalla completa y partida en pausa *(T461, 2026-10-23)*

Cuando nace el **primer jefe de una partida de campaña** (jugada desde el menú), el juego se **pausa en ese mismo instante** y una pantalla completa lo presenta: «¡Llega el Jefe!», su retrato, su nombre y su frase. Dura **5 segundos la primera vez** que tu guardado ve a ese jefe y **3 segundos** las veces siguientes. Pasados **0,3 segundos** la salteás con cualquier tecla, clic o toque. **`P`** (o «Atrás») la cierra y deja la partida **en pausa**. Al terminar, la partida sigue exactamente como estaba, salvo que ya estuviera en pausa o que la app haya pasado a segundo plano: en esos casos queda pausada hasta que la continúes vos. Es solo presentación: el jefe nace igual, no cambian oro, vidas ni balance, y mientras se muestra, el cartel de oleada y las tarjetas «Nuevo enemigo» que esperan quedan congelados. El jefe presentado no lleva su propia tarjeta «Nuevo enemigo».

**No aparece** en Asedio, en el modo de pruebas, probando desde el editor ni en mapas de la comunidad. Se apaga en **Opciones → «Presentación de los jefes»** (es la casilla de antes, con otro nombre; conserva tu preferencia).

**Límite visual:** la composición es **provisional** (retrato que el jefe ya tenía sobre un fondo liso teñido, movido por código). Las ilustraciones y los fondos propios del Jefe y del Coloso esperan la aprobación de Lucas (T367); el jefe supremo del nivel 15 espera a T243/T463. No se probó en un celular real. Reemplaza al destello, la grieta y el cartel de 1,6 s de más abajo, que se retiraron.

## Piloto de entrada del Jefe *(T366 y T368, retirado por T461)*

El piloto anterior de destello, grieta y cartel de 1,6 segundos quedó retirado al incorporarse la presentación a pantalla completa. Sus recursos y opción ya no forman parte del juego. La presentación vigente y sus límites están descritos arriba.

## «Novedades de esta versión»: una pantalla con lo nuevo, una vez por versión *(T371 y T373, 2026-10-19)*

- **Al abrir el juego, una pantalla muestra lo nuevo de la versión instalada**, una sola vez por versión: un panel con título, subtítulo, la lista de novedades (hasta 8, con íconos si los hay) y el botón **«Entendido»**. Se cierra con «Entendido», `Esc` o el «atrás» del celular, y el toque que cierra **no** activa nada del menú de abajo. Si la lista no entra, se desplaza (rueda y barra en PC, un dedo con inercia en el celular).
- **Para volver a verla:** **Opciones → «Créditos y versión» → «Novedades de esta versión»** (menú principal y pausa, PC y celular). No cambia lo que el juego recuerda.
- **Cuándo sale sola:** cuando la versión instalada es un número y trae novedades aprobadas, y el guardado todavía no las vio. **No sale** en la versión `beta`, mientras el texto sea un borrador, en el modo de pruebas ni al correr desde el editor de Godot. Si el archivo está roto, el menú abre como siempre.
- **La presentación de la 1.0.0 sale a todos** (también a quien instala por primera vez, antes de la intro); las versiones siguientes, tipo «Mejoras de esta versión», las ven quienes ya jugaron.
- **Los textos están en `data/novedades/novedades.json`** y se pueden retocar sin programar (`CONTENIDO.md`). `godot --headless --path . -s tools/check_novedades.gd` los revisa y avisa si falta la entrada de la versión.
- **Arte:** T375 integró la cabecera y los medallones aprobados; el rombo de bronce queda para ítems sin imagen.
- Tu progreso no cambia: el guardado suma una marca («última versión vista») y una versión anterior del juego lo sigue leyendo.

## Un consejo cuando perdés: qué torre conviene *(T420 a T422, 2026-10-20)*

La pantalla de **Derrota** muestra una pista corta sobre **qué torre usar**, según los enemigos que llegaron a la salida y la oleada final. Solo nombra torres que ese nivel ofrece; si no hay una causa clara, no muestra consejo. Los textos siguen en borrador en `data/consejos/consejos.json`. No cambia el balance.

## «Ver todo» también cuando corriste el mapa *(T304, 2026-10-19)*

«Ver todo» aparece ahora también cuando corriste el mapa con dos dedos aunque no hayas acercado nada: antes, con el zoom mínimo no había forma de volver al encuadre. En la computadora el botón aparece solo cuando corrés el mapa con el botón del medio estando con el zoom mínimo (con la rueda del mouse no aparece, como hasta ahora).

## Pausa al pasar la app a segundo plano *(T303, 2026-10-19)*

En el celular, si llega una llamada o tocás el botón de inicio, la partida **se pausa sola** y queda en pausa al volver (se sigue con «Seguir»). En la computadora, perder el foco de la ventana **no** pausa.

## Botón de demolición en el celular *(T302, 2026-10-19)*

En los niveles con árboles, escombros o minas hay un **tercer botón flotante** (un pico) para demoler y habilitar: se arrastra y se guarda como el carrito y la X, y ya no hay que abrir el catálogo. Al tocarlo se tiñe y la barra de abajo dice «Demoler o habilitar: tocá un objeto del mapa» y trae una cruz para salir (también salen volviendo a tocar el botón, con «atrás» o eligiendo una torre). Un solo toque sirve para un árbol o para una mina; si sale bien, la herramienta se suelta sola, y si no alcanza el oro o ya hay una demolición en curso, la barra dice el motivo y no cobra nada. Mientras está elegida no se ven «Empezar oleada» ni «Próxima oleada». Los tres botones flotantes no se pisan entre sí.

## Un solo catálogo de torres en el celular *(T301, 2026-10-19)*

El catálogo del celular ya no tiene pestañas: es una sola lista con **las torres del nivel** (antes mostraba las 11 del juego, con las que no se podían usar apagadas) y siempre abre mostrando las torres. Antes, en los niveles 6 a 15, abría en «Infraestructura» y volvía ahí cada vez que cambiaba el oro. Donde hay Demoledora, su compra es la última tarjeta. Las herramientas de demoler y habilitar se mueven a un botón propio (T302).
## Opciones: «Créditos y versión» *(T315, 2026-10-19)*

Opciones tiene una sección nueva, **«Créditos y versión»**, con la versión del juego (hoy **«Beta»**; cuando llegue la 1.0.0 dirá «Versión 1.0.0») y el botón **«Ver créditos»**, que abre los créditos y vuelve a Opciones. Está en el menú principal y en la pausa, en PC y en celular. La versión se cambia en un solo lugar (`config/version` en `project.godot`).

## Niveles, Wiki, Récords y Créditos con el dedo *(T314, 2026-10-19)*

En el modo celular, las listas de la selección de niveles, la Wiki, Opciones y los Créditos se **desplazan arrastrando un dedo** (con un poco de inercia al soltar), aunque el dedo empiece sobre una tarjeta o un botón, y la barra de desplazamiento es más ancha para agarrarla. Un toque corto sigue abriendo el nivel o la entrada, y los deslizadores de volumen siguen siendo del dedo. Todos los botones y las filas de esas pantallas miden al menos 56 px de alto. En PC no cambia nada: rueda y barra de siempre.

## Menú principal, Opciones y Pausa pensados para el celular *(T313, 2026-10-19)*

En el modo celular, el menú principal pone el logo a la izquierda y los botones a la derecha (todos de 56 px de alto, cómodos para el dedo) y Opciones se muestra en **dos columnas** con el título y «Volver» siempre a la vista. En Opciones, «Interfaz» ahora está dentro de «Visualización» (antes quedaba debajo de «Volver») y, en cualquier modo, si el panel no entra en la pantalla **se desplaza** en vez de cortarse. En PC todo sigue igual.

## Mouse y toque conviven en el modo celular *(T311, 2026-10-19)*

En el modo celular ahora se puede usar el **mouse además del dedo**, también en Android (DeX, Chromebook, teclado y mouse): un clic mueve el fantasma, abre el carrito, usa la X, la tilde y la cruz, y arrastrar con el botón izquierdo equivale a arrastrar un dedo. Ya no hace falta cambiar a «Interfaz: PC». Un toque sigue haciendo su acción una sola vez (el clic que el sistema fabrica a partir del toque se descarta), también en una notebook con pantalla táctil, donde antes ese clic hacía de segundo dedo. **No se probó en un celular real.**
## Un tutorial en el nivel 1, que se puede apagar y volver a ver *(T330 y T331, 2026-10-19)*

- **Al entrar por primera vez al nivel 1** (después del cartel de entrada) aparece una **tarjeta con un texto corto** y, sobre el botón o la casilla que hay que usar, un **recuadro amarillo que parpadea con una flecha**. Te va mostrando: el **camino** por donde entran los monstruos, tu **oro**, tus **vidas**, cómo **elegir una torre** y **construirla**, cómo **empezar la oleada**, cómo **elegir tu torre**, qué hacen **«Mejorar»** y **«Vender»**, y que existen la **velocidad** y la **pausa**.
- **Te espera a que lo hagas de verdad:** elegir la torre, construirla, empezar la oleada, cambiar la velocidad o pausar hacen avanzar el tutorial solos. Los pasos que solo se leen se pasan con **«Siguiente»**. **El juego no se pausa** mientras tanto, y si te adelantás, el tutorial lo da por hecho.
- **En el celular** los pasos son otros y hablan de toques: **el carrito**, **elegir la torre en el catálogo**, **tocar la casilla** y confirmar con **la tilde ✓** (o con un **doble toque**).
- **Podés saltarlo cuando quieras** con **«Saltar tutorial»**. Si lo completás o lo salteás, **no vuelve a salir**. Quien ya había ganado el nivel 1 antes de esta versión no lo ve.
- **Para apagarlo o volver a verlo:** **Opciones → «Tutorial del nivel 1»** (casilla) y **«Volver a verlo»** (se ve la próxima vez que entres al nivel 1).
- **No sale** en el modo de pruebas, en el editor, en los mapas de la comunidad, en los modos ni en los niveles 2 en adelante. No cambia nada del nivel 1 (oro, vidas, oleadas).
- **Los textos son un borrador** hasta que Lucas los apruebe: están en `data/tutorial/tutorial.json`.
- **Opciones ahora se desplaza** si no entra en la pantalla (con las opciones nuevas ya no cabía en 720 de alto).
- Tu progreso no cambia: el guardado suma una marca («tutorial visto») y una opción, y una versión anterior del juego lo sigue leyendo.

## Un toque, una sola acción en el celular *(T291, 2026-10-18)*

«Apuntar» avanzaba dos modos por toque; ahora avanza uno. La tilde y la cruz de construir ya no salen de la pantalla ni se suben a la barra de arriba (donde un toque podía cambiar la velocidad o pausar además de construir): si arriba no entran, se ponen abajo de la torre.

## Catálogo del celular más fluido *(T290, 2026-10-18)*

Elegir una torre en el catálogo ya no falla si justo cambia el oro (por ejemplo, al morir un enemigo con el dedo apoyado), y el juego deja de hacer trabajo de más en cada cambio de oro con el catálogo cerrado.

## «Empezar oleada» responde al toque en el celular *(T288, 2026-10-18)*

En el modo celular el botón «Empezar oleada» se veía pero no recibía el toque, porque la barra de abajo lo tapaba. Ahora responde.

## Ajustes del HUD móvil tras probar el PR #10 *(T287, 2026-10-16)*

## Escombros comunes del nivel 9 *(T282, 2026-10-17)*

Los tres escombros comunes del Taller ahora garantizan 1 recurso cada uno al demolerlos. El bot confirmó que así se reúnen los 3 recursos del Mortero, pero la estrategia que va por ellos pierde en las cinco semillas y no llega a comprarlo; se deja el costo de demolición y el del Mortero como están hasta que Lucas lo pruebe (T283).

## Copia de seguridad automática del guardado *(M60, spec del 2026-10-16; todavía falta programarla, T281)*

Carrito y salida reciben un solo gesto, sin doble pulsación del mouse emulado. Carrito, X, tilde y cruz son más chicos y redondeados, con íconos de marfil y bronce; la tilde ya no repite el precio. El catálogo y la barra inferior comparten el tema oscuro del juego. Se eliminan las franjas grises de los márgenes y la línea que atravesaba la barra superior. El precio sigue en el catálogo y la barra; si no se puede construir, la barra muestra el motivo.

## Arte aprobado de La Cuadrilla *(T286, 2026-10-16)*

El Ratero usa el concepto B elegido por Lucas y el Cargador el concepto A, con sus atlas de caminata en cuatro direcciones. Se calibró su tamaño visual para acercarlo al del Ladrón; radios, vida, velocidad, robo y oleadas no cambiaron.

## Copia de seguridad automática del guardado *(T281, 2026-10-16)*

Antes de la primera escritura de `save.json` en una ejecución, el juego copia los bytes originales a `save_respaldo_<versión>.json` en la misma carpeta. Conserva la primera copia de cada versión, también si el guardado está dañado; no copia archivos vacíos y no se activa para el modo de pruebas ni para rutas de tests. Es silenciosa, tiene un tope de 10 copias y no reemplaza el respaldo manual obligatorio del archivo real del tester.

## Arte aprobado en el mapa *(T277, 2026-10-16)*

Las estatuas de los niveles 1, 3 y 5 ahora representan Cañón, Francotirador y Ametralladora tallados en piedra con musgo y pedestal; siguen siendo decoración sin selección ni alcance. Mina y bosque explotable muestran dibujos renderizados distintos al habilitarse y agotarse; los escombros cambian durante la demolición. La Central del nivel 15 usa el edificio aprobado, continuo sobre sus cuatro casillas. Se conservan suelos, flores, torres, casillas y reglas de juego.

## Niveles 2 y 7 más justos *(T279, 2026-10-16)*

El bot confirmó que los cambios de oleadas alivian los picos sin cambiar el aumento de vida. El nivel 2 ahora tiene un Jefe y no trae los 12 Blindados finales; el nivel 7 reduce los Rápidos de las oleadas 2, 11 y 18 y los Voladores de la 18. En cinco semillas, `mix` gana el nivel 2 con 16 vidas y `smart` con 17; en el nivel 7 ganan `smart` (5–6), `mix` (12), mejoras tempranas (9–11) y `demoler` (13). La regla de oro sigue cumpliéndose y los niveles 13, 14 y 15 conservaron sus mínimos (5, 3 y 2 vidas).

Lucas todavía tiene que jugar 1 → 2 → 3 y 6 → 7 → 8, además de las partidas específicas de T280. No se hicieron partidas humanas; falta esa validación antes de reenviar el juego al tester.

## Interfaz para celular: modo, gestos, cámara, catálogo y barra de torre *(T271 a T276, 2026-10-16)*

- **Opciones → Interfaz** permite elegir «Automática», «Celular» o «PC». La elección se guarda y se aplica al abrir la próxima partida; no cambia una partida en curso.
- En modo Celular, la barra superior crece a 64 px, muestra Pausa y velocidad con botones de 56 px, y oculta «← Menú» y los atajos de teclado. Los números de esta interfaz se cargan desde `data/ui/mobile_ui.json`; si el archivo está dañado, se usan los valores por omisión.
- **Construcción en dos pasos:** al elegir una torre aparece un fantasma; tocar mueve el fantasma y la tilde construye. La cruz o `Esc` cancelan; un doble toque rápido en una misma casilla también confirma. Un toque, arrastre o gesto de dos dedos no compra.
- **Zoom y movimiento del mapa:** en celular, pinza para acercar o alejar, dos dedos para mover y «Ver todo» para volver al encuadre. En PC, rueda para acercar y alejar alrededor del puntero y botón central para desplazar; no aparece un control nuevo.
- **Carrito y salida:** en modo Celular, el carrito y la X flotan sobre el mapa. Se arrastran hasta el borde izquierdo o derecho, recuerdan su ubicación por dispositivo y se apartan temporalmente del fantasma. El carrito abre un catálogo de torres y, cuando el nivel los usa, una pestaña de infraestructura; las opciones que no se pueden elegir muestran el motivo. La X muestra la confirmación de salida de siempre y, al probar desde el editor, vuelve directo al editor.
- **El catálogo no pausa la partida:** al elegir una torre aparece el fantasma; las herramientas de demolición y extracción se eligen allí y se aplican al tocar el objeto compatible del mapa. Tocar afuera o usar «atrás» cierra el catálogo sin enviar ese toque al mapa.
- **La barra inferior móvil** alterna entre una sugerencia con las oleadas, la torre fantasma con tilde/cruz duplicadas y la torre elegida con nivel, estadísticas, apuntado, mejora y venta protegida por dos toques. Una mejora bloquea el botón durante 0,35 s; la venta armada expira y el toque a 8 px debajo de «Mejorar» no la activa.
- **La PC conserva su interfaz actual.** La medición en un celular real y las capturas de los niveles 1 y 15 quedan pendientes.

## Lo que viene al celular: insignias y estatuas *(M58, spec del 2026-10-16)*

**Esto es lo que Lucas pidió y todavía falta implementar:**

- **Un carrito flotante** abre el catálogo de torres sobre el mapa y se cierra solo al elegir una; **una X flotante** lleva al menú (con la confirmación de siempre). Los dos se **arrastran y se pegan al borde** izquierdo o derecho, y el juego recuerda dónde los dejaste.
- **Se coloca con una torre fantasma:** tocás una casilla, ves cómo queda, y confirmás con la **tilde** (o cancelás con la **cruz**). **Nada se compra al apoyar el dedo.** Al colocar, la torre se deselecciona.
- **Zoom con los dedos:** pinza para acercar y alejar, dos dedos para mover el mapa y un botón «Ver todo». En la computadora, con la rueda del mouse y el botón del medio.
- **La barra de abajo muestra la torre elegida:** nombre, nivel, estadísticas, «Mejorar» (con el costo o el motivo si no se puede) y «Vender», que pide un segundo toque.
- **Las tarjetas de nivel ya muestran las torres como insignias de bronce** (T270, en PC y en celular).
- **La PC queda igual**; el selector para forzar el modo celular o de PC ya está en Opciones.
- **Las estatuas de los niveles 1, 3 y 5 ya son torres de piedra** con el arte aprobado (T277).

## La intro: siete láminas con texto, que se pueden omitir y volver a ver *(T242, 2026-10-11)*

- **Al tocar «Jugar» por primera vez se ve una intro de siete láminas** (unos 50 segundos) con el texto abajo y un fundido entre una y otra: la nave, qué lleva, los años de viaje, el planeta seco con un único punto verde, la bajada, los motores apagados y el oasis. Cuenta la llegada; no explica cómo se juega.
- **Avanza sola o con un toque** (clic, `Espacio`, `Enter` o `→`). **«Omitir»** (arriba a la derecha), `Esc` y el «atrás» del celular la terminan entera, sin pedir confirmación.
- **A dónde lleva al terminar:** si todavía no ganaste ningún nivel, **directo al nivel 1**; si ya jugaste antes, a la **selección de niveles** como siempre. Un guardado de una versión anterior la ve **una sola vez**.
- **Para volver a verla:** **Wiki → Lore → «Ver la intro»**. Funciona siempre y no toca tu progreso. En el modo de pruebas no salta sola (se pide desde la Wiki).
- **Si el archivo de la intro falla, el juego sigue:** «Jugar» va a la selección de niveles.
- **Las siete láminas son las definitivas** (dibujos en estilo «cuaderno de bitácora», aprobados el 2026-10-11): ocupan unos **24 MB** del juego (el instalable de Android pasa de unos 60 MB a unos 87 MB). El texto entra en la franja de abajo en cualquier tamaño de pantalla, también el peor caso de dos líneas de 90 caracteres.
- Tu progreso no cambia: el guardado suma solo una marca («intro vista») y una versión anterior del juego lo sigue leyendo.

## Asedio con los 15 mapas y una dificultad propia por mapa *(T258, 2026-10-10)*

- **Asedio tiene ahora los 15 mapas de la campaña.** Cada mapa se abre al ganar el anterior, como siempre: ganar el 9 abre el 10, y así hasta **La Central**. Tienen progreso, estrellas y récords propios y no tocan la campaña.
- **Cada mapa tiene su propia dureza.** Los monstruos de Asedio ya no tienen todos 115 % de vida: van de **101 % a 118 %** según el mapa (por ejemplo, los tres primeros 105 %, el 10 y el 14 118 %, y el 4 y el 15 siguen en 115 %). La campaña no cambió en nada.
- **Todavía no es la dificultad final:** los porcentajes salen de un bot de pruebas, no de una persona. Se ajustan después de que Lucas juegue del 1 al 15.
- **Para quien arma modos propios:** un `modo.json` puede traer la tabla `"vida_monstruos_por_mapa_%"` dentro de `reglas` (ver `CONTENIDO.md`). **Una versión anterior del juego no abre un modo que la traiga**: lo muestra con error.
- El editor de mapas **conserva** la tabla al guardar un mapa en un modo, pero no la edita: se escribe a mano en el archivo.

## La Cuadrilla: una banda nueva en los niveles 7, 10, 13 y 14 *(T253, 2026-10-10)*

- **Dos enemigos nuevos, el Ratero y el Cargador.** Son criaturas que **andan en banda**: el **Ratero** es chico y rapidísimo (14 de vida, velocidad 2,2, quita 1 vida) y el **Cargador** es grande y lento (110 de vida, armadura 1, quita 2 vidas). **Los dos roban oro** como el Ladrón, pero **cada uno por su cuenta**: el Ratero 2 de oro cada 2 segundos y el Cargador 4, sin bajar nunca de 10. Se barren con **torres de área** (Ratero) y con **daño sostenido** (Cargador); el Hielo los frena.
- **Dónde salen.** Debutan en el **nivel 7** (oleada 8) y vuelven en el **10**, el **13** y el **14**, **cuatro veces en cada uno**, siempre en oleadas sin Guardián, Curandero, Chamán, Espejo ni Soberano. Los demás niveles no cambian, y el 15 tampoco.
- **Wiki.** Los dos tienen su entrada en **Enemigos** (se abre la primera vez que los ves, con la línea «Robo» y los niveles donde aparecen) y hay un artículo nuevo en **Lore**, **«La Cuadrilla»**, que se abre al ganar el nivel 7; los artículos siguientes conservan su orden.
- **Arte provisional, pendiente de rehacerse:** por ahora se ven como una **forma de color** (un rombo ocre el Ratero y un hexágono más oscuro el Cargador); la Wiki todavía no muestra ilustraciones. Otro agente prepara las nuevas versiones (2026-10-16).
- **Modo Asedio:** los mapas 7, 10, 13 y 14 heredan a la Cuadrilla, así que ahí se vuelven más difíciles.
- Los números del Ladrón, del Soberano, del Coloso y de las torres **no cambian**.

## Versión 1.0: el juego pasa a llamarse «Monsters & Canons» *(T237, 2026-10-09)*

- **Nuevo nombre en la ventana y en los archivos.** El juego se abre como **Monsters & Canons**, y los archivos son `MonstersCanons.exe` (Windows), `MonstersCanons.x86_64` (Linux) y `MonstersCanons.apk` (Android). La versión es la **1.0.0**.
- **Tu progreso se conserva en PC.** Los guardados, récords, mapas y modos propios siguen en la misma carpeta de siempre, así que no se pierde nada.
- **En el celular se instala como otra app.** El paquete cambió a `com.monsterscanons.v1`: la APK vieja queda aparte y se puede desinstalar a mano; el progreso del celular viejo **no pasa** a la app nueva. *(La APK nueva todavía no está generada: falta preparar el SDK de Android en la máquina de trabajo.)*
- No cambia ninguna regla ni número del juego.

## Torres más livianas con muchas en pantalla *(T236, 2026-10-09)*

- **El juego va más fluido en las oleadas finales.** Con 60 o más torres en el mapa del final, las torres quietas ya no se vuelven a dibujar en cada instante: solo se redibujan cuando giran de verdad, disparan o están aturdidas. En la prueba del nivel 15 (oleada 30, 64 torres) los cuadros por segundo pasaron de unos 30–45 a unos 95–100 en los primeros 30 segundos de la oleada. No cambia cómo se ven ni cómo apuntan ni ninguna regla ni número.
- Los guardados de versiones anteriores (solo con niveles, de antes de la Disruptora, con las colecciones completas y los del modo de pruebas) se siguen leyendo sin perder nada, y ganar el 9 sigue abriendo el 10.

## Nivel 15: La Central, el Coloso, el epílogo y los créditos *(T234, 2026-10-09)*

- **La campaña tiene 15 niveles y termina.** El nuevo se abre al ganar el 14: **La Central**, «energía y abastecimiento», un mapa **grande** (26 × 12) en el **valle** donde aterrizó la nave, con **tres entradas**. Al lado de la salida está la **central de energía** (un edificio de cuatro piezas) y, por el borde del mapa, la **cadena de abastecimiento** (un depósito, un poste de línea y una vagoneta) que la une con la mina. Hay una mina, dos bosques y cinco escombros, y también tres campamentos vacíos y dos rocas marcadas, como en el primer nivel. Es **el nivel más difícil de la campaña**: **30 oleadas**, 520 de oro y 20 vidas.
- **Llega el Coloso.** Es el jefe del final y **reemplaza al Soberano**: una masa de piedra lenta (velocidad 0.5), con mucha vida y armadura, que **al caer se parte en tres Pedazos** rápidos y sin armadura que siguen camino. Si el Coloso llega a la salida **quita 12 de tus 20 vidas** (y no se parte); cada Pedazo que llega, 4. **Los golpes fuertes lo rompen** (Francotirador, Cañón, la quemadura de la Incendiaria, la Eléctrica) y **el Hielo y las torres de área barren los Pedazos**: hace falta tener las dos cosas. Sale en las oleadas **26** (uno, con enemigos ya conocidos), **28** (dos) y **30** (tres, con la **escolta completa**: Guardianes, Curanderos y Chamanes en formación y por dos entradas a la vez). La oleada 25 es un respiro.
- **Ganar el 15 muestra el «Epílogo».** En la pantalla de victoria, en lugar de «Siguiente nivel» (no hay otro) aparece el botón **«Epílogo»**: la imagen del final con cuatro líneas y los botones **«Créditos»** y **«Niveles»**. `Esc` o un toque sobre la imagen vuelven a la pantalla de victoria; los puntos, las iniciales y los récords funcionan **antes**, como siempre. **Los créditos** son una pantalla de texto con «Volver». Solo se ve ganando el 15 desde la campaña (no en los modos, los mapas de la comunidad, el editor ni el modo de pruebas), y **no se guarda nada nuevo**: la campaña queda terminada cuando los 15 niveles figuran ganados.
- **Wiki:** al ganar el 15 se abre el artículo de Lore **«La Central»** (con lo que dicen los colonos del Coloso); y los de los niveles 11 («Los pozos») y 14 («Los poblados vacíos») ya se ven al ganar esos niveles. **Enemigos** suma al **Coloso** (con la corona de «Peligroso») y al **Pedazo**, que se abren cuando los ves por primera vez.
- Sin Ametralladora ni Lanzamisiles. **Se gana sin tocar la mina, los bosques ni los escombros.**
- Para quien arma mapas: la **leyenda** de un mapa puede tener ahora hasta **12 letras** (eran 10), y hay ocho dibujos nuevos para las piezas de la central y de la cadena de abastecimiento.
- **Aprobación de arte (2026-10-16):** Lucas aprobó el arte del Coloso y su Pedazo para integración. El Ratero y el Cargador se van a rehacer; los nuevos dibujos los prepara otro agente y todavía no están integrados.

## Tarjetas de nivel sin superposiciones *(T250, 2026-10-09)*

- En la selección de nivel, el nombre, el lugar, los íconos de las torres, las estrellas y el resultado ahora tienen su propio espacio. «Bloqueado» y «Mejor: N vidas» ya no pisan los íconos.
- Si un nivel ofrece 9 o más torres, los íconos pasan a otro renglón y siguen dentro de la tarjeta; la marca naranja y el tooltip «Nueva» se conservan.

## Textos de los niveles y Lore en la Wiki *(T228, 2026-10-09)*

- **Cada nivel de la campaña (1 a 10) cuenta dónde estás.** La **tarjeta** del nivel (si ya está desbloqueado) muestra su lugar bajo el nombre, por ejemplo «El paso del agua». Al entrar a un nivel aparece un **cartel** con el nombre, el lugar y tres líneas de entrada: **la partida espera mientras lo leés** y se cierra con un toque, `Espacio`, `Enter` o `Esc`. **«Reintentar» no lo vuelve a mostrar.** Al ganar, la pantalla de victoria suma dos líneas bajo las estrellas.
- **No se ven** en el modo de pruebas, al probar un mapa desde el editor ni en el modo Asedio. Un mapa de la comunidad los muestra solo si su archivo trae el campo `"textos"` (ver `CONTENIDO.md`).
- **Wiki → Lore:** una solapa nueva con artículos sobre el oasis, Cántaro, la Compañía Meridiana, el Soberano y más. Cada uno **se abre al ganar un nivel** (quien ya había ganado hasta el 9 los tiene abiertos); antes se ve «???» y «Se abre al ganar el nivel N.». Hoy son **7 artículos**; los de los niveles 11, 14 y 15 aparecen cuando esos niveles lleguen a la campaña.
- No cambió ningún número del juego ni el guardado.
## Nivel 14: Los poblados vacíos *(T232, 2026-10-09)*

- **La campaña tiene 14 niveles.** El nuevo se abre al ganar el 13: **Los poblados vacíos**, «asentamientos de los Moradores», un mapa **grande** (26 × 12) de **ruinas** con **dos entradas** a la derecha cuyos caminos se unen y siguen juntos hasta la salida, a la izquierda. Los poblados están **vacíos pero con huellas recientes**: campamentos con restos de fuego, cuerdas y pieles, el símbolo A por todas partes y columnas rotas. Hay una mina y un bosque (uno por entrada) y cinco removibles, las casas del poblado.
- **No hay enemigos nuevos: es el examen antes del final.** Vienen **todos juntos**: la escolta (Guardián, Curandero y Chamán) con el **Espejo** y **Voladores**, el Ladrón, el Embestidor y el Soberano, en **26 oleadas**. Es **el nivel más difícil hasta ahora** (aumento de vida de 30 % por oleada).
- Sin Ametralladora. **Se gana sin tocar la mina, el bosque ni los removibles.** Con la Disruptora, conviene ponerla donde se juntan los caminos.

## Nivel 13: Paso alto *(T231, 2026-10-09)*

- **La campaña tiene 13 niveles.** El nuevo se abre al ganar el 12: **Paso alto**, «el camino al resto de la región», un mapa **grande** (26 × 12) de **nieve** con **dos entradas** (arriba y abajo a la izquierda) cuyos caminos **se unen** y siguen juntos hasta la salida, una **laguna de hielo** en el medio (no se construye) y cuatro rocas marcadas a lo largo de los caminos. Hay una **mina** del lado de la entrada de arriba y un **bosque** del lado de la de abajo (2 recursos por oleada cada uno), y cinco removibles.
- **No hay enemigos nuevos: lo nuevo es cómo vienen.** Aparece **la escolta**: un **Guardián, un Curandero y un Chamán juntos**, que protegen, curan y apagan torres a la vez. La primera llega en la oleada 9 por una sola entrada; desde la 14 vienen **por las dos entradas al mismo tiempo**. Conviene **repartir las defensas** entre las dos entradas y apagar las auras (con la Disruptora, si la tenés) donde los caminos se juntan.
- Sin Ametralladora ni Lanzamisiles. **Se gana sin tocar la mina, el bosque ni los removibles.** El nivel es **tan difícil como el 11** (con aumento de vida de 40 % por oleada, 24 oleadas).

## Nivel 12: El cañadón *(T230, 2026-10-09)*

- **La campaña tiene 12 niveles.** El nuevo se abre al ganar el 11: **El cañadón**, «el paso hacia el norte»: un mapa **grande** (26 × 11) del **desierto** con **una entrada** y un camino que **zigzaguea entre paredes de roca** (cinco tramos verticales). Hay pocas casillas buenas (45), tres rocas marcadas en la boca del cañadón, cinco rocas y escombros que pueden dar 1 recurso y, en lugar de la mina, un **bosque explotable** (100 de oro, 2 recursos por oleada, 8 en total).
- **Debuta el Espejo**, solo, en la oleada 5: **devuelve los tiros de las torres cercanas** (a menos de 2,5 casillas) y las aturde un par de segundos. Lo que rinde es **pegarle de lejos** (Francotirador, Mortero, Incendiaria) y no poner las torres pegadas al camino. Desde la oleada 8 se mezclan el Chamán, el Guardián y el Curandero, y desde la 12 el Espejo viaja con ellos.
- Sigue sin Ametralladora; con las colecciones completas están la Disruptora y el Mecánico. **Se gana sin tocar el bosque ni los removibles.** El nivel es **más difícil que el 11** (aumento de vida de 27 % por oleada, 24 oleadas).

## Nivel 11: Puesto seco *(T229, 2026-10-09)*

- **La campaña tiene 11 niveles.** El nuevo se abre al ganar el 10: **Puesto seco**, «el punto de agua», un mapa **grande** (24 × 11) del **desierto** con **una sola entrada** y un camino largo en serpentina. Tiene **dos pozos de agua** y tres rocas marcadas al costado del camino, una **mina** (100 de oro, 2 recursos por oleada) y cinco rocas y escombros que pueden dar 1 recurso.
- **Desde acá ya no hay Ametralladora.** El nivel ofrece las otras torres (Cañón, Hielo, Francotirador, Incendiaria, Múltiple, Ráfaga, Eléctrica y Mortero) y, si completaste sus colecciones, la **Disruptora** (que en este nivel aparece marcada como «Nueva») y el Mecánico. La apertura es con el **Hielo** y una torre de entre 90 y 110 de oro.
- **Debuta el Chamán**, y lo hace solo, en la oleada 5: **apaga la torre más cercana** unos segundos. Un Francotirador lo alcanza antes de que lance el hechizo. El Guardián y el Curandero llegan juntos desde la oleada 8; el Chamán se les suma desde la 12 (ahí sirve la Disruptora contra las auras). El Soberano aparece a mitad del nivel.
- **Se gana sin tocar la mina, los removibles ni los recursos.** El nivel es más difícil que el 10 (con aumento de vida de 27 % por oleada).

## La barra con pestañas y la flecha al menú *(T248, 2026-10-08)*

- **Del nivel 6 en adelante, la barra de abajo tiene dos pestañas:** **«Cañones»** (las torres de siempre) e **«Infraestructura»** (todo lo de demoler, la demoledora, la extracción y los recursos). Aparecen en **todo mapa que tenga removibles, minas o demoledora** (hoy, los niveles 6 a 10, y también un mapa de la comunidad con un solo árbol removible). **Los niveles 1 a 5 se ven y se juegan exactamente igual.**
- **El botón «Infraestructura» de arriba a la derecha desaparece:** la demoledora se compra ahora en la pestaña, que además muestra el **trabajo en curso** (con barra y «Cancelar»), la **extracción** (una ficha por mina o bosque, con «Habilitar») y los **recursos**. Tocar una roca o un árbol del mapa funciona igual que antes y **no cambia de pestaña**: mientras demolés, el título de la pestaña dice «Infraestructura · 4 s».
- **Teclas:** `1` a `9` eligen las torres 1 a 9, **`0` elige la décima** y **`Tab` cambia de pestaña** (solo en los niveles con pestañas). Con una torre elegida, `Tab` cancela la construcción; apretar la tecla de una torre desde «Infraestructura» vuelve a «Cañones» y la elige. Todo se puede hacer también con el mouse o con el dedo.
- **Los botones de torre se achican** (de 76 a 57 px) cuando hay más de 9, para que entren todas sin tapar «Próxima oleada»; el costo y el ícono del recurso se siguen leyendo.
- **Arreglo escondido:** con 10 torres, cada tecla o clic hacía que el juego anotara un error de «acción inexistente» (`build_10`) en el registro. Ya no.
- **Una flecha «← Menú» arriba a la izquierda, en todos los niveles.** **Siempre pregunta** antes de salir y te dice qué perdés: las **piezas de colección recogidas en la partida (aunque ya estén confirmadas)** y la **demolición en curso**; lo que ya ganaste (niveles, estrellas, récords y piezas guardadas) se conserva. Mientras decidís, la partida queda en pausa, y «Seguir jugando» la deja como estaba (corriendo a la misma velocidad, o en pausa si ya lo estaba). Al probar un mapa desde el editor, la flecha dice **«← Editor»** y vuelve sin preguntar. El menú de pausa (`Esc`) no cambió.
## Retoques de arte provisional *(T249, 2026-10-09)*

- Las señales de piedra muestran el símbolo A con más contraste y el poste tiene cintas gastadas más claras. La **Disruptora** gana anillos más anchos y un disco emisor más legible en el mapa y la barra.
- Se retocaron también los SVG de removibles, minas, bosque e íconos; su integración visual completa sigue pendiente. Comparación antes/después y límites en `art/t249-mejoras/`. Todo sigue siendo **provisional**, sujeto a la aprobación de Lucas.

## Arreglo del botón «Infraestructura» *(T246, 2026-10-08)*

- En el **Cruce** (nivel 7) el botón **Infraestructura** estaba **encima de «Pausa» y «Velocidad»** y se veía como texto suelto. Ahora va en la barra de arriba, a la izquierda de «Pausa», con el mismo marco que los demás botones.
- El panel de compra de la demoledora ya no sale altísimo por un instante al abrirse, y el panel de cada removible tampoco.
- En los niveles 8 y 9 el panel de los escombros funciona al tocarlos (se comprobó con clics reales de mouse); si algo no responde en tu máquina, avisá con el nivel y la casilla.

## Herramientas para probar recursos, demoliciones y colecciones *(T213, 2026-10-08)*

- El panel de pruebas suma **+10 recursos** (el contador aparece aunque el mapa no tenga fuentes), **Terminar demolición** para cobrar la recompensa normal del trabajo en curso y **Habilitar todas las colecciones** para probar las torres que las requieren sin completar ni guardar piezas.
- La habilitación de colecciones dura solo la partida actual; nada de estas acciones modifica el guardado normal.
## Nivel 10: La mina vieja *(T225, 2026-10-08)*

- **La campaña tiene 10 niveles.** El nuevo se abre al ganar el 9: **La mina vieja**, un mapa **grande** (24 × 11) del **desierto**, con dos entradas y un camino en serpentina. Las ruinas de los niveles 8 y 9 quedan atrás: se ven columnas rotas, escombros y el símbolo A en tres rocas.
- **Una mina para habilitar** (100 de oro): da **2 recursos por oleada completada** y se agota a los 8. Hay también **seis removibles** (rocas y escombros) que pueden entregar 1 recurso (50 %, al azar).
- **La pieza 3/3 de la Disruptora** está en un escombro del centro del mapa. Con las piezas del 8 y del 9, la colección queda **completa** y la Disruptora estará lista para el nivel 11.
- El **Mortero** sigue disponible (300 de oro + 3 recursos), con cuatro bloques de 2×2 libres. El Francotirador mantiene sus dos precios (150 de oro, o 120 + 1 recurso).
- **Hay pocas casillas buenas** (43): el espacio es lo que falta, no el oro. Los enemigos son los de los niveles 6 a 9, sin ninguno nuevo; el Guardián y el Curandero van juntos en varias oleadas. **Se gana sin tocar la mina, los removibles ni los recursos.**
- El modo **Asedio** sigue con los mapas 1 a 9.

## Editor: removibles, minas, demoledora y torres del mapa *(T212, 2026-10-08)*

- El **editor de mapas** suma cinco pinceles: **Árbol**, **Roca**, **Escombro**, **Mina** y **Bosque** (teclas `6` a `0`). Se pintan como el pasto o el camino y el editor arma solo la leyenda del archivo. Si la leyenda ya tiene sus 10 letras, avisa abajo en lugar de pintar.
- Un botón nuevo, **Objetos**, deja cambiar el costo, el tiempo, los recursos y la probabilidad de un removible (o la producción y la reserva de una mina) para todas las casillas de ese tipo, viendo siempre el valor de la clase.
- **Ajustes** suma *Demoledora disponible* y *Torres del mapa* (casillas para elegir cuáles ofrece el nivel; "Usar las de siempre" las deja como antes). **Probar** funciona con todo esto.
- La **pieza de colección** de una ruina solo se puede elegir al editar un nivel de la campaña; en los mapas de la comunidad y de los modos el campo está deshabilitado y explica por qué (si el archivo ya tenía una, se conserva).
## Niveles 8 y 9 en las ruinas *(T224, 2026-10-08)*

- **Bastión («El bastión sobre ruinas»)** y **Taller asediado («El taller»)** pasan a las **ruinas**, con escombros que se pueden **demoler** (90 de oro, 10 segundos). Algunos entregan 1 recurso (50 %) y se ve el símbolo A grabado en la piedra.
- En cada nivel hay un **escombro especial** con una **pieza de la Disruptora** (la 1.ª en el Bastión y la 2.ª en el Taller). Se confirma al completar la oleada y queda guardada en la campaña; la 3.ª aparece más adelante.
- El **Mortero debuta en el Taller** y cuesta 300 de oro y 3 recursos; el Bastión no lo tiene. Con los escombros del Bastión el mapa es un poco más exigente si no se demuele.
- El camino y las oleadas no cambian.

## Niveles 6 y 7 en el bosque *(T223, 2026-10-08)*

- **Nido («El lindero»)** y **Cruce («El aserradero»)** pasan al **bosque**, con árboles y rocas que se pueden **demoler** pagando oro y esperando (un clic sobre el objeto). Despejarlos libera casillas buenas entre las rectas del camino. En el Nido son 3 y **no dan recursos**; se gana sin demoler.
- En el Cruce hay 6 removibles, la **demoledora** se puede comprar desde el botón *Infraestructura* y cada removible **puede entregar 1 recurso** (50 % de probabilidad). Con un recurso, el Francotirador cuesta 120 de oro en vez de 150; nunca es obligatorio. Se suman señales nuevas (un poste con cintas y una roca con una marca tallada).
- El camino y las oleadas no cambian.
## Disruptora *(T217, 2026-10-08; en revisión de balance)*

- Torre nueva, la **Disruptora** (130 de oro + 2 recursos): no dispara; cada 4 s emite un **pulso** en un círculo de 2,5 casillas. Si el pulso alcanza a un **Guardián o un Curandero**, ese enemigo **deja de emitir su aura 2,5 s** (3 y 3,5 s en los niveles 2 y 3), y todos los alcanzados reciben un golpe muy débil (5). No toca al Espejo ni apaga otras habilidades (Chamán, Ladrón, Embestidor). Si no hay ningún emisor de aura a su alcance, no pulsa.
- Solo la tienen quienes completaron la colección **Disruptora** y en los niveles que la ofrecen: **ningún nivel de 1 a 10 la ofrece**.
- Se ve como un anillo blanco azulado que se expande; el enemigo suprimido muestra el anillo del suelo roto y un ícono de tres arcos que se apagan. La Wiki suma la ficha de la torre, la línea **Contramedida** en el Guardián y el Curandero y un párrafo en "Efectos de las torres".

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
