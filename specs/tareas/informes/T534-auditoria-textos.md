# T534 · Auditoría de textos que siguen en español fuera del catálogo

*Generada con `python3 tools/localization_inventory.py --auditoria` (solo lee el proyecto). Parte de los candidatos del inventario T533 (`T533-inventario-textos.md`) y descarta los textos que ya viven en `data/i18n/es.json` y las líneas que ya llaman a `Localization`. Es una heurística: lo que queda se clasificó por ruta y por forma de la línea.*

- Candidatos del inventario ya cubiertos por el catálogo (descartados): **341**.
- Lore: **124** en **28** archivos.
- Validación de datos de desarrollo (solo consola/tests): **199** en **13** archivos.
- Herramienta de desarrollo (documento y mensajes de tools/intro_doc.gd): **62** en **1** archivos.
- Texto por omisión de escena (el código lo reemplaza o está oculto): **14** en **6** archivos.
- Texto sin uso (campo `text` de `DevMode.ACTIONS`, que ningún código lee): **5** en **1** archivos.
- Nombre técnico, id o formato (no es texto de jugador): **169** en **43** archivos.
- Notas internas de archivos de datos (no se muestran): **3** en **2** archivos.
- Revisar a mano: **0** en **0** archivos.
- Total que sigue fuera del catálogo: **576**.

## Lore

***Es lo único que queda en español como texto de jugador** (D-222): lugar, entrada y victoria y nombre de los 15 niveles, intro, créditos (incluye «Un juego de Lucas», «Hecho con Godot Engine» y la línea de licencia) y los 11 artículos de Lore de la Wiki. Se traduce después de T545/T558 y con el OK de Lucas; mientras tanto el respaldo en español los muestra. También son Lore los nombres de nivel que salen en el selector, en Récords y en la lista «Abrir un nivel» del editor.*

<details><summary><code>data/creditos.json</code> · 4</summary>

- `[lineas.1] Un juego de Lucas`
- `[lineas.2] Lucas Felici`
- `[lineas.3] lucas.a.felici@gmail.com`
- `[lineas.5] Software libre bajo la licencia GPL-3.0-or-later (los detalles, en Wiki → Licencias)`

</details>

<details><summary><code>data/intro/intro.json</code> · 7</summary>

- `[laminas.0.texto] La Compañía Meridiana mandó una sola nave. No lleva soldados: lleva gente de oficio.`
- `[laminas.1.texto] Herreros, carpinteros, ingenieros, agricultores: cada uno trajo su oficio. Hay semillas, planos y piezas para empezar d…`
- `[laminas.2.texto] Fueron años de viaje. Se durmió por turnos y lo que se rompía se arreglaba a bordo. Era un viaje de ida.`
- `[laminas.3.texto] El reconocimiento vio agua en un solo lugar de todo el planeta. Hacia ahí apuntó la nave.`
- `[laminas.4.texto] La bajada fue brusca. El casco crujió entero, pero aguantó.`
- `[laminas.5.texto] Los motores se apagaron al tocar tierra. La nave ya no va a despegar.`
- `[laminas.6.texto] Un valle chico, con agua y pasto, en medio de la nada. Acá nos quedamos.`

</details>

<details><summary><code>data/levels/level_01.json</code> · 4</summary>

- `[nombre] Pradera`
- `[textos.lugar] Campamento de aterrizaje`
- `[textos.entrada] La nave quedó en el borde del oasis. Hay agua, pasto y un terreno firme donde armar el campamento. Antes de descargar, h…`
- `[textos.victoria] Campamento asegurado. Las primeras torres quedaron en pie. La carga de la nave se baja esta noche.`

</details>

<details><summary><code>data/levels/level_02.json</code> · 3</summary>

- `[nombre] Desfiladero`
- `[textos.entrada] El agua dulce más cercana está al otro lado del desfiladero. Sin ese paso, el campamento no aguanta. Hay que sostenerlo …`
- `[textos.victoria] Paso asegurado. El agua llega al campamento por primera vez. Faltan tres tramos de cañería.`

</details>

<details><summary><code>data/levels/level_03.json</code> · 4</summary>

- `[nombre] Encrucijada`
- `[textos.lugar] Las huertas`
- `[textos.entrada] Al norte del campamento hay tierra buena para sembrar. Dos caminos se cruzan justo ahí, y por los dos llegan manadas. Si…`
- `[textos.victoria] Huertas aseguradas. Se sembró el primer surco. Lo que crezca depende de que las torres aguanten.`

</details>

<details><summary><code>data/levels/level_04.json</code> · 4</summary>

- `[nombre] Espiral`
- `[textos.lugar] El pozo`
- `[textos.entrada] El arroyo no alcanza para toda la colonia. Hay que cavar un pozo en el centro del valle. El camino hasta ahí da muchas v…`
- `[textos.victoria] Pozo terminado. Hay agua para toda la colonia. Se armó un turno de guardia para cuidarlo.`

</details>

<details><summary><code>data/levels/level_05.json</code> · 4</summary>

- `[nombre] Fortaleza`
- `[textos.lugar] La empalizada`
- `[textos.entrada] El campamento ya es un pueblo y todavía no tiene cerco. Hoy se cierra el primer perímetro. Lo que quede afuera, queda af…`
- `[textos.victoria] Empalizada cerrada. Es el primer perímetro de la colonia. Por primera vez, dormimos adentro.`

</details>

<details><summary><code>data/levels/level_06.json</code> · 4</summary>

- `[nombre] Nido`
- `[textos.lugar] El lindero`
- `[textos.entrada] El bosque empieza donde termina el cerco. Hay madera para varios años, y también criaturas que no habíamos visto. Del ca…`
- `[textos.victoria] Lindero asegurado. Se taló el primer tramo. La madera alcanza para dos casas.`

</details>

<details><summary><code>data/levels/level_07.json</code> · 4</summary>

- `[nombre] Cruce`
- `[textos.lugar] El aserradero`
- `[textos.entrada] El mejor sitio para cortar madera es un cruce de caminos. Se arma un aserradero, y para eso hay que despejar el terreno.…`
- `[textos.victoria] Aserradero en marcha. La colonia ya tiene madera propia. La primera carga sale mañana hacia el campamento.`

</details>

