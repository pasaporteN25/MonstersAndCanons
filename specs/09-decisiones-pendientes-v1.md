# 09 — Decisiones pendientes para cerrar la V1 (cuestionario para Lucas)

Fecha: 2026-10-07 (respondido por Lucas el 2026-10-08). Es la tarea **T200** del [plan 08](08-plan-cierre-v1.md) y la compuerta **G1**: sin estas respuestas no arranca ninguna tarea de spec.

**Cómo responder:** cada pregunta trae la **recomendación de Claude**. Alcanza con escribir en tu respuesta, por ejemplo, *"Acepto todas salvo Q-07 (no) y Q-29 (retirar también la Ráfaga)"*. En las preguntas abiertas (Q-03) hace falta tu texto. Después, la tarea T205 o T227 las pasa a decisiones `D-0xx` con la fecha de tu respuesta.

Los **valores numéricos** de las recomendaciones son **iniciales**: viven en datos y se ajustan con el bot (T214) y con tus partidas. Lo que se decide acá es la **regla**.

Columna "Tu respuesta": ✔ acepto · ✘ no · ✎ cambio (escribir cuál).

---

## A. Alcance y marco

| # | Pregunta | Recomendación de Claude | Tu respuesta |
|---|---|---|---|
| Q-01 | §11 de la spec excluye **"Historia, diálogos o cinemáticas"**. El 07 pide textos, epílogo e intro. ¿Se enmienda §11? | **Sí, de forma acotada.** Se permiten textos breves por nivel (entrada de hasta 3 líneas y victoria de hasta 2), una categoría Lore en la Wiki, un epílogo en la victoria del 15 y una intro de láminas que se pueda omitir y volver a ver. **Siguen excluidos:** diálogos entre personajes, cinemáticas animadas y voces. | ✔ (2026-10-08) |
| Q-02 | ¿"Base para la franquicia" es lo de la sección 3 del plan 08 (biblia, glosario, lore en el juego, marca y datos reutilizables)? | **Sí.** No incluye preparar código para el 3D. | ✔ (2026-10-08) |
| Q-03 | Nombres del **planeta**, de la **expedición o colonia** y de las **comunidades locales**. | Que T201 proponga **3 opciones de cada uno** y vos elijas en G2. Si ya tenés nombres, escribilos acá. | ✔ (2026-10-08) |
| Q-04 | El ejecutable, el paquete Android (`com.juegoa.towerdefense`) y la ventana dicen **"JuegoA"**. ¿Se pasan a la marca? | **Sí:** `MonstersCanons.exe` / `.x86_64` / `.apk`, ventana "Monsters & Canons" y un paquete nuevo (por ejemplo `com.monsterscanons.v1`). La APK que tenés instalada quedaría como otra app. | ✔ (2026-10-08) |
| Q-05 | ¿Dónde se publica y cómo se ofrece el código fuente (GPL, D-077)? | **itch.io gratis**, y el **repositorio público** con una etiqueta `v1.0` al publicar. Play Store queda para después. | ✔ (2026-10-08) |
| Q-06 | El documento 06 pedía hacer **B-14 (tipos de daño), B-23 (recetas de vecindad), B-08 (terrenos con efecto) y B-09 (puentes)** antes de los niveles 10 a 15. ¿Entran en la V1? | **No: después de la entrega**, como actualizaciones. Los sistemas del 07 ya son bastante. Si alguno entra, tiene que ir **antes** de T223 para no balancear dos veces. | ✔ (2026-10-08) |
| Q-07 | Aprobar la sugerencia "**bot de balance repetible**" (§13, Sugerencias de Claude), ampliada a varias semillas. | **Sí.** Es la herramienta para demostrar "se gana sin recursos". | ✔ (2026-10-08) |

