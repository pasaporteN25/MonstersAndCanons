# T480 · Precisar el disparador del aviso de «Ver todo»

- Ejecutor · Codex / documentación.
- Depende de · Aclaración de Lucas, recibida el 2026-10-24.
- Compuerta · Cerrada para esta decisión; no pide una partida ni un teléfono.
- Tamaño · Chico.

## Leer

- `CLAUDE.md`
- `specs/00-constitucion.md`
- `specs/01-spec.md` § M75 / RF-676
- `specs/04-decisiones.md` D-192
- `specs/02-plan-tecnico.md` M75
- `specs/03-tareas.md` T464/T480

## Objetivo

Alinear la spec, las decisiones y las guías con la aclaración de Lucas: el aviso de «Ver todo» aparece solo al acercar el mapa.

## Alcance

**Sí:** enmendar RF-676 y D-192 mediante D-207; describir el disparador igual en plan, README, CONTENIDO y ONBOARDING; registrar esta tarea en el tablero y el índice de fichas.

**No:** cambiar textos aprobados, duración, clave de guardado, comportamiento del botón de celular o código; no cerrar la aprobación de la lupa ni afirmar que T464 está integrado.

## Decisión registrada

El aviso se activa únicamente cuando aumenta el zoom. No se activa al disminuirlo ni al desplazar el mapa sin acercarlo. Si el jugador primero desplaza y luego acerca, el aviso puede aparecer si todavía no se mostró en ese guardado.

## Hecho cuando

- RF-676 y D-192 expresan el disparador anterior y el criterio Dado/Cuando/Entonces lo cubre.
- D-207 explica motivo y alternativa descartada.
- El plan, la ficha T458 y las guías no dicen que un paneo por sí solo muestre el aviso; contemplan que un acercamiento posterior lo muestre aunque el botón ya fuera visible, y no limitan el requisito a campaña.
- Existe entrada en `specs/03-tareas.md` y esta ficha aparece en `specs/tareas/README.md`.
- El diff es solo documental y `git diff --check` está limpio.

## Verificación

Revisión estática de coincidencias y `git diff --check`. No hace falta Godot/GUT.

## Frenar si

La aclaración parece afectar otra decisión funcional o requiere cambiar los textos aprobados; en ese caso registrar la nueva decisión antes de programar.
