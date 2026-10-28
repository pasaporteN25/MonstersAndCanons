# T533 · Inventario de textos visibles del juego

*Generado con `python3 tools/localization_inventory.py` (solo lee el proyecto). Es una heurística: son **candidatos**, no una lista cerrada ni una traducción. Lucas revisa este documento antes de T534; todavía no se tradujo nada.*

## Resumen

- Candidatos a texto visible: **1609** en **166** archivos.
- Por tipo de fuente: GDScript **1150**, Escenas (.tscn) **108**, Recursos (.tres) **60**, Datos (.json) **291**.

| Pantalla / grupo | Archivos | Candidatos | Con placeholder | Concatenados | Plural | Multilínea |
|---|---:|---:|---:|---:|---:|---:|
| Menú principal y navegación | 5 | 18 | 3 | 0 | 0 | 0 |
| Opciones | 2 | 44 | 3 | 0 | 0 | 1 |
| Selector de campaña y mapa | 9 | 78 | 26 | 1 | 6 | 8 |
| Introducción, nivel y presentación | 8 | 119 | 64 | 0 | 1 | 16 |
| Niveles (nombre, lugar, entrada, victoria) | 15 | 61 | 0 | 0 | 0 | 0 |
| HUD y partida | 23 | 331 | 138 | 9 | 25 | 16 |
| Pausa y confirmaciones de salida | 3 | 17 | 2 | 0 | 2 | 1 |
| Tutorial | 3 | 71 | 27 | 0 | 3 | 1 |
| Consejos de derrota | 3 | 51 | 42 | 0 | 0 | 0 |
| Resultados, epílogo y créditos | 7 | 35 | 10 | 0 | 0 | 0 |
| Récords, iniciales y Salón de la fama | 5 | 16 | 2 | 0 | 0 | 1 |
| Wiki (pantalla y artículos) | 22 | 240 | 34 | 0 | 17 | 3 |
| Torres (nombre, descripción, mejoras) | 14 | 71 | 35 | 4 | 6 | 1 |
| Enemigos y jefes | 20 | 40 | 2 | 0 | 2 | 0 |
| Modos (Asedio y otros) | 2 | 37 | 28 | 2 | 0 | 1 |
| Novedades | 3 | 64 | 30 | 0 | 2 | 1 |
| Editor de mapas y comunidad | 12 | 287 | 104 | 29 | 9 | 11 |
| Mensajes técnicos y de desarrollo (a decidir si se traducen) | 9 | 27 | 6 | 0 | 0 | 0 |
| Coleccionables y hallazgos | 1 | 2 | 2 | 0 | 0 | 0 |
| **Total** | **166** | **1609** | **558** | **45** | **73** | **61** |

## Cómo leer los candidatos

- Los literales de GDScript incluyen algunos falsos positivos (nombres de nodos, formatos de depuración, ids con mayúscula). En la revisión se descartan; los **falsos negativos** más probables son textos armados con `str()`/`%` desde varias piezas sueltas y textos de una sola palabra en minúscula.
- Las escenas `.tscn` listan `text`, `tooltip_text`, `placeholder_text` y `title`. Los recursos `.tres` listan `display_name`, `description` y similares. Los `.json` listan los valores de texto (se excluyen ids, temas, dibujos y rutas).
- No entran: documentación de desarrollo (`specs/`, `README`…), nombres de archivo e identificadores, `print`/`push_error` (solo consola), tests.
- Los textos generados en tiempo de ejecución (marcados `placeholder`, `concatenado`, `plural`) están en las tablas de abajo; cada uno necesita una clave con placeholders nombrados.

## Estrategia de claves y rutas de cobertura

- **Infraestructura (T533):** `Localization` (`scripts/logic/localization.gd`) con catálogos `data/i18n/es.json` y `data/i18n/en.json`; `LocalizationCatalog` valida claves ausentes, duplicadas y placeholders. El idioma se guarda en `settings.language` (por omisión `es`) sin tocar `SAVE_VERSION` ni progreso. El selector en Opciones queda **oculto** (`Localization.SELECTOR_ENABLED = false`) hasta que T534 complete el inglés.
- **Claves estables en inglés**, con puntos, por dominio: `menu.main.play`, `options.audio.music`, `level.level_01.entry`, `tower.basic.name`, `wiki.teclas.b3`, `enemy.armored.description`, `hud.wave`. Nunca se usa el texto en español como clave.
- **Escenas y GDScript:** el literal pasa a `Localization.t(&"clave")`; los valores van con `Localization.t_fmt(&"clave", {"n": 3})` y placeholders `{n}`. Las concatenaciones se reescriben como una frase con placeholders; los plurales usan `clave.one` / `clave.other` (`t_plural`).
- **Datos (`data/`):** el texto en español queda como valor base (no cambia balance ni guardados); el inglés vive en `data/i18n/en.json` bajo `<dominio>.<id>.<campo>`.
- **Wiki, tutorial, intro, consejos, novedades, créditos:** por bloque/lámina/regla con índice estable (`wiki.<articulo>.b<n>`).
- **Accesibilidad y tooltips:** `tooltip_text`, `placeholder_text` y cualquier texto para lector de pantalla entran al mismo catálogo.
- **No se traducen:** ids, nombres de archivo, teclas internas, símbolos canónicos y nombres propios del canon (ver decisiones).

## Puntos a decidir por Lucas antes de T534

- Nombres propios del canon (Cántaro, Compañía Meridiana, Moradores, lugares de niveles, jefes): ¿se conservan en español o tienen versión inglesa? `specs/10-universo.md` no define una.
- Los textos de `specs/11-textos-lore.md` (lugar/entrada/victoria, epílogo, créditos, Lore) son canon en español; ¿quién traduce y aprueba el inglés?
- Nombre del juego y siglas visibles («Monsters & Canons»), y las iniciales de récords de 3 y 5 letras.
- Formato de números, fechas y versión (`GameVersion`) según idioma.
- Mientras `specs/11-textos-lore.md` siga como borrador, ¿los textos de Lore se traducen en T534 o después?

## Detalle por pantalla y fuente

### Menú principal y navegación

<details><summary><code>scenes/ui/main_menu.tscn</code> · Escenas (.tscn) · 6</summary>

- L63 `[text] Jugar`
- L70 `[text] Récords`
- L77 `[text] Wiki`
- L85 `[text] Herramientas`
- L92 `[text] Opciones`
- L99 `[text] Salir`

</details>

<details><summary><code>scenes/ui/tools_hub.gd</code> · GDScript · 2</summary>

- L6 `Editor de mapas`
- L7 `Editor de banderines`

</details>

<details><summary><code>scenes/ui/tools_hub.tscn</code> · Escenas (.tscn) · 4</summary>

- L49 `[text] Herramientas`
- L57 `[text] Editor de mapas`
- L65 `[text] Editor de banderines`
- L73 `[text] Volver`

</details>

<details><summary><code>scripts/autoload/game_flow.gd</code> · GDScript · 1</summary>

- L515 `Transition`

</details>

<details><summary><code>scripts/logic/game_version.gd</code> · GDScript · 5</summary>

- L8 `Beta`
- L23 `%s %s` `placeholder`
- L25 `Versión %s` `placeholder`
- L26 `%s %s` `placeholder`
- L32 `^(\\d+)\\.(\\d+)\\.(\\d+)(?:[-+](.+))?$`

</details>

### Opciones

<details><summary><code>scenes/ui/options_menu.gd</code> · GDScript · 28</summary>

- L13 `Activar modo de pruebas`
- L14 `Volver al juego normal`
- L16 `Tutorial del nivel 1`
- L17 `Volver a verlo`
- L18 `Se verá en el nivel 1`
- L20 `Presentación de los jefes`
- L22 `Consejos en la derrota`
- L24 `Círculo de alcance`
- L26 `Tecla de «Ver todo»`
- L27 `Presioná una tecla…`
- L28 `Restaurar`
- L30 `Novedades de esta versión`
- L31 `No hay novedades`
- L34 `Sonido`
- L34 `Pantalla`
- L34 `Partida y ayudas`
- L34 `Controles`
- L34 `Avanzado`
- L220 `OptionsPage%d` `placeholder`
- L232 `Tab%d` `placeholder`
- L233 `Partida ⏎ y ayudas` `multilinea`
- L359 `Oculto`
- L360 `Sutil`
- L361 `Completo`
- L465 `Esa tecla ya la usa %s. Elegí otra.` `placeholder`
- L536 `Interfaz`
- L541 `Automática`
- L542 `Celular`

</details>

<details><summary><code>scenes/ui/options_menu.tscn</code> · Escenas (.tscn) · 16</summary>

- L56 `[text] Opciones`
- L84 `[text] Sonido`
- L89 `[text] Volumen de la música`
- L101 `[text] Volumen de los efectos`
- L114 `[text] Pantalla`
- L120 `[text] Pantalla completa`
- L126 `[text] Mostrar números de daño`
- L132 `[text] Animaciones de mejora`
- L144 `[text] Créditos y versión`
- L150 `[text] Beta`
- L157 `[text] Ver créditos`
- L164 `[text] Administración`
- L171 `[text] Activar modo de pruebas`
- L200 `[text] Sí, activar`
- L208 `[text] Cancelar`
- L215 `[text] Volver`

</details>

### Selector de campaña y mapa

<details><summary><code>data/progression.json</code> · Datos (.json) · 1</summary>

- `[disruptor.nombre] Disruptora`

</details>

<details><summary><code>data/ui/marcas_campana.json</code> · Datos (.json) · 1</summary>

- `[nota] T507, RF-717: marcas (señales) que la campaña dibuja como capa visual, por nivel: casilla (x, y) y tipo. Hoy solo las 28 señales grabadas de la tabla …`

</details>

<details><summary><code>data/ui/postes_campana.json</code> · Datos (.json) · 2</summary>

- `[nota] T475, RF-696: casillas (x, y) donde la campaña dibuja un poste como capa visual. Aprobadas por Lucas el 2026-10-25 (Atlas + los 20 postes tal cual). S…`
- `[sin_integrar] Niveles 8 y 9: la casilla aprobada (0, 4) es el símbolo de ruina canónico y el poste lo tapa por completo en la captura del motor; frenados ha…`

</details>

<details><summary><code>scenes/ui/campaign_map_view.gd</code> · GDScript · 9</summary>

- L93 `Region_%d` `placeholder`
- L109 `../Region_%d` `placeholder`
- L113 `../Region_%d` `placeholder`
- L183 `%s · %s` `placeholder`
- L234 `Ganá el nivel anterior para abrirla`
- L236 `%s · sin victorias todavía` `placeholder`
- L237 `%s · %d de 3 estrellas` `placeholder`
- L361 `Jugar`
- L390 `ATLAS MERIDIANO · CÁNTARO`

</details>

<details><summary><code>scenes/ui/campaign_region.gd</code> · GDScript · 3</summary>

- L77 `Nivel %d · %s · %s` `placeholder`
- L79 ` · %d de 3 estrellas` `placeholder`
- L108 `%s · %s` `placeholder`

</details>

<details><summary><code>scenes/ui/level_select.gd</code> · GDScript · 41</summary>

- L104 `Comunidad`
- L252 `Estrellas: %d de %d` `placeholder`
- L259 `%d %s` `placeholder,plural`
- L264 `Abrir carpeta del modo` `plural`
- L264 `Abrir carpeta de mapas` `plural`
- L382 `%s (con errores)` `placeholder`
- L416 `Modo con errores`
- L419 `Este modo todavía no tiene mapas. ⏎  ⏎ En el editor de mapas, \"Guardar en un modo\" los agrega.` `multilinea`
- L420 `0 mapas`
- L430 `Estrellas: %d de %d` `placeholder`
- L442 `Mapa %d ⏎ %s ⏎ %d oleadas ⏎ %s ⏎  ⏎ ` `multilinea,placeholder`
- L453 `Bloqueado`
- L456 `Mejor: %d vidas` `placeholder`
- L457 `¡Jugar!`
- L462 `%s ⏎ Con errores ⏎  ⏎  ⏎ ` `multilinea,placeholder`
- L477 `Pruebas`
- L480 `Oleada inicial`
- L484 `Oro inicial`
- L486 `Automático`
- L495 `Si pasa del total del nivel, se usa la última oleada.`
- L567 `Estandarte mecánico: requiere cinco avances de niveles1–5 (%d/5).` `placeholder`
- L569 `Avance de este nivel: %s. Una pieza distinta por nivel1–5.` `placeholder,plural`
- L586 `Badge`
- L621 `Nivel %d` `placeholder`
- L621 `Nivel %d · %d oleadas` `placeholder`
- L635 `Place`
- L639 ` ⏎ ` `concatenado,multilinea`
- L698 `Torres  ·  %d` `placeholder`
- L732 ` ⏎ ` `multilinea,plural`
- L732 ` · Nueva` `plural`
- L747 `Badge_%s` `placeholder`
- L767 `%s ⏎ %d oleadas ⏎ %s ⏎  ⏎ ` `multilinea,placeholder`
- L795 `Stars`
- L803 `Status`
- L811 `Todavía no hay mapas de la comunidad. ⏎  ⏎ Copiá archivos .json a esta carpeta y aparecen acá: ⏎ %s ⏎  ⏎ Los mapas que hacés con el editor de mapas también a…` `multilinea,placeholder`
- L813 `Todavía no hay mapas de la comunidad. ⏎  ⏎ En el celular no se pueden agregar mapas: usá la versión de computadora.` `multilinea`
- L831 `Bloqueado`
- L833 `Mejor: %d vidas` `placeholder`
- L834 `¡Jugar!`
- L841 `Mejor: %d vidas` `placeholder`
- L842 `¡Jugar!`

</details>

<details><summary><code>scenes/ui/level_select.tscn</code> · Escenas (.tscn) · 9</summary>

- L87 `[text] Elegir nivel`
- L102 `[text] Estrellas: 0 de 15`
- L160 `[text] Campaña`
- L169 `[text] Comunidad`
- L203 `[text] Vista:`
- L212 `[text] Tarjetas`
- L220 `[text] Mapa`
- L229 `[text] Abrir carpeta de mapas`
- L237 `[text] Volver`

</details>

<details><summary><code>scripts/logic/banner_catalog.gd</code> · GDScript · 8</summary>

- L11 `Meridiana`
- L12 `Brasa`
- L13 `Musgo`
- L14 `Marea`
- L18 `Chevron`
- L19 `Rombo`
- L20 `Estrella`
- L21 `Franja`

</details>

<details><summary><code>scripts/logic/campaign_map.gd</code> · GDScript · 4</summary>

- L159 `Bloqueada`
- L161 `Disponible`
- L163 `Presencia rebelde`
- L164 `Zona tomada`

</details>

### Introducción, nivel y presentación

<details><summary><code>data/intro/intro.json</code> · Datos (.json) · 7</summary>

- `[laminas.0.texto] La Compañía Meridiana mandó una sola nave. No lleva soldados: lleva gente de oficio.`
- `[laminas.1.texto] Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio. Hay semillas, planos y piezas para empezar de cero.`
- `[laminas.2.texto] Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo. Era un viaje de ida.`
- `[laminas.3.texto] El reconocimiento vio agua en un solo lugar de todo el planeta. Hacia ahí apuntó la nave.`
- `[laminas.4.texto] La bajada fue brusca. El casco crujió entero, pero aguantó.`
- `[laminas.5.texto] Los motores se apagaron al tocar tierra. La nave ya no va a despegar.`
- `[laminas.6.texto] Un valle chico, con agua y pasto, en medio de la nada. Acá nos quedamos.`

</details>

<details><summary><code>scenes/ui/boss_presentation.gd</code> · GDScript · 11</summary>

- L20 `¡Llega el Jefe!`
- L21 `Tocá para seguir`
- L22 `Clic o cualquier tecla para seguir  ·  P deja la pausa`
- L63 `Root`
- L68 `Backdrop`
- L83 `Column`
- L89 `Title`
- L91 `Illustration`
- L98 `Name`
- L99 `Line`
- L100 `Hint`

</details>

<details><summary><code>scenes/ui/intro_screen.gd</code> · GDScript · 1</summary>

- L19 `Omitir`

</details>

<details><summary><code>scenes/ui/level_intro.gd</code> · GDScript · 2</summary>

