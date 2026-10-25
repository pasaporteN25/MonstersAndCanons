# T489 · 📜 Corregir en el tablero el estado del PR #22

- **Ejecutor:** Sonnet · documentos.
- **Depende de / compuerta:** ninguna. No hace falta aprobación: es registrar un hecho que Lucas ya confirmó («El 22 ya se mergeó, corregí eso»).
- **Refs:** PR #22 (M71, T410–T417), PR #52 (T452), T362, T364, T367, T369. **Rama:** `feature/t489-estado-pr22`, desde `origin/main`; un commit `T489: …`, PR a main.

## Objetivo y alcance

El PR #22 figura en GitHub como mergeado el 2026-10-23 (merge commit `aa812f1`, ancestro de `origin/main`), pero el tablero lo describía como abierto, en draft y sin merge. Corregir **solo** el estado del PR y lo que sea consecuencia verificable.

## Reglas

- Una línea que describe el estado **actual** se corrige; un «Resultado (fecha)» o un informe fechado es historia y no se reescribe (a lo sumo, una marca de corrección al lado).
- No cerrar T362, T364, T367 ni T369 por inferencia: T364 y T369 esperan la medición en PC y la prueba en teléfono real; T362 y T367 esperan el OK de Lucas.
- Donde la integración no esté comprobada contra el código de `origin/main`, escribir «mergeado; integración sin verificar».

## Verificación

`gh pr view 22`, `git merge-base --is-ancestor`, lectura de `scenes/effects/upgrade_effect.gd` y de los archivos de `assets/` y `art/`, `git diff --check`. No Godot ni tests (solo documentos).
