# T563 · Ráfaga: más cadencia al mejorar

- Ejecutor · Haiku · esfuerzo alto
- Depende de · nada · Compuerta · ninguna · Tamaño · Chico

## Leer

`specs/01-spec.md`: RF-742 y RF-162. `specs/04-decisiones.md`: D-228. `.claude/rules/datos.md`. El encabezado de `tools/balance_sim.gd`.

## Objetivo

Que mejorar la Ráfaga se note: cadencia 0,8 / 1,1 / 1,4.

## Alcance

**Sí:** `data/towers/burst.tres` (solo `fire_rate` de los niveles 2 y 3), `tests/test_new_content.gd:328-330`, otros tests que fijen esos números y `CHANGELOG.md`.

**No:** daño, púas, alcance, costos ni otra torre.

## Pasos

1. Correr el bot `mix` en todos los niveles que soporte **antes** de cambiar nada y guardar el resultado.
2. Cambiar `fire_rate = 0.9` por `1.1` y `fire_rate = 1.0` por `1.4` en `burst.tres`.
3. Actualizar los tests que fallen por esos números, solo en los valores.
4. Correr el bot otra vez con los mismos parámetros y comparar.
5. Anotar los dos resultados en el Resultado de `specs/03-tareas.md`.

## Hecho cuando

`burst.tres` tiene 0,8 / 1,1 / 1,4. El panel de mejora y la Wiki muestran los valores nuevos sin tocar su código. Los tests pasan. La comparación del bot está en el Resultado.

## Verificación

Suite completa sin `SCRIPT ERROR`. `--import` no debe dejar SVG cambiados: revisar `git status`.

## Frenar si

El bot pierde un nivel que antes ganaba, o la Ráfaga pasa a ganar sola un nivel que antes no ganaba. No ajustar otros números: avisar con los resultados.
