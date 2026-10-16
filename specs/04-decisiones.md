# 04 — Registro de decisiones

> **Qué es este documento:** cada decisión importante del proyecto, con las **alternativas** que había y el **por qué** de la elección. Sirve para no volver a discutir lo mismo y para entender el proyecto dentro de unos meses.
>
> **Cómo se agrega una decisión:** copia el formato de abajo con el número siguiente. Si una decisión se cambia, **no se borra**: se marca como *Reemplazada por D-0xx* y se agrega la nueva.

---

### D-001 · Motor: Godot 4 con GDScript
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** Web (TypeScript + Phaser), Unity (C#).
- **Por qué:** motor gratuito, liviano, excelente para 2D, con editor visual. GDScript es sencillo de aprender y está integrado en el editor.
- **Consecuencia:** Claude no puede ver el juego en ejecución; puede leer y escribir código y ejecutar tests por consola si Godot está en el `PATH`. **Las pruebas visuales las hace Lucas** y le cuenta a Claude lo que ve (una captura de pantalla ayuda mucho).

### D-002 · Vista 2D desde arriba, con formas simples *(formas reemplazadas por dibujos en D-023)*
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** pixel art desde el principio; 3D.
- **Por qué:** permite enfocarse en que el juego sea divertido. Los gráficos se cambian en M4 sin tocar la lógica, porque cada torre/enemigo se dibuja en un solo lugar (`_draw()`).

### D-003 · Camino fijo + construir en cualquier casilla libre
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** laberinto libre (los enemigos buscan su ruta); solo puntos fijos de construcción.
- **Por qué:** es el formato más simple de programar (no hace falta búsqueda de caminos) y aun así da decisiones interesantes (dónde poner cada torre).

### D-004 · Alcance "juego mediano", construido por hitos M0–M4
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Lucas (alcance) / Claude (división en hitos)
- **Alternativas:** prototipo chico; experimento técnico.
- **Por qué:** el objetivo es un juego mediano, pero construirlo "todo a la vez" es la forma más común de no terminarlo. El hito M1 ya es un juego completo pequeño; cada hito siguiente agrega sobre algo que ya funciona.

### D-005 · Números de balance en Resources (`.tres`)
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** constantes en el código; archivos JSON.
- **Por qué:** los `.tres` se editan en el Inspector de Godot, tienen tipos (el editor no te deja poner texto donde va un número) y se pueden referenciar entre sí (un `SpawnGroup` apunta directamente a `tank.tres`). JSON obligaría a escribir código de lectura y validación.

### D-006 · Una sola escena para todas las torres (y otra para todos los enemigos)
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** una escena por tipo (`cannon.tscn`, `frost.tscn`…) con herencia.
- **Por qué:** las torres solo se diferencian en **números** (daño, área, ralentización), no en comportamiento. Una escena + datos evita duplicar código. Si en el futuro aparece una torre con un comportamiento realmente distinto, se revisa esta decisión.

### D-007 · Movimiento de enemigos con distancia + `Curve2D`, sin `PathFollow2D`
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** `PathFollow2D` por enemigo; movimiento de casilla en casilla.
- **Por qué:** ver plan §6.2. Menos nodos, sirve igual para voladores, y "cuánto le falta para llegar" (necesario para apuntar al Primero) sale directo.

### D-008 · Proyectiles que siempre impactan
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** proyectiles con física que pueden fallar; daño instantáneo sin proyectil.
- **Por qué:** fallar disparos hace el balance impredecible y frustrante. El daño instantáneo se ve pobre. El proyectil teledirigido es predecible y se ve bien.

### D-009 · Sin autoloads hasta M3
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** un autoload `GameState` global desde el principio.
- **Por qué:** los globales hacen que "reiniciar" sea propenso a errores (hay que acordarse de limpiar todo a mano). Si el estado vive en la escena, reiniciar = recargar la escena. Solo se agregan globales cuando algo **debe** sobrevivir a un cambio de escena (progreso, opciones, música).

### D-010 · Idioma: documentos en español, código en inglés
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude (se puede cambiar si Lucas prefiere)
- **Por qué:** ver constitución P9.

### D-011 · Resolución base 1280×720, casillas de 64 px, mapa de 20×9
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** mapa de 20×10 (no deja espacio para el HUD en 720 px de alto).
- **Por qué:** 16:9 es el formato de casi todos los monitores; 64 px es un tamaño cómodo para hacer clic y para dibujar; 20×9 deja 144 px para la interfaz (arriba y abajo).

### D-012 · Tests con GUT
- **Fecha:** 2026-09-27 · **Estado:** Aceptada · **Decidió:** Claude
- **Alternativas:** GdUnit4.
- **Por qué:** GUT es simple, está en la AssetLib y se ejecuta por consola. Ambas opciones son válidas; lo importante es tener tests desde el día uno.

### D-013 · Porcentajes como enteros y valores por defecto en 0
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (durante T10)
- **Alternativas:** guardar `0.7` y `0.08` como decimales (lo que decía el plan original); valores de ejemplo como defaults en las clases de datos.
- **Por qué (porcentajes):** los decimales en la computadora no son exactos. Con `0.7`, 16 de cada 101 ventas de múltiplos de 10 se redondeaban mal (por ejemplo `170 × 0.7 = 118,999…` → 118 en vez de 119). Con enteros (`70`) la cuenta es exacta. Lo vigila `test_sell_refund_has_no_rounding_errors`.
- **Por qué (defaults en 0):** con defaults distintos de 0, un número de balance viviría en el código (contra P2), y Godot no lo escribiría en el `.tres` por ser igual al default.
- **No afecta a la spec:** 70 % y 8 % siguen siendo los mismos valores; solo cambia cómo se guardan.

### D-014 · Las torres detectan enemigos midiendo distancias, no con `Area2D`
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (durante T19)
- **Alternativas:** `Area2D` en cada torre y capas de colisión (lo que decía el plan original).
- **Por qué:** las áreas de colisión se actualizan solo en frames de física reales. Los tests simulan el tiempo más rápido que eso, así que las torres no habrían "visto" a nadie en los tests. Medir distancias es más simple, determinista y fácil de testear.
- **Costo:** unos 36.000 cálculos de distancia por segundo en el peor caso (60 torres × 200 enemigos × 3 disparos/s). Se mide en T39; si fuera lento, se optimiza midiendo primero.
- **Consecuencia:** el enemigo pasa a ser un `Node2D` y las capas de colisión quedan reservadas sin uso.

### D-015 · Balance del nivel 1 revisado con un bot
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T25), confirmado jugando por Lucas
- **Qué:** vida base ×1,5, aumento por oleada 8 % → 40 %, daño del Cañón 12 → 20. Detalle y resultados en spec §7.1.
- **Por qué:** con los números del borrador se ganaba sin perder vidas incluso poniendo torres al azar, y el Cañón nunca convenía.
- **Herramienta:** `tools/balance_sim.gd` juega solo con tres estrategias. Se vuelve a correr cada vez que cambie el balance.

### D-016 · Adelantar el pulido visual (M1.5) antes de la profundidad (M2)
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Lucas
- **Alternativas:** seguir el orden original (M2 → M3 → M4 con el pulido al final).
- **Por qué:** con M1 terminado, Lucas confirmó que el juego es divertido, que era la condición de la constitución P4 para dejar de lado "solo formas simples". Ver el juego más vivo motiva a seguir.
- **Cómo:** se mantiene el **estilo geométrico** (sin dibujos ni sprites) porque la ambientación todavía no está decidida; así nada de este trabajo se pierde si después se cambian las formas por arte. Los efectos son solo visuales y no cambian ninguna regla.

### D-017 · "Épocas" entra al backlog como candidata a ambientación
- **Fecha:** 2026-09-28 · **Estado:** Propuesta (sin fecha) · **Propuso:** Lucas
- **Qué:** idea B-01 de la spec §13: armas y enemigos que evolucionan a través de las épocas.
- **Por qué no ahora:** cambia la ambientación, el arte y quizás la estructura de la campaña. Hacerlo antes de tener M2 (profundidad) y M3 (campaña y guardado) obligaría a rehacer trabajo. M1.5 mantiene el estilo geométrico justamente para que nada se pierda si se elige esta ambientación.
- **Próximo paso:** ninguno por ahora. Lucas decidió dejar las tres variantes (A, B, C) documentadas sin elegir ninguna; se retoma cuando él quiera.

### D-018 · Balance de los enemigos de M2 y oleadas nuevas del nivel 1
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T38), pendiente de confirmar jugando
- **Qué:** Volador 25 → 18 de vida, Blindado 45 → 30 de vida y armadura 4 → 3, Jefe 800 → 300. Oleadas nuevas que presentan un enemigo nuevo por vez (Blindados en la 4, Voladores en la 5, Jefe en la 10). Detalle en spec §7 y §7.1.
- **Por qué:** con los valores del borrador (pensados antes del +40 % por oleada) se perdía con cualquier estrategia. Con los nuevos, el bot que mezcla torres gana con 13 vidas, el de solo Ametralladoras con 10 y el que pone torres al azar pierde en la oleada 7: la variedad de torres ahora importa.
- **Herramienta:** el bot aprendió a tener en cuenta el camino aéreo al elegir casillas para torres antiaéreas.

### D-019 · Cada nivel puede tener su propio aumento de vida por oleada
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T43; era una pregunta abierta de la spec)
- **Qué:** `LevelData.health_scale_percent_per_wave`. Si vale 0, se usa el general de `BalanceConfig` (40 %).
- **Por qué:** con +40 % por oleada, un nivel de 20 oleadas termina con enemigos 9 veces más fuertes. Con el bot, el nivel 3 se perdía siempre en la oleada 6. Los niveles largos necesitan un aumento menor. Valores elegidos en la spec §7.4.

### D-020 · Sonidos y música sintetizados con código
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Claude (T48)
- **Alternativas:** descargar sonidos con licencia libre (CC0); usar un editor como *jsfxr*.
- **Por qué:** descargar archivos de internet requiere revisar la licencia de cada uno y el permiso de Lucas. Sintetizarlos con `tools/make_sounds.gd` (ondas + envolventes) da sonidos "retro" que combinan con el estilo geométrico, sin dependencias externas, y se pueden regenerar cuando se quiera.
- **Cómo reemplazarlos:** poner un `.wav` con el mismo nombre en `assets/audio/`. El juego no necesita cambios.

### D-021 · Versión Android de prueba con adaptaciones mínimas
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Lucas (pidió el `.apk`) / Claude (alcance)
- **Qué:** exportar el mismo proyecto a Android (Godot lo hace sin portar nada) con solo tres adaptaciones: horizontal fijo, botón "atrás" = Esc, y tocar = clic (spec §9.4).
- **Por qué mínimo:** "Versión para móvil" estaba fuera de alcance (spec §11). Lucas pidió hacerlo solo si no era muy complejo. Todo lo necesario ya estaba instalado (Android Studio: SDK y Java 21; plantillas de Godot). Un rediseño táctil de verdad (arrastrar para construir, botones más grandes, zoom) sigue fuera de alcance.
- **Riesgo conocido:** la interfaz fue pensada para 1280×720 con mouse; en pantallas chicas los botones pueden quedar pequeños. Se evalúa al probar (TA3).

### D-022 · Arte y lore entran al backlog
- **Fecha:** 2026-09-28 · **Estado:** Propuesta (sin fecha) · **Propuso:** Lucas
- **Qué:** ideas B-02 (diseño de assets) y B-03 (lore) de la spec §13. Lucas aclaró que no las hacemos ahora.
- **Relación:** Épocas (B-01), lore (B-03) y arte (B-02) se deciden juntos: el lore elige el mundo, el mundo elige el arte.

### D-023 · Arte provisional: dibujos SVG hechos a mano
- **Fecha:** 2026-09-28 · **Estado:** Aceptada · **Decidió:** Lucas (pidió dibujos simples "para rellenar", como primer intento) / Claude (técnica y estilo)
- **Qué:** 22 dibujos en `assets/sprites/` (torres, enemigos, proyectiles y mapa), estilo caricatura con borde oscuro (spec §9.6). No elige ambientación: el arte definitivo sigue en el backlog (B-02).
- **Alternativas:** pixel art generado con código (se ve más tosco y cuesta editarlo); descargar un paquete gratuito, por ejemplo los de Kenney (licencia CC0), que requiere el permiso de Lucas para descargar y revisar la licencia; esperar a un diseñador (B-02).
- **Por qué SVG:** es un formato de **texto** (Claude lo puede escribir y en git se ve qué cambió), Godot lo importa sin agregados, y cualquiera lo puede abrir y retocar en Inkscape (gratis), Figma o Illustrator.
- **Cómo se importan:** al **doble** de tamaño (`svg/scale=2.0`: 128×128 píxeles por casilla), para que se vean nítidos en pantalla completa, y con **mipmaps** (`mipmaps/generate=true`), que son copias achicadas que Godot usa para que el dibujo se vea suave cuando se muestra chico. Las dos opciones están en el `.import` de cada dibujo.
- **Filtro:** el proyecto sigue usando el filtro "Nearest" por defecto, porque con otro filtro aparecen líneas finas entre las casillas del mapa. Solo los nodos que dibujan sprites usan "Linear con mipmaps".
- **Cómo reemplazar un dibujo:** guardar el nuevo con el **mismo nombre** en la misma carpeta, o elegir otro archivo en el Inspector (en el `.tres` de la torre o del enemigo). Sirve cualquier imagen: SVG o PNG de 128×128. Los enemigos, las torretas y los proyectiles se dibujan **mirando a la derecha**; las torretas giran sobre el **centro** de la imagen.

### D-024 · Mapas fáciles de crear y mods entran al backlog
- **Fecha:** 2026-09-29 · **Estado:** Escalón 1 aceptado (D-031); editor y mods, sin fecha · **Propuso:** Lucas / **Analizó:** Claude
- **Qué:** idea B-04 de la spec §13: mapas en archivos de texto (JSON), después un editor dentro del juego y, por último, mods de datos.
- **Recomendación de Claude:** empezar por los mapas en JSON y pasar a ese formato los 5 niveles actuales; los mods, **solo con datos** (JSON e imágenes, sin código), por seguridad.
- **Por qué no ahora:** Lucas pidió analizarlo y dejarlo anotado, no hacerlo todavía.

### D-025 · Cada comportamiento nuevo es un dato que se puede combinar
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (pidió que crear contenido y mods sea fácil) / Claude (cómo)
- **Qué:** quemadura, varios objetivos, ráfaga en círculo, rayo en cadena (torres) y regeneración y crías (enemigos) son **campos** de `TowerLevelData` y `EnemyData`, que valen 0 cuando no se usan (spec RF-164). El código no pregunta nunca "¿es el Troll?" o "¿es la Eléctrica?": pregunta "¿este enemigo se regenera?".
- **Alternativa descartada:** programar cada torre y enemigo nuevo como un caso aparte. Es más rápido la primera vez, pero cada contenido nuevo (o cada mod) necesitaría código.
- **Consecuencia:** una torre nueva puede combinar cosas que hoy no existen juntas (por ejemplo, un rayo que quema) sin programar nada. La guía `CONTENIDO.md` explica cada campo.

### D-026 · Barra de torres compacta, para 8 torres
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Claude (T77)
- **Qué:** los botones de torres muestran dibujo, costo y tecla; el nombre y la frase de la torre aparecen al pasar el mouse y al elegirla (spec RF-170, RF-171). Teclas 1–8.
- **Por qué:** con 8 torres, los botones de 184 px con el nombre no entran en la barra de 1280 px (quedaría tapada "Próxima oleada").

### D-027 · Modos y enemigo espejo entran al backlog
- **Fecha:** 2026-09-29 · **Estado:** Propuesta (sin fecha) · **Propuso:** Lucas
- **Qué:** B-05 (modos de juego; el actual sería "Torres y Bestias", y el de historia usaría imperios reales) y B-06 (enemigo espejo que aturde a las torres cercanas). Lucas pidió solo anotarlos. Además decidió que Épocas (B-01) sea un **modo aparte**.

### D-028 · Modo de pruebas en un ejecutable aparte y con guardado aparte
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (ejecutable aparte) / Claude (el resto)
- **Qué:** el modo de pruebas (spec §10.2) solo existe en `JuegoA_pruebas.exe` (preset "Windows (pruebas)", que agrega la característica `pruebas`) y al jugar desde el editor con `--pruebas`. Usa `save_pruebas.json`.
- **Alternativas:** una clave de administrador dentro del juego; una combinación secreta de teclas.
- **Por qué:** es un juego de un solo jugador que guarda en la computadora del jugador: una "contraseña de admin" no protege nada (el guardado es un archivo de texto que cualquiera puede editar). Lo que importa es que el jugador normal **no vea** las herramientas de prueba y que las pruebas **no ensucien** el progreso ni los récords reales. El ejecutable aparte y el guardado aparte resuelven las dos cosas.

### D-029 · Récords estilo arcade: top 5 por nivel y Salón de la fama
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (qué) / Claude (cómo se calcula)
- **Qué:** puntos = oro de cada enemigo muerto × 10 + vidas que quedan × 100 al ganar (spec RF-190). Top 5 por nivel con 3 letras; Salón de la fama con 5 letras para quien ganó todos los niveles.
- **Cómo se suma el Salón de la fama:** la suma del **mejor puntaje en victoria de cada nivel** de la partida guardada. Alternativa descartada: sumar una "corrida" de la campaña de principio a fin, que obligaría a registrar corridas y a no poder repetir niveles en el medio.
- **Detalle:** se guarda el último total anotado para no volver a pedir letras por el mismo total; se vuelve a entrar solo si el total sube.

### D-030 · Tests automáticos en GitHub Actions
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (hacerlo) / Claude (cómo)
- **Qué:** en cada *push* a `main` y en cada *pull request*, GitHub corre en Linux (`ubuntu-24.04`, fijo para que no cambie solo) el mismo Godot 4.7.2 que usamos, importa el proyecto desde cero, revisa que compilen las herramientas de `tools/` y corre todos los tests de GUT ([`.github/workflows/tests.yml`](../.github/workflows/tests.yml)).
- **Alternativas:** una imagen de Docker ya armada con Godot (por ejemplo `barichello/godot-ci`) o una *action* de terceros; exportar también los ejecutables en cada push.
- **Por qué:** bajar Godot del sitio oficial y guardarlo en la caché es simple, no depende de terceros y fija la versión exacta. Exportar necesita las plantillas de exportación (~1 GB) y no agrega seguridad a los tests: queda para más adelante, si hace falta publicar versiones.
- **Detalle:** GUT **saltea sin avisar** un archivo de test con un error de sintaxis y termina en verde. Por eso el workflow falla también si el registro tiene "SCRIPT ERROR", "Parse Error" o "Failed to load script": una corrida sana no tiene ninguna de esas líneas.
- **Costo:** el repositorio es privado; GitHub da 2000 minutos por mes gratis y cada corrida tarda unos pocos minutos.

### D-031 · Los niveles pasan a archivos JSON (B-04, escalón 1)
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (hacerlo) / Claude (cómo, siguiendo las recomendaciones de B-04)
- **Qué:** cada nivel es un `data/levels/<id>.json` con el mapa dibujado con letras y las oleadas; la campaña es `data/campaign.json` (spec §7.8). El juego arma el mapa al vuelo. Se borran las escenas `level_0N.tscn`, los `level_0N.tres` y `campaign.tres`, y `tools/make_levels.gd` (que escribía los mapas dentro del código).
- **Formato JSON y no `.tres`:** se escribe a mano, Godot lo lee sin agregados y no puede traer código (importa para los mods). Las claves van en castellano (`oro`, `oleadas`, `cada`…), porque el archivo lo edita una persona, no un programador; el código sigue en inglés (constitución).
- **El recorrido es el camino más corto, y un empate es un error:** así el mapa de letras alcanza para describir el nivel (no hay que listar esquinas), y nunca hay un recorrido "adivinado". Se comprobó que los 6 niveles actuales dan exactamente los mismos recorridos.
- **Qué NO incluye:** el editor dentro del juego, cargar mapas de `user://` o de una carpeta de mods, y los dibujos elegidos por casilla (una `X` sigue eligiendo roca, árbol o arbusto sola). Son los escalones 2 y 3 de B-04.
- **Un nivel inválido no rompe el juego:** se saltea con su error en el registro. Los niveles oficiales, además, los revisa un test (y GitHub, D-030) en cada push.

