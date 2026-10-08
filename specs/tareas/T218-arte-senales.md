# T218 · 🎨 Señales de los habitantes (decoración del mapa)

- **Ejecutor:** **Codex**
- **Depende de:** T200 (Q-38) y T201 (la biblia define el **símbolo A** y el catálogo de señales) · **Compuerta:** 🎨 Lucas aprueba la hoja de concepto antes de producir · **Tamaño:** chico

## Leer
- `specs/tareas/README.md` §6.
- `specs/05-guia-de-arte.md` §2, §4 y §5 (decoración SVG: contorno `#2b2233`, degradé de 3 paradas, sombra suave en el suelo) y `.claude/rules/arte.md`.
- `specs/10-universo.md`, la sección "Señales".
- Los SVG existentes de `assets/sprites/map/` (estatua, columna, bloque, abeto…), para igualar la técnica.
- `scripts/logic/level_file.gd` y `level_decor.gd`: la lista cerrada de dibujos de la leyenda (RF-263) y cómo se dibujan.

## Entregables
SVG de 64 × 64 en `assets/sprites/map/`, con su comentario en castellano. **Un dibujo por señal**, aproximadamente:

| Dibujo (id para la leyenda) | Qué es | Dónde aparece (plan 08 §5) |
|---|---|---|
| `roca_marcada` | Una roca con el **símbolo A** tallado | Niveles 1 y 5, y las ruinas del 8 |
| `sendero` | Piedras planas acomodadas: un camino mantenido, **que no se confunda con el camino de los enemigos** | Nivel 2 |
| `herramienta` | Una herramienta tallada abandonada (de hueso o madera) | Nivel 3 |
| `poste_cintas` | Un poste con cintas o tiras de tela | Nivel 4 |
| `simbolo_ruina` | El símbolo A en piedra de ruina | Niveles 8 a 10 |
| `campamento_vacio` | Restos de un campamento abandonado | Niveles 14 y 15 |

La lista final la fija la biblia (T201). Si cambia, se sigue la de la biblia.

## Pasos
1. **Concepto:** una hoja con todas las señales a 220 y a 34 px, sobre el suelo de `pradera`, `bosque` y `ruinas`. **Esperar el OK de Lucas** y registrarlo.
2. Producir los SVG. **Integración en datos:** sumar los ids a la lista cerrada de dibujos (RF-263) en `level_file.gd`, una línea por dibujo, y cargarlos con `preload` donde se dibuja la decoración. Si eso exige más que agregar entradas a la lista, dejarlo para T222 y anotarlo.
3. Hoja de contacto (§5 de la guía) y captura en partida con el mapa de ejemplo `tools/ejemplos/tema_ruinas.json` más una leyenda de prueba.
4. Tests completos en verde (los tests de sprites verifican 64 × 64).

## Reglas
- Una señal **nunca se parece a una torre ni a un enemigo** (guía §4).
- Son **casillas bloqueadas** (no construibles), como `X`.
- Tienen que ser **discretas** en el bloque 1: decoración que el jugador no tiene por qué notar.

## Hecho cuando
- El concepto aprobado está registrado, los SVG están integrados en la lista de dibujos, y hay hoja de contacto y captura.
- Commit `T218: …` y PR.