## B. Demolición y demoledora (07 §5)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-08 | ¿La demoledora es un **botón en un panel global del HUD** o una **estructura en una casilla**? | **Botón global** ("Infraestructura"). Ya está acordado que su descuento vale para todo el mapa; así no ocupa casillas y en el mapa solo se ve una animación de trabajo sobre el objeto. | ✔ (2026-10-08) |
| Q-09 | ¿Precio **uniforme** o **por clase** de objeto? | **Por clase**, en datos: árbol 40, roca 60 y escombro de ruina 90 de oro (valores iniciales). | ✔ (2026-10-08) |
| Q-10 | ¿Duración uniforme o por clase? ¿La máquina baja también el tiempo? | **Por clase:** árbol 4 s, roca 6 s y escombro 10 s de juego. **La máquina solo baja el precio.** | ✎ (2026-10-08): duración por clase (árbol 4 s, roca 6 s, escombro 10 s; valores iniciales) y la máquina baja el precio **y también un poco el tiempo**. Cuánto baja el tiempo lo fija T205 con el bot; no se inventa acá. |
| Q-11 | ¿Se cobra al ordenar o al terminar? | **Al ordenar.** Así no se puede quedar sin oro a mitad de un trabajo. | ✔ (2026-10-08) |
| Q-12 | ¿Se puede cancelar? | **Sí, con reembolso total**, y el objeto queda como estaba. No da ganancia, porque la recompensa llega recién al terminar. | ✔ (2026-10-08) |
| Q-13 | ¿Se vende la máquina? | **No.** Evita ganar plata comprándola y vendiéndola. Precio: 3 × el de la roca (180) y uso a 10 % del precio de cada objeto (mínimo 5). | ✔ (2026-10-08) |
| Q-14 | ¿Qué pasa con un trabajo en curso al terminar una oleada o la partida? | **Al terminar la oleada sigue**, porque se demuele en preparación y durante las oleadas. **Al terminar la partida** (victoria, derrota o abandono) se pierde y no entrega nada. | ✔ (2026-10-08) |
| Q-15 | ¿Hay cola de órdenes? | **No.** Mientras hay un trabajo activo, los demás removibles muestran "Hay una demolición en curso". | ✔ (2026-10-08) |
| Q-16 | ¿Cómo se elige el objetivo? | **Tocar o hacer clic en el objeto** abre un panel con el costo, el tiempo, la recompensa ("1 recurso", "Pieza de la Disruptora: pendiente" o "ya recuperada") y el botón **Demoler**. Los removibles tienen una **marca visual** que los distingue de lo permanente. | ✔ (2026-10-08) |
| Q-17 | ¿Se puede demoler algo sobre el camino o abrir atajos? | **No** (es la primera versión del 07). Solo se despejan casillas laterales para construir. | ✔ (2026-10-08) |

## C. Recursos y extracción (07 §6 y §7)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-18 | Árbol y roca "pueden entregar 1 recurso", pero los recursos tienen que tener uso donde aparecen. ¿Qué hacemos en los niveles 6 a 9? | **La recompensa es un dato de cada objeto:** en los niveles 6 a 9 los removibles **no dan recursos** (solo abren casillas). Desde el 10, junto con el primer uso, dan 1. | ✎ (2026-10-08): los recursos empiezan a caer **desde el nivel 7**, y no desde el 10. Caen **al azar con la semilla del mapa** (probabilidad por removible, en datos): es la única excepción a "sin sorteos" (Q-27), y el bot la repite con las mismas semillas. Los niveles 6 y 8 en adelante siguen la recompensa como dato de cada objeto; el 6 no da recursos. La regla del plan 08 §2.2 ("los recursos tienen uso donde aparecen") se cumple con el uso chico de Q-21: la mecánica se adelanta al 7. |
| Q-19 | ¿Cómo se habilita una mina o un bosque explotable? | **Pagando oro** (100), tocándolo como a un removible. Produce **2 recursos por oleada completada** hasta agotar su **reserva de 8**. No produce por esperar. Mina y bosque funcionan igual y cambia el dibujo. | ✔ (2026-10-08) |
| Q-20 | ¿Cuántos puntos de extracción activos a la vez? | **Sin límite** (lo limita el oro). Es lo más simple. | ✔ (2026-10-08) |
| Q-21 | ¿Cuál es el **primer uso** de los recursos (nivel 10)? | **El Mortero cuesta oro y recursos** (300 de oro + 3 recursos): es el "mejor cañón" del 07 §6. Desde el 11 también la Disruptora. | ✎ (2026-10-08): el Mortero cuesta oro y recursos (300 + 3, valores iniciales) y **debuta en el nivel 9** (enmienda RF-300, que lo reservaba para el 10). **Uso chico previo (nuevo):** el Francotirador se puede comprar **de dos formas en la misma partida: 150 de oro, o 120 de oro + 1 recurso**; en los mapas sin recursos la segunda opción queda deshabilitada. Nunca es indispensable para ganar. Con 1 recurso, la venta devuelve 0 (70 % redondeado hacia abajo, Q-23). Los precios los ajusta el bot. |
| Q-22 | ¿Las **mejoras** de torres avanzadas cuestan recursos? | **No**, solo construirlas. Menos reglas. | ✔ (2026-10-08) |
| Q-23 | Al vender una torre que costó recursos, ¿se devuelven? | **Sí, con el mismo % que el oro (70 %), redondeado hacia abajo.** | ✔ (2026-10-08) |
| Q-24 | Los recursos que sobran al ganar, ¿dan puntaje? | **No.** Son locales y se pierden (07 §7). El puntaje no cambia. | ✔ (2026-10-08) |

