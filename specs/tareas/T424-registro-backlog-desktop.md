# T424 · Registrar y subdividir el pedido de mejoras desktop
- Ejecutor · Codex, documentación y orquestación
- Depende de · pedido explícito de Lucas del 2026-10-21 · Compuerta · ninguna
- Tamaño · Chico

## Objetivo
Convertir los pedidos de Lucas sobre selector, mapa planetario, panel de torre, presentación del nivel, sprites y variedad de torres en trabajo ordenado y delegable.

## Alcance
Registrar B-45 a B-49 en `specs/01-spec.md`; reflejar el avance humano 1–4 en T280; dividir el trabajo en T425–T432 y describir paralelismo seguro en `specs/08-plan-cierre-v1.md`. El código y los assets de producción quedan intactos.

## Hecho cuando
Las ideas, límites desktop/mobile, dependencias, compuertas de arte y asignaciones a Claude/Gemini/Codex están anotadas. Se conserva la regla de una tarea de spec por vez y cada ejecución futura usa worktree propio.

## Verificación
Revisar referencias cruzadas, tareas y dependencias; ejecutar `git diff --check`. Sin tests de juego porque no cambia código.