- L25 `Tocá en cualquier parte para empezar.`
- L26 `Hacé clic en cualquier lugar, o apretá cualquier tecla, para empezar.`

</details>

<details><summary><code>scenes/ui/level_intro.tscn</code> · Escenas (.tscn) · 5</summary>

- L73 `[text] Nivel`
- L82 `[text] Lugar`
- L91 `[text] Entrada`
- L101 `[text] Empezar`
- L108 `[text] Tocá en cualquier parte para empezar.`

</details>

<details><summary><code>scripts/logic/intro_data.gd</code> · GDScript · 21</summary>

- L32 `intro: no existe el archivo %s.` `placeholder`
- L36 `intro: no se pudo abrir %s.` `placeholder`
- L41 `intro: %s no es un JSON válido (línea %d: %s).` `placeholder`
- L50 `intro: el archivo tiene que ser un objeto con \"version\" y \"laminas\".`
- L54 `intro: \"version\" tiene que ser %d.` `placeholder`
- L58 `intro: \"fundido_s\" tiene que ser un número de 0 a %s segundos.` `placeholder`
- L63 `intro: \"laminas\" tiene que ser una lista de láminas.`
- L67 `el mínimo es %d` `placeholder`
- L67 `el máximo es %d` `placeholder`
- L68 `hay %d láminas y %s.` `placeholder`
- L88 `la lámina %d tiene que ser un objeto con \"imagen\", \"texto\" y \"segundos\".` `placeholder`
- L96 `la lámina %d: \"imagen\" tiene que ser una ruta que empiece con res://.` `placeholder`
- L98 `la lámina %d no encuentra la imagen '%s'.` `placeholder`
- L103 `la lámina %d: \"texto\" tiene que ser un texto entre comillas.` `placeholder`
- L110 `la lámina %d: \"segundos\" tiene que ser un entero de %d a %d.` `placeholder`
- L120 `la lámina %d tiene el texto vacío.` `placeholder`
- L125 `la lámina %d: el texto tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).` `multilinea,placeholder`
- L129 `la lámina %d tiene %d líneas y el máximo es %d.` `placeholder`
- L131 `la lámina %d tiene %d caracteres y el máximo es %d.` `placeholder`
- L134 `la lámina %d: la línea %d está en blanco.` `placeholder`
- L136 `la lámina %d: la línea %d tiene %d caracteres y el máximo por línea es %d.` `placeholder`

</details>

<details><summary><code>scripts/logic/intro_doc.gd</code> · GDScript · 62</summary>

- L10 `Ajustes generales`
- L11 `Lámina`
- L12 `sin voz`
- L12 `sin sonido`
- L27 `sin título`
- L33 `{ ⏎ ` `multilinea`
- L34 `\t\"version\": %s, ⏎ ` `multilinea,placeholder`
- L36 `\t\"fundido_s\": %s, ⏎ ` `multilinea,placeholder`
- L37 `\t\"laminas\": [ ⏎ ` `multilinea`
- L41 `\t\t{ ⏎ ` `multilinea`
- L42 `\t\t\t\"imagen\": %s, ⏎ ` `multilinea,placeholder`
- L43 `\t\t\t\"texto\": %s, ⏎ ` `multilinea,placeholder`
- L44 `\t\t\t\"segundos\": %s ⏎ ` `multilinea,placeholder`
- L45 `\t\t}%s ⏎ ` `multilinea,placeholder,plural`
- L46 `\t] ⏎ } ⏎ ` `multilinea`
- L53 `# Intro del juego: textos y tiempos`
- L55 `Este documento es una **vista editable** de 'data/intro/intro.json'. El juego lee ese JSON, no este archivo.`
- L57 `**Cómo se usa** (más detalle en 'CONTENIDO.md'):`
- L59 `1. Cambiá lo que quieras: el texto de cada lámina, los segundos, el fundido o la imagen.`
- L60 `2. Para ver si quedó bien sin guardar nada: 'godot --headless --path . -s tools/intro_doc.gd -- import --dry'.`
- L61 `3. Para pasarlo al juego: 'godot --headless --path . -s tools/intro_doc.gd -- import'. Si hay un error, lo dice con el número de línea y **no cambia nada**.`
- L62 `4. Para volver a empezar desde lo que carga el juego: '... -- export' (conserva las notas).`
- L64 `**Reglas** (las mismas que revisa el juego): de 5 a 8 láminas; el texto, de 1 o 2 líneas, hasta %d caracteres por línea y %d en total; los segundos, un númer…` `placeholder`
- L66 `Cada línea del texto empieza con '> '. Las **notas** son solo para vos: no se cargan al juego. La intro no tiene voces ni sonidos propios, así que «Voz o son…`
- L68 `## %s` `placeholder`
- L70 `- Versión del formato: %s` `placeholder`
- L72 `- Fundido entre láminas (segundos): %s` `placeholder`
- L78 `## %s %d · %s` `placeholder`
- L80 `- Imagen: %s` `placeholder`
- L81 `- Segundos: %s` `placeholder`
- L82 `- Voz o sonido: ninguno`
- L84 `Texto:`
- L89 `Notas:`
- L95 ` ⏎ ` `multilinea`
- L109 ` ⏎ ` `multilinea`
- L127 `línea %d: no entiendo la sección «%s» (tiene que ser «%s» o «%s N»).` `placeholder`
- L139 `línea %d: la lámina %d tiene dos bloques «Texto:».` `placeholder`
- L151 `línea %d: en la lámina %d cada línea del texto tiene que empezar con «> » (o escribí «Notas:» antes de las notas).` `placeholder`
- L161 `fundido entre láminas: %s → %s` `placeholder`
- L161 `por omisión`
- L161 `por omisión`
- L165 `cantidad de láminas: %d → %d` `placeholder`
- L171 `lámina %d, %s: %s → %s` `placeholder`
- L181 `falta la sección «%s» (con la versión del formato).` `placeholder`
- L183 `línea %d: en «%s» falta «Versión del formato».` `placeholder`
- L187 `«Versión del formato» tiene que ser un número (dice «%s»).` `placeholder`
- L193 `«Fundido entre láminas» tiene que ser un número de segundos (dice «%s»).` `placeholder`
- L202 `línea %d: el título dice «Lámina %d» pero es la %d.ª del documento; se usa el orden del documento.` `placeholder`
- L204 `la lámina %d (línea %d) no tiene «Imagen».` `placeholder`
- L208 `la lámina %d (línea %d) no tiene «Texto:».` `placeholder`
- L210 ` ⏎ ` `multilinea`
- L212 `la lámina %d (línea %d) no tiene «Segundos».` `placeholder`
- L216 `la lámina %d (línea %d): «Segundos» tiene que ser un número entero (dice «%s»).` `placeholder`
- L220 `la lámina %d: «Voz o sonido» dice «%s», pero la intro no tiene voces ni sonidos (RF-499): no se carga.` `placeholder`
- L222 ` ⏎ ` `multilinea`
- L233 `la lámina %d dura %d s y su texto pide al menos %d s para leerse (regla del guion); el juego la acepta igual.` `placeholder`
- L244 `línea %d: no entiendo «%s» (se espera «- Clave: valor»).` `placeholder`
- L262 `línea %d: «Texto:» y «Notas:» van solas en su línea y lo que escribas va debajo (el texto, con «> » adelante).` `placeholder`
- L264 `línea %d: no conozco el campo «%s».` `placeholder`
- L266 `línea %d: «%s» está repetido%s.` `placeholder`
- L266 ` en la lámina %d` `placeholder`
- L266 ` en los ajustes`

</details>

<details><summary><code>scripts/logic/level_texts.gd</code> · GDScript · 10</summary>

- L33 `textos: tiene que ser un objeto con %s, como {\"lugar\": \"El paso del agua\"}.` `placeholder`
- L38 `textos: clave desconocida \"%s\" (se usan: %s).` `placeholder`
- L44 `textos \"%s\": tiene que ser un texto entre comillas.` `placeholder`
- L48 `textos \"%s\" está vacío: sacá la clave si no querés texto.` `placeholder`
- L51 `textos \"%s\": tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).` `multilinea,placeholder`
- L89 `textos \"%s\" tiene %d líneas y el máximo es %d.` `placeholder`
- L91 `textos \"%s\" tiene %d líneas y el mínimo es %d.` `placeholder`
- L93 `textos \"%s\" tiene %d caracteres y el máximo es %d.` `placeholder`
- L96 `textos \"%s\": la línea %d está en blanco.` `placeholder`
- L98 `textos \"%s\": la línea %d tiene %d caracteres y el máximo por línea es %d.` `placeholder`

</details>

### Niveles (nombre, lugar, entrada, victoria)

<details><summary><code>data/levels/level_01.json</code> · Datos (.json) · 4</summary>

- `[nombre] Pradera`
- `[textos.lugar] Campamento de aterrizaje`
- `[textos.entrada] La nave quedó en el borde del oasis. Hay agua, pasto y un terreno firme donde armar el campamento. Antes de descargar, hay que defenderlo.`
- `[textos.victoria] Campamento asegurado. Las primeras torres quedaron en pie. La carga de la nave se baja esta noche.`

</details>

<details><summary><code>data/levels/level_02.json</code> · Datos (.json) · 4</summary>

- `[nombre] Desfiladero`
- `[textos.lugar] El paso del agua`
- `[textos.entrada] El agua dulce más cercana está al otro lado del desfiladero. Sin ese paso, el campamento no aguanta. Hay que sostenerlo antes de tender las …`
- `[textos.victoria] Paso asegurado. El agua llega al campamento por primera vez. Faltan tres tramos de cañería.`

</details>

<details><summary><code>data/levels/level_03.json</code> · Datos (.json) · 4</summary>

- `[nombre] Encrucijada`
- `[textos.lugar] Las huertas`
- `[textos.entrada] Al norte del campamento hay tierra buena para sembrar. Dos caminos se cruzan justo ahí, y por los dos llegan manadas. Sin huerta no hay cose…`
- `[textos.victoria] Huertas aseguradas. Se sembró el primer surco. Lo que crezca depende de que las torres aguanten.`

</details>

<details><summary><code>data/levels/level_04.json</code> · Datos (.json) · 4</summary>

- `[nombre] Espiral`
- `[textos.lugar] El pozo`
- `[textos.entrada] El arroyo no alcanza para toda la colonia. Hay que cavar un pozo en el centro del valle. El camino hasta ahí da muchas vueltas: que les cues…`
- `[textos.victoria] Pozo terminado. Hay agua para toda la colonia. Se armó un turno de guardia para cuidarlo.`

</details>

<details><summary><code>data/levels/level_05.json</code> · Datos (.json) · 4</summary>

- `[nombre] Fortaleza`
- `[textos.lugar] La empalizada`
- `[textos.entrada] El campamento ya es un pueblo y todavía no tiene cerco. Hoy se cierra el primer perímetro. Lo que quede afuera, queda afuera.`
- `[textos.victoria] Empalizada cerrada. Es el primer perímetro de la colonia. Por primera vez, dormimos adentro.`

</details>

<details><summary><code>data/levels/level_06.json</code> · Datos (.json) · 4</summary>

- `[nombre] Nido`
- `[textos.lugar] El lindero`
- `[textos.entrada] El bosque empieza donde termina el cerco. Hay madera para varios años, y también criaturas que no habíamos visto. Del campamento empezaron a…`
- `[textos.victoria] Lindero asegurado. Se taló el primer tramo. La madera alcanza para dos casas.`

</details>

<details><summary><code>data/levels/level_07.json</code> · Datos (.json) · 4</summary>

- `[nombre] Cruce`
- `[textos.lugar] El aserradero`
- `[textos.entrada] El mejor sitio para cortar madera es un cruce de caminos. Se arma un aserradero, y para eso hay que despejar el terreno. Todo lo que estorbe…`
- `[textos.victoria] Aserradero en marcha. La colonia ya tiene madera propia. La primera carga sale mañana hacia el campamento.`

</details>

<details><summary><code>data/levels/level_08.json</code> · Datos (.json) · 4</summary>

- `[nombre] Bastión`
- `[textos.lugar] El bastión sobre ruinas`
- `[textos.entrada] Sobre la loma hay muros de piedra vieja, a medio enterrar. Las rocas tienen la misma marca que las del campamento. Alguien la puso antes que…`
- `[textos.victoria] Bastión asegurado. La colonia tiene una posición alta sobre la loma. Los muros son de otros; los usamos igual.`

</details>

<details><summary><code>data/levels/level_09.json</code> · Datos (.json) · 4</summary>

- `[nombre] Taller asediado`
- `[textos.lugar] El taller`
- `[textos.entrada] Entre las ruinas hay un galpón que puede servir de taller. Los que lo rodean no parecen animales: algunos curan a los suyos. Hoy se prueba e…`
- `[textos.victoria] Taller asegurado. El horno se encendió por primera vez fuera del oasis. La forja ya no depende de lo que trajo la nave.`

</details>

<details><summary><code>data/levels/level_10.json</code> · Datos (.json) · 4</summary>

- `[nombre] La mina vieja`
- `[textos.lugar] Primer puesto de abastecimiento`
- `[textos.entrada] Las galerías ya estaban cavadas cuando llegamos. Si se las retoma, la colonia tiene mineral a pocos días del campamento. Hay que sostener la…`
- `[textos.victoria] Mina asegurada. Es el primer puesto de abastecimiento de la colonia. Las galerías no las cavamos nosotros, y nadie vino a reclamarlas.`

</details>

<details><summary><code>data/levels/level_11.json</code> · Datos (.json) · 4</summary>

- `[nombre] Puesto seco`
- `[textos.lugar] El punto de agua`
- `[textos.entrada] Pasada la mina, el camino se vuelve seco. Los dos pozos que hay ya tenían huellas alrededor. Desde hoy, algunas torres se apagan sin que nad…`
- `[textos.victoria] Informe del puesto seco: paso asegurado. Dos pozos quedaron dentro del perímetro.`

</details>

<details><summary><code>data/levels/level_12.json</code> · Datos (.json) · 4</summary>

- `[nombre] El cañadón`
- `[textos.lugar] El paso hacia el norte`
- `[textos.entrada] El único paso hacia el norte es un cañadón de paredes altas. Los tiros vuelven contra las torres, como si las paredes los devolvieran. Cruza…`
- `[textos.victoria] Cañadón asegurado. El paso al norte quedó abierto. En las paredes quedaron las marcas de los tiros que volvieron.`

</details>

<details><summary><code>data/levels/level_13.json</code> · Datos (.json) · 4</summary>

- `[nombre] Paso alto`
- `[textos.lugar] El camino al resto de la región`
- `[textos.entrada] En el paso alto el camino se parte en dos. Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apaga torres. Hay hitos …`
- `[textos.victoria] Paso alto asegurado. La región queda comunicada con el valle. Los hitos quedaron del lado de adentro.`

</details>

<details><summary><code>data/levels/level_14.json</code> · Datos (.json) · 4</summary>

- `[nombre] Los poblados vacíos`
- `[textos.lugar] Asentamientos de los Moradores`
- `[textos.entrada] Los poblados están a la vista, pero no sale humo de ninguno. Los Moradores se llevaron lo que pudieron. Aun así, algo todavía defiende el lu…`
- `[textos.victoria] Los poblados están vacíos. Las brasas todavía están tibias.`

</details>

<details><summary><code>data/levels/level_15.json</code> · Datos (.json) · 5</summary>

- `[nombre] La Central`
- `[textos.lugar] Energía y abastecimiento`
- `[textos.entrada] Falta cerrar el valle: la central de energía y la línea que la une con la mina. Si se sostiene, la colonia queda asentada en esta región. Ho…`
- `[textos.victoria] Central encendida. La línea de abastecimiento está completa. La colonia tiene luz propia.`
- `[textos.epilogo] La central se encendió al anochecer. La colonia tiene, por primera vez, luz propia. Hay agua, energía y un camino de abastecimiento que une …`

</details>

### HUD y partida

<details><summary><code>data/ui/mejoras.json</code> · Datos (.json) · 7</summary>

- `[estadisticas.0.etiqueta] daño`
- `[estadisticas.4.etiqueta] área`
- `[estadisticas.5.etiqueta] púas`
- `[estadisticas.8.etiqueta] s de frenado`
- `[estadisticas.10.etiqueta] s de quemadura`
- `[estadisticas.11.etiqueta] s de pulso`
- `[estadisticas.13.etiqueta] reparación/s`