<details><summary><code>data/levels/level_08.json</code> · 4</summary>

- `[nombre] Bastión`
- `[textos.lugar] El bastión sobre ruinas`
- `[textos.entrada] Sobre la loma hay muros de piedra vieja, a medio enterrar. Las rocas tienen la misma marca que las del campamento. Algui…`
- `[textos.victoria] Bastión asegurado. La colonia tiene una posición alta sobre la loma. Los muros son de otros; los usamos igual.`

</details>

<details><summary><code>data/levels/level_09.json</code> · 4</summary>

- `[nombre] Taller asediado`
- `[textos.lugar] El taller`
- `[textos.entrada] Entre las ruinas hay un galpón que puede servir de taller. Los que lo rodean no parecen animales: algunos curan a los su…`
- `[textos.victoria] Taller asegurado. El horno se encendió por primera vez fuera del oasis. La forja ya no depende de lo que trajo la nave.`

</details>

<details><summary><code>data/levels/level_10.json</code> · 4</summary>

- `[nombre] La mina vieja`
- `[textos.lugar] Primer puesto de abastecimiento`
- `[textos.entrada] Las galerías ya estaban cavadas cuando llegamos. Si se las retoma, la colonia tiene mineral a pocos días del campamento.…`
- `[textos.victoria] Mina asegurada. Es el primer puesto de abastecimiento de la colonia. Las galerías no las cavamos nosotros, y nadie vino…`

</details>

<details><summary><code>data/levels/level_11.json</code> · 4</summary>

- `[nombre] Puesto seco`
- `[textos.lugar] El punto de agua`
- `[textos.entrada] Pasada la mina, el camino se vuelve seco. Los dos pozos que hay ya tenían huellas alrededor. Desde hoy, algunas torres s…`
- `[textos.victoria] Informe del puesto seco: punto de agua asegurado. Dos pozos quedaron dentro del perímetro.`

</details>

<details><summary><code>data/levels/level_12.json</code> · 4</summary>

- `[nombre] Cañadón`
- `[textos.lugar] El paso hacia el norte`
- `[textos.entrada] El único paso hacia el norte es un cañadón de paredes altas. Los tiros vuelven contra las torres, como si las paredes lo…`
- `[textos.victoria] Cañadón asegurado. El paso al norte quedó abierto. En las paredes quedaron las marcas de los tiros que volvieron.`

</details>

<details><summary><code>data/levels/level_13.json</code> · 4</summary>

- `[nombre] Paso alto`
- `[textos.lugar] El camino al resto de la región`
- `[textos.entrada] En el paso alto el camino se parte en dos. Ya no llegan de a uno: cada grupo trae quien protege, quien cura y quien apag…`
- `[textos.victoria] Paso alto asegurado. La región queda comunicada con el valle de más al este. Las rocas marcadas quedaron del lado de ad…`

</details>

<details><summary><code>data/levels/level_14.json</code> · 4</summary>

- `[nombre] Poblados`
- `[textos.lugar] Asentamientos de los Moradores`
- `[textos.entrada] Los poblados están a la vista, pero no sale humo de ninguno. Los fogones están armados y no se ve a nadie. Aun así, algo…`
- `[textos.victoria] Los poblados están vacíos. Las brasas todavía están tibias.`

</details>

<details><summary><code>data/levels/level_15.json</code> · 5</summary>

- `[nombre] Central`
- `[textos.lugar] Energía y abastecimiento`
- `[textos.entrada] Falta cerrar el valle: la central de energía y la línea que la une con la mina. Si se sostiene, la colonia queda asentad…`
- `[textos.victoria] Central encendida. La línea de abastecimiento está completa. La colonia ya no depende de la nave.`
- `[textos.epilogo] La máquina sigue avanzando, pero ¿por cuánto tiempo más? ¿A qué costo?`

</details>

<details><summary><code>data/wiki/lore/criaturas_solas.json</code> · 4</summary>

- `[titulo] Las criaturas que van solas`
- `[subtitulo] Lo que no pertenece a ninguna manada`
- `[bloques.0.texto] En el bosque hay seres que no andan con ninguna manada. El Ladrón, por ejemplo, va solo, con una capa gris y una bolsa,…`
- `[bloques.1.texto] Los informes las llaman criaturas, para distinguirlas de los animales. No obedecen a nadie, y nadie sabe cuántas hay.`

</details>

<details><summary><code>data/wiki/lore/el_oasis.json</code> · 5</summary>

- `[titulo] El oasis`
- `[subtitulo] Donde aterrizó la nave`
- `[bloques.0.texto] El oasis es un valle chico de agua dulce, pasto y flores, rodeado de tierra seca. Es el único sitio con agua a la vista…`
- `[bloques.1.texto] Los primeros días se armó el campamento junto al agua. Desde entonces, todo lo que la colonia necesita (madera, mineral…`
- `[bloques.2.texto] Los registros de la Compañía lo llaman «el único lugar seguro». No aclaran seguro de qué.`

</details>

<details><summary><code>data/wiki/lore/el_soberano.json</code> · 4</summary>

- `[titulo] El Soberano`
- `[subtitulo] Quien va al frente de las manadas`
- `[bloques.0.texto] Al final de una oleada aparece a veces un animal enorme, carmesí y cornudo. Las manadas parecen seguirlo, o dejarle pas…`
- `[bloques.1.texto] No es uno solo: hay uno por cada paraje, y ninguno se parece del todo al anterior. Nadie sabe si manda o si solo va ade…`

</details>

<details><summary><code>data/wiki/lore/la_central.json</code> · 5</summary>

- `[titulo] La Central`
- `[subtitulo] Energía y abastecimiento`
- `[bloques.0.texto] La central quedó en el último valle, el de más al este, lejos del oasis donde aterrizó la nave. Produce la energía que …`
- `[bloques.1.texto] Con ella, la región queda asegurada: agua, luz y camino. No es todo el planeta, y nadie en la Compañía dice que lo sea.`
- `[bloques.2.texto] Los colonos lo llaman el Coloso. Es de la misma piedra que los Guardianes. Cuando cae, se parte en tres y los pedazos s…`

</details>

<details><summary><code>data/wiki/lore/la_compania.json</code> · 5</summary>

