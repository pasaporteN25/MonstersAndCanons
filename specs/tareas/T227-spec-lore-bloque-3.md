# T227 · 📜 Spec del lore dentro del juego, del bloque 3 y del final

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto** (ideal: Opus)
- **Depende de:** T201 (biblia aprobada), T226 (lo aprendido del bloque 2) y Q-01 (enmienda de §11) · **Compuerta:** Lucas da el OK a los textos y a las fichas del 11 al 15 antes de T228 y T229 · **Tamaño:** mediano · 📜

## Leer
- `specs/10-universo.md` entero.
- El 07 §2, §3 y §12, el plan 08 §5 (bloque 3) y las respuestas Q-01, Q-29, Q-32 y Q-35.
- §11 de la spec ("Qué NO incluye"), §10.5 (Wiki: RF-230 y siguientes), RF-387 (artículo de licencias, para ver cómo se agrega un artículo) y los artículos de `data/wiki/*.json`.
- El informe de T226.

## Qué tiene que quedar escrito
1. **Enmienda de §11**, con el texto exacto de Q-01:
   - "Historia, diálogos o cinemáticas" pasa a "Diálogos entre personajes, cinemáticas animadas y voces";
   - una nota que remita a la sección nueva.
   - Su D, con fecha y la cita de la respuesta de Lucas.
2. **Una sección nueva "M52 · Lore en el juego"**, con sus RF:
   - **Textos por nivel:** un campo opcional del nivel (propuesta: `"textos": {"lugar": "...", "entrada": "...", "victoria": "..."}`), con sus límites de largo. Dónde se muestran: la tarjeta de selección (lugar), la pantalla previa o el cartel al empezar (entrada) y la pantalla de victoria. Que se puedan **omitir** con un toque. Que no se muestren en los modos ni en la comunidad, **salvo que el mapa los traiga**.
   - **Categoría Lore en la Wiki:** artículos en `data/wiki/lore/` (o el formato que convenga), que se **desbloquean** al ganar ciertos niveles. Por ejemplo: "El oasis" al ganar el 1 y "Las ruinas" al ganar el 8.
   - **Epílogo:** pantalla de victoria del 15, con 3 a 5 líneas, la imagen final (T233) y "Créditos".
3. **Los textos mismos:**
   - lugar, entrada y victoria de los 15 niveles;
   - de 6 a 10 artículos de Lore;
   - el epílogo.
   Todo escrito **según la biblia** y su sección de tono, y aprobado por Lucas.
4. **Las fichas detalladas del 11 al 15** (los 9 puntos del 07 §3 cada una) como subsecciones de §7 de la spec, con su RF de campaña:
   - debuts: Chamán en el 11 y Espejo en el 12;
   - rotación (Q-29);
   - Disruptora desde el 11;
   - extracción;
   - el final del 15 (Q-32: el Soberano con escolta).
5. En `03-tareas.md`: las entradas de T228 a T235, revisando las fichas de `specs/tareas/` si algo cambió.

## Hecho cuando
- Spec, D y textos escritos, **sin código**, y Lucas aprobó los textos y las fichas (anotarlo con la fecha).
- Resultado, commit y PR.

## Frenar si
- Algún texto o ficha contradice la biblia o el 07.
