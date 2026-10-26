# Informe de M80 · T504 y T505: muestras de rocas, glifo H y marcas

**Fecha:** 2026-10-26 · **Estado:** propuestas **sin integrar**; la elección es de Lucas (T506). No se tocó `assets/`, `scenes/`, `scripts/`, `data/` ni `project.godot`. No se editó `10-universo.md` ni `11-textos-lore.md`.

## Quién hizo qué

| Quién | Qué |
|---|---|
| Codex (`gpt-6.1-sol`, esfuerzo medio, 2026-10-26) | Todo el arte: tres generadores procedurales en Python 3 + Pillow (sin servicios de imágenes ni material ajeno) con sus piezas, hojas de contacto y composiciones. Rocas: dos pasadas (la primera, con rocas lisas como guijarros, la descarté y se rehizo con facetas, grietas y colores más apagados). Glifo y marcas: una pasada (el primer intento salió con «model at capacity», sin escribir nada, y se relanzó el mismo prompt). |
| Claude (Sonnet 5.5) | Los prompts (`*/sources/prompts.md`), la revisión visual de cada hoja y composición, la verificación independiente de casillas contra `data/levels/*.json`, este informe, el registro del OK de canon (commit aparte) y la actualización de las tareas. |
| Lucas | Elige (T506). Nada de esto está aprobado. |

Fuentes editables y procedencia detallada: `rocas/sources/` (`generate_rocks.py`, `manifest.json`, `procedencia.md`, `prompts.md`), `glifo-h/sources/` (`glyphs.py`, `glyph_g1/g2/g3.svg`, `generate_glifo.py`, ...) y `marcas/sources/` (`generate_marcas.py`, ...). Cada script regenera todo de forma determinista (semillas fijas; Codex comprobó hashes idénticos al regenerar).

## Qué se entrega

- **Rocas** (`rocas/`): 3 modelos × 3 colores, PNG RGBA 128×128: A «peña baja ancha con cara frontal inclinada», B «tres cantos/bloques», C «bloque alto angular». Colores: `caliza` (pradera, bosque), `arenisca` (desierto), `oscura` (ruinas). La roca nevada del 13 no se rehizo. `hoja_220.png`, `hoja_034.png` (más `*_detalle.png`) sobre los suelos reales de pradera, bosque, desierto, nieve y ruinas; `referencias.png` (lado a lado con `rock_a`/`rock_b`); composiciones sobre capturas reales: `comp_nivel_15.png`, `comp_nivel_11.png`, `comp_nivel_14.png`.
- **Glifo** (`glifo-h/`): 3 diseños (g1 «pilares y barra quebrada», g2 «bucle abierto» tipo blackletter, g3 «angulosa rúnica») en 3 materiales: grabado en roca caliza, relieve/pintura en un sillar de ruina caído y pintado en un banderín (9 PNG). `glifo_solo.png` (siluetas puras a 220 y 34 px), `glifo_hoja_220.png`, `glifo_hoja_034.png`.
- **Marcas** (`marcas/`): 4 tipos (banderín, tablilla clavada, hito de cinco piedras, cinta en un poste) × 3 glifos = 12 PNG. `marcas_hoja_220.png` y `marcas_hoja_034.png` (con el poste de campaña al lado), y composiciones sobre las capturas reales de los niveles 12, 13 y 14, sin poste y `_con_poste`.

## Casillas usadas en las composiciones (x, y; verificadas contra los JSON)

Todas las «señales» son casillas de leyenda `h`/`s` de la tabla de M80 (roca con glifo grabado, un solo ítem con dos capas); las marcas sueltas están en casillas `X` libres (comprobé con `data/levels/level_NN.json` que lo son) y **no coinciden con ningún poste** de `postes_campana.json` ni entre sí. Cada marca reemplaza lo que hubiera en esa `X` (se repinta el suelo): un solo ítem por casilla.

| Nivel (bioma, glifo) | Rocas con glifo grabado | Banderín | Tablilla | Hito | Cinta | Postes (solo en `_con_poste`) |
|---|---|---|---|---|---|---|
| 12 (desierto, g1) | (4,0) (0,3) (1,6) | (9,1) | (16,4) | (23,6) | (5,9) | (5,2) (24,9) |
| 13 (nieve, g2) | (7,1) (11,4) (20,5) (8,7) | (3,1) | (13,4) | (5,8) | (17,10) | (23,2) (24,9) |
| 14 (ruinas, g3) | (8,1) (24,1) (18,2) (3,5) (14,5) (7,7) (13,8) (25,9) | (11,1) | (1,5) | (18,7) | (7,10) | (1,1) (24,10) |

