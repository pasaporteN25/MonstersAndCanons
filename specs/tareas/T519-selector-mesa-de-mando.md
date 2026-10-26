# T519 · Especificar Mesa de mando para el selector de niveles
- Ejecutor · Codex `gpt-6.1-sol`, esfuerzo medio
- Depende de · elección explícita de Lucas (recibida 2026-10-26)
- Tamaño · solo documentos

## Leer
- `CLAUDE.md`, `specs/00-constitucion.md`, `.claude/rules/specs.md`
- RF-687 a RF-698 y RF-711 en `specs/01-spec.md`
- decisiones D-198 a D-214 y ficha T518
- `specs/02-plan-tecnico.md` M76 y `specs/03-tareas.md`
- `art/t518-selector/README.md`

## Objetivo
Convertir la elección de Lucas de Mesa de mando y el rótulo «Comunidad» en una especificación comprobable para reorganizar el marco general del selector en PC y celular apaisado.

## Alcance
Sí: RF-723, D-215, plan técnico M81, ficha de implementación T520 y estado de T518/T519 en el tablero.

No: código, escenas, datos, `CHANGELOG.md`, arte nuevo ni cerrar compuertas de uso humano.

## Hecho cuando
Los documentos explican la adaptación real al viewport lógico horizontal 1280×720, preservan mapa/tarjetas y navegación existentes, mantienen controles táctiles y modos dinámicos, y tienen criterios verificables. La tarea de implementación depende de T519 integrada y ambos PR apuntan a `main`.

## Verificación
`git diff --check`; revisar identificadores únicos contra main/PR; inspeccionar el diff para asegurar que solo cambian documentos.

## Frenar si
La composición requiere cambiar el atlas, tarjetas, selección, progreso o datos; consultar a Lucas antes de extender ese alcance.
