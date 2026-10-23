# T434 · Auditoría de arte activo y piezas antiguas pendientes

- **Ejecutor:** Claude Opus · solo lectura
- **Depende de:** proyecto en `main` actualizado · **Compuerta:** aprobación de Lucas antes de integrar o redibujar arte
- **Tamaño:** mediano

## Objetivo
Identificar qué arte usa hoy el juego, qué piezas visibles son antiguas/provisionales y qué trabajo requiere aprobación, con foco inicial en nivel 6.

## Hecho cuando
El informe `specs/tareas/informes/T434-auditoria-activos-visuales.md` clasifica recursos por nivel/sistema, rutas exactas, quién los carga, evidencia y estado (vigente, migrado, provisional o candidato sin uso); contrasta escenas/código/datos con las capturas e historial de tareas; distingue deuda conocida de deuda no registrada. Solo lectura: no reescribe ni integra assets, no corre importación ni cambia el test de recursos.
