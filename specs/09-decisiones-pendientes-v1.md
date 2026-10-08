# 09 — Decisiones pendientes para cerrar la V1 (cuestionario para Lucas)

Fecha: 2026-10-07. Es la tarea **T200** del [plan 08](08-plan-cierre-v1.md) y la compuerta **G1**: sin estas respuestas no arranca ninguna tarea de spec.

**Cómo responder:** cada pregunta trae la **recomendación de Claude**. Alcanza con escribir en tu respuesta, por ejemplo, *"Acepto todas salvo Q-07 (no) y Q-29 (retirar también la Ráfaga)"*. En las preguntas abiertas (Q-03) hace falta tu texto. Después, la tarea T205 o T227 las pasa a decisiones `D-0xx` con la fecha de tu respuesta.

Los **valores numéricos** de las recomendaciones son **iniciales**: viven en datos y se ajustan con el bot (T214) y con tus partidas. Lo que se decide acá es la **regla**.

Columna "Tu respuesta": ✔ acepto · ✘ no · ✎ cambio (escribir cuál).

---

## A. Alcance y marco

| # | Pregunta | Recomendación de Claude | Tu respuesta |
|---|---|---|---|
| Q-01 | §11 de la spec excluye **"Historia, diálogos o cinemáticas"**. El 07 pide textos, epílogo e intro. ¿Se enmienda §11? | **Sí, de forma acotada.** Se permiten textos breves por nivel (entrada de hasta 3 líneas y victoria de hasta 2), una categoría Lore en la Wiki, un epílogo en la victoria del 15 y una intro de láminas que se pueda omitir y volver a ver. **Siguen excluidos:** diálogos entre personajes, cinemáticas animadas y voces. | |
| Q-02 | ¿"Base para la franquicia" es lo de la sección 3 del plan 08 (biblia, glosario, lore en el juego, marca y datos reutilizables)? | **Sí.** No incluye preparar código para el 3D. | |
| Q-03 | Nombres del **planeta**, de la **expedición o colonia** y de las **comunidades locales**. | Que T201 proponga **3 opciones de cada uno** y vos elijas en G2. Si ya tenés nombres, escribilos acá. | |
| Q-04 | El ejecutable, el paquete Android (`com.juegoa.towerdefense`) y la ventana dicen **"JuegoA"**. ¿Se pasan a la marca? | **Sí:** `MonstersCanons.exe` / `.x86_64` / `.apk`, ventana "Monsters & Canons" y un paquete nuevo (por ejemplo `com.monsterscanons.v1`). La APK que tenés instalada quedaría como otra app. | |
| Q-05 | ¿Dónde se publica y cómo se ofrece el código fuente (GPL, D-077)? | **itch.io gratis**, y el **repositorio público** con una etiqueta `v1.0` al publicar. Play Store queda para después. | |
| Q-06 | El documento 06 pedía hacer **B-14 (tipos de daño), B-23 (recetas de vecindad), B-08 (terrenos con efecto) y B-09 (puentes)** antes de los niveles 10 a 15. ¿Entran en la V1? | **No: después de la entrega**, como actualizaciones. Los sistemas del 07 ya son bastante. Si alguno entra, tiene que ir **antes** de T223 para no balancear dos veces. | |
| Q-07 | Aprobar la sugerencia "**bot de balance repetible**" (§13, Sugerencias de Claude), ampliada a varias semillas. | **Sí.** Es la herramienta para demostrar "se gana sin recursos". | |

## B. Demolición y demoledora (07 §5)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-08 | ¿La demoledora es un **botón en un panel global del HUD** o una **estructura en una casilla**? | **Botón global** ("Infraestructura"). Ya está acordado que su descuento vale para todo el mapa; así no ocupa casillas y en el mapa solo se ve una animación de trabajo sobre el objeto. | |
| Q-09 | ¿Precio **uniforme** o **por clase** de objeto? | **Por clase**, en datos: árbol 40, roca 60 y escombro de ruina 90 de oro (valores iniciales). | |
| Q-10 | ¿Duración uniforme o por clase? ¿La máquina baja también el tiempo? | **Por clase:** árbol 4 s, roca 6 s y escombro 10 s de juego. **La máquina solo baja el precio.** | |
| Q-11 | ¿Se cobra al ordenar o al terminar? | **Al ordenar.** Así no se puede quedar sin oro a mitad de un trabajo. | |
| Q-12 | ¿Se puede cancelar? | **Sí, con reembolso total**, y el objeto queda como estaba. No da ganancia, porque la recompensa llega recién al terminar. | |
| Q-13 | ¿Se vende la máquina? | **No.** Evita ganar plata comprándola y vendiéndola. Precio: 3 × el de la roca (180) y uso a 10 % del precio de cada objeto (mínimo 5). | |
| Q-14 | ¿Qué pasa con un trabajo en curso al terminar una oleada o la partida? | **Al terminar la oleada sigue**, porque se demuele en preparación y durante las oleadas. **Al terminar la partida** (victoria, derrota o abandono) se pierde y no entrega nada. | |
| Q-15 | ¿Hay cola de órdenes? | **No.** Mientras hay un trabajo activo, los demás removibles muestran "Hay una demolición en curso". | |
| Q-16 | ¿Cómo se elige el objetivo? | **Tocar o hacer clic en el objeto** abre un panel con el costo, el tiempo, la recompensa ("1 recurso", "Pieza de la Disruptora: pendiente" o "ya recuperada") y el botón **Demoler**. Los removibles tienen una **marca visual** que los distingue de lo permanente. | |
| Q-17 | ¿Se puede demoler algo sobre el camino o abrir atajos? | **No** (es la primera versión del 07). Solo se despejan casillas laterales para construir. | |

