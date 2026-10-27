# T528 · Registrar el nuevo orden de cierre y las pruebas post-V1

- **Ejecutor:** Codex · **Tipo:** documental · **Depende de:** respuesta explícita de Lucas del 2026-10-27 · **Tamaño:** mediano
- **Refs:** decisión D-216; T226, T238, T239, T266, T268, T280, T283, T453; plan `08-plan-cierre-v1.md`.

## Objetivo

Separar la publicación de V1 de las partidas humanas de campaña, según lo que decidió Lucas, y conservar todas las tareas diferidas como trabajo posterior con estado claro.

## Alcance

- Registrar D-216 y actualizar el orden y el resumen de cierre en `03-tareas.md` y `08-plan-cierre-v1.md`.
- Poner T280, T226, T283, T453 y T238 en la lista post-V1, sin marcar pruebas como hechas.
- Dejar T266 pendiente solo de su validación humana T280, sin que bloquee T239.
- Quitar T238 como dependencia de publicación T239; mantener cualquier otra dependencia de publicación (por ejemplo, T242 si la intro entra en la 1.0).
- Actualizar las instrucciones de T226, T238, T239 y T453 para reflejar que se usan después de publicar, desde guardado nuevo, y que los hallazgos se anotan para actualizaciones.
- Mantener T268 como preparación e identificación de la build, pero excluir la validación del archivo viejo del tester ya retirada; conservar el checklist de salida vigente en T375.
- Conservar como historial los pasos y resultados anteriores. No editar `01-spec.md`, reglas del juego, guardados ni tareas de arte que no sean partidas de campaña.

## Hecho cuando

- El tablero y el plan no contradicen la secuencia publicación → validación post-V1.
- T239 deja de estar condicionada por T238; T238 sigue abierta y claramente pospuesta.
- T268 sigue pendiente como preparación de build; su antigua prueba con el archivo del tester no se intenta ni se presenta como aprobada.
- Todas las partidas conservan su contenido y compuertas; ningún test humano se declara pasado.
- `git diff --check` pasa.

## Verificación

Revisión documental y búsquedas de referencias a T226/T238/T239/T266/T268/T280/T283/T453 en `03-tareas.md`, `08-plan-cierre-v1.md` y sus fichas. No se corre Godot/GUT ni se juega una partida: esta tarea solo cambia el orden documental.

## Frenar si

La versión publicada exige modificar una regla de gameplay o los artefactos de release fuera del checklist T375. Eso requiere una tarea separada.