### D-032 · Nivel 7 hecho en JSON y versión para GNU/Linux
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (pidió el nivel 7 y la versión de Linux) / Claude (el diseño y los números)
- **Qué:** el nivel 7 "Cruce" (spec §7.9) es el primero que nace como archivo de texto, para probar el formato de M7 con contenido nuevo. Y se agrega un preset de exportación "Linux" (un solo archivo `JuegoA.x86_64` de 64 bits, con los datos adentro) más un `.tar.gz` que conserva el permiso de ejecución.
- **Aumento de vida 24 %:** se probó con 15, 20, 24, 30 y 45 %. Con 15 y 20 % el bot que mezcla las 8 torres ganaba sin perder vidas; con 30 %, perdía en la oleada 18. Con 24 % el bot que mezcla gana con 7 vidas y el de las 4 torres viejas pierde en la 18: el nivel final exige usar las torres nuevas.
- **Consecuencia:** el Salón de la fama (D-029) pide ganar **todos** los niveles de la campaña, así que ahora exige ganar también el 7. Quien ya lo tenía anotado con 6 niveles vuelve a poder entrar cuando gane el 7 y su total suba.
- **Linux, lo que NO se probó:** el ejecutable se exportó pero no se abrió en una computadora Linux (no había una a mano). Los tests sí corren en Linux en cada push (D-030).
- **Alternativas para Linux:** un AppImage o un paquete Flatpak (más cómodos de instalar, pero piden herramientas y pasos extra); un `.deb`. Quedan para cuando haya jugadores que los pidan.

### D-033 · Prioridades después de M8: editor de mapas y mapas de la comunidad
- **Fecha:** 2026-09-29 · **Estado:** Aceptada (sin fecha de inicio) · **Decidió:** Lucas
- **Qué:** de las ideas para seguir, Lucas eligió **el editor de mapas dentro del juego** y **los mapas de la comunidad** (B-04, escalones 2 y 3). Las demás quedaron en el backlog: mapas más ricos (B-08), rutas explícitas y cruces (B-09), más niveles y niveles difíciles (B-10), compartir un mapa como texto (B-11), mapas al azar y modo desafío (B-12) y una sola app con modo admin (B-13).
- **El editor entra primero en `JuegoA_pruebas.exe`,** como herramienta de administración, junto al panel de pruebas (§10.2). Después se decide si pasa al juego normal o si se unifica todo en una app con modo admin (B-13). Sigue valiendo D-028: lo de administración usa su propio guardado y no ensucia el progreso real.
- **Dónde guarda el editor:** `user://maps/` (el `.exe` no puede escribir en `res://`). Para hacer oficial un mapa se copia a `data/levels/` en el repositorio y se suma a `campaign.json`.
- **Requisito previo:** la selección de nivel debe soportar cualquier cantidad de niveles (hoy es una fila fija de tarjetas que ya se angostó dos veces, al pasar a 6 y a 7 niveles).
- **Los mapas no se ofuscan (ver D-034 para los mapas de la comunidad):** los archivos de nivel viajan legibles dentro del `.exe` y no hay nada que proteger (juego de un solo jugador, sin servidor ni claves), y ofuscarlos rompería los diffs de git, la revisión automática (D-030), `check_level` y los mods. Lo que sí se cuida: la clave de firma de Android no se sube nunca a git.

### D-034 · Mapas de la comunidad: una carpeta, progreso aparte y límites
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (qué: mapas de la comunidad, como segunda prioridad después del editor) / Claude (cómo)
- **Qué:** todo `.json` de `user://maps/` es un mapa de la comunidad y aparece en una solapa de la selección de nivel, en cualquier versión (spec §10.4).
- **Una sola carpeta, la misma del editor:** el editor ya guarda en `user://maps/` (D-033). Así un mapa hecho con el editor de pruebas aparece **solo** en el juego normal, sin un paso de "publicar" ni una carpeta `mods/` aparte. **Alternativa descartada:** una carpeta `mods/` con paquetes (mapas + enemigos + torres + dibujos): es el escalón siguiente del B-04, y Lucas pidió solo la parte de mapas. La carpeta única no impide agregarla después.
- **Progreso aparte, con el id `comunidad_<archivo>`:** el prefijo evita que un archivo llamado `level_03.json` o `hall_of_fame.json` se confunda con un nivel oficial o con el Salón de la fama en el guardado. Los mapas de la comunidad **no desbloquean nada** y **no suman** a las estrellas ni al Salón: si sumaran, cualquiera podría regalarse el "ranking de rankings" con un mapa fácil hecho a medida.
- **Límites para cualquier archivo ajeno (RF-223):** un mapa con `"cantidad": 1000000000` o con 5000 oleadas colgaría el juego. Los topes valen para todos los niveles y coinciden con los del editor. **Solo datos, nunca código:** por eso JSON y no `.tres` (un `.tres` puede traer scripts).
- **Un archivo roto no rompe nada:** se muestra como tarjeta deshabilitada con el motivo (así quien crea el mapa sabe qué arreglar) y el resto sigue andando.
- **Lo que NO incluye:** descargar mapas desde el juego, compartirlos por internet o por código de texto (B-11), calificarlos, y mapas en el celular (la carpeta `user://` no se ve desde el Android). Cualquier alternativa que use internet necesitaría un servidor y otras reglas de seguridad.
- **Riesgo conocido:** un mapa puede ser imposible o demasiado fácil. Los récords de los mapas de la comunidad son **solo del jugador que los juega** (no hay ranking compartido), así que no hay nada que "hacer trampa".

### D-035 · Wiki en el juego: categorías, entradas y bloques, con los datos como fuente
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (qué: una wiki con enemigos, torres y algo más, escalable) / Claude (cómo)
- **Qué:** una pantalla "Wiki" en el menú principal (spec §10.5). La pantalla es **genérica**: dibuja categorías → entradas → bloques (`titulo`, `texto`, `tabla`) y no sabe qué es un enemigo. Lo que sabe de enemigos, torres y artículos está en `Wiki` ([`wiki.gd`](../scripts/logic/wiki.gd)), que arma las entradas **leyendo los datos**.
- **Por qué así (escalabilidad):** agregar un enemigo o una torre a `data/` lo agrega solo a la wiki (nada de listas a mano que se olviden); agregar un artículo es soltar un `.json` en `data/wiki/`; agregar una categoría entera (Niveles, Lore, Épocas…) es **una función más** en `Wiki` que devuelve entradas, sin tocar la pantalla. Las entradas son datos simples y por eso se prueban sin abrir ninguna ventana.
- **Los números salen de los datos** (constitución P2): la vida, el daño o el costo que se ven en la wiki son los del `.tres`. Los artículos escritos a mano explican reglas, no repiten números.
- **Se refactoriza el texto de la torre:** el panel de la torre ya armaba las líneas "Daño, cadencia, área, quema…" a mano; ahora vive en `TowerText` y lo usan el panel y la wiki, así no hay dos versiones que se desincronicen.
- **Alternativas descartadas:** (1) una escena con una página dibujada a mano por enemigo: cada enemigo nuevo obligaría a editar la escena; (2) un solo archivo grande de texto con todo: se duplicarían los números de los `.tres`. (3) Ocultar lo que el jugador todavía no vio: no se hace por ahora (RF-238); queda como B-15.
- **Lo que NO incluye:** buscador, enlaces entre entradas, bestiario que se llena, imágenes propias en los artículos (B-15).

### D-036 · Bestiario: los enemigos se abren al verlos
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas
- **Qué:** en la wiki (D-035) un enemigo está cerrado ("???", silueta) hasta que el jugador lo ve por primera vez en una partida (spec §10.5, RF-238 a RF-240). Torres y Guía se ven siempre; el modo de pruebas lo ve todo.
- **Por qué así:** el guardado ya recordaba qué enemigos se vieron (RF-134), así que **no hay datos nuevos que guardar** y los jugadores que ya jugaron encuentran abiertos los que ya vieron. Coleccionar enemigos le da una razón más para explorar los niveles y no arruina las sorpresas (un jefe, un volador).
- **Cómo:** `Wiki.categories()` recibe una función "¿lo vio?"; la entrada cerrada es un `WikiEntry` con `locked = true` que **no lleva** los datos reales (así ni un error de la pantalla los puede filtrar). La pantalla solo dibuja la silueta y el "???".
- **Alternativa descartada:** ocultar del todo las entradas cerradas: el jugador no sabría que existen más ni cuántos faltan. Con "???" hay algo que completar.
- **Consecuencia:** un enemigo visto en un mapa de la comunidad también se abre (es el mismo guardado y el mismo aviso de RF-134).

### D-037 · Mapas más grandes con zoom (cámara), no con desplazamiento
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas (qué: un mapa un poco más grande, solo para los niveles 9 y 10) / Claude (cómo)
- **Qué:** un mapa puede medir de 20×9 a 26×12 casillas y el juego lo achica para que entre entero (spec §7.10, RF-250 a RF-255).
- **Cómo:** una `Camera2D` con `zoom` y centrada en el mapa, solo cuando el mapa no es de 20×9. **Es lo que menos toca:** una cámara **no cambia las coordenadas del mundo**: `global_position`, los alcances en píxeles y la casilla bajo el mouse (`get_global_mouse_position`) siguen valiendo lo mismo. Si en cambio se hubiera achicado el nodo `Game`, cada distancia entre torres y enemigos (más de 50 usos de `global_position`) habría quedado multiplicada por el zoom y todo el combate habría cambiado sin avisar. La barra de arriba y la de torres son `CanvasLayer`, que la cámara no toca.
- **Por qué solo hasta 26×12:** con zoom 0,75 las casillas miden 48 px en la pantalla lógica de 1280×720; más chico se vuelve difícil de tocar con el dedo. Lucas pidió "no mucho".
- **Alternativa descartada:** cámara que se desplaza (mapas enormes): peor en el celular (el dedo ya selecciona torres), obliga a pensar qué se ve y qué no, y cambia mucho más.
- **Lo que NO incluye:** cambiar el tamaño desde el editor (RF-254), tamaños menores a 20×9, zoom manual del jugador.

### D-038 · El editor de mapas es para todos (opción 2 de B-13)
- **Fecha:** 2026-09-29 · **Estado:** Aceptada · **Decidió:** Lucas
- **Qué:** el botón "Editor de mapas" pasa al juego normal (spec §10.3, RF-210). Sigue siendo del modo de pruebas el panel de pruebas y **jugar cualquier nivel de la campaña** (RF-183, RF-184): Lucas quiere que la comunidad haga mapas, pero que los niveles de la campaña se ganen.
- **Cómo:** una línea en el menú. Se **mantienen los dos ejecutables** (opción 2 de la propuesta): no hace falta un archivo `pruebas.txt` ni una app unificada todavía (B-13 sigue abierta).
- **Consecuencia que Lucas conoce:** el editor guarda en la misma carpeta que lee la solapa de los mapas de la comunidad (D-034), así que **un mapa hecho por un jugador aparece solo en su propia lista**, sin publicar nada. No hay riesgo para nadie más: los mapas de la comunidad son solo datos (RF-223) y con progreso propio.
- **En el celular no se ofrece:** el editor es de mouse y teclado (Ctrl+Z, teclas 1 a 5) y la carpeta de mapas no se ve desde el Android (RF-220).
- **El editor puede abrir los niveles oficiales** (para mirarlos o partir de uno): no se pueden pisar, hay que guardarlos con otro nombre (RF-216).

### D-039 · Leyenda y temas: dos campos opcionales, un catálogo cerrado de dibujos
- **Fecha:** 2026-09-29 · **Estado:** **Aceptada** (Lucas, 2026-09-29: aprobó los temas, sumó bosque, pantano y ruinas, y el estilo de arte; el editor va en otra etapa) · **Decidió:** Lucas (qué) / Claude (cómo)
- **Qué:** un nivel puede tener `"tema"` (paisaje de todo el mapa) y `"leyenda"` (letras nuevas con un dibujo del catálogo y si se puede construir). Spec §7.11.
- **Por qué campos opcionales:** los 7 niveles y los mapas de la comunidad que ya existen no cambian ni se tocan, y un archivo viejo se sigue leyendo igual (misma idea que `aumento_vida`, D-019).
- **Por qué un catálogo cerrado de dibujos (y no imágenes propias en el archivo):** un mapa de la comunidad tiene que ser **solo datos** (D-034): una imagen dentro de un JSON es más peso, más superficie de error y, con archivos ajenos, más riesgo. Los mods con imágenes propias siguen siendo el escalón siguiente de B-04, y un catálogo no lo impide.
- **Por qué una letra de leyenda nunca es camino:** así **no se toca el cálculo de los recorridos** (§7.8, RF-202), que es lo más delicado del formato y está muy probado. Para el juego una letra de leyenda es pasto o bloqueada; el resto es dibujo. Un "puente" (camino que se ve distinto) queda para después.
- **Cómo (plan §6.12):** `MapGrid` entiende las letras de la leyenda como pasto o bloqueada y recuerda cuál es cuál; `LevelDecor` recibe el tema y el dibujo de cada casilla. Los temas son **paletas y listas de decoración en código**, no un TileSet por tema: tres colores planos y decoración dibujada encima ya es como está hecho hoy (RF-126).
- **Alternativas descartadas:** (1) un TileSet distinto por tema: hay que rehacer el suelo y los tests de casillas para pintar tres colores; (2) que la leyenda pueda declarar **caminos**: obliga a rehacer el cálculo de recorridos; (3) un tema por casilla: sin uso claro y multiplica los casos.
- **El editor queda para M16:** Lucas prefirió hacer primero lo que se ve en el juego y después los botones del editor. Mientras tanto un mapa con tema y leyenda se escribe a mano y el editor **lo conserva** al abrirlo y guardarlo.
- **Riesgos conocidos:** el **arte** es el grueso del trabajo (unos 25 dibujos nuevos: siete temas con su decoración y los dibujos de la leyenda) y hay que cuidar el estilo (RF-151). Un mapa con muchas letras de agua se puede ver repetitivo hasta que haya una decoración más rica (B-08).

### D-040 · Guía de arte y reglas por carpeta; qué se toma del repositorio Claude Code Game Studios
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Lucas
- **Qué:** se escribe la **guía de arte** ([`05-guia-de-arte.md`](05-guia-de-arte.md)) a partir del rediseño de los nueve enemigos (T127) y se ponen **reglas por carpeta** para Claude en `.claude/rules/` (`gdscript.md`, `tests.md`, `datos.md`, `arte.md`, `specs.md`). Cada archivo declara a qué carpetas aplica y solo se carga cuando se trabaja ahí.
- **De dónde viene:** Lucas propuso revisar el repositorio **Claude Code Game Studios** (49 agentes, 74 comandos, 12 hooks, 13 reglas por carpeta). Se leyó a través de un resumen de su página, **no su código**.
- **Qué se toma:** la idea del **director de arte** (→ guía de arte) y de las **reglas por carpeta** (→ `.claude/rules/`). Quedan anotadas como sugerencias (backlog): informe de prueba, auditoría de recursos, notas de versión y registro de deuda técnica.
- **Qué NO se toma:** los 49 agentes, los sprints y retrospectivas, las plantillas de documentos de diseño y los **hooks** (Lucas: `validate-commit` no hace falta). El flujo actual (spec, decisiones, tareas, tests, commit) ya cubre lo que ese marco resuelve, con menos contexto y sin ejecutar scripts ajenos.
- **Por qué reglas por carpeta y no todo en un solo archivo:** son **cortas, específicas y se cargan solo donde se trabaja**; la constitución sigue siendo la fuente y las reglas la recuerdan junto con los errores que ya nos pasaron (tabuladores, `StringName`, `JSON.parse_string`, funciones que cambian de pantalla en los tests).

### D-041 · El orden de las próximas etapas
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Lucas
- **Qué:** después de leyenda y temas (M15) el orden es: **1)** enemigos con aura, **Guardián y Curandero**; **2)** **Chamán y Espejo**, con la regla nueva de "torre aturdida"; **3)** **torre 2×2 que se construye directo** (B-16, forma B); **4)** **sinergias entre torres vecinas** (B-16, forma C); **5)** los **niveles 8, 9 y 10**, que estrenan todo lo anterior. La **fusión** de 4 torres (B-16, forma A) queda **para más adelante**, sin fecha. El **editor con tema y leyenda** (M16) queda también para otra etapa.
- **Por qué los niveles al final:** cada nivel nuevo debe estrenar enemigos, torres y paisajes que ya existan; hacerlos antes obligaría a rehacerlos (D-036 y D-039 dejaron listas las piezas visuales y de datos).
- **Detalle de los enemigos** (aspecto, datos, números de partida y contrajuego): B-07 ampliado. **Detalle de las torres:** B-16.

### D-042 · Las auras se "pulsan" y caducan, en vez de calcularse en un administrador central
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Claude (cómo), sobre lo que Lucas aprobó (D-041)
- **Qué:** cada portador de aura, cada 0,25 s, busca a los enemigos cercanos (la misma búsqueda por grupo que usa el rayo en cadena) y les da el efecto **por 0,35 s**. Cuando no lo refrescan, el efecto **caduca solo**.
- **Por qué:** (1) **no hay un nodo administrador** que recorra a todos: cada enemigo es autosuficiente (constitución P6); (2) si el portador muere, se va o llega a la salida, **no hay que "quitar" nada a nadie**: el efecto caduca en menos de medio segundo; (3) la pausa y el x2 funcionan solos porque se cuenta con el tiempo del mundo; (4) con 200 enemigos y unos pocos portadores el costo es despreciable.
- **Cómo no se pisan dos auras:** el que recibe guarda **el mayor** valor y cuándo caduca. Un aura más débil no refresca a una más fuerte, así que si el portador fuerte muere, su valor caduca y recién ahí entra el débil.
- **Alternativas descartadas:** (a) un administrador que recalcula todo cada frame: acopla todo y es más lento; (b) que cada afectado busque a los portadores: obliga a cada enemigo a mirar a todos.
- **Consecuencia:** entre la muerte del portador y el fin del efecto pasan hasta 0,35 s. Es intencional y se ve como un "apagarse" natural.

### D-043 · "Torre aturdida" es un estado de la torre; el disparo lleva la torre que lo hizo
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Claude (cómo), sobre lo que Lucas aprobó (D-041)
- **Qué:** `Tower` tiene un contador de aturdimiento (`stun`, `is_stunned`, `stun_left`) y un grupo (`Tower.GROUP`) para que un enemigo las encuentre. Un `Projectile` recuerda **qué torre lo disparó** (`source`).
- **Por qué:** el Chamán necesita **encontrar torres** y el Espejo necesita saber **quién le pegó** para aturdirla. Antes nada de eso existía: un proyectil no sabía de dónde venía y las torres no tenían estados.
- **Cómo se evita romper nada:** el aturdimiento solo **impide disparar** (el resto de la torre sigue igual: apuntar, mejorar, vender). Un proyectil sin torre de origen (los de los tests y los sueltos) se comporta como siempre.
- **Los rebotes:** ocurren al **impactar** y miden la distancia entre la torre y el Espejo en ese momento, no al disparar. Así una torre que dispara de lejos y el enemigo se acerca **sí rebota** si al llegar está cerca. Es coherente con el "castigo a las torres pegadas al camino".
- **Alternativas descartadas:** (a) rebotar al **disparar** según la distancia de ese instante: un tiro que sale de lejos y llega de cerca no rebotaría; (b) que la quemadura también rebote: haría inútil a la Incendiaria contra el Espejo, cuando el diseño dice que es una de sus respuestas.
- **Consecuencia conocida:** el Espejo es muy fuerte contra las torres pegadas al camino con poco alcance (Ráfaga, Eléctrica); es su papel. Con 2,5 casillas de rebote y 2 s de aturdimiento, las de largo alcance (Francotirador, y las de nivel 3 a 3,5 casillas) lo golpean sin problema.

