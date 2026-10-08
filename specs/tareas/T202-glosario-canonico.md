# T202 · Auditoría de nombres y propuesta de glosario canónico

- **Ejecutor:** Sonnet 5.5 · esfuerzo **bajo**
- **Depende de:** nada (**puede arrancar ya**) · **Compuerta:** ninguna para el informe; Lucas elige en G2, junto con T201 · **Tamaño:** chico

## Leer
`specs/05-guia-de-arte.md` (§3, §7, §8 y §M43), los `name`/`display_name` de `data/towers/*.tres` y `data/enemies/*.tres`, los artículos de `data/wiki/*.json`, los textos de la Wiki que arma `scripts/logic/wiki.gd` y `CONTENIDO.md`.

## Objetivo
Un **informe** en `specs/tareas/informes/T202-glosario.md` que liste, para cada torre, enemigo, tema de mapa y concepto (avance, colección, Estandarte, Mecánico…):

| Id en código | Nombre en el juego (lo que ve el jugador) | Otros nombres encontrados (archivo:línea) | Propuesta de nombre canónico | Motivo |
|---|---|---|---|---|

## Pasos
1. Recorrer los archivos de arriba y anotar **cada nombre distinto** que aparece para la misma cosa. Ejemplo conocido: el Normal es "lobo de ceniza" en la guía §3 y "diablillo rojo" en M24 y M43.
2. Marcar dónde el **dibujo actual** ya no coincide con la descripción escrita (por ejemplo, una especie que cambió de aspecto en M24 o M43).
3. Proponer **un** nombre canónico por cosa: el que ve hoy el jugador, salvo que choque con el lore del 07.
4. Al final, una lista de los **archivos que habría que cambiar** si Lucas aprueba el glosario. **No cambiarlos en esta tarea.**

## Hecho cuando
- El informe existe, con la tabla completa (10 torres, 15 enemigos, 7 temas y los conceptos).
- La entrada de T202 en `03-tareas.md` está completa.
- Commit `T202: …` (solo documentación; los tests no hace falta correrlos).

## Frenar si
Nunca hace falta: es un informe. Las dudas van como preguntas dentro del informe.