- `[titulo] La Compañía Meridiana`
- `[subtitulo] Quiénes somos`
- `[bloques.0.texto] La Compañía Meridiana armó la expedición. No es un ejército: es gente de oficio (ingenieros, herreros, carpinteros, agr…`
- `[bloques.1.texto] La nave no puede volver a despegar. Se la va desarmando de a poco para hacer casas, cañerías y torres, y lo que se romp…`
- `[bloques.2.texto] Por eso las torres son de hierro, bronce y cristal: se pueden reparar en el lugar. Entre la carga venían también planos…`

</details>

<details><summary><code>data/wiki/lore/la_cuadrilla.json</code> · 5</summary>

- `[titulo] La Cuadrilla`
- `[subtitulo] Los que andan juntos`
- `[bloques.0.texto] Cerca del aserradero se vieron criaturas chicas y rápidas que se llevan lo que brilla, igual que el Ladrón. A diferenci…`
- `[bloques.1.texto] Con ellas viene siempre una más grande y lenta, con una bolsa más grande que ella misma donde parece juntarse lo de tod…`
- `[bloques.2.texto] Nadie vio que alguna mande ni que alguna obedezca. Parece que van juntas porque buscan lo mismo.`

</details>

<details><summary><code>data/wiki/lore/las_ruinas.json</code> · 5</summary>

- `[titulo] Las ruinas`
- `[subtitulo] Lo que había antes`
- `[bloques.0.texto] Sobre la loma del bastión hay muros de piedra y metal, a medio enterrar. Los colonos los llaman «las ruinas» y los trat…`
- `[bloques.1.texto] Todas llevan la misma marca que las rocas del oasis. Nadie sabe qué quiere decir: puede ser «esto es nuestro», «hasta a…`
- `[bloques.2.texto] El informe de la Compañía dice que las dejó una gente que ya no está. No dice cómo lo sabe.`

</details>

<details><summary><code>data/wiki/lore/los_moradores.json</code> · 5</summary>

- `[titulo] Los Moradores`
- `[subtitulo] Los que ya estaban`
- `[bloques.0.texto] Así llama la Compañía a las comunidades que viven en Cántaro. Es un nombre de informe: cómo se llaman ellos a sí mismos…`
- `[bloques.1.texto] Hasta ahora se vieron dos oficios: los que protegen, de piedra y escudo dorado, y los que curan, con una semilla en el …`
- `[bloques.2.texto] Tampoco está claro si guían a los animales de las manadas o si solo cuidan sus propios caminos.`

</details>

<details><summary><code>data/wiki/lore/los_pozos.json</code> · 5</summary>

- `[titulo] Los pozos`
- `[subtitulo] Informe del puesto seco`
- `[bloques.0.texto] En el camino seco hay pocos pozos, y todos tienen huellas alrededor. Dos quedaron dentro del perímetro del puesto.`
- `[bloques.1.texto] El mismo día en que se aseguró el paso empezaron los fallos: torres que se apagan sin motivo. Las observaciones coincid…`
- `[bloques.2.texto] No ataca a las personas. Ataca lo que construimos.`

</details>

<details><summary><code>data/wiki/lore/planeta_cantaro.json</code> · 5</summary>

- `[titulo] Cántaro`
- `[subtitulo] El planeta, o lo que se conoce de él`
- `[bloques.0.texto] Los colonos le pusieron Cántaro al planeta, por el oasis: un poco de agua guardada en una tierra seca.`
- `[bloques.1.texto] Lo que se conoce es un solo rincón: el oasis y lo que lo rodea. Más allá, todavía no se llegó.`
- `[bloques.2.texto] Cada tramo que se asegura se agrega al mapa de la Compañía. El mapa tiene más blanco que dibujo.`

</details>

<details><summary><code>data/wiki/lore/poblados_vacios.json</code> · 5</summary>

- `[titulo] Los poblados vacíos`
- `[subtitulo] Lo que quedó en pie`
- `[bloques.0.texto] Los poblados del valle bajo son de piedra y paja. Tienen fogones, cuerdas y pieles todavía en su sitio.`
- `[bloques.1.texto] No hay nadie. Se fueron hace poco y se llevaron lo que podían cargar.`
- `[bloques.2.texto] La Compañía registra los poblados como «posiciones desocupadas».`

</details>

## Validación de datos de desarrollo (solo consola/tests)

*Mensajes de los lectores de `data/` (tutorial, intro, consejos, novedades, artículos de la Wiki, créditos, configuraciones de alcance y de mejoras, el catálogo de idiomas, `balance_args`, `collection_definitions`). Solo llegan a `push_warning`/`push_error` o a los tests; ninguna pantalla los muestra. D-222 dejó la consola en español. Los de mapas, modos y textos de nivel **sí** se tradujeron (`lvlfile.*`, `grid.*`, `modepack.*`…).*

<details><summary><code>scripts/data/range_display_config.gd</code> · 6</summary>

- L20 `No se encontró %s; se usan los valores por omisión.`
- L24 `No se pudo leer %s; se usan los valores por omisión.`
- L28 `%s no es un JSON válido (un objeto); se usan los valores por omisión.`
- L52 `Falta «%s» (un objeto); se usan sus valores por omisión.`
- L58 `«%s.%s» tiene que ser un número; se usa %s.`
- L63 `«%s.%s» está fuera de rango (%s).`

</details>

<details><summary><code>scripts/data/upgrade_fx_config.gd</code> · 19</summary>

- L56 `No se encontró %s; se usan los valores por omisión.`
- L60 `No se pudo leer %s; se usan los valores por omisión.`
- L64 `%s no es un JSON válido (un objeto); se usan los valores por omisión.`
- L92 `Falta «%s»; se usa %s.`
- L96 `«%s» tiene que ser un número.`
- L101 `«%s» está fuera de rango (%s).`
- L105 `«fuente_min_px» no puede ser mayor que «fuente_max_px»; se usan los de omisión.`
- L112 `Falta «variantes» (un objeto con «refuerzo» y «maestria»); se usan los valores por omisión.`
- L117 `Falta la variante «%s»; se usan los valores por omisión.`
- L123 `En la variante «%s», «%s» tiene que ser un número.`
- L125 `En la variante «%s», «%s» tiene que ser mayor que 0 (es %s).`
- L133 `Falta «estadisticas» (una lista); se usa la tabla por omisión.`
- L144 `La estadística %d no es un objeto.`
- L153 `La estadística %d usa el campo «%s», que no existe en TowerLevelData.`
- L156 `La estadística %d repite el campo «%s».`
- L159 `La estadística %d (%s) no tiene «etiqueta».`
- L162 `La estadística %d (%s) tiene el formato desconocido «%s» (valen: %s).`
- L166 `La estadística %d (%s) tiene una «escala» que no sirve (tiene que ser un número distinto de 0).`
- L172 `La tabla de estadísticas quedó vacía; se usa la de omisión.`

