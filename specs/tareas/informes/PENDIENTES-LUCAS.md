# Pendientes de Lucas · 2026-10-31

Un solo lugar con todo lo que espera una decisión, una validación o una edición tuya. Pensado para trabajarlo desde otra máquina: **clonás o actualizás el repo, abrís este archivo y vas completando**. Cuando termines, pasale a Claude el archivo (o pegá el contenido) y él aplica todo.

**Cómo se completa.** Marcá con `[x]` en cada casilla o escribí en la línea **Respuesta**. Lo que no toques queda como está.

Estado del repo al escribir esto: `main` incluye hasta el PR #175. No hay PRs ni agentes pendientes. Los números `T…` remiten a `specs/03-tareas.md`.

---

## A · Edición larga (lo que más destraba)

### A1 · T545 · Revisar los textos del juego, uno por uno
- **Archivo a editar:** `specs/tareas/informes/T545-decisiones-redaccion.md` (82 textos; cada uno trae el actual, opciones con casilla, `Mi redacción` y `Nota`).
- **Alternativa visual:** `art/t545-revision/opciones.html` (abrir en el navegador; trae capturas y contadores de caracteres; «Copiar mis decisiones» te da el texto para pegarle a Claude).
- **Ya decidido (no hace falta repetirlo):** `specs/tareas/informes/T545-decisiones-hallazgos.md`. Ya está cargado en el juego lo de los niveles 3, 4, 11, 12, 13, 14 y 15, los créditos y la Wiki (PR #171).
- **Cómo avanzar:** si preferís por tandas, completá diez textos y pasámelos; no hace falta terminar los 82.
- Respuesta / avance: 

### A2 · T545 · Tres propuestas que esperan tu aprobación
Archivo: `specs/tareas/informes/T545-propuestas-pendientes.md` (2 o 3 opciones por pieza, con el texto actual).

- **H1-B · El agua del oasis** (lámina 4 de la intro, artículo «El oasis», nivel 1 entrada línea 2). Elegí una opción por pieza.
  - Lámina 4: opción ____
  - Artículo «El oasis»: opción ____
  - Nivel 1, entrada: opción ____
- **H8 · «El Jefe» y «El Soberano».** Opciones en el archivo. Dos avisos del agente: usar «monstruos» rompe el vocabulario de la biblia de lore (que dice «criaturas»), y decir que nadie supo si existía «hasta el final» adelanta el desenlace en un artículo que se abre en el nivel 4.
  - Opción elegida: ____ (o tu redacción: ____)
- **H12 · Repeticiones.** (A) lugares repetidos en los niveles 2, 10, 12 y 15; (B) apertura «X asegurado/a» de las victorias 1, 2, 3, 6, 8, 9, 10, 12 y 13.
  - A: opción ____
  - B: opción ____ (o tus aperturas: ____)

---

## B · Validaciones rápidas (minutos)

### B1 · T267 · ¿El arte de los niveles 1, 14 y 15 cierra para la V1?
- **Qué mirar:** `art/t267-comparacion/revision.html` (antes/después con control deslizante; está generado con `main` posterior a T549).
- [ ] Cierra. Marcá T267 como hecha.
- [ ] Ajustar, y la pieza es: ____
- Respuesta: 

### B2 · T532 · Brillo y saturación de las franjas laterales
- **Qué mirar:** jugá un nivel en una pantalla ancha (relación mayor a 16:9) y mirá las franjas a los costados del mapa.
- Hoy: brillo 0,55 y saturación 0,6, en `data/ui/presentation_backgrounds.json` (`franjas`).
- [ ] Están bien. Cerrar T532.
- [ ] Más oscuras / menos saturadas: brillo ____ saturación ____
- [ ] Más claras / más saturadas: brillo ____ saturación ____
- Capturas existentes: `art/t532-franjas/` (faltan pradera, bosque, ruinas y pantano).

### B3 · T216 · Arte de la Disruptora
- **Qué mirar:** `art/m51-disruptora/` (arte provisional, ya en partida).
- [ ] Aprobado tal cual. Después se conectan o se descartan el ícono de supresión, sus tres arcos y el anillo de pulso.
- [ ] Rehacer. Qué no te gusta: ____
- Respuesta: 

---

## C · Decisiones de sí o no

### C1 · Editor de mapas que se pasa del ancho (idea de Claude, no implementada)
«Salir» y «Rehacer» quedan unos 35 px fuera de 1280 px en español (en inglés se pasa menos).
- [ ] Sí, que lo arregle (una tarea chica).
- [ ] No, dejarlo.

### C2 · Inglés de los mensajes de datos de desarrollo (T534)
199 mensajes en 13 archivos que solo salen por consola y en tests (tutorial, intro, consejos, novedades, Wiki, créditos y configuraciones). Hoy quedan en español.
- [ ] Dejarlos en español (recomendado).
- [ ] Traducirlos en una tanda aparte.

### C3 · Selector de idioma (T534)
`Localization.SELECTOR_ENABLED` está en `false`. Falta el Lore en inglés (unos 130 textos, que se traducen después de A1 y A2 y los aprobás vos).
- [ ] Habilitarlo recién cuando el Lore esté traducido y aprobado.
- [ ] Habilitarlo antes de la V1 con el Lore en español en modo inglés (excepción conocida).
- [ ] No habilitarlo en la V1.

### C4 · Publicación de la V1 (T268 y T239)
No se genera build ni versión hasta que lo digas.
- Fecha o condición para publicar: 

---

## D · Con celular real o con tus partidas (post-V1 o cuando puedas)
- **T454 y T364:** probar en un dispositivo real.
- **T226, T238, T280, T283 y T453:** tus partidas (niveles 6 a 10, 1 a 15 con guardado nuevo, 2 y 7, y 9 con el Mortero). La sesión está preparada en `T453`.
- **T266:** validar la progresión de dificultad.

## E · En espera, sin acción tuya ahora
- **T463:** fondo del Coloso integrado; queda abierta por T367 (estilo de la ilustración quieta).
- **T367 y T369:** ilustración y presentación nuevas.
- **T479:** láminas rotativas en la carga, bloqueada.
- **T128:** tema y leyenda en el editor de mapas, diferida.
- **T218, T219, T220 y T221:** arte parcial (señales, removibles, mina y bosque, íconos).

## E · M89, mejoras de celular (2026-11-02)

- [ ] **PR de T562:** revisar los valores propuestos en la spec M89 y mergear. Ese merge es el OK para arrancar al coordinador (`specs/tareas/M89-orquestacion.md`).
- [ ] **T575:** elegir cómo quedan recursos, agua y estandartes cuando esté el informe. Hasta entonces, T576 y T577 esperan.

## F · M89, lista para probar en el teléfono (T579, 2026-11-03)

Todo M89 está hecho y probado **solo en la computadora**: tests, y capturas reales del celular simulado en 16:9 (1280 × 720) y 20:9 (1600 × 720) en `Capturas/T5xx-*.png`. **Nada de esto se vio en un teléfono**: tamaño físico, pulgar, muesca, barra de gestos, sol y rendimiento son lo que probás vos. Marcá cada casilla y, si algo falla, anotá qué pasó. Informe completo: `specs/tareas/informes/T579-revision-m89.md`.

**Antes de empezar:** instalá el APK (si hay: ver el informe), abrí **Opciones → Interfaz → Celular** si el aparato no se detecta solo, y empezá por el nivel 1. Probá en el teléfono horizontal.

### F1 · Pinza y zoom hasta 2,0 (RF-731)
- [ ] **Qué hacer:** en el nivel 2 pinzá hacia afuera hasta el tope. **Debería pasar:** el mapa se acerca mucho más que antes (casilla de unos 128 px virtuales), se ve nítido y un toque sigue eligiendo la casilla que está bajo el dedo.
- [ ] **Qué hacer:** pinzá hacia adentro. **Debería pasar:** vuelve al encuadre completo y aparece la lupa «Ver todo» mientras haya zoom.

### F2 · Un dedo mueve el mapa (RF-732)
- [ ] **Qué hacer:** con zoom, sin torre ni carrito, arrastrá un dedo por el mapa. **Debería pasar:** el mapa sigue al dedo, no se elige ni suelta nada y se llega a las cuatro esquinas sin que las barras las tapen.
- [ ] **Qué hacer:** con un fantasma de torre puesto, arrastrá. **Debería pasar:** mueve el fantasma, no el mapa.
- [ ] **Qué hacer:** con el zoom mínimo, arrastrá un dedo. **Debería pasar:** no se mueve nada.

### F3 · Rieles con los pulgares (RF-733, RF-734)
- [ ] **Qué hacer:** jugá un rato sosteniendo el teléfono con los dos pulgares. **Debería pasar:** a la izquierda alcanzás «Menú», «+», «−», la lupa y «Vender»; a la derecha, el carrito y «Demoler» (en los niveles con infraestructura). Ningún botón se siente chico ni cuesta acertarlo (¿llegan a 6 mm?).
- [ ] **Qué hacer:** tocá «+» y «−» varias veces. **Debería pasar:** el zoom sube y baja de a pasos y el botón se apaga en cada tope.
- [ ] **Qué hacer:** tocá la parte vacía del riel. **Debería pasar:** nada.
- [ ] **Qué hacer:** con un teléfono 16:9 (si tenés otro) o girando la ventana. **Debería pasar:** sin franjas no hay rieles y los botones están dentro del mapa como antes.

### F4 · Muesca y barra de gestos
- [ ] **Qué hacer:** mirá los rieles con la muesca (cámara) a un lado y luego al otro (girando el teléfono 180°). **Debería pasar:** ningún botón queda tapado ni debajo de la muesca.
- [ ] **Qué hacer:** con los botones de Android o con la barra de gestos, tocá «Vender» (abajo a la izquierda). **Debería pasar:** no se activa el gesto de Android ni cuesta tocarlo.

### F5 · «Menú» en lugar de la X (RF-735)
- [ ] **Qué hacer:** tocá «Menú». **Debería pasar:** se ve el menú de pausa (Continuar, Reintentar, Opciones, Salir) y Opciones se abre desde ahí.
- [ ] **Qué hacer:** «Salir». **Debería pasar:** pide confirmación y dice qué se pierde; «Seguir jugando» vuelve al menú de pausa.

### F6 · Barra de la torre y «Vender» (RF-736, RF-737)
- [ ] **Qué hacer:** elegí una torre ya puesta. **Debería pasar:** la × está pegada al borde izquierdo y la torre elegida lleva las esquinas amarillas con un pulso suave; el Mortero (2 × 2) la lleva sobre sus cuatro casillas.
- [ ] **Qué hacer:** probá la marca **a pleno sol**. **Debería pasar:** se distingue de las demás torres y del círculo de alcance. Si no, anotá cuánto contraste falta (los colores están en `data/ui/mobile_ui.json`).
- [ ] **Qué hacer:** tocá «Vender» una vez, esperá 3 s, y otra vez dos veces seguidas. **Debería pasar:** el primer toque arma, a los 3 s se desarma, y el segundo toque vende. **Nunca** se vende con un solo toque ni al tocar «Empezar oleada».

### F7 · Llega el jefe (RF-738)
- [ ] **Qué hacer:** jugá hasta la primera oleada con jefe (un nivel de campaña). **Debería pasar:** la pantalla se cubre entera, sin franjas del terreno a los costados, el texto se lee y entra, el rótulo no se corta. Un toque o esperar la cierra y el fondo del terreno vuelve. **Mirá:** que no se vea pixelado.

### F8 · Doble toque (RF-740)
- [ ] **Qué hacer:** tocá dos veces seguidas una casilla de pasto vacía. **Debería pasar:** se abre el catálogo del carrito y no se cobra nada.
- [ ] **Qué hacer:** con zoom, movés el mapa y tocás dos veces. **Debería pasar:** funciona igual y no abre nada si los dos toques caen en casillas distintas.
- [ ] **Qué hacer:** doble toque sobre el camino, sobre una torre o con el fantasma puesto. **Debería pasar:** en el camino y en la torre no abre nada; con el fantasma confirma la compra.

### F9 · Tutorial (RF-739)
- [ ] **Qué hacer:** «Volver a verlo» y recorré todo el tutorial del nivel 1. **Debería pasar:** en cada paso de acción se oscurece todo menos lo señalado y un anillo se expande con «Tocá acá». El toque sobre lo señalado funciona.
- [ ] **Qué hacer:** en el paso del carrito (que está en el riel). **Debería pasar:** el anillo se ve sobre el botón del riel y los demás botones se apagan. **Mirá:** que el rótulo «Tocá acá» no tape «Pausa» (en nuestras capturas 20:9 lo toca un poco).
- [ ] **Qué hacer:** ¿te cansa o te ayuda el anillo? Anotá si preferís el parpadeo anterior (T574 no pudo elegir).

### F10 · Cuadrícula y Ráfaga (RF-741, RF-742)
- [ ] **Qué hacer:** Opciones → Partida y ayudas → «Cuadrícula marcada». **Debería pasar:** se ven las líneas de todas las casillas, también con zoom, y se aplica en el acto. (T579 corrigió un error que la rompía al dibujar.)
- [ ] **Qué hacer:** jugá con la Ráfaga y mejorala. **Debería pasar:** dispara notablemente más rápido en el nivel 2 y en el 3 (1,1 y 1,4 por segundo) y el panel lo anuncia.

### F11 · Rendimiento con zoom
- [ ] **Qué hacer:** en el nivel 15 (o el más grande) jugá con zoom 2,0 y una oleada fuerte, a ×2. **Debería pasar:** sin tirones. Anotá el modelo del teléfono y si se traba.

### F12 · Lo que dejó el celular simulado sin resolver
- [ ] **Rótulo «Tocá acá» y «Pausa» (20:9):** el rótulo del carrito se superpone con «Pausa». ¿Molesta?
- [ ] **«Acercaste el mapa» sin fondo:** el aviso queda pegado a la barra de arriba, sobre el pasto. ¿Se lee?
- [ ] **Caminata a la izquierda (T572):** mirá un nivel donde los enemigos vayan hacia la izquierda. ¿Se ven rotos o solo distintos? (El informe de T572 midió las hojas y no vio un error de código; no se vio en partida.)

### F13 · Lo que espera una decisión tuya
- [ ] **T575:** elegir recursos, agua y estandartes (`specs/tareas/informes/T575-mecanicas-y-agua.md`). Hasta que elijas, T576 (tutorial con todas las mecánicas) y T577 (agua como recurso) esperan.
- [ ] **Arte de T572 y T367:** no se produjo ni se aprobó arte nuevo (caminata a la izquierda; ilustración de los jefes).
- [ ] **B-64:** ¿mapas más largos para el celular? Recomendación: no por ahora (D-224).
- [ ] **T578:** PvP por red local, solo investigado: el informe recomienda posponerlo (`specs/tareas/informes/T578-investigacion-pvp-lan.md`).
- [ ] **PR de `feature/m89-integracion` a `main`:** lo mergeás vos.

## G · Ideas de Lucas registradas en el backlog

- [ ] **B-65 / T580:** investigación de la carrera PvP entre niveles, post-V1 y de prioridad baja; revisar el informe cuando exista.
- [ ] **B-66:** definir el enemigo que congela torres en una zona y sus contramedidas.
- [ ] **B-67 / T575:** elegir la economía de recursos, incluidas las nuevas ideas y su relación con Q-22, dentro de T575.
- [ ] **B-68 / T575:** elegir el futuro de los Estandartes y torres de apoyo, considerando V2 y 3D.
- [ ] **B-69:** decidir si «Reintentar» pide confirmación desde pausa y desde el fin de partida.
