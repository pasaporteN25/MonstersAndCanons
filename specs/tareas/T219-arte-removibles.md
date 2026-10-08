# T219 · 🎨 Removibles y ruinas: intacto, en trabajo y despejado

- **Ejecutor:** **Codex**
- **Depende de:** T205 (la lista de estados visuales del plan M50) · **Compuerta:** 🎨 concepto aprobado por Lucas · **Tamaño:** mediano

## Leer
- `specs/tareas/README.md` §6, la guía §2, §4 y §5, y `.claude/rules/arte.md`.
- La sección M50 del plan técnico: los estados visuales y cómo los usa el código.
- Los SVG existentes de rocas y árboles en `assets/sprites/map/` y `scripts/logic/map_themes.gd` (qué dibujo usa cada tema).
- Si T207 ya está hecho, el dibujo provisional de removible y del trabajo, para respetar sus anclajes.

## Entregables (SVG de 64 × 64 en `assets/sprites/map/`)

| Pieza | Estados | Nota |
|---|---|---|
| `arbol_removible` | intacto, en trabajo (andamio o hacha clavada, cortes) | Tiene que distinguirse del árbol **permanente** (07 §6). Propuesta: **una cinta o estaca ámbar de marcado** que tenga también la roca removible. |
| `roca_removible` | intacto, en trabajo (cuñas y grietas) | La misma marca ámbar. |
| `escombro` | intacto, en trabajo | Piedra de ruina con el símbolo (T218). Es la que puede guardar una pieza. |
| `despejado` | uno por tema (`pradera`, `bosque`, `ruinas` y `desierto`) | El suelo con tocón o restos chatos, **construible**: que no parezca bloqueado. |
| Marca de "pieza pendiente" | 32 × 32 | Un brillo plateado sobre el escombro que todavía guarda una pieza. |

Si T205 fijó otros estados, se sigue la lista de T205.

## Pasos
1. Concepto (una hoja con todos los estados sobre `bosque` y `ruinas`, a 220 y a 34 px) y **OK de Lucas**.
2. Producir. Integrar las rutas donde el plan M50 indique (`level_decor.gd` o el nodo de obstáculos de T207). Si el código no tiene el gancho todavía, dejar los archivos y anotar.
3. Hoja de contacto, captura en partida de una demolición a mitad de trabajo y tests en verde.

## Hecho cuando
Concepto aprobado y registrado, archivos integrados (o anotados) y capturas. Commit `T219: …` y PR.