</details>

<details><summary><code>scripts/logic/advice_data.gd</code> · 35</summary>

- L21 `{torres}`
- L39 `consejos: no existe el archivo %s.`
- L43 `consejos: no se pudo abrir %s.`
- L47 `consejos: %s no es un JSON válido (línea %d: %s).`
- L55 `consejos: el archivo tiene que ser un objeto con \"ajustes\", \"criterios\", \"reglas\".`
- L59 `consejos: \"version\" tiene que ser %d.`
- L61 `consejos: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).`
- L183 `consejos: falta \"ajustes\" (un objeto con %s).`
- L188 `consejos: \"ajustes\" no conoce la clave \"%s\" (las válidas: %s).`
- L191 `consejos: \"ajustes.%s\" tiene que ser un número.`
- L199 `consejos: \"peso_oleada\" tiene que estar entre 0 y 5.`
- L201 `consejos: \"participacion_minima_pct\" tiene que estar entre 0 y 100.`
- L203 `consejos: \"vidas_minimas\" tiene que ser 1 o más.`
- L205 `consejos: \"max_torres\" tiene que estar entre 1 y 4.`
- L207 `consejos: \"max_caracteres\" tiene que estar entre 30 y 120 (si no, el texto no entra en 2 líneas).`
- L212 `consejos: falta \"criterios\" (qué torres cuentan como «de golpe alto», «que golpean el aire»…).`
- L218 `consejos: el criterio \"%s\" tiene que ser un objeto con al menos una condición.`
- L225 `consejos: en el criterio \"%s\", \"%s\" tiene que ser true o false.`
- L229 `consejos: en el criterio \"%s\", \"%s\" tiene que ser un número de 0 o más.`
- L232 `consejos: el criterio \"%s\" no conoce la condición \"%s\" (las válidas: %s).`
- L241 `consejos: falta \"reglas\" (una lista con al menos una regla).`
- L248 `consejos: la regla %d tiene que ser un objeto.`
- L252 `la regla \"%s\"`
- L252 `la regla %d`
- L254 `consejos: %s no tiene \"id\".`
- L256 `consejos: el id \"%s\" está repetido.`
- L262 `consejos: %s necesita \"torres\" (la lista de criterios que sirven).`
- L266 `consejos: %s nombra el criterio \"%s\", que no existe en \"criterios\".`
- L271 `consejos: %s no tiene \"texto\".`
- L273 `consejos: el texto de %s tiene que llevar %s donde van los nombres de las torres.`
- L275 `consejos: el texto de %s mide hasta %d caracteres con %d nombres largos y el máximo es %d (no entraría en 2 líneas).`
- L283 `consejos: %s necesita \"enemigo\" (a qué enemigos aplica, por ejemplo {\"vuela\": true}).`
- L291 `consejos: en %s, \"%s\" solo puede ser true.`
- L295 `consejos: en %s, \"%s\" tiene que ser un número mayor que 0.`
- L298 `consejos: %s no conoce la condición de enemigo \"%s\" (las válidas: %s).`

</details>

<details><summary><code>scripts/logic/balance_args.gd</code> · 4</summary>

- L128 `no es un JSON con { }`
- L133 `'%s' necesita {\"estrategia\": ..., \"mejoras\": ...}`
- L136 `'%s': \"mejoras\" tiene que ser llenar o temprana`
- L139 `falta \"por_defecto\"`

</details>

<details><summary><code>scripts/logic/collection_definitions.gd</code> · 2</summary>

- L80 `La colección \"%s\" pide %d piezas pero tiene %d fuentes.`
- L82 `La colección \"%s\" tiene un origen desconocido: \"%s\".`

</details>

<details><summary><code>scripts/logic/credits.gd</code> · 10</summary>

- L17 `No se encuentra el archivo de créditos (%s).`
- L27 `Los créditos no son un JSON válido (línea %d: %s).`
- L30 `Los créditos tienen que ser un objeto con \"version\" y \"lineas\".`
- L35 `clave desconocida \"%s\" (se usan: %s).`
- L37 `\"version\" tiene que ser 1.`
- L39 `\"lineas\" tiene que ser una lista de textos.`
- L43 `\"lineas\" no puede estar vacía.`
- L45 `\"lineas\" tiene %d líneas y el máximo es %d.`
- L48 `la línea %d tiene que ser un texto.`
- L52 `la línea %d tiene %d caracteres y el máximo es %d.`

</details>

<details><summary><code>scripts/logic/intro_data.gd</code> · 21</summary>

- L32 `intro: no existe el archivo %s.`
- L36 `intro: no se pudo abrir %s.`
- L41 `intro: %s no es un JSON válido (línea %d: %s).`
- L50 `intro: el archivo tiene que ser un objeto con \"version\" y \"laminas\".`
- L54 `intro: \"version\" tiene que ser %d.`
- L58 `intro: \"fundido_s\" tiene que ser un número de 0 a %s segundos.`
- L63 `intro: \"laminas\" tiene que ser una lista de láminas.`
- L67 `el mínimo es %d`
- L67 `el máximo es %d`
- L68 `hay %d láminas y %s.`
- L88 `la lámina %d tiene que ser un objeto con \"imagen\", \"texto\" y \"segundos\".`
- L96 `la lámina %d: \"imagen\" tiene que ser una ruta que empiece con res://.`
- L98 `la lámina %d no encuentra la imagen '%s'.`
- L103 `la lámina %d: \"texto\" tiene que ser un texto entre comillas.`
- L110 `la lámina %d: \"segundos\" tiene que ser un entero de %d a %d.`
- L120 `la lámina %d tiene el texto vacío.`
- L125 `la lámina %d: el texto tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).`
- L129 `la lámina %d tiene %d líneas y el máximo es %d.`
- L131 `la lámina %d tiene %d caracteres y el máximo es %d.`
- L134 `la lámina %d: la línea %d está en blanco.`
- L136 `la lámina %d: la línea %d tiene %d caracteres y el máximo por línea es %d.`

