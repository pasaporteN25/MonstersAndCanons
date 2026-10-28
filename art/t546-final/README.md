# T546 · Muestras del final, dos variantes (propuesta, sin aprobar)

Fecha: 2026-10-28. Tarea T546 (RF-729, D-219). **Nada está en `assets/` ni en el juego**: esperan el OK escrito de Lucas. Revisión visual: abrir `revision.html`.

## Qué hay

| Archivo | Variante | Qué es |
|---|---|---|
| `muestra_luminosa_01.png` | luminosa (3 estrellas en los 15) | Atardecer limpio; colonia con ventanas encendidas a la izquierda; fuegos y tiendas de los Moradores lejos, a la derecha. La más «de utilería» (la más cercana al mapa). |
| `muestra_luminosa_02.png` | luminosa | Composición espejada: colonia a la derecha, sol bajo y camino con fuegos alejándose por la izquierda. Más pictórica y cinematográfica. |
| `muestra_oscura_01.png` | oscura (cualquier otro caso) | Colonia a la izquierda con luz cálida; un frente de lluvia y nubes grises apagadas arriba a la derecha, sin ninguna forma reconocible. |
| `muestra_oscura_02.png` | oscura | Igual de base; la tormenta ocupa más cielo (grises con tintes verdosos y violetas). Más teatral. |

1920×1080 RGB (salida del generador de 1672×941 ampliada con Lanczos). `sources/`: salidas crudas, incluidas las **descartadas** (`descartada_*`: a1, b1, b2, b3) y dos que no pasaron a la presentación (`b5`, `b7`). `context/`: montajes con la franja de texto (16:9 y 21:9) y las referencias vigentes. `montar.py` los regenera.

## Compuerta de estilo (guía de arte §4, T540)

Referencias inspeccionadas: `assets/sprites/map/rendered/tree.png`, `rock_a.png`, `forest_idle.png`, `m79/cactus_02.png`, `assets/sprites/enemies/rendered/colossus.png` y la captura `art/t537-arte-campana/captures/level_15_active.png` (copiada en `context/juego_nivel15.png`).

- **Técnica:** PNG pintados con volumen esculpido y simplificado (no vector plano ni foto). **Perspectiva:** cámara elevada 3/4. **Material:** mate; rocas de basalto gordas con biseles y musgo; árboles de copa oliva con hojas grandes en capas. **Luz:** suave, arriba a la izquierda. **Paleta:** oliva, ocre, basalto carbón, teja; sin contorno negro ni resplandor. **Alfa:** ninguno (imagen opaca a pantalla completa). **Escala de uso:** 1280×720 de diseño, recortada con `COVERED` (en 21:9 se pierde un 25 % del alto).
- La imagen vigente de T233 (`context/vigente_epilogue_t233.png`) se usó **solo como idea de composición** (colonia iluminada, fuegos lejanos), no como estilo.

**Veredicto honesto.** Las muestras reproducen bien las rocas, los árboles, el pasto y el camino del mapa, pero **no son idénticas a él**: tienen más detalle y paisaje (lago, puente, cielo, montañas) que cualquier recurso del mapa; es la parte del encargo que el generador no sabe contener. La luminosa 02 y la oscura 02 se alejan más del mapa que las 01. Lucas decide si ese grado de paisaje es aceptable.

## Lo que se probó y lo que no

- Se vieron a escala real con la franja de texto de `EpilogueScreen` (230 px, 78 % de opacidad, 3 líneas de 22 px, botones) en 16:9 y en 21:9: la frase y los botones se leen en las cuatro, porque el tercio inferior salió calmo.
- **Los montajes son del script `montar.py`, NO capturas del motor** (la fuente es DejaVu, no la del juego; los botones son un dibujo aproximado). No se integró nada, así que tampoco se corrió GUT: es solo documentación y arte, sin código.
- No se probó en celular; no se midió contraste con herramienta (a ojo).

## Preguntas para Lucas

1. ¿Cuál de las dos luminosas (01 o 02) y cuál de las dos oscuras (01 o 02)? ¿Preferís que ambas variantes compartan la composición (colonia a la izquierda), como pide RF-729 («la misma composición base»)? Hoy `luminosa_01` y `oscura_01`/`02` comparten la colonia a la izquierda, pero no son la misma escena pixel a pixel: el generador no permite eso. Si querés que se lean como la **misma** escena, habría que generar una y editar el cielo (otra ronda).
2. ¿Te cierra el nivel de paisaje (lago, puente, montañas) o lo querés más contenido, como el mapa?
3. La luminosa tiene fuegos de los Moradores a lo lejos (idea de T233) y la oscura no los tiene (en las rondas 2 y 3 aparecieron como incendios y se descartaron). ¿Está bien que la oscura no muestre a los Moradores?
4. Procedencia: salida de la herramienta de imagen de Codex, como en T244, T540 y T463. ¿Está bien como arte final?
5. Resolución: 1920×1080 es una ampliación del 15 % de lo que entrega el generador. ¿Alcanza o querés otra vía?
