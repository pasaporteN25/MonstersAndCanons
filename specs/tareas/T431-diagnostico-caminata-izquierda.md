# T431 · Diagnóstico de la caminata hacia la izquierda

- **Ejecutor:** Codex · esfuerzo medio
- **Depende de:** inventario de enemigos y atlas de movimiento · **Compuerta:** Lucas elige antes de producir vistas/ciclos nuevos
- **Tamaño:** chico

## Leer
Guía de arte, D-049, tareas de arte y recursos activos en `assets/sprites/enemies/rendered/`.

## Objetivo
Identificar qué personajes se ven peor al caminar hacia la izquierda y recomendar una solución de bajo costo.

## Alcance
Comparar los ciclos actuales en ambas direcciones a tamaño nativo y de juego; revisar orientación de luz, silueta, anclaje y continuidad de pasos. Comparar conservar el comportamiento, ajustar la animación existente o producir una vista lateral propia. Estimar tiempo de arte, cantidad de cuadros y peso/importación.

## Hecho cuando
Informe con personajes concretos, comparaciones, opciones/costos, límites y recomendación. No se cambia ningún sprite ni escena en esta tarea.

## Resultado (2026-10-21)
El informe [`T431-diagnostico-caminata-izquierda.md`](informes/T431-diagnostico-caminata-izquierda.md) identifica siete candidatos prioritarios y dos secundarios; la secuencia de cuadros se ve continua en las hojas revisadas. El proyecto usa filas de orientación izquierda propias, no espejo. Se preparó `art/t431-diagnostico/comparison.html` con 18 atlas activos, sin duplicar PNGs ni tocar producción. Claude Opus hizo la lectura visual; Codex confirmó el selector de filas y la regla del espejo en código. No se abrió una partida, no hubo medición de contornos ni se cambiaron sprites. `git diff --check` pasó.
