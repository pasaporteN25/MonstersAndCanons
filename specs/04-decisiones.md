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