</details>

<details><summary><code>scripts/logic/leading_zero_audit.gd</code> · 1</summary>

- L35 `%s: \"%s\"`

</details>

<details><summary><code>scripts/logic/level_file.gd</code> · 3</summary>

- L89 `mapa: `
- L110 `mapa: `
- L315 `%s: %s`

</details>

<details><summary><code>scripts/logic/localization_catalog.gd</code> · 13</summary>

- L10 `^[a-z][a-z0-9_]*(\\.[a-z0-9_]+)+$`
- L11 `\\{([A-Za-z0-9_]+)\\}`
- L19 `No existe el catálogo %s.`
- L25 `catálogo`
- L29 `%s no es un JSON válido (objeto).`
- L35 `%s: «entradas» debe ser una lista.`
- L42 `%s: una entrada no tiene «clave» y «texto» de tipo texto.`
- L82 `[%s] clave duplicada: %s`
- L85 `[%s] clave con formato inválido: %s`
- L90 `[%s] clave que no existe en el catálogo base: %s`
- L94 `[%s] clave sin traducción: %s`
- L97 `[%s] placeholders distintos en %s: %s contra %s`
- L100 `[%s] traducción vacía: %s`

</details>

<details><summary><code>scripts/logic/news_data.gd</code> · 33</summary>

- L60 `novedades: no existe el archivo %s.`
- L64 `novedades: no se pudo abrir %s.`
- L69 `novedades: %s no es un JSON válido (línea %d: %s).`
- L78 `novedades: el archivo tiene que ser un objeto con \"version\", \"interfaz\" y \"versiones\".`
- L82 `novedades: \"version\" tiene que ser %d.`
- L86 `novedades: \"versiones\" tiene que ser una lista (puede estar vacía).`
- L127 `la versión %s de project.godot no tiene entrada en las novedades (no se mostrará nada).`
- L129 `la entrada de la versión %s sigue en borrador (no se mostrará sola hasta pasar \"borrador\" a false).`
- L135 `novedades: \"interfaz\" tiene que ser un objeto con los rótulos fijos (%s).`
- L141 `novedades: \"interfaz\" necesita \"%s\" con un texto.`
- L149 `la versión número %d de la lista tiene que ser un objeto.`
- L155 `la versión número %d de la lista no tiene \"id\" (tiene que ser la versión, por ejemplo \"1.0.0\").`
- L156 `número %d`
- L160 `la versión %s está repetida.`
- L162 `la versión %s`
- L165 `%s: \"tipo\" tiene que ser \"%s\" o \"%s\".`
- L170 `%s: \"borrador\" tiene que ser true o false.`
- L179 `%s: \"novedades\" tiene que ser una lista de 1 a %d.`
- L183 `%s tiene %d novedades y tiene que haber de 1 a %d.`
- L196 `%s, novedad %d: tiene que ser un objeto con \"titulo\" y \"texto\".`
- L199 `%s, novedad %d`
- L202 `%s, novedad %d («%s»)`
- L215 `%s: \"%s\" tiene que ser un texto entre comillas%s.`
- L215 ` (o sacá la clave)`
- L219 `%s: \"%s\" no puede tener saltos de línea ni caracteres de control.`
- L221 `%s: \"%s\" tiene %d caracteres y el máximo es %d.`
- L228 `%s: \"texto\" tiene que ser un texto entre comillas.`
- L232 `%s: el texto tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).`
- L235 `%s: el texto tiene %d líneas y el máximo es %d.`
- L237 `%s: el texto tiene %d caracteres y el máximo es %d.`
- L240 `%s: el texto tiene una línea en blanco.`
- L250 `%s: \"%s\" tiene que ser una ruta que empiece con res://.`
- L253 `%s no encuentra la imagen '%s' (\"%s\").`

</details>

<details><summary><code>scripts/logic/tutorial_data.gd</code> · 33</summary>

- L79 `tutorial: no existe el archivo %s.`
- L83 `tutorial: no se pudo abrir %s.`
- L88 `tutorial: %s no es un JSON válido (línea %d: %s).`
- L97 `tutorial: el archivo tiene que ser un objeto con \"version\", \"pc\" y \"celular\".`
- L101 `tutorial: \"version\" tiene que ser %d.`
- L103 `tutorial: \"borrador\" tiene que ser true o false (true hasta que Lucas apruebe los textos).`
- L108 `tutorial: \"nivel\" tiene que ser el id del nivel donde se muestra, como \"level_01\".`
- L151 `tutorial: \"interfaz\" tiene que ser un objeto con %s.`
- L157 `tutorial: \"interfaz\" \"%s\" tiene que ser un texto no vacío.`
- L159 `tutorial: \"interfaz\" \"%s\" tiene %d caracteres y el máximo es %d.`
- L163 `tutorial: \"interfaz\" \"paso\" tiene que llevar dos %d (el número del paso y el total), como \"Paso %d de %d\".`
- L167 `tutorial: \"interfaz\" no usa la clave \"%s\" (se usan: %s).`
- L172 `la lista \"%s\"`
- L174 `tutorial: %s tiene que ser una lista de pasos.`
- L181 `el paso %d de %s`
- L183 `%s tiene que ser un objeto con \"paso\" y \"texto\".`
- L187 `%s: \"paso\" '%s' no existe (se usan: %s).`
- L191 `%s: el paso \"%s\" no se usa en %s.`
- L191 `la PC`
- L191 `el modo celular`
- L194 `%s: el paso \"%s\" está repetido.`
- L198 `%s (\"%s\"): \"texto\" tiene que ser un texto entre comillas.`
- L202 `%s (\"%s\") %s`
- L217 `la lista \"%s\" no tiene el paso \"%s\" y hace falta.`
- L220 `la lista \"%s\": el paso \"%s\" tiene que ir antes que \"%s\".`
- L222 `la lista \"%s\": después de \"pause\" tiene que ir \"resume\" (si no, la partida quedaría pausada).`
- L224 `la lista \"%s\": el paso \"done\" tiene que ser el último.`
- L231 `tiene el texto vacío.`
- L236 `tiene caracteres de control (solo se permite el salto de línea \ ⏎ ).`
- L240 `tiene %d líneas y el máximo es %d.`
- L242 `tiene %d caracteres y el máximo es %d.`
- L245 `tiene la línea %d en blanco.`
- L247 `tiene la línea %d con %d caracteres y el máximo por línea es %d.`

