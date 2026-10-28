# T543 · Reconciliación del backlog (2026-10-28)

Base: `origin/main` en `0103f8c`. Solo lectura de código, datos, assets, tests, `git log` y las entradas de `specs/03-tareas.md`. No se corrió Godot ni GUT.

| Tarea | Veredicto | Evidencia / qué falta |
|---|---|---|
| T362 | **Hecha, tildada** | `art/t362-muestras/` (atlas, fuentes, prompts, manifest, contactos); OK de Lucas en D-165 y en la actualización del 2026-10-23; commits `d40cdb3`, `c535b30`. La carpeta no se llama `art/mejoras-m65/`. |
| T469 | **Hecha, tildada** | `art/t469-mapa-propuesta/` (commit `f719b0f`, PR #91); Lucas aprobó V3 (T474) y la máscara G2 (T488). |
| T476 | **Hecha, tildada** | `7bf78d6` (PR #67), `9c44cdb` (PR #81), `b813683` (PR #86); `test_presentation_geometry.gd`, `test_presentation_host.gd`. Sin Windows ni celular real. |
| T364 | Parcial | Atlas integrados (T411) y docs (T415). Falta medición limpia de RF-629 (T414 no la certificó) y celular real. |
| T474 | Parcial | Números e insignias V3 hechos, con tests (`test_campaign_numbers.gd`, `test_campaign_badges.gd`); falta auditoría de las demás pantallas y la receta del editor (RF-697). |
| T454 | Parcial | Fase 1 hecha (informe estático, PR #120). Faltan fases 2 (celular real, K1-K22) y 3 (medición PC). |
| T216 | Parcial | Arte provisional en uso; íconos/arcos/anillo sin conectar (`KNOWN_UNUSED`); sin aprobación de Lucas. |
| T218 | Parcial | 5 de 6 señales provisionales sin aprobación (el poste ya lo reemplazó T437/T443). |
| T219 | Parcial | Escombros resueltos (T267b/T277); árbol, roca, despejados y marca sin arte aprobado. |
| T220 | Parcial | Mina y bosque resueltos; falta solo el indicador de reserva. |
| T221 | Parcial | `stat_resources.svg` y `coleccion_disruptor.svg` sin uso; sin aprobación. |
| T233 | Parcial | Central resuelta; abastecimiento (T527 propuesto, sin integrar), hito y epílogo provisionales. |
| T367 | Pendiente | `art/t367-muestras/` es del concepto viejo; no hay fondos/ilustraciones para la presentación nueva. |
| T369 | Pendiente | Depende de T367 y de una medición limpia que no existe. |
| T463 | Pendiente | Sin muestra ni trabajo. |
| T479 | Pendiente (bloqueada) | Sin código; espera medición en celular real (T454) y OK de Lucas. |
| T128 | Diferida | `scenes/editor/` sin selector de tema ni paleta de leyenda; B-08 va después de la V1. |

Límites: no se verificó que las aprobaciones de Lucas citadas existan fuera de lo que registra el tablero y las decisiones.