</details>

<details><summary><code>scenes/effects/effects_layer.gd</code> · GDScript · 8</summary>

- L32 `¡Combo de hielo!`
- L33 `¡Combo de fuego!`
- L93 `%d!` `placeholder`
- L141 `+%d` `placeholder`
- L171 `+%d` `placeholder`
- L208 `¡Rebote!`
- L375 `+%d` `placeholder`
- L384 `−%d oro` `placeholder`

</details>

<details><summary><code>scenes/game/build_controller.gd</code> · GDScript · 1</summary>

- L439 `Ahí no`

</details>

<details><summary><code>scenes/game/dev_panel.gd</code> · GDScript · 18</summary>

- L33 `Pruebas`
- L37 `Recursos`
- L38 `+1000 de oro`
- L39 `+10 recursos`
- L40 `Terminar demolición`
- L41 `Habilitar estandartes`
- L44 `Habilitar todas las colecciones`
- L47 `Vidas infinitas  [%s]` `placeholder`
- L50 `Partida`
- L51 `Saltar oleada  [%s]` `placeholder`
- L52 `Matar a todos  [%s]` `placeholder`
- L53 `Ganar`
- L54 `Perder`
- L55 `Simulación`
- L59 `Mostrar FPS`
- L67 `Velocidad  [%s / %s]` `placeholder`
- L109 `Rueda: cambiar enemigo. Clic: abrir la lista completa.`
- L127 `Aparecer`

</details>

<details><summary><code>scenes/game/game.gd</code> · GDScript · 31</summary>

- L17 `Récords del nivel`
- L19 `Volver al editor`
- L244 `← Editor`
- L244 `Volver al editor`
- L271 `Infrastructure`
- L330 `Ahí no hay nada para demoler ni habilitar`
- L338 `Ya hay una demolición en curso`
- L340 `El punto ya está activo`
- L342 `El punto está agotado`
- L344 `No se puede usar ahí`
- L346 `Faltan %d de oro` `placeholder`
- L353 `No se pudo`
- L382 `Faltan %d de oro` `placeholder`
- L383 `Demoledora`
- L383 `%d de oro` `placeholder`
- L519 `Faltan %d de oro` `placeholder`
- L628 `Acercaste el mapa. Tocá la lupa para volver a verlo entero.`
- L630 `Acercaste el mapa. Apretá %s para volver a verlo entero.` `placeholder`
- L645 `Pausa`
- L711 `Tutorial`
- L788 `Continuar`
- L879 `Pruebas [F1]`
- L966 `¡Desgaste!`
- L1188 `Faltan %d de oro` `placeholder`
- L1289 `¡Nuevo récord! Escribí tus iniciales`
- L1337 `conseguido aquí` `plural`
- L1337 `pendiente aquí` `plural`
- L1341 `oleada confirmada; pendiente del resultado` `plural`
- L1341 `completar oleada` `plural`
- L1344 `oleada confirmada; pendiente del resultado` `plural`
- L1344 `completar oleada` `plural`

</details>

<details><summary><code>scenes/game/hud.gd</code> · GDScript · 46</summary>

- L112 `%d FPS · %.1f ms/cuadro` `placeholder`
- L167 `Gold`
- L167 `Oro`
- L167 `Lives`
- L167 `Vidas`
- L167 `Score`
- L167 `Puntos`
- L167 `Wave`
- L167 `Oleada`
- L167 `Technology`
- L167 `Avances tecnológicos`
- L168 `Stat/` `concatenado`
- L168 `Icon` `concatenado`
- L223 `Recursos (solo de esta partida)`
- L289 `Seguir` `plural`
- L289 `Pausa` `plural`
- L289 `Seguir  [P]` `plural`
- L289 `Pausa  [P]` `plural`
- L295 `  [F]` `plural`
- L318 ` · encuentro opcional (grupo %.0f %%)` `placeholder`
- L379 `Nuevo enemigo: %s` `placeholder`
- L423 `Cañones`
- L542 `%s (tecla %s): %s` `placeholder`
- L545 `%s: %s` `placeholder`
- L547 `%s: %s` `placeholder`
- L563 ` · o ` `concatenado`
- L602 `o ` `concatenado`
- L660 `%s · %s` `placeholder`
- L663 ` Necesita %d×%d casillas libres.` `placeholder`
- L700 ` ⏎ ` `concatenado,multilinea`
- L739 `Oleada`
- L743 `→ %d/%d` `placeholder`
- L754 `%d/%d ✓` `placeholder`
- L755 `Oleada completada (+%d de oro)` `placeholder`
- L761 `Empezar oleada`
- L763 `Oleada en curso`
- L765 `Empezar oleada`
- L767 `¡Victoria!`
- L769 `Derrota`
- L774 `Empezar oleada (%d)` `placeholder`
- L776 `%s · %ds` `placeholder`
- L788 `Pausa`
- L812 `Oleada %d` `placeholder`
- L826 `¡Llega el %s!` `placeholder`
- L856 `Avances tecnológicos: %s. Una pieza por cada nivel del 1 al 5; se guarda al terminar, abandonar descarta.` `placeholder`
- L858 `Piezas de la %s: %s. Una pieza por ruina; se guarda al terminar, abandonar descarta.` `placeholder`

</details>

<details><summary><code>scenes/game/hud.tscn</code> · Escenas (.tscn) · 13</summary>

- L27 `[text] Oleada 1`
- L42 `[text] ¡Llega el Jefe!`
- L192 `[text] Próxima oleada`
- L209 `[text] Empezar oleada`
- L231 `[text] Torre · 0 de oro`
- L241 `[text] Para qué sirve.`
- L251 `[text] Pausa  [P]`
- L260 `[tooltip_text] Volver al menú principal`
- L261 `[text] ← Menú`
- L270 `[text] x1  [F]`
- L283 `[text] PAUSA`
- L328 `[text] Nuevo enemigo`
- L335 `[text] Descripción`

</details>

<details><summary><code>scenes/game/infrastructure_controller.gd</code> · GDScript · 3</summary>

- L130 `+%d %s` `placeholder,plural`
- L167 `+%d %s` `placeholder,plural`
- L169 `¡Pieza encontrada!`

</details>

<details><summary><code>scenes/game/mobile_hud.gd</code> · GDScript · 41</summary>

- L103 `M8 1v3M8 12v3M1 8h3M12 8h3`
- L114 `Button`
- L223 `Button`
- L258 `Tocá el carrito para elegir una torre`
- L259 `En pausa: seguí la partida para construir`
- L282 `Demoler o habilitar: tocá un objeto del mapa`
- L296 `%s  ·  %s` `placeholder`
- L325 `Aturdida`
- L327 `Desgaste %d %%` `placeholder`
- L331 `%s %s` `placeholder`
- L340 `Apuntar: %s` `placeholder`
- L348 `Nivel máximo`
- L352 `Faltan %d de oro` `placeholder`
- L365 `Devuelve %d de oro y %d recursos` `placeholder`
- L367 `Devuelve %d de oro` `placeholder`
- L396 ` ⏎ ` `multilinea`
- L405 `%s ⏎ %s` `multilinea,placeholder`
- L407 `%s · %s ⏎ %s` `multilinea,placeholder`
- L408 `%s ⏎ %s ⏎ %s` `multilinea,placeholder`
- L464 `Tocá para confirmar  %d` `placeholder`
- L467 `Mejorar → N%d  %d` `placeholder`
- L494 `¡Nivel %d!` `placeholder`
- L508 `Vender por %s ⏎ Confirmar venta` `multilinea,placeholder`
- L513 `Vender ⏎ +%d%s` `concatenado,multilinea,placeholder`
- L513 ` +%d` `concatenado,placeholder`
- L603 `Ver todo`
- L604 `Ver todo`
- L620 `Elegir torre`
- L622 `Salir al menú`
- L624 `Demoler o habilitar`
- L670 `Button`
- L706 `Elegí una opción`
- L771 `%s / %s` `placeholder`
- L776 `Demoledora`
- L814 `CatalogCard_%s` `placeholder`
- L833 `%s ⏎ %s` `multilinea,placeholder`
- L835 ` ⏎ %s` `multilinea,placeholder`
- L836 `%s · %s` `placeholder`
- L884 `Confirmar construcción`
- L885 `%s  ·  %s` `placeholder`
- L886 `Cancelar construcción`

</details>

<details><summary><code>scenes/game/tutorial_controller.gd</code> · GDScript · 1</summary>

- L102 `%s · %s` `placeholder`

</details>

<details><summary><code>scenes/levels/level.gd</code> · GDScript · 6</summary>

- L40 `Level`
- L51 `Entrances`
- L55 `GroundPath%d` `placeholder`
- L60 `AirPath%d` `placeholder`
- L66 `Decor`
- L75 `Ground`

</details>

<details><summary><code>scenes/ui/bar_tabs.gd</code> · GDScript · 2</summary>

- L38 `Tab_%s` `placeholder`
- L105 `%s · %s` `placeholder`

</details>

<details><summary><code>scenes/ui/infrastructure_tab.gd</code> · GDScript · 11</summary>

- L55 `Cards`
- L138 `Trabajo en curso`
- L157 `Cancelar`
- L159 `Cancelar la demolición y recuperar todo el oro`
- L171 `Comprar`
- L185 `Arrows`
- L191 `Puntos anteriores`
- L195 `Puntos siguientes`
- L245 `Comprar la demoledora`
- L292 `Ver en el mapa`
- L300 `Habilitar el punto`

</details>

<details><summary><code>scenes/ui/obstacle_panel.gd</code> · GDScript · 11</summary>

- L81 ` ⏎ Con la demoledora: %d de oro` `multilinea,placeholder`
- L88 `Pagado: %d de oro` `placeholder`
- L90 `Cancelar (devuelve %d)` `placeholder`
- L92 `Cancelar la demolición y recuperar todo el oro`
- L95 `Hay una demolición en curso`
- L96 `Demoler (%d)` `placeholder`
- L104 `Demoler (%d)` `placeholder`
- L106 `Demoler`
- L111 `%s · %s` `placeholder`
- L114 `Entrega al completar cada oleada` `plural`
- L114 `Ya no entrega más` `plural`

</details>

<details><summary><code>scenes/ui/tower_panel.gd</code> · GDScript · 20</summary>

- L150 `%s %s %s` `placeholder`
- L157 `Nivel actual: %d de 3` `placeholder`
- L260 `Aturdida (%d s)` `placeholder`
- L262 `Desgaste %.0f %%` `placeholder`
- L267 `Golpea voladores` `plural`
- L267 `No golpea voladores` `plural`
- L273 ` ⏎ ` `multilinea`
- L276 ` ⏎ ` `concatenado,multilinea`
- L278 ` ⏎ Reparación recibida: %s puntos/s` `multilinea,placeholder`
- L280 ` ⏎ Prestaciones actuales: %.0f %%` `multilinea,placeholder`
- L282 ` ⏎ Apoyo recibido: +%d %% cadencia` `multilinea,placeholder`
- L285 ` ⏎ ` `concatenado,multilinea`
- L291 `Apuntar: %s (clic para cambiar la prioridad de objetivo)` `placeholder`
- L293 `Vender +%s [S]` `placeholder`
- L300 `Nivel máximo`
- L303 `Nivel máximo alcanzado`
- L306 `Mejorar a nivel %d` `placeholder`
- L311 `faltan %d` `placeholder`
- L313 `Faltan %d de oro` `placeholder`
- L313 `Mejorar torre · U`

</details>

<details><summary><code>scenes/ui/tower_panel.tscn</code> · Escenas (.tscn) · 16</summary>

- L41 `[text] Torre`
- L51 `[tooltip_text] Golpea voladores`
- L67 `[tooltip_text] Nivel actual: 1 de 3`
- L89 `[tooltip_text] Ocultar panel; al elegir otra torre, vuelve a aparecer`
- L124 `[text] Daño`
- L138 `[text] Cadencia`
- L145 `[text] 0/s`
- L152 `[text] Alcance`
- L153 `[tooltip_text] Distancia en casillas`
- L174 `[text] Mejorar`
- L197 `[text] faltan 0`
- L220 `[text] [U]`
- L233 `[text] Primero`
- L234 `[tooltip_text] Cambiar prioridad de objetivo`
- L243 `[text] Vender`
- L244 `[tooltip_text] Vender y recuperar parte de lo invertido · S`

</details>

<details><summary><code>scripts/data/range_display_config.gd</code> · GDScript · 6</summary>

- L20 `No se encontró %s; se usan los valores por omisión.` `placeholder`
- L24 `No se pudo leer %s; se usan los valores por omisión.` `placeholder`
- L28 `%s no es un JSON válido (un objeto); se usan los valores por omisión.` `placeholder`
- L52 `Falta «%s» (un objeto); se usan sus valores por omisión.` `placeholder`
- L58 `«%s.%s» tiene que ser un número; se usa %s.` `placeholder`
- L63 `«%s.%s» está fuera de rango (%s).` `placeholder`

</details>

<details><summary><code>scripts/data/upgrade_fx_config.gd</code> · GDScript · 26</summary>

- L16 `daño`
- L20 `área`
- L21 `púas`
- L24 `s de frenado`
- L26 `s de quemadura`
- L27 `s de pulso`
- L29 `reparación/s`
- L56 `No se encontró %s; se usan los valores por omisión.` `placeholder`
- L60 `No se pudo leer %s; se usan los valores por omisión.` `placeholder`
- L64 `%s no es un JSON válido (un objeto); se usan los valores por omisión.` `placeholder`
- L92 `Falta «%s»; se usa %s.` `placeholder`
- L96 `«%s» tiene que ser un número.` `placeholder`
- L101 `«%s» está fuera de rango (%s).` `placeholder`
- L105 `«fuente_min_px» no puede ser mayor que «fuente_max_px»; se usan los de omisión.`
- L112 `Falta «variantes» (un objeto con «refuerzo» y «maestria»); se usan los valores por omisión.`
- L117 `Falta la variante «%s»; se usan los valores por omisión.` `placeholder`
- L123 `En la variante «%s», «%s» tiene que ser un número.` `placeholder`
- L125 `En la variante «%s», «%s» tiene que ser mayor que 0 (es %s).` `placeholder`
- L133 `Falta «estadisticas» (una lista); se usa la tabla por omisión.`
- L144 `La estadística %d no es un objeto.` `placeholder`
- L153 `La estadística %d usa el campo «%s», que no existe en TowerLevelData.` `placeholder`
- L156 `La estadística %d repite el campo «%s».` `placeholder`
- L159 `La estadística %d (%s) no tiene «etiqueta».` `placeholder`
- L162 `La estadística %d (%s) tiene el formato desconocido «%s» (valen: %s).` `placeholder`
- L166 `La estadística %d (%s) tiene una «escala» que no sirve (tiene que ser un número distinto de 0).` `placeholder`
- L172 `La tabla de estadísticas quedó vacía; se usa la de omisión.`

</details>

<details><summary><code>scripts/logic/ghost_placement.gd</code> · GDScript · 5</summary>

- L8 `Ahí no`
- L21 `Ahí no`
- L24 `Ahí no`
- L44 `Faltan %d de oro` `placeholder`
- L46 `Faltan %d recursos` `placeholder`

</details>

<details><summary><code>scripts/logic/infrastructure_text.gd</code> · GDScript · 14</summary>

- L6 `Sin demolición en curso. Tocá un objeto del mapa para demolerlo.`
- L7 `Infraestructura`
- L13 `%d s` `placeholder`
- L18 `Faltan %s` `placeholder`
- L23 `Demoledora activa` `plural`
- L23 `Demoledora · %d de oro` `placeholder,plural`
- L29 `Cada demolición cuesta el %d %% y tarda el %d %%` `placeholder`
- L35 `Comprar` `plural`
- L35 `Te faltan %d de oro` `placeholder,plural`
- L43 `Activa · reserva %d/%d · +%d por oleada` `placeholder`
- L45 `Agotada`
- L46 `Habilitar · %d de oro` `placeholder`
- L51 `Recursos: %d` `placeholder`
- L56 `Al terminar la oleada: +%d` `placeholder`

</details>

<details><summary><code>scripts/logic/obstacle_catalog.gd</code> · GDScript · 19</summary>

