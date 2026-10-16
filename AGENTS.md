# Instrucciones para agentes — TDv1

## Proyecto y fuentes de verdad

- Este repositorio contiene Monsters & Canons (TDv1), un juego 2D en Godot 4 con GDScript.
- La constitución `specs/00-constitucion.md` prevalece sobre otras decisiones del proyecto. Para requisitos, decisiones, plan y estado del trabajo, seguir `specs/01-spec.md`, `specs/04-decisiones.md`, `specs/08-plan-cierre-v1.md` y `specs/03-tareas.md`.
- `ONBOARDING.md` es la guía canónica para instalar y configurar herramientas, abrir el proyecto, correrlo, probarlo y exportarlo. Consultarla para el sistema operativo y la tarea concretos; mantenerla actualizada cuando cambien pasos o requisitos.
- `CLAUDE.md` y `.claude/rules/` conservan contexto y reglas específicas de Claude Code. Estas instrucciones generales complementan el material del proyecto; no duplicar aquí sus detalles técnicos.
- La documentación y la comunicación con Lucas van en español rioplatense. Identificadores, nombres de código, archivos y escenas van en inglés.

## Tareas y alcance

- El tablero `specs/03-tareas.md` es la fuente de verdad del estado de las tareas de TDv1. Las fichas delegables viven en `specs/tareas/`.
- Antes de implementar una tarea, comprobar dependencias, compuertas de aprobación y criterios de aceptación. Si falta una dependencia o una decisión requerida, detenerse y explicarlo.
- Seguir el flujo de desarrollo del proyecto: spec → decisión → plan → tarea → código y pruebas. No inventar requisitos ni implementar ideas propias no aprobadas.
- Al completar una tarea, actualizar únicamente su entrada en `specs/03-tareas.md`, con un resultado honesto que distinga qué se hizo, qué se verificó y qué quedó sin verificar. Actualizar `CHANGELOG.md` si cambia algo visible para quien juega.
- Mantener cada cambio acotado a su repositorio y objetivo. Las tareas, especificaciones y cambios del juego pertenecen a TDv1. Las skills reutilizables para Godot pertenecen a `pasaporteN25/Godot-Skills`; no agregar su contenido a un PR del juego.
- Si una rama contiene cambios independientes que deben conservarse, separarlos en commits o ramas apropiados antes de retirar la rama. No descartar una actualización válida del tablero por estar junto a otro cambio.

## Git y revisión

- Crear ramas nuevas desde `origin/main` actualizado, con el prefijo `feature/`; el destino normal de los PR es `main`.
- No trabajar directamente en `main`, no hacer merge del PR y no usar `--force` sobre `main`.
- Al terminar el trabajo solicitado y cumplir sus verificaciones, publicar la rama `feature/` y abrir un PR hacia `main`; avisar si el push o la creación del PR no están disponibles.
- Para una tarea con identificador `Txxx`, usar un commit por tarea con el mensaje `Txxx: descripción corta en español`.
- Antes de confirmar cambios, revisar `git status` y el diff. Preservar cambios preexistentes y revertir únicamente archivos generados accidentalmente por herramientas.
- No mezclar cambios de juego con skills, automatizaciones o mantenimiento ajeno al alcance del PR. Si aparecen juntos, separarlos antes de publicar.

## Godot: entorno y exportaciones

- Consultar `ONBOARDING.md` antes de instalar o configurar Godot, sus plantillas, el SDK de Android o herramientas de plataforma. Comprobar primero qué está disponible en la máquina y explicar los pasos faltantes de forma concreta.
- Las exportaciones para entrega deben partir de `main` o `master` actualizado del repositorio, nunca de una rama de feature. Usar un worktree temporal si el checkout está en otra rama y dejar intactos los cambios locales.
- Antes de exportar, verificar la versión de Godot, el preset solicitado, las plantillas correspondientes y las dependencias de plataforma. No afirmar éxito si falla el proceso; informar referencia y commit de origen.
- Para el procedimiento detallado y diagnóstico multiplataforma, usar la skill `godot-mainline-export` de Godot-Skills cuando esté disponible. Esta referencia complementa, pero no reemplaza, los pasos específicos documentados en `ONBOARDING.md`.