### D-044 · Las torres grandes: el tamaño es un dato y la torre recuerda sus casillas
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Lucas (hacer el Mortero 2×2 primero, D-041) y Claude (cómo)
- **Qué:** `TowerData.footprint` (lado en casillas, 1 por defecto). `BuildController` anota **las cuatro casillas** de una torre grande en el registro de ocupadas y la torre guarda cuáles son; vender las libera todas. La torre se coloca en el **centro** del cuadrado y apunta y mide desde ahí. La vista previa se centra en el mouse.
- **Por qué un dato y no una clase aparte:** una torre grande es la misma torre con otro tamaño (constitución D-006: una sola escena). Así la fusión de cuatro torres (B-16 forma A) podrá reusar todo esto sin tocar la ocupación.
- **Por qué el mouse va al centro:** con la esquina arriba a la izquierda, el cuadrado se "escapaba" hacia abajo y a la derecha y costaba apuntar; centrado, lo que se ve es lo que se construye.
- **Por qué reusar las bases:** `base_1`, `base_2` y `base_3` son dibujos vectoriales que escalan sin perder nitidez; hacer tres bases nuevas solo para el Mortero sería trabajo de arte que la fusión ya no necesitaría. Solo se dibuja la torreta y la bomba.
- **Alternativas descartadas:** (a) una escena aparte para las torres grandes: duplica mejorar, vender, aturdir y apuntar; (b) guardar solo la casilla de arriba a la izquierda y calcular el resto al vender: cada consulta "¿está ocupada?" tendría que recorrer todas las torres.
- **Riesgos conocidos:** en los mapas de 20×9 hay pocos lugares con 2×2 libres cerca del camino; el Mortero es de **largo alcance** (5 casillas) justamente para no necesitar estar pegado. Al ser la novena torre, la barra queda más apretada en pantallas chicas (se revisa en T140).

### D-045 · El Mortero es una torre reservada: solo los niveles que la piden la tienen
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Lucas ("la torre de 4 no me terminó de convencer, dejarla solo para el nivel 10")
- **Qué:** `TowerData.reserved` y el campo `"torres_extra"` del archivo de nivel (`LevelData.extra_towers`). `Game.available_towers` (lo que ven la barra y las teclas) sale de `tower_types` filtrando las reservadas no habilitadas. El Mortero sigue en `tower_types`, en la Wiki y en los tests.
- **Por qué así y no un "nivel desde el que se desbloquea":** la campaña todavía no tiene desbloqueos de torres; un campo en el nivel es lo más chico que sirve hoy y deja a los mapas de la comunidad habilitar torres reservadas si quieren. Más adelante puede crecer a un sistema de desbloqueos sin cambiar los archivos.
- **Alternativa descartada:** sacar el Mortero del juego hasta el nivel 10: perdería su ficha, sus tests y la prueba de que el 2×2 funciona.
- **Consecuencia:** hasta que exista el nivel 10, el Mortero solo se juega con un mapa que lo habilite. La restricción es de **interfaz**: `BuildController.try_build` no rechaza una torre reservada (los tests y el bot construyen directo).

### D-046 · Sinergias en dos etapas: primero reacciones por estado, después vecinas
- **Fecha:** 2026-09-30 · **Estado:** Aceptada · **Decidió:** Lucas (elegir A y B1 en dos etapas, 8 casillas de vecindad, combos de +25 a 30 %); Claude propuso las opciones y los números
- **Qué:** etapa A (M20): `bonus_vs_slowed_percent` y `bonus_vs_burning_percent` en `TowerLevelData`; el proyectil mira los estados del enemigo **al impactar** y le pasa el daño ya multiplicado. Etapa B1 (M21): pares de torres vecinas, por especificar.
- **Por qué empezar por A:** prueba la idea de "combinar ataques" **barata** (sin interfaz de vecindad ni líneas) usando estados que el juego ya muestra; si los combos no divierten, se descubre antes de construir la parte cara.
- **Por qué el bono va antes de la armadura:** el golpe "vale más" y después la armadura resta lo de siempre (RF-80). Así un bono sobre un daño grande rinde casi entero, y sobre uno chico se lo come la armadura, como debe ser.
- **Por qué los dos porcentajes se suman y no se multiplican:** son fáciles de explicar ("+25 % y +30 % = +55 %") y no se disparan si se agregan más estados.
- **Alternativas descartadas:** (a) bonus para todas las torres: borra la identidad de cada una; (b) un estado nuevo ("mojado", "empapado") para combinar: más reglas que enseñar cuando ya hay dos estados visibles; (c) que el bono dependa de **cuánto** está ralentizado: los números dejarían de poder anunciarse en el panel.
- **Riesgo conocido:** con Hielo y Cañón juntos en el camino, las partidas se vuelven más fáciles en los niveles 1 a 7 (que no se pensaron con esto). Se mide con el bot (T145) y, si hace falta, se baja el bono o se rebalancean oleadas.

### D-047 · El combo primero se lee y se descubre; si falta peso, una regla nueva (no más porcentaje)
- **Fecha:** 2026-10-01 · **Estado:** Aceptada · **Decidió:** Lucas (empezar por que se lea y se descubra, el color según el estado, y "una regla nueva está bien" si después falta peso); Claude investigó y propuso
- **De dónde sale:** Lucas sospechaba que el combo de la etapa A (D-046) quedaba "flojo". Una investigación con capturas de partidas reales y **784 partidas del bot** (copia instrumentada, 8 semillas por caso) encontró tres causas:
  1. **No se lee:** el "¡Combo!" usaba el mismo tamaño, subida y corrimiento que los números de daño y se encimaba con ellos; era del **mismo dorado** que el "+N" del oro (que sale justo cuando el golpe mata); su anillo se confundía con la onda naranja del Cañón; y con los números apagados desaparecía entero.
  2. **Pesa poco porque pasa poco:** los enemigos están ralentizados apenas el **3 a 14 %** del tiempo (un Hielo frena **un** enemigo por segundo), así que el bonus aporta el **1,6 a 7,7 %** del daño total. Con 25/30 % el bot `mix` gana 48 de 56 partidas (43 sin bonus); con **50/60 %**, 51: duplicar el porcentaje **casi no cambia** las partidas (en la mayoría de las semillas terminan igual).
  3. **Nada lo hace descubrir:** solo lo decía el panel de la torre que aprovecha; el Hielo, la Incendiaria, la barra y la Wiki no.
- **Qué:** RF-315 a RF-318. El número de daño del golpe **es** el aviso (más grande, con "!", del color del estado: **celeste** = ralentizado, **naranja** = quemado), "¡Combo de hielo!" / "¡Combo de fuego!" la primera vez en la partida, sin amontonar (0,15 s y 40 px), anillo y sonido aunque los números estén apagados, tope propio; un sonido propio; el combo se dice desde la torre que pone el estado (armado desde los datos) y en la barra; y una marca de "vulnerable" en el enemigo cuando hay en el mapa una torre que lo aprovecha. **Los porcentajes no cambian.**
- **Por qué el color según el estado (y no uno solo para todos los combos):** enseña la **causa** ("celeste = por el hielo") con los mismos colores que el juego ya usa para esos estados (escarcha, llamitas). Lo eligió Lucas.
- **Por qué no dorado:** en el juego el dorado ya significa **oro** (RF-124, el "+N" y la barra de arriba).
- **Por qué no marcar en la vista previa con quién combina:** en la etapa A la ubicación **no importa** (el bot que pone Hielo y Cañón pegados ganó **menos** que el que los reparte: 43 contra 48 de 56, porque amontonarlos pierde cobertura del camino). Una línea entre torres haría creer que tienen que estar juntas, que es justamente la regla de la B1 (vecinas), donde sí se marcará.
- **Si después falta peso:** Lucas aprobó una **regla nueva** en vez de subir porcentajes: el combo frena en seco al enemigo un instante (el "quiebre"). Se especifica, con sus números y una medición del bot, cuando se tome (después de que Lucas lo pruebe a mano).
- **Alternativas descartadas:** (a) subir los porcentajes a 40/50 o 50/60 %: barato, pero el bot muestra que casi no se siente; (b) un "¡Combo!" mejor ubicado pero aparte del número: siguen siendo dos textos por golpe; (c) un color único para todos los combos: más simple de reconocer pero no enseña la causa.
- **Hallazgo de paso (herramientas):** el bot de balance **no era repetible** cuando corren varias copias a la vez: el temblor de pantalla (RF-128) usa `randf` sin semilla fija, y en el nivel 7 eso cambiaba el resultado (8 de 10 corridas perdían en la oleada 11 y 2 en la 18). Parte del "derrota en la 18 → en la 11" de T145 era ese ruido. Se anotó como sugerencia (fijar la semilla en el bot); no cambia el juego.


### D-048 · El modo de pruebas puede empezar en cualquier oleada, con el oro que habría juntado
- **Fecha:** 2026-10-01 · **Estado:** Aceptada (Lucas, 2026-10-01: "dale, hacelo, pero sobre un PR") · **Decidió:** Lucas (aprobó la mejora, que sale del análisis de la skill `godot-test-mode`); Claude propone el cómo
- **Qué:** RF-319 a RF-325: oleada inicial y oro inicial al elegir nivel, cinco velocidades (x0,25 a x4) que se ven en el cartel, cinco atajos de teclado (`F2` a `F4`, `F6` y `F7`) para las acciones más usadas del panel y un informe de estadísticas de la partida.
- **Por qué:** para ver la oleada 18 o mirar el aviso de combo (RF-315 a RF-318) hoy hay que jugar el nivel entero, y la única velocidad extra (x4) vuelve ilegible justo lo que se quiere mirar. La referencia es el modo de pruebas de Former Walker (saltar a cualquier etapa con equipo inicial).
- **Cómo se calcula el oro por defecto:** oro inicial del nivel + recompensas de **todos** los enemigos de las oleadas saltadas (con sus crías, `death_spawn`) + bono de cada una. Es lo que juntaría quien no deja pasar a nadie. **Por qué así y no solo "oro del nivel + bonos":** sin las recompensas, quien salta a la oleada 15 llega con poco oro y no puede defenderla; la prueba no serviría. **Por qué no un número medido con el bot:** el bot es tosco (T145) y su resultado cambia con cada estrategia; la fórmula sale de los datos y se actualiza sola si cambia una recompensa. En T150 se **contrasta** con el bot (oro que le queda + lo que gastó en torres, al terminar la oleada N-1) y las diferencias se escriben tal cual, sin ajustar la fórmula para que coincida.
- **Por qué se empieza sin torres:** restaurar "la defensa que habría armado" exigiría elegir torres y lugares: una decisión de diseño que no es de esta herramienta. Con el oro alcanza para armarla a mano en un minuto (en pausa).
- **Por qué una franja en la selección de nivel y no un cuadro al elegir cada nivel:** es un clic menos (se prueba mucho el mismo nivel). El costo: el máximo de oleadas depende del nivel y no se conoce hasta elegirlo; por eso un valor mayor se ajusta a la última oleada.
- **Por qué esa partida no guarda progreso:** una victoria desde la oleada 6 daría estrellas y récords que no valen. Se trata como el nivel probado desde el editor (RF-217). Con la oleada 1 se guarda como antes.
- **Por qué `F2` a `F4`, `F6` y `F7` (y no `F5`):** `F5` la usa Godot en los cuadros de archivos (`ui_filedialog_refresh`); lo encontró el test que recorre el `InputMap`. Y `1`-`9`, `Esc`, `Espacio`, `P`, `F`, `U` y `S` ya están en uso, y las teclas de función no las usa ningún jugador. Son acciones del `InputMap` creadas solo en el modo de pruebas (el juego normal no las tiene) y un test recorre el `InputMap` para que ninguna choque, hoy y cuando se agregue otra acción.
- **Por qué la velocidad se ve en el cartel:** es lo que más fácil se olvida activado, y el cartel de MODO PRUEBAS ya es lo que ve todo el que usa esta herramienta. Vuelve a x1 al salir (RF-105).
- **Alternativas descartadas:** (a) un deslizador de velocidad: más difícil de repetir y de leer el valor exacto que cinco botones; (b) guardar "puntos de control" de partidas reales para saltar a ellos: serviría para probar con una defensa real, pero es mucho más trabajo y queda como idea; (c) cambiar el juego normal: no, es una herramienta de administración (B-13).
- **Riesgos conocidos:** a x0,25 la cuenta atrás y las animaciones también van lentas (es lo pedido); el oro automático es un **techo** (nadie deja pasar a ningún enemigo), así que probar con él es probar con una defensa algo más rica que la real.
- **Estadísticas (RF-325):** Lucas dijo que sí. Van **al final**, porque son más útiles cuando ya se llega rápido a la oleada que se quiere medir. Se escriben en `user://pruebas_stats.json` con los datos del informe del bot y sus nombres pasados al inglés (`wave`, `lives`, `gold`, `towers`, `result`), para compararlos a ojo o con un script. Una partida **reemplaza** el archivo: es el informe de una prueba, no un historial.

### D-049 · Tres familias visuales, sprites con ocho vistas

**Fecha:** 2026-10-02. **Estado:** aceptada por el pedido de Lucas. **Refs:** RF-326 a RF-328.

Lucas eligió A para el cañón, B para las torretas y C para hielo. Se extiende A al mortero, B a básica/francotirador/fuego/múltiple/ráfaga y C a Tesla. Las imágenes renderizadas se conservan en PNG con alfa; no se vuelven a aproximar con polígonos SVG. Ocho vistas mantienen volumen y luz al apuntar en el juego 2D. La base se separa del mecanismo que gira. El atlas se corta y normaliza mediante una herramienta reproducible de Godot y se conserva una vista de 128×128 para consumidores antiguos. Se descarta rotar una imagen de perspectiva fija, porque haría girar también la vertical y la iluminación. Se conserva la ruta de una sola textura para datos sin atlas. No se cambia el balance.

### D-050 · Monstruos M24: copias de producción de una sola vista, sin espejo, y evoluciones sin integrar

**Fecha:** 2026-10-02. **Estado:** aceptada por el pedido de Lucas. **Refs:** RF-329 a RF-333.

Lucas aprobó diablillo rojo, bestia turquesa, ogro verde y el logo corregido. Los PNG generados son una sola vista con la luz arriba a la izquierda. **Decisión:** (1) se hacen copias de producción de 256×256 con una herramienta reproducible de Godot (las fuentes no se tocan) que recorta el cuerpo, lo escala y apoya los pies siempre a la misma altura; (2) estos enemigos **no se reflejan en espejo** al caminar a la izquierda, porque el espejo movería la luz a la derecha, y se acepta que miren siempre hacia el mismo lado hasta tener vistas propias (campo `flip_when_walking_left`, por enemigo); (3) el menú usa el logo y un tema propio para los botones, sin tocar el tema del resto del juego; (4) las evoluciones **no se integran**: usarlas como atlas de ocho vistas sería inventar vistas que no existen. **Alternativas descartadas:** reflejar igual (la luz quedaría en el lado equivocado); rotar la imagen (gira también la luz y la vertical, como ya se descartó en D-049); fabricar cuatro u ocho vistas con deformaciones (daría un resultado falso); teñir las torres por nivel (el plan M24 pide evitarlo); un tema global para todos los botones (cambiaría pantallas que nadie pidió revisar). **Consecuencia:** el movimiento es solo el bamboleo y el monstruo mira siempre al mismo lado; la siguiente entrega artística necesita vistas laterales izquierda/derecha con la misma luz (plan §6.20).

## D-051 · Texturas M26 sobre el mapa lógico
LevelDecor dibuja los PNG preparados sobre el TileMap existente. MapThemes centraliza los recursos y conserva el fallback a pradera. Se descarta reemplazar el TileSet: sus datos de construcción y navegación no necesitan cambios. Las superficies especiales de leyenda conservan su dibujo actual.

## D-052 · Evoluciones discretas y entrega artística separada
Generar niveles 2 y 3 usando los atlas aprobados como referencia: identidad, ocho vistas y luz fija. Preparar copias normalizadas y muestras antes de integrar; los cinco especiales son conceptos estáticos para revisión, con su función visible en la silueta. No se sustituyen datos de producción con fuentes sin validar.

## D-053 · Atlas opcional por nivel
TowerLevelData contiene un atlas visual opcional; Tower lo elige según stats() con fallback al atlas del tipo. Los especiales siguen el contrato estático M24. Se conservan todas las cifras de balance.

## D-054 · Prototipos aislados para revisar M28
Usar los cinco físicos aprobados y los ciclos M25 existentes, comparar aumentos solo visuales y reducir deformación global. Comparar ventana1920×1080 con y sin cambio de lienzo lógico, porque más resolución por sí sola no agranda las unidades. Evaluar montaje y contacto entre mecanismo y base antes de producir nuevos atlas.

## D-055 · Escala visual, poses reales y encastre C
Lucas aprobó +20 %, ciclos de patas y montaje C de M28. La escala vive en EnemyData y se dibuja con anclaje a los pies, sin modificar size_tiles. EnemyVisual selecciona cuadros por distancia (caminar) o tiempo físico (aleteo), evitando deformaciones de todo el sprite. Se integran los ciclos existentes, sin inventar poses para los nueve estáticos. El montaje C utiliza un asiento fijo nuevo con contacto y mecanismos de ocho vistas; el cañón se rediseña siguiendo el concepto C. El lienzo lógico sigue en1280×720: cambiarlo a1920×1080 dejaría huecos o alteraría coordenadas y balance. Solo la ventana de escritorio crece y se limita al área útil del monitor. Se descartan reflejos que cambian la luz y rotaciones de sprites planos.

## D-056 · Reflejos aditivos sobre las mejoras existentes
Los atlas por nivel ya cambian, pero el brillo pintado es sutil a escala de partida. Añadir un Sprite2D con shader de reflejos localizados sobre los píxeles claros del mecanismo; intensidad por nivel y color por familia. La textura y el cuadro son los de producción, sin recolorear el cuerpo entero ni sumar sombras. El tiempo viene del proceso físico, respetando pausa. Se descarta redibujar todos los atlas para este detalle. Los nueve enemigos sin ciclo quedan registrados, sin inventar animaciones de patas.

## D-057 · Completar nueve ciclos conservando el contrato M29
Generar una hoja independiente por criatura tomando su PNG aprobado como referencia estricta, cuatro direcciones por cuatro fases reales (16cuadros). Empaquetar por conectividad de alfa en Godot, escala constante por especie, pies fila191; calibrar el enmarcado frente a la pose estática para que no se achique al animarse. Integrar con walk_atlas/stride/art_scale existentes, sin otra máquina de estados ni efectos de combate nuevos. Se descartan imágenes reflejadas, deformación global y sustituir habilidades por efectos dibujados.

## D-058 · Renovación rápida de HUD y monitor
2026-10-02, aprobada por Lucas. Reutilizar tema hierro/bronce; barra con borde, pausa y panel agrupados. Hud posee el monitor y DevPanel emite la activación: cerrar el panel no lo oculta. FPS/ms estimados bastan; se descartan métricas adicionales costosas y telemetría remota.

## D-059 · Un tema reutilizable para submenús
2026-10-02, aprobada por Lucas (B-19). Extender el tema existente con deslizadores, casillas y listas desplegables; aplicarlo localmente a submenús y paneles, sin tema global ni cambios de guardados. Conservar el marco dorado del Salón de la Fama y todos los flujos.

