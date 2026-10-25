# T487 · Modelo puro del descubrimiento por zonas

- **Ejecutor:** Sonnet · lógica y tests.
- **Depende de / compuerta:** 🚦 **T486 aprobada por Lucas**. **No empezar sin ese OK.**
- **Refs:** RF-709, RF-710, RF-711, D-209. **Rama:** `feature/t487-modelo-descubrimiento`, desde `origin/main` actualizado; un commit `T487: …`, PR a main.

## Leer

Reglas `.claude/rules/gdscript.md` y `tests.md`, M78 (spec y plan), `scripts/logic/campaign_map.gd`, `tests/test_campaign_map.gd`.

## Objetivo y alcance

Función estática pura que, dados los 15 `unlocked`, devuelve la zona descubierta de cada región y qué regiones admiten foco/selección. Límites 6 y 11 como constantes. No guarda nada ni toca `SaveManager`.

## Archivos previstos

`scripts/logic/campaign_map.gd` y su test. Si T471 lo está editando, usar un archivo de modelo aparte (propietario único).

## Hecho cuando

Tests de los tres casos de RF-709, guardado raro (11 abierto y 6 cerrado), `unlocked` dañado, modo de pruebas e inmutabilidad de `unlocked`. GUT completo sin `SCRIPT ERROR`; `.uid` del test versionado.

## Frenar si

Falta el OK de la spec; T471 edita el mismo archivo; hay que guardar una marca nueva.
