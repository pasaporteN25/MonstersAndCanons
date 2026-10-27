# T521 · Reorientar el README hacia el juego

**Pedido:** Lucas, 2026-10-26. **Tipo:** documental.

## Objetivo

Presentar Monsters & Canons a quienes quieren conocer el juego: su propuesta, campaña, modos y posibilidades. Dejar la información técnica en una sección posterior y acompañar la explicación con capturas existentes.

## Alcance

- Reescribir la estructura y los textos de `README.md` en español rioplatense.
- Priorizar la experiencia de juego y describir con precisión el estado actual, sin dar a entender que ya hay una versión publicada o certificada.
- Incluir capturas versionadas de una partida y del selector en PC y celular simulado.
- Mantener enlaces útiles a la guía de instalación, contenido y licencia; mover la información de desarrollo a la parte técnica.
- Registrar la tarea en `specs/03-tareas.md`.

## Hecho cuando

- El contenido de juego precede a la información técnica y al proceso de desarrollo.
- Las capturas existen en el repositorio y los enlaces relativos se resuelven desde GitHub.
- El README aclara que la simulación móvil no reemplaza una prueba en teléfono físico.
- `git diff --check` pasa.

## Resultado

**Resultado (2026-10-26):** el README ahora presenta el juego y sus posibilidades antes de la información técnica; incorpora capturas existentes de la preparación de una partida y del selector de campaña en PC y celular simulado. Conserva los enlaces de instalación, contenido, licencia y desarrollo, y aclara que no hay descarga pública ni validación en teléfono real. `git diff --check` pasó. No se corrieron Godot/GUT porque no se modificó el juego.