## D-060 · APK independientes para instalación local
2026-10-02, pedido por Lucas. Reusar exportación Android sin Gradle, arm64 y feature pruebas solo en variante de administración. Firmar con clave de depuración local para instalación directa, sin publicación en Play Store. iOS requiere macOS/Xcode y firma Apple, no se genera APK ni se promete IPA desde Windows.

## D-061 · Panel compacto con contenido desplazable
2026-10-03, autorizado por Lucas al iniciar el orden de mejoras (B-28). Reutilizar el tema local hierro/bronce y separar métricas, descripción/efectos y acciones. Mantener270 píxeles de ancho y fijar la altura; desplazar solo el detalle para que textos de mods y sinergias no empujen los botones fuera de pantalla. Conservar señales y lógica de Game/BuildController. Se descarta ampliar el ancho o recortar los efectos. El foco de teclado usa el tema existente; no se toma automáticamente al seleccionar con el mouse.

## D-062 · Cierre completo del rango B-20 a B-27
2026-10-03, Lucas aclaró que autoriza completar todo el rango. Implementar B-20/24/25/26/27 y entregar investigación B-21/22/23 conforme a su alcance registrado. Efectos dibujados y shaders sobre arte existente: no inventar ciclos de muerte deformando poses ni regenerar monstruos. Residuo de muerte conserva la pose/silueta antes de disolverse; remaches quedan en la base y no dependen del brillo. Audio original por síntesis con ataque/final suaves y variantes/menu-combate; sin descargas/licencias ajenas. Prototipos de vista quedan fuera del paquete y no autorizan migración ni merge. Esta tanda se verifica y registra como una tarea completa con sus ocho entregables.

## D-063 · Depurar el backlog y separar documentación futura
2026-10-03, decisión de Lucas. Cerrar B-02 y resolver arte futuro mediante detalles específicos. Retirar el bestiario ya hecho de B-15 y descartar búsqueda/enlaces, categoría Niveles e imágenes adicionales. Trasladar lore y documentación de Épocas a B-03; separar Wiki de mods (B-29) y comunidad (B-30), sin duplicar sistemas de B-04 ni renumerar ids anteriores. B-01 conserva la mecánica de Épocas. B-21/22/23 continúan abiertos: los informes M36 son rápidos/preliminares, no decisiones ni diseños definitivos. Se descarta mantener un bloque genérico de mejoras de Wiki o arte permanentemente abierto.

## D-064 · Progresión por fuentes y apoyo antes de desgaste
2026-10-03, Lucas aprueba desarrollo por etapas. Una fuente de avance distinta por nivel1–5, colección genérica persistente más permiso por nivel; Estandarte desde6, admin habilita sin colección. La oleada debe completarse antes de una derrota para conservar el drop; abandonar no conserva. Elegir un portador aleatorio entre enemigos originales garantiza oportunidad si se matan todos, evitando azar sin límite y duplicados por farmear un solo nivel. Se descarta introducir amenazas nuevas en1–5 o agregar ahora niveles8–15 sin diseño/balance. Ladrón periódico con piso10 y Embestidor al final de rectas pasan a siguientes etapas; mecánico reparador después. Vida/destrucción/reconstrucción quedan como alternativa futura, no se mezclan con aturdimiento ni se implementan ahora. Estatua e icono plateado iniciales son vectoriales nativos; no reemplazan arte aprobado existente.

## D-065 · Avances integrados al HUD
2026-10-03, Lucas pide mover avances a la barra superior respetando icono/valor y seguir las etapas pendientes en feature/avances-estandarte. Se retira el cartel sobre el mapa; estado en ayuda del icono. No cambia la colección ni los primeros cinco niveles. Ramas nuevas siempre feature/, por pedido explícito de Lucas.

## D-066 · Efecto económico por señal y grupos opcionales
Lucas autorizó continuar las etapas, 2026-10-03. Enemy mide tiempo y emite solicitud; Game aplica LevelSession.steal, sin acceso del enemigo a economía global. Probabilidad por grupo y límite por EnemyData permiten nuevos encuentros sin codificar ids. No cambia el guardado ni se reemplazan enemigos existentes. Robo de un monto fijo al escapar descartado según el pedido. Balance6/7 de prueba; intensidad8/9 y diseño10–15 quedan para su creación.


## D-067 · Carga por geometría y desgaste sin destrucción
Lucas aprobó el extremo de la recta y la cercanía al camino. ChargeRules fusiona puntos colineales del recorrido; Enemy acumula preparación solo en esa recta y evalúa sus extremos al cruzarlos. WearRules conserva lógica pura; límite en BalanceConfig y cifras del impacto en EnemyData. Torres mantienen inversión/huella y se pueden reparar en T186. Alternativa futura registrada: vida/destrucción, reparación pagada, precios de reconstrucción, interfaz económica y rebalanceo; no activada en esta etapa.


## D-068 · Reparación automática y no acumulable
Lucas autorizó desgaste reparable y el rol del Mecánico. Tower consulta fuentes activas dentro de radio; repara con la mayor tasa en tiempo físico, sin trabajo global ni referencias persistentes. Tasas2/3/4 en TowerLevelData; no crea nueva economía, botones ni monedas. El daño del propio Mecánico reduce prestaciones para que el Embestidor tenga efecto real en toda torre; otro Mecánico puede restaurarlo. La alternativa de economía/reparación manual/destrucción queda anotada en D-067 y fuera de esta etapa. Costos actuales se mantienen como base para laboratorio6/7.


## D-069 · Lista acotada y selección rápida en Pruebas
Lucas, 2026-10-04, aprobó corregir recorte y sumar rueda conservando clic. Se mantiene OptionButton y PopupMenu nativo con máximo320 píxeles lógicos y scroll, fondo opaco y hover sin sombra exterior; no se reemplaza por otro sistema de listas. gui_input recibe la rueda solo sobre el selector, limita índice y consume el evento. B-31 registra los cuatro rediseños pedidos; usar Curandero como base de Embestidor se evaluará con muestras, no cambia arte en esta tarea.


## D-070 · Producción B-31 por familias de silueta
2026-10-04, autorizado por Lucas (“Dale avanza”). Embestidor toma anatomía del antiguo Curandero, cambia bulbo por armadura/frente de impacto; no se intercambian archivos sin adaptar identidad. Curandero nuevo erguido, con semilla medicinal en herramienta. Ciclos nativos 4×4 por distancia, sin deformaciones para fingir animación; Ladrón encapuchado con bolsa y Mecánico fijo renderizado sobre bases existentes. Generación integrada con imagegen, fuentes intactas y empaquetado en Godot; no cambia balance. B-31 sigue pendiente de revisión visual de Lucas antes de arte definitivo.


## D-071 · Aprobación visual B31 y entrega multiplataforma
2026-10-04, Lucas: “Excelente los apruebo. Podes generarme los dos exe y las apk?”. Aprueba los cuatro diseños M43, cierra B31 y autoriza generar Windows normal/pruebas y Android normal/pruebas con presets existentes. APK debug para instalación directa, con paquetes separados; comprobar integridad/firma y distinguir verificación estática de prueba física.

## D-072 · Laboratorio de balance6/7 con mejoras y ubicación
2026-10-04, Lucas autorizó avanzar con comparación de compra de Mecánico, colocación, mejoras y frecuencia de especiales. Comparar semillas iguales y estrategias explícitas antes de rebalancear. Variantes de frecuencia se aplican solo en memoria: evitar alterar niveles1–5 y preservar incertidumbre humana. La falta de impactos en bot no prueba falta de utilidad reparadora; medir también exposición/colocación cerca de extremos de rectas.

**D072, hallazgo del laboratorio:** pasos0.1s dejan residuos≈1e-14 en desgaste y el guard is_equal_approx impedía asignar0. Corregir terminal sin introducir umbral de balance: aplicar is_zero_approx y permitir transición positiva→0 aunque la variación sea aproximada. Verificar señal/tasa e indicador.

**D072, reproducibilidad:** fijar el RNG global antes de instanciar Game además del spawner (D047). Descartar exploraciones sin esa condición. Usar física60Hz y APPDATA independiente; comparar controles de misma semilla y repetir un caso. Las ablaciones modifican también recompensas/tiempos y no demuestran causalidad aislada. DPS nominal es proxy de ubicación, no potencia total.

**D072, conclusión:** conservar costos/aura/tasas y frecuencia6/7.38 corridas reproducibles más repetición idéntica. Nivel6 con mejoras termina20 vidas en tres semillas; Mecánico temprano pierde con semilla42. En7, apoyo tardío por cantidad con mejoras termina18–19 frente a7–10 sin apoyo en esos perfiles. Presión reforzada permite impactos y reparación natural, pero cambia recompensas/compras y no tiene efecto monotónico en vidas: no adoptar esa frecuencia automáticamente. Diseñar8/9 con posiciones expuestas y margen económico. B22 permanece abierto; balance humano pendiente. Evidencia completa art/balance-m44.

## D-073 · Producción de campaña8/9
2026-10-04. Lucas autoriza continuar8/9 y excluye regenerar APK/EXE. Respetar debut Guardián8/Curandero9 ya aprobado en D041; encuentros después de preparación, separados antes de combinarse.8 concentra enseñanza en una entrada;9 combina dos entradas y auras. Reutilizar sistemas/assets actuales y mantener datos1–7/globales. El Mecánico sigue opcional, con permiso8/9 y cinco avances persistentes. Ajustar solo mapas/oleadas/economía local si las comparaciones lo justifican; no extrapolar frecuencia reforzada M44 como receta.

**D073, compatibilidad:** el antiguo último nivel no guardaba desbloqueo del siguiente inexistente. GameFlow consulta victoria del nivel anterior además de la marca explícita. Inferencia solo de acceso, sin migración ni escritura del guardado y sin adelantar más de una posición.

**D073, calibración:** exploración22% terminó con20 vidas en8/9.40% vuelve8 demasiado exigente para el perfil de apoyo: primera versión final8=32%,9=40%. El bot se amplía solo en el laboratorio para considerar cobertura aérea al mejorar; conserva controles anteriores. Un encuentro con la oleada8 oficial, torre expuesta y apoyo legal demuestra40 puntos recibidos/reparados sin forzar el efecto; la ubicación por daño del bot puede no cubrir extremos. No imponer compra del apoyo como condición de victoria ni extrapolar ese encuentro mínimo a balance humano.

**D073, resultado:**24 corridas finales más repetición idéntica;8 ganador en todos los perfiles,9 con control variado gana11 vidas y compra tardía por daño8 en tres semillas. La heurística de mejoras puede perder; no es optimización ni prueba humana. Oleada8 oficial con defensa mínima expuesta causa/repara40 puntos en ambos mapas, sin forzar efectos. Configuración32%/40% aceptada como primera versión automatizada, pendiente validación jugando. No crear10–15 ni regenerar paquetes en esta tarea.

## D-074 · Estudio de vista B-21 v2: método y recomendación
2026-10-06. **Estado: recomendación de Claude, decisión pendiente de Lucas.** Lucas pidió revisar B-21 con un análisis y pruebas nuevos, y considerar también no aplicarlo. El estudio de M36 no alcanzaba para decidir: sus muestras no tenían monstruos, HUD ni vista previa, la "oblicua" era un paralelogramo y la "3D" un plano girado en diagonal, y los costos no se habían medido.

**D074, método:** las cuatro vistas se arman sobre la partida real (`game.tscn`), con la misma escena, y solo cambia la presentación. A es la actual. B es el relieve dibujado en la misma cuadrícula, con orden por profundidad. C suma una cámara Camera2D con zoom (1; 0,8) y endereza lo que está de pie. D es una maqueta 3D con la lógica 2D oculta copiada en cada cuadro. Se mide tamaño de casilla, superficie, 615 clics de ida y vuelta y rendimiento con la carga de P7 en tres rondas, con un control que oculta los actores 2D. Cada vista además se puede jugar. El relieve se mide también "horneado" en una textura, porque así sería en producción.

**D074, recomendación:** no cambiar la proyección. Si se quiere más profundidad, B por etapas: (1) orden por profundidad y decoración como objetos, con capa superior para barras, coronas e íconos; (2) relieve horneado en la Pradera; (3) los otros temas y los suelos de la leyenda. Así cuesta lo mismo que A (92 contra 92 FPS) y no rompe mapas, clics ni guardados.
- **C (oblicua):** queda condicionada a que Lucas la prefiera. Cuesta B más 5 a 8 días, achica la casilla a 64 × 51 px y deja el tablero en el 80 % del área. Va en un PR *breaking change*.
- **D (3D real):** descartada para este juego. Son 4 a 8 semanas de una capa de presentación nueva, la casilla del fondo baja a 53 × 38 px, el tablero ocupa el 66 % y el celular es incierto. Su número de rendimiento no es comparable: omite casi todos los detalles por enemigo.
- **A (no cambiar):** es una alternativa válida que libera tiempo para B-22.

Nada de esto se integra sin la elección de Lucas. Evidencia en `art/b21-vista/`.

## D-075 · El 3D va a una segunda entrega: Monsters & Canons 3D
2026-10-07, **decisión de Lucas.** Después de ver el análisis v2 de B-21, la maqueta 3D le pareció la mejor, pero exige adaptar o rehacer los dibujos y repensar el espacio: en 3D no tiene sentido un mapa en forma de laberinto plano. Por eso el 3D no se integra en la V1 y pasa a una segunda entrega, *Monsters & Canons 3D*, que conserva lo de la V1 y sirve de campo de pruebas antes de una eventual *Monsters & Canons 2*. Esa segunda entrega tendrá dos desarrollos, PC (preferido) y celular (Lucas es desarrollador mobile), y cámara no fija. **Antes de empezarla se termina todo lo pendiente de la V1**, que tampoco tiene que ser perfecta: también es campo de pruebas.

**D075, alternativas descartadas:**
- **Convertir la V1 al 3D:** son 4 a 8 semanas de una presentación nueva sobre mapas pensados para 2D, y se pierde legibilidad en el celular.
- **Adoptar el relieve (B) o la oblicua (C) en la V1 como sustituto del 3D:** no conforma la sensación buscada.
- **Planificar ya M&C 2:** es demasiado lejano.

**D075, propuestas de Claude, para que Lucas las confirme ítem por ítem:**
- Un solo proyecto con dos productos (PC y celular) en lugar de dos proyectos.
- Cámara de estratega con giro de ±30° mientras se usen los dibujos actuales; el giro de 360° pide modelos (prueba de cámara de T194).
- Arte por etapas: terreno y decoración, después torres (rígidas, fáciles en 3D) y por último monstruos.
- Escribir el lore en la V1 (B-03).
- Probar en 2D la colina de B-08 y los puentes de B-09.
- Cerrar la V1 en un orden en el que lo que cambia el balance va antes de los niveles 10–15.

La etapa 1 del relieve (orden por profundidad) queda como opcional en la V1. Documento: `specs/06-monsters-canons-3d.md`.

## D-076 · Épocas pasa al otro juego y la V1 se regala
2026-10-07, **decisión de Lucas.**
- **Épocas (B-01)**, con sus imperios reales, torres y monstruos por época, **no se hace en la V1**: pasa al backlog de *Monsters & Canons 3D* o de *M&C 2* (`specs/06-monsters-canons-3d.md` §15, entrada 3D-01). Viaja con todo lo ya decidido: es un modo aparte, con imperios reales representados con respeto.
- **Los modos (B-05)** se prueban en chico en la V1, unificados con el gestor de mapas.
- **La V1 se va a regalar.** Por eso Lucas propone llevar el modo de pruebas a Opciones y unificar ejecutables y APK (B-13).
- **Estado de la V1:** Lucas informó que ya probó la APK en su celular. El lore (B-03) lo está trabajando con otro agente.

**D076, alternativas descartadas:**
- Hacer Épocas completo en la V1: es casi un juego nuevo.
- Hacer en la V1 una rebanada de Épocas: Lucas prefiere probar los modos con algo más chico.

**Pendiente:** el diseño de la prueba de modos y del modo de pruebas en Opciones son propuestas de Claude; no se implementan hasta el OK de Lucas.

## D-077 · Modo de pruebas en Opciones, una sola app y licencia GPL
- **Fecha:** 2026-10-07 · **Estado:** Aceptada · **Decidió:** Lucas (qué) / Claude (cómo)
- **Qué:**
  - El modo de pruebas se activa desde Opciones en el menú principal, con confirmación, y se desactiva desde el mismo lugar (RF-383, RF-384).
  - El juego siempre arranca normal; `--pruebas` al iniciar se conserva para desarrollo (RF-385).
  - Un solo ejecutable o APK por plataforma (RF-386).
  - Licencia GPL-3.0-or-later (RF-387).
  - Reemplaza la parte "ejecutable aparte" de D-028. Se mantiene el guardado aparte, que es lo que protege el progreso y los récords reales.
- **Por qué:**
  - El juego se regala y es de un solo jugador: esconder las herramientas no protege nada (D-028 ya lo decía) y duplicaba exportaciones, presets y paquetes de Android.
  - Arrancar siempre normal evita que alguien abra el juego, vea el guardado de pruebas y crea que perdió su progreso.
  - La sección no aparece en la pausa para no cambiar de guardado en medio de una partida.
- **Licencia:**
  - Lucas pidió "tipo GNU 3.0". Se usa "versión 3 o posterior", que es el aviso que recomienda la FSF; si se prefiere "solo versión 3", es un cambio de una línea.
  - Cubre todo lo propio del proyecto. Lucas tiene los derechos de su obra, así que podría relicenciarla más adelante.
  - Componentes de terceros: el motor **Godot** es MIT y su aviso tiene que acompañar a los ejecutables (va en la Wiki); **GUT** es MIT y solo se usa en desarrollo (se excluye de las exportaciones).
  - **Consecuencia:** quien reparte ejecutables bajo GPL tiene que ofrecer también el código fuente. El repositorio de GitHub hoy es privado, así que antes de publicar hay que hacerlo público o adjuntar el código.
- **Alternativas descartadas:**
  - Recordar el modo de pruebas entre sesiones: confunde, porque parece que se perdió el progreso.
  - Combinación secreta de teclas: ya descartada en D-028.
  - Licencias permisivas (MIT, Apache): Lucas eligió GPL.
  - Separar arte y sonido con Creative Commons: suma complejidad sin pedido.

## D-078 · Modos como paquetes de datos unificados con el gestor de mapas
- **Fecha:** 2026-10-07 · **Estado:** Aceptada, hecha en T197 · **Decidió:** Lucas (prueba chica de modos, unificada con el gestor de mapas) / Claude (diseño)
- **Qué:** un modo es una carpeta con `modo.json` y mapas JSON; los oficiales en `data/modos/` y los propios en `user://modos/`. La selección de nivel muestra Campaña, modos oficiales, Comunidad y modos propios. El progreso va por modo, y el editor puede guardar mapas dentro de un modo propio. El modo oficial de prueba es "Asedio" (RF-388 a RF-392), con vida 115 % según el bot (T197).
- **Por qué:**
  - Un modo y un mapa de la comunidad son el mismo concepto en distinto tamaño, así que comparten carga, validación, progreso y editor.
  - Asedio no necesita arte ni reglas nuevas y cubre los niveles difíciles de B-10.
  - El formato sirve después para los mods completos (B-04) y para Épocas en el otro juego (3D-01).
- **Alternativas descartadas:**
  - Modos como una lista más en `campaign.json`: no une con la comunidad ni con el editor.
  - Modos con torres y monstruos propios desde ya: eso es B-04 y agranda la prueba.

