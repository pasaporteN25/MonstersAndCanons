# T222 · Niveles 1 a 5: señales y oasis, sin cambiar el juego

- **Ejecutor:** Sonnet 5.5 · esfuerzo **bajo** · ***apto Qwen*** (datos con validador; un Sonnet revisa)
- **Depende de:** T200 (Q-36 y las fichas) y T218 (los dibujos de las señales). Si T218 no está, se usan dibujos existentes como provisionales: `estatua`, `columna` y `bloque` · **Compuerta:** ninguna · **Tamaño:** chico

## Leer
- `specs/08-plan-cierre-v1.md` §5, el bloque 1 (qué señal va en cada mapa).
- RF-201 (letras del mapa), RF-260 a RF-267 (tema y leyenda) y la respuesta Q-36.
- `data/levels/level_01.json` a `level_05.json`.

## Regla de oro de esta tarea
**No cambia ni una casilla jugable.** Solo se reemplazan casillas que **ya** son `X` por letras de la leyenda **no construibles**. No se tocan `.`, `#`, entradas, salida, oleadas, oro ni vidas.

## Pasos (por cada nivel del 1 al 5)
1. Agregar `"tema": "pradera"` (es el de siempre: no cambia nada).
2. Agregar a `"leyenda"` las letras de la señal del mapa (por ejemplo `"m": {"dibujo": "roca_marcada"}`) y, si se quiere el oasis, `"~": {"dibujo": "agua"}` y `",": {"dibujo": "flores"}`. **Todas sin `construible`**: así quedan bloqueadas, igual que `X`.
3. En `"mapa"`, cambiar **solo** algunas `X` por esas letras: de 1 a 3 señales por mapa, y agua o flores donde se vea natural.
4. Correr `godot --headless --path . -s tools/check_level.gd -- data/levels/level_0N.json`. Tiene que dar **el mismo recorrido y el mismo largo** que antes. Copiar en el Resultado la salida de antes y la de después.
5. Actualizar RF-267 de la spec: los niveles 1 a 5 ahora tienen decoración con leyenda, según Q-36. Es una nota sobre un RF existente: **no** se crea un RF nuevo.

## Verificación
- Un test o script que compare las casillas de cada nivel antes y después: el conjunto de casillas construibles, el de camino y los recorridos tienen que ser **idénticos**. Si no hay un test así, agregar uno chico en `tests/` que lo verifique contra `git show HEAD~1:data/levels/level_0N.json`, o dejar en el Resultado el diff de casillas hecho a mano.
- `mix levels=1-5 seeds=3` (T204) da **exactamente** lo mismo que la línea de base de T204.
- Todos los tests en verde.
- Captura de cada mapa en `art/campaign-v1/bloque1/level_0N.png`.

## Para Qwen
Hacer solo los pasos 1 a 4. No tocar `01-spec.md`, no tocar `.gd` y no hacer el commit. Un Sonnet completa el paso 5, revisa y hace el commit.

## Hecho cuando
Las cinco capturas, `check_level` idéntico, el bot idéntico y los tests en verde. Commit `T222: …` y PR.
