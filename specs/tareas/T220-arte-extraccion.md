# T220 · 🎨 Mina y bosque explotable: activo, agotado y reserva

- **Ejecutor:** **Codex**
- **Depende de:** T205 · **Compuerta:** 🎨 concepto aprobado · **Tamaño:** chico

## Leer
`specs/tareas/README.md` §6, la guía §2, §4 y §5, los estados de extracción del plan M50 y, si existe, la vista provisional de T210.

## Entregables (SVG de 64 × 64 en `assets/sprites/map/`)

| Pieza | Estados |
|---|---|
| `mina` | sin habilitar (una boca de mina con tablas), activa (vagoneta, puntales y algún brillo de mineral) y agotada (tapiada o derrumbada) |
| `bosque_explotable` | sin habilitar (un grupo de árboles marcados, **distinto** del árbol removible y del permanente), activo (troncos apilados) y agotado (tocones) |
| Indicador de reserva | segmentos de 8 × 8 o el formato que pida el plan, legibles a 34 px |

Una mina activa **no se puede confundir con una torre** (guía §4).

**Nombres de archivo y estados:** los de la tabla "Estados visuales" de la sección M50 del plan técnico (`mina.svg`, `mina_activa.svg`, `mina_agotada.svg`, `bosque_explotable*.svg`, `reserva_llena.svg` y `reserva_vacia.svg`). Un punto de extracción es siempre una casilla bloqueada y nunca se despeja (RF-400).

## Pasos
Concepto, OK de Lucas, producción, integración de rutas (o anotarla), hoja de contacto, captura y tests en verde. Commit `T220: …` y PR.