## D. Hallazgos y colecciones (07 §8)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-25 | Colección de la Disruptora: ¿cuántas piezas y dónde? | **3 piezas fijas**, una en una ruina de cada nivel: **8, 9 y 10**. Con las 3, la Disruptora se puede construir **desde el 11**, donde el mapa la habilita. | ✔ (2026-10-08) |
| Q-26 | ¿Cuándo se confirma una pieza? | **Igual que los avances actuales (RF-359):** se recoge al terminar la demolición y se confirma al completar la oleada en curso (o la siguiente, si se demolió en preparación). Una derrota antes de confirmar, o abandonar, la pierde, y se puede rejugar. | ✔ (2026-10-08) |
| Q-27 | Una ruina cuya pieza ya recuperaste, ¿qué da? | **1 recurso** si el mapa usa recursos y nada si no. Antes de demoler, el panel dice "ya recuperada". **No hay sorteos** en la V1. | ✔ (2026-10-08) |
| Q-28 | Lanzamisiles: ¿entra en la V1? | **No: actualización posterior.** El Mortero ya cubre el ataque de área, y el 07 dice que todavía no tiene diseño cerrado. | ✔ (2026-10-08) |
| Q-29 | **Rotación:** ¿qué torres salen de la oferta en el bloque 3 (11 a 15)? | **Se retira la Básica (la Ametralladora, `basic`).** La apertura barata pasa al Hielo (75). El bot comprueba que sigue siendo viable. | ✔ (2026-10-08) |
| Q-30 | ¿Cómo se avisa qué torres hay antes de entrar? | La **tarjeta del nivel** muestra los íconos de las torres disponibles y una etiqueta **"Nueva"** en la que debuta. **No hay pantalla de mazo** (07 §4). | ✔ (2026-10-08) |
| Q-31 | En **editor, comunidad, modos y pruebas**, ¿funcionan los removibles y la extracción? | **Sí**, porque son datos del mapa. Las **piezas de colección solo salen en la campaña** (como RF-358). | ✔ (2026-10-08) |

## E. Disruptora (07 §9)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-33 | Reglas de la Disruptora. | Cada **4 s** emite un pulso en un **radio de 2,5** casillas. Los Guardianes y Curanderos alcanzados **pierden su aura 2,5 s**. Daño 5. Mejoras: radio 3 y 3,5, y supresión 3 y 3,5 s. Costo **130 de oro + 2 recursos**. **No afecta** al Chamán, al Espejo ni a otras habilidades. El Chamán la puede aturdir, como a cualquier torre. | ✔ (2026-10-08) |

## F. Campaña

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-32 | Nivel 15: ¿líder nuevo o Soberano con escolta? | **El Soberano con una escolta coordinada** (Guardián + Curandero + Chamán) en la V1. Un líder nuevo puede llegar en una actualización. | ✎ (2026-10-08): en el nivel 15 va un **jefe supremo nuevo** (no el Soberano actual), acompañado de la escolta coordinada (Guardián + Curandero + Chamán). Su diseño (función, contramedidas, vida, habilidad, textos) **no se inventa acá**: lo define la tarea T243 (📜 con compuerta para Lucas) y su arte, T244 (Codex). El Soberano (`boss.tres`) sigue como jefe de los niveles anteriores. **Resuelto el 2026-10-09 (T243): el jefe supremo es el Coloso** (concepto C), con RF-481 a RF-484 y D-092. |
| Q-34 | ¿Aprobás las **fichas de los 15 mapas** del plan 08, sección 5? | Aprobarlas como **dirección**. Cada tarea de nivel completa los detalles. | ✔ (2026-10-08) como dirección, **con el reparto nuevo** del plan 08 §5: nivel 7 suma el primer drop de recursos, el Francotirador con recurso y un primer indicio del símbolo A; nivel 8 queda con el debut del Guardián, la pieza 1/3 y la revelación del símbolo A; nivel 9 suma el debut del Mortero (más la pieza 2/3 y el Curandero); nivel 10 es la mina explotable y la pieza 3/3. |
| Q-35 | ¿Chamán (11) y Espejo (12) debutan en el bloque 3? | **Sí.** Ya están hechos y el Chamán es el "sabotaje" del lore (07 §2.5). | ✔ (2026-10-08) |
| Q-36 | Niveles 1 a 5: ¿solo decoración y textos, sin tocar casillas ni oleadas? | **Sí.** Las señales reemplazan casillas `X`, que ya estaban bloqueadas. | ✔ (2026-10-08) |
| Q-37 | ¿Asedio pasa a tener los 15 mapas? | **Sí**, al final (T235). Es solo datos. | ✔ (2026-10-08) |

## G. Arte

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-38 | ¿En qué formato van la decoración nueva (señales, removibles y minas)? | **Igual que la decoración actual del mapa:** SVG de 64 × 64 con una sombra suave en el suelo (guía §4). Así combina con el suelo, que todavía es el de antes. | ✔ (2026-10-08) |
| Q-39 | ¿Y los íconos nuevos (recurso, piezas y demoledora)? | En el estilo del **avance plateado de M37** (disco de metal), con una silueta distinta por colección. | ✔ (2026-10-08) |
| Q-40 | ¿Vale el arte provisional hecho en código hasta que se apruebe el de Codex? | **Sí**, para no frenar el código. | ✔ (2026-10-08) |