**D078, ajustes de T197:**
- **Mapas reusados:** un mapa de un modo se busca primero en su carpeta y después entre los niveles oficiales, así Asedio no copia los nueve niveles.
- **Editor:** "Guardar" no cambió (así siguen valiendo sus tests y la costumbre); el destino se elige con la acción nueva "En un modo…".
- **Balance de Asedio, con el bot `mix`:**
  - Con vida 150 % y oro 80 % perdía en la oleada 4 de los mapas 1 a 3; con 125 % y el mismo oro también perdía temprano. Con reglas neutras da exactamente lo mismo que la campaña, oleada por oleada, así que el camino del modo está bien.
  - Valor elegido: **vida 115 %, el mismo oro**. Gana los mapas 1, 3 y 5 con 3, 6 y 4 vidas; en la campaña gana 8 de 9.
  - Es un modo claramente más difícil. Este bot es simple, así que hace falta una prueba jugando; 110 % es la alternativa si resulta demasiado.
- **Limitación conocida:** con más de dos modos propios, las solapas no entran en la fila de 1280 px.

**Revisada por D-095 (T256, 2026-10-10):** el esquema del modo gana una tabla opcional de porcentajes de vida por mapa y Asedio pasa a los 15 mapas. Lo de arriba (nueve niveles, 115 % uniforme) **queda como historial** de T197.

## D-079 · Torres por mapa: lista de las que se ofrecen
- **Fecha:** 2026-10-08 · **Estado:** Aceptada, hecha en T203 · **Decidió:** Lucas (Q-29 y Q-30 del cuestionario 09) / Claude (formato)
- **Qué:** el nivel gana el campo opcional `"torres"` con la lista de las torres que ofrece; la tarjeta de la selección muestra sus íconos y marca "Nueva" donde una torre debuta. Con un modo, vale la intersección. Detalle en RF-393 a RF-397.
- **Por qué:**
  - El 07 §4 dice que la rotación de torres va **por datos del mapa** y que **no hay pantalla de mazo**: el jugador no arma nada, el mapa decide.
  - Una lista de las que **se ofrecen** se lee de un vistazo (qué hay en este mapa) y se escribe igual que `"torres"` de los modos (RF-388), así que el formato y la validación se copian.
  - Sin el campo todo queda como hoy: los 9 niveles actuales no cambian.
  - "Nueva" se calcula desde los datos y no se guarda, así no hay nada que migrar ni que se desincronice.
- **Alternativas descartadas:**
  - Una lista de torres **a quitar** (`"sin_torres"`): hay que saber cuáles son las comunes para entender qué queda, y si mañana se suma una torre común, entra sola en todos los mapas sin que nadie lo decida.
  - Una pantalla de mazo antes del nivel: el 07 §4 la descarta.
  - Guardar en el guardado qué torres "ya vio" el jugador: complica el guardado y deja de ser un dato del contenido.

## D-080 · Removibles y puntos de extracción: se declaran en la leyenda del mapa
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-398 a RF-403), a la espera del OK de Lucas (G3) · **Decidió:** Lucas (Q-09, Q-17, Q-19, Q-31 y Q-38 del cuestionario 09) / Claude (formato)
- **Qué:** un removible o un punto de extracción es una **letra de la leyenda** del mapa (RF-262) que lleva `"removible"` o `"extraccion"` con su `clase`. Los números de cada clase (costo, tiempo, recursos, probabilidad, producción, reserva) están en `data/obstaculos.json` y la letra puede sobrescribirlos. Intacto es una casilla bloqueada, despejado es pasto construible, y **nunca es camino**.
- **Por qué:**
  - La leyenda ya es el lugar donde un mapa dice "esta letra se dibuja así y se construye o no" (RF-262 a RF-265). Extenderla sirve al editor, a la comunidad y a los modos sin formato nuevo (Q-31), y mantiene el principio de que un mapa es solo datos (RF-204).
  - **Por clase, en datos** (Q-09): lo pidió Lucas, y es P2 (los números no van en el código). Que la letra pueda sobrescribir un valor deja ajustar un mapa sin tocar la clase.
  - Que **nunca sea camino** (RF-264, Q-17) deja intactos los recorridos, el cálculo de RF-202 y el bot: despejar solo abre casillas laterales. No hay atajos.
  - `dibujo` opcional evita que el mapa se contradiga (una `clase: roca` con `dibujo: arbol`).
- **Alternativas descartadas:**
  - **Un campo aparte** (`"obstaculos": [{"fila": 2, "columna": 5, …}]`): hay que mantenerlo sincronizado con el mapa de letras y el editor tendría que pintar en dos lugares.
  - **Un solo archivo de datos sin sobrescritura**: obliga a clases nuevas para cada ajuste de un mapa.
  - **Subir el tope de 10 letras ya**: no hace falta todavía; se decide en la tarea del nivel que se pase (punto 6 de "Para revisar en G3").
  - **Que despejar vuelva la casilla camino**: abre atajos y rutas dinámicas, que la V1 no incluye (07 §5).

## D-081 · Demolición directa: se cobra al ordenar, tarda en tiempo de juego, una a la vez
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-404 a RF-410), a la espera del OK de Lucas (G3) · **Decidió:** Lucas (Q-09 a Q-12 y Q-14 a Q-17, 2026-10-08) / Claude (detalle)
- **Qué:** tocar un removible abre un panel con costo, tiempo y recompensa; **Demoler** cobra el oro y empieza un trabajo que dura segundos de juego (pausa y velocidad respetadas). Hay uno solo a la vez y sin cola. Se puede cancelar con reembolso total. Al terminar se despeja la casilla y se entrega la recompensa **una sola vez**. Al terminar la oleada sigue; al terminar la partida se pierde.
- **Por qué:**
  - **Se cobra al ordenar** (Q-11): así nadie se queda sin oro a mitad de un trabajo, y cancelar devuelve todo; como la recompensa llega recién al final, no hay ganancia posible cancelando.
  - **El trabajo tarda tiempo de juego** (07 §5): la demolición es una **decisión de inversión** (oro ahora, casilla útil después), no un clic instantáneo. Tiene que respetar pausa y velocidad para no ser trampa ni frustrante, igual que el reloj del Ladrón (RF-363).
  - **Una sola a la vez y sin cola** (Q-15): lo acordado en el 07 y lo más simple; el panel dice por qué no se puede.
  - **Tocar el objeto** (Q-16) reusa la selección de torres, sin gestos nuevos (§11). Los removibles se marcan para no confundirlos con lo permanente.
  - **Solo se pierde al terminar la partida** (Q-14), porque se demuele en preparación y en las oleadas.
  - No es una "habilidad activa del jugador" (§11 la excluye): es una compra con espera, como construir.
- **Alternativas descartadas:**
  - **Cobrar al terminar:** se puede quedar sin oro a mitad de trabajo y hay que definir qué pasa.
  - **Cancelar con reembolso parcial o nulo:** castiga el error y complica; con el total no hay ganancia.
  - **Cola de órdenes o varias demoliciones a la vez:** más reglas y más interfaz sin pedido.
  - **Demolición instantánea:** no sería una decisión de inversión.
  - **Entregar la recompensa al ordenar:** sería ganancia al cancelar.

## D-082 · Demoledora: una compra global, sin venta, baja precio y un poco el tiempo
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-411 a RF-414), a la espera del OK de Lucas (G3); el valor del tiempo es provisional · **Decidió:** Lucas (Q-08, Q-10 ✎ y Q-13) / Claude (fórmulas)
- **Qué:** si el nivel dice `"demoledora": true`, el HUD tiene un botón "Infraestructura" donde se compra la máquina una vez (**180 de oro**). Desde ahí, cada demolición cuesta el 10 % (mínimo 5) y tarda el 80 % del tiempo. No se vende.
- **Por qué:**
  - **Botón global, no estructura** (Q-08): el descuento ya está acordado como global (07 §5), así que no tiene sentido que ocupe una casilla; evita construir un objeto más con vida, estado y arte propios.
  - **Sin venta** (Q-13): comprarla y venderla sería una forma de ganar plata.
  - **Precio 3 × una roca** (Q-13, 07 §5): convierte la decisión en un cálculo de amortización. Con los valores iniciales se paga sola desde 4 rocas, 6 árboles o 3 escombros (RF-414).
  - **También baja el tiempo** (Q-10 ✎): Lucas lo cambió respecto de la recomendación ("solo baja el precio"). Lo que no se pudo cerrar es **cuánto**: Lucas pidió fijarlo "con el bot", y como la demolición no existe, el bot no puede medirla. Se dejó **80 %** como valor provisional en datos y se revisa en T214 y T223. *Anotado como pendiente en "Para revisar en G3".*
  - **Un trabajo ya ordenado conserva su precio y su tiempo**: es más simple y justo; la diferencia no se reembolsa.
- **Alternativas descartadas:**
  - **Máquina como estructura en una casilla:** ocupa lugar, hay que dibujarla y animarla (07 pide que se vea el trabajo solo sobre el objeto) y no cambia el descuento.
  - **Descuento por radio local:** el 07 lo descarta.
  - **Máquina vendible con reembolso parcial:** abre ganancias y casos borde sin pedido.
  - **Que baje solo el precio (la recomendación original):** Lucas pidió que baje también el tiempo.

## D-083 · Recursos locales: un solo tipo, sin guardar, con drop al azar con semilla y torres que cuestan recursos
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-415 a RF-421 y RF-432 a RF-433), a la espera del OK de Lucas (G3); los números son iniciales · **Decidió:** Lucas (Q-18 ✎, Q-21 ✎, Q-22, Q-23, Q-24 y Q-07) / Claude (detalle)
- **Qué:**
  - Un recurso genérico, **local** a la partida (en `LevelSession`), que no se guarda ni da puntaje. El contador solo se ve en mapas **con fuentes**.
  - Los removibles entregan 1 recurso **con una probabilidad por clase** (50 % inicial), sorteada **al empezar la partida** con una semilla que el bot y los tests fijan. Es la única excepción a "sin sorteos".
  - `TowerData.resource_cost` (el **Mortero**, 300 + 3, debuta en el nivel 9) y `alt_gold_cost` / `alt_resource_cost` (el **Francotirador**: 150 de oro o 120 + 1 recurso). Mejorar no cuesta recursos y vender devuelve el 70 % redondeado hacia abajo.
  - **Regla de oro:** todo mapa de la campaña con recursos se gana con la estrategia `sin_recursos` (4 de 5 semillas).
- **Por qué:**
  - **Local y sin guardar** (07 §7, Q-24): evita acumular recursos varios niveles y una economía persistente.
  - **Desde el nivel 7 y al azar** (Q-18 ✎): Lucas quiso que la mecánica empiece antes del 10. Para que los recursos "tengan uso donde aparecen" (plan 08 §2.2), el Francotirador gana una forma de pago chica con recurso, y el Mortero ya cuesta recursos desde el 9.
  - **Sorteo fijado al empezar, no al terminar:** el resultado no depende del orden de demolición ni de cancelar y reordenar (nadie puede "tirar de nuevo"), y el bot compara estrategias sobre **la misma** partida. El jugador no ve el resultado hasta terminar, así que sigue habiendo sorpresa.
  - **Contador solo con fuentes:** con "torres que cuestan recursos" como criterio, aparecería en los niveles 1 a 6 por el Francotirador, donde no hay forma de conseguir recursos.
  - **Dos formas de pago a la vez** (Q-21 ✎): la de oro cuesta lo mismo que hoy, así que el Francotirador y los niveles 1 a 6 no cambian, y nunca es indispensable.
  - **Mejorar no cuesta recursos** (Q-22): menos reglas. **Vender devuelve con el mismo %** (Q-23): comprar y vender no da ganancia.
  - **Regla de oro** (07 §7, Q-07): es lo que garantiza que los recursos son "una estrategia más" y no un requisito encubierto; se mide con el bot y después con las partidas de Lucas.
- **Alternativas descartadas:**
  - **Sortear al terminar cada demolición:** depende del orden y de las cancelaciones, y el bot no compara bien las estrategias.
  - **Una semilla escrita en el archivo del mapa:** el resultado sería siempre el mismo y desaparecería el azar que pidió Lucas (punto 2 de "Para revisar en G3").
  - **Recursos con costo en las mejoras** (Q-22) y **que sobrantes den puntaje** (Q-24): más reglas, y el puntaje cambiaría.
  - **Varias monedas** (madera, piedra): el 07 pide un recurso genérico.
  - **Que el recurso empiece en el 10** (la recomendación original): Lucas lo adelantó al 7.
  - **Que el mapa decida si "usa recursos" con una bandera propia:** se deduce de las fuentes, sin otro campo que mantener.

## D-084 · Extracción finita: se habilita con oro y produce al completar oleadas hasta agotar la reserva
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-422 a RF-424), a la espera del OK de Lucas (G3) · **Decidió:** Lucas (Q-19 y Q-20) / Claude (detalle)
- **Qué:** una mina o un bosque explotable se habilita pagando **100 de oro** tocándolo como un removible, produce **2 recursos por oleada completada** hasta agotar una **reserva de 8**, y no produce por esperar. No hay límite de puntos activos. Mina y bosque funcionan igual; cambia el dibujo.
- **Por qué:**
  - **Pagar oro para habilitar** (07 §6): la extracción es una **inversión** que hay que recuperar con las oleadas.
  - **Solo por oleada completada** (07 §6): evita generar recursos esperando y repitiendo; la **reserva finita** evita que la economía crezca sin tope.
  - **Sin límite de puntos** (Q-20): lo limita el oro; es lo más simple.
  - **Que cuente la oleada en curso:** habilitar en medio de una oleada ya aprovecha su final; no se pidió algo más estricto y cuesta menos explicarlo ("produce cada oleada que se completa mientras está activa").
  - **No la abarata la demoledora:** no es una demolición.
  - Con los valores iniciales, 100 de oro compran 8 recursos; si **no se recupera** frente al valor de lo que se compra con ellos, es un dato para el balance (T214), no un error de la regla.
- **Alternativas descartadas:**
  - **Producción por tiempo:** premia esperar y deja de ser una decisión.
  - **Límite de puntos activos o de extracción simultánea:** más reglas, y el oro ya lo limita.
  - **Reserva infinita o que se recupera:** rompe "finito" (07 §6).
  - **Que la producción empiece con la oleada siguiente:** más estricta pero más difícil de explicar (punto 5 de "Para revisar en G3").

## D-085 · Colecciones por tecnología: varias en `progression.json`, con pieza en una ruina
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-425 a RF-431), a la espera del OK de Lucas (G3) · **Decidió:** Lucas (Q-25 a Q-27 y Q-31) / Claude (formato)
- **Qué:** `progression.json` admite **varias colecciones**; cada una dice cuántas piezas necesita y qué niveles son su fuente. La nueva, `disruptor`, tiene 3 piezas fijas, una en una ruina de los niveles **8, 9 y 10**. Una pieza se **recoge** al terminar la demolición de la ruina y se **confirma** como los avances actuales (RF-359). Una ruina ya recuperada da 1 recurso si el mapa tiene recursos. **Solo en la campaña.**
- **Por qué:**
  - **Mismas reglas que los avances de hoy** (Q-26): una sola idea de "recogido, pendiente y confirmado" para el jugador, y el código de M37 se reutiliza.
  - **Guardado igual que hoy:** la pieza es el id del nivel dentro de la lista de su colección. No cambia la versión del guardado, un guardado viejo carga igual, y una versión anterior del juego que lea uno nuevo ignora la colección que no conoce (aunque al volver a guardar la descartaría).
  - **`technology` queda idéntica**: el `origen` por omisión es `"portador"`, y los tests de M37 y M38 siguen valiendo sin tocarlos.
  - **Pieza fija y garantizada, sin sorteos** (Q-27, 07 §8): nadie tiene que repetir un mapa por suerte; la identidad única evita duplicados por repetir la ruina.
  - **Solo campaña** (Q-31, RF-358): los mapas de la comunidad o un editor no pueden "fabricar" piezas.
  - **La ruina ya recuperada da 1 recurso** (Q-27) para que repetir un mapa tenga algún sentido sin dar piezas repetidas.
- **Alternativas descartadas:**
  - **Una pieza por enemigo portador** (como los 5 avances): no sirve para una ruina que se demuele.
  - **Piezas sorteadas** o un 2.º hallazgo por ruina: lo descarta Q-27.
  - **Un guardado nuevo con versión 2:** migraciones y riesgo sin necesidad.
  - **Que la comunidad pueda dar piezas:** se podrían fabricar.
  - **Un id global distinto del nivel:** hoy una pieza por colección y nivel alcanza (RF-426); si hiciera falta más de una, se cambia con una `D` nueva.

## D-086 · Disruptora: una torre de pulso que apaga el aura de los emisores, no una segunda Eléctrica
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-438 a RF-452), a la espera de que Lucas revise los puntos de "Para revisar" de M51 · **Decidió:** Lucas (Q-33 y 07 §9) / Claude (detalle)
- **Qué:** la Disruptora (bobina Tesla, pedido de Lucas) emite cada 4 s un **pulso** en un radio de 2,5 casillas (3 y 3,5 al mejorar). Los enemigos **con aura** (Guardián, Curandero y cualquiera con `has_aura()`) que el pulso alcanza **no emiten su aura** durante 2,5 s (3 y 3,5 al mejorar). Todos los alcanzados reciben 5 de daño. Cuesta 130 de oro + 2 recursos y pide la colección `disruptor`. **Solo apaga auras:** ninguna otra habilidad enemiga.
- **Por qué:**
  - **Suprimir al que emite** (y no cortar el efecto en el que lo recibe): el aura ya tiene una vida corta (0,35 s, D-042), así que dejar de emitir la apaga **en menos de medio segundo** sin tocar el código de los receptores, y sigue la frase de Lucas en Q-33 ("pierden su aura 2,5 s"). Es un estado más del enemigo, como la ralentización o la quemadura, y se muestra igual (RF-449).
  - **Es otra cosa que la Eléctrica** (la torre con la que más se parece por el aspecto de bobina): la **Eléctrica** pega fuerte a varios con un rayo y es la respuesta al **grupo**; la **Disruptora** casi no daña (≈13 % del daño por segundo de la Eléctrica de nivel 1) y es la respuesta a **la ayuda** que dan el Guardián y el Curandero. Sin ella, la contramedida era "matarlos primero" (D-041); con ella hay una segunda, que además **combina** con el resto (el Mecánico la acelera, el Hielo y el Cañón rematan). No hay forma de que la Disruptora reemplace a la Eléctrica ni al revés.
  - **Frente al Aislador** (relegado en 07 §9): el 07 solo lo llama "defensivo preventivo" y dice que Lucas lo encontró parecido al Disruptor; **no tiene reglas escritas**. Se lo dejó de lado para no tener dos torres que hacen casi lo mismo, y la Disruptora es la que quedó con reglas concretas (Q-33): actúa **sobre los enemigos con aura, durante la oleada** y se paga con una colección. No se comparan más detalles porque no hay de dónde sacarlos.
  - **Un ritmo con huecos a propósito** (cobertura 62,5 % a 87,5 %): una torre que apaga un aura **para siempre** haría inútiles al Guardián y al Curandero, y los niveles que los usan perderían sentido. Cubrirlo todo pide invertir (nivel 3 + Mecánico o dos Disruptoras, RF-445).
  - **Daño bajo a todos** (Q-33): el pulso no es un efecto sin cuerpo; el daño es tan chico que no compite con las demás torres, pero termina a los enemigos débiles que ya venían heridos.
  - **Los números son de Lucas** (Q-33). Lo que Q-33 no fija (el costo en oro de mejorar) quedó como **valor inicial** y se ajusta con el bot.
- **Alternativas descartadas:**
  - **Suprimir todas las habilidades enemigas:** 07 §9 dice que no se da por aprobado; Q-33 descartó al Chamán, al Espejo y a otras habilidades. Una torre que apaga todo es una respuesta única a todos los enemigos especiales.
  - **Cortar el aura ya recibida en el receptor:** toca RF-271 y RF-272 (M17) para ganar menos de 0,35 s (RF-443).
  - **Una zona que apaga auras mientras el emisor está adentro:** pide una entidad persistente, estados que entran y salen y más dibujos; Q-33 describe un estado de segundos, no una zona.
  - **Más daño y menos supresión** (una Eléctrica con un extra): 07 §9 pide una torre que "interrumpe" con "poco daño directo", y con más daño se parecería a la Eléctrica.
  - **Una torre pasiva o un aura propia:** la distinguiría menos del Mecánico (apoyo) y no tendría el ritmo de pulsos.
  - **Que dispare un proyectil al emisor:** reabre reglas de proyectiles, bloqueos y el Espejo; el pulso en área es más simple y se lee mejor.