- L18 `No existe el archivo %s.` `placeholder`
- L21 `El archivo %s no contiene un objeto JSON válido.` `placeholder`
- L25 `version: tiene que ser 1.`
- L30 `El archivo %s tiene errores: %s` `placeholder`
- L73 `demoledora: falta \"%s\".` `placeholder`
- L75 `demoledora.%s: tiene que ser un número de 0 para arriba.` `placeholder`
- L77 `demoledora.%s: tiene que ser un número entero.` `placeholder`
- L82 `%s: tiene que ser un objeto.` `placeholder`
- L86 `%s: falta la clase \"%s\".` `placeholder`
- L90 `%s.%s: tiene que ser un objeto.` `placeholder`
- L94 `%s: la clase \"%s\" no existe.` `placeholder`
- L100 `%s.%s: \"recursos_si_recuperado\" solo corresponde a escombro.` `placeholder`
- L103 `%s.%s: falta \"%s\".` `placeholder`
- L107 `%s.%s: tiene que ser un número de 0 para arriba.` `placeholder`
- L110 `%s.%s: tiene que ser mayor que 0.` `placeholder`
- L112 `%s.%s: tiene que ser un número entero.` `placeholder`
- L114 `%s.probabilidad: no puede superar 100.` `placeholder`
- L119 `%s: tiene que ser un objeto.` `placeholder`
- L127 `%s: clave desconocida \"%s\".` `placeholder`

</details>

<details><summary><code>scripts/logic/obstacle_text.gd</code> · GDScript · 20</summary>

- L6 `Árbol`
- L6 `Roca`
- L6 `Escombros`
- L7 `Mina`
- L7 `Bosque explotable`
- L16 `Costo: %d de oro` `placeholder`
- L20 `Tiempo: %s s` `placeholder`
- L25 `Te faltan %d de oro` `placeholder`
- L33 `Aquí no se recogen piezas`
- L35 `Pieza de la %s: %s` `placeholder,plural`
- L35 `ya recuperada` `plural`
- L37 `Puede dar %d %s (%d %%)` `placeholder,plural`
- L38 `No da recursos`
- L42 `Falta: %s s` `placeholder`
- L51 `Habilitar extracción (%d de oro)` `placeholder`
- L55 `Produce %d %s por oleada` `placeholder,plural`
- L60 `Reserva %d/%d` `placeholder`
- L66 `Activa`
- L68 `Agotada`
- L69 `Sin habilitar`

</details>

<details><summary><code>scripts/logic/view_all_binding.gd</code> · GDScript · 6</summary>

- L24 `una tecla reservada`
- L26 `el panel de pruebas`
- L40 `cambiar de pestaña`
- L40 `empezar la oleada`
- L46 `elegir una torre`
- L75 `Espacio`

</details>

### Pausa y confirmaciones de salida

<details><summary><code>scenes/ui/exit_dialog.tscn</code> · Escenas (.tscn) · 3</summary>

- L57 `[text] ¿Volver al menú principal?`
- L77 `[text] Seguir jugando`
- L85 `[text] Salir al menú`

</details>

<details><summary><code>scenes/ui/pause_menu.tscn</code> · Escenas (.tscn) · 5</summary>

- L59 `[text] Pausa`
- L67 `[text] Continuar`
- L74 `[text] Reintentar`
- L81 `[text] Opciones`
- L88 `[text] Salir al menú`

</details>

<details><summary><code>scripts/logic/exit_text.gd</code> · GDScript · 9</summary>

- L6 `¿Volver al menú principal?`
- L7 `Se abandona esta partida. El oro, las torres y la oleada actual no se guardan.`
- L8 `La demolición en curso se pierde y no devuelve el oro.`
- L10 `Avances tecnológicos`
- L11 `Lo que ya ganaste (niveles, estrellas, récords y piezas guardadas) se conserva.`
- L23 ` ⏎  ⏎ ` `multilinea`
- L35 `1 pieza de colección recogida` `plural`
- L35 `%d piezas de colección recogidas` `placeholder,plural`
- L36 `Perdés %s en esta partida (%s). Se guardan recién al terminar la partida.` `placeholder`

</details>

### Tutorial

<details><summary><code>data/tutorial/tutorial.json</code> · Datos (.json) · 34</summary>

- `[interfaz.titulo] Tutorial`
- `[interfaz.paso] Paso %d de %d` `placeholder`
- `[interfaz.siguiente] Siguiente`
- `[interfaz.saltar] Saltar tutorial`
- `[interfaz.terminar] ¡A jugar!`
- `[pc.0.texto] ¡Bienvenido! En un minuto aprendés lo básico. Podés saltar el tutorial cuando quieras.`
- `[pc.1.texto] Los monstruos entran por acá y siguen el camino hasta la salida. Si llegan, perdés vidas.`
- `[pc.2.texto] Este es tu oro. Lo ganás derrotando monstruos y terminando oleadas.`
- `[pc.3.texto] Estas son tus vidas. Si te quedás sin ninguna, se pierde el nivel.`
- `[pc.4.texto] Elegí una torre en la barra de abajo (o apretá la tecla 1).`
- `[pc.5.texto] Hacé clic en una casilla de pasto junto al camino para construirla. Cuesta oro.`
- `[pc.6.texto] Cuando estés listo, apretá «Empezar oleada» (o Espacio).`
- `[pc.7.texto] Clic derecho para soltar la torre; después, clic en la tuya para elegirla.`
- `[pc.8.texto] «Mejorar» hace más fuerte a la torre elegida. Cuesta oro.`
- `[pc.9.texto] «Vender» te devuelve parte del oro si te arrepentís.`
- `[pc.10.texto] Este botón acelera la partida al doble. Apretalo de nuevo para volver a la velocidad normal.`
- `[pc.11.texto] «Pausa» congela todo para que pienses con calma. Probala.`
- `[pc.12.texto] Apretá «Seguir» para continuar.`
- `[pc.13.texto] ¡Listo! Ya sabés lo básico. Defendé el campamento hasta la última oleada.`
- `[celular.0.texto] ¡Bienvenido! En un minuto aprendés lo básico. Podés saltar el tutorial cuando quieras.`
- `[celular.1.texto] Los monstruos entran por acá y siguen el camino hasta la salida. Si llegan, perdés vidas.`
- `[celular.2.texto] Este es tu oro. Lo ganás derrotando monstruos y terminando oleadas.`
- `[celular.3.texto] Estas son tus vidas. Si te quedás sin ninguna, se pierde el nivel.`
- `[celular.4.texto] Tocá el carrito para abrir la lista de torres.`
- `[celular.5.texto] Tocá una torre. Aparece un fantasma sobre el mapa.`
- `[celular.6.texto] Tocá una casilla junto al camino y confirmá con la tilde ✓. También sirve tocar dos veces la misma casilla.`
- `[celular.7.texto] Cuando estés listo, tocá «Empezar oleada».`
- `[celular.8.texto] Tocá tu torre en el mapa para elegirla.`
- `[celular.9.texto] «Mejorar» hace más fuerte a la torre elegida. Cuesta oro. Un toque muestra hasta dónde llega su alcance; otro toque confirma.`
- `[celular.10.texto] «Vender» pide dos toques y te devuelve parte del oro.`
- `[celular.11.texto] Este botón acelera la partida al doble. Tocalo de nuevo para volver a la velocidad normal.`
- `[celular.12.texto] «Pausa» congela todo para que pienses con calma. Probala.`
- `[celular.13.texto] Tocá «Seguir» para continuar.`
- `[celular.14.texto] ¡Listo! Ya sabés lo básico. Defendé el campamento hasta la última oleada.`

</details>

<details><summary><code>scenes/ui/tutorial_overlay.gd</code> · GDScript · 4</summary>

- L57 `Highlight`
- L125 `Card`
- L137 `Header`
- L146 `Text`

</details>

<details><summary><code>scripts/logic/tutorial_data.gd</code> · GDScript · 33</summary>

- L79 `tutorial: no existe el archivo %s.` `placeholder`
- L83 `tutorial: no se pudo abrir %s.` `placeholder`
- L88 `tutorial: %s no es un JSON válido (línea %d: %s).` `placeholder`
- L97 `tutorial: el archivo tiene que ser un objeto con \"version\", \"pc\" y \"celular\".`
- L101 `tutorial: \"version\" tiene que ser %d.` `placeholder`
- L103 `tutorial: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).`
- L108 `tutorial: \"nivel\" tiene que ser el id del nivel donde se muestra, como \"level_01\".`
- L137 `tutorial: \"interfaz\" tiene que ser un objeto con %s.` `placeholder`
- L143 `tutorial: \"interfaz\" \"%s\" tiene que ser un texto no vacío.` `placeholder`
- L145 `tutorial: \"interfaz\" \"%s\" tiene %d caracteres y el máximo es %d.` `placeholder`
- L149 `tutorial: \"interfaz\" \"paso\" tiene que llevar dos %d (el número del paso y el total), como \"Paso %d de %d\".` `placeholder`
- L153 `tutorial: \"interfaz\" no usa la clave \"%s\" (se usan: %s).` `placeholder`
- L158 `la lista \"%s\"` `placeholder`
- L160 `tutorial: %s tiene que ser una lista de pasos.` `placeholder`
- L167 `el paso %d de %s` `placeholder`
- L169 `%s tiene que ser un objeto con \"paso\" y \"texto\".` `placeholder`
- L173 `%s: \"paso\" '%s' no existe (se usan: %s).` `placeholder`
- L177 `%s: el paso \"%s\" no se usa en %s.` `placeholder,plural`
- L177 `la PC` `plural`
- L177 `el modo celular` `plural`
- L180 `%s: el paso \"%s\" está repetido.` `placeholder`
- L184 `%s (\"%s\"): \"texto\" tiene que ser un texto entre comillas.` `placeholder`
- L188 `%s (\"%s\") %s` `placeholder`
- L203 `la lista \"%s\" no tiene el paso \"%s\" y hace falta.` `placeholder`
- L206 `la lista \"%s\": el paso \"%s\" tiene que ir antes que \"%s\".` `placeholder`
- L208 `la lista \"%s\": después de \"pause\" tiene que ir \"resume\" (si no, la partida quedaría pausada).` `placeholder`
- L210 `la lista \"%s\": el paso \"done\" tiene que ser el último.` `placeholder`
- L217 `tiene el texto vacío.`
- L222 `tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).` `multilinea`
- L226 `tiene %d líneas y el máximo es %d.` `placeholder`
- L228 `tiene %d caracteres y el máximo es %d.` `placeholder`
- L231 `tiene la línea %d en blanco.` `placeholder`
- L233 `tiene la línea %d con %d caracteres y el máximo por línea es %d.` `placeholder`

</details>

### Consejos de derrota

<details><summary><code>data/consejos/consejos.json</code> · Datos (.json) · 15</summary>

- `[reglas.0.texto] Contra voladores, probá con {torres}.` `placeholder`
- `[reglas.1.texto] El Chamán apaga torres cercanas. Pegale de lejos con {torres}.` `placeholder`
- `[reglas.2.texto] El Espejo devuelve los tiros de cerca. Probá con {torres}.` `placeholder`
- `[reglas.3.texto] Curan al resto: frená la cura o matalos rápido con {torres}.` `placeholder`
- `[reglas.4.texto] Su aura da armadura al resto. Apagala con {torres}.` `placeholder`
- `[reglas.5.texto] Su aura da armadura al resto. Pegale de lejos con {torres}.` `placeholder`
- `[reglas.6.texto] El Troll se cura solo y el fuego lo frena. Probá con {torres}.` `placeholder`
- `[reglas.7.texto] Los que se curan solos piden daño concentrado: {torres}.` `placeholder`
- `[reglas.8.texto] Los que roban oro caen rápido ante varios tiros: {torres}.` `placeholder`
- `[reglas.9.texto] El Embestidor desgasta torres. Frená su carga con {torres}.` `placeholder`
- `[reglas.10.texto] El Hielo les hace la mitad. No confíes en frenarlos: {torres}.` `placeholder`
- `[reglas.11.texto] Con armadura, los tiros chicos no entran. Probá con {torres}.` `placeholder`
- `[reglas.12.texto] Al morir sueltan crías. El daño en área las limpia: {torres}.` `placeholder`
- `[reglas.13.texto] Son muy rápidos. Ralentizalos o pegales a varios: {torres}.` `placeholder`
- `[reglas.14.texto] Aguantan mucho. Conviene el daño concentrado: {torres}.` `placeholder`

</details>

<details><summary><code>scripts/logic/advice_data.gd</code> · GDScript · 35</summary>

- L21 `{torres}` `placeholder`
- L39 `consejos: no existe el archivo %s.` `placeholder`
- L43 `consejos: no se pudo abrir %s.` `placeholder`
- L47 `consejos: %s no es un JSON válido (línea %d: %s).` `placeholder`
- L55 `consejos: el archivo tiene que ser un objeto con \"ajustes\", \"criterios\", \"reglas\".`
- L59 `consejos: \"version\" tiene que ser %d.` `placeholder`
- L61 `consejos: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).`
- L183 `consejos: falta \"ajustes\" (un objeto con %s).` `placeholder`
- L188 `consejos: \"ajustes\" no conoce la clave \"%s\" (las válidas: %s).` `placeholder`
- L191 `consejos: \"ajustes.%s\" tiene que ser un número.` `placeholder`
- L199 `consejos: \"peso_oleada\" tiene que estar entre 0 y 5.`
- L201 `consejos: \"participacion_minima_pct\" tiene que estar entre 0 y 100.`
- L203 `consejos: \"vidas_minimas\" tiene que ser 1 o más.`
- L205 `consejos: \"max_torres\" tiene que estar entre 1 y 4.`
- L207 `consejos: \"max_caracteres\" tiene que estar entre 30 y 120 (si no, el texto no entra en 2 líneas).`
- L212 `consejos: falta \"criterios\" (qué torres cuentan como «de golpe alto», «que golpean el aire»…).`
- L218 `consejos: el criterio \"%s\" tiene que ser un objeto con al menos una condición.` `placeholder`
- L225 `consejos: en el criterio \"%s\", \"%s\" tiene que ser true o false.` `placeholder`
- L229 `consejos: en el criterio \"%s\", \"%s\" tiene que ser un número de 0 o más.` `placeholder`
- L232 `consejos: el criterio \"%s\" no conoce la condición \"%s\" (las válidas: %s).` `placeholder`
- L241 `consejos: falta \"reglas\" (una lista con al menos una regla).`
- L248 `consejos: la regla %d tiene que ser un objeto.` `placeholder`
- L252 `la regla \"%s\"` `placeholder`
- L252 `la regla %d` `placeholder`
- L254 `consejos: %s no tiene \"id\".` `placeholder`
- L256 `consejos: el id \"%s\" está repetido.` `placeholder`
- L262 `consejos: %s necesita \"torres\" (la lista de criterios que sirven).` `placeholder`
- L266 `consejos: %s nombra el criterio \"%s\", que no existe en \"criterios\".` `placeholder`
- L271 `consejos: %s no tiene \"texto\".` `placeholder`
- L273 `consejos: el texto de %s tiene que llevar %s donde van los nombres de las torres.` `placeholder`
- L275 `consejos: el texto de %s mide hasta %d caracteres con %d nombres largos y el máximo es %d (no entraría en 2 líneas).` `placeholder`
- L283 `consejos: %s necesita \"enemigo\" (a qué enemigos aplica, por ejemplo {\"vuela\": true}).` `placeholder`
- L291 `consejos: en %s, \"%s\" solo puede ser true.` `placeholder`
- L295 `consejos: en %s, \"%s\" tiene que ser un número mayor que 0.` `placeholder`
- L298 `consejos: %s no conoce la condición de enemigo \"%s\" (las válidas: %s).` `placeholder`

</details>

<details><summary><code>scripts/logic/defeat_advice.gd</code> · GDScript · 1</summary>

- L76 `%s y %s` `placeholder`

</details>

### Resultados, epílogo y créditos

<details><summary><code>data/creditos.json</code> · Datos (.json) · 4</summary>

- `[lineas.0] Monsters & Canons`
- `[lineas.1] Un juego de Lucas`
- `[lineas.2] Hecho con Godot Engine`
- `[lineas.3] Software libre bajo la licencia GPL-3.0-or-later (los detalles, en Wiki → Licencias)`