</details>

<details><summary><code>scripts/logic/wiki.gd</code> · 19</summary>

- L134 ` ⏎ `
- L343 `%s: %s`
- L362 `No es un JSON válido (línea %d): %s`
- L369 `La clave \"%s\" no existe (las válidas: %s).`
- L374 `Falta \"desbloqueo\": el id del nivel que abre el artículo, como \"level_08\".`
- L376 `\"desbloqueo\": el nivel \"%s\" no figura en la campaña.`
- L380 `Falta \"version\": %d.`
- L383 `Falta \"titulo\" (un texto).`
- L389 `\"orden\" tiene que ser un número entero.`
- L395 `\"subtitulo\" tiene que ser un texto.`
- L398 `Falta \"bloques\" (una lista con al menos un bloque).`
- L402 `bloque %d`
- L439 `%s: tiene que ser un objeto { }.`
- L446 `%s (%s): falta \"texto\".`
- L451 `%s (%s): falta \"filas\" (una lista de filas).`
- L457 `%s (%s): cada fila tiene que ser una lista de textos.`
- L463 `%s (datos): cada fila tiene 2 textos (nombre y valor).`
- L466 `%s (tabla): todas las filas tienen que tener la misma cantidad de columnas.`
- L471 `%s: el tipo \"%s\" no existe (los válidos: titulo, texto, datos, tabla).`

</details>

## Herramienta de desarrollo (documento y mensajes de tools/intro_doc.gd)

*El documento editable de la intro y sus mensajes (herramienta de línea de comandos).*

<details><summary><code>scripts/logic/intro_doc.gd</code> · 62</summary>

- L10 `Ajustes generales`
- L11 `Lámina`
- L12 `sin voz`
- L12 `sin sonido`
- L27 `sin título`
- L33 `{ ⏎ `
- L34 `\t\"version\": %s, ⏎ `
- L36 `\t\"fundido_s\": %s, ⏎ `
- L37 `\t\"laminas\": [ ⏎ `
- L41 `\t\t{ ⏎ `
- L42 `\t\t\t\"imagen\": %s, ⏎ `
- L43 `\t\t\t\"texto\": %s, ⏎ `
- L44 `\t\t\t\"segundos\": %s ⏎ `
- L45 `\t\t}%s ⏎ `
- L46 `\t] ⏎ } ⏎ `
- L53 `# Intro del juego: textos y tiempos`
- L55 `Este documento es una **vista editable** de 'data/intro/intro.json'. El juego lee ese JSON, no este archivo.`
- L57 `**Cómo se usa** (más detalle en 'CONTENIDO.md'):`
- L59 `1. Cambiá lo que quieras: el texto de cada lámina, los segundos, el fundido o la imagen.`
- L60 `2. Para ver si quedó bien sin guardar nada: 'godot --headless --path . -s tools/intro_doc.gd -- import --dry'.`
- L61 `3. Para pasarlo al juego: 'godot --headless --path . -s tools/intro_doc.gd -- import'. Si hay un error, lo dice con el número de línea y …`
- L62 `4. Para volver a empezar desde lo que carga el juego: '... -- export' (conserva las notas).`
- L64 `**Reglas** (las mismas que revisa el juego): de 5 a 8 láminas; el texto, de 1 o 2 líneas, hasta %d caracteres por línea y %d en total; lo…`
- L66 `Cada línea del texto empieza con '> '. Las **notas** son solo para vos: no se cargan al juego. La intro no tiene voces ni sonidos propios…`
- L68 `## %s`
- L70 `- Versión del formato: %s`
- L72 `- Fundido entre láminas (segundos): %s`
- L78 `## %s %d · %s`
- L80 `- Imagen: %s`
- L81 `- Segundos: %s`
- L82 `- Voz o sonido: ninguno`
- L84 `Texto:`
- L89 `Notas:`
- L95 ` ⏎ `
- L109 ` ⏎ `
- L127 `línea %d: no entiendo la sección «%s» (tiene que ser «%s» o «%s N»).`
- L139 `línea %d: la lámina %d tiene dos bloques «Texto:».`
- L151 `línea %d: en la lámina %d cada línea del texto tiene que empezar con «> » (o escribí «Notas:» antes de las notas).`
- L161 `fundido entre láminas: %s → %s`
- L161 `por omisión`
- L161 `por omisión`
- L165 `cantidad de láminas: %d → %d`
- L171 `lámina %d, %s: %s → %s`
- L181 `falta la sección «%s» (con la versión del formato).`
- L183 `línea %d: en «%s» falta «Versión del formato».`
- L187 `«Versión del formato» tiene que ser un número (dice «%s»).`
- L193 `«Fundido entre láminas» tiene que ser un número de segundos (dice «%s»).`
- L202 `línea %d: el título dice «Lámina %d» pero es la %d.ª del documento; se usa el orden del documento.`
- L204 `la lámina %d (línea %d) no tiene «Imagen».`
- L208 `la lámina %d (línea %d) no tiene «Texto:».`
- L210 ` ⏎ `
- L212 `la lámina %d (línea %d) no tiene «Segundos».`
- L216 `la lámina %d (línea %d): «Segundos» tiene que ser un número entero (dice «%s»).`
- L220 `la lámina %d: «Voz o sonido» dice «%s», pero la intro no tiene voces ni sonidos (RF-499): no se carga.`
- L222 ` ⏎ `
- L233 `la lámina %d dura %d s y su texto pide al menos %d s para leerse (regla del guion); el juego la acepta igual.`
- L244 `línea %d: no entiendo «%s» (se espera «- Clave: valor»).`
- L262 `línea %d: «Texto:» y «Notas:» van solas en su línea y lo que escribas va debajo (el texto, con «> » adelante).`
- L264 `línea %d: no conozco el campo «%s».`
- L266 `línea %d: «%s» está repetido%s.`
- L266 ` en la lámina %d`
- L266 ` en los ajustes`

