# T243 · 📜 🚦 Spec del jefe supremo del nivel 15

- **Ejecutor:** Sonnet 5.5 · esfuerzo **alto**, junto con **Lucas** (diseña y aprueba) · **Tamaño:** chico · 📜
- **Depende de:** T227 (spec del lore y de la ficha del 15, **con el OK de Lucas**; sin otra 📜 abierta). **Los siguientes números libres son RF-481 y D-092** (T227 usó RF-464 a RF-480 y D-089 a D-091); confirmarlo con `git grep` en todas las ramas `feature/*` antes de escribir · **Compuerta:** Lucas aprueba el diseño antes de programar y antes de dibujar · **Origen:** Q-32 ✎ (Lucas, 2026-10-08)

## Por qué existe
Lucas pidió que el último nivel tenga un **jefe supremo nuevo**, y no el Soberano de siempre (`data/enemies/boss.tres`). El 07 (§ de reglas, punto 9) dice que un líder nuevo se define **después de fijar su función y sus contramedidas**. Esta tarea es esa definición. **Nadie inventa números ni habilidades fuera de esta spec.**

## Leer
- **§7.17 de la spec** (la ficha del 15, que deja el hueco de este jefe, y RF-480), D-091 y `specs/11-textos-lore.md` (la entrada y el epílogo del 15, que no dicen nada del jefe más que «lo más grande que vimos hasta ahora, y no viene solo»).
- 07 §1, §2 y §12 (lore y final) y `specs/10-universo.md` (T201), para saber quién es y qué representa.
- §7.4 de la spec (vida por nivel) y §6.3 (Chamán y Espejo) como referencia de habilidades.
- `data/enemies/boss.tres` y los demás enemigos, para no repetir la función de ninguno.
- El Resultado de T229 a T232 (la curva de dificultad hasta el 14).

## Qué hacer
1. Proponer a Lucas **2 o 3 conceptos** del jefe supremo, cada uno con su **función**, su **contramedida** (qué torres o jugadas lo frenan) y cómo se combina con la escolta (Guardián + Curandero + Chamán).
2. Con el que elija, escribir el RF (con "Dado / Cuando / Entonces"), la decisión `D-0xx` (con las alternativas descartadas) y la sección del plan técnico: vida, velocidad, habilidad, recompensa, aparición en la Wiki y texto del lore.
3. Los números son iniciales y los ajusta T234 con el bot.

## Hecho cuando
Hay un RF y una D, Lucas aprobó el concepto y quedó claro qué dibuja T244 y qué programa T234. Resultado, `CHANGELOG.md` (si lo notan los jugadores), commit y PR.

## Frenar si
El concepto exige un sistema nuevo (por ejemplo, un nuevo tipo de daño o de mapa). Eso es una sugerencia para §13, no se implementa sin consultar.
