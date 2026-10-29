# Decisiones pendientes de la auditoría (T538) · 2026-10-28

Origen: `specs/tareas/informes/T538-auditoria-integral.md` §2 (D) y §5, más lo medido por T550 (PR #162). Ninguna de estas decisiones bloquea la V1: lo que se pudo hacer sin decidir ya se hizo (T547, T550, T551). Cada una dice qué cambia, cuánto ahorra, el riesgo y la recomendación.

## Lo que ya se midió (T550)

| | Antes | Después de excluir `Capturas/` |
|---|---|---|
| `.pck` | 236.774.592 B | 60.714.592 B (−74 %) |
| Ejecutable Linux (con el `.pck`) | 310.322.152 B | 134.234.016 B |

Lo que pesa hoy dentro del paquete (60,7 MB): `assets/sprites` 31 MB, `assets/backgrounds` 18,4 MB (7 franjas), `assets/intro` 4,2 MB, `assets/audio` 3 MB. Escenas, scripts y datos suman menos de 1 MB. El `.exe` de Windows se estima en unos 170 MB (la plantilla sola pesa 109 MB). No se exportó Windows ni Android.

## Decisiones

### D1 · ¿Qué hacemos con `Capturas/` en el repositorio? — **DECIDIDO (2026-10-28): A**
Son 138 MB de PNG en el árbol y 141 MB en el historial. **Ya no entran en el juego exportado** (T550), así que esto es solo sobre el peso del repo (clonar, CI).
- **A. Dejar de versionar capturas nuevas** (`.gitignore`), conservar las que muestra el README y no tocar el historial. *Recomendado.*
- B. Mover las capturas a otro lugar (Releases de GitHub o LFS) y sacarlas del árbol. El historial sigue pesando.
- C. Dejar todo como está.

### D2 · ¿Reescribir el historial para achicar el repo? — **DECIDIDO (2026-10-28): no**
Implica `git push --force`, que está prohibido sin tu permiso explícito, y rompe las ramas, worktrees y PR abiertos. **Recomendado: no**, salvo necesidad real.

### D3 · ¿Compresión con pérdida en franjas, epílogo y logo? — **DECIDIDO (2026-10-28): ninguna antes de la V1**
Ahorro estimado 8–12 MB sobre 60 MB (franjas: 18,4 MB). Riesgo: pérdida visible en degradados y bordes. Requiere una comparación a escala real antes de elegir.
- A. No por ahora; mirar la comparación después de la V1. *Recomendado.*
- B. Hacerla ya, con comparación para que apruebes.

### D4 · ¿La música pasa a OGG? — **DECIDIDO (2026-10-28): después de la V1**
Ahorro 1,5–2 MB. Requiere escucha y verificar los bucles. **Recomendado: después de la V1.**

### D5 · ¿Qué hacemos con los ~50 SVG fuente que están en `assets/`? — **EN CURSO: Lucas pidió un documento que muestre cuáles son; probablemente se borran**
No los usa el juego (el arte vigente son PNG renderizados) y están listados como «sin uso» en el test. Ahorro < 1,5 MB, pero confunden.
- A. Moverlos a `art/` (quedan como fuente, reversible). *Recomendado, después de la V1.*
- B. Borrarlos.
- C. Dejarlos donde están.

### D6 · Resuelta
T527 se integró (T549) y `supply_conveyor` y los tres `supply_*` se retiraron. No hace falta decidir.

### D7 · ¿Las migraciones de guardado siguen después de la V1? — *sin respuesta de Lucas; se asume la recomendación*
Son ramas de código que cargan guardados de builds viejas. Ya no se prueba el archivo viejo del tester. **Recomendado: conservarlas** (costo casi nulo, evitan perder partidas) y revisarlas en la 1.1.

### D8 · Temas `volcan` y `pantano` — *sin respuesta de Lucas; se asume la recomendación*
Hoy los usan solo los mapas de la comunidad; ningún nivel de campaña. **Recomendado: conservarlos** (hay tests y RF-267) y corregir el README, que da a entender otra cosa.

## Ya hecho sin necesidad de decidir
- Capturas fuera del export: −176 MB en el `.pck` (T550).
- `rammer.png`, `healer.png` aislados en `art/t551-retirados/`; el test detecta recursos sin uso por ruta completa y `uid` (T551).
- `hito.svg`, `supply_conveyor.svg` y los tres `supply_*` retirados (T547).

## Resultado de las respuestas (2026-10-28)
- D1 A: `.gitignore` deja de versionar capturas nuevas (T552); se conservan las ya versionadas y las del README.
- D2: no se reescribe el historial; no hay `push --force`.
- D3 y D4: sin compresión ni OGG antes de la V1.
- D5: documento con los SVG fuente y su estado, para decidir el borrado.
