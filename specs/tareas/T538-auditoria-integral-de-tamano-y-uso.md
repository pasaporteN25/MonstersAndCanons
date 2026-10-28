# T538 · Auditoría integral de tamaño y código sin uso

- **Ejecutor:** Claude Opus 5.5, esfuerzo medio.
- **Depende de:** pedido de Lucas del 2026-10-27.
- **Alcance:** análisis estático de TDv1 completo; sin cambios en runtime ni borrados.

## Objetivo

Revisar arquitectura, recursos, datos, exportación, pruebas y documentación de todo el juego; identificar oportunidades demostrables para reducir el tamaño del paquete y separar código o assets sin uso de recursos que siguen activos por carga dinámica, herramientas, comunidad, compatibilidad o pruebas.

## Hecho cuando

- El informe incluye un baseline cuantitativo reproducible y deja claras las diferencias entre repo, caché, paquete y runtime.
- Cada candidato tiene evidencia, certeza, ahorro medido o rango justificado, riesgo y método de verificación.
- Las oportunidades se clasifican por impacto y riesgo, y las eliminaciones propuestas siguen un orden reversible.
- Se registran límites, tareas dependientes y decisiones pendientes, sin editar ni borrar contenido del juego.

## Resultado (2026-10-27)

Auditoría completa de 7 áreas por Opus 5.5 en esfuerzo medio, sobre `origin/main` `86911ee`. Informe: [`informes/T538-auditoria-integral.md`](informes/T538-auditoria-integral.md). Incluye inventario y tamaños versionados, análisis de importación, carga de escenas/recursos, código, datos, export presets, CI y cobertura. Los hallazgos principales son `Capturas/` (257 PNG; 138.256.832 bytes y caché de 170.054.036 bytes en un worktree próximo; ahorro de export no medido), 670 MB de caché importada desde `art/` que no entra al export, 1,95 MB de fuentes raster/SVG probablemente obsoletas, y debilidad del test de recursos sin uso. Distingue los respaldos y recursos vivos de los candidatos a retirar, entre ellos los tres SVG de abastecimiento del nivel 15 que esperan la tarea de integración T527.

Se verificaron manualmente los filtros en `export_presets.cfg`, el conteo/tamaño de `Capturas/`, `.gdignore` y los usos de `flores.svg` en los niveles 1, 3, 4 y 5. No se ejecutó Godot, GUT, exportación, benchmark ni prueba de VRAM; no se borraron ni modificaron recursos activos. Opus completó la tarea sin agotar cuota. `git diff --check` pasa.
