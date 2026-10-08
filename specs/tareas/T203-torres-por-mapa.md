# T203 · 📜 Torres disponibles por mapa y aviso en la selección de nivel

- **Ejecutor:** Sonnet 5.5 · esfuerzo **medio**
- **Depende de:** T200 (Q-29 y Q-30) · **Compuerta:** ninguna · **Tamaño:** chico · 📜 escribe RF y D (ninguna otra tarea 📜 al mismo tiempo)

## Leer
- `specs/01-spec.md`: RF-200 a RF-205 (formato del nivel), RF-300 (torres reservadas y `torres_extra`), RF-388 (`torres` de los modos) y RF-360 (Mecánico con colección).
- `scripts/data/level_data.gd` (`available_towers`, `allowed_towers`, `extra_towers`), `scripts/logic/level_file.gd` (`LEVEL_KEYS` y la lectura de `torres_extra`), `scripts/logic/mode_packs.gd` (cómo valida `"torres"`, para copiar el patrón), `scenes/ui/level_select.gd` (tarjetas) y `scenes/editor/` (el editor tiene que **conservar** el campo).
- Los tests que ya cubren esto: `grep -l "torres_extra\|allowed_towers" tests/*.gd`.

## Objetivo
1. Un nivel puede decir **qué torres ofrece**, con el campo opcional `"torres": ["frost", "cannon", …]`, para la rotación del 07 §4.
2. La tarjeta de la selección de nivel **muestra las torres disponibles** y marca **"Nueva"** la primera vez que aparece una torre en la campaña (Q-30).

## Reglas (escribirlas como RF, con criterio Dado / Cuando / Entonces)
- Sin `"torres"`, el nivel se comporta **exactamente como hoy**: las 8 comunes más `torres_extra`.
- Con `"torres"`, la barra muestra **solo esas**, en el orden canónico de `tower_types`, no en el del archivo. `torres` puede nombrar reservadas: equivale a habilitarlas.
- Un id inexistente es un error que lista los que existen (como RF-204). Si se repite, cuenta una vez.
- La condición de colección (`required_collection`) **sigue aplicando**: estar en la lista no saltea la colección.
- **Modo y nivel juntos:** vale la **intersección**. Si queda vacía, es un error del modo, con su mensaje.
- El editor conserva el campo (no hace falta editarlo todavía: eso es T212).
- La tarjeta del nivel muestra íconos chicos de las torres que ofrece (los mismos de la barra). "Nueva" sale en la torre cuyo **primer** nivel de campaña con ella es este. Se calcula desde los datos y no se guarda en el guardado.
- La Wiki sigue mostrando todas las torres.

## Pasos
1. 📜 `git pull` y tomar los siguientes RF y D libres.
   - `01-spec.md`: una subsección nueva "Torres por mapa (rotación)" cerca de RF-300, con los RF y su criterio.
   - `04-decisiones.md`: una D con el porqué. El 07 §4 dice que la rotación va por datos del mapa y que no hay pantalla de mazo; descartar la alternativa "lista de torres a quitar".
   - `02-plan-tecnico.md`: unas líneas con el cómo.
2. Código: `LEVEL_KEYS`, la lectura y validación en `level_file.gd`, `allowed_towers` en `LevelData` (ya existe: combinarlo con el del modo) y las tarjetas de `level_select.gd`.
3. Tests nuevos:
   - nivel sin campo (igual que hoy), con campo, con una reservada, con un id malo y con un repetido;
   - intersección con un modo, incluida la que queda vacía;
   - la colección sigue mandando;
   - la tarjeta muestra los íconos y la marca "Nueva" (lógica pura, sin cambiar de escena).
4. `CONTENIDO.md`: explicar el campo con un ejemplo.

## Hecho cuando
- Todos los tests en verde (más de 1017, ninguno roto) y sin `SCRIPT ERROR`.
- `check_level` acepta un nivel de ejemplo con `"torres"`.
- Los 9 niveles actuales siguen dando lo mismo en el bot: comparar `mix level=6` y `level=9` antes y después.
- Resultado en `03-tareas.md`, commit y PR.

## Frenar si
- La intersección con los modos rompe algún test de T197 de una forma que no sea obvia.