</details>

<details><summary><code>scenes/ui/credits_screen.gd</code> · GDScript · 2</summary>

- L10 `Créditos`
- L11 `Volver`

</details>

<details><summary><code>scenes/ui/end_screen.gd</code> · GDScript · 8</summary>

- L24 `Siguiente nivel`
- L25 `Epílogo`
- L84 `¡Victoria!`
- L88 `Vidas restantes: %d` `placeholder`
- L92 `Puntos: %d` `placeholder`
- L103 `Derrota`
- L106 `Llegaste a la oleada %d de %d` `placeholder`
- L109 `Puntos: %d` `placeholder`

</details>

<details><summary><code>scenes/ui/end_screen.tscn</code> · Escenas (.tscn) · 5</summary>

- L51 `[text] Título`
- L65 `[text] Detalle`
- L74 `[text] Siguiente nivel`
- L82 `[text] Reintentar`
- L90 `[text] Niveles`

</details>

<details><summary><code>scenes/ui/epilogue_screen.gd</code> · GDScript · 2</summary>

- L14 `Créditos`
- L15 `Niveles`

</details>

<details><summary><code>scripts/logic/credits.gd</code> · GDScript · 10</summary>

- L17 `No se encuentra el archivo de créditos (%s).` `placeholder`
- L27 `Los créditos no son un JSON válido (línea %d: %s).` `placeholder`
- L30 `Los créditos tienen que ser un objeto con \"version\" y \"lineas\".`
- L35 `clave desconocida \"%s\" (se usan: %s).` `placeholder`
- L37 `\"version\" tiene que ser 1.`
- L39 `\"lineas\" tiene que ser una lista de textos.`
- L43 `\"lineas\" no puede estar vacía.`
- L45 `\"lineas\" tiene %d líneas y el máximo es %d.` `placeholder`
- L48 `la línea %d tiene que ser un texto.` `placeholder`
- L52 `la línea %d tiene %d caracteres y el máximo es %d.` `placeholder`

</details>

<details><summary><code>scripts/logic/lore_unlock.gd</code> · GDScript · 4</summary>

- L6 `Se abre al ganar el nivel `
- L21 `Se abre al ganar un nivel de la campaña.`
- L32 `^level_(\\d+)$`
- L38 `^level_\\d+$`

</details>

### Récords, iniciales y Salón de la fama

<details><summary><code>scenes/ui/hall_of_fame.gd</code> · GDScript · 3</summary>

- L16 `SALÓN DE LA FAMA`
- L65 `Continuar`
- L85 `¡Ganaste todos los niveles! ⏎ Total de la campaña: %d puntos` `multilinea,placeholder`

</details>

<details><summary><code>scenes/ui/name_entry.gd</code> · GDScript · 1</summary>

- L32 `Listo  [Enter]`

</details>

<details><summary><code>scenes/ui/records_screen.gd</code> · GDScript · 6</summary>

- L7 `Para quien ganó todos los niveles`
- L8 `Todavía nadie ganó todos los niveles`
- L65 `Campaña`
- L103 `Nivel %d · %s` `placeholder`
- L111 `Modo con errores`
- L118 `Sin mapas`

</details>

<details><summary><code>scenes/ui/records_screen.tscn</code> · Escenas (.tscn) · 5</summary>

- L52 `[text] Récords`
- L73 `[text] Campaña`
- L101 `[text] Nivel 1 · Pradera`
- L137 `[text] Salón de la fama`
- L145 `[text] Volver`

</details>

<details><summary><code>scenes/ui/score_table.gd</code> · GDScript · 1</summary>

- L23 `Todavía no hay récords`

</details>

### Wiki (pantalla y artículos)

<details><summary><code>data/wiki/armadura_y_dano.json</code> · Datos (.json) · 7</summary>

- `[titulo] Armadura y daño`
- `[subtitulo] Por qué algunas torres no le hacen nada a algunos enemigos`
- `[bloques.0.texto] La armadura de un enemigo se resta de cada golpe que recibe. Si el golpe es de 10 y la armadura es de 3, entran 7. Siempre entra al menos 1…`
- `[bloques.1.texto] Qué significa para vos`
- `[bloques.2.texto] Las torres que pegan muchas veces con poco daño (Ametralladora, Múltiple, Ráfaga) pierden mucho contra los enemigos blindados. Las torres d…`
- `[bloques.3.texto] El fuego ignora la armadura`
- `[bloques.4.texto] El daño de la quemadura no se reduce con la armadura, así que la Incendiaria sirve justo contra los blindados.`

</details>

<details><summary><code>data/wiki/como_se_juega.json</code> · Datos (.json) · 9</summary>

- `[titulo] Cómo se juega`
- `[subtitulo] Lo básico, en un minuto`
- `[bloques.0.texto] Los enemigos salen por las entradas y siguen el camino hasta la salida. Tu trabajo es frenarlos con torres antes de que lleguen. Cada enemi…`
- `[bloques.1.texto] Oro`
- `[bloques.2.texto] Con el oro construís y mejorás torres. Empezás con el oro del nivel, ganás más matando enemigos y recibís un bono al terminar cada oleada. …`
- `[bloques.3.texto] Oleadas`
- `[bloques.4.texto] Nada empieza hasta que apretás "Empezar oleada": construí con calma antes. Entre oleadas hay una cuenta atrás; si no querés esperar, empezá…`
- `[bloques.5.texto] Consejos`
- `[bloques.6.texto] Poné las torres en las curvas: ahí los enemigos pasan más tiempo dentro del alcance. Mezclá tipos de torre, porque cada enemigo tiene una d…`

</details>

<details><summary><code>data/wiki/construir_y_mejorar.json</code> · Datos (.json) · 9</summary>

- `[titulo] Construir, mejorar y vender`
- `[subtitulo] Cómo se manejan las torres`
- `[bloques.0.texto] Elegí una torre en la barra de abajo (o con las teclas 1 a 8) y hacé clic en una casilla libre del césped. Se ve el círculo de alcance y, e…`
- `[bloques.1.texto] Mejorar`
- `[bloques.2.texto] Cada torre tiene 3 niveles. Al hacer clic en una torre construida se abre su panel: ahí se ve su nivel, sus números y el botón Mejorar (tec…`
- `[bloques.3.texto] Vender`
- `[bloques.4.texto] Vender (tecla S) elimina la torre y te devuelve una parte de todo el oro que pusiste en ella, construcción y mejoras incluidas. Sirve para …`
- `[bloques.5.texto] Modo de apuntado`
- `[bloques.6.texto] Cada torre elige a quién dispararle: Primero (el más cerca de la salida, es el normal), Último, Más fuerte (el de más vida) o Más cercano (…`

</details>

<details><summary><code>data/wiki/efectos.json</code> · Datos (.json) · 15</summary>

- `[titulo] Efectos de las torres`
- `[subtitulo] Lo que hacen las torres además de dañar`
- `[bloques.0.texto] Ralentización`
- `[bloques.1.texto] El Hielo frena a los enemigos: un enemigo ralentizado avanza más lento y se ve teñido de azul. Si le llegan varias ralentizaciones no se su…`
- `[bloques.2.texto] Quemadura`
- `[bloques.3.texto] La Incendiaria prende fuego: el enemigo recibe daño cada medio segundo durante unos segundos. El fuego ignora la armadura y, mientras dura,…`
- `[bloques.4.texto] Daño en área`
- `[bloques.5.texto] El Cañón daña a todos los enemigos cerca del punto de impacto: rinde contra grupos. No toca a los voladores.`
- `[bloques.6.texto] Varios objetivos, púas y rayos`
- `[bloques.7.texto] La Múltiple le dispara a varios enemigos a la vez. La Ráfaga lanza púas en círculo, y rinde más en una curva. La Eléctrica lanza un rayo qu…`
- `[bloques.8.texto] Combos`
- `[bloques.9.texto] Algunas torres le pegan más fuerte a un enemigo que ya está frenado por el Hielo o en llamas por la Incendiaria: el Cañón, el Francotirador…`
- `[bloques.10.texto] Un golpe con combo muestra su número más grande y con un «!»: celeste si fue por el hielo y naranja si fue por el fuego, y suena un «tin».…`
- `[bloques.11.texto] Supresión de auras`
- `[bloques.12.texto] La Disruptora no dispara: cada tanto emite un pulso a su alrededor. Los enemigos con aura, como el Guardián y el Curandero, que el pulso a…`

</details>

<details><summary><code>data/wiki/enemigos_especiales.json</code> · Datos (.json) · 8</summary>

- `[titulo] Enemigos especiales`
- `[subtitulo] Voladores, peligrosos y jefes`
- `[bloques.0.texto] Voladores`
- `[bloques.1.texto] Los voladores ignoran el camino: van en línea recta desde su entrada hasta la salida. Las torres que no pueden golpear voladores (mirá "Gol…`
- `[bloques.2.texto] Peligrosos`
- `[bloques.3.texto] Los enemigos que llevan una corona dorada son peligrosos: si llegan a la salida te quitan muchas vidas de golpe. Vale la pena guardar las m…`
- `[bloques.4.texto] Jefes y cosas raras`
- `[bloques.5.texto] El Jefe resiste la ralentización: el Hielo le hace la mitad de efecto. El Troll se cura solo con el tiempo, pero el fuego lo deja sin curar…`

</details>

<details><summary><code>data/wiki/licencias.json</code> · Datos (.json) · 10</summary>

- `[titulo] Licencias`
- `[subtitulo] Qué podés hacer con el juego`
- `[bloques.0.texto] Monsters & Canons`
- `[bloques.1.texto] Copyright (C) 2026 Lucas.  Este juego es software libre y se regala: podés usarlo, copiarlo, compartirlo y modificarlo bajo los términos de…`
- `[bloques.2.texto] Se distribuye con la esperanza de que sea útil, pero SIN NINGUNA GARANTÍA, ni siquiera la garantía implícita de COMERCIABILIDAD o de APTITU…`
- `[bloques.3.texto] Motor Godot`
- `[bloques.4.texto] Hecho con Godot Engine (https://godotengine.org), bajo la licencia MIT:  Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.…`
- `[bloques.5.texto] Godot incluye componentes de terceros, cada uno con su propia licencia (por ejemplo FreeType, HarfBuzz, ENet, Mbed TLS, libpng y zlib). La …`
- `[bloques.6.texto] Herramientas de desarrollo`
- `[bloques.7.texto] Los tests automáticos usan GUT (Godot Unit Test, licencia MIT). Es solo una herramienta de desarrollo y no va dentro de los ejecutables.`

</details>

<details><summary><code>data/wiki/lore/criaturas_solas.json</code> · Datos (.json) · 4</summary>

- `[titulo] Las criaturas que van solas`
- `[subtitulo] Lo que no pertenece a ninguna manada`
- `[bloques.0.texto] En el bosque hay seres que no andan con ninguna manada. El Ladrón, por ejemplo, va solo, con una capa gris y una bolsa, y se lleva lo que b…`
- `[bloques.1.texto] Los informes las llaman criaturas, para distinguirlas de los animales. No obedecen a nadie, y nadie sabe cuántas hay.`

</details>

<details><summary><code>data/wiki/lore/el_oasis.json</code> · Datos (.json) · 5</summary>

- `[titulo] El oasis`
- `[subtitulo] Donde aterrizó la nave`
- `[bloques.0.texto] El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista que encontró el rec…`
- `[bloques.1.texto] Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral, un lugar donde sem…`
- `[bloques.2.texto] Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.`

</details>

<details><summary><code>data/wiki/lore/el_soberano.json</code> · Datos (.json) · 4</summary>

- `[titulo] El Soberano`
- `[subtitulo] Quien va al frente de las manadas`
- `[bloques.0.texto] Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle paso. Los colonos le di…`
- `[bloques.1.texto] No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va adelante.`

</details>

<details><summary><code>data/wiki/lore/la_central.json</code> · Datos (.json) · 6</summary>

- `[titulo] La Central`
- `[subtitulo] Energía y abastecimiento`
- `[bloques.0.texto] La central quedó en el valle donde aterrizó la nave. Produce la energía que necesita la colonia y alimenta la línea que la une con la mina.`
- `[bloques.1.texto] Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.`
- `[bloques.2.texto] Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos siguen camino.`
- `[bloques.3.texto] El informe termina ahí. No dice qué se hará con lo que falta.`

</details>

<details><summary><code>data/wiki/lore/la_compania.json</code> · Datos (.json) · 5</summary>

- `[titulo] La Compañía Meridiana`
- `[subtitulo] Quiénes somos`
- `[bloques.0.texto] La Compañía Meridiana armó la expedición. No es un ejército: es gente de oficio (ingenieros, herreros, carpinteros, agricultores) con herra…`
- `[bloques.1.texto] La nave no puede volver a despegar. Se la va desarmando de a poco para hacer casas, cañerías y torres, y lo que se rompe se arregla con lo …`
- `[bloques.2.texto] Por eso las torres son de hierro, bronce y cristal: se pueden reparar en el lugar. Entre la carga venían también planos y piezas de repuest…`

</details>

<details><summary><code>data/wiki/lore/la_cuadrilla.json</code> · Datos (.json) · 5</summary>

- `[titulo] La Cuadrilla`
- `[subtitulo] Los que andan juntos`
- `[bloques.0.texto] Cerca del aserradero se vieron criaturas chicas y rápidas que se llevan lo que brilla, igual que el Ladrón. A diferencia de él, no andan so…`
- `[bloques.1.texto] Con ellas viene siempre una más grande y lenta, con una bolsa más grande que ella misma donde parece juntarse lo de todas. La llaman el Car…`
- `[bloques.2.texto] Nadie vio que alguna mande ni que alguna obedezca. Parece que van juntas porque buscan lo mismo.`

</details>

<details><summary><code>data/wiki/lore/las_ruinas.json</code> · Datos (.json) · 5</summary>

- `[titulo] Las ruinas`
- `[subtitulo] Lo que había antes`
- `[bloques.0.texto] Sobre la loma del bastión hay muros de piedra y metal, a medio enterrar. Los colonos los llaman «las ruinas» y los tratan como un yacimient…`
- `[bloques.1.texto] Todas llevan la misma marca que las rocas del oasis. Nadie sabe qué quiere decir: puede ser «esto es nuestro», «hasta acá» o un recuerdo.`
- `[bloques.2.texto] El informe de la Compañía dice que las dejó una gente que ya no está. No dice cómo lo sabe.`

</details>

<details><summary><code>data/wiki/lore/los_moradores.json</code> · Datos (.json) · 5</summary>

- `[titulo] Los Moradores`
- `[subtitulo] Los que ya estaban`
- `[bloques.0.texto] Así llama la Compañía a las comunidades que viven en Cántaro. Es un nombre de informe: cómo se llaman ellos a sí mismos no figura en ningún…`
- `[bloques.1.texto] Hasta ahora se vieron dos oficios: los que protegen, de piedra y escudo dorado, y los que curan, con una semilla en el pecho. No está claro…`
- `[bloques.2.texto] Tampoco está claro si guían a los animales de las manadas o si solo cuidan sus propios caminos.`

</details>

<details><summary><code>data/wiki/lore/los_pozos.json</code> · Datos (.json) · 5</summary>

- `[titulo] Los pozos`
- `[subtitulo] Informe del puesto seco`
- `[bloques.0.texto] En el camino seco hay pocos pozos, y todos tienen huellas alrededor. Dos quedaron dentro del perímetro del puesto.`
- `[bloques.1.texto] El mismo día en que se aseguró el paso empezaron los fallos: torres que se apagan sin motivo. Las observaciones coinciden en un encapuchado…`
- `[bloques.2.texto] No ataca a las personas. Ataca lo que construimos.`

</details>

<details><summary><code>data/wiki/lore/planeta_cantaro.json</code> · Datos (.json) · 5</summary>

- `[titulo] Cántaro`
- `[subtitulo] El planeta, o lo que se conoce de él`
- `[bloques.0.texto] Los colonos le pusieron Cántaro al planeta, por el oasis: un poco de agua guardada en una tierra seca.`
- `[bloques.1.texto] Lo que se conoce es un solo rincón: el oasis y lo que lo rodea. Más allá, todavía no se llegó.`
- `[bloques.2.texto] Cada tramo que se asegura se agrega al mapa de la Compañía. El mapa tiene más blanco que dibujo.`

