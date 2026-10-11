# T241 · 🎨 Láminas de la intro

> **Estado: PENDIENTE. Espera el OK de Lucas al guion (G6, T240) y al estilo (la lámina de prueba de abajo).** El guion es `specs/intro/guion.md`; la spec, **M57** (`01-spec.md`, RF-497 a RF-501); la decisión, **D-096**.

- **Ejecutor:** **Codex** · **Depende de:** T240 (**escrita**; falta el OK de Lucas) · **Compuerta:** 🎨 Lucas aprueba **una lámina de prueba** (estilo) antes de hacer el resto · **Tamaño:** mediano

## Leer
`specs/tareas/README.md` §6, **`specs/intro/guion.md` entero** (sobre todo §3 «Hoja de continuidad», §4 «Las siete láminas» y §6 «Dos referencias de estilo»), `specs/10-universo.md` (§3 «Aspecto de la expedición», §1 y §6) y `.claude/rules/arte.md`. La guía de arte (`05`) es de sprites de 64 px: **de ahí vale la paleta de la familia A (hierro, bronce y madera)** y nada más; las láminas no son SVG.

## Entregables
- **Siete láminas**, una por cada una del guion: **PNG de 1920 × 1080 (16:9)**, **sin texto dentro** (el texto lo pone el juego).
- **El 22 % de abajo (de y = 842 a y = 1080) es la zona del texto:** tranquila, oscura y sin nada que importe; el juego pone ahí una franja. **La lámina se ve entera** (no se recorta): no hace falta un «área segura» lateral.
- **Coherencia:** la misma nave, los mismos cuatro colonos y el mismo oasis en todas, según la **hoja de continuidad** (`guion.md` §3). Hierro, bronce, cristal y mecanismos: sin láseres, sin trajes espaciales, sin armas (07 §2).
- **Lo que no aparece:** los Moradores, animales o criaturas, ruinas, el **símbolo A**, humo o fuegos en el horizonte, el nombre del planeta. **El verde solo desde la lámina 4**, como punto; la 7 es lo único vivo (guion de color de `guion.md` §3).
- Fuentes, prompts y manifest en `art/intro-v1/` (como `art/redesign-m43/`: `sources/`, `prompts.md`, `manifest.json`). Los finales, en `assets/intro/` con los nombres del manifest (`01_la_nave.png`, `02_la_bodega.png`, `03_los_turnos.png`, `04_la_ventana.png`, `05_el_descenso.png`, `06_los_motores_apagados.png`, `07_el_oasis.png`).
- **Una hoja con las siete en miniatura**, para revisar la continuidad.

## Pasos
1. **Lámina de prueba: la 7, en las dos referencias de estilo** (A «Cuaderno de bitácora» y B «Diapositiva pintada»), para que Lucas compare con lo mismo adelante. **Lucas elige una (o pide mezclar).** Sin su OK no se sigue.
2. **El resto de las láminas** (1 a 6) en el estilo elegido. Cuidar la nave y **la ingeniera** (aparece en la 2, 3, 4 y 6) y que el herrero sea el mismo en la 2, la 4 y la 7.
3. **La hoja de miniaturas** y la revisión de Lucas **antes del PR**.

## Hecho cuando
Las siete láminas aprobadas y en `assets/intro/`, con fuentes, prompts y manifest. Cada una mide 1920 × 1080 y pesa lo razonable (anotar cuánto: T242 mide el total en la APK). Commit `T241: …` y PR.

## Frenar si
- Lucas no contestó P3 (estilo) o pidió cambiar el guion: **no dibujar** hasta tener el texto de cada lámina final.
- Una lámina no se puede dibujar sin romper la hoja de continuidad (por ejemplo, la 6 con la palanca y el candado): **preguntar** en el PR en vez de inventar.
- Aparece sola una marca que se parece a una **A** o un símbolo (por ejemplo, las rayitas de tiza de la lámina 3 o el círculo del mapa): **repetir**, no dejarla.