</details>

## Texto por omisión de escena (el código lo reemplaza o está oculto)

*Texto que trae el `.tscn` y que el código pisa antes de mostrarlo (verificado con `tools/capture_menus.gd`, que en inglés no lo encuentra en pantalla) o que está oculto (`WaveBanner`, `BossLine`).*

<details><summary><code>scenes/game/hud.tscn</code> · 4</summary>

- L27 `[text] Oleada 1`
- L251 `[text] Pausa  [P]`
- L270 `[text] x1  [F]`
- L335 `[text] Descripción`

</details>

<details><summary><code>scenes/ui/end_screen.tscn</code> · 2</summary>

- L51 `[text] Título`
- L65 `[text] Detalle`

</details>

<details><summary><code>scenes/ui/level_intro.tscn</code> · 1</summary>

- L82 `[text] Lugar`

</details>

<details><summary><code>scenes/ui/level_select.tscn</code> · 1</summary>

- L102 `[text] Estrellas: 0 de 15`

</details>

<details><summary><code>scenes/ui/records_screen.tscn</code> · 1</summary>

- L101 `[text] Nivel 1 · Pradera`

</details>

<details><summary><code>scenes/ui/tower_panel.tscn</code> · 5</summary>

- L41 `[text] Torre`
- L67 `[tooltip_text] Nivel actual: 1 de 3`
- L145 `[text] 0/s`
- L197 `[text] faltan 0`
- L220 `[text] [U]`

</details>

## Texto sin uso (campo `text` de `DevMode.ACTIONS`, que ningún código lee)

*Campo `text` de `DevMode.ACTIONS`: ningún código lo lee (el panel usa `dev.*`).*

<details><summary><code>scripts/autoload/dev_mode.gd</code> · 5</summary>

- L20 `Matar a todos`
- L21 `Saltar oleada`
- L22 `Vidas infinitas`
- L23 `Velocidad más lenta`
- L24 `Velocidad más rápida`

</details>

## Nombre técnico, id o formato (no es texto de jugador)

*Nombres de nodos, ids, expresiones regulares, fragmentos de formato (`%s · %s`, ` ⏎ `), trozos de JSON que escribe el editor y rutas de clave (` → removible → `): no son texto de jugador.*

<details><summary><code>scenes/editor/map_editor.gd</code> · 3</summary>

- L224 `%s (%s)`
- L376 `%s · %s`
- L479 ` ⏎ `

</details>

<details><summary><code>scenes/editor/objects_panel.gd</code> · 1</summary>

- L67 `Spin_`

</details>

<details><summary><code>scenes/editor/settings_panel.gd</code> · 1</summary>

- L89 `Tower_`

</details>

<details><summary><code>scenes/editor/waves_panel.gd</code> · 5</summary>

- L35 `Prev`
- L38 `Next`
- L156 ` s`
- L160 ` s`
- L236 `Button`

</details>

<details><summary><code>scenes/effects/effects_layer.gd</code> · 4</summary>

- L93 `%d!`
- L141 `+%d`
- L171 `+%d`
- L375 `+%d`

</details>

<details><summary><code>scenes/game/game.gd</code> · 2</summary>

- L270 `Infrastructure`
- L710 `Tutorial`

</details>

<details><summary><code>scenes/game/hud.gd</code> · 8</summary>

- L173 `Stat/`
- L173 `Icon`
- L300 `  [F]`
- L665 `%s · %s`
- L705 ` ⏎ `
- L748 `→ %d/%d`
- L759 `%d/%d ✓`
- L781 `%s · %ds`

</details>

<details><summary><code>scenes/game/infrastructure_controller.gd</code> · 1</summary>

- L130 `+%d %s`

</details>

<details><summary><code>scenes/game/mobile_hud.gd</code> · 17</summary>

- L114 `Button`
- L223 `Button`
- L294 `%s  ·  %s`
- L323 `Aturdida`
- L329 `%s %s`
- L394 ` ⏎ `
- L403 `%s ⏎ %s`
- L405 `%s · %s ⏎ %s`
- L406 `%s ⏎ %s ⏎ %s`
- L668 `Button`
- L769 `%s / %s`
- L774 `Demoledora`
- L812 `CatalogCard_%s`
- L831 `%s ⏎ %s`
- L833 ` ⏎ %s`
- L834 `%s · %s`
- L883 `%s  ·  %s`

</details>

<details><summary><code>scenes/game/tutorial_controller.gd</code> · 1</summary>

- L101 `%s · %s`

</details>

<details><summary><code>scenes/levels/level.gd</code> · 6</summary>

- L40 `Level`
- L51 `Entrances`
- L55 `GroundPath%d`
- L60 `AirPath%d`
- L66 `Decor`
- L75 `Ground`

</details>

<details><summary><code>scenes/ui/bar_tabs.gd</code> · 2</summary>

- L38 `Tab_%s`
- L105 `%s · %s`

</details>

<details><summary><code>scenes/ui/boss_presentation.gd</code> · 6</summary>

- L60 `Root`
- L65 `Backdrop`
- L81 `Column`
- L89 `Illustration`
- L96 `Name`
- L97 `Line`

</details>

<details><summary><code>scenes/ui/campaign_map_view.gd</code> · 4</summary>

- L93 `Region_%d`
- L109 `../Region_%d`
- L113 `../Region_%d`
- L183 `%s · %s`

</details>

<details><summary><code>scenes/ui/campaign_region.gd</code> · 1</summary>

- L108 `%s · %s`

</details>

<details><summary><code>scenes/ui/enemy_icon.gd</code> · 2</summary>

- L44 `≤%d?`
- L44 `×%d`

</details>

<details><summary><code>scenes/ui/infrastructure_tab.gd</code> · 2</summary>

- L55 `Cards`
- L185 `Arrows`

</details>

<details><summary><code>scenes/ui/intro_screen.gd</code> · 1</summary>

- L19 `Omitir`

</details>

<details><summary><code>scenes/ui/level_select.gd</code> · 7</summary>

- L265 `%d %s`
- L592 `Badge`
- L641 `Place`
- L645 ` ⏎ `
- L753 `Badge_%s`
- L801 `Stars`
- L809 `Status`

