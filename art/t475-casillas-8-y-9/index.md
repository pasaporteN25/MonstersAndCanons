# T475 · Candidatas de casilla para los niveles 8 y 9 (NO integradas)

> 2026-10-28, Claude (Sonnet 5.5). Base: `origin/main` e17245e. Lucas decidió buscar otra casilla para cada nivel; si no hay una limpia, ese nivel queda sin poste. **No se integró nada**: `data/ui/postes_campana.json` y `data/levels/` quedaron intactos. Espera el OK de Lucas.

## Hallazgo principal: no existe una casilla limpia en ninguno de los dos niveles

Los mapas 8 y 9 no tienen ninguna `X` ni decoración sin significado. Leyendo `level_08.json` y `level_09.json`, cada casilla es una de estas:

| Tipo | Nivel 8 | Nivel 9 | Sirve para el poste |
|---|---|---|---|
| Camino, entrada o salida | sí | sí | No (criterio de la ficha) |
| Removible (`u`, `e`) | (7,6), (11,6), (15,6), (14,8) | (3,2), (14,2), (11,6), (7,8) | No |
| Símbolo de ruina `s` (señal canónica) | (12,0) y (0,4) | (6,0) y (0,4) | No: tapa una señal |
| Construible `.` | todo el resto | todo el resto | No: es casilla libre |

Las únicas casillas permanentemente no construibles que no son camino son las dos señales de cada mapa; todo lo demás es construible o removible. Con el criterio de la ficha, **ninguna casilla es limpia**. Para dar algo que decidir se muestran, por nivel, las 3 «menos malas»: 2 casillas libres alejadas del camino y la otra señal (no la de (0,4)).

Un poste sobre una casilla libre es solo una capa visual: no la vuelve no construible, así que el jugador vería un poste donde igual puede construir, o la casilla quedaría tapada por el arte. Para que fuera limpia habría que convertirla en `X` en `data/levels/` (cambio de mapa jugable que la ficha prohíbe sin OK explícito de Lucas).

## Tabla de candidatas

Las capturas son del motor real (`tools/capture_t475_postes.tscn`, ventana 1280×720, `DISPLAY=:0`, 0 estrellas = poste rebelde) con el poste puesto temporalmente en cada casilla; el JSON se restauró después de cada corrida. El motor, al dibujar un poste, borra el ítem de atrás y deja solo el suelo.

| Nivel | Casilla | Qué hay alrededor | Margen de borde | Riesgo | Captura | Recomendación |
|---|---|---|---|---|---|---|
| 8 | C1 (18,1) | Casilla libre `.` en el rincón noreste; el camino pasa a 2 casillas (fila 3); sin señales ni removibles cerca | 1 | Medio: es construible y el poste la oculta (lejos del camino, poco uso táctico) | `nivel_08_cand_18-1_captura.png` | **Primera opción** si Lucas acepta poste sobre casilla libre. Es la misma posición que el poste del nivel 6 |
| 8 | C2 (16,1) | Casilla libre, a 2 casillas del camino (fila 3); lejos de señales | 1 | Medio: igual que C1 | `nivel_08_cand_16-1_captura.png` | Alternativa a C1 |
| 8 | C3 (12,0) | Símbolo de ruina `s` (señal canónica) del borde norte; sin camino cerca | 0 | **Alto:** tapa un símbolo canónico (el mismo problema que (0,4)) | `nivel_08_cand_12-0_captura.png` | No recomendada |
| 9 | C1 (18,1) | Casilla libre en el rincón noreste; el camino pasa a 2 casillas (fila 3); sin señales cerca | 1 | Medio: construible, la oculta el poste | `nivel_09_cand_18-1_captura.png` | **Primera opción** si se acepta casilla libre |
| 9 | C2 (16,1) | Casilla libre; el removible (14,2) a 2 casillas, sin pisarlo; lejos de señales | 1 | Medio: como C1 | `nivel_09_cand_16-1_captura.png` | Alternativa a C1 |
| 9 | C3 (6,0) | Símbolo de ruina `s` del borde norte; el camino pasa a 1 casilla en diagonal | 0 | **Alto:** tapa un símbolo canónico | `nivel_09_cand_6-0_captura.png` | No recomendada |

## Recomendación

1. **Según la regla de Lucas** («si no hay una limpia, queda sin poste»): dejar **los niveles 8 y 9 sin poste**. No hay casilla limpia y no se pierde nada jugable.
2. Si prefiere poste en los 15 niveles: C1 (18,1) en ambos, aceptando que oculta una casilla libre (decidir aparte si esa casilla pasa a `X`, lo que toca `data/levels/` y exige su OK).
3. Evitar C3 en ambos: tapa un símbolo canónico.

## Qué no se probó

- Solo la variante rebelde (0 estrellas); no hay captura con 3 estrellas ni 2 estrellas en estas casillas.
- No hay captura en 1920×1080, celular simulado ni dispositivo real; no se midió rendimiento.
- No se vio cómo queda el poste con una torre construida debajo en C1/C2.
- Los planos (`nivel_08_plano.png`, `nivel_09_plano.png`) son dibujos de la grilla leída de los JSON, no capturas.
- No se corrió GUT completo: no se tocó código ni datos, solo `art/` y `specs/`.