## D-087 · Disruptora: reglas de borde (espera a un emisor, el Espejo queda fuera, lo recibido no se corta)
- **Fecha:** 2026-10-08 · **Estado:** Aceptada en la spec (RF-440, RF-443, RF-444, RF-445 y RF-448), a la espera de que Lucas revise los puntos 1, 3, 4 y 5 de "Para revisar" de M51 · **Decidió:** Claude (detalle) sobre lo que dijo Lucas en Q-33
- **Qué:**
  - **Cuándo pulsa:** cuando está lista **y** hay al menos un emisor de aura a su alcance. Sin emisor no pulsa ni gasta su espera.
  - **Quién queda fuera:** el **Espejo** (por su dato `reflect_range_tiles`, no por el nombre) no recibe nada del pulso, y por eso no hay rebote. El Chamán, el Ladrón y el Embestidor reciben el golpe de daño bajo pero **conservan su habilidad**.
  - **Lo ya recibido** del aura no se corta: caduca solo (0,35 s).
  - **Las otras torres:** el Chamán la aturde como a cualquiera; el desgaste del Embestidor y el Mecánico cambian su cadencia como en todas las torres; la barra sigue el orden canónico y la Disruptora es la décima.
- **Por qué:**
  - **Esperar un emisor:** los pulsos de 4 s son escasos; gastarlos con cualquier enemigo los pierde justo cuando aparece el Guardián. También la separa de la Eléctrica (D-086).
  - **El Espejo:** RF-284 dice que **todo** golpe de torre que lo alcanza rebota, incluidos los de área. Si el pulso lo tocara, la Disruptora quedaría aturdida, lo que contradice Q-33 ("no afecta al Espejo"). Dejarlo fuera **sin tocar RF-284** es lo más chico: ningún RF existente cambia y los proyectiles siguen rebotando como siempre.
  - **El Chamán, el Ladrón y el Embestidor reciben el golpe:** Q-33 habla de **habilidades**, no de inmunidad. Recibir 5 de daño no cambia lo que hacen. Si Lucas prefiere que no los toque en nada, es un cambio chico (punto 1 de "Para revisar").
  - **Lo ya recibido no se corta:** el aura caduca en 0,35 s (RF-273); cortarla antes exigiría tocar a los receptores (D-086).
  - **La décima torre:** la barra y las teclas llegan a 9 (RF-297). No se agrega una tecla nueva en esta etapa; los niveles del bloque 3 eligen qué ofrecen (RF-393).
- **Alternativas descartadas:**
  - **Pulsar siempre que haya cualquier enemigo:** más "viva" a la vista, pero deja huecos (punto 3 de "Para revisar").
  - **Que el pulso rebote en el Espejo o lo aturda:** contradice Q-33.
  - **Que el pulso no toque al Chamán, al Ladrón ni al Embestidor:** posible (punto 1 de "Para revisar"); queda como alternativa de un cambio chico.
  - **Excluir al Espejo por su `id`:** rompe el principio de que todo son datos (RF-164); con `reflect_range_tiles` un enemigo nuevo con rebote queda fuera solo.
  - **Una tecla `0` para la décima torre:** cambia el HUD y el mapa de teclas (RF-297); no hace falta si cada nivel ofrece 9.

## D-088 · La barra de abajo con pestañas por tipo (Cañones e Infraestructura) y una flecha al menú principal
- **Fecha:** 2026-10-08 · **Estado:** **Aprobada por Lucas el 2026-10-08** (preguntas P1 a P8 de M53, todas con la recomendación de cada una: pestañas por datos del mapa, teclas `1`–`9` más `0` y `Tab`, cuatro tarjetas en «Infraestructura», la flecha «← Menú» en todos los niveles con confirmación, el menú de pausa sin tocar); programada en T248 · **Decidió:** Lucas (el pedido y las dos pestañas) / Claude (el detalle: medidas, teclas, textos y recomendaciones de las preguntas P1 a P8)
- **Qué:**
  - Los niveles que **usan infraestructura** (demoledora, removibles o extracción; hoy del 6 al 10) tienen una barra con **dos pestañas**: **«Cañones»** (las torres de hoy) e **«Infraestructura»** (trabajo en curso, demoledora, extracción y recursos). Los niveles 1 a 5 no cambian.
  - Las teclas: `1`–`9` para las torres 1 a 9, **`0` para la décima** y **`Tab`** para cambiar de pestaña. Los botones de torre se achican (de 76 a 56 px como mínimo) para que entren hasta 11.
  - El botón y el panel «Infraestructura» de arriba a la derecha **desaparecen**: la pestaña es el único lugar. Tocar un objeto del mapa **funciona igual** que hoy, en cualquier pestaña, y no cambia la pestaña sola.
  - Una **flecha «← Menú»** arriba a la izquierda, en todos los niveles, que **pide confirmación** y dice qué se pierde (las piezas de colección de la partida, aunque estén confirmadas, y la demolición en curso). El menú de pausa **no cambia**.
- **Por qué:**
  - **Hace falta lugar y no hay:** con el Mecánico, el Mortero y la Disruptora hay hasta 11 torres y las teclas llegan al 9. Seguir apretando botones en una sola fila no escala; una pestaña por tipo sí: una torre o herramienta nueva de otro tipo es **una pestaña nueva**, no un rediseño (Lucas: «poder sumar más torres y herramientas en la misma barra»).
  - **Todo lo de infraestructura en un solo lugar:** hoy el panel de la demoledora cae, por las coordenadas del código, encima de Pausa y Velocidad; el trabajo en curso solo se ve tocando el objeto; y la extracción solo se ve tocando la mina. La pestaña reúne el estado del trabajo, la compra y la extracción con las **mismas** reglas y los mismos controladores (nada de lógica nueva).
  - **Por datos y no por número de nivel:** para la campaña da lo mismo que «a partir del 6», pero un mapa de la comunidad o de un modo con demolición tiene el mismo problema y la misma solución; y los niveles 1 a 5 quedan intactos porque no tienen ningún dato de infraestructura.
  - **`0` para la décima:** es la continuación natural de la fila de números y no pide una tecla nueva que memorizar. **`Tab`** no choca con ninguna tecla de la partida y es la tecla que se espera para cambiar de pestaña. La torre 11 queda sin tecla, como hoy la décima: se elige con el mouse o el dedo, y todo lo de este bloque se puede hacer sin teclado (celular).
  - **La pestaña no cambia sola:** quien está construyendo toca rocas sin querer; sacarlo de su barra de torres cada vez molesta más de lo que ayuda. Para no perder de vista el trabajo, la pestaña muestra el tiempo que falta.
  - **La flecha siempre pregunta:** abandonar descarta las piezas de colección de la partida **aunque ya estén confirmadas** (se guardan recién al mostrar el resultado, RF-359 y RF-427), y eso se descubre tarde. La flecha queda cerca de Pausa y Velocidad, así que un toque de más no tiene que costar una pieza.
  - **El menú de pausa queda como está:** no se pidió cambiarlo. Que sus dos botones también confirmen es una idea mía, anotada en §13 y como pregunta P7.
- **Alternativas descartadas:**
  - **Una segunda fila de botones debajo o encima de la actual:** la barra mide 96 px y lo de arriba es el mapa; una fila más le quita alto al área del mapa (de 48 a 624 px, RF-251) y obliga a achicar el zoom de los mapas grandes.
  - **Desplazar la barra de torres de costado o pasar de página con flechas:** funciona con mouse pero en el celular pide arrastrar (gestos, §11) y esconde torres; las pestañas muestran todas las de su tipo a la vez.
  - **Dejar el panel «Infraestructura» arriba a la derecha y sumar solo la fila de torres con más teclas:** no resuelve el panel pegado arriba ni la compra de la demoledora y la extracción en un solo lugar.
  - **Menú radial o ventana emergente de torres:** más tocadas por construcción; la barra fija es lo que el juego ya enseña.
  - **«Nivel ≥ 6» como regla de aparición:** deja sin pestañas a mapas con demolición que no son de la campaña, y obliga a tocar código cada vez que cambie la lista de niveles.
  - **Pestañas que se abren solas al tocar un objeto:** deja el estado a la vista pero saca al jugador de su barra de torres (decide Lucas, P4).
  - **Teclas `Q`/`E` o `C`/`I` para las pestañas:** son posibles (pregunta P2); `Tab` quedó porque no se pisa con nada y vale igual con dos pestañas o con cinco.
  - **Una tecla propia para la flecha:** se descarta a propósito: salir del juego no debe estar a un `Espacio` de distancia.
  - **Que la flecha abra el menú de pausa:** duplica `Esc` y no sirve para el caso de salir de una vez; el menú de pausa sigue donde estaba.
  - **Guardar la última pestaña usada:** un guardado más sin ganancia; arrancar siempre en «Cañones» es lo previsible.

- **Ajustes al programarla (T248, 2026-10-08)** *(no cambian lo decidido; salieron de medir en una ventana real)*:
  - «Infraestructura» a 13 pt no entra en 96 px (mide 96): las pestañas usan 12 pt con 3 px de margen. Los botones de torre miden 71, 63 y 57 px con 9, 10 y 11 torres, como la cuenta; el costo y la insignia de la segunda forma de pago se achican en los botones angostos (RF-455).
  - Sin pestañas y con 10 o más torres (mapa de la comunidad o de un modo) los botones miden 73 y 66 px: la spec dejaba «siempre 76» en una frase y «se achican» en otra, y a 76 la décima tapaba «Próxima oleada» (RF-454).
  - `Tab` se atiende en `_input` y no en `_unhandled_input`: los íconos de arriba aceptan el foco del teclado y, con uno enfocado, el motor se quedaba `Tab` para mover el foco. Probado con un ícono enfocado en la ventana real.
  - El nivel 6 no tiene demoledora (solo el 7): la tarjeta de la demoledora no se dibuja en el 6.
## D-089 · Se enmienda §11: entran los textos breves, el Lore de la Wiki, el epílogo y la intro; siguen fuera los diálogos, las cinemáticas animadas y las voces
- **Fecha:** 2026-10-08 · **Estado:** Aprobada por Lucas (la enmienda, Q-01) · **Decidió:** Lucas (la enmienda y sus límites, respuesta **Q-01 ✔** del cuestionario `09-decisiones-pendientes-v1.md`, el 2026-10-08) / Claude (el texto de la enmienda y de su nota en §11)
- **Cita de la respuesta de Lucas (Q-01):** *«Sí, de forma acotada. Se permiten textos breves por nivel (entrada de hasta 3 líneas y victoria de hasta 2), una categoría Lore en la Wiki, un epílogo en la victoria del 15 y una intro de láminas que se pueda omitir y volver a ver. Siguen excluidos: diálogos entre personajes, cinemáticas animadas y voces.»* (respondida con ✔: Lucas aceptó la recomendación tal cual).
- **Qué:**
  - En §11 («Qué NO incluye este juego»), la línea «Historia, diálogos o cinemáticas» pasa a **«Diálogos entre personajes, cinemáticas animadas y voces»**, con una nota que manda a **M52** (`01-spec.md`) y a `specs/11-textos-lore.md`.
  - Lo que entra queda acotado por M52: un campo opcional `"textos"` por nivel (lugar, entrada de hasta 3 líneas, victoria de hasta 2, y un epílogo de 3 a 5 líneas solo en el último nivel), una categoría **Lore** en la Wiki y créditos. La **intro de láminas** también queda permitida, pero su spec es de T240 y todavía no existe.
- **Por qué:**
  - El 07 pide que la victoria muestre el logro y su costo, y que las explicaciones esenciales estén **dentro del juego**. Sin textos no hay dónde decirlo, y la constitución (P4) pide enmendar §11 **antes** de agregar algo que figura como excluido.
  - Se mantiene excluido lo que cambiaría el tipo de juego: personajes que hablan, escenas animadas y voces piden guion, animación y actores, y no hacen falta para un cierre ambiguo y sobrio (biblia §8).
- **Alternativas descartadas:**
  - **No enmendar §11 y contar todo con las señales del terreno:** el 07 §12 pide explicaciones esenciales dentro del juego; las señales por sí solas no cuentan el logro y el costo de la victoria.
  - **Sacar «Historia» de §11 por completo:** abría la puerta a diálogos y cinemáticas, que Lucas dejó fuera.
  - **Enmendar §11 sin límites de largo:** los límites (3 líneas, 2 líneas, 3 a 5 de epílogo) son los que hacen que los textos sean «breves» y no una novela; sin límite, un texto de la comunidad podría tapar la pantalla.

## D-090 · Los textos viven en el archivo de cada nivel y la Wiki Lore se abre por niveles ganados, sin campos nuevos en el guardado
- **Fecha:** 2026-10-08 · **Estado:** Propuesta en la spec (RF-464 a RF-473, M52), **a la espera del OK de Lucas** · **Decidió:** Lucas (la forma general: texto de entrada/victoria por nivel, Lore en la Wiki que se desbloquea y epílogo en el 15; Q-01 y 07 §1, §2 y §12) / Claude (el detalle: formato, límites, cartel, desbloqueo y recomendaciones de las preguntas P1 a P8 de M52)
- **Qué:**
  - El campo opcional **`"textos"`** vive **en el JSON del nivel**, con `lugar`, `entrada`, `victoria` y `epilogo` (límites de RF-464). Es un dato como la leyenda: lo conserva el editor, lo valida `check_level` y un mapa de la comunidad lo puede traer.
  - La entrada es un **cartel al empezar** que **pausa** la partida mientras se lee, se omite con un toque y no vuelve al reintentar. La victoria sale en la pantalla de victoria; el lugar, en la tarjeta de selección (solo si el nivel está desbloqueado).
  - La Wiki suma **«Lore»**: artículos en `data/wiki/lore/*.json` con una clave `"desbloqueo"` (el id del nivel que los abre). Se abren con `SaveManager.is_completed`: **no hay campos nuevos en el guardado**.
  - El **epílogo** es un botón en la pantalla de victoria del último nivel, que abre una pantalla con la imagen, el texto y «Créditos» (`data/creditos.json`). «Campaña terminada» se **deduce** (los 15 niveles completados).
  - Los textos mismos viven en **un solo documento**, `specs/11-textos-lore.md`, y las tareas los copian tal cual.
- **Por qué:**
  - **En el archivo del nivel, no en un archivo aparte:** un nivel nuevo (o un mapa de la comunidad) trae su historia con él, sin tocar código ni otra lista (constitución P2 y P10). Es lo que dice el pedido: «salvo que el mapa los traiga».
  - **Pausar mientras se lee:** un cartel que no pausa obliga a leer con la cuenta atrás corriendo; un jugador de celular perdería segundos. No es el menú de pausa: no cambia ninguna regla.
  - **Reintentar sin cartel:** el cartel es para entrar al nivel; repetirlo cinco veces cansa y empuja a saltearlo siempre.
  - **Desbloquear por nivel ganado y no por un campo nuevo:** el guardado ya sabe qué niveles se ganaron. Así los guardados viejos abren los artículos retroactivamente, no hay migración y no hay nada que se pueda desincronizar.
  - **Un solo documento de textos:** los textos se corrigen y se aprueban en un lugar; evita que la spec, la ficha de cada nivel y los JSON digan cosas distintas.
- **Alternativas descartadas:**
  - **Un archivo de textos aparte (`data/lore.json`) con todos los niveles:** el mapa de la comunidad no podría traer sus textos, y renombrar o sumar un nivel obligaría a tocar dos archivos.
  - **Que el cartel no pause:** más simple, pero castiga la lectura (ver arriba).
  - **Guardar «visto» por texto o por artículo:** un campo más en el guardado y una migración, sin ganancia: reaparecería lo que ya se vio solo si se borra el guardado, que es lo esperable.
  - **Un estado «campaña terminada» en el guardado:** se deduce sin guardar nada y no puede quedar mal.
  - **Un modo «ver historia» aparte, con todos los textos en fila:** es una pantalla nueva que nadie pidió. La Wiki Lore cumple ese papel para el que la quiera releer.
  - **Mostrar los textos también en Asedio:** Asedio reusa los mapas con monstruos más fuertes; «asegurar este lugar» no es lo que pasa ahí (decide Lucas, P2).

## D-091 · Bloque 3 (niveles 11 a 15): fichas por datos, rotación sin Ametralladora, central de cuatro dibujos y las dudas de G4 marcadas
- **Fecha:** 2026-10-08 · **Estado:** Propuesta en la spec (RF-474 a RF-480, §7.13 a §7.17), **a la espera del OK de Lucas** · **Decidió:** Lucas (la rotación, Q-29; Chamán en el 11 y Espejo en el 12, Q-35; jefe supremo nuevo en el 15, Q-32 ✎; Disruptora desde el 11 con su balance a reevaluar ahí, T217; recursos desde el 7 y Mortero en el 9, Q-18 ✎ y Q-21 ✎) / Claude (el detalle de las fichas y los valores iniciales)
- **Qué:**
  - Los niveles **11 a 15** tienen el campo `"torres"` con las del juego **menos la Ametralladora** (Q-29); la Disruptora, el Mortero y el Mecánico entran en la lista y la colección de las dos que la tienen sigue mandando (RF-395).
  - Cada nivel tiene su **ficha de 9 puntos** (07 §3) como subsección de §7 y su RF de campaña. Las fichas dicen **qué** debe tener cada mapa y los **números iniciales**; las coordenadas y las oleadas las arma cada tarea con el bot.
  - **Debuts:** Chamán en el 11 y Espejo en el 12, **solos** en su primera oleada (07 §4); el 13 es **cómo vienen** (la escolta coordinada, solo con oleadas, RF-203); el 14 junta todo; el 15 deja un **hueco** para el jefe supremo de T243.
  - **La central de energía** se arma con **cuatro dibujos de 64 × 64** al lado de la salida, sin sistema nuevo de objetos grandes.
  - **Lo que depende de la partida de Lucas del 6 al 10 (T226, G4) está marcado «A REVISAR TRAS G4»:** (a) si la demolición convence, (b) si el Mortero del 9 se alcanza y (c) si la Disruptora rinde. Se confirman antes de arrancar cada nivel.
- **Por qué:**
  - **Fichas por datos y no un mapa dibujado:** las coordenadas de los niveles 6 a 10 se rehicieron varias veces con el bot (T223 a T225 y T245). Fijar casillas acá, sin que Lucas haya jugado el 6 al 10, sería fijar lo que probablemente cambie.
  - **Sin Ametralladora desde el 11:** es la rotación que pidió Lucas (07 §4: «algunas torres baratas o repetidas pueden retirarse»); el riesgo es la apertura, y por eso la comprueba el bot con la regla de RF-475.
  - **El hueco del jefe supremo:** Lucas pidió que su diseño sea de T243 y que **nadie lo invente** fuera de esa spec. *(Resuelto el 2026-10-09: D-092, el Coloso.)*
  - **La central como cuatro dibujos:** un objeto grande de verdad (que ocupe 2 × 2 casillas con un solo dibujo) es un sistema nuevo de decoración; con cuatro cuartos se resuelve con lo que la leyenda ya hace.
  - **Marcar G4 en vez de esperar:** Lucas pidió dejar la spec lista para su OK sin frenar por la partida; marcar cada punto dudoso permite aprobar lo firme hoy y corregir lo marcado después.