## C. Recursos y extracción (07 §6 y §7)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-18 | Árbol y roca "pueden entregar 1 recurso", pero los recursos tienen que tener uso donde aparecen. ¿Qué hacemos en los niveles 6 a 9? | **La recompensa es un dato de cada objeto:** en los niveles 6 a 9 los removibles **no dan recursos** (solo abren casillas). Desde el 10, junto con el primer uso, dan 1. | |
| Q-19 | ¿Cómo se habilita una mina o un bosque explotable? | **Pagando oro** (100), tocándolo como a un removible. Produce **2 recursos por oleada completada** hasta agotar su **reserva de 8**. No produce por esperar. Mina y bosque funcionan igual y cambia el dibujo. | |
| Q-20 | ¿Cuántos puntos de extracción activos a la vez? | **Sin límite** (lo limita el oro). Es lo más simple. | |
| Q-21 | ¿Cuál es el **primer uso** de los recursos (nivel 10)? | **El Mortero cuesta oro y recursos** (300 de oro + 3 recursos): es el "mejor cañón" del 07 §6. Desde el 11 también la Disruptora. | |
| Q-22 | ¿Las **mejoras** de torres avanzadas cuestan recursos? | **No**, solo construirlas. Menos reglas. | |
| Q-23 | Al vender una torre que costó recursos, ¿se devuelven? | **Sí, con el mismo % que el oro (70 %), redondeado hacia abajo.** | |
| Q-24 | Los recursos que sobran al ganar, ¿dan puntaje? | **No.** Son locales y se pierden (07 §7). El puntaje no cambia. | |

## D. Hallazgos y colecciones (07 §8)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-25 | Colección de la Disruptora: ¿cuántas piezas y dónde? | **3 piezas fijas**, una en una ruina de cada nivel: **8, 9 y 10**. Con las 3, la Disruptora se puede construir **desde el 11**, donde el mapa la habilita. | |
| Q-26 | ¿Cuándo se confirma una pieza? | **Igual que los avances actuales (RF-359):** se recoge al terminar la demolición y se confirma al completar la oleada en curso (o la siguiente, si se demolió en preparación). Una derrota antes de confirmar, o abandonar, la pierde, y se puede rejugar. | |
| Q-27 | Una ruina cuya pieza ya recuperaste, ¿qué da? | **1 recurso** si el mapa usa recursos y nada si no. Antes de demoler, el panel dice "ya recuperada". **No hay sorteos** en la V1. | |
| Q-28 | Lanzamisiles: ¿entra en la V1? | **No: actualización posterior.** El Mortero ya cubre el ataque de área, y el 07 dice que todavía no tiene diseño cerrado. | |
| Q-29 | **Rotación:** ¿qué torres salen de la oferta en el bloque 3 (11 a 15)? | **Se retira la Básica.** La apertura barata pasa al Hielo (75). El bot comprueba que sigue siendo viable. | |
| Q-30 | ¿Cómo se avisa qué torres hay antes de entrar? | La **tarjeta del nivel** muestra los íconos de las torres disponibles y una etiqueta **"Nueva"** en la que debuta. **No hay pantalla de mazo** (07 §4). | |
| Q-31 | En **editor, comunidad, modos y pruebas**, ¿funcionan los removibles y la extracción? | **Sí**, porque son datos del mapa. Las **piezas de colección solo salen en la campaña** (como RF-358). | |

## E. Disruptora (07 §9)

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-33 | Reglas de la Disruptora. | Cada **4 s** emite un pulso en un **radio de 2,5** casillas. Los Guardianes y Curanderos alcanzados **pierden su aura 2,5 s**. Daño 5. Mejoras: radio 3 y 3,5, y supresión 3 y 3,5 s. Costo **130 de oro + 2 recursos**. **No afecta** al Chamán, al Espejo ni a otras habilidades. El Chamán la puede aturdir, como a cualquier torre. | |

## F. Campaña

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-32 | Nivel 15: ¿líder nuevo o Soberano con escolta? | **El Soberano con una escolta coordinada** (Guardián + Curandero + Chamán) en la V1. Un líder nuevo puede llegar en una actualización. | |
| Q-34 | ¿Aprobás las **fichas de los 15 mapas** del plan 08, sección 5? | Aprobarlas como **dirección**. Cada tarea de nivel completa los detalles. | |
| Q-35 | ¿Chamán (11) y Espejo (12) debutan en el bloque 3? | **Sí.** Ya están hechos y el Chamán es el "sabotaje" del lore (07 §2.5). | |
| Q-36 | Niveles 1 a 5: ¿solo decoración y textos, sin tocar casillas ni oleadas? | **Sí.** Las señales reemplazan casillas `X`, que ya estaban bloqueadas. | |
| Q-37 | ¿Asedio pasa a tener los 15 mapas? | **Sí**, al final (T235). Es solo datos. | |

## G. Arte

| # | Pregunta | Recomendación | Tu respuesta |
|---|---|---|---|
| Q-38 | ¿En qué formato van la decoración nueva (señales, removibles y minas)? | **Igual que la decoración actual del mapa:** SVG de 64 × 64 con una sombra suave en el suelo (guía §4). Así combina con el suelo, que todavía es el de antes. | |
| Q-39 | ¿Y los íconos nuevos (recurso, piezas y demoledora)? | En el estilo del **avance plateado de M37** (disco de metal), con una silueta distinta por colección. | |
| Q-40 | ¿Vale el arte provisional hecho en código hasta que se apruebe el de Codex? | **Sí**, para no frenar el código. | |