</details>

<details><summary><code>data/wiki/lore/poblados_vacios.json</code> · Datos (.json) · 5</summary>

- `[titulo] Los poblados vacíos`
- `[subtitulo] Lo que quedó en pie`
- `[bloques.0.texto] Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.`
- `[bloques.1.texto] No hay nadie. Las brasas están tibias, así que se fueron hace poco, y se llevaron lo que podían cargar.`
- `[bloques.2.texto] La Compañía registra los poblados como «posiciones desocupadas».`

</details>

<details><summary><code>data/wiki/puntos_y_estrellas.json</code> · Datos (.json) · 8</summary>

- `[titulo] Puntos, estrellas y récords`
- `[subtitulo] Cómo se mide cómo jugaste`
- `[bloques.0.texto] Puntos`
- `[bloques.1.texto] Cada enemigo que matás suma puntos según el oro que da. Si ganás, cada vida que te queda suma más. Ves los puntos arriba, junto al oro.`
- `[bloques.2.texto] Estrellas`
- `[bloques.3.texto] Al ganar un nivel te llevás de 1 a 3 estrellas según cuántas vidas te quedaron: cuantas más, mejores. Las estrellas de todos los niveles se…`
- `[bloques.4.texto] Récords`
- `[bloques.5.texto] Cada nivel tiene su top 5, con tres letras. Quien gana todos los niveles entra al Salón de la fama, que suma el mejor puntaje de cada nivel…`

</details>

<details><summary><code>data/wiki/teclas.json</code> · Datos (.json) · 17</summary>

- `[titulo] Teclas y controles`
- `[subtitulo] Para jugar rápido`
- `[bloques.0.filas.0.0] Tecla`
- `[bloques.0.filas.0.1] Qué hace`
- `[bloques.0.filas.1.0] 1 a 8`
- `[bloques.0.filas.1.1] Elegir una torre para construir`
- `[bloques.0.filas.2.0] Clic izquierdo`
- `[bloques.0.filas.2.1] Construir / seleccionar una torre`
- `[bloques.0.filas.3.0] Clic derecho o Esc`
- `[bloques.0.filas.3.1] Cancelar / cerrar el panel`
- `[bloques.0.filas.4.0] Espacio`
- `[bloques.0.filas.4.1] Empezar la oleada`
- `[bloques.0.filas.5.1] Pausar o seguir`
- `[bloques.0.filas.6.1] Alternar velocidad x1 / x2`
- `[bloques.0.filas.7.1] Mejorar la torre elegida`
- `[bloques.0.filas.8.1] Vender la torre elegida`
- `[bloques.1.texto] En el celular se juega tocando la pantalla: los botones de abajo eligen la torre y el panel de la torre tiene Mejorar y Vender.`

</details>

<details><summary><code>scenes/ui/wiki_screen.gd</code> · GDScript · 7</summary>

- L87 `Label`
- L89 ` ⏎ ` `multilinea`
- L164 `Wiki`
- L189 `Ver la intro`
- L213 `Volver`
- L244 ` %d/%d` `placeholder`
- L391 `atrás`

</details>

<details><summary><code>scripts/logic/wiki.gd</code> · GDScript · 95</summary>

- L20 `Todavía no te cruzaste con este enemigo. Aparece acá cuando lo enfrentes en una partida.`
- L41 `Enemigos`
- L42 `Torres`
- L43 `Colecciones`
- L44 `Guía`
- L45 `Lore`
- L88 `Vuela` `plural`
- L88 `Terrestre` `plural`
- L89 ` · Peligroso` `plural`
- L95 `Vida (oleada 1)`
- L96 `Velocidad`
- L96 `%.1f casillas por segundo` `placeholder`
- L97 `Armadura`
- L98 `Oro al morir`
- L99 `Vidas que quita`
- L100 `Vuela` `plural`
- L100 `sí` `plural`
- L103 `Resistencia a la ralentización`
- L103 `%d %%` `placeholder`
- L105 `Se cura`
- L105 `%.0f %% de su vida por segundo` `placeholder`
- L107 `Robo`
- L107 `%d de oro cada %s s; piso %d, hasta morir o escapar` `placeholder`
- L109 `Carga`
- L109 `tras %s casillas rectas, velocidad ×%s; slow mayor al %s %% la interrumpe` `placeholder`
- L110 `Impacto`
- L110 `%s %% de desgaste a una torre a ≤%s casillas del extremo de la recta; sin destrucción` `placeholder`
- L112 `Al morir suelta`
- L112 `%d × %s` `placeholder`
- L114 `Hechizo`
- L114 `apaga la torre más cercana (a menos de %s casillas) durante %s s, cada %s s` `placeholder`
- L116 `Rebota los tiros`
- L116 `de las torres a menos de %s casillas, y las aturde %s s` `placeholder`
- L118 `a menos de %s casillas` `placeholder`
- L120 `Aura de armadura`
- L120 `+%d de armadura a los enemigos %s` `placeholder`
- L122 `Aura de cura`
- L122 `cura %s %% de la vida por segundo a los enemigos %s` `placeholder`
- L124 `Contramedida`
- L125 `Contramedida`
- L125 `%s (le apaga el aura unos segundos)` `placeholder`
- L128 `Dónde aparece`
- L135 ` ⏎ ` `multilinea`
- L137 `No aparece en la campaña.`
- L139 `Lo suelta al morir: %s.` `placeholder`
- L159 `Nivel %d · %s` `placeholder`
- L201 `Apoyo · no dispara` `plural`
- L201 `Golpea voladores` `plural`
- L201 `Solo terrestres` `plural`
- L209 `Función` `plural`
- L209 `Apoyo de cadencia; no dispara` `plural`
- L209 `Golpea voladores` `plural`
- L209 `sí` `plural`
- L211 `Requisito` `plural`
- L211 `%d %s distintos y permiso del nivel` `placeholder,plural`
- L213 `Pulso`
- L214 `Límites`
- L214 `No alcanza al Espejo y no apaga otras habilidades.`
- L216 `Tamaño`
- L216 `%d×%d casillas` `placeholder`
- L219 `Niveles`
- L220 `Nivel`
- L220 `Oro`
- L220 `Daño`
- L220 `Cadencia`
- L220 `Daño/s`
- L220 `Alcance`
- L224 `%d (%s)` `placeholder,plural`
- L237 `Efectos`
- L239 `Nivel %d: %s` `placeholder`
- L243 `Combos`
- L277 `Piezas en ruinas` `plural`
- L277 `Avances de enemigos portadores` `plural`
- L282 `Se completa con %d piezas distintas, una por nivel de origen. Se guardan al terminar la partida.` `placeholder`
- L284 `Progreso`
- L285 `Desbloquea`
- L285 `todavía ninguna torre`
- L342 `%s: %s` `placeholder`
- L361 `No es un JSON válido (línea %d): %s` `placeholder`
- L368 `La clave \"%s\" no existe (las válidas: %s).` `placeholder`
- L373 `Falta \"desbloqueo\": el id del nivel que abre el artículo, como \"level_08\".`
- L375 `\"desbloqueo\": el nivel \"%s\" no figura en la campaña.` `placeholder`
- L379 `Falta \"version\": %d.` `placeholder`
- L382 `Falta \"titulo\" (un texto).`
- L388 `\"orden\" tiene que ser un número entero.`
- L394 `\"subtitulo\" tiene que ser un texto.`
- L397 `Falta \"bloques\" (una lista con al menos un bloque).`
- L401 `bloque %d` `placeholder`
- L416 `%s: tiene que ser un objeto { }.` `placeholder`
- L423 `%s (%s): falta \"texto\".` `placeholder`
- L428 `%s (%s): falta \"filas\" (una lista de filas).` `placeholder`
- L434 `%s (%s): cada fila tiene que ser una lista de textos.` `placeholder`
- L440 `%s (datos): cada fila tiene 2 textos (nombre y valor).` `placeholder`
- L443 `%s (tabla): todas las filas tienen que tener la misma cantidad de columnas.` `placeholder`
- L448 `%s: el tipo \"%s\" no existe (los válidos: titulo, texto, datos, tabla).` `placeholder`

</details>

<details><summary><code>scripts/logic/wiki_entry.gd</code> · GDScript · 1</summary>

- L56 ` ⏎ ` `multilinea`

</details>

### Torres (nombre, descripción, mejoras)

<details><summary><code>data/towers/basic.tres</code> · Recursos (.tres) · 2</summary>

- L45 `[display_name] Ametralladora`
- L46 `[description] Barata y rápida. Buena contra enemigos débiles; mala contra la armadura.`

</details>

<details><summary><code>data/towers/burst.tres</code> · Recursos (.tres) · 2</summary>

- L48 `[display_name] Ráfaga`
- L49 `[description] Lanza púas en círculo; rinde más en una curva. No le pega a los voladores.`

</details>

<details><summary><code>data/towers/cannon.tres</code> · Recursos (.tres) · 2</summary>

- L51 `[display_name] Cañón`
- L52 `[description] Daño en área contra grupos. No le pega a los voladores.`

</details>

<details><summary><code>data/towers/disruptor.tres</code> · Recursos (.tres) · 2</summary>

- L45 `[display_name] Disruptora`
- L46 `[description] Apaga un rato el aura del Guardián y del Curandero. Casi no hace daño.`

</details>

<details><summary><code>data/towers/fire.tres</code> · Recursos (.tres) · 2</summary>

- L51 `[display_name] Incendiaria`
- L52 `[description] Prende fuego a los enemigos: el fuego ignora la armadura y no los deja curarse.`

</details>

<details><summary><code>data/towers/frost.tres</code> · Recursos (.tres) · 2</summary>

- L51 `[display_name] Hielo`
- L52 `[description] Casi no hace daño, pero frena a los enemigos para que las demás torres les peguen más.`

</details>

<details><summary><code>data/towers/mechanical_standard.tres</code> · Recursos (.tres) · 2</summary>

- L32 `[display_name] Estandarte mecánico`
- L33 `[description] Estatua de ingeniería: aumenta la cadencia de los cañones cercanos. No dispara ni acumula su apoyo con otros estandartes. Requiere cinco avance…`

</details>

<details><summary><code>data/towers/mortar.tres</code> · Recursos (.tres) · 2</summary>

- L51 `[display_name] Mortero`
- L52 `[description] Bomba lenta de gran daño en área y largo alcance. Ideal contra blindados y jefes.`

</details>

<details><summary><code>data/towers/multi.tres</code> · Recursos (.tres) · 2</summary>

- L48 `[display_name] Múltiple`
- L49 `[description] Dispara a varios enemigos a la vez. Buena contra enjambres.`

</details>

<details><summary><code>data/towers/sniper.tres</code> · Recursos (.tres) · 2</summary>

- L48 `[display_name] Francotirador`
- L49 `[description] Muchísimo alcance y daño por tiro. Ideal contra blindados y el Jefe.`

</details>

<details><summary><code>data/towers/tesla.tres</code> · Recursos (.tres) · 2</summary>

- L54 `[display_name] Eléctrica`
- L55 `[description] El rayo salta de un enemigo a otro. Cara y de corto alcance.`

</details>

<details><summary><code>scenes/towers/tower.gd</code> · GDScript · 4</summary>

- L19 `Primero`
- L19 `Último`
- L19 `Más fuerte`
- L19 `Más cercano`

</details>

<details><summary><code>scripts/logic/tower_text.gd</code> · GDScript · 41</summary>

- L21 `Pulso: apaga las auras durante %s s` `placeholder`
- L25 `Apoyo: +%s %% de cadencia; solo el mayor` `placeholder`
- L27 `Repara %s puntos de desgaste/s; solo la mayor tasa` `placeholder`
- L29 `Área: radio %s` `placeholder`
- L31 `El rayo salta a %s enemigos más` `placeholder`
- L33 `Lanza %s púas en círculo` `placeholder`
- L35 `Dispara a %s enemigos a la vez` `placeholder`
- L37 `Quema: %s por segundo durante %s s` `placeholder`
- L39 `+%s %% de daño a ralentizados` `placeholder`
- L41 `+%s %% de daño a quemados` `placeholder`
- L43 `Ralentiza %s %% durante %s s` `placeholder`
- L59 `%s %s %s` `placeholder`
- L66 `Alc. %s` `placeholder`
- L67 `Daño %d · %s/s · Alc. %s` `placeholder`
- L77 `Pulso cada %s s · radio %s · apaga las auras %s s · %d de daño` `placeholder`
- L80 `. Apaga el aura de %s.` `placeholder`
- L149 `a los que frena`
- L153 `a los que quema`
- L167 `Combo: +%d %% a ralentizados.` `placeholder`
- L169 `Combo: +%d %% a quemados.` `placeholder`
- L197 `%s +%d %%` `placeholder`
- L198 `Combo: %s %s` `placeholder`
- L205 `%s y %s` `placeholder`
- L211 `Daño: %d   ·   Cadencia: %.1f/s` `placeholder`
- L212 `Alcance: %.1f casillas` `placeholder`
- L215 `Golpea voladores: %s` `placeholder,plural`
- L215 `sí` `plural`
- L216 ` ⏎ ` `multilinea`
- L228 `%d de oro` `placeholder`
- L231 ` + %d %s` `concatenado,placeholder`
- L239 ` + %d` `concatenado,placeholder`
- L254 `%d de oro` `placeholder`
- L257 `recursos (este mapa no tiene cómo conseguirlos)`
- L259 `%d %s` `placeholder`
- L260 `Faltan ` `concatenado,plural`
- L260 ` y ` `concatenado,plural`
- L267 `%d y %d %s` `placeholder`
- L275 `Recursos invertidos: %d` `placeholder`
- L282 `Costo de construcción`
- L284 `Formas de pago`
- L284 `%s, o %s` `placeholder`

</details>

<details><summary><code>scripts/logic/upgrade_deltas.gd</code> · GDScript · 4</summary>

- L31 `%s %s` `placeholder`
- L56 `%s %s %s %s` `placeholder`
- L89 `¡Nivel máximo!` `plural`
- L89 `¡Nivel %d!` `placeholder,plural`

</details>

### Enemigos y jefes

<details><summary><code>data/enemies/armored.tres</code> · Recursos (.tres) · 2</summary>

- L13 `[display_name] Blindado`
- L14 `[description] Su armadura le quita 3 a cada golpe: la Ametralladora casi no le hace nada. Usa Cañón o Francotirador.`

</details>

<details><summary><code>data/enemies/boss.tres</code> · Recursos (.tres) · 2</summary>

- L12 `[display_name] Jefe`
- L13 `[description] Mucha vida y armadura; el Hielo lo frena a medias. ¡Si llega, quita 10 vidas!`

</details>

<details><summary><code>data/enemies/cargador.tres</code> · Recursos (.tres) · 2</summary>

- L10 `[display_name] Cargador`
- L11 `[description] Grande y lento: lleva la bolsa de la cuadrilla y roba 4 de oro cada 2 segundos, sin bajar de 10. Hace falta daño sostenido.`

</details>

<details><summary><code>data/enemies/colossus.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Coloso`
- L12 `[description] Masa de piedra lenta y muy blindada: los golpes fuertes la rompen. Al caer se parte en tres pedazos rápidos. ¡Si llega, quita 12 vidas!`

</details>

<details><summary><code>data/enemies/colossus_shard.tres</code> · Recursos (.tres) · 2</summary>

- L10 `[display_name] Pedazo`
- L11 `[description] Rápido y sin armadura. El Hielo lo frena y las torres de área lo barren.`

</details>

<details><summary><code>data/enemies/fast.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Rápido`
- L12 `[description] Muy veloz pero frágil. Las Ametralladoras lo frenan bien.`

</details>

<details><summary><code>data/enemies/flyer.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Volador`
- L12 `[description] Vuela en línea recta hacia la salida. ¡El Cañón no le pega!`

</details>

<details><summary><code>data/enemies/guardian.tres</code> · Recursos (.tres) · 2</summary>

- L12 `[display_name] Guardián`
- L13 `[description] Da armadura a los enemigos que lo rodean. Conviene eliminarlo primero, o pegarle de lejos.`

</details>

<details><summary><code>data/enemies/healer.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Curandero`
- L12 `[description] Cura a los enemigos que lo rodean. Conviene eliminarlo primero; el fuego frena la cura.`

</details>