- **Alternativas descartadas:**
  - **Esperar a G4 para escribir las fichas:** frena el lore y los textos, que sí están firmes.
  - **Fichas con las coordenadas y las oleadas completas:** se rehacen al medir; solo suman ruido a la revisión de Lucas.
  - **Retirar más torres en el bloque 3 (por ejemplo la Ráfaga):** Q-29 retiró solo la Ametralladora; más cambios empeoran la apertura y el 07 no los pide.
  - **La central como la salida del mapa:** exige un objeto de salida nuevo y tocar el recorrido; es un sistema nuevo.
  - **Que el 15 repita el Soberano con escolta:** la respuesta Q-32 de Lucas cambió esto (jefe supremo nuevo).
  - **Agregar el Lanzamisiles al 13:** Q-28 lo dejó para una actualización posterior.

## D-092 · El jefe supremo del nivel 15 es el Coloso: una masa de piedra que se parte en tres pedazos, con datos que ya existen
- **Fecha:** 2026-10-09 · **Estado:** Aprobada por Lucas (concepto, vidas, oleadas, nombre y pertenencia) · **Decidió:** Lucas (eligió el concepto C y aceptó las propuestas de las otras cuatro preguntas del informe de T243, el 2026-10-09) / Claude (los conceptos, los números iniciales y el texto)
- **Qué:**
  - El nivel 15 trae al **Coloso** (`colossus`) y a su **Pedazo** (`colossus_shard`) en lugar del Soberano (RF-481 a RF-484, §7.17). El Coloso tiene 600 de vida base, velocidad 0.5, armadura 5 y resiste la mitad de la ralentización; al morir por daño **suelta 3 Pedazos** (180 de vida, velocidad 1.0, sin armadura) con `death_spawn` (RF-166). **Quita 12 de las 20 vidas** si llega; cada Pedazo, 4.
  - Aparece en las oleadas **26, 28 y 30**; la **escolta completa** (Guardián + Curandero + Chamán) viene **solo con la 30**. Las cantidades exactas las cierra T234 con el bot.
  - **Nombre «Coloso»** (nombre de informe, por el tamaño) y **pertenencia ambigua** a los Moradores, como el Espejo: el juego no lo aclara y el Coloso no lleva el símbolo A.
  - **No hay sistema nuevo ni campo nuevo en `EnemyData`:** son dos archivos de datos, un dibujo del cuerpo y otro del Pedazo (con ciclo de caminata), y el texto de la Wiki Lore.
- **Por qué:**
  - **Es un cierre y no «un jefe más» (10 §4.4, punto 1).** La ficha del 15 dice que el nivel no enseña nada nuevo, sino que **junta lo aprendido**. El Coloso castiga a quien juega con una sola idea: la primera mitad pide golpe fuerte (la lección del Blindado) y la segunda pide área y ralentización (la lección del Hielo, el Cañón y la Araña). Ninguno de los otros jefes obliga a tener las dos cosas a la vez.
  - **Tiene función propia.** El Soberano es vida y armadura; el Guardián, aura; el Chamán, sabotaje. «Se parte» es una función que nadie tiene.
  - **No exige nada nuevo** (la ficha de T243 manda frenar si hacía falta un sistema). `death_spawn` ya existe, está probado con la Araña y las Crías, y la Wiki ya sabe escribir «Al morir suelta» y «Lo suelta al morir».
  - **La contramedida está entre las torres comunes** (Francotirador, Cañón, Incendiaria, Hielo, Tesla), así que `sin_recursos` puede ganarle sin Disruptora, Mortero ni Mecánico (ficha del 15, punto 8).
  - **12 vidas de 20:** una sola fuga lo deja en el límite y dos pierden la partida, así que es «la amenaza más grande del juego» (más que las 10 del Soberano) sin ser una derrota automática. **3 Pedazos × 4 vidas = 12**: matarlo y dejarlo pasar cuestan lo mismo en el peor caso, y nadie queda castigado por haberlo roto.
  - **Oleadas 26, 28 y 30 y escolta completa solo en la 30:** el jefe se anuncia, se aprende y recién en la última oleada se combina con todo (07 §4: primero se enseña la amenaza, después se combina).
  - **Pertenencia ambigua:** un gólem de la misma piedra que los Guardianes haría la escolta más natural, pero lo acercaría a «el líder de ellos», y el tono de la biblia (10 §8) pide **no tener un villano**. Un cuerpo que se parte no tiene intención ni mensaje: avanza.
- **Alternativas descartadas:**
  - **A · «El Custodio» (el muro que avanza):** un gólem con 700 de vida, armadura 4 y un aura más grande que la del Guardián. Es **un Soberano con aura** y repite la función del Guardián, que la ficha pedía no repetir; se sentía como «el jefe de siempre, más grande». Queda como plan B barato si T244 no llegara a dibujar dos cuerpos; no hizo falta.
  - **B · «El Vocero» (el gran sabotaje):** un Chamán mayor que aturde **4 torres** a la vez. Repite la función del Chamán y, con poca vida, es más molesto que peligroso; subirle la vida lo vuelve un Chamán gordo. Además **necesitaba un campo nuevo** (`stun_targets` en `EnemyData`) y un cambio de código. Si Lucas quiere un Chamán mayor, queda para una entrega futura.
  - **Una mezcla** (el informe ofrecía, por ejemplo, el Coloso con el aura de A): Lucas eligió el concepto C tal cual. Un aura sobre el Coloso repetiría la función del Guardián, que es justamente lo que se le criticaba a A; la armadura de aura de los demás la sigue poniendo el Guardián de la escolta.
  - **Más de 12 vidas, o menos:** con 20 o más, una sola fuga pierde; con 10 o menos, es el Soberano. Con 12 la decisión de dejarlo pasar o romperlo importa.
  - **Que el Pedazo no tenga ficha propia en la Wiki:** la Cría la tiene y el Pedazo es un enemigo distinto (sin armadura, rápido); sin ficha, quien lo ve por primera vez no sabría qué es.

## D-093 · El tope de letras de la leyenda de un nivel sube de 10 a 12 (el nivel 15 necesita 12)
- **Fecha:** 2026-10-09 · **Estado:** Aplicada en T234 · **Decidió:** Claude (Sonnet 5.5), dentro de lo que la spec de M50 ya dejaba previsto («si un nivel se pasa, el tope se sube en la tarea del nivel con una `D` nueva», riesgo 6); Lucas lo ve en el Resultado de T234.
- **Qué:** `LevelFile.MAX_LEGEND` pasa de **10 a 12** letras (RF-262, RF-265, RF-399 y RF-434). Es el único cambio: los mapas que ya existen tienen 7 letras o menos, así que cargan igual; el editor avisa «La leyenda ya tiene 12 letras» en lugar de 10.
- **Por qué:** la ficha del 15 (§7.17) pide **cuatro cuartos de la central** (`central_1` a `central_4`, una letra cada uno, P5 de M52), **de 2 a 4 piezas de la cadena de abastecimiento**, **una mina**, **un bosque explotable** (las dos fuentes comparten letra), **removibles**, **`campamento_vacio`** y **`roca_marcada`**. Con el mínimo de dos piezas de la cadena son 11 letras; con la tercera, que ayuda a que la cadena se lea de punta a punta del borde, son 12. Son 12 y no 11 para dejar el tope redondo.
- **Alternativas descartadas:**
  - **Sacar la `roca_marcada` del 15** para quedarse en 10: la ficha la pide («de nuevo, como en el 1») y es la única señal que cierra el círculo con el nivel 1.
  - **Un solo cuarto con un dibujo de 128 × 128:** exige un objeto grande nuevo (P5 de M52 lo descartó: es un sistema nuevo).
  - **Compartir letra entre las piezas de la cadena:** se perdería la diferencia entre depósito, poste y vagoneta, que es justamente lo que cuenta la cadena.
  - **Subir el tope a un número mayor:** 12 alcanza y un mapa de la comunidad con más letras que eso ya es difícil de leer.
- **Qué cambia:** `scripts/logic/level_file.gd` (la constante), los tests de la leyenda y del editor (que ahora leen la constante), `01-spec.md` (RF-265, RF-399, RF-434 y el riesgo 6 de M50), `CONTENIDO.md`. **Los mapas de la comunidad hechos con 11 o 12 letras se rechazan en una versión anterior del juego** (como pasó con la clave `"leyenda"` en RF-267).

## D-094 · La Cuadrilla: una banda de criaturas independientes (Rateros y Cargador), con datos que ya existen, en los niveles 7, 10, 13 y 14
- **Fecha:** 2026-10-10 · **Estado:** Aprobada y **cargada en T253** (2026-10-10). Lucas aprobó el concepto (opción A del informe de T251, y que entre en la V1) y, el mismo día, los niveles 7, 10, 13 y 14, los nombres, las frases, el artículo de la Wiki y el arte provisional (P1, P3, P4, P5 y P6 de M55). **Queda abierta P2 (Asedio 7):** hoy hereda la Cuadrilla · **Decidió:** Lucas (el concepto, que sean criaturas independientes sin jefe ni símbolo A, que entre en la V1 y que quede como semilla para la v2 en 3D) / Claude (los niveles, los números iniciales, los textos y el artículo de la Wiki, medidos con el bot en T252)
- **Qué:**
  - El juego suma dos enemigos, el **Ratero** (`ratero`: 14 de vida, velocidad 2.2, 1 vida, roba 2 de oro cada 2 s) y el **Cargador** (`cargador`: 110 de vida, velocidad 0.9, armadura 1, 2 vidas, roba 4 de oro cada 2 s), que forman **La Cuadrilla** (RF-485 a RF-491, M55). Son criaturas **independientes**: **no son Moradores, no llevan el símbolo A y no tienen jefe**.
  - Entran en los niveles **7** (donde debutan), **10**, **13** y **14**, con **cuatro apariciones** por nivel (6 Rateros + 1 Cargador, 8 + 1, 8 + 1 y 10 + 2) en oleadas sin auras ni jefe. No entran en el 6, el 8, el 9, el 11, el 12 ni el 15.
  - Un artículo nuevo de la Wiki Lore, **«La Cuadrilla»** (el 11, se abre al ganar el 7), y una **semilla** en la biblia para la v2 en 3D (sin preparar nada de 3D).
  - **No hay campo ni sistema nuevo:** el robo (`gold_drain_*`, RF-363) ya existe y `optional_wave_limit` queda en 0.
- **Por qué:**
  - **Respeta la biblia sin enmiendas.** La capa 2 (criaturas independientes) «no obedece a nadie» (07 §2.3), y el Ladrón ya demostró que una criatura puede robar sin ser un Morador. Una banda que **no se manda a sí misma** conserva eso; una «tribu» no (ver abajo).
  - **Es otra especie y no «más Ladrones».** El artículo aprobado de la Wiki dice que el Ladrón **«va solo»**: con una especie nueva ese texto sigue siendo cierto y no hay que corregir nada que Lucas ya aprobó.
  - **Tiene dientes, medido.** T251 dudaba de que el robo mordiera (el bot deja miles de oro sin gastar). Con el bot, la Cuadrilla roba **326 a 807 de oro por partida** en los niveles propuestos, contra **21 a 66** del Ladrón solo: es de **8 a 16 veces más**. Las cuatro apariciones, si el bot las mata todas, le dan unos 310 de oro: en neto **cuesta oro**, sin dejar al jugador sin nada.
  - **Dos tamaños obligan a cubrir con dos cosas.** El Ratero (rápido, sin armadura) se barre con área y Hielo; el Cargador (armadura 1, lento, mucha vida) pide daño sostenido o golpe fuerte. Una defensa de una sola idea deja pasar a uno de los dos. La contramedida está **entre las torres comunes**, así que `sin_recursos` puede ganar (RF-432).
  - **Los niveles salen de las mediciones, no de las ganas** (informe de T252, 135 partidas): con las dos formas de armar la oleada, **el 7, el 10, el 13 y el 14** ganan 5 de 5 y terminan con 3 vidas o más; el **14 sigue en 3 y el 15 en 2**, así que el 15 sigue siendo el más difícil (RF-475, punto 3). Además, el 7 y el 10 **no estrenan otro enemigo** (RF-453) y el 7 es el nivel con más holgura (16 vidas). El **6 se rompe** (0 de 5).
  - **No arregla Asedio, y se dice.** Lucas propuso un grupo nuevo pensando en Asedio (T251); el informe mostró que ningún grupo nuevo hace ganable Asedio al 115 %. La Cuadrilla entra por lo que le aporta al juego y al lore, no como arreglo de Asedio (M55, «Lo que M55 no incluye»).
- **Alternativas descartadas:**
  - **B · «Los Correos»** (un enemigo de los Moradores que corre y quita 3 vidas por fuga): exige **enmendar la biblia** (un cuarto oficio) y Lucas eligió A. Queda como idea del informe de T251.
  - **C · «Las Luminarias»** (inmunes al Hielo): es la que más riesgo tiene de romper la regla de oro (el bot abre con Cañón + Hielo, T229), pide dibujar luz con alfa y no se eligió. Sin fecha.
  - **Una «tribu de ladrones» de los Moradores** (capa 3): convertiría a los habitantes en ladrones, que es lo que 10 §8 pide evitar («ni habitantes villanos»), y exigiría la misma enmienda de la biblia que B.
  - **Más Ladrones, sin enemigo nuevo** (subir las apariciones del que ya hay): contradice el texto aprobado «va solo», no trae el segundo tamaño y su tope de uno por oleada (RF-364) es justamente lo que lo vuelve un hecho aislado.
  - **Un solo enemigo nuevo** (un «Ladrón de banda»): sin el contraste Ratero/Cargador la jugada es el Ladrón multiplicado y alcanza con área; el segundo tamaño es lo que obliga a combinar.
  - **Un cabecilla o un aura de la banda** (velocidad compartida, mando): pide **código nuevo** (campo en `EnemyData` y cambios en `enemy.gd`) y contradice «no obedecen a nadie». T251 §4.4 ya lo había descartado.
  - **Que tengan probabilidad, como el Ladrón** (RF-364): el debut tiene que verse **siempre** en la oleada que lo trae (07 §4: enseñar antes de exigir), y la medición con 5 semillas no puede depender de que salga o no.
  - **Un párrafo nuevo en el artículo 5 de Lore** (lo que proponía el informe de T251): ese artículo se abre al ganar el 6 y la Cuadrilla debuta en el 7, y **un artículo nunca nombra algo que debuta después de su nivel** (`11-textos-lore.md` §4). Además el artículo 5 está aprobado. Va en un **artículo propio**.
  - **Debutar en el 11 o el 12** (donde el oro es más justo, como sugería el informe): con la Cuadrilla el 11 y el 12 **terminan a 2 vidas, empatando con el 15** en alguna de las dos formas de armar la oleada, y ya debutan al Chamán y al Espejo.
  - **Debutar en el 10** (la mina, «lo que brilla»): RF-453 dice que el 10 **no estrena enemigos** a propósito (cierra el bloque con extracción y pieza). Se mantiene como cuarta aparición, no como debut.
  - **Entrar también en el 8 y el 9, o en todos del 6 al 14:** el 6 **pierde 5 de 5**; el 8 y el 9 ganan sumando la Cuadrilla, pero con la **misma vida total** (reemplazando relleno) terminan con **1 a 4 vidas**, al borde de un precipicio.
  - **Solo en Asedio:** los textos no se ven ahí (RF-468), no se cuenta nada del lore, y no arregla Asedio.
  - **En el 15:** ya tiene al Coloso y termina con 2 vidas; el pedido fue no tocarlo.
- **Qué cambia:** `01-spec.md` (M55, RF-485 a RF-491; una línea en B-07), `10-universo.md` (§4.2, §7 y §9: la Cuadrilla y la semilla), `11-textos-lore.md` (§4.11, borrador), `02-plan-tecnico.md` (M55), `03-tareas.md` (T252 hecha; T253 y T257 pendientes), `08-plan-cierre-v1.md` (tres filas), `specs/tareas/T253-cuadrilla-datos-y-reajuste.md` y el informe `specs/tareas/informes/T252-medicion-cuadrilla.md`. **No cambia ningún dato ni código:** los `.tres`, las oleadas, el artículo de la Wiki y los tests los hace T253.

## D-095 · Asedio con los 15 mapas y un porcentaje de vida por mapa (115 % global y una tabla opcional por id de mapa)
- **Fecha:** 2026-10-10 · **Estado:** Estructura aprobada por Lucas; **los números de la tabla son iniciales** (medidos en T255 sin La Cuadrilla; los mapas 7, 10, 13 y 14 a remedir), a la espera de G5 · **Decidió:** Lucas (conservar los 15 mapas y la campaña, 115 % global y una tabla opcional de porcentajes por id de mapa) / Claude (formato, validación y valores iniciales, medidos con el bot en T255). **Revisa D-078** y conserva su historial.
- **Qué:**
  - El modo oficial **Asedio** pasa de los mapas 1 a 9 a los **15 mapas de la campaña**, con sus mismas oleadas, caminos y enemigos y **sin copiar ningún mapa** (RF-493).
  - El `modo.json` gana, dentro de `"reglas"`, una **tabla opcional `"vida_monstruos_por_mapa_%"`** con un porcentaje entero por id de mapa. Para cada mapa vale **primero la tabla, después `vida_monstruos_%` y después 100** (RF-492). La `"version"` sigue en 1 y todos los paquetes que ya existen cargan igual.
  - `vida_monstruos_%` queda en **115 %** como regla global y la tabla trae **13 excepciones**: 105 % en los mapas 1, 2 y 3; 108 % en el 5; 101 % en el 6, 8, 9, 11 y 13; 103 % en el 7; 110 % en el 12; 118 % en el 10 y el 14. Los mapas **4 y 15** toman el 115 % global (RF-494).
  - El margen de cada mapa se comprueba con el bot, **cinco semillas, política fija por mapa y tres vidas o más** (RF-495).
  - **La campaña no cambia.**
- **Por qué:**
  - **Un solo número no alcanza.** Con 115 % para todos, el bot gana **3 de 15 mapas** y, aun mejorando torres, **6 de 15** (T255). Con la tabla gana **75 de 75** partidas (cinco semillas en cada uno de los 15 mapas). Los porcentajes que dejan al bot ganando con margen van **de 101 % a 118 %**: cada mapa multiplica una base de vida distinta, así que no se pueden juntar bajo un número.
  - **Resuelve el pendiente de T235.** Lucas había dicho que Asedio tuviera los 15 (Q-37) y T235 frenó porque el bot no ganaba el 10 a 15 al 115 %, con las opciones de dejarlo en 9, sumar solo el 10 y el 12, sumar los 15 igual o bajar el porcentaje de los últimos. Esta decisión es **«los 15, con porcentaje por mapa»**: no pierde ningún mapa ni toca la campaña.
  - **No hay que tocar nada de la campaña ni de sus niveles.** Se conservan sus oleadas, y su regla de oro y sus tablas del bot (RF-432, RF-475) quedan como estaban.
  - **Cambia lo mínimo del formato:** una clave opcional dentro de `reglas`, validada con las mismas reglas de `vida_monstruos_%` y el mismo lector. Un id desconocido es un error, no se ignora.
  - **Los valores salen de datos y no de las ganas,** con cinco semillas por mapa. El caso del mapa 14 lo muestra: **122 %** ganaba con una semilla y perdía las otras cuatro, mientras que **118 %** gana las cinco. Se usó el segundo.
  - **Se conserva la honestidad sobre lo que no se sabe.** La tabla no demuestra que Lucas sienta bien la progresión (nadie la jugó) ni una curva estricta mapa por mapa (el 4 recompensa mejorar temprano, el 7 deja más vidas que el 6): solo que **el bot gana con margen y los bloques bajan** (16,00 · 11,72 · 6,84 vidas). Por eso es «inicial» y se juega en G5.
