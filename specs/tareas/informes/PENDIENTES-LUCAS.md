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
