# T576 · Tutorial del nivel 1 con todas las mecánicas elegidas

- Ejecutor · Sonnet · esfuerzo medio
- Depende de · T574 y T575 con OK de Lucas · Compuerta · 🚦 · Tamaño · Se fija en T575

> **Ficha incompleta a propósito.** T575 la completa con los `RF` y los pasos que elija Lucas. Sin eso, no empezar.

## Leer

La elección registrada en T575 y sus `RF`. `specs/01-spec.md`: RF-574 a RF-577 y RF-739. `data/tutorial/tutorial.json`, `scenes/game/tutorial_controller.gd`, `scripts/logic/tutorial_flow.gd`, `tests/test_tutorial_*.gd`.

## Objetivo

Que el primer nivel enseñe lo que Lucas decidió, en la PC y en el celular.

## Alcance

**Sí:** lo que fije T575. Se esperan los pasos en `data/tutorial/tutorial.json` y sus textos en los dos idiomas, el controlador, tests y `CHANGELOG.md`.

**No:** lo que T575 deje para otro nivel, para la parte 2 o para la 3D.

## Hecho cuando

El tutorial enseña lo elegido en PC y celular y se completa de punta a punta. Saltarlo y volver a verlo sigue funcionando (RF-576). El nivel 1 se sigue ganando con el bot. Hay capturas de los pasos nuevos.

## Verificación

Suite completa sin `SCRIPT ERROR`. **No se puede probar acá:** si alguien nuevo lo entiende.

## Frenar si

La ficha no fue completada por T575.