<details><summary><code>data/enemies/mirror.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Espejo`
- L12 `[description] Devuelve los tiros de las torres cercanas y las aturde. El fuego y las torres de largo alcance lo golpean sin problema.`

</details>

<details><summary><code>data/enemies/normal.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Normal`
- L12 `[description] Camina por el camino. Si llega a la salida, quita 1 vida.`

</details>

<details><summary><code>data/enemies/rammer.tres</code> · Recursos (.tres) · 2</summary>

- L8 `[display_name] Embestidor`
- L9 `[description] Carga después de 3 casillas rectas. Al llegar al giro o salida desgasta una torre cercana a ese extremo. Hielo fuerte corta su carga. No destru…`

</details>

<details><summary><code>data/enemies/ratero.tres</code> · Recursos (.tres) · 2</summary>

- L10 `[display_name] Ratero`
- L11 `[description] Chico y veloz. Anda en cuadrilla y cada uno roba 2 de oro cada 2 segundos, sin bajar de 10. Se barren con área.`

</details>

<details><summary><code>data/enemies/shaman.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Chamán`
- L12 `[description] Cada tanto apaga la torre más cercana. Un Francotirador lo alcanza antes de que lance su hechizo.`

</details>

<details><summary><code>data/enemies/spider.tres</code> · Recursos (.tres) · 2</summary>

- L12 `[display_name] Araña`
- L13 `[description] Al morir suelta 4 crías. La Múltiple, la Ráfaga y el Cañón las barren.`

</details>

<details><summary><code>data/enemies/spiderling.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Cría`
- L12 `[description] Frágil y rápida, pero salen de a muchas.`

</details>

<details><summary><code>data/enemies/tank.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Tanque`
- L12 `[description] Lento y con mucha vida. Si llega, quita 2 vidas.`

</details>

<details><summary><code>data/enemies/thief.tres</code> · Recursos (.tres) · 2</summary>

- L8 `[display_name] Ladrón`
- L9 `[description] Roba 3 de oro cada 2 segundos mientras sigue en pantalla, sin bajar de 10. Si ganás monedas, vuelve a robar. Matalo pronto; escapar no añade ot…`

</details>

<details><summary><code>data/enemies/troll.tres</code> · Recursos (.tres) · 2</summary>

- L11 `[display_name] Troll`
- L12 `[description] Se cura solo con el tiempo. El fuego de la Incendiaria le corta la curación.`

</details>

<details><summary><code>scenes/ui/enemy_icon.gd</code> · GDScript · 2</summary>

- L44 `≤%d?` `placeholder,plural`
- L44 `×%d` `placeholder,plural`

</details>

### Modos (Asedio y otros)

<details><summary><code>data/modos/asedio/modo.json</code> · Datos (.json) · 2</summary>

- `[nombre] Asedio`
- `[descripcion] Los 15 mapas de la campaña con monstruos más duros, cada uno con su dificultad. Ganar un mapa abre el siguiente.`

</details>

<details><summary><code>scripts/logic/mode_packs.gd</code> · GDScript · 35</summary>

- L47 `Ya hay un modo oficial llamado '%s': cambiale el nombre a la carpeta.` `placeholder`
- L82 `Nombre de carpeta no válido: solo minúsculas, números y _ (hasta %d letras).` `placeholder`
- L86 `Falta el archivo %s en la carpeta del modo.` `placeholder`
- L89 `%s es demasiado grande.` `placeholder`
- L181 `Escribí un nombre.`
- L183 `El nombre tiene %d letras y el máximo es %d.` `placeholder`
- L186 `El nombre necesita al menos una letra o un número.`
- L188 `'%s' es un modo oficial: elegí otro nombre.` `placeholder`
- L190 `Ya tenés un modo llamado '%s'.` `placeholder`
- L201 `No se pudo leer %s del modo.` `placeholder`
- L220 `Clave desconocida \"%s\" (se usan: %s).` `placeholder`
- L222 `\"version\" tiene que ser %d.` `placeholder`
- L227 `\"nombre\" tiene que ser un texto, como \"Asedio\".`
- L229 `El nombre tiene %d letras y el máximo es %d.` `placeholder`
- L234 `\"descripcion\" tiene que ser un texto de hasta %d letras.` `placeholder`
- L248 `\"mapas\" tiene que ser una lista de nombres de mapa, como [\"level_01\"].`
- L252 `\"mapas\" tiene %d mapas y el máximo es %d.` `placeholder`
- L256 `\"mapas\": '%s' no es un nombre de mapa válido (minúsculas, números y _).` `placeholder`
- L258 `\"mapas\": '%s' está repetido.` `placeholder`
- L268 `\"torres\" tiene que ser una lista con al menos una torre, como [\"basic\", \"cannon\"].`
- L272 `\"torres\": la torre '%s' no existe. Las que hay: %s.` `placeholder`
- L281 `\"reglas\" tiene que estar entre { }, como {\"vida_monstruos_%\": 150}.` `placeholder`
- L286 `\"reglas\": clave desconocida \"%s\" (se usan: %s).` `placeholder`
- L301 `\"reglas\": \"%s\" tiene que estar entre { }, como {\"level_01\": 105}.` `placeholder`
- L306 `\"reglas\": \"%s\" nombra el mapa '%s', que no está en \"mapas\" (los del modo: %s).` `placeholder`
- L309 `%s\" para el mapa \"%s` `placeholder`
- L315 `\"reglas\": \"%s\" tiene que ser un número entero entre %d y %d.` `placeholder`
- L327 `No existe el mapa '%s': ni en la carpeta del modo ni entre los niveles oficiales.` `placeholder`
- L330 `El mapa '%s' es demasiado grande.` `placeholder`
- L367 `El mapa '%s' ofrece las torres %s y este modo permite %s: no tienen ninguna en común, así que no habría con qué defenderse.` `placeholder`
- L374 `%s no es un JSON válido (línea %d: %s).` `placeholder`
- L377 `%s tiene que empezar con { y terminar con }.` `placeholder`
- L385 `No se pudo escribir %s (%s).` `placeholder`
- L386 `\t` `concatenado`
- L386 ` ⏎ ` `concatenado,multilinea`

</details>

### Novedades

<details><summary><code>data/novedades/novedades.json</code> · Datos (.json) · 20</summary>

- `[interfaz.entendido] Entendido`
- `[interfaz.titulo_novedades] Novedades de esta versión`
- `[interfaz.titulo_mejoras] Mejoras de esta versión`
- `[interfaz.sin_novedades] No hay novedades`
- `[versiones.0.titulo] Monsters & Canons 1.0`
- `[versiones.0.subtitulo] Esto es lo que trae el juego completo.`
- `[versiones.0.novedades.0.titulo] 15 niveles, una historia`
- `[versiones.0.novedades.0.texto] Defendé la colonia a lo largo de toda la campaña, con textos de cada lugar y un epílogo final.`
- `[versiones.0.novedades.1.titulo] Torres que se mejoran`
- `[versiones.0.novedades.1.texto] Torres de distintos estilos, cada una con tres niveles. Combinalas: algunas se potencian entre sí.`
- `[versiones.0.novedades.2.titulo] Monstruos con carácter`
- `[versiones.0.novedades.2.texto] Jefes, curanderos, chamanes y espejos: cada enemigo se juega distinto. La Wiki explica cómo enfrentarlos.`
- `[versiones.0.novedades.3.titulo] Asedio`
- `[versiones.0.novedades.3.texto] Un modo aparte con los mapas de la campaña y monstruos más duros, con estrellas y récords propios.`
- `[versiones.0.novedades.4.titulo] Tus propios mapas`
- `[versiones.0.novedades.4.texto] En la PC, el editor deja crear niveles y jugarlos.`
- `[versiones.0.novedades.5.titulo] PC y celular`
- `[versiones.0.novedades.5.texto] Interfaz táctil con zoom, botones flotantes y menús que se desplazan con el dedo, además de mouse y teclado.`
- `[versiones.0.novedades.6.titulo] Intro y tutorial`
- `[versiones.0.novedades.6.texto] La intro cuenta cómo llegó la nave y el tutorial del primer nivel te enseña a jugar. Los dos se pueden saltear.`

</details>

<details><summary><code>scenes/ui/news_screen.gd</code> · GDScript · 11</summary>

- L154 `Header`
- L169 `Title`
- L173 `Subtitle`
- L176 `Version`
- L179 `Scroll`
- L190 `Understood`
- L191 `Entendido`
- L205 `Borrador`
- L219 `Item`
- L224 `Icon`
- L253 `Marker`

</details>

<details><summary><code>scripts/logic/news_data.gd</code> · GDScript · 33</summary>

- L32 `novedades: no existe el archivo %s.` `placeholder`
- L36 `novedades: no se pudo abrir %s.` `placeholder`
- L41 `novedades: %s no es un JSON válido (línea %d: %s).` `placeholder`
- L50 `novedades: el archivo tiene que ser un objeto con \"version\", \"interfaz\" y \"versiones\".`
- L54 `novedades: \"version\" tiene que ser %d.` `placeholder`
- L58 `novedades: \"versiones\" tiene que ser una lista (puede estar vacía).`
- L99 `la versión %s de project.godot no tiene entrada en las novedades (no se mostrará nada).` `placeholder`
- L101 `la entrada de la versión %s sigue en borrador (no se mostrará sola hasta pasar \"borrador\" a false).` `placeholder`
- L107 `novedades: \"interfaz\" tiene que ser un objeto con los rótulos fijos (%s).` `placeholder`
- L113 `novedades: \"interfaz\" necesita \"%s\" con un texto.` `placeholder`
- L121 `la versión número %d de la lista tiene que ser un objeto.` `placeholder`
- L127 `la versión número %d de la lista no tiene \"id\" (tiene que ser la versión, por ejemplo \"1.0.0\").` `placeholder`
- L128 `número %d` `placeholder`
- L132 `la versión %s está repetida.` `placeholder`
- L134 `la versión %s` `placeholder`
- L137 `%s: \"tipo\" tiene que ser \"%s\" o \"%s\".` `placeholder`
- L142 `%s: \"borrador\" tiene que ser true o false.` `placeholder`
- L151 `%s: \"novedades\" tiene que ser una lista de 1 a %d.` `placeholder`
- L155 `%s tiene %d novedades y tiene que haber de 1 a %d.` `placeholder`
- L168 `%s, novedad %d: tiene que ser un objeto con \"titulo\" y \"texto\".` `placeholder`
- L171 `%s, novedad %d` `placeholder`
- L174 `%s, novedad %d («%s»)` `placeholder`
- L187 `%s: \"%s\" tiene que ser un texto entre comillas%s.` `placeholder,plural`
- L187 ` (o sacá la clave)` `plural`
- L191 `%s: \"%s\" no puede tener saltos de línea ni caracteres de control.` `placeholder`
- L193 `%s: \"%s\" tiene %d caracteres y el máximo es %d.` `placeholder`
- L200 `%s: \"texto\" tiene que ser un texto entre comillas.` `placeholder`
- L204 `%s: el texto tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).` `multilinea,placeholder`
- L207 `%s: el texto tiene %d líneas y el máximo es %d.` `placeholder`
- L209 `%s: el texto tiene %d caracteres y el máximo es %d.` `placeholder`
- L212 `%s: el texto tiene una línea en blanco.` `placeholder`
- L222 `%s: \"%s\" tiene que ser una ruta que empiece con res://.` `placeholder`
- L225 `%s no encuentra la imagen '%s' (\"%s\").` `placeholder`

</details>

### Editor de mapas y comunidad

<details><summary><code>scenes/editor/banner_editor.gd</code> · GDScript · 3</summary>

- L50 `Predeterminado seleccionado. Aplicalo para guardarlo.`
- L56 `No se pudo guardar. Revisá el espacio y los permisos del dispositivo.`
- L58 `Diseño aplicado.`

</details>

<details><summary><code>scenes/editor/banner_editor.tscn</code> · Escenas (.tscn) · 8</summary>

- L57 `[text] Editor de banderines`
- L74 `[text] Vista del poste`
- L87 `[text] Así se ve en el mapa (34 px)`
- L105 `[text] Paleta`
- L115 `[text] Emblema`
- L139 `[text] Restaurar`
- L146 `[text] Aplicar`
- L152 `[text] Cancelar`

</details>

<details><summary><code>scenes/editor/editor_dialog.gd</code> · GDScript · 1</summary>

- L65 `Cancelar`

</details>

<details><summary><code>scenes/editor/map_editor.gd</code> · GDScript · 68</summary>

- L14 `Pasto`
- L14 `Camino`
- L14 `Bloqueada`
- L14 `Entrada`
- L14 `Salida`
- L14 `Árbol`
- L14 `Roca`
- L14 `Escombro`
- L14 `Mina`
- L14 `Bosque`
- L17 `Árbol removible: se despeja pagando oro (Demoler)`
- L17 `Roca removible: se despeja pagando oro (Demoler)`
- L18 `Escombro: ruinas removibles; en la campaña pueden esconder una pieza`
- L19 `Mina: punto de extracción de recursos`
- L19 `Bosque explotable: punto de extracción de recursos`
- L198 `Nuevo nivel`
- L198 `Nivel nuevo`
- L203 `Abrir otro nivel`
- L217 `— Mis modos —`
- L219 `%s (%s)` `placeholder`
- L220 `+ Nuevo modo…`
- L222 `Guardar en un modo`
- L222 `Elegí el modo donde se guarda este mapa.`
- L222 `Elegir`
- L233 `✗ No se creó el modo: ` `concatenado`
- L236 `Nuevo modo`
- L236 `Nombre del modo (se ve como una solapa en la selección de nivel):`
- L237 `Crear`
- L246 `Se crea la carpeta ` `concatenado`
- L253 `✗ No se puede probar todavía: ` `concatenado`
- L264 `Salir del editor`
- L265 `Hay cambios sin guardar. Si cerrás el juego se pierden. ⏎ (Mientras el juego siga abierto, el borrador se conserva y se retoma al volver.)` `multilinea`
- L266 `Salir igual`
- L275 `Hay cambios sin guardar. Si seguís, se pierden.`
- L275 `Descartar y seguir`
- L313 `Guardar el mapa` `plural`
- L313 `Guardar el mapa en el modo '%s'` `placeholder,plural`
- L314 `Nombre del archivo (minúsculas, números y _):`
- L315 `Guardar`
- L321 `Escribí un nombre.`
- L323 `Solo minúsculas, números y _ (hasta %d letras).` `placeholder`
- L325 `'%s' es el nombre de un nivel oficial: elegí otro para no pisarlo.` `placeholder`
- L327 `'%s' está reservado para el archivo del modo: elegí otro.` `placeholder`
- L329 `Ya hay un mapa con ese nombre: se va a reemplazar.`
- L330 `Se guarda en ` `concatenado`
- L340 `✗ No se guardó: ` `concatenado`
- L343 `Guardado en ` `concatenado`
- L353 `— Mis mapas —`
- L356 `(todavía no guardaste ninguno)`
- L365 `— Modo %s —` `placeholder`
- L368 `— Niveles oficiales (se abren como plantilla) —`
- L371 `%s · %s` `placeholder`
- L374 `Abrir un nivel`
- L374 `Abrir`
- L385 `Guardar`
- L389 `✗ No se pudo abrir ` `concatenado`
- L391 `Abierto: %s` `placeholder`
- L393 `Abierto como plantilla: %s (al guardarlo pide otro nombre)` `placeholder`
- L414 `Editor de mapas · %s%s` `placeholder,plural`
- L428 `Editor de mapas · %s%s` `placeholder,plural`
- L463 `   (y %d más)` `concatenado,placeholder,plural`
- L471 `✓ Nivel válido · ` `concatenado`
- L474 ` ⏎ ` `concatenado,multilinea`
- L482 `Entrada %s: %d casillas` `placeholder`
- L490 `%s (%d)` `placeholder`
- L500 `Clic der.: borra · Ctrl+Z/Y · Ctrl+S`
- L507 `Deshacer`
- L508 `Rehacer`

</details>

<details><summary><code>scenes/editor/map_editor.tscn</code> · Escenas (.tscn) · 13</summary>

