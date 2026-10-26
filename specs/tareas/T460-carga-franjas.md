# T460 · 📜 Franjas temáticas y láminas rotativas de carga

- **Ejecutor:** spec/arquitectura pesada y revisión del orquestador, preferencia Opus si disponible.
- **Depende de:** decisiones de Lucas T450 y aclaraciones posteriores del 2026-10-23. **Compuerta:** 🚦 aprobación de Lucas al PR antes del código; carga con imágenes además espera medición T454 y OK con esos datos.
- **Refs:** M77 RF-699–707, D-204–206. T458 usa RF-674–686/D-192–197 y T459 RF-687–698/D-198–203; números no se reutilizan aunque PRs tengan bases distintas.

## Leer

CLAUDE.md, ~/.agents/AGENTS.md, constitución, spec §11/§13/M64 (RF-580–589), D-130–134, plan/tablero/cierre, ONBOARDING, tareas/README e informe T450 completo. T454 se lee desde rama remota si #57 aún no está en main, sin modificarla.

## Objetivo y alcance

Especificar fondo temático por terreno fijo respecto al zoom y recorte en ejecución manteniendo máximo 1,0; propuesta técnica que cubra franjas fuera del viewport keep sin expandir zona jugable/HUD. Enmendar RF-580/D-133 para imágenes de intro opcionales, inyectadas por GameFlow y condicionadas a medición real de celular. Plan/fichas T476–479 y guías coherentes. No código ni arte final.

## Borrador textual para revisar composición

```text
┌────────── superficie física: llena ventana ───────────────┐
│ Fondo del terreno, quieto, como más allá del mapa         │
│   ┌──── marco lógico 1280×720, escala uniforme ──────┐    │
│   │ HUD actual                                    │    │
│   │ Mapa actual: zoom/pan solo aquí                │    │
│   │ Controles actuales                             │    │
│   └────────────────────────────────────────────────┘    │
│ Las áreas de alrededor no reciben acciones de juego      │
└─────────────────────────────────────────────────────────┘
Carga (solo tras T454): color + barra → lámina lista/velo → escena.
Si imagen llega tarde/falla: sigue color + barra y la escena no espera.
```

La proporción de la superficie cambia con la ventana; el marco mantiene 16:9 y HUD fijo. Esto es un diagrama, **no una muestra de arte aprobada**. T477 debe mostrar los recortes por terreno y relaciones, sin retocar el arte aprobado. La capa de carga conserva texto/barra legibles y no reproduce el texto narrativo de la intro.

## Hecho cuando

RF con Dado/Cuando/Entonces, decisiones/alternativas, arquitectura revisable y fichas pequeñas con compuertas. Plan y guías distinguen lo aprobado funcionalmente, lo propuesto técnicamente y los resultados pendientes del teléfono. T460 documental puede cerrarse sin dar por aprobada la medición ni el código.

## Verificación y límites

Lectura de fuentes/código y revisión documental; git diff --check. No Godot/GUT por cambio documental. No captura nueva, teléfono, medición ni aprobación de composición; T450 PC no se extrapola. CHANGELOG se actualizará cuando cambie el juego.