Composiciones de solo rocas (T504, sin glifo): nivel 15, señales (2,4) y (19,10) más dos `X` de comparación (3,4) y (4,4); nivel 11, (1,2) (21,2) (2,8); nivel 14, las 8 casillas de señal. En 14 se usó un glifo distinto por nivel solo para mostrar los tres; en el juego sería el mismo en todos («se repite, siempre igual»). Los niveles 8 y 9 no se compusieron (su `(0, 4)` sigue frenada por el poste).

## Tabla pieza → variante recomendada (mi opinión; decide Lucas)

| Pieza | Recomendación | Por qué / reservas |
|---|---|---|
| Modelos de roca | **A + B**, y C solo si Lucas quiere una tercera silueta | A tiene la cara frontal para el grabado; B rompe la repetición entre vecinas. C se parece a un bloque/dado facetado. |
| Colores | caliza (pradera/bosque), arenisca (desierto), oscura (ruinas) | Se distinguen bien entre sí sobre sus suelos. La oscura queda gris-azulada, algo fría sobre las ruinas marrones. |
| Glifo | **g1** (1.ª opción), **g3** (2.ª) | g1 se lee como H por los dos pilares y tiene carácter por la barra quebrada; g3 es la más simple y sobrevive mejor a 34 px. **g2** es la más «gótica» a 220 px pero sus trazos finos **se fusionan a 34 px**: la descarto salvo que Lucas la prefiera. |
| Tipo de marca | **tablilla** y **hito**, luego **banderín** | Las siluetas más legibles y más distintas del poste de campaña rojo. **Cinta**: a 34 px es una mancha verde-oliva; solo si se ensancha. |
| Material del glifo | pintado en tela/madera y en relieve sobre piedra | Ver reservas. |

## Descartado o con problemas (dicho sin maquillar)

- **Primera tanda de rocas** (guijarros lisos y borrosos, arenisca naranja chillón): descartada y rehecha.
- **Las rocas siguen siendo más geométricas** que `rock_a`/`rock_b` de `main`: facetas poligonales con grano, sin la pintura orgánica y el musgo de esas dos. En `referencias.png` se nota. Codex lo reconoció; yo coincido. Se ven coherentes en tamaño y luz, pero **no alcanzan la paridad visual**; si Lucas quiere esa calidad, hay que pedir otra pasada o un flujo distinto (p. ej. pintado a mano o 3D).
- **El «grabado» en la roca** se lee más como una placa oscura incrustada que como tallado profundo: el contraste (oscuro sobre gris) es bajo a tamaño real.
- **El sillar caído con el glifo** (`g?_relieve_ruina.png`) corre riesgo de leerse como una **lápida tumbada**, justo lo que pidió evitar la guía: lo marco como la pieza más débil del conjunto.
- **Legibilidad a 34 px reales**: en las hojas de 34 px el glifo solo se identifica con la ampliación ×4; a tamaño real (1 casilla ≈ 49–64 px en el juego, 34 px en celular chico) es una mancha con silueta de H. En las composiciones 1280×720 las marcas se ven pequeñas entre cactus y columnas; el glifo no se lee a primera vista salvo en el banderín y la tablilla.
- **El glifo se parece a una H de tipografía?** g1 y g3 se leen como signo; no lo doy por probado: el riesgo que marca RF-718 sigue abierto hasta que Lucas lo mire.

## Qué NO se probó

Nada se importó a Godot ni se vio en el motor (las composiciones son Pillow sobre capturas reales del PR #89/M79, sin arte integrado); el filtro de GPU real del mapa no se reprodujo (hay una aproximación trilineal); no hay celular simulado ni teléfono real; no se midió rendimiento ni peso en memoria; no se probó con el poste de campaña de los niveles 8 y 9; no se comprobó contraste/daltonismo; las casillas libres son las de la grilla, no se jugó el nivel. El nivel 15 mezcla rocas nuevas con las `rock_a`/`rock_b` existentes solo en una comparación.