- **Alternativas descartadas:**
  - **Dejar Asedio en 9 mapas** (opción a de T235): sacrifica seis mapas ya hechos y contradice lo que Lucas pidió en Q-37.
  - **Sumar solo el 10 y el 12** (opción b de T235): son los únicos de esos seis que el bot gana en la campaña con `mix`, pero así se elige por lo que gana el bot y no por lo que Lucas quiere para el modo; tampoco arregla los mapas 1 a 9, donde el 115 % ya deja al bot con 3 vidas en el 1 y lo hace perder el 2, el 4, el 6, el 7, el 8 y el 9 (sin mejoras, T255).
  - **Un porcentaje único más bajo** (por ejemplo 105 % o 101 %): con 101 a 105 % el bot gana la apertura, pero **los mapas 10 y 14 quedarían con mucho margen** (al 115 % y mejorando, el bot los gana con 10 y con 12 a 14 vidas) y recién se acercan al borde con 118 %: con un solo número unos mapas quedan regalados y otros imposibles.
  - **Seis copias de los mapas 10 a 15 con menos aumento de vida por oleada** (la alternativa de T255 §5): **no necesita código** (RF-388 ya busca los mapas en la carpeta del modo) y mantiene la apertura al 115 %, pero **no corrige los picos de 1 a 9**, hay que **sincronizar las copias** cada vez que cambie la campaña y el modo deja de ser «mismas oleadas». Queda como **plan B** si Lucas prefiere no extender el formato, copiando solo los mapas que el 115 % no deja ganar y con la validación de cinco semillas.
  - **Un campo `vida_monstruos_%` dentro del JSON de cada nivel:** `LevelFile` **no lo acepta** y haría que un mapa de la campaña o de la comunidad traiga una regla que es del modo.
  - **Convertir `"mapas"` en una lista de objetos** (`{"mapa": "level_07", "vida_%": 103}`): rompe el formato de la versión 1 y todo lector existente, y obliga a subir la versión del paquete sin necesidad.
  - **Porcentajes por bloque** (`"1-5": 105`): más corta, pero **se mueve sola** si se reordena o se suma un mapa; por id es explícito.
  - **Escribir los 15 porcentajes, incluidos el 4 y el 15:** el global dejaría de significar algo y mover el 115 % no mueve a esos dos. Se escriben las 13 excepciones.
  - **Bajar la dificultad de la campaña para que el bot de la regla de oro gane el mapa 2:** el mapa 2 lo pierde `sin_recursos` por su orden de compra y lo gana `smart` (T236), no es un fallo del juego.
  - **Hacer que el bot de referencia mejore siempre y cambiar así las tablas de campaña:** se confundiría el instrumento con la dificultad. Las variantes con mejoras se **suman** como opciones de la herramienta; la referencia histórica (`sin_recursos` sin mejoras) queda (RF-495, punto 6).
- **Qué cambia:** `01-spec.md` (M56, RF-492 a RF-496; notas en el encabezado de M49 y en RF-388, RF-389, RF-390, RF-391, RF-392, RF-432, RF-475 y RF-491), `02-plan-tecnico.md` (M56), `03-tareas.md` (T256 hecha; T258 pendiente; una nota en T235), `08-plan-cierre-v1.md` (dos filas), `09-decisiones-pendientes-v1.md` (una línea en Q-37), `specs/tareas/T258-asedio-porcentajes-por-mapa.md` y el informe `specs/tareas/informes/T255-curva-dificultad-asedio.md` como respaldo. **No cambia ningún dato ni código:** el `modo.json`, `ModePacks`, el bot y los tests los hace T258.

## D-096 · La intro es una pantalla de siete láminas con texto abajo, hecha con un archivo de datos, que se ve una vez al tocar «Jugar» y se vuelve a ver desde la Wiki
- **Fecha:** 2026-10-11 · **Estado:** Propuesta, a la espera del OK de Lucas (G6; P1 a P5 de M57) · **Decidió:** Lucas (qué es: una mini película casera de láminas con el texto abajo, con sensación de nave y de viaje, que termina en una panorámica del oasis y sigue con el mapa jugable; entra en la 1.0; se ve la primera vez que se toca «Jugar», se omite siempre, se vuelve a ver y avanza con un toque o sola) / Claude (el guion, los números, el campo del guardado, el destino al terminar y dónde se vuelve a ver). **No revisa D-089:** la intro ya estaba permitida (Q-01) con los mismos límites.
- **Qué:**
  - La intro es una pantalla con **siete láminas quietas** (imagen 16:9 y, abajo, 1 o 2 líneas de texto) y un fundido entre una y otra. Las láminas, los textos y las duraciones salen de **`data/intro/intro.json`** (de 5 a 8 láminas, 90 caracteres por línea y 160 en total, de 4 a 12 segundos) (RF-497). El guion está en `specs/intro/guion.md`.
  - **Se ve sola una vez:** al tocar «Jugar» si el guardado no tiene `"intro_seen": true`, una clave **nueva y aditiva** (sin subir `SAVE_VERSION`). Se marca **al abrirse**. Un guardado anterior la ve una vez. En el modo de pruebas no salta sola (RF-498).
  - **Se maneja con un toque o sola**, y siempre se puede omitir: botón «Omitir», `Esc` y el «atrás» de Android. La lámina se ve entera y la música de menú sigue (RF-499).
  - **Al terminar:** el **nivel 1** si el guardado no tiene niveles ganados; la **selección de niveles** si ya los tiene (RF-500).
  - **Se vuelve a ver** con un botón «Ver la intro» en la **solapa Lore de la Wiki**, sin tocar el guardado (RF-501).
  - **Nunca bloquea jugar:** si el archivo falla, «Jugar» va a la selección de niveles como siempre.
- **Por qué:**
  - **Datos y no código.** La intro es contenido que Lucas va a querer corregir (un texto, una duración, una lámina): en un archivo se cambia sin programar y sin riesgo, igual que los textos de los niveles (D-090). Los números van en `data/` (`.claude/rules/gdscript.md`).
  - **Imágenes quietas con fundido** es lo que Lucas pidió («imágenes tipo diapositiva») y lo que Q-01 permite: **no hace falta animar nada** para dar sensación de viaje, la da el guion (una nave chica, años a bordo, motores que se apagan) y el color (el verde recién aparece en el final).
  - **«Se ve la primera vez» necesita recordarse**, y la única forma es un campo del guardado. Aditivo, como `collections` y `hall_total`: un guardado viejo lo lee como «no vista» y se ve una vez, que es lo que Lucas quiere para quien ya venía jugando; el guardado nuevo sigue cargando en la versión anterior.
  - **Se marca al abrirse y no al terminar** porque la intro se puede omitir siempre y quien cierra el juego a la mitad ya la vio lo suficiente; verla otra vez sola sería la molestia que Lucas quiere evitar. Si quiere verla de nuevo, el botón está.
  - **Al terminar, el nivel 1 y no la selección** porque con un guardado nuevo la selección solo tiene un nivel abierto: es un toque de más entre la última lámina (el oasis) y el mapa, justo donde Lucas quiere que «aparezca el mapa jugable». Con progreso guardado, la selección es lo que corresponde. *(Es la P1 de M57; si Lucas prefiere otra cosa, cambia RF-500 y nada más.)*
  - **«Ver la intro» en la Wiki y no en el menú principal.** El menú arma su alto con la cantidad de botones (RF-331) y en el celular ya está justo; la Wiki ya tiene la solapa de la historia (Lore) y es donde alguien que se la salteó va a buscarla. *(P2 de M57.)*
  - **El modo de pruebas no la dispara:** usa un guardado aparte (RF-181), así que en cada guardado de pruebas nuevo volvería a salir y estorbaría a quien prueba; quien la quiera, la pide en la Wiki. Igual criterio que RF-468 con los carteles.
  - **Un archivo roto no frena el juego.** La intro es un adorno: nadie tiene que quedar sin poder jugar porque un PNG falte.
- **Alternativas descartadas:**
  - **Una cinemática animada o un video:** la excluye Q-01 (D-089), pesa mucho en la APK y es lo opuesto a lo que Lucas pidió («diapositivas»).
  - **Un zoom lento sobre cada lámina:** no estaba en el pedido ni lo habilita Q-01; queda como sugerencia en §13 y **no se implementa** sin el OK de Lucas.
  - **Mostrarla cada vez que se abre el juego o con cada guardado nuevo:** cansa; Lucas pidió «la primera vez que se toca Jugar».
  - **Marcarla como vista al terminarla:** quien la omite a mitad la vería otra vez. Para el que la omite, «omitir» tiene que significar «ya está».
  - **Una casilla en Opciones para elegir:** más superficie para una pantalla que dura un minuto; el botón de la Wiki alcanza.
  - **Un botón «Intro» en el menú principal:** es lo que dice el pedido («o un botón Intro»), pero le saca alto al logo (RF-331) y no se justifica si la Wiki la ofrece. Queda como alternativa en P2.
  - **Ir siempre a la selección de niveles:** no es el «mapa jugable» que Lucas describió y suma un toque con un guardado nuevo.
  - **Que el texto vaya dibujado en la imagen:** lo pone el juego (legible a cualquier tamaño, corregible sin volver a dibujar, y T241 no depende de que Codex dibuje letras).
  - **Un campo `"intro_seen"` por perfil o por modo:** no hay perfiles; el guardado es uno (y el de pruebas, aparte).
  - **Subir `SAVE_VERSION`:** un cambio de versión descarta guardados (`save_manager.gd`: «se empieza de cero»); una clave aditiva no.
  - **Textos en `11-textos-lore.md`:** ese documento es el único lugar de los textos de los niveles y la Wiki, pero la intro necesita sus **ilustraciones, su hoja de continuidad y sus preguntas** al lado de cada texto. Se deja en `specs/intro/guion.md` y `11-textos-lore.md` lo apunta.
- **Qué cambia:** `01-spec.md` (M57, RF-497 a RF-501; §11 y M52 apuntan a ella; una sugerencia en §13), `02-plan-tecnico.md` (M57), `03-tareas.md` (T240 hecha a la espera del OK; T241 y T242 pendientes), `08-plan-cierre-v1.md` (fila de T240), `11-textos-lore.md` (una nota), `specs/intro/guion.md` (nuevo), y las fichas `specs/tareas/T241-arte-intro.md` y `specs/tareas/T242-intro-integracion.md`. **No cambia ningún dato ni código:** el archivo `intro.json`, las láminas, la pantalla, el botón de la Wiki y el campo del guardado los hacen T241 y T242.

## D-097 · El celular tiene su propio modo de interfaz: carrito y salir flotantes, barra de la torre elegida, torre fantasma con tilde y cruz, y zoom con los dedos
- **Fecha:** 2026-10-16 · **Estado:** Propuesta, a la espera del OK de Lucas sobre la spec M58 (las decisiones de fondo ya las tomó Lucas en G7) · **Decidió:** Lucas (qué: solo celular; carrito y X flotantes, arrastrables y pegados a un costado, con la posición guardada; barra de arriba sin «Menú»; barra de abajo como barra de la torre elegida, alternativa A de T263; torre fantasma con tilde y cruz, C1 de T264; zoom Z1; tarjetas con Insignias; PC igual que hoy; interruptor en Opciones; qué queda fuera) / Claude (los números, los casos de error, el campo del guardado y lo que figura en «Lo que decidí por defecto» de M58).
- **Qué:**
  - Un **modo de interfaz «celular»** distinto del de PC. Se elige solo (`OS.has_feature("mobile")`) y se puede forzar desde Opciones (**Automática / Celular / PC**, clave `ui_mode` en `settings`) para probar sin celular (RF-502).
  - **Nada se compra ni se elige al apoyar el dedo**; se decide al soltar, y dos dedos o un dedo que se movió más de 2 mm nunca construyen (RF-504).
  - **Colocar** en dos pasos: el catálogo (carrito) elige, el **fantasma** se mueve (toque o arrastre relativo) y la **tilde** construye; la **cruz** cancela; la torre se deselecciona al colocarla (RF-505, RF-510).
  - **Zoom** con pinza y dos dedos para desplazar, «Ver todo» solo en el celular; rueda y botón central en PC, sin botón (RF-506).
  - **Dos botones flotantes** (carrito y X) de 7,6 mm o más, arrastrables y pegados al borde, con la posición en una clave nueva **`ui_prefs`** del guardado (lado y altura; si falla la lectura, valor por omisión) y con reglas para no tapar el fantasma (RF-507 a RF-509, RF-511).
  - **Barra de abajo** = barra de la torre elegida, con estados vacía / fantasma / elegida, «Mejorar» y «Vender» en extremos opuestos, y **Vender con segundo toque** (RF-512, RF-513).
  - **Tarjetas de nivel con Insignias** en PC y celular (RF-514).
  - Los números sueltos (56, 64, 82 px, 2 mm, 150 ms, 3 s, 0,4 s, 0,35 s, 45 %) van en un archivo de datos y se ajustan después de la prueba real.
- **Por qué:**
  - **Porque hoy el celular es la PC achicada y se nota (T262):** botones de 3 mm, un panel que tapa el 13 % del mapa, y 11 de 49 toques corridos alrededor de «Mejorar» que **venden la torre**. Un modo propio permite arreglar el celular **sin tocar la PC**, que Lucas pidió que quede igual.
  - **Fantasma con tilde (C1) y no compra al apoyar** porque T264 midió que arrastrar o pinzar con una torre elegida hoy **compra por error** y que con tilde las compras por error de los ocho casos pasaron de 3 a 0. El arrastre relativo evita que el dedo tape el fantasma, y la tilde y la cruz van del lado contrario al botón para que tampoco los tape.
  - **Carrito flotante y no barra de torres fija** porque el catálogo ocupa el mapa solo cuando se compra; las tarjetas muestran nombre y costo y miden 18 × 10 mm (hoy 7,1 × 5,6 mm y sin nombre). Cuesta **un toque más** al cambiar de torre (T264 §4.2); Lucas lo aceptó al elegirlo.
  - **Botones flotantes arrastrables y pegados a un costado** porque la mano que juega, el tamaño del celular y la funda son de cada persona: nadie tapa su propio mapa si puede poner el botón donde le queda cómodo. Pegados al borde porque en el medio estorban.
  - **La barra de abajo con la torre elegida (A)** porque tapa **0 %** del mapa, deja «Vender» a unos 35 mm de «Mejorar» y combina con el zoom (no depende de dónde esté la torre en pantalla); B y C tenían que seguir a la torre al mover el mapa.
  - **La preferencia en el guardado y no en un archivo aparte:** el guardado ya es por dispositivo y se lee con tolerancia a errores (RF-115). Una clave aditiva no sube `SAVE_VERSION` (como `intro_seen` en D-096): un guardado viejo carga con los valores por omisión y uno nuevo carga en una versión anterior. `ui_mode` va en `settings` porque es una opción más; `ui_prefs` es aparte porque guarda texto y números que `settings` no admite hoy.
  - **El corrimiento automático de los botones es temporal:** si cambiara la preferencia, el botón quedaría en un lugar que el jugador no eligió.
- **Alternativas descartadas:**
  - **Un solo modo para todos (más grande y con zoom también en PC):** cambia lo que Lucas pidió que quede igual y no ayuda a la PC.
  - **Detectar el celular solo por `OS.has_feature("mobile")` sin interruptor:** no se podría probar en la PC de Lucas, que no tiene celular ni SVM para el emulador (G7, punto 9).
  - **Colocación automática protegida (C2 de T264):** más rápida (7 contra 11 toques en cinco torres) pero exige zoom antes de colocar y deja un «Deshacer» que toca reglas de oro y recursos. Lucas eligió C1.
  - **Compra al soltar el dedo sin fantasma (C0 corregido):** evita comprar al apoyar pero no deja corregir antes de pagar.
  - **Barra plegable (S3) o botones grandes en la barra (S1):** no liberan el mapa o no entran con 10 torres (T264 §4.2).
  - **Barra de torre como ficha junto a la torre (B) o panel al costado (C):** tapan el mapa justo alrededor de la torre y «Vender» queda a 1,3 mm de «Mejorar».
  - **Un solo botón flotante que despliega varias acciones (menú, pausa, velocidad):** Lucas dejó Pausa y x2 arriba y la X sola; un menú desplegable agrega un toque a cada acción.
  - **Un diálogo al vender:** el segundo toque en el mismo botón protege igual, sin una ventana más (B-34 pide menos diálogos).
  - **Guardar la posición de los botones en un archivo aparte o en `settings`:** el primero duplica la lectura tolerante; el segundo solo guarda números y booleanos hoy.
  - **Que los botones se pausen o desaparezcan con el fantasma:** no se ven si no hay forma de abrir el carrito o salir; semitransparentes y que se corran alcanza.
  - **Nuevas teclas o gestos de desplazamiento con un dedo:** un dedo ya selecciona y mueve el fantasma; desplazar con uno sería otra fuente de errores (T264, G3).
- **Qué cambia:** `01-spec.md` (M58, RF-502 a RF-515; notas en RF-104, RF-113, RF-143, RF-251 y RF-459; backlog B-40 a B-44), `02-plan-tecnico.md` (M58), `03-tareas.md` (T269 hecha; T270 a T277 pendientes), `CONTENIDO.md`, `README.md`, `ONBOARDING.md` y `CHANGELOG.md` (notas), y `12-plan-t262-t268.md` (estado). **No cambia ningún dato ni código:** el modo de interfaz, los botones, los gestos, el fantasma, el zoom, la barra, las tarjetas y el archivo de números los hacen T270 a T276.

## D-098 · Las estatuas decorativas de los mapas son estatuas de torres de piedra erosionada, no de personas con espada
- **Fecha:** 2026-10-16 · **Estado:** Propuesta (dirección decidida por Lucas; qué torres se esculpen, abierto: P6 de M58) · **Decidió:** Lucas (el cambio de concepto: «estatuas de las torres, no de hombres con espada, porque son nuestras armas y no hay hombres con espadas en el juego»; de las muestras de T267a, la estatua es la única que le convence) / Claude (el material, la casilla y la regla para no confundirla con el Estandarte).
- **Qué:** la estatua decorativa de los niveles 1, 3 y 5 (`assets/sprites/map/estatua.svg`) pasa a representar **torres**: **piedra gris erosionada** (con **musgo** en la pradera y **escarcha** en la nieve), con **pedestal**, de **una casilla**, **sin círculo de alcance**, **no seleccionable** y **distinta del Estandarte mecánico** (RF-515; regla de arte en `05-guia-de-arte.md` §9).
- **Por qué:**
  - **Lore y coherencia:** en el universo (`10-universo.md`) no hay personas con espada; las armas de la colonia son las torres. Una estatua de una torre cuenta que la Compañía las honra, sin inventar una cultura.
  - **Piedra y no metal** porque el Estandarte mecánico es una torre jugable «estatua de ingeniería» de hierro, plata y bronce (`10-universo.md` §3); la decoración tiene que leerse como **piedra vieja** a primera vista, para que nadie intente tocarla creyendo que es la torre de apoyo.
  - **Musgo y escarcha** porque los temas del mapa (§5 de la guía de arte) ya cambian la textura del suelo; la estatua tiene que vivir en el mismo clima.
  - **Sin círculo de alcance ni selección** para que ni siquiera al tocarla parezca una torre (y para que no se pueda construir encima como si fuera una).
- **Alternativas descartadas:**
  - **Conservar la estatua del hombre con espada:** Lucas la rechazó.
  - **Estatuas de metal o bronce:** se confundirían con el Estandarte y con las torres reales.
  - **Que las estatuas se puedan seleccionar y muestren una descripción:** agrega una interacción que nadie pidió y puede confundirse con el panel de torres.
  - **Una sola variante en todos los niveles:** posible y barata, pero queda como la pregunta P6 para que Lucas elija cuántas.
- **Qué cambia:** `01-spec.md` (RF-515), `05-guia-de-arte.md` (§9), `03-tareas.md` (T277). **No cambia ningún asset ni código:** el dibujo y su integración son T277, con muestras aprobadas por Lucas antes de integrarse.