- L70 `[text] Editor de mapas`
- L78 `[text] Nuevo`
- L85 `[text] Abrir`
- L92 `[text] Guardar`
- L99 `[tooltip_text] Guardar el mapa dentro de un modo propio (o crear uno nuevo)`
- L100 `[text] En un modo…`
- L107 `[text] Probar`
- L118 `[text] Ajustes`
- L126 `[text] Oleadas`
- L134 `[tooltip_text] Los valores de los removibles y de la extracción que hay en el mapa`
- L135 `[text] Objetos`
- L142 `[text] Salir`
- L177 `[text] ✓ Nivel válido`

</details>

<details><summary><code>scenes/editor/objects_panel.gd</code> · GDScript · 25</summary>

- L9 `Árbol removible`
- L9 `Roca removible`
- L9 `Escombro`
- L10 `Mina`
- L10 `Bosque explotable`
- L14 `Costo`
- L14 `Tiempo`
- L14 `Recursos`
- L14 `Probabilidad`
- L15 `Producción por oleada`
- L15 `Reserva`
- L18 ` de oro`
- L18 ` s`
- L20 `(sin pieza)`
- L21 `Las piezas de colección solo se consiguen en la campaña`
- L35 `Objetos del mapa`
- L36 `Todavía no hay objetos. Pintá un árbol, una roca, un escombro, una mina o un bosque explotable y volvé acá para cambiar sus valores.`
- L42 `Cada letra de la leyenda es una clase de objeto. Lo que cambies vale para todas sus casillas.`
- L56 `Spin_` `concatenado`
- L64 `Pieza de colección`
- L74 `Los valores en gris claro de cada dato son los de la clase: si escribís el mismo número, la sobrescritura se borra.`
- L93 `%s · %s` `placeholder`
- L112 `%s (clase: %s)` `placeholder`
- L113 `De la clase: %s%s` `placeholder`
- L138 `Qué colección entrega la pieza escondida entre estas ruinas.`

</details>

<details><summary><code>scenes/editor/settings_panel.gd</code> · GDScript · 16</summary>

- L20 `Ajustes del nivel`
- L26 ` de oro`
- L27 ` vidas`
- L29 `Vida extra de los enemigos en cada oleada. 0 = usar el general (spec §7.4).`
- L35 `Nombre`
- L35 `Oro inicial`
- L35 `Vidas`
- L36 `Vida extra por oleada`
- L43 `0 en la vida extra = usar el general del juego. Los niveles oficiales van de 10 % a 35 %.` `placeholder`
- L47 `Demoledora disponible`
- L48 `El nivel habilita comprar la demoledora para despejar removibles (RF-411).`
- L54 `Torres del mapa`
- L64 `Usar las de siempre`
- L89 `Tower_` `concatenado`
- L103 `El mapa ofrece solo las marcadas (RF-393). Tiene que quedar al menos una.`
- L104 `Sin lista propia: se ofrecen las de siempre (las comunes más las de torres_extra). Marcar o desmarcar una arma la lista.`

</details>

<details><summary><code>scenes/editor/waves_panel.gd</code> · GDScript · 22</summary>

- L28 `Oleadas`
- L35 `Prev`
- L38 `Next`
- L39 `Quitar`
- L45 `Agregar`
- L46 `Copiar`
- L61 `+ Agregar grupo`
- L91 `Oleada %d de %d` `placeholder`
- L110 `Enemigos en esta oleada: %d` `placeholder`
- L113 ` (máximo; incluye opcionales)`
- L121 `Enemigo`
- L121 `Cantidad`
- L121 `Cada`
- L122 `Desde`
- L122 `Entrada`
- L122 `Azar %`
- L142 `%s (no existe)` `placeholder`
- L156 ` s`
- L160 ` s`
- L180 `Probabilidad de que salga este grupo al iniciar la oleada.100%: siempre.`
- L186 `Quitar este grupo`
- L236 `Button`

</details>

<details><summary><code>scripts/logic/community_maps.gd</code> · GDScript · 2</summary>

- L62 `Nombre de archivo no válido: solo minúsculas, números y _ (hasta %d letras).` `placeholder`
- L67 `El archivo es demasiado grande (%d KB; el máximo es %d KB).` `placeholder`

</details>

<details><summary><code>scripts/logic/level_draft.gd</code> · GDScript · 37</summary>

- L15 `Nivel nuevo`
- L617 `  \"version\": %d,` `placeholder`
- L618 `  \"nombre\": %s,` `placeholder`
- L619 `  \"oro\": %d,` `placeholder`
- L620 `  \"vidas\": %d,` `placeholder`
- L622 `  \"aumento_vida\": %d,` `placeholder`
- L624 `  \"tema\": %s,` `placeholder`
- L629 `    %s: %s` `placeholder`
- L630 `  \"leyenda\": { ⏎ ` `concatenado,multilinea`
- L630 `, ⏎ ` `concatenado,multilinea`
- L630 ` ⏎   },` `concatenado,multilinea`
- L632 `  \"torres_extra\": %s,` `placeholder`
- L634 `  \"torres\": %s,` `placeholder`
- L636 `  \"demoledora\": %s,` `placeholder`
- L639 `  \"mapa\": [`
- L642 `    \"%s\"%s` `placeholder,plural`
- L644 `  \"oleadas\": [`
- L650 `, ⏎      ` `concatenado,multilinea`
- L653 ` ⏎ ` `concatenado,multilinea`
- L653 ` ⏎ ` `concatenado,multilinea`
- L660 `  \"textos\": %s,` `placeholder`
- L671 `    %s: %s` `placeholder`
- L672 `  \"textos\": { ⏎ ` `concatenado,multilinea`
- L672 `, ⏎ ` `concatenado,multilinea`
- L672 ` ⏎   },` `concatenado,multilinea`
- L677 `^[a-z0-9_]+$`
- L699 `El nombre del archivo solo puede tener minúsculas, números y _.`
- L701 `'%s' es el nombre de un nivel oficial: elegí otro para no pisarlo.` `placeholder`
- L705 `No se pudo escribir el archivo (error %d).` `placeholder`
- L834 `La leyenda ya tiene %d letras, que es el máximo. Borrá todos los objetos de una clase para poder usar otra.` `placeholder`
- L838 `No quedan letras libres para la leyenda.`
- L917 `\"enemigo\": %s` `placeholder`
- L918 `\"cantidad\": %d` `placeholder`
- L919 `\"cada\": %s` `placeholder`
- L922 `\"desde\": %s` `placeholder`
- L924 `\"entrada\": %s` `placeholder`
- L926 `\"probabilidad\": %s` `placeholder`

</details>

<details><summary><code>scripts/logic/level_file.gd</code> · GDScript · 75</summary>

- L39 `No existe el archivo %s.` `placeholder`
- L59 `El nombre tiene %d letras y el máximo es %d.` `placeholder`
- L69 `demoledora: tiene que ser true o false.`
- L82 `Falta \"mapa\".`
- L84 `mapa: tiene que ser una lista de filas entre comillas, como [\"....\", \"A###\"].`
- L89 `mapa: ` `concatenado`
- L96 `Falta \"oleadas\".`
- L98 `oleadas: tiene que ser una lista con al menos una oleada.`
- L100 `oleadas: hay %d y el máximo es %d.` `placeholder`
- L104 `oleada %d` `placeholder`
- L110 `mapa: ` `concatenado`
- L112 `demoledora: el nivel la habilita pero no tiene removibles.`
- L116 `torres: el %s cuesta recursos y este mapa no tiene cómo conseguirlos.` `placeholder`
- L141 `No existe el archivo.`
- L146 `\"niveles\" tiene que ser una lista de nombres de nivel, como [\"level_01\"].`
- L148 `El archivo tiene que empezar con { y terminar con }.` `placeholder`
- L160 `tiene que ser una lista con al menos un grupo, como [{\"enemigo\": \"normal\", \"cantidad\": 5, \"cada\": 1.0}].` `placeholder`
- L164 `tiene %d grupos y el máximo es %d.` `placeholder`
- L167 `%s, grupo %d` `placeholder`
- L169 `tiene que estar entre { }.` `placeholder`
- L182 `no existe el enemigo '%s' (tiene que ser un archivo de data/enemies/).` `placeholder`
- L189 `\"cada\" tiene que ser mayor que 0 (si no, salen todos juntos).`
- L196 `\"entrada\" tiene que ser una letra, como \"A\" o \"B\".`
- L198 `la entrada %s no está en el mapa.` `placeholder`
- L220 `^[a-z0-9_]+$`
- L249 `torres_extra: tiene que ser una lista de nombres de torre entre comillas, como [\"mortar\"].`
- L254 `torres_extra: la torre \"%s\" no existe. Las que hay: %s.` `placeholder`
- L267 `torres: tiene que ser una lista con al menos una torre entre comillas, como [\"frost\", \"cannon\"].`
- L272 `torres: la torre \"%s\" no existe. Las que hay: %s.` `placeholder`
- L286 `tema: %s no existe. Los que hay: %s.` `placeholder`
- L303 `leyenda: tiene que ser un objeto con una letra por entrada, como {\"~\": {\"dibujo\": \"agua\"}}.` `placeholder`
- L309 `leyenda: hay %d letras y el máximo es %d.` `placeholder`
- L312 `leyenda \"%s\"` `placeholder`
- L315 `%s: %s` `placeholder`
- L318 `%s: tiene que ser un objeto, como {\"dibujo\": \"agua\"}.` `placeholder`
- L325 `%s: no puede tener \"removible\" y \"extraccion\" a la vez.` `placeholder`
- L341 `%s: falta \"clase\" (tiene que ser un texto).` `placeholder`
- L347 `%s: el dibujo %s no existe. Los que hay: %s.` `placeholder`
- L350 `%s: el dibujo de la clase \"%s\" no existe.` `placeholder`
- L353 `%s: el dibujo tiene que ser \"%s\", como la clase.` `placeholder`
- L357 `%s: \"construible\" tiene que ser true o false.` `placeholder`
- L360 `%s: \"construible\" no puede ser true en un removible ni en una extracción.` `placeholder`
- L373 `\"%s\" tiene que ser un objeto.` `placeholder`
- L380 `%s: falta \"clase\" (tiene que ser un texto).` `placeholder`
- L385 `%s: la clase \"%s\" no existe. Las que hay: %s.` `placeholder`
- L393 ` → removible → ` `concatenado`
- L395 ` → removible → tiempo` `concatenado`
- L405 `\"hallazgo\" solo se puede usar en un escombro.`
- L409 `la colección \"%s\" no existe en progression.json.` `placeholder`
- L413 ` → extraccion → ` `concatenado`
- L452 `leyenda \"%s\" en %s` `placeholder`
- L452 `ya hay un hallazgo de la colección \"%s\" en este nivel (letra \"%s\").` `placeholder`
- L471 `tiene que ser %s.` `placeholder,plural`
- L471 `un número entero mayor que 0` `plural`
- L471 `un número entero de 0 para arriba` `plural`
- L478 `tiene que ser mayor que 0.`
- L484 ` → probabilidad` `concatenado`
- L486 `\"probabilidad\" no puede superar 100.`
- L494 `tiene que ser una sola letra o símbolo.`
- L495 `. # X S`
- L496 `esa letra ya significa algo (. # X S y las entradas A a H).`
- L498 `no puede ser un espacio, una comilla ni una barra.`
- L507 `El archivo no es un JSON válido (línea %d: %s). Revisá comas, comillas y llaves.` `placeholder`
- L517 `clave desconocida \"%s\" (se usan: %s).` `placeholder`
- L522 `Falta \"version\" (hoy es %d).` `placeholder`
- L524 `La versión %s no se puede leer: este juego lee la %d.` `placeholder`
- L529 `falta \"%s\".` `placeholder`
- L532 `\"%s\" tiene que ser un texto entre comillas.` `placeholder`
- L541 `falta \"%s\".` `placeholder`
- L545 `\"%s\" tiene que ser un número entero.` `placeholder`
- L548 `\"%s\" tiene que ser %d o más.` `placeholder`
- L551 `\"%s\" tiene que ser %d o menos (es demasiado grande).` `placeholder`
- L559 `falta \"%s\".` `placeholder`
- L563 `\"%s\" tiene que ser un número de 0 para arriba (segundos).` `placeholder`
- L566 `\"%s\" tiene que ser %s segundos o menos.` `placeholder`

</details>

<details><summary><code>scripts/logic/map_grid.gd</code> · GDScript · 17</summary>

- L102 `fila %d, columna %d` `placeholder`
- L107 `El mapa tiene %d filas y tiene que tener entre %d y %d.` `placeholder`
- L112 `La fila 1 tiene %d letras y tiene que tener entre %d y %d.` `placeholder`
- L121 `La fila %d tiene %d letras y la fila 1 tiene %d: todas las filas tienen que tener el mismo largo.` `placeholder`
- L139 `La entrada %s está dos veces (%s y %s).` `placeholder`
- L152 `Letra desconocida '%s' en %s. Se usan: . # X S, las entradas A, B, C… y las letras que declares en la \"leyenda\" del nivel.` `placeholder`
- L156 `Falta la salida (S).`
- L158 `Hay %d salidas (S) y tiene que haber una sola.` `placeholder`
- L162 `Falta la entrada A.`
- L167 `Está la entrada %s pero falta la %s.` `placeholder`
- L171 `No hay pasto (.): no se podría construir ninguna torre.`
- L175 `La letra '%s' está en la leyenda pero no se usa en el mapa.` `placeholder`
- L195 `La entrada %s (%s) no tiene camino hasta la salida.` `placeholder`
- L204 `Desde la entrada %s hay dos recorridos igual de cortos: se separan en %s. Cerrá uno (con X o pasto) o hacelo más largo.` `placeholder`
- L229 `Hay %d casillas de camino que ningún recorrido usa (%s%s). Puede ser un atajo: ` `placeholder`
- L230 `dos partes del camino quedaron en casillas vecinas y el enemigo se salta el tramo del medio. ` `concatenado`
- L231 `También puede ser un callejón sin salida o un camino de dos casillas de ancho.` `concatenado`

</details>

### Mensajes técnicos y de desarrollo (a decidir si se traducen)

<details><summary><code>scenes/ui/touch_scroller.gd</code> · GDScript · 1</summary>

- L145 `Control`

</details>

<details><summary><code>scripts/autoload/audio.gd</code> · GDScript · 1</summary>

- L13 `Music`

</details>

<details><summary><code>scripts/autoload/dev_mode.gd</code> · GDScript · 7</summary>

- L13 `MODO PRUEBAS · F1: panel`
- L21 `Matar a todos`
- L22 `Saltar oleada`
- L23 `Vidas infinitas`
- L24 `Velocidad más lenta`
- L25 `Velocidad más rápida`
- L105 ` · %s` `placeholder`

</details>

<details><summary><code>scripts/autoload/save_manager.gd</code> · GDScript · 1</summary>

- L221 `[^A-Za-z0-9._-]`

</details>

<details><summary><code>scripts/logic/balance_args.gd</code> · GDScript · 4</summary>

- L128 `no es un JSON con { }` `placeholder`
- L133 `'%s' necesita {\"estrategia\": ..., \"mejoras\": ...}` `placeholder`
- L136 `'%s': \"mejoras\" tiene que ser llenar o temprana` `placeholder`
- L139 `falta \"por_defecto\"`

</details>

<details><summary><code>scripts/logic/desktop_window.gd</code> · GDScript · 2</summary>

- L14 `Windows`
- L14 `Linux`

</details>

<details><summary><code>scripts/logic/dev_stats.gd</code> · GDScript · 1</summary>

- L54 `\t`

</details>

<details><summary><code>scripts/logic/record_sources.gd</code> · GDScript · 3</summary>

- L23 `Mapa %d · %s` `placeholder`
- L24 `El mapa no se pudo cargar`
- L26 `Mapa %d · %s` `placeholder`

</details>

<details><summary><code>scripts/logic/scene_transition.gd</code> · GDScript · 7</summary>

- L41 `Cargando…`
- L206 `Root`
- L213 `Background`
- L219 `Center`
- L226 `Column`
- L231 `Title`
- L239 `Bar`

</details>

### Coleccionables y hallazgos

<details><summary><code>scripts/logic/collection_definitions.gd</code> · GDScript · 2</summary>

- L80 `La colección \"%s\" pide %d piezas pero tiene %d fuentes.` `placeholder`
- L82 `La colección \"%s\" tiene un origen desconocido: \"%s\".` `placeholder`

</details>