</details>

<details><summary><code>scenes/ui/news_screen.gd</code> · 11</summary>

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

<details><summary><code>scenes/ui/obstacle_panel.gd</code> · 1</summary>

- L111 `%s · %s`

</details>

<details><summary><code>scenes/ui/options_menu.gd</code> · 3</summary>

- L15 `Title`
- L222 `OptionsPage%d`
- L236 `Tab%d`

</details>

<details><summary><code>scenes/ui/touch_scroller.gd</code> · 1</summary>

- L145 `Control`

</details>

<details><summary><code>scenes/ui/tower_panel.gd</code> · 4</summary>

- L154 `%s %s %s`
- L277 ` ⏎ `
- L280 ` ⏎ `
- L289 ` ⏎ `

</details>

<details><summary><code>scenes/ui/tutorial_overlay.gd</code> · 4</summary>

- L57 `Highlight`
- L125 `Card`
- L137 `Header`
- L146 `Text`

</details>

<details><summary><code>scenes/ui/wiki_screen.gd</code> · 3</summary>

- L87 `Label`
- L89 ` ⏎ `
- L244 ` %d/%d`

</details>

<details><summary><code>scripts/autoload/audio.gd</code> · 1</summary>

- L13 `Music`

</details>

<details><summary><code>scripts/autoload/dev_mode.gd</code> · 1</summary>

- L106 ` · %s`

</details>

<details><summary><code>scripts/autoload/game_flow.gd</code> · 1</summary>

- L526 `Transition`

</details>

<details><summary><code>scripts/autoload/save_manager.gd</code> · 1</summary>

- L224 `[^A-Za-z0-9._-]`

</details>

<details><summary><code>scripts/logic/desktop_window.gd</code> · 2</summary>

- L14 `Windows`
- L14 `Linux`

</details>

<details><summary><code>scripts/logic/dev_stats.gd</code> · 1</summary>

- L54 `\t`

</details>

<details><summary><code>scripts/logic/game_version.gd</code> · 3</summary>

- L23 `%s %s`
- L26 `%s %s`
- L32 `^(\\d+)\\.(\\d+)\\.(\\d+)(?:[-+](.+))?$`

</details>

<details><summary><code>scripts/logic/infrastructure_text.gd</code> · 1</summary>

- L20 `%d s`

</details>

<details><summary><code>scripts/logic/leading_zero_audit.gd</code> · 1</summary>

- L7 `(?<![\\w.,:/\\-])0\\d+(?![\\w])`

</details>

<details><summary><code>scripts/logic/level_draft.gd</code> · 31</summary>

- L623 `  \"version\": %d,`
- L624 `  \"nombre\": %s,`
- L625 `  \"oro\": %d,`
- L626 `  \"vidas\": %d,`
- L628 `  \"aumento_vida\": %d,`
- L630 `  \"tema\": %s,`
- L635 `    %s: %s`
- L636 `  \"leyenda\": { ⏎ `
- L636 `, ⏎ `
- L636 ` ⏎   },`
- L638 `  \"torres_extra\": %s,`
- L640 `  \"torres\": %s,`
- L642 `  \"demoledora\": %s,`
- L645 `  \"mapa\": [`
- L648 `    \"%s\"%s`
- L650 `  \"oleadas\": [`
- L656 `, ⏎      `
- L659 ` ⏎ `
- L659 ` ⏎ `
- L666 `  \"textos\": %s,`
- L677 `    %s: %s`
- L678 `  \"textos\": { ⏎ `
- L678 `, ⏎ `
- L678 ` ⏎   },`
- L683 `^[a-z0-9_]+$`
- L923 `\"enemigo\": %s`
- L924 `\"cantidad\": %d`
- L925 `\"cada\": %s`
- L928 `\"desde\": %s`
- L930 `\"entrada\": %s`
- L932 `\"probabilidad\": %s`

</details>

<details><summary><code>scripts/logic/level_file.gd</code> · 6</summary>

- L220 `^[a-z0-9_]+$`
- L393 ` → removible → `
- L395 ` → removible → tiempo`
- L413 ` → extraccion → `
- L484 ` → probabilidad`
- L495 `. # X S`

</details>

<details><summary><code>scripts/logic/lore_unlock.gd</code> · 2</summary>

- L31 `^level_(\\d+)$`
- L37 `^level_\\d+$`

</details>

<details><summary><code>scripts/logic/mode_packs.gd</code> · 3</summary>

- L311 `%s\" para el mapa \"%s`
- L387 `\t`
- L387 ` ⏎ `

</details>

<details><summary><code>scripts/logic/scene_transition.gd</code> · 6</summary>

- L206 `Root`
- L213 `Background`
- L219 `Center`
- L226 `Column`
- L231 `Title`
- L239 `Bar`

</details>

<details><summary><code>scripts/logic/tower_text.gd</code> · 5</summary>

- L59 `%s %s %s`
- L218 ` ⏎ `
- L233 ` + %d %s`
- L241 ` + %d`
- L261 `%d %s`

</details>

<details><summary><code>scripts/logic/upgrade_deltas.gd</code> · 2</summary>

- L31 `%s %s`
- L56 `%s %s %s %s`

</details>

<details><summary><code>scripts/logic/wiki_entry.gd</code> · 1</summary>

- L56 ` ⏎ `

</details>

## Notas internas de archivos de datos (no se muestran)

*Claves `nota` de `data/ui/*.json`: comentarios para quien edita el archivo.*

<details><summary><code>data/ui/marcas_campana.json</code> · 1</summary>

- `[nota] T507, RF-717: marcas (señales) que la campaña dibuja como capa visual, por nivel: casilla (x, y) y tipo. Hoy solo las 28 señales g…`

</details>

<details><summary><code>data/ui/postes_campana.json</code> · 2</summary>

- `[nota] T475, RF-696: casillas (x, y) donde la campaña dibuja un poste como capa visual. Aprobadas por Lucas el 2026-10-25 (Atlas + los 20…`
- `[casillas_libres] Niveles 8 y 9 (Lucas, 2026-10-28): el poste va en (18, 1), una casilla libre construible; la anterior (0, 4) es el símb…`

</details>

## Revisar a mano

*Lo que la heurística no supo clasificar.*

Ninguno.
