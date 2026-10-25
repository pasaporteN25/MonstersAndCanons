# T475 · Integración de los postes de campaña

> Escrito el 2026-10-25 por Claude (Sonnet 5.5). Rama `feature/t475-paquete-propuesta` (PR #83), segundo commit sobre el paquete de propuesta, con `origin/main` 299d48d mergeado. No se tocó ningún `data/levels/*.json`, ni `scenes/ui/campaign_map*`, `level_select`, `records` ni `presentation_host`.

## Veredicto

**Integración parcial: 18 de los 20 postes (13 de los 15 niveles).** Los niveles **8 y 9 quedan sin integrar**: la casilla aprobada `(0, 4)` es el símbolo de ruina canónico y el poste lo tapa por completo (captura del motor real). La tarea **sigue `[ ]`**.

## Aprobación de Lucas (registro literal)

Lucas, 2026-10-25, respuesta en sesión tras revisar el HTML con los 15 planos: aprobó **«Atlas + los 20 postes tal cual»**, incluidas las casillas de borde o sobre señal existente en los niveles 2, 4, 8 y 9. Es **una sola aprobación en bloque**; no hay aprobaciones por mapa separadas. Se registra en la columna «OK de Lucas» de `art/t475-paquete-postes/index.md` como «Aprobado 2026-10-25, en bloque, tras revisar el plano de cada nivel en el HTML de revisión». Posiciones: las 20 vigentes del índice (con los reemplazos del paquete: nivel 12 `(5,2)`, nivel 13 `(23,2)` y `(24,9)`).

La orden de integración decía además: si un poste tapa una señal canónica o no cabe visualmente (comprobado con captura del motor), no se mantiene. Esa condición se aplicó a los niveles 8 y 9 aunque la aprobación en bloque incluía su casilla; Lucas decide si prefiere otra casilla o mantener el poste encima de la señal.

## Qué se hizo

- **Datos visuales:** `data/ui/postes_campana.json` (posiciones por nivel; ningún número de balance). `CampaignPosts` (`scripts/logic/campaign_posts.gd`) las lee con tolerancia a archivo ausente o dañado, y decide la variante: solo 3 estrellas dan el poste del jugador.
- **Contexto hacia abajo:** `Game` calcula el contexto (campaña normal + estrellas del nivel) y lo pasa por `LevelData.build_map` → `Level.build` → `LevelDecor.paint`. `MapDrawings` y `LevelDecor` no consultan autoloads. Los postes se dibujan como capa superpuesta al final de `LevelDecor._draw`, con el arte existente (`poste_cintas`: `banner_post_enemy.png` y los banderines del editor); no hay arte nuevo.
- **Nivel 6:** su poste ya era el dibujo `p` de la leyenda; ahora cambia solo con 3 estrellas (antes, con cualquier victoria). La capa superpuesta no lo repite.
- **Aislamiento:** conquista y receta solo en campaña normal. Comunidad, modos (Asedio incluido), editor (probar), escena suelta y modo de pruebas usan la variante rebelde fija; el modo de pruebas no toma conquista ni receta del progreso normal. Los postes de la capa existen solo cuando se juega un nivel de campaña (con o sin modo de pruebas); no en comunidad, modos, editor ni escena suelta.
- **Herramienta de captura:** `tools/capture_t475_postes.tscn`.

## Verificación (números reales)

- `godot --headless --import`: código 0 al primer intento. Assets: `git status` limpio de assets; se borraron los `.png.import` sueltos de `Capturas/`.
- `tests/test_campaign_posts.gd` (17 tests, 7023 aserciones): 18 postes en 13 niveles (1 en 1–10, 2 en 11–15), posiciones exactas aprobadas, hash SHA-256 de los 15 JSON igual al «antes» del índice, cada poste sobre casilla `X` o dibujo no removible/no extracción/no construible/no señal, estructura jugable idéntica con y sin capa en los 15 mapas (tipos de casilla, suelo, entradas, salida, leyenda, removibles, curvas de camino), contexto 0/1/2/3 estrellas, nivel 6, receta, y aislamiento (pruebas con progreso normal en 3 estrellas, escena suelta, editor, comunidad, Asedio).
- `python3 tools/t475_planos_postes.py --verify`: «igual» en los 15 niveles.
- GUT completo: **primera corrida 2368/2370, con 2 fallos en `test_records.gd`** (`test_outside_the_campaign_nothing_is_recorded` y `test_a_new_record_asks_for_initials_even_when_losing`), sin `SCRIPT ERROR` ni `Parse Error`. `test_records.gd` solo pasa 11/11, y junto con `test_campaign_posts.gd` también. **Segunda corrida completa: 2370/2370, 32.219 aserciones, 0 `SCRIPT ERROR`/`Parse Error`.** No se determinó la causa del fallo de la primera corrida (no reproducible; ocurrió tras varias corridas parciales de la sesión); se informa sin darlo por resuelto.

## Capturas del motor real

`Capturas/T475-*.png`: partida de campaña real (escena `game.tscn`, ventana de 1280×720 con `DISPLAY=:0`, GTX 1660 Super, Godot 4.7.2, **sin** el host de presentación; resolución pedida a la ventana, no medida contra el compositor). Los 15 niveles con 0 estrellas; con 3 estrellas los niveles 1, 6, 11 y los de borde/señal 2, 4, 8 y 9 (en 8 y 9 sin poste, por el frenado). Más una ampliación del nivel 8 con el poste que tapaba la señal.

- Niveles 2 y 4 (columna y flores existentes, borde): el poste entra completo en el encuadre, sobre la decoración (la columna del 2 queda parcialmente detrás). No son señales canónicas: se mantienen.
- Niveles 11–15: los postes cercanos a señales (roca marcada del 11, símbolo de ruina del 14) no las cubren.
- Niveles 8 y 9: el símbolo A tallado queda totalmente oculto: frenados.

## Límites

No se probó en teléfono real ni en Windows; no se afirma rendimiento ni balance. No se probaron 2 estrellas con captura (sí con test: 1 y 2 estrellas dan el poste rebelde). Las capturas son a 1280×720, no a 1920×1080 ni en celular simulado. El arte de los postes es el existente. Falta que Lucas elija nueva casilla para los niveles 8 y 9 (o confirme el poste sobre la señal).

## Seguimiento (2026-10-25): sin el ítem de atrás

Lucas vio que los estandartes quedaban encima de otro ítem del mapa. Era así: casi todos los postes están sobre una casilla `X` (no construible), que el motor dibuja con un cactus, roca o hueso del tema (`blocked_decor`), y los niveles 2 a 5 los ponen sobre la columna o las flores de la leyenda. Se eligió **borrar el ítem de atrás, no mover el poste**: `LevelDecor._draw` dibuja solo el suelo en las casillas con poste (`overlay_post_cells()`), así las posiciones aprobadas no cambian. Es solo visual: ningún `data/levels/*.json` ni la grilla jugable cambian (la comparación estructural sigue igual). Las 23 capturas `Capturas/T475-*.png` se regeneraron con el cambio. Los niveles 8 y 9 siguen sin poste. No se probó en celular real ni a 1920×1080.
